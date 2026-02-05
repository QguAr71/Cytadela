#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL UNINSTALL MODULE v3.3                                             ║
# ║  Complete uninstallation of Citadel DNS Filter                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

citadel_uninstall() {
    # Colors (256-color palette for better contrast)
    # Auto-disable colors if stdout is not a TTY (for CI/logs)
    if [[ -t 1 ]]; then
        EMR='\e[38;5;43m'  # Emerald - success/active
        VIO='\e[38;5;99m'  # Violet - info/sections
        MAG='\e[38;5;201m' # Magenta - accent
        RED='\e[38;5;196m' # Bloody Red - errors/warnings
        BOLD='\e[1m'       # Bold text
        NC='\e[0m'         # Reset
        RST='\e[0m'        # Reset (alias)
    else
        EMR=''
        VIO=''
        MAG=''
        RED=''
        BOLD=''
        NC=''
        RST=''
    fi

    # Legacy color aliases (for compatibility)
    # shellcheck disable=SC2034
    GREEN="$EMR"
    # shellcheck disable=SC2034
    YELLOW="$VIO"
    # shellcheck disable=SC2034
    BLUE="$VIO"
    # shellcheck disable=SC2034
    CYAN="$EMR"
    # shellcheck disable=SC2034
    PURPLE="$VIO"
    NC="$RST"

    # Configuration
    SCRIPT_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
    LOG_FILE="/tmp/citadel-uninstall-$(date +%Y%m%d-%H%M%S).log"

    # Gum availability check
    if command -v gum >/dev/null 2>&1; then
        GUM_AVAILABLE=true
    else
        GUM_AVAILABLE=false
    fi

    # Logging function
    log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
    }

    # Enhanced status output (matching installer)
    status() {
        if [[ "$GUM_AVAILABLE" == true ]]; then
            gum style --foreground 121 "✓ $1"
        else
            echo -e "${GREEN}✓${NC} $1"
        fi
    }

    error() {
        if [[ "$GUM_AVAILABLE" == true ]]; then
            gum style --foreground 196 "✗ $1"
        else
            echo -e "${RED}✗${NC} $1" >&2
        fi
        log "ERROR: $1"
        exit 1
    }

    warning() {
        if [[ "$GUM_AVAILABLE" == true ]]; then
            gum style --foreground 214 "⚠ $1"
        else
            echo -e "${YELLOW}⚠${NC} $1" >&2
        fi
        log "WARNING: $1"
    }

    info() {
        if [[ "$GUM_AVAILABLE" == true ]]; then
            gum style --foreground 39 "$1"
        else
            echo -e "${BLUE}$1${NC}"
        fi
    }

    # Load i18n
    load_i18n_module "uninstall"

    # Enhanced welcome message (matching installer)
    if [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --border double --width 64 --padding "1 2" --foreground 99 --bold "${T_UNINSTALL_TITLE:-Citadel Uninstallation}"
    else
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║                                                               ║"
        echo "║                ${T_UNINSTALL_TITLE:-Citadel Uninstallation}                ║"
        echo "║                                                               ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
    fi

    echo -e "${VIO}${T_WORKING_DIRECTORY:-Working directory:}${NC} $SCRIPT_DIR"
    echo -e "${VIO}${T_LOG_FILE_LABEL:-Log file:}${NC} $LOG_FILE"
    echo ""

    log "Starting Citadel uninstallation"

    # Display uninstall plan (matching installer)
    if [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --border normal --width 64 --padding "0 1" --foreground 75 --bold "${T_UNINSTALL_PLAN_TITLE:-Citadel Uninstallation Plan}"
    else
        echo "┌───────────────────────────────────────────────────────────────┐"
        echo "│                ${T_UNINSTALL_PLAN_TITLE:-Citadel Uninstallation Plan}                 │"
        echo "└───────────────────────────────────────────────────────────────┘"
    fi

    echo -e "${VIO}${T_PLAN_WARNING:-This will REMOVE all Citadel components!}${NC}"
    echo -e "${VIO}${T_PLAN_SERVICES:-Services will be stopped and disabled}${NC}"
    echo -e "${VIO}${T_PLAN_CONFIG:-Configuration files will be deleted}${NC}"
    echo ""

    # Check for root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo)"
    fi

    # Confirmation prompt (matching installer)
    if [[ "$GUM_AVAILABLE" == true ]]; then
        if gum confirm --affirmative="Tak" --negative="Nie" --selected.foreground 46 --selected.background 27 --unselected.foreground 196 --unselected.background 250 "${T_CONFIRM_CONTINUE:-Are you sure you want to continue?}"; then
            confirm="yes"
        else
            confirm="no"
        fi
    else
        echo -n "Are you sure you want to continue? [y/N]: "
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            confirm="yes"
        else
            confirm="no"
        fi
    fi

    if [[ "$confirm" != "yes" ]]; then
        info "${T_UNINSTALL_CANCELLED:-Uninstallation cancelled}"
        exit 0
    fi

    # Main uninstallation logic
    status "${T_STARTING_UNINSTALL:-Starting uninstallation process...}"

    # Stop services
    status "${T_STOPPING_SERVICES:-Stopping Citadel services...}"
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl disable coredns dnscrypt-proxy 2>/dev/null || true

    # DNS restoration
    status "${T_RESTORING_DNS:-Restoring DNS configuration...}"
    local dns_restored=false
    local dns_servers=("1.1.1.1" "8.8.8.8" "9.9.9.9")
    local backup_dir="${CYTADELA_STATE_DIR}/backups"
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
    if [[ "$dns_restored" == false ]]; then
        log_info "Setting fallback DNS servers..."
        chattr -i /etc/resolv.conf 2>/dev/null || true
        cat > /etc/resolv.conf << 'EOF'
# Temporary DNS configuration after Citadel uninstall
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 9.9.9.9
EOF
        if [[ $? -eq 0 ]]; then
            log_info "Set fallback DNS (Cloudflare, Google, Quad9)"
        else
            log_error "Failed to write to /etc/resolv.conf - trying alternative method"
            if command -v resolvconf >/dev/null 2>&1; then
                echo "nameserver 1.1.1.1" | resolvconf -a lo.dns-restore 2>/dev/null || true
                echo "nameserver 8.8.8.8" | resolvconf -a lo.dns-restore 2>/dev/null || true
                echo "nameserver 9.9.9.9" | resolvconf -a lo.dns-restore 2>/dev/null || true
                log_info "Used resolvconf to set fallback DNS"
            else
                log_error "Could not restore DNS configuration. Manual intervention may be required."
                log_error "Try: sudo chattr -i /etc/resolv.conf && sudo nano /etc/resolv.conf"
            fi
        fi
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
        
        # NEW: Offer emergency network restore option
        log_warning "${T_EMERGENCY_OFFER:-Connectivity test failed. Would you like to run emergency network restore?}"
        echo ""
        log_info "${T_EMERGENCY_OPTION:-This will:}"
        log_info "  • ${T_EMERGENCY_DNS:-Set emergency public DNS servers}"
        log_info "  • ${T_EMERGENCY_STOP:-Stop Citadel DNS services}"  
        log_info "  • ${T_EMERGENCY_FLUSH:-Flush firewall rules}"
        log_info "  • ${T_EMERGENCY_RESTART:-Restart network services}"
        echo ""
        
        if [[ "$GUM_AVAILABLE" == true ]]; then
            if gum confirm --affirmative="Tak" --negative="Nie" --selected.foreground 46 --selected.background 27 --unselected.foreground 196 --unselected.background 250 "${T_RUN_EMERGENCY:-Run emergency network restore now?}"; then
                run_emergency="yes"
            else
                run_emergency="no"
            fi
        else
            echo -n "${T_RUN_EMERGENCY:-Run emergency network restore now?} [y/N]: "
            read -r run_emergency
            if [[ "$run_emergency" =~ ^[Yy]$ ]]; then
                run_emergency="yes"
            else
                run_emergency="no"
            fi
        fi
        
        if [[ "$run_emergency" == "yes" ]]; then
            log_info "${T_RUNNING_EMERGENCY:-Running emergency network restore...}"
            
            # Try to run emergency network restore
            if [[ -f "../citadel.sh" ]]; then
                if ../citadel.sh recovery emergency-network-restore; then
                    log_success "${T_EMERGENCY_SUCCESS:-Emergency network restore completed successfully}"
                    
                    # Test connectivity again after emergency restore
                    log_info "${T_TESTING_AGAIN:-Testing connectivity again...}"
                    dns_works_after=false
                    for server in "${dns_servers[@]}"; do
                        if dig +time=2 +tries=1 @"$server" google.com >/dev/null 2>&1; then
                            log_success "${T_DNS_OK:-DNS connectivity verified via} $server"
                            dns_works_after=true
                            break
                        fi
                    done
                    
                    if [[ "$dns_works_after" == true ]]; then
                        log_success "${T_CONNECTIVITY_RESTORED:-Internet connectivity restored successfully!}"
                        dns_works=true  # Mark as working for continuation
                    else
                        log_warning "${T_EMERGENCY_FAILED:-Emergency restore completed but connectivity test still fails}"
                        log_info "${T_MANUAL_INTERVENTION:-Manual intervention may still be required}"
                    fi
                else
                    log_error "${T_EMERGENCY_FAILED_RUN:-Failed to run emergency network restore}"
                fi
            else
                log_error "${T_CITADEL_NOT_FOUND:-citadel.sh not found - cannot run emergency restore}"
            fi
        fi
        
        echo ""
        draw_emergency_frame "${T_EMERGENCY_RECOVERY:-EMERGENCY RECOVERY:}" \
            "${T_RUN_CMD:-Run:}" \
            "${T_RECOVERY_CMD:-  sudo ./citadel.sh emergency-network-restore}"
        log_info "${T_MANUAL_FIX:-Manual fix options:}"
        log_info "  1. ${T_RESTART_NM:-Restart NetworkManager}: sudo systemctl restart NetworkManager"
        log_info "  2. ${T_RESTART_SD:-Or restart systemd-resolved}: sudo systemctl restart systemd-resolved"
        log_info "  3. ${T_MANUAL_EDIT:-Or manually edit}: sudo nano /etc/resolv.conf"
        log_info "     ${T_ADD_NAMESERVER:-and add}: nameserver 1.1.1.1"
        echo ""
        if [[ "$GUM_AVAILABLE" == true ]]; then
            if gum confirm --affirmative="Tak" --negative="Nie" --selected.foreground 46 --selected.background 27 --unselected.foreground 196 --unselected.background 250 "${T_CONTINUE_ANYWAY:-Continue with uninstall despite DNS issues?}"; then
                continue_anyway="yes"
            else
                continue_anyway="no"
            fi
        else
            read -rp "${T_CONTINUE_ANYWAY:-Continue with uninstall despite DNS issues? (yes/no): }" continue_anyway
        fi
        if [[ "$continue_anyway" != "yes" ]]; then
            log_info "${T_UNINSTALL_CANCELLED_DNS:-Uninstall cancelled. Fix DNS first, then run uninstall again.}"
            return 0
        fi
    fi

    # Remove components
    status "${T_REMOVING_COMPONENTS:-Removing Citadel components...}"

    # Check for optional packages that might be removable
    status "${T_CHECKING_DEPS:-Checking optional dependencies...}"
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
        warning "${T_FOUND_PACKAGES:-Found optional packages that may have been installed for Citadel:}"
        printf "  • %s\n" "${optional_packages[@]}"
        info "${T_REMOVE_PKGS_MANUAL:-You may want to remove them manually if no other app needs them:}"
        info "  sudo pacman -R ${optional_packages[*]}"
        echo ""
        if [[ "$GUM_AVAILABLE" == true ]]; then
            if gum confirm --affirmative="Tak" --negative="Nie" --selected.foreground 46 --selected.background 27 --unselected.foreground 196 --unselected.background 250 "${T_REMOVE_PKGS_NOW:-Remove these packages now?}"; then
                remove_pkgs="y"
            else
                remove_pkgs="n"
            fi
        else
            echo -n "Remove these packages now? [y/N]: "
            read -r remove_pkgs
        fi
        if [[ "$remove_pkgs" =~ ^[Yy]$ ]]; then
            status "${T_REMOVING_PACKAGES:-Removing packages...}"
            # Remove only if no other packages depend on them
            for pkg in "${optional_packages[@]}"; do
                if pacman -Qi "$pkg" 2>/dev/null | grep -q "^Required By.*None"; then
                    info "${T_REMOVING:-Removing} $pkg ${T_NO_DEPS:-no other package depends on it}"
                    pacman -R --noconfirm "$pkg" 2>/dev/null || warning "${T_FAILED_REMOVE:-Failed to remove} $pkg"
                else
                    info "${T_SKIPPING_PACKAGE:-Skipping} $pkg ${T_REQUIRED_BY_DEPS:-required by other packages}"
                fi
            done
        fi
    else
        info "${T_NO_OPTIONAL_PKGS:-No optional packages found}"
    fi

    # Remove Citadel components
    status "${T_REMOVING_FILES:-Removing Citadel files and configurations...}"
    rm -rf /etc/coredns/ 2>/dev/null || true
    rm -rf /etc/dnscrypt-proxy/ 2>/dev/null || true
    rm -rf /var/lib/dnscrypt/ 2>/dev/null || true
    rm -rf /var/log/dnscrypt-proxy/ 2>/dev/null || true
    rm -rf /opt/cytadela/ 2>/dev/null || true
    rm -rf /var/cache/cytadela/ 2>/dev/null || true

    # Remove system components
    status "${T_REMOVING_SYSTEM:-Removing system components...}"
    userdel dnscrypt 2>/dev/null || true
    rm -f /usr/local/bin/citadel-top 2>/dev/null || true
    rm -f /etc/systemd/system/citadel-dashboard.service 2>/dev/null || true
    rm -f /etc/cron.d/cytadela-* 2>/dev/null || true
    rm -f /usr/local/bin/citadel 2>/dev/null || true

    # Clean up firewall and systemd
    if command -v nft >/dev/null 2>&1; then
        # Use proper nftables uninstall if available
        if declare -f uninstall_nftables >/dev/null 2>&1; then
            uninstall_nftables 2>/dev/null || true
        else
            # Fallback basic cleanup
            nft delete table inet citadel_dns 2>/dev/null || true
            rm -f /etc/nftables.d/citadel-dns.nft 2>/dev/null || true
        fi
    fi
    rm -rf /etc/systemd/system/coredns.service.d/ 2>/dev/null || true
    rm -rf /etc/systemd/system/dnscrypt-proxy.service.d/ 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true

    # Completion
    echo ""
    if [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --border double --width 64 --padding "1 2" --foreground 43 --bold "${T_UNINSTALL_COMPLETE_TITLE:-UNINSTALLATION COMPLETE}"
    else
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║                                                               ║"
        echo "║                 UNINSTALLATION COMPLETE                      ║"
        echo "║                                                               ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
    fi

    status "${T_UNINSTALL_SUCCESS:-Citadel has been completely uninstalled!}"

    # Always show emergency recovery info at the end as safety reminder
    echo ""
    draw_emergency_frame "${T_EMERGENCY_RECOVERY:-EMERGENCY RECOVERY:}" \
        "${T_RUN_CMD:-Run:}" \
        "${T_RECOVERY_CMD:-  sudo ./citadel.sh emergency-network-restore}"
    info "${T_MANUAL_FIX:-Manual fix options:}"
    info "  1. ${T_RESTART_NM:-Restart NetworkManager}: sudo systemctl restart NetworkManager"
    info "  2. ${T_RESTART_SD:-Or restart systemd-resolved}: sudo systemctl restart systemd-resolved"
    info "  3. ${T_MANUAL_EDIT:-Or manually edit}: sudo nano /etc/resolv.conf"
    info "     ${T_ADD_NAMESERVER:-and add}: nameserver 1.1.1.1"

    echo ""
    echo -e "${VIO}${T_LOG_FILE_LABEL:-Log file:}${NC} $LOG_FILE"

    log "Uninstallation completed successfully"
}
