# Wydanie v3.1.0-STABLE: Aktualizacja Wydajności i Odporności

**Data Wydania:** 2026-02-01
**Status:** Gotowe do Produkcji ✅
**Testowane Na:** CachyOS (Arch Linux)

---

## 📋 Przegląd

To wydanie oznacza główny kamień milowy dla **Cytadela** (dawniej Cytadela). Skupiliśmy się na ekstremalnej optymalizacji wydajności, kuloodpornej ochronie przed wyciekami DNS oraz solidnym systemie odzyskiwania. W pełni zweryfikowane i zoptymalizowane dla CachyOS.

---

## 🚀 Co Nowego w v3.1.0

### ⚡ Optymalizacja Wydajności
- **76,323 QPS utrzymana przepustowość** z średnim opóźnieniem poniżej 1.5ms
- Benchmark pojedynczego węzła localhost używając dnsperf v2.14.0 (30s utrzymane obciążenie, rotacja 20 domen)
- Zoptymalizowana konfiguracja CoreDNS i DNSCrypt-Proxy
- 99.99% współczynnik trafień cache dla często odwiedzanych domen
- 0% strat pakietów pod utrzymywanym obciążeniem
- Minimalne opóźnienie: 0.01ms dla trafień cache
- **Szczegółowy benchmark:** [TESTING-RESULTS-2026-02-01.md](docs/TESTING-RESULTS-2026-02-01.md)

### 🛡️ Ścisła Ochrona Firewall
- Ulepszony zestaw reguł nftables z obowiązkowym przekierowaniem do lokalnego stosu DNS
- **Cały wychodzący ruch :53 jest siłowo przekierowany do lokalnego resolvera**
- **Zero wycieków DNS** - wszystkie zewnętrzne zapytania DNS blokowane (IPv4 + IPv6)
- Ograniczenie szybkości: 10 zapytań/sekundę z burst 5 pakietów
- Kompleksowe logowanie: prefiks "CITADEL DNS LEAK" do monitorowania
- `table inet` obsługuje zarówno IPv4 jak i IPv6 jednocześnie

### 🔄 System Samonaprawiający się
- Nowy system watchdog zapewnia odzyskiwanie usług w **mniej niż 30 sekund** po awarii
- Automatyczny restart usług dnscrypt-proxy i coredns
- Integracja z systemd z `Restart=always` i `RestartSec=5s`
- Zweryfikowane odzyskiwanie po awarii z testami manualnego kill

### 💾 Bezpieczeństwo Operacyjne
- **Automatyczna kopia zapasowa przed instalacją** oryginalnej konfiguracji DNS
- Lokalizacja backup: `/var/lib/cytadela/backups/`
- Nowe polecenie `restore-system-default` do resetu fabrycznego
- Kompletny cykl backup/restore zweryfikowany i działający
- Bezpieczny rollback do systemd-resolved jeśli potrzebne

### 🏎️ Parallel Racing
- Włączone DoH parallel racing dla szybszych czasów odpowiedzi
- Wielu dostawców upstream testowanych jednocześnie
- Automatyczny wybór najszybciej odpowiadającego serwera
- Przetestowane Cloudflare (69ms), Google (77ms), Quad9 (92ms)

### 🔒 Walidacja DNSSEC
- Pełna walidacja DNSSEC z flagą Authenticated Data (AD)
- Nieprawidłowe podpisy prawidłowo odrzucane (SERVFAIL)
- Ochrona przed spoofingiem DNS i atakami MITM
- Zweryfikowane z cloudflare-dns.com (flaga AD obecna)
- Przetestowane z dnssec-failed.org (prawidłowo zablokowane)

### 🚫 Ulepszone Blokowanie Reklam/Malware
- **325,979 zablokowanych domen** (listy blokowania OISD + StevenBlack)
- Automatyczne aktualizacje listy blokowania
- Znane domeny tracking zablokowane (np. doubleclick.net → 0.0.0.0)
- Blokowanie reklam na poziomie DNS dla wszystkich urządzeń w sieci

### 🌐 Obsługa IPv6 Dual-Stack
- Pełna ochrona przed wyciekami DNS IPv6
- IPv6 localhost (::1) dozwolony dla usług lokalnych
- Wszystkie zewnętrzne zapytania DNS IPv6 blokowane
- Brak możliwego ominięcia IPv6

---

## 📊 Wyniki Walidacji (7/7 Testów PASSED)

Wszystkie testy wykonane na CachyOS (Arch Linux) z trybem STRICT firewall i włączonym adblock.

| Test | Status | Wynik |
|------|--------|-------|
| **Ochrona przed wyciekami DNS** | ✅ PASSED | Tryb STRICT blokuje wszystkie próby ominięcia (IPv4) |
| **Odzyskiwanie po awarii** | ✅ PASSED | Auto-restart funkcjonalny (~29s czas odzyskiwania) |
| **Backup/Restore** | ✅ PASSED | Pełny cykl działa bezbłędnie |
| **Walidacja DNSSEC** | ✅ PASSED | Flaga AD zweryfikowana, nieprawidłowe podpisy zablokowane |
| **IPv6 Dual-Stack** | ✅ PASSED | Ochrona przed wyciekami DNS IPv6 działa |
| **Blokowanie Malware** | ✅ PASSED | 325,979 domen zablokowanych (OISD/StevenBlack) |
| **Benchmark Wydajności** | ✅ PASSED | 76,323 QPS, 1.29ms średnie opóźnienie, 0% strat pakietów |

**Środowisko testowe:** CachyOS (jądro Linux 6.12.1, systemd 257.2)
**Szczegółowe wyniki testów:** [TESTING-RESULTS-2026-02-01.md](docs/TESTING-RESULTS-2026-02-01.md)

---

## 🔧 Ulepszenia Techniczne

### Optymalizacja CoreDNS
- Zoptymalizowane ustawienia cache (TTL 30s)
- Efektywne przetwarzanie plików hosts
- Metryki Prometheus na 127.0.0.1:9153
- GOMAXPROCS=12 (pełne wykorzystanie CPU)

### Ulepszenia DNSCrypt-Proxy
- `require_dnssec = true` dla walidacji DNSSEC
- Włączone parallel DoH racing
- Automatyczny wybór serwera bazowany na opóźnieniu
- Nasłuch na 127.0.0.1:5356

### Firewall NFTables
- `table inet citadel_dns` dla IPv4+IPv6
- Ścisłe reguły DROP dla zewnętrznego DNS (porty 53, 853)
- Ograniczenie szybkości z logowaniem
- Tabela awaryjnego bypass dla rozwiązywania problemów

### Integracja z Systemd
- Automatyczny restart usług przy niepowodzeniu
- Właściwe uporządkowanie zależności
- Łagodne wyłączanie (SIGTERM)
- Monitorowanie statusu usług

---

## 📚 Nowa Dokumentacja

### Dodane Pliki
- `ACKNOWLEDGMENTS.md` - Podziękowania dla wszystkich upstream projektów open-source
- `docs/TESTING-RESULTS-2026-02-01.md` - Kompletne wyniki testów (v4.0)
- `docs/INSTALLATION-SIMPLIFICATION-V3.2.md` - Plan auto-konfiguracji dla v3.2
- `docs/v3.2-fixes/RFC1035-WARNING-FIX.md` - Naprawa ostrzeżenia CoreDNS dla v3.2

### Zaktualizowana Dokumentacja
- `README.md` - Dodano configure-system do Quick Start, link do ACKNOWLEDGMENTS
- `docs/user/quick-start.md` - Dodano Krok 4: Configure System (Krytyczny!)
- `docs/user/MANUAL_PL.md` - Dodano dokumentację restore-system-default
- `docs/user/MANUAL_EN.md` - Dodano dokumentację restore-system-default
- `docs/user/commands.md` - Dodano polecenie restore-system-default
- `docs/user/FAQ.md` - Dodano wpis FAQ restore-system-default
- `CHANGELOG.md` - Zaktualizowano przyszłe branding do Weles-SysQ (v3.2)

---

## 🎯 Instalacja

### Szybki Start
```bash
# Klonuj repozytorium
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# Sprawdź zależności
sudo ./citadel.sh check-deps

# Zainstaluj z interaktywnym kreatorem (zalecane)
sudo ./citadel.sh install-wizard

# Skonfiguruj system (przełącz z systemd-resolved na Cytadel)
sudo ./citadel.sh configure-system

# Zweryfikuj instalację
sudo ./citadel.sh verify
```

### Obsługa Języków
- 🇵🇱 Polish (Polski) - Pełna dokumentacja
- 🇬🇧 English - Pełna dokumentacja
- 🇩🇪 German (Deutsch) - Tylko kreator
- 🇪🇸 Spanish (Español) - Tylko kreator
- 🇮🇹 Italian (Italiano) - Tylko kreator
- 🇫🇷 French (Français) - Tylko kreator
- 🇷🇺 Russian (Русский) - Tylko kreator

> **Uwaga:** Pełne i18n dla wszystkich języków planowane dla v3.2 (wydanie Weles-SysQ)

---

## 🔄 Aktualizacja z v3.0

```bash
# Backup aktualnej konfiguracji
sudo ./citadel.sh backup-config

# Pobierz najnowsze zmiany
git pull origin main

# Przeinstaluj komponenty (zachowuje konfigurację)
sudo ./citadel.sh install-all

# Zweryfikuj aktualizację
sudo ./citadel.sh verify
sudo ./citadel.sh status
```

---

## 🆕 Nowe Polecenia

### `restore-system-default`
Reset fabryczny do domyślnej konfiguracji systemd-resolved.

```bash
sudo ./citadel.sh restore-system-default
```

**Przypadki użycia:**
- Kompletna deinstalacja Cytadela
- Przywracanie ustawień DNS fabrycznych
- Rozwiązywanie problemów z DNS
- Bezpieczna opcja fallback

**Co robi:**
- Przywraca fabryczną konfigurację systemd-resolved
- Odblokowuje i włącza systemd-resolved
- Usuwa konfigurację DNS NetworkManager
- Łączy /etc/resolv.conf ze stub systemd-resolved

---

## 🐛 Poprawki Błędów

### Naprawione Problemy
- **Poprawka ścieżki backup:** Zmieniono `/var/lib/cytadela/backup/` na `/var/lib/cytadela/backups/` dla spójności
- **Wykrywanie WiFi:** Dodano obsługę lokalizacji włoskiej (`sì`) do wykrywania lokalizacji
- **Jasność dokumentacji:** Poprawiono wprowadzającą w błąd informację o obsłudze języków (PL/EN pełna dokumentacja, 5 języków tylko kreator)

### Znane Problemy
- **Ostrzeżenie CoreDNS RFC1035:** Kosmetyczne ostrzeżenie o formacie nazwy domeny (naprawa planowana dla v3.2)
  - Nie wpływa na funkcjonalność
  - Metryki Prometheus działają prawidłowo
  - Zobacz: `docs/v3.2-fixes/RFC1035-WARNING-FIX.md`

---

## 🔮 Przyszłe Plany (v3.2 - Weles-SysQ)

### Rebranding Projektu
- Nowa nazwa: **Weles-SysQ** (Słowiański bóg magii, przysiąg i strażnik bogactwa)
- Uzasadnienie: DNS jako strażnik/broniący bramki internetowej
- Unikalna mitologia słowiańska (korzenie polskie)
- Brak konfliktów z istniejącym oprogramowaniem DNS

### Planowane Funkcje
- **Instalacja auto-konfiguracji** (4 kroki → 2 kroki)
- **Zunifikowana architektura modułów** (29 modułów → 6 modułów, -79% złożoności)
- **Tryb silent DROP firewall** (tryb stealth, brak odpowiedzi ICMP)
- **Pełne wsparcie i18n** dla wszystkich 7 języków (CLI, moduły, dokumentacja)
- **Naprawa CoreDNS RFC1035** (przeniesienie prometheus do głównego bloku DNS)
- **Funkcje Bash 5.0+** (tablice asocjacyjne, flaga --silent)

Zobacz: `docs/REFACTORING-V3.2-PLAN.md` i `docs/INSTALLATION-SIMPLIFICATION-V3.2.md`

---

## 🙏 Podziękowania

Cytadela jest zbudowana na bazie wyjątkowych projektów open-source:

- **DNSCrypt-Proxy** - Fundament szyfrowanego DNS
- **CoreDNS** - Serwer DNS wysokiej wydajności
- **NFTables** - Nowoczesne filtrowanie pakietów
- **Prometheus** - Monitorowanie i metryki
- **StevenBlack i OISD** - Kompleksowe listy blokowania
- **CachyOS i Arch Linux** - Fundament dystrybucji
- **Społeczność Open Source** - Inspiracja i wsparcie

Aby uzyskać szczegółowe podziękowania i jak wspierać te projekty, zobacz [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

---

## 📊 Metryki Wydajności

### Wyniki Benchmark (test dnsperf 30s)
- **Wysłane zapytania:** 2,289,780
- **Ukończone zapytania:** 2,289,780 (100%)
- **Utracone zapytania:** 0 (0%)
- **QPS:** 76,323 zapytań/sekundę
- **Średnie opóźnienie:** 1.29ms
- **Min opóźnienie:** 0.01ms (trafienia cache)
- **Maks opóźnienie:** 202ms (chybienia cache)
- **Współczynnik sukcesu:** 100% NOERROR

### Zasoby Systemowe
- **Wykorzystanie CPU:** GOMAXPROCS=12 (pełne wykorzystanie rdzeni)
- **Pamięć:** Efektywne (brak wykrytych wycieków pamięci)
- **Współczynnik trafień cache:** 99.99%
- **Straty pakietów:** 0%

---

## 🔒 Funkcje Bezpieczeństwa

- ✅ Szyfrowanie DNS (DoH/DoT poprzez DNSCrypt-Proxy)
- ✅ Walidacja DNSSEC z flagą Authenticated Data
- ✅ Ochrona przed wyciekami DNS (ścisły firewall, IPv4 + IPv6)
- ✅ Automatyczne odzyskiwanie po awarii
- ✅ Kompletna funkcjonalność backup/restore
- ✅ Blokowanie reklam/malware (325K+ domen)
- ✅ Ograniczenie szybkości i logowanie
- ✅ Opcja resetu fabrycznego

---

## 📞 Wsparcie

- **Dokumentacja:** [docs/](docs/)
- **Problemy:** [GitHub Issues](https://github.com/QguAr71/Cytadela/issues)
- **Dyskusje:** [GitHub Discussions](https://github.com/QguAr71/Cytadela/discussions)
- **Wyniki Testów:** [TESTING-RESULTS-2026-02-01.md](docs/TESTING-RESULTS-2026-02-01.md)

---

## 📜 Licencja

Ten projekt jest licencjonowany na **GNU General Public License v3.0** - zobacz plik [LICENSE](LICENSE) dla szczegółów.

---

## 🎉 Współtwórcy

Specjalne podziękowania dla:
- **QguAr71** - Twórca i opiekun projektu
- **Społeczność CachyOS** - Testowanie i opinie
- **Społeczność Open Source** - Projekty upstream i inspiracja

---

**Status:** Gotowe do Produkcji ✅
**Przetestowane:** 7/7 Testów PASSED
**Wydajność:** 76K QPS, 1.29ms opóźnienie, 0% strat
**Bezpieczeństwo:** DNSSEC zweryfikowane, wycieki DNS chronione, 325K domen zablokowanych

**Cytadela v3.1.0 - Twój Strażnik DNS** 🛡️
