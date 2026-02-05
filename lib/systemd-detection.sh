#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.2 - SYSTEMD PATH DETECTION & VERIFICATION                   ║
# ║  Cross-distribution systemd compatibility and path detection            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# SYSTEMD DETECTION & PATH VERIFICATION
# ==============================================================================

# Global systemd detection results
SYSTEMD_DETECTED=false
SYSTEMD_VERSION=""
SYSTEMD_ROOT="/"
SYSTEMD_PATHS=()

# Systemd binary paths (by priority)
SYSTEMD_BINARIES=(
    "/usr/bin/systemctl"
    "/bin/systemctl"
    "/usr/sbin/systemctl"
    "/sbin/systemctl"
    "/usr/local/bin/systemctl"
)

# Systemd service directories (by priority)
SYSTEMD_SERVICE_DIRS=(
    "/usr/lib/systemd/system"
    "/lib/systemd/system"
    "/etc/systemd/system"
    "/usr/local/lib/systemd/system"
)

# Systemd user directories
SYSTEMD_USER_DIRS=(
    "/usr/lib/systemd/user"
    "/etc/systemd/user"
)

# Systemd configuration directories
SYSTEMD_CONF_DIRS=(
    "/etc/systemd"
    "/usr/lib/systemd"
)

# Detect init system
detect_init_system() {
    local init_pid init_exe

    # Method 1: Check PID 1
    if [[ -r /proc/1/comm ]]; then
        init_pid=$(cat /proc/1/comm 2>/dev/null | tr -d '\0')
        case "$init_pid" in
            systemd)
                SYSTEMD_DETECTED=true
                return 0
                ;;
            init|sysvinit)
                SYSTEMD_DETECTED=false
                log_error "SysV init detected. Citadel requires systemd."
                return 1
                ;;
            openrc)
                SYSTEMD_DETECTED=false
                log_error "OpenRC init detected. Citadel requires systemd."
                return 1
                ;;
            runit)
                SYSTEMD_DETECTED=false
                log_error "Runit init detected. Citadel requires systemd."
                return 1
                ;;
        esac
    fi

    # Method 2: Check /proc/1/exe
    if [[ -L /proc/1/exe ]]; then
        init_exe=$(readlink -f /proc/1/exe 2>/dev/null)
        case "$init_exe" in
            */systemd)
                SYSTEMD_DETECTED=true
                return 0
                ;;
        esac
    fi

    # Method 3: Check for systemd directories
    if [[ -d /run/systemd ]]; then
        SYSTEMD_DETECTED=true
        return 0
    fi

    # Method 4: Check for systemctl binary
    if command -v systemctl >/dev/null 2>&1; then
        SYSTEMD_DETECTED=true
        return 0
    fi

    SYSTEMD_DETECTED=false
    log_error "Could not detect init system. Citadel requires systemd."
    return 1
}

# Find systemd binary paths
find_systemd_binaries() {
    local binary

    for binary in "${SYSTEMD_BINARIES[@]}"; do
        if [[ -x "$binary" ]]; then
            SYSTEMD_PATHS+=("$binary")
            log_debug "Found systemd binary: $binary"
        fi
    done

    # Also check PATH
    if command -v systemctl >/dev/null 2>&1; then
        local systemctl_path
        systemctl_path=$(command -v systemctl)
        if [[ ! " ${SYSTEMD_PATHS[*]} " =~ " $systemctl_path " ]]; then
            SYSTEMD_PATHS+=("$systemctl_path")
            log_debug "Found systemctl in PATH: $systemctl_path"
        fi
    fi
}

# Find systemd directories
find_systemd_directories() {
    local dir

    # Service directories
    for dir in "${SYSTEMD_SERVICE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            SYSTEMD_PATHS+=("$dir")
            log_debug "Found systemd service dir: $dir"
        fi
    done

    # User directories
    for dir in "${SYSTEMD_USER_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            SYSTEMD_PATHS+=("$dir")
            log_debug "Found systemd user dir: $dir"
        fi
    done

    # Config directories
    for dir in "${SYSTEMD_CONF_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            SYSTEMD_PATHS+=("$dir")
            log_debug "Found systemd config dir: $dir"
        fi
    done
}

# Get systemd version
get_systemd_version() {
    local version_output

    if command -v systemctl >/dev/null 2>&1; then
        version_output=$(systemctl --version 2>/dev/null | head -1)
        if [[ $? -eq 0 && -n "$version_output" ]]; then
            # Extract version number (format: "systemd 255 (255-2-arch)")
            SYSTEMD_VERSION=$(echo "$version_output" | grep -oP 'systemd \K\d+')
            log_debug "Detected systemd version: $SYSTEMD_VERSION"
            return 0
        fi
    fi

    # Fallback: check /etc/os-release or other methods
    if [[ -f /etc/os-release ]]; then
        local id version_id
        # shellcheck source=/dev/null
        source /etc/os-release 2>/dev/null || true

        case "${ID:-}" in
            arch|cachyos|manjaro)
                # Arch-based systems typically have recent systemd
                SYSTEMD_VERSION="255"  # Conservative estimate
                log_debug "Estimated systemd version for ${ID}: $SYSTEMD_VERSION"
                ;;
            ubuntu)
                # Ubuntu systemd versions by release
                case "${VERSION_ID:-}" in
                    "20.04") SYSTEMD_VERSION="245" ;;
                    "22.04") SYSTEMD_VERSION="249" ;;
                    "24.04") SYSTEMD_VERSION="255" ;;
                    *) SYSTEMD_VERSION="245" ;;  # Conservative fallback
                esac
                log_debug "Estimated systemd version for Ubuntu ${VERSION_ID}: $SYSTEMD_VERSION"
                ;;
            fedora)
                # Fedora typically has latest systemd
                SYSTEMD_VERSION="255"
                log_debug "Estimated systemd version for Fedora: $SYSTEMD_VERSION"
                ;;
            *)
                SYSTEMD_VERSION="245"  # Very conservative fallback
                log_debug "Unknown distribution, using conservative systemd version estimate: $SYSTEMD_VERSION"
                ;;
        esac
    else
        SYSTEMD_VERSION="245"  # Very conservative fallback
        log_debug "Could not determine systemd version, using conservative estimate: $SYSTEMD_VERSION"
    fi
}

# Verify systemd functionality
verify_systemd_functionality() {
    local systemctl_path

    # Find systemctl
    systemctl_path=$(command -v systemctl 2>/dev/null || echo "")
    if [[ -z "$systemctl_path" ]]; then
        for path in "${SYSTEMD_BINARIES[@]}"; do
            if [[ -x "$path" ]]; then
                systemctl_path="$path"
                break
            fi
        done
    fi

    if [[ -z "$systemctl_path" ]]; then
        log_error "systemctl binary not found in any standard location"
        return 1
    fi

    # Test systemctl functionality
    if ! "$systemctl_path" --version >/dev/null 2>&1; then
        log_error "systemctl is not functional: $systemctl_path"
        return 1
    fi

    # Test systemd user instance (if available)
    if ! "$systemctl_path" --user --version >/dev/null 2>&1 2>/dev/null; then
        log_warning "systemd user instance not available (optional)"
    fi

    # Test service management
    if ! "$systemctl_path" list-units --no-pager >/dev/null 2>&1; then
        log_error "systemctl cannot list units - systemd may not be fully functional"
        return 1
    fi

    log_debug "systemctl functionality verified: $systemctl_path"
    return 0
}

# Main systemd detection function
detect_systemd() {
    log_debug "Starting systemd detection and verification..."

    # Step 1: Detect init system
    if ! detect_init_system; then
        return 1
    fi

    # Step 2: Find binaries and directories
    find_systemd_binaries
    find_systemd_directories

    # Step 3: Get version
    get_systemd_version

    # Step 4: Verify functionality
    if ! verify_systemd_functionality; then
        return 1
    fi

    echo "ℹ ${T_SYSTEMD_DETECTED:-Systemd detected and verified:}"
    echo "ℹ   - ${T_SYSTEMD_VERSION:-Version:} $SYSTEMD_VERSION"
    echo "ℹ   - ${T_SYSTEMD_STATUS:-Status:} ${T_SYSTEMD_FUNCTIONAL:-Fully functional}"
    echo "ℹ   - ${T_SYSTEMD_PATHS:-Paths found:} ${#SYSTEMD_PATHS[@]} ${T_SYSTEMD_LOCATIONS:-locations}"

    return 0
}

# Get systemctl command with proper path
get_systemctl_cmd() {
    local systemctl_path

    systemctl_path=$(command -v systemctl 2>/dev/null || echo "")
    if [[ -n "$systemctl_path" ]]; then
        echo "$systemctl_path"
        return 0
    fi

    # Fallback to detected paths
    for path in "${SYSTEMD_PATHS[@]}"; do
        if [[ -x "$path" && "${path##*/}" == "systemctl" ]]; then
            echo "$path"
            return 0
        fi
    done

    echo "systemctl"
    return 1
}

# Get systemd service directory
get_systemd_service_dir() {
    for dir in "${SYSTEMD_SERVICE_DIRS[@]}"; do
        if [[ -d "$dir" && -w "$dir" ]]; then
            echo "$dir"
            return 0
        fi
    done

    # Fallback
    echo "/etc/systemd/system"
    return 1
}

# Export functions for use in other modules
export -f detect_init_system
export -f find_systemd_binaries
export -f find_systemd_directories
export -f get_systemd_version
export -f verify_systemd_functionality
export -f detect_systemd
export -f get_systemctl_cmd
export -f get_systemd_service_dir

# Export variables
export SYSTEMD_DETECTED
export SYSTEMD_VERSION
export SYSTEMD_ROOT
export SYSTEMD_PATHS
