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
    
    # Module selection with toggle
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
        echo ""
        log_section "${T_INSTALLING:-INSTALLING}"
        echo "Installation would run here..."
        sleep 1
        log_success "${T_COMPLETE:-Complete!}"
    else
        log_warning "${T_CANCELLED:-Cancelled}"
        return 1
    fi
}
