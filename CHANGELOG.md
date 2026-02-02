# Changelog

All notable changes to this repository will be documented in this file.

## [3.1.1] - 2026-02-01 - MAINTENANCE RELEASE

### 🎉 All TODO Items Completed
- **ShellCheck:** Zero warnings across entire codebase (43 files)
- **Security:** Rate limiting, input validation, credential audit
- **Testing:** Comprehensive smoke tests + BATS suite (47 test cases)
- **Documentation:** Complete docstrings, examples, README enhancement
- **Internationalization:** v3.2+ features in 7 languages
- **Code Quality:** shfmt formatting, error messages, progress indicators

### 🔧 Code Quality Improvements
- **ShellCheck Fixes:** Fixed SC2034 warnings in 14 modules
- **Code Formatting:** Applied shfmt to all shell scripts (4 spaces, case indentation)
- **Error Messages:** Enhanced with usage examples and better descriptions
- **Progress Indicators:** Added animated spinners for long operations

### 📚 Documentation Enhancements
- **Function Documentation:** Added comprehensive docstrings to 10 critical functions
- **Example Scripts:** Created 3 setup/recovery scripts with error handling
- **README Update:** Enhanced with badges, dashboard preview, comparison table, quick links
- **BATS Tests:** Complete test suite with unit and integration tests

### 🌍 Internationalization
- **Advanced Features:** Added v3.2+ feature translations in DE, FR, ES, IT, RU
- **Consistency:** Unified translation patterns across all languages
- **Coverage:** Honeypot enabled, Reputation system active, ASN blocking configured

### 🛡️ Security Enhancements
- **Rate Limiting:** Implemented for panic-bypass (3 attempts per 60s)
- **Input Validation:** Verified proper domain validation in adblock functions
- **Credential Audit:** Confirmed no hardcoded secrets (only public keys)
- **Eval Usage:** Verified no eval usage in codebase

### 🧪 Testing Infrastructure
- **Smoke Tests:** Added tests for help, version, root check, status, check-deps
- **BATS Suite:** 47 test cases covering module loader, network utils, installation
- **Test Helpers:** 20+ utility functions for testing automation
- **CI Ready:** Tests designed for continuous integration environments

### 🎨 User Experience
- **Help Text:** Restructured with emojis and better organization
- **Status Output:** Enhanced with color coding and additional sections
- **Error Handling:** More descriptive messages with examples
- **Progress Feedback:** Visual indicators for long-running operations

### 📊 Statistics
- **Commits:** 7 commits in this release
- **Files Changed:** 60 files
- **Lines Added:** 3,125
- **Lines Removed:** 849
- **Net Change:** +2,276 lines
- **Test Coverage:** 47 BATS test cases + 5 smoke tests

---

## [3.1.2] - 2026-02-01 - MAINTENANCE RELEASE

### Metrics & Monitoring
- **NEW:** Prometheus metrics export module (`modules/prometheus.sh`)
  - Service status, DNS resolution, cache metrics
  - Blocklist statistics, firewall status, system load
  - HTTP metrics server on port 9100
- **NEW:** Grafana dashboard template (`docs/grafana-dashboard.json`)
  - 8 panels: services, cache, DNS requests, blocklist, firewall, load, version
- **NEW:** Performance benchmarks module (`modules/benchmark.sh`)
  - DNS performance testing (dnsperf)
  - Cache hit/miss ratio tests
  - Blocklist lookup performance
  - Comprehensive benchmark suite
  - Historical tracking and comparison

### Packaging & Distribution
- **NEW:** Docker image (`Dockerfile`)
  - Based on Arch Linux for maximum compatibility
  - Multi-service compose with optional Prometheus/Grafana
  - Health checks and persistent volumes
  - Host networking for optimal DNS performance
- **NEW:** Docker Compose (`docker-compose.yml`)
  - Basic DNS service profile
  - Monitoring profile with Prometheus + Grafana
  - Persistent volumes for config and data
- **NEW:** AUR Package (`PKGBUILD`)
  - Arch Linux package support
  - Automatic dependency resolution
  - systemd integration ready
- **NEW:** Docker documentation (`docs/DOCKER.md`)
  - Quick start guide
  - Deployment instructions
  - Volume and port reference

### Statistics
- **Commits:** 7 in this release
- **Files Changed:** 25
- **Lines Added:** +2,000
- **Lines Removed:** -400
- **Net Change:** +1,600 lines

---

## [3.1.1] - 2026-02-01 - MAINTENANCE RELEASE

### Critical Bug Fixes
- Fixed `coredns-blocklist.timer` non-existent unit causing install-all failure
- Fixed `install-wizard` module key mismatch (supply-chain, nft-debug with spaces)
- Fixed module count in documentation (32 → 29 actual modules)

### Code Quality (Copilot Review)
- Added `set -o errtrace` for ERR trap propagation in functions
- Added early-fail checks for lib/modules directories existence
- Enhanced `call_fn` with empty argument validation
- Replaced raw `source` with `source_lib` in module-loader
- Improved `load_module_for_command` with exact match before prefix
- Added TTY detection to disable colors when not TTY (CI/logs)
- Converted log functions to use `printf` instead of `echo -e`
- Added file locking (flock) to rate_limit_check for thread safety

### CI/CD Infrastructure
- **NEW:** Comprehensive CI workflow (`ci-improved.yml`)
  - Separate jobs: shellcheck, smoke-tests, bats-tests, integration
  - Arch Linux container for integration tests
  - Proper fail-fast behavior (removed excessive || true)
  - Concurrency with cancel-in-progress
  - Caching for apt packages, shfmt binary
- **NEW:** Format check workflow (`format-check.yml`)
  - shfmt binary caching
  - Code formatting validation
- **NEW:** Release workflow (`release.yml`)
  - Automated GitHub releases on tag push
  - Auto-generated changelog from git history
  - Release artifacts (.tar.gz + SHA256 checksums)
- **NEW:** Package lists for cache keys

### Documentation
- **NEW:** Release instructions (`docs/RELEASE-INSTRUCTIONS.md`)
- **NEW:** Version management section in README
- **NEW:** Testing section with local testing instructions
- **UPDATED:** Fixed CITADEL-STRUCTURE.md module count and diagrams
- **UPDATED:** Added ShellCheck CI badge to README

### Statistics
- **Commits:** 13 in this release
- **Files Changed:** 55
- **Lines Added:** +2,800
- **Lines Removed:** -900
- **Net Change:** +1,900 lines

---

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

### Latest Updates (2026-01-31 Evening)

#### Code Quality Improvements
- **Refactored citadel.sh:** Added `call_fn()` helper for DRY dynamic function calls
- **Safe source:** Added `source_lib()` with file existence validation
- **Portability:** Added realpath fallback for systems without realpath
- **Bug fixes:** Fixed check-deps parameter bug (${2:-} → ${1:-} after shift)
- **Defensive coding:** Added defensive expansions (${EUID:-}, ${CYTADELA_MODE:-})
- **Exit codes:** Documented exit codes (0-4+)
- **ShellCheck:** 0 errors, improved compliance

#### CI/CD & Testing
- **GitHub Actions:** Added comprehensive lint-and-test workflow
  - ShellCheck (citadel.sh, lib/, modules/)
  - shfmt format checking
  - BATS tests (when available)
  - Security checks (hardcoded secrets, strict mode)
- **ShellCheckRC:** Improved configuration with inline annotation examples
- **Removed CodeQL:** Bash not supported, using ShellCheck instead

#### Documentation
- **Fixed placeholders:** Corrected 15 occurrences of yourusername → QguAr71/Cytadela
- **Refactoring plans:**
  - v3.2: Bash 5.0+ features, associative arrays, --silent flag
  - v3.3: Honeypot feature added
  - v3.4: Web Dashboard plan (2-3 weeks, htmx+Bash, HTTPS)
- **Aurora Mystica:** Marked as IS-ONLY-A-CONCEPT

#### Future Branding
- **Note:** Project will be rebranded to "Weles-SysQ" in v3.2 release
- **Rationale:** Weles - Slavic god of magic, oaths, and guardian of wealth/prosperity
  - Perfect metaphor: DNS as guardian/protector of internet gateway
  - Unique Slavic mythology (Polish roots)
  - No conflicts with existing DNS software
  - Easy pronunciation and memorable name

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
