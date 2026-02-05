# Podręcznik użytkownika Citadel v3.2 (Polski)

**Wersja:** 3.2.0
**Ostatnia aktualizacja:** 2026-02-04
**Kompatybilność:** Bash 4.x/5.x, Linux (Arch, Ubuntu, Fedora)

---

## Spis treści

1. [Wprowadzenie](#wprowadzenie)
2. [Szybki start](#szybki-start)
3. [Ujednolicony interfejs komend](#ujednolicony-interfejs-komend)
4. [Odzyskiwanie i sytuacje awaryjne](#odzyskiwanie-i-sytuacje-awaryjne)
5. [Instalacja i konfiguracja](#instalacja-i-konfiguracja)
6. [Bezpieczeństwo i monitorowanie](#bezpieczeństwo-i-monitorowanie)
7. [Konfiguracja sieci](#konfiguracja-sieci)
8. [Blokowanie reklam](#blokowanie-reklam)
9. [Kopia zapasowa i przywracanie](#kopia-zapasowa-i-przywracanie)
10. [Monitorowanie i diagnostyka](#monitorowanie-i-diagnostyka)
11. [Rozwiązywanie problemów](#rozwiązywanie-problemów)
12. [Przewodnik migracji](#przewodnik-migracji)

---

## Wprowadzenie

Citadel to kompleksowy system ochrony sieci oparty na DNS, oferujący szyfrowany DNS (DNSCrypt), blokowanie reklam, reguły firewall oraz zaawansowane możliwości monitorowania.

### Co nowego w v3.2

**Ujednolicona architektura:** Cała funkcjonalność skonsolidowana w 7 specjalizowanych modułach:
- `unified-recovery.sh` - Awaryjne odzyskiwanie i przywracanie systemu
- `unified-install.sh` - Kompletny system instalacyjny
- `unified-security.sh` - Monitorowanie bezpieczeństwa i integralności
- `unified-network.sh` - Narzędzia konfiguracji sieci
- `unified-adblock.sh` - Blokowanie reklam i białe listy
- `unified-backup.sh` - Kopie zapasowe i automatyczne aktualizacje
- `unified-monitor.sh` - Monitorowanie, diagnostyka i benchmarki

**Kompatybilność wsteczna:** Wszystkie starsze komendy nadal działają bez zmian.

**Inteligentne ładowanie modułów:** Moduły ładują się na żądanie z weryfikacją integralności.

---

## Szybki start

### Podstawowa instalacja
```bash
# Pobierz i zainstaluj
git clone https://github.com/your-org/cytadela.git
cd cytadela

# Uruchom kompletną instalację
sudo ./citadel.sh install all

# Skonfiguruj systemowy DNS
sudo ./citadel.sh install configure-system
```

### Pierwsze użycie
```bash
# Sprawdź status systemu
sudo ./citadel.sh monitor status

# Uruchom diagnostykę
sudo ./citadel.sh monitor diagnostics

# Wyświetl dashboard
sudo citadel-top
```

---

## Ujednolicony interfejs komend

Citadel v3.2 używa ujednoliconej struktury komend:

```
citadel <moduł> <akcja> [parametry]
```

### Dostępne moduły

| Moduł | Przeznaczenie | Przykładowe komendy |
|--------|---------------|---------------------|
| `recovery` | Awaryjne odzyskiwanie | `panic-status`, `emergency-network-restore` |
| `install` | Instalacja i konfiguracja | `dnscrypt`, `coredns`, `all`, `configure-system` |
| `security` | Monitorowanie bezpieczeństwa | `integrity-check`, `location-check`, `ghost-check` |
| `network` | Narzędzia sieciowe | `ipv6-privacy-on`, `edit`, `logs`, `fix-ports` |
| `adblock` | Blokowanie reklam | `status`, `add`, `blocklist-switch`, `allowlist-add` |
| `backup` | Kopie zapasowe i auto-aktualizacje | `config-backup`, `lkg-status`, `auto-update-enable` |
| `monitor` | Monitorowanie i diagnostyka | `diagnostics`, `cache-stats`, `benchmark-dns` |

### Starsze komendy (nadal wspierane)

Wszystkie komendy v3.1 nadal działają:
- `panic-bypass` → `citadel recovery panic-bypass`
- `install-all` → `citadel install all`
- `adblock-status` → `citadel adblock status`

---

## Odzyskiwanie i sytuacje awaryjne

### Tryb paniki
Tymczasowo wyłącz ochronę DNS do rozwiązywania problemów:

```bash
# Włącz tryb paniki (5-minutowe auto-przywracanie)
sudo ./citadel.sh recovery panic-bypass

# Sprawdź status paniki
sudo ./citadel.sh recovery panic-status

# Przywróć ochronę
sudo ./citadel.sh recovery panic-restore
```

### Awaryjne przywracanie sieci
Przywróć łączność internetową gdy DNS jest uszkodzony:

```bash
# Kompletne odzyskiwanie sieci
sudo ./citadel.sh recovery emergency-network-restore

# Szybka naprawa tylko DNS
sudo ./citadel.sh recovery emergency-network-fix
```

### Przywracanie systemu
Przywróć konfigurację systemu z kopii zapasowej:

```bash
# Przywróć z kopii zapasowej
sudo ./citadel.sh recovery restore-system

# Przywróć do ustawień fabrycznych
sudo ./citadel.sh recovery restore-system-default
```

---

## Instalacja i konfiguracja

### Kompletna instalacja
```bash
# Zainstaluj wszystko
sudo ./citadel.sh install all

# Zainstaluj poszczególne komponenty
sudo ./citadel.sh install dnscrypt
sudo ./citadel.sh install coredns
sudo ./citadel.sh install nftables
sudo ./citadel.sh install dashboard
```

### Konfiguracja systemu
```bash
# Skonfiguruj system do używania DNS Citadel
sudo ./citadel.sh install configure-system

# Ustaw tryb firewall
sudo ./citadel.sh install firewall-safe    # Zezwól na zewnętrzny DNS
sudo ./citadel.sh install firewall-strict  # Zablokuj zewnętrzny DNS
```

### Zależności
```bash
# Sprawdź i zainstaluj brakujące zależności
sudo ./citadel.sh install check-deps

# Interaktywny kreator instalacji
sudo ./citadel.sh install wizard
```

---

## Bezpieczeństwo i monitorowanie

### Weryfikacja integralności
```bash
# Inicjalizuj sprawdzanie integralności
sudo ./citadel.sh security integrity-init

# Weryfikuj integralność plików
sudo ./citadel.sh security integrity-check

# Pokaż status integralności
sudo ./citadel.sh security integrity-status
```

### Bezpieczeństwo oparte na lokalizacji
```bash
# Sprawdź obecne bezpieczeństwo sieci
sudo ./citadel.sh security location-check

# Zarządzaj zaufanymi sieciami
sudo ./citadel.sh security location-add-trusted "MójDomowyWiFi"
sudo ./citadel.sh security location-remove-trusted "PublicznyWiFi"
sudo ./citadel.sh security location-list-trusted
```

### Bezpieczeństwo łańcucha dostaw
```bash
# Inicjalizuj weryfikację łańcucha dostaw
sudo ./citadel.sh security supply-chain-init

# Weryfikuj źródła i binaria
sudo ./citadel.sh security supply-chain-verify

# Pokaż status łańcucha dostaw
sudo ./citadel.sh security supply-chain-status
```

### Audyt bezpieczeństwa
```bash
# Sprawdź otwarte porty i podejrzane procesy
sudo ./citadel.sh security ghost-check

# Debuguj reguły firewall
sudo ./citadel.sh security nft-debug-on
sudo ./citadel.sh security nft-debug-status
sudo ./citadel.sh security nft-debug-logs
```

---

## Konfiguracja sieci

### Rozszerzenia prywatności IPv6
```bash
# Włącz prywatność IPv6
sudo ./citadel.sh network ipv6-privacy-on

# Wyłącz prywatność IPv6
sudo ./citadel.sh network ipv6-privacy-off

# Auto-konfiguruj prywatność IPv6
sudo ./citadel.sh network ipv6-privacy-auto

# Sprawdź status prywatności IPv6
sudo ./citadel.sh network ipv6-privacy-status
```

### Edycja konfiguracji
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

### Zarządzanie portami
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

# Testuj powiadomienia
sudo ./citadel.sh network notify-test
```

---

## Blokowanie reklam

### Status i statystyki
```bash
# Pokaż status blokowania reklam
sudo ./citadel.sh adblock status

# Pokaż statystyki
sudo ./citadel.sh adblock stats

# Pokaż zawartość listy blokowania
sudo ./citadel.sh adblock show blocklist   # Pokaż zablokowane domeny
sudo ./citadel.sh adblock show custom      # Pokaż własne bloki
sudo ./citadel.sh adblock show combined    # Pokaż wszystkie bloki
```

### Zarządzanie domenami
```bash
# Dodaj domenę do listy blokowania
sudo ./citadel.sh adblock add ads.example.com

# Usuń domenę z listy blokowania
sudo ./citadel.sh adblock remove ads.example.com

# Edytuj własną listę blokowania
sudo ./citadel.sh adblock edit
```

### Zarządzanie białą listą
```bash
# Pokaż białą listę
sudo ./citadel.sh adblock allowlist-list

# Dodaj do białej listy (obejdź blokowanie)
sudo ./citadel.sh adblock allowlist-add trusted.example.com

# Usuń z białej listy
sudo ./citadel.sh adblock allowlist-remove trusted.example.com
```

### Profile list blokowania
```bash
# Wyświetl dostępne profile
sudo ./citadel.sh adblock blocklist-list

# Przełącz profil
sudo ./citadel.sh adblock blocklist-switch balanced

# Pokaż status obecnego profilu
sudo ./citadel.sh adblock blocklist-status

# Dodaj własny URL listy blokowania
sudo ./citadel.sh adblock blocklist-add-url "https://example.com/blocklist.txt"
```

---

## Kopia zapasowa i przywracanie

### Kopia zapasowa konfiguracji
```bash
# Utwórz kopię zapasową
sudo ./citadel.sh backup config-backup

# Wyświetl dostępne kopie zapasowe
sudo ./citadel.sh backup config-list

# Przywróć z kopii zapasowej
sudo ./citadel.sh backup config-restore /path/to/backup.tar.gz

# Usuń kopię zapasową
sudo ./citadel.sh backup config-delete /path/to/backup.tar.gz
```

### Last Known Good (LKG)
```bash
# Zapisz obecną listę blokowania jako LKG
sudo ./citadel.sh backup lkg-save

# Przywróć z cache LKG
sudo ./citadel.sh backup lkg-restore

# Pokaż status LKG
sudo ./citadel.sh backup lkg-status
```

### Auto-aktualizacje
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

### Aktualizacje list blokowania
```bash
# Aktualizuj listy blokowania z fallback LKG
sudo ./citadel.sh backup lists-update
```

---

## Monitorowanie i diagnostyka

### Status systemu
```bash
# Pokaż kompleksowy status
sudo ./citadel.sh monitor status

# Uruchom pełną diagnostykę
sudo ./citadel.sh monitor diagnostics

# Weryfikuj konfigurację
sudo ./citadel.sh monitor verify

# Uruchom wszystkie testy
sudo ./citadel.sh monitor test-all
```

### Statystyki cache
```bash
# Pokaż wydajność cache
sudo ./citadel.sh monitor cache-stats

# Pokaż top domeny
sudo ./citadel.sh monitor cache-top

# Resetuj statystyki cache
sudo ./citadel.sh monitor cache-reset

# Obserwuj statystyki cache na żywo
sudo ./citadel.sh monitor cache-watch
```

### Monitorowanie zdrowia
```bash
# Sprawdź zdrowie systemu
sudo ./citadel.sh monitor health-status

# Zainstaluj watchdog zdrowia
sudo ./citadel.sh monitor health-watchdog-install

# Odinstaluj watchdog zdrowia
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

### Benchmarki wydajności
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

### Weryfikacja konfiguracji
```bash
# Sprawdź pliki konfiguracyjne
sudo ./citadel.sh monitor verify-config

# Testuj funkcjonalność DNS
sudo ./citadel.sh monitor verify-dns

# Weryfikuj usługi
sudo ./citadel.sh monitor verify-services

# Weryfikuj pliki
sudo ./citadel.sh monitor verify-files
```

---

## Rozwiązywanie problemów

### Częste problemy

#### DNS nie działa
```bash
# Sprawdź rozwiązywanie DNS
sudo ./citadel.sh monitor verify-dns

# Awaryjne przywracanie sieci
sudo ./citadel.sh recovery emergency-network-restore

# Sprawdź reguły firewall
sudo ./citadel.sh monitor verify
```

#### Usługi nie uruchamiają się
```bash
# Sprawdź status usług
sudo ./citadel.sh monitor status

# Wyświetl logi usług
sudo ./citadel.sh network logs coredns
sudo ./citadel.sh network logs dnscrypt

# Zrestartuj usługi
sudo systemctl restart coredns dnscrypt-proxy
```

#### Blokowanie reklam nie działa
```bash
# Sprawdź status blokowania reklam
sudo ./citadel.sh adblock status

# Odbuduj listę blokowania
sudo ./citadel.sh backup lists-update

# Sprawdź białą listę
sudo ./citadel.sh adblock allowlist-list
```

#### Problemy z firewall
```bash
# Sprawdź status firewall
sudo ./citadel.sh monitor verify

# Ustaw tryb bezpieczny tymczasowo
sudo ./citadel.sh install firewall-safe

# Resetuj do trybu ścisłego
sudo ./citadel.sh install firewall-strict
```

### Uzyskiwanie pomocy

#### Wbudowana pomoc
```bash
# Ogólna pomoc
./citadel.sh help

# Pomoc specyficzna dla modułu
./citadel.sh install help
./citadel.sh adblock help
./citadel.sh monitor help
```

#### Logi i debugowanie
```bash
# Logi systemowe
sudo ./citadel.sh network logs

# Logi specyficzne dla usługi
sudo journalctl -u coredns -f
sudo journalctl -u dnscrypt-proxy -f

# Tryb debugowania (jeśli dostępny)
export CYTADELA_MODE=developer
```

---

## Przewodnik migracji

### Z v3.1 do v3.2

Citadel v3.2 utrzymuje **100% kompatybilności wstecznej**. Wszystkie istniejące komendy i konfiguracje nadal działają bez zmian.

#### Co się zmieniło
- **Architektura:** 29 modułów skonsolidowanych w 7 zunifikowanych modułów
- **Komendy:** Dostępna nowa zunifikowana struktura komend
- **Wydajność:** Ulepszone ładowanie i zmniejszone użycie pamięci
- **Bezpieczeństwo:** Ulepszone sprawdzanie integralności i weryfikacja łańcucha dostaw

#### Co nowego
- **Zunifikowane komendy:** Składnia `citadel <moduł> <akcja>`
- **Inteligentne ładowanie:** Moduły ładują się na żądanie
- **Ulepszone monitorowanie:** Metryki Prometheus, sprawdzanie zdrowia, benchmarki
- **Prywatność IPv6:** Automatyczne zarządzanie adresami prywatnymi
- **Bezpieczeństwo lokalizacji:** Polityki bezpieczeństwa oparte na sieciach WiFi

#### Kroki migracji
1. **Aktualizacja:** Pobierz najnowszy kod z repozytorium
2. **Kopia zapasowa:** Utwórz kopię zapasową konfiguracji (zalecane)
3. **Test:** Uruchom diagnostykę aby sprawdzić czy wszystko działa
4. **Opcjonalnie:** Zacznij używać nowych zunifikowanych komend

#### Wsparcie starszych komend
Wszystkie komendy v3.1 nadal działają:
```bash
# Stare komendy (nadal działają)
sudo ./citadel.sh install-all
sudo ./citadel.sh adblock-status
sudo ./citadel.sh panic-bypass

# Nowe zunifikowane komendy (zalecane)
sudo ./citadel.sh install all
sudo ./citadel.sh adblock status
sudo ./citadel.sh recovery panic-bypass
```

### Wsparcie
- **Dokumentacja:** Ten podręcznik i REFACTORING-V3.2-ROADMAP.md
- **Issues:** Problemy GitHub z etykietą `unified-modules`
- **Społeczność:** Dyskusje projektu i wiki

---

**Citadel v3.2 - Zunifikowana architektura dla lepszego bezpieczeństwa i wydajności**
