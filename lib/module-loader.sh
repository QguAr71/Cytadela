#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ MODULE LOADER v3.1                                            ║
# ║  Lazy loading and module management                                       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# MODULE LOADING
# ==============================================================================
load_module() {
    local module="$1"
    local module_file="${CYTADELA_MODULES}/${module}.sh"

    # Check if module exists
    if [[ ! -f "$module_file" ]]; then
        log_error "Module not found: $module"
        return 1
    fi

    # Check if already loaded
    if [[ -n "${CYTADELA_LOADED_MODULES[$module]:-}" ]]; then
        log_debug "Module already loaded: $module"
        return 0
    fi

    # Integrity check in secure mode (skip if function not available)
    if [[ "$CYTADELA_MODE" == "secure" ]] && declare -f integrity_check_module >/dev/null 2>&1; then
        if ! integrity_check_module "$module_file"; then
            log_error "Integrity check failed for module: $module"
            return 1
        fi
    fi

    # Load module
    log_debug "Loading module: $module"
    source_lib "$module_file"

    # Mark as loaded
    CYTADELA_LOADED_MODULES[$module]=1

    return 0
}

# ==============================================================================
# AUTO-DISCOVERY (Enhancement #2)
# ==============================================================================
load_module_for_command() {
    local cmd="$1"

    # Try exact match first (e.g., "install-all" -> "install-all.sh")
    if [[ -f "${CYTADELA_MODULES}/${cmd}.sh" ]]; then
        load_module "$cmd"
        return 0
    fi

    # Extract module name from command (first segment before "-")
    local module="${cmd%%-*}"

    # Try to load module by prefix
    if [[ -f "${CYTADELA_MODULES}/${module}.sh" ]]; then
        load_module "$module"
        return 0
    fi

    # Fallback: check special mappings
    case "$cmd" in
        discover)
            load_module "discover"
            return $?
            ;;
        verify | diagnostics | test-all)
            load_module "diagnostics"
            return $?
            ;;
        install-all)
            load_module "install-all"
            return $?
            ;;
        help | --help | -h)
            # No module needed for help
            return 0
            ;;
        *)
            log_error "Unknown command: $cmd"
            return 1
            ;;
    esac
}

# ==============================================================================
# UNIFIED MODULE SUPPORT (v3.2)
# ==============================================================================

# Load unified module (new v3.2 architecture)
load_unified_module() {
    local module="$1"
    local unified_file="${CYTADELA_MODULES}/unified/unified-${module}.sh"

    # Check if unified module exists
    if [[ ! -f "$unified_file" ]]; then
        log_error "Unified module not found: unified-${module}"
        return 1
    fi

    # Check if already loaded
    if [[ -n "${CYTADELA_LOADED_MODULES[unified-${module}]:-}" ]]; then
        log_debug "Unified module already loaded: unified-${module}"
        return 0
    fi

    # Integrity check in secure mode
    if [[ "$CYTADELA_MODE" == "secure" ]] && declare -f integrity_check_module >/dev/null 2>&1; then
        if ! integrity_check_module "$unified_file"; then
            log_error "Integrity check failed for unified module: unified-${module}"
            return 1
        fi
    fi

    # Load unified module
    log_debug "Loading unified module: unified-${module}"
    source_lib "$unified_file"

    # Mark as loaded
    CYTADELA_LOADED_MODULES[unified-${module}]=1

    return 0
}

# Smart module loading - tries unified first, then legacy
smart_load_module() {
    local cmd="$1"

    # Extract module name from command
    local module="${cmd%%-*}"

    # Try unified module first (v3.2 architecture)
    case "$module" in
        install|security|network|adblock|backup|monitor|recovery)
            if load_unified_module "$module"; then
                return 0
            fi
            ;;
    esac

    # Fallback to legacy loading
    load_module_for_command "$cmd"
}

# Check if command should use unified module
is_unified_command() {
    local cmd="$1"
    local module="${cmd%%-*}"

    case "$module" in
        install|security|network|adblock|backup|monitor|recovery)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
list_available_modules() {
    local modules=()
    for module_file in "${CYTADELA_MODULES}"/*.sh; do
        [[ -f "$module_file" ]] || continue
        local module
        module=$(basename "$module_file" .sh)
        modules+=("$module")
    done
    echo "${modules[@]}"
}

is_module_loaded() {
    local module="$1"
    [[ -n "${CYTADELA_LOADED_MODULES[$module]:-}" ]]
}
