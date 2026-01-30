# FUTURE: Interactive Module Installer (Issue #25)
**Checklist instalacyjny dla opcjonalnych modułów**

---

## KONCEPT

### Komenda:
```bash
sudo cytadela++ install-interactive
# lub
sudo cytadela++ install-wizard
```

---

## IMPLEMENTACJA

### 1. Moduł: `modules/install-interactive.sh`

```bash
#!/bin/bash
# Cytadela Interactive Installer v3.1

# Dependency check
require_cmds whiptail || {
    log_error "whiptail not found. Install: sudo pacman -S libnewt"
    exit 1
}

# Module definitions
declare -A MODULES=(
    # Format: [key]="Name|Description|Default|Required"
    [dnscrypt]="DNSCrypt-Proxy|Encrypted DNS resolver|1|1"
    [coredns]="CoreDNS|Local DNS server with adblock|1|1"
    [nftables]="NFTables|Firewall rules|1|1"
    [health]="Health Watchdog|Auto-restart on failure|0|0"
    [citadel-top]="Citadel Top|Terminal dashboard|0|0"
    [editor]="Editor Integration|Syntax highlighting|0|0"
    [doh-parallel]="DoH Parallel|Parallel DNS-over-HTTPS|0|0"
    [auto-update]="Auto-update|Automatic blocklist updates|0|0"
    [notify]="Desktop Notify|System notifications|0|0"
    [supply-chain]="Supply-chain|Binary verification|0|0"
    [panic]="Panic Mode|Emergency DNS bypass|0|0"
    [location]="Location-aware|SSID-based firewall|0|0"
)

install_interactive() {
    log_section "🎯 INTERACTIVE INSTALLER"
    
    # Build checklist
    local options=()
    local defaults=()
    
    for key in "${!MODULES[@]}"; do
        IFS='|' read -r name desc default required <<< "${MODULES[$key]}"
        
        if [[ "$required" == "1" ]]; then
            # Required - always ON, disabled checkbox
            options+=("$key" "$name - $desc" "ON" "DISABLED")
        else
            # Optional - user choice
            local state="OFF"
            [[ "$default" == "1" ]] && state="ON"
            options+=("$key" "$name - $desc" "$state")
        fi
    done
    
    # Show checklist
    local selected
    selected=$(whiptail --title "Cytadela++ Installer" \
        --checklist "Select modules to install (SPACE to toggle, ENTER to confirm):" \
        20 78 12 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)
    
    if [[ $? -ne 0 ]]; then
        log_warning "Installation cancelled"
        return 1
    fi
    
    # Parse selection
    local modules_to_install=()
    for module in $selected; do
        modules_to_install+=("${module//\"/}")
    done
    
    # Confirm
    log_info "Selected modules: ${modules_to_install[*]}"
    echo -n "Proceed with installation? [Y/n]: "
    read -r answer
    [[ "$answer" =~ ^[Nn]$ ]] && { log_warning "Cancelled"; return 1; }
    
    # Install
    for module in "${modules_to_install[@]}"; do
        case "$module" in
            dnscrypt) load_module install-dnscrypt && install_dnscrypt ;;
            coredns) load_module install-coredns && install_coredns ;;
            nftables) load_module install-nftables && install_nftables ;;
            health) load_module health && install_health_watchdog ;;
            citadel-top) load_module extras && install_citadel_top ;;
            editor) load_module extras && install_editor_integration ;;
            doh-parallel) load_module extras && install_doh_parallel ;;
            auto-update) install_auto_update ;;
            notify) install_desktop_notify ;;
            supply-chain) load_module supply-chain && supply_chain_init ;;
            panic) log_info "Panic mode available via: cytadela++ panic-bypass" ;;
            location) log_info "Location-aware available via: cytadela++ location-check" ;;
        esac
    done
    
    # Save configuration
    mkdir -p /etc/cytadela
    printf '%s\n' "${modules_to_install[@]}" > /etc/cytadela/installed-modules.conf
    
    log_success "Installation complete!"
    log_info "Installed modules saved to /etc/cytadela/installed-modules.conf"
}
```

---

## ALTERNATYWA: Simple CLI Checklist (bez whiptail)

Jeśli nie chcemy dependency na `whiptail`:

```bash
install_interactive_simple() {
    log_section "🎯 INTERACTIVE INSTALLER"
    
    echo "Select modules to install (y/n):"
    echo ""
    
    # Core (required)
    echo "CORE COMPONENTS (required):"
    echo "  [✓] DNSCrypt-Proxy"
    echo "  [✓] CoreDNS"
    echo "  [✓] NFTables"
    echo ""
    
    # Optional
    echo "OPTIONAL MODULES:"
    
    local install_health install_top install_editor install_doh
    
    echo -n "  [ ] Health Watchdog - Auto-restart on failure? [y/N]: "
    read -r install_health
    
    echo -n "  [ ] Citadel Top - Terminal dashboard? [y/N]: "
    read -r install_top
    
    echo -n "  [ ] Editor Integration - Syntax highlighting? [y/N]: "
    read -r install_editor
    
    echo -n "  [ ] DoH Parallel - Parallel DNS-over-HTTPS? [y/N]: "
    read -r install_doh
    
    # ... więcej opcji
    
    echo ""
    echo "Installing selected modules..."
    
    # Core (always)
    load_module install-dnscrypt && install_dnscrypt
    load_module install-coredns && install_coredns
    load_module install-nftables && install_nftables
    
    # Optional
    [[ "$install_health" =~ ^[Yy]$ ]] && { load_module health && install_health_watchdog; }
    [[ "$install_top" =~ ^[Yy]$ ]] && { load_module extras && install_citadel_top; }
    [[ "$install_editor" =~ ^[Yy]$ ]] && { load_module extras && install_editor_integration; }
    [[ "$install_doh" =~ ^[Yy]$ ]] && { load_module extras && install_doh_parallel; }
    
    log_success "Installation complete!"
}
```

---

## DODATKOWE FUNKCJE

### 1. Lista zainstalowanych modułów

```bash
install_list() {
    log_section "📦 INSTALLED MODULES"
    
    if [[ ! -f /etc/cytadela/installed-modules.conf ]]; then
        log_warning "No installation record found"
        return 1
    fi
    
    while read -r module; do
        echo "  ✓ $module"
    done < /etc/cytadela/installed-modules.conf
}
```

### 2. Dodawanie modułu post-install

```bash
install_add() {
    local module="$1"
    
    [[ -z "$module" ]] && { log_error "Usage: install-add <module>"; return 1; }
    
    # Install module
    case "$module" in
        health) load_module health && install_health_watchdog ;;
        citadel-top) load_module extras && install_citadel_top ;;
        # ...
        *) log_error "Unknown module: $module"; return 1 ;;
    esac
    
    # Update config
    echo "$module" >> /etc/cytadela/installed-modules.conf
    log_success "Module $module installed and registered"
}
```

### 3. Usuwanie modułu

```bash
install_remove() {
    local module="$1"
    
    [[ -z "$module" ]] && { log_error "Usage: install-remove <module>"; return 1; }
    
    # Uninstall module
    case "$module" in
        health) load_module health && uninstall_health_watchdog ;;
        # ...
        *) log_error "Unknown module: $module"; return 1; }
    esac
    
    # Update config
    sed -i "/^${module}$/d" /etc/cytadela/installed-modules.conf
    log_success "Module $module removed"
}
```

---

## KOMENDY

```bash
# Interactive installer
sudo cytadela++ install-interactive

# Lista zainstalowanych
sudo cytadela++ install-list

# Dodaj moduł
sudo cytadela++ install-add health

# Usuń moduł
sudo cytadela++ install-remove health
```

---

## TIMELINE

**Issue #25: Interactive Module Installer**

- **Priorytet:** Średni
- **Trudność:** Niska-Średnia
- **Czas:** 3-4h
- **Dependencies:** Issues #11, #12 (refactoring)
- **Target:** v3.1.1 lub v3.2

---

## NOTATKA

Ten dokument to **szkic na przyszłość**. Nie implementujemy tego teraz, aby nie opóźniać refactoringu Issues #11/#12.

Po zakończeniu refactoringu można utworzyć Issue #25 i zaimplementować interactive installer jako osobny feature.
