# Roadmap

This file tracks planned changes and feature ideas. It is intentionally short and outcome-oriented.

---

## ✅ Completed (v3.0 - 2026-01-25)

### IPv6
- ✅ **IPv6 Reset (deep reset)** — `ipv6-deep-reset` command
- ✅ **IPv6 Privacy: auto-ensure** — `ipv6-privacy-auto` command

### Operational hardening
- ✅ **Fail-fast + better debugging** — Global `trap ERR` handler
- ✅ **Panic-bypass / recovery mode** — `panic-bypass`, `panic-restore`, `panic-status`
- ✅ **Systemd restart/watchdog + health checks** — `health-install`, `health-status`

### Supply chain / updates
- ✅ **Supply-chain protection** — `supply-chain-init`, `supply-chain-verify`
- ✅ **Integrity Layer (Local-First)** — `integrity-init`, `integrity-check`
- ✅ **LKG Blocklist Cache** — `lkg-save`, `lkg-restore`, `lists-update`

### nftables observability
- ✅ **Optional nft debug chain** — `nft-debug-on`, `nft-debug-off`, `nft-debug-status`

### Location-aware security
- ✅ **Location-aware firewall advisory** — `location-check`, `location-add-trusted`

### Network stack detection
- ✅ **Detect network manager** — `discover_network_stack()`
- ✅ **`discover` command** — network + firewall sanity snapshot

### Firewall / exposure audit
- ✅ **Ghost-Check (port audit)** — `ghost-check` command

---

## 🔄 Planned / Ideas (v3.1+)

### Code optimization

- **Deduplikacja PL/EN** (Issue #11)
  - Wydzielić wspólną logikę do `/opt/cytadela/lib/cytadela-core.sh`
  - Wrappery `cytadela++.sh` i `citadela_en.sh` tylko z tłumaczeniami
  - Zysk: ~3000 linii mniej do utrzymania

- **Modularyzacja** (Issue #12)
  - Podzielić skrypt na moduły: `health.sh`, `location.sh`, `ipv6.sh`, etc.
  - Lazy loading — ładuj tylko potrzebne moduły
  - Zysk: szybsze uruchamianie, łatwiejszy rozwój

### New features

- **Auto-update blocklist** (Issue #13)
  - Systemd timer do automatycznej aktualizacji blocklist
  - Integracja z LKG fallback
  - Konfigurowalny interwał (daily/weekly)

- **Backup/Restore config** (Issue #14)
  - `config-backup` — eksport całej konfiguracji do archiwum
  - `config-restore` — import konfiguracji
  - Pliki: dnscrypt, coredns, nftables, cytadela state

- **DNS Cache Stats** (Issue #15)
  - Komenda `cache-stats` pokazująca:
    - Hit rate cache CoreDNS
    - Top blocked domains
    - Query count per hour

- **Desktop Notifications** (Issue #16)
  - Powiadomienia gdy health check fail
  - Integracja z `notify-send` / libnotify
  - Opcjonalne (wymaga DE)

- **Multi-blocklist support** (Issue #17)
  - Wybór między blocklist: Hagezi Pro/Light/Ultimate, OISD, Steven Black
  - Komenda `blocklist-switch <name>`
  - Predefiniowane URL-e z hashami

- **Web Dashboard** (Issue #18)
  - Prosty lokalny dashboard (localhost:9154)
  - Status serwisów, metrics, blocked domains
  - Opcjonalny (nie wymagany do działania)

### DNS resiliency

- **DNS bypass / switcher (emergency)** (Low priority)
  - Ryzykowne — może osłabić ochronę
  - Rozważyć tylko jeśli panic-bypass nie wystarczy

---

## Notes

- Features should be ISP-agnostic (no Orange/FunBox assumptions).
- Prefer safe operations; network resets must warn about dropping connectivity.
- Optimization should not break existing functionality.
- New features should be optional and not increase complexity for basic users.
