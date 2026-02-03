#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ IPv6 MODULE v3.1                                              ║
# ║  IPv6 Privacy Extensions Management                                       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

ipv6_privacy_auto_ensure() {
    draw_section_header "󰌾 IPv6 PRIVACY AUTO-ENSURE"

    # Ensure network-utils functions are available
    if ! declare -f discover_active_interface >/dev/null 2>&1; then
        source_lib "${CYTADELA_LIB}/network-utils.sh"
    fi

    local iface
    iface=$(discover_active_interface)
    if [[ -z "$iface" ]]; then
        log_warning "No active interface detected. Skipping."
        return 0
    fi
    log_info "Active interface: $iface"

    local ipv6_global
    ipv6_global=$(ip -6 addr show dev "$iface" scope global 2>/dev/null | grep -v temporary | awk '/inet6/ {print $2; exit}' || true)
    [[ -z "$ipv6_global" ]] && log_info "No global IPv6 on $iface. Ensuring sysctl is configured anyway."

    local ipv6_temp
    ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ && /preferred_lft/ {print $2; exit}' || true)
    local temp_preferred=0
    if [[ -n "$ipv6_temp" ]]; then
        local pref_lft
        pref_lft=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | grep -oP 'preferred_lft \K[0-9]+' | head -1 || echo "0")
        [[ "$pref_lft" -gt 0 ]] && temp_preferred=1
    fi

    if [[ $temp_preferred -eq 1 ]]; then
        log_success "Usable temporary IPv6 address found: $ipv6_temp"
        log_success "IPv6 Privacy Extensions are working correctly."
        return 0
    fi

    log_warning "No usable temporary IPv6 address. Applying remediation..."

    local sysctl_file="/etc/sysctl.d/40-citadel-ipv6-privacy.conf"
    log_info "Setting sysctl for IPv6 privacy extensions..."
    cat >"$sysctl_file" <<EOF
# Cytadela IPv6 Privacy Extensions
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.${iface}.use_tempaddr = 2
EOF
    sysctl --system >/dev/null 2>&1 || true
    log_success "Sysctl configured: use_tempaddr=2"

    local stack
    stack=$(discover_network_stack)
    log_info "Network stack: $stack. Triggering address regeneration..."

    if [[ "$stack" == "NetworkManager" ]]; then
        if command -v nmcli &>/dev/null; then
            log_info "Reconnecting $iface via NetworkManager..."
            nmcli dev disconnect "$iface" 2>/dev/null || true
            sleep 1
            nmcli dev connect "$iface" 2>/dev/null || true
            sleep 2
        fi
    elif [[ "$stack" == "systemd-networkd" ]]; then
        if command -v networkctl &>/dev/null; then
            log_info "Reconfiguring $iface via systemd-networkd..."
            networkctl reconfigure "$iface" 2>/dev/null || true
            sleep 2
        fi
    else
        log_warning "Unknown network stack. Sysctl applied, but you may need to reconnect manually."
    fi

    sleep 1
    ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ {print $2; exit}' || true)
    if [[ -n "$ipv6_temp" ]]; then
        log_success "Temporary IPv6 address now active: $ipv6_temp"
    else
        log_warning "Temporary address not yet visible. It may take a moment to appear."
        log_info "Check with: ip -6 addr show dev $iface scope global temporary"
    fi
}

ipv6_privacy_on() {
    log_section "󰌾 IPv6 PRIVACY ON"
    local iface
    iface=$(discover_active_interface)
    [[ -z "$iface" ]] && {
        log_error "No active interface"
        return 1
    }

    log_info "Enabling IPv6 Privacy Extensions on $iface..."
    cat >/etc/sysctl.d/40-citadel-ipv6-privacy.conf <<EOF
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.${iface}.use_tempaddr = 2
EOF
    sysctl --system >/dev/null 2>&1
    log_success "IPv6 Privacy Extensions enabled"
    ipv6_privacy_status
}

ipv6_privacy_off() {
    log_section "󰌿 IPv6 PRIVACY OFF"
    local iface
    iface=$(discover_active_interface)
    [[ -z "$iface" ]] && {
        log_error "No active interface"
        return 1
    }

    log_info "Disabling IPv6 Privacy Extensions on $iface..."
    cat >/etc/sysctl.d/40-citadel-ipv6-privacy.conf <<EOF
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.default.use_tempaddr = 0
net.ipv6.conf.${iface}.use_tempaddr = 0
EOF
    sysctl --system >/dev/null 2>&1
    log_success "IPv6 Privacy Extensions disabled"
    ipv6_privacy_status
}

ipv6_privacy_status() {
    log_section "󰍉 IPv6 PRIVACY STATUS"
    local iface
    iface=$(discover_active_interface)
    [[ -z "$iface" ]] && {
        log_error "No active interface"
        return 1
    }

    echo "Interface: $iface"
    echo "Sysctl use_tempaddr: $(sysctl -n net.ipv6.conf.${iface}.use_tempaddr 2>/dev/null || echo 'unknown')"

    local ipv6_addrs
    ipv6_addrs=$(ip -6 addr show dev "$iface" scope global 2>/dev/null)
    echo ""
    echo "IPv6 Addresses:"
    echo "$ipv6_addrs" | grep inet6 | while read -r line; do
        if echo "$line" | grep -q temporary; then
            echo "  [TEMP] $line"
        else
            echo "  [PERM] $line"
        fi
    done
}

ipv6_deep_reset() {
    log_section "󰜝 IPv6 DEEP RESET"
    local iface
    iface=$(discover_active_interface)
    [[ -z "$iface" ]] && {
        log_error "No active interface"
        return 1
    }

    log_info "Flushing IPv6 addresses on $iface..."
    ip -6 addr flush dev "$iface" scope global 2>/dev/null || true

    log_info "Flushing IPv6 neighbor cache..."
    ip -6 neigh flush dev "$iface" 2>/dev/null || true

    local stack
    stack=$(discover_network_stack)
    if [[ "$stack" == "NetworkManager" ]]; then
        log_info "Reconnecting via NetworkManager..."
        nmcli dev disconnect "$iface" 2>/dev/null || true
        sleep 2
        nmcli dev connect "$iface" 2>/dev/null || true
    elif [[ "$stack" == "systemd-networkd" ]]; then
        log_info "Reconfiguring via systemd-networkd..."
        networkctl reconfigure "$iface" 2>/dev/null || true
    fi

    log_success "IPv6 reset complete. Waiting for new addresses..."
    sleep 3
    ipv6_privacy_status
}

smart_ipv6_detection() {
    log_section "󰍉 SMART IPv6 DETECTION"
    local iface
    iface=$(discover_active_interface)
    [[ -z "$iface" ]] && {
        log_error "No active interface"
        return 1
    }

    log_info "Testing IPv6 connectivity..."
    if ping -6 -c 3 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        log_success "IPv6 connectivity: OK"
    else
        log_warning "IPv6 connectivity: FAILED"
        log_info "Attempting auto-reconfiguration..."
        ipv6_deep_reset
    fi
}

# Alias for compatibility with cytadela++.new.sh
smart_ipv6() {
    smart_ipv6_detection
}
