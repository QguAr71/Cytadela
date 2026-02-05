# ❓ Często Zadawane Pytania (FAQ)

---

## 📋 Spis Treści

1. [Pytania Ogólne](#-pytania-ogólne)
2. [Instalacja](#-instalacja)
3. [Konfiguracja](#️-konfiguracja)
4. [Rozwiązywanie Problemów](#-rozwiązywanie-problemów)
5. [Wydajność](#-wydajność)
6. [Bezpieczeństwo i Prywatność](#-bezpieczeństwo-i-prywatność)
7. [Zaawansowane Użycie](#-zaawansowane-użycie)

---

## 🌟 Pytania Ogólne

### Co to jest Cytadela?

Cytadela to kompleksowe rozwiązanie DNS dla prywatności i bezpieczeństwa na Linuxie, które łączy:
- **DNSCrypt-Proxy** - Zaszyfrowany DNS (DoH/DoT)
- **CoreDNS** - Lokalny serwer DNS z cache
- **NFTables** - Firewall zapobiegający wyciekom DNS
- **Blokowanie reklam** - 325K+ zablokowanych domen
- **Architektura modułowa** - 29 niezależnych modułów

### Dla kogo jest Cytadela?

- 🏠 **Użytkownicy domowi** - Osoby świadome prywatności
- 👨‍💼 **Małe biura** - Zespół potrzebujący bezpieczeństwa DNS
- 🔧 **Power użytkownicy** - Ci, którzy chcą pełnej kontroli
- 🛡️ **Entuzjaści bezpieczeństwa** - Skupieni na prywatności i bezpieczeństwie

### Co wyróżnia Cytadelę?

- ✅ **Lokalnie pierwsze** - Bez zależności chmurowych
- ✅ **Modułowa** - 29 modułów, lazy loading
- ✅ **CLI pierwsze** - Pełna kontrola przez terminal
- ✅ **7 języków** - PL, EN, DE, ES, IT, FR, RU
- ✅ **Tryb awaryjny** - Odzyskiwanie panic-bypass
- ✅ **Open source** - Licencja GPL-3.0

### Które dystrybucje Linux są wspierane?

**Pełne wsparcie:**
- Arch Linux
- CachyOS

**Częściowe wsparcie (manualna adaptacja):**
- Ubuntu/Debian (wymaga manualnej instalacji pakietów)
- Fedora/RHEL (wymaga manualnej instalacji pakietów)
- Inne dystrybucje oparte na systemd

---

## 🚀 Instalacja

### Jak zainstalować Cytadelę?

**Szybka instalacja:**
```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./citadel.sh check-deps       # Sprawdź zależności
sudo ./citadel.sh install-wizard   # Tryb GUI
# LUB
sudo ./citadel.sh install-all      # Tryb CLI
```

Zobacz [Przewodnik Szybkiego Startu](quick-start.md) po szczegóły.

### Czy potrzebuję root/sudo?

**Tak**, Cytadela wymaga uprawnień root do:
- Instalacji pakietów systemowych
- Konfiguracji ustawień DNS
- Modyfikacji reguł firewall
- Zarządzania usługami systemd

### Czy mogę zainstalować bez kreatora?

**Tak**, użyj trybu CLI:
```bash
sudo ./citadel.sh install-all
```

To instaluje wszystkie komponenty automatycznie bez GUI.

### Jakie są wymagania systemowe?

**Minimalne:**
- 512 MB RAM
- 100 MB miejsca na dysku
- Aktywne połączenie internetowe

**Zalecane:**
- 2 GB RAM
- SSD
- 2+ rdzenie CPU

### Jak długo trwa instalacja?

- **Tryb kreatora:** 5-10 minut
- **Tryb CLI:** 3-5 minut
- **Tryb manualny:** 10-15 minut

---

## ⚙️ Konfiguracja

### Jak przełączyć się na DNS Cytadela?

```bash
sudo ./citadel.sh configure-system
```

To zrobi:
- Wyłączy systemd-resolved
- Skonfiguruje /etc/resolv.conf
- Wskaże DNS na 127.0.0.1

### Jak przywrócić oryginalny DNS?

```bash
# Przywróć backup sprzed Cytadeli
sudo ./citadel.sh restore-system

# Przywróć ustawienia fabryczne (jeśli backup był zepsuty)
sudo ./citadel.sh restore-system-default
```

### Czy mogę używać własnych resolverów DNS?

**Tak**, edytuj konfigurację DNSCrypt:
```bash
sudo ./citadel.sh edit-dnscrypt
```

Lub manualnie edytuj:
```bash
sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```

### Jak włączyć DNSSEC?

```bash
# Podczas instalacji
CITADEL_DNSSEC=1 sudo ./citadel.sh install-dnscrypt

# Lub dodaj flagę
sudo ./citadel.sh install-dnscrypt --dnssec
```

### Jak zmienić profil blocklist?

```bash
# Lista dostępnych profili
sudo ./citadel.sh blocklist-list

# Przełącz profil
sudo ./citadel.sh blocklist-switch aggressive
```

**Dostępne profile:**
- `light` - Podstawowe blokowanie (~50K domen)
- `balanced` - Zalecane (~150K domen)
- `aggressive` - Maksymalne blokowanie (~325K domen)
- `privacy` - Skupione na prywatności
- `polish` - Zoptymalizowane pod polskie strony
- `custom` - Twoja własna lista

---

## 🔧 Rozwiązywanie Problemów

### DNS nie działa po instalacji

**Sprawdź status:**
```bash
sudo ./citadel.sh status
sudo ./citadel.sh diagnostics
```

**Częste naprawy:**
```bash
# Restartuj usługi
sudo systemctl restart dnscrypt-proxy coredns

# Sprawdź firewall
sudo ./citadel.sh firewall-safe

# Testuj DNS
dig +short google.com @127.0.0.1
```

### Konflikty portów (53, 5353)

```bash
sudo ./citadel.sh fix-ports
```

To automatycznie rozwiąże konflikty portów.

### Internet przestał działać

**Odzyskiwanie awaryjne:**
```bash
sudo ./citadel.sh panic-bypass
```

To zrobi:
- Tymczasowo ominie DNS/firewall
- Przywróci łączność internetową
- Pozwoli naprawić problemy

**Przywróć normalny tryb:**
```bash
sudo ./citadel.sh panic-restore
```

### Jak sprawdzić wycieki DNS?

```bash
# Test wycieku DNS
dig @8.8.8.8 test.com  # Powinno być zablokowane przez firewall

# Sprawdź reguły firewall
sudo nft list ruleset | grep citadel

# Pełna diagnostyka
sudo ./citadel.sh diagnostics
```

### Usługi ciągle padają

**Sprawdź logi:**
```bash
sudo journalctl -u dnscrypt-proxy -f
sudo journalctl -u coredns -f
```

**Przeinstaluj:**
```bash
sudo ./citadel.sh restore-system
sudo ./citadel.sh install-all
```

---

## ⚡ Wydajność

### Czy Cytadela jest szybka?

**Tak!** Cache CoreDNS zapewnia:
- ~1-5ms czas odpowiedzi (cache)
- ~20-50ms czas odpowiedzi (upstream)
- 90%+ współczynnik trafień cache

**Sprawdź wydajność:**
```bash
sudo ./citadel.sh cache-stats
```

### Ile RAM zużywa?

**Typowe użycie:**
- DNSCrypt-Proxy: ~20-30 MB
- CoreDNS: ~30-50 MB
- **Razem:** ~50-80 MB RAM

### Czy spowalnia internet?

**Nie**, cache DNS faktycznie przyspiesza przeglądanie:
- Pierwsze zapytanie: ~20-50ms (upstream)
- Zapytania cache: ~1-5ms (lokalne)
- Ogólnie: **Szybciej** niż DNS ISP

### Ile zapytań może obsłużyć?

CoreDNS może obsłużyć:
- **1000+ zapytań/sekundę** na typowym sprzęcie
- **10,000+ zapytań/sekundę** na potężnym sprzęcie

Dla użytku domowego to więcej niż wystarczająco.

---

## 🔒 Bezpieczeństwo i Prywatność

### Czy mój ruch DNS jest szyfrowany?

**Tak**, DNSCrypt-Proxy zapewnia:
- DoH (DNS-over-HTTPS)
- DoT (DNS-over-TLS)
- Protokół DNSCrypt

Wszystkie zapytania DNS są szyfrowane end-to-end.

### Czy Cytadela loguje moje zapytania?

**Nie**, Cytadela nie loguje zapytań DNS domyślnie.

**Aby zweryfikować:**
```bash
# Sprawdź konfigurację DNSCrypt
grep -i log /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# Sprawdź konfigurację CoreDNS
grep -i log /etc/coredns/Corefile
```

### Czy mój ISP może zobaczyć moje zapytania DNS?

**Nie**, cały ruch DNS jest szyfrowany przez DNSCrypt-Proxy.

Twój ISP może zobaczyć tylko:
- Zaszyfrowany ruch HTTPS do resolvera DNS
- Nie może zobaczyć których domen pytasz

### Jak zweryfikować szyfrowanie DNS?

```bash
# Sprawdź status DNSCrypt
sudo systemctl status dnscrypt-proxy

# Test rozwiązywania DNS
dig +short google.com @127.0.0.1

# Sprawdź firewall (blokuje nieszyfrowany DNS)
sudo nft list ruleset | grep "port 53"
```

### Co z prywatnością IPv6?

Cytadela zawiera funkcje prywatności IPv6:
```bash
# Włącz prywatność IPv6
sudo ./citadel.sh ipv6-privacy-auto

# Głęboki reset IPv6
sudo ./citadel.sh ipv6-deep-reset
```

---

## 🎓 Zaawansowane Użycie

### Czy mogę używać Cytadeli jako bramy sieciowej?

**Tak** (v3.2 - planowane):
```bash
sudo ./citadel.sh gateway-wizard
```

To skonfiguruje Cytadelę jako bramę DNS dla całej Twojej sieci.

### Jak zrobić backup mojej konfiguracji?

```bash
# Utwórz backup
sudo ./citadel.sh config-backup

# Lista backupów
sudo ./citadel.sh config-list

# Przywróć backup
sudo ./citadel.sh config-restore nazwa-backup.tar.gz
```

### Czy mogę dodać własne blocklisty?

**Tak:**
```bash
# Dodaj własny URL
sudo ./citadel.sh blocklist-add-url https://example.com/blocklist.txt

# Edytuj własne hosts
sudo nano /etc/coredns/zones/custom.hosts

# Przebuduj blocklist
sudo ./citadel.sh adblock-rebuild
```

### Jak włączyć auto-aktualizacje?

```bash
# Włącz auto-aktualizację
sudo ./citadel.sh auto-update-enable

# Skonfiguruj harmonogram
sudo ./citadel.sh auto-update-configure

# Sprawdź status
sudo ./citadel.sh auto-update-status
```

### Czy mogę monitorować Cytadelę z Prometheus?

**Tak**, CoreDNS eksportuje metryki Prometheus:
```bash
# Sprawdź metryki
curl -s http://127.0.0.1:9153/metrics | grep coredns_

# Wyświetl statystyki cache
sudo ./citadel.sh cache-stats
```

### Jak zintegrować z moim edytorem?

```bash
sudo ./citadel.sh install-editor
```

To dodaje polecenia Cytadela do Twojego edytora (vim/nano/etc).

Obecnie Cytadela wymaga bezpośredniego dostępu systemowego do:
- Usług systemd
- Konfiguracji sieci
- Reguł firewall

---

## 🆘 Nadal Potrzebujesz Pomocy?

### Dokumentacja

- 📖 [Pełny Manual (PL)](MANUAL_PL.md)
- 📖 [Pełny Manual (EN)](MANUAL_EN.md)
- 🚀 [Przewodnik Szybkiego Startu](quick-start.md)
- 📋 [Referencja Poleceń](commands.md)
- 🏗️ [Architektura](../CITADEL-STRUCTURE.md)

### Społeczność

- 💬 [Dyskusje GitHub](https://github.com/QguAr71/Cytadela/discussions)
- 🐛 [Zgłoś Błąd](https://github.com/QguAr71/Cytadela/issues/new?template=bug_report.md)
- 💡 [Prośba o Funkcję](https://github.com/QguAr71/Cytadela/issues/new?template=feature_request.md)

### Awaryjne

Jeśli jesteś całkowicie zablokowany:
```bash
# Bypass awaryjny
sudo ./citadel.sh panic-bypass

# Pełne przywrócenie
sudo ./citadel.sh restore-system

# Diagnostyka
sudo ./citadel.sh diagnostics
```

---

**Ostatnia aktualizacja:** 2026-01-31
**Wersja:** 3.1.1
