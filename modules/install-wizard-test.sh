#!/bin/bash
# ULTRA MINIMAL INSTALL WIZARD - WITH COLORS

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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
            1|2|3) break ;;
            q) return 1 ;;
        esac
    done
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    print_frame_line "${CYAN}CITADEL INSTALL WIZARD${NC}"
    echo "╠══════════════════════════════════════════════════════════════╣"
    print_frame_line ""
    print_frame_line "This wizard will install Citadel++ DNS system"
    print_frame_line ""
    print_frame_line "${YELLOW}Required:${NC} Root privileges"
    print_frame_line "${YELLOW}Time:${NC} ~5 minutes"
    print_frame_line ""
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "Press Enter to continue..."
    read </dev/tty
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    print_frame_line "${CYAN}INSTALLATION SUMMARY${NC}"
    echo "╠══════════════════════════════════════════════════════════════╣"
    print_frame_line "Modules to install:"
    print_frame_line "${GREEN}✓${NC} DNSCrypt-Proxy"
    print_frame_line "${GREEN}✓${NC} CoreDNS"
    print_frame_line "${GREEN}✓${NC} NFTables"
    print_frame_line ""
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "Proceed? [y/N]: "
    read -r answer </dev/tty
    
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Installation started..."
    else
        echo "Cancelled."
        return 1
    fi
}
