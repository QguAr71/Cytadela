# CYTADELA++ MIGRATION PLAN - Issues #11 & #12
**Plan migracji krok po kroku z zachowaniem 100% backward compatibility**

---

## PHASE 3: PLAN MIGRACJI

### 3.1 STRATEGIA MIGRACJI

**Zasady:**
1. ✅ **Zero Downtime** - stary kod działa do końca
2. ✅ **Backward Compatibility** - wszystkie komendy działają identycznie
3. ✅ **Incremental Migration** - migracja modułami, nie big-bang
4. ✅ **Rollback Ready** - możliwość cofnięcia na każdym etapie
5. ✅ **Testing First** - testy przed każdym krokiem

---

### 3.2 ETAPY MIGRACJI

#### **ETAP 0: Przygotowanie (1-2h)**

**Cel:** Backup i przygotowanie środowiska

```bash
# 1. Backup obecnych skryptów
cd /home/qguar/Cytadela
mkdir -p backup/pre-refactoring
cp cytadela++.sh backup/pre-refactoring/cytadela++.sh.backup
cp citadela_en.sh backup/pre-refactoring/citadela_en.sh.backup
git add -A
git commit -m "Backup: Pre-refactoring state (Issues #11 #12)"

# 2. Utworzenie gałęzi refactoring
git checkout -b refactoring/issues-11-12

# 3. Utworzenie struktury katalogów
mkdir -p lib modules
touch lib/.gitkeep modules/.gitkeep

# 4. Utworzenie pliku wersji
echo "3.1.0-dev" > VERSION
```

**Weryfikacja:**
- ✅ Backup istnieje
- ✅ Gałąź refactoring utworzona
- ✅ Katalogi lib/ i modules/ istnieją

---

#### **ETAP 1: Core Library (2-3h)**

**Cel:** Wydzielenie cytadela-core.sh i network-utils.sh

**Krok 1.1:** Utworzenie `lib/cytadela-core.sh`

```bash
# Wyciągnij z cytadela++.sh:
# - Zmienne globalne (linie 17-58)
# - Funkcje log_* (linie 61-65)
# - trap_err_handler (linie 22-29)
# - require_cmd, require_cmds (linie 1473-1489)
# - dnssec_enabled (linie 1491-1499)
# - integrity_check_module (nowa funkcja)

cat > lib/cytadela-core.sh <<'EOF'
#!/bin/bash
# Cytadela Core Library v3.1
# (zawartość jak w ARCHITECTURE_DESIGN.md)
EOF

chmod +x lib/cytadela-core.sh
```

**Krok 1.2:** Utworzenie `lib/network-utils.sh`

```bash
# Wyciągnij z cytadela++.sh:
# - discover_active_interface (linie 221-231)
# - discover_network_stack (linie 233-244)
# - discover_nftables_status (linie 246-260)
# - port_in_use (linie 1527-1530)
# - pick_free_port (linie 1532-1543)
# - get_dnscrypt_listen_port (linie 1545-1550)
# - get_coredns_listen_port (linie 1552-1557)

cat > lib/network-utils.sh <<'EOF'
#!/bin/bash
# Cytadela Network Utilities v3.1
# (zawartość jak w ARCHITECTURE_DESIGN.md)
EOF

chmod +x lib/network-utils.sh
```

**Krok 1.3:** Test core libraries

```bash
# Test 1: Source libraries
bash -c "source lib/cytadela-core.sh && source lib/network-utils.sh && echo 'OK'"

# Test 2: Funkcje dostępne
bash -c "source lib/cytadela-core.sh && log_info 'Test' && echo 'OK'"

# Test 3: Network utils
bash -c "source lib/network-utils.sh && discover_active_interface && echo 'OK'"
```

**Weryfikacja:**
- ✅ `lib/cytadela-core.sh` działa
- ✅ `lib/network-utils.sh` działa
- ✅ Wszystkie funkcje dostępne

---

#### **ETAP 2: i18n Libraries (1-2h)**

**Cel:** Wydzielenie komunikatów do osobnych plików

**Krok 2.1:** Utworzenie `lib/i18n-pl.sh`

```bash
cat > lib/i18n-pl.sh <<'EOF'
#!/bin/bash
# Cytadela i18n - Polish Messages

show_help_pl() {
    # Skopiuj całą funkcję show_help() z cytadela++.sh (linie 2924-3049)
}

# Komunikaty
MSG_ROOT_REQUIRED="Ten skrypt wymaga uprawnień root. Uruchom: sudo \$0"
MSG_MODULE_NOT_FOUND="Moduł nie znaleziony"
MSG_UNKNOWN_COMMAND="Nieznana komenda"
MSG_LOADING_MODULE="Ładowanie modułu"
MSG_MODULE_LOADED="Moduł załadowany"
EOF

chmod +x lib/i18n-pl.sh
```

**Krok 2.2:** Utworzenie `lib/i18n-en.sh`

```bash
cat > lib/i18n-en.sh <<'EOF'
#!/bin/bash
# Cytadela i18n - English Messages

show_help_en() {
    # Skopiuj całą funkcję show_help() z citadela_en.sh
}

# Messages
MSG_ROOT_REQUIRED="This script requires root privileges. Run: sudo \$0"
MSG_MODULE_NOT_FOUND="Module not found"
MSG_UNKNOWN_COMMAND="Unknown command"
MSG_LOADING_MODULE="Loading module"
MSG_MODULE_LOADED="Module loaded"
EOF

chmod +x lib/i18n-en.sh
```

**Weryfikacja:**
- ✅ `lib/i18n-pl.sh` zawiera show_help_pl()
- ✅ `lib/i18n-en.sh` zawiera show_help_en()

---

#### **ETAP 3: Pierwszy Moduł - Integrity (2-3h)**

**Cel:** Migracja modułu integrity jako proof-of-concept

**Krok 3.1:** Utworzenie `modules/integrity.sh`

```bash
cat > modules/integrity.sh <<'EOF'
#!/bin/bash
# Cytadela Integrity Module v3.1

# Wyciągnij z cytadela++.sh:
# - integrity_verify_file (linie 70-83)
# - integrity_check (linie 85-153)
# - integrity_init (linie 155-200)
# - integrity_status (linie 202-216)

# (pełna zawartość jak w ARCHITECTURE_DESIGN.md)
EOF

chmod +x modules/integrity.sh
```

**Krok 3.2:** Test modułu integrity

```bash
# Test standalone
bash -c "
source lib/cytadela-core.sh
source modules/integrity.sh
integrity_status
"

# Test z głównym skryptem (tymczasowy wrapper)
cat > test-integrity.sh <<'EOF'
#!/bin/bash
source lib/cytadela-core.sh
source lib/network-utils.sh
source modules/integrity.sh

case "${1:-status}" in
    init) integrity_init ;;
    check) integrity_check ;;
    status) integrity_status ;;
esac
EOF

chmod +x test-integrity.sh
sudo ./test-integrity.sh status
```

**Weryfikacja:**
- ✅ Moduł integrity działa standalone
- ✅ Wszystkie funkcje integrity_* dostępne
- ✅ Kompatybilność z obecnym API

---

#### **ETAP 4: Migracja Pozostałych Modułów (8-12h)**

**Kolejność migracji (od najprostszych do najbardziej złożonych):**

1. ✅ **modules/integrity.sh** (DONE w Etapie 3)
2. **modules/nft-debug.sh** - prosty, bez zależności
3. **modules/discover.sh** - używa network-utils
4. **modules/ghost-check.sh** - używa network-utils
5. **modules/emergency.sh** - panic/emergency modes
6. **modules/health.sh** - health checks
7. **modules/supply-chain.sh** - supply-chain verification
8. **modules/location.sh** - location-aware advisory
9. **modules/ipv6.sh** - IPv6 management (używa network-utils)
10. **modules/adblock.sh** - adblock management
11. **modules/lkg.sh** - Last Known Good (używa adblock)
12. **modules/install-dnscrypt.sh** - instalacja DNSCrypt
13. **modules/install-coredns.sh** - instalacja CoreDNS (używa adblock)
14. **modules/install-nftables.sh** - instalacja NFTables
15. **modules/install-all.sh** - pełna instalacja (używa install-*)
16. **modules/diagnostics.sh** - diagnostyka
17. **modules/extras.sh** - new features v3.0

**Szablon migracji modułu:**

```bash
# 1. Utworzenie pliku modułu
cat > modules/MODULE_NAME.sh <<'EOF'
#!/bin/bash
# Cytadela MODULE_NAME Module v3.1

# Dependency check (jeśli potrzebne)
# [[ -z "${CYTADELA_LOADED_MODULES[dependency]:-}" ]] && load_module dependency

# Funkcje modułu
function_name() {
    # ... kod z cytadela++.sh
}
EOF

# 2. Test modułu
bash -c "
source lib/cytadela-core.sh
source lib/network-utils.sh
source modules/MODULE_NAME.sh
function_name
"

# 3. Dodanie do MODULE_MAP w wrapper
# (zostanie zrobione w Etapie 5)
```

**Weryfikacja po każdym module:**
- ✅ Moduł działa standalone
- ✅ Wszystkie funkcje dostępne
- ✅ Testy jednostkowe przechodzą

---

#### **ETAP 5: Nowe Wrappery (3-4h)**

**Cel:** Utworzenie nowych cytadela++.sh i citadela_en.sh z lazy loading

**Krok 5.1:** Backup starych wrapperów

```bash
mv cytadela++.sh cytadela++.sh.old
mv citadela_en.sh citadela_en.sh.old
```

**Krok 5.2:** Utworzenie nowego `cytadela++.sh`

```bash
cat > cytadela++.sh <<'EOF'
#!/bin/bash
# Cytadela++ v3.1 - Polish Wrapper
# (pełna zawartość jak w ARCHITECTURE_DESIGN.md)
EOF

chmod +x cytadela++.sh
```

**Krok 5.3:** Utworzenie nowego `citadela_en.sh`

```bash
cat > citadela_en.sh <<'EOF'
#!/bin/bash
# Citadel++ v3.1 - English Wrapper
# (pełna zawartość jak w ARCHITECTURE_DESIGN.md)
EOF

chmod +x citadela_en.sh
```

**Krok 5.4:** Test wrapperów

```bash
# Test 1: Help
./cytadela++.sh help
./citadela_en.sh help

# Test 2: Integrity
sudo ./cytadela++.sh integrity-status
sudo ./citadela_en.sh integrity-status

# Test 3: Discover
sudo ./cytadela++.sh discover
sudo ./citadela_en.sh discover

# Test 4: Lazy loading (debug)
CYTADELA_DEBUG=1 sudo ./cytadela++.sh integrity-check
# Powinno pokazać: "Załadowano moduł: integrity"
```

**Weryfikacja:**
- ✅ Nowe wrappery działają
- ✅ Lazy loading działa
- ✅ Developer mode działa (auto-detect git repo)
- ✅ Wszystkie komendy dostępne

---

#### **ETAP 6: Instalacja do /opt/cytadela (2-3h)**

**Cel:** Utworzenie installera i instalacja do /opt

**Krok 6.1:** Utworzenie `install.sh`

```bash
cat > install.sh <<'EOF'
#!/bin/bash
# Cytadela++ Installer v3.1
set -euo pipefail

INSTALL_ROOT="/opt/cytadela"

echo "Installing Cytadela++ v3.1 to $INSTALL_ROOT..."

# Create directories
sudo mkdir -p "$INSTALL_ROOT"/{lib,modules,bin}

# Copy libraries
sudo cp -v lib/*.sh "$INSTALL_ROOT/lib/"
sudo chmod +x "$INSTALL_ROOT/lib/"*.sh

# Copy modules
sudo cp -v modules/*.sh "$INSTALL_ROOT/modules/"
sudo chmod +x "$INSTALL_ROOT/modules/"*.sh

# Copy version
sudo cp -v VERSION "$INSTALL_ROOT/version"

# Create symlinks for wrappers
sudo ln -sf "$(pwd)/cytadela++.sh" /usr/local/bin/cytadela++
sudo ln -sf "$(pwd)/citadela_en.sh" /usr/local/bin/citadela

echo "Installation complete!"
echo "Run: cytadela++ help"
EOF

chmod +x install.sh
```

**Krok 6.2:** Instalacja

```bash
sudo ./install.sh
```

**Krok 6.3:** Test instalacji

```bash
# Test 1: Komenda globalna
cytadela++ help
citadela help

# Test 2: Moduły z /opt
sudo cytadela++ integrity-status

# Test 3: Developer mode (z git repo)
cd /home/qguar/Cytadela
sudo ./cytadela++.sh integrity-status
# Powinno użyć lokalnych lib/ i modules/
```

**Weryfikacja:**
- ✅ Pliki w /opt/cytadela
- ✅ Symlinki w /usr/local/bin
- ✅ Komendy globalne działają
- ✅ Developer mode działa

---

#### **ETAP 7: Testy Regresji (4-6h)**

**Cel:** Pełne testy wszystkich funkcji

**Test Suite:**

```bash
#!/bin/bash
# Cytadela++ Regression Test Suite

echo "=== CYTADELA++ REGRESSION TESTS ==="

# Test 1: Core Functions
echo "Test 1: Core functions..."
sudo cytadela++ integrity-status || exit 1
sudo cytadela++ discover || exit 1
sudo cytadela++ health-status || exit 1

# Test 2: Adblock
echo "Test 2: Adblock..."
sudo cytadela++ adblock-status || exit 1
sudo cytadela++ adblock-stats || exit 1

# Test 3: LKG
echo "Test 3: LKG..."
sudo cytadela++ lkg-status || exit 1

# Test 4: Panic
echo "Test 4: Panic..."
sudo cytadela++ panic-status || exit 1

# Test 5: Location
echo "Test 5: Location..."
sudo cytadela++ location-status || exit 1

# Test 6: NFT Debug
echo "Test 6: NFT Debug..."
sudo cytadela++ nft-debug-status || exit 1

# Test 7: Supply Chain
echo "Test 7: Supply Chain..."
sudo cytadela++ supply-chain-status || exit 1

# Test 8: IPv6
echo "Test 8: IPv6..."
sudo cytadela++ ipv6-privacy-status || exit 1

# Test 9: Ghost Check
echo "Test 9: Ghost Check..."
sudo cytadela++ ghost-check || exit 1

# Test 10: Diagnostics
echo "Test 10: Diagnostics..."
sudo cytadela++ verify || exit 1

# Test 11: English version
echo "Test 11: English version..."
sudo citadela help || exit 1
sudo citadela integrity-status || exit 1

echo ""
echo "=== ALL TESTS PASSED ==="
```

**Weryfikacja:**
- ✅ Wszystkie testy przechodzą
- ✅ Brak regresji
- ✅ Wydajność nie spadła

---

#### **ETAP 8: Dokumentacja i Cleanup (2-3h)**

**Krok 8.1:** Aktualizacja README.md

```bash
cat >> README.md <<'EOF'

## Architecture v3.1 (Issues #11 & #12)

Cytadela++ v3.1 introduces modular architecture:

- **Deduplikacja:** Reduced code duplication from 7153 to ~6000 lines (50% savings)
- **Modularyzacja:** Lazy loading modules for better performance
- **Backward Compatibility:** All commands work identically

### Directory Structure

```
/opt/cytadela/
├── lib/          # Shared libraries
├── modules/      # Feature modules (lazy loaded)
└── bin/          # Binaries (CoreDNS, DNSCrypt)
```

### Developer Mode

When running from git repository, Cytadela++ automatically uses local `lib/` and `modules/`:

```bash
cd /home/qguar/Cytadela
sudo ./cytadela++.sh integrity-check  # Uses local files
```
EOF
```

**Krok 8.2:** Cleanup

```bash
# Usuń stare backupy (zostaw tylko w backup/)
rm -f cytadela++.sh.old citadela_en.sh.old

# Usuń tymczasowe pliki testowe
rm -f test-*.sh

# Git cleanup
git add -A
git status
```

**Krok 8.3:** Commit

```bash
git commit -m "Refactoring: Issues #11 #12 - Deduplikacja PL/EN + Modularyzacja

- Wydzielono cytadela-core.sh i network-utils.sh
- Utworzono 17 modułów z lazy loading
- Redukcja kodu o ~1150 linii (50% duplikacji)
- 100% backward compatibility
- Developer mode support
- Wszystkie testy regresji przechodzą

Closes #11
Closes #12"
```

---

### 3.3 ROLLBACK PLAN

**Jeśli coś pójdzie nie tak na dowolnym etapie:**

```bash
# Opcja 1: Rollback do poprzedniego commita
git reset --hard HEAD~1

# Opcja 2: Przywrócenie z backup
cp backup/pre-refactoring/cytadela++.sh.backup cytadela++.sh
cp backup/pre-refactoring/citadela_en.sh.backup citadela_en.sh
chmod +x cytadela++.sh citadela_en.sh

# Opcja 3: Przełączenie na main branch
git checkout main

# Opcja 4: Usunięcie /opt/cytadela (jeśli instalacja nie działa)
sudo rm -rf /opt/cytadela
sudo rm -f /usr/local/bin/cytadela++ /usr/local/bin/citadela
```

---

### 3.4 TIMELINE

| Etap | Czas | Opis |
|------|------|------|
| 0 | 1-2h | Przygotowanie i backup |
| 1 | 2-3h | Core libraries |
| 2 | 1-2h | i18n libraries |
| 3 | 2-3h | Pierwszy moduł (integrity) |
| 4 | 8-12h | Pozostałe moduły (17 modułów) |
| 5 | 3-4h | Nowe wrappery |
| 6 | 2-3h | Instalacja do /opt |
| 7 | 4-6h | Testy regresji |
| 8 | 2-3h | Dokumentacja i cleanup |
| **TOTAL** | **25-38h** | **~1 tydzień pracy** |

---

### 3.5 KRYTERIA SUKCESU

✅ **Funkcjonalność:**
- Wszystkie komendy działają identycznie jak przed refactoringiem
- Brak regresji w funkcjonalności
- Wszystkie testy przechodzą

✅ **Wydajność:**
- Lazy loading - szybsze uruchamianie
- Brak degradacji wydajności
- Mniejsze zużycie pamięci (ładowanie tylko potrzebnych modułów)

✅ **Utrzymywalność:**
- Kod łatwiejszy do utrzymania
- Jasna struktura modułów
- Dokumentacja aktualna

✅ **Bezpieczeństwo:**
- Integrity check dla wszystkich modułów
- Developer mode vs secure mode
- Brak regresji bezpieczeństwa

---

## NASTĘPNE KROKI

✅ **PHASE 3 PLAN GOTOWY**  
➡️ **Rozpoczęcie implementacji** lub **dalsze pytania/modyfikacje**

**Gotowy do rozpoczęcia migracji?**
