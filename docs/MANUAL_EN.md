# Citadel v3.2 User Manual (English)

**Version:** 3.2.0
**Last Updated:** 2026-02-04
**Compatibility:** Bash 4.x/5.x, Linux (Arch, Ubuntu, Fedora)

---

## Table of Contents

1. [Introduction](#introduction)
2. [Quick Start](#quick-start)
3. [Unified Command Interface](#unified-command-interface)
4. [Recovery & Emergency](#recovery--emergency)
5. [Installation & Setup](#installation--setup)
6. [Security & Monitoring](#security--monitoring)
7. [Network Configuration](#network-configuration)
8. [Ad Blocking](#ad-blocking)
9. [Backup & Restore](#backup--restore)
10. [Monitoring & Diagnostics](#monitoring--diagnostics)
11. [Troubleshooting](#troubleshooting)
12. [Migration Guide](#migration-guide)

---

## Introduction

Citadel is a comprehensive DNS-based network protection system featuring encrypted DNS (DNSCrypt), ad blocking, firewall rules, and advanced monitoring capabilities.

### What's New in v3.2

**Unified Architecture:** All functionality consolidated into 7 specialized modules:
- `unified-recovery.sh` - Emergency recovery and system restoration
- `unified-install.sh` - Complete installation system
- `unified-security.sh` - Security monitoring and integrity
- `unified-network.sh` - Network configuration tools
- `unified-adblock.sh` - Ad blocking and allowlisting
- `unified-backup.sh` - Backup and auto-update functionality
- `unified-monitor.sh` - Monitoring, diagnostics, and benchmarking

**Backward Compatibility:** All legacy commands continue to work unchanged.

**Smart Module Loading:** Modules load on-demand with integrity verification.

---

## Quick Start

### Basic Installation
```bash
# Download and install
git clone https://github.com/your-org/cytadela.git
cd cytadela

# Run complete installation
sudo ./citadel.sh install all

# Configure system DNS
sudo ./citadel.sh install configure-system
```

### First Use
```bash
# Check system status
sudo ./citadel.sh monitor status

# Run diagnostics
sudo ./citadel.sh monitor diagnostics

# View dashboard
sudo citadel-top
```

---

## Unified Command Interface

Citadel v3.2 uses a unified command structure:

```
citadel <module> <action> [parameters]
```

### Available Modules

| Module | Purpose | Example Commands |
|--------|---------|------------------|
| `recovery` | Emergency recovery | `panic-status`, `emergency-network-restore` |
| `install` | Installation & setup | `dnscrypt`, `coredns`, `all`, `configure-system` |
| `security` | Security monitoring | `integrity-check`, `location-check`, `ghost-check` |
| `network` | Network tools | `ipv6-privacy-on`, `edit`, `logs`, `fix-ports` |
| `adblock` | Ad blocking | `status`, `add`, `blocklist-switch`, `allowlist-add` |
| `backup` | Backup & auto-update | `config-backup`, `lkg-status`, `auto-update-enable` |
| `monitor` | Monitoring & diagnostics | `diagnostics`, `cache-stats`, `benchmark-dns` |

### Legacy Commands (Still Supported)

All v3.1 commands continue to work:
- `panic-bypass` → `citadel recovery panic-bypass`
- `install-all` → `citadel install all`
- `adblock-status` → `citadel adblock status`

---

## Recovery & Emergency

### Panic Mode
Temporarily disable DNS protection for troubleshooting:

```bash
# Enter panic mode (5-minute auto-rollback)
sudo ./citadel.sh recovery panic-bypass

# Check panic status
sudo ./citadel.sh recovery panic-status

# Restore protection
sudo ./citadel.sh recovery panic-restore
```

### Emergency Network Restore
Restore internet connectivity when DNS is broken:

```bash
# Complete network recovery
sudo ./citadel.sh recovery emergency-network-restore

# Quick DNS fix only
sudo ./citadel.sh recovery emergency-network-fix
```

### System Restore
Restore system configuration from backup:

```bash
# Restore from backup
sudo ./citadel.sh recovery restore-system

# Restore to factory defaults
sudo ./citadel.sh recovery restore-system-default
```

---

## Installation & Setup

### Complete Installation
```bash
# Install everything
sudo ./citadel.sh install all

# Install individual components
sudo ./citadel.sh install dnscrypt
sudo ./citadel.sh install coredns
sudo ./citadel.sh install nftables
sudo ./citadel.sh install dashboard
```

### System Configuration
```bash
# Configure system to use Cytadela DNS
sudo ./citadel.sh install configure-system

# Set firewall mode
sudo ./citadel.sh install firewall-safe    # Allow external DNS
sudo ./citadel.sh install firewall-strict  # Block external DNS
```

### Dependencies
```bash
# Check and install missing dependencies
sudo ./citadel.sh install check-deps

# Interactive installation wizard
sudo ./citadel.sh install wizard
```

---

## Security & Monitoring

### Integrity Verification
```bash
# Initialize integrity checking
sudo ./citadel.sh security integrity-init

# Verify file integrity
sudo ./citadel.sh security integrity-check

# Show integrity status
sudo ./citadel.sh security integrity-status
```

### Location-Based Security
```bash
# Check current network security
sudo ./citadel.sh security location-check

# Manage trusted networks
sudo ./citadel.sh security location-add-trusted "MyHomeWiFi"
sudo ./citadel.sh security location-remove-trusted "PublicWiFi"
sudo ./citadel.sh security location-list-trusted
```

### Supply Chain Security
```bash
# Initialize supply chain verification
sudo ./citadel.sh security supply-chain-init

# Verify sources and binaries
sudo ./citadel.sh security supply-chain-verify

# Show supply chain status
sudo ./citadel.sh security supply-chain-status
```

### Security Audit
```bash
# Check for open ports and suspicious processes
sudo ./citadel.sh security ghost-check

# Debug firewall rules
sudo ./citadel.sh security nft-debug-on
sudo ./citadel.sh security nft-debug-status
sudo ./citadel.sh security nft-debug-logs
```

---

## Network Configuration

### IPv6 Privacy Extensions
```bash
# Enable IPv6 privacy
sudo ./citadel.sh network ipv6-privacy-on

# Disable IPv6 privacy
sudo ./citadel.sh network ipv6-privacy-off

# Auto-configure IPv6 privacy
sudo ./citadel.sh network ipv6-privacy-auto

# Check IPv6 privacy status
sudo ./citadel.sh network ipv6-privacy-status
```

### Configuration Editing
```bash
# Edit CoreDNS configuration
sudo ./citadel.sh network edit

# Edit DNSCrypt configuration
sudo ./citadel.sh network edit-dnscrypt

# View system logs
sudo ./citadel.sh network logs            # Show recent logs
sudo ./citadel.sh network logs 50          # Show last 50 lines
sudo ./citadel.sh network logs coredns     # Show CoreDNS logs
sudo ./citadel.sh network logs dnscrypt    # Show DNSCrypt logs
```

### Port Management
```bash
# Check for port conflicts
sudo ./citadel.sh network fix-ports
```

### Notifications
```bash
# Enable desktop notifications
sudo ./citadel.sh network notify-enable

# Disable notifications
sudo ./citadel.sh network notify-disable

# Check notification status
sudo ./citadel.sh network notify-status

# Test notifications
sudo ./citadel.sh network notify-test
```

---

## Ad Blocking

### Status & Statistics
```bash
# Show adblock status
sudo ./citadel.sh adblock status

# Show statistics
sudo ./citadel.sh adblock stats

# Show blocklist contents
sudo ./citadel.sh adblock show blocklist   # Show blocked domains
sudo ./citadel.sh adblock show custom      # Show custom blocks
sudo ./citadel.sh adblock show combined    # Show all blocks
```

### Domain Management
```bash
# Add domain to blocklist
sudo ./citadel.sh adblock add ads.example.com

# Remove domain from blocklist
sudo ./citadel.sh adblock remove ads.example.com

# Edit custom blocklist
sudo ./citadel.sh adblock edit
```

### Allowlist Management
```bash
# Show allowlist
sudo ./citadel.sh adblock allowlist-list

# Add to allowlist (bypass blocking)
sudo ./citadel.sh adblock allowlist-add trusted.example.com

# Remove from allowlist
sudo ./citadel.sh adblock allowlist-remove trusted.example.com
```

### Blocklist Profiles
```bash
# List available profiles
sudo ./citadel.sh adblock blocklist-list

# Switch profile
sudo ./citadel.sh adblock blocklist-switch balanced

# Show current profile status
sudo ./citadel.sh adblock blocklist-status

# Add custom blocklist URL
sudo ./citadel.sh adblock blocklist-add-url "https://example.com/blocklist.txt"
```

---

## Backup & Restore

### Configuration Backup
```bash
# Create backup
sudo ./citadel.sh backup config-backup

# List available backups
sudo ./citadel.sh backup config-list

# Restore from backup
sudo ./citadel.sh backup config-restore /path/to/backup.tar.gz

# Delete backup
sudo ./citadel.sh backup config-delete /path/to/backup.tar.gz
```

### Last Known Good (LKG)
```bash
# Save current blocklist as LKG
sudo ./citadel.sh backup lkg-save

# Restore from LKG cache
sudo ./citadel.sh backup lkg-restore

# Show LKG status
sudo ./citadel.sh backup lkg-status
```

### Auto-Update
```bash
# Enable automatic blocklist updates
sudo ./citadel.sh backup auto-update-enable

# Disable auto-updates
sudo ./citadel.sh backup auto-update-disable

# Check auto-update status
sudo ./citadel.sh backup auto-update-status

# Configure update schedule
sudo ./citadel.sh backup auto-update-configure

# Manual update now
sudo ./citadel.sh backup auto-update-now
```

### Blocklist Updates
```bash
# Update blocklists with LKG fallback
sudo ./citadel.sh backup lists-update
```

---

## Monitoring & Diagnostics

### System Status
```bash
# Show comprehensive status
sudo ./citadel.sh monitor status

# Run full diagnostics
sudo ./citadel.sh monitor diagnostics

# Verify configuration
sudo ./citadel.sh monitor verify

# Run all tests
sudo ./citadel.sh monitor test-all
```

### Cache Statistics
```bash
# Show cache performance
sudo ./citadel.sh monitor cache-stats

# Show top domains
sudo ./citadel.sh monitor cache-top

# Reset cache statistics
sudo ./citadel.sh monitor cache-reset

# Watch cache stats live
sudo ./citadel.sh monitor cache-watch
```

### Health Monitoring
```bash
# Check system health
sudo ./citadel.sh monitor health-status

# Install health watchdog
sudo ./citadel.sh monitor health-watchdog-install

# Uninstall health watchdog
sudo ./citadel.sh monitor health-watchdog-uninstall
```

### Prometheus Metrics
```bash
# Export metrics for Prometheus
sudo ./citadel.sh monitor prometheus-export

# Start metrics server
sudo ./citadel.sh monitor prometheus-serve

# Show metrics status
sudo ./citadel.sh monitor prometheus-status
```

### Performance Benchmarks
```bash
# Run DNS performance benchmark
sudo ./citadel.sh monitor benchmark-dns

# Run all benchmarks
sudo ./citadel.sh monitor benchmark-all

# Show benchmark reports
sudo ./citadel.sh monitor benchmark-report

# Compare benchmark results
sudo ./citadel.sh monitor benchmark-compare
```

### Verify Configuration
```bash
# Check configuration files
sudo ./citadel.sh monitor verify-config

# Test DNS functionality
sudo ./citadel.sh monitor verify-dns

# Verify services
sudo ./citadel.sh monitor verify-services

# Verify files
sudo ./citadel.sh monitor verify-files
```

---

## Troubleshooting

### Common Issues

#### DNS Not Working
```bash
# Check DNS resolution
sudo ./citadel.sh monitor verify-dns

# Emergency network restore
sudo ./citadel.sh recovery emergency-network-restore

# Check firewall rules
sudo ./citadel.sh monitor verify
```

#### Services Not Starting
```bash
# Check service status
sudo ./citadel.sh monitor status

# View service logs
sudo ./citadel.sh network logs coredns
sudo ./citadel.sh network logs dnscrypt

# Restart services
sudo systemctl restart coredns dnscrypt-proxy
```

#### Ad Blocking Not Working
```bash
# Check adblock status
sudo ./citadel.sh adblock status

# Rebuild blocklist
sudo ./citadel.sh backup lists-update

# Check allowlist
sudo ./citadel.sh adblock allowlist-list
```

#### Firewall Issues
```bash
# Check firewall status
sudo ./citadel.sh monitor verify

# Set safe mode temporarily
sudo ./citadel.sh install firewall-safe

# Reset to strict mode
sudo ./citadel.sh install firewall-strict
```

### Getting Help

#### Built-in Help
```bash
# General help
./citadel.sh help

# Module-specific help
./citadel.sh install help
./citadel.sh adblock help
./citadel.sh monitor help
```

#### Logs and Debugging
```bash
# System logs
sudo ./citadel.sh network logs

# Service-specific logs
sudo journalctl -u coredns -f
sudo journalctl -u dnscrypt-proxy -f

# Debug mode (if available)
export CYTADELA_MODE=developer
```

---

## Migration Guide

### From v3.1 to v3.2

Citadel v3.2 maintains **100% backward compatibility**. All existing commands and configurations continue to work unchanged.

#### What's Changed
- **Architecture:** 29 modules consolidated into 7 unified modules
- **Commands:** New unified command structure available
- **Performance:** Improved loading and reduced memory usage
- **Security:** Enhanced integrity checking and supply chain verification

#### What's New
- **Unified Commands:** `citadel <module> <action>` syntax
- **Smart Loading:** Modules load on-demand
- **Enhanced Monitoring:** Prometheus metrics, health checks, benchmarks
- **IPv6 Privacy:** Automatic privacy address management
- **Location Security:** WiFi network-based security policies

#### Migration Steps
1. **Update:** Pull latest code from repository
2. **Backup:** Create configuration backup (recommended)
3. **Test:** Run diagnostics to verify everything works
4. **Optional:** Start using new unified commands

#### Legacy Command Support
All v3.1 commands continue to work:
```bash
# Old commands (still work)
sudo ./citadel.sh install-all
sudo ./citadel.sh adblock-status
sudo ./citadel.sh panic-bypass

# New unified commands (recommended)
sudo ./citadel.sh install all
sudo ./citadel.sh adblock status
sudo ./citadel.sh recovery panic-bypass
```

### Support
- **Documentation:** This manual and REFACTORING-V3.2-ROADMAP.md
- **Issues:** GitHub issues with `unified-modules` label
- **Community:** Project discussions and wiki

---

**Citadel v3.2 - Unified Architecture for Enhanced Security and Performance**
