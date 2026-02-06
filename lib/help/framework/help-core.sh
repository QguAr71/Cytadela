#!/bin/bash
# ============================================================================
# CITADEL HELP SYSTEM - CORE FRAMEWORK
# ============================================================================
# Modular help system for Citadel project with TUI and CLI interfaces
#
# Author: Citadel Development Team
# Version: 1.0.0
# Dependencies: jq, gum (for TUI)
# ============================================================================

# Module metadata
MODULE_NAME="help-core"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Core framework for modular help system"
MODULE_AUTHOR="Citadel Development Team"
MODULE_DEPENDS=("jq")

# ============================================================================
# CONFIGURATION & CONSTANTS
# ============================================================================

HELP_BASE_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
HELP_MODULES_DIR="${HELP_BASE_DIR}/modules"
HELP_INTERFACES_DIR="${HELP_BASE_DIR}/interfaces"
HELP_DOCS_DIR="${HELP_BASE_DIR}/docs"

# Default language detection
detect_help_language() {
    local lang="${LANG%%_*}"
    lang="${lang:-en}"

    # Check if language is supported
    if [[ -f "${HELP_MODULES_DIR}/install/${lang}.json" ]]; then
        echo "$lang"
    else
        echo "en"  # Fallback to English
    fi
}

# ============================================================================
# MODULE LOADING SYSTEM
# ============================================================================

# Load help module documentation
# Usage: load_help_module <module_name> [language]
load_help_module() {
    local module_name="$1"
    local language="${2:-$(detect_help_language)}"

    local module_dir="${HELP_MODULES_DIR}/${module_name}"
    local index_file="${module_dir}/index.json"
    local lang_file="${module_dir}/${language}.json"

    # Check if module exists
    if [[ ! -d "$module_dir" ]]; then
        log_error "Help module '${module_name}' not found"
        return 1
    fi

    # Load module index
    if [[ ! -f "$index_file" ]]; then
        log_error "Module index not found: ${index_file}"
        return 1
    fi

    # Load language file
    if [[ ! -f "$lang_file" ]]; then
        log_error "Language file not found: ${lang_file}"
        return 1
    fi

    # Parse and return combined module data
    jq -s '.[0] * .[1]' "$index_file" "$lang_file" 2>/dev/null
}

# List all available help modules
list_help_modules() {
    local modules=()

    for dir in "${HELP_MODULES_DIR}"/*/; do
        if [[ -d "$dir" && -f "${dir}index.json" ]]; then
            local module_name
            module_name="$(basename "$dir")"
            modules+=("$module_name")
        fi
    done

    printf '%s\n' "${modules[@]}"
}

# Get module metadata
get_module_metadata() {
    local module_name="$1"
    local language="${2:-$(detect_help_language)}"

    local module_data
    module_data="$(load_help_module "$module_name" "$language")"

    if [[ $? -eq 0 && -n "$module_data" ]]; then
        echo "$module_data" | jq -r '.metadata // {}'
    fi
}

# ============================================================================
# COMMAND LOOKUP SYSTEM
# ============================================================================

# Find which module contains a specific command
find_command_module() {
    local command="$1"
    local modules
    mapfile -t modules < <(list_help_modules)

    for module in "${modules[@]}"; do
        local module_data
        module_data="$(load_help_module "$module")"

        if [[ $? -eq 0 ]] && echo "$module_data" | jq -e ".commands[]? | select(.name == \"$command\")" >/dev/null 2>&1; then
            echo "$module"
            return 0
        fi
    done

    return 1
}

# Get command documentation
get_command_help() {
    local command="$1"
    local language="${2:-$(detect_help_language)}"

    local module
    module="$(find_command_module "$command")"

    if [[ -n "$module" ]]; then
        local module_data
        module_data="$(load_help_module "$module" "$language")"

        if [[ $? -eq 0 ]]; then
            echo "$module_data" | jq -r ".commands[]? | select(.name == \"$command\") | .description // \"No description available\""
        fi
    else
        echo "Command '${command}' not found in help system"
        return 1
    fi
}

# Search for commands by keyword
search_commands() {
    local keyword="$1"
    local language="${2:-$(detect_help_language)}"
    local results=()

    local modules
    mapfile -t modules < <(list_help_modules)

    for module in "${modules[@]}"; do
        local module_data
        module_data="$(load_help_module "$module" "$language")"

        if [[ $? -eq 0 ]]; then
            # Search in command names and descriptions
            local matches
            matches="$(echo "$module_data" | jq -r ".commands[]? | select(.name | test(\"$keyword\"; \"i\") or .description | test(\"$keyword\"; \"i\")) | \"\(.name): \(.description)\"")"

            if [[ -n "$matches" ]]; then
                results+=("$matches")
            fi
        fi
    done

    if [[ ${#results[@]} -gt 0 ]]; then
        printf '%s\n' "${results[@]}"
    else
        echo "No commands found matching '${keyword}'"
        return 1
    fi
}

# ============================================================================
# INTERFACE DISPATCHER
# ============================================================================

# Main help dispatcher - routes to appropriate interface
help_dispatch() {
    local interface="${1:-tui}"
    shift

    case "$interface" in
        "tui"|"interactive"|"menu")
            source "${HELP_INTERFACES_DIR}/tui/help-tui.sh"
            help_tui_main "$@"
            ;;
        "cli"|"command"|"text")
            source "${HELP_INTERFACES_DIR}/cli/help-cli.sh"
            help_cli_main "$@"
            ;;
        "context"|"specific")
            source "${HELP_INTERFACES_DIR}/help-context.sh"
            help_context_main "$@"
            ;;
        *)
            log_error "Unknown help interface: ${interface}"
            echo "Available interfaces: tui, cli, context"
            return 1
            ;;
    esac
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Check if gum is available for TUI
check_gum_available() {
    command -v gum >/dev/null 2>&1
}

# Format help text with colors (for CLI output)
format_help_text() {
    local text="$1"
    local color="${2:-$CYAN}"

    if [[ -t 1 ]]; then
        echo -e "${color}${text}${NC}"
    else
        echo "$text"
    fi
}

# ============================================================================
# MAIN HELP ENTRY POINT
# ============================================================================

# Main function called by citadel.sh
citadel_help_main() {
    local interface="tui"
    local args=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --tui|--interactive|--menu)
                interface="tui"
                shift
                ;;
            --cli|--command|--text)
                interface="cli"
                shift
                ;;
            --context|--specific)
                interface="context"
                shift
                ;;
            --language|--lang|-l)
                export HELP_LANGUAGE="$2"
                shift 2
                ;;
            --help|-h)
                show_help_usage
                return 0
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done

    # Dispatch to appropriate interface
    help_dispatch "$interface" "${args[@]}"
}

# Show help usage
show_help_usage() {
    cat << 'EOF'
Citadel Help System

USAGE:
    citadel help [INTERFACE] [OPTIONS] [COMMAND]

INTERFACES:
    tui         Interactive terminal user interface (default)
    cli         Command-line interface for quick help
    context     Contextual help for specific commands

OPTIONS:
    --language LANG    Set help language (pl, en, de, es, fr, it, ru)
    --help, -h         Show this help message

EXAMPLES:
    citadel help                    # Interactive help menu
    citadel help install           # CLI help about installation
    citadel help status --examples # Show examples for status command
    citadel help --tui             # Force TUI interface
    citadel help --search "dns"    # Search for DNS-related commands

For more information, visit: https://citadel.example.com/docs
EOF
}

# Export main function
export -f citadel_help_main
