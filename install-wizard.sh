#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADELA - INTERACTIVE INSTALLER FOR BEGINNERS                        ║
# ║  Guided installation with gum TUI - no CLI flags needed!                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/citadel-interactive-install-$(date +%Y%m%d-%H%M%S).log"

# Load Citadel core library for logging functions
if [[ -f "lib/cytadela-core.sh" ]]; then
    # Set required environment variables before loading core library
    export CYTADELA_LIB="${SCRIPT_DIR}/lib"
    export CYTADELA_MODULES="${SCRIPT_DIR}/modules"
    export CYTADELA_STATE_DIR="/var/run/citadel"
    export CYTADELA_MANIFEST="${CYTADELA_LIB}/manifest.sha256"

    source "lib/cytadela-core.sh"
    
    # Load new i18n engine if available (after core library)
    if [[ -f "modules/i18n-engine/i18n-engine.sh" ]]; then
        source "modules/i18n-engine/i18n-engine.sh"
        i18n_engine_init
    fi
else
    echo "ERROR: Citadel core library not found. Please run from Citadel root directory."
    exit 1
fi

# Load frame UI utilities
if [[ -f "lib/frame-ui.sh" ]]; then
    source "lib/frame-ui.sh"
else
    echo "ERROR: Frame UI library not found. Please run from Citadel root directory."
    exit 1
fi

# Colors
RED='\033[0;31m'
GREEN='\033[38;5;121m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Auto-install gum if not available
install_gum_if_needed() {
    if ! command -v gum >/dev/null 2>&1; then
        echo -e "${YELLOW}Gum not found - installing for enhanced UI...${NC}"
        log "Installing gum for interactive installer"
        
        # Try different package managers with proper repository setup
        if command -v pacman >/dev/null 2>&1; then
            echo -e "${BLUE}Using pacman (Arch/Manjaro)...${NC}"
            if sudo pacman -S --needed --noconfirm gum >/dev/null 2>&1; then
                echo -e "${GREEN}Gum installed successfully${NC}"
                return 0
            fi
        elif command -v apt >/dev/null 2>&1; then
            echo -e "${BLUE}Setting up Charm repository for Debian/Ubuntu...${NC}"
            # Add Charm repository for Debian/Ubuntu
            if sudo mkdir -p /etc/apt/keyrings && \
               curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \
               echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list && \
               sudo apt update >/dev/null 2>&1 && \
               sudo apt install -y gum >/dev/null 2>&1; then
                echo -e "${GREEN}Gum installed successfully${NC}"
                return 0
            fi
        elif command -v dnf >/dev/null 2>&1; then
            echo -e "${BLUE}Using dnf (Fedora/RHEL)...${NC}"
            if sudo dnf install -y gum >/dev/null 2>&1; then
                echo -e "${GREEN}Gum installed successfully${NC}"
                return 0
            fi
        elif command -v zypper >/dev/null 2>&1; then
            echo -e "${BLUE}Setting up Charm repository for openSUSE...${NC}"
            # Add Charm repository for openSUSE
            if sudo zypper addrepo -f https://repo.charm.sh/rpm/charm.repo >/dev/null 2>&1 && \
               sudo zypper refresh >/dev/null 2>&1 && \
               sudo zypper install -y gum >/dev/null 2>&1; then
                echo -e "${GREEN}Gum installed successfully${NC}"
                return 0
            fi
        fi
        
        # If we get here, installation failed
        echo -e "${RED}Failed to install gum automatically${NC}"
        echo -e "${YELLOW}Please install gum manually:${NC}"
        echo -e "${YELLOW}   Arch/Manjaro: sudo pacman -S gum${NC}"
        echo -e "${YELLOW}   Debian/Ubuntu: curl + repository setup (see: https://github.com/charmbracelet/gum)${NC}"
        echo -e "${YELLOW}   Fedora/RHEL: sudo dnf install gum${NC}"
        echo -e "${YELLOW}   openSUSE: sudo zypper addrepo https://repo.charm.sh/rpm/charm.repo && sudo zypper install gum${NC}"
        echo ""
        echo -e "${BLUE}Alternative: Use CLI installer instead:${NC}"
        echo -e "${BLUE}   sudo ./scripts/citadel-install-cli.sh --help${NC}"
        exit 1
    fi
}

# Check if gum is available and install if needed
install_gum_if_needed

# Load frame UI utilities
source "${SCRIPT_DIR}/lib/frame-ui.sh"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

# Enhanced status output
status() {
    echo "✓ $1"
    # gum style --foreground 121 "✓ $1"
}

error() {
    echo "✗ $1"
    # gum style --foreground 196 "✗ $1"
    log "ERROR: $1"
    exit 1
}

warning() {
    echo "⚠ $1"
    # gum style --foreground 214 "⚠ $1"
    log "WARNING: $1"
}

info() {
    echo "$1"
    # gum style --foreground 39 "$1"
}

# Load language file
load_language() {
    # Try new i18n engine first (if available)
    if command -v i18n_engine_load >/dev/null 2>&1; then
        log_debug "Using new i18n engine for install-wizard module"
        # Set language in i18n engine
        if command -v i18n_engine_set_language >/dev/null 2>&1; then
            i18n_engine_set_language "$LANGUAGE" 2>/dev/null || true
        fi
        i18n_engine_load "install-wizard" 2>/dev/null || {
            log_debug "i18n engine load failed, using fallback"
            _load_english_fallback
        }
        return 0
    fi
    
    # Fall back to legacy translations (English only)
    log_debug "Using legacy translations (English fallback)"
        # English translations
        T_CITADEL_ALREADY_INSTALLED="Citadel is already installed"
        T_REINSTALL_WARNING="Reinstallation will remove existing configuration and install the new version"
        T_UNINSTALL_WARNING="Uninstallation will remove Citadel and restore original system settings"
        T_CHOOSE_ACTION="Choose action:"
        T_REINSTALL_CITADEL="Reinstall Citadel (recommended)"
        T_UNINSTALL_CITADEL="Uninstall Citadel"
        T_CANCEL_INSTALLATION="Cancel installation"
        T_UNINSTALLING_EXISTING="Uninstalling existing Citadel installation..."
        T_UNINSTALLING_CITADEL="Uninstalling Citadel..."
        T_CITADEL_UNINSTALLED="Citadel has been uninstalled"
        
        # Missing translations for final confirmation
        T_READY_TO_INSTALL="Ready to install Citadel?"
        T_YES_INSTALL_NOW="Yes, install now"
        T_SHOW_DRY_RUN="Show preview (dry-run)"
        T_NO_CANCEL_INSTALLATION="No, cancel installation"
        
        # Dry-run specific translations
        T_RUNNING_DRY_RUN="Running dry-run preview..."
        T_PROCEED_AFTER_DRY_RUN="Would you like to proceed with the actual installation?"
        T_DRY_RUN_FAILED="Dry-run failed"
        T_PROFILE_MINIMAL="Minimal - Core DNS only (dnscrypt, coredns)"
        T_PROFILE_STANDARD="Standard - Basic protection (minimal + adblock)"
        T_PROFILE_SECURITY="Security - Advanced (standard + reputation, asn-blocking, logging)"
        T_PROFILE_FULL="Full - Everything (security + honeypot, prometheus)"
        
        # Dry-run translations
        T_DRY_RUN_AVAILABLE="Tip: Use --dry-run to see what would be installed without making changes"
        T_DRY_RUN_TITLE="DRY RUN - Preview of Installation"
        T_DRY_RUN_SUMMARY="This is a DRY RUN - nothing will be installed.

The following configuration would be applied:"
        T_DRY_RUN_COMMANDS="Commands that would be executed:"
        T_DRY_RUN_WARNING="This is a preview only. No changes will be made to your system."
        T_DRY_RUN_INSTEAD="Show dry-run preview instead"
    
    status "Language loaded: $LANGUAGE (English fallback)"
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
    # Auto-detect from system locale
    local sys_lang="${LANG:-en}"
    case "$sys_lang" in
        pl*) LANGUAGE="pl" ;;
        de*) LANGUAGE="de" ;;
        es*) LANGUAGE="es" ;;
        fr*) LANGUAGE="fr" ;;
        it*) LANGUAGE="it" ;;
        ru*) LANGUAGE="ru" ;;
        *)   LANGUAGE="en" ;;
    esac

    # Return the selected language
    echo "$LANGUAGE"
}

# Profile selection with descriptions
select_profile() {
    print_gum_section_header "${T_INSTALLATION_PROFILE:-Installation Profile}"

    local profile_desc
    profile_desc=$(gum choose \
        --header "${T_CHOOSE_PROFILE:-Choose installation profile:}" \
        --cursor.foreground "#00d7ff" \
        --selected.foreground "#00d7ff" \
        --selected.background "#003366" \
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
        --cursor.foreground "#00d7ff" \
        --selected.foreground "#00d7ff" \
        --selected.background "#003366" \
        "${T_USE_RECOMMENDED_PROFILE:-Use recommended profile} ($profile)" \
        "${T_CUSTOMIZE_COMPONENTS_MANUALLY:-Customize components manually}")

    if [[ "$customize" == "${T_CUSTOMIZE_COMPONENTS_MANUALLY:-Customize components manually}" ]]; then
        echo "" >&2
        echo "${T_FIREWALL_ALWAYS_INCLUDED:-Note: Firewall is always included for security}" >&2
        echo "" >&2

        # Interactive component selection
        local selected
        selected=$(gum choose --no-limit \
            --header "${T_SELECT_COMPONENTS_TO_INSTALL:-Select components to install (use SPACE to select/deselect):}" \
            --cursor.foreground "#00d7ff" \
            --selected.foreground "#00d7ff" \
            --selected.background "#003366" \
            "dnscrypt|${T_DNSCRYPT_DESC:-DNS encryption and caching}" \
            "coredns|${T_COREDNS_DESC:-DNS server and filtering}" \
            "adblock|${T_ADBLOCK_DESC:-DNS-based ad blocking}" \
            "reputation|${T_REPUTATION_DESC:-IP reputation scoring}" \
            "asn-blocking|${T_ASN_BLOCKING_DESC:-Network-level blocking}" \
            "event-logging|${T_EVENT_LOGGING_DESC:-Structured event logging}" \
            "honeypot|${T_HONEYPOT_DESC:-Scanner detection traps}" \
            "prometheus|${T_PROMETHEUS_DESC:-Metrics collection}" \
            "optimize-kernel|${T_OPTIMIZE_KERNEL_DESC:-Kernel priority optimization (CPU/IO boost)}" \
            "doh-parallel|${T_DOH_PARALLEL_DESC:-DoH parallel racing (faster DNS)}" \
            | cut -d"|" -f1 | paste -sd, -)

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
        --cursor.foreground "#00d7ff" \
        --selected.foreground "#00d7ff" \
        --selected.background "#003366" \
        "${T_YES_CREATE_BACKUPS:-Yes, create backups}" \
        "${T_NO_DONT_CREATE_BACKUPS:-No, do not create backups}")

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
            --cursor.foreground "#00d7ff" \
            --selected.foreground "#00d7ff" \
            --selected.background "#003366" \
            "${T_YES_INSTALL_NOW:-Yes, install now}" \
            "${T_SHOW_DRY_RUN:-Show preview (dry-run)}" \
            "${T_NO_CANCEL_INSTALLATION:-No, cancel installation}")

        if [[ "$confirm" == "${T_SHOW_DRY_RUN:-Show preview (dry-run)}" ]]; then
            echo "dry-run"
        elif [[ "$confirm" != "${T_YES_INSTALL_NOW:-Yes, install now}" ]]; then
            gum style --foreground 196 "${T_INSTALLATION_CANCELLED:-Installation cancelled by user}"
            exit 0
        else
            echo "install"
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

        # Always auto-fix ports in wizard mode (user can cancel if they want)
        cmd="$cmd --auto-fix-ports"

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

    # Run dry-run preview
    run_dry_run() {
        local language="$1"
        local profile="$2"
        local components="$3"
        local backup="$4"

        print_gum_section_header "${T_DRY_RUN_TITLE:-DRY RUN - Preview of Installation}"

        # Build the CLI command with dry-run flag
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

        # Add dry-run flag
        cmd="$cmd --dry-run"

        status "${T_RUNNING_DRY_RUN:-Running dry-run preview...}"
        info "Command: $cmd"

        echo ""
        print_gum_info_box "${T_DRY_RUN_WARNING:-This is a preview only. No changes will be made to your system.}"
        echo ""

        # Execute the dry-run
        if eval "sudo $cmd"; then
            echo ""
            print_gum_success_box "${T_DRY_RUN_COMPLETE:-Dry-run completed successfully!}"
            echo ""
            
            # Ask if user wants to proceed with actual installation
            local proceed
            proceed=$(gum choose \
                --header "${T_PROCEED_AFTER_DRY_RUN:-Would you like to proceed with the actual installation?}" \
                --cursor.foreground "#00d7ff" \
                --selected.foreground "#00d7ff" \
                --selected.background "#003366" \
                "${T_YES_INSTALL_NOW:-Yes, install now}" \
                "${T_NO_CANCEL_INSTALLATION:-No, cancel installation}")
            
            if [[ "$proceed" == "${T_YES_INSTALL_NOW:-Yes, install now}" ]]; then
                run_installation "$language" "$profile" "$components" "$backup"
            else
                info "${T_INSTALLATION_CANCELLED:-Installation cancelled by user}"
                exit 0
            fi
        else
            error "${T_DRY_RUN_FAILED:-Dry-run failed}. Check the log file: $LOG_FILE"
        fi
    }

# Show completion message
show_completion() {
    echo ""
    print_gum_success_box "${T_INSTALLATION_COMPLETE:-Installation Complete!}

${T_CITADEL_INSTALLED_SUCCESSFULLY:-Citadel has been successfully installed!}"

    echo ""
    echo "${T_USEFUL_COMMANDS:-Useful Commands}:"
    echo "  ${T_CMD_SHOW_HELP:-Show help}: sudo ./citadel.sh help"
    echo "  ${T_CMD_CHECK_STATUS:-Check status}: sudo ./citadel.sh monitor status"
    echo "  ${T_CMD_VIEW_LOGS:-View logs}: sudo ./citadel.sh logs"
    echo "  ${T_CMD_UPDATE_BLOCKLISTS:-Update blocklists}: sudo ./citadel.sh backup lists-update"
    echo "  ${T_CMD_EMERGENCY_RESTORE:-Emergency internet restore}: sudo ./citadel.sh emergency restore"
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

    # Load language translations
    load_language

    # Check if Citadel is already installed
    local already_installed=$(check_existing_installation)
    
    if [[ "$already_installed" == "true" ]]; then
        print_gum_warning_box "${T_CITADEL_ALREADY_INSTALLED:-Citadel is already installed}
        
${T_REINSTALL_WARNING:-Reinstallation will remove existing configuration and install the new version}
${T_UNINSTALL_WARNING:-Uninstallation will remove Citadel and restore original system settings}"
        
        local action
        action=$(gum choose \
            --header "${T_CHOOSE_ACTION:-Choose action:}" \
            --cursor.foreground "#00d7ff" \
            --selected.foreground "#00d7ff" \
            --selected.background "#003366" \
            "${T_REINSTALL_CITADEL:-Reinstall Citadel (recommended)}" \
            "${T_UNINSTALL_CITADEL:-Uninstall Citadel}" \
            "${T_CANCEL_INSTALLATION:-Cancel installation}")
        
        case "$action" in
            "${T_REINSTALL_CITADEL:-Reinstall Citadel (recommended)}")
                status "${T_UNINSTALLING_EXISTING:-Uninstalling existing Citadel installation...}"
                if [[ -f "./citadel.sh" ]]; then
                    sudo ./citadel.sh uninstall --yes
                elif [[ -f "./modules/uninstall.sh" ]]; then
                    # Fallback to direct module call
                    source ./modules/uninstall.sh
                    citadel_uninstall
                fi
                # FIX: Add cleanup after uninstall to prevent race condition
                sleep 2
                systemctl stop dnscrypt-proxy coredns 2>/dev/null || true
                rm -rf /etc/coredns /etc/dnscrypt-proxy 2>/dev/null || true
                nft delete table inet citadel_dns 2>/dev/null || true
                info "Cleanup completed, proceeding with fresh installation..."
                ;;
            "${T_UNINSTALL_CITADEL:-Uninstall Citadel}")
                status "${T_UNINSTALLING_CITADEL:-Uninstalling Citadel...}"
                if [[ -f "./citadel.sh" ]]; then
                    sudo ./citadel.sh uninstall --yes
                elif [[ -f "./modules/uninstall.sh" ]]; then
                    # Fallback to direct module call
                    source ./modules/uninstall.sh
                    citadel_uninstall
                fi
                echo ""
                echo "${T_CITADEL_UNINSTALLED:-Citadel has been uninstalled}"
                exit 0
                ;;
            "${T_CANCEL_INSTALLATION:-Cancel installation}")
                info "${T_INSTALLATION_CANCELLED:-Installation cancelled by user}"
                exit 0
                ;;
        esac
    fi

    # Continue with normal installation flow

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

    # Final confirmation - get user choice
    local user_choice
    user_choice=$(confirm_installation "$LANGUAGE" "$PROFILE" "$COMPONENTS" "$BACKUP")

    # Handle user choice
    if [[ "$user_choice" == "dry-run" ]]; then
        run_dry_run "$LANGUAGE" "$PROFILE" "$COMPONENTS" "$BACKUP"
    else
        run_installation "$LANGUAGE" "$PROFILE" "$COMPONENTS" "$BACKUP"
    fi

    log "Interactive installation completed successfully"
}

# Check if Citadel is already installed
# PRIORITY: marker file is the MOST RELIABLE indicator
check_existing_installation() {
    local installed=false
    
    # FIRST: Check for Citadel marker file (MOST RELIABLE)
    if [[ -f "/var/lib/cytadela/.installed" ]]; then
        installed=true
        log "Citadel detected via marker file"
        echo "$installed"
        return 0
    fi
    
    # SECOND: Check for alternative marker locations
    if [[ -f "/opt/cytadela/.installed" ]] || [[ -f "/etc/cytadela/VERSION" ]]; then
        installed=true
        log "Citadel detected via alternative marker"
        echo "$installed"
        return 0
    fi
    
    # THIRD: Check if Citadel services are RUNNING (not just enabled)
    # This prevents false positives when services are enabled but Citadel was uninstalled
    if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null && [[ -f "/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]]; then
        # Additional check: ensure it's actually Citadel config, not stock config
        if grep -q "Citadel" /etc/dnscrypt-proxy/dnscrypt-proxy.toml 2>/dev/null || \
           grep -q "server_names.*cloudflare.*google" /etc/dnscrypt-proxy/dnscrypt-proxy.toml 2>/dev/null; then
            installed=true
            log "Citadel detected via running dnscrypt with Citadel config"
            echo "$installed"
            return 0
        fi
    fi
    
    if systemctl is-active --quiet coredns 2>/dev/null && [[ -f "/etc/coredns/Corefile" ]]; then
        # Additional check: ensure it's Citadel's Corefile
        if grep -q "Citadel\|cytadela\|combined.hosts" /etc/coredns/Corefile 2>/dev/null; then
            installed=true
            log "Citadel detected via running coredns with Citadel config"
            echo "$installed"
            return 0
        fi
    fi
    
    # FOURTH: Check for Citadel-specific nftables rules (with Citadel-specific chains)
    if nft list tables 2>/dev/null | grep -q "citadel_dns"; then
        # Verify it's actually Citadel's rules by checking for specific Citadel chains
        if nft list table inet citadel_dns 2>/dev/null | grep -q "CITADEL\|citadel"; then
            installed=true
            log "Citadel detected via nftables rules"
        fi
    fi
    
    echo "$installed"
}

# Run main function
main "$@"
