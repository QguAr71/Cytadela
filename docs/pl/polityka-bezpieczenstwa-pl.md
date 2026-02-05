# Polityka Bezpieczeństwa

## 🔒 Wspierane Wersje

| Wersja | Wspierana          | Status |
| ------- | ------------------ | ------ |
| 3.1.x   | ✅ Tak            | Stabilna |
| 3.0.x   | ⚠️ Ograniczona    | Legacy |
| < 3.0   | ❌ Nie            | Przestarzała |

**Aktualna stabilna wersja:** v3.1.0 (2026-01-31)

---

## 🚨 Zgłaszanie Usterki Bezpieczeństwa

Jeśli odkryjesz usterkę bezpieczeństwa w Cytadeli, proszę zgłoś ją odpowiedzialnie:

### Preferowana Metoda: Prywatny Advisory Bezpieczeństwa

1. Przejdź do [Security Advisories](https://github.com/QguAr71/Cytadela/security/advisories)
2. Kliknij "Report a vulnerability"
3. Podaj szczegółowe informacje o usterce

### Alternatywna Metoda: Email

Wyślij email na: **security@citadel-project.org** (jeśli dostępny)

**Proszę dołączyć:**
- Opis usterki
- Kroki do reprodukcji
- Potencjalny wpływ
- Sugerowaną naprawę (jeśli jakaś)

### Czas Odpowiedzi

- **Odpowiedź wstępna:** W ciągu 48 godzin
- **Aktualizacja statusu:** W ciągu 7 dni
- **Harmonogram naprawy:** Zależy od poziomu krytyczności (patrz poniżej)

---

## 🎯 Poziomy Krytyczności

| Krytyczność | Opis | Czas Odpowiedzi | Przykład |
|-------------|------|-----------------|----------|
| **Krytyczna** | Zdalne wykonanie kodu, eskalacja uprawnień | 24-48 godzin | RCE w instalatorze |
| **Wysoka** | Ujawnienie danych, ominięcie uwierzytelniania | 3-7 dni | Wyciek DNS, ujawnienie konfiguracji |
| **Średnia** | DoS, ujawnienie informacji | 7-14 dni | Awaria usługi, ujawnienie wersji |
| **Niska** | Drobne problemy, kosmetyczne | 14-30 dni | Gadatliwość logów, problemy UI |

---

## 🛡️ Najlepsze Praktyki Bezpieczeństwa

### Dla Użytkowników

1. **Zawsze weryfikuj pobrane pliki:**
   ```bash
   # Weryfikuj repozytorium git
   git clone https://github.com/QguAr71/Cytadela.git
   cd Cytadela
   git verify-commit HEAD  # Jeśli podpisane
   ```

2. **Używaj sprawdzania integralności:**
   ```bash
   sudo ./citadel.sh integrity-init
   sudo ./citadel.sh integrity-check
   ```

3. **Utrzymuj system aktualnym:**
   ```bash
   sudo ./citadel.sh auto-update-enable
   ```

4. **Przeglądaj konfigurację:**
   ```bash
   sudo ./citadel.sh diagnostics
   sudo ./citadel.sh verify
   ```

5. **Używaj funkcji awaryjnych:**
   ```bash
   # Jeśli coś pójdzie nie tak
   sudo ./citadel.sh panic-bypass
   sudo ./citadel.sh restore-system
   ```

### Dla Deweloperów

1. **Code review:** Wszystkie PR wymagają przeglądu
2. **Testowanie:** Uruchamiaj testy przed commitem
   ```bash
   bash tests/smoke-test.sh
   shellcheck citadel.sh lib/*.sh modules/*.sh
   ```

3. **Brak zakodowanych sekretów:** Używaj zmiennych środowiskowych
4. **Walidacja wejścia:** Zawsze waliduj wejście użytkownika
5. **Zasada najmniejszych uprawnień:** Uruchamiaj z minimalnymi wymaganymi uprawnieniami

---

## 🔐 Funkcje Bezpieczeństwa

### Wbudowane Bezpieczeństwo

- ✅ **Ochrona łańcucha dostaw** - Weryfikacja integralności dla binariów
- ✅ **Szyfrowanie DNS** - DoH/DoT poprzez DNSCrypt-Proxy
- ✅ **Wzmocnienie firewall** - Ścisłe reguły NFTables
- ✅ **Odzyskiwanie awaryjne** - Tryb panic-bypass
- ✅ **Monitorowanie integralności** - Sprawdzanie integralności plików
- ✅ **Local-first** - Brak zależności chmurowych

### Polecenia Bezpieczeństwa

```bash
# Inicjalizacja bezpieczeństwa
sudo ./citadel.sh supply-chain-init
sudo ./citadel.sh integrity-init

# Weryfikacja integralności
sudo ./citadel.sh supply-chain-verify
sudo ./citadel.sh integrity-check

# Tryb awaryjny
sudo ./citadel.sh panic-bypass    # Ominięcie DNS/firewall
sudo ./citadel.sh panic-restore   # Przywracanie normalnego trybu

# Audyt firewall
sudo ./citadel.sh ghost-check     # Sprawdzanie otwartych portów
sudo ./citadel.sh location-check  # Sprawdzanie lokalizacji sieci
```

---

## 🚫 Znane Zagadnienia Bezpieczeństwa

### Ograniczenia Skryptów Shell

**Problem:** Skrypty Bash mogą być podatne na ataki injection.

**Łagodzenie:**
- Wszystkie wejścia użytkownika są walidowane
- ShellCheck używany do analizy statycznej
- Cudzysłowy używane konsekwentnie
- Brak `eval` lub dynamicznego wykonania kodu

### Uprawnienia Root

**Problem:** Cytadela wymaga root dla konfiguracji systemu.

**Łagodzenie:**
- Jasna dokumentacja wymaganych uprawnień
- Minimalne użycie uprawnień
- Ślad audytu w logach
- Tryb odzyskiwania awaryjnego

### Prywatność DNS

**Problem:** Zapytania DNS mogą ujawniać informacje.

**Łagodzenie:**
- Szyfrowanie DNSCrypt-Proxy (DoH/DoT)
- Zapobieganie wyciekom NFTables
- Resolvery DNS bez logowania
- Rozszerzenia prywatności IPv6

---

## 📋 Lista Sprawdzania Bezpieczeństwa

Przed wdrożeniem Cytadeli w produkcji:

- [ ] Przejrzyj wszystkie pliki konfiguracyjne
- [ ] Włącz sprawdzanie integralności
- [ ] Skonfiguruj firewall (tryb ścisły)
- [ ] Przetestuj odzyskiwanie awaryjne
- [ ] Włącz auto-aktualizacje
- [ ] Przejrzyj wybór resolvera DNS
- [ ] Przetestuj zapobieganie wyciekom DNS
- [ ] Skonfiguruj backup/restore
- [ ] Regularnie przeglądaj logi
- [ ] Dokumentuj własne zmiany

---

## 🔄 Aktualizacje Bezpieczeństwa

Aktualizacje bezpieczeństwa są wydawane tak szybko jak to możliwe po potwierdzeniu usterki.

**Proces aktualizacji:**
```bash
# Sprawdź aktualizacje
sudo ./citadel.sh auto-update-status

# Aktualizuj ręcznie
cd /path/to/Cytadela
git pull
sudo ./citadel.sh verify
```

**Kanały powiadomień:**
- GitHub Security Advisories
- Notki wydania (CHANGELOG.md)
- GitHub Releases

---

## 📚 Dodatkowe Zasoby

- [Pełny Manual (PL)](docs/user/MANUAL_PL.md)
- [Pełny Manual (EN)](docs/user/MANUAL_EN.md)
- [Dokumentacja Architektury](docs/CITADEL-STRUCTURE.md)
- [Wskazówki Współtworzenia](docs/developer/contributing.md)

---

## 🙏 Podziękowania

Doceniamy odpowiedzialne ujawnianie i będziemy przyznawać uznanie badaczom bezpieczeństwa, którzy zgłaszają usterki (chyba że wolą pozostać anonimowi).

**Hall of Fame:** (Do dodania)

---

**Ostatnia aktualizacja:** 2026-01-31
**Wersja:** 3.1.0
