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
# MODULE UTILITIES
# ==============================================================================
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
