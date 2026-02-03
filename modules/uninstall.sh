#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNINSTALL MODULE v3.1                                         ║
# ║  Complete uninstallation of Citadel DNS Filter                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

citadel_uninstall() {
    # Load i18n for uninstall module
    load_i18n_module "uninstall"

    log_section "🗑️  ${T_UNINSTALL_TITLE:-CITADEL++ UNINSTALLATION}"

    log_warning "${T_UNINSTALL_WARNING:-This will REMOVE all Citadel components!}"
    log_info "${T_UNINSTALL_INFO:-Services will be stopped and disabled}"
    log_info "${T_UNINSTALL_CONFIG:-Configuration files will be deleted}"
    echo ""
    read -rp "${T_CONFIRM_UNINSTALL:-Are you sure? Type 'yes' to continue: }" confirm
    if [[ "$confirm" != "yes" ]]; then
        log_info "${T_UNINSTALL_CANCELLED:-Cancelled}"
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
        log_warning "${T_OPTIONAL_PKGS_FOUND:-The following packages were possibly installed for Citadel:}"
        printf "  • %s\n" "${optional_packages[@]}"
        log_info "${T_REMOVE_PKGS_MANUAL:-You may want to remove them manually if no other app needs them:}"
        log_info "  sudo pacman -R ${optional_packages[*]}"
        echo ""
        read -rp "${T_REMOVE_PKGS_NOW:-Remove these packages now? (y/N): }" remove_pkgs
        if [[ "$remove_pkgs" =~ ^[Yy]$ ]]; then
            log_info "${T_REMOVING:-Removing} packages..."
            # Remove only if no other packages depend on them
            for pkg in "${optional_packages[@]}"; do
                if pacman -Qi "$pkg" 2>/dev/null | grep -q "^Required By.*None"; then
                    log_info "${T_REMOVING:-Removing} $pkg ${T_NO_DEPS:-(no other package depends on it)}"
                    pacman -R --noconfirm "$pkg" 2>/dev/null || log_warning "Failed to remove $pkg"
                else
                    log_info "${T_SKIPPING:-Skipping} $pkg ${T_REQUIRED_BY:-(required by other packages)}"
                fi
            done
        fi
    else
        log_info "${T_NO_OPTIONAL_PKGS:-No optional packages found (dnsperf, curl, jq, etc.)}"
    fi

    echo ""

    # CRITICAL: Restore DNS first (before stopping services!)
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

    # Test DNS connectivity with multiple servers
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
        # Emergency frame - using exact print_menu_line pattern from help.sh
        print_frame_line() {
            local text="$1"
            local total_width=60
            local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
            local visible_len=${#visible_text}
            local padding=$((total_width - visible_len))
            printf "${RED}║${NC} %b%*s ${RED}║${NC}\n" "$text" "$padding" ""
        }
        
        printf "${RED}╔══════════════════════════════════════════════════════════════╗${NC}\n"
        print_frame_line "${BOLD}EMERGENCY RECOVERY:${NC}"
        printf "${RED}╠══════════════════════════════════════════════════════════════╣${NC}\n"
        print_frame_line "Run:"
        print_frame_line "  ${YELLOW}sudo ./citadel.sh emergency-network-restore${NC}"
        printf "${RED}╚══════════════════════════════════════════════════════════════╝${NC}\n"
        echo ""
        log_info "${T_MANUAL_FIX:-Manual fix options:}"
        log_info "  1. ${T_RESTART_NM:-Restart NetworkManager}: sudo systemctl restart NetworkManager"
        log_info "  2. ${T_RESTART_SD:-Or restart systemd-resolved}: sudo systemctl restart systemd-resolved"
        log_info "  3. ${T_MANUAL_EDIT:-Or manually edit}: sudo nano /etc/resolv.conf"
        log_info "     ${T_ADD_NAMESERVER:-and add}: nameserver 1.1.1.1"
        echo ""
        read -rp "${T_CONTINUE_ANYWAY:-Continue with uninstall despite DNS issues? (yes/no): }" continue_anyway
        if [[ "$continue_anyway" != "yes" ]]; then
            log_info "${T_UNINSTALL_CANCELLED_DNS:-Uninstall cancelled. Fix DNS first, then run uninstall again.}"
            return 0
        fi
    fi

    echo ""

    # Stop and disable services
    log_info "${T_STOPPING_SERVICES:-Stopping services...}"
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl disable coredns dnscrypt-proxy 2>/dev/null || true

    # Remove systemd drop-ins
    log_info "Removing systemd configurations..."
    rm -rf /etc/systemd/system/coredns.service.d/ 2>/dev/null || true
    rm -rf /etc/systemd/system/dnscrypt-proxy.service.d/ 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true

    # Remove firewall rules
    log_info "${T_REMOVING_FIREWALL:-Removing firewall rules...}"
    nft delete table inet citadel_dns 2>/dev/null || true
    rm -f /etc/nftables.d/citadel-dns.nft 2>/dev/null || true

    # Remove configuration files
    log_info "${T_REMOVING_CONFIG:-Removing configuration files...}"
    rm -rf /etc/coredns/ 2>/dev/null || true
    rm -rf /etc/dnscrypt-proxy/ 2>/dev/null || true

    # Remove data directories
    log_info "${T_REMOVING_DATA:-Removing data directories...}"
    rm -rf /var/lib/dnscrypt/ 2>/dev/null || true
    rm -rf /var/log/dnscrypt-proxy/ 2>/dev/null || true
    rm -rf /opt/cytadela/ 2>/dev/null || true
    rm -rf /var/cache/cytadela/ 2>/dev/null || true

    # Remove user
    log_info "${T_REMOVING_USER:-Removing system user...}"
    userdel dnscrypt 2>/dev/null || true

    # Remove dashboard if installed
    log_info "${T_REMOVING_DASHBOARD:-Removing dashboard...}"
    rm -f /usr/local/bin/citadel-top 2>/dev/null || true
    rm -f /etc/systemd/system/citadel-dashboard.service 2>/dev/null || true

    # Remove cron jobs
    log_info "${T_REMOVING_CRON:-Removing scheduled tasks...}"
    rm -f /etc/cron.d/cytadela-* 2>/dev/null || true

    # Remove scripts from /usr/local/bin
    log_info "${T_REMOVING_SHORTCUTS:-Removing command shortcuts...}"
    rm -f /usr/local/bin/citadel 2>/dev/null || true

    echo ""
    log_success "${T_UNINSTALL_COMPLETE:-Citadel has been completely removed}"
    echo ""
    
    # Emergency frame - using exact print_menu_line pattern from help.sh
    print_frame_line() {
        local text="$1"
        local total_width=60
        local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
        local visible_len=${#visible_text}
        local padding=$((total_width - visible_len))
        printf "${RED}║${NC} %b%*s ${RED}║${NC}\n" "$text" "$padding" ""
    }
    
    printf "${RED}╔══════════════════════════════════════════════════════════════╗${NC}\n"
    print_frame_line "${BOLD}NEXT STEPS:${NC}"
    printf "${RED}╠══════════════════════════════════════════════════════════════╣${NC}\n"
    print_frame_line "Reinstall:  sudo ./citadel.sh install-wizard"
    print_frame_line "If issues:  sudo ./citadel.sh emergency-network-restore"
    printf "${RED}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

citadel_uninstall_keep_config() {
    # Load i18n strings based on language
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    local module_dir="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
    if [[ -f "${module_dir}/lib/i18n/${lang}.sh" ]]; then
        # shellcheck source=/dev/null
        source "${module_dir}/lib/i18n/${lang}.sh"
    fi

    log_section "🗑️  ${T_KEEP_CONFIG_TITLE:-CITADEL++ UNINSTALL (Keep Config)}"

    log_warning "${T_KEEP_CONFIG_WARNING:-This will stop services but KEEP configuration files}"
    echo ""
    read -rp "${T_CONFIRM_KEEP_CONFIG:-Continue? Type 'yes': }" confirm
    if [[ "$confirm" != "yes" ]]; then
        log_info "${T_UNINSTALL_CANCELLED:-Cancelled}"
        return 0
    fi

    log_info "${T_STOPPING_SERVICES:-Stopping services...}"
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl disable coredns dnscrypt-proxy 2>/dev/null || true

    log_success "${T_SERVICES_STOPPED:-Services stopped, configuration preserved}"
    log_info "${T_RESTART_HINT:-To restart: sudo ./citadel.sh install-wizard}"
}
