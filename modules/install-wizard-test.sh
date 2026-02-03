#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-WIZARD MODULE v3.2                                    ║
# ║  Interactive installer with frames (consistent with help system)          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

MODULE_NAME="install-wizard"
MODULE_VERSION="3.2.0"
MODULE_DESCRIPTION="Interactive installer with frame-based UI"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=()
MODULE_TAGS=("install" "wizard" "interactive" "ui")

# Color definitions (in case not loaded from core)
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# =============================================================================
# FRAME HELPERS (shared with help.sh pattern)
# =============================================================================

print_frame_line() {
    local text="$1"
    local width="${2:-60}"
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((width - visible_len))
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

# =============================================================================
# LANGUAGE SELECTION
# =============================================================================

select_language_menu() {
    echo "DEBUG: Entering select_language_menu" >&2
    while true; do
        echo "DEBUG: In loop" >&2
        # clear 2>/dev/null || echo ""
        echo "DEBUG: After clear" >&2
        print_frame_header "SELECT LANGUAGE"
        echo "DEBUG: After header" >&2
        print_frame_line "${GREEN}[1]${NC} English"
        print_frame_line "${GREEN}[2]${NC} Polski"
        print_frame_footer
        echo "DEBUG: Before read" >&2
        echo -n "Choice: "
        read choice
        echo "DEBUG: Read choice: $choice" >&2
        case "$choice" in
            1) echo "en"; return ;;
            2) echo "pl"; return ;;
            q) echo ""; return 1 ;;
        esac
    done
}

# =============================================================================
# MAIN WIZARD
# =============================================================================

install_wizard() {
    # Language selection
    local WIZARD_LANG
    WIZARD_LANG=$(select_language_menu)
    if [[ -z "$WIZARD_LANG" ]]; then
        log_warning "Wizard cancelled"
        return 1
    fi
    
    # Load i18n
    CYTADELA_LANG="$WIZARD_LANG" load_i18n_module "install-wizard"
    
    # Show welcome
    clear
    print_frame_header "${T_WIZARD_TITLE:-CITADEL++ INSTALL WIZARD}"
    print_frame_line ""
    print_frame_line "${T_WIZARD_DESC:-This wizard will install Citadel++ DNS system}"
    print_frame_line ""
    print_frame_line "${YELLOW}Required:${NC} Root privileges"
    print_frame_line "${YELLOW}Time:${NC} ~5 minutes"
    print_frame_footer
    echo ""
    echo -n "${T_PRESS_ENTER:-Press Enter to continue...}"
    read
    
    # Module selection menu
    select_modules_menu "$WIZARD_LANG"
}

select_modules_menu() {
    local lang="$1"
    local selected=()
    local required=(dnscrypt coredns nftables)
    local optional=(health supply-chain lkg ipv6 location nft-debug)
    
    while true; do
        clear
        print_frame_header "${T_SELECT_MODULES:-SELECT MODULES}"
        
        # Show required (always selected)
        print_frame_line "${YELLOW}${T_REQUIRED:-REQUIRED}:${NC}"
        for mod in "${required[@]}"; do
            print_frame_line "  ${GREEN}[✓]${NC} ${mod}"
        done
        
        # Show optional with selection status
        print_frame_line ""
        print_frame_line "${YELLOW}${T_OPTIONAL:-OPTIONAL}:${NC}"
        local i=1
        for mod in "${optional[@]}"; do
            local status="${RED}[ ]${NC}"
            if [[ " ${selected[*]} " =~ " ${mod} " ]]; then
                status="${GREEN}[✓]${NC}"
            fi
            print_frame_line "${GREEN}[$i]${NC} $status ${mod}"
            ((i++))
        done
        
        print_frame_line ""
        print_frame_line "${YELLOW}[c]${NC} ${T_CONTINUE:-Continue}"
        print_frame_line "${RED}[q]${NC} ${T_CANCEL:-Cancel}"
        print_frame_footer
        echo ""
        echo -n "${T_CHOICE:-Choice}: "
        read choice
        
        case "$choice" in
            [1-7])
                local idx=$((choice-1))
                local mod="${optional[$idx]}"
                if [[ " ${selected[*]} " =~ " ${mod} " ]]; then
                    selected=(${selected[@]/$mod})
                else
                    selected+=("$mod")
                fi
                ;;
            c) break ;;
            q) return 1 ;;
        esac
    done
    
    # Combine required + selected
    local modules_to_install=("${required[@]}" "${selected[@]}")
    
    # Show summary and confirm
    show_summary "$lang" "${modules_to_install[@]}"
}

show_summary() {
    local lang="$1"
    shift
    local modules=("$@")
    
    clear
    print_frame_header "${T_SUMMARY:-INSTALLATION SUMMARY}"
    print_frame_line ""
    print_frame_line "${T_SELECTED_MODULES:-Selected modules:}"
    for mod in "${modules[@]}"; do
        print_frame_line "  ${GREEN}✓${NC} ${mod}"
    done
    print_frame_line ""
    print_frame_line "${YELLOW}${T_WARNING:-This will configure DNS on your system}${NC}"
    print_frame_footer
    echo ""
    echo -n "${T_PROCEED:-Proceed? [y/N]: }"
    read answer
    
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        install_modules "$lang" "${modules[@]}"
    else
        log_warning "${T_CANCELLED:-Installation cancelled}"
        return 1
    fi
}

install_modules() {
    local lang="$1"
    shift
    local modules=("$@")
    
    log_section "${T_INSTALLING:-INSTALLING MODULES}"
    
    for mod in "${modules[@]}"; do
        echo ""
        log_info "Installing: ${mod}"
        # Module installation logic here (same as before)
        sleep 0.5  # Placeholder
    done
    
    log_success "${T_COMPLETE:-Installation complete!}"
}
