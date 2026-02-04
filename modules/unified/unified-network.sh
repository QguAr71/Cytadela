#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-NETWORK MODULE v3.2                                ║
# ║  Unified network configuration and tools                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

# IPv6 Privacy settings
IPV6_SYSCTL_FILE="/etc/sysctl.d/40-citadel-ipv6-privacy.conf"

# Edit tools settings
COREDNS_CONFIG="/etc/coredns/Corefile"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

# Port fixing settings
PORT_CHECK_TIMEOUT=5

# Notification settings
NOTIFICATION_CONFIG="${CYTADELA_STATE_DIR}/notifications.conf"

# ==============================================================================
# IPv6 PRIVACY FUNCTIONS (migrated from ipv6.sh, non-recovery)
# ==============================================================================

# Auto-ensure IPv6 privacy extensions
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

    local sysctl_file="$IPV6_SYSCTL_FILE"
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

# Enable IPv6 privacy extensions
ipv6_privacy_on() {
    log_section "󰌾 IPv6 PRIVACY ON"
    local iface
    iface=$(discover_active_interface)
    [[ -z "$iface" ]] && {
        log_error "No active interface"
        return 1
    }

    log_info "Enabling IPv6 Privacy Extensions on $iface..."
    cat >"$IPV6_SYSCTL_FILE" <<EOF
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.${iface}.use_tempaddr = 2
EOF
    sysctl --system >/dev/null 2>&1
    log_success "IPv6 Privacy Extensions enabled"
    ipv6_privacy_status
}

# Disable IPv6 privacy extensions
ipv6_privacy_off() {
    log_section "󰌿 IPv6 PRIVACY OFF"
    local iface
    iface=$(discover_active_interface)
    [[ -z "$iface" ]] && {
        log_error "No active interface"
        return 1
    }

    log_info "Disabling IPv6 Privacy Extensions on $iface..."
    cat >"$IPV6_SYSCTL_FILE" <<EOF
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.default.use_tempaddr = 0
net.ipv6.conf.${iface}.use_tempaddr = 0
EOF
    sysctl --system >/dev/null 2>&1
    log_success "IPv6 Privacy Extensions disabled"
    ipv6_privacy_status
}

# Show IPv6 privacy status
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

# ==============================================================================
# EDIT TOOLS FUNCTIONS (migrated from edit-tools.sh)
# ==============================================================================

# Edit CoreDNS configuration
edit_config() {
    log_section "󰏫 EDIT COREDNS CONFIG"

    if [[ ! -f "$COREDNS_CONFIG" ]]; then
        log_error "CoreDNS config not found: $COREDNS_CONFIG"
        return 1
    fi

    local editor="${EDITOR:-nano}"
    log_info "Opening $COREDNS_CONFIG with $editor..."
    log_warning "Remember to reload CoreDNS after changes: systemctl reload coredns"

    if [[ -t 0 && -t 1 ]]; then
        "$editor" "$COREDNS_CONFIG"
    else
        log_warning "Non-interactive mode - cannot open editor"
        log_info "Edit manually: $editor $COREDNS_CONFIG"
    fi
}

# Edit DNSCrypt configuration
edit_dnscrypt() {
    log_section "󰏫 EDIT DNSCRYPT CONFIG"

    if [[ ! -f "$DNSCRYPT_CONFIG" ]]; then
        log_error "DNSCrypt config not found: $DNSCRYPT_CONFIG"
        return 1
    fi

    local editor="${EDITOR:-nano}"
    log_info "Opening $DNSCRYPT_CONFIG with $editor..."
    log_warning "Remember to restart DNSCrypt after changes: systemctl restart dnscrypt-proxy"

    if [[ -t 0 && -t 1 ]]; then
        "$editor" "$DNSCRYPT_CONFIG"
    else
        log_warning "Non-interactive mode - cannot open editor"
        log_info "Edit manually: $editor $DNSCRYPT_CONFIG"
    fi
}

# Show system logs
show_logs() {
    log_section "󰸨 SYSTEM LOGS"

    local lines="${1:-50}"
    local service="${2:-}"

    case "$service" in
        coredns|dns)
            log_info "Showing CoreDNS logs (last $lines lines)..."
            if command -v journalctl &>/dev/null; then
                journalctl -u coredns -n "$lines" --no-pager
            else
                log_warning "journalctl not available"
            fi
            ;;
        dnscrypt|proxy)
            log_info "Showing DNSCrypt logs (last $lines lines)..."
            if command -v journalctl &>/dev/null; then
                journalctl -u dnscrypt-proxy -n "$lines" --no-pager
            else
                log_warning "journalctl not available"
            fi
            ;;
        nftables|firewall)
            log_info "Showing NFTables logs (last $lines lines)..."
            if command -v journalctl &>/dev/null; then
                journalctl -k --grep="nft" -n "$lines" --no-pager
            else
                dmesg | grep nft | tail -"$lines" || log_warning "No NFTables logs found"
            fi
            ;;
        *)
            log_info "Available log types: coredns, dnscrypt, nftables"
            log_info "Usage: logs [lines] [service]"
            log_info "Showing general system logs (last $lines lines)..."
            if command -v journalctl &>/dev/null; then
                journalctl -n "$lines" --no-pager
            else
                dmesg | tail -"$lines" || log_warning "No logs available"
            fi
            ;;
    esac
}

# ==============================================================================
# PORT FIXING FUNCTIONS (migrated from fix-ports.sh)
# ==============================================================================

# Fix port conflicts
fix_port_conflicts() {
    log_section "🔧 PORT CONFLICT FIXER"

    log_info "Checking for port conflicts..."

    local conflicts_found=0

    # Check DNS port 53
    if lsof -i :53 >/dev/null 2>&1; then
        local dns_process
        dns_process=$(lsof -i :53 | tail -1 | awk '{print $1}')
        if [[ "$dns_process" != "coredns" ]]; then
            log_warning "Port 53 in use by: $dns_process (expected: coredns)"
            conflicts_found=1
        fi
    else
        log_warning "Port 53 not in use - DNS may not be working"
    fi

    # Check DNSCrypt port 5353
    if lsof -i :5353 >/dev/null 2>&1; then
        local dnscrypt_process
        dnscrypt_process=$(lsof -i :5353 | tail -1 | awk '{print $1}')
        if [[ "$dnscrypt_process" != "dnscrypt-prox" ]]; then
            log_warning "Port 5353 in use by: $dnscrypt_process (expected: dnscrypt-proxy)"
            conflicts_found=1
        fi
    else
        log_warning "Port 5353 not in use - DNSCrypt may not be running"
    fi

    # Check common conflicting ports
    local common_ports=(53 5353 853 443)
    for port in "${common_ports[@]}"; do
        if lsof -i :"$port" >/dev/null 2>&1; then
            local process
            process=$(lsof -i :"$port" | tail -1 | awk '{print $1}')
            log_info "Port $port: $process"
        fi
    done

    if [[ $conflicts_found -eq 1 ]]; then
        log_warning "Port conflicts detected. You may need to:"
        log_info "  1. Stop conflicting services"
        log_info "  2. Change ports in configurations"
        log_info "  3. Restart Cytadela services"
        return 1
    else
        log_success "No port conflicts detected"
        return 0
    fi
}

# ==============================================================================
# NOTIFICATION FUNCTIONS (migrated from notify.sh)
# ==============================================================================

# Enable notifications
notify_enable() {
    log_section "󰵙 NOTIFICATIONS ENABLE"

    mkdir -p "$(dirname "$NOTIFICATION_CONFIG")"

    cat > "$NOTIFICATION_CONFIG" <<EOF
# Cytadela Notification Settings
enabled=true
service_health=true
blocklist_updates=true
security_events=true
EOF

    log_success "Notifications enabled"
    log_info "Configuration: $NOTIFICATION_CONFIG"
}

# Disable notifications
notify_disable() {
    log_section "󰵚 NOTIFICATIONS DISABLE"

    if [[ -f "$NOTIFICATION_CONFIG" ]]; then
        sed -i 's/enabled=true/enabled=false/' "$NOTIFICATION_CONFIG"
        log_success "Notifications disabled"
    else
        log_warning "Notification config not found"
    fi
}

# Show notification status
notify_status() {
    log_section "󰵛 NOTIFICATION STATUS"

    if [[ -f "$NOTIFICATION_CONFIG" ]]; then
        echo "Configuration file: $NOTIFICATION_CONFIG"
        echo ""
        echo "Settings:"
        while IFS='=' read -r key value; do
            [[ -z "$key" || "$key" == "#"* ]] && continue
            echo "  $key: $value"
        done < "$NOTIFICATION_CONFIG"
    else
        echo "Notifications: DISABLED (config not found)"
        echo "Run 'notify-enable' to enable notifications"
    fi
}

# Test notifications
notify_test() {
    log_section "󰵞 NOTIFICATION TEST"

    if [[ ! -f "$NOTIFICATION_CONFIG" ]] || ! grep -q "enabled=true" "$NOTIFICATION_CONFIG"; then
        log_warning "Notifications are disabled"
        return 1
    fi

    log_info "Sending test notification..."

    # Try different notification methods
    local notified=false

    # Try notify-send (desktop notifications)
    if command -v notify-send &>/dev/null; then
        notify-send "Cytadela Test" "This is a test notification from Cytadela" 2>/dev/null && notified=true
    fi

    # Try wall (system broadcast)
    if command -v wall &>/dev/null && [[ $notified == false ]]; then
        echo "Cytadela Test: This is a test notification" | wall 2>/dev/null && notified=true
    fi

    # Try logger (system log)
    if [[ $notified == false ]]; then
        logger "Cytadela Test: This is a test notification" && notified=true
    fi

    if [[ $notified == true ]]; then
        log_success "Test notification sent"
    else
        log_warning "Could not send notification - no supported method found"
    fi
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Discover active network interface
discover_active_interface() {
    # Try multiple methods to find active interface
    local iface=""

    # Method 1: ip route
    iface=$(ip route | grep default | awk '{print $5}' | head -1)

    # Method 2: NetworkManager
    if [[ -z "$iface" ]] && command -v nmcli &>/dev/null; then
        iface=$(nmcli -t -f device,state dev | grep connected | head -1 | cut -d: -f1)
    fi

    # Method 3: systemd-networkd
    if [[ -z "$iface" ]] && command -v networkctl &>/dev/null; then
        iface=$(networkctl | grep routable | head -1 | awk '{print $2}')
    fi

    echo "$iface"
}

# Discover network stack
discover_network_stack() {
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        echo "NetworkManager"
    elif systemctl is-active --quiet systemd-networkd 2>/dev/null; then
        echo "systemd-networkd"
    else
        echo "unknown"
    fi
}
