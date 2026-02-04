# Podręcznik Użytkownika Citadel v3.2 (Polski)

**Wersja:** 3.2.0
**Ostatnia Aktualizacja:** 2026-02-04
**Kompatybilność:** Bash 4.x/5.x, Linux (Arch, Ubuntu, Fedora)

---

## Spis Treści

1. [Wprowadzenie](#wprowadzenie)
2. [Szybki Start](#szybki-start)
3. [Ujednolicony Interfejs Komend](#ujednolicony-interfejs-komend)
4. [Odzyskiwanie i Awaryjne](#odzyskiwanie-i-awaryjne)
5. [Instalacja i Konfiguracja](#instalacja-i-konfiguracja)
6. [Bezpieczeństwo i Monitorowanie](#bezpieczeństwo-i-monitorowanie)
7. [Konfiguracja Sieci](#konfiguracja-sieci)
8. [Blokowanie Reklam](#blokowanie-reklam)
9. [Kopia Zapasowa i Przywracanie](#kopia-zapasowa-i-przywracanie)
10. [Monitorowanie i Diagnostyka](#monitorowanie-i-diagnostyka)
11. [Rozwiązywanie Problemów](#rozwiązywanie-problemów)
12. [Przewodnik Migracji](#przewodnik-migracji)

---

## Wprowadzenie

Citadel to kompleksowy system ochrony sieci oparty na DNS, oferujący szyfrowany DNS (DNSCrypt), blokowanie reklam, reguły firewalla oraz zaawansowane możliwości monitorowania.

### Co Nowego w v3.2

**Ujednolicona Architektura:** Wszystkie funkcje skonsolidowane w 7 specjalistycznych modułach:
- `unified-recovery.sh` - Awaryjne odzyskiwanie i przywracanie systemu
- `unified-install.sh` - Kompletny system instalacyjny
- `unified-security.sh` - Monitorowanie bezpieczeństwa i integralności
- `unified-network.sh` - Narzędzia konfiguracji sieci
- `unified-adblock.sh` - Blokowanie reklam i białe listy
- `unified-backup.sh` - Funkcje kopii zapasowej i auto-aktualizacji
- `unified-monitor.sh` - Monitorowanie, diagnostyka i benchmarking

**Kompatybilność Wsteczna:** Wszystkie stare komendy nadal działają bez zmian.

**Inteligentne Ładowanie Modułów:** Moduły ładują się na żądanie z weryfikacją integralności.

---

## Szybki Start

### Podstawowa Instalacja
```bash
# Pobierz i zainstaluj
git clone https://github.com/your-org/cytadela.git
cd cytadela

# Uruchom kompletną instalację
sudo ./citadel.sh install all

# Skonfiguruj systemowy DNS
sudo ./citadel.sh install configure-system
```

### Pierwsze Użycie
```bash
# Sprawdź status systemu
sudo ./citadel.sh monitor status

# Uruchom diagnostykę
sudo ./citadel.sh monitor diagnostics

# Wyświetl dashboard
sudo citadel-top
```

---

## Ujednolicony Interfejs Komend

Citadel v3.2 używa ujednoliconej struktury komend:

```
citadel <moduł> <akcja> [parametry]
```

### Dostępne Moduły

| Moduł | Cel | Przykładowe Komendy |
|-------|-----|---------------------|
| `recovery` | Awaryjne odzyskiwanie | `panic-status`, `emergency-network-restore` |
| `install` | Instalacja i konfiguracja | `dnscrypt`, `coredns`, `all`, `configure-system` |
| `security` | Monitorowanie bezpieczeństwa | `integrity-check`, `location-check`, `ghost-check` |
| `network` | Narzędzia sieciowe | `ipv6-privacy-on`, `edit`, `logs`, `fix-ports` |
| `adblock` | Blokowanie reklam | `status`, `add`, `blocklist-switch`, `allowlist-add` |
| `backup` | Kopia zapasowa i auto-aktualizacja | `config-backup`, `lkg-status`, `auto-update-enable` |
| `monitor` | Monitorowanie i diagnostyka | `diagnostics`, `cache-stats`, `benchmark-dns` |

### Stare Komendy (Nadal Wspierane)

Wszystkie komendy v3.1 nadal działają:
- `panic-bypass` → `citadel recovery panic-bypass`
- `install-all` → `citadel install all`
- `adblock-status` → `citadel adblock status`

---

## Odzyskiwanie i Awaryjne

### Tryb Paniki
Tymczasowo wyłącz ochronę DNS do rozwiązywania problemów:

```bash
# Wejdź w tryb paniki (5-minutowy auto-rollback)
sudo ./citadel.sh recovery panic-bypass

# Sprawdź status paniki
sudo ./citadel.sh recovery panic-status

# Przywróć ochronę
sudo ./citadel.sh recovery panic-restore
```

### Awaryjne Przywracanie Sieci
Przywróć połączenie internetowe gdy DNS jest uszkodzone:

```bash
# Kompletne odzyskiwanie sieci
sudo ./citadel.sh recovery emergency-network-restore

# Szybka naprawa DNS
sudo ./citadel.sh recovery emergency-network-fix
```

### Przywracanie Systemu
Przywróć konfigurację systemu z kopii zapasowej:

```bash
# Przywróć z kopii zapasowej
sudo ./citadel.sh recovery restore-system

# Przywróć do ustawień fabrycznych
sudo ./citadel.sh recovery restore-system-default
```

---

## Instalacja i Konfiguracja

### Kompletna Instalacja
```bash
# Zainstaluj wszystko
sudo ./citadel.sh install all

# Zainstaluj poszczególne komponenty
sudo ./citadel.sh install dnscrypt
sudo ./citadel.sh install coredns
sudo ./citadel.sh install nftables
sudo ./citadel.sh install dashboard
```

### Konfiguracja Systemu
```bash
# Skonfiguruj system aby używał DNS Cytadeli
sudo ./citadel.sh install configure-system

# Ustaw tryb firewalla
sudo ./citadel.sh install firewall-safe    # Zezwól na zewnętrzny DNS
sudo ./citadel.sh install firewall-strict  # Blokuj zewnętrzny DNS
```

### Zależności
```bash
# Sprawdź i zainstaluj brakujące zależności
sudo ./citadel.sh install check-deps

# Interaktywny kreator instalacji
sudo ./citadel.sh install wizard
```

---

## Bezpieczeństwo i Monitorowanie

### Weryfikacja Integralności
```bash
# Zainicjuj sprawdzanie integralności
sudo ./citadel.sh security integrity-init

# Zweryfikuj integralność plików
sudo ./citadel.sh security integrity-check

# Pokaż status integralności
sudo ./citadel.sh security integrity-status
```

### Bezpieczeństwo Lokalizacyjne
```bash
# Sprawdź bezpieczeństwo obecnej sieci
sudo ./citadel.sh security location-check

# Zarządzaj zaufanymi sieciami
sudo ./citadel.sh security location-add-trusted "MojaSiećDomowa"
sudo ./citadel.sh security location-remove-trusted "PublicznaSieć"
sudo ./citadel.sh security location-list-trusted
```

### Bezpieczeństwo Łańcucha Dostaw
```bash
# Zainicjuj weryfikację łańcucha dostaw
sudo ./citadel.sh security supply-chain-init

# Zweryfikuj źródła i binaria
sudo ./citadel.sh security supply-chain-verify

# Pokaż status łańcucha dostaw
sudo ./citadel.sh security supply-chain-status
```

### Audyt Bezpieczeństwa
```bash
# Sprawdź otwarte porty i podejrzane procesy
sudo ./citadel.sh security ghost-check

# Debuguj reguły firewalla
sudo ./citadel.sh security nft-debug-on
sudo ./citadel.sh security nft-debug-status
sudo ./citadel.sh security nft-debug-logs
```

---

## Konfiguracja Sieci

### Rozszerzenia Prywatności IPv6
```bash
# Włącz prywatność IPv6
sudo ./citadel.sh network ipv6-privacy-on

# Wyłącz prywatność IPv6
sudo ./citadel.sh network ipv6-privacy-off

# Auto-konfiguracja prywatności IPv6
sudo ./citadel.sh network ipv6-privacy-auto

# Sprawdź status prywatności IPv6
sudo ./citadel.sh network ipv6-privacy-status
```

### Edycja Konfiguracji
```bash
# Edytuj konfigurację CoreDNS
sudo ./citadel.sh network edit

# Edytuj konfigurację DNSCrypt
sudo ./citadel.sh network edit-dnscrypt

# Wyświetl logi systemowe
sudo ./citadel.sh network logs            # Pokaż ostatnie logi
sudo ./citadel.sh network logs 50          # Pokaż ostatnie 50 linii
sudo ./citadel.sh network logs coredns     # Pokaż logi CoreDNS
sudo ./citadel.sh network logs dnscrypt    # Pokaż logi DNSCrypt
```

### Zarządzanie Portami
```bash
# Sprawdź konflikty portów
sudo ./citadel.sh network fix-ports
```

### Powiadomienia
```bash
# Włącz powiadomienia desktopowe
sudo ./citadel.sh network notify-enable

# Wyłącz powiadomienia
sudo ./citadel.sh network notify-disable

# Sprawdź status powiadomień
sudo ./citadel.sh network notify-status

# Przetestuj powiadomienia
sudo ./citadel.sh network notify-test
```

---

## Blokowanie Reklam

### Status i Statystyki
```bash
# Pokaż status blokowania reklam
sudo ./citadel.sh adblock status

# Pokaż statystyki
sudo ./citadel.sh adblock stats

# Pokaż zawartość list blokowania
sudo ./citadel.sh adblock show blocklist   # Pokaż zablokowane domeny
sudo ./citadel.sh adblock show custom      # Pokaż własne blokady
sudo ./citadel.sh adblock show combined    # Pokaż wszystkie blokady
```

### Zarządzanie Domenami
```bash
# Dodaj domenę do listy blokowania
sudo ./citadel.sh adblock add reklamy.przyklad.com

# Usuń domenę z listy blokowania
sudo ./citadel.sh adblock remove reklamy.przyklad.com

# Edytuj własną listę blokowania
sudo ./citadel.sh adblock edit
```

### Zarządzanie Białą Listą
```bash
# Pokaż białą listę
sudo ./citadel.sh adblock allowlist-list

# Dodaj do białej listy (obejdź blokowanie)
sudo ./citadel.sh adblock allowlist-add zaufana.przyklad.com

# Usuń z białej listy
sudo ./citadel.sh adblock allowlist-remove zaufana.przyklad.com
```

### Profile List Blokowania
```bash
# Wyświetl dostępne profile
sudo ./citadel.sh adblock blocklist-list

# Przełącz profil
sudo ./citadel.sh adblock blocklist-switch balanced

# Pokaż status obecnego profilu
sudo ./citadel.sh adblock blocklist-status

# Dodaj własny URL listy blokowania
sudo ./citadel.sh adblock blocklist-add-url "https://przyklad.com/lista-blokowania.txt"
```

---

## Kopia Zapasowa i Przywracanie

### Kopia Zapasowa Konfiguracji
```bash
# Utwórz kopię zapasową
sudo ./citadel.sh backup config-backup

# Wyświetl dostępne kopie zapasowe
sudo ./citadel.sh backup config-list

# Przywróć z kopii zapasowej
sudo ./citadel.sh backup config-restore /sciezka/do/kopii.tar.gz

# Usuń kopię zapasową
sudo ./citadel.sh backup config-delete /sciezka/do/kopii.tar.gz
```

### Last Known Good (LKG)
```bash
# Zapisz obecną listę blokowania jako LKG
sudo ./citadel.sh backup lkg-save

# Przywróć z pamięci podręcznej LKG
sudo ./citadel.sh backup lkg-restore

# Pokaż status LKG
sudo ./citadel.sh backup lkg-status
```

### Auto-Aktualizacja
```bash
# Włącz automatyczne aktualizacje list blokowania
sudo ./citadel.sh backup auto-update-enable

# Wyłącz auto-aktualizacje
sudo ./citadel.sh backup auto-update-disable

# Sprawdź status auto-aktualizacji
sudo ./citadel.sh backup auto-update-status

# Skonfiguruj harmonogram aktualizacji
sudo ./citadel.sh backup auto-update-configure

# Ręczna aktualizacja teraz
sudo ./citadel.sh backup auto-update-now
```

### Aktualizacje List Blokowania
```bash
# Zaktualizuj listy blokowania z fallbackiem LKG
sudo ./citadel.sh backup lists-update
```

---

## Monitorowanie i Diagnostyka

### Status Systemu
```bash
# Pokaż kompleksowy status
sudo ./citadel.sh monitor status

# Uruchom pełną diagnostykę
sudo ./citadel.sh monitor diagnostics

# Zweryfikuj konfigurację
sudo ./citadel.sh monitor verify

# Uruchom wszystkie testy
sudo ./citadel.sh monitor test-all
```

### Statystyki Pamięci Podręcznej
```bash
# Pokaż wydajność pamięci podręcznej
sudo ./citadel.sh monitor cache-stats

# Pokaż top domeny
sudo ./citadel.sh monitor cache-top

# Resetuj statystyki pamięci podręcznej
sudo ./citadel.sh monitor cache-reset

# Obserwuj statystyki pamięci podręcznej na żywo
sudo ./citadel.sh monitor cache-watch
```

### Monitorowanie Zdrowia
```bash
# Sprawdź zdrowie systemu
sudo ./citadel.sh monitor health-status

# Zainstaluj strażnika zdrowia
sudo ./citadel.sh monitor health-watchdog-install

# Odinstaluj strażnika zdrowia
sudo ./citadel.sh monitor health-watchdog-uninstall
```

### Metryki Prometheus
```bash
# Eksportuj metryki dla Prometheus
sudo ./citadel.sh monitor prometheus-export

# Uruchom serwer metryk
sudo ./citadel.sh monitor prometheus-serve

# Pokaż status metryk
sudo ./citadel.sh monitor prometheus-status
```

### Benchmarki Wydajności
```bash
# Uruchom benchmark wydajności DNS
sudo ./citadel.sh monitor benchmark-dns

# Uruchom wszystkie benchmarki
sudo ./citadel.sh monitor benchmark-all

# Pokaż raporty benchmarków
sudo ./citadel.sh monitor benchmark-report

# Porównaj wyniki benchmarków
sudo ./citadel.sh monitor benchmark-compare
```

### Weryfikacja Konfiguracji
```bash
# Sprawdź pliki konfiguracyjne
sudo ./citadel.sh monitor verify-config

# Przetestuj funkcjonalność DNS
sudo ./citadel.sh monitor verify-dns

# Zweryfikuj serwisy
sudo ./citadel.sh monitor verify-services

# Zweryfikuj pliki
sudo ./citadel.sh monitor verify-files
```

---

## Rozwiązywanie Problemów

### Częste Problemy

#### DNS Nie Działa
```bash
# Sprawdź rozwiązywanie DNS
sudo ./citadel.sh monitor verify-dns

# Awaryjne przywracanie sieci
sudo ./citadel.sh recovery emergency-network-restore

# Sprawdź reguły firewalla
sudo ./citadel.sh monitor verify
```

#### Serwisy Nie Uruchamiają Się
```bash
# Sprawdź status serwisów
sudo ./citadel.sh monitor status

# Wyświetl logi serwisów
sudo ./citadel.sh network logs coredns
sudo ./citadel.sh network logs dnscrypt

# Restartuj serwisy
sudo systemctl restart coredns dnscrypt-proxy
```

#### Blokowanie Reklam Nie Działa
```bash
# Sprawdź status blokowania reklam
sudo ./citadel.sh adblock status

# Przebuduj listę blokowania
sudo ./citadel.sh backup lists-update

# Sprawdź białą listę
sudo ./citadel.sh adblock allowlist-list
```

#### Problemy z Firewallem
```bash
# Sprawdź status firewalla
sudo ./citadel.sh monitor verify

# Ustaw tryb bezpieczny tymczasowo
sudo ./citadel.sh install firewall-safe

# Resetuj do trybu ścisłego
sudo ./citadel.sh install firewall-strict
```

### Uzyskiwanie Pomocy

#### Wbudowana Pomoc
```bash
# Ogólna pomoc
./citadel.sh help

# Pomoc specyficzna dla modułu
./citadel.sh install help
./citadel.sh adblock help
./citadel.sh monitor help
```

#### Logi i Debugowanie
```bash
# Logi systemowe
sudo ./citadel.sh network logs

# Logi specyficzne dla serwisów
sudo journalctl -u coredns -f
sudo journalctl -u dnscrypt-proxy -f

# Tryb debugowania (jeśli dostępny)
export CYTADELA_MODE=developer
```

---

## Przewodnik Migracji

### Z v3.1 do v3.2

Citadel v3.2 zachowuje **100% kompatybilności wstecznej**. Wszystkie istniejące komendy i konfiguracje nadal działają bez zmian.

#### Co Się Zmieniło
- **Architektura:** 29 modułów skonsolidowanych do 7 ujednoliconych modułów
- **Komendy:** Dostępna nowa ujednolicona struktura komend
- **Wydajność:** Ulepszone ładowanie i zmniejszone zużycie pamięci
- **Bezpieczeństwo:** Ulepszone sprawdzanie integralności i weryfikacja łańcucha dostaw

#### Co Jest Nowego
- **Ujednolicone Komendy:** Składnia `citadel <moduł> <akcja>`
- **Inteligentne Ładowanie:** Moduły ładują się na żądanie
- **Ulepszone Monitorowanie:** Metryki Prometheus, sprawdzanie zdrowia, benchmarki
- **Prywatność IPv6:** Automatyczne zarządzanie adresami prywatnymi
- **Bezpieczeństwo Lokalizacyjne:** Polityki bezpieczeństwa oparte na sieciach WiFi

#### Kroki Migracji
1. **Aktualizacja:** Pobierz najnowszy kod z repozytorium
2. **Kopia Zapasowa:** Utwórz kopię zapasową konfiguracji (zalecane)
3. **Testowanie:** Uruchom diagnostykę aby sprawdzić czy wszystko działa
4. **Opcjonalne:** Zacznij używać nowych ujednoliconych komend

#### Wsparcie Starych Komend
Wszystkie komendy v3.1 nadal działają:
```bash
# Stare komendy (nadal działają)
sudo ./citadel.sh install-all
sudo ./citadel.sh adblock-status
sudo ./citadel.sh panic-bypass

# Nowe ujednolicone komendy (zalecane)
sudo ./citadel.sh install all
sudo ./citadel.sh adblock status
sudo ./citadel.sh recovery panic-bypass
```

### Wsparcie
- **Dokumentacja:** Ten podręcznik i REFACTORING-V3.2-ROADMAP.md
- **Problemy:** Issues na GitHub z etykietą `unified-modules`
- **Społeczność:** Dyskusje projektu i wiki

---

**Citadel v3.2 - Ujednolicona Architektura dla Ulepszonego Bezpieczeństwa i Wydajności**
