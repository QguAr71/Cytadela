#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ CORE LIBRARY v3.1                                             ║
# ║  Shared utilities for all modules                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# GLOBAL VARIABLES
# ==============================================================================
# shellcheck disable=SC2034
CYTADELA_VERSION="3.1.0"
CYTADELA_MANIFEST="/etc/cytadela/manifest.sha256"
CYTADELA_STATE_DIR="/var/lib/cytadela"
# shellcheck disable=SC2034
CYTADELA_LKG_DIR="${CYTADELA_STATE_DIR}/lkg"
# shellcheck disable=SC2034
CYTADELA_OPT_BIN="/opt/cytadela/bin"
CYTADELA_MODE="${CYTADELA_MODE:-secure}"
# shellcheck disable=SC2034
CYTADELA_SCRIPT_PATH="$(realpath "$0")"

# Colors (256-color palette for better contrast)
# Auto-disable colors if stdout is not a TTY (for CI/logs)
if [[ -t 1 ]]; then
    EMR='\e[38;5;43m'  # Emerald - success/active
    VIO='\e[38;5;99m'  # Violet - info/sections
    RED='\e[38;5;160m' # Crimson - errors/warnings
    RST='\e[0m'        # Reset
else
    EMR=''
    VIO=''
    RED=''
    RST=''
fi

# Legacy color aliases (for compatibility)
# shellcheck disable=SC2034
GREEN="$EMR"
# shellcheck disable=SC2034
YELLOW="$VIO"
# shellcheck disable=SC2034
BLUE="$VIO"
# shellcheck disable=SC2034
CYAN="$EMR"
NC="$RST"

# Loaded modules tracking
# shellcheck disable=SC2034
declare -gA CYTADELA_LOADED_MODULES

# ==============================================================================
# LOGGING FUNCTIONS (using printf for safety)
# ==============================================================================
log_info() { printf '%b\n' "${EMR}⬥${RST} ${VIO}$1${RST}"; }
log_success() { printf '%b\n' "${EMR}✔${RST} $1"; }
log_warning() { printf '%b\n' "${RED}⚠${RST} $1"; }
log_error() { printf '%b\n' "${RED}✖${RST} $1" >&2; }
log_section() {
    printf '\n%b\n' "${VIO}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RST}"
    printf '%b\n' "${VIO}║${RST} $1"
    printf '%b\n\n' "${VIO}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${RST}"
}
log_debug() {
    [[ "${CYTADELA_DEBUG:-0}" == "1" ]] && printf '%b\n' "${VIO}[DEBUG]${RST} $1" >&2
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
    printf '%b\n' "${RED}✗ ERROR in ${func_name}() at line ${line_no}: '${command}' exited with code ${exit_code}${NC}" >&2
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
        *) echo "en" ;;
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
    if ((${#missing[@]} > 0)); then
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

# ==============================================================================
# RATE LIMITING
# ==============================================================================
RATE_LIMIT_DIR="${CYTADELA_STATE_DIR}/rate-limits"

rate_limit_check() {
    local operation="$1"
    local max_attempts="${2:-3}"
    local window_seconds="${3:-60}"

    mkdir -p "$RATE_LIMIT_DIR"

    local limit_file="${RATE_LIMIT_DIR}/${operation}"
    local lock_file="${limit_file}.lock"
    local now
    now=$(date +%s)

    # Use flock for atomic operations (prevent race conditions)
    local count=0
    (
        # Try to acquire exclusive lock with timeout
        if ! flock -w 2 9; then
            log_error "Rate limit: could not acquire lock"
            exit 1
        fi

        # Clean old entries and count recent ones
        if [[ -f "$limit_file" ]]; then
            local temp_file
            temp_file=$(mktemp)
            while IFS= read -r timestamp; do
                if [[ $((now - timestamp)) -lt $window_seconds ]]; then
                    echo "$timestamp" >> "$temp_file"
                    ((count++))
                fi
            done < "$limit_file"
            mv "$temp_file" "$limit_file"
        fi

        # Check if limit exceeded
        if [[ $count -ge $max_attempts ]]; then
            log_error "Rate limit exceeded for: $operation"
            log_info "Maximum $max_attempts attempts per ${window_seconds}s"
            exit 1
        fi

        # Record this attempt
        echo "$now" >> "$limit_file"
        exit 0
    ) 9>"$lock_file"

    return $?
}
