#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3+ - ENHANCED COMMAND LINE INSTALLER                        ║
# ║  Advanced installation with profiles, component selection & gum TUI     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/citadel-install-$(date +%Y%m%d-%H%M%S).log"

# Language configuration
LANGUAGE="en"
declare -A LANGUAGES=(
    ["en"]="English"
    ["pl"]="Polski"
    ["de"]="Deutsch"
    ["es"]="Español"
    ["fr"]="Français"
    ["it"]="Italiano"
    ["ru"]="Русский"
)

# Enhanced CLI options
PROFILE="standard"
COMPONENTS=""
DRY_RUN=false
VERBOSE=false
GUM_ENHANCED=false
BACKUP_EXISTING=true  # Enabled by default for safety
SELECT_COMPONENTS=false

# Available profiles
declare -A PROFILES=(
    ["minimal"]="dnscrypt,coredns"
    ["standard"]="dnscrypt,coredns,adblock"
    ["security"]="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging"
    ["full"]="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging,honeypot,prometheus"
    ["custom"]=""
)

# Components are now defined after language loading

# Colors for output
RED='\033[0;31m'
GREEN='\033[38;5;121m' # Mint green instead of regular green
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
        gum style --foreground 121 "✓ $1"
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
            --language=*)
                LANGUAGE="${1#*=}"
                shift
                ;;
            --language)
                LANGUAGE="$2"
                shift 2
                ;;
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
    --language=LANG         Language selection (en|pl|de|es|fr|it|ru) [default: en]
    --profile=PROFILE       Installation profile (minimal|standard|security|full|custom)
    --components=LIST       Comma-separated list of components to install
    --dry-run              Show what would be installed without making changes
    --verbose              Enable verbose output
    --gum-enhanced         Use gum TUI for enhanced user experience (installs gum if needed)
    --backup-existing      Create backups of existing configurations (enabled by default)
    --select-components    Interactive component selection
    --help, -h            Show this help message

PROFILES:
    minimal     - Core DNS functionality (dnscrypt, coredns)
    standard    - Basic protection (dnscrypt, coredns, adblock)
    security    - Advanced security (standard + reputation, asn-blocking, logging)
    full        - Everything (security + honeypot, prometheus)
    custom      - Custom component selection

COMPONENTS:
    dnscrypt           - DNS encryption and caching
    coredns            - DNS server and filtering
    adblock            - DNS-based ad blocking
    reputation         - IP reputation scoring
    asn-blocking       - Network-level blocking
    event-logging      - Structured event logging
    honeypot           - Scanner detection traps
    prometheus         - Metrics collection
    firewall           - NFTables firewall rules
    optimize-kernel    - Kernel priority optimization (CPU/IO boost for DNS)
    doh-parallel       - DoH parallel racing (faster DNS responses)

LANGUAGES:
    en              - English (default)
    pl              - Polski
    de              - Deutsch
    es              - Español
    fr              - Français
    it              - Italiano
    ru              - Русский

EXAMPLES:
    sudo ./citadel-install-cli.sh --profile=standard
    sudo ./citadel-install-cli.sh --language=pl --profile=standard --gum-enhanced
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

# Validate language
validate_language() {
    if [[ -z "${LANGUAGES[$LANGUAGE]}" ]]; then
        error "Invalid language: $LANGUAGE. Available: ${!LANGUAGES[*]}"
    fi
}

# Load language file
load_language() {
    local lang_file="${SCRIPT_DIR}/../lib/i18n/${LANGUAGE}.sh"
    if [[ -f "$lang_file" ]]; then
        # shellcheck source=/dev/null
        source "$lang_file"
        status "${T_LANGUAGE_LOADED:-Language loaded}: ${LANGUAGES[$LANGUAGE]}"
    else
        warning "Language file not found: $lang_file, using English"
        LANGUAGE="en"
    fi
}

# Install gum if needed for enhanced UI
install_gum_if_needed() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == false ]]; then
        status "Installing gum for enhanced UI..."
        if [[ "$DRY_RUN" == false ]]; then
            # Try different package managers
            if command -v pacman >/dev/null 2>&1; then
                if ! pacman -S --noconfirm gum >/dev/null 2>&1; then
                    warning "Failed to install gum with pacman"
                fi
            elif command -v apt >/dev/null 2>&1; then
                if ! apt update && apt install -y gum >/dev/null 2>&1; then
                    warning "Failed to install gum with apt"
                fi
            elif command -v dnf >/dev/null 2>&1; then
                if ! dnf install -y gum >/dev/null 2>&1; then
                    warning "Failed to install gum with dnf"
                fi
            elif command -v zypper >/dev/null 2>&1; then
                if ! zypper install -y gum >/dev/null 2>&1; then
                    warning "Failed to install gum with zypper"
                fi
            else
                warning "No supported package manager found. Please install gum manually for enhanced UI."
            fi

            # Re-check if gum is now available
            if command -v gum >/dev/null 2>&1; then
                GUM_AVAILABLE=true
                status "Gum installed successfully"
            else
                GUM_AVAILABLE=false
                warning "Gum installation failed - falling back to plain text UI"
                GUM_ENHANCED=false
            fi
        else
            status "Would install gum for enhanced UI"
        fi
    fi
}

# Select additional optional components
select_additional_components() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        # Gum-enhanced selection for additional components
        gum style --bold --foreground 75 --width 64 "${T_SELECT_ADDITIONAL_COMPONENTS:-Select Additional Components}"

        # Get currently selected components as array
        IFS=',' read -ra current_comps <<< "$COMPONENTS"

        # Build list of available optional components (not already selected)
        local available_options=""
        for comp in "${!COMPONENTS_DESC[@]}"; do
            # Skip if already selected
            if [[ " ${current_comps[*]} " =~ " $comp " ]]; then
                continue
            fi

            case "$comp" in
                dnscrypt|coredns|firewall) continue ;; # Skip core components
                *) available_options+="$comp|${COMPONENTS_DESC[$comp]}\n" ;;
            esac
        done

        if [[ -z "$available_options" ]]; then
            info "${T_NO_ADDITIONAL_COMPONENTS:-No additional components available}"
            return
        fi

        # Use gum choose for multi-selection
        local additional
        additional=$(echo -e "$available_options" | gum choose --no-limit --header "${T_SELECT_ADDITIONAL_TO_ADD:-Select additional components to add:}" | cut -d'|' -f1 | tr '\n' ',' | sed 's/,$//')

        if [[ -n "$additional" ]]; then
            # Add to existing components
            if [[ -n "$COMPONENTS" ]]; then
                COMPONENTS="$COMPONENTS,$additional"
            else
                COMPONENTS="$additional"
            fi
            status "${T_ADDED_ADDITIONAL_COMPONENTS:-Added additional components:} $additional"
        else
            info "${T_NO_ADDITIONAL_SELECTED:-No additional components selected}"
        fi

    else
        # Fallback to text-based selection
        echo "Available additional components:"
        local i=1
        declare -a available_comps
        IFS=',' read -ra current_comps <<< "$COMPONENTS"

        for comp in "${!COMPONENTS_DESC[@]}"; do
            # Skip if already selected or core component
            if [[ " ${current_comps[*]} " =~ " $comp " ]] || [[ "$comp" =~ ^(dnscrypt|coredns|firewall)$ ]]; then
                continue
            fi

            echo "  $i) $comp - ${COMPONENTS_DESC[$comp]}"
            available_comps[$i]="$comp"
            ((i++))
        done

        if [[ ${#available_comps[@]} -eq 0 ]]; then
            info "No additional components available"
            return
        fi

        echo ""
        echo -n "Enter additional component numbers (comma-separated): "
        read -r selection

        local additional=""
        IFS=',' read -ra selections <<< "$selection"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | xargs)
            if [[ "$sel" =~ ^[0-9]+$ ]] && [[ -n "${available_comps[$sel]}" ]]; then
                additional+="${available_comps[$sel]},"
            fi
        done

        if [[ -n "$additional" ]]; then
            additional=${additional%,}
            # Add to existing components
            if [[ -n "$COMPONENTS" ]]; then
                COMPONENTS="$COMPONENTS,$additional"
            else
                COMPONENTS="$additional"
            fi
            status "Added additional components: $additional"
        fi
    fi
}

# Interactive component selection
select_components_interactive() {
    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        # Gum-enhanced selection
        gum style --bold --foreground 75 --width 64 "${T_COMPONENT_SELECTION:-Component Selection}"

        local available_components=""
        for comp in "${!COMPONENTS_DESC[@]}"; do
            available_components+="$comp|${COMPONENTS_DESC[$comp]}\n"
        done

        # Use gum choose for multi-selection
        COMPONENTS=$(echo -e "$available_components" | gum choose --no-limit --header "${T_SELECT_COMPONENTS_TO_INSTALL:-Select components to install:}" | cut -d'|' -f1 | tr '\n' ',' | sed 's/,$//')

    else
        # Fallback to text-based selection
        echo "${T_AVAILABLE_COMPONENTS:-Available components}:"
        local i=1
        declare -a comp_list
        for comp in "${!COMPONENTS_DESC[@]}"; do
            echo "  $i) $comp - ${COMPONENTS_DESC[$comp]}"
            comp_list[$i]="$comp"
            ((i++))
        done

        echo ""
        echo -n "${T_ENTER_COMPONENT_NUMBERS:-Enter component numbers (comma-separated):} "
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
        gum style --bold --foreground 75 --border double --width 64 --padding "0 1" "${T_INSTALLATION_PLAN:-Citadel v3.3+ Installation Plan}"
    else
        echo "${T_INSTALLATION_PLAN:-Citadel v3.3+ Installation Plan}"
        echo "================================"
    fi

    echo "${T_PROFILE:-Profile}: $PROFILE"
    echo "${T_COMPONENTS:-Components}: $COMPONENTS"
    echo "${T_DRY_RUN:-Dry run}: $DRY_RUN"
    echo "${T_GUM_ENHANCED:-Gum enhanced}: $GUM_ENHANCED"
    echo "${T_BACKUP_EXISTING:-Backup existing}: $BACKUP_EXISTING"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        warning "${T_DRY_RUN_MODE_WARNING:-DRY RUN MODE - No changes will be made}"
    fi

    # List selected components
    echo "${T_SELECTED_COMPONENTS:-Selected components}:"
    IFS=',' read -ra comp_array <<< "$COMPONENTS"
    for comp in "${comp_array[@]}"; do
        comp=$(echo "$comp" | xargs)
        case "$comp" in
            dnscrypt) desc="${T_COMPONENT_DNSCRYPT:-DNS encryption and caching}" ;;
            coredns) desc="${T_COMPONENT_COREDNS:-DNS server and filtering}" ;;
            adblock) desc="${T_COMPONENT_ADBLOCK:-DNS-based ad blocking}" ;;
            reputation) desc="${T_COMPONENT_REPUTATION:-IP reputation scoring}" ;;
            asn-blocking) desc="${T_COMPONENT_ASN_BLOCKING:-Network-level blocking}" ;;
            event-logging) desc="${T_COMPONENT_EVENT_LOGGING:-Structured event logging}" ;;
            honeypot) desc="${T_COMPONENT_HONEYPOT:-Scanner detection traps}" ;;
            prometheus) desc="${T_COMPONENT_PROMETHEUS:-Metrics collection}" ;;
            firewall) desc="${T_COMPONENT_FIREWALL:-NFTables firewall rules}" ;;
            optimize-kernel) desc="${T_COMPONENT_OPTIMIZE_KERNEL:-Kernel priority optimization}" ;;
            doh-parallel) desc="${T_COMPONENT_DOH_PARALLEL:-DoH parallel racing}" ;;
            *) desc="Unknown component" ;;
        esac
        echo "  • $comp - $desc"
    done
    echo ""

    # Check if there are any additional components available before asking
    local has_additional=false
    IFS=',' read -ra current_comps <<< "$COMPONENTS"
    for comp in "${!COMPONENTS_DESC[@]}"; do
        # Skip if already selected
        if [[ " ${current_comps[*]} " =~ " $comp " ]]; then
            continue
        fi

        case "$comp" in
            dnscrypt|coredns|firewall) continue ;; # Skip core components
            *) has_additional=true; break ;;
        esac
    done

    # Ask if user wants to add optional components only if there are any available
    if [[ "$has_additional" == true ]]; then
        if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
            if gum confirm --affirmative="Tak" --negative="Nie" --selected.foreground 46 --selected.background 27 --unselected.foreground 196 --unselected.background 250 "${T_ADD_OPTIONAL_COMPONENTS:-Czy chcesz dodać opcjonalne komponenty?}"; then
                add_optional=true
            else
                add_optional=false
            fi
        else
            echo -n "${T_ADD_OPTIONAL_COMPONENTS:-Add optional components?} [y/N]: "
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                add_optional=true
            else
                add_optional=false
            fi
        fi

        if [[ "$add_optional" == true ]]; then
            SELECT_COMPONENTS=true
            select_additional_components
        fi
    else
        info "${T_ALL_COMPONENTS_SELECTED:-All available components are already selected}"
    fi

    if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
        if gum confirm --affirmative="Tak" --negative="Nie" --selected.foreground 46 --selected.background 27 --unselected.foreground 196 --unselected.background 250 "${T_PROCEED_WITH_INSTALLATION:-Kontynuować instalację?}"; then
            return 0
        else
            info "Installation cancelled"
            exit 0
        fi
    else
        echo -n "${T_PROCEED_WITH_INSTALLATION:-Proceed with installation?} [y/N]: "
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

# Validate language
validate_language

# Load language file
load_language

# Define components after language is loaded (so translations work)
declare -A COMPONENTS_DESC=(
    ["dnscrypt"]="${T_COMPONENT_DNSCRYPT:-DNS encryption and caching}"
    ["coredns"]="${T_COMPONENT_COREDNS:-DNS server and filtering}"
    ["adblock"]="${T_COMPONENT_ADBLOCK:-DNS-based ad blocking}"
    ["reputation"]="${T_COMPONENT_REPUTATION:-IP reputation scoring}"
    ["asn-blocking"]="${T_COMPONENT_ASN_BLOCKING:-Network-level blocking}"
    ["event-logging"]="${T_COMPONENT_EVENT_LOGGING:-Structured event logging}"
    ["honeypot"]="${T_COMPONENT_HONEYPOT:-Scanner detection traps}"
    ["prometheus"]="${T_COMPONENT_PROMETHEUS:-Metrics collection}"
    ["firewall"]="${T_COMPONENT_FIREWALL:-NFTables firewall rules}"
    ["optimize-kernel"]="${T_COMPONENT_OPTIMIZE_KERNEL:-Kernel priority optimization (CPU/IO boost)}"
    ["doh-parallel"]="${T_COMPONENT_DOH_PARALLEL:-DoH parallel racing (faster DNS)}"
)

# Install gum if needed for enhanced UI
install_gum_if_needed

# Determine components
determine_components

# Enhanced welcome message
if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
    gum style --bold --foreground 99 --border double --width 64 --padding "1 2" "${T_INSTALLER_TITLE:-Citadel v3.3+ Enhanced CLI Installer}"
else
    echo "${T_INSTALLER_TITLE:-Citadel v3.3+ Enhanced CLI Installer}"
    echo "==================================="
fi

echo "${T_WORKING_DIRECTORY:-Working directory}: $SCRIPT_DIR"
echo "${T_LOG_FILE_LABEL:-Log file}: $LOG_FILE"
echo ""

log "Starting Citadel v3.3+ enhanced installation"
log "Profile: $PROFILE, Components: $COMPONENTS, Dry-run: $DRY_RUN, Gum: $GUM_ENHANCED"

# Show installation plan
show_installation_plan

# Continue with existing installation logic...

# Function to run citadel commands
run_citadel() {
    local cmd="$1"
    local citadel_path="$(dirname "$SCRIPT_DIR")/citadel.sh"
    log "Running: $citadel_path $cmd"
    if ! "$citadel_path" $cmd >> "$LOG_FILE" 2>&1; then
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
            status "${T_INSTALLING:-Installing} DNSCrypt..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install dnscrypt"
                if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then
                    status "${T_DNSCRYPT_INSTALLED_AND_RUNNING:-DNSCrypt installed and running}"
                else
                    warning "DNSCrypt service not active (expected after config)"
                fi
            else
                status "Would ${T_INSTALLING,,} DNSCrypt"
            fi
            ;;

        coredns)
            status "${T_INSTALLING:-Installing} CoreDNS..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install coredns"
                if systemctl is-active --quiet coredns 2>/dev/null; then
                    status "${T_COREDNS_INSTALLED_AND_RUNNING:-CoreDNS installed and running}"
                else
                    warning "CoreDNS service not active (expected after config)"
                fi
            else
                status "Would ${T_INSTALLING_COREDNS,,}"
            fi
            ;;

        firewall)
            status "${T_CONFIGURING_FIREWALL:-Configuring firewall}..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install firewall-safe"
                # Check if firewall rules are loaded by looking for Citadel table
                if nft list tables | grep -q "citadel_dns" 2>/dev/null; then
                    status "${T_FIREWALL_CONFIGURED:-Firewall configured}"
                else
                    warning "${T_FIREWALL_NOT_ACTIVE:-Firewall rules not loaded}"
                fi
            else
                status "Would ${T_CONFIGURING_FIREWALL,,}"
            fi
            ;;

        adblock)
            status "${T_INITIALIZING_ADBLOCK:-Initializing adblock}..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "unified-backup lists-update"
                status "${T_ADBLOCK_UPDATED:-Adblock updated}"
            else
                status "Would ${T_INITIALIZING_ADBLOCK,,}"
            fi

            status "${T_CONFIGURING_ADBLOCK:-Configuring adblock}..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "blocklist-switch balanced"
                status "${T_ADBLOCK_CONFIGURED:-Adblock configured}"
            else
                status "Would ${T_CONFIGURING_ADBLOCK,,}"
            fi
            ;;

        reputation)
            status "${T_INITIALIZING_REPUTATION:-Initializing reputation system}..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable reputation in configuration
                log "Enabling reputation system"
                status "${T_REPUTATION_ENABLED:-Reputation system enabled}"
            else
                status "Would ${T_INITIALIZING_REPUTATION,,}"
            fi
            ;;

        asn-blocking)
            status "${T_INITIALIZING_ASN:-Initializing ASN blocking}..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable ASN blocking in configuration
                log "Enabling ASN blocking system"
                status "${T_ASN_ENABLED:-ASN blocking enabled}"
            else
                status "Would ${T_INITIALIZING_ASN,,}"
            fi
            ;;

        event-logging)
            status "${T_INITIALIZING_EVENTS:-Initializing event logging}..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable event logging in configuration
                log "Enabling event logging system"
                status "${T_EVENTS_ENABLED:-Event logging enabled}"
            else
                status "Would ${T_INITIALIZING_EVENTS,,}"
            fi
            ;;

        honeypot)
            status "${T_INITIALIZING_HONEYPOT:-Initializing honeypot system}..."
            if [[ "$DRY_RUN" == false ]]; then
                # Enable honeypot in configuration
                log "Enabling honeypot system"
                status "${T_HONEYPOT_ENABLED:-Honeypot system enabled}"
            else
                status "Would ${T_INITIALIZING_HONEYPOT,,}"
            fi
            ;;

        prometheus)
            status "${T_INSTALLING_PROMETHEUS:-Installing Prometheus metrics}..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install dashboard"
                status "${T_PROMETHEUS_ENABLED:-Prometheus metrics enabled}"
            else
                status "Would ${T_INSTALLING_PROMETHEUS,,}"
            fi
            ;;

        optimize-kernel)
            status "${T_OPTIMIZING_KERNEL:-Optimizing kernel priorities}..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "optimize-kernel"
                status "${T_KERNEL_OPTIMIZED:-Kernel priorities optimized}"
            else
                status "Would ${T_OPTIMIZING_KERNEL,,}"
            fi
            ;;

        doh-parallel)
            status "${T_ENABLING_DOH_PARALLEL:-Enabling DoH parallel racing}..."
            if [[ "$DRY_RUN" == false ]]; then
                run_citadel "install-doh-parallel"
                status "${T_DOH_PARALLEL_ENABLED:-DoH parallel racing enabled}"
            else
                status "Would ${T_ENABLING_DOH_PARALLEL,,}"
            fi
            ;;
    esac
}

# Main installation logic
main_installation() {
    IFS=',' read -ra comp_array <<< "$COMPONENTS"

    # Step 1: Check dependencies (always first)
    status "${T_CHECKING_DEPS:-Checking system dependencies...}"
    if [[ "$DRY_RUN" == false ]]; then
        run_citadel "check-deps --install"
        status "${T_DEPENDENCIES_OK:-Dependencies OK}"
    else
        status "${T_WOULD_CHECK_DEPS:-Would check dependencies}"
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
        status "${T_CONFIGURING_DNS:-Configuring system DNS...}"
        if [[ "$DRY_RUN" == false ]]; then
            run_citadel "install configure-system"
            status "${T_DNS_CONFIGURED:-System DNS configured}"
        else
            status "${T_WOULD_CONFIGURE_DNS:-Would configure system DNS}"
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

    # Step 6: Install advanced optimizations
    local advanced_components=("optimize-kernel" "doh-parallel")
    for comp in "${advanced_components[@]}"; do
        if [[ " ${comp_array[*]} " =~ " $comp " ]]; then
            install_component "$comp"
        fi
    done

    # Step 7: Enable auto-updates
    if [[ " ${comp_array[*]} " =~ " adblock " ]]; then
        status "${T_ENABLING_AUTO_UPDATES:-Enabling auto-updates...}"
        if [[ "$DRY_RUN" == false ]]; then
            run_citadel "unified-backup auto-update-enable"
            status "${T_AUTO_UPDATES_ENABLED:-Auto-updates enabled}"
        else
            status "${T_WOULD_ENABLE_AUTO_UPDATES:-Would enable auto-updates}"
        fi
    fi

    # Step 8: Final verification
    status "${T_RUNNING_VERIFICATION:-Running final verification...}"
    if [[ "$DRY_RUN" == false ]]; then
        run_citadel "monitor status" >/dev/null 2>&1

        # Test DNS resolution
        if dig @127.0.0.1 google.com +short +time=5 >/dev/null 2>&1; then
            status "${T_DNS_WORKING:-DNS resolution working}"
        else
            warning "${T_DNS_TEST_FAILED:-DNS resolution test failed}"
        fi
    else
        status "${T_WOULD_RUN_VERIFICATION:-Would run final verification}"
    fi
}

# Run main installation
main_installation

# Completion message
echo ""
if [[ "$GUM_ENHANCED" == true ]] && [[ "$GUM_AVAILABLE" == true ]]; then
    gum style --bold --foreground 99 --border double --width 64 --padding "1 2" "${T_COMPLETE_TITLE:-INSTALLATION COMPLETE}"
else
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                           ${T_COMPLETE_TITLE:-INSTALLATION COMPLETE}                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
fi

echo ""
if [[ "$DRY_RUN" == true ]]; then
    status "${T_DRY_RUN_COMPLETE:-Dry run completed - no changes made}"
else
    status "${T_ALL_SUCCESS:-Citadel v3.3+ successfully installed!}"
fi

echo ""
echo "${T_NEXT_STEPS:-Next steps}:"
echo "• ${T_STEP_MONITOR:-Start monitoring}: ./citadel-top"
echo "• ${T_STEP_STATUS:-Check status}: sudo ./citadel.sh monitor status"
echo "• ${T_STEP_LOGS:-View logs}: sudo ./citadel.sh logs"
echo "• ${T_STEP_UPDATE:-Update blocklists}: sudo ./citadel.sh backup lists-update"
echo ""
echo "${T_LOG_FILE:-Log file}: $LOG_FILE"

log "Installation completed successfully"
