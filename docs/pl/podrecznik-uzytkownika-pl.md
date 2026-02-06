# 🛡️ CITADEL - KOMPLETNY PODRĘCZNIK UŻYTKOWNIKA

**Wersja:** 3.1.1  
**Data:** 2026-02-02  
**Język:** Polski

---

## 📑 SPIS TREŚCI

1. [Wprowadzenie](#-wprowadzenie)
2. [Wymagania Systemowe](#-wymagania-systemowe)
3. [Instalacja](#-instalacja)
4. [Konfiguracja](#️-konfiguracja)
5. [Podstawowe Użycie](#-podstawowe-użycie)
6. [Zaawansowane Funkcje](#-zaawansowane-funkcje)
7. [Blokowanie Reklam](#-blokowanie-reklam)
8. [Bezpieczeństwo](#-bezpieczeństwo)
9. [Monitorowanie](#-monitorowanie)
10. [Tryb Awaryjny](#-tryb-awaryjny)
11. [Rozwiązywanie Problemów](#-rozwiązywanie-problemów)
12. [Przykłady Użycia](#-przykłady-użycia)
13. [FAQ](#-faq-często-zadawane-pytania)

---

## 🎯 WPROWADZENIE

### Interaktywny System Pomocy

Citadel zawiera interaktywny system pomocy dostępny poprzez:

```bash
sudo cytadela.sh help
```

Ten system udostępnia:
- **5 zorganizowanych sekcji**: Instalacja, Główny Program, Dodatki, Zaawansowane, Awaryjne
- **70+ poleceń** z opisami
- **7 języków wsparcia**: Automatycznie używa języka systemu
- **Łatwą nawigację**: Wybierz sekcję wg numeru

---

### Co to jest Cytadela?

Cytadela to zaawansowany system DNS z kompletnym stosem prywatności, zaprojektowany dla użytkowników domowych i małych firm. Łączy:

- **DNSCrypt-Proxy** - Zaszyfrowane zapytania DNS (DoH/DoT)
- **CoreDNS** - Wysokowydajny resolver z cache
- **NFTables** - Firewall zapobiegający wyciekom DNS
- **Blokowanie reklam** - 325,000+ zablokowanych domen
- **Monitorowanie** - Metryki Prometheus w czasie rzeczywistym

### Dlaczego Cytadela?

✅ **Prywatność** - Wszystkie zapytania DNS są szyfrowane  
✅ **Bezpieczeństwo** - Ochrona przed śledzeniem i malware  
✅ **Wydajność** - Inteligentne cache'owanie  
✅ **Prostota** - Instalacja w 5 minut (graficzny kreator)  
✅ **Modularność** - 32 niezależne moduły  
✅ **Wielojęzyczna** - 7 języków (PL, EN, DE, ES, IT, FR, RU)  
✅ **Open Source** - Pełna transparentność kodu

### 🌍 Wsparcie dla 7 Języków

Cytadela ma pełne wsparcie dla **7 języków**:

| Język | Kod | Status |
|-------|-----|--------|
| 🇵🇱 Polski | `pl` | ✅ Pełne tłumaczenie |
| 🇬🇧 Angielski | `en` | ✅ Pełne tłumaczenie |
| 🇩🇪 Niemiecki | `de` | ✅ Pełne tłumaczenie |
| 🇪🇸 Hiszpański | `es` | ✅ Pełne tłumaczenie |
| 🇮🇹 Włoski | `it` | ✅ Pełne tłumaczenie |
| 🇫🇷 Francuski | `fr` | ✅ Pełne tłumaczenie |
| 🇷🇺 Rosyjski | `ru` | ✅ Pełne tłumaczenie |

**Co jest tłumaczone:**
- ✅ Graficzny kreator instalacji (install-wizard)
- ✅ Wszystkie komunikaty systemowe
- ✅ Moduły (adblock, diagnostics, help)
- ✅ Logi i raporty błędów

**Automatyczne wykrywanie języka:**
```bash
# System automatycznie wykrywa język z $LANG
sudo ./citadel.sh install-wizard
```

**Wymuszenie języka:**
```bash
sudo ./citadel.sh install-wizard pl  # Polski
sudo ./citadel.sh install-wizard en  # Angielski
sudo ./citadel.sh install-wizard de  # Niemiecki
```

### 🖥️ Graficzny Kreator Instalacji

Cytadela ma **interaktywny kreator graficzny** (whiptail/dialog) który przeprowadza Cię przez całą instalację:

**Funkcje kreatora:**
- ✅ Graficzne menu w terminalu
- ✅ Listy wyboru dla komponentów
- ✅ Automatyczne wykrywanie języka
- ✅ Krok po kroku (7 etapów)
- ✅ Weryfikacja na końcu

**Przykładowy wygląd:**
```
┌─────────────────────────────────────────────────────┐
│    CITADEL INSTALLATION WIZARD v3.1                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Select components to install:                     │
│                                                     │
│  [X] DNSCrypt-Proxy (DNS encryption)               │
│  [X] CoreDNS (DNS server)                          │
│  [X] NFTables (firewall)                           │
│  [X] Ad blocking                                   │
│  [ ] Terminal Dashboard (optional)                 │
│                                                     │
│         <OK>              <Cancel>                  │
└─────────────────────────────────────────────────────┘
```

### 🏗️ Architektura Systemu

**Jak działa Cytadela:**

```
┌─────────────┐
│ Aplikacja   │  Twoja przeglądarka, aplikacje itp.
└──────┬──────┘
       │ Zapytanie DNS (example.com?)
       ▼
┌─────────────────────────────────┐
│ CoreDNS (127.0.0.1:53)         │  Lokalny resolver DNS
│ ├─ Cache (85-90% trafień)     │  Szybkie odpowiedzi
│ ├─ Adblock (325k+ domen)      │  Blokuje reklamy/trackery
│ └─ Metryki (Prometheus)        │  Monitorowanie
└──────┬──────────────────────────┘
       │ Cache miss? Przekaż do...
       ▼
┌─────────────────────────────────┐
│ DNSCrypt-Proxy                 │  Warstwa szyfrowania
│ └─ Zaszyfrowane (DoH/DoT)      │  ISP nie może zobaczyć zapytań
└──────┬──────────────────────────┘
       │ Zaszyfrowane zapytanie DNS
       ▼
   🌐 Internet (Prywatność chroniona)

┌─────────────────────────────────┐
│ NFTables (Poziom kernela)      │  Zapobieganie wyciekom
│ └─ Blokuje zewnętrzne :53 ✗    │  Aplikacje nie mogą ominąć
│    (dotyczy całego ruchu       │  Egzekwowanie systemowe
│     wychodzącego)              │
└─────────────────────────────────┘
```

**Dlaczego to lepsze:**
- ✅ **Prywatność:** ISP nie może zobaczyć Twoich zapytań DNS (szyfrowane)
- ✅ **Bezpieczeństwo:** Aplikacje nie mogą ominąć DNS (egzekwowanie na poziomie kernela)
- ✅ **Szybkość:** Lokalny cache = szybsze przeglądanie (85-90% współczynnik trafień)
- ✅ **Czystość:** Blokuje reklamy/trackery na poziomie DNS (325k+ domen)
- ✅ **Kontrola:** Wszystko działa lokalnie, bez zależności chmurowych

---

## 💻 WYMAGANIA SYSTEMOWE

### Minimalne wymagania:

- **Dystrybucja systemu operacyjnego:** Arch Linux, CachyOS (inne dystrybucje: manualna adaptacja)
- **RAM:** 512 MB minimum, 1 GB zalecane
- **Dysk:** 100 MB na instalację
- **Sieć:** Aktywne połączenie internetowe
- **Uprawnienia:** Dostęp root (sudo)

### Zalecane:

- **CPU:** 2 rdzenie lub więcej
- **RAM:** 2 GB lub więcej
- **Dysk:** SSD dla lepszej wydajności

### Sprawdzanie wymagań:

```bash
# Sprawdź wersję systemu
cat /etc/os-release

# Sprawdź RAM
free -h

# Sprawdź miejsce na dysku
df -h

# Sprawdź połączenie internetowe
ping -c 3 1.1.1.1
```

---

## 🚀 INSTALACJA

### Krok 1: Pobierz repozytorium

```bash
# Klonuj repozytorium
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# Sprawdź wersję
cat VERSION
```

### Krok 2: Sprawdź zależności

```bash
# Sprawdź brakujące zależności
sudo ./citadel.sh check-deps

# Lub zainstaluj automatycznie
sudo ./citadel.sh check-deps --install
```

**Wymagane pakiety:**
- `dnscrypt-proxy` - Szyfrowanie DNS
- `coredns` - Serwer DNS
- `nftables` - Firewall
- `curl` - Pobieranie list blokowania
- `jq` - Parsowanie JSON
- `dig` - Testy DNS

### Krok 3: Instalacja

Cytadela oferuje **DWIE TRYB INSTALACJI:**

#### Opcja A: Kreator graficzny (ZALECANE dla początkujących)

```bash
# Uruchom interaktywny kreator instalacji
sudo ./citadel.sh install-wizard
```

**Kreator przeprowadzi Cię przez:**

1. ✅ Sprawdzanie zależności
2. ✅ Wybór komponentów do instalacji
3. ✅ Konfigurację DNSCrypt-Proxy
4. ✅ Konfigurację CoreDNS
5. ✅ Konfigurację firewall
6. ✅ Konfigurację systemu
7. ✅ Weryfikację instalacji

**Przykładowy przebieg:**

```
╔═══════════════════════════════════════════════════════════════╗
║              CITADEL INSTALLATION WIZARD                      ║
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
  [ ] Terminal Dashboard (opcjonalne)

[3/7] Konfigurowanie DNSCrypt-Proxy...
✓ Utworzono /etc/dnscrypt-proxy/dnscrypt-proxy.toml

[4/7] Konfigurowanie CoreDNS...
✓ Utworzono /etc/coredns/Corefile

[5/7] Konfigurowanie firewall...
✓ Reguły NFTables załadowane

[6/7] Konfigurowanie systemu...
✓ System przełączony na DNS Cytadela

[7/7] Weryfikacja...
✓ DNSCrypt-Proxy: URUCHOMIONY
✓ CoreDNS: URUCHOMIONY
✓ NFTables: URUCHOMIONY
✓ Rozwiązywanie DNS: OK

╔═══════════════════════════════════════════════════════════════╗
║              INSTALACJA ZAKOŃCZONA POWODZENIEM!              ║
╚═══════════════════════════════════════════════════════════════╝
```

---

#### Opcja B: CLI dla hardcore użytkowników (szybka instalacja)

```bash
# Zainstaluj wszystko bez GUI - jedno polecenie!
sudo ./citadel.sh install-all
```

**Charakterystyki:**
- ✅ **Bez GUI** - czysty CLI
- ✅ **Szybki** - instaluje wszystko automatycznie
- ✅ **Bez pytań** - pełna instalacja natychmiast
- ✅ **Dla zaawansowanych użytkowników** - pełna kontrola przez logi

**Co `install-all` robi:**
1. Instaluje DNSCrypt-Proxy
2. Instaluje CoreDNS
3. Instaluje NFTables
4. Przebudowuje listy blokowania
5. Uruchamia wszystkie usługi
6. Przeprowadza testy (DNS + adblock)
7. Pokazuje status

**Przepływ dla hardcore użytkowników:**
```bash
# 1. Instalacja (bez GUI)
sudo ./citadel.sh install-all

# 2. Firewall (tryb bezpieczny)
sudo ./citadel.sh firewall-safe

# 3. Test DNS
dig +short google.com @127.0.0.1

# 4. Przełącz system
sudo ./citadel.sh configure-system

# 5. Weryfikacja
sudo ./citadel.sh verify
```

**5 poleceń, 0 GUI, pełna kontrola!** 💪

---

#### Porównanie trybów instalacji

| Funkcja | install-wizard | install-all |
|---------|----------------|-------------|
| **GUI** | ✅ whiptail | ❌ CLI tylko |
| **Interaktywny** | ✅ Tak | ❌ Nie |
| **Języki** | ✅ 7 | ❌ EN/PL |
| **Wybór komponentów** | ✅ Lista wyboru | ❌ Wszystko |
| **Szybkość** | Wolniejszy | ⚡ Szybszy |
| **Dla kogo** | Początkujący | 💪 Hardcore |

---

### Krok 4: Zweryfikuj instalację

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

### Kompletne usunięcie

Usuwa Cytadelę całkowicie włącznie z konfiguracją i danymi:

```bash
sudo ./citadel.sh uninstall
```

**To zrobi:**
- Sprawdza i opcjonalnie usuwa opcjonalne pakiety (dnsperf, curl, jq)
- **Przywraca DNS** (sprawdza ważność backupu, używa NetworkManager jeśli dostępny, lub ustawia fallback DNS)
- **Testuje DNS** z wieloma serwerami (1.1.1.1, 8.8.8.8, 9.9.9.9) przed kontynuacją
- Zatrzymuje i wyłącza usługi (coredns, dnscrypt-proxy)
- Usuwa reguły firewall
- Usuwa pliki konfiguracyjne (`/etc/coredns/`, `/etc/dnscrypt-proxy/`)
- Usuwa katalogi danych
- Usuwa użytkownika systemowego `dnscrypt`

**Funkcje bezpieczeństwa DNS:**
- Ignoruje backup jeśli wskazuje na localhost (127.0.0.1)
- Próbuje użyć NetworkManager auto-DNS jeśli dostępny
- Używa 3 fallback DNS serwerów (Cloudflare, Google, Quad9)
- Testuje DNS przed kontynuacją - ostrzega jeśli problemy
- Pozwala na anulowanie jeśli wykryje problemy z DNS
- Udostępnia instrukcje manualnej naprawy

**Wymagane potwierdzenie:** Wpisz `yes` aby kontynuować.

### Zachowaj konfigurację

Zatrzymuje usługi ale zachowuje wszystkie pliki konfiguracyjne:

```bash
sudo ./citadel.sh uninstall-keep-config
```

**Przypadek użycia:** Tymczasowe wyłączenie, planowana reinstalacja.

---

## ⚙️ KONFIGURACJA

### Konfiguracja systemu

#### Przełącz na DNS Cytadela

```bash
sudo ./citadel.sh configure-system
```

**Co robi to polecenie:**
- Tworzy backup oryginalnej konfiguracji
- Modyfikuje `/etc/resolv.conf`
- Ustawia `127.0.0.1` jako serwer DNS
- Blokuje zmiany przez NetworkManager

#### Przywróć oryginalną konfigurację:

```bash
# Przywróć backup sprzed instalacji Cytadeli
sudo ./citadel.sh restore-system

# Przywróć fabryczne ustawienia systemd-resolved (bezpieczny fallback)
sudo ./citadel.sh restore-system-default
```

**Różnica:**
- `restore-system` - przywraca dokładną konfigurację z backupu (przed Cytadelą)
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

#### Tryb ścisły (dla zaawansowanych użytkowników):

```bash
sudo ./citadel.sh firewall-strict
```

**Reguły trybu ścisłego:**
- ✅ Blokuje WSZYSTKIE zapytania DNS poza localhost
- ✅ Blokuje DoH na poziomie IP (1.1.1.1:443, 8.8.8.8:443)
- ✅ Loguje próby ominięcia
- ⚠️ Może blokować niektóre aplikacje

### Konfiguracja DNSCrypt-Proxy

#### Edytuj konfigurację:

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
require_nofilter = false     # Zezwól na filtrowanie

# Wydajność
cache_size = 1024            # Rozmiar cache (wpisy)
cache_min_ttl = 300          # Min TTL (sekundy)
cache_max_ttl = 86400        # Max TTL (sekundy)

# Timeout
timeout = 3000               # Timeout zapytania (ms)
```

**Po zmianach:**

```bash
# Restartuj DNSCrypt-Proxy
sudo systemctl restart dnscrypt-proxy

# Sprawdź status
sudo systemctl status dnscrypt-proxy
```

### Konfiguracja CoreDNS

#### Edytuj konfigurację:

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
    
    # Przekaż do DNSCrypt-Proxy
    forward . 127.0.0.1:5355
    
    # Metryki Prometheus
    prometheus 127.0.0.1:9153
    
    # Logi (opcjonalne)
    # log
    
    # Błędy
    errors
}
```

**Po zmianach:**

```bash
# Restartuj CoreDNS
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

**Przykładowe wyjście:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    STATUS CYTADELA                           ║
╚═══════════════════════════════════════════════════════════════╝

🔥 USŁUGI:
✓ DNSCrypt-Proxy: URUCHOMIONY (PID: 12345)
✓ CoreDNS: URUCHOMIONY (PID: 12346)
✓ NFTables: URUCHOMIONY

🌐 KONFIGURACJA DNS:
✓ System DNS: 127.0.0.1
✓ Rozwiązywanie DNS: OK
✓ DNSCrypt: AKTYWNY

📊 STATYSTYKI:
  Łączne Zapytania: 15,234
  Trafienia Cache: 12,891 (84.6%)
  Zablokowane Domeny: 1,234
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

### Auto-aktualizacja list blokowania

#### Włącz auto-aktualizację:

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
- Czas aktualizacji (domyślnie: 03:00)
- Powiadomienia (domyślnie: włączone)

#### Manualna aktualizacja:

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

#### Przywróć z backupu:

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

### Prywatność IPv6

#### Włącz prywatność IPv6:

```bash
sudo ./citadel.sh ipv6-privacy-on
```

**Co robi:**
- Włącza tymczasowe adresy IPv6
- Ustawia preferencję dla tymczasowych adresów
- Konfiguruje rotację adresów

#### Automatyczne zarządzanie:

```bash
sudo ./citadel.sh ipv6-privacy-auto
```

**Auto-ensure:**
- Sprawdza tymczasowe adresy
- Automatycznie włącza jeśli brakuje
- Monitoruje i naprawia

#### Inteligentne wykrywanie IPv6:

```bash
sudo ./citadel.sh smart-ipv6
```

**Funkcje:**
- Testuje łączność IPv6
- Wykrywa problemy
- Automatycznie naprawia (deep reset)

### Dashboard Terminala

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

### Benchmark Wydajności DNS

Test wydajności serwera DNS z dnsperf:

```bash
sudo ./citadel.sh benchmark
```

**Parametry:**
- Zapytania: 10,000
- Równoległe klienty: 50
- Czas trwania: 60 sekund
- Cel: 127.0.0.1:53

**Wyniki:**
- QPS (Zapytania na Sekundę)
- Średnie opóźnienie
- Współczynnik sukcesu
- Współczynnik trafień cache

**Interpretacja:**
- >50,000 QPS: Doskonale
- 20,000-50,000 QPS: Dobrze
- 10,000-20,000 QPS: Akceptowalne
- <10,000 QPS: Wymaga optymalizacji

---

## 🚫 BLOKOWANIE REKLAM

### Status blokowania

```bash
sudo ./citadel.sh adblock-status
```

**Przykładowe wyjście:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    STATUS ADBLOCK                            ║
╚═══════════════════════════════════════════════════════════════╝

📊 STATYSTYKI:
  Łączne Zablokowane Domeny: 325,847
  Zablokowane Niestandardowe: 42
  Na Allowlist: 5
  Ostatnia Aktualizacja: 2026-01-31 03:00:15

📋 PROFIL LISTY BLOKUJĄCEJ:
  Aktualny: standard
  Dostępne: minimal, standard, aggressive

🎯 NAJCZĘŚCIEJ BLOKOWANE DZISIAJ:
  1. ads.example.com (1,234 zapytań)
  2. tracker.example.com (987 zapytań)
  3. analytics.example.com (654 zapytania)
```

### Zarządzanie profilami list blokujących

#### Lista dostępnych profili:

```bash
sudo ./citadel.sh blocklist-list
```

**Dostępne profile:**

| Profil | Domeny | Opis |
|--------|--------|------|
| `minimal` | ~50K | Reklamy i trackery tylko |
| `standard` | ~325K | Reklamy, trackery, malware (zalecane) |
| `aggressive` | ~1M+ | Maksymalne blokowanie |

#### Przełącz profil:

```bash
# Przełącz na aggressive
sudo ./citadel.sh blocklist-switch aggressive

# Przełącz na minimal
sudo ./citadel.sh blocklist-switch minimal
```

#### Status listy blokującej:

```bash
sudo ./citadel.sh blocklist-status
```

#### Zarządzaj własnymi URL list blokujących:

```bash
# Dodaj własny URL listy blokującej
sudo ./citadel.sh blocklist-add-url https://example.com/blocklist.txt

# Usuń URL
sudo ./citadel.sh blocklist-remove-url https://example.com/blocklist.txt

# Pokaż wszystkie skonfigurowane URL
sudo ./citadel.sh blocklist-show-urls
```

#### Aktualizuj listy blokujące z LKG fallback:

```bash
sudo ./citadel.sh lists-update
```

Używa Last Known Good (LKG) cache jeśli aktualizacja zawiedzie.

### Blokowanie własnych domen

#### Dodaj domenę do listy blokującej:

```bash
sudo ./citadel.sh adblock-add ads.example.com
```

**Obsługuje wildcardy:**

```bash
# Zablokuj wszystkie subdomeny
sudo ./citadel.sh adblock-add "*.ads.example.com"
```

#### Usuń domenę z listy blokującej:

```bash
sudo ./citadel.sh adblock-remove ads.example.com
```

#### Sprawdź czy domena jest zablokowana:

```bash
sudo ./citadel.sh adblock-query ads.example.com
```

**Wyjście:**

```
✓ ads.example.com jest ZABLOKOWANA
  Źródło: custom.hosts
  Dodano: 2026-01-31 12:34:56
```

### Allowlist (whitelisty)

#### Dodaj domenę do allowlist:

```bash
sudo ./citadel.sh allowlist-add safe-ads.example.com
```

**Przypadki użycia:**
- Odblokuj fałszywe pozytywy
- Zezwól na dostęp do zaufanych domen
- Nadpisuje listy blokujące

#### Lista allowlist:

```bash
sudo ./citadel.sh allowlist-list
```

#### Usuń z allowlist:

```bash
sudo ./citadel.sh allowlist-remove safe-ads.example.com
```

### Przebuduj listy blokujące

```bash
sudo ./citadel.sh adblock-rebuild
```

**Kiedy używać:**
- Po dodaniu/usunięciu wielu domen
- Po zmianie profilu
- Po manualnych edycjach plików

### Wyświetl listy

```bash
# Pokaż własne bloki
sudo ./citadel.sh custom

# Pokaż główną listę blokującą
sudo ./citadel.sh blocklist

# Pokaż połączoną listę
sudo ./citadel.sh combined
```

---

## 🔐 BEZPIECZEŃSTWO

### Ochrona Supply Chain

#### Inicjalizuj:

```bash
sudo ./citadel.sh supply-chain-init
```

**Tworzy:**
- Checksumy wszystkich plików
- Manifest integralności
- Podpisy cyfrowe (opcjonalne)

#### Weryfikuj:

```bash
sudo ./citadel.sh supply-chain-verify
```

**Sprawdza:**
- ✅ Integralność binarna
- ✅ Integralność skryptów
- ✅ Integralność konfiguracji
- ⚠️ Wykrywa modyfikacje

#### Status:

```bash
sudo ./citadel.sh supply-chain-status
```

### Sprawdzenie Integralności

#### Inicjalizuj manifest:

```bash
sudo ./citadel.sh integrity-init
```

#### Sprawdź integralność:

```bash
sudo ./citadel.sh integrity-check
```

**Przykładowe wyjście:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    SPRAWDZENIE INTEGRALNOŚCI                 ║
╚═══════════════════════════════════════════════════════════════╝

✓ /usr/bin/dnscrypt-proxy: OK
✓ /usr/bin/coredns: OK
✓ /etc/dnscrypt-proxy/dnscrypt-proxy.toml: OK
⚠ /etc/coredns/Corefile: MODYFIKOWANY
✓ /opt/citadel/modules/*.sh: OK

WYNIK: 1 plik zmodyfikowany
```

### Ghost Check (Audyt Portów)

```bash
sudo ./citadel.sh ghost-check
```

**Sprawdza:**
- Otwarte porty
- Nasłuchujące usługi
- Nieoczekiwane połączenia
- Potencjalne backdoory

**Przykładowe wyjście:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    GHOST CHECK                               ║
╚═══════════════════════════════════════════════════════════════╝

🔍 OTWARTE PORTY:
  ✓ 22/tcp (ssh) - OCZEKIWANY
  ✓ 53/udp (dns) - OCZEKIWANY
  ⚠ 8080/tcp (unknown) - NIEOCZEKIWANY

⚠ OSTRZEŻENIE: 1 nieoczekiwany port znaleziony!
```

### Killswitch (Przełącznik Awaryjny)

#### Włącz killswitch:

```bash
sudo ./citadel.sh killswitch-on
```

**Co robi:**
- Blokuje WSZYSTKIE zapytania DNS oprócz localhost
- Wymusza użycie Cytadela
- Zapobiega wyciekom DNS

#### Wyłącz killswitch:

```bash
sudo ./citadel.sh killswitch-off
```

---

## 📊 MONITOROWANIE

### Status Zdrowia

```bash
sudo ./citadel.sh health-status
```

**Sprawdza:**
- Status usług
- Wydajność DNS
- Użycie zasobów
- Błędy w logach
- Anomalie

#### Zainstaluj Health Watchdog

```bash
sudo ./citadel.sh health-install
```

Automatycznie monitoruje usługi i restartuje jeśli potrzebne.

#### Odinstaluj Health Watchdog

```bash
sudo ./citadel.sh health-uninstall
```

### Statystyki Cache

```bash
# Podstawowe statystyki
sudo ./citadel.sh cache-stats

# Top zapytywanych domen
sudo ./citadel.sh cache-stats-top 20

# Resetuj statystyki
sudo ./citadel.sh cache-stats-reset

# Śledź statystyki na żywo
sudo ./citadel.sh cache-stats-watch
```

**Pokazuje:**
- Rozmiar cache
- Współczynnik trafień
- Najpopularniejsze domeny
- Statystyki wydajności

**Przykładowe wyjście:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    STATYSTYKI CACHE                          ║
╚═══════════════════════════════════════════════════════════════╝

📊 METRYKI CACHE:
  Łączne Wpisy: 8,234
  Współczynnik Trafień: 87.3%
  Współczynnik Chybień: 12.7%
  Wypędzenia: 234

🔥 TOP DOMENY (ostatnie 24h):
  1. google.com (2,345 zapytań)
  2. youtube.com (1,987 zapytań)
  3. github.com (1,234 zapytań)
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

### Odkrywanie Sieci

```bash
sudo ./citadel.sh discover
```

**Pokazuje:**
- Aktywny interfejs sieciowy
- Adres IP (IPv4/IPv6)
- Domyślna brama
- Serwery DNS
- Reguły firewall

---

## 🚨 TRYB AWARYJNY

### Panic Bypass

**Używaj gdy:**
- DNS przestało działać
- Brak dostępu do internetu
- Potrzebujesz szybko przywrócić połączenie

#### Aktywuj (na 5 minut):

```bash
sudo ./citadel.sh panic-bypass 300
```

**Co robi:**
- Opróżnia reguły NFTables
- Tymczasowo przełącza na publiczny DNS (1.1.1.1)
- Automatycznie przywraca po timeout

#### Aktywuj (bez limitu czasu):

```bash
sudo ./citadel.sh panic-bypass
```

#### Manualne przywrócenie:

```bash
sudo ./citadel.sh panic-restore
```

#### Status trybu panic:

```bash
sudo ./citadel.sh panic-status
```

### Emergency Refuse

**Używaj gdy:**
- Podejrzewasz atak
- Chcesz całkowicie zablokować DNS

```bash
# Zablokuj wszystkie zapytania DNS
sudo ./citadel.sh emergency-refuse

# Przywróć normalną operację
sudo ./citadel.sh emergency-restore
```

---

## 🔧 ROZWIĄZYWANIE PROBLEMÓW

### Problem: DNS nie działa po instalacji

#### Objawy:
- Brak dostępu do stron internetowych
- Błędy "could not resolve host"
- Timeout przy pingowaniu domen

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

# Restartuj usługi
sudo systemctl restart dnscrypt-proxy
sudo systemctl restart coredns
```

**2. Błąd konfiguracji:**

```bash
# Sprawdź DNSCrypt config
dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Sprawdź CoreDNS config
coredns -conf /etc/coredns/Corefile -validate
```

**3. Firewall blokuje:**

```bash
# Sprawdź reguły
sudo nft list ruleset

# Tymczasowo wyłącz firewall
sudo systemctl stop nftables

# Jeśli pomogło - problem z regułami
sudo ./citadel.sh firewall-safe
```

### Problem: Konflikty portów

#### Objawy:
