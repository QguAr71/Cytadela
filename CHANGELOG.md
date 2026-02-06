# Changelog

All notable changes to this repository will be documented in this file.

## [3.4.0] - 2026-02-06

### 🌍 **Internationalization Expansion - 7 Languages Complete**

Complete expansion of internationalization support from 2 to 7 languages across all Citadel modules.

#### ✨ **New Languages Added**
- **German (de)** - Complete translation coverage for all modules
- **Spanish (es)** - Full Spanish localization
- **French (fr)** - Comprehensive French translations
- **Italian (it)** - Complete Italian language support
- **Russian (ru)** - Full Russian translations

#### 📊 **Translation Coverage Expansion**
- **Before:** 2 languages (Polish, English) - partial coverage
- **After:** 7 languages (pl, en, de, es, fr, it, ru) - complete coverage
- **Modules covered:** common, install, uninstall, recovery, help
- **Translation strings:** 1000+ strings per language
- **Quality assurance:** All strings use `${T_KEY:-fallback}` pattern

### 🏗️ **Comprehensive Modular Help System**

Complete overhaul of Citadel's help system with modern, user-friendly interfaces for all user levels.

#### 🖥️ **New TUI Interface (Terminal User Interface)**
- **Gum-powered interface** - Modern, beautiful terminal UI
- **Interactive menus** - Easy navigation for beginners
- **Search functionality** - Find commands and help instantly
- **Contextual help** - Smart suggestions based on system state

#### 💻 **New CLI Interface (Command Line Interface)**
- **Script-friendly** - Perfect for automation and advanced users
- **Detailed command info** - Examples, usage, and notes
- **JSON output support** - For programmatic usage
- **Search and filtering** - Quick access to specific information

#### 🎯 **Contextual Help System**
- **Workflow guidance** - Step-by-step tutorials for complex tasks
- **Smart suggestions** - Intelligent help based on current system state
- **First-time user guidance** - Complete installation walkthroughs
- **Troubleshooting assistance** - Problem-solving guides

#### 📚 **Comprehensive Documentation**
- **Modular JSON structure** - Easy to maintain and extend
- **5 core modules documented** - install, core, addons, advanced, emergency
- **Troubleshooting guides** - DNS connectivity, installation issues, firewall problems
- **Quick-start tutorials** - Get started in 5 minutes
- **Multi-language support** - All help content in 7 languages

### 🔧 **Architecture Improvements**

#### 📁 **New Help System Architecture**
```
lib/help/
├── framework/           # Core framework (help-core.sh)
├── interfaces/          # TUI, CLI, contextual interfaces
│   ├── tui/            # Gum-based terminal UI
│   ├── cli/            # Command-line interface
│   └── help-context.sh # Contextual help system
├── modules/             # Modular documentation
└── docs/               # Guides and tutorials
    ├── quick-start/    # Getting started guides
    └── troubleshooting/# Problem-solving guides
```

#### 🔗 **System Integration**
- **Seamless citadel.sh integration** - New help command structure
- **Automatic language detection** - Smart fallback to user preferences
- **Backward compatibility** - Old help commands still work
- **Multi-interface dispatch** - Automatic routing to appropriate interface

### 🎨 **User Experience Enhancements**

#### 👥 **Multi-Level User Support**
- **Beginners** → Interactive TUI with guided workflows
- **Advanced Users** → Fast CLI with detailed information
- **Developers** → Contextual help with technical details
- **System Admins** → Troubleshooting guides and diagnostics

#### 🌐 **International User Base**
- **7 languages** - Support for global user community
- **Consistent experience** - Same quality across all languages
- **Cultural adaptation** - Language-specific formatting and conventions

### 📊 **Implementation Statistics**
- **New files:** 35+ help system files
- **Translation strings:** 1000+ per language × 7 languages
- **Code lines:** 2000+ lines of new help system code
- **Documentation modules:** 5 core modules fully documented
- **Help interfaces:** 3 different user interfaces
- **Languages supported:** 7 complete language packs

### 🔄 **Breaking Changes**
- **New help command structure:**
  - `citadel help` → Interactive TUI (default)
  - `citadel help --cli command` → CLI help
  - `citadel help --context workflow` → Contextual guidance
- **Enhanced i18n coverage** - All user-facing text now localized

### 🎯 **Migration Path**
- **Automatic interface detection** - Smart routing based on context
- **Backward compatibility maintained** - Old help commands redirect appropriately
- **Progressive enhancement** - New features don't break existing usage

---

## [4.0.0] - 2026-02-04

### 🎉 **Major Release: Gateway Mode & Network Infrastructure**

Enterprise Security Platform v4.0 transforms Enterprise Security Platform from a DNS resolver into a full network gateway solution, enabling complete home/office network management.

### ✨ Added

#### 🚪 **Gateway Mode - Complete Network Gateway**
- **Full Network Gateway** - Transform Enterprise Security Platform into a network router/gateway
  - DHCP server integration (dnsmasq)
  - NAT and routing configuration
  - Network interface detection and management
  - Firewall rules for secure routing
- **Device Management** - Monitor and manage all network devices
  - Real-time device discovery and tracking
  - DHCP lease monitoring and management
  - ARP table integration for device visibility
  - Per-device network statistics
- **Interactive Gateway Wizard** - Easy setup for gateway mode
  - Automatic network interface detection
  - Guided configuration process
  - Network settings validation
  - One-command gateway activation
- **Gateway Services** - Production-ready gateway services
  - Systemd service integration
  - Service lifecycle management
  - Health monitoring and auto-recovery
  - Gateway-specific logging and metrics

#### 🛡️ **Network Security Infrastructure**
- **Advanced Firewall Management** - Gateway-specific firewall rules
  - NAT rule automation
  - DHCP traffic allowance
  - DNS query protection
  - Secure routing policies
- **Network Monitoring** - Comprehensive network visibility
  - Connected device enumeration
  - DHCP lease tracking
  - Network traffic monitoring
  - Gateway performance metrics

### 🔄 Changed

- **Architecture Expansion** - Citadel now supports dual modes
  - DNS Resolver Mode (original functionality)
  - Gateway Mode (new network infrastructure)
- **Service Architecture** - Enhanced service management
  - Gateway-specific services
  - Multi-interface network configuration
  - DHCP integration with DNS

#### �️ **Advanced IDS Integration**
- **Suricata Integration** - Network IDS for DNS traffic analysis
  - DNS-specific detection rules and signatures
  - Real-time DNS query monitoring and alerting
  - DGA (Domain Generation Algorithm) detection
  - DNS tunneling and amplification attack detection
  - Suspicious TLD and domain pattern analysis
- **Zeek Integration** - Advanced network analysis framework
  - DNS protocol analysis and logging
  - Entropy-based DGA detection algorithms
  - NXDOMAIN storm detection and alerting
  - Comprehensive DNS traffic pattern analysis
  - Scriptable analysis and alerting framework
- **DNS Threat Detection** - Advanced DNS security monitoring
  - Query flood detection and rate limiting
  - Suspicious domain pattern recognition
  - Fast flux domain detection
  - DNS zone transfer attempt detection
  - Comprehensive DNS security event logging

### 🔄 Changed

- **Security Architecture** - Enhanced threat detection capabilities
  - Multi-layered IDS approach with Suricata and Zeek
  - DNS-specific security monitoring and alerting
  - Integration with existing reputation and blocking systems
  - Advanced threat intelligence and pattern analysis

#### 🌐 **Web Dashboard - Complete Monitoring Interface**
- **Modern Web Interface** - Responsive HTML/CSS/JavaScript dashboard
  - Real-time system status monitoring and visualization
  - Security overview with threat metrics and alerts
  - Network device management and DHCP lease tracking
  - IDS alerts and status monitoring
  - Interactive controls with auto-refresh capabilities
- **Web Server Integration** - Nginx and Lighttpd support
  - Automatic web server configuration and deployment
  - Security hardening with proper headers and access controls
  - Static file caching and compression optimization
  - Reverse proxy for API endpoints
- **RESTful API Backend** - JSON API for data retrieval
  - System status, security metrics, and network information
  - Real-time data updates with automatic refresh
  - Error handling and status reporting
  - Extensible API design for future enhancements
- **User Experience** - Professional monitoring interface
  - Clean, modern design with intuitive navigation
  - Color-coded status indicators and alerts
  - Responsive layout for desktop and mobile devices
  - Accessibility features and keyboard navigation

### 🔄 Changed

- **User Interface Paradigm** - Web-based monitoring alongside CLI
  - Dual interface approach (CLI + Web) for different use cases
  - Web dashboard as primary monitoring interface
  - CLI maintained for automation and scripting
  - Consistent data and status reporting across interfaces

### 📚 Documentation

- **Web Dashboard Guide** - Complete web interface documentation
- **API Reference** - RESTful API endpoint documentation
- **Web Server Configuration** - Nginx/Lighttpd setup guides
- **Security Best Practices** - Web interface security guidelines

---

## Roadmap Status

### ✅ **Completed High-Priority Features**
- **Gateway Mode** - Complete network infrastructure
- **IDS Integration** - Advanced threat detection
- **Web Dashboard** - Modern monitoring interface

### 🔄 **Next Steps (Medium Priority)**
- **Enhanced CLI** - Better UX and auto-completion
- **Per-device Policies** - Network segmentation
- **Advanced Threat Intelligence** - Enhanced threat feeds
- **Compliance Features** - Audit and compliance tools

### 🔮 **Future Enhancements**
- **AI/ML Integration** - Automated threat analysis
- **Performance Optimization** - Advanced caching
- **Ecosystem Expansion** - Third-party integrations

---

### ✨ Added

#### 🔒 **Security Features (v3.3.0)**
- **Reputation System** - Dynamic IP reputation scoring with automatic blocking
  - Real-time reputation tracking and scoring
  - Configurable thresholds and auto-blocking
  - Event-driven reputation updates
- **ASN Blocking** - Network-level traffic control
  - Autonomous System Number (ASN) based filtering
  - WHOIS integration for prefix lookups
  - Automated blocklist management
- **Advanced Event Logging** - Structured JSON event logging
  - Multi-format logging (JSON, text)
  - Configurable retention policies
  - Advanced querying and analysis capabilities
- **Honeypot System** - Active threat detection
  - Multiple service simulation (SSH, HTTP, RDP)
  - Connection logging and analysis
  - Automatic attacker blocking

#### 🎯 **Management Features**
- **YAML Configuration Management** - Profile-based configuration
  - Multiple configuration profiles (standard, security, enterprise)
  - Runtime configuration validation
  - Import/export and diff capabilities
- **Dynamic Module Management** - Runtime module control
  - Load/unload modules without restart
  - Dependency resolution and conflict detection
  - Module discovery and status monitoring
- **Systemd Service Integration** - Production-ready service management
  - Automatic service file generation
  - Service lifecycle management (start/stop/restart/enable/disable)
  - Health monitoring and auto-recovery

#### 🏢 **Advanced Features**
- **Prometheus/Grafana Integration** - Advanced monitoring and visualization
  - Real-time metrics collection
  - Pre-configured dashboards
  - Custom metric endpoints
- **Docker Integration** - Containerized deployment
  - docker-compose orchestration
  - Multi-service container management
  - Production-ready container configurations
- **Advanced Security** - Corporate-grade security features
  - Advanced firewall rules (nftables-based)
  - Threat intelligence feeds integration
  - Audit logging and compliance features
- **Scalability Features** - High availability and load balancing
  - HAProxy load balancing
  - Keepalived high availability
  - Performance monitoring and optimization

#### 🎨 **User Interface**
- **Enhanced CLI Installer** - Advanced installation options
  - Profile-based component selection
  - Dry-run and verbose modes
  - Comprehensive dependency checking
- **Gum TUI Dashboard** - Interactive terminal interface
  - Real-time system monitoring
  - Security status overview
  - Configuration management interface

### 🔄 Changed

- **Architecture Overhaul** - Complete system redesign
  - Modular architecture with unified modules
  - Event-driven system design
  - Plugin-based extensibility
- **Configuration System** - Migration to YAML-based configuration
  - Backward compatibility maintained
  - Profile-based configuration management
  - Runtime validation and error checking

### 🐛 Fixed

- **Memory Management** - Improved resource utilization
- **Error Handling** - Enhanced error reporting and recovery
- **Performance** - Optimized module loading and execution

### 📚 Documentation

- **Complete Documentation Suite** - Comprehensive user and developer documentation
- **API Documentation** - Detailed module and API reference
- **Troubleshooting Guide** - Common issues and solutions
- **Developer Guide** - Architecture and contribution guidelines

---

### 🌍 Internationalization Complete
- **Full i18n support for all 30+ modules** - Every module now uses T_* variables
- **7 languages fully supported:** Polish, English, German, Spanish, Italian, French, Russian
- **Translation coverage:**
  - ✅ install-wizard (all 7 languages)
  - ✅ uninstall (all 7 languages)
  - ✅ check-dependencies (all 7 languages)
  - ✅ verify-config (all 7 languages)
  - All user-facing strings use `${T_VAR:-fallback}` pattern

### ✨ New Module: verify-config
- **Purpose:** Verify Citadel configuration, services, and DNS functionality
- **Commands:**
  - `verify-config` - Full configuration check
  - `verify-config dns` - DNS resolution tests only
  - `verify-config services` - Service status only
  - `verify-config files` - Configuration files only
  - `verify-config all` - All checks including DNS
- **Features:**
  - CoreDNS configuration validation
  - DNSCrypt configuration validation
  - NFTables table verification
  - Service status (coredns, dnscrypt-proxy)
  - DNS resolution tests
  - DNSSEC validation check

### 📦 Dependency Installation Improvements
- **AUR fallback for Arch Linux:**
  - Auto-detects yay/paru helpers
  - Asks user before trying AUR
  - Shows manual instructions if no helper available
- **Per-package installation:**
  - Continues to next package on failure
  - Individual success/failure tracking
  - Summary with installed/failed/AUR lists
- **Alternative sources info:**
  - Debian/Ubuntu: PPA suggestions
  - Fedora/RHEL: EPEL, RPM Fusion, COPR suggestions

### 📚 Documentation Updates
- **New workflow:** `.windsurf/workflows/add-new-module.md`
  - Step-by-step guide for creating modules with i18n
  - Templates and examples
  - Requirements checklist
- **Updated commands.md:** Added verify-config documentation
- **Updated README.md:** Marked i18n as complete for all modules

### 📊 Statistics
- **Commits:** 5 commits
- **Files Changed:** 15 files
- **New Module:** 1 (verify-config)
- **Translation Strings Added:** 322 (46 per language × 7 languages)
- **Lines Added:** ~1,500

---

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
- **Commits:** 14 in this release
- **Files Changed:** 80
- **Lines Added:** +4,800
- **Lines Removed:** -1,200
- **Net Change:** +3,600 lines

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
