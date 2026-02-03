#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ EMERGENCY MODULE v3.1                                         ║
# ║  Panic Bypass & Emergency Recovery (SPOF mitigation)                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

PANIC_STATE_FILE="${CYTADELA_STATE_DIR}/panic.state"
PANIC_BACKUP_RESOLV="${CYTADELA_STATE_DIR}/resolv.conf.pre-panic"
PANIC_ROLLBACK_TIMER=300

# Disable DNS protection temporarily with auto-rollback
# Usage: panic_bypass [seconds]
# Args:
#   seconds: Optional rollback time (default: 300)
# Returns:
#   0: Success (panic mode activated)
#   1: Failed (already in panic, rate limited, or cancelled)
# Side effects:
#   - Creates panic.state file
#   - Flushes nftables rules
#   - Backup/restore resolv.conf
#   - Starts rollback timer
panic_bypass() {
    log_section "🚨 PANIC BYPASS - Emergency Recovery Mode"

    # Rate limiting: max 3 attempts per 60 seconds
    if declare -f rate_limit_check >/dev/null 2>&1; then
        if ! rate_limit_check "panic-bypass" 3 60; then
            return 1
        fi
    fi

    local rollback_seconds="${1:-$PANIC_ROLLBACK_TIMER}"

    [[ -f "$PANIC_STATE_FILE" ]] && {
        log_warning "Already in panic mode. Use 'panic-restore' to exit."
        return 1
    }

    log_warning "This will temporarily disable DNS protection!"
    log_info "Auto-rollback in ${rollback_seconds} seconds (or run 'panic-restore')"

    if [[ -t 0 && -t 1 ]]; then
        echo -n "Continue? [y/N]: "
        read -r answer
        [[ ! "$answer" =~ ^[Yy]$ ]] && {
            log_info "Cancelled."
            return 1
        }
    fi

    mkdir -p "$CYTADELA_STATE_DIR"

    log_info "Saving current state..."
    cp /etc/resolv.conf "$PANIC_BACKUP_RESOLV" 2>/dev/null || true
    nft list ruleset >"${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true

    echo "started=$(date -Iseconds)" >"$PANIC_STATE_FILE"
    echo "rollback_at=$(date -d "+${rollback_seconds} seconds" -Iseconds 2>/dev/null || date -Iseconds)" >>"$PANIC_STATE_FILE"
    echo "rollback_seconds=$rollback_seconds" >>"$PANIC_STATE_FILE"

    log_info "Flushing nftables rules..."
    nft flush ruleset 2>/dev/null || true

    log_info "Setting temporary public DNS..."
    rm -f /etc/resolv.conf 2>/dev/null || true
    cat >/etc/resolv.conf <<EOF
# CYTADELA PANIC MODE - Temporary public DNS
nameserver 9.9.9.9
nameserver 149.112.112.112
nameserver 2620:fe::fe
nameserver 2620:fe::9
EOF

    log_success "Panic mode ACTIVE. Protection disabled."
    log_warning "Auto-rollback in ${rollback_seconds}s. Run 'panic-restore' to restore manually."

    (
        sleep "$rollback_seconds"
        if [[ -f "$PANIC_STATE_FILE" ]]; then
            log_warning "Auto-rollback timer expired. Restoring protection..."
            panic_restore
        fi
    ) &

    log_info "Background rollback timer started (PID: $!)"
}

# Restore DNS protection from panic mode
# Usage: panic_restore
# Args: None
# Returns:
#   0: Success (protection restored or not in panic)
#   1: Failed (restore failed)
# Side effects:
#   - Removes panic.state file
#   - Restores nftables rules
#   - Restores original resolv.conf
#   - Kills rollback timer
panic_restore() {
    log_section "🔄 PANIC RESTORE"

    [[ ! -f "$PANIC_STATE_FILE" ]] && {
        log_info "Not in panic mode."
        return 0
    }

    log_info "Restoring protected mode..."

    if [[ -f "$PANIC_BACKUP_RESOLV" ]]; then
        cp "$PANIC_BACKUP_RESOLV" /etc/resolv.conf
        log_success "Restored resolv.conf"
    fi

    if [[ -f "${CYTADELA_STATE_DIR}/nft.pre-panic" ]]; then
        nft -f "${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true
        log_success "Restored nftables rules"
    fi

    rm -f "$PANIC_STATE_FILE"
    log_success "Panic mode DEACTIVATED. Protection restored."
}

panic_status() {
    log_section "🚨 PANIC MODE STATUS"

    if [[ -f "$PANIC_STATE_FILE" ]]; then
        log_warning "PANIC MODE: ACTIVE"
        cat "$PANIC_STATE_FILE" | sed 's/^/  /'
    else
        log_success "PANIC MODE: INACTIVE (protected)"
    fi
}

emergency_refuse() {
    log_section "🚫 EMERGENCY REFUSE MODE"
    log_warning "This will make CoreDNS refuse all DNS queries!"

    local corefile="/etc/coredns/Corefile"
    [[ ! -f "$corefile" ]] && {
        log_error "CoreDNS not installed"
        return 1
    }

    cp "$corefile" "${corefile}.backup" 2>/dev/null || true

    cat >"$corefile" <<'EOF'
. {
    refuse
    log
}
EOF

    systemctl reload coredns 2>/dev/null || systemctl restart coredns
    log_success "Emergency refuse mode activated"
}

emergency_restore() {
    log_section "✅ EMERGENCY RESTORE"

    local corefile="/etc/coredns/Corefile"
    [[ -f "${corefile}.backup" ]] && cp "${corefile}.backup" "$corefile"

    systemctl reload coredns 2>/dev/null || systemctl restart coredns
    log_success "Normal operation restored"
}

# Block all DNS except localhost (emergency kill-switch)
# Usage: killswitch_on
# Args: None
# Returns:
#   0: Success (kill-switch activated)
#   1: Failed (nftables error)
# Side effects:
#   - Adds nftables rules to drop external DNS
#   - Only allows 127.0.0.0/8 and ::1 DNS
emergency_killswitch_on() {
    log_section "🔒 KILL-SWITCH ON"
    log_warning "This will block all DNS except localhost!"

    nft add rule inet citadel filter_output ip daddr != 127.0.0.0/8 udp dport 53 drop 2>/dev/null || true
    nft add rule inet citadel filter_output ip6 daddr != ::1 udp dport 53 drop 2>/dev/null || true

    log_success "Kill-switch activated"
}

# Disable emergency kill-switch (restore DNS access)
# Usage: killswitch_off
# Args: None
# Returns:
#   0: Success (kill-switch deactivated)
#   1: Failed (nftables error)
# Side effects:
#   - Removes nftables DNS drop rules
#   - Restores normal DNS access
emergency_killswitch_off() {
    log_section "🔓 KILL-SWITCH OFF"

    nft delete rule inet citadel filter_output ip daddr != 127.0.0.0/8 udp dport 53 drop 2>/dev/null || true
    nft delete rule inet citadel filter_output ip6 daddr != ::1 udp dport 53 drop 2>/dev/null || true

    log_success "Kill-switch deactivated"
}

# Aliases for compatibility with cytadela++.new.sh
killswitch_on() {
    emergency_killswitch_on
}

killswitch_off() {
    emergency_killswitch_off
}

# Emergency network restore - handles VPN, custom configs, all network managers
# Usage: emergency_network_restore
# Returns:
#   0: Success (internet connectivity restored)
#   1: Failed (requires manual intervention)
# Side effects:
#   - Disables Citadel DNS services temporarily
#   - Flushes nftables rules
#   - Restores system default DNS configuration
#   - Handles VPN tunnels gracefully
emergency_network_restore() {
    log_section "🌐 EMERGENCY NETWORK RESTORE"
    log_warning "This will attempt to restore internet connectivity"
    log_warning "Citadel protection will be temporarily disabled"
    echo ""

    # Step 1: Immediate DNS fix with public servers
    log_info "Step 1: Setting emergency public DNS..."
    chattr -i /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf 2>/dev/null || true
    cat >/etc/resolv.conf <<EOF
# EMERGENCY DNS - Set by Citadel emergency restore
# This is a temporary configuration for connectivity recovery
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 9.9.9.9
nameserver 2620:fe::9
options edns0 trust-ad
EOF
    chmod 644 /etc/resolv.conf
    log_success "Emergency DNS configured"

    # Step 2: Stop Citadel services that might block DNS
    log_info "Step 2: Stopping Citadel DNS services..."
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl stop systemd-resolved 2>/dev/null || true
    log_success "DNS services stopped"

    # Step 3: Flush nftables rules (remove DNS blocks)
    log_info "Step 3: Removing firewall DNS restrictions..."
    nft flush ruleset 2>/dev/null || true
    nft delete table inet citadel 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    log_success "Firewall rules cleared"

    # Step 4: Detect and handle VPN connections
    log_info "Step 4: Checking for VPN connections..."
    local vpn_found=false

    # Check for common VPN interfaces
    local vpn_interfaces=("tun0" "tun1" "wg0" "wg1" "ppp0" "vpn0")
    local iface
    for iface in "${vpn_interfaces[@]}"; do
        if ip link show "$iface" &>/dev/null; then
            log_info "Found VPN interface: $iface"
            vpn_found=true
            # Ensure VPN interface has DNS access
            ip link set "$iface" up 2>/dev/null || true
        fi
    done

    # Check for WireGuard
    if command -v wg &>/dev/null; then
        local wg_interfaces
        wg_interfaces=$(wg show interfaces 2>/dev/null)
        if [[ -n "$wg_interfaces" ]]; then
            log_info "WireGuard interfaces active: $wg_interfaces"
            vpn_found=true
        fi
    fi

    # Check for OpenVPN
    if pgrep -x openvpn &>/dev/null; then
        log_info "OpenVPN process detected"
        vpn_found=true
    fi

    if [[ "$vpn_found" == true ]]; then
        log_warning "VPN detected - attempting to preserve VPN connectivity"
        log_info "Note: You may need to restart your VPN client after this"
    fi

    # Step 5: Restart network management services
    log_info "Step 5: Restarting network services..."

    # NetworkManager (most common)
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        log_info "Restarting NetworkManager..."
        systemctl restart NetworkManager
        sleep 2
    fi

    # systemd-networkd
    if systemctl is-active --quiet systemd-networkd 2>/dev/null; then
        log_info "Restarting systemd-networkd..."
        systemctl restart systemd-networkd
        sleep 2
    fi

    # dhcpcd
    if systemctl is-active --quiet dhcpcd 2>/dev/null; then
        log_info "Restarting dhcpcd..."
        systemctl restart dhcpcd
        sleep 2
    fi

    # wpa_supplicant (WiFi)
    if systemctl is-active --quiet wpa_supplicant 2>/dev/null; then
        log_info "Restarting wpa_supplicant..."
        systemctl restart wpa_supplicant
        sleep 2
    fi

    # Step 6: Flush DNS caches
    log_info "Step 6: Clearing DNS caches..."
    systemd-resolve --flush-caches 2>/dev/null || true
    resolvectl flush-caches 2>/dev/null || true

    # Step 7: Test connectivity
    log_info "Step 7: Testing connectivity..."
    echo ""
    local test_hosts=("1.1.1.1" "8.8.8.8" "google.com" "cloudflare.com")
    local connectivity_works=false
    local dns_works=false

    # Test ping to IP addresses first (no DNS needed)
    for host in "1.1.1.1" "8.8.8.8"; do
        log_info "Testing ping to $host..."
        if ping -c 2 -W 3 "$host" &>/dev/null; then
            log_success "✓ ICMP connectivity to $host works"
            connectivity_works=true
        else
            log_warning "✗ Cannot reach $host via ICMP"
        fi
    done

    # Test DNS resolution
    for host in "google.com" "cloudflare.com"; do
        log_info "Testing DNS resolution for $host..."
        if dig +time=5 +tries=2 "$host" @1.1.1.1 +short &>/dev/null || \
           dig +time=5 +tries=2 "$host" @8.8.8.8 +short &>/dev/null || \
           nslookup "$host" 1.1.1.1 &>/dev/null 2>&1; then
            log_success "✓ DNS resolution for $host works"
            dns_works=true
            break
        else
            log_warning "✗ DNS resolution for $host failed"
        fi
    done

    echo ""
    log_section "📊 RESTORE SUMMARY"

    if [[ "$connectivity_works" == true ]] && [[ "$dns_works" == true ]]; then
        log_success "🎉 INTERNET CONNECTIVITY RESTORED!"
        echo ""
        log_info "Next steps:"
        log_info "  1. Your internet is working now"
        log_info "  2. If using VPN, restart your VPN client"
        log_info "  3. To restore Citadel: sudo ./citadel.sh install-wizard"
        log_info "  4. Or keep using emergency DNS (1.1.1.1, 8.8.8.8)"
        return 0
    elif [[ "$connectivity_works" == true ]]; then
        log_warning "⚠ Basic connectivity works but DNS may have issues"
        log_info "Try: dig @1.1.1.1 google.com"
        log_info "Or manually edit: sudo nano /etc/resolv.conf"
        return 0
    else
        log_error "❌ Could not restore connectivity automatically"
        echo ""
        log_info "Manual steps to try:"
        log_info "  1. Check cable/WiFi connection"
        log_info "  2. Restart router/modem"
        log_info "  3. Check VPN status: ip link show"
        log_info "  4. Check routes: ip route show"
        log_info "  5. Check interface status: ip addr show"
        log_info "  6. For WiFi: sudo systemctl restart iwd"
        echo ""
        log_info "Your backup is at: ${CYTADELA_STATE_DIR:-/var/lib/cytadela}/backups/"
        return 1
    fi
}

# Quick DNS-only emergency fix (minimal intervention)
# Usage: emergency_dns_fix
emergency_dns_fix() {
    log_section "🔧 QUICK DNS FIX"
    
    log_info "Setting reliable public DNS..."
    chattr -i /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf 2>/dev/null || true
    cat >/etc/resolv.conf <<EOF
# Quick DNS fix by Citadel
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    
    log_success "DNS configured to use Cloudflare and Google"
    
    # Test
    if dig +time=3 +tries=1 google.com +short &>/dev/null; then
        log_success "✓ DNS is working!"
        return 0
    else
        log_error "✗ DNS test failed - run: emergency-network-restore"
        return 1
    fi
}
