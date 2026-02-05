#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADELA - INTERACTIVE INSTALLER FOR BEGINNERS                        ║
# ║  Guided installation with gum TUI - no CLI flags needed!                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/citadel-interactive-install-$(date +%Y%m%d-%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[38;5;121m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if gum is available
if ! command -v gum >/dev/null 2>&1; then
    echo -e "${RED}❌ Gum is required for interactive installer${NC}"
    echo -e "${YELLOW}💡 Install gum first: sudo pacman -S gum (Arch) or check your distro${NC}"
    echo -e "${BLUE}🔄 Or use CLI installer: sudo ./scripts/citadel-install-cli.sh --help${NC}"
    exit 1
fi

# Load frame UI utilities
source "./lib/frame-ui.sh"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

# Enhanced status output
status() {
    gum style --foreground 121 "✓ $1"
}

error() {
    gum style --foreground 196 "✗ $1"
    log "ERROR: $1"
    exit 1
}

warning() {
    gum style --foreground 214 "⚠ $1"
    log "WARNING: $1"
}

info() {
    gum style --foreground 39 "$1"
}

# Load language file
load_language() {
    local lang_file="${SCRIPT_DIR}/lib/i18n/${LANGUAGE}.sh"
    if [[ -f "$lang_file" ]]; then
        # shellcheck source=/dev/null
        source "$lang_file"
        status "Language loaded: ${LANGUAGES[$LANGUAGE]}"
    else
        warning "Language file not found: $lang_file, using English"
        LANGUAGE="en"
    fi
}

# Welcome screen
show_welcome() {
    local welcome_text="${T_WIZARD_TITLE:-Citadel Installation Wizard}

${T_WIZARD_DESCRIPTION_LINE1:-This wizard will guide you through the Citadel}
${T_WIZARD_DESCRIPTION_LINE2:-installation process step by step.}
${T_WIZARD_DESCRIPTION_LINE3:-No technical knowledge required - we'\''ll handle everything}"

    gum style \
        --border double \
        --border-foreground 6 \
        --width 64 \
        --padding "1 2" \
        "$welcome_text"

    echo ""
    echo "${T_WIZARD_SUBTITLE:-Let's get your DNS protection set up...}"
    echo ""
}

# Language selection
select_language() {
    print_gum_section_header "${T_LANGUAGE_SELECTION:-Language Selection}"

    local lang
    lang=$(gum choose \
        --header "Select your preferred language:" \
        "en|English" \
        "pl|Polski" \
        "de|Deutsch" \
        "es|Espanol" \
        "fr|Francais" \
        "it|Italiano" \
        "ru|Русский" \
        | cut -d'|' -f1)

    if [[ -z "$lang" ]]; then
        error "Language selection is required"
    fi

    # Return only the language code, not the frame
    printf '%s' "$lang"
}

# Load language file
load_language() {
    LANGUAGE=$1
    case "$LANGUAGE" in
        en) source "./lib/i18n/uninstall/en.sh" 2>/dev/null || true ;;
        pl) source "./lib/i18n/uninstall/pl.sh" 2>/dev/null || true ;;
        de) source "./lib/i18n/uninstall/de.sh" 2>/dev/null || true ;;
        es) source "./lib/i18n/uninstall/es.sh" 2>/dev/null || true ;;
        fr) source "./lib/i18n/uninstall/fr.sh" 2>/dev/null || true ;;
        it) source "./lib/i18n/uninstall/it.sh" 2>/dev/null || true ;;
        ru) source "./lib/i18n/uninstall/ru.sh" 2>/dev/null || true ;;
        *) warning "Unknown language '$LANGUAGE', falling back to English"
           source "./lib/i18n/uninstall/en.sh" 2>/dev/null || true ;;
    esac
}

# Profile selection with descriptions
select_profile() {
    print_gum_section_header "${T_INSTALLATION_PROFILE:-Installation Profile}"

    local profile_desc
    profile_desc=$(gum choose \
        --header "${T_CHOOSE_PROFILE:-Choose installation profile:}" \
        "minimal|${T_PROFILE_MINIMAL:-Minimal - Core DNS only (dnscrypt, coredns)}" \
        "standard|${T_PROFILE_STANDARD:-Standard - Basic protection (minimal + adblock)}" \
        "security|${T_PROFILE_SECURITY:-Security - Advanced (standard + reputation, asn-blocking, logging)}" \
        "full|${T_PROFILE_FULL:-Full - Everything (security + honeypot, prometheus)}" \
        | cut -d'|' -f1)

    if [[ -z "$profile_desc" ]]; then
        error "Profile selection is required"
    fi

    echo "$profile_desc"
}

# Component customization (optional)
customize_components() {
    local profile="$1"
    local components

    # Get default components for profile
    case "$profile" in
        minimal) components="dnscrypt,coredns" ;;
        standard) components="dnscrypt,coredns,adblock" ;;
        security) components="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging" ;;
        full) components="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging,honeypot,prometheus" ;;
    esac

    print_gum_section_header "${T_COMPONENT_CUSTOMIZATION:-Component Customization}"

    local customize
    customize=$(gum choose \
        --header "${T_WANT_CUSTOMIZE_COMPONENTS:-Want to customize components?}" \
        "no|${T_USE_RECOMMENDED_PROFILE:-Use recommended profile} ($profile)" \
        "yes|${T_CUSTOMIZE_COMPONENTS_MANUALLY:-Customize components manually}")

    if [[ "$customize" == "yes" ]]; then
        echo ""
        echo "${T_FIREWALL_ALWAYS_INCLUDED:-Note: Firewall is always included for security}"
        echo ""

        # Interactive component selection
        local selected
        selected=$(gum choose --no-limit \
            --header "${T_SELECT_COMPONENTS_TO_INSTALL:-Select components to install (use SPACE to select/deselect):}" \
            "dnscrypt|${T_DNSCRYPT_DESC:-DNS encryption and caching}" \
            "coredns|${T_COREDNS_DESC:-DNS server and filtering}" \
            "adblock|${T_ADBLOCK_DESC:-DNS-based ad blocking}" \
            "reputation|${T_REPUTATION_DESC:-IP reputation scoring}" \
            "asn-blocking|${T_ASN_BLOCKING_DESC:-Network-level blocking}" \
            "event-logging|${T_EVENT_LOGGING_DESC:-Structured event logging}" \
            "honeypot|${T_HONEYPOT_DESC:-Scanner detection traps}" \
            "prometheus|${T_PROMETHEUS_DESC:-Metrics collection}" \
            | cut -d'|' -f1 | tr '\n' ',' | sed 's/,$//')

        if [[ -n "$selected" ]]; then
            components="$selected"
        fi
    fi

    echo "$components"
}

# Backup confirmation
confirm_backup() {
    print_gum_section_header "${T_BACKUP_CONFIGURATION:-Backup Configuration}"

    local backup_choice
    backup_choice=$(gum choose \
        --header "${T_CREATE_BACKUPS:-Create backups of existing configurations?}" \
        "${T_NO_DONT_CREATE_BACKUPS:-No, do not create backups}" \
        "${T_YES_CREATE_BACKUPS:-Yes, create backups}")

    if [[ "$backup_choice" == "${T_YES_CREATE_BACKUPS:-Yes, create backups}" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Installation confirmation
confirm_installation() {
    local language="$1"
    local profile="$2"
    local components="$3"
    local backup="$4"

    local summary_text="${T_INSTALLATION_SUMMARY:-Installation Summary}

${T_SUMMARY_LANGUAGE:-Language:} $language
${T_SUMMARY_PROFILE:-Profile:} $profile
${T_SUMMARY_COMPONENTS:-Components:} $components
${T_SUMMARY_BACKUP:-Backup existing:} $backup

${T_INSTALLATION_WARNING:-WARNING: Installation will modify system DNS and firewall settings}"

    print_gum_warning_box "$summary_text"

    local confirm
    confirm=$(gum choose \
        --header "${T_READY_TO_INSTALL:-Ready to install Citadel?}" \
        "yes|${T_YES_INSTALL_NOW:-Yes, install now}" \
        "no|${T_NO_CANCEL_INSTALLATION:-No, Cancel installation}")

    if [[ "$confirm" != "yes" ]]; then
        gum style --foreground 196 "${T_INSTALLATION_CANCELLED:-Installation cancelled by user}"
        exit 0
    fi
}

# Run the actual installation
run_installation() {
    local language="$1"
    local profile="$2"
    local components="$3"
    local backup="$4"

    print_gum_section_header "${T_INSTALLING_CITADEL:-Installing Citadel...}"

    # Build the CLI command
    local cmd="./scripts/citadel-install-cli.sh"
    cmd="$cmd --language=$language"
    cmd="$cmd --profile=$profile"

    # Add components if customized
    case "$profile" in
        minimal) default_comps="dnscrypt,coredns" ;;
        standard) default_comps="dnscrypt,coredns,adblock" ;;
        security) default_comps="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging" ;;
        full) default_comps="dnscrypt,coredns,adblock,reputation,asn-blocking,event-logging,honeypot,prometheus" ;;
    esac

    if [[ "$components" != "$default_comps" ]]; then
        cmd="$cmd --components=$components"
    fi

    # Add backup flag if enabled
    if [[ "$backup" == "true" ]]; then
        cmd="$cmd --backup-existing"
    fi

    # Always use gum enhanced
    cmd="$cmd --gum-enhanced"

    status "${T_RUNNING_INSTALLATION_COMMAND:-Running installation command...}"
    info "Command: $cmd"

    # Execute the installation
    if eval "sudo $cmd"; then
        show_completion
    else
        error "${T_INSTALLATION_FAILED:-Installation failed}. Check the log file: $LOG_FILE"
    fi
}

# Show completion message
show_completion() {
    echo ""
    print_gum_success_box "${T_INSTALLATION_COMPLETE:-Installation Complete!}

${T_CITADEL_INSTALLED_SUCCESSFULLY:-Citadel has been successfully installed!}"

    echo ""
    echo "${T_USEFUL_COMMANDS:-Useful Commands}:"
    echo "  Check status: sudo ./citadel.sh monitor status"
    echo "  View logs: sudo ./citadel.sh logs"
    echo "  Update blocklists: sudo ./citadel.sh backup lists-update"
    echo ""
    echo "${T_LOG_FILE_LABEL:-Log file:}: $LOG_FILE"
    echo ""
    echo "${T_THANK_YOU:-Thank you for choosing Citadel!}"
}

# Main function
main() {
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This installer must be run as root (sudo)"
    fi

    log "Starting interactive Citadel installation"

    # Language selection first
    LANGUAGE=$(select_language)
    status "Language selected: $LANGUAGE"
    log "Language: $LANGUAGE"

    # Load language file
    load_language "$LANGUAGE"

    # Welcome screen in selected language
    show_welcome

    # Profile selection
    PROFILE=$(select_profile)
    status "Profile selected: $PROFILE"
    log "Profile: $PROFILE"

    # Component customization
    COMPONENTS=$(customize_components "$PROFILE")
    status "${T_COMPONENTS_CONFIGURED:-Components configured:} $COMPONENTS"
    log "Components: $COMPONENTS"

    # Backup confirmation
    BACKUP=$(confirm_backup)
    if [[ "$BACKUP" == "true" ]]; then
        status "${T_BACKUPS_WILL_BE_CREATED:-Backups will be created}"
    else
        warning "${T_NO_BACKUPS_WILL_BE_CREATED:-No backups will be created}"
    fi
    log "Backup: $BACKUP"

    # Final confirmation
    confirm_installation "$LANGUAGE" "$PROFILE" "$COMPONENTS" "$BACKUP"

    # Run installation
    run_installation "$LANGUAGE" "$PROFILE" "$COMPONENTS" "$BACKUP"

    log "Interactive installation completed successfully"
}

# Run main function
main "$@"
