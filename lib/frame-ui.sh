#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ FRAME UI LIBRARY                                              ║
# ║  Reusable frame drawing functions                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Funkcja do rysowania równej linii w ramce (z kolorem ramki)
print_menu_line() {
    local text="$1"
    local frame_color="${2:-$NC}"
    local total_width=60
    
    # Usuwamy kody kolorów (niewidoczne znaki) tylko do obliczenia długości
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    
    # Obliczamy ile spacji brakuje
    local padding=$((total_width - visible_len))
    
    # Drukujemy linię z kolorem ramki - używamy echo -e aby zinterpretować kody kolorów
    echo -e "${frame_color}║${NC} ${text}$(printf '%*s' "$padding" '') ${frame_color}║${NC}"
}

# Draw section header with purple frame
draw_section_header() {
    local title="$1"
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    print_menu_line "${BOLD}${title}${NC}" "$VIO"
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Draw emergency frame with red color
draw_emergency_frame() {
    local title="$1"
    shift
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    print_menu_line "${BOLD}${title}${NC}" "$RED"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
    for line in "$@"; do
        print_menu_line "$line" "$RED"
    done
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Backward compatibility - log_section now uses frames
log_section() {
    draw_section_header "$1"
}
