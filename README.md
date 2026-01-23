# Citadel++ (Cytadela++) — Hardened Local DNS Stack (DNSCrypt + CoreDNS + NFTables)

[![ShellCheck](https://github.com/QguAr71/Cytadela/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/QguAr71/Cytadela/actions/workflows/shellcheck.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## PL — Opis projektu

Ten projekt jest **hobbystyczny** i jest udostępniany **"as-is"** (bez gwarancji i bez supportu).

Cytadela++ to narzędzie bezpieczeństwa, a nie „produkt”.
Istnieje dla osób, które rozumieją kompromisy.
Używaj go, jeśli pasuje do Twojego threat modelu. Jeśli nie — nie używaj.

### Własność bezpieczeństwa (twardy wniosek z audytu)

Na podstawie analizy ruchu (`tcpdump`) można stwierdzić technicznie: Cytadela działa jako **secure DNS gateway na poziomie jądra** — system nie posiada ścieżki DNS do świata zewnętrznego (DNS `:53`) poza lokalnym stackiem (localhost).
Jest to ten sam typ wyniku, jaki zobaczysz w architekturach typu Qubes `sys-firewall`, Whonix Gateway, hardened VPN gateway.

Citadel++ to skrypt instalacyjno-konfiguracyjny, który buduje lokalny „stos DNS” nastawiony na prywatność i spójność działania:

- **Warstwa 1**: `dnscrypt-proxy` — szyfrowany upstream (DNSCrypt/DoH), dynamiczny port lokalny.
- **Warstwa 2**: `CoreDNS` — cache + DNS-adblock (blocklist/custom) + metryki Prometheus.
- **Warstwa 3**: `nftables` — **blokada DNS leaków** na `:53` poza `localhost` (SAFE/STRICT).

### Dlaczego to ma sens

- **Jedno miejsce rozwiązywania nazw** (CoreDNS na `127.0.0.1:53`).
- **Szyfrowany upstream** (DNSCrypt/DoH przez dnscrypt-proxy).
- **Zabezpieczenie przed „leakami”**: aplikacje nie powinny móc wysyłać DNS `:53` wprost do internetu.
- **Adblock na poziomie DNS**: blokowanie domen reklam/telemetrii/malware przez zwracanie `0.0.0.0`.

### Optymalizacje pod Polskę

- Wbudowana jest lista PolishFilters (PPB / Polish Annoyance) jako jedno ze źródeł do budowy `blocklist.hosts`.
- Stos jest nastawiony na użycie lokalnego CoreDNS i szyfrowanego upstreamu (DNSCrypt/DoH), co w praktyce jest sensowne dla PL/EU.

Jeśli chcesz dodatkowo „pod Polskę” dopasować upstreamy DNS:
- Edytuj `server_names` w `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` i wybierz serwery, które preferujesz (np. EU-friendly).
- Po zmianach uruchom:

```bash
sudo systemctl restart dnscrypt-proxy
sudo ./cytadela++.sh verify
```

### Szybki start (bezpieczny)

1) Instalacja komponentów:

```bash
sudo ./cytadela++.sh install-all
```

2) SAFE firewall (na czas wdrażania):

```bash
sudo ./cytadela++.sh firewall-safe
```

3) Test lokalnego DNS:

```bash
dig +short google.com @127.0.0.1
```

4) Przełączenie DNS systemu (dopiero gdy test działa):

```bash
sudo ./cytadela++.sh configure-system
```

5) Szybka weryfikacja:

```bash
sudo ./cytadela++.sh verify
```

Po aktualizacji skryptu:

```bash
sudo ./cytadela++.sh verify
dig @1.1.1.1 test.com
```

Jeśli masz włączony STRICT, drugie polecenie powinno być zablokowane/timeout (to jest szybki test, że `nftables` faktycznie blokuje DNS poza localhost).

Możesz też użyć testu wprost na `:53`:

```bash
nslookup google.com 8.8.8.8
```

W trybie STRICT powinno timeoutować (`no servers could be reached`).

Uwagi:
- `install-nftables` jest bezpieczne do uruchamiania wielokrotnie (czyści stan tabel `citadel_*` i usuwa historyczne duplikaty `include` w `/etc/nftables.conf`).

### Rollback

Jeśli po przełączeniu systemu coś pójdzie źle:

```bash
sudo ./cytadela++.sh restore-system
```

### DNS Adblock (panel)

Pliki:
- `/etc/coredns/zones/custom.hosts` — Twoje ręczne wpisy
- `/etc/coredns/zones/blocklist.hosts` — listy pobierane automatycznie
- `/etc/coredns/zones/combined.hosts` — plik używany przez CoreDNS

Komendy:

```bash
sudo ./cytadela++.sh adblock-status
sudo ./cytadela++.sh adblock-stats
sudo ./cytadela++.sh adblock-add example.com
sudo ./cytadela++.sh adblock-remove example.com
sudo ./cytadela++.sh adblock-edit
sudo ./cytadela++.sh adblock-rebuild
sudo ./cytadela++.sh adblock-query doubleclick.net
```

### Dokumentacja

- PL: `CITADEL++_NOTES.md`
- EN: `CITADEL++_NOTES_EN.md`
- Angielski entrypoint skryptu: `citadela_en.sh`

Tracking poprawek:
- Jeśli chcesz trzymać listę planowanych zmian w repo, użyj GitHub Issues.

### GPL-3.0 w praktyce (FAQ)

- Jeśli używasz/modyfikujesz Citadel++ **tylko u siebie** (home/lab) i nikomu nie przekazujesz kopii: **nic nie musisz publikować**.
- Obowiązki GPL pojawiają się dopiero, gdy **dystrybuujesz** (przekazujesz dalej) kopię skryptu lub zmodyfikowaną wersję.
- Jeśli dystrybuujesz, musisz:
  - zostawić licencję GPL-3.0,
  - udostępnić kod źródłowy (w przypadku bash to po prostu skrypt),
  - nie nakładać dodatkowych ograniczeń na odbiorcę.

---

## EN — Project overview

This is a **hobby project** provided **"as-is"** (no warranty, no support).

Cytadela++ is a security tool, not a product.
It exists for people who understand the trade-offs.
Use it if it fits your threat model. Otherwise – don’t.

### Security property (audit conclusion)

Based on `tcpdump` traffic analysis, Citadel++ meets the requirements of a **secure DNS gateway at the kernel level**: the system has no external DNS path (DNS `:53`) to the Internet outside the local stack (localhost).
This is the same kind of outcome you would expect from architectures such as Qubes `sys-firewall`, Whonix Gateway, or hardened VPN gateway setups.

Citadel++ is an install/config script that builds a local DNS privacy stack:

- **Layer 1**: `dnscrypt-proxy` — encrypted upstream (DNSCrypt/DoH), dynamic local port.
- **Layer 2**: `CoreDNS` — cache + DNS-level adblock (blocklist/custom) + Prometheus metrics.
- **Layer 3**: `nftables` — DNS leak prevention on `:53` outside localhost (SAFE/STRICT).

### Quick start (safe)

1) Install components:

```bash
sudo ./citadela_en.sh install-all
```

2) SAFE firewall mode during rollout:

```bash
sudo ./citadela_en.sh firewall-safe
```

3) Test local DNS:

```bash
dig +short google.com @127.0.0.1
```

4) Switch system DNS only after the test succeeds:

```bash
sudo ./citadela_en.sh configure-system
```

5) Verify:

```bash
sudo ./citadela_en.sh verify
```

After updating the script:

```bash
sudo ./citadela_en.sh verify
dig @1.1.1.1 test.com
```

If STRICT is enabled, the second command should be blocked / time out (quick confirmation that `nftables` actually prevents DNS leaks outside localhost).

You can also test classic DNS directly on `:53`:

```bash
nslookup google.com 8.8.8.8
```

In STRICT mode it should time out (`no servers could be reached`).

Notes:
- `install-nftables` is safe to run repeatedly (it flushes `citadel_*` tables and removes historical duplicate `include` lines in `/etc/nftables.conf`).

### Rollback

```bash
sudo ./citadela_en.sh restore-system
```

### DNS Adblock (panel)

Files:
- `/etc/coredns/zones/custom.hosts`
- `/etc/coredns/zones/blocklist.hosts`
- `/etc/coredns/zones/combined.hosts`

Commands:

```bash
sudo ./citadela_en.sh adblock-status
sudo ./citadela_en.sh adblock-stats
sudo ./citadela_en.sh adblock-add example.com
sudo ./citadela_en.sh adblock-remove example.com
sudo ./citadela_en.sh adblock-edit
sudo ./citadela_en.sh adblock-rebuild
sudo ./citadela_en.sh adblock-query doubleclick.net
```

### Docs

- Polish notes: `CITADEL++_NOTES.md`
- English notes: `CITADEL++_NOTES_EN.md`
- English script entrypoint: `citadela_en.sh`

Tracking improvements:
- If you want lightweight tracking for future changes, use GitHub Issues.

### GPL-3.0 in practice (FAQ)

- If you use/modify Citadel++ **only on your own machines** (home/lab) and you don't share copies with others: **you don't need to publish anything**.
- GPL obligations apply when you **distribute** (convey) a copy of the script or a modified version.
- If you distribute it, you must:
  - keep it under GPL-3.0,
  - provide the corresponding source (for bash: the script itself),
  - avoid adding extra restrictions for recipients.

### Poland-focused optimizations

- The PolishFilters list (PPB / Polish Annoyance) is included as one of the blocklist sources.
- The stack is geared towards a local CoreDNS resolver with encrypted upstream (DNSCrypt/DoH), which is a sensible default for PL/EU.

If you want to tune upstream resolvers specifically for Poland/EU:
- Edit `server_names` in `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` and pick your preferred resolvers.
- After changes:

```bash
sudo systemctl restart dnscrypt-proxy
sudo ./citadela_en.sh verify
```
