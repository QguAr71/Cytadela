# 🛡️ Citadel - Fortified DNS Infrastructure

**Advanced hardened DNS resolver with full privacy stack for home users and small businesses.**

[![Version](https://img.shields.io/badge/version-3.1.1-blue.svg)](https://github.com/QguAr71/Cytadela/releases)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![ShellCheck](https://img.shields.io/github/actions/workflow/status/QguAr71/Cytadela/shellcheck.yml?label=shellcheck)](https://github.com/QguAr71/Cytadela/actions)
[![Tests](https://img.shields.io/github/actions/workflow/status/QguAr71/Cytadela/shellcheck.yml?label=tests&logo=gnu-bash&logoColor=white)](https://github.com/QguAr71/Cytadela/actions)
[![Last Commit](https://img.shields.io/github/last-commit/QguAr71/Cytadela)](https://github.com/QguAr71/Cytadela/commits/main)
[![Issues](https://img.shields.io/github/issues-raw/QguAr71/Cytadela)](https://github.com/QguAr71/Cytadela/issues)

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# Check dependencies
sudo ./citadel.sh check-deps

# Run interactive installation wizard (7 languages available)
sudo ./citadel.sh install-wizard

# Or force specific language:
sudo ./citadel.sh install-wizard pl  # Polski
sudo ./citadel.sh install-wizard en  # English
sudo ./citadel.sh install-wizard de  # Deutsch

# Configure system (switch from systemd-resolved to Citadel)
sudo ./citadel.sh configure-system

# Check status
sudo ./citadel.sh status
```

---

## 🖥️ Dashboard Preview

**Real-time monitoring with `citadel-top`:**

```
┌─ CYTADELA++ TERMINAL DASHBOARD v3.1 ───────────────────────┐
│                                                         │
│ 📊 SYSTEM STATUS                                          │
│ ├─ DNSCrypt Proxy:     ● ACTIVE (127.0.0.1:5353)        │
│ ├─ CoreDNS:            ● ACTIVE (127.0.0.1:53)          │
│ ├─ NFTables:           ● ACTIVE (DNS leak protection)   │
│ └─ Blocklist:          325,847 domains                 │
│                                                         │
│ 📈 PERFORMANCE METRICS                                   │
│ ├─ DNS Queries:        1,247/min                       │
│ ├─ Cache Hit Rate:      94.2%                          │
│ ├─ Blocked Queries:    187/min (15.0%)                │
│ └─ Response Time:      12ms avg                       │
│                                                         │
│ 🛡️ SECURITY STATUS                                       │
│ ├─ Firewall Mode:      STRICT                          │
│ ├─ DNS Encryption:     DoH + DoT                        │
│ ├─ Last Update:        2 hours ago                     │
│ └─ Emergency Mode:     INACTIVE                        │
└─────────────────────────────────────────────────────────┘
```

*Run `sudo ./citadel.sh install-dashboard` to install*

---

### 🌍 Multilingual Support

Citadel supports **7 languages** with full translations:
- 🇵🇱 Polish (Polski)
- 🇬🇧 English
- 🇩🇪 German (Deutsch)
- 🇪🇸 Spanish (Español)
- 🇮🇹 Italian (Italiano)
- 🇫🇷 French (Français)
- 🇷🇺 Russian (Русский)

**What's translated:**
- **Interactive installer wizard** - All 7 languages (auto-detect from $LANG) ✅
- **CLI commands** - Planned for v3.2 (`citadel.sh help [lang]`)
- **System messages** - Planned for v3.2
- **Modules** - Planned for v3.2 (adblock, diagnostics, help)
- **Error logs and reports** - Planned for v3.2

> **Note:** Currently, only **PL and EN** have full documentation. Other 5 languages (DE, ES, IT, FR, RU) are available only in install-wizard interface. Complete i18n for all modules, CLI commands, and documentation is planned for **v3.2 (Weles-SysQ release)**.

---

## ✨ Key Features

- 🔒 **DNSCrypt-Proxy** - Encrypted DNS queries (DoH/DoT)
- 🎯 **CoreDNS** - High-performance caching resolver
- 🛡️ **NFTables Firewall** - DNS leak protection
- 🚫 **Ad Blocking** - 325,000+ domains blocked
- 📊 **Prometheus Metrics** - Real-time monitoring
- 🔐 **Supply Chain Protection** - Integrity verification
- 🌍 **IPv6 Privacy** - Temporary address management
- 🚨 **Emergency Recovery** - Panic bypass mode
- 📦 **Modular Architecture** - 32 independent modules
- 🔄 **Auto-Update** - Automatic blocklist updates
- 🌐 **Multi-Language** - Full docs (PL, EN) + 5 languages in wizard (DE, ES, IT, FR, RU)
- 🖥️ **Interactive Installer** - Graphical wizard (whiptail)

---

## 📋 System Requirements

- **OS:** Arch Linux, CachyOS (other distros: manual adaptation)
- **RAM:** 512 MB minimum, 1 GB recommended (2 GB for Gateway Mode)
- **Disk:** 100 MB for installation
- **Network:** Active internet connection
- **Privileges:** Root access required

---

## 🏆 Project Status

### ✅ **v3.1.0 - STABLE** (Current - 2026-01-31)

**Production-ready with:**
- ✅ 32 functional modules with lazy loading
- ✅ 7 languages (PL, EN, DE, ES, IT, FR, RU)
- ✅ Interactive installer wizard (whiptail)
- ✅ Terminal Dashboard (`citadel-top`)
- ✅ Auto-update, Backup/Restore, Cache Stats
- ✅ Desktop Notifications, Multi-blocklist
- ✅ 18 functions migrated from legacy
- ✅ Professional repository structure

**All features tested and working!**

### 🔄 **v3.2.0 - PLANNED** (Q1 2026)

**Gateway Mode (PRIORITY #1):**
- 🔄 Network Gateway for entire home network
- 🔄 DHCP server (dnsmasq/systemd-networkd)
- 🔄 NAT & routing (NFTables)
- 🔄 Per-device statistics and management
- 🔄 Terminal UI (TUI) with ncurses
- 🔄 Commands: `gateway-wizard`, `gateway-status`, `gateway-devices`

**Requirements for Gateway Mode:**
- 2x Ethernet interfaces
- 2 GB RAM
- Old PC (150-300 zł / $40-80)

**Effort:** ~15-20 hours development

---

## 📚 Documentation

### For Users
- [Quick Start Guide](docs/user/quick-start.md) - Get started in 5 minutes
- [Commands Reference](docs/user/commands.md) - All available commands
- [FAQ](docs/user/FAQ.md) - Frequently asked questions
- [Manual (PL)](docs/user/MANUAL_PL.md) - Complete Polish guide
- [Manual (EN)](docs/user/MANUAL_EN.md) - Complete English guide

### For Developers
- [Architecture](docs/developer/architecture.md) - System design
- [Contributing](docs/developer/contributing.md) - How to contribute
- [Testing Strategy](docs/developer/testing-strategy.md) - Testing approach
- [Testing Guide](docs/developer/testing-guide.md) - How to run tests

### Roadmap
- [Current Roadmap](docs/roadmap/current.md) - v3.1-v3.2 plans
- [Home Users Focus](docs/roadmap/home-users.md) - Features for home users
- [Future Plans](docs/roadmap/future.md) - v4.0+ vision

---

## 🎯 Popular Commands

```bash
# Installation
sudo ./citadel.sh install-wizard      # Interactive installer
sudo ./citadel.sh install-all          # Install all components

# Configuration
sudo ./citadel.sh configure-system     # Switch to Citadel DNS
sudo ./citadel.sh firewall-strict      # Enable strict firewall

# Monitoring
sudo ./citadel.sh status               # Show status
sudo ./citadel.sh verify               # Verify installation
sudo ./citadel.sh health-status        # Health check

# Adblock
sudo ./citadel.sh adblock-status       # Show adblock status
sudo ./citadel.sh adblock-add domain   # Block custom domain
sudo ./citadel.sh blocklist-switch     # Switch blocklist profile

# Emergency
sudo ./citadel.sh panic-bypass         # Emergency recovery
sudo ./citadel.sh emergency-restore    # Restore normal operation

# Maintenance
sudo ./citadel.sh auto-update-enable   # Enable auto-updates
sudo ./citadel.sh config-backup        # Backup configuration
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     User Applications                        │
└─────────────────────┬───────────────────────────────────────┘
                      │ DNS Queries
┌─────────────────────▼───────────────────────────────────────┐
│                    CoreDNS (Port 53)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Caching    │  │   Adblock    │  │  Prometheus  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────┬───────────────────────────────────────┘
                      │ Upstream Queries
┌─────────────────────▼───────────────────────────────────────┐
│              DNSCrypt-Proxy (Port 5355)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     DoH      │  │     DoT      │  │   DNSCrypt   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────┬───────────────────────────────────────┘
                      │ Encrypted
┌─────────────────────▼───────────────────────────────────────┐
│                  NFTables Firewall                           │
│              (DNS Leak Protection)                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
                 Internet
```

---

## 🆚 Comparison

| Feature | Citadel | Pi-hole | AdGuard Home | Unbound |
|---------|---------|---------|--------------|---------|
| **DNS Encryption** | ✅ DoH/DoT/DNSCrypt | ❌ | ✅ DoH/DoT | ❌ |
| **Ad Blocking** | ✅ 325K+ domains | ✅ | ✅ | ❌ |
| **Firewall** | ✅ NFTables + DNS leak protection | ❌ | ❌ | ❌ |
| **Metrics** | ✅ Prometheus + citadel-top | ✅ Web UI | ✅ Web UI | ❌ |
| **Modular** | ✅ 32 independent modules | ❌ | ❌ | ❌ |
| **CLI-first** | ✅ Full CLI interface | ❌ | ❌ | ✅ |
| **Emergency Mode** | ✅ Panic bypass + kill-switch | ❌ | ❌ | ❌ |
| **Multi-language** | ✅ 7 languages (PL, EN, DE, ES, IT, FR, RU) | ❌ | ❌ | ❌ |
| **Auto-update** | ✅ Systemd timer + LKG fallback | ❌ | ✅ | ❌ |
| **IPv6 Support** | ✅ Privacy extensions + smart detection | ❌ | ✅ | ✅ |
| **Supply Chain** | ✅ Integrity verification | ❌ | ❌ | ❌ |
| **Terminal UI** | ✅ citadel-top dashboard | ❌ | ❌ | ❌ |
| **Rate Limiting** | ✅ Built-in protection | ❌ | ✅ | ❌ |

[Full comparison](docs/comparison/vs-competitors.md)

---

## 📊 Project Status

- **Version:** 3.1.0 (Stable)
- **Development:** Active
- **Maintenance:** Regular updates
- **Community:** Growing
- **License:** GPL-3.0

### Version History
- ✅ **v3.1.0** (2026-01-31) - STABLE - Modular architecture, 7 languages, 29 modules
- ✅ **v3.0.0** (2026-01-25) - Initial stable release
- 🔄 **v3.2.0** (Q1 2026) - PLANNED - Gateway Mode, Terminal UI

---

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](docs/developer/contributing.md) for guidelines.

### Ways to Contribute
- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation
- 🔧 Submit pull requests
- ⭐ Star the repository

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

Cytadela is built on top of exceptional open-source projects. We are deeply grateful to:

- **DNSCrypt-Proxy** - Encrypted DNS foundation
- **CoreDNS** - High-performance DNS server
- **NFTables** - Modern packet filtering
- **Prometheus** - Monitoring and metrics
- **StevenBlack & OISD** - Comprehensive blocklists
- **CachyOS & Arch Linux** - Distribution foundation
- **Open Source Community** - Inspiration and support

For detailed acknowledgments, licenses, and how to support these projects, see [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

---

## � Quick Links

### 📚 Documentation
- [📖 Quick Start Guide](docs/user/quick-start.md) - Get started in 5 minutes
- [🔧 Commands Reference](docs/user/commands.md) - All available commands
- [❓ FAQ](docs/user/FAQ.md) - Frequently asked questions
- [📋 Manual (PL)](docs/user/MANUAL_PL.md) - Complete Polish guide
- [📋 Manual (EN)](docs/user/MANUAL_EN.md) - Complete English guide

### 🛠️ Development
- [🏗️ Architecture](docs/developer/architecture.md) - System design
- [🤝 Contributing](docs/developer/contributing.md) - How to contribute
- [🧪 Testing Strategy](docs/developer/testing-strategy.md) - Testing approach
- [📝 Testing Guide](docs/developer/testing-guide.md) - How to run tests

### 🗺️ Roadmap
- [📍 Current Roadmap](docs/roadmap/current.md) - v3.1-v3.2 plans
- [🏠 Home Users Focus](docs/roadmap/home-users.md) - Features for home users
- [🔮 Future Plans](docs/roadmap/future.md) - v4.0+ vision

### 💾 Examples & Scripts
- [🚀 Basic Setup](examples/basic-setup.sh) - Simple installation
- [⚡ Advanced Setup](examples/advanced-setup.sh) - Full configuration
- [🆘 Emergency Recovery](examples/emergency-recovery.sh) - Crisis procedures

---

## 📋 Version Management

Citadel uses [Semantic Versioning](https://semver.org/): **MAJOR.MINOR.PATCH**

- **v3.1.0** - Current stable release
- **v3.1.1** - Next patch release (bug fixes)
- **v3.2.0** - Next minor release (new features)

### Release Process
See [RELEASE-INSTRUCTIONS.md](docs/RELEASE-INSTRUCTIONS.md) for detailed release guidelines.

### Version Sources
- `VERSION` - Single source of truth
- `lib/cytadela-core.sh` - Runtime version variable
- `CHANGELOG.md` - Release history
- GitHub Releases - Automated releases

---

## 🧪 Testing

### Local Testing

Run tests locally before submitting PRs:

```bash
# Run smoke tests
bash tests/smoke-test.sh

# Run BATS unit tests (requires bats)
pacman -S bats  # Arch/CachyOS
bats tests/unit/

# Run shellcheck manually
shellcheck -S warning -e SC2034 citadel.sh lib/*.sh modules/*.sh

# Check code formatting
shfmt -d .
```

### CI/CD

All PRs trigger automated tests via GitHub Actions:
- **ShellCheck** - Static analysis for shell scripts
- **Smoke Tests** - Basic functionality checks
- **BATS Tests** - Unit and integration tests

See [tests/README-BATS.md](tests/README-BATS.md) for detailed testing documentation.

---

## 📞 Support

- **Documentation:** [docs/](docs/)
- **Issues:** [GitHub Issues](https://github.com/QguAr71/Cytadela/issues)
- **Discussions:** [GitHub Discussions](https://github.com/QguAr71/Cytadela/discussions)

---

## 🔗 Links

- **📦 Repository:** [github.com/QguAr71/Cytadela](https://github.com/QguAr71/Cytadela)
- **📖 Documentation:** [docs/](docs/)
- **🚀 Releases:** [Releases page](https://github.com/QguAr71/Cytadela/releases)
- **🐛 Issues:** [GitHub Issues](https://github.com/QguAr71/Cytadela/issues)
- **💬 Discussions:** [GitHub Discussions](https://github.com/QguAr71/Cytadela/discussions)
- **📄 License:** [GPL-3.0](LICENSE)
- **🏆 Acknowledgments:** [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md)
- **🔧 Legacy:** [legacy/](legacy/) (v3.0 - deprecated)

---

**Made with ❤️ for privacy and security**

*Citadel - Your fortress against DNS surveillance*
