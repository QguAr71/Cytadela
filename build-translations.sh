#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  JSON to Bash Translation Builder                                         ║
# ║  Converts JSON translation files to bash .sh format for runtime loading ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSLATIONS_DIR="${1:-${SCRIPT_DIR}/modules/i18n-engine/translations}"

debug() {
    [[ "${DEBUG:-0}" == "1" ]] && echo "[DEBUG] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Convert single JSON file to bash format
convert_json_to_bash() {
    local json_file="$1"
    local bash_file="${json_file%.json}.sh"
    
    debug "Converting: $json_file → $bash_file"
    
    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        error "jq is required for building translations"
    fi
    
    # Create bash file header
    cat > "$bash_file" << 'HEADER'
#!/bin/bash
# Auto-generated from JSON - DO NOT EDIT
# Use: source this file to load translations

HEADER
    
    # Convert JSON entries to bash exports
    jq -r 'to_entries[] | "export \(.key)=\"\(.value | @sh)\""' "$json_file" >> "$bash_file"
    
    # Make it source-able
    chmod +x "$bash_file"
    
    echo "✓ Generated: $bash_file"
}

# Process all JSON files in directory
process_directory() {
    local dir="$1"
    local count=0
    
    [[ ! -d "$dir" ]] && error "Directory not found: $dir"
    
    # Find all JSON files recursively
    while IFS= read -r -d '' json_file; do
        convert_json_to_bash "$json_file"
        ((count++))
    done < <(find "$dir" -name "*.json" -type f -print0 2>/dev/null)
    
    echo ""
    echo "Build complete: $count translation files converted"
}

# Clean old .sh files (optional)
clean_old_builds() {
    local dir="$1"
    find "$dir" -name "*.sh" -type f -delete
    echo "Cleaned old .sh files"
}

# Main
main() {
    local action="${1:-build}"
    
    case "$action" in
        build)
            process_directory "$TRANSLATIONS_DIR"
            ;;
        clean)
            clean_old_builds "$TRANSLATIONS_DIR"
            ;;
        rebuild)
            clean_old_builds "$TRANSLATIONS_DIR"
            process_directory "$TRANSLATIONS_DIR"
            ;;
        *)
            echo "Usage: $0 [build|clean|rebuild] [translations_dir]"
            exit 1
            ;;
    esac
}

main "$@"
