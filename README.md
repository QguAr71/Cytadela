# 🛡️ Citadel - Fortified DNS Infrastructure

**Advanced hardened DNS resolver with full privacy stack for home users and small businesses.**

[![Version](https://img.shields.io/badge/version-3.1.0-blue.svg)](https://github.com/QguAr71/Cytadela)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)

---

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# Run interactive installation wizard (7 languages available)
sudo ./citadel.sh install-wizard

# Or force specific language:
sudo ./citadel.sh install-wizard pl  # Polski
sudo ./citadel.sh install-wizard en  # English
sudo ./citadel.sh install-wizard de  # Deutsch

# Check status
sudo ./citadel.sh status
```

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
- **Interactive installer wizard** - All 7 languages (auto-detect from $LANG)
- **CLI commands** - All 7 languages (`citadel.sh help [lang]`)
- **System messages** - All 7 languages
- **Modules** - adblock, diagnostics, help (7 languages)
- **Error logs and reports** - All 7 languages

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
- 🌐 **7 Languages** - Full support (PL, EN, DE, ES, IT, FR, RU)
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
- [Installation Guide](docs/user/installation.md) - Detailed installation
- [Configuration](docs/user/configuration.md) - Customize your setup
- [Commands Reference](docs/user/commands.md) - All available commands
- [Troubleshooting](docs/user/troubleshooting.md) - Common issues
- [FAQ](docs/user/faq.md) - Frequently asked questions

### For Developers
- [Architecture](docs/developer/architecture.md) - System design
- [Contributing](docs/developer/contributing.md) - How to contribute
- [Testing](docs/developer/testing.md) - Testing strategy
- [Modules](docs/developer/modules.md) - Module documentation

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
| DNS Encryption | ✅ DoH/DoT | ❌ | ✅ DoH/DoT | ❌ |
| Ad Blocking | ✅ 325K+ | ✅ | ✅ | ❌ |
| Firewall | ✅ NFTables | ❌ | ❌ | ❌ |
| Metrics | ✅ Prometheus | ✅ Web UI | ✅ Web UI | ❌ |
| Modular | ✅ 29 modules | ❌ | ❌ | ❌ |
| CLI-first | ✅ | ❌ | ❌ | ✅ |
| Emergency Mode | ✅ | ❌ | ❌ | ❌ |

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

- **DNSCrypt-Proxy** - Encrypted DNS
- **CoreDNS** - DNS server
- **NFTables** - Firewall
- **Community** - Feedback and contributions

---

## 📞 Support

- **Documentation:** [docs/](docs/)
- **Issues:** [GitHub Issues](https://github.com/QguAr71/Cytadela/issues)
- **Discussions:** [GitHub Discussions](https://github.com/QguAr71/Cytadela/discussions)

---

## 🔗 Links

- **Website:** [Coming soon]
- **Documentation:** [docs/](docs/)
- **Legacy Version:** [legacy/](legacy/) (v3.0 - deprecated)

---

**Made with ❤️ for privacy and security**

*Citadel - Your fortress against DNS surveillance*
