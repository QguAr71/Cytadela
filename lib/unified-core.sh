#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED CORE LIBRARY v3.2                                    ║
# ║  Shared utilities for unified modules                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# BASH VERSION DETECTION & COMPATIBILITY
# ==============================================================================

# Detect Bash version for compatibility features
detect_bash_version() {
    if [[ -n "${BASH_VERSINFO[0]}" ]]; then
        echo "${BASH_VERSINFO[0]}"
    else
        echo "3"  # Fallback for very old Bash
    fi
}

BASH_MAJOR_VERSION=$(detect_bash_version)

# Check minimum Bash version
check_bash_version() {
    local min_version="${1:-4}"
    local current_version="$BASH_MAJOR_VERSION"

    if [[ $current_version -lt $min_version ]]; then
        log_error "Bash $min_version+ required (current: $current_version)"
        return 1
    fi

    # Warn about old versions but allow
    if [[ $current_version -lt 5 ]]; then
        log_warning "Running on Bash $current_version (compatibility mode)"
        log_info "For best performance, upgrade to Bash 5.0+"
    fi

    return 0
}

# ==============================================================================
# COMMAND TRANSLATION & BACKWARD COMPATIBILITY
# ==============================================================================

# Command translation map (avoid associative arrays for compatibility)
TRANSLATION_KEYS=(
    "tools-update"
    "adblock-rebuild"
    "tools-install"
    "check-dependencies"
    "install-dnscrypt"
    "install-coredns"
    "emergency"
    "lkg"
    "lists-update"
    "firewall-safe"
    "firewall-strict"
    "configure-system"
    "restore-system"
    "restore-system-default"
)

TRANSLATION_VALUES=(
    "update blocklists"
    "adblock rebuild"
    "install all"
    "install check-deps"
    "install dnscrypt"
    "install coredns"
    "recovery panic-bypass"
    "backup lkg"
    "backup update"
    "install firewall-safe"
    "install firewall-strict"
    "install configure-system"
    "recovery restore-system"
    "recovery restore-system-default"
)

# Translate legacy commands to unified interface
translate_command() {
    local cmd="$1"

    # Find command in translation keys
    local i
    for ((i=0; i<${#TRANSLATION_KEYS[@]}; i++)); do
        if [[ "${TRANSLATION_KEYS[$i]}" == "$cmd" ]]; then
            echo "${TRANSLATION_VALUES[$i]}"
            return 0
        fi
    done

    # No translation found - return original command
    echo "$cmd"
}

# ==============================================================================
# SILENT MODE & OUTPUT CONTROL
# ==============================================================================

SILENT_MODE=false
VERBOSE_MODE=false

# Parse --silent flag
parse_silent_flag() {
    for arg in "$@"; do
        case "$arg" in
            --silent)
                SILENT_MODE=true
                # Remove --silent from arguments
                set -- "${@/--silent/}"
                break
                ;;
            --verbose)
                VERBOSE_MODE=true
                set -- "${@/--verbose/}"
                ;;
        esac
    done
}

# Silent-aware logging functions
log_silent() {
    [[ "$SILENT_MODE" == true ]] && return 0
    log_info "$@"
}

log_verbose() {
    [[ "$VERBOSE_MODE" == true ]] || return 0
    log_debug "$@"
}

# ==============================================================================
# MODULE LOADING HELPERS
# ==============================================================================

# Check if unified module exists
unified_module_exists() {
    local module="$1"
    [[ -f "modules/unified/unified-${module}.sh" ]]
}

# Load unified module with error handling
load_unified_module() {
    local module="$1"

    if unified_module_exists "$module"; then
        if ! load_module "unified/unified-${module}"; then
            log_error "Failed to load unified-${module} module"
            return 1
        fi
    else
        log_error "Unified module unified-${module} not found"
        return 1
    fi
}

# ==============================================================================
# COMMON UTILITY FUNCTIONS
# ==============================================================================

# Safe file operations with backup
safe_write_file() {
    local file="$1"
    local content="$2"
    local backup="${file}.backup.$(date +%s)"

    # Create backup if file exists
    [[ -f "$file" ]] && cp "$file" "$backup" 2>/dev/null

    # Write new content
    echo "$content" > "$file"

    # Verify write succeeded
    if [[ $? -eq 0 ]]; then
        log_silent "Updated $file"
        return 0
    else
        # Restore backup on failure
        [[ -f "$backup" ]] && mv "$backup" "$file" 2>/dev/null
        log_error "Failed to write $file"
        return 1
    fi
}

# Validate IP address
is_valid_ip() {
    local ip="$1"
    [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && return 0
    [[ $ip =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]] && return 0
    return 1
}

# Validate domain name
is_valid_domain() {
    local domain="$1"
    [[ $domain =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && return 0
    return 1
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Initialize unified core
unified_core_init() {
    # Check Bash version
    check_bash_version 4 || return 1

    # Ensure state directory exists
    mkdir -p "${CYTADELA_STATE_DIR}/rate_limits" 2>/dev/null || true

    # Parse silent flag from command line if present
    parse_silent_flag "$@"

    return 0
}

# Export functions for use in other modules
export -f detect_bash_version
export -f check_bash_version
export -f translate_command
export -f parse_silent_flag
export -f log_silent
export -f log_verbose
export -f unified_module_exists
export -f load_unified_module
export -f safe_write_file
export -f is_valid_ip
export -f is_valid_domain
export -f unified_core_init
