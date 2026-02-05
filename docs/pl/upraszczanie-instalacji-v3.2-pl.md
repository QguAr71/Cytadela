# 🚀 Plan Upraszczania Instalacji - v3.2 (Weles-SysQ)

**Wersja:** 3.2.0 PLANOWANA
**Utworzono:** 2026-02-01
**Status:** Faza planowania
**Priorytet:** Wysoki (Doświadczenie użytkownika)

---

## 📋 Opis problemu

### Aktualny przebieg instalacji (v3.1.0)
```bash
1. sudo ./citadel.sh check-deps
2. sudo ./citadel.sh install-wizard
3. sudo ./citadel.sh configure-system  ← Łatwo zapomnieć!
4. sudo ./citadel.sh verify
```

**Problemy:**
- ⚠️ **4 osobne komendy** - zbyt wiele kroków
- ⚠️ **configure-system jest krytyczny** ale łatwo zapomnieć
- ⚠️ **Mylące dla nowych użytkowników** - "Dlaczego DNS nie działa?"
- ⚠️ **Brak jasnej wskazówki** że krok 3 jest obowiązkowy

**Wpływ na użytkowników:**
- Użytkownicy instalują Citadel ale zapominają o `configure-system`
- System nadal używa systemd-resolved zamiast Citadel
- Zapytania DNS NIE są szyfrowane/filtrowane
- Użytkownicy zgłaszają "Citadel nie działa" gdy po prostu nie jest skonfigurowany

---

## ✨ Proponowane rozwiązanie: Auto-konfiguracja

### Nowy przebieg instalacji (v3.2)
```bash
1. sudo ./citadel.sh check-deps
2. sudo ./citadel.sh install-wizard  ← Auto-konfiguruje system!
   # (lub: sudo ./citadel.sh install-all)
```

**Rezultat:** **4 kroki → 2 kroki** (-50%)

---

## 🔧 Implementacja techniczna

### 1. Auto-konfiguracja domyślnie

**Lokalizacja:** `modules/unified-install.sh` (moduł zunifikowany v3.2)

**Kod:**
```bash
# Globalna flaga
AUTO_CONFIGURE=true

# Parsowanie flag linii komend
parse_install_flags() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-configure)
                AUTO_CONFIGURE=false
                log_info "Auto-konfiguracja wyłączona (--no-configure flaga)"
                shift
                ;;
            --silent)
                SILENT_MODE=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Na końcu install_wizard() i install_all()
finalize_installation() {
    if [[ "$AUTO_CONFIGURE" == "true" ]]; then
        log_section "🔧 KONFIGURACJA SYSTEMU"
        log_info "Przełączanie z systemd-resolved na DNS Citadel..."

        # Wywołanie configure_system z unified-network.sh
        configure_system

        if [[ $? -eq 0 ]]; then
            log_success "System skonfigurowany pomyślnie!"
            log_info "Kopia zapasowa utworzona: /var/lib/cytadela/backups/"
        else
            log_error "Konfiguracja nie powiodła się!"
            log_info "Możesz spróbować ręcznie: sudo ./citadel.sh configure-system"
            return 1
        fi
    else
        log_warning "⚠️  AUTO-KONFIGURACJA WYŁĄCZONA"
        log_warning "Citadel jest zainstalowany ale NIEAKTYWNY!"
        log_warning "System nadal używa systemd-resolved."
        echo ""
        log_info "Aby aktywować Citadel, uruchom:"
        echo "  sudo ./citadel.sh configure-system"
        echo ""
    fi
}
```

---

### 2. Możliwość rezygnacji dla zaawansowanych użytkowników

**Przypadki użycia:**
- Testowanie instalacji bez aktywacji
- Własna konfiguracja przed aktywacją
- Pipeline'y CI/CD z osobnym krokiem konfiguracji
- Wdrożenia wieloetapowe

**Użycie:**
```bash
# Standardowa instalacja (auto-konfiguracja)
sudo ./citadel.sh install-wizard

# Zaawansowane: instalacja bez konfiguracji
sudo ./citadel.sh install-wizard --no-configure

# Później, skonfiguruj ręcznie
sudo ./citadel.sh configure-system
```

---

### 3. Inteligentna detekcja i ostrzeżenia

**Sprawdzenie czy system jest już skonfigurowany:**
```bash
is_citadel_configured() {
    # Sprawdź czy /etc/resolv.conf wskazuje na 127.0.0.1
    if grep -q "nameserver 127.0.0.1" /etc/resolv.conf 2>/dev/null; then
        # Sprawdź czy systemd-resolved jest zamaskowany
        if systemctl is-enabled systemd-resolved 2>/dev/null | grep -q "masked"; then
            return 0  # Skonfigurowany
        fi
    fi
    return 1  # Nieskonfigurowany
}

# Przed auto-konfiguracją
if is_citadel_configured; then
    log_warning "System już skonfigurowany - pomijanie configure-system"
    return 0
fi
```

**Ostrzeżenie jeśli nie skonfigurowany:**
```bash
# W komendzie status
check_configuration_status() {
    if ! is_citadel_configured; then
        log_warning "⚠️  CITADEL NIE SKONFIGUROWANY"
        log_warning "Citadel jest zainstalowany ale system nadal używa systemd-resolved"
        log_info "Aby aktywować: sudo ./citadel.sh configure-system"
        return 1
    fi
}
```

---

## 📚 Wymagania dokumentacyjne

### 1. Aktualizacje README.md

**Przed (v3.1):**
```bash
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard
sudo ./citadel.sh configure-system  # Nie zapomnij!
sudo ./citadel.sh verify
```

**Po (v3.2):**
```bash
# Szybki start (auto-konfiguruje system)
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard

# Zaawansowane: Instalacja bez auto-konfiguracji
sudo ./citadel.sh install-wizard --no-configure
sudo ./citadel.sh configure-system  # Ręczna konfiguracja
```

**Dodaj prominentną notatkę:**
> **Zmiana w v3.2:** Instalacja teraz automatycznie konfiguruje system domyślnie. Użyj flagi `--no-configure` aby wyłączyć auto-konfigurację.

---

### 2. Aktualizacje przewodnika szybkiego startu

**Plik:** `docs/user/quick-start.md`

**Dodaj nową sekcję:**
```markdown
### Krok 3: Zainstaluj Citadel

**Opcja A: Instalacja standardowa (Zalecana)**
```bash
sudo ./citadel.sh install-wizard
```
- Interaktywny GUI z 7 językami
- **Automatycznie konfiguruje system** (nowość w v3.2!)
- Tworzy kopię zapasową oryginalnej konfiguracji
- Włącza ochronę przed wyciekiem DNS

**Opcja B: Instalacja bez auto-konfiguracji**
```bash
sudo ./citadel.sh install-wizard --no-configure
```
- Dla zaawansowanych użytkowników chcących ręcznej kontroli
- System pozostaje na systemd-resolved dopóki nie uruchomisz:
  ```bash
  sudo ./citadel.sh configure-system
  ```

> **Ważne:** W v3.2, `install-wizard` automatycznie uruchamia `configure-system` na końcu. To zmiana łamiąca w porównaniu z v3.1 gdzie był to osobny krok.
```

---

### 3. Przewodnik migracji

**Plik:** `docs/MIGRATION-v3.1-to-v3.2.md`

**Sekcja: Zmiany w instalacji**
```markdown
## Upraszczanie instalacji

### Co się zmieniło
- `install-wizard` i `install-all` teraz **automatycznie konfigurują system**
- `configure-system` jest wywoływany wewnętrznie na końcu instalacji
- Nowa flaga `--no-configure` aby wyłączyć auto-konfigurację

### Wpływ na Twój workflow

**v3.1 (Stary):**
```bash
sudo ./citadel.sh install-wizard
sudo ./citadel.sh configure-system  # Osobny krok
```

**v3.2 (Nowy):**
```bash
sudo ./citadel.sh install-wizard  # Auto-konfiguruje!
```

### Zmiany łamiące
- **Skrypty/automatyzacja:** Jeśli Twoje skrypty polegają na osobnym kroku `configure-system`, dodaj flagę `--no-configure`
- **Pipeline'y CI/CD:** Aktualizuj aby używać `--no-configure` jeśli potrzebujesz wdrożeń etapowych
- **Testowanie:** Użyj `--no-configure` dla instalacji testowych

### Kompatybilność wsteczna
- Komenda `configure-system` nadal istnieje i działa
- Można wywołać ręcznie jeśli potrzeba
- Bezpieczna do wielokrotnego wywołania (idempotentna)
```

---

### 4. Aktualizacje MANUAL

**Pliki:** `docs/user/MANUAL_PL.md`, `docs/user/MANUAL_EN.md`

**Dodaj do sekcji instalacji:**

**Angielski:**
```markdown
### Automatic System Configuration (v3.2+)

Starting with v3.2, Citadel automatically configures your system during installation:

1. **Backs up** original DNS configuration to `/var/lib/cytadela/backups/`
2. **Disables** systemd-resolved service
3. **Configures** /etc/resolv.conf to use Citadel (127.0.0.1)
4. **Enables** DNS leak protection firewall

**To disable auto-configuration:**
```bash
sudo ./citadel.sh install-wizard --no-configure
```

**To configure manually later:**
```bash
sudo ./citadel.sh configure-system
```

**To restore original configuration:**
```bash
sudo ./citadel.sh restore-system
```
```

**Polski:**
```markdown
### Automatyczna Konfiguracja Systemu (v3.2+)

Od wersji v3.2, Citadel automatycznie konfiguruje system podczas instalacji:

1. **Tworzy backup** oryginalnej konfiguracji DNS w `/var/lib/cytadela/backups/`
2. **Wyłącza** usługę systemd-resolved
3. **Konfiguruje** /etc/resolv.conf aby używać Citadel (127.0.0.1)
4. **Włącza** firewall ochrony przed wyciekiem DNS

**Aby wyłączyć auto-konfigurację:**
```bash
sudo ./citadel.sh install-wizard --no-configure
```

**Aby skonfigurować ręcznie później:**
```bash
sudo ./citadel.sh configure-system
```

**Aby przywrócić oryginalną konfigurację:**
```bash
sudo ./citadel.sh restore-system
```
```

---

### 5. Aktualizacje FAQ

**Plik:** `docs/user/FAQ.md`

**Dodaj nowe pytania:**

**P: Dlaczego v3.2 automatycznie konfiguruje mój system?**
O: Aby uprościć instalację i zapobiec zapominaniu krytycznego kroku `configure-system`. W v3.1 wielu użytkowników instalowało Citadel ale zapominali go skonfigurować, co powodowało że DNS nie był szyfrowany/filtrowany. Użyj flagi `--no-configure` jeśli chcesz ręcznej kontroli.

**P: Czy mogę wyłączyć auto-konfigurację?**
O: Tak, użyj flagi `--no-configure`:
```bash
sudo ./citadel.sh install-wizard --no-configure
```

**P: Co jeśli auto-konfiguracja się nie powiedzie?**
O: Instalator pokaże błąd i zasugeruje uruchomienie `configure-system` ręcznie. Twój system pozostanie na systemd-resolved (bezpieczny fallback).

**P: Czy auto-konfiguracja jest bezpieczna?**
O: Tak. Tworzy backup Twojej oryginalnej konfiguracji przed wprowadzeniem jakichkolwiek zmian. Możesz przywrócić w dowolnym momencie za pomocą `restore-system`.

**P: Zaktualizowałem z v3.1 - czy muszę ponownie skonfigurować?**
O: Nie. Jeśli Twój system jest już skonfigurowany, instalator to wykryje i pominie auto-konfigurację.

---

### 6. Referencja komend

**Plik:** `docs/user/commands.md`

**Aktualizuj wpis install-wizard:**
```markdown
### install-wizard

**Składnia:**
```bash
sudo ./citadel.sh install-wizard [język] [--no-configure] [--silent]
```

**Opis:**
Interaktywny kreator instalacji z interfejsem graficznym (gum).

**Parametry:**
- `język` (opcjonalny) - Wymuś konkretny język: pl, en, de, es, it, fr, ru
- `--no-configure` - Pomiń automatyczną konfigurację systemu (v3.2+)
- `--silent` - Tryb nieinteraktywny dla automatyzacji

**Zachowanie (v3.2+):**
- Automatycznie uruchamia `configure-system` na końcu
- Tworzy backup oryginalnej konfiguracji DNS
- Wyłącza systemd-resolved i włącza DNS Citadel
- Użyj `--no-configure` aby wyłączyć auto-konfigurację

**Przykłady:**
```bash
# Standardowa instalacja (auto-konfiguruje)
sudo ./citadel.sh install-wizard

# Wymuś język polski
sudo ./citadel.sh install-wizard pl

# Zainstaluj bez konfigurowania systemu
sudo ./citadel.sh install-wizard --no-configure

# Cicha instalacja dla automatyzacji
sudo ./citadel.sh install-wizard --silent
```
```

---

## 🧪 Wymagania testowe

### Testy jednostkowe
```bash
# Test auto-konfiguracji włączonej (domyślnie)
test_install_wizard_auto_configure() {
    AUTO_CONFIGURE=true
    install_wizard
    assert_citadel_configured
}

# Test auto-konfiguracji wyłączonej
test_install_wizard_no_configure() {
    AUTO_CONFIGURE=false
    install_wizard
    assert_citadel_not_configured
}

# Test już skonfigurowanego (pomiń)
test_install_wizard_already_configured() {
    configure_system  # Pre-konfiguracja
    install_wizard
    assert_no_duplicate_configuration
}
```

### Testy integracyjne
```bash
# Pełny przebieg instalacji
test_full_installation() {
    check_deps
    install_wizard
    verify_installation
    assert_dns_working
    assert_leak_protection_active
}

# Instalacja z --no-configure
test_install_no_configure() {
    install_wizard --no-configure
    assert_citadel_not_configured
    configure_system
    assert_citadel_configured
}
```

### Testy akceptacyjne użytkownika
- [ ] Nowy użytkownik może zainstalować pojedynczą komendą
- [ ] Zaawansowany użytkownik może używać --no-configure
- [ ] Komunikaty błędów są jasne jeśli konfiguracja się nie powiedzie
- [ ] Kopia zapasowa jest tworzona przed konfiguracją
- [ ] restore-system działa po auto-konfiguracji

---

## 📊 Metryki sukcesu

### Doświadczenie użytkownika
- ✅ Kroki instalacji: 4 → 2 (-50%)
- ✅ Raporty "Citadel nie działa": Oczekiwane -80%
- ✅ Czas do pierwszego działającego DNS: <5 minut
- ✅ Zamieszanie użytkownika: Znacznie zmniejszone

### Technicznie
- ✅ Wskaźnik sukcesu auto-konfiguracji: >95%
- ✅ Tworzenie kopii zapasowej: 100%
- ✅ Wskaźnik sukcesu rollback: 100%
- ✅ Brak zmian łamiących dla zaawansowanych użytkowników

---

## 🚨 Ryzyka i łagodzenie

### Ryzyko 1: Auto-konfiguracja się nie powiedzie
**Wpływ:** Wysoki
**Prawdopodobieństwo:** Niskie
**Łagodzenie:**
- Kompleksowa obsługa błędów
- Jasne komunikaty błędów z krokami manualnymi
- Bezpieczny fallback do systemd-resolved
- Kopia zapasowa zawsze tworzona przed zmianami

### Ryzyko 2: Użytkownicy nie chcą auto-konfiguracji
**Wpływ:** Średni
**Prawdopodobieństwo:** Niskie
**Łagodzenie:**
- Flaga `--no-configure` dla rezygnacji
- Jasna dokumentacja
- Kompatybilność wsteczna (configure-system nadal działa)

### Ryzyko 3: Łamanie istniejących skryptów
**Wpływ:** Średni
**Prawdopodobieństwo:** Średnie
**Łagodzenie:**
- Przewodnik migracji z przykładami
- Ostrzeżenia deprecjacji w v3.1.x
- Flaga `--no-configure` dla starego zachowania

---

## 📅 Harmonogram implementacji

### Faza 1: Implementacja kodu (Tydzień 1)
- [ ] Dodaj flagę AUTO_CONFIGURE do unified-install.sh
- [ ] Zaimplementuj parse_install_flags()
- [ ] Zaimplementuj finalize_installation()
- [ ] Dodaj sprawdzenie is_citadel_configured()
- [ ] Dodaj inteligentne ostrzeżenia

### Faza 2: Dokumentacja (Tydzień 2)
- [ ] Aktualizuj README.md
- [ ] Aktualizuj quick-start.md
- [ ] Aktualizuj MANUAL_PL.md
- [ ] Aktualizuj MANUAL_EN.md
- [ ] Aktualizuj commands.md
- [ ] Aktualizuj FAQ.md
- [ ] Utwórz MIGRATION-v3.1-to-v3.2.md

### Faza 3: Testowanie (Tydzień 3)
- [ ] Testy jednostkowe
- [ ] Testy integracyjne
- [ ] Testy akceptacyjne użytkownika
- [ ] Beta testowanie z wolontariuszami

### Faza 4: Wydanie (Tydzień 4)
- [ ] Końcowy przegląd dokumentacji
- [ ] Informacje o wydaniu
- [ ] Ogłoszenie
- [ ] Przygotowanie wsparcia

---

## 📝 Szablon informacji o wydaniu

```markdown
## v3.2.0 - Upraszczanie instalacji

### 🚀 Główne zmiany

**Uproszczony proces instalacji**
- Instalacja teraz automatycznie konfiguruje system
- Zmniejszono z 4 kroków do 2 kroków
- Koniec z zapominaniem `configure-system`!

**Przed (v3.1):**
```bash
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard
sudo ./citadel.sh configure-system  # Łatwo zapomnieć!
sudo ./citadel.sh verify
```

**Po (v3.2):**
```bash
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard  # Auto-konfiguruje!
```

### ⚙️ Zaawansowani użytkownicy

Użyj flagi `--no-configure` aby wyłączyć auto-konfigurację:
```bash
sudo ./citadel.sh install-wizard --no-configure
```

### 📚 Dokumentacja

Zobacz [MIGRATION-v3.1-to-v3.2.md](docs/MIGRATION-v3.1-to-v3.2.md) dla szczegółowego przewodnika migracji.
```

---

## 🎯 Wnioski

**Korzyści:**
- ✅ Prostsza instalacja (4 → 2 kroki)
- ✅ Mniej błędów użytkownika
- ✅ Lepiej pierwsze doświadczenie
- ✅ Zachowuje elastyczność dla zaawansowanych użytkowników
- ✅ Kompleksowa dokumentacja

**Kluczowy czynnik sukcesu:** **Doskonała dokumentacja**
- Jasny przewodnik migracji
- Zaktualizowane podręczniki (PL + EN)
- Wpisy FAQ
- Przykłady dla wszystkich przypadków użycia
- Komunikaty ostrzegawcze w kodzie

---

**Ostatnia aktualizacja:** 2026-02-05
**Status:** Zatwierdzony do implementacji v3.2
**Następne kroki:** Rozpocznij Fazę 1 (Implementacja kodu)
