# ❓ Frequently Asked Questions (FAQ)

---

## 📋 Table of Contents

1. [General Questions](#-general-questions)
2. [Installation](#-installation)
3. [Configuration](#️-configuration)
4. [Troubleshooting](#-troubleshooting)
5. [Performance](#-performance)
6. [Security & Privacy](#-security--privacy)
7. [Advanced Usage](#-advanced-usage)

---

## 🌟 General Questions

### What is Citadel?

Citadel is a comprehensive DNS privacy and security solution for Linux that combines:
- **DNSCrypt-Proxy** - Encrypted DNS (DoH/DoT)
- **CoreDNS** - Local DNS server with caching
- **NFTables** - Firewall for DNS leak prevention
- **Ad blocking** - 325K+ domains blocked
- **Modular architecture** - 29 independent modules

### Who is Citadel for?

- 🏠 **Home users** - Privacy-conscious individuals
- 👨‍💼 **Small offices** - Teams needing DNS security
- 🔧 **Power users** - Those who want full control
- 🛡️ **Security enthusiasts** - Privacy and security focused

### What makes Citadel different?

- ✅ **Local-first** - No cloud dependencies
- ✅ **Modular** - 29 modules, lazy loading
- ✅ **CLI-first** - Full control via terminal
- ✅ **7 languages** - PL, EN, DE, ES, IT, FR, RU
- ✅ **Emergency mode** - Panic-bypass recovery
- ✅ **Open source** - GPL-3.0 license

### Which Linux distributions are supported?

**Fully supported:**
- Arch Linux
- CachyOS

**Partially supported (manual adaptation):**
- Ubuntu/Debian (requires manual package installation)
- Fedora/RHEL (requires manual package installation)
- Other systemd-based distributions

---

## 🚀 Installation

### How do I install Citadel?

**Quick installation:**
```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./citadel.sh check-deps       # Check dependencies
sudo ./citadel.sh install-wizard   # GUI mode
# OR
sudo ./citadel.sh install-all      # CLI mode
```

See [Quick Start Guide](quick-start.md) for details.

### Do I need root/sudo?

**Yes**, Citadel requires root privileges to:
- Install system packages
- Configure DNS settings
- Modify firewall rules
- Manage systemd services

### Can I install without the wizard?

**Yes**, use CLI mode:
```bash
sudo ./citadel.sh install-all
```

This installs all components automatically without GUI.

### What are the system requirements?

**Minimum:**
- 512 MB RAM
- 100 MB disk space
- Active internet connection

**Recommended:**
- 2 GB RAM
- SSD storage
- 2+ CPU cores

### How long does installation take?

- **Wizard mode:** 5-10 minutes
- **CLI mode:** 3-5 minutes
- **Manual mode:** 10-15 minutes

---

## ⚙️ Configuration

### How do I switch to Citadel DNS?

```bash
sudo ./citadel.sh configure-system
```

This will:
- Disable systemd-resolved
- Configure /etc/resolv.conf
- Point DNS to 127.0.0.1

### How do I restore original DNS?

```bash
# Restore backup from before Citadel
sudo ./citadel.sh restore-system

# Restore factory defaults (if backup was broken)
sudo ./citadel.sh restore-system-default
```

### Can I use custom DNS resolvers?

**Yes**, edit DNSCrypt configuration:
```bash
sudo ./citadel.sh edit-dnscrypt
```

Or manually edit:
```bash
sudo nano /etc/dnscrypt-proxy/dnscrypt-proxy.toml
```

### How do I enable DNSSEC?

```bash
# During installation
CITADEL_DNSSEC=1 sudo ./citadel.sh install-dnscrypt

# Or add flag
sudo ./citadel.sh install-dnscrypt --dnssec
```

### How do I change blocklist profile?

```bash
# List available profiles
sudo ./citadel.sh blocklist-list

# Switch profile
sudo ./citadel.sh blocklist-switch aggressive
```

**Available profiles:**
- `light` - Basic blocking (~50K domains)
- `balanced` - Recommended (~150K domains)
- `aggressive` - Maximum blocking (~325K domains)
- `privacy` - Privacy-focused
- `polish` - Polish sites optimized
- `custom` - Your custom list

---

## 🔧 Troubleshooting

### DNS is not working after installation

**Check status:**
```bash
sudo ./citadel.sh status
sudo ./citadel.sh diagnostics
```

**Common fixes:**
```bash
# Restart services
sudo systemctl restart dnscrypt-proxy coredns

# Check firewall
sudo ./citadel.sh firewall-safe

# Test DNS
dig +short google.com @127.0.0.1
```

### Port conflicts (53, 5353)

```bash
sudo ./citadel.sh fix-ports
```

This will automatically resolve port conflicts.

### Internet stopped working

**Emergency recovery:**
```bash
sudo ./citadel.sh panic-bypass
```

This will:
- Bypass DNS/firewall temporarily
- Restore internet connectivity
- Allow you to fix issues

**Restore normal mode:**
```bash
sudo ./citadel.sh panic-restore
```

### How do I check for DNS leaks?

```bash
# Test DNS leak
dig @8.8.8.8 test.com  # Should be blocked by firewall

# Check firewall rules
sudo nft list ruleset | grep citadel

# Full diagnostics
sudo ./citadel.sh diagnostics
```

### Services keep crashing

**Check logs:**
```bash
sudo journalctl -u dnscrypt-proxy -f
sudo journalctl -u coredns -f
```

**Reinstall:**
```bash
sudo ./citadel.sh restore-system
sudo ./citadel.sh install-all
```

---

## ⚡ Performance

### Is Citadel fast?

**Yes!** CoreDNS caching provides:
- ~1-5ms response time (cached)
- ~20-50ms response time (upstream)
- 90%+ cache hit rate

**Check performance:**
```bash
sudo ./citadel.sh cache-stats
```

### How much RAM does it use?

**Typical usage:**
- DNSCrypt-Proxy: ~20-30 MB
- CoreDNS: ~30-50 MB
- **Total:** ~50-80 MB RAM

### Does it slow down internet?

**No**, DNS caching actually speeds up browsing:
- First query: ~20-50ms (upstream)
- Cached queries: ~1-5ms (local)
- Overall: **Faster** than ISP DNS

### How many queries can it handle?

CoreDNS can handle:
- **1000+ queries/second** on typical hardware
- **10,000+ queries/second** on powerful hardware

For home use, this is more than enough.

---

## 🔒 Security & Privacy

### Is my DNS traffic encrypted?

**Yes**, DNSCrypt-Proxy provides:
- DoH (DNS-over-HTTPS)
- DoT (DNS-over-TLS)
- DNSCrypt protocol

All DNS queries are encrypted end-to-end.

### Does Citadel log my queries?

**No**, Citadel does not log DNS queries by default.

**To verify:**
```bash
# Check DNSCrypt config
grep -i log /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# Check CoreDNS config
grep -i log /etc/coredns/Corefile
```

### Can my ISP see my DNS queries?

**No**, all DNS traffic is encrypted via DNSCrypt-Proxy.

Your ISP can only see:
- Encrypted HTTPS traffic to DNS resolver
- Cannot see which domains you're querying

### How do I verify DNS encryption?

```bash
# Check DNSCrypt status
sudo systemctl status dnscrypt-proxy

# Test DNS resolution
dig +short google.com @127.0.0.1

# Check firewall (blocks unencrypted DNS)
sudo nft list ruleset | grep "port 53"
```

### What about IPv6 privacy?

Citadel includes IPv6 privacy features:
```bash
# Enable IPv6 privacy
sudo ./citadel.sh ipv6-privacy-auto

# Deep reset IPv6
sudo ./citadel.sh ipv6-deep-reset
```

---

## 🎓 Advanced Usage

### Can I use Citadel as a network gateway?

**Yes** (v3.2 - planned):
```bash
sudo ./citadel.sh gateway-wizard
```

This will configure Citadel as a DNS gateway for your entire network.

### How do I backup my configuration?

```bash
# Create backup
sudo ./citadel.sh config-backup

# List backups
sudo ./citadel.sh config-list

# Restore backup
sudo ./citadel.sh config-restore backup-name.tar.gz
```

### Can I add custom blocklists?

**Yes:**
```bash
# Add custom URL
sudo ./citadel.sh blocklist-add-url https://example.com/blocklist.txt

# Edit custom hosts
sudo nano /etc/coredns/zones/custom.hosts

# Rebuild blocklist
sudo ./citadel.sh adblock-rebuild
```

### How do I enable auto-updates?

```bash
# Enable auto-update
sudo ./citadel.sh auto-update-enable

# Configure schedule
sudo ./citadel.sh auto-update-configure

# Check status
sudo ./citadel.sh auto-update-status
```

### Can I monitor Citadel with Prometheus?

**Yes**, CoreDNS exports Prometheus metrics:
```bash
# Check metrics
curl -s http://127.0.0.1:9153/metrics | grep coredns_

# View cache stats
sudo ./citadel.sh cache-stats
```

### How do I integrate with my editor?

```bash
sudo ./citadel.sh install-editor
```

This adds Citadel commands to your editor (vim/nano/etc).

### Can I run Citadel in Docker?

**Not yet** (v3.5+ - planned)

Currently, Citadel requires direct system access for:
- systemd services
- Network configuration
- Firewall rules

---

## 🆘 Still Need Help?

### Documentation

- 📖 [Full Manual (PL)](MANUAL_PL.md)
- 📖 [Full Manual (EN)](MANUAL_EN.md)
- 🚀 [Quick Start Guide](quick-start.md)
- 📋 [Commands Reference](commands.md)
- 🏗️ [Architecture](../CITADEL-STRUCTURE.md)

### Community

- 💬 [GitHub Discussions](https://github.com/QguAr71/Cytadela/discussions)
- 🐛 [Report Bug](https://github.com/QguAr71/Cytadela/issues/new?template=bug_report.md)
- 💡 [Feature Request](https://github.com/QguAr71/Cytadela/issues/new?template=feature_request.md)

### Emergency

If you're completely stuck:
```bash
# Emergency bypass
sudo ./citadel.sh panic-bypass

# Full restore
sudo ./citadel.sh restore-system

# Diagnostics
sudo ./citadel.sh diagnostics
```

---

**Last updated:** 2026-01-31  
**Version:** 3.1.0
