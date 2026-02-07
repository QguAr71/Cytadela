# 🛡️ CITADEL - KOMPLETNY PODRĘCZNIK UŻYTKOWNIKA

**Wersja:** 3.1.1  
**Data:** 2026-02-02  
**Język:** Polski

---

## 📑 SPIS TREŚCI

1. [Wprowadzenie](#-wprowadzenie)
2. [Wymagania systemowe](#-wymagania-systemowe)
3. [Instalacja](#-instalacja)
4. [Konfiguracja](#️-konfiguracja)
5. [Podstawowe użycie](#-podstawowe-użycie)
6. [Zaawansowane funkcje](#-zaawansowane-funkcje)
7. [Blokowanie reklam](#-blokowanie-reklam)
8. [Bezpieczeństwo](#-bezpieczeństwo)
9. [Monitorowanie](#-monitorowanie)
10. [Tryb awaryjny](#-tryb-awaryjny)
11. [Rozwiązywanie problemów](#-rozwiązywanie-problemów)
12. [Przykłady użycia](#-przykłady-użycia)
13. [FAQ](#-faq-najczęściej-zadawane-pytania)

---

## 🎯 WPROWADZENIE

### Interaktywny System Pomocy

Citadel zawiera interaktywny system pomocy:

```bash
sudo cytadela.sh help
```

To menu zapewnia:
- **5 zorganizowanych sekcji**: Instalacja, Główny program, Dodatki, Zaawansowane, Awaryjne
- **70+ komend** z opisami
- **Obsługę 7 języków**: Automatycznie używa języka systemowego
- **Łatwą nawigację**: Wybór sekcji przez numer

---

### Czym jest Citadel?

Citadel to zaawansowany system DNS z pełnym stosem prywatności, zaprojektowany dla użytkowników domowych i małych firm. Łączy w sobie:

- **DNSCrypt-Proxy** - szyfrowane zapytania DNS (DoH/DoT)
- **CoreDNS** - wydajny resolver z cache
- **NFTables** - firewall chroniący przed wyciekami DNS
- **Blokowanie reklam** - 325,000+ zablokowanych domen
- **Monitoring** - metryki Prometheus w czasie rzeczywistym

### Dlaczego Citadel?

✅ **Prywatność** - wszystkie zapytania DNS są szyfrowane  
✅ **Bezpieczeństwo** - ochrona przed śledzeniem i malware  
✅ **Wydajność** - inteligentne cache'owanie  
✅ **Prostota** - instalacja w 5 minut (graficzny kreator)  
✅ **Modularność** - 32 niezależne moduły  
✅ **Wielojęzyczność** - 7 języków (PL, EN, DE, ES, IT, FR, RU)  
✅ **Open Source** - pełna transparentność kodu

### 🌍 Obsługa 7 języków

Citadel posiada pełne wsparcie dla **7 języków**:

| Język | Kod | Status |
|-------|-----|--------|
| 🇵🇱 Polski | `pl` | ✅ Pełne tłumaczenie |
| 🇬🇧 English | `en` | ✅ Pełne tłumaczenie |
| 🇩🇪 Deutsch | `de` | ✅ Pełne tłumaczenie |
| 🇪🇸 Español | `es` | ✅ Pełne tłumaczenie |
| 🇮🇹 Italiano | `it` | ✅ Pełne tłumaczenie |
| 🇫🇷 Français | `fr` | ✅ Pełne tłumaczenie |
| 🇷🇺 Русский | `ru` | ✅ Pełne tłumaczenie |

**Co jest przetłumaczone:**
- ✅ Graficzny kreator instalacji (install-wizard)
- ✅ Wszystkie komunikaty systemowe
- ✅ Moduły (adblock, diagnostics, help)
- ✅ Logi i raporty błędów

**Automatyczna detekcja języka:**
```bash
# System automatycznie wykryje język z $LANG
sudo ./citadel.sh install-wizard
```

**Wymuszenie języka:**
```bash
sudo ./citadel.sh install-wizard pl  # Polski
sudo ./citadel.sh install-wizard en  # English
sudo ./citadel.sh install-wizard de  # Deutsch
```

### 🖥️ Graficzny kreator instalacji

Citadel posiada **interaktywny graficzny kreator** (whiptail/dialog) który przeprowadzi Cię przez całą instalację:

**Funkcje kreatora:**
- ✅ Graficzne menu w terminalu
- ✅ Checklisty do wyboru komponentów
- ✅ Automatyczna detekcja języka
- ✅ Krok po kroku (7 etapów)
- ✅ Weryfikacja na końcu

**Przykładowy wygląd:**
```
┌─────────────────────────────────────────────────────┐
│    CITADEL KREATOR INSTALACJI v3.1                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Wybierz komponenty do instalacji:                 │
│                                                     │
│  [X] DNSCrypt-Proxy (szyfrowanie DNS)              │
│  [X] CoreDNS (serwer DNS)                          │
│  [X] NFTables (firewall)                           │
│  [X] Blokowanie reklam                             │
│  [ ] Terminal Dashboard (opcjonalnie)              │
│  [ ] Health Watchdog (opcjonalnie)                 │
│                                                     │
│         <OK>              <Anuluj>                  │
└─────────────────────────────────────────────────────┘
```

### 🏗️ Architektura systemu

**Jak działa Citadel:**

```
┌─────────────┐
│ Aplikacja   │  Twoja przeglądarka, aplikacje, etc.
└──────┬──────┘
       │ Zapytanie DNS (example.com?)
       ▼
┌─────────────────────────────────┐
│ CoreDNS (127.0.0.1:53)         │  Lokalny resolver DNS
│ ├─ Cache (85-90% trafień)     │  Szybkie odpowiedzi
│ ├─ Adblock (325k+ domen)      │  Blokuje reklamy/trackery
│ └─ Metryki (Prometheus)        │  Monitoring
└──────┬──────────────────────────┘
       │ Brak w cache? Przekaż do...
       ▼
┌─────────────────────────────────┐
│ DNSCrypt-Proxy                 │  Warstwa szyfrowania
│ └─ Szyfrowane (DoH/DoT)        │  ISP nie widzi zapytań
└──────┬──────────────────────────┘
       │ Szyfrowane zapytanie DNS
       ▼
   🌐 Internet (Prywatność chroniona)

┌─────────────────────────────────┐
│ NFTables (Poziom jądra)        │  Zapobieganie wyciekom
│ └─ Blokuje zewnętrzne :53 ✗    │  Aplikacje nie mogą ominąć
│    (dotyczy całego ruchu       │  Wymuszenie na poziomie systemu
│     wychodzącego)              │
└─────────────────────────────────┘
```

**Dlaczego to lepsze:**
- ✅ **Prywatność:** ISP nie widzi Twoich zapytań DNS (szyfrowane)
- ✅ **Bezpieczeństwo:** Aplikacje nie mogą ominąć DNS (wymuszenie na poziomie jądra)
- ✅ **Szybkość:** Lokalny cache = szybsze przeglądanie (85-90% trafień)
- ✅ **Czystość:** Blokuje reklamy/trackery na poziomie DNS (325k+ domen)
- ✅ **Kontrola:** Wszystko działa lokalnie, bez zależności od chmury  

---

## 💻 WYMAGANIA SYSTEMOWE

### Minimalne wymagania:

- **System operacyjny:** Arch Linux, CachyOS (inne dystrybucje: ręczna adaptacja)
- **RAM:** 512 MB minimum, 1 GB zalecane
- **Dysk:** 100 MB na instalację
- **Sieć:** Aktywne połączenie internetowe
- **Uprawnienia:** Dostęp root (sudo)

### Zalecane:

- **CPU:** 2 rdzenie lub więcej
- **RAM:** 2 GB lub więcej
- **Dysk:** SSD dla lepszej wydajności

### Sprawdzenie wymagań:

```bash
# Sprawdź wersję systemu
cat /etc/os-release

# Sprawdź pamięć RAM
free -h

# Sprawdź miejsce na dysku
df -h

# Sprawdź połączenie internetowe
ping -c 3 1.1.1.1
```

---

## 🚀 INSTALACJA

### Krok 1: Pobranie repozytorium

```bash
# Sklonuj repozytorium
git clone https://github.com/QguAr71/Cytadela.git
cd Citadel

# Sprawdź wersję
cat VERSION
```

### Krok 2: Sprawdzenie zależności

```bash
# Sprawdź brakujące zależności
sudo ./citadel.sh check-deps

# Lub zainstaluj automatycznie
sudo ./citadel.sh check-deps --install
```

**Wymagane pakiety:**
- `dnscrypt-proxy` - szyfrowanie DNS
- `coredns` - serwer DNS
- `nftables` - firewall
- `curl` - pobieranie list blokad
- `jq` - parsowanie JSON
- `dig` - testy DNS

### Krok 3: Instalacja

**Citadel oferuje DWA TRYBY instalacji:**

#### Opcja A: Graficzny kreator (ZALECANE dla początkujących)

```bash
# Uruchom interaktywny kreator instalacji
sudo ./citadel.sh install-wizard
```

**Kreator przeprowadzi Cię przez:**

1. ✅ Sprawdzenie zależności
2. ✅ Wybór komponentów do instalacji
3. ✅ Konfigurację DNSCrypt-Proxy
4. ✅ Konfigurację CoreDNS
5. ✅ Konfigurację firewall
6. ✅ Konfigurację systemu
7. ✅ Weryfikację instalacji

**Przykładowy przebieg:**

```
╔═══════════════════════════════════════════════════════════════╗
║              CITADEL KREATOR INSTALACJI                       ║
╚═══════════════════════════════════════════════════════════════╝

[1/7] Sprawdzanie zależności...
✓ dnscrypt-proxy: zainstalowany
✓ coredns: zainstalowany
✓ nftables: zainstalowany

[2/7] Wybór komponentów:
  [x] DNSCrypt-Proxy
  [x] CoreDNS
  [x] NFTables
  [x] Blokowanie reklam
  [ ] Terminal Dashboard (opcjonalnie)

[3/7] Konfiguracja DNSCrypt-Proxy...
✓ Utworzono /etc/dnscrypt-proxy/dnscrypt-proxy.toml

[4/7] Konfiguracja CoreDNS...
✓ Utworzono /etc/coredns/Corefile

[5/7] Konfiguracja firewall...
✓ Załadowano reguły NFTables

[6/7] Konfiguracja systemu...
✓ System przełączony na Citadel DNS

[7/7] Weryfikacja...
✓ DNSCrypt-Proxy: DZIAŁA
✓ CoreDNS: DZIAŁA
✓ NFTables: DZIAŁA
✓ Rozwiązywanie DNS: OK

╔═══════════════════════════════════════════════════════════════╗
║         INSTALACJA ZAKOŃCZONA POMYŚLNIE!                      ║
╚═══════════════════════════════════════════════════════════════╝
```

---

#### Opcja B: CLI dla hardcorów (szybka instalacja)

```bash
# Instalacja wszystkiego bez GUI - jedna komenda!
sudo ./citadel.sh install-all
```

**Charakterystyka:**
- ✅ **Bez GUI** - czysty CLI
- ✅ **Szybkie** - instaluje wszystko automatycznie
- ✅ **Bez pytań** - pełna instalacja od razu
- ✅ **Dla zaawansowanych** - pełna kontrola przez logi

**Co robi `install-all`:**
1. Instaluje DNSCrypt-Proxy
2. Instaluje CoreDNS
3. Instaluje NFTables
4. Przebudowuje blocklists
5. Uruchamia wszystkie usługi
6. Wykonuje testy (DNS + adblock)
7. Pokazuje status

**Workflow dla hardcorów:**
```bash
# 1. Instalacja (bez GUI)
sudo ./citadel.sh install-all

# 2. Firewall (safe mode)
sudo ./citadel.sh firewall-safe

# 3. Test DNS
dig +short google.com @127.0.0.1

# 4. Przełącz system
sudo ./citadel.sh configure-system

# 5. Weryfikacja
sudo ./citadel.sh verify
```

**5 komend, 0 GUI, pełna kontrola!** 💪

---

#### Porównanie trybów instalacji

| Funkcja | install-wizard | install-all |
|---------|----------------|-------------|
| **GUI** | ✅ whiptail | ❌ CLI only |
| **Interaktywny** | ✅ Tak | ❌ Nie |
| **Języki** | ✅ 7 | ❌ EN/PL |
| **Wybór komponentów** | ✅ Checklist | ❌ Wszystko |
| **Szybkość** | Wolniejsze | ⚡ Szybsze |
| **Dla kogo** | Początkujący | 💪 Hardcorzy |

---

### Krok 4: Weryfikacja instalacji

```bash
# Sprawdź status wszystkich usług
sudo ./citadel.sh status

# Uruchom pełną weryfikację
sudo ./citadel.sh verify

# Test DNS
sudo ./citadel.sh test
```

---

## 🗑️ DEINSTALACJA

### Całkowite usunięcie

Usuwa Citadel całkowicie wraz z konfiguracją i danymi:

```bash
sudo ./citadel.sh uninstall
```

**To usunie:**
- Sprawdzi i opcjonalnie usunie pakiety opcjonalne (dnsperf, curl, jq)
- **Przywróci DNS** (sprawdzi poprawność backupu, użyje NetworkManager jeśli dostępny, lub ustawi fallback DNS)
- **Przetestuje DNS** wieloma serwerami (1.1.1.1, 8.8.8.8, 9.9.9.9) przed kontynuacją
- Zatrzyma i wyłączy usługi (coredns, dnscrypt-proxy)
- Usunie reguły firewalla
- Usunie pliki konfiguracyjne (`/etc/coredns/`, `/etc/dnscrypt-proxy/`)
- Usunie katalogi z danymi
- Usunie użytkownika systemowego `dnscrypt`

**Funkcje bezpieczeństwa DNS:**
- Ignoruje backup jeśli wskazuje na localhost (127.0.0.1)
- Próbuje użyć NetworkManager auto-DNS jeśli dostępny
- Użyje 3 serwerów fallback DNS (Cloudflare, Google, Quad9)
- Testuje DNS przed kontynuacją - ostrzega jeśli nie działa
- Pozwala anulować jeśli wykryto problemy z DNS
- Podaje instrukcje naprawy manualnej

**Wymagane potwierdzenie:** Wpisz `yes` aby kontynuować.

### Zachowaj konfigurację

Zatrzymuje usługi ale zachowuje wszystkie pliki konfiguracyjne:

```bash
sudo ./citadel.sh uninstall-keep-config
```

**Zastosowanie:** Tymczasowe wyłączenie, planowana ponowna instalacja.

---

## ⚙️ KONFIGURACJA

### Konfiguracja systemu

#### Przełączenie na Citadel DNS:

```bash
sudo ./citadel.sh configure-system
```

**Co robi ta komenda:**
- Tworzy backup oryginalnej konfiguracji
- Modyfikuje `/etc/resolv.conf`
- Ustawia `127.0.0.1` jako serwer DNS
- Blokuje zmiany przez NetworkManager

#### Przywrócenie oryginalnej konfiguracji:

```bash
# Przywróć backup sprzed instalacji Cytadeli
sudo ./citadel.sh restore-system

# Przywróć fabryczną konfigurację systemd-resolved (bezpieczny fallback)
sudo ./citadel.sh restore-system-default
```

**Różnica:**
- `restore-system` - przywraca dokładną konfigurację sprzed Cytadeli (z backupu)
- `restore-system-default` - przywraca fabryczne ustawienia systemd-resolved (ignoruje backup)

### Konfiguracja firewall

#### Tryb bezpieczny (zalecany dla początkujących):

```bash
sudo ./citadel.sh firewall-safe
```

**Reguły trybu bezpiecznego:**
- ✅ Blokuje zapytania DNS poza localhost
- ✅ Pozwala na ruch lokalny
- ⚠️ Ostrzega o wyciekach DNS

#### Tryb restrykcyjny (dla zaawansowanych):

```bash
sudo ./citadel.sh firewall-strict
```

**Reguły trybu restrykcyjnego:**
- ✅ Blokuje WSZYSTKIE zapytania DNS poza localhost
- ✅ Blokuje DoH na poziomie IP (1.1.1.1:443, 8.8.8.8:443)
- ✅ Loguje próby obejścia
- ⚠️ Może zablokować niektóre aplikacje

### Konfiguracja DNSCrypt-Proxy

#### Edycja konfiguracji:

```bash
sudo ./citadel.sh edit-dnscrypt
```

**Ważne parametry w `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`:**

```toml
# Serwery DNS (wybierz 2-3)
server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

# Wymagania bezpieczeństwa
require_dnssec = true        # Wymagaj DNSSEC
require_nolog = true         # Wymagaj polityki no-log
require_nofilter = false     # Pozwól na filtrowanie

# Wydajność
cache_size = 1024            # Rozmiar cache (wpisy)
cache_min_ttl = 300          # Min TTL (sekundy)
cache_max_ttl = 86400        # Max TTL (sekundy)

# Timeout
timeout = 3000               # Timeout zapytania (ms)
```

**Po zmianach:**

```bash
# Restart DNSCrypt-Proxy
sudo systemctl restart dnscrypt-proxy

# Sprawdź status
sudo systemctl status dnscrypt-proxy
```

### Konfiguracja CoreDNS

#### Edycja konfiguracji:

```bash
sudo ./citadel.sh edit
```

**Przykładowa konfiguracja `/etc/coredns/Corefile`:**

```
.:53 {
    # Blokowanie reklam
    hosts /etc/coredns/zones/combined.hosts {
        fallthrough
    }
    
    # Cache
    cache {
        success 10000 3600
        denial 1000 300
    }
    
    # Forward do DNSCrypt-Proxy
    forward . 127.0.0.1:5355
    
    # Metryki Prometheus
    prometheus 127.0.0.1:9153
    
    # Logi (opcjonalnie)
    # log
    
    # Błędy
    errors
}
```

**Po zmianach:**

```bash
# Restart CoreDNS
sudo systemctl restart coredns

# Sprawdź status
sudo systemctl status coredns
```

---

## 📖 PODSTAWOWE UŻYCIE

### Sprawdzanie statusu

```bash
# Status wszystkich usług
sudo ./citadel.sh status
```

**Przykładowy output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    CITADEL STATUS                             ║
╚═══════════════════════════════════════════════════════════════╝

🔥 SERVICES:
✓ DNSCrypt-Proxy: RUNNING (PID: 12345)
✓ CoreDNS: RUNNING (PID: 12346)
✓ NFTables: RUNNING

🌐 DNS CONFIGURATION:
✓ System DNS: 127.0.0.1
✓ DNS Resolution: OK
✓ DNSCrypt: ACTIVE

📊 STATISTICS:
  Total Queries: 15,234
  Cache Hits: 12,891 (84.6%)
  Blocked Domains: 1,234
```

### Testowanie DNS

```bash
# Podstawowy test
sudo ./citadel.sh test

# Pełny test
sudo ./citadel.sh test-all
```

### Wyświetlanie logów

```bash
# Ostatnie 20 wpisów
sudo ./citadel.sh logs

# Logi na żywo
sudo journalctl -u dnscrypt-proxy -u coredns -f
```

### Diagnostyka

```bash
# Pełna diagnostyka
sudo ./citadel.sh diagnostics
```

**Diagnostyka sprawdza:**
- ✅ Status usług
- ✅ Konfigurację DNS
- ✅ Reguły firewall
- ✅ Rozwiązywanie nazw
- ✅ Szyfrowanie DNS
- ✅ Wycieki DNS

---

## 🚀 ZAAWANSOWANE FUNKCJE

### Auto-aktualizacja list blokad

#### Włączenie auto-aktualizacji:

```bash
sudo ./citadel.sh auto-update-enable
```

**Co robi:**
- Tworzy timer systemd
- Aktualizuje listy co 24h
- Zapisuje last-known-good backup
- Automatycznie przywraca przy błędzie

#### Konfiguracja:

```bash
sudo ./citadel.sh auto-update-configure
```

**Opcje:**
- Częstotliwość aktualizacji (domyślnie: 24h)
- Godzina aktualizacji (domyślnie: 03:00)
- Powiadomienia (domyślnie: włączone)

#### Ręczna aktualizacja:

```bash
sudo ./citadel.sh auto-update-now
```

### Backup i przywracanie

#### Backup konfiguracji:

```bash
sudo ./citadel.sh config-backup
```

**Backup zawiera:**
- `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`
- `/etc/coredns/Corefile`
- `/etc/coredns/zones/`
- Reguły NFTables
- Konfigurację systemu

**Lokalizacja:** `/var/lib/citadel/backups/citadel-backup-YYYYMMDD-HHMMSS.tar.gz`

#### Lista backupów:

```bash
sudo ./citadel.sh config-list
```

#### Przywracanie z backupu:

```bash
sudo ./citadel.sh config-restore /var/lib/citadel/backups/citadel-backup-20260131-120000.tar.gz
```

#### Last-Known-Good (LKG):

```bash
# Zapisz aktualną konfigurację jako LKG
sudo ./citadel.sh lkg-save

# Przywróć LKG
sudo ./citadel.sh lkg-restore

# Status LKG
sudo ./citadel.sh lkg-status
```

### IPv6 Privacy

#### Włączenie prywatności IPv6:

```bash
sudo ./citadel.sh ipv6-privacy-on
```

**Co robi:**
- Włącza tymczasowe adresy IPv6
- Ustawia preferowanie tymczasowych adresów
- Konfiguruje rotację adresów

#### Automatyczne zarządzanie:

```bash
sudo ./citadel.sh ipv6-privacy-auto
```

**Auto-ensure:**
- Sprawdza obecność tymczasowych adresów
- Automatycznie włącza jeśli brak
- Monitoruje i naprawia

#### Smart IPv6 detection:

```bash
sudo ./citadel.sh smart-ipv6
```

**Funkcje:**
- Testuje łączność IPv6
- Wykrywa problemy
- Automatycznie naprawia (deep reset)

### Terminal Dashboard

#### Instalacja:

```bash
sudo ./citadel.sh install-dashboard
```

#### Uruchomienie:

```bash
citadel-top
```

**Dashboard pokazuje:**
- Status usług w czasie rzeczywistym
- Metryki Prometheus
- Status sieci
- Wydajność systemu
- Obciążenie CPU/RAM

**Odświeżanie:** co 5 sekund  
**Wyjście:** Ctrl+C

---

## 🚫 BLOKOWANIE REKLAM

### Status blokowania

```bash
sudo ./citadel.sh adblock-status
```

**Przykładowy output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    ADBLOCK STATUS                             ║
╚═══════════════════════════════════════════════════════════════╝

📊 STATISTICS:
  Total Blocked Domains: 325,847
  Custom Blocked: 42
  Allowlisted: 5
  Last Update: 2026-01-31 03:00:15

📋 BLOCKLIST PROFILE:
  Current: standard
  Available: minimal, standard, aggressive

🎯 TOP BLOCKED TODAY:
  1. ads.example.com (1,234 queries)
  2. tracker.example.com (987 queries)
  3. analytics.example.com (654 queries)
```

### Zarządzanie profilami list blokad

#### Lista dostępnych profili:

```bash
sudo ./citadel.sh blocklist-list
```

**Dostępne profile:**

| Profil | Domeny | Opis |
|--------|--------|------|
| `minimal` | ~50K | Tylko reklamy i trackery |
| `standard` | ~325K | Reklamy, trackery, malware (zalecany) |
| `aggressive` | ~1M+ | Maksymalne blokowanie |

#### Zmiana profilu:

```bash
# Przełącz na agresywny
sudo ./citadel.sh blocklist-switch aggressive

# Przełącz na minimalny
sudo ./citadel.sh blocklist-switch minimal
```

### Blokowanie własnych domen

#### Dodanie domeny do blokady:

```bash
sudo ./citadel.sh adblock-add ads.example.com
```

**Obsługuje wildcards:**

```bash
# Zablokuj wszystkie subdomeny
sudo ./citadel.sh adblock-add "*.ads.example.com"
```

#### Usunięcie domeny z blokady:

```bash
sudo ./citadel.sh adblock-remove ads.example.com
```

#### Sprawdzenie czy domena jest zablokowana:

```bash
sudo ./citadel.sh adblock-query ads.example.com
```

**Output:**

```
✓ ads.example.com is BLOCKED
  Source: custom.hosts
  Added: 2026-01-31 12:34:56
```

### Allowlist (białe listy)

#### Dodanie domeny do allowlist:

```bash
sudo ./citadel.sh allowlist-add safe-ads.example.com
```

**Użycie:**
- Odblokowanie fałszywie pozytywnych
- Umożliwienie dostępu do zaufanych domen
- Nadpisuje listy blokad

#### Lista allowlist:

```bash
sudo ./citadel.sh allowlist-list
```

#### Usunięcie z allowlist:

```bash
sudo ./citadel.sh allowlist-remove safe-ads.example.com
```

### Przebudowa list blokad

```bash
sudo ./citadel.sh adblock-rebuild
```

**Kiedy użyć:**
- Po dodaniu/usunięciu wielu domen
- Po zmianie profilu
- Po ręcznej edycji plików

### Wyświetlanie list

```bash
# Pokaż własne blokady
sudo ./citadel.sh custom

# Pokaż główną listę blokad
sudo ./citadel.sh blocklist

# Pokaż połączoną listę
sudo ./citadel.sh combined
```

---

## 🔐 BEZPIECZEŃSTWO

### Supply Chain Protection

#### Inicjalizacja:

```bash
sudo ./citadel.sh supply-chain-init
```

**Tworzy:**
- Sumy kontrolne wszystkich plików
- Manifest integralności
- Podpisy cyfrowe (opcjonalnie)

#### Weryfikacja:

```bash
sudo ./citadel.sh supply-chain-verify
```

**Sprawdza:**
- ✅ Integralność plików binarnych
- ✅ Integralność skryptów
- ✅ Integralność konfiguracji
- ⚠️ Wykrywa modyfikacje

#### Status:

```bash
sudo ./citadel.sh supply-chain-status
```

### Integrity Check

#### Inicjalizacja manifestu:

```bash
sudo ./citadel.sh integrity-init
```

#### Sprawdzenie integralności:

```bash
sudo ./citadel.sh integrity-check
```

**Przykładowy output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    INTEGRITY CHECK                            ║
╚═══════════════════════════════════════════════════════════════╝

✓ /usr/bin/dnscrypt-proxy: OK
✓ /usr/bin/coredns: OK
✓ /etc/dnscrypt-proxy/dnscrypt-proxy.toml: OK
⚠ /etc/coredns/Corefile: MODIFIED
✓ /opt/citadel/modules/*.sh: OK

RESULT: 1 file modified
```

### Ghost Check (Audit portów)

```bash
sudo ./citadel.sh ghost-check
```

**Sprawdza:**
- Otwarte porty
- Nasłuchujące usługi
- Nieoczekiwane połączenia
- Potencjalne backdoory

**Przykładowy output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    GHOST CHECK                                ║
╚═══════════════════════════════════════════════════════════════╝

🔍 OPEN PORTS:
  ✓ 22/tcp (ssh) - EXPECTED
  ✓ 53/udp (dns) - EXPECTED
  ⚠ 8080/tcp (unknown) - UNEXPECTED

⚠ WARNING: 1 unexpected port found!
```

### Killswitch (Wyłącznik awaryjny)

#### Włączenie killswitch:

```bash
sudo ./citadel.sh killswitch-on
```

**Co robi:**
- Blokuje WSZYSTKIE zapytania DNS poza localhost
- Wymusza użycie Citadel
- Zapobiega wyciekom DNS

#### Wyłączenie killswitch:

```bash
sudo ./citadel.sh killswitch-off
```

---

## 📊 MONITOROWANIE

### Status zdrowia

```bash
sudo ./citadel.sh health-status
```

**Sprawdza:**
- Status usług
- Wydajność DNS
- Wykorzystanie zasobów
- Błędy w logach
- Anomalie

### Cache Statistics

```bash
sudo ./citadel.sh cache-stats
```

**Pokazuje:**
- Rozmiar cache
- Współczynnik trafień (hit rate)
- Najpopularniejsze domeny
- Statystyki wydajności

**Przykładowy output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    CACHE STATISTICS                           ║
╚═══════════════════════════════════════════════════════════════╝

📊 CACHE METRICS:
  Total Entries: 8,234
  Hit Rate: 87.3%
  Miss Rate: 12.7%
  Evictions: 234

🔥 TOP DOMAINS (last 24h):
  1. google.com (2,345 queries)
  2. youtube.com (1,987 queries)
  3. github.com (1,234 queries)
```

### Metryki Prometheus

```bash
# Wyświetl metryki
curl http://127.0.0.1:9153/metrics
```

**Dostępne metryki:**
- `coredns_dns_request_count_total` - liczba zapytań
- `coredns_cache_hits_total` - trafienia cache
- `coredns_cache_misses_total` - chybienia cache
- `coredns_dns_request_duration_seconds` - czas odpowiedzi

### Network Discovery

```bash
sudo ./citadel.sh discover
```

**Pokazuje:**
- Aktywny interfejs sieciowy
- Adres IP (IPv4/IPv6)
- Brama domyślna
- Serwery DNS
- Reguły firewall

---

## 🚨 TRYB AWARYJNY

### Panic Bypass

**Użyj gdy:**
- DNS przestał działać
- Nie masz dostępu do internetu
- Potrzebujesz szybko przywrócić połączenie

#### Aktywacja (na 5 minut):

```bash
sudo ./citadel.sh panic-bypass 300
```

**Co robi:**
- Flush reguł NFTables
- Tymczasowo przełącza na publiczny DNS (1.1.1.1)
- Automatycznie przywraca po czasie

#### Aktywacja (bez limitu czasu):

```bash
sudo ./citadel.sh panic-bypass
```

#### Ręczne przywrócenie:

```bash
sudo ./citadel.sh panic-restore
```

#### Status panic mode:

```bash
sudo ./citadel.sh panic-status
```

### Emergency Refuse

**Użyj gdy:**
- Podejrzewasz atak
- Chcesz całkowicie zablokować DNS

```bash
# Zablokuj wszystkie zapytania DNS
sudo ./citadel.sh emergency-refuse

# Przywróć normalną pracę
sudo ./citadel.sh emergency-restore
```

---

## 🔧 ROZWIĄZYWANIE PROBLEMÓW

### Problem: DNS nie działa

#### Objawy:
- Brak dostępu do stron internetowych
- Błędy "could not resolve host"
- Timeout przy ping do domen

#### Rozwiązanie:

```bash
# Krok 1: Sprawdź status usług
sudo ./citadel.sh status

# Krok 2: Sprawdź logi
sudo ./citadel.sh logs

# Krok 3: Uruchom diagnostykę
sudo ./citadel.sh diagnostics

# Krok 4: Jeśli nic nie pomaga - panic bypass
sudo ./citadel.sh panic-bypass 300
```

#### Częste przyczyny:

**1. Usługi nie działają:**

```bash
# Sprawdź status
sudo systemctl status dnscrypt-proxy
sudo systemctl status coredns

# Restart usług
sudo systemctl restart dnscrypt-proxy
sudo systemctl restart coredns
```

**2. Błąd w konfiguracji:**

```bash
# Sprawdź konfigurację DNSCrypt
dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Sprawdź konfigurację CoreDNS
coredns -conf /etc/coredns/Corefile -validate
```

**3. Firewall blokuje:**

```bash
# Sprawdź reguły
sudo nft list ruleset

# Tymczasowo wyłącz firewall
sudo systemctl stop nftables

# Jeśli pomogło - problem w regułach
sudo ./citadel.sh firewall-safe
```

### Problem: Konflikt portów

#### Objawy:
- Błąd "address already in use"
- CoreDNS nie może się uruchomić
- Port 53 zajęty

#### Rozwiązanie:

```bash
# Automatyczne rozwiązanie
sudo ./citadel.sh fix-ports
```

**Kreator pomoże:**
1. Wykryć co używa portu 53
2. Zatrzymać konfliktujące usługi (avahi, systemd-resolved)
3. Zmienić port CoreDNS (jeśli potrzeba)

#### Ręczne rozwiązanie:

```bash
# Sprawdź co używa portu 53
sudo ss -tulpn | grep :53

# Zatrzymaj systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Zatrzymaj avahi-daemon
sudo systemctl stop avahi-daemon
sudo systemctl disable avahi-daemon

# Restart CoreDNS
sudo systemctl restart coredns
```

### Problem: Wolne DNS

#### Objawy:
- Długie ładowanie stron
- Opóźnienia przy pierwszym połączeniu
- Timeout przy rzadko używanych domenach

#### Rozwiązanie:

**1. Sprawdź cache:**

```bash
sudo ./citadel.sh cache-stats
```

Jeśli hit rate < 70% - zwiększ rozmiar cache:

```bash
sudo ./citadel.sh edit
```

W Corefile zmień:

```
cache {
    success 20000 7200  # Zwiększ z 10000
    denial 2000 600     # Zwiększ z 1000
}
```

**2. Zmień serwery DNSCrypt:**

```bash
sudo ./citadel.sh edit-dnscrypt
```

Wybierz szybsze serwery (bliżej geograficznie):

```toml
server_names = ['cloudflare', 'google']  # Szybkie, globalne
```

**3. Zmniejsz timeout:**

```toml
timeout = 2000  # Zmniejsz z 3000
```

**4. Włącz parallel racing:**

```bash
sudo ./citadel.sh install-doh-parallel
```

### Problem: Fałszywe blokady

#### Objawy:
- Ważna strona nie działa
- Aplikacja nie może się połączyć
- Usługa jest zablokowana

#### Rozwiązanie:

**1. Sprawdź czy domena jest zablokowana:**

```bash
sudo ./citadel.sh adblock-query example.com
```

**2. Dodaj do allowlist:**

```bash
sudo ./citadel.sh allowlist-add example.com
```

**3. Przebuduj listy:**

```bash
sudo ./citadel.sh adblock-rebuild
```

**4. Test:**

```bash
dig example.com @127.0.0.1
```

### Problem: Wycieki DNS

#### Objawy:
- Test wycieku pokazuje ISP DNS
- Zapytania omijają Citadel
- Aplikacje używają własnego DNS

#### Rozwiązanie:

**1. Włącz strict firewall:**

```bash
sudo ./citadel.sh firewall-strict
```

**2. Włącz killswitch:**

```bash
sudo ./citadel.sh killswitch-on
```

**3. Sprawdź wycieki:**

```bash
# Online test
curl -s https://www.dnsleaktest.com/

# Lokalny test
sudo ./citadel.sh diagnostics | grep -i leak
```

### Problem: IPv6 nie działa

#### Objawy:
- Brak łączności IPv6
- Tylko IPv4 działa
- Błędy przy ping6

#### Rozwiązanie:

**1. Smart detection:**

```bash
sudo ./citadel.sh smart-ipv6
```

**2. Deep reset:**

```bash
sudo ./citadel.sh ipv6-deep-reset
```

**3. Sprawdź konfigurację:**

```bash
# Sprawdź adresy IPv6
ip -6 addr show

# Sprawdź routing
ip -6 route show

# Test łączności
ping6 -c 3 2001:4860:4860::8888
```

### Problem: Wysokie użycie CPU/RAM

#### Objawy:
- System zwalnia
- Wysokie użycie zasobów przez CoreDNS/DNSCrypt
- Out of memory

#### Rozwiązanie:

**1. Optymalizacja priorytetów:**

```bash
sudo ./citadel.sh optimize-kernel
```

**2. Zmniejsz cache:**

```bash
sudo ./citadel.sh edit
```

Zmień w Corefile:

```
cache {
    success 5000 3600   # Zmniejsz z 10000
    denial 500 300      # Zmniejsz z 1000
}
```

**3. Zmniejsz cache DNSCrypt:**

```bash
sudo ./citadel.sh edit-dnscrypt
```

Zmień:

```toml
cache_size = 512  # Zmniejsz z 1024
```

**4. Restart usług:**

```bash
sudo systemctl restart dnscrypt-proxy coredns
```

---

## 💡 PRZYKŁADY UŻYCIA

### Przykład 1: Podstawowa instalacja

**Scenariusz:** Nowa instalacja na czystym systemie

```bash
# 1. Sklonuj repozytorium
git clone https://github.com/QguAr71/Cytadela.git
cd Citadel

# 2. Sprawdź zależności
sudo ./citadel.sh check-deps --install

# 3. Uruchom kreator
sudo ./citadel.sh install-wizard

# 4. Weryfikuj
sudo ./citadel.sh verify

# 5. Test
sudo ./citadel.sh test
```

**Czas:** ~5-10 minut  
**Trudność:** Łatwa

### Przykład 2: Maksymalne blokowanie reklam

**Scenariusz:** Chcesz zablokować maksymalnie dużo reklam

```bash
# 1. Przełącz na agresywny profil
sudo ./citadel.sh blocklist-switch aggressive

# 2. Dodaj własne domeny
sudo ./citadel.sh adblock-add "*.doubleclick.net"
sudo ./citadel.sh adblock-add "*.googlesyndication.com"
sudo ./citadel.sh adblock-add "*.googleadservices.com"

# 3. Przebuduj listy
sudo ./citadel.sh adblock-rebuild

# 4. Sprawdź status
sudo ./citadel.sh adblock-status

# 5. Włącz auto-update
sudo ./citadel.sh auto-update-enable
```

**Rezultat:** ~1M+ zablokowanych domen

### Przykład 3: Maksymalna prywatność

**Scenariusz:** Chcesz maksymalną prywatność i bezpieczeństwo

```bash
# 1. Strict firewall
sudo ./citadel.sh firewall-strict

# 2. Killswitch
sudo ./citadel.sh killswitch-on

# 3. IPv6 privacy
sudo ./citadel.sh ipv6-privacy-on
sudo ./citadel.sh ipv6-privacy-auto

# 4. Supply chain protection
sudo ./citadel.sh supply-chain-init

# 5. Weryfikacja integralności
sudo ./citadel.sh integrity-init

# 6. Sprawdź wycieki
sudo ./citadel.sh diagnostics | grep -i leak
```

**Rezultat:** Maksymalna ochrona prywatności

### Przykład 4: Monitoring i dashboard

**Scenariusz:** Chcesz monitorować DNS w czasie rzeczywistym

```bash
# 1. Zainstaluj dashboard
sudo ./citadel.sh install-dashboard

# 2. Włącz health monitoring
sudo ./citadel.sh health-install

# 3. Uruchom dashboard
citadel-top

# W drugim terminalu:
# 4. Sprawdź metryki
curl http://127.0.0.1:9153/metrics

# 5. Cache stats
sudo ./citadel.sh cache-stats

# 6. Logi na żywo
sudo journalctl -u coredns -f
```

**Rezultat:** Pełny monitoring w czasie rzeczywistym

### Przykład 5: Backup przed zmianami

**Scenariusz:** Chcesz eksperymentować z konfiguracją

```bash
# 1. Backup aktualnej konfiguracji
sudo ./citadel.sh config-backup

# 2. Zapisz jako LKG
sudo ./citadel.sh lkg-save

# 3. Eksperymentuj z konfiguracją
sudo ./citadel.sh edit
# ... zmiany ...

# 4. Test
sudo ./citadel.sh test-all

# 5a. Jeśli działa - OK!
# 5b. Jeśli nie działa - przywróć
sudo ./citadel.sh lkg-restore
```

**Rezultat:** Bezpieczne eksperymenty

### Przykład 6: Migracja z Pi-hole

**Scenariusz:** Masz Pi-hole i chcesz przejść na Citadel

```bash
# 1. Eksportuj własne blokady z Pi-hole
# (ręcznie skopiuj z Pi-hole Web UI)

# 2. Zainstaluj Citadel
sudo ./citadel.sh install-wizard

# 3. Importuj własne blokady
while read domain; do
    sudo ./citadel.sh adblock-add "$domain"
done < pihole-custom-list.txt

# 4. Przebuduj listy
sudo ./citadel.sh adblock-rebuild

# 5. Przełącz DNS na Citadel
sudo ./citadel.sh configure-system

# 6. Wyłącz Pi-hole
# (na Pi-hole: pihole disable)

# 7. Test
sudo ./citadel.sh verify
```

**Rezultat:** Płynna migracja z Pi-hole

---

## ❓ FAQ (Najczęściej zadawane pytania)

### Ogólne

**Q: Czy Citadel jest darmowy?**  
A: Tak, Citadel jest w pełni darmowy i open-source (licencja GPL-3.0).

**Q: Czy Citadel działa na Raspberry Pi?**  
A: Tak, ale wymaga ręcznej adaptacji dla Raspberry Pi OS (Debian-based).

**Q: Czy mogę używać Citadel z VPN?**  
A: Tak, Citadel działa z VPN. DNS będzie szyfrowany przez Citadel, a ruch przez VPN.

**Q: Czy Citadel spowalnia internet?**  
A: Nie, dzięki cache'owaniu często przyspiesza rozwiązywanie nazw.

### Instalacja

**Q: Czy mogę zainstalować tylko wybrane komponenty?**  
A: Tak, użyj `install-dnscrypt`, `install-coredns`, `install-nftables` osobno.

**Q: Czy mogę zainstalować bez kreatora?**  
A: Tak, użyj `install-all` dla pełnej instalacji bez interakcji.

**Q: Co jeśli instalacja się nie powiedzie?**  
A: Użyj `panic-bypass` aby przywrócić internet, potem sprawdź logi.

### Konfiguracja

**Q: Czy mogę używać własnych serwerów DNS?**  
A: Tak, edytuj `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` i dodaj własne serwery.

**Q: Czy mogę wyłączyć blokowanie reklam?**  
A: Tak, użyj profilu `minimal` lub wyłącz w Corefile.

**Q: Jak zmienić port CoreDNS?**  
A: Edytuj `/etc/coredns/Corefile` i zmień `.:53` na `.:TWÓJ_PORT`.

### Blokowanie

**Q: Czy mogę zaimportować listy z Pi-hole?**  
A: Tak, dodaj domeny przez `adblock-add` lub ręcznie do `/etc/coredns/zones/custom.hosts`.

**Q: Czy blokowanie działa na poziomie sieci?**  
A: Tak, jeśli ustawisz Citadel jako DNS dla całej sieci (router/DHCP).

**Q: Jak odblokować stronę?**  
A: Użyj `allowlist-add DOMENA`.

### Bezpieczeństwo

**Q: Czy moje zapytania DNS są szyfrowane?**  
A: Tak, DNSCrypt-Proxy szyfruje wszystkie zapytania (DoH/DoT/DNSCrypt).

**Q: Czy Citadel loguje moje zapytania?**  
A: Nie, domyślnie logi są wyłączone. Możesz włączyć dla debugowania.

**Q: Czy Citadel chroni przed malware?**  
A: Tak, listy blokad zawierają domeny malware i phishing.

### Wydajność

**Q: Ile RAM zużywa Citadel?**  
A: ~100-200 MB (DNSCrypt + CoreDNS + cache).

**Q: Ile CPU zużywa Citadel?**  
A: <1% w spoczynku, 2-5% przy intensywnym użyciu.

**Q: Jak zwiększyć wydajność?**  
A: Zwiększ cache, użyj `optimize-kernel`, wybierz szybsze serwery DNS.

### Rozwiązywanie problemów

**Q: Co zrobić gdy DNS przestał działać?**  
A: Użyj `panic-bypass 300` dla szybkiego przywrócenia internetu.

**Q: Jak sprawdzić logi błędów?**  
A: `sudo ./citadel.sh logs` lub `sudo journalctl -u coredns -u dnscrypt-proxy`.

**Q: Jak zresetować konfigurację?**  
A: `sudo ./citadel.sh restore-system` przywraca backup sprzed Cytadeli. Jeśli backup był zły, użyj `sudo ./citadel.sh restore-system-default` aby przywrócić fabryczne ustawienia.

---

## 📞 WSPARCIE

### Dokumentacja

- **Szybki start:** [docs/user/quick-start.md](quick-start.md)
- **Komendy:** [docs/user/commands.md](commands.md)
- **FAQ:** [docs/user/FAQ.md](FAQ.md)
- **Manuał EN:** [docs/user/MANUAL_EN.md](MANUAL_EN.md)

### Społeczność

- **GitHub Issues:** [github.com/QguAr71/Cytadela/issues](https://github.com/QguAr71/Cytadela/issues)
- **GitHub Discussions:** [github.com/QguAr71/Cytadela/discussions](https://github.com/QguAr71/Cytadela/discussions)

### Zgłaszanie błędów

Przy zgłaszaniu błędu dołącz:

```bash
# Informacje o systemie
uname -a
cat /etc/os-release

# Status Citadel
sudo ./citadel.sh status

# Diagnostyka
sudo ./citadel.sh diagnostics

# Logi
sudo ./citadel.sh logs
```

---

## 📜 LICENCJA

Citadel jest oprogramowaniem open-source na licencji **GNU General Public License v3.0**.

Pełna treść licencji: [LICENSE](../../LICENSE)

---

## 🙏 PODZIĘKOWANIA

- **DNSCrypt-Proxy** - za szyfrowanie DNS
- **CoreDNS** - za wydajny serwer DNS
- **NFTables** - za firewall
- **Społeczność** - za feedback i wkład

---

**Wersja dokumentu:** 1.0  
**Data ostatniej aktualizacji:** 2026-01-31  
**Autor:** Citadel Team

---

**Citadel - Twoja forteca przeciwko inwigilacji DNS** 🛡️
