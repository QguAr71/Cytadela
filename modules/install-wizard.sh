#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-WIZARD MODULE v3.1                                    ║
# ║  Interactive installer with checklist (Issue #25)                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

install_wizard() {
    log_section "🎯 INTERACTIVE INSTALLER WIZARD"
    
    # Check for whiptail
    if ! command -v whiptail &>/dev/null; then
        log_error "whiptail not found. Install it first:"
        echo "  Arch/Manjaro: sudo pacman -S libnewt"
        echo "  Debian/Ubuntu: sudo apt install whiptail"
        echo "  Fedora: sudo dnf install newt"
        return 1
    fi
    
    # Module definitions: key|Name|Description|Default|Required
    declare -A MODULES=(
        [dnscrypt]="DNSCrypt-Proxy|Szyfrowany resolver DNS (DNSCrypt/DoH)|1|1"
        [coredns]="CoreDNS|Lokalny serwer DNS z adblockiem i cache|1|1"
        [nftables]="NFTables|Reguły firewall (ochrona przed DNS leak)|1|1"
        [health]="Health Watchdog|Auto-restart usług przy awarii|0|0"
        [supply-chain]="Supply-chain|Weryfikacja binariów (sumy kontrolne)|0|0"
        [lkg]="LKG Cache|Cache Last Known Good dla blocklist|1|0"
        [ipv6]="IPv6 Privacy|Zarządzanie rozszerzeniami prywatności IPv6|0|0"
        [location]="Location-aware|Firewall zależny od SSID|0|0"
        [nft-debug]="NFT Debug|Łańcuch debug NFTables z logowaniem|0|0"
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
    selected=$(whiptail --title "Cytadela++ v3.1 - Kreator Instalacji" \
        --checklist "\nWybierz moduły do instalacji:\n(SPACJA - zaznacz/odznacz, TAB - nawigacja, ENTER - potwierdź)\n\nModuły wymagane są wstępnie zaznaczone i nie można ich wyłączyć." \
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
        log_info "Instalowanie: $name"
        
        case "$module" in
            dnscrypt)
                if ! declare -f install_dnscrypt >/dev/null 2>&1; then
                    load_module "install-dnscrypt"
                fi
                if install_dnscrypt; then
                    log_success "$name zainstalowany"
                else
                    log_error "Instalacja $name nie powiodła się"
                    ((failed++))
                fi
                ;;
            
            coredns)
                if ! declare -f install_coredns >/dev/null 2>&1; then
                    load_module "install-coredns"
                fi
                if install_coredns; then
                    log_success "$name zainstalowany"
                else
                    log_error "Instalacja $name nie powiodła się"
                    ((failed++))
                fi
                ;;
            
            nftables)
                if ! declare -f install_nftables >/dev/null 2>&1; then
                    load_module "install-nftables"
                fi
                if install_nftables; then
                    log_success "$name zainstalowany"
                else
                    log_error "Instalacja $name nie powiodła się"
                    ((failed++))
                fi
                ;;
            
            health)
                if ! declare -f install_health_watchdog >/dev/null 2>&1; then
                    load_module "health"
                fi
                if install_health_watchdog; then
                    log_success "$name zainstalowany"
                else
                    log_error "Instalacja $name nie powiodła się"
                    ((failed++))
                fi
                ;;
            
            supply-chain)
                if ! declare -f supply_chain_init >/dev/null 2>&1; then
                    load_module "supply-chain"
                fi
                if supply_chain_init; then
                    log_success "$name zainicjalizowany"
                else
                    log_error "Inicjalizacja $name nie powiodła się"
                    ((failed++))
                fi
                ;;
            
            lkg)
                if ! declare -f lkg_save_blocklist >/dev/null 2>&1; then
                    load_module "lkg"
                fi
                if lkg_save_blocklist; then
                    log_success "Cache $name zapisany"
                else
                    log_warning "Cache $name nie zapisany (zostanie utworzony przy pierwszej aktualizacji)"
                fi
                ;;
            
            ipv6)
                if ! declare -f ipv6_privacy_auto_ensure >/dev/null 2>&1; then
                    load_module "ipv6"
                fi
                if ipv6_privacy_auto_ensure; then
                    log_success "$name skonfigurowany"
                else
                    log_warning "Konfiguracja $name pominięta"
                fi
                ;;
            
            location)
                if ! declare -f location_status >/dev/null 2>&1; then
                    load_module "location"
                fi
                log_info "Moduł $name załadowany (użyj: location-add-trusted <SSID>)"
                ;;
            
            nft-debug)
                if ! declare -f nft_debug_on >/dev/null 2>&1; then
                    load_module "nft-debug"
                fi
                log_info "Moduł $name załadowany (użyj: nft-debug-on aby włączyć)"
                ;;
            
            *)
                log_warning "Nieznany moduł: $module"
                ;;
        esac
    done
    
    # Final summary
    echo ""
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
