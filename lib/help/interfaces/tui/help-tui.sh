#!/bin/bash
# ============================================================================
# CITADEL HELP SYSTEM - TUI INTERFACE (GUM-BASED)
# ============================================================================
# Interactive Terminal User Interface using gum for Citadel help system
#
# Features:
# - Modern TUI with gum (Charm.sh)
# - Modular help display
# - Search functionality
# - Context-aware help
#
# Dependencies: gum (for TUI), jq (for JSON parsing)
# ============================================================================

# Load core framework
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../framework/help-core.sh"

# ============================================================================
# GUM-BASED TUI FUNCTIONS
# ============================================================================

# Check if gum is available and install if needed
ensure_gum_available() {
    if ! command -v gum >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing gum for TUI interface...${NC}"

        # Try to install gum automatically
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y gum
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y gum
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S gum
        else
            echo -e "${RED}ERROR: Cannot install gum automatically. Please install it manually:${NC}"
            echo -e "${CYAN}curl -sSL https://github.com/charmbracelet/gum/releases/download/v0.13.0/gum_0.13.0_linux_amd64.tar.gz | tar xz && sudo mv gum /usr/local/bin/${NC}"
            return 1
        fi

        # Verify installation
        if ! command -v gum >/dev/null 2>&1; then
            echo -e "${RED}ERROR: Failed to install gum${NC}"
            return 1
        fi
    fi
    return 0
}

# Show main help menu using gum
tui_main_menu() {
    local language="${HELP_LANGUAGE:-$(detect_help_language)}"

    # Get available modules
    local modules
    mapfile -t modules < <(list_help_modules)

    # Create menu options
    local menu_options=("🔍 Search Commands" "📋 All Commands" "❌ Quit")

    # Add module options
    for module in "${modules[@]}"; do
        local display_name
        display_name="$(echo "$module" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')"
        menu_options+=("📚 $display_name Help")
    done

    # Show menu with gum
    local choice
    choice=$(printf '%s\n' "${menu_options[@]}" | gum choose --header="🏰 CITADEL HELP SYSTEM" --cursor="▶ " --selected.background="4" --cursor.foreground="2")

    echo "$choice"
}

# Handle module help display
tui_show_module_help() {
    local module="$1"
    local language="$2"

    gum style --border="double" --border-foreground="4" --padding="1 2" --header="📚 $(echo "$module" | tr '[:lower:]' '[:upper:]') MODULE HELP" --header.foreground="3" << EOF

$(load_help_module "$module" "$language" | jq -r '.metadata.description // "Help documentation for '"$module"'" module"')

Available commands in this module:
$(load_help_module "$module" "$language" | jq -r '.commands[]? | "• \(.name): \(.description)"' 2>/dev/null || echo "No commands documented yet")

$(gum style --foreground="8" "💡 Tip: Use 'citadel help --cli $module' for detailed command-line help")
EOF
}

# Search interface using gum
tui_search_interface() {
    local language="$1"

    # Get search term with gum input
    local search_term
    search_term=$(gum input --header="🔍 SEARCH HELP SYSTEM" --placeholder="Enter command name or description..." --value="dns")

    if [[ -z "$search_term" ]]; then
        return
    fi

    # Show loading spinner
    gum spin --spinner="dots" --title="Searching..." -- sleep 0.5

    # Perform search
    local results
    results="$(search_commands "$search_term" "$language")"

    if [[ $? -eq 0 && -n "$results" ]]; then
        gum style --border="rounded" --border-foreground="2" --padding="1 2" --header="🔍 SEARCH RESULTS FOR: '$search_term'" --header.foreground="2" << EOF
$(echo "$results" | sed 's/^/• /')
EOF
    else
        gum style --border="rounded" --border-foreground="1" --padding="1 2" --header="❌ NO RESULTS FOUND" --header.foreground="1" << EOF
No commands found matching '$search_term'

Try different keywords like:
• dns, firewall, install, status
• diagnostics, backup, restore
• emergency, panic, help
EOF
    fi
}

# Show all commands overview
tui_show_all_commands() {
    local language="$1"
    local modules
    mapfile -t modules < <(list_help_modules)

    local content=""
    for module in "${modules[@]}"; do
        local module_display
        module_display="$(echo "$module" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')"

        content+="=== $module_display MODULE ===\n"
        content+="$(load_help_module "$module" "$language" | jq -r '.commands[]? | "• \(.name): \(.description)"' 2>/dev/null || echo "  No commands documented yet")\n\n"
    done

    echo -e "$content" | gum pager --header="📋 ALL CITADEL COMMANDS"
}

# Show command details
tui_show_command_details() {
    local command="$1"
    local language="$2"

    local module
    module="$(find_command_module "$command")"

    if [[ -z "$module" ]]; then
        gum style --border="rounded" --border-foreground="1" --padding="1 2" --header="❌ COMMAND NOT FOUND" --header.foreground="1" << EOF
Command '$command' not found in help system.

Try searching for similar commands or use 'citadel help' to browse all available commands.
EOF
        return 1
    fi

    local cmd_data
    cmd_data="$(load_help_module "$module" "$language" | jq -r ".commands[]? | select(.name == \"$command\")")"

    if [[ -z "$cmd_data" ]]; then
        gum style --border="rounded" --border-foreground="1" --padding="1 2" --header="❌ COMMAND DETAILS UNAVAILABLE" --header.foreground="1" << EOF
Detailed information for '$command' is not available yet.

Command is part of the '$module' module.
EOF
        return 1
    fi

    local name desc usage examples notes
    name="$(echo "$cmd_data" | jq -r '.name // "Unknown"')"
    desc="$(echo "$cmd_data" | jq -r '.description // "No description available"')"
    usage="$(echo "$cmd_data" | jq -r '.usage // "citadel '"$command"'"')"
    examples="$(echo "$cmd_data" | jq -r '.examples // ["No examples available"] | join("\n• ")')"
    notes="$(echo "$cmd_data" | jq -r '.notes // "No additional notes"')"

    gum style --border="double" --border-foreground="4" --padding="1 2" --header="📖 COMMAND: $name" --header.foreground="4" << EOF
📝 Description: $desc

💻 Usage: $usage

🔍 Examples:
• $examples

📋 Notes: $notes

🏷️  Module: $module
EOF
}

# ============================================================================
# MAIN TUI CONTROLLER
# ============================================================================

# Main TUI event loop
tui_main_loop() {
    local language="${HELP_LANGUAGE:-$(detect_help_language)}"

    while true; do
        local choice
        choice="$(tui_main_menu)"

        case "$choice" in
            "🔍 Search Commands")
                tui_search_interface "$language"
                ;;
            "📋 All Commands")
                tui_show_all_commands "$language"
                ;;
            "❌ Quit")
                gum style --foreground="2" "👋 Thanks for using Citadel Help System!"
                return 0
                ;;
            *"Help"*)
                # Extract module name from choice (e.g., "📚 Install Help" -> "install")
                local module_name
                module_name="$(echo "$choice" | sed 's/📚 //' | sed 's/ Help//' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')"

                # Handle special cases
                case "$module_name" in
                    "core")
                        module_name="core"
                        ;;
                    "emergency")
                        module_name="emergency"
                        ;;
                    "addons")
                        module_name="addons"
                        ;;
                    "advanced")
                        module_name="advanced"
                        ;;
                esac

                if [[ -n "$module_name" ]]; then
                    tui_show_module_help "$module_name" "$language"
                fi
                ;;
            *)
                # Unknown choice
                continue
                ;;
        esac

        # Wait for user confirmation before returning to menu
        echo ""
        gum confirm "Return to main menu?" || return 0
    done
}

# ============================================================================
# MAIN TUI ENTRY POINT
# ============================================================================

# Main TUI function
help_tui_main() {
    # Ensure gum is available
    if ! ensure_gum_available; then
        return 1
    fi

    # Load i18n if available
    if command -v load_i18n_module >/dev/null 2>&1; then
        load_i18n_module "help" 2>/dev/null || true
    fi

    # Set gum styling
    export GUM_SPIN_SPINNER="dots"
    export GUM_CHOOSE_CURSOR_FOREGROUND="2"
    export GUM_CHOOSE_SELECTED_FOREGROUND="4"

    # Start main TUI loop
    tui_main_loop
}
