# Citadel v3.2 Installation Guide

**Version:** 3.2.0
**Date:** 2026-02-04
**Compatibility:** Linux (Arch, Ubuntu, Fedora, Debian)
**Installation Time:** 15-30 minutes

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Quick Install](#quick-install)
3. [Detailed Installation](#detailed-installation)
4. [Post-Installation](#post-installation)
5. [Uninstallation](#uninstallation)
6. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Minimum Requirements
- **OS:** Linux (Arch Linux, Ubuntu 18.04+, Fedora 30+, Debian 10+)
- **RAM:** 512 MB
- **Disk:** 100 MB free space
- **Network:** Internet connection for blocklist downloads

### Recommended Requirements
- **OS:** Arch Linux or Ubuntu 20.04+
- **RAM:** 1 GB
- **Disk:** 500 MB free space
- **CPU:** 1 GHz single core minimum

### Required Packages
```bash
# Arch Linux
sudo pacman -S bash coreutils curl jq grep awk sed systemd

# Ubuntu/Debian
sudo apt update
sudo apt install bash coreutils curl jq grep awk sed systemd

# Fedora/RHEL
sudo dnf install bash coreutils curl jq grep awk sed systemd
```

---

## Quick Install

### One-Line Install (Recommended)
```bash
# Clone repository
git clone https://github.com/your-org/cytadela.git
cd cytadela

# Make executable and run complete installation
chmod +x citadel.sh
sudo ./citadel.sh install all
```

### Verify Installation
```bash
# Check system status
sudo ./citadel.sh monitor status

# Test DNS resolution
sudo ./citadel.sh monitor verify-dns

# Check services
sudo ./citadel.sh monitor verify
```

---

## Detailed Installation

### Step 1: Download and Prepare
```bash
# Create installation directory
mkdir -p ~/cytadela-install
cd ~/cytadela-install

# Clone repository (use develop branch for latest v3.2)
git clone https://github.com/your-org/cytadela.git .
git checkout develop

# Verify files
ls -la
# Should show: citadel.sh, modules/, lib/, docs/

# Make scripts executable
chmod +x citadel.sh
find modules/unified -name "*.sh" -exec chmod +x {} \;
find lib -name "*.sh" -exec chmod +x {} \;
```

### Step 2: Check Prerequisites
```bash
# Check system compatibility
./citadel.sh install check-deps

# Expected output: list of installed/missing packages
# Fix any missing dependencies before proceeding
```

### Step 3: Install Core Components

#### Option A: Complete Installation (Recommended)
```bash
# Install everything automatically
sudo ./citadel.sh install all

# This will install:
# - DNSCrypt-Proxy (encrypted DNS)
# - CoreDNS (DNS server with adblocking)
# - NFTables firewall (DNS leak protection)
# - Citadel terminal dashboard
```

#### Option B: Step-by-Step Installation
```bash
# Install individual components
sudo ./citadel.sh install dnscrypt     # Encrypted DNS client
sudo ./citadel.sh install coredns      # DNS server with adblocking
sudo ./citadel.sh install nftables     # Firewall rules
sudo ./citadel.sh install dashboard    # Terminal monitoring dashboard
```

### Step 4: System Configuration
```bash
# Configure system to use Citadel DNS
sudo ./citadel.sh install configure-system

# This will:
# - Disable systemd-resolved
# - Configure /etc/resolv.conf to use 127.0.0.1
# - Set up NFTables firewall rules
# - Enable DNS leak protection
```

### Step 5: Firewall Setup
```bash
# Choose firewall mode
sudo ./citadel.sh install firewall-safe     # Allows external DNS (safe)
sudo ./citadel.sh install firewall-strict   # Blocks external DNS (strict)

# Safe mode: Allows DNS to external servers for compatibility
# Strict mode: Blocks all external DNS for maximum security
```

### Step 6: Adblock Configuration
```bash
# Download and configure blocklists
sudo ./citadel.sh backup lists-update

# Choose blocklist profile
sudo ./citadel.sh adblock blocklist-list
sudo ./citadel.sh adblock blocklist-switch balanced

# Add custom domains to block
sudo ./citadel.sh adblock add ads.example.com
sudo ./citadel.sh adblock add tracker.example.com

# Add domains to allowlist (bypass blocking)
sudo ./citadel.sh adblock allowlist-add trusted.example.com
```

---

## Post-Installation

### Verification Tests
```bash
# Comprehensive system check
sudo ./citadel.sh monitor diagnostics

# DNS functionality test
sudo ./citadel.sh monitor verify-dns

# Service status check
sudo ./citadel.sh monitor status

# Adblock test
sudo ./citadel.sh adblock status
```

### Enable Auto-Updates (Recommended)
```bash
# Enable automatic blocklist updates
sudo ./citadel.sh backup auto-update-enable

# Configure update schedule (optional)
sudo ./citadel.sh backup auto-update-configure

# Check auto-update status
sudo ./citadel.sh backup auto-update-status
```

### Dashboard Usage
```bash
# Start terminal dashboard
sudo citadel-top

# Or run directly
./citadel-top

# Dashboard shows:
# - Service status (DNSCrypt, CoreDNS, NFTables)
# - DNS query metrics
# - Network status
# - System load
```

### Manual Testing
```bash
# Test DNS resolution
dig google.com @127.0.0.1

# Test adblocking (should return 0.0.0.0)
dig doubleclick.net @127.0.0.1

# Test allowlisted domain (should resolve normally)
dig trusted.example.com @127.0.0.1

# Check firewall rules
sudo nft list table inet citadel_dns
```

---

## Configuration Options

### DNS Server Configuration
```bash
# Edit CoreDNS configuration
sudo ./citadel.sh network edit

# Edit DNSCrypt configuration
sudo ./citadel.sh network edit-dnscrypt

# Restart services after config changes
sudo systemctl restart coredns dnscrypt-proxy
```

### IPv6 Privacy Extensions
```bash
# Enable IPv6 privacy addresses
sudo ./citadel.sh network ipv6-privacy-on

# Check IPv6 status
sudo ./citadel.sh network ipv6-privacy-status

# View IPv6 addresses
ip -6 addr show
```

### Security Features
```bash
# Initialize integrity checking
sudo ./citadel.sh security integrity-init

# Check file integrity
sudo ./citadel.sh security integrity-check

# Location-based security
sudo ./citadel.sh security location-add-trusted "MyHomeWiFi"
sudo ./citadel.sh security location-check
```

### Backup and Restore
```bash
# Create configuration backup
sudo ./citadel.sh backup config-backup

# List available backups
sudo ./citadel.sh backup config-list

# Restore from backup
sudo ./citadel.sh backup config-restore /path/to/backup.tar.gz
```

---

## Uninstallation

### Complete Uninstallation
```bash
# Restore system to pre-Citadel state
sudo ./citadel.sh recovery restore-system

# Remove Citadel files (optional)
sudo rm -rf /opt/cytadela
sudo rm -rf /var/lib/cytadela
sudo rm -f /usr/local/bin/citadel-top
```

### Selective Removal
```bash
# Remove specific components
sudo systemctl stop coredns dnscrypt-proxy
sudo systemctl disable coredns dnscrypt-proxy
sudo pacman -R coredns dnscrypt-proxy  # Arch Linux
sudo apt remove coredns dnscrypt-proxy  # Ubuntu/Debian

# Remove firewall rules
sudo nft delete table inet citadel_dns 2>/dev/null || true

# Remove systemd services
sudo rm -f /etc/systemd/system/citadel-*.service
sudo rm -f /etc/systemd/system/citadel-*.timer
sudo systemctl daemon-reload
```

---

## Troubleshooting

### Common Installation Issues

#### Permission Errors
```bash
# Ensure you're running as root for installation
sudo ./citadel.sh install all

# Check file permissions
ls -la citadel.sh
chmod +x citadel.sh
```

#### Package Not Found
```bash
# Update package database
sudo pacman -Syu  # Arch
sudo apt update   # Ubuntu/Debian
sudo dnf update   # Fedora

# Check available packages
pacman -Ss dnscrypt-proxy  # Arch
apt search dnscrypt-proxy   # Ubuntu/Debian
dnf search dnscrypt-proxy    # Fedora
```

#### Service Startup Failures
```bash
# Check service status
sudo systemctl status coredns
sudo systemctl status dnscrypt-proxy

# View service logs
sudo journalctl -u coredns -n 20
sudo journalctl -u dnscrypt-proxy -n 20

# Restart services
sudo systemctl restart coredns dnscrypt-proxy
```

#### DNS Not Working
```bash
# Check DNS configuration
cat /etc/resolv.conf

# Test local DNS
dig @127.0.0.1 google.com

# Check firewall rules
sudo nft list table inet citadel_dns

# Temporarily disable firewall for testing
sudo ./citadel.sh install firewall-safe
```

#### Adblocking Not Working
```bash
# Check blocklist status
sudo ./citadel.sh adblock status

# Update blocklists
sudo ./citadel.sh backup lists-update

# Check CoreDNS configuration
sudo ./citadel.sh network edit
```

### Recovery Procedures

#### Emergency DNS Restore
```bash
# Restore internet connectivity
sudo ./citadel.sh recovery emergency-network-restore

# Quick DNS fix
sudo ./citadel.sh recovery emergency-network-fix
```

#### System Restore
```bash
# Restore from backup
sudo ./citadel.sh backup config-restore /path/to/backup.tar.gz

# Or restore to defaults
sudo ./citadel.sh recovery restore-system-default
```

#### Panic Mode
```bash
# Temporarily disable protection
sudo ./citadel.sh recovery panic-bypass

# Restore protection
sudo ./citadel.sh recovery panic-restore
```

---

## Advanced Configuration

### Custom Blocklist Sources
```bash
# Add custom blocklist URL
sudo ./citadel.sh adblock blocklist-add-url "https://example.com/blocklist.txt"

# Switch to custom profile
sudo ./citadel.sh adblock blocklist-switch custom
```

### Prometheus Metrics
```bash
# Export metrics for monitoring
sudo ./citadel.sh monitor prometheus-export

# Start metrics server
sudo ./citadel.sh monitor prometheus-serve

# Access metrics
curl http://localhost:9100/metrics
```

### Performance Tuning
```bash
# Run performance benchmarks
sudo ./citadel.sh monitor benchmark-dns

# Check cache statistics
sudo ./citadel.sh monitor cache-stats

# Monitor system load
sudo ./citadel.sh monitor health-status
```

---

## Getting Help

### Built-in Help
```bash
# General help
./citadel.sh help

# Module-specific help
./citadel.sh install help
./citadel.sh adblock help
./citadel.sh monitor help
```

### Documentation
- **Installation Guide:** This document
- **User Manual:** `docs/MANUAL_EN.md` / `docs/MANUAL_PL.md`
- **Testing Procedure:** `docs/TESTING-PROCEDURE.md`
- **Unified Modules:** `docs/UNIFIED-MODULES-DOCUMENTATION.md`

### Community Support
- **GitHub Issues:** Report bugs and request features
- **Documentation:** Check docs/ for detailed guides
- **Testing:** Use provided test procedures

---

## Success Checklist

After installation, verify these items:

- [ ] DNS resolution works: `dig google.com @127.0.0.1`
- [ ] Adblocking active: `dig doubleclick.net @127.0.0.1` returns 0.0.0.0
- [ ] Services running: `./citadel.sh monitor status`
- [ ] Firewall configured: `./citadel.sh monitor verify`
- [ ] Dashboard works: `citadel-top`
- [ ] Auto-updates enabled: `./citadel.sh backup auto-update-status`

---

**Citadel v3.2 Installation Complete!**
**For questions or issues, check the troubleshooting section or create a GitHub issue.**
