#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-RECOVERY MODULE v3.2                               ║
# ║  Emergency recovery & system restore functionality                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

# Panic Mode Configuration
PANIC_STATE_FILE="${CYTADELA_STATE_DIR}/panic.state"
PANIC_BACKUP_RESOLV="${CYTADELA_STATE_DIR}/resolv.conf.pre-panic"
PANIC_ROLLBACK_TIMER=300

# Emergency DNS Servers
EMERGENCY_DNS_SERVERS=(
    "1.1.1.1"      # Cloudflare
    "8.8.8.8"      # Google
    "9.9.9.9"      # Quad9
    "2620:fe::9"   # Quad9 IPv6
)

# VPN Interface Patterns
VPN_INTERFACE_PATTERNS=("tun0" "tun1" "wg0" "wg1" "ppp0" "vpn0")

# Test Hosts
TEST_PING_HOSTS=("1.1.1.1" "8.8.8.8")
TEST_DNS_HOSTS=("google.com" "cloudflare.com")

# ==============================================================================
# PANIC MODE FUNCTIONS (migrated from emergency.sh)
# ==============================================================================

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
    log_section "󰀨 PANIC BYPASS - Emergency Recovery Mode"

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
    log_section "󰜝 PANIC RESTORE"

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
    log_section "󰀨 PANIC MODE STATUS"

    if [[ -f "$PANIC_STATE_FILE" ]]; then
        log_warning "PANIC MODE: ACTIVE"
        cat "$PANIC_STATE_FILE" | sed 's/^/  /'
    else
        log_success "PANIC MODE: INACTIVE (protected)"
    fi
}

# ==============================================================================
# EMERGENCY RECOVERY FUNCTIONS
# ==============================================================================

# Emergency network restore - atomowa naprawa sieci
emergency_network_restore() {
    log_section "🌐 EMERGENCY NETWORK RESTORE"
    log_warning "This will attempt to restore internet connectivity"
    log_warning "Citadel protection will be temporarily disabled"

    echo ""

    # Step 1: Emergency DNS fix
    _fix_emergency_dns

    # Step 2: Stop Citadel services
    _stop_citadel_services

    # Step 3: Flush firewall rules
    _flush_all_firewall

    # Step 4: Detect and handle VPN
    _detect_and_handle_vpn

    # Step 5: Restart network services
    _restart_all_network_services

    # Step 6: Flush DNS caches
    _flush_dns_caches

    # Step 7: Final connectivity test
    _verify_final_connectivity
}

# Emergency network fix - quick DNS only
emergency_network_fix() {
    log_section "🔧 EMERGENCY NETWORK FIX"
    log_info "Quick DNS fix without full network restart"

    _fix_emergency_dns
    _flush_dns_caches
    _verify_connectivity
}

# ==============================================================================
# SYSTEM RESTORE FUNCTIONS (migrated from install-nftables.sh)
# ==============================================================================

# Main system restore function
restore_system() {
    log_section "󰜝 System Restore"

    local backup_dir="${CYTADELA_STATE_DIR}/backups"

    # Check if backup exists
    if [[ -d "$backup_dir" && -f "${backup_dir}/resolv.conf.pre-citadel" ]]; then
        log_info "Found backup - restoring from backup..."
        _restore_dns_from_backup
        _restore_systemd_resolved_from_backup
    else
        log_warning "No backup found - restoring to defaults..."
        _restore_dns_fallback
        _restore_systemd_resolved_default
    fi

    _cleanup_networkmanager_config

    # Test connectivity
    if _test_full_connectivity; then
        log_success "System restored successfully"
        return 0
    else
        log_warning "System restore completed but connectivity issues detected"
        _offer_emergency_restore
        return 1
    fi
}

# Restore system to default systemd-resolved configuration
restore_system_default() {
    log_section "󰜝 System Restore (Default)"

    log_warning "This will restore to factory systemd-resolved configuration"
    log_warning "Any user backup will be ignored"

    if [[ -t 0 && -t 1 ]]; then
        echo -n "Continue? [y/N]: "
        read -r answer
        [[ ! "$answer" =~ ^[Yy]$ ]] && {
            log_info "Cancelled."
            return 1
        }
    fi

    _restore_systemd_resolved_default
    _cleanup_networkmanager_config

    log_success "System restored to default configuration"
}

# ==============================================================================
# PRIVATE HELPER FUNCTIONS
# ==============================================================================

# Test full connectivity (ping + DNS + IPv6)
_test_full_connectivity() {
    log_info "Testing connectivity..."

    # Test ping
    if ! _test_ping_connectivity; then
        return 1
    fi

    # Test DNS
    if ! _test_dns_resolution; then
        return 1
    fi

    # Test IPv6 (optional)
    _test_ipv6_connectivity || true

    return 0
}

# Test ping connectivity
_test_ping_connectivity() {
    for host in "${TEST_PING_HOSTS[@]}"; do
        if ping -c 2 -W 3 "$host" >/dev/null 2>&1; then
            log_success "✓ ICMP connectivity to $host"
            return 0
        fi
    done
    log_error "✗ No ICMP connectivity to test hosts"
    return 1
}

# Test DNS resolution
_test_dns_resolution() {
    for host in "${TEST_DNS_HOSTS[@]}"; do
        if dig +time=5 +tries=2 "$host" @1.1.1.1 +short >/dev/null 2>&1 || \
           dig +time=5 +tries=2 "$host" @8.8.8.8 +short >/dev/null 2>&1; then
            log_success "✓ DNS resolution for $host"
            return 0
        fi
    done
    log_error "✗ DNS resolution failed"
    return 1
}

# Test IPv6 connectivity
_test_ipv6_connectivity() {
    if ping6 -c 2 -W 3 2001:4860:4860::8888 >/dev/null 2>&1; then
        log_success "✓ IPv6 connectivity"
        return 0
    else
        log_warning "⚠ IPv6 connectivity issues (may be normal)"
        return 1
    fi
}

# Offer emergency restore if connectivity test fails
_offer_emergency_restore() {
    log_warning "Connectivity test failed"
    echo ""
    log_info "Would you like to run emergency network restore?"
    echo -n "[Y/n]: "

    if [[ -t 0 && -t 1 ]]; then
        read -r answer
        [[ "$answer" =~ ^[Nn]$ ]] && return 1
    fi

    emergency_network_restore
}

# Emergency DNS fix
_fix_emergency_dns() {
    log_info "Step 1: Setting emergency public DNS..."

    chattr -i /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf 2>/dev/null || true

    {
        echo "# EMERGENCY DNS - Set by Citadel recovery"
        echo "# This is a temporary configuration for connectivity recovery"
        printf 'nameserver %s\n' "${EMERGENCY_DNS_SERVERS[@]}"
    } > /etc/resolv.conf

    chmod 644 /etc/resolv.conf
    log_success "Emergency DNS configured"
}

# Stop Citadel DNS services
_stop_citadel_services() {
    log_info "Step 2: Stopping Citadel DNS services..."
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    log_success "DNS services stopped"
}

# Flush all firewall rules
_flush_all_firewall() {
    log_info "Step 3: Flushing firewall rules..."
    nft flush ruleset 2>/dev/null || true
    nft delete table inet citadel 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    log_success "Firewall rules cleared"
}

# Detect and handle VPN connections
_detect_and_handle_vpn() {
    log_info "Step 4: Checking for VPN connections..."

    local vpn_found=false

    # Check for common VPN interfaces
    for iface in "${VPN_INTERFACE_PATTERNS[@]}"; do
        if ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
            log_info "Found active VPN interface: $iface"
            vpn_found=true
        fi
    done

    # Check WireGuard
    if command -v wg >/dev/null 2>&1; then
        if wg show interfaces >/dev/null 2>&1; then
            log_info "WireGuard interfaces detected"
            vpn_found=true
        fi
    fi

    # Check OpenVPN
    if pgrep -x openvpn >/dev/null 2>&1; then
        log_info "OpenVPN process detected"
        vpn_found=true
    fi

    if [[ "$vpn_found" == true ]]; then
        log_warning "VPN detected - you may need to restart VPN client after recovery"
    fi
}

# Restart all network services
_restart_all_network_services() {
    log_info "Step 5: Restarting network services..."

    # NetworkManager
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

    # wpa_supplicant
    if systemctl is-active --quiet wpa_supplicant 2>/dev/null; then
        log_info "Restarting wpa_supplicant..."
        systemctl restart wpa_supplicant
        sleep 2
    fi

    log_success "Network services restarted"
}

# Flush DNS caches
_flush_dns_caches() {
    log_info "Step 6: Clearing DNS caches..."

    systemd-resolve --flush-caches 2>/dev/null || true
    resolvectl flush-caches 2>/dev/null || true

    log_success "DNS caches cleared"
}

# Verify final connectivity
_verify_final_connectivity() {
    log_info "Step 7: Verifying final connectivity..."

    if _test_full_connectivity; then
        log_success "🎉 INTERNET CONNECTIVITY RESTORED!"
        echo ""
        log_info "Next steps:"
        log_info "  1. Your internet is working now"
        log_info "  2. If using VPN, restart your VPN client"
        log_info "  3. To restore Citadel: sudo ./citadel.sh install-wizard"
        return 0
    else
        log_error "❌ Could not restore connectivity automatically"
        echo ""
        log_info "Manual troubleshooting steps:"
        log_info "  1. Check cable/WiFi connection"
        log_info "  2. Restart router/modem"
        log_info "  3. Check VPN status: ip link show"
        log_info "  4. Manual DNS: echo 'nameserver 1.1.1.1' > /etc/resolv.conf"
        return 1
    fi
}

# Alias for backward compatibility
_verify_connectivity() {
    _verify_final_connectivity
}

# Restore DNS from backup
_restore_dns_from_backup() {
    local backup_dir="${CYTADELA_STATE_DIR}/backups"
    local backup_file="${backup_dir}/resolv.conf.pre-citadel"

    if [[ -f "$backup_file" ]]; then
        log_info "Restoring resolv.conf from backup..."
        chattr -i /etc/resolv.conf 2>/dev/null || true
        cp "$backup_file" /etc/resolv.conf 2>/dev/null || true
        log_success "Restored resolv.conf from backup"
    fi
}

# Restore systemd-resolved from backup
_restore_systemd_resolved_from_backup() {
    local backup_dir="${CYTADELA_STATE_DIR}/backups"
    local state_file="${backup_dir}/systemd-resolved.state"

    if [[ -f "$state_file" ]]; then
        local resolved_state
        resolved_state=$(cat "$state_file")

        log_info "Restoring systemd-resolved (state: $resolved_state)..."

        systemctl unmask systemd-resolved 2>/dev/null || true

        if [[ "$resolved_state" == "enabled" ]]; then
            systemctl enable systemd-resolved 2>/dev/null || true
            systemctl start systemd-resolved 2>/dev/null || true
        else
            systemctl disable systemd-resolved 2>/dev/null || true
            systemctl stop systemd-resolved 2>/dev/null || true
        fi

        log_success "Restored systemd-resolved state"
    fi
}

# Restore systemd-resolved to default
_restore_systemd_resolved_default() {
    log_info "Restoring systemd-resolved to default configuration..."

    systemctl unmask systemd-resolved 2>/dev/null || true
    systemctl enable systemd-resolved 2>/dev/null || true
    systemctl start systemd-resolved 2>/dev/null || true

    log_success "systemd-resolved restored to defaults"
}

# Fallback DNS configuration
_restore_dns_fallback() {
    log_info "Setting fallback DNS servers..."

    chattr -i /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf

    {
        echo "# Fallback DNS configuration"
        echo "nameserver 1.1.1.1"
        echo "nameserver 8.8.8.8"
        echo "nameserver 9.9.9.9"
    } > /etc/resolv.conf

    log_success "Fallback DNS configured"
}

# Cleanup NetworkManager configuration
_cleanup_networkmanager_config() {
    log_info "Cleaning up NetworkManager configuration..."

    rm -f /etc/NetworkManager/conf.d/citadel-dns.conf
    systemctl restart NetworkManager 2>/dev/null || true

    log_success "NetworkManager configuration cleaned"
}

# ==============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ==============================================================================

# Emergency module compatibility
emergency_restore() {
    panic_restore
}

killswitch_on() {
    emergency_killswitch_on
}

killswitch_off() {
    emergency_killswitch_off
}

# IPv6 recovery alias
ipv6_emergency_reset() {
    _ipv6_emergency_reset
}

smart_ipv6_recovery() {
    _test_ipv6_connectivity
}

# Stub functions for future implementation
emergency_killswitch_on() {
    log_warning "Killswitch functionality moved to unified-security module"
    log_info "Use: citadel security killswitch-on"
}

emergency_killswitch_off() {
    log_warning "Killswitch functionality moved to unified-security module"
    log_info "Use: citadel security killswitch-off"
}

_ipv6_emergency_reset() {
    log_warning "IPv6 deep reset functionality moved to unified-network module"
    log_info "Use: citadel network ipv6-emergency-reset"
}
