#!/bin/bash
# CITADEL INSTALL-WIZARD MODULE v3.2 - Frame-based UI

MODULE_NAME="install-wizard"
MODULE_VERSION="3.2.0"
MODULE_DESCRIPTION="Interactive installer with frame-based UI"
MODULE_AUTHOR="Citadel Team"
MODULE_DEPENDS=()
MODULE_TAGS=("install" "wizard" "interactive" "ui")

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
PURPLE_BOLD='\033[1;35m'

print_frame_line() {
    local text="$1"
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((60 - visible_len))
    printf "║ %b%*s ║\n" "$text" "$padding" ""
}

print_frame_header() {
    local title="$1"
    echo "╔══════════════════════════════════════════════════════════════╗"
    print_frame_line "${CYAN}${title}${NC}"
    echo "╠══════════════════════════════════════════════════════════════╣"
}

print_frame_footer() {
    echo "╚══════════════════════════════════════════════════════════════╝"
}

select_language_menu() {
    while true; do
        echo ""
        print_frame_header "SELECT LANGUAGE"
        print_frame_line "${GREEN}[1]${NC} English"
        print_frame_line "${GREEN}[2]${NC} Polski"
        print_frame_line "${GREEN}[3]${NC} Deutsch"
        print_frame_line "${GREEN}[4]${NC} Español"
        print_frame_line "${GREEN}[5]${NC} Italiano"
        print_frame_line "${GREEN}[6]${NC} Français"
        print_frame_line "${GREEN}[7]${NC} Русский"
        print_frame_line ""
        print_frame_line "${RED}[q]${NC} Cancel"
        print_frame_footer
        echo ""
        echo -n "Choice: "
        read -r choice </dev/tty
        case "$choice" in
            1) echo "en"; return ;;
            2) echo "pl"; return ;;
            3) echo "de"; return ;;
            4) echo "es"; return ;;
            5) echo "it"; return ;;
            6) echo "fr"; return ;;
            7) echo "ru"; return ;;
            q) echo ""; return 1 ;;
        esac
    done
}

install_wizard() {
    local WIZARD_LANG
    WIZARD_LANG=$(select_language_menu)
    [[ -z "$WIZARD_LANG" ]] && { log_warning "Cancelled"; return 1; }
    
    CYTADELA_LANG="$WIZARD_LANG" load_i18n_module "install-wizard"
    
    echo ""
    print_frame_header "CITADEL INSTALL WIZARD"
    print_frame_line ""
    print_frame_line "This wizard will install Citadel DNS system"
    print_frame_line ""
    print_frame_line "${PURPLE_BOLD}Required:${NC} Root privileges"
    print_frame_line "${PURPLE_BOLD}Time:${NC} ~5 minutes"
    print_frame_line ""
    print_frame_footer
    echo ""
    echo -n "Press Enter to continue..."
    read </dev/tty
    
    echo "Installation would continue here..."
}

install_wizard_help() {
    echo "Install wizard with frame-based UI"
}
