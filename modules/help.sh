#!/bin/bash
# CYTADELA++ INTERACTIVE HELP MODULE

MODULE_NAME="help"
MODULE_VERSION="2.0.0"
MODULE_DESCRIPTION="Interactive multi-language help system"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=()
MODULE_TAGS=("help" "i18n" "documentation" "interactive")

# =============================================================================
# HELPER: Print menu line with proper alignment (handles ANSI colors)
# =============================================================================

print_menu_line() {
    local text="$1"
    local total_width=60
    
    # Strip ANSI colors for length calculation
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((total_width - visible_len))
    
    printf "║ %b%*s ║\n" "$text" "$padding" ""
}

# =============================================================================
# MAIN HELP FUNCTION - Interactive menu
# =============================================================================

citadel_help() {
    load_i18n_module "help"
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    
    while true; do
        clear 2>/dev/null || echo ""
        
        # Display menu with frame
        echo "╔══════════════════════════════════════════════════════════════╗"
        print_menu_line "${CYAN}${T_HELP_MENU_TITLE:-CITADEL++ HELP}${NC}"
        echo "╠══════════════════════════════════════════════════════════════╣"
        print_menu_line "${GREEN}[1]${NC} ${T_HELP_MENU_1:-1. Installation}"
        print_menu_line "${GREEN}[2]${NC} ${T_HELP_MENU_2:-2. Main Program}"
        print_menu_line "${GREEN}[3]${NC} ${T_HELP_MENU_3:-3. Add-ons}"
        print_menu_line "${GREEN}[4]${NC} ${T_HELP_MENU_4:-4. Advanced}"
        print_menu_line "${GREEN}[5]${NC} ${T_HELP_MENU_5:-5. Emergency}"
        print_menu_line "${YELLOW}[6]${NC} ${T_HELP_MENU_6:-6. All Commands}"
        print_menu_line ""
        print_menu_line "${RED}[q]${NC} ${T_HELP_MENU_QUIT:-Quit}"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo -n "${T_HELP_PROMPT:-Your choice}: "
        read choice
        
        case "$choice" in
            1) show_help_section_install "$lang" ;;
            2) show_help_section_main "$lang" ;;
            3) show_help_section_addons "$lang" ;;
            4) show_help_section_advanced "$lang" ;;
            5) show_help_section_emergency "$lang" ;;
            6) show_help_full "$lang" ;;
            q|Q) break ;;
            *) 
                echo -e "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
        
        if [[ "$choice" != "q" && "$choice" != "Q" ]]; then
            echo ""
            echo -n "Press Enter to return to menu..."
            read
        fi
    done
}

show_help_section_install() {
    echo ""
    echo -e "${GREEN}=== 1. INSTALLATION ===${NC}"
    echo ""
    echo -e "${CYAN}install-wizard${NC}     - Interactive installer"
    echo -e "${CYAN}install-all${NC}        - Install all DNS modules"
    echo -e "${CYAN}install-dnscrypt${NC}   - Install DNSCrypt only"
}

show_help_section_main() {
    echo ""
    echo -e "${YELLOW}=== 2. MAIN PROGRAM ===${NC}"
    echo ""
    echo -e "${CYAN}configure-system${NC}   - Switch to Citadel DNS"
    echo -e "${CYAN}status${NC}             - Show service status"
    echo -e "${CYAN}diagnostics${NC}        - Full diagnostics"
}

show_help_section_addons() {
    echo ""
    echo -e "${PURPLE}=== 3. ADD-ONS ===${NC}"
    echo ""
    echo -e "${CYAN}blocklist-list${NC}     - Show blocklist profiles"
    echo -e "${CYAN}adblock-status${NC}     - Show adblock status"
}

show_help_section_advanced() {
    echo ""
    echo -e "${RED}=== 4. ADVANCED ===${NC}"
    echo ""
    echo -e "${CYAN}panic-bypass${NC}       - Emergency bypass"
    echo -e "${CYAN}lkg-save${NC}           - Save blocklist"
}

show_help_section_emergency() {
    echo ""
    echo -e "${RED}=== 5. EMERGENCY ===${NC}"
    echo ""
    echo -e "${CYAN}panic-bypass${NC}       - Emergency bypass"
    echo -e "${CYAN}killswitch-on${NC}      - Activate kill-switch"
}

show_help_full() {
    show_help_section_install
    show_help_section_main
    show_help_section_addons
    show_help_section_advanced
    show_help_section_emergency
}
