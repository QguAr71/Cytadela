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
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║            ${T_WIZARD_TITLE:-Citadel Installation Wizard}            ║"
    echo "║                                                            ║"
    echo "║  ${T_WIZARD_DESCRIPTION_LINE1:-This wizard will guide you through the Citadel}           ║"
    echo "║  ${T_WIZARD_DESCRIPTION_LINE2:-installation process step by step.}                       ║"
    echo "║  ${T_WIZARD_DESCRIPTION_LINE3:-No technical knowledge required - we'll handle everything}║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "${T_WIZARD_SUBTITLE:-Let's get your DNS protection set up...}"
    echo ""
}

# Language selection
select_language() {
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Language Selection                                        │"
    echo "└────────────────────────────────────────────────────────────┘"

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

    echo "$lang"
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
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Installation Profile                                      │"
    echo "└────────────────────────────────────────────────────────────┘"

    local profile_desc
    profile_desc=$(gum choose \
        --header "Choose installation profile:" \
        "minimal|Minimal - Core DNS only (dnscrypt, coredns)" \
        "standard|Standard - Basic protection (minimal + adblock)" \
        "security|Security - Advanced (standard + reputation, asn-blocking, logging)" \
        "full|Full - Everything (security + honeypot, prometheus)" \
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

    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Component Customization                                  │"
    echo "└────────────────────────────────────────────────────────────┘"

    local customize
    customize=$(gum choose \
        --header "Want to customize components?" \
        "no|Use recommended profile ($profile)" \
        "yes|Customize components manually")

    if [[ "$customize" == "yes" ]]; then
        echo ""
        echo "Note: Firewall is always included for security"
        echo ""

        # Interactive component selection
        local selected
        selected=$(gum choose --no-limit \
            --header "Select components to install (use SPACE to select/deselect):" \
            "dnscrypt|DNS encryption and caching" \
            "coredns|DNS server and filtering" \
            "adblock|DNS-based ad blocking" \
            "reputation|IP reputation scoring" \
            "asn-blocking|Network-level blocking" \
            "event-logging|Structured event logging" \
            "honeypot|Scanner detection traps" \
            "prometheus|Metrics collection" \
            | cut -d'|' -f1 | tr '\n' ',' | sed 's/,$//')

        if [[ -n "$selected" ]]; then
            components="$selected"
        fi
    fi

    echo "$components"
}

# Backup confirmation
confirm_backup() {
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Backup Configuration                                      │"
    echo "└────────────────────────────────────────────────────────────┘"

    local backup_choice
    backup_choice=$(gum choose \
        --header "Create backups of existing configurations?" \
        "yes|Yes, create backups (recommended)" \
        "no|No, don't create backups")

    if [[ "$backup_choice" == "yes" ]]; then
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

    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Installation Summary                                      │"
    echo "└────────────────────────────────────────────────────────────┘"

    echo "Language: $language"
    echo "Profile: $profile"
    echo "Components: $components"
    echo "Backup existing: $backup"
    echo ""

    echo "WARNING: Installation will modify system DNS and firewall settings"
    echo ""

    local confirm
    confirm=$(gum choose \
        --header "Ready to install Citadel?" \
        "yes|Yes, install now" \
        "no|Cancel installation")

    if [[ "$confirm" != "yes" ]]; then
        gum style --foreground 196 "Installation cancelled by user"
        exit 0
    fi
}

# Run the actual installation
run_installation() {
    local language="$1"
    local profile="$2"
    local components="$3"
    local backup="$4"

    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Installing Citadel...                                     │"
    echo "└────────────────────────────────────────────────────────────┘"

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

    status "Running installation command..."
    info "Command: $cmd"

    # Execute the installation
    if eval "sudo $cmd"; then
        show_completion
    else
        error "Installation failed. Check the log file: $LOG_FILE"
    fi
}

# Show completion message
show_completion() {
    echo ""
    echo "┌────────────────────────────────────────────────────────────┐"
    echo "│ Installation Complete!                                    │"
    echo "└────────────────────────────────────────────────────────────┘"

    echo ""
    echo "Citadel has been successfully installed!"
    echo ""
    echo "Useful commands:"
    echo "  Check status: sudo ./citadel.sh monitor status"
    echo "  View logs: sudo ./citadel.sh logs"
    echo "  Update blocklists: sudo ./citadel.sh backup lists-update"
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
    echo "Thank you for choosing Citadel!"
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
    status "Components configured: $COMPONENTS"
    log "Components: $COMPONENTS"

    # Backup confirmation
    BACKUP=$(confirm_backup)
    if [[ "$BACKUP" == "true" ]]; then
        status "Backups will be created"
    else
        warning "No backups will be created"
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
