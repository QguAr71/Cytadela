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
        echo "en"  # Default to English
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

install_wizard() {
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
    
    # Load i18n translations for selected language
    # Determine script directory (same as citadel.sh bootstrap)
    local module_dir
    if command -v realpath >/dev/null 2>&1; then
        module_dir="$(dirname "$(dirname "$(realpath "${BASH_SOURCE[0]}")")")"
    else
        module_dir="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
    fi
    
    local i18n_file="${module_dir}/lib/i18n/${WIZARD_LANG}.sh"
    if [[ -f "$i18n_file" ]]; then
        # shellcheck source=/dev/null
        source "$i18n_file"
    else
        log_warning "Translation file not found: $i18n_file, falling back to English"
        # shellcheck source=/dev/null
        source "${module_dir}/lib/i18n/en.sh"
    fi
    
    # Display wizard title in selected language
    log_section "🎯 ${T_WIZARD_TITLE}"
    
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
        
        IFS='|' read -r name desc default required <<< "${MODULES[$key]}"
        
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
    
    # Parse selection (remove quotes)
    local modules_to_install=()
    for module in $selected; do
        modules_to_install+=("${module//\"/}")
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
    log_section "📋 INSTALLATION SUMMARY"
    echo "Selected modules:"
    for module in "${modules_to_install[@]}"; do
        IFS='|' read -r name desc default required <<< "${MODULES[$module]}"
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
    log_section "🚀 INSTALLING MODULES"
    
    local failed=0
    
    for module in "${modules_to_install[@]}"; do
        IFS='|' read -r name desc default required <<< "${MODULES[$module]}"
        
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
        log_section "✅ INSTALACJA ZAKOŃCZONA"
        
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
        log_section "✅ INSTALLATION COMPLETE"
        
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
