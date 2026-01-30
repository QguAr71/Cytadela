# FUTURE ENHANCEMENTS - Do zrobienia później
**Features odłożone na v3.1.1 lub v3.2**

---

## OPCJA C - Features pominięte w refactoringu v3.1

### Issue #26: i18n jako Associative Arrays
**Priorytet:** Niski  
**Effort:** 1h  
**Target:** v3.1.1 lub gdy dodamy 3+ języki

**Opis:**
Zamiast osobnych plików `i18n-pl.sh` i `i18n-en.sh`, użyj associative arrays:

```bash
# lib/cytadela-core.sh
declare -gA MSG_PL=(
    [ROOT_REQUIRED]="Ten skrypt wymaga uprawnień root"
    [MODULE_NOT_FOUND]="Moduł nie znaleziony"
    [LOADING_MODULE]="Ładowanie modułu"
    # ... więcej
)

declare -gA MSG_EN=(
    [ROOT_REQUIRED]="This script requires root privileges"
    [MODULE_NOT_FOUND]="Module not found"
    [LOADING_MODULE]="Loading module"
    # ... więcej
)

# Wrapper wybiera język
LANG="${CYTADELA_LANG:-pl}"
msg() {
    local key="$1"
    case "$LANG" in
        pl) echo "${MSG_PL[$key]}" ;;
        en) echo "${MSG_EN[$key]}" ;;
        *) echo "${MSG_EN[$key]}" ;;
    esac
}
```

**Zalety:**
- Łatwiejsze dodawanie języków (DE, FR, etc.)
- Centralna definicja komunikatów
- Mniej plików

**Kiedy zrobić:**
- Gdy dodajemy 3+ języki
- Lub w v3.1.1 jako cleanup

---

### Issue #27: Module Metadata Headers
**Priorytet:** Niski  
**Effort:** 1h  
**Target:** v3.1.1

**Opis:**
Dodaj metadata headers do każdego modułu:

```bash
#!/bin/bash
# Cytadela Integrity Module v3.1
# @module integrity
# @version 3.1.0
# @requires cytadela-core network-utils
# @provides integrity_init integrity_check integrity_status integrity_verify_file
# @description Local-First integrity verification (Issue #1)
```

**Użycie:**
```bash
# Auto-load dependencies
load_module() {
    local module="$1"
    local deps=$(grep '^# @requires' "${CYTADELA_MODULES}/${module}.sh" | cut -d' ' -f3-)
    for dep in $deps; do
        load_module "$dep"
    done
    source "${CYTADELA_MODULES}/${module}.sh"
}
```

**Zalety:**
- Auto-loading dependencies
- Dokumentacja w kodzie
- Możliwość `module-info` command

**Kiedy zrobić:**
- v3.1.1 jako enhancement
- Lub gdy dependencies staną się bardziej złożone

---

### Issue #28: --version i --debug Flags
**Priorytet:** Niski  
**Effort:** 30 min  
**Target:** v3.1.1

**Opis:**
Dodaj standardowe CLI flagi:

```bash
# Wrapper
case "$1" in
    --version|-v)
        echo "Cytadela++ v${CYTADELA_VERSION}"
        [[ -n "${CYTADELA_GIT_COMMIT:-}" ]] && echo "Commit: ${CYTADELA_GIT_COMMIT}"
        exit 0
        ;;
    --debug|-d)
        export CYTADELA_DEBUG=1
        shift
        ;;
esac
```

**Użycie:**
```bash
cytadela++ --version
# Cytadela++ v3.1.0

cytadela++ --debug integrity-check
# [DEBUG] Loading module: integrity
# [DEBUG] Verifying /etc/cytadela/manifest.sha256
```

**Kiedy zrobić:**
- v3.1.1 jako quick win
- Bardzo łatwe do dodania

---

### Issue #29: module-list Command
**Priorytet:** Niski  
**Effort:** 30 min  
**Target:** v3.1.1

**Opis:**
Komenda listująca dostępne moduły:

```bash
module_list() {
    log_section "📦 AVAILABLE MODULES"
    
    for module in "${CYTADELA_MODULES}"/*.sh; do
        local name=$(basename "$module" .sh)
        local desc=$(grep '^# @description' "$module" 2>/dev/null | cut -d' ' -f3- || echo "No description")
        local version=$(grep '^# @version' "$module" 2>/dev/null | cut -d' ' -f3 || echo "unknown")
        
        printf "  %-20s %s (v%s)\n" "$name" "$desc" "$version"
    done
}
```

**Użycie:**
```bash
cytadela++ module-list
# Output:
#   integrity            Local-First integrity verification (v3.1.0)
#   adblock              Adblock management (v3.1.0)
#   emergency            Panic/emergency modes (v3.1.0)
```

**Kiedy zrobić:**
- v3.1.1 po dodaniu metadata (#27)
- Lub jako standalone z `ls` fallback

---

### Issue #25: Interactive Module Installer (już zapisany)
**Priorytet:** Średni  
**Effort:** 3-4h  
**Target:** v3.1.1 lub v3.2

Zobacz: `FUTURE_INTERACTIVE_INSTALLER.md`

---

## PODSUMOWANIE

**Features do zrobienia później:**
- #25 Interactive installer (3-4h) - v3.1.1
- #26 i18n arrays (1h) - v3.1.1 lub gdy 3+ języki
- #27 Module metadata (1h) - v3.1.1
- #28 --version/--debug (30min) - v3.1.1
- #29 module-list (30min) - v3.1.1

**Total effort:** ~6-7h  
**Target release:** v3.1.1 (za 1-2 miesiące po v3.1)

---

**Notatka:** Te features są nice-to-have, ale nie krytyczne dla v3.1. Skupiamy się teraz na solidnym, niezawodnym refactoringu (Opcja B).
