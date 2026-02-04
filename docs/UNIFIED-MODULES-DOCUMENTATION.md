# 📚 Cytadela++ v3.2 - Unified Modules Documentation

**Version:** 3.2.0
**Created:** 2026-02-04
**Status:** Phase 0-4 Complete (71% implementation)

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [unified-recovery.sh](#unified-recovery)
3. [unified-install.sh](#unified-install)
4. [unified-security.sh](#unified-security)
5. [unified-network.sh](#unified-network)
6. [Command Migration Table](#command-migration)
7. [Backward Compatibility](#backward-compatibility)
8. [Developer Guide](#developer-guide)

---

## 🏗️ Architecture Overview

### **What are Unified Modules?**

Cytadela++ v3.2 introduces **unified modules** - a new architecture that consolidates 29 scattered modules into 7 focused, maintainable modules. Each unified module handles a specific domain of functionality.

### **Benefits**
- **Reduced Complexity:** 29 → 7 modules (-75%)
- **Single Source of Truth:** No more scattered functions
- **Better Maintainability:** Consistent interfaces and patterns
- **Improved Testing:** Isolated, focused modules
- **Backward Compatible:** All old commands still work

### **Unified Module Structure**
```
modules/unified/
├── unified-recovery.sh   (~1,100 LOC) - Emergency & system recovery
├── unified-install.sh    (~1,500 LOC) - All installation functions
├── unified-security.sh   (~560 LOC)  - Security, integrity, location
├── unified-network.sh    (~570 LOC)  - Network tools & IPv6
├── unified-adblock.sh    (~800 LOC)  - Ad blocking (Phase 5)
├── unified-backup.sh     (~700 LOC)  - Backup & auto-update (Phase 5)
└── unified-monitor.sh    (~600 LOC)  - Monitoring & diagnostics (Phase 6)
```

---

## 🔄 unified-recovery.sh

**Purpose:** Emergency recovery and system restoration functions

### **Functions Included**
- **Panic Mode:** `panic_bypass()`, `panic_restore()`, `panic_status()`
- **Emergency Network:** `emergency_network_restore()`, `emergency_network_fix()`
- **System Restore:** `restore_system()`, `restore_system_default()`
- **IPv6 Recovery:** IPv6 deep reset and smart recovery
- **VPN Detection:** Automatic VPN handling in recovery scenarios

### **Available Commands**

| Command | Description | Example |
|---------|-------------|---------|
| `citadel recovery panic-bypass` | Temporarily disable DNS protection | `citadel recovery panic-bypass` |
| `citadel recovery panic-restore` | Restore DNS protection | `citadel recovery panic-restore` |
| `citadel recovery panic-status` | Show panic mode status | `citadel recovery panic-status` |
| `citadel recovery emergency-network-restore` | Full network recovery | `citadel recovery emergency-network-restore` |
| `citadel recovery emergency-network-fix` | Quick DNS fix | `citadel recovery emergency-network-fix` |
| `citadel recovery restore-system` | Restore system from backup | `citadel recovery restore-system` |
| `citadel recovery restore-system-default` | Restore to factory defaults | `citadel recovery restore-system-default` |

### **Key Features**
- **Auto-rollback:** Panic mode automatically restores after timeout
- **VPN-aware:** Detects and preserves VPN connections during recovery
- **Multi-stage recovery:** DNS → Firewall → Network → Testing
- **Backup integration:** Uses system backups for restoration

### **Examples**
```bash
# Emergency recovery when internet is broken
sudo citadel recovery emergency-network-restore

# Temporary panic mode (5 minute auto-rollback)
sudo citadel recovery panic-bypass 300

# Restore system from backup
sudo citadel recovery restore-system
```

---

## ⚙️ unified-install.sh

**Purpose:** Complete installation system for all Cytadela components

### **Functions Included**
- **DNSCrypt Installation:** `install_dnscrypt()`
- **CoreDNS Installation:** `install_coredns()`
- **Firewall Installation:** `install_nftables()`, `firewall_safe()`, `firewall_strict()`
- **System Configuration:** `configure_system()`
- **Dashboard Installation:** `install_dashboard()`
- **Dependency Management:** `check_dependencies_install()`
- **Complete Installation:** `install_all()`, `install_wizard()`

### **Available Commands**

| Command | Description | Example |
|---------|-------------|---------|
| `citadel install dnscrypt` | Install DNSCrypt-Proxy | `citadel install dnscrypt` |
| `citadel install coredns` | Install CoreDNS | `citadel install coredns` |
| `citadel install nftables` | Install NFTables firewall | `citadel install nftables` |
| `citadel install dashboard` | Install terminal dashboard | `citadel install dashboard` |
| `citadel install all` | Complete system installation | `citadel install all` |
| `citadel install wizard` | Interactive installation wizard | `citadel install wizard` |
| `citadel install check-deps` | Install missing dependencies | `citadel install check-deps` |
| `citadel install firewall-safe` | Set safe firewall mode | `citadel install firewall-safe` |
| `citadel install firewall-strict` | Set strict firewall mode | `citadel install firewall-strict` |
| `citadel install configure-system` | Configure system DNS | `citadel install configure-system` |

### **Key Features**
- **Modular Installation:** Install individual components or everything
- **Dependency Resolution:** Automatic package manager detection and installation
- **Firewall Modes:** Safe vs Strict DNS leak protection
- **System Integration:** Automatic systemd-resolved disabling
- **Interactive Wizard:** Simplified setup for new users

### **Examples**
```bash
# Complete installation
sudo citadel install all

# Install individual components
sudo citadel install dnscrypt
sudo citadel install coredns
sudo citadel install nftables

# Configure firewall mode
sudo citadel install firewall-strict

# Install missing dependencies
sudo citadel install check-deps
```

---

## 🔒 unified-security.sh

**Purpose:** Security monitoring, integrity verification, and access control

### **Functions Included**
- **Integrity Verification:** `integrity_init()`, `integrity_check()`, `integrity_status()`
- **Location-based Security:** `location_check()`, `location_add_trusted()`, `location_remove_trusted()`
- **Supply Chain Security:** `supply_chain_init()`, `supply_chain_verify()`
- **Ghost Check:** `ghost_check()` - open ports and suspicious processes
- **NFT Debug:** `nft_debug_on()`, `nft_debug_off()`, `nft_debug_status()`

### **Available Commands**

| Command | Description | Example |
|---------|-------------|---------|
| `citadel security integrity-init` | Initialize integrity manifest | `citadel security integrity-init` |
| `citadel security integrity-check` | Verify file integrity | `citadel security integrity-check` |
| `citadel security integrity-status` | Show integrity status | `citadel security integrity-status` |
| `citadel security location-check` | Check current network security | `citadel security location-check` |
| `citadel security location-add-trusted <SSID>` | Add trusted WiFi network | `citadel security location-add-trusted MyHomeWiFi` |
| `citadel security location-remove-trusted <SSID>` | Remove trusted network | `citadel security location-remove-trusted PublicWiFi` |
| `citadel security location-list-trusted` | List trusted networks | `citadel security location-list-trusted` |
| `citadel security supply-chain-init` | Initialize supply chain verification | `citadel security supply-chain-init` |
| `citadel security supply-chain-verify` | Verify supply chain | `citadel security supply-chain-verify` |
| `citadel security supply-chain-status` | Show supply chain status | `citadel security supply-chain-status` |
| `citadel security ghost-check` | Security audit for open ports | `citadel security ghost-check` |
| `citadel security nft-debug-on` | Enable NFTables debug logging | `citadel security nft-debug-on` |
| `citadel security nft-debug-off` | Disable NFTables debug logging | `citadel security nft-debug-off` |
| `citadel security nft-debug-status` | Show debug status | `citadel security nft-debug-status` |
| `citadel security nft-debug-logs` | Show debug logs | `citadel security nft-debug-logs` |

### **Key Features**
- **File Integrity:** SHA256 verification with developer mode bypass
- **Location Awareness:** WiFi network-based security policies
- **Supply Chain:** Verification of update sources and binaries
- **Security Audit:** Detection of suspicious processes and open ports
- **Firewall Debugging:** Real-time NFTables logging and monitoring

### **Examples**
```bash
# Initialize integrity checking
sudo citadel security integrity-init

# Check current network security
sudo citadel security location-check

# Add trusted WiFi network
sudo citadel security location-add-trusted "OfficeWiFi"

# Run security audit
sudo citadel security ghost-check

# Enable firewall debugging
sudo citadel security nft-debug-on
```

---

## 🌐 unified-network.sh

**Purpose:** Network configuration and IPv6 management tools

### **Functions Included**
- **IPv6 Privacy:** `ipv6_privacy_auto_ensure()`, `ipv6_privacy_on()`, `ipv6_privacy_off()`, `ipv6_privacy_status()`
- **Edit Tools:** `edit_config()`, `edit_dnscrypt()`, `show_logs()`
- **Port Management:** `fix_port_conflicts()`
- **Notifications:** `notify_enable()`, `notify_disable()`, `notify_status()`, `notify_test()`

### **Available Commands**

| Command | Description | Example |
|---------|-------------|---------|
| `citadel network ipv6-privacy-auto` | Auto-ensure IPv6 privacy | `citadel network ipv6-privacy-auto` |
| `citadel network ipv6-privacy-on` | Enable IPv6 privacy extensions | `citadel network ipv6-privacy-on` |
| `citadel network ipv6-privacy-off` | Disable IPv6 privacy extensions | `citadel network ipv6-privacy-off` |
| `citadel network ipv6-privacy-status` | Show IPv6 privacy status | `citadel network ipv6-privacy-status` |
| `citadel network edit` | Edit CoreDNS configuration | `citadel network edit` |
| `citadel network edit-dnscrypt` | Edit DNSCrypt configuration | `citadel network edit-dnscrypt` |
| `citadel network logs` | Show system logs | `citadel network logs coredns` |
| `citadel network logs <lines>` | Show logs with custom line count | `citadel network logs 100` |
| `citadel network fix-ports` | Fix port conflicts | `citadel network fix-ports` |
| `citadel network notify-enable` | Enable notifications | `citadel network notify-enable` |
| `citadel network notify-disable` | Disable notifications | `citadel network notify-disable` |
| `citadel network notify-status` | Show notification status | `citadel network notify-status` |
| `citadel network notify-test` | Test notifications | `citadel network notify-test` |

### **Key Features**
- **IPv6 Privacy:** Automatic privacy address management
- **Configuration Editing:** Built-in editors for DNS configs
- **Log Management:** Centralized log viewing with filtering
- **Port Conflict Resolution:** Automatic detection and fixing
- **Notification System:** Desktop and system notifications

### **Examples**
```bash
# Ensure IPv6 privacy
sudo citadel network ipv6-privacy-auto

# Edit CoreDNS configuration
sudo citadel network edit

# Show CoreDNS logs
sudo citadel network logs coredns

# Enable notifications
sudo citadel network notify-enable

# Test notifications
sudo citadel network notify-test
```

---

## 🔄 Command Migration Table

### **Recovery Commands Migration**

| Legacy Command | New Unified Command | Status |
|----------------|---------------------|--------|
| `panic-bypass` | `citadel recovery panic-bypass` | ✅ Migrated |
| `panic-restore` | `citadel recovery panic-restore` | ✅ Migrated |
| `panic-status` | `citadel recovery panic-status` | ✅ Migrated |
| `emergency-network-restore` | `citadel recovery emergency-network-restore` | ✅ Migrated |
| `restore-system` | `citadel recovery restore-system` | ✅ Migrated |
| `restore-system-default` | `citadel recovery restore-system-default` | ✅ Migrated |

### **Installation Commands Migration**

| Legacy Command | New Unified Command | Status |
|----------------|---------------------|--------|
| `install-dnscrypt` | `citadel install dnscrypt` | ✅ Migrated |
| `install-coredns` | `citadel install coredns` | ✅ Migrated |
| `install-nftables` | `citadel install nftables` | ✅ Migrated |
| `install-dashboard` | `citadel install dashboard` | ✅ Migrated |
| `install-all` | `citadel install all` | ✅ Migrated |
| `install-wizard` | `citadel install wizard` | ✅ Migrated |
| `firewall-safe` | `citadel install firewall-safe` | ✅ Migrated |
| `firewall-strict` | `citadel install firewall-strict` | ✅ Migrated |
| `configure-system` | `citadel install configure-system` | ✅ Migrated |
| `check-dependencies` | `citadel install check-deps` | ✅ Migrated |

### **Security Commands Migration**

| Legacy Command | New Unified Command | Status |
|----------------|---------------------|--------|
| `integrity-init` | `citadel security integrity-init` | ✅ Migrated |
| `integrity-check` | `citadel security integrity-check` | ✅ Migrated |
| `integrity-status` | `citadel security integrity-status` | ✅ Migrated |
| `location-status` | `citadel security location-check` | ✅ Migrated |
| `location-add-trusted` | `citadel security location-add-trusted` | ✅ Migrated |
| `supply-chain-init` | `citadel security supply-chain-init` | ✅ Migrated |
| `supply-chain-verify` | `citadel security supply-chain-verify` | ✅ Migrated |
| `ghost-check` | `citadel security ghost-check` | ✅ Migrated |
| `nft-debug-on` | `citadel security nft-debug-on` | ✅ Migrated |

### **Network Commands Migration**

| Legacy Command | New Unified Command | Status |
|----------------|---------------------|--------|
| `ipv6-privacy-on` | `citadel network ipv6-privacy-on` | ✅ Migrated |
| `ipv6-privacy-off` | `citadel network ipv6-privacy-off` | ✅ Migrated |
| `ipv6-privacy-auto` | `citadel network ipv6-privacy-auto` | ✅ Migrated |
| `edit` | `citadel network edit` | ✅ Migrated |
| `edit-dnscrypt` | `citadel network edit-dnscrypt` | ✅ Migrated |
| `logs` | `citadel network logs` | ✅ Migrated |
| `fix-ports` | `citadel network fix-ports` | ✅ Migrated |
| `notify-enable` | `citadel network notify-enable` | ✅ Migrated |

---

## 🔙 Backward Compatibility

### **100% Backward Compatibility Guarantee**

All legacy commands continue to work exactly as before. The unified architecture uses:

1. **Command Translation Layer:** Legacy commands are automatically translated to unified format
2. **Alias System:** Old module functions remain accessible
3. **Gradual Migration:** Users can migrate at their own pace

### **Translation Examples**
```bash
# These all work identically:
citadel emergency                # Legacy (still works)
citadel recovery panic-bypass    # Unified (recommended)

citadel install-all             # Legacy (still works)
citadel install all             # Unified (recommended)

citadel ghost-check             # Legacy (still works)
citadel security ghost-check    # Unified (recommended)
```

### **Migration Timeline**
- **Phase 0-4:** Legacy commands fully supported
- **Phase 5-7:** Documentation updates to unified commands
- **v3.3.0:** Legacy command deprecation warnings
- **v4.0.0:** Legacy commands removed (if needed)

---

## 👨‍💻 Developer Guide

### **Adding New Unified Functions**

1. **Choose Module:** Determine which unified module fits the functionality
2. **Add Function:** Implement in appropriate `modules/unified/unified-*.sh`
3. **Update Dispatcher:** Add case in `citadel.sh` for new commands
4. **Add i18n:** Add strings to `lib/i18n/*/recovery/*.sh` if needed
5. **Test:** Ensure backward compatibility and new functionality

### **Module Structure Standards**

Each unified module follows this pattern:
```bash
#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-[MODULE] MODULE v3.2                                ║
# ║  [Brief description]                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Configuration constants
MODULE_CONFIG_VAR="value"

# Public API functions (called by dispatcher)
function_name() {
    # Implementation
}

# Private helper functions (prefixed with _)
_helper_function() {
    # Implementation
}
```

### **Testing Unified Modules**

```bash
# Test individual modules
sudo ./citadel.sh recovery panic-status
sudo ./citadel.sh install check-deps
sudo ./citadel.sh security integrity-check
sudo ./citadel.sh network ipv6-privacy-status

# Test backward compatibility
sudo ./citadel.sh panic-status          # Should still work
sudo ./citadel.sh check-dependencies    # Should still work
sudo ./citadel.sh ghost-check           # Should still work
```

---

## 📞 Support

### **Getting Help**
- **Documentation:** This document and REFACTORING-V3.2-ROADMAP.md
- **Commands:** `citadel help` or `citadel --help`
- **Issues:** GitHub issues with `unified-modules` label
- **Migration:** MIGRATION-v3.1-to-v3.2.md (Phase 7)

### **Version Information**
- **Current Version:** v3.2.0-alpha (Phase 0-4 complete)
- **Next Milestone:** Phase 5 (Adblock & Backup modules)
- **Full Release:** Expected Q1 2026

---

**Last Updated:** 2026-02-04
**Implementation Progress:** Phase 0-4 Complete (71%)
