# Citadel++ – notatki / jak używać (żeby nie stracić internetu)

Ten dokument opisuje:
- co zostało zmienione w `cytadela++.sh` w porównaniu do wcześniejszej wersji,
- czym jest „blokada DNS leaków poza localhost”,
- bezpieczny workflow instalacji i przełączenia systemu,
- nową komendę `verify`.

Dodatkowo zawiera aktualny opis:
- panelu zarządzania DNS-adblock (blocklist/custom),
- automatycznego healthcheck po `install-all`.

## TL;DR (bezpieczny workflow)

1. Zainstaluj komponenty:

```bash
sudo ./cytadela++.sh install-all
```

2. Załaduj reguły firewall w trybie SAFE:

```bash
sudo ./cytadela++.sh install-nftables
sudo ./cytadela++.sh firewall-safe
```

3. Sprawdź lokalny DNS:

```bash
dig +short google.com @127.0.0.1
```

4. Dopiero wtedy przełącz DNS systemu:

```bash
sudo ./cytadela++.sh configure-system
```

`configure-system` robi automatycznie:
- przełącza firewall na SAFE,
- robi zmianę DNS systemu,
- testuje `dig @127.0.0.1 google.com`,
- jeśli test przejdzie → włącza firewall STRICT,
- jeśli test nie przejdzie → zostawia SAFE i podaje rollback.

5. Weryfikacja całości:

```bash
sudo ./cytadela++.sh verify
```

6. Rollback (gdyby coś poszło źle):

```bash
sudo ./cytadela++.sh restore-system
```

---

## Co to jest „blokada leaków poza localhost”

### Definicja

**DNS leak** w tym kontekście to sytuacja, w której aplikacja albo system wysyła zapytania DNS **w plaintext** bezpośrednio do zewnętrznych serwerów (np. DNS od ISP, routera, `8.8.8.8:53`) zamiast do Twojego lokalnego stosu (CoreDNS → DNSCrypt).

**„Blokada leaków poza localhost”** oznacza, że firewall blokuje próby wyjścia z komputera z ruchem DNS na porcie `53` (UDP/TCP) **do internetu**, a dopuszcza DNS tylko do `127.0.0.1` (localhost).

### Po co to jest

- Wymusza, że *wszystkie* aplikacje korzystają z lokalnego resolvera (CoreDNS), a nie „omijają” go.
- Chroni przed sytuacją, gdzie część zapytań idzie szyfrowanym kanałem (DNSCrypt), a część „wycieka” normalnym DNS.

### Ważne ograniczenie

To dotyczy głównie klasycznego DNS (`UDP/TCP 53`).
Jeśli aplikacja ma wbudowany **DoH** (DNS-over-HTTPS) na `443` i sama robi zapytania HTTPs do dostawcy DNS, to nie jest to „DNS leak na 53” i te reguły tego nie zatrzymają.

---

## Pełna lista funkcji / komend (co potrafi Citadel++)

Komendy uruchamiasz jako:

```bash
sudo ./cytadela++.sh <komenda>
```

### Instalacja i konfiguracja

- **`install-dnscrypt`**: instaluje/konfiguruje `dnscrypt-proxy` (z `[sources]` dla resolverów), dobiera wolny port, uruchamia usługę.
- **`install-coredns`**: instaluje/konfiguruje CoreDNS (cache + blocklist + forward do DNSCrypt), metryki Prometheus na `127.0.0.1:9153`.
- **`install-nftables`**: generuje reguły NFTables w trybach SAFE/STRICT i ładuje domyślnie SAFE.
- **`install-all`**: uruchamia: DNSCrypt → CoreDNS → NFTables (bez automatycznego przełączania DNS systemu) i na końcu robi krótki healthcheck DNS/Adblock.

### DNS Adblock (panel)

CoreDNS korzysta z list w formacie „hosts” i blokuje domeny przez zwracanie `0.0.0.0`.

Pliki:
- `/etc/coredns/zones/custom.hosts` – Twoje ręczne wpisy (nie są nadpisywane przez auto-update).
- `/etc/coredns/zones/blocklist.hosts` – listy pobierane automatycznie.
- `/etc/coredns/zones/combined.hosts` – plik używany przez CoreDNS (custom + blocklist).

Ważne: CoreDNS działa jako użytkownik `coredns`, więc pliki list muszą być czytelne dla tego usera:
- `blocklist.hosts` i `combined.hosts`: owner `root:coredns`, uprawnienia `0640`
- `custom.hosts`: `0644`

Komendy panelu (uruchamiane przez `sudo ./cytadela++.sh <komenda>`):
- **`adblock-status`** – status integracji (czy CoreDNS używa combined, liczba wpisów).
- **`adblock-stats`** – liczba wpisów w custom/blocklist/combined.
- **`adblock-show custom|blocklist|combined`** – podgląd pierwszych 200 linii.
- **`adblock-edit`** – edycja `custom.hosts` + rebuild + reload.
- **`adblock-add <domena>`** – dodaje domenę do custom (blokada).
- **`adblock-remove <domena>`** – usuwa domenę z custom.
- **`adblock-rebuild`** – przebudowuje `combined.hosts` + reload CoreDNS.
- **`adblock-query <domena>`** – test zapytania DNS przez `127.0.0.1`.

### DNS systemu (przełączanie / rollback)

- **`configure-system`**: przełącza DNS systemu na Citadel++ (z zabezpieczeniem: SAFE → test DNS → STRICT).
- **`restore-system`**: przywraca `systemd-resolved` i ustawienia DNS (rollback).

### Firewall modes (DNS leak prevention)

- **`firewall-safe`**: tryb SAFE – nie zrywa internetu podczas wdrażania (ma wyjątki na bootstrap i `systemd-resolved`).
- **`firewall-strict`**: tryb STRICT – pełna blokada DNS leaków poza localhost.

### Tryby awaryjne

- **`emergency-refuse`**: CoreDNS ustawia `refuse` (odrzuca wszystkie zapytania DNS).
- **`emergency-restore`**: przywraca normalny tryb (Corefile z backupu + restart usług).
- **`killswitch-on`**: awaryjny kill-switch DNS.
- **`killswitch-off`**: wyłącza kill-switch.

### Diagnostyka i kontrola stanu

- **`status`**: status usług (`dnscrypt-proxy`, `coredns`, `nftables`).
- **`diagnostics`**: rozszerzona diagnostyka (test DNS, metryki, logi, reguły, blocklista).
- **`verify`**: szybki self-check całego stacku (porty/usługi/NFT/DNS/metryki).
- **`safe-test`**: testy kontrolne bez przełączania DNS systemu.

### Dodatkowe moduły i narzędzia

- **`smart-ipv6`**: wykrywa IPv6 i przełącza `ipv6_servers` w DNSCrypt.
- **`install-dashboard`**: instaluje dashboard `citadel-top`.
- **`install-editor`**: instaluje wrapper `citadel` (edycja configów + autorestart).
- **`optimize-kernel`**: ustawia timer+service do priorytetów (renice/ionice) dla DNS.
- **`install-doh-parallel`**: generuje opcjonalny config DNSCrypt pod DoH parallel racing.
- **`fix-ports`**: pomaga zdiagnozować konflikty portów.

## Czy wszystkie funkcjonalności z pierwotnej wersji są zachowane?

### Zachowane

Skrypt nadal ma i obsługuje:
- `install-dnscrypt`, `install-coredns`, `install-nftables`, `install-all`
- `configure-system`
- tryby awaryjne: `emergency-refuse`, `emergency-restore`, `killswitch-on`, `killswitch-off`
- diagnostyka: `diagnostics`, `status`
- dodatkowe moduły: `smart-ipv6`, `install-dashboard` (`citadel-top`), `install-editor` (`citadel edit`), `optimize-kernel`, `install-doh-parallel`, `fix-ports`, `safe-test`

### Zmiany (celowe) względem pierwotnej wersji

1. **`install-all` nie wywołuje automatycznie `configure-system`**

To celowe: przełączenie DNS systemu jest najbardziej ryzykownym momentem. Teraz robisz je świadomie i w kontrolowanych warunkach.

2. **NFTables ma dwa tryby: SAFE i STRICT**

- `firewall-safe`:
  - ma wyjątki, żeby nie odcinać internetu w trakcie przygotowania (np. bootstrap dla dnscrypt-proxy i działanie `systemd-resolved` przed przełączeniem systemu).
- `firewall-strict`:
  - to „twarda” ochrona: blokuje DNS na `:53` poza localhost.

Dodatkowo `install-nftables` jest bezpieczne do uruchamiania wielokrotnie:
- czyści stan tabel `citadel_dns` / `citadel_emergency` przed ponownym załadowaniem reguł,
- usuwa historyczne duplikaty linii `include "/etc/nftables.d/citadel-dns.nft"` w `/etc/nftables.conf`.

3. **`configure-system` automatycznie przełącza na STRICT dopiero po udanym teście DNS**

To jest mechanizm „samozabezpieczenia”: najpierw SAFE → zmiana DNS → test → dopiero potem STRICT.

4. **DNSCrypt ma poprawne źródło resolverów**

W konfiguracji generowanej przez skrypt jest sekcja `[sources]` z URL do listy resolverów i `minisign_key`, żeby dnscrypt-proxy zawsze widział serwery z `server_names`.

5. **Install-coredns ma "bootstrap DNS" i utwardzone pobieranie list**

Żeby w trakcie `install-coredns` nie stracić rozwiązywania nazw (gdy system DNS jest już ustawiony na `127.0.0.1`), skrypt najpierw uruchamia tymczasowy CoreDNS forwardujący do aktualnego portu DNSCrypt.

Pobieranie list jest utwardzone:
- `curl -f` (błędy HTTP przerywają pobieranie),
- generowanie do plików tymczasowych,
- podmiana list tylko jeśli wynik ma sensowną liczbę wpisów (żeby auto-update nie „wyzerował” listy),
- źródło PolishFilters: używany jest plik `PPB.txt` (działający URL).

---

## Nowa komenda: `verify`

Komenda:

```bash
sudo ./cytadela++.sh verify
```

Sprawdza:
- wykryte porty DNSCrypt/CoreDNS,
- status usług `dnscrypt-proxy` i `coredns`,
- czy tabela `inet citadel_dns` jest załadowana,
- który tryb firewall jest aktywny (SAFE/STRICT) na podstawie symlink `/etc/nftables.d/citadel-dns.nft`,
- test lokalnego DNS (`dig @127.0.0.1`),
- dostępność endpointu metryk Prometheus (`http://127.0.0.1:9153/metrics`).

---

## Szybka diagnostyka po instalacji

```bash
sudo ./cytadela++.sh verify
sudo ./cytadela++.sh diagnostics
citadel-top
```

---

## Rollback

Jeśli po `configure-system` cokolwiek zrobi się niestabilne:

```bash
sudo ./cytadela++.sh restore-system
```

To przywraca:
- `systemd-resolved` (unmask + enable + start),
- usuwa override NetworkManager,
- naprawia `/etc/resolv.conf`.

---

## FAQ / Najczęstsze problemy

### 1) `curl: (6) Could not resolve host ...` podczas `install-all` / `install-coredns`

Oznacza, że w danym momencie **system nie ma działającego resolvera**, a `curl` nie potrafi rozwiązać nazw.

Co zrobić:
- Uruchom ponownie `sudo ./cytadela++.sh install-coredns`.
- Sprawdź, czy lokalny DNS działa:

```bash
dig +short google.com @127.0.0.1
```

Jeśli powyższe nie działa, sprawdź logi:

```bash
journalctl -u coredns -n 50 --no-pager
journalctl -u dnscrypt-proxy -n 50 --no-pager
```

### 2) `curl: (22) The requested URL returned error: 404` podczas pobierania list

To znaczy, że jedno ze źródeł list zmieniło URL.

Skrypt jest utwardzony tak, żeby **nie wyzerować list** w takiej sytuacji (zostawia poprzednią działającą).
Możesz po prostu uruchomić `install-coredns` ponownie później.

### 3) `nftables.service` jest `inactive (dead)` – czy firewall działa?

Tak, to często normalne (unit typu "oneshot" ładuje reguły i kończy).
Sprawdź, czy reguły Citadel są w rulesecie:

```bash
sudo nft list ruleset | grep -i citadel
```

### 4) Adblock nie działa (domena zwraca normalne IP)

Najczęstsze powody:

- **Uprawnienia plików list**: CoreDNS działa jako user `coredns` i musi móc czytać listy.
  Wymagane:
  - `blocklist.hosts` i `combined.hosts`: `root:coredns` + `0640`
  - `custom.hosts`: `0644`

Możesz to sprawdzić:

```bash
stat -c '%U %G %a %n' /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts
```

I naprawić (bezpiecznie) przez:

```bash
sudo ./cytadela++.sh adblock-rebuild
sudo systemctl restart coredns
```

- **Cache**: po zmianach w `custom.hosts` czasem warto zrobić restart CoreDNS.

Test blokowania:

```bash
sudo ./cytadela++.sh adblock-query doubleclick.net
```

### 5) `install-all` pokazuje FAIL w healthcheck

Najpierw uruchom ręcznie:

```bash
sudo ./cytadela++.sh verify
sudo ./cytadela++.sh adblock-status
```

Jeśli `verify` pokazuje, że DNS działa, a healthcheck nie – zwykle pomaga:

```bash
sudo systemctl restart coredns
```
