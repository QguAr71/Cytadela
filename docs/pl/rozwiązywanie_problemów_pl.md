# Rozwiązywanie problemów - Citadel v3.3

Ten przewodnik pomoże Ci rozwiązać najczęstsze problemy z Citadel v3.3.

## 🔍 Diagnoza problemów

### Sprawdź status systemu

Zawsze zaczynaj od sprawdzenia ogólnego statusu:

```bash
# Podstawowy status
sudo citadel.sh status

# Szczegółowy status
sudo citadel.sh status --verbose

# Sprawdzenie zdrowia
sudo citadel.sh monitoring-health-check
```

### Sprawdź logi

```bash
# Logi systemd
sudo journalctl -u citadel-* --since "1 hour ago"

# Logi aplikacji
tail -f /var/log/citadel/citadel.log

# Logi zdarzeń
sudo citadel.sh events query --level error --tail 20

# Logi bezpieczeństwa
tail -f /var/log/citadel/security.log
```

### Sprawdź konfigurację

```bash
# Waliduj konfigurację
sudo citadel.sh config-validate

# Wyświetl konfigurację
sudo citadel.sh config-show

# Sprawdź pliki konfiguracyjne
ls -la /etc/citadel/
cat /etc/citadel/config.yaml
```

## 🚨 Problemy z instalacją

### Problem: Brak uprawnień (Permission denied)

**Objawy:**
```
Error: Permission denied
./citadel-install-cli.sh: Permission denied
```

**Rozwiązania:**

```bash
# Uruchom z sudo
sudo ./scripts/citadel-install-cli.sh

# Lub nadaj uprawnienia
chmod +x citadel.sh
chmod +x scripts/citadel-install-cli.sh

# Sprawdź czy jesteś w odpowiedniej grupie
groups
```

### Problem: Brakujące zależności

**Objawy:**
```
Error: jq command not found
Error: curl command not found
Error: yq command not found
```

**Rozwiązania:**

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install jq curl wget nftables systemd

# Arch Linux
sudo pacman -S jq curl wget nftables systemd

# Fedora/RHEL
sudo dnf install jq curl wget nftables systemd

# Dla yq (opcjonalne, ale zalecane)
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
```

### Problem: Instalator się zawiesza

**Objawy:**
- Instalator przestaje odpowiadać
- Brak postępu przez długi czas

**Rozwiązania:**

```bash
# Uruchom w trybie verbose
sudo ./citadel-install-cli.sh --verbose

# Sprawdź procesy
ps aux | grep citadel

# Zabij wiszące procesy
sudo pkill -f citadel

# Spróbuj instalacji krok po kroku
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-all
```

## 🛡️ Problemy z bezpieczeństwem

### Problem: Firewall nie działa

**Objawy:**
```
Error: nftables rules failed
nft: command not found
```

**Rozwiązania:**

```bash
# Sprawdź czy nftables jest zainstalowany
which nft
sudo systemctl status nftables

# Zainstaluj nftables jeśli brakuje
sudo apt-get install nftables

# Przeładuj reguły firewall
sudo nft flush ruleset
sudo citadel.sh security reload

# Sprawdź status firewall
sudo nft list ruleset
```

### Problem: Moduły bezpieczeństwa nie ładują się

**Objawy:**
```
Error: Module not found
Error: Failed to load module
```

**Rozwiązania:**

```bash
# Sprawdź dostępne moduły
sudo citadel.sh module-list

# Odkryj nowe moduły
sudo citadel.sh module-discover

# Załaduj moduły ręcznie
sudo citadel.sh module-load unified-security
sudo citadel.sh module-load reputation
sudo citadel.sh module-load asn-blocking

# Sprawdź ścieżki modułów
ls -la lib/
ls -la modules/unified/
```

### Problem: System reputacji nie działa

**Objawy:**
- Brak blokowania podejrzanych IP
- `reputation list` pokazuje pustą listę

**Rozwiązania:**

```bash
# Sprawdź status modułu reputacji
sudo citadel.sh module-info reputation

# Przeładuj moduł
sudo citadel.sh module-reload reputation

# Sprawdź konfigurację
sudo citadel.sh config-show security.reputation

# Zresetuj dane reputacji
sudo citadel.sh reputation reset
```

### Problem: Honeypot nie wychwytuje połączeń

**Objawy:**
- Brak logów połączeń w honeypot
- `honeypot logs` pokazuje puste wyniki

**Rozwiązania:**

```bash
# Sprawdź status honeypot
sudo citadel.sh honeypot status

# Uruchom honeypot
sudo citadel.sh honeypot start

# Sprawdź czy porty są otwarte
sudo netstat -tlnp | grep :22
sudo netstat -tlnp | grep :80

# Sprawdź firewall
sudo nft list ruleset | grep honeypot
```

## ⚙️ Problemy z konfiguracją

### Problem: Błąd walidacji konfiguracji

**Objawy:**
```
Error: Configuration validation failed
YAML syntax error
```

**Rozwiązania:**

```bash
# Sprawdź składnię YAML
python3 -c "import yaml; yaml.safe_load(open('/etc/citadel/config.yaml'))"

# Napraw składnię YAML
sudo nano /etc/citadel/config.yaml

# Przeładuj konfigurację
sudo citadel.sh config-apply

# Sprawdź błędy szczegółowo
sudo citadel.sh config-validate --verbose
```

### Problem: Zmiany konfiguracji nie działają

**Objawy:**
- Konfiguracja się zapisuje ale ustawienia nie obowiązują

**Rozwiązania:**

```bash
# Zastosuj zmiany
sudo citadel.sh config-apply

# Przeładuj odpowiednie moduły
sudo citadel.sh module-reload unified-security

# Zrestartuj usługi
sudo citadel.sh service-restart citadel-main

# Sprawdź czy pliki są aktualne
ls -la /etc/citadel/
```

### Problem: Profile konfiguracyjne nie przełączają się

**Objawy:**
```
Error: Profile switch failed
```

**Rozwiązania:**

```bash
# Sprawdź dostępne profile
sudo citadel.sh config-list-profiles

# Przełącz profil z wymuszaniem
sudo citadel.sh config-switch-profile enterprise --force

# Zastosuj zmiany
sudo citadel.sh config-apply

# Sprawdź czy profil został przełączony
sudo citadel.sh config-show profile
```

## 🔧 Problemy z usługami

### Problem: Usługa Citadel nie uruchamia się

**Objawy:**
```
Error: Service failed to start
Failed to start citadel-main.service
```

**Rozwiązania:**

```bash
# Sprawdź status usługi
sudo systemctl status citadel-main.service

# Sprawdź logi systemd
sudo journalctl -u citadel-main.service --no-pager -n 50

# Przeładuj systemd
sudo systemctl daemon-reload

# Spróbuj uruchomić ręcznie
sudo citadel.sh service-start citadel-main

# Sprawdź zależności
sudo systemctl list-dependencies citadel-main.service
```

### Problem: Usługi Citadel nie są skonfigurowane

**Objawy:**
```
Error: Service not found
Unit citadel-main.service not found
```

**Rozwiązania:**

```bash
# Skonfiguruj wszystkie usługi
sudo citadel.sh service-setup-all

# Sprawdź utworzone pliki usług
ls -la /etc/systemd/system/citadel-*

# Przeładuj systemd
sudo systemctl daemon-reload

# Włącz i uruchom usługi
sudo citadel.sh service-enable citadel-main
sudo citadel.sh service-start citadel-main
```

### Problem: Konflikt portów

**Objawy:**
```
Error: Port already in use
Address already in use
```

**Rozwiązania:**

```bash
# Znajdź proces używający portu
sudo lsof -i :9090
sudo netstat -tlnp | grep :9090

# Zmień port w konfiguracji
sudo citadel.sh config-set enterprise.prometheus.port 9091
sudo citadel.sh config-set enterprise.grafana.port 3001

# Zrestartuj usługi
sudo citadel.sh service-restart citadel-main
```

## 📊 Problemy z wydajnością

### Problem: Wysokie użycie CPU

**Objawy:**
- Wysokie użycie CPU przez procesy Citadel
- System staje się wolny

**Diagnoza:**

```bash
# Sprawdź użycie CPU
top -p $(pgrep citadel.sh | tr '\n' ',' | sed 's/,$//')

# Sprawdź metryki systemu
sudo citadel.sh enterprise-metrics

# Analizuj logi wydajności
sudo citadel.sh monitoring-performance
```

**Rozwiązania:**

```bash
# Zoptymalizuj konfigurację
sudo citadel.sh config-set logging.level warning
sudo citadel.sh config-set security.reputation.update_interval 300
sudo citadel.sh config-set enterprise.prometheus.scrape_interval 30s

# Ogranicz liczbę równoczesnych połączeń
sudo citadel.sh config-set security.honeypot.max_connections 10

# Przeładuj konfigurację
sudo citadel.sh config-apply
sudo citadel.sh service-restart citadel-main
```

### Problem: Brak miejsca na dysku

**Objawy:**
```
Error: No space left on device
```

**Rozwiązania:**

```bash
# Sprawdź użycie dysku
df -h
du -sh /var/log/citadel/*

# Obróć logi
sudo citadel.sh events rotate

# Wyczyść stare logi
sudo find /var/log/citadel -name "*.log.*" -mtime +30 -delete

# Skompresuj stare logi
sudo find /var/log/citadel -name "*.log.*" -exec gzip {} \;

# Zmień politykę retencji
sudo citadel.sh config-set event_logging.retention 7d
sudo citadel.sh config-apply
```

### Problem: Wysokie użycie pamięci

**Objawy:**
- Wysokie użycie RAM przez Citadel
- System swapuje

**Rozwiązania:**

```bash
# Sprawdź użycie pamięci
ps aux --sort=-%mem | head -10

# Zoptymalizuj cache
sudo citadel.sh config-set core.dns.cache.size 512MB
sudo citadel.sh config-set security.reputation.cache_size 1000

# Ogranicz liczbę worker'ów
sudo citadel.sh config-set enterprise.prometheus.max_workers 2

# Przeładuj konfigurację
sudo citadel.sh config-apply
```

## 🌐 Problemy z integracją

### Problem: Prometheus nie zbiera metryk

**Objawy:**
- Brak danych w Prometheus
- Grafana pokazuje puste dashboard'y

**Rozwiązania:**

```bash
# Sprawdź status Prometheus
sudo systemctl status prometheus

# Sprawdź konfigurację
cat /etc/prometheus/prometheus.yml

# Zrestartuj Prometheus
sudo systemctl restart prometheus

# Sprawdź endpoint metryk
curl http://localhost:9090/metrics

# Sprawdź logi
sudo journalctl -u prometheus --no-pager -n 20
```

### Problem: Grafana nie łączy się z Prometheus

**Objawy:**
- Grafana pokazuje błąd połączenia
- Brak danych w dashboard'ach

**Rozwiązania:**

```bash
# Sprawdź status Grafana
sudo systemctl status grafana-server

# Sprawdź konfigurację datasource
cat /etc/grafana/provisioning/datasources/prometheus.yml

# Zrestartuj Grafana
sudo systemctl restart grafana-server

# Sprawdź dostępność Prometheus
curl http://localhost:9090/-/healthy

# Sprawdź logi Grafana
sudo journalctl -u grafana-server --no-pager -n 20
```

### Problem: Docker kontenery nie uruchamiają się

**Objawy:**
```
Error: docker command not found
Error: Cannot connect to the Docker daemon
```

**Rozwiązania:**

```bash
# Sprawdź status Docker
sudo systemctl status docker

# Uruchom Docker jeśli nie działa
sudo systemctl start docker

# Dodaj użytkownika do grupy docker
sudo usermod -aG docker $USER

# Zrestartuj sesję
# newgrp docker

# Sprawdź konfigurację docker-compose
cat /etc/citadel/docker-compose.yml

# Uruchom kontenery
cd /etc/citadel && docker-compose up -d

# Sprawdź logi kontenerów
docker-compose logs
```

## 🔄 Problemy z aktualizacjami

### Problem: Aktualizacja się nie powiodła

**Objawy:**
```
Error: Update failed
```

**Rozwiązania:**

```bash
# Sprawdź dostępność repozytorium
git status

# Pobierz najnowsze zmiany
git pull origin main

# Sprawdź konflikty
git status

# Rozwiąż konflikty jeśli są
# Następnie uruchom ponownie instalację
sudo ./citadel-install-cli.sh --update

# Lub ręczna aktualizacja
sudo citadel.sh module-reload unified-security
sudo citadel.sh service-restart citadel-main
```

### Problem: Wersje modułów są niezgodne

**Objawy:**
```
Error: Module version mismatch
```

**Rozwiązania:**

```bash
# Sprawdź wersje modułów
sudo citadel.sh module-list --versions

# Przeładuj wszystkie moduły
sudo citadel.sh module-unload-all
sudo citadel.sh module-load-all

# Sprawdź kompatybilność
sudo citadel.sh config-validate

# Zrestartuj usługi
sudo citadel.sh service-restart-all
```

## 🆘 Zaawansowana diagnostyka

### Tryb debugowania

```bash
# Włącz debugowanie globalne
export CITADEL_DEBUG=1
sudo citadel.sh <komenda>

# Debuguj konkretny moduł
sudo citadel.sh module-info <nazwa_modułu> --debug

# Sprawdź zmienne środowiskowe
env | grep CITADEL
```

### Zbieranie informacji diagnostycznych

```bash
# Utwórz raport diagnostyczny
sudo citadel.sh diagnostic-report > citadel-diagnostic-$(date +%Y%m%d-%H%M%S).txt

# Zawartość powinna zawierać:
# - Status systemu
# - Konfiguracja
# - Logi błędów
# - Informacje o systemie
# - Status usług
```

### Resetowanie systemu

Jeśli wszystko inne zawiedzie:

```bash
# Krok 1: Zatrzymaj wszystkie usługi
sudo citadel.sh service-stop-all

# Krok 2: Resetuj konfigurację
sudo citadel.sh config-reset

# Krok 3: Wyczyść dane modułów
sudo rm -rf /var/lib/citadel/*
sudo rm -rf /var/run/citadel/*

# Krok 4: Przeładuj moduły
sudo citadel.sh module-discover
sudo citadel.sh module-load-all

# Krok 5: Przeinstaluj usługi
sudo citadel.sh service-remove-all
sudo citadel.sh service-setup-all

# Krok 6: Uruchom system
sudo citadel.sh service-start citadel-main
sudo citadel.sh status
```

## 📞 Uzyskiwanie pomocy

### Społeczność i wsparcie

- **GitHub Issues**: [Zgłaszanie błędów](https://github.com/QguAr71/Cytadela/issues)
- **GitHub Discussions**: [Dyskusje i pytania](https://github.com/QguAr71/Cytadela/discussions)
- **Dokumentacja**: [docs/](docs/)
- **Logi diagnostyczne**: Przy zgłaszaniu problemów dołącz logi z `journalctl -u citadel-*`

### Przed zgłoszeniem problemu

1. **Zbierz informacje**:
   - Wersja Citadel: `citadel.sh --version`
   - Wersja systemu: `uname -a`
   - Status systemu: `citadel.sh status`
   - Logi błędów: `journalctl -u citadel-* --since "1 hour ago"`

2. **Spróbuj podstawowych rozwiązań**:
   - Przeładuj systemd: `sudo systemctl daemon-reload`
   - Przeładuj moduły: `sudo citadel.sh module-reload-all`
   - Zrestartuj usługi: `sudo citadel.sh service-restart-all`

3. **Opisz problem szczegółowo**:
   - Co robiłeś gdy wystąpił błąd?
   - Jaki jest dokładny komunikat błędu?
   - Jakie kroki podjęłeś aby rozwiązać problem?

---

*Pamiętaj: Większość problemów można rozwiązać sprawdzając logi i wykonując podstawowe kroki diagnostyczne. Jeśli problem będzie się powtarzał, zgłoś go w GitHub Issues z pełnymi informacjami diagnostycznymi.*
