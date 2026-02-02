#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ CHECK-DEPENDENCIES MODULE                                     ║
# ║  Comprehensive dependency checker for all Cytadela components             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Load dependencies configuration
if [[ -f "${CYTADELA_LIB}/dependencies.conf" ]]; then
    source "${CYTADELA_LIB}/dependencies.conf"
fi

check_dependencies() {
    log_section "🔍 ${T_CHECK_DEPS_TITLE:-CHECKING DEPENDENCIES}"

    local missing=0
    local optional_missing=0

    echo ""
    echo "=== ${T_REQUIRED_DEPS:-REQUIRED DEPENDENCIES} ==="
    echo ""

    # Check all required dependencies from config
    local cmd desc pkg
    for cmd in "${!CYTADELA_DEPS_REQUIRED[@]}"; do
        IFS='|' read -r desc pkg _ <<< "${CYTADELA_DEPS_REQUIRED[$cmd]}"
        check_dep "$cmd" "required" "$desc" "sudo pacman -S $pkg" || ((missing++))
    done

    echo ""
    echo "=== ${T_OPTIONAL_DEPS:-OPTIONAL DEPENDENCIES} ==="
    echo ""

    # Check all optional dependencies from config
    for cmd in "${!CYTADELA_DEPS_OPTIONAL[@]}"; do
        IFS='|' read -r desc pkg _ <<< "${CYTADELA_DEPS_OPTIONAL[$cmd]}"
        check_dep "$cmd" "optional" "$desc" "sudo pacman -S $pkg" || ((optional_missing++))
    done

    echo ""
    echo "=== ${T_SUMMARY:-SUMMARY} ==="
    echo ""

    if [[ $missing -eq 0 ]]; then
        log_success "${T_ALL_REQUIRED_OK:-All required dependencies are installed!} ✓"
    else
        log_error "$missing ${T_REQUIRED_MISSING:-required dependencies are missing!}"
        echo ""
        echo "Install missing dependencies and run this check again."
        return 1
    fi

    if [[ $optional_missing -eq 0 ]]; then
        log_success "${T_ALL_OPTIONAL_OK:-All optional dependencies are installed!} ✓"
    else
        log_warning "$optional_missing ${T_OPTIONAL_MISSING:-optional dependencies are missing}"
        echo ""
        echo "${T_OPTIONAL_INFO:-Optional dependencies enhance functionality but are not required.}"
        echo "Install them for full feature support."
    fi

    echo ""
    log_info "${T_INSTALL_HINT:-Run 'sudo cytadela++ check-deps --install' to auto-install missing packages}"

    return 0
}

check_dep() {
    local cmd="$1"
    local type="$2"
    local desc="$3"
    local install_hint="${4:-}"

    if command -v "$cmd" &>/dev/null; then
        local version=""
        case "$cmd" in
            bash) version=$(bash --version | head -1 | awk '{print $4}') ;;
            nft) version=$(nft --version 2>/dev/null | awk '{print $2}') ;;
            dig) version=$(dig -v 2>&1 | grep -oP 'DiG \K[0-9.]+' | head -1) ;;
            coredns) version=$(coredns -version 2>&1 | grep -oP 'CoreDNS-\K[0-9.]+' | head -1) ;;
            dnscrypt-proxy) version=$(dnscrypt-proxy -version 2>&1 | head -1 | awk '{print $2}') ;;
            git) version=$(git --version | awk '{print $3}') ;;
            curl) version=$(curl --version | head -1 | awk '{print $2}') ;;
            jq) version=$(jq --version 2>&1 | grep -oP '[0-9.]+' | head -1) ;;
            systemctl) version=$(systemctl --version | head -1 | awk '{print $2}') ;;
            openssl) version=$(openssl version | awk '{print $2}') ;;
            *) version="" ;;
        esac

        if [[ -n "$version" ]]; then
            printf "  ${GREEN}✓${NC} %-20s %s (v%s)\n" "$cmd" "$desc" "$version"
        else
            printf "  ${GREEN}✓${NC} %-20s %s\n" "$cmd" "$desc"
        fi
        return 0
    else
        if [[ "$type" == "required" ]]; then
            printf "  ${RED}✗${NC} %-20s %s\n" "$cmd" "$desc"
            [[ -n "$install_hint" ]] && echo "      Install: $install_hint"
        else
            printf "  ${YELLOW}⚠${NC} %-20s %s\n" "$cmd" "$desc"
            [[ -n "$install_hint" ]] && echo "      Install: $install_hint"
        fi
        return 1
    fi
}

check_dependencies_install() {
    log_section "📦 ${T_AUTO_INSTALL_TITLE:-AUTO-INSTALLING MISSING DEPENDENCIES}"

    # Detect package manager
    local pkg_manager=""
    if command -v pacman &>/dev/null; then
        pkg_manager="pacman"
    elif command -v apt &>/dev/null; then
        pkg_manager="apt"
    elif command -v dnf &>/dev/null; then
        pkg_manager="dnf"
    else
        log_error "${T_NO_PKG_MANAGER:-No supported package manager found (pacman/apt/dnf)}"
        return 1
    fi

    log_info "${T_PKG_MANAGER_DETECTED:-Detected package manager:} $pkg_manager"
    echo ""

    # Build list of missing packages from config
    local packages=()
    local cmd pkg

    # Check required dependencies
    for cmd in "${!CYTADELA_DEPS_REQUIRED[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            IFS='|' read -r _ pkg _ <<< "${CYTADELA_DEPS_REQUIRED[$cmd]}"
            # Map package names for different distros
            case "$pkg_manager" in
                apt)
                    case "$pkg" in
                        bind-tools) pkg="dnsutils" ;;
                        libnewt) pkg="whiptail" ;;
                        libnotify) pkg="libnotify-bin" ;;
                    esac
                    ;;
                dnf)
                    case "$pkg" in
                        bind-tools) pkg="bind-utils" ;;
                        libnewt) pkg="newt" ;;
                        shellcheck) pkg="ShellCheck" ;;
                    esac
                    ;;
            esac
            packages+=("$pkg")
        fi
    done

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_success "${T_ALL_REQUIRED_OK:-All dependencies are already installed!}"
        return 0
    fi

    log_info "${T_MISSING_PACKAGES:-Missing packages:} ${packages[*]}"
    echo ""
    echo -n "${T_INSTALL_PROMPT:-Install missing packages? [y/N]: }"
    read -r answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        log_warning "${T_INSTALL_CANCELLED:-Installation cancelled}"
        return 1
    fi

    echo ""
    log_info "${T_INSTALLING_PACKAGES:-Installing packages...}"

    local exit_code=0
    case "$pkg_manager" in
        pacman)
            sudo pacman -S --needed --noconfirm "${packages[@]}" || exit_code=$?
            ;;
        apt)
            sudo apt update && sudo apt install -y "${packages[@]}" || exit_code=$?
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}" || exit_code=$?
            ;;
    esac

    if [[ $exit_code -eq 0 ]]; then
        log_success "${T_INSTALL_SUCCESS:-Dependencies installed successfully!}"
        echo ""
        log_info "${T_VERIFY_HINT:-Run 'sudo cytadela++ check-deps' to verify installation}"
    else
        log_error "${T_INSTALL_FAILED:-Installation failed with exit code} $exit_code"
        return 1
    fi
}

check_dependencies_help() {
    local req_list=""
    local opt_list=""
    local cmd desc

    # Generate required dependencies list
    for cmd in "${!CYTADELA_DEPS_REQUIRED[@]}"; do
        IFS='|' read -r desc _ <<< "${CYTADELA_DEPS_REQUIRED[$cmd]}"
        req_list+="  - ${cmd,-15} ${desc}\n"
    done

    # Generate optional dependencies list (limit to most important ones)
    for cmd in whiptail curl jq nmcli notify-send shellcheck git htop watch lsof fuser netstat; do
        if [[ -n "${CYTADELA_DEPS_OPTIONAL[$cmd]}" ]]; then
            IFS='|' read -r desc _ <<< "${CYTADELA_DEPS_OPTIONAL[$cmd]}"
            opt_list+="  - ${cmd,-15} ${desc}\n"
        fi
    done

    cat <<EOF
🔍 ${T_CHECK_DEPS_TITLE:-CHECK-DEPS} - ${T_CHECK_DEPS_DESC:-Dependency Checker}

${T_USAGE:-USAGE}:
  sudo cytadela++ check-deps [--install]

${T_DESCRIPTION:-DESCRIPTION}:
  ${T_CHECK_DEPS_LONG_DESC:-Checks if all required and optional dependencies are installed.}
  ${T_SHOWS_VERSION:-Shows version information where available.}

${T_OPTIONS:-OPTIONS}:
  --install    ${T_AUTO_INSTALL_DESC:-Auto-install missing dependencies}

${T_DEPS_CHECKED:-DEPENDENCIES CHECKED}:

${T_REQUIRED_DEPS:-Required}:
${req_list}
${T_OPTIONAL_DEPS:-Optional} (${T_MOST_IMPORTANT:-most important}):
${opt_list}
${T_EXAMPLES:-EXAMPLES}:
  sudo cytadela++ check-deps           # ${T_CHECK_ONLY:-Check dependencies}
  sudo cytadela++ check-deps --install # ${T_AUTO_INSTALL_CMD:-Auto-install missing}

EOF
}
