# Citadel++ – notatki / jak używać (żeby nie stracić internetu)

Ten dokument opisuje:
- co zostało zmienione w `cytadela++.sh` w porównaniu do wcześniejszej wersji,
- czym jest „blokada DNS leaków poza localhost”,
- bezpieczny workflow instalacji i przełączenia systemu,
- nową komendę `verify`.

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
- **`install-all`**: uruchamia: DNSCrypt → CoreDNS → NFTables (bez automatycznego przełączania DNS systemu).

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

3. **`configure-system` automatycznie przełącza na STRICT dopiero po udanym teście DNS**

To jest mechanizm „samozabezpieczenia”: najpierw SAFE → zmiana DNS → test → dopiero potem STRICT.

4. **DNSCrypt ma poprawne źródło resolverów**

W konfiguracji generowanej przez skrypt jest sekcja `[sources]` z URL do listy resolverów i `minisign_key`, żeby dnscrypt-proxy zawsze widział serwery z `server_names`.

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
