# Współtworzenie Cytadeli

Dziękujemy za zainteresowanie współtworzeniem Cytadeli! Ten dokument zawiera wytyczne dotyczące współtworzenia projektu.

## 🎯 Filozofia Projektu

Cytadela to **projekt hobbystyczny** skupiający się na:
- **Stos DNS skupiony na prywatności** (DNSCrypt + CoreDNS + NFTables)
- **Kontrola tylko lokalna** (bez chmury, bez telemetrii)
- **Wzmocnienie bezpieczeństwa** (zapobieganie wyciekom, sprawdzenia integralności)
- **Prostocie** (skrypty Bash, zależności systemowe)

## 🤝 Jak Współtworzyć

### Zgłaszanie Problemów

Przed utworzeniem zgłoszenia:
1. Sprawdź [istniejące zgłoszenia](https://github.com/QguAr71/Cytadela/issues)
2. Przeszukaj [zamknięte zgłoszenia](https://github.com/QguAr71/Cytadela/issues?q=is%3Aissue+is%3Aclosed)
3. Przejrzyj [ROADMAP.md](ROADMAP.md) pod kątem planowanych funkcji

**Dobre zgłoszenia problemów zawierają:**
- Jasny opis problemu
- Kroki do odtworzenia
- Oczekiwane vs rzeczywiste zachowanie
- Informacje o systemie (OS, wersja, architektura)
- Istotne logi (z `cytadela++ diagnostics`)

**Użyj szablonów zgłoszeń:**
- Bug Report: `.github/ISSUE_TEMPLATE/bug_report.md`
- Feature Request: `.github/ISSUE_TEMPLATE/feature_request.md`

### Sugerowanie Funkcji

Prośby o funkcje są mile widziane! Proszę:
1. Najpierw sprawdzić [ROADMAP.md](ROADMAP.md)
2. Wyjaśnić **przypadek użycia** (nie tylko funkcję)
3. Rozważyć **implikacje bezpieczeństwa**
4. Zachować skupienie na **prywatności**

**Obszary priorytetowe (v3.2+):**
- Ulepszenia monitorowania/metryk
- Ulepszenia automatyzacji
- Wzmocnienie bezpieczeństwa
- Poprawy dokumentacji

### Pull Requests

**Przed wysłaniem PR:**
1. Zrób fork repozytorium
2. Utwórz gałąź funkcji (`git checkout -b feature/amazing-feature`)
3. Wykonaj swoje zmiany
4. Uruchom testy (zobacz sekcję Testowanie poniżej)
5. Zaktualizuj dokumentację jeśli potrzebne
6. Commit z jasnymi komunikatami

**Wytyczne PR:**
- Jedna funkcja/poprawka na PR
- Przestrzegaj istniejącego stylu kodu
- Dodaj testy dla nowych funkcji
- Zaktualizuj istotną dokumentację
- Odwołaj się do powiązanych zgłoszeń

**Lista Sprawdzająca PR:**
- [ ] Kod przestrzega stylu projektu (najlepsze praktyki Bash)
- [ ] Wszystkie testy przechodzą (`./tests/smoke-test.sh`)
- [ ] ShellCheck przechodzi (bez ostrzeżeń)
- [ ] Dokumentacja zaktualizowana
- [ ] **i18n kompletne** (jeśli dodajesz/modyfikujesz moduły - zobacz sekcję i18n poniżej)
- [ ] Komunikaty commit są jasne
- [ ] Brak zmian łamiących (lub jasno udokumentowanych)

## 🧪 Testowanie

### Uruchamianie Testów

**Testy Smoke (bez sudo wymagane):**
```bash
cd /path/to/Cytadela
./tests/smoke-test.sh
```

**Testy Integracyjne (wymaga sudo):**
```bash
sudo ./tests/integration-test.sh
```

**ShellCheck:**
```bash
shellcheck -S warning -e SC2034 cytadela++.sh lib/*.sh modules/*.sh
```

### Pisanie Testów

Podczas dodawania nowych funkcji:
1. Dodaj testy smoke do `tests/smoke-test.sh`
2. Dodaj testy integracyjne do `tests/integration-test.sh`
3. Zapewnij że testy są idempotentne
4. Udokumentuj oczekiwane zachowanie

Zobacz `tests/README.md` po szczegóły framework testowania.

## 📝 Styl Kodu

### Najlepsze Praktyki Bash

**Wymagane:**
- Użyj `set -euo pipefail` na początku skryptu
- Cytuj wszystkie zmienne: `"$variable"`
- Użyj `[[ ]]` zamiast `[ ]`
- Sprawdzaj sukces polecenia: `if command; then`
- Użyj funkcji dla kodu wielokrotnego użytku
- Dodaj obsługę błędów

**Konwencje nazewnictwa:**
- Funkcje: `snake_case` (np., `install_coredns`)
- Zmienne: `UPPER_CASE` dla globalnych, `lower_case` dla lokalnych
- Pliki: `kebab-case.sh` (np., `module-loader.sh`)

**Przykład:**
```bash
#!/bin/bash
set -euo pipefail

my_function() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Error: input required" >&2
        return 1
    fi
    
    echo "Processing: $input"
}
```

### Zagadnienia Bezpieczeństwa

**Zawsze:**
- Waliduj wejście użytkownika
- Używaj ścieżek absolutnych
- Sprawdzaj uprawnienia plików
- Unikaj `eval` i command injection
- Używaj `mktemp` dla plików tymczasowych
- Czyść przy wyjściu (trap)

**Nigdy:**
- Nie ufaj zewnętrznemu wejściu bez walidacji
- Nie używaj `curl` bez HTTPS
- Nie przechowuj sekretów w kodzie
- Nie uruchamiaj niepotrzebnych poleceń jako root

## 📚 Dokumentacja

### Co Dokumentować

**Dokumentacja kodu:**
- Cel funkcji i parametry
- Wyjaśnienia złożonej logiki
- Zagadnienia bezpieczeństwa
- Znane ograniczenia

**Dokumentacja użytkownika:**
- Zaktualizuj `CYTADELA_INSTRUKCJA.md` (Polski)
- Zaktualizuj `CITADEL_EN_COMPLETE_MANUAL.md` (Angielski)
- Zaktualizuj `README.md` jeśli potrzebne
- Dodaj przykłady dla nowych funkcji

### Styl Dokumentacji

- Jasny i zwięzły
- Zawiera przykłady
- Wyjaśnia **dlaczego**, nie tylko **co**
- Używa właściwego formatowania (Markdown)

## 🔒 Bezpieczeństwo

### Zgłaszanie Problemów Bezpieczeństwa

**NIE** otwieraj publicznych zgłoszeń dla podatności bezpieczeństwa.

Zamiast tego:
1. Wyślij email do opiekuna (sprawdź profil GitHub)
2. Dołącz szczegółowy opis
3. Podaj kroki do odtworzenia
4. Zaproponuj poprawkę jeśli możliwe

Odpowiemy w ciągu 48 godzin.

### Proces Recenzji Bezpieczeństwa

Wszystkie PR związane z bezpieczeństwem będą:
1. Dokładnie przejrzane
2. Dokładnie przetestowane
3. Udokumentowane w notkach wydania
4. Odpowiednio przypisane

## 🌍 Internacjonalizacja (i18n)

Cytadela wspiera **7 języków** z pełnymi tłumaczeniami:
- 🇵🇱 Polish (pl)
- 🇬🇧 English (en)
- 🇩🇪 German (de)
- 🇪🇸 Spanish (es)
- 🇮🇹 Italian (it)
- 🇫🇷 French (fr)
- 🇷🇺 Russian (ru)

### Dla Nowych Modułów

**Każdy nowy moduł MUSI mieć pełną obsługę i18n.** Przestrzegaj workflow:
```bash
# Użyj nowego workflow modułu
cat .windsurf/workflows/add-new-module.md
```

**Wymagania:**
1. Wszystkie widoczne dla użytkownika stringi używają wzorca `${T_VAR:-fallback}`
2. Dodaj tłumaczenia do WSZYSTKICH 7 plików językowych w `lib/i18n/`:
   - `en.sh`, `pl.sh`, `de.sh`, `es.sh`, `fr.sh`, `it.sh`, `ru.sh`
3. Używaj opisowych nazw zmiennych: `T_MODULE_ACTION_DESC`
4. Dołącz tłumaczenia tekstu pomocy
5. Testuj w przynajmniej 2 językach przed wysłaniem PR

**Przykład:**
```bash
# W Twoim module
log_info "${T_MYMODULE_RUNNING:-Running my module...}"

# W lib/i18n/en.sh
export T_MYMODULE_RUNNING="Running my module..."

# W lib/i18n/pl.sh
export T_MYMODULE_RUNNING="Uruchamianie mojego modułu..."
# ... i 5 więcej języków
```

**Lista Sprawdzająca PR dla i18n:**
- [ ] Wszystkie stringi używają zmiennych `T_*` (bez zakodowanego tekstu)
- [ ] Tłumaczenia dodane do wszystkich 7 plików językowych
- [ ] Tekst pomocy przetłumaczony
- [ ] Przetestowane z `LANG=pl_PL.UTF-8` i `LANG=en_US.UTF-8`
- [ ] Workflow `.windsurf/workflows/add-new-module.md` przestrzegany

Zobacz `docs/developer/I18N-REQUIREMENTS.md` po szczegółowe wytyczne.

## 🎨 Struktura Projektu

```
Cytadela/
├── cytadela++.new.sh          # Główny wrapper polski
├── citadela_en.new.sh         # Główny wrapper angielski
├── lib/                       # Biblioteki rdzenia
│   ├── cytadela-core.sh       # Funkcje rdzenia
│   ├── module-loader.sh       # Ładowanie modułów
│   ├── i18n-pl.sh            # Tłumaczenia polskie
│   └── i18n-en.sh            # Tłumaczenia angielskie
├── modules/                   # Moduły funkcjonalne
│   ├── install-*.sh          # Moduły instalacji
│   ├── diagnostics.sh        # Diagnostyka
│   ├── adblock.sh            # Zarządzanie adblock
│   └── ...                   # Inne moduły
├── tests/                     # Framework testowania
│   ├── smoke-test.sh         # Testy poziomu 2
│   ├── integration-test.sh   # Testy poziomu 3
│   └── README.md             # Dokumentacja testowania
└── docs/                      # Dokumentacja
```

## 🚀 Proces Wydania

Wydania są zarządzane przez opiekuna:
1. Bump wersji (semantic versioning)
2. Zaktualizuj CHANGELOG
3. Uruchom pełny zestaw testów
4. Utwórz tag git
5. Opublikuj wydanie GitHub

Zobacz `CYTADELA_PUBLIKACJA.md` po szczegółowy proces wydania.

## 📞 Komunikacja

### Gdzie Zadawać Pytania

- **GitHub Issues:** Zgłoszenia błędów, prośby o funkcje
- **GitHub Discussions:** Ogólne pytania, pomysły (jeśli włączone)
- **Pull Requests:** Recenzja kodu, dyskusja implementacji

### Czas Odpowiedzi

To projekt hobbystyczny:
- Zgłoszenia: Odpowiedź w ciągu 1-7 dni
- PR: Recenzja w ciągu 1-14 dni
- Bezpieczeństwo: Odpowiedź w ciągu 48 godzin

Proszę o cierpliwość!

## 🏆 Uznanie

Współtwórcy będą:
- Wymienieni w notkach wydania
- Przypisani w komunikatach commit
- Wspomniani w dokumentacji (przy znacznym wkładzie)

## 📜 Licencja

Współtworząc, zgadzasz się że Twoje wkłady będą licencjonowane na **GNU General Public License v3.0**.

Zobacz [LICENSE](LICENSE) po szczegóły.

## 🙏 Dziękuję!

Każdy wkład pomaga uczynić Cytadelę lepszą dla społeczności świadomej prywatności!

**Specjalne podziękowania dla:**
- Wszystkich przyszłych współtwórców
- Użytkowników zgłaszających problemy
- Członków społeczności szerzących wiedzę

---

## Szybkie Linki

- [README](README.md)
- [ROADMAP](ROADMAP.md)
- [Przewodnik Testowania](tests/README.md)
- [Projekt Architektury](ARCHITECTURE_DESIGN.md)
- [Instrukcja Polska](CYTADELA_INSTRUKCJA.md)
- [Instrukcja Angielska](CITADEL_EN_COMPLETE_MANUAL.md)

---

*Ostatnia aktualizacja: 2026-01-30*
*Projekt: Cytadela v3.1*
*Opiekun: QguAr71*
