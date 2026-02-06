#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA I18N ENGINE v4.0                                               ║
# ║  Unified Internationalization System with JSON support                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# I18N ENGINE CONFIGURATION
# ==============================================================================

# Engine paths
I18N_ENGINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
I18N_TRANSLATIONS_DIR="${I18N_ENGINE_DIR}/translations"
I18N_CACHE_DIR="${I18N_ENGINE_DIR}/.cache"

# Supported languages (will be auto-detected from translation files)
declare -ga I18N_SUPPORTED_LANGUAGES=()

# Translation cache (associative array for performance)
declare -gA I18N_CACHE=()

# Engine state
I18N_ENGINE_INITIALIZED=false
I18N_CURRENT_LANGUAGE="${CYTADELA_LANG:-en}"

# ==============================================================================
# CORE ENGINE FUNCTIONS
# ==============================================================================

# Initialize the i18n engine
i18n_engine_init() {
    local force="${1:-false}"

    # Skip if already initialized
    [[ "$I18N_ENGINE_INITIALIZED" == "true" && "$force" != "true" ]] && return 0

    log_debug "Initializing i18n engine..."

    # Create cache directory
    mkdir -p "$I18N_CACHE_DIR" 2>/dev/null || true

    # Detect supported languages from translation files
    _i18n_detect_supported_languages

    # Validate current language
    if ! _i18n_is_language_supported "$I18N_CURRENT_LANGUAGE"; then
        log_warning "Language '$I18N_CURRENT_LANGUAGE' not supported, falling back to 'en'"
        I18N_CURRENT_LANGUAGE="en"
    fi

    # Mark as initialized BEFORE loading translations to prevent recursion
    I18N_ENGINE_INITIALIZED=true

    # Load common translations first
    _i18n_load_translations "common" "$I18N_CURRENT_LANGUAGE"

    log_debug "i18n engine initialized for language: $I18N_CURRENT_LANGUAGE"
    return 0
}

# Load translations for a specific module and language (wrapper for backward compatibility)
_i18n_load_translations() {
    local module="$1"
    local language="$2"
    
    # Use the new engine function
    i18n_engine_load "$module" "$language"
}

# Load translations for a specific module and language
i18n_engine_load() {
    local module="$1"
    local language="${2:-$I18N_CURRENT_LANGUAGE}"

    # Ensure engine is initialized
    [[ "$I18N_ENGINE_INITIALIZED" != "true" ]] && i18n_engine_init

    log_debug "Loading translations for module: $module, language: $language"

    # Validate language
    if ! _i18n_is_language_supported "$language"; then
        log_warning "Language '$language' not supported for module '$module'"
        return 1
    fi

    # Try to load JSON translations first, fallback to bash
    if _i18n_load_json_translations "$module" "$language"; then
        log_debug "Loaded JSON translations for $module/$language"
        _i18n_export_globals "$module" "$language"
        return 0
    elif _i18n_load_bash_translations "$module" "$language"; then
        log_debug "Loaded bash translations for $module/$language"
        _i18n_export_globals "$module" "$language"
        return 0
    else
        log_warning "No translations found for $module/$language"
        return 1
    fi
}

# Get a translation with fallback chain
i18n_engine_get() {
    local key="$1"
    local module="${2:-common}"
    local language="${3:-$I18N_CURRENT_LANGUAGE}"

    # Ensure engine is initialized
    [[ "$I18N_ENGINE_INITIALIZED" != "true" ]] && i18n_engine_init

    # Create cache key
    local cache_key="${module}_${language}_${key}"

    # Check cache first
    if [[ -n "${I18N_CACHE[$cache_key]:-}" ]]; then
        echo "${I18N_CACHE[$cache_key]}"
        return 0
    fi

    # Fallback chain: specific module → common → English → key itself
    local translation=""

    # 1. Try specific module and language
    translation="$(_i18n_get_raw "$key" "$module" "$language")"
    [[ -n "$translation" ]] && _i18n_cache_set "$cache_key" "$translation" && echo "$translation" && return 0

    # 2. Try common module for same language
    translation="$(_i18n_get_raw "$key" "common" "$language")"
    [[ -n "$translation" ]] && _i18n_cache_set "$cache_key" "$translation" && echo "$translation" && return 0

    # 3. Try specific module in English
    translation="$(_i18n_get_raw "$key" "$module" "en")"
    [[ -n "$translation" ]] && _i18n_cache_set "$cache_key" "$translation" && echo "$translation" && return 0

    # 4. Try common module in English
    translation="$(_i18n_get_raw "$key" "common" "en")"
    [[ -n "$translation" ]] && _i18n_cache_set "$cache_key" "$translation" && echo "$translation" && return 0

    # 5. Return key itself as last resort
    _i18n_cache_set "$cache_key" "$key"
    echo "$key"
}

# ==============================================================================
# BACKWARD COMPATIBILITY FUNCTIONS
# ==============================================================================

# Backward compatibility with existing load_i18n_module()
load_i18n_module() {
    local module="$1"
    local lang="${CYTADELA_LANG:-en}"

    # Initialize engine if needed
    [[ "$I18N_ENGINE_INITIALIZED" != "true" ]] && i18n_engine_init

    # Load translations using new engine
    i18n_engine_load "$module" "$lang"

    # Export all loaded translations as global variables (for backward compatibility)
    _i18n_export_globals "$module" "$lang"
}

# ==============================================================================
# INTERNAL FUNCTIONS
# ==============================================================================

# Detect supported languages from translation files
_i18n_detect_supported_languages() {
    I18N_SUPPORTED_LANGUAGES=()

    # Find all JSON translation files
    while IFS= read -r -d '' file; do
        # Extract language code from filename (e.g., "pl.json" -> "pl")
        local lang
        lang=$(basename "$file" .json)

        # Add to supported languages if not already present
        if [[ ! " ${I18N_SUPPORTED_LANGUAGES[*]} " =~ " $lang " ]]; then
            I18N_SUPPORTED_LANGUAGES+=("$lang")
        fi
    done < <(find "$I18N_TRANSLATIONS_DIR" -name "*.json" -print0 2>/dev/null || true)

    log_debug "Detected supported languages: ${I18N_SUPPORTED_LANGUAGES[*]}"
}

# Check if language is supported
_i18n_is_language_supported() {
    local language="$1"
    [[ " ${I18N_SUPPORTED_LANGUAGES[*]} " =~ " $language " ]]
}

# Load JSON translations for a module (simplified - direct to memory)
_i18n_load_json_translations() {
    local module="$1"
    local language="$2"
    local json_file="${I18N_TRANSLATIONS_DIR}/${module}/${language}.json"

    # Check if JSON file exists
    [[ ! -f "$json_file" ]] && return 1

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        log_debug "jq not available, skipping JSON translations"
        return 1
    fi

    log_debug "Loading JSON translations from: $json_file"

    # Parse JSON directly to memory (no cache files)
    while IFS='=' read -r key value; do
        [[ -n "$key" ]] && I18N_CACHE["$key"]="$value"
    done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' "$json_file" 2>/dev/null)

    # Verify we loaded something
    [[ ${#I18N_CACHE[@]} -eq 0 ]] && return 1

    log_debug "Loaded ${#I18N_CACHE[@]} translations from JSON"
    return 0
}

# Load bash translations for a module (fallback)
_i18n_load_bash_translations() {
    local module="$1"
    local language="$2"
    local bash_file="${CYTADELA_LIB:-/opt/cytadela/lib}/i18n/${module}/${language}.sh"

    # Check if bash file exists
    [[ ! -f "$bash_file" ]] && return 1

    log_debug "Loading bash translations from: $bash_file"

    # Source the bash translation file
    # shellcheck source=/dev/null
    source "$bash_file"
    return $?
}

# Get raw translation without caching
_i18n_get_raw() {
    local key="$1"
    local module="$2"
    local language="$3"

    # Create variable name (T_KEY format)
    local var_name="T_${key}"

    # Check if variable exists in environment
    local var_value="${!var_name:-}"

    # Return value if found
    [[ -n "$var_value" ]] && echo "$var_value" && return 0

    # Not found
    return 1
}

# Set cache value
_i18n_cache_set() {
    local key="$1"
    local value="$2"
    I18N_CACHE["$key"]="$value"
}

# Export loaded translations as global variables (for backward compatibility)
_i18n_export_globals() {
    local module="$1"
    local language="$2"

    # Export all cached translations as T_* variables
    for key in "${!I18N_CACHE[@]}"; do
        local var_name="$key"
        local var_value="${I18N_CACHE[$key]}"
        # Set the variable globally
        declare -g "$var_name"="$var_value"
        export "$var_name"
    done
    
    log_debug "Exported ${#I18N_CACHE[@]} translations as global variables"
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# List supported languages
i18n_engine_list_languages() {
    [[ "$I18N_ENGINE_INITIALIZED" != "true" ]] && i18n_engine_init
    printf '%s\n' "${I18N_SUPPORTED_LANGUAGES[@]}"
}

# Get current language
i18n_engine_get_language() {
    echo "$I18N_CURRENT_LANGUAGE"
}

# Set current language
i18n_engine_set_language() {
    local language="$1"

    if _i18n_is_language_supported "$language"; then
        I18N_CURRENT_LANGUAGE="$language"
        # Clear cache for new language
        I18N_CACHE=()
        log_debug "Language changed to: $language"
        return 0
    else
        log_error "Unsupported language: $language"
        return 1
    fi
}

# Clean cache (memory only, no files)
i18n_engine_clear_cache() {
    I18N_CACHE=()
    log_debug "Translation cache cleared"
}

# Get engine status
i18n_engine_status() {
    echo "i18n Engine Status:"
    echo "  Initialized: $I18N_ENGINE_INITIALIZED"
    echo "  Current Language: $I18N_CURRENT_LANGUAGE"
    echo "  Supported Languages: ${I18N_SUPPORTED_LANGUAGES[*]}"
    echo "  Cache Size: ${#I18N_CACHE[@]}"
    echo "  Translations Dir: $I18N_TRANSLATIONS_DIR"
    echo "  Cache Dir: $I18N_CACHE_DIR"
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Auto-initialize if sourced directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    log_info "i18n Engine loaded directly, initializing..."
    i18n_engine_init
fi
