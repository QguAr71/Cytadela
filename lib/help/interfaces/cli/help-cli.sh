#!/bin/bash
# ============================================================================
# CITADEL HELP SYSTEM - CLI INTERFACE
# ============================================================================
# Command Line Interface for Citadel help system
#
# Features:
# - Quick command lookup
# - Search functionality
# - Detailed command information
# - Script-friendly output
#
# Dependencies: jq (for JSON parsing)
# ============================================================================

# Load core framework
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../framework/help-core.sh"

# ============================================================================
# CLI SPECIFIC FUNCTIONS
# ============================================================================

# Show help for specific command
cli_show_command_help() {
    local command="$1"
    local language="$2"
    local show_examples="${3:-false}"

    local module
    module="$(find_command_module "$command")"

    if [[ -z "$module" ]]; then
        echo "ERROR: Command '$command' not found in help system." >&2
        echo ""
        echo "Try one of these commands:"
        list_help_modules | while read -r mod; do
            load_help_module "$mod" "$language" | jq -r ".commands[]?.name" 2>/dev/null
        done | head -10 | sed 's/^/  /'
        return 1
    fi

    local cmd_data
    cmd_data="$(load_help_module "$module" "$language" | jq -r ".commands[]? | select(.name == \"$command\")")"

    if [[ -z "$cmd_data" ]]; then
        echo "ERROR: Detailed information for '$command' is not available." >&2
        echo "Command is part of the '$module' module."
        return 1
    fi

    # Extract command information
    local name desc usage category
    name="$(echo "$cmd_data" | jq -r '.name // "Unknown"')"
    desc="$(echo "$cmd_data" | jq -r '.description // "No description available"')"
    usage="$(echo "$cmd_data" | jq -r '.usage // "citadel '"$command"'"')"
    category="$(echo "$cmd_data" | jq -r '.category // "general"')"

    # Show basic information
    echo "Command: $name"
    echo "Module:  $module"
    echo "Category: $category"
    echo ""
    echo "Description:"
    echo "  $desc"
    echo ""
    echo "Usage:"
    echo "  $usage"

    # Show examples if requested
    if [[ "$show_examples" == "true" ]]; then
        local examples
        examples="$(echo "$cmd_data" | jq -r '.examples // [] | join("\n")')"
        if [[ -n "$examples" && "$examples" != "[]" ]]; then
            echo ""
            echo "Examples:"
            echo "$examples" | sed 's/^/  /'
        fi
    fi

    # Show additional notes
    local notes
    notes="$(echo "$cmd_data" | jq -r '.notes // empty')"
    if [[ -n "$notes" ]]; then
        echo ""
        echo "Notes:"
        echo "$notes" | sed 's/^/  /'
    fi
}

# Show help for entire module
cli_show_module_help() {
    local module="$1"
    local language="$2"
    local format="${3:-text}"

    local module_data
    module_data="$(load_help_module "$module" "$language")"

    if [[ $? -ne 0 || -z "$module_data" ]]; then
        echo "ERROR: Cannot load help for module '$module'" >&2
        return 1
    fi

    case "$format" in
        "json")
            echo "$module_data" | jq '.'
            ;;
        "compact")
            local desc
            desc="$(echo "$module_data" | jq -r '.metadata.description // "No description"')"
            echo "$module: $desc"
            echo "$module_data" | jq -r '.commands[]? | "  \(.name): \(.description)"' 2>/dev/null
            ;;
        "text"|*)
            local desc
            desc="$(echo "$module_data" | jq -r '.metadata.description // "Help documentation for '"$module"'" module"')"

            echo "=== $(echo "$module" | tr '[:lower:]' '[:upper:]') MODULE ==="
            echo ""
            echo "Description: $desc"
            echo ""

            local commands
            commands="$(echo "$module_data" | jq -r '.commands[]? | "\(.name)|\(.description)"' 2>/dev/null)"

            if [[ -n "$commands" ]]; then
                echo "Commands:"
                echo "$commands" | while IFS='|' read -r name desc; do
                    printf "  %-20s %s\n" "$name" "$desc"
                done
            else
                echo "No commands documented for this module yet."
            fi
            ;;
    esac
}

# List all modules
cli_list_modules() {
    local format="${1:-text}"
    local language="${2:-$(detect_help_language)}"

    case "$format" in
        "json")
            local modules=()
            local modules_list
            mapfile -t modules_list < <(list_help_modules)

            for module in "${modules_list[@]}"; do
                local desc
                desc="$(get_module_metadata "$module" "$language" | jq -r '.description // "No description"' 2>/dev/null)"
                modules+=("{\"name\":\"$module\",\"description\":\"$desc\"}")
            done

            printf '[%s]\n' "$(IFS=,; echo "${modules[*]}")"
            ;;
        "compact")
            list_help_modules | while read -r module; do
                local desc
                desc="$(get_module_metadata "$module" "$language" | jq -r '.description // "No description"' 2>/dev/null)"
                printf "%-15s %s\n" "$module:" "$desc"
            done
            ;;
        "text"|*)
            echo "Available help modules:"
            echo ""
            list_help_modules | while read -r module; do
                local desc
                desc="$(get_module_metadata "$module" "$language" | jq -r '.description // "No description"' 2>/dev/null)"
                printf "  %-15s %s\n" "$module" "$desc"
            done
            ;;
    esac
}

# Show all commands
cli_show_all_commands() {
    local format="${1:-text}"
    local language="${2:-$(detect_help_language)}"

    case "$format" in
        "json")
            local all_commands="[]"
            local modules
            mapfile -t modules < <(list_help_modules)

            for module in "${modules[@]}"; do
                local module_commands
                module_commands="$(load_help_module "$module" "$language" | jq -r '.commands // [] | map(. + {"module":"'"$module"'"} )' 2>/dev/null)"
                if [[ -n "$module_commands" && "$module_commands" != "[]" ]]; then
                    all_commands="$(echo "$all_commands" | jq ". + $module_commands")"
                fi
            done
            echo "$all_commands"
            ;;
        "compact")
            local modules
            mapfile -t modules < <(list_help_modules)

            for module in "${modules[@]}"; do
                echo "=== $module ==="
                load_help_module "$module" "$language" | jq -r '.commands[]? | "\(.name): \(.description)"' 2>/dev/null || echo "  No commands documented"
                echo ""
            done
            ;;
        "text"|*)
            local modules
            mapfile -t modules < <(list_help_modules)

            for module in "${modules[@]}"; do
                echo "=== $(echo "$module" | tr '[:lower:]' '[:upper:]') MODULE ==="
                load_help_module "$module" "$language" | jq -r '.commands[]? | "  \(.name): \(.description)"' 2>/dev/null || echo "  No commands documented yet"
                echo ""
            done
            ;;
    esac
}

# Search commands
cli_search_commands() {
    local search_term="$1"
    local language="${2:-$(detect_help_language)}"
    local format="${3:-text}"

    if [[ -z "$search_term" ]]; then
        echo "ERROR: Search term is required" >&2
        return 1
    fi

    local results
    results="$(search_commands "$search_term" "$language")"

    if [[ $? -ne 0 || -z "$results" ]]; then
        case "$format" in
            "json")
                echo '{"error":"No results found","search_term":"'"$search_term"'"}'
                ;;
            *)
                echo "No commands found matching '$search_term'"
                ;;
        esac
        return 1
    fi

    case "$format" in
        "json")
            # Convert text results to JSON
            local json_results="[]"
            echo "$results" | while IFS=: read -r cmd desc; do
                local module
                module="$(find_command_module "$cmd")"
                json_results="$(echo "$json_results" | jq ". + [{\"command\":\"$cmd\",\"description\":\"$desc\",\"module\":\"$module\"}]")"
            done
            echo "$json_results"
            ;;
        "compact")
            echo "Search results for '$search_term':"
            echo "$results" | sed 's/^/  /'
            ;;
        "text"|*)
            echo "Search results for '$search_term':"
            echo ""
            echo "$results" | while IFS=: read -r cmd desc; do
                printf "  %-20s %s\n" "$cmd" "$desc"
            done
            ;;
    esac
}

# ============================================================================
# CLI ARGUMENT PARSING
# ============================================================================

# Parse CLI arguments and dispatch to appropriate function
cli_parse_args() {
    local language="$(detect_help_language)"
    local format="text"
    local show_examples=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --language|-l)
                language="$2"
                shift 2
                ;;
            --format|-f)
                format="$2"
                shift 2
                ;;
            --examples|-e)
                show_examples=true
                shift
                ;;
            --json)
                format="json"
                shift
                ;;
            --compact|-c)
                format="compact"
                shift
                ;;
            --help|-h)
                cli_show_usage
                return 0
                ;;
            --list-modules|--modules)
                cli_list_modules "$format" "$language"
                return 0
                ;;
            --all|--all-commands)
                cli_show_all_commands "$format" "$language"
                return 0
                ;;
            --search|-s)
                cli_search_commands "$2" "$language" "$format"
                return 0
                ;;
            -*)
                echo "ERROR: Unknown option: $1" >&2
                cli_show_usage
                return 1
                ;;
            *)
                # Assume it's a command or module name
                break
                ;;
        esac
    done

    # Handle remaining arguments
    case $# in
        0)
            # No arguments - show general help
            cli_show_usage
            ;;
        1)
            local arg="$1"
            # Check if it's a module or command
            if list_help_modules | grep -q "^${arg}$"; then
                cli_show_module_help "$arg" "$language" "$format"
            else
                cli_show_command_help "$arg" "$language" "$show_examples"
            fi
            ;;
        *)
            echo "ERROR: Too many arguments" >&2
            cli_show_usage
            return 1
            ;;
    esac
}

# Show CLI usage
cli_show_usage() {
    cat << 'EOF'
Citadel Help System - CLI Interface

USAGE:
    citadel help --cli [OPTIONS] [COMMAND|MODULE]

COMMANDS:
    citadel help --cli                    Show this help
    citadel help --cli --modules          List all help modules
    citadel help --cli --all              Show all commands
    citadel help --cli --search TERM      Search for commands
    citadel help --cli MODULE             Show help for module
    citadel help --cli COMMAND            Show help for command

OPTIONS:
    --language LANG, -l LANG    Set language (pl, en, de, es, fr, it, ru)
    --format FORMAT, -f FORMAT  Output format (text, json, compact)
    --examples, -e              Show examples for commands
    --json                      JSON output format
    --compact, -c               Compact output format

EXAMPLES:
    citadel help --cli install              # Help about install module
    citadel help --cli status               # Help about status command
    citadel help --cli --search dns         # Search DNS-related commands
    citadel help --cli --all --json         # All commands in JSON format
    citadel help --cli status --examples    # Status command with examples

For interactive help, use: citadel help
EOF
}

# ============================================================================
# MAIN CLI ENTRY POINT
# ============================================================================

# Main CLI function
help_cli_main() {
    # Parse and execute command
    cli_parse_args "$@"
}
