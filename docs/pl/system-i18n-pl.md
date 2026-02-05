# System Internacjonalizacji (i18n)

## Przegląd

Cytadela używa elastycznego systemu internacjonalizacji obsługującego 7 języków:
- 🇵🇱 Polish (pl)
- 🇬🇧 English (en) - domyślny
- 🇩🇪 German (de)
- 🇪🇸 Spanish (es)
- 🇮🇹 Italian (it)
- 🇫🇷 French (fr)
- 🇷🇺 Russian (ru)

## Struktura Plików

```
lib/i18n/
├── common/           # Wspólne stringi dla wszystkich modułów
│   ├── en.sh
│   ├── pl.sh
│   ├── de.sh
│   ├── es.sh
│   ├── it.sh
│   ├── fr.sh
│   └── ru.sh
└── [module]/         # Tłumaczenia specyficzne dla modułu
    ├── en.sh
    └── pl.sh
```

## Dodawanie Nowego Języka

1. Utwórz pliki językowe w `lib/i18n/common/` i `lib/i18n/[module]/`
2. Przestrzegaj konwencji nazewnictwa: `[kod_języka].sh`
3. Skopiuj strukturę z istniejącego języka (np. `en.sh`)
4. Przetłumacz wszystkie stringi
5. Dodaj język do `detect_language()` w `lib/cytadela-core.sh`

## Format Plików Językowych

```bash
#!/bin/bash
# strings_[LANG].sh - Tłumaczenia [Nazwa Języka]

# Module: [nazwa_modułu]
I18N_MODULE_NAME="Przetłumaczona Nazwa Modułu"
I18N_WELCOME="Komunikat powitalny"
# ... itp
```

## Ładowanie Tłumaczeń

```bash
# W Twoim module
load_i18n_module "nazwa_modułu"
```

To automatycznie ładuje:
1. Wspólne stringi dla aktualnego języka
2. Stringi specyficzne dla modułu dla aktualnego języka
3. Fallback do angielskiego jeśli tłumaczenie brakuje

## Testowanie Tłumaczeń

```bash
# Wymuś konkretny język
CYTADELA_LANG=pl sudo ./citadel.sh [polecenie]

# Sprawdź załadowane stringi
sudo ./citadel.sh debug-i18n
```

## Aktualny Status

- ✅ install-wizard: 7 języków
- ⚠️  Inne moduły: tylko EN/PL (v3.2+)
