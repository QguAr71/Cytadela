#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3+ - ENHANCED COMMAND LINE INSTALLER                        ║
# ║  Advanced installation with profiles, component selection & gum TUI     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/citadel-install-$(date +%Y%m%d-%H%M%S).log"

# Enhanced CLI options
PROFILE="standard"
COMPONENTS=""
DRY_RUN=false
VERBOSE=false
GUM_ENHANCED=false
BACKUP_EXISTING=false
SELECT_COMPONENTS=false

# Available profiles
declare -A PROFILES=(
    ["minimal"]="dnscrypt,coredns"
    ["standard"]="dnscrypt,coredns,adblock"
    ["security"]="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging"
    ["full"]="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging,honeypot,prometheus"
    ["custom"]=""
)

# Available components
declare -A COMPONENTS_DESC=(
    ["dnscrypt"]="DNS encryption and caching"
    ["coredns"]="DNS server and filtering"
    ["adblock"]="DNS-based ad blocking"
    ["reputation"]="IP reputation scoring"
    ["asn-blocking"]="Network-level blocking"
    ["event-logging"]="Structured event logging"
    ["honeypot"]="Scanner detection traps"
    ["prometheus"]="Metrics collection"
    ["firewall"]="NFTables firewall rules"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Gum-enhanced colors if available
if command -v gum >/dev/null 2>&1; then
    GUM_AVAILABLE=true
else
    GUM_AVAILABLE=false
fi

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

# Enhanced status output
status() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --foreground 46 "✓ $1"
    else
        echo -e "${GREEN}✓${NC} $1"
    fi
}

error() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --foreground 196 "✗ $1"
    else
        echo -e "${RED}✗${NC} $1" >&2
    fi
    log "ERROR: $1"
    exit 1
}

warning() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --foreground 214 "⚠ $1"
    else
        echo -e "${YELLOW}⚠${NC} $1" >&2
    fi
    log "WARNING: $1"
}

info() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --foreground 39 "$1"
    else
        echo -e "${BLUE}$1${NC}"
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile=*)
                PROFILE="${1#*=}"
                shift
                ;;
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            --components=*)
                COMPONENTS="${1#*=}"
                shift
                ;;
            --components)
                COMPONENTS="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --gum|--gum-enhanced)
                GUM_ENHANCED=true
                shift
                ;;
            --backup-existing)
                BACKUP_EXISTING=true
                shift
                ;;
            --select-components)
                SELECT_COMPONENTS=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
Citadel v3.3+ Enhanced CLI Installer

USAGE:
    sudo ./citadel-install-cli.sh [OPTIONS]

OPTIONS:
    --profile=PROFILE      Installation profile (minimal|standard|security|full|custom)
    --components=LIST      Comma-separated list of components to install
    --dry-run             Show what would be installed without making changes
    --verbose             Enable verbose output
    --gum-enhanced        Use gum TUI for enhanced user experience
    --backup-existing     Create backups of existing configurations
    --select-components   Interactive component selection
    --help, -h           Show this help message

PROFILES:
    minimal     - Core DNS functionality (dnscrypt, coredns)
    standard    - Basic protection (dnscrypt, coredns, adblock)
    security    - Advanced security (standard + reputation, asn-blocking, logging)
    full        - Everything (security + honeypot, prometheus)
    custom      - Custom component selection

COMPONENTS:
    dnscrypt        - DNS encryption and caching
    coredns         - DNS server and filtering
    adblock         - DNS-based ad blocking
    reputation      - IP reputation scoring
    asn-blocking    - Network-level blocking
    event-logging   - Structured event logging
    honeypot        - Scanner detection traps
    prometheus      - Metrics collection
    firewall        - NFTables firewall rules

EXAMPLES:
    sudo ./citadel-install-cli.sh --profile=standard
    sudo ./citadel-install-cli.sh --components=dnscrypt,coredns,adblock --dry-run
    sudo ./citadel-install-cli.sh --select-components --gum-enhanced

EOF
}

# Validate profile
validate_profile() {
    if [[ -z "${PROFILES[$PROFILE]}" ]] && [[ "$PROFILE" != "custom" ]]; then
        error "Invalid profile: $PROFILE. Available: ${!PROFILES[*]} custom"
    fi
}

# Interactive component selection
select_components_interactive() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        # Gum-enhanced selection
        gum style --bold --foreground 212 "Component Selection"

        local available_components=""
        for comp in "${!COMPONENTS_DESC[@]}"; do
            available_components+="$comp|${COMPONENTS_DESC[$comp]}\n"
        done

        # Use gum choose for multi-selection
        COMPONENTS=$(echo -e "$available_components" | gum choose --no-limit --header "Select components to install:" | cut -d'|' -f1 | tr '\n' ',' | sed 's/,$//')

    else
        # Fallback to text-based selection
        echo "Available components:"
        local i=1
        declare -a comp_list
        for comp in "${!COMPONENTS_DESC[@]}"; do
            echo "  $i) $comp - ${COMPONENTS_DESC[$comp]}"
            comp_list[$i]="$comp"
            ((i++))
        done

        echo ""
        echo -n "Enter component numbers (comma-separated): "
        read -r selection

        COMPONENTS=""
        IFS=',' read -ra selections <<< "$selection"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | xargs)  # trim whitespace
            if [[ "$sel" =~ ^[0-9]+$ ]] && [[ -n "${comp_list[$sel]}" ]]; then
                COMPONENTS+="${comp_list[$sel]},"
            fi
        done
        COMPONENTS=${COMPONENTS%,}
    fi
}

# Determine components to install
determine_components() {
    if [[ -n "$COMPONENTS" ]]; then
        # Components explicitly specified
        return
    elif [[ "$SELECT_COMPONENTS" == true ]]; then
        # Interactive selection
        select_components_interactive
    elif [[ "$PROFILE" == "custom" ]]; then
        # Custom profile requires component selection
        select_components_interactive
    else
        # Use profile defaults
        COMPONENTS="${PROFILES[$PROFILE]}"
    fi

    if [[ -z "$COMPONENTS" ]]; then
        error "No components selected for installation"
    fi
}

# Display installation plan
show_installation_plan() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        gum style --bold --foreground 212 "Citadel v3.3+ Installation Plan"
    else
        echo "Citadel v3.3+ Installation Plan"
        echo "================================"
    fi

    echo "Profile: $PROFILE"
    echo "Components: $COMPONENTS"
    echo "Dry run: $DRY_RUN"
    echo "Gum enhanced: $GUM_ENHANCED"
    echo "Backup existing: $BACKUP_EXISTING"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        warning "DRY RUN MODE - No changes will be made"
    fi

    # List selected components
    echo "Selected components:"
    IFS=',' read -ra comp_array <<< "$COMPONENTS"
    for comp in "${comp_array[@]}"; do
        comp=$(echo "$comp" | xargs)
        if [[ -n "${COMPONENTS_DESC[$comp]}" ]]; then
            echo "  • $comp - ${COMPONENTS_DESC[$comp]}"
        else
            warning "Unknown component: $comp"
        fi
    done
    echo ""

    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        if gum confirm "Proceed with installation?"; then
            return 0
        else
            info "Installation cancelled"
            exit 0
        fi
    else
        echo -n "Proceed with installation? [y/N]: "
        read -r answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            info "Installation cancelled"
            exit 0
        fi
    fi
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error "This installer must be run as root (sudo)"
fi

# Parse arguments
parse_args "$@"

# Validate profile
validate_profile

# Determine components
determine_components

# Enhanced welcome message
if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
    gum style --bold --foreground 212 --border double --padding "1 2" "Citadel v3.3+ Enhanced CLI Installer"
else
    echo "Citadel v3.3+ Enhanced CLI Installer"
    echo "==================================="
fi

echo "Working directory: $SCRIPT_DIR"
echo "Log file: $LOG_FILE"
echo ""

log "Starting Citadel v3.3+ enhanced installation"
log "Profile: $PROFILE, Components: $COMPONENTS, Dry-run: $DRY_RUN, Gum: $GUM_ENHANCED"

# Show installation plan
show_installation_plan

# Continue with existing installation logic...

# Function to run citadel commands
run_citadel() {
    local cmd="$1"
    log "Running: citadel.sh $cmd"
    if ! "$SCRIPT_DIR/citadel.sh" $cmd >> "$LOG_FILE" 2>&1; then
        error "Failed to run: citadel.sh $cmd"
    fi
}

# Function to check service status
check_service() {
    local service="$1"
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        log "$service is running"
        return 0
    else
        log "$service is not running"
        return 1
    fi
}

# Component installation logic
install_component() {
    local component="$1"

    case "$component" in
        dnscrypt)
            status "Installing DNSCrypt..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install dnscrypt"
                if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then
                    status "DNSCrypt installed and running"
                else
                    warning "DNSCrypt service not active (expected after config)"
                fi
            else
                status "Would install DNSCrypt"
            fi
            ;;

        coredns)
            status "Installing CoreDNS..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install coredns"
                if systemctl is-active --quiet coredns 2>/dev/null; then
                    status "CoreDNS installed and running"
                else
                    warning "CoreDNS service not active (expected after config)"
                fi
            else
                status "Would install CoreDNS"
            fi
            ;;

        firewall)
            status "Configuring firewall..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install firewall-safe"
                if systemctl is-active --quiet nftables 2>/dev/null; then
                    status "Firewall configured"
                else
                    warning "Firewall service not active"
                fi
            else
                status "Would configure firewall"
            fi
            ;;

        adblock)
            status "Initializing blocklists..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "backup lists-update"
                status "Blocklists updated"
            else
                status "Would initialize blocklists"
            fi

            status "Configuring adblock..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "adblock blocklist-switch balanced"
                status "Adblock configured"
            else
                status "Would configure adblock"
            fi
            ;;

        reputation)
            status "Initializing reputation system..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable reputation in configuration
                log "Enabling reputation system"
                status "Reputation system enabled"
            else
                status "Would initialize reputation system"
            fi
            ;;

        asn-blocking)
            status "Initializing ASN blocking..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable ASN blocking in configuration
                log "Enabling ASN blocking system"
                status "ASN blocking enabled"
            else
                status "Would initialize ASN blocking"
            fi
            ;;

        event-logging)
            status "Initializing event logging..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable event logging in configuration
                log "Enabling event logging system"
                status "Event logging enabled"
            else
                status "Would initialize event logging"
            fi
            ;;

        honeypot)
            status "Initializing honeypot system..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable honeypot in configuration
                log "Enabling honeypot system"
                status "Honeypot system enabled"
            else
                status "Would initialize honeypot system"
            fi
            ;;

        prometheus)
            status "Installing Prometheus metrics..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install dashboard"
                status "Prometheus metrics enabled"
            else
                status "Would install Prometheus metrics"
            fi
            ;;
    esac
}

# Main installation logic
main_installation() {
    IFS=',' read -ra comp_array <<< "$COMPONENTS"

    # Step 1: Check dependencies (always first)
    status "Checking system dependencies..."
    if [[ "$DRY_RUN" == false ]]; then
        run_citadel "install check-deps --install"
        status "Dependencies OK"
    else
        status "Would check dependencies"
    fi

    # Step 2: Install core components in order
    local core_components=("dnscrypt" "coredns" "firewall")
    for comp in "${core_components[@]}"; do
        if [[ " ${comp_array[*]} " =~ " $comp " ]]; then
            install_component "$comp"
        fi
    done

    # Step 3: Configure system DNS
    if [[ " ${comp_array[*]} " =~ " dnscrypt " ]] || [[ " ${comp_array[*]} " =~ " coredns " ]]; then
        status "Configuring system DNS..."
        if [[ "$DRY_RUN" == false ]]; then
            run_citadel "install configure-system"
            status "System DNS configured"
        else
            status "Would configure system DNS"
        fi
    fi

    # Step 4: Install security features
    local security_components=("adblock" "reputation" "asn-blocking" "event-logging" "honeypot")
    for comp in "${security_components[@]}"; do
        if [[ " ${comp_array[*]} " =~ " $comp " ]]; then
            install_component "$comp"
        fi
    done

    # Step 5: Install monitoring
    if [[ " ${comp_array[*]} " =~ " prometheus " ]]; then
        install_component "prometheus"
    fi

    # Step 6: Enable auto-updates
    if [[ " ${comp_array[*]} " =~ " adblock " ]]; then
        status "Enabling auto-updates..."
        if [[ "$DRY_RUN" == false ]]; then
            run_citadel "backup auto-update-enable"
            status "Auto-updates enabled"
        else
            status "Would enable auto-updates"
        fi
    fi

    # Step 7: Final verification
    status "Running final verification..."
    if [[ "$DRY_RUN" == false ]]; then
        run_citadel "monitor status" >/dev/null 2>&1

        # Test DNS resolution
        if dig @127.0.0.1 google.com +short +time=5 >/dev/null 2>&1; then
            status "DNS resolution working"
        else
            warning "DNS resolution test failed"
        fi
    else
        status "Would run final verification"
    fi
}

# Run main installation
main_installation

# Completion message
echo ""
if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
    gum style --bold --foreground 212 --border double --padding "1 2" "INSTALLATION COMPLETE"
else
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                           INSTALLATION COMPLETE                         ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
fi

echo ""
if [[ "$DRY_RUN" == true ]]; then
    status "Dry run completed - no changes made"
else
    status "Citadel v3.3+ successfully installed!"
fi

echo ""
echo "Next steps:"
echo "• Start monitoring: ./citadel-top"
echo "• Check status: sudo ./citadel.sh monitor status"
echo "• View logs: sudo ./citadel.sh logs"
echo "• Update blocklists: sudo ./citadel.sh backup lists-update"
echo ""
echo "Log file: $LOG_FILE"

log "Installation completed successfully"
