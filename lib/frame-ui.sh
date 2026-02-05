#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ FRAME UI LIBRARY                                              ║
# ║  Reusable frame drawing functions                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Draw a single line with colored frame borders
print_frame_line() {
    local text="$1"
    local frame_color="${2:-$VIO}"
    local total_width=62
    
    # Strip ANSI colors for length calculation  
    local visible_text
    visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((total_width - visible_len))
    
    printf "${frame_color}│${NC} %b%*s ${frame_color}│${NC}\n" "$text" "$padding" ""
}

# Draw section header with purple frame
draw_section_header() {
    local title="$1"
    local total_width=62

    # Calculate display width with emoji awareness
    local visible_title
    visible_title=$(echo -e "$title" | sed 's/\x1b\[[0-9;]*m//g')
    
    # Calculate visual width (emoji = 2 columns)
    local visual_len
    if command -v python3 &>/dev/null; then
        visual_len=$(python3 -c "import unicodedata; print(sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in '$visible_title'))")
    else
        # Fallback to simple counting
        visual_len=${#visible_title}
    fi
    
    local padding=$((total_width - visual_len))

    echo ""
    echo -e "${VIO}╔════════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}${title}${NC}" "$padding" ""
    echo -e "${VIO}╚════════════════════════════════════════════════════════════════╝${NC}"
}

# Draw emergency frame with red color
draw_emergency_frame() {
    local title="$1"
    shift
    local text="${BOLD}${title}${NC}"
    local total_width=62
    
    # Calculate display width with emoji awareness
    local visible_text
    visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    
    # Calculate visual width (emoji = 2 columns)
    local visual_len
    if command -v python3 &>/dev/null; then
        visual_len=$(python3 -c "import unicodedata; print(sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in '$visible_text'))")
    else
        # Fallback to simple counting
        visual_len=${#visible_text}
    fi
    
    local padding=$((total_width - visual_len))
    
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    printf "${RED}║${NC} %b%*s ${RED}║${NC}\n" "$text" "$padding" ""
    echo -e "${RED}╠════════════════════════════════════════════════════════════════╣${NC}"
    
    for line in "$@"; do
        local line_text="$line"
        local line_visible
        line_visible=$(echo -e "$line_text" | sed 's/\x1b\[[0-9;]*m//g')
        local line_len=${#line_visible}
        local line_padding=$((total_width - line_len))
        printf "${RED}║${NC} %b%*s ${RED}║${NC}\n" "$line_text" "$line_padding" ""
    done
    
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
}

# Backward compatibility - log_section now uses frames
log_section() {
    draw_section_header "$1"
}

# Improved frame drawing with proper emoji width handling
print_custom_frame() {
    local text="$1"
    local total_width=62  # Internal frame width
    
    # 1. Remove ANSI color codes for calculation
    local clean_text
    clean_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    
    # 2. Calculate visual width (emoji = 2 columns)
    local visual_len
    if command -v python3 &>/dev/null; then
        visual_len=$(python3 -c "import unicodedata; print(sum(2 if unicodedata.east_asian_width(c) in 'WF' else 1 for c in '$clean_text'))")
    else
        # Fallback to simple counting
        visual_len=${#clean_text}
    fi
    
    # 3. Calculate padding
    local padding=$((total_width - visual_len))
    [[ $padding -lt 0 ]] && padding=0

    # 4. Draw frame with colors
    echo -e "${VIO}╔════════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "$text" "$padding" ""
    echo -e "${VIO}╚════════════════════════════════════════════════════════════════╝${NC}"
}

# Print next steps section with gum styling
print_next_steps() {
    local separator=$(printf '%.0s─' $(seq 1 60)) # Pojedyncza linia w środku

    gum style \
        --border double \
        --border-foreground 6 \
        --width 64 \
        --padding "0 2" \
        "→ NASTĘPNE KROKI:
$(gum style --foreground 8 "$separator")
wypróbuj to do ramek" >&2
}

# Print a section header with gum double border
print_gum_section_header() {
    local title="$1"
    local width="${2:-64}"

    gum style \
        --border double \
        --border-foreground 6 \
        --width "$width" \
        --padding "0 2" \
        "$title" >&2
}

# Print info box with gum single border
print_gum_info_box() {
    local content="$1"
    local width="${2:-64}"

    gum style \
        --border normal \
        --border-foreground 4 \
        --width "$width" \
        --padding "0 2" \
        "$content" >&2
}

# Print warning box with yellow border
print_gum_warning_box() {
    local content="$1"
    local width="${2:-64}"

    gum style \
        --border normal \
        --border-foreground 3 \
        --width "$width" \
        --padding "0 2" \
        "$content" >&2
}

# Print success box with green border
print_gum_success_box() {
    local content="$1"
    local width="${2:-64}"

    gum style \
        --border double \
        --border-foreground 2 \
        --width "$width" \
        --padding "0 2" \
        "$content" >&2
}

# Print error box with red border
print_gum_error_box() {
    local content="$1"
    local width="${2:-64}"

    gum style \
        --border normal \
        --border-foreground 1 \
        --width "$width" \
        --padding "0 2" \
        "$content" >&2
}
