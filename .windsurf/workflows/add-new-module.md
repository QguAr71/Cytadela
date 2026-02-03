---
description: How to add a new Citadel++ module with full i18n support
---

# Dodawanie nowego modułu do Citadel++

## Krok 1: Utwórz plik modułu

```bash
cp modules/module-template.sh modules/my-new-module.sh
```

## Krok 2: Wypełnij metadane modułu

Edytuj sekcję MODULE METADATA:

```bash
MODULE_NAME="my-new-module"           # Unikalna nazwa
MODULE_VERSION="1.0.0"                # Wersja semver
MODULE_DESCRIPTION="Co robi ten moduł"
MODULE_AUTHOR="Twoje Imię"
MODULE_DEPENDS=("curl" "jq")          # Wymagane narzędzia
MODULE_TAGS=("network" "security")    # Kategorie
```

## Krok 3: Dodaj tłumaczenia i18n

// turbo
Dla każdego języka w `lib/i18n/` dodaj zmienne T_*:

```bash
# lib/i18n/en.sh
export T_MYMODULE_TITLE="My Module"
export T_MYMODULE_RUNNING="Running..."

# lib/i18n/pl.sh
export T_MYMODULE_TITLE="Mój Moduł"
export T_MYMODULE_RUNNING="Uruchamianie..."
```

## Krok 4: Zaimplementuj funkcje

Główne funkcje modułu:

```bash
my_new_module() {
    # Wczytaj i18n
    load_i18n_module "my-module"
    
    # Użyj fioletowej ramki z szablonu
    draw_section_header "${T_MYMODULE_TITLE:-My Module}"
    
    # Używaj zmiennych T_* z fallbackiem
    log_info "${T_MYMODULE_RUNNING:-Running...}"
}

my_new_module_help() {
    cat <<'EOF'
${T_MYMODULE_USAGE:-USAGE}: cytadela++ my-new-module [run|help]
EOF
}
```

### Ramki UI

Używaj funkcji z `lib/frame-ui.sh`:

- `draw_section_header "Tytuł"` - fioletowa ramka z nagłówkiem
- `draw_emergency_frame "Tytuł"` - czerwona ramka (awaryjna)
- `print_frame_line "tekst"` - pojedyncza linia z obramowaniem

Przykład:
```bash
draw_section_header "${T_MYMODULE_TITLE:-My Module}"
print_frame_line "${T_STEP_1:-Step 1}: ${T_CONFIGURING:-Configuring...}"
print_frame_line "${T_STEP_2:-Step 2}: ${T_VERIFYING:-Verifying...}"
echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"
```

## Krok 5: Testuj moduł

// turbo
```bash
# Test działania
sudo ./citadel.sh my-new-module

# Test help
sudo ./citadel.sh my-new-module help

# Sprawdź czy i18n działa
LANG=pl_PL.UTF-8 sudo ./citadel.sh my-new-module
```

## Krok 6: Zacommituj zmiany

```bash
git add modules/my-new-module.sh lib/i18n/*.sh
git commit -m "Add my-new-module with full i18n support"
```

## Wymagania (wymuszane w PR)

- [ ] Wszystkie stringi użytkownika używają `T_*` variables
- [ ] Tłumaczenia dodane do wszystkich 7 języków
- [ ] Moduł ma funkcję `help`
- [ ] Metadata MODULE_* wypełniona
- [ ] Przetestowane lokalnie
- [ ] Brak hardcoded strings

## Przykładowe moduły (wzorce)

- `modules/check-dependencies.sh` - pełne i18n, auto-install
- `modules/uninstall.sh` - kompletne tłumaczenia
- `modules/install-wizard.sh` - dynamiczne i18n

## Wskazówki

- Używaj `log_info`, `log_success`, `log_warning`, `log_error` zamiast `echo`
- Zawsze dodawaj fallback `${T_VAR:-default}`
- Testuj w różnych językach przed commitem
- Jeśli moduł potrzebuje konfiguracji - użyj `lib/config.sh`
