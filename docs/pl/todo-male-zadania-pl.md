# TODO - Małe Zadania

**Cel:** Proste zadania odpowiednie dla mniejszych modeli AI lub szybkich wkładów.
**Cel:** Zadania, które nie wymagają dużego kontekstu lub decyzji strategicznych.

---

## 🔧 Poprawki ShellCheck (Priorytet: Średni)

### Katalog lib/
- [x] Napraw SC2034 w `lib/cytadela-core.sh` - Dodaj `export` dla CYTADELA_VERSION
- [x] Napraw SC2034 w `lib/cytadela-core.sh` - Dodaj `export` dla CYTADELA_LKG_DIR
- [x] Napraw SC2034 w `lib/cytadela-core.sh` - Dodaj `export` dla CYTADELA_OPT_BIN
- [x] Napraw SC2034 w `lib/cytadela-core.sh` - Dodaj `export` dla CYTADELA_SCRIPT_PATH
- [x] Napraw SC2034 w `lib/network-utils.sh` - Dodaj `export` dla DNSCRYPT_PORT_DEFAULT
- [x] Napraw SC2034 w `lib/network-utils.sh` - Dodaj `export` dla COREDNS_PORT_DEFAULT
- [x] Napraw SC2034 w `lib/network-utils.sh` - Dodaj `export` dla COREDNS_METRICS_ADDR
- [x] Napraw SC2004 w `lib/module-loader.sh` linia 40 - Usuń `$` w indeksie tablicy (nie dotyczy - fałszywy pozytyw)

### Katalog modules/
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/auto-update.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/blocklist-manager.sh` (wykonane - name→_name)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/cache-stats.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/config-backup.sh` (wykonane - usunięta nieużywana zmienna)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/diagnostics.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/ghost-check.sh` (wykonane - dodano shellcheck disable)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/install-coredns.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/install-wizard.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/ipv6.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/location.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/nft-debug.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/notify.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/supply-chain.sh` (czyste - brak ostrzeżeń)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w `modules/test-tools.sh` (czyste - brak ostrzeżeń)

---

## 📐 Formatowanie Kodu (Priorytet: Niski)

- [x] Uruchom `shfmt -w -i 4 -ci lib/*.sh` - Sformatuj wszystkie pliki biblioteczne
- [x] Uruchom `shfmt -w -i 4 -ci modules/*.sh` - Sformatuj wszystkie pliki modułów
- [x] Uruchom `shfmt -w -i 4 -ci citadel.sh citadel_en.sh` - Sformatuj główne skrypty
- [x] Zweryfikuj formatowanie z `shfmt -d .` - Sprawdź niespójności

---

## 🔧 Infrastruktura i CI (Priorytet: Wysoki)

### Standaryzacja Dokumentacji
- [x] Unifikuj dokumentację: napraw liczbę modułów i kluczowe diagramy w `docs/CITADEL-STRUCTURE.md`
- [x] Dodaj badge statusu CI do README.md
- [x] Dodaj instrukcje testowania lokalnego (jeśli nie obecne)

### Usprawnienie Pipeline CI/CD
- [x] Uruchamiaj testy smoke przy każdym PR
- [x] Dodaj opcjonalne zadanie testów integracyjnych (manualne lub na żądanie)
- [x] Przejrzyj i napraw ostrzeżenia ShellCheck w workflow (zapewnij zgodność reguł ze stylem kodu)

### Zarządzanie Wersjami
- [ ] Standaryzuj format wersjonowania
- [ ] Dodaj instrukcje wydania (changelog + workflow GitHub Releases)

### Planowanie Przyszłej Architektury
- [ ] Jeśli roadmap zawiera rewrite w Rust, dodaj osobny projekt/monorepo lub folder `cytadela-core/`
- [ ] Dodaj jasne milestone i przykłady build/run dla wersji Rust

---

## 📚 Dokumentacja (Priorytet: Średni)

### Dokumentacja Funkcji
- [x] Dodaj docstring do `panic_bypass()` w `modules/emergency.sh`
- [x] Dodaj docstring do `panic_restore()` w `modules/emergency.sh`
- [x] Dodaj docstring do `killswitch_on()` w `modules/emergency.sh`
- [x] Dodaj docstring do `killswitch_off()` w `modules/emergency.sh`
- [x] Dodaj docstring do `adblock_add()` w `modules/adblock.sh`
- [x] Dodaj docstring do `adblock_remove()` w `modules/adblock.sh`
- [x] Dodaj docstring do `adblock_rebuild()` w `modules/adblock.sh`
- [x] Dodaj docstring do `ghost_check()` w `modules/ghost-check.sh`
- [x] Dodaj docstring do `smart_ipv6()` w `modules/ipv6.sh`
- [x] Dodaj docstring do `supply_chain_verify()` w `modules/supply-chain.sh`

### Aktualizacje README
- [x] Zaktualizuj badges w README.md (wersja, status build)
- [x] Dodaj screenshot dashboard `citadel-top`
- [x] Zaktualizuj tabelę porównania z najnowszymi funkcjami
- [x] Dodaj sekcję "Quick Links" do README

### Przykłady
- [x] Utwórz `examples/basic-setup.sh` - Prosty przykład instalacji
- [x] Utwórz `examples/advanced-setup.sh` - Przykład zaawansowanej konfiguracji
- [x] Utwórz `examples/emergency-recovery.sh` - Przykład procedur awaryjnych

---

## 🧪 Testy (Priorytet: Wysoki)

### Testy Smoke
- [x] Dodaj test dla `citadel.sh help` w `tests/smoke-test.sh`
- [x] Dodaj test dla `citadel.sh --version` w `tests/smoke-test.sh`
- [x] Dodaj test dla sprawdzenia root (powinien zawieść bez sudo)
- [x] Dodaj test dla `citadel.sh status` (podstawowe sprawdzenie statusu)
- [x] Dodaj test dla `citadel.sh check-deps` (sprawdzenie zależności)

### Testy BATS (Przyszłość)
- [x] Utwórz `tests/unit/test-module-loader.bats` - Testy ładowacza modułów
- [x] Utwórz `tests/unit/test-network-utils.bats` - Testy narzędzi sieciowych
- [x] Utwórz `tests/integration/test-install.bats` - Testy instalacji

---

## 🌍 Tłumaczenia (Priorytet: Niski)

### Niemiecki (DE)
- [x] Przetłumacz "Honeypot enabled" w `lib/i18n-de.sh`
- [x] Przetłumacz "Reputation system active" w `lib/i18n-de.sh`
- [x] Przetłumacz "ASN blocking configured" w `lib/i18n-de.sh`

### Francuski (FR)
- [x] Przetłumacz "Honeypot enabled" w `lib/i18n-fr.sh`
- [x] Przetłumacz "Reputation system active" w `lib/i18n-fr.sh`
- [x] Przetłumacz "ASN blocking configured" w `lib/i18n-fr.sh`

### Hiszpański (ES)
- [x] Przetłumacz "Honeypot enabled" w `lib/i18n-es.sh`
- [x] Przetłumacz "Reputation system active" w `lib/i18n-es.sh`
- [x] Przetłumacz "ASN blocking configured" w `lib/i18n-es.sh`

### Włoski (IT)
- [x] Przetłumacz "Honeypot enabled" w `lib/i18n-it.sh`
- [x] Przetłumacz "Reputation system active" w `lib/i18n-it.sh`
- [x] Przetłumacz "ASN blocking configured" w `lib/i18n-it.sh`

### Rosyjski (RU)
- [x] Przetłumacz "Honeypot enabled" w `lib/i18n-ru.sh`
- [x] Przetłumacz "Reputation system active" w `lib/i18n-ru.sh`
- [x] Przetłumacz "ASN blocking configured" w `lib/i18n-ru.sh`

---

## 🐛 Poprawki Błędów (Priorytet: Wysoki)

- [x] Testuj i zweryfikuj poprawkę check-deps (${1:-} po shift) - zweryfikowane, działa prawidłowo
- [x] Zweryfikuj fallback realpath działa na systemach bez realpath - zweryfikowane, ma fallback
- [x] Testuj call_fn() ze wszystkimi funkcjami modułów - zweryfikowane, działa prawidłowo
- [x] Zweryfikuj obsługę błędów source_lib() - zweryfikowane, wychodzi z kodem 2

---

## 🎨 Ulepszenia UI/UX (Priorytet: Niski)

- [x] Dodaj kodowanie kolorów do wyjścia `citadel.sh status` - ulepszone z większą liczbą sekcji
- [x] Popraw komunikaty błędów (bardziej opisowe) - dodano przykłady do poleceń adblock
- [x] Dodaj wskaźniki postępu dla długich operacji - dodano do lists_update
- [x] Popraw formatowanie tekstu pomocy - zrestrukturyzowane z emoji i lepszymi kolorami

---

## 📦 Pakowanie (Priorytet: Przyszłość)

- [x] Utwórz pakiet AUR (PKGBUILD)
- [ ] Utwórz pakiet Debian (.deb)
- [ ] Utwórz pakiet RPM (.rpm)
- [x] Utwórz obraz Docker

---

## 🔒 Bezpieczeństwo (Priorytet: Wysoki)

- [x] Przejrzyj wszystkie użycia `eval` (jeśli jakiekolwiek) - nie znaleziono w kodzie
- [x] Sprawdź zakodowane credentials - zweryfikowane, tylko klucze publiczne
- [x] Zweryfikuj walidację wejścia we wszystkich funkcjach skierowanych do użytkownika - obecna podstawowa walidacja
- [x] Dodaj rate limiting do krytycznych operacji - zaimplementowane z flock

---

## 📊 Metryki (Priorytet: Niski)

- [x] Dodaj eksport metryk Prometheus
- [x] Utwórz szablon dashboard Grafana
- [x] Dodaj benchmarki wydajności

---

## Notatki

**Dla Współtwórców:**
- Wybierz dowolne zadanie z tej listy
- Oznacz jako ukończone po wykonaniu
- Dodaj nowe małe zadania w miarę potrzeb
- Zachowaj zadania proste (1 plik, 1 funkcja, 1 funkcja)

**Dla Mniejszych Modeli AI:**
- Skup się na zmianach pojedynczych plików
- Unikaj decyzji strategicznych
- Używaj istniejących wzorców
- Testuj zmiany lokalnie

**Ostatnia aktualizacja:** 2026-02-01
