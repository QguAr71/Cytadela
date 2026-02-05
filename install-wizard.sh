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

# Auto-install gum if not available
install_gum_if_needed() {
    if ! command -v gum >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 Gum not found - installing for enhanced UI...${NC}"
        log "Installing gum for interactive installer"
        
        # Try different package managers with proper repository setup
        if command -v pacman >/dev/null 2>&1; then
            echo -e "${BLUE}📦 Using pacman (Arch/Manjaro)...${NC}"
            if sudo pacman -S --needed --noconfirm gum >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Gum installed successfully${NC}"
                return 0
            fi
        elif command -v apt >/dev/null 2>&1; then
            echo -e "${BLUE}📦 Setting up Charm repository for Debian/Ubuntu...${NC}"
            # Add Charm repository for Debian/Ubuntu
            if sudo mkdir -p /etc/apt/keyrings && \
               curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \
               echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list && \
               sudo apt update >/dev/null 2>&1 && \
               sudo apt install -y gum >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Gum installed successfully${NC}"
                return 0
            fi
        elif command -v dnf >/dev/null 2>&1; then
            echo -e "${BLUE}📦 Using dnf (Fedora/RHEL)...${NC}"
            if sudo dnf install -y gum >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Gum installed successfully${NC}"
                return 0
            fi
        elif command -v zypper >/dev/null 2>&1; then
            echo -e "${BLUE}📦 Setting up Charm repository for openSUSE...${NC}"
            # Add Charm repository for openSUSE
            if sudo zypper addrepo -f https://repo.charm.sh/rpm/charm.repo >/dev/null 2>&1 && \
               sudo zypper refresh >/dev/null 2>&1 && \
               sudo zypper install -y gum >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Gum installed successfully${NC}"
                return 0
            fi
        fi
        
        # If we get here, installation failed
        echo -e "${RED}❌ Failed to install gum automatically${NC}"
        echo -e "${YELLOW}💡 Please install gum manually:${NC}"
        echo -e "${YELLOW}   Arch/Manjaro: sudo pacman -S gum${NC}"
        echo -e "${YELLOW}   Debian/Ubuntu: curl + repository setup (see: https://github.com/charmbracelet/gum)${NC}"
        echo -e "${YELLOW}   Fedora/RHEL: sudo dnf install gum${NC}"
        echo -e "${YELLOW}   openSUSE: sudo zypper addrepo https://repo.charm.sh/rpm/charm.repo && sudo zypper install gum${NC}"
        echo ""
        echo -e "${BLUE}🔄 Alternative: Use CLI installer instead:${NC}"
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
    if [[ "$LANGUAGE" == "pl" ]]; then
        # Polish translations
        T_CITADEL_ALREADY_INSTALLED="Citadel jest już zainstalowany"
        T_REINSTALL_WARNING="Przeinstalacja usunie istniejącą konfigurację i zainstaluje nową wersję"
        T_UNINSTALL_WARNING="Odinstalacja usunie Citadel i przywróci oryginalne ustawienia systemu"
        T_CHOOSE_ACTION="Wybierz działanie:"
        T_REINSTALL_CITADEL="Przeinstaluj Citadel (zalecane)"
        T_UNINSTALL_CITADEL="Odinstaluj Citadel"
        T_CANCEL_INSTALLATION="Anuluj instalację"
        T_UNINSTALLING_EXISTING="Odinstalowywanie istniejącej instalacji Citadel..."
        T_UNINSTALLING_CITADEL="Odinstalowywanie Citadel..."
        T_CITADEL_UNINSTALLED="Citadel został odinstalowany"
    elif [[ "$LANGUAGE" == "en" ]]; then
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
    elif [[ "$LANGUAGE" == "de" ]]; then
        # German translations
        T_CITADEL_ALREADY_INSTALLED="Citadel ist bereits installiert"
        T_REINSTALL_WARNING="Die Neuinstallation entfernt die bestehende Konfiguration und installiert die neue Version"
        T_UNINSTALL_WARNING="Die Deinstallation entfernt Citadel und stellt die ursprünglichen Systemeinstellungen wieder her"
        T_CHOOSE_ACTION="Aktion wählen:"
        T_REINSTALL_CITADEL="Citadel neu installieren (empfohlen)"
        T_UNINSTALL_CITADEL="Citadel deinstallieren"
        T_CANCEL_INSTALLATION="Installation abbrechen"
        T_UNINSTALLING_EXISTING="Deinstalliere bestehende Citadel-Installation..."
        T_UNINSTALLING_CITADEL="Deinstalliere Citadel..."
        T_CITADEL_UNINSTALLED="Citadel wurde deinstalliert"
    elif [[ "$LANGUAGE" == "es" ]]; then
        # Spanish translations
        T_CITADEL_ALREADY_INSTALLED="Citadel ya está instalado"
        T_REINSTALL_WARNING="La reinstalación eliminará la configuración existente e instalará la nueva versión"
        T_UNINSTALL_WARNING="La desinstalación eliminará Citadel y restaurará la configuración original del sistema"
        T_CHOOSE_ACTION="Elegir acción:"
        T_REINSTALL_CITADEL="Reinstalar Citadel (recomendado)"
        T_UNINSTALL_CITADEL="Desinstalar Citadel"
        T_CANCEL_INSTALLATION="Cancelar instalación"
        T_UNINSTALLING_EXISTING="Desinstalando instalación existente de Citadel..."
        T_UNINSTALLING_CITADEL="Desinstalando Citadel..."
        T_CITADEL_UNINSTALLED="Citadel ha sido desinstalado"
    elif [[ "$LANGUAGE" == "fr" ]]; then
        # French translations
        T_CITADEL_ALREADY_INSTALLED="Citadel est déjà installé"
        T_REINSTALL_WARNING="La réinstallation supprimera la configuration existante et installera la nouvelle version"
        T_UNINSTALL_WARNING="La désinstallation supprimera Citadel et restaurera les paramètres système originaux"
        T_CHOOSE_ACTION="Choisir l'action:"
        T_REINSTALL_CITADEL="Réinstaller Citadel (recommandé)"
        T_UNINSTALL_CITADEL="Désinstaller Citadel"
        T_CANCEL_INSTALLATION="Annuler l'installation"
        T_UNINSTALLING_EXISTING="Désinstallation de l'installation Citadel existante..."
        T_UNINSTALLING_CITADEL="Désinstallation de Citadel..."
        T_CITADEL_UNINSTALLED="Citadel a été désinstallé"
    elif [[ "$LANGUAGE" == "it" ]]; then
        # Italian translations
        T_CITADEL_ALREADY_INSTALLED="Citadel è già installato"
        T_REINSTALL_WARNING="La reinstallazione rimuoverà la configurazione esistente e installerà la nuova versione"
        T_UNINSTALL_WARNING="La disinstallazione rimuoverà Citadel e ripristinerà le impostazioni originali del sistema"
        T_CHOOSE_ACTION="Scegli azione:"
        T_REINSTALL_CITADEL="Reinstalla Citadel (consigliato)"
        T_UNINSTALL_CITADEL="Disinstalla Citadel"
        T_CANCEL_INSTALLATION="Annulla installazione"
        T_UNINSTALLING_EXISTING="Disinstallazione dell'installazione Citadel esistente..."
        T_UNINSTALLING_CITADEL="Disinstallazione di Citadel..."
        T_CITADEL_UNINSTALLED="Citadel è stato disinstallato"
    elif [[ "$LANGUAGE" == "ru" ]]; then
        # Russian translations
        T_CITADEL_ALREADY_INSTALLED="Citadel уже установлен"
        T_REINSTALL_WARNING="Переустановка удалит существующую конфигурацию и установит новую версию"
        T_UNINSTALL_WARNING="Удаление удалит Citadel и восстановит оригинальные настройки системы"
        T_CHOOSE_ACTION="Выбрать действие:"
        T_REINSTALL_CITADEL="Переустановить Citadel (рекомендуется)"
        T_UNINSTALL_CITADEL="Удалить Citadel"
        T_CANCEL_INSTALLATION="Отменить установку"
        T_UNINSTALLING_EXISTING="Удаление существующей установки Citadel..."
        T_UNINSTALLING_CITADEL="Удаление Citadel..."
        T_CITADEL_UNINSTALLED="Citadel был удален"
    else
        # Fallback to English
        warning "Unknown language '$LANGUAGE', falling back to English"
        LANGUAGE="en"
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
    fi
    status "Language loaded: $LANGUAGE"
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
    # Default to Polish without showing menu
    LANGUAGE="pl"

    # Return the selected language
    echo "$LANGUAGE"
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
        "${T_YES_INSTALL_NOW:-Yes, install now}" \
        "${T_NO_CANCEL_INSTALLATION:-No, Cancel installation}")

    if [[ "$confirm" != "${T_YES_INSTALL_NOW:-Yes, install now}" ]]; then
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
            "${T_REINSTALL_CITADEL:-Reinstall Citadel (recommended)}" \
            "${T_UNINSTALL_CITADEL:-Uninstall Citadel}" \
            "${T_CANCEL_INSTALLATION:-Cancel installation}")
        
        case "$action" in
            "${T_REINSTALL_CITADEL:-Reinstall Citadel (recommended)}")
                status "${T_UNINSTALLING_EXISTING:-Uninstalling existing Citadel installation...}"
                if [[ -f "./scripts/uninstall.sh" ]]; then
                    sudo ./scripts/uninstall.sh --yes
                fi
                ;;
            "${T_UNINSTALL_CITADEL:-Uninstall Citadel}")
                status "${T_UNINSTALLING_CITADEL:-Uninstalling Citadel...}"
                if [[ -f "./scripts/uninstall.sh" ]]; then
                    sudo ./scripts/uninstall.sh --yes
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

    # Final confirmation
    confirm_installation "$LANGUAGE" "$PROFILE" "$COMPONENTS" "$BACKUP"

    # Run installation
    run_installation "$LANGUAGE" "$PROFILE" "$COMPONENTS" "$BACKUP"

    log "Interactive installation completed successfully"
}

# Check if Citadel is already installed
check_existing_installation() {
    local installed=false
    
    # Check if Citadel services are running
    if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null || systemctl is-active --quiet coredns 2>/dev/null; then
        installed=true
    fi
    
    # Check for Citadel configuration files
    if [[ -f "/etc/coredns/coredns.toml" ]] || [[ -f "/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]]; then
        installed=true
    fi
    
    # Check for Citadel nftables rules
    if nft list tables 2>/dev/null | grep -q "citadel_dns"; then
        installed=true
    fi
    
    echo "$installed"
}

# Run main function
main "$@"
