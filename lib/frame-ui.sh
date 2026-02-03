#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ FRAME UI LIBRARY                                              ║
# ║  Reusable frame drawing functions                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Draw a single line with colored frame borders
print_frame_line() {
    local text="$1"
    local frame_color="${2:-$VIO}"
    local total_width=60
    
    # Strip ANSI colors for length calculation  
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((total_width - visible_len))
    
    printf "${frame_color}║${NC} %b%*s ${frame_color}║${NC}\n" "$text" "$padding" ""
}

# Draw section header with purple frame
draw_section_header() {
    local title="$1"
    local total_width=60
    
    # Calculate display width - simple version without external tools
    local visible_title=$(echo -e "$title" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_title}
    # Add 1 extra space for common emoji (approximation)
    if [[ "$visible_title" =~ [📦🛡🎯📋🚀✅🔐🏥🔧🔒] ]]; then
        visible_len=$((visible_len + 1))
    fi
    local padding=$((total_width - visible_len))
    
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}${title}${NC}" "$padding" ""
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Draw emergency frame with red color
draw_emergency_frame() {
    local title="$1"
    shift
    local text="${BOLD}${title}${NC}"
    local total_width=60
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((total_width - visible_len))
    
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${RED}║${NC} %b%*s ${RED}║${NC}\n" "$text" "$padding" ""
    echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
    
    for line in "$@"; do
        local line_text="$line"
        local line_visible=$(echo -e "$line_text" | sed 's/\x1b\[[0-9;]*m//g')
        local line_len=${#line_visible}
        local line_padding=$((total_width - line_len))
        printf "${RED}║${NC} %b%*s ${RED}║${NC}\n" "$line_text" "$line_padding" ""
    done
    
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Backward compatibility - log_section now uses frames
log_section() {
    draw_section_header "$1"
}
