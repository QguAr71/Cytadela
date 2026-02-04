# Szybki Start - Citadel v3.3

Ten przewodnik pomoże Ci zacząć pracę z Citadel v3.3 w ciągu 5 minut.

## 🚀 Szybka instalacja

### 1. Pobierz Citadel

```bash
# Sklonuj repozytorium
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
```

### 2. Sprawdź zależności

```bash
# Sprawdź wymagania systemowe
sudo ./scripts/citadel-install-cli.sh --check-deps
```

### 3. Uruchom instalator

```bash
# Interaktywny instalator (zalecane)
sudo ./scripts/citadel-install-cli.sh --wizard

# Lub instalacja bezpośrednia
sudo ./scripts/citadel-install-cli.sh --profile standard
```

### 4. Skonfiguruj system

```bash
# Przełącz system na Citadel
sudo citadel.sh configure-system
```

### 5. Sprawdź status

```bash
# Sprawdź czy wszystko działa
sudo citadel.sh status
```

## ⚙️ Konfiguracja podstawowa

### Domyślna konfiguracja

Citadel działa od razu po instalacji z domyślnymi ustawieniami. Aby dostosować:

```bash
# Wyświetl obecną konfigurację
sudo citadel.sh config-show

# Zmień ustawienia bezpieczeństwa
sudo citadel.sh config-set security.reputation.threshold 75
sudo citadel.sh config-set logging.level debug

# Zastosuj zmiany
sudo citadel.sh config-apply
```

### Profile konfiguracyjne

```bash
# Lista dostępnych profili
sudo citadel.sh config-list-profiles

# Przełącz na profil enterprise
sudo citadel.sh config-switch-profile enterprise
```

## 🛡️ Funkcje bezpieczeństwa

### Włącz podstawowe bezpieczeństwo

```bash
# Uruchom system reputacji
sudo citadel.sh reputation list

# Włącz honeypot
sudo citadel.sh honeypot start

# Sprawdź logi zdarzeń
sudo citadel.sh events query --tail 10
```

### Blokowanie zagrożeń

```bash
# Zablokuj podejrzane IP
sudo citadel.sh reputation block 192.168.1.100

# Zablokuj ASN
sudo citadel.sh asn-block add AS12345

# Sprawdź status bezpieczeństwa
sudo citadel.sh status
```

## 📊 Monitorowanie

### Sprawdź zdrowie systemu

```bash
# Kompleksowe sprawdzenie zdrowia
sudo citadel.sh monitoring-health-check

# Informacje o systemie
sudo citadel.sh monitoring-system-info
```

### Monitoruj w czasie rzeczywistym

```bash
# Status w czasie rzeczywistym
watch -n 5 'sudo citadel.sh status'

# Logi zdarzeń na żywo
sudo citadel.sh events query --tail 20 --follow
```

## 🎯 Komendy podstawowe

| Komenda | Opis |
|---------|------|
| `citadel.sh status` | Wyświetl status systemu |
| `citadel.sh config-show` | Pokaż konfigurację |
| `citadel.sh reputation list` | Lista reputacji IP |
| `citadel.sh events query` | Przeszukaj logi zdarzeń |
| `citadel.sh monitoring-health-check` | Sprawdź zdrowie systemu |
| `citadel.sh service-list` | Lista usług Citadel |

## 🏢 Funkcje enterprise (opcjonalne)

Jeśli potrzebujesz zaawansowanych funkcji korporacyjnych:

```bash
# Inicjalizuj funkcje enterprise
sudo citadel.sh enterprise-init

# Skonfiguruj monitoring
sudo citadel.sh prometheus-setup
sudo citadel.sh grafana-setup

# Sprawdź status enterprise
sudo citadel.sh enterprise-status
```

## 🛠️ Rozwiązywanie problemów

### Najczęstsze problemy

#### Problem: "Permission denied"
```bash
# Rozwiązanie: użyj sudo
sudo ./scripts/citadel-install-cli.sh
```

#### Problem: "Service not found"
```bash
# Rozwiązanie: skonfiguruj usługi
sudo citadel.sh service-setup-all
sudo citadel.sh service-start citadel-main
```

#### Problem: "Module not loaded"
```bash
# Rozwiązanie: załaduj moduły
sudo citadel.sh module-load-all
```

### Sprawdź logi

```bash
# Logi systemu
sudo journalctl -u citadel-* --since "1 hour ago"

# Logi aplikacji
tail -f /var/log/citadel/citadel.log

# Logi zdarzeń
sudo citadel.sh events query --level error --tail 10
```

### Resetuj konfigurację

Jeśli coś pójdzie nie tak:

```bash
# Resetuj do wartości domyślnych
sudo citadel.sh config-reset

# Przeładuj wszystkie moduły
sudo citadel.sh module-reload unified-security

# Zrestartuj usługi
sudo citadel.sh service-restart citadel-main
```

## 📚 Następne kroki

Po ukończeniu szybkiej instalacji:

1. **Dostosuj konfigurację** - Użyj `config-set` do zmiany ustawień
2. **Włącz funkcje bezpieczeństwa** - Uruchom reputation, honeypot, ASN blocking
3. **Skonfiguruj monitorowanie** - Ustaw Prometheus/Grafana dla zaawansowanego monitoringu
4. **Dowiedz się więcej** - Przeczytaj pełną dokumentację w `docs/`

## 🔗 Uzyskaj pomoc

```bash
# Pomoc wbudowana
citadel.sh --help

# Sprawdź dokumentację
cat docs/pl/README_PL.md

# Issues i dyskusje
# https://github.com/QguAr71/Cytadela/issues
# https://github.com/QguAr71/Cytadela/discussions
```

---

**Gotowe! Citadel v3.3 jest teraz zainstalowany i gotowy do użycia.** 🎉

Zobacz [pełną dokumentację](README_PL.md) aby poznać wszystkie funkcje.
