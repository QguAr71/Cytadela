#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-WIZARD MODULE v3.1                                    ║
# ║  Interactive installer with checklist (Issue #25)                         ║
# ║  Bilingual: EN/PL                                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# LANGUAGE DETECTION AND SELECTION
# ==============================================================================

detect_language() {
    # Check $LANG environment variable
    if [[ "${LANG}" =~ ^pl ]]; then
        echo "pl"
    elif [[ "${LANG}" =~ ^de ]]; then
        echo "de"
    elif [[ "${LANG}" =~ ^es ]]; then
        echo "es"
    elif [[ "${LANG}" =~ ^it ]]; then
        echo "it"
    elif [[ "${LANG}" =~ ^fr ]]; then
        echo "fr"
    elif [[ "${LANG}" =~ ^ru ]]; then
        echo "ru"
    else
        echo "en" # Default to English
    fi
}

select_language() {
    local lang="${1:-}"

    # Valid languages
    local valid_langs=("en" "pl" "de" "es" "it" "fr" "ru")

    # If language specified via parameter, validate and use it
    if [[ -n "$lang" ]]; then
        for valid in "${valid_langs[@]}"; do
            if [[ "$lang" == "$valid" ]]; then
                echo "$lang"
                return 0
            fi
        done
    fi

    # Auto-detect from $LANG
    local detected
    detected=$(detect_language)

    # Ask user to confirm or change
    if command -v whiptail &>/dev/null; then
        local choice
        choice=$(whiptail --title "Language / Język / Sprache / Idioma / Lingua / Langue / Язык" \
            --menu "Select language / Wybierz język / Sprache wählen / Seleccionar idioma / Seleziona lingua / Sélectionner la langue / Выберите язык:" 20 78 7 \
            "en" "🇬🇧 English" \
            "pl" "🇵🇱 Polski" \
            "de" "🇩🇪 Deutsch" \
            "es" "🇪🇸 Español" \
            "it" "🇮🇹 Italiano" \
            "fr" "🇫🇷 Français" \
            "ru" "🇷🇺 Русский" \
            3>&1 1>&2 2>&3)

        if [[ -n "$choice" ]]; then
            echo "$choice"
        else
            echo "$detected"
        fi
    else
        echo "$detected"
    fi
}

# Function to safely install dependencies with fallback
install_dep() {
    local pkg_name="$1"
    local display_name="$2"
    
    log_info "Installing $display_name ($pkg_name)..."
    
    # 1. First attempt (silent)
    if sudo pacman -S --noconfirm --needed "$pkg_name" &>/dev/null; then
        log_success "$display_name installed"
        return 0
    fi
    
    # 2. Fallback: refresh databases
    log_warning "Download failed, refreshing databases..."
    sudo pacman -Sy --noconfirm &>/dev/null || true
    
    # 3. Second attempt (show output to see error)
    if sudo pacman -S --noconfirm --needed "$pkg_name"; then
        log_success "$display_name installed after sync"
        return 0
    else
        log_warning "Failed to install $display_name (skipped)"
        return 1
    fi
}

install_wizard() {
    # Load i18n for install-wizard module
    load_i18n_module "install-wizard"

    # === SAFETY FIRST: Backup system DNS state BEFORE any changes ===
    local SYSTEM_BACKUP_DIR="${CYTADELA_STATE_DIR}/backups"
    mkdir -p "$SYSTEM_BACKUP_DIR"
    
    # Purple frame for section header
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}🛡️  SAFETY BACKUP${NC}" $((60 - 16)) ""
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"
    log_info "Creating backup of system DNS configuration..."
    
    # Backup resolv.conf (the critical file for internet connectivity)
    if [[ -f /etc/resolv.conf ]]; then
        cp /etc/resolv.conf "${SYSTEM_BACKUP_DIR}/resolv.conf.pre-citadel"
        log_success "Backed up /etc/resolv.conf"
        
        # Show current DNS for user awareness
        local current_dns
        current_dns=$(grep "^nameserver" /etc/resolv.conf | head -1 | awk '{print $2}')
        log_info "Current DNS server: ${current_dns:-unknown}"
    else
        log_warning "/etc/resolv.conf not found - system may not be using traditional DNS"
    fi
    
    # Backup systemd-resolved state
    local resolved_state="disabled"
    if systemctl is-enabled systemd-resolved &>/dev/null; then
        resolved_state="enabled"
    fi
    echo "$resolved_state" > "${SYSTEM_BACKUP_DIR}/systemd-resolved.state"
    log_success "Backed up systemd-resolved state: $resolved_state"
    
    # Backup NetworkManager DNS config if exists
    if [[ -f /etc/NetworkManager/NetworkManager.conf ]]; then
        cp /etc/NetworkManager/NetworkManager.conf "${SYSTEM_BACKUP_DIR}/NetworkManager.conf.pre-citadel"
        log_success "Backed up NetworkManager.conf"
    fi
    
    # Create restore instructions
    cat > "${SYSTEM_BACKUP_DIR}/RESTORE-INSTRUCTIONS.txt" <<'EOF'
================================================================================
CITADEL SYSTEM BACKUP - RESTORE INSTRUCTIONS
================================================================================

If you need to restore internet connectivity after failed installation:

OPTION 1: Use Citadel restore command (if available):
  sudo ./citadel.sh restore-system

OPTION 2: Manual restore:
  # Restore DNS configuration
  sudo cp resolv.conf.pre-citadel /etc/resolv.conf
  
  # Restore systemd-resolved (if was enabled)
  sudo systemctl unmask systemd-resolved
  sudo systemctl enable systemd-resolved  # only if it was enabled before
  sudo systemctl restart systemd-resolved
  
  # Restore NetworkManager (if was using it)
  sudo systemctl restart NetworkManager

OPTION 3: Emergency DNS (quick fix):
  echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
  echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf

================================================================================
Backup created at: TIMESTAMP
System: HOSTNAME
================================================================================
EOF
    sed -i "s/TIMESTAMP/$(date -Iseconds)/" "${SYSTEM_BACKUP_DIR}/RESTORE-INSTRUCTIONS.txt"
    sed -i "s/HOSTNAME/$(hostname)/" "${SYSTEM_BACKUP_DIR}/RESTORE-INSTRUCTIONS.txt"
    
    log_success "System backup complete"
    log_info "Backup location: $SYSTEM_BACKUP_DIR"
    echo ""
    
    # Emergency frame - using exact print_menu_line pattern from help.sh
    print_frame_line() {
        local text="$1"
        local total_width=60
        local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
        local visible_len=${#visible_text}
        local padding=$((total_width - visible_len))
        printf "${RED}║${NC} %b%*s ${RED}║${NC}\n" "$text" "$padding" ""
    }
    
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    print_frame_line "${BOLD}EMERGENCY RECOVERY:${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
    print_frame_line "If installation fails:"
    print_frame_line "  ${YELLOW}sudo ./citadel.sh emergency-network-restore${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Pause so user can see the message
    sleep 2

    # Check if Citadel is already installed - offer management options
    if [[ -d /etc/coredns ]] || [[ -f /etc/systemd/system/coredns.service ]] || [[ -d /opt/cytadela ]]; then
        # Already installed - show management menu
        export NEWT_COLORS='
root=,black
window=brightmagenta,black
border=brightgreen,black
textbox=brightmagenta,black
button=black,brightgreen
actbutton=black,brightmagenta
checkbox=brightgreen,black
actcheckbox=black,brightgreen
'
        local choice
        choice=$(whiptail --title "${T_WIZARD_SETUP_TITLE:-Citadel++ Setup}" \
            --menu "${T_WIZARD_INSTALLED_MSG:-Citadel is already installed. Choose action:}" 15 60 4 \
            "reinstall" "${T_WIZARD_REINSTALL:-Reinstall with backup}" \
            "uninstall" "${T_WIZARD_UNINSTALL:-Remove Citadel}" \
            "modify" "${T_WIZARD_MODIFY:-Modify components (coming in v3.2)}" \
            "cancel" "${T_WIZARD_CANCEL:-Exit}" 3>&1 1>&2 2>&3)
        
        case "$choice" in
            reinstall)
                if declare -f config_backup_create >/dev/null 2>&1; then
                    config_backup_create
                fi
                if declare -f citadel_uninstall >/dev/null 2>&1; then
                    citadel_uninstall
                else
                    load_module "uninstall"
                    citadel_uninstall
                fi
                ;;
            uninstall)
                if declare -f citadel_uninstall >/dev/null 2>&1; then
                    citadel_uninstall
                else
                    load_module "uninstall"
                    citadel_uninstall
                fi
                return 0
                ;;
            modify)
                whiptail --msgbox "${T_WIZARD_MODIFY_MSG:-Component modification coming in v3.2}" 10 40
                return 0
                ;;
            *)
                return 0
                ;;
        esac
    fi

    # === CHECK AND INSTALL OPTIONAL DEPENDENCIES (before any DNS changes) ===
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}📦 OPTIONAL DEPENDENCIES${NC}" $((60 - 23)) ""
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"
    log_info "Checking optional dependencies..."
    local optional_deps=()
    local dep_cmd
    
    for dep_cmd in dnsperf curl jq whiptail notify-send shellcheck git htop watch lsof fuser netstat nmcli networkctl; do
        if ! command -v "$dep_cmd" &>/dev/null; then
            optional_deps+=("$dep_cmd")
        fi
    done
    
    if [[ ${#optional_deps[@]} -gt 0 ]]; then
        echo ""
        log_warning "Optional dependencies not installed:"
        printf "  • %s\n" "${optional_deps[@]}"
        echo ""
        log_info "These packages enhance functionality but are not required:"
        log_info "  dnsperf - DNS performance benchmarking"
        log_info "  curl - HTTP client for metrics"
        log_info "  jq - JSON processor"
        log_info "  whiptail - Interactive GUI (already required for wizard)"
        log_info "  notify-send - Desktop notifications"
        log_info "  shellcheck - Script linting"
        log_info "  git - Version control for updates"
        log_info "  htop - Interactive process viewer"
        log_info "  watch - Periodic command execution"
        log_info "  lsof - List open files"
        log_info "  fuser - Find processes using files"
        log_info "  netstat - Network statistics"
        log_info "  nmcli - NetworkManager CLI"
        log_info "  networkctl - systemd-networkd CLI"
        echo ""
        echo -n "Install optional dependencies now? [y/N]: "
        read -r deps_answer </dev/tty
        if [[ "$deps_answer" =~ ^[Yy]$ ]]; then
            log_info "Installing optional dependencies..."
            for dep in "${optional_deps[@]}"; do
                # Map command to package name
                local pkg="$dep"
                case "$dep" in
                    netstat) pkg="net-tools" ;;
                    fuser) pkg="psmisc" ;;
                    watch) pkg="procps" ;;
                esac
                install_dep "$pkg" "$dep"
            done
        fi
    else
        log_success "All optional dependencies already installed"
    fi

    # Set whiptail colors (256-color palette for better contrast)
    # Format: root=,window=,border=,textbox=,button=
    export NEWT_COLORS='
root=,black
window=brightmagenta,black
border=brightgreen,black
textbox=brightmagenta,black
button=black,brightgreen
actbutton=black,brightmagenta
checkbox=brightgreen,black
actcheckbox=black,brightgreen
entry=brightmagenta,black
label=brightmagenta,black
listbox=brightmagenta,black
actlistbox=black,brightgreen
sellistbox=black,brightgreen
title=brightgreen,black
roottext=brightmagenta,black
emptyscale=black
fullscale=brightgreen,black
'

    # Language selection
    local WIZARD_LANG
    WIZARD_LANG=$(select_language "${1:-}")

    # Reload i18n with selected language
    CYTADELA_LANG="$WIZARD_LANG" load_i18n_module "install-wizard"

    # Display wizard title in selected language
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}🎯 ${T_WIZARD_TITLE}${NC}" $((60 - 3 - ${#T_WIZARD_TITLE})) ""
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"

    # Check for whiptail
    if ! command -v whiptail &>/dev/null; then
        if [[ "$WIZARD_LANG" == "pl" ]]; then
            log_error "whiptail nie znaleziony. Zainstaluj najpierw:"
            echo "  Arch/Manjaro: sudo pacman -S libnewt"
            echo "  Debian/Ubuntu: sudo apt install whiptail"
            echo "  Fedora: sudo dnf install newt"
            echo ""
            log_info "Lub uruchom: sudo cytadela++ check-deps --install"
        else
            log_error "whiptail not found. Install it first:"
            echo "  Arch/Manjaro: sudo pacman -S libnewt"
            echo "  Debian/Ubuntu: sudo apt install whiptail"
            echo "  Fedora: sudo dnf install newt"
            echo ""
            log_info "Or run: sudo cytadela++ check-deps --install"
        fi
        return 1
    fi

    # Module definitions: key|Name|Description|Default|Required
    # Use T_MOD_* variables from i18n translations
    declare -A MODULES
    MODULES=(
        [dnscrypt]="DNSCrypt-Proxy|${T_MOD_DNSCRYPT}|1|1"
        [coredns]="CoreDNS|${T_MOD_COREDNS}|1|1"
        [nftables]="NFTables|${T_MOD_NFTABLES}|1|1"
        [health]="Health Watchdog|${T_MOD_HEALTH}|0|0"
        [supply-chain]="Supply-chain|${T_MOD_SUPPLY}|0|0"
        [lkg]="LKG Cache|${T_MOD_LKG}|1|0"
        [ipv6]="IPv6 Privacy|${T_MOD_IPV6}|0|0"
        [location]="Location-aware|${T_MOD_LOCATION}|0|0"
        [nft-debug]="NFT Debug|${T_MOD_DEBUG}|0|0"
    )

    # Build checklist options for whiptail
    local options=()

    # Sort keys for consistent order
    local sorted_keys=(dnscrypt coredns nftables lkg health supply-chain ipv6 location nft-debug)

    for key in "${sorted_keys[@]}"; do
        [[ -z "${MODULES[$key]}" ]] && continue

        IFS='|' read -r name desc default required <<<"${MODULES[$key]}"

        local state="OFF"
        [[ "$default" == "1" ]] && state="ON"

        if [[ "$required" == "1" ]]; then
            # Required modules - always ON
            options+=("$key" "✓ $name - $desc [REQUIRED]" "ON")
        else
            # Optional modules
            options+=("$key" "  $name - $desc" "$state")
        fi
    done

    # Show checklist
    local selected
    # Use T_* variables from i18n translations
    local dialog_title="${T_DIALOG_TITLE}"
    local dialog_text="\n${T_SELECT_MODULES}\n${T_DIALOG_HELP}\n\n${T_REQUIRED_NOTE}"

    selected=$(whiptail --title "$dialog_title" \
        --checklist "$dialog_text" \
        24 78 10 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)

    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_warning "Instalacja anulowana przez użytkownika"
        return 1
    fi

    # Validate selection is not empty
    if [[ -z "${selected// /}" ]]; then
        log_warning "Nie wybrano żadnych modułów"
        return 1
    fi

    # Parse selection (remove quotes)
    local modules_to_install=()
    for module in $selected; do
        [[ -n "$module" ]] && modules_to_install+=("${module//\"/}")
    done

    # Ensure required modules are included
    for key in dnscrypt coredns nftables; do
        local pattern=" $key "
        if [[ ! " ${modules_to_install[*]} " =~ $pattern ]]; then
            modules_to_install+=("$key")
        fi
    done

    # Show summary
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}📋 INSTALLATION SUMMARY${NC}" $((60 - 22)) ""
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo "Selected modules:"
    for module in "${modules_to_install[@]}"; do
        IFS='|' read -r name desc default required <<<"${MODULES[$module]}"
        printf "  ${GREEN}✓${NC} %s\n" "$name"
    done

    echo ""
    log_warning "This will install and configure DNS services on your system."
    echo -n "Proceed with installation? [y/N]: "
    read -r answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        log_warning "Installation cancelled"
        return 1
    fi

    # Install selected modules
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}🚀 INSTALLING MODULES${NC}" $((60 - 20)) ""
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"

    local failed=0

    for module in "${modules_to_install[@]}"; do
        IFS='|' read -r name desc default required <<<"${MODULES[$module]}"

        echo ""
        if [[ "$WIZARD_LANG" == "pl" ]]; then
            log_info "Instalowanie: $name"
        else
            log_info "Installing: $name"
        fi

        case "$module" in
            dnscrypt)
                if ! declare -f install_dnscrypt >/dev/null 2>&1; then
                    load_module "install-dnscrypt"
                fi
                if install_dnscrypt; then
                    if [[ "$WIZARD_LANG" == "pl" ]]; then
                        log_success "$name zainstalowany"
                    else
                        log_success "$name installed"
                    fi
                else
                    if [[ "$WIZARD_LANG" == "pl" ]]; then
                        log_error "Instalacja $name nie powiodła się"
                    else
                        log_error "$name installation failed"
                    fi
                    ((failed++))
                fi
                ;;

            coredns)
                if ! declare -f install_coredns >/dev/null 2>&1; then
                    load_module "install-coredns"
                fi
                if install_coredns; then
                    [[ "$WIZARD_LANG" == "pl" ]] && log_success "$name zainstalowany" || log_success "$name installed"
                else
                    [[ "$WIZARD_LANG" == "pl" ]] && log_error "Instalacja $name nie powiodła się" || log_error "$name installation failed"
                    ((failed++))
                fi
                ;;

            nftables)
                if ! declare -f install_nftables >/dev/null 2>&1; then
                    load_module "install-nftables"
                fi
                if install_nftables; then
                    [[ "$WIZARD_LANG" == "pl" ]] && log_success "$name zainstalowany" || log_success "$name installed"
                else
                    [[ "$WIZARD_LANG" == "pl" ]] && log_error "Instalacja $name nie powiodła się" || log_error "$name installation failed"
                    ((failed++))
                fi
                ;;

            health)
                if ! declare -f install_health_watchdog >/dev/null 2>&1; then
                    load_module "health"
                fi
                if install_health_watchdog; then
                    [[ "$WIZARD_LANG" == "pl" ]] && log_success "$name zainstalowany" || log_success "$name installed"
                else
                    [[ "$WIZARD_LANG" == "pl" ]] && log_error "Instalacja $name nie powiodła się" || log_error "$name installation failed"
                    ((failed++))
                fi
                ;;

            supply-chain)
                if ! declare -f supply_chain_init >/dev/null 2>&1; then
                    load_module "supply-chain"
                fi
                if supply_chain_init; then
                    [[ "$WIZARD_LANG" == "pl" ]] && log_success "$name zainicjalizowany" || log_success "$name initialized"
                else
                    [[ "$WIZARD_LANG" == "pl" ]] && log_error "Inicjalizacja $name nie powiodła się" || log_error "$name initialization failed"
                    ((failed++))
                fi
                ;;

            lkg)
                if ! declare -f lkg_save_blocklist >/dev/null 2>&1; then
                    load_module "lkg"
                fi
                if lkg_save_blocklist; then
                    [[ "$WIZARD_LANG" == "pl" ]] && log_success "Cache $name zapisany" || log_success "$name cache saved"
                else
                    [[ "$WIZARD_LANG" == "pl" ]] && log_warning "Cache $name nie zapisany (zostanie utworzony przy pierwszej aktualizacji)" || log_warning "$name cache not saved (will be created on first update)"
                fi
                ;;

            ipv6)
                if ! declare -f ipv6_privacy_auto_ensure >/dev/null 2>&1; then
                    load_module "ipv6"
                fi
                if ipv6_privacy_auto_ensure; then
                    [[ "$WIZARD_LANG" == "pl" ]] && log_success "$name skonfigurowany" || log_success "$name configured"
                else
                    [[ "$WIZARD_LANG" == "pl" ]] && log_warning "Konfiguracja $name pominięta" || log_warning "$name configuration skipped"
                fi
                ;;

            location)
                if ! declare -f location_status >/dev/null 2>&1; then
                    load_module "location"
                fi
                [[ "$WIZARD_LANG" == "pl" ]] && log_info "Moduł $name załadowany (użyj: location-add-trusted <SSID>)" || log_info "$name module loaded (use: location-add-trusted <SSID>)"
                ;;

            nft-debug)
                if ! declare -f nft_debug_on >/dev/null 2>&1; then
                    load_module "nft-debug"
                fi
                [[ "$WIZARD_LANG" == "pl" ]] && log_info "Moduł $name załadowany (użyj: nft-debug-on aby włączyć)" || log_info "$name module loaded (use: nft-debug-on to enable)"
                ;;

            *)
                [[ "$WIZARD_LANG" == "pl" ]] && log_warning "Nieznany moduł: $module" || log_warning "Unknown module: $module"
                ;;
        esac
    done

    # Final summary
    echo ""
    if [[ "$WIZARD_LANG" == "pl" ]]; then
        echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
        printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}✅ INSTALACJA ZAKOŃCZONA${NC}" $((60 - 23)) ""
        echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"

        if [[ $failed -eq 0 ]]; then
            log_success "Wszystkie moduły zainstalowane pomyślnie!"
        else
            log_warning "Instalacja $failed modułu/ów nie powiodła się"
        fi

        echo ""
        log_info "Następne kroki:"
        echo "  1. Test DNS: dig +short google.com @127.0.0.1"
        echo "  2. Konfiguracja systemu: sudo cytadela++ configure-system"
        echo "  3. Weryfikacja: sudo cytadela++ verify"
    else
        echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
        printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}✅ INSTALLATION COMPLETE${NC}" $((60 - 23)) ""
        echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"

        if [[ $failed -eq 0 ]]; then
            log_success "All modules installed successfully!"
        else
            log_warning "$failed module(s) failed to install"
        fi

        echo ""
        log_info "Next steps:"
        echo "  1. Test DNS: dig +short google.com @127.0.0.1"
        echo "  2. Configure system: sudo cytadela++ configure-system"
        echo "  3. Verify: sudo cytadela++ verify"
    fi

    if ! declare -f diagnostics >/dev/null 2>&1; then
        load_module "diagnostics"
    fi

    echo ""
    verify_stack
}

install_wizard_help() {
    cat <<'EOF'
🎯 INSTALL WIZARD - Interactive Installer

USAGE:
  sudo cytadela++ install-wizard

DESCRIPTION:
  Interactive installer with checklist for selecting modules.
  Uses whiptail for terminal GUI.

REQUIRED MODULES (always installed):
  - DNSCrypt-Proxy: Encrypted DNS resolver
  - CoreDNS: Local DNS server with adblock
  - NFTables: Firewall rules (DNS leak prevention)

OPTIONAL MODULES:
  - Health Watchdog: Auto-restart services on failure
  - Supply-chain: Binary verification
  - LKG Cache: Last Known Good blocklist cache
  - IPv6 Privacy: IPv6 privacy extensions
  - Location-aware: SSID-based firewall advisory
  - NFT Debug: NFTables debug chain

REQUIREMENTS:
  - whiptail (libnewt package)
  - Root privileges

EXAMPLE:
  sudo cytadela++ install-wizard
  # Select modules with SPACE, confirm with ENTER
  # Follow on-screen instructions

EOF
}
