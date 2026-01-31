#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ CORE LIBRARY v3.1                                             ║
# ║  Shared utilities for all modules                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# GLOBAL VARIABLES
# ==============================================================================
CYTADELA_VERSION="3.1.0"
CYTADELA_MANIFEST="/etc/cytadela/manifest.sha256"
CYTADELA_STATE_DIR="/var/lib/cytadela"
CYTADELA_LKG_DIR="${CYTADELA_STATE_DIR}/lkg"
CYTADELA_OPT_BIN="/opt/cytadela/bin"
CYTADELA_MODE="${CYTADELA_MODE:-secure}"
CYTADELA_SCRIPT_PATH="$(realpath "$0")"

# Colors (256-color palette for better contrast)
EMR='\e[38;5;43m'    # Emerald - success/active
VIO='\e[38;5;99m'    # Violet - info/sections
RED='\e[38;5;160m'   # Crimson - errors/warnings
RST='\e[0m'          # Reset

# Legacy color aliases (for compatibility)
GREEN="$EMR"
YELLOW="$VIO"
BLUE="$VIO"
CYAN="$EMR"
NC="$RST"

# Loaded modules tracking
declare -gA CYTADELA_LOADED_MODULES

# ==============================================================================
# LOGGING FUNCTIONS
# ==============================================================================
log_info() { echo -e "${EMR}⬥${RST} ${VIO}$1${RST}"; }
log_success() { echo -e "${EMR}✔${RST} $1"; }
log_warning() { echo -e "${RED}⚠${RST} $1"; }
log_error() { echo -e "${RED}✖${RST} $1" >&2; }
log_section() { 
    echo -e "\n${VIO}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RST}"
    echo -e "${VIO}║${RST} $1"
    echo -e "${VIO}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RST}\n"
}
log_debug() {
    [[ "${CYTADELA_DEBUG:-0}" == "1" ]] && echo -e "${VIO}[DEBUG]${RST} $1" >&2
    return 0
}

# ==============================================================================
# ERROR TRAP
# ==============================================================================
trap_err_handler() {
    local exit_code=$?
    local line_no=${BASH_LINENO[0]}
    local func_name=${FUNCNAME[1]:-main}
    local command="$BASH_COMMAND"
    echo -e "${RED}✗ ERROR in ${func_name}() at line ${line_no}: '${command}' exited with code ${exit_code}${NC}" >&2
}
trap 'trap_err_handler' ERR

# ==============================================================================
# INTERNATIONALIZATION (i18n)
# ==============================================================================

# Detect system language
detect_language() {
    case "${LANG}" in
        pl*) echo "pl" ;;
        de*) echo "de" ;;
        fr*) echo "fr" ;;
        es*) echo "es" ;;
        it*) echo "it" ;;
        ru*) echo "ru" ;;
        *)   echo "en" ;;
    esac
}

# Set global language (can be overridden by CYTADELA_LANG env var)
export CYTADELA_LANG="${CYTADELA_LANG:-$(detect_language)}"

# Load i18n strings for a module
load_i18n_module() {
    local module="$1"
    local lang="${CYTADELA_LANG:-en}"
    
    # Always load common strings first
    if [[ -f "${CYTADELA_LIB}/i18n/common/${lang}.sh" ]]; then
        # shellcheck source=/dev/null
        source "${CYTADELA_LIB}/i18n/common/${lang}.sh"
    fi
    
    # Load module-specific strings
    if [[ -n "$module" && -f "${CYTADELA_LIB}/i18n/${module}/${lang}.sh" ]]; then
        # shellcheck source=/dev/null
        source "${CYTADELA_LIB}/i18n/${module}/${lang}.sh"
    fi
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================
require_cmd() {
    command -v "$1" >/dev/null 2>&1
}

require_cmds() {
    local missing=()
    for cmd in "$@"; do
        require_cmd "$cmd" || missing+=("$cmd")
    done
    if (( ${#missing[@]} > 0 )); then
        log_error "Missing required tools: ${missing[*]}"
        return 1
    fi
}

dnssec_enabled() {
    [[ "${CITADEL_DNSSEC:-}" =~ ^(1|true|yes|on)$ ]] && return 0
    [[ "${1:-}" == "--dnssec" || "${2:-}" == "--dnssec" ]] && return 0
    return 1
}

# ==============================================================================
# INTEGRITY CHECK FOR MODULES
# ==============================================================================
integrity_check_module() {
    local module_file="$1"
    
    # Developer mode: skip checks
    [[ "$CYTADELA_MODE" == "developer" ]] && return 0
    
    # No manifest: skip checks (bootstrap)
    [[ ! -f "$CYTADELA_MANIFEST" ]] && return 0
    
    # Get expected hash
    local expected_hash
    expected_hash=$(grep -F "$module_file" "$CYTADELA_MANIFEST" 2>/dev/null | awk '{print $1}')
    
    # No hash in manifest: skip check
    [[ -z "$expected_hash" ]] && return 0
    
    # Calculate actual hash
    local actual_hash
    actual_hash=$(sha256sum "$module_file" | awk '{print $1}')
    
    # Compare
    if [[ "$actual_hash" != "$expected_hash" ]]; then
        log_warning "Module integrity mismatch: $module_file"
        
        # Non-interactive mode: abort
        if [[ ! -t 0 ]]; then
            log_error "Non-interactive mode: aborting"
            return 1
        fi
        
        # Interactive: ask user
        echo -n "Continue despite mismatch? [y/N]: "
        read -r answer
        [[ "$answer" =~ ^[Yy]$ ]] || return 1
    fi
    
    return 0
}
