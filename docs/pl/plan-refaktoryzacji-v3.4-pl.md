# 🌐 Plan Refaktoryzacji v3.4 - Web Dashboard

**Wersja:** 3.4.0 PLANOWANA
**Utworzono:** 2026-01-31
**Zaktualizowano:** 2026-01-31 (połączone z planem użytkownika)
**Status:** Faza planowania
**Szacowany czas:** 2-3 tygodnie (z pomocą AI)
**Wymagania wstępne:** v3.3.0 (Reputation, ASN, Event Logging, Honeypot)
**Podejście:** PoC-first (zacznij od minimalnego endpointu /stats)

---

## 📋 Spis Treści

1. [Podsumowanie wykonawcze](#podsumowanie-wykonawcze)
2. [Architektura techniczna](#architektura-techniczna)
3. [Funkcje](#funkcje)
4. [Plan implementacji](#plan-implementacji)
5. [Zagadnienia bezpieczeństwa](#zagadnienia-bezpieczeństwa)
6. [Harmonogram i kamienie milowe](#harmonogram-i-kamienie-milowe)
7. [Strategia testowania](#strategia-testowania)

---

## 🎯 Podsumowanie Wykonawcze

### Cele

- **Dodaj Web Dashboard:** Lokalny interfejs WWW tylko dla monitorowania i zarządzania
- **Zachowaj bezpieczeństwo:** Minimalna powierzchnia ataku, brak ekspozycji sieciowej
- **Zachowaj prostotę:** Lekki stos (htmx + Bash CGI)
- **Opcjonalna funkcja:** Flaga `--web` do włączania/wyłączania
- **Konkurencyjna:** Dorównaj UX Pi-hole przy zachowaniu fokusu na prywatności

### Korzyści

- ✅ Niższy próg wejścia (użytkownicy nie-CLI)
- ✅ Wizualne metryki (wykresy, statystyki w czasie rzeczywistym)
- ✅ Konkurencyjna z Pi-hole/AdGuard
- ✅ Wzrost społeczności (łatwiejsza adopcja)
- ✅ Lepsze debugowanie (wizualne logi)

### Kompromisy

- ⚠️ +Powierzchnia ataku (łagodzone: tylko localhost)
- ⚠️ +Nakład utrzymania (testy UI, multi-lang)
- ⚠️ +Czas rozwoju (~3-4 tygodnie)

### Cele nieobejmowane

- ❌ Dostęp sieciowy (ryzyko bezpieczeństwa)
- ❌ Uwierzytelnianie (niepotrzebne dla localhost)
- ❌ Ciężkie frameworki (React, Vue - zbyt skomplikowane)
- ❌ Zastąpienie CLI (UI jest komplementarne)

---

## 🔧 Architektura Techniczna

### Stos

**Backend:**
- Skrypty Bash CGI
- Netcat/socat dla serwera HTTP
- Integracja metryk Prometheus
- Endpoints API JSON

**Frontend:**
- htmx (hypermedia, ~14kB)
- Vanilla CSS (bez frameworków)
- Minimalny JavaScript (tylko wykresy)

**Serwer:**
- Tylko localhost: `127.0.0.1:9154`
- HTTPS (certyfikat self-signed via openssl)
- Usługa systemd: `cytadela-web.service`
- Alternatywa: Apache CGI lub socat/netcat

### Diagram Architektury

```
┌─────────────────────────────────────────┐
│  Browser (localhost:9154)               │
└─────────────────┬───────────────────────┘
                  │ HTTP
                  ↓
┌─────────────────────────────────────────┐
│  Netcat/Socat HTTP Server               │
│  (Bash CGI handler)                     │
└─────────────────┬───────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    ↓             ↓             ↓
┌─────────┐  ┌─────────┐  ┌─────────┐
│ Status  │  │ Metrics │  │ Logs    │
│ API     │  │ API     │  │ API     │
└────┬────┘  └────┬────┘  └────┬────┘
     │            │            │
     ↓            ↓            ↓
┌─────────────────────────────────────────┐
│  Cytadela Core (Bash modules)           │
│  - unified-monitor.sh                   │
│  - unified-security.sh                  │
│  - lib/reputation.sh                    │
│  - lib/event-logger.sh                  │
└─────────────────────────────────────────┘
```

---

## 🎨 Funkcje

### 1. Dashboard (Home)

**Co to jest:** Przegląd statusu systemu

**Komponenty:**
- Status DNS (CoreDNS, DNSCrypt)
- Status Firewall (nftables)
- Zdrowie systemu (CPU, RAM, uptime)
- Szybkie statystyki (zapytania/min, zablokowane, współczynnik trafień cache)

**Implementacja:**
```bash
# /opt/cytadela/web/cgi-bin/dashboard.sh
#!/bin/bash
source /opt/cytadela/lib/cytadela-core.sh

# Pobierz status
dns_status=$(systemctl is-active coredns)
firewall_status=$(nft list tables 2>/dev/null | grep -q "inet filter" && echo "active" || echo "inactive")

# Wyjście JSON
cat <<EOF
{
  "dns": "$dns_status",
  "firewall": "$firewall_status",
  "uptime": "$(uptime -p)",
  "queries_per_min": $(get_queries_per_min)
}
EOF
```

**Frontend (htmx):**
```html
<div hx-get="/api/dashboard" hx-trigger="every 5s" hx-swap="innerHTML">
  <div class="card">
    <h3>Status DNS</h3>
    <span class="status-active">Aktywny</span>
  </div>
</div>
```

---

### 2. Log Zapytania

**Co to jest:** Log zapytań DNS w czasie rzeczywistym

**Funkcje:**
- Ostatnie 100 zapytań
- Filtrowanie po domenie/IP
- Pokazanie zablokowanych/dozwolonych
- Eksport do CSV

**Implementacja:**
```bash
# /opt/cytadela/web/cgi-bin/queries.sh
#!/bin/bash

# Parsuj logi CoreDNS
tail -n 100 /var/log/coredns/queries.log | \
  awk '{print $1, $2, $3, $4}' | \
  jq -R -s 'split("\n") | map(select(length > 0) | split(" ") | {
    timestamp: .[0],
    domain: .[1],
    type: .[2],
    result: .[3]
  })'
```

---

### 3. Zarządzanie Blocklist

**Co to jest:** Zarządzaj listami adblock

**Funkcje:**
- Lista aktywnych blocklist
- Włącz/wyłącz listy
- Dodaj własne domeny
- Przebuduj blocklist

**Implementacja:**
```bash
# /opt/cytadela/web/cgi-bin/blocklists.sh
#!/bin/bash

case "$REQUEST_METHOD" in
  GET)
    # Lista blocklist
    cat /etc/cytadela/blocklists.conf | jq -R -s 'split("\n") | map(select(length > 0))'
    ;;
  POST)
    # Dodaj/usuń blocklist
    domain="$POST_domain"
    action="$POST_action"
    
    if [[ "$action" == "add" ]]; then
      echo "$domain" >> /etc/cytadela/custom-blocklist.txt
      citadel adblock rebuild
    fi
    ;;
esac
```

---

### 4. Metryki i Wykresy

**Co to jest:** Wizualne metryki z Prometheus

**Funkcje:**
- Współczynnik trafień cache (wykres liniowy)
- Zapytania na minutę (wykres słupkowy)
- Top zablokowanych domen (wykres kołowy)
- Dane historyczne (ostatnie 24h)

**Implementacja:**
```bash
# /opt/cytadela/web/cgi-bin/metrics.sh
#!/bin/bash

# Zapytanie do Prometheus
curl -s "http://localhost:9090/api/v1/query?query=coredns_cache_hits_total" | \
  jq '.data.result[0].value[1]'
```

**Frontend (Chart.js):**
```html
<canvas id="cacheChart"></canvas>
<script>
  fetch('/api/metrics/cache')
    .then(r => r.json())
    .then(data => {
      new Chart(ctx, {
        type: 'line',
        data: { labels: data.timestamps, datasets: [{ data: data.values }] }
      });
    });
</script>
```

---

### 5. Ustawienia

**Co to jest:** Zarządzanie konfiguracją

**Funkcje:**
- Ustawienia DNS (upstream, rozmiar cache)
- Tryb firewall (safe/strict)
- Próg reputacji
- Toggle auto-aktualizacji

**Implementacja:**
```bash
# /opt/cytadela/web/cgi-bin/settings.sh
#!/bin/bash

case "$REQUEST_METHOD" in
  GET)
    # Odczytaj config
    cat /etc/cytadela/config.json
    ;;
  POST)
    # Zaktualizuj config
    jq ".firewall_mode = \"$POST_firewall_mode\"" /etc/cytadela/config.json > /tmp/config.json
    mv /tmp/config.json /etc/cytadela/config.json
    
    # Zastosuj zmiany
    citadel firewall-mode "$POST_firewall_mode"
    ;;
esac
```

---

## 📅 Plan Implementacji

### Faza 1: PoC + Fundamenty Backend (Tydzień 1)

**Zadania:**
1. **PoC:** Prosty endpoint `/stats` (Bash CGI + test curl)
2. Zainstaluj zależności (htmx.js via CDN, openssl dla cert)
3. Utwórz `modules/web-ui.sh` (funkcje web_start/stop)
4. Wygeneruj self-signed cert HTTPS
5. Utwórz serwer HTTPS (socat/netcat z SSL)
6. Zaimplementuj handler CGI (Bash)
7. Utwórz strukturę endpoints API
8. Dodaj usługę systemd
9. Testuj podstawowe routing

**Rezultaty:**
- **PoC:** Działa endpoint `/stats`
- `modules/web-ui.sh` - Moduł Web UI
- `lib/web-server.sh` - Serwer HTTPS
- `web/cgi-bin/` - Skrypty CGI
- Cert self-signed: `/etc/cytadela/ssl/`
- `systemd/cytadela-web.service`
- Podstawowe API działa

**Czas:** 4-6 dni (PoC: 1 dzień, reszta: 3-5 dni)

---

### Faza 2: Endpoints API (Tydzień 1-2)

**Zadania:**
1. Dashboard API (`/api/dashboard`) - integracja z cache-stats.sh
2. Query log API (`/api/queries`) - parsuj logi CoreDNS
3. Blocklist API (`/api/blocklists`) - integracja z blocklist-manager.sh
4. Metrics API (`/api/metrics`) - integracja Prometheus
5. Settings API (`/api/settings`) - zarządzanie config
6. Formatowanie odpowiedzi JSON
7. Sanitizacja wejścia (z wzorców adblock.sh)

**Rezultaty:**
- 5 działających endpoints API
- Odpowiedzi JSON
- Obsługa błędów
- Walidacja wejścia

**Czas:** 4-5 dni

---

### Faza 3: Frontend (Tydzień 2)

**Zadania:**
1. Pliki statyczne w `docs/web-ui/` (index.html, css)
2. Sekcje dashboard (stats, adblock, diagnostics)
3. Integracja htmx:
   - `<div hx-get="/stats" hx-trigger="every 5s">` - auto-odświeżanie
   - Formy z hx-post dla akcji
4. Styling CSS (responsive, dark mode)
5. Chart.js dla metryk (opcjonalne)
6. Wsparcie multi-language (i18n via ?lang=pl)

**Rezultaty:**
- `docs/web-ui/` - HTML/CSS/JS
- htmx dynamiczne aktualizacje (odświeżanie 5s)
- Responsive UI
- Dark mode
- Multi-lang (PL/EN)

**Czas:** 5-7 dni

---

### Faza 4: Integracja i Testowanie (Tydzień 3)

**Zadania:**
1. Zintegruj z module-loader (lazy load web-ui.sh)
2. Dodaj polecenia `citadel web start|stop|status`
3. Opcjonalna flaga `--web` w install-wizard
4. Wzmocnienie bezpieczeństwa:
   - Wymuszenie HTTPS
   - Tokeny CSRF
   - Rate limiting
   - Walidacja wejścia
5. Testowanie:
   - `tests/test-web-ui.sh` (curl endpoints, sprawdz JSON)
   - Integracja CI (shellcheck.yml)
   - Testowanie przeglądarki (Chrome, Firefox)
6. Testowanie wydajności (obciążenie, pamięć)
7. Dokumentacja:
   - Zaktualizuj MANUAL_EN.md (sekcja Web UI)
   - Zaktualizuj ROADMAP.md
   - Aktualizacja Issue #18

**Rezultaty:**
- Pełna integracja z core
- Audyt bezpieczeństwa zaliczony
- Zestaw testów (unit + integration)
- Benchmarki wydajności
- Kompletna dokumentacja

**Czas:** 5-7 dni

---

## 🔒 Zagadnienia Bezpieczeństwa

### Model Zagrożeń

**Zagrożenia:**
1. **Lokalny atakujący** - Użytkownik z dostępem do shell
2. **MITM** - Sniffing sieci (localhost)
3. **XSS** - Złośliwe wejście w formy
4. **CSRF** - Cross-site request forgery

### Łagodzenia

**1. Tylko localhost**
```bash
# Bind tylko do 127.0.0.1
netcat -l 127.0.0.1 9154
```

**2. Walidacja wejścia**
```bash
# Sanitizuj wejście użytkownika
sanitize_input() {
    local input="$1"
    echo "$input" | sed 's/[^a-zA-Z0-9._-]//g'
}
```

**3. Tokeny CSRF**
```bash
# Wygeneruj token
csrf_token=$(openssl rand -hex 16)
echo "$csrf_token" > /tmp/cytadela-csrf-token

# Waliduj
if [[ "$POST_csrf_token" != "$(cat /tmp/cytadela-csrf-token)" ]]; then
    echo "HTTP/1.1 403 Forbidden"
    exit 1
fi
```

**4. Nagłówki Content-Type**
```bash
# Zapobiegaj XSS
echo "Content-Type: application/json"
echo "X-Content-Type-Options: nosniff"
```

**5. Rate limiting**
```bash
# Max 100 zapytań na minutę
if (( $(wc -l < /tmp/cytadela-requests.log) > 100 )); then
    echo "HTTP/1.1 429 Too Many Requests"
    exit 1
fi
```

---

## ⏰ Harmonogram i Kamienie Milowe

### Tydzień 1: PoC + Backend
- **Dzień 1:** PoC - Prosty endpoint /stats
- **Dzień 2-3:** Serwer HTTPS + handler CGI + self-signed cert
- **Dzień 4-5:** Endpoints API (dashboard, queries, blocklists)
- **Dzień 6:** Testowanie + usługa systemd
- **Kamień milowy:** Backend działa z HTTPS

### Tydzień 2: Frontend
- **Dzień 1-2:** Metrics + Settings API
- **Dzień 3-4:** Szablony HTML + integracja htmx
- **Dzień 5-6:** Styling CSS + dark mode
- **Dzień 7:** Multi-lang (i18n)
- **Kamień milowy:** UI kompletne

### Tydzień 3: Integracja + Wydanie
- **Dzień 1-2:** Integracja z module-loader
- **Dzień 3-4:** Audyt bezpieczeństwa (HTTPS, CSRF, rate limit)
- **Dzień 5:** Testowanie (unit, integration, browser)
- **Dzień 6:** Dokumentacja (MANUAL, ROADMAP)
- **Dzień 7:** Wydanie v3.4.0
- **Kamień milowy:** Web UI wydane

---

## 🧪 Strategia Testowania

### Testy Jednostkowe

```bash
# Test endpoints API
test_dashboard_api() {
    response=$(curl -s http://127.0.0.1:9154/api/dashboard)
    assert_contains "$response" "dns"
    assert_contains "$response" "firewall"
}

test_blocklist_api() {
    response=$(curl -s -X POST http://127.0.0.1:9154/api/blocklists \
      -d "domain=example.com&action=add")
    assert_equals "$response" '{"status":"ok"}'
}
```

### Testy Integracyjne

```bash
# Test pełnego workflow
test_add_blocklist_and_rebuild() {
    # Dodaj domenę via UI
    curl -X POST http://127.0.0.1:9154/api/blocklists \
      -d "domain=ads.example.com&action=add"
    
    # Zweryfikuj w blocklist
    assert_file_contains /etc/cytadela/custom-blocklist.txt "ads.example.com"
    
    # Zweryfikuj przebudowę wywołaną
    assert_file_newer /var/lib/cytadela/blocklist.txt
}
```

### Testy Przeglądarki

- Chrome 120+ (desktop, mobile)
- Firefox 120+ (desktop, mobile)
- Safari 17+ (macOS, iOS)

### Testy Wydajności

```bash
# Test obciążenia
ab -n 1000 -c 10 http://127.0.0.1:9154/api/dashboard

# Użycie pamięci
ps aux | grep cytadela-web | awk '{print $6}'
```

---

## 📊 Kryteria Sukcesu

### Techniczne

- ✅ Wszystkie endpoints API działające
- ✅ UI responsywne (mobile + desktop)
- ✅ Czas ładowania < 1s
- ✅ Użycie pamięci < 50MB
- ✅ Audyt bezpieczeństwa zaliczony

### Doświadczenie Użytkownika

- ✅ Intuicyjna nawigacja
- ✅ Aktualizacje w czasie rzeczywistym (< 5s opóźnienie)
- ✅ Wsparcie multi-language
- ✅ Dark mode działające
- ✅ Brak błędów JavaScript

### Dokumentacja

- ✅ Przewodnik instalacji
- ✅ Dokumentacja API
- ✅ Najlepsze praktyki bezpieczeństwa
- ✅ Przewodnik rozwiązywania problemów

---

## 🚀 Strategia Wdrożenia

### Alpha (Wewnętrzne)

- **Wersja:** v3.4.0-alpha
- **Czas trwania:** 1 tydzień
- **Cel:** Znajdź krytyczne błędy

### Beta (Wcześni Adopci)

- **Wersja:** v3.4.0-beta
- **Czas trwania:** 2 tygodnie
- **Cel:** Testowanie w rzeczywistym świecie

### Wydanie Stabilne

- **Wersja:** v3.4.0
- **Ogłoszenie:** GitHub, Reddit (r/selfhosted, r/privacy)

---

## 📝 Aktualizacje Dokumentacji

### Dokumentacja Użytkownika

- `docs/user/web-dashboard.md` - Przewodnik Web UI
- `docs/user/MANUAL_PL.md` - Dodaj sekcję web UI
- `docs/user/MANUAL_EN.md` - Dodaj sekcję web UI
- `docs/user/quick-start.md` - Dodaj szybki start web UI

### Dokumentacja Dewelopera

- `docs/developer/web-api.md` - Referencja API
- `docs/developer/web-architecture.md` - Dokumentacja architektury
- `CONTRIBUTING.md` - Dodaj przewodnik współtworzenia web UI

---

**Ostatnia aktualizacja:** 2026-01-31
**Wersja:** 1.0
**Status:** Faza planowania
**Następna recenzja:** Po wydaniu v3.3.0
