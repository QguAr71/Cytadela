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

    # Restore original DNS
    log_info "Restoring original DNS configuration..."
    if [[ -f /etc/resolv.conf.bak ]]; then
        mv /etc/resolv.conf.bak /etc/resolv.conf 2>/dev/null || true
    else
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
    fi

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
