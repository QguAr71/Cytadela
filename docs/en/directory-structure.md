# Struktura katalogów Citadel v3.3

Ten dokument opisuje organizację katalogów w repozytorium Citadel zgodnie z najlepszymi standardami.

## 🏗️ Struktura katalogów

```
citadel/
├── 📁 .github/                    # Konfiguracja GitHub (workflows, issues)
├── 📁 docs/                       # Dokumentacja
│   ├── 📁 en/                     # Dokumentacja angielska
│   │   ├── 📄 README_EN.md        # Główna dokumentacja EN
│   │   └── 📁 user/               # Dokumentacja użytkownika EN
│   └── 📁 pl/                     # Dokumentacja polska
│       ├── 📄 README_PL.md        # Główna dokumentacja PL
│       ├── 📄 komendy_pl.md       # Referencja komend PL
│       ├── 📄 szybki_start_pl.md  # Szybki start PL
│       ├── 📄 rozwiązywanie_problemów_pl.md # Troubleshooting PL
│       └── 📄 dziennik_zmian_pl.md # Changelog PL
├── 📁 lib/                        # Biblioteki modułów
│   ├── 📄 reputation.sh           # System reputacji
│   ├── 📄 asn-blocking.sh         # Blokowanie ASN
│   ├── 📄 event-logger.sh         # Logowanie zdarzeń
│   ├── 📄 honeypot.sh             # Honeypot
│   ├── 📄 config-management.sh    # Zarządzanie konfiguracją
│   ├── 📄 module-management.sh    # Zarządzanie modułami
│   ├── 📄 advanced-management.sh  # Zaawansowane zarządzanie
│   └── 📄 enterprise-features.sh  # Funkcje korporacyjne
├── 📁 modules/                    # Moduły zunifikowane
│   └── 📁 unified/
│       └── 📄 unified-security.sh # Zunifikowany moduł bezpieczeństwa
├── 📁 scripts/                    # Skrypty instalacyjne i narzędziowe
│   ├── 📄 citadel-install-cli.sh  # Instalator CLI
│   ├── 📄 citadel-dashboard.sh    # Dashboard TUI
│   └── 📄 install-citadel-direct.sh # Bezpośrednia instalacja
├── 📁 config/                     # Szablony konfiguracji
├── 📁 examples/                   # Przykładowe konfiguracje i skrypty
│   ├── 📄 basic-config.yaml       # Podstawowa konfiguracja
│   ├── 📄 enterprise-config.yaml  # Konfiguracja korporacyjna
│   └── 📄 basic-install.sh        # Skrypt instalacji podstawowej
├── 📁 tests/                      # Testy i narzędzia testowe
├── 📁 legacy/                     # Starsze wersje (zachowane dla kompatybilności)
├── 📄 citadel.sh                  # Główny plik wykonywalny
├── 📄 README.md                   # Główna dokumentacja (EN)
├── 📄 CHANGELOG.md                # Historia zmian
├── 📄 LICENSE                     # Licencja
├── 📄 VERSION                     # Wersja
├── 📄 INSTALL.md                  # Instrukcje instalacji
├── 📄 .gitignore                  # Reguły git ignore
├── 📄 .shellcheckrc               # Konfiguracja ShellCheck
└── 📁 backup/                     # Kopie zapasowe (puste)
```

## 📂 Opis katalogów

### 🔧 Katalogi główne

#### `/` - Katalog główny
- **Pliki wykonywalne**: `citadel.sh` (główny plik)
- **Dokumentacja projektu**: `README.md`, `CHANGELOG.md`, `LICENSE`
- **Konfiguracja**: `.gitignore`, `.shellcheckrc`
- **Metadane**: `VERSION`, `INSTALL.md`

#### `docs/` - Dokumentacja
- **`en/`**: Dokumentacja angielska
  - `README_EN.md` - Główna dokumentacja
  - `user/` - Dokumentacja użytkownika
- **`pl/`**: Dokumentacja polska
  - `README_PL.md` - Główna dokumentacja PL
  - `komendy_pl.md` - Referencja komend
  - `szybki_start_pl.md` - Szybki start
  - `rozwiązywanie_problemów_pl.md` - Troubleshooting
  - `dziennik_zmian_pl.md` - Changelog

#### `lib/` - Biblioteki modułów
- **Moduły bezpieczeństwa**: `reputation.sh`, `asn-blocking.sh`, `honeypot.sh`
- **Moduły systemowe**: `event-logger.sh`, `config-management.sh`
- **Moduły zarządzania**: `module-management.sh`, `advanced-management.sh`
- **Moduły enterprise**: `enterprise-features.sh`

#### `modules/` - Moduły zunifikowane
- **`unified/`**: Moduły główne systemu
  - `unified-security.sh` - Zunifikowany moduł bezpieczeństwa

#### `scripts/` - Skrypty instalacyjne
- **`citadel-install-cli.sh`**: Główny instalator CLI z profilami
- **`citadel-dashboard.sh`**: Interaktywny dashboard TUI
- **`install-citadel-direct.sh`**: Bezpośrednia instalacja

#### `config/` - Szablony konfiguracji
- Przykładowe pliki konfiguracyjne YAML
- Szablony dla różnych środowisk

#### `examples/` - Przykłady użycia
- **`basic-config.yaml`**: Podstawowa konfiguracja
- **`enterprise-config.yaml`**: Konfiguracja korporacyjna
- **`basic-install.sh`**: Skrypt instalacji podstawowej

#### `tests/` - Testy i QA
- Testy jednostkowe i integracyjne
- Narzędzia testowe
- Konfiguracja CI/CD

#### `legacy/` - Starsze wersje
- Zachowane dla kompatybilności wstecznej
- Starsze wersje Citadel (v3.0, etc.)

### 🔗 Zależności między katalogami

```
citadel.sh (główny)
├── lib/ (biblioteki)
├── modules/ (moduły zunifikowane)
├── scripts/ (narzędzia instalacyjne)
└── config/ (konfiguracje)

docs/ (dokumentacja)
├── en/ (angielski)
└── pl/ (polski)

examples/ (przykłady)
└── config/ (szablony konfiguracji)
```

## 📋 Standardy organizacji

### ✅ Zasady nazewnictwa

1. **Pliki wykonywalne**: `kebab-case` (np. `citadel.sh`, `citadel-install-cli.sh`)
2. **Biblioteki**: `kebab-case.sh` (np. `reputation.sh`, `config-management.sh`)
3. **Dokumentacja**: `UPPER_CASE.md` dla głównych, `snake_case.md` dla pozostałych
4. **Katalogi**: `kebab-case` dla funkcjonalności, `en/pl` dla języków

### ✅ Struktura hierarchiczna

1. **Poziom główny**: Pliki wykonywalne i metadane projektu
2. **Poziom funkcjonalny**: `lib/`, `modules/`, `scripts/`
3. **Poziom wsparcia**: `docs/`, `examples/`, `tests/`
4. **Poziom archiwalny**: `legacy/`, `backup/`

### ✅ Separacja odpowiedzialności

- **`citadel.sh`**: Jedyny punkt wejścia, dispatcher komend
- **`lib/`**: Czyste funkcje, brak efektów ubocznych
- **`modules/`**: Logika biznesowa, integracja funkcji
- **`scripts/`**: Automatyzacja, instalacja, narzędzia
- **`docs/`**: Dokumentacja dla wszystkich języków
- **`examples/`**: Rzeczywiste przykłady użycia
- **`tests/`**: Zapewnienie jakości i niezawodności

### ✅ Najlepsze praktyki

1. **Zgodność wsteczna**: `legacy/` dla starszych wersji
2. **Wielojęzyczność**: `docs/en/`, `docs/pl/` dla dokumentacji
3. **Modularność**: Oddzielne biblioteki i moduły
4. **Testowalność**: Dedykowany katalog `tests/`
5. **Przykłady**: Rzeczywiste konfiguracje w `examples/`

## 🔄 Migracja ze starej struktury

Jeśli migrujesz ze starszej wersji Citadel:

### Zmiany struktury
- `doc pl/` → `docs/pl/`
- Skrypty instalacyjne → `scripts/`
- Przykłady → `examples/`
- Testy → `tests/`

### Aktualizacja ścieżek
```bash
# Stara struktura
./citadel-install-cli.sh
./doc pl/README_PL.md

# Nowa struktura
./scripts/citadel-install-cli.sh
./docs/pl/README_PL.md
```

### Zachowana kompatybilność
- Wszystkie główne pliki wykonywalne w katalogu głównym
- Ścieżki względne działają bez zmian
- Symboleczne linki dla wstecznej kompatybilności

---

*Tę strukturę można rozszerzać zachowując opisane zasady organizacji.*
