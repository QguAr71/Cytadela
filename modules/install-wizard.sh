#!/bin/bash
# ULTRA MINIMAL INSTALL WIZARD - WITH COLORS

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE_BOLD='\033[1;35m'
CYAN='\033[0;36m'

print_frame_line() {
    local text="$1"
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((60 - visible_len))
    printf "║ %b%*s ║\n" "$text" "$padding" ""
}

install_wizard() {
    # Check if already installed
    if [[ -d /etc/coredns ]] || [[ -f /etc/systemd/system/coredns.service ]] || [[ -d /opt/cytadela ]]; then
        already_installed_menu
        return $?
    fi
    
    # Language selection
    while true; do
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        print_frame_line "${CYAN}SELECT LANGUAGE${NC}"
        echo "╠══════════════════════════════════════════════════════════════╣"
        print_frame_line "${GREEN}[1]${NC} English"
        print_frame_line "${GREEN}[2]${NC} Polski"
        print_frame_line "${GREEN}[3]${NC} Deutsch"
        print_frame_line "${RED}[q]${NC} Cancel"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo -n "Choice: "
        read -r choice </dev/tty
        
        case "$choice" in
            1) WIZARD_LANG="en"; break ;;
            2) WIZARD_LANG="pl"; break ;;
            3) WIZARD_LANG="de"; break ;;
            q) return 1 ;;
        esac
    done
    
    CYTADELA_LANG="$WIZARD_LANG" load_i18n_module "install-wizard"
    
    # Welcome
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    print_frame_line "${CYAN}${T_WIZARD_TITLE:-CITADEL INSTALL WIZARD}${NC}"
    echo "╠══════════════════════════════════════════════════════════════╣"
    print_frame_line ""
    print_frame_line "${T_WIZARD_DESC:-This wizard will install Citadel DNS system}"
    print_frame_line ""
    print_frame_line "${PURPLE_BOLD}${T_REQUIRED:-Required}:${NC} Root privileges"
    print_frame_line "${PURPLE_BOLD}${T_TIME:-Time}:${NC} ~5 minutes"
    print_frame_line ""
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "${T_PRESS_ENTER:-Press Enter to continue...}"
    read </dev/tty
    
    # Module selection
    local selected=()
    while true; do
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        print_frame_line "${CYAN}${T_SELECT_MODULES:-SELECT MODULES}${NC}"
        echo "╠══════════════════════════════════════════════════════════════╣"
        print_frame_line "${PURPLE_BOLD}${T_REQUIRED:-REQUIRED}:${NC}"
        print_frame_line "  ${GREEN}[✓]${NC} DNSCrypt-Proxy"
        print_frame_line "  ${GREEN}[✓]${NC} CoreDNS"
        print_frame_line "  ${GREEN}[✓]${NC} NFTables"
        print_frame_line ""
        print_frame_line "${PURPLE_BOLD}${T_OPTIONAL:-OPTIONAL}:${NC}"
        local status1="${RED}[ ]${NC}"
        local status2="${RED}[ ]${NC}"
        [[ " ${selected[*]} " =~ " health " ]] && status1="${GREEN}[✓]${NC}"
        [[ " ${selected[*]} " =~ " lkg " ]] && status2="${GREEN}[✓]${NC}"
        print_frame_line "${GREEN}[1]${NC} $status1 Health Watchdog"
        print_frame_line "${GREEN}[2]${NC} $status2 LKG Cache"
        print_frame_line ""
        print_frame_line "${YELLOW}[c]${NC} ${T_CONTINUE:-Continue}  ${RED}[q]${NC} ${T_CANCEL:-Cancel}"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo -n "${T_CHOICE:-Choice}: "
        read -r mod_choice </dev/tty
        
        case "$mod_choice" in
            1) 
                if [[ " ${selected[*]} " =~ " health " ]]; then
                    selected=(${selected[@]/health})
                else
                    selected+=("health")
                fi
                ;;
            2)
                if [[ " ${selected[*]} " =~ " lkg " ]]; then
                    selected=(${selected[@]/lkg})
                else
                    selected+=("lkg")
                fi
                ;;
            c) break ;;
            q) return 1 ;;
        esac
    done
    
    # Summary
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    print_frame_line "${CYAN}${T_SUMMARY:-INSTALLATION SUMMARY}${NC}"
    echo "╠══════════════════════════════════════════════════════════════╣"
    print_frame_line ""
    print_frame_line "${T_SELECTED_MODULES:-Selected modules:}"
    print_frame_line "  ${GREEN}✓${NC} DNSCrypt-Proxy"
    print_frame_line "  ${GREEN}✓${NC} CoreDNS"
    print_frame_line "  ${GREEN}✓${NC} NFTables"
    for mod in "${selected[@]}"; do
        print_frame_line "  ${GREEN}✓${NC} ${mod}"
    done
    print_frame_line ""
    print_frame_line "${YELLOW}${T_WARNING:-This will configure DNS}${NC}"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "${T_PROCEED:-Proceed? [y/N]: }"
    read -r answer </dev/tty
    
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        run_full_installation "$WIZARD_LANG" "${selected[@]}"
    else
        log_warning "${T_CANCELLED:-Cancelled}"
        return 1
    fi
}

already_installed_menu() {
    while true; do
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        print_frame_line "${CYAN}CITADEL SETUP${NC}"
        echo "╠══════════════════════════════════════════════════════════════╣"
        print_frame_line "Citadel is already installed."
        print_frame_line ""
        print_frame_line "${GREEN}[1]${NC} Reinstall with backup"
        print_frame_line "${GREEN}[2]${NC} Remove Citadel"
        print_frame_line "${GREEN}[3]${NC} Modify components"
        print_frame_line "${RED}[q]${NC} Exit"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo -n "Choice: "
        read -r choice </dev/tty
        
        case "$choice" in
            1) 
                if declare -f config_backup_create >/dev/null 2>&1; then
                    config_backup_create
                fi
                if declare -f citadel_uninstall >/dev/null 2>&1; then
                    citadel_uninstall
                else
                    load_module "uninstall"
                    citadel_uninstall
                fi
                return 0
                ;;
            2)
                if declare -f citadel_uninstall >/dev/null 2>&1; then
                    citadel_uninstall
                else
                    load_module "uninstall"
                    citadel_uninstall
                fi
                return 0
                ;;
            3)
                echo "Component modification coming in v3.2"
                return 0
                ;;
            q) return 1 ;;
        esac
    done
}

run_full_installation() {
    local lang="$1"
    shift
    local optional_modules=("$@")
    
    log_section "INSTALLING MODULES"
    local failed=0
    
    # Install required modules
    for mod in dnscrypt coredns nftables; do
        echo ""
        log_info "Installing: ${mod}"
        case "$mod" in
            dnscrypt)
                if ! declare -f install_dnscrypt >/dev/null 2>&1; then
                    load_module "install-dnscrypt"
                fi
                install_dnscrypt && log_success "${mod} installed" || { log_error "${mod} failed"; ((failed++)); }
                ;;
            coredns)
                if ! declare -f install_coredns >/dev/null 2>&1; then
                    load_module "install-coredns"
                fi
                install_coredns && log_success "${mod} installed" || { log_error "${mod} failed"; ((failed++)); }
                ;;
            nftables)
                if ! declare -f install_nftables >/dev/null 2>&1; then
                    load_module "install-nftables"
                fi
                install_nftables && log_success "${mod} installed" || { log_error "${mod} failed"; ((failed++)); }
                ;;
        esac
    done
    
    # Install optional modules
    for mod in "${optional_modules[@]}"; do
        echo ""
        log_info "Installing: ${mod}"
        case "$mod" in
            health)
                if ! declare -f install_health_watchdog >/dev/null 2>&1; then
                    load_module "health"
                fi
                install_health_watchdog && log_success "${mod} installed" || log_warning "${mod} failed"
                ;;
            lkg)
                if ! declare -f lkg_save_blocklist >/dev/null 2>&1; then
                    load_module "lkg"
                fi
                lkg_save_blocklist && log_success "${mod} configured" || log_warning "${mod} skipped"
                ;;
        esac
    done
    
    # Final verification
    echo ""
    log_section "INSTALLATION COMPLETE"
    
    if [[ $failed -eq 0 ]]; then
        log_success "All modules installed successfully!"
    else
        log_warning "$failed module(s) failed to install"
    fi
    
    if ! declare -f verify_stack >/dev/null 2>&1; then
        load_module "diagnostics"
    fi
    verify_stack
}
