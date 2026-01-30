#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ CHECK-DEPENDENCIES MODULE                                     ║
# ║  Comprehensive dependency checker for all Cytadela components             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

check_dependencies() {
    log_section "🔍 CHECKING DEPENDENCIES"
    
    local missing=0
    local optional_missing=0
    
    echo ""
    echo "=== REQUIRED DEPENDENCIES ==="
    echo ""
    
    # Core system tools
    check_dep "bash" "required" "Shell interpreter" || ((missing++))
    check_dep "systemctl" "required" "Systemd service manager" || ((missing++))
    check_dep "nft" "required" "NFTables firewall" "sudo pacman -S nftables" || ((missing++))
    
    # DNS tools
    check_dep "dig" "required" "DNS lookup utility" "sudo pacman -S bind-tools" || ((missing++))
    check_dep "coredns" "required" "CoreDNS server" "sudo pacman -S coredns" || ((missing++))
    check_dep "dnscrypt-proxy" "required" "DNSCrypt proxy" "sudo pacman -S dnscrypt-proxy" || ((missing++))
    
    # Network tools
    check_dep "ip" "required" "Network configuration" "sudo pacman -S iproute2" || ((missing++))
    check_dep "ss" "required" "Socket statistics" "sudo pacman -S iproute2" || ((missing++))
    
    echo ""
    echo "=== OPTIONAL DEPENDENCIES ==="
    echo ""
    
    # Optional but recommended
    check_dep "whiptail" "optional" "Interactive installer GUI" "sudo pacman -S libnewt" || ((optional_missing++))
    check_dep "curl" "optional" "HTTP client for metrics" "sudo pacman -S curl" || ((optional_missing++))
    check_dep "jq" "optional" "JSON processor" "sudo pacman -S jq" || ((optional_missing++))
    
    # Network management
    check_dep "nmcli" "optional" "NetworkManager CLI" "sudo pacman -S networkmanager" || ((optional_missing++))
    check_dep "networkctl" "optional" "systemd-networkd CLI" "(built-in)" || ((optional_missing++))
    
    # Monitoring tools
    check_dep "notify-send" "optional" "Desktop notifications" "sudo pacman -S libnotify" || ((optional_missing++))
    check_dep "ping6" "optional" "IPv6 connectivity test" "sudo pacman -S iputils" || ((optional_missing++))
    
    # Development tools
    check_dep "shellcheck" "optional" "Shell script linter" "sudo pacman -S shellcheck" || ((optional_missing++))
    check_dep "git" "optional" "Version control" "sudo pacman -S git" || ((optional_missing++))
    
    echo ""
    echo "=== SUMMARY ==="
    echo ""
    
    if [[ $missing -eq 0 ]]; then
        log_success "All required dependencies are installed! ✓"
    else
        log_error "$missing required dependencies are missing!"
        echo ""
        echo "Install missing dependencies and run this check again."
        return 1
    fi
    
    if [[ $optional_missing -eq 0 ]]; then
        log_success "All optional dependencies are installed! ✓"
    else
        log_warning "$optional_missing optional dependencies are missing"
        echo ""
        echo "Optional dependencies enhance functionality but are not required."
        echo "Install them for full feature support."
    fi
    
    echo ""
    log_info "Run 'sudo cytadela++ check-deps --install' to auto-install missing packages"
    
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
    log_section "📦 AUTO-INSTALLING MISSING DEPENDENCIES"
    
    # Detect package manager
    local pkg_manager=""
    if command -v pacman &>/dev/null; then
        pkg_manager="pacman"
    elif command -v apt &>/dev/null; then
        pkg_manager="apt"
    elif command -v dnf &>/dev/null; then
        pkg_manager="dnf"
    else
        log_error "No supported package manager found (pacman/apt/dnf)"
        return 1
    fi
    
    log_info "Detected package manager: $pkg_manager"
    echo ""
    
    # Define packages per manager
    local packages=()
    
    case "$pkg_manager" in
        pacman)
            # Check and add missing packages
            command -v nft &>/dev/null || packages+=("nftables")
            command -v dig &>/dev/null || packages+=("bind-tools")
            command -v coredns &>/dev/null || packages+=("coredns")
            command -v dnscrypt-proxy &>/dev/null || packages+=("dnscrypt-proxy")
            command -v whiptail &>/dev/null || packages+=("libnewt")
            command -v curl &>/dev/null || packages+=("curl")
            command -v jq &>/dev/null || packages+=("jq")
            command -v notify-send &>/dev/null || packages+=("libnotify")
            command -v shellcheck &>/dev/null || packages+=("shellcheck")
            ;;
        apt)
            command -v nft &>/dev/null || packages+=("nftables")
            command -v dig &>/dev/null || packages+=("dnsutils")
            command -v coredns &>/dev/null || packages+=("coredns")
            command -v dnscrypt-proxy &>/dev/null || packages+=("dnscrypt-proxy")
            command -v whiptail &>/dev/null || packages+=("whiptail")
            command -v curl &>/dev/null || packages+=("curl")
            command -v jq &>/dev/null || packages+=("jq")
            command -v notify-send &>/dev/null || packages+=("libnotify-bin")
            command -v shellcheck &>/dev/null || packages+=("shellcheck")
            ;;
        dnf)
            command -v nft &>/dev/null || packages+=("nftables")
            command -v dig &>/dev/null || packages+=("bind-utils")
            command -v coredns &>/dev/null || packages+=("coredns")
            command -v dnscrypt-proxy &>/dev/null || packages+=("dnscrypt-proxy")
            command -v whiptail &>/dev/null || packages+=("newt")
            command -v curl &>/dev/null || packages+=("curl")
            command -v jq &>/dev/null || packages+=("jq")
            command -v notify-send &>/dev/null || packages+=("libnotify")
            command -v shellcheck &>/dev/null || packages+=("ShellCheck")
            ;;
    esac
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_success "All dependencies are already installed!"
        return 0
    fi
    
    log_info "Missing packages: ${packages[*]}"
    echo ""
    echo -n "Install missing packages? [y/N]: "
    read -r answer
    
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        log_warning "Installation cancelled"
        return 1
    fi
    
    echo ""
    log_info "Installing packages..."
    
    case "$pkg_manager" in
        pacman)
            sudo pacman -S --needed --noconfirm "${packages[@]}"
            ;;
        apt)
            sudo apt update
            sudo apt install -y "${packages[@]}"
            ;;
        dnf)
            sudo dnf install -y "${packages[@]}"
            ;;
    esac
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "Dependencies installed successfully!"
        echo ""
        log_info "Run 'sudo cytadela++ check-deps' to verify installation"
    else
        log_error "Installation failed with exit code $exit_code"
        return 1
    fi
}

check_dependencies_help() {
    cat <<'EOF'
🔍 CHECK-DEPS - Dependency Checker

USAGE:
  sudo cytadela++ check-deps [--install]

DESCRIPTION:
  Checks if all required and optional dependencies are installed.
  Shows version information where available.

OPTIONS:
  --install    Auto-install missing dependencies

DEPENDENCIES CHECKED:

Required:
  - bash           Shell interpreter
  - systemctl      Systemd service manager
  - nft            NFTables firewall
  - dig            DNS lookup utility
  - coredns        CoreDNS server
  - dnscrypt-proxy DNSCrypt proxy
  - ip, ss         Network tools

Optional:
  - whiptail       Interactive installer GUI
  - curl           HTTP client for metrics
  - jq             JSON processor
  - nmcli          NetworkManager CLI
  - notify-send    Desktop notifications
  - shellcheck     Shell script linter
  - git            Version control

EXAMPLES:
  sudo cytadela++ check-deps           # Check dependencies
  sudo cytadela++ check-deps --install # Auto-install missing

EOF
}
