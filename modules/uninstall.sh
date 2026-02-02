#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNINSTALL MODULE v3.1                                         ║
# ║  Complete uninstallation of Citadel DNS Filter                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

citadel_uninstall() {
    log_section "🗑️  CITADEL++ UNINSTALLATION"

    log_warning "This will REMOVE all Citadel components!"
    log_info "Services will be stopped and disabled"
    log_info "Configuration files will be deleted"
    echo ""
    read -rp "Are you sure? Type 'yes' to continue: " confirm
    if [[ "$confirm" != "yes" ]]; then
        log_info "Cancelled"
        return 0
    fi

    # Check for optional packages that might be removable
    echo ""
    log_info "Checking optional dependencies..."
    local optional_packages=()
    local pkg
    for pkg in dnsperf curl jq whiptail notify-send shellcheck; do
        if command -v "$pkg" >/dev/null 2>&1; then
            # Check if it's a system package (not manually compiled)
            if pacman -Qq "$pkg" 2>/dev/null | grep -q "^$pkg$"; then
                optional_packages+=("$pkg")
            fi
        fi
    done

    if [[ ${#optional_packages[@]} -gt 0 ]]; then
        log_warning "The following packages were possibly installed for Citadel:"
        printf "  • %s\n" "${optional_packages[@]}"
        log_info "You may want to remove them manually if no other app needs them:"
        log_info "  sudo pacman -R ${optional_packages[*]}"
        echo ""
        read -rp "Remove these packages now? (y/N): " remove_pkgs
        if [[ "$remove_pkgs" =~ ^[Yy]$ ]]; then
            log_info "Removing packages..."
            # Remove only if no other packages depend on them
            for pkg in "${optional_packages[@]}"; do
                if pacman -Qi "$pkg" 2>/dev/null | grep -q "^Required By.*None"; then
                    log_info "Removing $pkg (no other package depends on it)"
                    pacman -R --noconfirm "$pkg" 2>/dev/null || log_warning "Failed to remove $pkg"
                else
                    log_info "Skipping $pkg (required by other packages)"
                fi
            done
        fi
    fi

    echo ""

    # CRITICAL: Restore DNS first (before stopping services!)
    log_info "Restoring original DNS configuration..."
    
    local dns_restored=false
    local dns_servers=("1.1.1.1" "8.8.8.8" "9.9.9.9")
    
    # Check if backup exists and is valid (not pointing to localhost)
    if [[ -f /etc/resolv.conf.bak ]]; then
        local backup_dns
        backup_dns=$(grep "^nameserver" /etc/resolv.conf.bak | head -1 | awk '{print $2}')
        if [[ "$backup_dns" != "127.0.0.1" && -n "$backup_dns" ]]; then
            mv /etc/resolv.conf.bak /etc/resolv.conf 2>/dev/null || true
            log_success "Restored from backup (DNS: $backup_dns)"
            dns_restored=true
        else
            log_warning "Backup points to localhost, ignoring..."
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

    # Test DNS connectivity with multiple servers
    log_info "Testing DNS connectivity..."
    local dns_works=false
    for server in "${dns_servers[@]}"; do
        if dig +time=2 +tries=1 @"$server" google.com >/dev/null 2>&1; then
            log_success "DNS connectivity verified via $server"
            dns_works=true
            break
        fi
    done
    
    if [[ "$dns_works" == false ]]; then
        log_error "DNS test failed - system may lose internet after restart!"
        echo ""
        log_info "Manual fix options:"
        log_info "  1. Restart NetworkManager: sudo systemctl restart NetworkManager"
        log_info "  2. Or restart systemd-resolved: sudo systemctl restart systemd-resolved"
        log_info "  3. Or manually edit: sudo nano /etc/resolv.conf"
        log_info "     and add: nameserver 1.1.1.1"
        echo ""
        read -rp "Continue with uninstall despite DNS issues? (yes/no): " continue_anyway
        if [[ "$continue_anyway" != "yes" ]]; then
            log_info "Uninstall cancelled. Fix DNS first, then run uninstall again."
            return 0
        fi
    fi

    echo ""

    # Stop and disable services
    log_info "Stopping services..."
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl disable coredns dnscrypt-proxy 2>/dev/null || true

    # Remove systemd drop-ins
    log_info "Removing systemd configurations..."
    rm -rf /etc/systemd/system/coredns.service.d/ 2>/dev/null || true
    rm -rf /etc/systemd/system/dnscrypt-proxy.service.d/ 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true

    # Remove firewall rules
    log_info "Removing firewall rules..."
    nft delete table inet citadel_dns 2>/dev/null || true
    rm -f /etc/nftables.d/citadel-dns.nft 2>/dev/null || true

    # Remove configuration files
    log_info "Removing configuration files..."
    rm -rf /etc/coredns/ 2>/dev/null || true
    rm -rf /etc/dnscrypt-proxy/ 2>/dev/null || true

    # Remove data directories
    log_info "Removing data directories..."
    rm -rf /var/lib/dnscrypt/ 2>/dev/null || true
    rm -rf /var/log/dnscrypt-proxy/ 2>/dev/null || true
    rm -rf /opt/cytadela/ 2>/dev/null || true
    rm -rf /var/cache/cytadela/ 2>/dev/null || true

    # Remove user
    log_info "Removing system user..."
    userdel dnscrypt 2>/dev/null || true

    # Remove dashboard if installed
    log_info "Removing dashboard..."
    rm -f /usr/local/bin/citadel-top 2>/dev/null || true
    rm -f /etc/systemd/system/citadel-dashboard.service 2>/dev/null || true

    # Remove cron jobs
    log_info "Removing scheduled tasks..."
    rm -f /etc/cron.d/cytadela-* 2>/dev/null || true

    # Remove scripts from /usr/local/bin
    log_info "Removing command shortcuts..."
    rm -f /usr/local/bin/citadel 2>/dev/null || true

    echo ""
    log_success "Citadel has been completely removed"
    echo ""
    log_info "To reinstall, run: sudo ./citadel.sh install-wizard"
}

citadel_uninstall_keep_config() {
    log_section "🗑️  CITADEL++ UNINSTALL (Keep Config)"

    log_warning "This will stop services but KEEP configuration files"
    echo ""
    read -rp "Continue? Type 'yes': " confirm
    if [[ "$confirm" != "yes" ]]; then
        log_info "Cancelled"
        return 0
    fi

    # Stop services only
    log_info "Stopping services..."
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl disable coredns dnscrypt-proxy 2>/dev/null || true

    log_success "Services stopped, configuration preserved"
    log_info "To restart: sudo ./citadel.sh install-wizard"
}
