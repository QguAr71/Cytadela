# Roadmap

Ten plik śledzi planowane zmiany i pomysły na funkcje. Jest celowo krótki i zorientowany na wyniki.

---

## ✅ Zakończone (v3.0 - 2026-01-25)

### IPv6
- ✅ **IPv6 Reset (deep reset)** — Komenda `ipv6-deep-reset`
- ✅ **IPv6 Privacy: auto-ensure** — Komenda `ipv6-privacy-auto`

### Wzmocnienie operacyjne
- ✅ **Fail-fast + lepsze debugowanie** — Globalny handler `trap ERR`
- ✅ **Panic-bypass / tryb odzyskiwania** — `panic-bypass`, `panic-restore`, `panic-status`
- ✅ **Systemd restart/watchdog + health checks** — `health-install`, `health-status`

### Supply chain / aktualizacje
- ✅ **Ochrona supply-chain** — `supply-chain-init`, `supply-chain-verify`
- ✅ **Warstwa integralności (Local-First)** — `integrity-init`, `integrity-check`
- ✅ **LKG Blocklist Cache** — `lkg-save`, `lkg-restore`, `lists-update`

### nftables obserwowalność
- ✅ **Opcjonalny łańcuch debug nft** — `nft-debug-on`, `nft-debug-off`, `nft-debug-status`

### Bezpieczeństwo świadome lokalizacji
- ✅ **Firewall advisory świadomy lokalizacji** — `location-check`, `location-add-trusted`

### Wykrywanie stosu sieciowego
- ✅ **Wykrywanie network managera** — `discover_network_stack()`
- ✅ **Komenda `discover`** — snapshot sieci + firewall sanity

### Firewall / audyt ekspozycji
- ✅ **Ghost-Check (audyt portów)** — Komenda `ghost-check`

---

## ✅ Zakończone (v3.1 - 2026-01-31) - STABILNE

### Optymalizacja kodu

- ✅ **Deduplikacja PL/EN** (Issue #11)
  - Wydzielono wspólną logikę do `/opt/cytadela/lib/`
  - Wrappery `cytadela++.sh` i `citadela_en.sh` (150 linii każdy)
  - Zysk: ~3200 linii mniej (45% redukcja)

- ✅ **Modularyzacja** (Issue #12)
  - 29 modułów funkcjonalnych w `/modules/`
  - Lazy loading — moduły ładowane tylko gdy potrzebne
  - Auto-discovery komend

### Nowe funkcje (v3.1)

- ✅ **Interaktywny Instalator** (Issue #25)
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

- ✅ **Terminal Dashboard** (Issue #18)
  - Terminal dashboard `citadel-top` z real-time monitoring
  - Status serwisów, metryki Prometheus, wydajność systemu
  - Komenda: `install-dashboard`
  - Opcjonalny (nie wymagany do działania)

### Internacjonalizacja (i18n)

- ✅ **7 języków** - Pełne wsparcie wielojęzyczne
  - Polski (pl), English (en), Deutsch (de)
  - Español (es), Italiano (it), Français (fr), Русский (ru)
  - Pełne tłumaczenia: installer, moduły, komunikaty, logi
  - Automatyczna detekcja języka z $LANG
  - System i18n w `/lib/i18n/`

### Poprawki błędów & Migracja Legacy (2026-01-31)

- ✅ **Naprawa smart-ipv6** - dodano alias funkcji w module ipv6.sh
- ✅ **Naprawa killswitch** - dodano aliasy funkcji w module emergency.sh
- ✅ **Migracja z legacy** - przeniesiono 18 brakujących funkcji:
  - `fix-ports` - rozwiązywanie konfliktów portów
  - `blocklist`, `combined`, `custom` - aliasy adblock-show
  - `edit`, `edit-dnscrypt`, `logs` - edycja i logi
  - `install-dashboard` - terminal dashboard
  - `optimize-kernel` - optymalizacja priorytetów
  - `install-doh-parallel` - DoH parallel racing
  - `install-editor` - integracja edytora
  - `safe-test`, `test` - narzędzia testowe
- ✅ **Reorganizacja repozytorium** - profesjonalna struktura:
  - `docs/` - uporządkowana dokumentacja (user/developer/roadmap)
  - `legacy/` - legacy v3.0 oddzielone z dokumentacją
  - Nowa nazwa: `citadel.sh` (było: cytadela++.new.sh)
  - Usunięto 9 niepotrzebnych plików
  - Utworzono 5 nowych modułów

---

## 🔄 Planowane (v3.2+ - Focus na Użytkownikach Domowych)

### Tryb Gateway (PRIORYTET #1)

- **Network Gateway** (v3.2)
  - Cytadela jako gateway dla całej sieci domowej
  - DHCP server (dnsmasq lub systemd-networkd)
  - NAT & routing (NFTables)
  - Statystyki per-device
  - Zarządzanie urządzeniami (block/unblock)
  - Komendy: `gateway-wizard`, `gateway-status`, `gateway-devices`, `gateway-stats`
  - **Wymagania:** 2x Ethernet, 2 GB RAM, stary PC (150-300 zł)
  - **Effort:** ~15-20h

### Doświadczenie Użytkownika (v3.2-v3.3)

- **Terminal UI (TUI)** (v3.2)
  - Prosty interface w terminalu (ncurses)
  - Dashboard, statystyki, zarządzanie
  - Działa przez SSH
  - Dla początkujących użytkowników

- **Kontrola Rodzicielska** (v3.3)
  - Profile dla dzieci
  - Time schedules (internet 8-20)
  - Blokowanie kategorii (adult, gambling, social media)
  - Raporty aktywności
  - Komendy: `parental-add/set/block/report`

### Automatyzacja (v3.3-v3.4)

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

## 🔄 Planowane (v3.3 - Automatyzacja & Kontrola)

### Kontrola Rodzicielska (Issue #26)

- **Kontrola rodzicielska** (v3.3)
  - Profile dla dzieci (Kids, Teens)
  - Time schedules (internet 8-20, weekends)
  - Blokowanie kategorii (adult, gambling, social media, gaming)
  - Raporty aktywności (daily/weekly)
  - Komendy: `parental-add`, `parental-set`, `parental-block`, `parental-report`
  - **Effort:** ~10-15h

### Full Auto-update (Issue #27)

- **Pełna automatyczna aktualizacja** (v3.3)
  - Auto-update wszystkiego: blocklist, resolvers, CoreDNS, skrypty
  - Automatyczny backup przed każdą aktualizacją
  - Auto-rollback przy błędzie
  - Powiadomienia o aktualizacjach
  - Komendy: `full-update-enable`, `full-update-status`, `full-update-rollback`
  - **Effort:** ~8-12h

### Full Backup/Restore (Issue #28)

- **Pełny backup/restore systemu** (v3.3)
  - 1 komenda = pełny backup (config + blocklists + state)
  - Łatwa migracja na nowy komputer
  - Cloud backup (opcjonalnie - Nextcloud, rsync)
  - Scheduled backups (daily/weekly)
  - Komendy: `full-backup`, `full-restore`, `full-backup-schedule`
  - **Effort:** ~6-10h

---

## 🚀 Zaawansowane Funkcje (v3.5+ - Daleka Przyszłość)

### Advanced-grade (opcjonalnie, niska priorytet)

- **Grafana / Prometheus Integration** (Issue #19) - **v3.5+**
  - Historyczne dane, dashboardy
  - Dla zaawansowanych użytkowników
  - **Status:** Daleka przyszłość

- **IDS DNS** (Issue #20) - **v3.5+**
  - DNS traffic analysis
  - DGA detection, C2 domains
  - Suricata/Zeek integration
  - **Status:** Daleka przyszłość

- **Per-device Policy** (Issue #21) - **v3.5+**
  - Różne polityki per MAC/IP
  - Kids/Work/IoT modes
  - **Status:** Daleka przyszłość

- **DNS Sinkhole** (Issue #22) - **v3.5+**
  - Internal sinkhole
  - Threat intelligence feeds
  - **Status:** Daleka przyszłość

- **Immutable OS Integration** (Issue #23) - **v3.5+**
  - Fedora Silverblue, NixOS
  - Docker/Podman support
  - **Status:** Daleka przyszłość

- **Geo/ASN Firewall** (Issue #24) - **v3.5+**
  - Geograficzne blokowanie
  - Dynamiczne ASN updates
  - **Status:** Daleka przyszłość

---

## 📋 Notatki

- **Focus:** Użytkownicy domowi i małe firmy (nie korporacje)
- **Filozofia:** Prostota, bezpieczeństwo, prywatność - bez korporacyjnego bełkotu
- **ISP-agnostic:** Bez założeń o konkretnym ISP (Orange/FunBox)
- **Safe operations:** Network resets muszą ostrzegać o utracie połączenia
- **Backward compatibility:** Nowe features nie mogą psuć istniejącej funkcjonalności
- **Optional features:** Nowe funkcje powinny być opcjonalne
- **Polish-first:** Pełna dokumentacja PL, wsparcie społeczności polskiej

---

## 🎯 Priorytety

**v3.2 (Q1 2026):**
1. Tryb Gateway (PRIORYTET!)
2. Terminal UI (TUI)
3. Poprawki błędów

**v3.3 (Q2 2026):**
1. Kontrola Rodzicielska (Issue #26)
2. Full Auto-update (Issue #27)
3. Full Backup/Restore (Issue #28)

**v3.4+ (Q3+ 2026):**
1. Web UI (opcjonalnie)

**v3.5+ (Daleka przyszłość):**
1. Advanced features (Issues #19-24) - Advanced-grade, niska priorytet

---

**Więcej szczegółów:** Zobacz `ROADMAP_HOME_USERS.md` i `COMPARISON_VS_COMPETITORS.md`
