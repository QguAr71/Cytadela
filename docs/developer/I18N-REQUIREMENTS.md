# Wymagania i18n dla modułów Cytadela++

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

### 3. Tłumaczenia w obu plikach

Każda zmienna T_* musi być zdefiniowana w:
- `lib/i18n/en.sh` - angielski (fallback)
- `lib/i18n/pl.sh` - polski

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
- [ ] Dodano tłumaczenia do `lib/i18n/en.sh`
- [ ] Dodano tłumaczenia do `lib/i18n/pl.sh`
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

Odpowiednie tłumaczenia w `lib/i18n/en.sh` i `lib/i18n/pl.sh`.

---

**Data utworzenia:** 2026-02-02  
**Autor:** Cytadela++ Team
