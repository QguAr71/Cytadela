# CYTADELA++ v3.1 — KOMPLETNY PODRĘCZNIK

> **Fortified DNS Infrastructure** — Advanced Hardened Resolver with Full Privacy Stack  
> **Modular Architecture** — Lazy Loading, Interactive Installer, Multi-Blocklist Support

---

# OCENA PROJEKTU

## 🛡️ Poziom ochrony: **8.5/10**

| Warstwa | Ochrona | Ocena |
|---------|---------|-------|
| **DNS Encryption** | DNSCrypt/DoH szyfruje zapytania przed ISP | ⭐⭐⭐⭐⭐ |
| **DNS Leak Prevention** | nftables wymusza localhost, blokuje bypass | ⭐⭐⭐⭐⭐ |
| **Adblock** | 318k+ domen zablokowanych (Hagezi Pro) | ⭐⭐⭐⭐⭐ |
| **IPv6 Privacy** | Temporary addresses, auto-ensure | ⭐⭐⭐⭐ |
| **Integrity** | SHA256 manifest, supply-chain verification | ⭐⭐⭐⭐ |
| **Resilience** | LKG cache, panic-bypass, health watchdog | ⭐⭐⭐⭐⭐ |

### Co chroni:
- ✅ ISP nie widzi zapytań DNS
- ✅ Aplikacje nie mogą ominąć lokalnego resolvera
- ✅ Reklamy/trackery/malware blokowane na poziomie DNS
- ✅ IPv6 nie ujawnia stałego adresu MAC
- ✅ System działa nawet gdy upstream padnie (LKG)

### Czego nie chroni:
- ❌ Ruch HTTP/HTTPS (potrzebny VPN)
- ❌ Fingerprinting przeglądarki
- ❌ Metadata połączeń (IP docelowe)

---

## 👤 Przydatność dla użytkowników: **9.5/10**

| Aspekt | Ocena | Uwagi |
|--------|-------|-------|
| **Instalacja** | ⭐⭐⭐⭐⭐ | Interactive wizard, modular architecture |
| **Diagnostyka** | ⭐⭐⭐⭐⭐ | `discover`, `health-status`, `cache-stats` |
| **Recovery** | ⭐⭐⭐⭐⭐ | `panic-bypass`, `config-backup/restore` |
| **Dokumentacja** | ⭐⭐⭐⭐⭐ | Kompletny manual, help wbudowany |
| **Maintenance** | ⭐⭐⭐⭐⭐ | Auto-update, health watchdog, notifications |
| **Flexibility** | ⭐⭐⭐⭐⭐ | Multi-blocklist, SAFE/STRICT, location-aware |

### Dla kogo idealne:
- 🎯 Privacy-conscious użytkownicy
- 🎯 Administratorzy domowych sieci
- 🎯 Użytkownicy Arch/CachyOS
- 🎯 Osoby chcące blokować reklamy na poziomie sieci

### Krzywa uczenia:
- **Podstawowe użycie:** łatwe (install-all → configure-system)
- **Zaawansowane:** średnie (wymaga zrozumienia DNS/firewall)

---

## 📊 Porównanie z alternatywami

| Rozwiązanie | Ochrona DNS | Adblock | Leak Prevention | Łatwość |
|-------------|-------------|---------|-----------------|---------|
| **Cytadela++** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Pi-hole | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| AdGuard Home | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Tylko DNSCrypt | ⭐⭐⭐⭐⭐ | ❌ | ⭐⭐ | ⭐⭐⭐ |

### Przewaga Cytadeli (v3.1):
- Pełna integracja nftables (leak prevention)
- **Modułowa architektura z lazy loading**
- **Interactive installer wizard**
- **Multi-blocklist support (6 profili)**
- **Auto-update z LKG fallback**
- **Config backup/restore**
- **Cache statistics z Prometheus**
- **Desktop notifications**
- Panic recovery
- IPv6 privacy management

---

## 🎯 Podsumowanie

**Cytadela++ to solidne, kompleksowe rozwiązanie DNS security dla zaawansowanych użytkowników Linux.**

- **Ochrona:** Bardzo dobra dla DNS/adblock, wymaga VPN dla pełnej prywatności
- **Przydatność:** Wysoka, szczególnie dzięki diagnostyce i recovery
- **Unikalność:** Kombinacja DNSCrypt + CoreDNS + nftables + health monitoring

### Ocena końcowa: 9/10 🛡️

**Nowości v3.1:**
- ✨ Modułowa architektura (45% redukcja kodu)
- 🎯 Interactive installer z checklistą
- 📦 Multi-blocklist (light/balanced/aggressive/privacy/polish/custom)
- 🔄 Auto-update blocklist (systemd timer)
- 💾 Config backup/restore
- 📊 Cache statistics (hit rate, latency)
- 🔔 Desktop notifications
- 🚀 Lazy loading modułów

---

# SPIS TREŚCI

1. [Architektura](#architektura)
2. [Instalacja](#instalacja)
3. [Moduły bezpieczeństwa](#moduły-bezpieczeństwa)
4. [Komendy diagnostyczne](#komendy-diagnostyczne)
5. [Komendy awaryjne](#komendy-awaryjne)
6. [Adblock Panel](#adblock-panel)
7. [IPv6 Management](#ipv6-management)
8. [Firewall Modes](#firewall-modes)
9. [Narzędzia dodatkowe](#narzędzia-dodatkowe)
10. [Pliki konfiguracyjne](#pliki-konfiguracyjne)
11. [Troubleshooting](#troubleshooting)

---

# ARCHITEKTURA

## Warstwy ochrony (Defense in Depth)

```
┌─────────────────────────────────────────────────────────────┐
│                    APLIKACJE (Firefox, curl, etc.)          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  WARSTWA 3: NFTables (leak prevention, kill-switch)        │
│  - Blokuje DNS do zewnętrznych serwerów                    │
│  - Wymusza użycie lokalnego resolvera                      │
│  - Kill-switch w trybie STRICT                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  WARSTWA 2: CoreDNS (caching, blocking, metrics)           │
│  - Cache DNS (szybsze odpowiedzi)                          │
│  - Adblock (blokowanie domen)                              │
│  - Prometheus metrics (:9153)                              │
│  - Nasłuchuje na 127.0.0.1:53                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  WARSTWA 1: DNSCrypt-Proxy (encrypted upstream)            │
│  - Szyfrowane zapytania DNS (DNSCrypt/DoH)                 │
│  - Anonimizacja (opcjonalnie)                              │
│  - DNSSEC validation (opcjonalnie)                         │
│  - Nasłuchuje na 127.0.0.1:5355                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  INTERNET (zaszyfrowane zapytania do resolverów)           │
│  - Quad9, Cloudflare, Mullvad, etc.                        │
└─────────────────────────────────────────────────────────────┘
```

## Model zagrożeń

- **ISP tracking** — szyfrowanie DNS uniemożliwia ISP podgląd zapytań
- **DNS leaks** — nftables wymusza użycie lokalnego resolvera
- **Malware/telemetry** — adblock blokuje znane domeny
- **Metadata exposure** — Privacy Extensions dla IPv6

---

# INSTALACJA

## Komendy instalacyjne (v3.1)

| Komenda | Opis |
|---------|------|
| `install-wizard` | 🎯 **Interactive installer z checklistą (ZALECANE)** |
| `install-all` | Instaluj wszystkie moduły DNS (NIE wyłącza systemd-resolved) |
| `install-dnscrypt` | Instaluj tylko DNSCrypt-Proxy |
| `install-coredns` | Instaluj tylko CoreDNS |
| `install-nftables` | Instaluj tylko reguły NFTables |

## Rekomendowany workflow (v3.1)

### Opcja A: Interactive Wizard (najłatwiejsze)

```bash
# 1. Instalacja przez wizard
sudo cytadela++ install-wizard
# Wybierz moduły SPACE, potwierdź ENTER

# 2. Przełącz system na Cytadel++ DNS
sudo cytadela++ configure-system
```

### Opcja B: Tradycyjna instalacja

```bash
# 1. Instalacja wszystkich modułów
sudo cytadela++ install-all

# 2. Ustaw firewall SAFE (nie zrywa internetu)
sudo ./cytadela++.sh firewall-safe

# 3. Test lokalnego DNS
dig +short google.com @127.0.0.1

# 4. Przełącz system na Cytadel++ DNS
sudo ./cytadela++.sh configure-system

# 5. Test internetu
ping -c 3 google.com

# 6. Przełącz na STRICT (pełna blokada DNS-leak)
sudo ./cytadela++.sh firewall-strict
```

## Opcje DNSSEC

```bash
# Metoda 1: zmienna środowiskowa
CITADEL_DNSSEC=1 sudo ./cytadela++.sh install-dnscrypt

# Metoda 2: flaga
sudo ./cytadela++.sh install-all --dnssec
```

---

# MODUŁY BEZPIECZEŃSTWA

## 1. Integrity Layer (Local-First)

**Cel:** Weryfikacja integralności skryptów i binarek przed uruchomieniem.

### Komendy
```bash
integrity-init        # Utwórz manifest SHA256 dla skryptów/binarek
integrity-check       # Zweryfikuj integralność przeciwko manifestowi
integrity-status      # Pokaż tryb i info o manifeście
--dev                 # Uruchom w trybie developer (pominięte sprawdzenia)
```

### Tryby
- **secure** (domyślny) — pełna weryfikacja integralności
- **developer** — pominięte sprawdzenia (dla deweloperów)

### Pliki
```
/etc/cytadela/manifest.sha256    # Manifest z hashami SHA256
~/.cytadela_dev                  # Plik włączający tryb developer
```

### Działanie
1. `integrity-init` generuje hashe SHA256 dla:
   - Głównych skryptów (`cytadela++.sh`, `citadela_en.sh`)
   - Binarek w `/opt/cytadela/bin/`
2. `integrity-check` porównuje aktualne hashe z manifestem
3. W trybie secure: mismatch dla binarek = hard fail, dla modułów = prompt

---

## 2. LKG (Last Known Good) — Blocklist Cache

**Cel:** Zapewnienie działania adblock nawet gdy upstream jest niedostępny.

### Komendy
```bash
lkg-save              # Zapisz aktualną blocklist do cache
lkg-restore           # Przywróć blocklist z cache
lkg-status            # Pokaż status cache
lists-update          # Aktualizuj blocklist z LKG fallback
```

### Pliki
```
/var/lib/cytadela/lkg/blocklist.hosts    # Cached blocklist
/var/lib/cytadela/lkg/blocklist.meta     # Metadane (data, linie, sha256)
```

### Walidacja blocklist
Przed zapisem do LKG, blocklist jest walidowana:
- Min. 1000 linii
- Format hosts (`0.0.0.0 domain`)
- Brak error pages (`<html>`, `404`, `403`)

### Przepływ `lists-update`
```
1. Pobierz blocklist do staging
2. Waliduj pobrany plik
3. Jeśli OK → atomic swap + zapisz do LKG
4. Jeśli walidacja fail → zachowaj obecny
5. Jeśli download fail → przywróć z LKG
```

---

## 3. Supply-Chain Verification

**Cel:** Weryfikacja SHA256 pobieranych assetów.

### Komendy
```bash
supply-chain-status   # Pokaż status pliku checksums
supply-chain-init     # Zainicjalizuj checksums dla znanych assetów
supply-chain-verify   # Zweryfikuj lokalne pliki przeciwko manifestowi
```

### Pliki
```
/etc/cytadela/checksums.sha256    # Checksums dla zewnętrznych assetów
```

### Działanie
- `supply-chain-init` pobiera aktualne hashe blocklist
- `supply-chain-verify` sprawdza pliki z integrity manifest
- Funkcja `supply_chain_download()` weryfikuje hash przed zapisem

---

## 4. Health Watchdog

**Cel:** Automatyczny restart serwisów przy awarii + okresowe health checks.

### Komendy
```bash
health-status         # Pokaż status zdrowia (serwisy, DNS probe, firewall)
health-install        # Zainstaluj auto-restart + health check timer
health-uninstall      # Usuń health watchdog
```

### Co instaluje `health-install`
1. **Health check script** (`/usr/local/bin/citadel-health-check`)
   - Sprawdza DNS resolution
   - Jeśli fail → restartuje coredns
2. **Systemd overrides** dla dnscrypt-proxy i coredns:
   ```ini
   [Service]
   Restart=on-failure
   RestartSec=5
   StartLimitIntervalSec=300
   StartLimitBurst=5
   ```
3. **Health check timer** (co 5 minut)

### Pliki tworzone
```
/usr/local/bin/citadel-health-check
/etc/systemd/system/citadel-health.service
/etc/systemd/system/citadel-health.timer
/etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf
/etc/systemd/system/coredns.service.d/citadel-restart.conf
```

---

## 5. Location-Aware Advisory

**Cel:** Porada o trybie firewalla w zależności od sieci WiFi.

### Komendy
```bash
location-status           # Pokaż SSID, trust status, tryb firewalla
location-check            # Sprawdź i zaproponuj zmianę trybu
location-add-trusted      # Dodaj SSID do zaufanych (lub aktualny jeśli brak arg)
location-remove-trusted   # Usuń SSID z zaufanych
location-list-trusted     # Pokaż listę zaufanych SSID
```

### Pliki
```
/etc/cytadela/trusted-ssids.txt    # Lista zaufanych SSID
```

### Logika `location-check`
| Sieć | Firewall | Akcja |
|------|----------|-------|
| UNTRUSTED + SAFE | ⚠️ | Prompt: przełączyć na STRICT? |
| UNTRUSTED + STRICT | ✅ | Good |
| TRUSTED + SAFE | ✅ | Good |
| TRUSTED + STRICT | ℹ️ | Info: możesz przełączyć na SAFE |
| Wired | — | Traktowane jako trusted |

---

## 6. NFT Debug Chain

**Cel:** Debugowanie reguł firewalla z rate-limited logging.

### Komendy
```bash
nft-debug-on          # Włącz debug chain z logowaniem
nft-debug-off         # Wyłącz debug chain
nft-debug-status      # Pokaż status i countery
nft-debug-logs        # Pokaż ostatnie logi CITADEL
```

### Co loguje
- `[CITADEL-DNS]` — zapytania DNS (port 53)
- `[CITADEL-DOT]` — DNS-over-TLS (port 853)
- `[CITADEL-DOH]` — DNS-over-HTTPS do znanych resolverów

### Rate limiting
5 logów/minutę per reguła (żeby nie zalać journala)

### Podgląd logów
```bash
journalctl -f | grep CITADEL
```

---

# KOMENDY DIAGNOSTYCZNE

## Podstawowe

| Komenda | Opis |
|---------|------|
| `status` | Pokaż status serwisów (dnscrypt, coredns, nftables) |
| `diagnostics` | Pełna diagnostyka systemu |
| `verify` | Weryfikuj cały stack (porty/serwisy/DNS/NFT/metrics) |
| `test-all` | Smoke test (verify + leak test + IPv6) |

## Discover

```bash
sudo ./cytadela++.sh discover
```

Pokazuje:
- Aktywny interfejs sieciowy
- Network stack (NetworkManager/systemd-networkd)
- Status nftables
- Adresy IPv4/IPv6
- Status serwisów DNS

## Ghost-Check (Port Audit)

```bash
sudo ./cytadela++.sh ghost-check
```

Skanuje wszystkie nasłuchujące porty i ostrzega o:
- Portach bindowanych do `0.0.0.0` (wszystkie interfejsy IPv4)
- Portach bindowanych do `::` (wszystkie interfejsy IPv6)

**Dozwolone porty (domyślnie):** 22, 53, 5353, 9153

---

# KOMENDY AWARYJNE

## Emergency Commands

| Komenda | Opis |
|---------|------|
| `emergency-refuse` | Odrzuć wszystkie zapytania DNS (emergency mode) |
| `emergency-restore` | Przywróć normalne działanie |
| `killswitch-on` | Aktywuj DNS kill-switch (blokuj wszystko poza localhost) |
| `killswitch-off` | Dezaktywuj kill-switch |

## Panic Bypass (SPOF Recovery)

**Cel:** Tymczasowe wyłączenie ochrony gdy DNS nie działa.

### Komendy
```bash
panic-bypass [secs]   # Wyłącz ochronę + auto-rollback (default 300s)
panic-restore         # Ręcznie przywróć tryb chroniony
panic-status          # Pokaż status panic mode
```

### Co robi `panic-bypass`
1. Zapisuje stan: `resolv.conf`, `nftables ruleset`
2. Flush nftables (pozwala na cały ruch)
3. Ustawia public DNS (9.9.9.9, 1.1.1.1, 8.8.8.8)
4. Uruchamia timer auto-rollback w tle

### Co robi `panic-restore`
1. Przywraca `resolv.conf` z backupu
2. Przywraca nftables z backupu
3. Restartuje dnscrypt-proxy + coredns
4. Czyści pliki stanu

### Pliki
```
/var/lib/cytadela/panic.state              # Stan panic mode
/var/lib/cytadela/resolv.conf.pre-panic    # Backup resolv.conf
/var/lib/cytadela/nft.pre-panic            # Backup nftables
```

---

# NOWE FUNKCJE v3.1

## Multi-Blocklist Support (Issue #17)

**6 profili blocklist do wyboru:**

| Profil | Opis | Domeny |
|--------|------|--------|
| `light` | Minimal blocking, szybki DNS | ~50k |
| `balanced` | **Default** - zbalansowany | ~1.2M |
| `aggressive` | Maksymalna blokada | ~2M+ |
| `privacy` | Focus na telemetry/tracking | ~800k |
| `polish` | Zoptymalizowany pod Polskę 🇵🇱 | ~1.5M |
| `custom` | Własne URL-e użytkownika | - |

### Komendy

```bash
# Pokaż dostępne profile
sudo cytadela++ blocklist-list

# Przełącz profil
sudo cytadela++ blocklist-switch light
sudo cytadela++ blocklist-switch aggressive
sudo cytadela++ blocklist-switch polish

# Status
sudo cytadela++ blocklist-status

# Custom URLs
sudo cytadela++ blocklist-add-url https://example.com/list.txt
sudo cytadela++ blocklist-remove-url https://example.com/list.txt
sudo cytadela++ blocklist-show-urls
```

## Auto-Update Blocklist (Issue #13)

**Automatyczne aktualizacje blocklist przez systemd timer.**

```bash
# Włącz auto-update (daily)
sudo cytadela++ auto-update-enable

# Wyłącz
sudo cytadela++ auto-update-disable

# Status i harmonogram
sudo cytadela++ auto-update-status

# Uruchom teraz (ręcznie)
sudo cytadela++ auto-update-now

# Konfiguruj częstotliwość
sudo cytadela++ auto-update-configure
# Wybierz: daily/weekly/custom
```

**Features:**
- Systemd timer z randomized delay (1h)
- Integracja z LKG fallback
- Automatyczne logowanie do journald
- Restart on failure

## Config Backup/Restore (Issue #14)

**Backup i restore całej konfiguracji.**

```bash
# Utwórz backup
sudo cytadela++ config-backup
# Zapisuje do: /var/lib/cytadela/backups/cytadela-backup-YYYYMMDD-HHMMSS.tar.gz

# Pokaż backupy
sudo cytadela++ config-list

# Przywróć z backupu
sudo cytadela++ config-restore /var/lib/cytadela/backups/cytadela-backup-20260130-163000.tar.gz

# Usuń backup
sudo cytadela++ config-delete /var/lib/cytadela/backups/cytadela-backup-20260130-163000.tar.gz
```

**Backup zawiera:**
- DNSCrypt config (toml, cloaking-rules)
- CoreDNS config (Corefile, zones)
- NFTables rules
- NetworkManager config
- Cytadela state (manifest, panic, location)
- Systemd units

## Cache Statistics (Issue #15)

**Statystyki DNS cache z Prometheus metrics.**

```bash
# Pokaż statystyki
sudo cytadela++ cache-stats

# Top N domen
sudo cytadela++ cache-stats-top 20

# Reset statystyk (restart CoreDNS)
sudo cytadela++ cache-stats-reset

# Live monitoring (2s refresh)
sudo cytadela++ cache-stats-watch
```

**Metryki:**
- Cache hit rate (%)
- Request types (A, AAAA, PTR)
- Response codes (NOERROR, NXDOMAIN, SERVFAIL)
- Query latency (ms)
- Adblock stats

## Desktop Notifications (Issue #16)

**Powiadomienia systemowe (libnotify).**

```bash
# Włącz powiadomienia
sudo cytadela++ notify-enable

# Wyłącz
sudo cytadela++ notify-disable

# Status
sudo cytadela++ notify-status

# Test
sudo cytadela++ notify-test
```

**Powiadomienia dla:**
- Health check failures
- Service restarts
- Blocklist updates
- Panic mode activation

---

# ADBLOCK PANEL

## Komendy

| Komenda | Opis |
|---------|------|
| `adblock-status` | Pokaż status adblock/CoreDNS |
| `adblock-stats` | Pokaż liczby: custom/blocklist/combined |
| `adblock-show [type]` | Pokaż: custom\|blocklist\|combined (pierwsze 200 linii) |
| `adblock-edit` | Edytuj custom.hosts i przeładuj |
| `adblock-add <domain>` | Dodaj domenę do custom.hosts |
| `adblock-remove <domain>` | Usuń domenę z custom.hosts |
| `adblock-rebuild` | Przebuduj combined.hosts i przeładuj |
| `adblock-query <domain>` | Zapytaj domenę przez lokalny DNS |

## Pliki
```
/etc/coredns/zones/custom.hosts      # Twoje własne blokady
/etc/coredns/zones/blocklist.hosts   # Zewnętrzna blocklist (Hagezi)
/etc/coredns/zones/combined.hosts    # custom + blocklist (używane przez CoreDNS)
```

## Allowlist (whitelist)

| Komenda | Opis |
|---------|------|
| `allowlist-add <domain>` | Dodaj domenę do allowlist |
| `allowlist-remove <domain>` | Usuń domenę z allowlist |
| `allowlist-list` | Pokaż allowlist |

Domeny z allowlist są usuwane z combined.hosts podczas `adblock-rebuild`.

---

# IPv6 MANAGEMENT

## Komendy

| Komenda | Opis |
|---------|------|
| `smart-ipv6` | Smart IPv6 detection & auto-reconfiguration |
| `ipv6-privacy-on` | Włącz IPv6 Privacy Extensions |
| `ipv6-privacy-off` | Wyłącz IPv6 Privacy Extensions |
| `ipv6-privacy-status` | Pokaż status Privacy Extensions |
| `ipv6-privacy-auto` | Auto-ensure IPv6 privacy (detect + fix) |
| `ipv6-deep-reset` | Pełny reset IPv6 (flush + reconnect) |

## IPv6 Privacy Auto

**Cel:** Automatyczne zapewnienie tymczasowych adresów IPv6.

### Działanie
1. Wykryj aktywny interfejs
2. Sprawdź czy istnieje usable temporary address
3. Jeśli nie:
   - Ustaw sysctl `use_tempaddr=2`
   - Reconnect interfejsu (stack-aware)
4. Zweryfikuj wynik

## IPv6 Deep Reset

**Cel:** Pełny reset IPv6 gdy ping nie działa mimo widocznego adresu.

### Działanie
1. Flush IPv6 neighbor cache
2. Flush global IPv6 addresses
3. Reconnect interfejsu (NM/networkd/manual)
4. Czekaj na Router Advertisement
5. Opcjonalnie wyślij Router Solicitation (rdisc6)

### Różnica vs `ipv6-privacy-auto`
- `ipv6-privacy-auto` — tylko zapewnia temporary address
- `ipv6-deep-reset` — pełny reset IPv6 (flush wszystkiego)

---

# FIREWALL MODES

## Tryby

| Tryb | Komenda | Opis |
|------|---------|------|
| **SAFE** | `firewall-safe` | Nie zrywa internetu, podstawowa ochrona |
| **STRICT** | `firewall-strict` | Pełna blokada DNS-leak, wymusza localhost |

## SAFE Mode
- Pozwala na DNS do localhost
- Loguje próby DNS leak
- Nie blokuje ruchu

## STRICT Mode
- Blokuje DNS do wszystkiego poza localhost
- Kill-switch dla DNS
- Wymusza użycie lokalnego resolvera

## Tabele nftables
```
table inet citadel_dns        # Główne reguły DNS
table inet citadel_emergency  # Reguły emergency/killswitch
table inet citadel_debug      # Debug chain (opcjonalny)
```

---

# NARZĘDZIA DODATKOWE

## Terminal Dashboard

```bash
sudo ./cytadela++.sh install-dashboard
citadel-top
```

Real-time dashboard pokazujący:
- Status serwisów
- Prometheus metrics
- DNS resolution
- External IP
- System load

## Editor Integration

```bash
sudo ./cytadela++.sh install-editor
citadel edit           # Edytuj CoreDNS config
citadel edit-dnscrypt  # Edytuj DNSCrypt config
citadel status         # Quick status
citadel logs           # Recent logs
citadel test           # Test DNS
```

## Kernel Priority Optimization

```bash
sudo ./cytadela++.sh optimize-kernel
```

Ustawia wyższy priorytet dla procesów DNS (renice, ionice).

## DoH Parallel Racing

```bash
sudo ./cytadela++.sh install-doh-parallel
```

Tworzy konfigurację DNSCrypt z parallel racing dla szybszych odpowiedzi.

---

# PLIKI KONFIGURACYJNE

## Główne

| Plik | Opis |
|------|------|
| `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` | Konfiguracja DNSCrypt |
| `/etc/coredns/Corefile` | Konfiguracja CoreDNS |
| `/etc/nftables.d/citadel-dns.nft` | Reguły nftables |

## Cytadela state

| Plik | Opis |
|------|------|
| `/etc/cytadela/manifest.sha256` | Integrity manifest |
| `/etc/cytadela/checksums.sha256` | Supply-chain checksums |
| `/etc/cytadela/trusted-ssids.txt` | Zaufane sieci WiFi |
| `/var/lib/cytadela/` | State directory |
| `/var/lib/cytadela/lkg/` | LKG blocklist cache |

## Logi

```bash
journalctl -u dnscrypt-proxy -f    # Logi DNSCrypt
journalctl -u coredns -f           # Logi CoreDNS
journalctl | grep CITADEL          # Logi nftables debug
```

---

# TROUBLESHOOTING

## DNS nie działa

```bash
# 1. Sprawdź status serwisów
sudo ./cytadela++.sh health-status

# 2. Sprawdź czy port 53 jest zajęty
ss -ln | grep :53

# 3. Test lokalnego DNS
dig +short google.com @127.0.0.1

# 4. Sprawdź logi
journalctl -u coredns -n 50

# 5. Panic bypass (ostateczność)
sudo ./cytadela++.sh panic-bypass 60
```

## Port 53 zajęty

```bash
# Sprawdź co zajmuje port
sudo ss -tlnp | grep :53

# Zwykle to systemd-resolved lub avahi
sudo systemctl stop systemd-resolved
sudo systemctl stop avahi-daemon

# Lub użyj fix-ports
sudo ./cytadela++.sh fix-ports
```

## IPv6 nie działa

```bash
# 1. Sprawdź status
sudo ./cytadela++.sh discover

# 2. Deep reset
sudo ./cytadela++.sh ipv6-deep-reset

# 3. Sprawdź Privacy Extensions
sudo ./cytadela++.sh ipv6-privacy-auto
```

## Firewall blokuje za dużo

```bash
# 1. Sprawdź tryb
sudo ./cytadela++.sh location-status

# 2. Przełącz na SAFE
sudo ./cytadela++.sh firewall-safe

# 3. Włącz debug
sudo ./cytadela++.sh nft-debug-on
journalctl -f | grep CITADEL
```

## Przywracanie systemu

```bash
# Pełny rollback do systemd-resolved
sudo ./cytadela++.sh restore-system
```

---

# GLOBAL ERROR TRAP

Cytadela++ ma wbudowany global error trap który pokazuje:
- Funkcję gdzie wystąpił błąd
- Numer linii
- Komendę która zawiodła
- Kod wyjścia

Przykład:
```
✗ ERROR in install_coredns() at line 1234: 'systemctl restart coredns' exited with code 1
```

---

# PODSUMOWANIE KOMEND

## Wszystkie komendy (alfabetycznie)

```
adblock-add           adblock-edit          adblock-query
adblock-rebuild       adblock-remove        adblock-show
adblock-stats         adblock-status        allowlist-add
allowlist-list        allowlist-remove      configure-system
diagnostics           discover              emergency-refuse
emergency-restore     firewall-safe         firewall-strict
fix-ports             ghost-check           health-install
health-status         health-uninstall      install-all
install-coredns       install-dashboard     install-dnscrypt
install-doh-parallel  install-editor        install-nftables
integrity-check       integrity-init        integrity-status
ipv6-deep-reset       ipv6-privacy-auto     ipv6-privacy-off
ipv6-privacy-on       ipv6-privacy-status   killswitch-off
killswitch-on         lkg-restore           lkg-save
lkg-status            lists-update          location-add-trusted
location-check        location-list-trusted location-remove-trusted
location-status       nft-debug-logs        nft-debug-off
nft-debug-on          nft-debug-status      optimize-kernel
panic-bypass          panic-restore         panic-status
restore-system        smart-ipv6            status
supply-chain-init     supply-chain-status   supply-chain-verify
test-all              verify
```

---

# WERSJE

- **v3.0** — Aktualna wersja z wszystkimi modułami
- **Commity sesji 2026-01-25:**
  - `96cce16` — integrity layer
  - `fb17ca9` — trap ERR, discover, ipv6-privacy-auto
  - `e01b935` — LKG, panic-bypass
  - `a91e801` — fix symlink (bypass)
  - `04c556e` — fix symlink (restore)
  - `1c41fdc` — ghost-check, ipv6-deep-reset
  - `ab74d7a` — health watchdog, supply-chain
  - `4b4122a` — location-aware, nft-debug

---

# POMYSŁY NA PRZYSZŁOŚĆ (v3.1+)

## Optymalizacje kodu

### Issue #11: Deduplikacja PL/EN
**Priorytet:** Średni

Wydzielić wspólną logikę do `/opt/cytadela/lib/cytadela-core.sh`:
- Wrappery `cytadela++.sh` i `citadela_en.sh` tylko z tłumaczeniami
- **Zysk:** ~3000 linii mniej do utrzymania

### Issue #12: Modularyzacja (lazy loading)
**Priorytet:** Średni

Podzielić skrypt na moduły:
```
/opt/cytadela/modules/
├── health.sh
├── location.sh
├── ipv6.sh
├── integrity.sh
├── lkg.sh
├── panic.sh
└── nft-debug.sh
```
- Lazy loading — ładuj tylko potrzebne moduły
- **Zysk:** szybsze uruchamianie, łatwiejszy rozwój

---

## Nowe funkcje

### Issue #13: Auto-update blocklist
**Priorytet:** Średni

```bash
auto-update-enable [interval]   # Włącz (daily/weekly)
auto-update-disable             # Wyłącz
auto-update-status              # Status timera
```
- Systemd timer do automatycznej aktualizacji
- Integracja z LKG fallback

### Issue #14: Backup/Restore config
**Priorytet:** Średni

```bash
config-backup [path]    # Eksport do tar.gz
config-restore <path>   # Import z archiwum
```
Pliki: dnscrypt, coredns, nftables, cytadela state

### Issue #15: DNS Cache Stats
**Priorytet:** Niski

```bash
cache-stats           # Statystyki cache
cache-stats --top 20  # Top blocked domains
```
- Hit rate, query count, top blocked

### Issue #16: Desktop Notifications
**Priorytet:** Niski

- Powiadomienia gdy health check fail
- Integracja z `notify-send`
- Opcjonalne (wymaga DE)

### Issue #17: Multi-blocklist support
**Priorytet:** Niski

```bash
blocklist-list              # Dostępne blocklist
blocklist-switch <name>     # Przełącz
```
Dostępne: Hagezi Pro/Light/Ultimate, OISD, Steven Black

### Issue #18: Web Dashboard
**Priorytet:** Niski

- Lokalny dashboard (localhost:9154)
- Status, metrics, blocked domains
- Opcjonalny

---

## Priorytet implementacji

| # | Funkcja | Priorytet | Trudność |
|---|---------|-----------|----------|
| 11 | Deduplikacja PL/EN | ⭐⭐⭐ | Średnia |
| 12 | Modularyzacja | ⭐⭐⭐ | Średnia |
| 13 | Auto-update blocklist | ⭐⭐⭐ | Niska |
| 14 | Backup/Restore | ⭐⭐⭐ | Niska |
| 15 | DNS Cache Stats | ⭐⭐ | Niska |
| 16 | Desktop Notifications | ⭐⭐ | Niska |
| 17 | Multi-blocklist | ⭐⭐ | Średnia |
| 18 | Web Dashboard | ⭐ | Wysoka |

**Rekomendowana kolejność:** #13 → #14 → #11 → #12 → #15 → #17 → #16 → #18

---

*Dokumentacja wygenerowana: 2026-01-25*
*Autor: QguAr71*
*Projekt: https://github.com/QguAr71/Cytadela*
