# Release v3.1.0-STABLE: The Performance & Resilience Update

**Release Date:** 2026-02-01  
**Status:** Production Ready ✅  
**Tested On:** CachyOS (Arch Linux)

---

## 📋 Overview

This release marks a major milestone for **Citadel** (formerly Cytadela++). We have focused on extreme performance optimization, bulletproof DNS leak protection, and a robust recovery system. Fully verified and optimized for CachyOS.

---

## 🚀 What's New in v3.1.0

### ⚡ Performance Optimization
- **76,323 QPS sustained throughput** with sub-1.5ms average latency
- Single-node localhost benchmark using dnsperf v2.14.0 (30s sustained load, 20 domain rotation)
- Optimized CoreDNS & DNSCrypt-Proxy configuration
- 99.99% cache hit rate for frequently accessed domains
- 0% packet loss under sustained load
- Minimum latency: 0.01ms for cache hits
- **Detailed benchmark:** [TESTING-RESULTS-2026-02-01.md](docs/TESTING-RESULTS-2026-02-01.md)

### 🛡️ Strict Firewall Protection
- Enhanced nftables ruleset with mandatory redirection to local DNS stack
- **All outbound :53 traffic is forcibly redirected to the local resolver stack**
- **Zero DNS leaks** - all external DNS queries blocked (IPv4 + IPv6)
- Rate limiting: 10 queries/second with burst of 5 packets
- Comprehensive logging: "CITADEL DNS LEAK" prefix for monitoring
- `table inet` handles both IPv4 and IPv6 simultaneously

### 🔄 Self-Healing System
- New watchdog system ensures service recovery in **less than 30 seconds** after crash
- Automatic restart for dnscrypt-proxy and coredns services
- Systemd integration with `Restart=always` and `RestartSec=5s`
- Verified crash recovery with manual kill tests

### 💾 Operational Safety
- **Automated pre-install backup** of original DNS configuration
- Backup location: `/var/lib/cytadela/backups/`
- New `restore-system-default` command for factory reset
- Complete backup/restore cycle verified and working
- Safe rollback to systemd-resolved if needed

### 🏎️ Parallel Racing
- Enabled DoH parallel racing for faster response times
- Multiple upstream providers tested simultaneously
- Automatic selection of fastest responding server
- Cloudflare (69ms), Google (77ms), Quad9 (92ms) tested

### 🔒 DNSSEC Validation
- Full DNSSEC validation with Authenticated Data (AD) flag
- Invalid signatures correctly rejected (SERVFAIL)
- Protection against DNS spoofing and MITM attacks
- Verified with cloudflare-dns.com (AD flag present)
- Tested with dnssec-failed.org (correctly blocked)

### 🚫 Enhanced Ad/Malware Blocking
- **325,979 blocked domains** (OISD + StevenBlack blocklists)
- Automatic blocklist updates
- Known tracking domains blocked (e.g., doubleclick.net → 0.0.0.0)
- DNS-level ad blocking for all devices on network

### 🌐 IPv6 Dual-Stack Support
- Full IPv6 DNS leak protection
- IPv6 localhost (::1) allowed for local services
- All external IPv6 DNS queries blocked
- No IPv6 bypass possible

---

## 📊 Validation Results (7/7 Tests PASSED)

All tests performed on CachyOS (Arch Linux) with STRICT firewall mode and adblock enabled.

| Test | Status | Result |
|------|--------|--------|
| **DNS Leak Protection** | ✅ PASSED | STRICT mode blocks all bypass attempts (IPv4) |
| **Crash Recovery** | ✅ PASSED | Auto-restart functional (~29s recovery time) |
| **Backup/Restore** | ✅ PASSED | Full cycle works flawlessly |
| **DNSSEC Validation** | ✅ PASSED | AD flag verified, invalid signatures blocked |
| **IPv6 Dual-Stack** | ✅ PASSED | IPv6 DNS leak protection working |
| **Malware Blocking** | ✅ PASSED | 325,979 domains blocked (OISD/StevenBlack) |
| **Performance Benchmark** | ✅ PASSED | 76,323 QPS, 1.29ms avg latency, 0% packet loss |

**Test environment:** CachyOS (Linux kernel 6.12.1, systemd 257.2)  
**Detailed test results:** [TESTING-RESULTS-2026-02-01.md](docs/TESTING-RESULTS-2026-02-01.md)

---

## 🔧 Technical Improvements

### CoreDNS Optimization
- Optimized cache settings (30s TTL)
- Efficient hosts file processing
- Prometheus metrics on 127.0.0.1:9153
- GOMAXPROCS=12 (full CPU utilization)

### DNSCrypt-Proxy Enhancements
- `require_dnssec = true` for DNSSEC validation
- Parallel DoH racing enabled
- Automatic server selection based on latency
- Listen on 127.0.0.1:5356

### NFTables Firewall
- `table inet citadel_dns` for IPv4+IPv6
- Strict DROP rules for external DNS (ports 53, 853)
- Rate limiting with logging
- Emergency bypass table for troubleshooting

### Systemd Integration
- Automatic service restart on failure
- Proper dependency ordering
- Graceful shutdown (SIGTERM)
- Service status monitoring

---

## 📚 New Documentation

### Added Files
- `ACKNOWLEDGMENTS.md` - Credits to all upstream open-source projects
- `docs/TESTING-RESULTS-2026-02-01.md` - Complete test results (v4.0)
- `docs/INSTALLATION-SIMPLIFICATION-V3.2.md` - Auto-configure plan for v3.2
- `docs/v3.2-fixes/RFC1035-WARNING-FIX.md` - CoreDNS warning fix for v3.2

### Updated Documentation
- `README.md` - Added configure-system to Quick Start, link to ACKNOWLEDGMENTS
- `docs/user/quick-start.md` - Added Step 4: Configure System (Critical!)
- `docs/user/MANUAL_PL.md` - Added restore-system-default documentation
- `docs/user/MANUAL_EN.md` - Added restore-system-default documentation
- `docs/user/commands.md` - Added restore-system-default command
- `docs/user/FAQ.md` - Added restore-system-default FAQ entry
- `CHANGELOG.md` - Updated future branding to Weles-SysQ (v3.2)

---

## 🎯 Installation

### Quick Start
```bash
# Clone repository
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# Check dependencies
sudo ./citadel.sh check-deps

# Install with interactive wizard (recommended)
sudo ./citadel.sh install-wizard

# Configure system (switch from systemd-resolved to Citadel)
sudo ./citadel.sh configure-system

# Verify installation
sudo ./citadel.sh verify
```

### Language Support
- 🇵🇱 Polish (Polski) - Full documentation
- 🇬🇧 English - Full documentation
- 🇩🇪 German (Deutsch) - Wizard only
- 🇪🇸 Spanish (Español) - Wizard only
- 🇮🇹 Italian (Italiano) - Wizard only
- 🇫🇷 French (Français) - Wizard only
- 🇷🇺 Russian (Русский) - Wizard only

> **Note:** Full i18n for all languages planned for v3.2 (Weles-SysQ release)

---

## 🔄 Upgrade from v3.0

```bash
# Backup current configuration
sudo ./citadel.sh backup-config

# Pull latest changes
git pull origin main

# Reinstall components (preserves configuration)
sudo ./citadel.sh install-all

# Verify upgrade
sudo ./citadel.sh verify
sudo ./citadel.sh status
```

---

## 🆕 New Commands

### `restore-system-default`
Factory reset to default systemd-resolved configuration.

```bash
sudo ./citadel.sh restore-system-default
```

**Use cases:**
- Complete uninstall of Citadel
- Restore to factory DNS settings
- Troubleshooting DNS issues
- Safe fallback option

**What it does:**
- Restores factory systemd-resolved configuration
- Unmasks and enables systemd-resolved
- Removes NetworkManager DNS configuration
- Links /etc/resolv.conf to systemd-resolved stub

---

## 🐛 Bug Fixes

### Fixed Issues
- **Backup path correction:** Changed `/var/lib/cytadela/backup/` to `/var/lib/cytadela/backups/` for consistency
- **WiFi detection:** Added Italian locale support (`sì`) to location detection
- **Documentation clarity:** Corrected misleading language support information (PL/EN full docs, 5 languages wizard-only)

### Known Issues
- **CoreDNS RFC1035 warning:** Cosmetic warning about domain name format (fix planned for v3.2)
  - Does not affect functionality
  - Prometheus metrics work correctly
  - See: `docs/v3.2-fixes/RFC1035-WARNING-FIX.md`

---

## 🔮 Future Plans (v3.2 - Weles-SysQ)

### Project Rebranding
- New name: **Weles-SysQ** (Slavic god of magic, oaths, and guardian of wealth)
- Rationale: DNS as guardian/protector of internet gateway
- Unique Slavic mythology (Polish roots)
- No conflicts with existing DNS software

### Planned Features
- **Auto-configure installation** (4 steps → 2 steps)
- **Unified module architecture** (29 modules → 6 modules, -79% complexity)
- **Silent DROP firewall mode** (stealth mode, no ICMP responses)
- **Full i18n support** for all 7 languages (CLI, modules, documentation)
- **CoreDNS RFC1035 fix** (move prometheus to main DNS block)
- **Bash 5.0+ features** (associative arrays, --silent flag)

See: `docs/REFACTORING-V3.2-PLAN.md` and `docs/INSTALLATION-SIMPLIFICATION-V3.2.md`

---

## 🙏 Acknowledgments

Citadel is built on top of exceptional open-source projects:

- **DNSCrypt-Proxy** - Encrypted DNS foundation
- **CoreDNS** - High-performance DNS server
- **NFTables** - Modern packet filtering
- **Prometheus** - Monitoring and metrics
- **StevenBlack & OISD** - Comprehensive blocklists
- **CachyOS & Arch Linux** - Distribution foundation
- **Open Source Community** - Inspiration and support

For detailed acknowledgments and how to support these projects, see [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

---

## 📊 Performance Metrics

### Benchmark Results (dnsperf 30s test)
- **Queries sent:** 2,289,780
- **Queries completed:** 2,289,780 (100%)
- **Queries lost:** 0 (0%)
- **QPS:** 76,323 queries/second
- **Average latency:** 1.29ms
- **Min latency:** 0.01ms (cache hits)
- **Max latency:** 202ms (cache misses)
- **Success rate:** 100% NOERROR

### System Resources
- **CPU utilization:** GOMAXPROCS=12 (full core usage)
- **Memory:** Efficient (no memory leaks detected)
- **Cache hit rate:** 99.99%
- **Packet loss:** 0%

---

## 🔒 Security Features

- ✅ DNS encryption (DoH/DoT via DNSCrypt-Proxy)
- ✅ DNSSEC validation with Authenticated Data flag
- ✅ DNS leak protection (strict firewall, IPv4 + IPv6)
- ✅ Automatic crash recovery
- ✅ Complete backup/restore functionality
- ✅ Adblock/malware blocking (325K+ domains)
- ✅ Rate limiting and logging
- ✅ Factory reset option

---

## 📞 Support

- **Documentation:** [docs/](docs/)
- **Issues:** [GitHub Issues](https://github.com/QguAr71/Cytadela/issues)
- **Discussions:** [GitHub Discussions](https://github.com/QguAr71/Cytadela/discussions)
- **Testing Results:** [TESTING-RESULTS-2026-02-01.md](docs/TESTING-RESULTS-2026-02-01.md)

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

---

## 🎉 Contributors

Special thanks to:
- **QguAr71** - Project creator and maintainer
- **CachyOS Community** - Testing and feedback
- **Open Source Community** - Upstream projects and inspiration

---

**Status:** Production Ready ✅  
**Tested:** 7/7 Tests PASSED  
**Performance:** 76K QPS, 1.29ms latency, 0% loss  
**Security:** DNSSEC validated, DNS leak protected, 325K domains blocked

**Citadel v3.1.0 - Your DNS Guardian** 🛡️
