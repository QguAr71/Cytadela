# Referencja Komend

Ten dokument zawiera kompleksową referencję wszystkich komend Citadel v3.3.

## Spis treści

- [Uzyskiwanie pomocy](#uzyskiwanie-pomocy)
- [Komendy bezpieczeństwa](#komendy-bezpieczeństwa)
- [Komendy zarządzania](#komendy-zarządzania)
- [Komendy korporacyjne](#komendy-korporacyjne)
- [Komendy usług](#komendy-usług)
- [Komendy monitorowania](#komendy-monitorowania)
- [Komendy konfiguracji](#komendy-konfiguracji)
- [Komendy modułów](#komendy-modułów)

## Uzyskiwanie pomocy

### Podstawowa pomoc

```bash
citadel.sh --help          # Wyświetl główną pomoc
citadel.sh help           # Alternatywna komenda pomocy
citadel.sh --version      # Wyświetl wersję
```

## Komendy bezpieczeństwa

### System reputacji

```bash
# Wyświetlanie reputacji adresów IP
citadel.sh reputation list                    # Lista wszystkich śledzonych IP
citadel.sh reputation score <IP>             # Sprawdź score konkretnego IP

# Zarządzanie blokadami
citadel.sh reputation block <IP>             # Zablokuj IP
citadel.sh reputation unblock <IP>           # Odblokuj IP

# Statystyki
citadel.sh reputation stats                  # Wyświetl statystyki reputacji
citadel.sh reputation reset                  # Resetuj wszystkie dane reputacji
```

### Blokowanie ASN

```bash
# Zarządzanie ASN
citadel.sh asn-block add <ASN>               # Zablokuj Autonomous System
citadel.sh asn-block remove <ASN>            # Odblokuj Autonomous System
citadel.sh asn-block list                    # Lista zablokowanych ASN

# Zarządzanie prefiksami
citadel.sh asn-block update                  # Aktualizuj listy prefiksów z WHOIS
citadel.sh asn-block show <ASN>              # Wyświetl szczegóły konkretnego ASN

# Statystyki
citadel.sh asn-block stats                   # Wyświetl statystyki blokowania
citadel.sh asn-block whitelist <ASN>         # Dodaj ASN do białej listy
```

### Logowanie zdarzeń

```bash
# Logowanie zdarzeń
citadel.sh events log <wiadomość> <kategoria> <poziom>  # Zaloguj własne zdarzenie

# Przeszukiwanie zdarzeń
citadel.sh events query                        # Wyświetl ostatnie zdarzenia
citadel.sh events query --level error          # Filtruj wg poziomu
citadel.sh events query --category security    # Filtruj wg kategorii
citadel.sh events query --since 1h             # Filtruj wg czasu
citadel.sh events query --tail 50              # Wyświetl ostatnie 50 zdarzeń

# Zarządzanie
citadel.sh events stats                        # Wyświetl statystyki logowania
citadel.sh events rotate                       # Obróć pliki logów
citadel.sh events analyze --period 24h         # Analizuj zdarzenia
```

### Honeypot

```bash
# Sterowanie honeypot
citadel.sh honeypot start                      # Uruchom usługi honeypot
citadel.sh honeypot stop                       # Zatrzymaj usługi honeypot
citadel.sh honeypot restart                    # Zrestartuj honeypot

# Monitorowanie
citadel.sh honeypot status                     # Wyświetl status honeypot
citadel.sh honeypot logs                       # Wyświetl logi połączeń
citadel.sh honeypot stats                      # Wyświetl statystyki

# Zarządzanie
citadel.sh honeypot cleanup                    # Wyczyść dane honeypot
citadel.sh honeypot reload                     # Przeładuj konfigurację
```

## Komendy zarządzania

### Status systemu

```bash
citadel.sh status                              # Wyświetl ogólny status systemu
citadel.sh status --verbose                    # Szczegółowy status
citadel.sh status --json                       # Wyjście w formacie JSON
```

### Sterowanie systemem

```bash
# Zarządzanie systemem (kompatybilność wsteczna)
citadel.sh configure-system                    # Skonfiguruj system dla Citadel
citadel.sh uninstall                           # Odinstaluj Citadel
citadel.sh verify                              # Zweryfikuj instalację
```

## Komendy korporacyjne

### Funkcje enterprise

```bash
citadel.sh enterprise-init                     # Inicjalizuj funkcje enterprise
citadel.sh enterprise-status                   # Wyświetl status enterprise
citadel.sh enterprise-metrics                  # Wyświetl metryki enterprise
```

### Integracja Prometheus

```bash
citadel.sh prometheus-setup                    # Skonfiguruj integrację Prometheus
citadel.sh prometheus-status                   # Wyświetl status Prometheus
citadel.sh prometheus-restart                  # Zrestartuj usługę Prometheus
```

### Integracja Grafana

```bash
citadel.sh grafana-setup                       # Skonfiguruj integrację Grafana
citadel.sh grafana-status                      # Wyświetl status Grafana
citadel.sh grafana-restart                     # Zrestartuj usługę Grafana
```

### Integracja Docker

```bash
citadel.sh docker-setup                        # Skonfiguruj integrację Docker
citadel.sh docker-status                       # Wyświetl status kontenerów Docker
citadel.sh docker-logs                         # Wyświetl logi Docker
citadel.sh docker-restart                      # Zrestartuj usługi Docker
```

### Bezpieczeństwo enterprise

```bash
citadel.sh enterprise-security-init            # Inicjalizuj bezpieczeństwo enterprise
citadel.sh threat-feeds-update                 # Aktualizuj kanały zagrożeń
citadel.sh audit-logs                          # Wyświetl logi audytu
```

### Skalowalność

```bash
citadel.sh scalability-init                    # Inicjalizuj funkcje skalowalności
citadel.sh load-balancer-status                # Wyświetl status load balancer
citadel.sh high-availability-status            # Wyświetl status wysokiej dostępności
```

## Komendy usług

### Zarządzanie usługami

```bash
# Cykl życia usług
citadel.sh service-start <nazwa>               # Uruchom usługę
citadel.sh service-stop <nazwa>                # Zatrzymaj usługę
citadel.sh service-restart <nazwa>             # Zrestartuj usługę

# Konfiguracja usług
citadel.sh service-enable <nazwa>              # Włącz auto-start
citadel.sh service-disable <nazwa>             # Wyłącz auto-start

# Informacje o usługach
citadel.sh service-status <nazwa>              # Wyświetl status usługi
citadel.sh service-list                        # Lista wszystkich usług Citadel

# Operacje zbiorcze
citadel.sh service-setup-all                   # Utwórz wszystkie usługi Citadel
citadel.sh service-remove-all                  # Usuń wszystkie usługi Citadel
```

### Dostępne usługi

- `citadel-main` - Główna usługa Citadel
- `citadel-security` - Usługa monitorowania bezpieczeństwa
- `citadel-events` - Usługa logowania zdarzeń
- `citadel-honeypot` - Usługa honeypot

## Komendy monitorowania

### Monitorowanie zdrowia

```bash
citadel.sh monitoring-health-check             # Uruchom kompleksowe sprawdzenie zdrowia
citadel.sh monitoring-system-info              # Wyświetl szczegółowe informacje o systemie
```

### Zaawansowane monitorowanie

```bash
# Monitorowanie enterprise
citadel.sh monitoring-metrics                  # Wyświetl szczegółowe metryki
citadel.sh monitoring-alerts                   # Wyświetl aktywne alerty
citadel.sh monitoring-performance              # Wyświetl statystyki wydajności
```

## Komendy konfiguracji

### Podstawowa konfiguracja

```bash
citadel.sh config-init                         # Inicjalizuj konfigurację
citadel.sh config-show                         # Wyświetl obecną konfigurację
citadel.sh config-show <klucz>                 # Wyświetl konkretny klucz
citadel.sh config-set <klucz> <wartość>        # Ustaw wartość konfiguracji
citadel.sh config-get <klucz>                  # Pobierz wartość konfiguracji
```

### Zarządzanie profilami

```bash
citadel.sh config-list-profiles                # Lista dostępnych profili
citadel.sh config-switch-profile <profil>      # Przełącz na profil
citadel.sh config-apply                        # Zastosuj zmiany konfiguracji
```

### Import/Eksport

```bash
citadel.sh config-export <plik>                # Eksportuj konfigurację
citadel.sh config-import <plik>                # Importuj konfigurację
citadel.sh config-diff <plik1> <plik2>         # Porównaj konfiguracje
citadel.sh config-reset                        # Resetuj do wartości domyślnych
```

### Walidacja

```bash
citadel.sh config-validate                     # Waliduj obecną konfigurację
citadel.sh config-validate <plik>              # Waliduj konkretny plik
```

## Komendy modułów

### Odkrywanie modułów

```bash
citadel.sh module-list                         # Lista wszystkich modułów
citadel.sh module-list --details               # Szczegółowe informacje o modułach
citadel.sh module-discover                     # Odkryj nowe moduły
```

### Zarządzanie modułami

```bash
citadel.sh module-load <nazwa>                 # Załaduj moduł
citadel.sh module-unload <nazwa>               # Rozładuj moduł
citadel.sh module-reload <nazwa>               # Przeładuj moduł

citadel.sh module-load-all                     # Załaduj wszystkie dostępne moduły
citadel.sh module-unload-all                   # Rozładuj wszystkie moduły
```

### Informacje o modułach

```bash
citadel.sh module-info <nazwa>                 # Wyświetl informacje o module
citadel.sh module-status <nazwa>               # Wyświetl status modułu
citadel.sh module-dependencies <nazwa>         # Wyświetl zależności modułu
```

## Opcje linii komend

### Opcje globalne

```bash
--help, -h              Wyświetl informacje pomocy
--version, -v           Wyświetl wersję
--verbose, -V           Włącz szczegółowe wyjście
--quiet, -q             Wyłącz wyjście
--json                  Wyjście w formacie JSON
--dry-run               Pokaż co zostanie wykonane bez wykonywania
--force                 Wymuś operację (pomiń potwierdzenia)
--config <plik>         Użyj konkretnego pliku konfiguracyjnego
```

### Opcje specyficzne dla komend

#### Filtry czasowe

```bash
--since <czas>         Filtruj wg czasu (np. 1h, 30m, 1d)
--until <czas>         Filtruj do czasu
--period <czas>        Okres analizy
```

#### Filtry wyjścia

```bash
--level <poziom>       Filtruj wg poziomu logów (debug, info, warn, error)
--category <kategoria> Filtruj wg kategorii
--limit <liczba>       Ogranicz liczbę wyników
--tail <liczba>        Wyświetl ostatnie N wpisów
```

#### Opcje formatowania

```bash
--format <format>      Format wyjścia (text, json, yaml, table)
--columns <kolumny>    Określ kolumny do wyświetlenia
--no-headers           Nie wyświetlaj nagłówków
--sort <kolumna>       Sortuj wg kolumny
--reverse              Odwróć sortowanie
```

## Kody wyjścia

| Kod | Znaczenie |
|-----|-----------|
| 0   | Sukces |
| 1   | Ogólny błąd |
| 2   | Komenda nie znaleziona |
| 3   | Brak uprawnień |
| 4   | Błąd konfiguracji |
| 5   | Błąd usługi |
| 6   | Błąd sieci |
| 7   | Błąd walidacji |
| 8   | Błąd zależności |
| 9   | Przekroczenie czasu |

## Przykłady

### Kompletne ustawienia

```bash
# Zainstaluj z profilem enterprise
sudo ./scripts/citadel-install-cli.sh --profile enterprise --verbose

# Inicjalizuj konfigurację
sudo citadel.sh config-init

# Skonfiguruj funkcje enterprise
sudo citadel.sh enterprise-init

# Utwórz i uruchom usługi
sudo citadel.sh service-setup-all
sudo citadel.sh service-start citadel-main

# Sprawdź status
sudo citadel.sh status
sudo citadel.sh monitoring-health-check
```

### Monitorowanie bezpieczeństwa

```bash
# Włącz funkcje bezpieczeństwa
sudo citadel.sh reputation list
sudo citadel.sh honeypot start
sudo citadel.sh events query --tail 20

# Monitoruj w czasie rzeczywistym
watch -n 5 'sudo citadel.sh status'
```

### Wdrożenie korporacyjne

```bash
# Skonfiguruj Prometheus/Grafana
sudo citadel.sh prometheus-setup
sudo citadel.sh grafana-setup

# Skonfiguruj wysoką dostępność
sudo citadel.sh scalability-init

# Sprawdź status enterprise
sudo citadel.sh enterprise-status
```

## Rozwiązywanie problemów

### Najczęstsze problemy

1. **Brak uprawnień** - Uruchom z `sudo`
2. **Usługa nie znaleziona** - Sprawdź czy usługi są utworzone przez `service-setup-all`
3. **Moduł nie załadowany** - Załaduj moduły przez `module-load <nazwa>`
4. **Konfiguracja nieprawidłowa** - Waliduj przez `config-validate`

### Uzyskiwanie pomocy

```bash
# Pomoc specyficzna dla komendy
citadel.sh <komenda> --help

# Ogólna pomoc
citadel.sh --help

# Sprawdź logi
sudo journalctl -u citadel-*

# Tryb debugowania
CITADEL_DEBUG=1 citadel.sh <komenda>
```

---

*Więcej szczegółowych informacji znajdziesz w głównej dokumentacji w [README_PL.md](README_PL.md)*
