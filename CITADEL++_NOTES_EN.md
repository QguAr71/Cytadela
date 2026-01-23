# Citadel++ — notes / how to use it (without losing internet)

This document explains:
- what was changed in `cytadela++.sh` compared to earlier iterations,
- what “DNS leak blocking outside localhost” means,
- a safe installation and system switch workflow,
- the `verify` self-check command.

It also includes an up-to-date description of:
- the DNS-adblock management panel (blocklist/custom),
- the automatic healthcheck after `install-all`.

## TL;DR (safe workflow)

1. Install components:

```bash
sudo ./cytadela++.sh install-all
```

2. Load firewall rules in SAFE mode:

```bash
sudo ./cytadela++.sh install-nftables
sudo ./cytadela++.sh firewall-safe
```

3. Verify local DNS:

```bash
dig +short google.com @127.0.0.1
```

4. Only then switch system DNS:

```bash
sudo ./cytadela++.sh configure-system
```

`configure-system` automatically:
- switches firewall to SAFE,
- changes system DNS settings,
- tests `dig @127.0.0.1 google.com`,
- if test succeeds → switches firewall to STRICT,
- if test fails → keeps SAFE and prints rollback command.

5. Verify everything:

```bash
sudo ./cytadela++.sh verify
```

6. Rollback (if something goes wrong):

```bash
sudo ./cytadela++.sh restore-system
```

---

## What is “DNS leak blocking outside localhost”

### Definition

A **DNS leak** here means a situation where an application or the OS sends DNS queries **in plaintext** directly to external resolvers (e.g. ISP/router DNS, `8.8.8.8:53`) instead of using your local stack (CoreDNS → DNSCrypt).

**“DNS leak blocking outside localhost”** means the firewall blocks outbound DNS traffic on port `53` (UDP/TCP) **to the internet**, while still allowing DNS to `127.0.0.1` (localhost).

### Why it exists

- It forces *all* apps to use the local resolver (CoreDNS) rather than bypassing it.
- It prevents a mixed situation where some queries go encrypted (DNSCrypt) while others “leak” via classic DNS.

### Important limitation

This mostly applies to classic DNS (`UDP/TCP 53`).
If an application uses built-in **DoH** (DNS-over-HTTPS) over port `443`, that is not a “DNS leak on port 53”, and these rules do not stop it.

---

## Full list of functions / commands

Run commands as:

```bash
sudo ./cytadela++.sh <command>
```

### Installation & configuration

- **`install-dnscrypt`**: installs/configures `dnscrypt-proxy` (with `[sources]`), picks a free port, starts service.
- **`install-coredns`**: installs/configures CoreDNS (blocking + caching + forward to DNSCrypt), Prometheus metrics on `127.0.0.1:9153`.
- **`install-nftables`**: generates NFTables rules for SAFE/STRICT and loads SAFE by default.
- **`install-all`**: runs DNSCrypt → CoreDNS → NFTables (without switching system DNS) and then performs a short DNS/Adblock healthcheck.

### System DNS (switch / rollback)

- **`configure-system`**: switches system DNS to Citadel++ (SAFE → test DNS → STRICT).
- **`restore-system`**: restores `systemd-resolved` and system DNS settings (rollback).

### Firewall modes (DNS leak prevention)

- **`firewall-safe`**: SAFE mode — designed to not break connectivity during deployment.
- **`firewall-strict`**: STRICT mode — full DNS leak block outside localhost.

### Emergency modes

- **`emergency-refuse`**: CoreDNS sets `refuse` (rejects all DNS queries).
- **`emergency-restore`**: restores normal mode (Corefile from backup + service restarts).
- **`killswitch-on`**: emergency DNS kill-switch.
- **`killswitch-off`**: disables kill-switch.

### Diagnostics & control

- **`status`**: service status (`dnscrypt-proxy`, `coredns`, `nftables`).
- **`diagnostics`**: extended diagnostics (DNS test, metrics, logs, rules, blocklist).
- **`verify`**: quick self-check for the whole stack (ports/services/NFT/DNS/metrics).
- **`safe-test`**: checks without switching system DNS.

### Additional modules & tools

- **`smart-ipv6`**: detects IPv6 and toggles `ipv6_servers` in DNSCrypt.
- **`install-dashboard`**: installs `citadel-top` dashboard.
- **`install-editor`**: installs `citadel` wrapper (edit configs + auto-restart).
- **`optimize-kernel`**: installs service/timer to tune DNS process priorities.
- **`install-doh-parallel`**: generates optional DNSCrypt config for DoH parallel racing.
- **`fix-ports`**: helps diagnose port conflicts.

---

## DNS Adblock (management panel)

CoreDNS uses host-style lists and blocks domains by returning `0.0.0.0`.

Files:
- `/etc/coredns/zones/custom.hosts` — your manual entries (not overwritten by auto-update).
- `/etc/coredns/zones/blocklist.hosts` — automatically downloaded lists.
- `/etc/coredns/zones/combined.hosts` — file used by CoreDNS (custom + blocklist).

Important: CoreDNS runs as user `coredns`, so list files must be readable:
- `blocklist.hosts` and `combined.hosts`: owner `root:coredns`, permissions `0640`
- `custom.hosts`: `0644`

Panel commands:
- **`adblock-status`** — integration status (Corefile uses `combined.hosts`, counts).
- **`adblock-stats`** — line counts for custom/blocklist/combined.
- **`adblock-show custom|blocklist|combined`** — show first 200 lines.
- **`adblock-edit`** — edit `custom.hosts` + rebuild + reload.
- **`adblock-add <domain>`** — add a domain to custom (block it).
- **`adblock-remove <domain>`** — remove a domain from custom.
- **`adblock-rebuild`** — rebuild `combined.hosts` + reload CoreDNS.
- **`adblock-query <domain>`** — query a domain via local DNS (`127.0.0.1`).

---

## What changed vs. the original version

1. **`install-all` does not automatically call `configure-system`**

This is intentional: switching system DNS is the riskiest step. You do it consciously.

2. **NFTables has two modes: SAFE and STRICT**

- `firewall-safe`: exceptions to avoid breaking connectivity during setup.
- `firewall-strict`: hard protection: blocks DNS `:53` outside localhost.

3. **`configure-system` switches to STRICT only after a successful DNS test**

Safety mechanism: SAFE → switch DNS → test → STRICT.

4. **DNSCrypt has proper resolver sources**

Generated config contains a `[sources]` section with resolver URLs and `minisign_key` so dnscrypt-proxy can load `server_names`.

5. **`install-coredns` uses “bootstrap DNS” and hardened list downloads**

To prevent losing name resolution while downloading lists (especially if system DNS is already set to `127.0.0.1`), the script first starts a temporary CoreDNS forwarder to the current DNSCrypt port.

Downloads are hardened:
- `curl -f` (HTTP errors fail the download),
- temp-file generation,
- swap-in only if a minimum entry count is met (prevents “zeroing” the list),
- PolishFilters source uses `PPB.txt` (working URL).

---

## `verify` command

```bash
sudo ./cytadela++.sh verify
```

Checks:
- detected DNSCrypt/CoreDNS ports,
- `dnscrypt-proxy` and `coredns` service status,
- whether `inet citadel_dns` table is loaded,
- active firewall mode (SAFE/STRICT) based on `/etc/nftables.d/citadel-dns.nft` symlink,
- local DNS test (`dig @127.0.0.1`),
- Prometheus metrics endpoint availability (`http://127.0.0.1:9153/metrics`).

---

## Quick post-install diagnostics

```bash
sudo ./cytadela++.sh verify
sudo ./cytadela++.sh diagnostics
citadel-top
```

---

## Rollback

If after `configure-system` anything becomes unstable:

```bash
sudo ./cytadela++.sh restore-system
```

This restores:
- `systemd-resolved` (unmask + enable + start),
- removes NetworkManager override,
- fixes `/etc/resolv.conf`.

---

## FAQ / Common issues

### 1) `curl: (6) Could not resolve host ...` during `install-all` / `install-coredns`

It means the system temporarily has **no working resolver**, so `curl` cannot resolve names.

What to do:
- Re-run `sudo ./cytadela++.sh install-coredns`.
- Check local DNS:

```bash
dig +short google.com @127.0.0.1
```

If it fails, check logs:

```bash
journalctl -u coredns -n 50 --no-pager
journalctl -u dnscrypt-proxy -n 50 --no-pager
```

### 2) `curl: (22) The requested URL returned error: 404` while downloading lists

One of the list sources changed URL.

The script is hardened to **not zero out lists** in that case (keeps previous working data).
You can re-run `install-coredns` later.

### 3) `nftables.service` is `inactive (dead)` — is the firewall working?

Yes, often normal (oneshot unit loads rules and exits).
Check Citadel rules in the ruleset:

```bash
sudo nft list ruleset | grep -i citadel
```

### 4) Adblock does not work (domain resolves to real IP)

Most common causes:

- **File permissions**: CoreDNS runs as `coredns` and must read the lists.
  Required:
  - `blocklist.hosts` and `combined.hosts`: `root:coredns` + `0640`
  - `custom.hosts`: `0644`

Check:

```bash
stat -c '%U %G %a %n' /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts
```

Fix (safe):

```bash
sudo ./cytadela++.sh adblock-rebuild
sudo systemctl restart coredns
```

- **Cache**: after changing `custom.hosts`, sometimes restart CoreDNS.

Test:

```bash
sudo ./cytadela++.sh adblock-query doubleclick.net
```

### 5) `install-all` healthcheck shows FAIL

First run:

```bash
sudo ./cytadela++.sh verify
sudo ./cytadela++.sh adblock-status
```

If `verify` is OK but healthcheck failed, usually helps:

```bash
sudo systemctl restart coredns
```
