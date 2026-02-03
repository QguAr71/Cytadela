#!/bin/bash
# CYTADELA++ INTERACTIVE HELP MODULE

MODULE_NAME="help"
MODULE_VERSION="2.0.0"
MODULE_DESCRIPTION="Interactive multi-language help system"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=()
MODULE_TAGS=("help" "i18n" "documentation" "interactive")

citadel_help() {
    load_i18n_module "help"
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    
    while true; do
        clear 2>/dev/null || echo ""
        
        echo ""
        echo -e "${BLUE}========================================${NC}"
        echo -e "${CYAN}  CITADEL++ HELP${NC}"
        echo -e "${BLUE}========================================${NC}"
        echo ""
        echo -e "${GREEN}[1]${NC} 1. Installation"
        echo -e "${GREEN}[2]${NC} 2. Main Program"
        echo -e "${GREEN}[3]${NC} 3. Add-ons"
        echo -e "${GREEN}[4]${NC} 4. Advanced"
        echo -e "${GREEN}[5]${NC} 5. Emergency"
        echo -e "${YELLOW}[6]${NC} 6. All Commands"
        echo -e "${RED}[q]${NC} Quit"
        echo ""
        echo -n "Your choice: "
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
