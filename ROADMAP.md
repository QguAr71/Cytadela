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

## ✅ Completed (v3.1 - 2026-01-30)

### Code optimization

- ✅ **Deduplikacja PL/EN** (Issue #11)
  - Wydzielono wspólną logikę do `/opt/cytadela/lib/`
  - Wrappery `cytadela++.sh` i `citadela_en.sh` (150 linii każdy)
  - Zysk: ~3200 linii mniej (45% redukcja)

- ✅ **Modularyzacja** (Issue #12)
  - 23 moduły funkcjonalne w `/opt/cytadela/modules/`
  - Lazy loading — moduły ładowane tylko gdy potrzebne
  - Auto-discovery komend

### New features (v3.1)

- ✅ **Interactive Installer** (Issue #25)
  - Terminal GUI z whiptail
  - Checklist modułów (required vs optional)
  - Komenda `install-wizard`

- ✅ **Auto-update blocklist** (Issue #13)
  - Systemd timer do automatycznej aktualizacji
  - Integracja z LKG fallback
  - Komendy: `auto-update-enable/disable/status/now/configure`

- ✅ **Backup/Restore config** (Issue #14)
  - `config-backup` — pełny backup do tar.gz
  - `config-restore` — restore z backupu
  - Komendy: `config-backup/restore/list/delete`

- ✅ **DNS Cache Stats** (Issue #15)
  - Komenda `cache-stats` z Prometheus metrics
  - Hit rate, latency, request types, response codes
  - Komendy: `cache-stats/top/reset/watch`

- ✅ **Desktop Notifications** (Issue #16)
  - Powiadomienia systemowe (libnotify)
  - Komendy: `notify-enable/disable/status/test`
  - Hook functions dla integracji

- ✅ **Multi-blocklist support** (Issue #17)
  - 6 profili: light/balanced/aggressive/privacy/polish/custom
  - Komendy: `blocklist-list/switch/status/add-url/remove-url`
  - Automatyczny backup przed zmianą

- ⏳ **Web Dashboard** (Issue #18)
  - Prosty lokalny dashboard (localhost:9154)
  - Status serwisów, metrics, blocked domains
  - Opcjonalny (nie wymagany do działania)
  - **Status:** Odłożone na v3.4+

---

## 🔄 Planned (v3.2+ - Home Users Focus)

### Gateway Mode (PRIORYTET #1)

- **Network Gateway** (v3.2)
  - Cytadela++ jako gateway dla całej sieci domowej
  - DHCP server (dnsmasq lub systemd-networkd)
  - NAT & routing (NFTables)
  - Per-device statistics
  - Device management (block/unblock)
  - Komendy: `gateway-wizard`, `gateway-status`, `gateway-devices`, `gateway-stats`
  - **Wymagania:** 2x Ethernet, 2 GB RAM, stary PC (150-300 zł)
  - **Effort:** ~15-20h

### User Experience (v3.2-v3.3)

- **Terminal UI (TUI)** (v3.2)
  - Prosty interface w terminalu (ncurses)
  - Dashboard, statystyki, zarządzanie
  - Działa przez SSH
  - Dla początkujących użytkowników

- **Parental Control** (v3.3)
  - Profile dla dzieci
  - Time schedules (internet 8-20)
  - Category blocking (adult, gambling, social media)
  - Activity reports
  - Komendy: `parental-add/set/block/report`

### Automation (v3.3-v3.4)

- **Full Auto-update** (v3.3)
  - Auto-update wszystkiego (blocklist, resolvers, CoreDNS, skrypty)
  - Backup przed każdą aktualizacją
  - Auto-rollback przy błędzie

- **Full Backup/Restore** (v3.3)
  - 1 komenda = pełny backup
  - Łatwa migracja na nowy komputer
  - Cloud backup (opcjonalnie)

- **Web UI** (v3.4 - opcjonalnie)
  - Lekki backend (Python Flask / Go)
  - Podstawowe funkcje (status, stats, blocklist)
  - Tylko dla użytkowników którzy nie chcą CLI
  - **NIE** pełny dashboard jak Pi-hole

---

## 🚀 Advanced Features (v3.5+ - Future)

### Enterprise-grade (opcjonalnie)

- **Grafana / Prometheus Integration** (Issue #19)
  - Historyczne dane, dashboardy
  - Dla zaawansowanych użytkowników

- **IDS DNS** (Issue #20)
  - DNS traffic analysis
  - DGA detection, C2 domains
  - Suricata/Zeek integration

- **Per-device Policy** (Issue #21)
  - Różne polityki per MAC/IP
  - Kids/Work/IoT modes

- **DNS Sinkhole** (Issue #22)
  - Internal sinkhole
  - Threat intelligence feeds

- **Immutable OS Integration** (Issue #23)
  - Fedora Silverblue, NixOS
  - Docker/Podman support

- **Geo/ASN Firewall** (Issue #24)
  - Geograficzne blokowanie
  - Dynamiczne ASN updates

---

## 📋 Notes

- **Focus:** Użytkownicy domowi i małe firmy (nie korporacje)
- **Filozofia:** Prostota, bezpieczeństwo, prywatność - bez korporacyjnego bełkotu
- **ISP-agnostic:** Bez założeń o konkretnym ISP (Orange/FunBox)
- **Safe operations:** Network resets muszą ostrzegać o utracie połączenia
- **Backward compatibility:** Nowe features nie mogą psuć istniejącej funkcjonalności
- **Optional features:** Nowe funkcje powinny być opcjonalne
- **Polish-first:** Pełna dokumentacja PL, wsparcie społeczności polskiej

---

## 🎯 Priorities

**v3.2 (Q1 2026):**
1. Gateway Mode (PRIORYTET!)
2. Terminal UI (TUI)
3. Bug fixes

**v3.3 (Q2 2026):**
1. Parental Control
2. Full Auto-update
3. Full Backup/Restore

**v3.4+ (Q3+ 2026):**
1. Web UI (opcjonalnie)
2. Advanced features (IDS, Per-device Policy, etc.)

---

**Więcej szczegółów:** Zobacz `ROADMAP_HOME_USERS.md` i `COMPARISON_VS_COMPETITORS.md`
