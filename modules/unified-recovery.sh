#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED RECOVERY MODULE v3.2                                ║
# ║  Centralized Recovery & Emergency Network Functions                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ============================================================================
# CONFIGURATION
# ============================================================================

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

# ============================================================================
# PRIVATE HELPER FUNCTIONS
# ============================================================================

# Complete connectivity test (ping + DNS + HTTP)
_test_connectivity() {
    local test_icmp=true
    local test_dns=true
    local test_ipv6=false

    # Test ICMP connectivity
    if [[ "$test_icmp" == true ]]; then
        _test_ping_connectivity
    fi

    # Test DNS resolution
    if [[ "$test_dns" == true ]]; then
        _test_dns_resolution
    fi

    # Test IPv6 if requested
    if [[ "$test_ipv6" == true ]]; then
        _test_ipv6_connectivity
    fi

    # Return success if any test passed
    [[ "$icmp_works" == true ]] || [[ "$dns_works" == true ]]
}

# Test ICMP connectivity to known IPs
_test_ping_connectivity() {
    icmp_works=false
    for host in "${TEST_PING_HOSTS[@]}"; do
        log_info "Testing ping to $host..."
        if ping -c 2 -W 3 "$host" >/dev/null 2>&1; then
            log_success "✓ ICMP connectivity to $host works"
            icmp_works=true
            break
        else
            log_warning "✗ Cannot reach $host via ICMP"
        fi
    done
}

# Test DNS resolution
_test_dns_resolution() {
    dns_works=false
    for host in "${TEST_DNS_HOSTS[@]}"; do
        log_info "Testing DNS resolution for $host..."
        if dig +time=5 +tries=2 "$host" @1.1.1.1 +short >/dev/null 2>&1 || \
           dig +time=5 +tries=2 "$host" @8.8.8.8 +short >/dev/null 2>&1; then
            log_success "✓ DNS resolution for $host works"
            dns_works=true
            break
        else
            log_warning "✗ DNS resolution for $host failed"
        fi
    done
}

# Test IPv6 connectivity
_test_ipv6_connectivity() {
    ipv6_works=false
    log_info "Testing IPv6 connectivity..."
    if ping -6 -c 3 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        log_success "✓ IPv6 connectivity works"
        ipv6_works=true
    else
        log_warning "✗ IPv6 connectivity failed"
    fi
}

# Offer emergency restore when connectivity fails
_offer_emergency_restore() {
    log_warning "${T_EMERGENCY_OFFER:-Connectivity test failed. Would you like to run emergency network restore?}"
    echo ""
    log_info "${T_EMERGENCY_OPTION:-This will:}"
    log_info "  • ${T_EMERGENCY_DNS:-Set emergency public DNS servers}"
    log_info "  • ${T_EMERGENCY_STOP:-Stop Citadel DNS services}"
    log_info "  • ${T_EMERGENCY_FLUSH:-Flush firewall rules}"
    log_info "  • ${T_EMERGENCY_RESTART:-Restart network services}"
    echo ""

    if [[ -t 0 && -t 1 ]]; then
        read -p "${T_EMERGENCY_PROMPT:-Run emergency network restore?} [y/N]: " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            return 0  # Yes, run emergency restore
        fi
    fi

    return 1  # No, don't run
}

# Restore DNS from backup or fallback to public servers
_restore_dns_with_fallback() {
    log_info "${T_RESTORE_DNS:-Restoring original DNS configuration...}"

    local dns_restored=false
    local dns_servers=("1.1.1.1" "8.8.8.8" "9.9.9.9")
    local backup_dir="${CYTADELA_STATE_DIR}/backups"

    # Check if backup exists in new location (install-wizard backup)
    if [[ -f "${backup_dir}/resolv.conf.pre-citadel" ]]; then
        local backup_dns
        backup_dns=$(grep "^nameserver" "${backup_dir}/resolv.conf.pre-citadel" | head -1 | awk '{print $2}')
        if [[ "$backup_dns" != "127.0.0.1" && -n "$backup_dns" ]]; then
            chattr -i /etc/resolv.conf 2>/dev/null || true
            cp "${backup_dir}/resolv.conf.pre-citadel" /etc/resolv.conf
            log_success "${T_RESTORED_BACKUP:-Restored from backup} (DNS: $backup_dns)"
            dns_restored=true
        else
            log_warning "Backup points to localhost, using fallback..."
        fi
    # Check old location for compatibility
    elif [[ -f /etc/resolv.conf.bak ]]; then
        local backup_dns
        backup_dns=$(grep "^nameserver" /etc/resolv.conf.bak | head -1 | awk '{print $2}')
        if [[ "$backup_dns" != "127.0.0.1" && -n "$backup_dns" ]]; then
            chattr -i /etc/resolv.conf 2>/dev/null || true
            cp /etc/resolv.conf.bak /etc/resolv.conf
            log_success "${T_RESTORED_BACKUP:-Restored from backup} (DNS: $backup_dns)"
            dns_restored=true
        else
            log_warning "Backup points to localhost, using fallback..."
            rm -f /etc/resolv.conf.bak 2>/dev/null || true
        fi
    fi

    # If no valid backup, try to detect system DNS configuration
    if [[ "$dns_restored" == false ]]; then
        # Try NetworkManager
        if command -v nmcli >/dev/null 2>&1 && systemctl is-active --quiet NetworkManager; then
            log_info "Detected NetworkManager - enabling automatic DNS..."
            nmcli general reload 2>/dev/null || true
            # Wait a moment for NM to configure DNS
            sleep 2
            if dig +time=2 +tries=1 google.com >/dev/null 2>&1; then
                log_success "NetworkManager DNS is working"
                dns_restored=true
            fi
        fi
    fi

    # If still no DNS, use fallback servers
    if [[ "$dns_restored" == false ]]; then
        log_info "Setting fallback DNS servers..."
        {
            echo "# Temporary DNS configuration after Citadel uninstall"
            echo "nameserver 1.1.1.1"
            echo "nameserver 8.8.8.8"
            echo "nameserver 9.9.9.9"
        } > /etc/resolv.conf
        log_info "Set fallback DNS (Cloudflare, Google, Quad9)"
    fi

    # Test DNS connectivity
    log_info "${T_TESTING_DNS:-Testing DNS connectivity...}"
    local dns_works=false
    for server in "${dns_servers[@]}"; do
        if dig +time=2 +tries=1 @"$server" google.com >/dev/null 2>&1; then
            log_success "${T_DNS_OK:-DNS connectivity verified via} $server"
            dns_works=true
            break
        fi
    done

    if [[ "$dns_works" == false ]]; then
        log_error "${T_DNS_FAILED:-DNS test failed - system may lose internet after restart!}"
        echo ""
        draw_emergency_frame "EMERGENCY RECOVERY:" \
            "Run:" \
            "  ${YELLOW}sudo ./citadel.sh emergency-network-restore${NC}"
        return 1
    fi

    return 0
}

# Set fallback DNS servers
_restore_dns_fallback() {
    log_info "${T_SETTING_FALLBACK:-Setting fallback DNS servers...}"
    chattr -i /etc/resolv.conf 2>/dev/null || true
    {
        echo "# Emergency DNS configuration"
        printf 'nameserver %s\n' "${EMERGENCY_DNS_SERVERS[@]}"
    } > /etc/resolv.conf
    log_success "${T_FALLBACK_SET:-Fallback DNS configured}"
}

# Restore systemd-resolved state
_restore_systemd_resolved_state() {
    local backup_dir="${CYTADELA_STATE_DIR}/backups"

    if [[ -f "${backup_dir}/systemd-resolved.state" ]]; then
        local resolved_state
        resolved_state=$(cat "${backup_dir}/systemd-resolved.state")

        log_info "${T_RESTORING_RESOLVED:-Restoring systemd-resolved (state:} ${resolved_state})..."
        systemctl unmask systemd-resolved 2>/dev/null || true

        if [[ "$resolved_state" == "enabled" ]]; then
            systemctl enable systemd-resolved 2>/dev/null || true
            systemctl start systemd-resolved 2>/dev/null || true
        else
            systemctl disable systemd-resolved 2>/dev/null || true
            systemctl stop systemd-resolved 2>/dev/null || true
        fi
    fi
}

# Clean up NetworkManager configuration
_cleanup_networkmanager() {
    log_info "${T_CLEANING_NM:-Cleaning NetworkManager configuration...}"
    rm -f /etc/NetworkManager/conf.d/citadel-dns.conf
    systemctl restart NetworkManager 2>/dev/null || true
}

# Stop Citadel services
_stop_citadel_services() {
    log_info "${T_STOPPING_SERVICES:-Stopping Citadel DNS services...}"
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl stop systemd-resolved 2>/dev/null || true
    log_success "${T_SERVICES_STOPPED:-DNS services stopped}"
}

# Flush all firewall rules
_flush_all_firewall() {
    log_info "${T_FLUSHING_FIREWALL:-Removing firewall DNS restrictions...}"
    nft flush ruleset 2>/dev/null || true
    nft delete table inet citadel 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    log_success "${T_FIREWALL_FLUSHED:-Firewall rules cleared}"
}

# Detect VPN interfaces
_detect_vpn_interfaces() {
    local vpn_found=false

    for iface in "${VPN_INTERFACE_PATTERNS[@]}"; do
        if ip link show "$iface" >/dev/null 2>&1; then
            log_info "${T_VPN_FOUND:-Found VPN interface:} $iface"
            vpn_found=true
            ip link set "$iface" up 2>/dev/null || true
        fi
    done

    if command -v wg >/dev/null 2>&1; then
        local wg_interfaces
        wg_interfaces=$(wg show interfaces 2>/dev/null)
        if [[ -n "$wg_interfaces" ]]; then
            log_info "${T_WG_ACTIVE:-WireGuard interfaces active:} $wg_interfaces"
            vpn_found=true
        fi
    fi

    if pgrep -x openvpn >/dev/null 2>&1; then
        log_info "${T_OPENVPN_ACTIVE:-OpenVPN process detected}"
        vpn_found=true
    fi

    if [[ "$vpn_found" == true ]]; then
        log_warning "${T_VPN_WARNING:-VPN detected - attempting to preserve VPN connectivity}"
        log_info "${T_VPN_RESTART:-Note: You may need to restart your VPN client after this}"
    fi
}

# Restart all network services
_restart_all_network_services() {
    log_info "${T_RESTARTING_SERVICES:-Restarting network services...}"

    # NetworkManager
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        log_info "${T_RESTARTING_NM:-Restarting NetworkManager...}"
        systemctl restart NetworkManager
        sleep 2
    fi

    # systemd-networkd
    if systemctl is-active --quiet systemd-networkd 2>/dev/null; then
        log_info "${T_RESTARTING_NETWORKD:-Restarting systemd-networkd...}"
        systemctl restart systemd-networkd
        sleep 2
    fi

    # dhcpcd
    if systemctl is-active --quiet dhcpcd 2>/dev/null; then
        log_info "${T_RESTARTING_DHCPCD:-Restarting dhcpcd...}"
        systemctl restart dhcpcd
        sleep 2
    fi

    # wpa_supplicant
    if systemctl is-active --quiet wpa_supplicant 2>/dev/null; then
        log_info "${T_RESTARTING_WPA:-Restarting wpa_supplicant...}"
        systemctl restart wpa_supplicant
        sleep 2
    fi
}

# Flush DNS caches
_flush_dns_caches() {
    log_info "${T_FLUSHING_CACHES:-Clearing DNS caches...}"
    systemd-resolve --flush-caches 2>/dev/null || true
    resolvectl flush-caches 2>/dev/null || true
}

# Final connectivity verification
_verify_final_connectivity() {
    log_info "${T_VERIFYING_FINAL:-Verifying final connectivity...}"
    echo ""

    # Test ICMP
    icmp_final=false
    for host in "${TEST_PING_HOSTS[@]}"; do
        if ping -c 2 -W 3 "$host" >/dev/null 2>&1; then
            log_success "✓ ${T_ICMP_OK:-ICMP connectivity to} $host ${T_WORKS:-works}"
            icmp_final=true
            break
        fi
    done

    # Test DNS
    dns_final=false
    for host in "${TEST_DNS_HOSTS[@]}"; do
        if dig +time=5 +tries=2 "$host" @1.1.1.1 +short >/dev/null 2>&1 || \
           dig +time=5 +tries=2 "$host" @8.8.8.8 +short >/dev/null 2>&1; then
            log_success "✓ ${T_DNS_OK:-DNS resolution for} $host ${T_WORKS:-works}"
            dns_final=true
            break
        fi
    done

    echo ""

    if [[ "$icmp_final" == true ]] && [[ "$dns_final" == true ]]; then
        log_success "[SUCCESS] ${T_CONNECTIVITY_RESTORED:-INTERNET CONNECTIVITY RESTORED!}"
        echo ""
        log_info "${T_NEXT_STEPS:-Next steps:}"
        log_info "  1. ${T_INTERNET_WORKING:-Your internet is working now}"
        log_info "  2. ${T_VPN_RESTART_IF:-If using VPN, restart your VPN client}"
        log_info "  3. ${T_RESTORE_CITADEL:-To restore Citadel:} sudo ./citadel.sh install-wizard"
        log_info "  4. ${T_KEEP_EMERGENCY:-Or keep using emergency DNS}"
        return 0
    elif [[ "$icmp_final" == true ]]; then
        log_warning "[WARNING] ${T_ICMP_OK_DNS_ISSUES:-Basic connectivity works but DNS may have issues}"
        log_info "${T_TEST_DNS_MANUAL:-Try:} dig @1.1.1.1 google.com"
        log_info "${T_EDIT_MANUAL:-Or manually edit:} sudo nano /etc/resolv.conf"
        return 0
    else
        log_error "[ERROR] ${T_CONNECTIVITY_FAILED:-Could not restore connectivity automatically}"
        echo ""
        log_info "${T_MANUAL_STEPS:-Manual steps to try:}"
        log_info "  1. ${T_CHECK_CABLE:-Check cable/WiFi connection}"
        log_info "  2. ${T_RESTART_ROUTER:-Restart router/modem}"
        log_info "  3. ${T_CHECK_VPN:-Check VPN status:} ip link show"
        log_info "  4. ${T_CHECK_ROUTES:-Check routes:} ip route show"
        log_info "  5. ${T_CHECK_INTERFACE:-Check interface status:} ip addr show"
        log_info "  6. ${T_RESTART_IWD:-For WiFi:} sudo systemctl restart iwd"
        echo ""
        log_info "${T_BACKUP_LOCATION:-Your backup is at:} ${CYTADELA_STATE_DIR:-/var/lib/cytadela}/backups/"
        return 1
    fi
}

# ============================================================================
# PUBLIC API FUNCTIONS
# ============================================================================

# ============================================================================
# PANIC MODE FUNCTIONS
# ============================================================================

# Disable DNS protection temporarily with auto-rollback
panic_bypass() {
    log_section "${T_PANIC_BYPASS:-󰀨 PANIC BYPASS}"

    # Rate limiting
    if declare -f rate_limit_check >/dev/null 2>&1; then
        if ! rate_limit_check "panic-bypass" 3 60; then
            return 1
        fi
    fi

    local rollback_seconds="${1:-$PANIC_ROLLBACK_TIMER}"

    [[ -f "$PANIC_STATE_FILE" ]] && {
        log_warning "${T_PANIC_ALREADY_ACTIVE:-Already in panic mode. Use 'panic-restore' to exit.}"
        return 1
    }

    log_warning "${T_PANIC_WARNING:-This will temporarily disable DNS protection!}"
    log_info "${T_PANIC_AUTO_ROLLBACK:-Auto-rollback in} ${rollback_seconds} ${T_SECONDS:-seconds}"

    if [[ -t 0 && -t 1 ]]; then
        echo -n "${T_CONTINUE:-Continue?} [y/N]: "
        read -r answer
        [[ ! "$answer" =~ ^[Yy]$ ]] && {
            log_info "${T_CANCELLED:-Cancelled.}"
            return 1
        }
    fi

    mkdir -p "$CYTADELA_STATE_DIR"

    log_info "${T_PANIC_SAVING:-Saving current state...}"
    cp /etc/resolv.conf "$PANIC_BACKUP_RESOLV" 2>/dev/null || true
    nft list ruleset >"${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true

    echo "started=$(date -Iseconds)" >"$PANIC_STATE_FILE"
    echo "rollback_at=$(date -d "+${rollback_seconds} seconds" -Iseconds 2>/dev/null || date -Iseconds)" >>"$PANIC_STATE_FILE"
    echo "rollback_seconds=$rollback_seconds" >>"$PANIC_STATE_FILE"

    log_info "${T_PANIC_FLUSHING:-Flushing nftables rules...}"
    nft flush ruleset 2>/dev/null || true

    log_info "${T_PANIC_SETTING_DNS:-Setting temporary public DNS...}"
    rm -f /etc/resolv.conf 2>/dev/null || true
    cat >/etc/resolv.conf <<EOF
# CYTADELA PANIC MODE - Temporary public DNS
nameserver 9.9.9.9
nameserver 149.112.112.112
nameserver 2620:fe::fe
nameserver 2620:fe::9
EOF

    log_success "${T_PANIC_ACTIVE:-Panic mode ACTIVE. Protection disabled.}"
    log_warning "${T_PANIC_ROLLBACK_WARNING:-Auto-rollback in} ${rollback_seconds}s. ${T_PANIC_MANUAL_RESTORE:-Run 'panic-restore' to restore manually.}"

    (
        sleep "$rollback_seconds"
        if [[ -f "$PANIC_STATE_FILE" ]]; then
            log_warning "${T_PANIC_AUTO_ROLLBACK_TRIGGER:-Auto-rollback timer expired. Restoring protection...}"
            panic_restore
        fi
    ) &

    log_info "${T_PANIC_TIMER_STARTED:-Background rollback timer started (PID:} $!)"
}

# Restore DNS protection from panic mode
panic_restore() {
    log_section "${T_PANIC_RESTORE:-󰜝 PANIC RESTORE}"

    [[ ! -f "$PANIC_STATE_FILE" ]] && {
        log_info "${T_PANIC_NOT_ACTIVE:-Not in panic mode.}"
        return 0
    }

    log_info "${T_PANIC_RESTORING:-Restoring protected mode...}"

    if [[ -f "$PANIC_BACKUP_RESOLV" ]]; then
        cp "$PANIC_BACKUP_RESOLV" /etc/resolv.conf
        log_success "${T_PANIC_RESTORED_RESOLV:-Restored resolv.conf}"
    fi

    if [[ -f "${CYTADELA_STATE_DIR}/nft.pre-panic" ]]; then
        nft -f "${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true
        log_success "${T_PANIC_RESTORED_NFT:-Restored nftables rules}"
    fi

    rm -f "$PANIC_STATE_FILE"
    log_success "${T_PANIC_DEACTIVATED:-Panic mode DEACTIVATED. Protection restored.}"
}

# Check panic mode status
panic_status() {
    log_section "${T_PANIC_STATUS:-󰀨 PANIC MODE STATUS}"

    if [[ -f "$PANIC_STATE_FILE" ]]; then
        log_warning "${T_PANIC_ACTIVE_STATUS:-PANIC MODE: ACTIVE}"
        cat "$PANIC_STATE_FILE" | sed 's/^/  /'
    else
        log_success "${T_PANIC_INACTIVE_STATUS:-PANIC MODE: INACTIVE (protected)}"
    fi
}

# ============================================================================
# SYSTEM RESTORE FUNCTIONS
# ============================================================================

restore_system() {
    log_section "${T_SYSTEM_RESTORE:-󰜝 System Restore}"

    local backup_dir="${CYTADELA_STATE_DIR}/backups"

    # Check if backup exists
    if [[ -d "$backup_dir" && -f "${backup_dir}/resolv.conf.pre-citadel" ]]; then
        log_info "${T_BACKUP_FOUND:-Found backup of original configuration - restoring...}"

        # Restore resolv.conf from backup
        log_info "${T_RESTORING_RESOLV:-Restoring /etc/resolv.conf from backup...}"
        chattr -i /etc/resolv.conf 2>/dev/null || true
        cp "${backup_dir}/resolv.conf.pre-citadel" /etc/resolv.conf 2>/dev/null || true

        # Restore systemd-resolved state
        _restore_systemd_resolved_state

        log_success "${T_BACKUP_RESTORED:-Restored original configuration from backup}"
    else
        log_warning "${T_NO_BACKUP:-No backup found - restoring default systemd-resolved configuration...}"

        log_info "${T_RESTORING_RESOLVED_DEFAULT:-Restoring systemd-resolved (default configuration)...}"
        systemctl unmask systemd-resolved 2>/dev/null || true
        systemctl enable systemd-resolved 2>/dev/null || true
        systemctl start systemd-resolved 2>/dev/null || true

        log_info "${T_RESTORING_RESOLV_DEFAULT:-Restoring /etc/resolv.conf (default symlink)...}"
        chattr -i /etc/resolv.conf 2>/dev/null || true
        rm -f /etc/resolv.conf
        ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true
    fi

    _cleanup_networkmanager

    # Test connectivity after restore
    log_info "${T_TESTING_CONNECTIVITY:-Testing connectivity after restore...}"
    if _test_connectivity; then
        log_success "${T_SYSTEM_RESTORED:-System restored to pre-Citadel state}"
    else
        log_error "${T_CONNECTIVITY_FAILED:-Connectivity test failed after restore}"
        if _offer_emergency_restore; then
            emergency_network_restore
        fi
    fi
}

restore_system_default() {
    log_section "${T_SYSTEM_RESTORE_DEFAULT:-󰜝 System Restore (Default)}"

    log_warning "${T_DEFAULT_WARNING:-This option restores FACTORY systemd-resolved configuration}"
    log_warning "${T_DEFAULT_WARNING_BACKUP:-Ignores user backup - use 'restore-system' to restore backup}"

    if [[ -t 0 && -t 1 ]]; then
        echo -n "${T_DEFAULT_CONFIRM:-Continue with default configuration restore?} [y/N]: "
        read -r answer
        [[ ! "$answer" =~ ^[Yy]$ ]] && {
            log_info "${T_CANCELLED:-Cancelled}"
            return 0
        }
    fi

    log_info "${T_RESTORING_RESOLVED_DEFAULT:-Restoring systemd-resolved (default configuration)...}"
    systemctl unmask systemd-resolved 2>/dev/null || true
    systemctl enable systemd-resolved 2>/dev/null || true
    systemctl start systemd-resolved 2>/dev/null || true

    _cleanup_networkmanager

    log_info "${T_RESTORING_RESOLV_DEFAULT:-Restoring /etc/resolv.conf (default symlink)...}"
    chattr -i /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true

    log_success "${T_DEFAULT_RESTORED:-System restored to DEFAULT systemd-resolved configuration}"
    log_info "${T_BACKUP_PRESERVED:-User backup (if exists) remains in} ${CYTADELA_STATE_DIR}/backups/"
}

# ============================================================================
# EMERGENCY NETWORK FUNCTIONS
# ============================================================================

emergency_network_restore() {
    log_section "${T_EMERGENCY_NETWORK_RESTORE:-[NETWORK] EMERGENCY NETWORK RESTORE}"
    log_warning "${T_EMERGENCY_WARNING:-This will attempt to restore internet connectivity}"
    log_warning "${T_EMERGENCY_PROTECTION_OFF:-Citadel protection will be temporarily disabled}"
    echo ""

    # Step 1: Immediate DNS fix with public servers
    log_info "${T_EMERGENCY_STEP1:-Step 1: Setting emergency public DNS...}"
    chattr -i /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf 2>/dev/null || true
    {
        echo "# EMERGENCY DNS - Set by Citadel emergency restore"
        echo "# This is a temporary configuration for connectivity recovery"
        printf 'nameserver %s\n' "${EMERGENCY_DNS_SERVERS[@]}"
        echo "options edns0 trust-ad"
    } > /etc/resolv.conf
    chmod 644 /etc/resolv.conf
    log_success "${T_EMERGENCY_DNS_SET:-Emergency DNS configured}"

    # Step 2: Stop Citadel services that might block DNS
    _stop_citadel_services

    # Step 3: Flush nftables rules (remove DNS blocks)
    _flush_all_firewall

    # Step 4: Detect and handle VPN connections
    _detect_vpn_interfaces

    # Step 5: Restart network management services
    _restart_all_network_services

    # Step 6: Flush DNS caches
    _flush_dns_caches

    # Step 7: Test connectivity
    _verify_final_connectivity
}

emergency_network_fix() {
    log_section "${T_EMERGENCY_FIX:-[FIX] EMERGENCY NETWORK FIX}"
    log_info "${T_EMERGENCY_FIX_DESC:-Quick DNS fix without full firewall reset}"

    # Set emergency DNS
    _restore_dns_fallback

    # Restart DNS-related services
    systemctl restart systemd-resolved 2>/dev/null || true
    systemctl restart NetworkManager 2>/dev/null || true

    # Flush DNS caches
    _flush_dns_caches

    # Quick connectivity test
    log_info "${T_TESTING_FIX:-Testing fix...}"
    if _test_connectivity; then
        log_success "${T_FIX_SUCCESS:-Network fix successful}"
    else
        log_warning "${T_FIX_FAILED:-Quick fix failed, try emergency-network-restore}"
    fi
}

# ============================================================================
# IPv6 RECOVERY FUNCTIONS
# ============================================================================

ipv6_emergency_reset() {
    log_section "${T_IPV6_RESET:-󰜝 IPv6 DEEP RESET}"

    local iface
    iface=$(ip route show | grep default | head -1 | awk '{print $5}')
    [[ -z "$iface" ]] && {
        log_error "${T_NO_ACTIVE_INTERFACE:-No active interface}"
        return 1
    }

    log_info "${T_FLUSHING_IPV6:-Flushing IPv6 addresses on} $iface..."
    ip -6 addr flush dev "$iface" scope global 2>/dev/null || true

    log_info "${T_FLUSHING_NEIGHBOR:-Flushing IPv6 neighbor cache...}"
    ip -6 neigh flush dev "$iface" 2>/dev/null || true

    # Detect network stack and reconnect
    if systemctl is-active --quiet NetworkManager; then
        log_info "${T_RECONNECTING_NM:-Reconnecting via NetworkManager...}"
        nmcli dev disconnect "$iface" 2>/dev/null || true
        sleep 2
        nmcli dev connect "$iface" 2>/dev/null || true
    elif systemctl is-active --quiet systemd-networkd; then
        log_info "${T_RECONFIGURING_NETWORKD:-Reconfiguring via systemd-networkd...}"
        networkctl reconfigure "$iface" 2>/dev/null || true
    fi

    log_success "${T_IPV6_RESET_COMPLETE:-IPv6 reset complete. Waiting for new addresses...}"
    sleep 3

    # Check IPv6 status
    ipv6_privacy_status
}

smart_ipv6_recovery() {
    log_section "${T_SMART_IPV6:-󰍉 SMART IPv6 DETECTION}"

    local iface
    iface=$(ip route show | grep default | head -1 | awk '{print $5}')
    [[ -z "$iface" ]] && {
        log_error "${T_NO_ACTIVE_INTERFACE:-No active interface}"
        return 1
    }

    log_info "${T_TESTING_IPV6:-Testing IPv6 connectivity...}"
    if ping -6 -c 3 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        log_success "${T_IPV6_OK:-IPv6 connectivity: OK}"
    else
        log_warning "${T_IPV6_FAILED:-IPv6 connectivity: FAILED}"
        log_info "${T_ATTEMPTING_AUTO:-Attempting auto-reconfiguration...}"
        ipv6_emergency_reset
    fi
}

# ============================================================================
# BACKWARD COMPATIBILITY ALIASES
# ============================================================================

# Aliases for compatibility with emergency.sh
killswitch_on() {
    emergency_killswitch_on
}

killswitch_off() {
    emergency_killswitch_off
}
