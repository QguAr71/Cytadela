# Wymagania i18n dla modułów Citadel

> **WAŻNE:** Każdy nowo dodany moduł MUSI mieć pełną obsługę i18n (internationalization).

## Zasady

### 1. Wszystkie stringi użytkownika przez T_* zmienne

**ZAKAZANE:**
```bash
log_info "Installing packages..."
echo "Checking dependencies"
whiptail --title "Citadel Setup"
```

**WYMAGANE:**
```bash
log_info "${T_INSTALLING_PACKAGES:-Installing packages...}"
echo "${T_CHECKING_DEPS:-Checking dependencies}"
whiptail --title "${T_SETUP_TITLE:-Citadel Setup}"
```

### 2. Struktura zmiennych

- Prefix: `T_`
- Nazwa: opisowa, wielkie litery, underscore
- Przykłady: `T_CHECK_DEPS_TITLE`, `T_INSTALL_SUCCESS`, `T_DNS_FAILED`

### 3. Tłumaczenia we wszystkich 7 językach

Każda zmienna T_* musi być zdefiniowana w:
- `lib/i18n/en.sh` - angielski (fallback)
- `lib/i18n/pl.sh` - polski
- `lib/i18n/de.sh` - niemiecki
- `lib/i18n/es.sh` - hiszpański
- `lib/i18n/fr.sh` - francuski
- `lib/i18n/it.sh` - włoski
- `lib/i18n/ru.sh` - rosyjski

### 4. Format plików i18n

```bash
# lib/i18n/en.sh
export T_MODULE_ACTION_DESC="English description"

# lib/i18n/pl.sh
export T_MODULE_ACTION_DESC="Polski opis"
```

## Checklist przed mergem

- [ ] Brak hardcoded stringów w kodzie modułu
- [ ] Wszystkie `echo` używają `T_*`
- [ ] Wszystkie `log_*` używają `T_*`
- [ ] Wszystkie `whiptail` używają `T_*`
- [ ] Help/dokumentacja modułu używa `T_*`
- [ ] Dodano tłumaczenia do `lib/i18n/en.sh` (angielski - fallback)
- [ ] Dodano tłumaczenia do `lib/i18n/pl.sh` (polski)
- [ ] Dodano tłumaczenia do `lib/i18n/de.sh` (niemiecki)
- [ ] Dodano tłumaczenia do `lib/i18n/es.sh` (hiszpański)
- [ ] Dodano tłumaczenia do `lib/i18n/fr.sh` (francuski)
- [ ] Dodano tłumaczenia do `lib/i18n/it.sh` (włoski)
- [ ] Dodano tłumaczenia do `lib/i18n/ru.sh` (rosyjski)
- [ ] Nazwy zmiennych są unikalne i opisowe

## Przykład kompletnego modułu z i18n

```bash
#!/bin/bash
# modules/example-module.sh

example_function() {
    log_section "🔧 ${T_EXAMPLE_TITLE:-Example Module}"
    
    log_info "${T_EXAMPLE_STARTING:-Starting example process...}"
    
    if some_command; then
        log_success "${T_EXAMPLE_SUCCESS:-Example completed successfully!}"
    else
        log_error "${T_EXAMPLE_FAILED:-Example failed!}"
        return 1
    fi
}

example_help() {
    cat <<EOF
${T_EXAMPLE_TITLE:-EXAMPLE MODULE}

${T_USAGE:-USAGE}:
  cytadela++ example-command

${T_DESCRIPTION:-DESCRIPTION}:
  ${T_EXAMPLE_DESC:-Does something useful.}
EOF
}
```

Odpowiednie tłumaczenia w `lib/i18n/*.sh` dla wszystkich 7 języków.

## Workflow dla nowych modułów

Użyj workflow dostępnego w:
```bash
.windsurf/workflows/add-new-module.md
```

Lub szybka ściągawka:
1. Utwórz moduł używając `T_*` zmiennych
2. Dodaj tłumaczenia do wszystkich 7 plików w `lib/i18n/`
3. Przetestuj w co najmniej 2 językach
4. Upewnij się, że wszystkie stringi mają fallback `${T_VAR:-domyślny}`

---

**Data utworzenia:** 2026-02-02  
**Autor:** Citadel Team
