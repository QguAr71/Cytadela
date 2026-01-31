# Changelog

All notable changes to this repository will be documented in this file.

## [3.1.0] - 2026-01-31 - STABLE

### Major Changes

#### Repository Reorganization
- Reorganized repository structure with professional layout
- Created `docs/` directory (user, developer, roadmap, comparison)
- Created `legacy/` directory for v3.0 monolithic scripts
- Created `tests/` directory for all test files
- Renamed main scripts: `cytadela++.new.sh` → `citadel.sh`
- Removed 9 obsolete files

#### Documentation
- **NEW:** Complete Polish manual (MANUAL_PL.md, 1,621 lines)
- **NEW:** Complete English manual (MANUAL_EN.md)
- **NEW:** 7 languages support documentation (PL, EN, DE, ES, IT, FR, RU)
- **NEW:** Graphical installer documentation (install-wizard)
- **NEW:** Architecture documentation (CITADEL-STRUCTURE.md with Mermaid diagrams)
- **NEW:** Modules logic map (MODULES-LOGIC-MAP.md)
- **NEW:** Refactoring plans for v3.2:
  - Unified interface proposal (REFACTORING-UNIFIED-INTERFACE.md)
  - Function duplication analysis (FUNCTION-DUPLICATION-ANALYSIS.md)
  - Total benefits analysis (REFACTORING-TOTAL-BENEFITS.md)
- Updated README.md with v3.1.0 STABLE and v3.2.0 PLANNED status
- Updated quick-start.md with installation modes and legacy info

#### Roadmap Updates
- Updated roadmap with v3.2-v3.5+ plans
- Created 3 new Issues for v3.3:
  - Issue #26: Parental Control
  - Issue #27: Full Auto-update
  - Issue #28: Full Backup/Restore
- Moved Issues #19-24 to distant future (v3.5+)

#### New Modules
- `modules/fix-ports.sh` - Port conflict resolution
- `modules/edit-tools.sh` - Config editing tools
- `modules/install-dashboard.sh` - Terminal dashboard
- `modules/advanced-install.sh` - Kernel optimization, DoH parallel
- `modules/test-tools.sh` - Safe test, DNS test

#### Bug Fixes
- Fixed module aliases: `smart_ipv6()`, `killswitch_on()`, `killswitch_off()`
- Fixed GitHub Actions workflows (shellcheck.yml, smoke-tests.yml)
- Updated paths to new file names and legacy/ directory

#### Installation Modes
- **Option A:** Graphical wizard (`install-wizard`) - 7 languages, interactive
- **Option B:** CLI for hardcore users (`install-all`) - fast, no GUI
- Both modes fully documented in manuals and quick-start

### Refactoring Plans (v3.2)

Based on user observations about interface chaos and function duplication:
- **Unified module interface:** 29 → 6 modules (-79%)
- **Function deduplication:** 17 duplications → 0 (-100%)
- **Total code reduction:** ~8,000 → ~4,800 lines (-40%)
- **Commands reduction:** 101 → ~30 (-70%)
- **User steps reduction:** 4.5 → 1 average (-78%)

### Statistics
- 53 files changed
- +7,787 lines added
- -3,389 lines removed
- 18 files moved to docs/
- 6 files moved to legacy/
- 5 tests moved to tests/

### Credits
- User observations about interface chaos and function duplication inspired v3.2 refactoring plans

---

## Unreleased

- Add fail-fast dependency checks in install modules.
- Add optional DNSSEC toggle for generated DNSCrypt config (`CITADEL_DNSSEC=1` or `--dnssec`).
- Make Arch/CachyOS-specific helper modules degrade gracefully when `pacman`/`yay` are missing.
- Lower priority tuning aggressiveness in `optimize-kernel`.

## 2026-01-23

- Make CoreDNS install resilient when DNSCrypt port changes (bootstrap CoreDNS forward to current port during downloads).
- Add DNS adblock panel (`adblock-*`) and hardened blocklist parsing + atomic updates.
- Fix CoreDNS hosts usage by combining custom + blocklist into a single `combined.hosts`.
- Fix CoreDNS hosts file permissions for `User=coredns`.
- Add `install-all` healthcheck (DNS + adblock).
- Add bilingual docs (`README.md`, notes PL/EN) and English script entrypoint (`citadela_en.sh`).
- Make nftables install idempotent (flush tables + dedupe include line).
- Update docs: recommend `verify` + leak test after updates.
