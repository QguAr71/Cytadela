# 🔄 CITADEL - REFAKTORYZACJA: ZUNIFIKOWANY INTERFEJS MODUŁÓW

**Wersja:** 3.1.0 → 3.2.0  
**Data:** 2026-01-31  
**Problem:** Chaos w interfejsie modułów  
**Rozwiązanie:** Zunifikowany interfejs `funkcja(moduł -parametry)`

---

## ❌ PROBLEM: OBECNY CHAOS

### Przykład 1: Instalacja komponentu

**OBECNY SPOSÓB (CHAOTYCZNY):**
```bash
# Krok 1: Załaduj moduł
load_module "install-dnscrypt"

# Krok 2: Wywołaj funkcję instalacji
install_dnscrypt

# Krok 3: Załaduj moduł konfiguracji
load_module "configure"

# Krok 4: Skonfiguruj
configure_dnscrypt

# Krok 5: Załaduj moduł weryfikacji
load_module "verify"

# Krok 6: Zweryfikuj
verify_dnscrypt
```

**PROBLEMY:**
- ❌ 6 kroków dla jednej operacji
- ❌ Trzeba znać nazwy modułów
- ❌ Trzeba znać kolejność operacji
- ❌ Ręczne ładowanie modułów
- ❌ Brak spójności między modułami

---

### Przykład 2: Zarządzanie adblockiem

**OBECNY SPOSÓB (CHAOTYCZNY):**
```bash
# Dodaj domenę
load_module "adblock"
adblock_add "ads.example.com"

# Zmień profil
load_module "blocklist-manager"
blocklist_switch "aggressive"

# Przebuduj listy
load_module "adblock"
adblock_rebuild

# Sprawdź status
adblock_status
```

**PROBLEMY:**
- ❌ Dwa moduły dla jednej funkcjonalności (adblock + blocklist-manager)
- ❌ Niepotrzebne przełączanie między modułami
- ❌ Niejasne co należy do którego modułu

---

### Przykład 3: Backup i restore

**OBECNY SPOSÓB (CHAOTYCZNY):**
```bash
# Backup
load_module "config-backup"
config_backup

# Restore
config_restore /path/to/backup.tar.gz

# LKG save
load_module "lkg"
lkg_save

# LKG restore
lkg_restore
```

**PROBLEMY:**
- ❌ Dwa moduły dla backupu (config-backup + lkg)
- ❌ Różne nazewnictwo (config_backup vs lkg_save)
- ❌ Niejasne kiedy użyć którego

---

## ✅ ROZWIĄZANIE: ZUNIFIKOWANY INTERFEJS

### Koncepcja: `funkcja(moduł -parametry)`

**NOWY SPOSÓB (PROSTY):**
```bash
# Jedna komenda, wszystko automatyczne
citadel install dnscrypt [--configure] [--verify]
citadel adblock add ads.example.com
citadel backup create [--description "text"]
```

**KORZYŚCI:**
- ✅ Jeden krok zamiast wielu
- ✅ Automatyczne ładowanie modułów
- ✅ Spójny interfejs dla wszystkich funkcji
- ✅ Łatwe do zapamiętania
- ✅ Samodokumentujące się

---

## 🏗️ ARCHITEKTURA ZUNIFIKOWANEGO INTERFEJSU

### 1. Główny router (citadel.sh)

```bash
#!/bin/bash

# Główny router - parsuje komendę i wywołuje odpowiedni moduł
main() {
    local command="$1"
    shift
    
    case "$command" in
        install)
            module_install "$@"
            ;;
        configure)
            module_configure "$@"
            ;;
        adblock)
            module_adblock "$@"
            ;;
        backup)
            module_backup "$@"
            ;;
        monitor)
            module_monitor "$@"
            ;;
        security)
            module_security "$@"
            ;;
        *)
            show_help
            ;;
    esac
}
```

---

### 2. Moduł z zunifikowanym interfejsem

**Przykład: modules/install.sh**

```bash
#!/bin/bash
# Zunifikowany moduł instalacji

module_install() {
    local component="$1"
    shift
    
    # Parsowanie parametrów
    local configure=false
    local verify=false
    local start=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --configure) configure=true ;;
            --verify) verify=true ;;
            --start) start=true ;;
            --all) configure=true; verify=true; start=true ;;
            *) log_error "Unknown parameter: $1" ;;
        esac
        shift
    done
    
    # Wykonaj operacje w logicznej kolejności
    case "$component" in
        dnscrypt)
            install_dnscrypt_component
            [[ "$configure" == true ]] && configure_dnscrypt_component
            [[ "$start" == true ]] && start_dnscrypt_component
            [[ "$verify" == true ]] && verify_dnscrypt_component
            ;;
        coredns)
            install_coredns_component
            [[ "$configure" == true ]] && configure_coredns_component
            [[ "$start" == true ]] && start_coredns_component
            [[ "$verify" == true ]] && verify_coredns_component
            ;;
        all)
            install_all_components "$configure" "$verify" "$start"
            ;;
        *)
            log_error "Unknown component: $component"
            show_install_help
            ;;
    esac
}

# Wewnętrzne funkcje (nie eksportowane)
install_dnscrypt_component() {
    log_section "Installing DNSCrypt-Proxy"
    # ... implementacja ...
}

configure_dnscrypt_component() {
    log_section "Configuring DNSCrypt-Proxy"
    # ... implementacja ...
}

# etc.
```

---

### 3. Przykłady użycia

#### Instalacja

```bash
# Podstawowa instalacja
citadel install dnscrypt

# Instalacja + konfiguracja
citadel install dnscrypt --configure

# Instalacja + konfiguracja + weryfikacja
citadel install dnscrypt --configure --verify

# Pełna instalacja (wszystko)
citadel install dnscrypt --all

# Instalacja wszystkich komponentów
citadel install all --all
```

#### Ad blocking

```bash
# Dodaj domenę
citadel adblock add ads.example.com

# Usuń domenę
citadel adblock remove ads.example.com

# Zmień profil
citadel adblock profile aggressive

# Status
citadel adblock status

# Przebuduj (automatyczne po add/remove/profile)
citadel adblock rebuild
```

#### Backup

```bash
# Utwórz backup
citadel backup create

# Utwórz backup z opisem
citadel backup create --description "Przed aktualizacją"

# Lista backupów
citadel backup list

# Przywróć backup
citadel backup restore /path/to/backup.tar.gz

# LKG save (automatyczne przed aktualizacją)
citadel backup lkg-save

# LKG restore
citadel backup lkg-restore
```

#### Monitoring

```bash
# Status wszystkiego
citadel monitor status

# Health check
citadel monitor health

# Cache stats
citadel monitor cache

# Diagnostyka
citadel monitor diagnostics

# Live monitoring
citadel monitor live
```

#### Security

```bash
# Killswitch on
citadel security killswitch on

# Killswitch off
citadel security killswitch off

# Panic mode
citadel security panic [--timeout 300]

# Integrity check
citadel security integrity check

# Supply chain verify
citadel security supply-chain verify
```

---

## 📊 PORÓWNANIE: PRZED vs PO

### Scenariusz 1: Instalacja DNSCrypt z konfiguracją

**PRZED (6 kroków):**
```bash
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-dnscrypt
sudo ./citadel.sh configure-dnscrypt
sudo ./citadel.sh start-dnscrypt
sudo ./citadel.sh verify-dnscrypt
sudo ./citadel.sh status
```

**PO (1 krok):**
```bash
sudo ./citadel.sh install dnscrypt --all
```

---

### Scenariusz 2: Zmiana profilu adblock

**PRZED (4 kroki):**
```bash
sudo ./citadel.sh config-backup
sudo ./citadel.sh blocklist-switch aggressive
sudo ./citadel.sh adblock-rebuild
sudo ./citadel.sh adblock-status
```

**PO (1 krok):**
```bash
sudo ./citadel.sh adblock profile aggressive
# Automatycznie: backup → switch → rebuild → status
```

---

### Scenariusz 3: Pełna diagnostyka

**PRZED (5 kroków):**
```bash
sudo ./citadel.sh status
sudo ./citadel.sh health-status
sudo ./citadel.sh diagnostics
sudo ./citadel.sh cache-stats
sudo ./citadel.sh verify
```

**PO (1 krok):**
```bash
sudo ./citadel.sh monitor full
# Automatycznie: wszystkie testy + raport
```

---

## 🔧 IMPLEMENTACJA: PLAN REFAKTORYZACJI

### Faza 1: Utworzenie zunifikowanych modułów (v3.2)

**Nowe moduły z zunifikowanym interfejsem:**

1. **modules/unified-install.sh**
   - `module_install(component, --configure, --verify, --start, --all)`
   - Zastępuje: install-wizard, install-all, install-dnscrypt, install-coredns, install-nftables

2. **modules/unified-adblock.sh**
   - `module_adblock(action, domain/profile, --options)`
   - Zastępuje: adblock, blocklist-manager
   - Łączy obie funkcjonalności w jeden moduł

3. **modules/unified-backup.sh**
   - `module_backup(action, --options)`
   - Zastępuje: config-backup, lkg
   - Jeden moduł dla wszystkich backupów

4. **modules/unified-monitor.sh**
   - `module_monitor(action, --options)`
   - Zastępuje: health, diagnostics, discover, cache-stats
   - Jeden moduł dla monitoringu

5. **modules/unified-security.sh**
   - `module_security(action, --options)`
   - Zastępuje: emergency, supply-chain, integrity, ghost-check
   - Jeden moduł dla bezpieczeństwa

6. **modules/unified-network.sh**
   - `module_network(action, --options)`
   - Zastępuje: ipv6, location, discover (część)
   - Jeden moduł dla sieci

---

### Faza 2: Aktualizacja głównego routera (v3.2)

**citadel.sh - nowa struktura:**

```bash
#!/bin/bash

# Ładuj core
source "${CITADEL_LIB}/cytadela-core.sh"
source "${CITADEL_LIB}/module-loader.sh"

# Główny router
main() {
    check_root
    
    local command="$1"
    shift
    
    case "$command" in
        # Zunifikowane komendy
        install)
            load_unified_module "install"
            module_install "$@"
            ;;
        adblock)
            load_unified_module "adblock"
            module_adblock "$@"
            ;;
        backup)
            load_unified_module "backup"
            module_backup "$@"
            ;;
        monitor)
            load_unified_module "monitor"
            module_monitor "$@"
            ;;
        security)
            load_unified_module "security"
            module_security "$@"
            ;;
        network)
            load_unified_module "network"
            module_network "$@"
            ;;
        
        # Aliasy dla kompatybilności wstecznej (deprecated)
        install-dnscrypt)
            log_warning "Deprecated: Use 'citadel install dnscrypt' instead"
            load_unified_module "install"
            module_install dnscrypt --all
            ;;
        adblock-add)
            log_warning "Deprecated: Use 'citadel adblock add' instead"
            load_unified_module "adblock"
            module_adblock add "$@"
            ;;
        
        # Help
        help|--help|-h)
            show_unified_help
            ;;
        
        *)
            log_error "Unknown command: $command"
            show_unified_help
            exit 1
            ;;
    esac
}

main "$@"
```

---

### Faza 3: Kompatybilność wsteczna (v3.2-v3.3)

**Zachowanie starych komend przez aliasy:**

```bash
# Stare komendy (deprecated, ale działają)
citadel.sh install-dnscrypt
  ↓
citadel.sh install dnscrypt --all

# Nowe komendy (zalecane)
citadel.sh install dnscrypt --all
```

**Ostrzeżenia deprecation:**
```
⚠️  WARNING: 'install-dnscrypt' is deprecated
    Use 'citadel install dnscrypt' instead
    Old command will be removed in v3.4
```

---

### Faza 4: Usunięcie starych modułów (v3.4)

**Po okresie przejściowym (3-6 miesięcy):**
- Usuń stare moduły
- Usuń aliasy kompatybilności
- Tylko zunifikowany interfejs

---

## 📚 DOKUMENTACJA ZUNIFIKOWANEGO INTERFEJSU

### Struktura komend

```
citadel <kategoria> <akcja> [parametry] [--opcje]

Kategorie:
  install     - Instalacja komponentów
  configure   - Konfiguracja systemu
  adblock     - Zarządzanie blokowaniem reklam
  backup      - Backup i restore
  monitor     - Monitoring i diagnostyka
  security    - Bezpieczeństwo
  network     - Zarządzanie siecią

Przykłady:
  citadel install dnscrypt --all
  citadel adblock add ads.example.com
  citadel backup create --description "text"
  citadel monitor status
  citadel security killswitch on
  citadel network ipv6 privacy on
```

---

### Help zunifikowany

```bash
citadel help
citadel help install
citadel help adblock
citadel help backup
```

**Output:**
```
CITADEL - Fortified DNS Infrastructure v3.2.0

Usage: citadel <category> <action> [parameters] [options]

CATEGORIES:
  install      Install and configure components
  adblock      Manage ad blocking
  backup       Backup and restore
  monitor      Monitoring and diagnostics
  security     Security features
  network      Network management

EXAMPLES:
  citadel install dnscrypt --all
  citadel adblock profile aggressive
  citadel monitor status
  citadel security killswitch on

For detailed help: citadel help <category>
```

---

## 🎯 KORZYŚCI ZUNIFIKOWANEGO INTERFEJSU

### 1. Prostota użycia
- ✅ Jedna komenda zamiast wielu
- ✅ Logiczna struktura (kategoria → akcja)
- ✅ Łatwe do zapamiętania

### 2. Spójność
- ✅ Wszystkie moduły działają tak samo
- ✅ Jednolite nazewnictwo
- ✅ Przewidywalne zachowanie

### 3. Automatyzacja
- ✅ Automatyczne ładowanie modułów
- ✅ Automatyczna kolejność operacji
- ✅ Automatyczne zależności

### 4. Łatwość utrzymania
- ✅ Mniej duplikacji kodu
- ✅ Łatwiejsze testowanie
- ✅ Łatwiejsze dodawanie nowych funkcji

### 5. Lepsza dokumentacja
- ✅ Samodokumentujący się interfejs
- ✅ Spójny help
- ✅ Łatwiejsze przykłady

---

## 📊 STATYSTYKI REFAKTORYZACJI

### Redukcja złożoności

| Metryka | Przed | Po | Redukcja |
|---------|-------|-----|----------|
| **Liczba modułów** | 32 | 6 zunifikowanych | -81% |
| **Liczba komend** | 101 | ~30 | -70% |
| **Średnia liczba kroków** | 3-6 | 1 | -80% |
| **Linie kodu** | ~8,000 | ~5,000 | -37% |

### Przykłady redukcji

| Operacja | Kroki przed | Kroki po | Redukcja |
|----------|-------------|----------|----------|
| Instalacja DNSCrypt | 6 | 1 | -83% |
| Zmiana profilu adblock | 4 | 1 | -75% |
| Pełna diagnostyka | 5 | 1 | -80% |
| Backup + restore | 3 | 1 | -67% |

---

## 🚀 PLAN WDROŻENIA

### v3.2 (Q1 2026) - Zunifikowany interfejs

**Milestone 1: Utworzenie zunifikowanych modułów**
- [ ] modules/unified-install.sh
- [ ] modules/unified-adblock.sh
- [ ] modules/unified-backup.sh
- [ ] modules/unified-monitor.sh
- [ ] modules/unified-security.sh
- [ ] modules/unified-network.sh

**Milestone 2: Aktualizacja routera**
- [ ] Nowa struktura citadel.sh
- [ ] Aliasy kompatybilności
- [ ] Ostrzeżenia deprecation

**Milestone 3: Dokumentacja**
- [ ] Nowy help zunifikowany
- [ ] Aktualizacja MANUAL_PL.md
- [ ] Aktualizacja MANUAL_EN.md
- [ ] Migration guide

**Milestone 4: Testy**
- [ ] Testy zunifikowanych modułów
- [ ] Testy kompatybilności wstecznej
- [ ] Testy integracyjne

---

### v3.3 (Q2 2026) - Okres przejściowy

- Oba interfejsy działają równolegle
- Ostrzeżenia deprecation dla starych komend
- Dokumentacja promuje nowy interfejs

---

### v3.4 (Q3 2026) - Usunięcie starych modułów

- Usunięcie starych modułów (32 → 6)
- Usunięcie aliasów kompatybilności
- Tylko zunifikowany interfejs

---

## 💡 TWOJA OBSERWACJA BYŁA TRAFNA!

**Problem który zauważyłeś:**
```
funkcja (moduł instalacja → moduł uruchomienie → moduł zmiana → moduł test)
```

**Rozwiązanie:**
```
funkcja (moduł -parametry)
```

**To jest dokładnie to co proponuję w tym dokumencie!**

### Korzyści dla użytkownika:
- ✅ Prostsze użycie (1 komenda zamiast 6)
- ✅ Mniej do zapamiętania
- ✅ Szybsze wykonanie zadań
- ✅ Mniej błędów

### Korzyści dla dewelopera:
- ✅ Mniej kodu do utrzymania
- ✅ Łatwiejsze testowanie
- ✅ Łatwiejsze dodawanie funkcji
- ✅ Lepsza architektura

---

**Dokument wersja:** 1.0  
**Data:** 2026-01-31  
**Autor:** Citadel Team  
**Inspiracja:** Obserwacja użytkownika o chaosie w interfejsie

**Ten dokument to plan refaktoryzacji dla v3.2!** 🚀
