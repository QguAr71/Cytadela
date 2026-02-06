#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  I18N MIGRATION SCRIPT - Convert bash translations to JSON              ║
# ║  Migrates existing .sh translation files to JSON format                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${CYTADELA_LIB:-/opt/cytadela/lib}/i18n"
TARGET_DIR="${SCRIPT_DIR}/translations"
ENGINE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Function to convert bash variable to JSON key-value pair
convert_bash_to_json() {
    local bash_file="$1"
    local json_file="$2"

    log_info "Converting $bash_file to $json_file"

    # Create JSON structure
    echo "{" > "$json_file"

    # Parse bash file and extract T_* variables
    local first=true
    while IFS='=' read -r key value; do
        # Skip if not a T_ variable
        [[ "$key" != T_* ]] && continue

        # Remove 'export ' prefix if present
        key="${key#export }"
        key="${key#T_}"

        # Remove quotes from value
        value="${value#\"}"
        value="${value%\"}"
        value="${value#\'}"
        value="${value%\'}"

        # Escape special characters for JSON
        value="${value//\\/\\\\}"  # Escape backslashes
        value="${value//\"/\\\"}"   # Escape quotes
        value="${value//$'\n'/\\n}" # Escape newlines
        value="${value//$'\r'/\\r}" # Escape carriage returns
        value="${value//$'\t'/\\t}" # Escape tabs

        # Add comma for all but first entry
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$json_file"
        fi

        # Write JSON key-value pair
        printf '  "%s": "%s"' "$key" "$value" >> "$json_file"

    done < <(grep '^export T_\|^T_=' "$bash_file" | sed 's/^export //' | sort)

    # Close JSON structure
    echo "" >> "$json_file"
    echo "}" >> "$json_file"

    log_success "Converted $bash_file to $json_file"
}

# Function to validate JSON file
validate_json() {
    local json_file="$1"

    if command -v jq >/dev/null 2>&1; then
        if jq empty "$json_file" >/dev/null 2>&1; then
            log_success "JSON validation passed: $json_file"
            return 0
        else
            log_error "JSON validation failed: $json_file"
            return 1
        fi
    else
        log_warning "jq not available, skipping JSON validation"
        return 0
    fi
}

# Function to migrate module translations
migrate_module() {
    local module="$1"

    log_info "Migrating module: $module"

    # Create target directory
    local target_module_dir="${TARGET_DIR}/${module}"
    mkdir -p "$target_module_dir"

    # Find all language files for this module
    local source_module_dir="${SOURCE_DIR}/${module}"
    if [[ ! -d "$source_module_dir" ]]; then
        log_warning "Module directory not found: $source_module_dir"
        return 1
    fi

    local migrated_count=0
    while IFS= read -r -d '' bash_file; do
        # Extract language from filename (e.g., pl.sh -> pl)
        local lang
        lang=$(basename "$bash_file" .sh)

        local json_file="${target_module_dir}/${lang}.json"

        # Convert bash to JSON
        if convert_bash_to_json "$bash_file" "$json_file"; then
            # Validate JSON
            if validate_json "$json_file"; then
                ((migrated_count++))
            else
                log_error "Failed to validate JSON for $module/$lang"
            fi
        else
            log_error "Failed to convert $bash_file"
        fi

    done < <(find "$source_module_dir" -name "*.sh" -print0 | sort -z)

    if [[ $migrated_count -gt 0 ]]; then
        log_success "Migrated $migrated_count language files for module $module"
    else
        log_warning "No files migrated for module $module"
    fi
}

# Main migration function
main() {
    log_info "Starting i18n migration from bash to JSON"
    echo ""

    # Check if source directory exists
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory not found: $SOURCE_DIR"
        log_info "Make sure CYTADELA_LIB is set correctly or run from project root"
        exit 1
    fi

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        log_warning "jq is not available. JSON validation will be skipped."
        log_info "Install jq for better validation: sudo apt install jq"
    fi

    # Create target directory
    mkdir -p "$TARGET_DIR"

    # Find all modules to migrate
    local modules=()
    while IFS= read -r -d '' module_dir; do
        local module
        module=$(basename "$module_dir")
        modules+=("$module")
    done < <(find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

    log_info "Found modules to migrate: ${modules[*]}"

    # Migrate each module
    for module in "${modules[@]}"; do
        migrate_module "$module"
    done

    # Special handling for common translations
    if [[ -f "${SOURCE_DIR}/common.sh" ]]; then
        log_info "Migrating common translations..."
        mkdir -p "${TARGET_DIR}/common"
        convert_bash_to_json "${SOURCE_DIR}/common.sh" "${TARGET_DIR}/common/en.json"
        validate_json "${TARGET_DIR}/common/en.json"
    fi

    log_success "Migration completed!"
    log_info "New JSON translations are in: $TARGET_DIR"
    log_info "Test the new i18n engine with: source modules/i18n-engine/i18n-engine.sh && i18n_engine_init"

    # Show summary
    echo ""
    log_info "Migration Summary:"
    find "$TARGET_DIR" -name "*.json" | wc -l | xargs echo "  JSON files created:"
    du -sh "$TARGET_DIR" 2>/dev/null | cut -f1 | xargs echo "  Total size:"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
