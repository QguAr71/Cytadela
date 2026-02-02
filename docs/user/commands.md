# 📋 Commands Reference

Complete list of all Citadel commands.

---

## 🚀 Installation Commands

| Command | Description |
|---------|-------------|
| `install-wizard` | Interactive installation wizard (recommended) |
| `install-all` | Install all components |
| `install-dnscrypt` | Install DNSCrypt-Proxy only |
| `install-coredns` | Install CoreDNS only |
| `install-nftables` | Install NFTables firewall only |
| `install-dashboard` | Install terminal dashboard |
| `install-editor` | Install editor integration |
| `install-doh-parallel` | Install DoH parallel racing |
| `check-deps` | Check dependencies |
| `check-dependencies` | Check dependencies (alias) |
| `check-deps --install` | Install missing dependencies (with AUR fallback for Arch) |
| `verify-config` | Verify configuration, services, and DNS |
| `verify-config dns` | Test DNS resolution only |
| `verify-config services` | Show service status only |
| `verify-config files` | Show configuration files only |
| `verify-config all` | Run all verification checks |

---

## ⚙️ Configuration Commands

| Command | Description |
|---------|-------------|
| `configure-system` | Switch system to Citadel DNS |
| `restore-system` | Restore original DNS configuration (from backup) |
| `restore-system-default` | Restore factory DNS configuration (safe fallback) |
| `firewall-safe` | Enable safe firewall mode |
| `firewall-strict` | Enable strict firewall mode |
| `fix-ports` | Resolve port conflicts |
| `optimize-kernel` | Optimize kernel priority for DNS |

---

## 📊 Monitoring Commands

| Command | Description |
|---------|-------------|
| `status` | Show service status |
| `verify` | Verify full stack |
| `diagnostics` | Run full diagnostics |
| `health-status` | Health check |
| `health-install` | Install health watchdog |
| `health-uninstall` | Uninstall health watchdog |
| `discover` | Network & firewall snapshot |
| `cache-stats` | DNS cache statistics |
| `cache-stats-top [N]` | Top N most queried domains |
| `cache-stats-reset` | Reset statistics |
| `cache-stats-watch` | Watch statistics live |
| `logs` | Show recent logs |

---

## 🚫 Adblock Commands

| Command | Description |
|---------|-------------|
| `adblock-status` | Show adblock status |
| `adblock-stats` | Show statistics |
| `adblock-add <domain>` | Block custom domain |
| `adblock-remove <domain>` | Unblock domain |
| `adblock-query <domain>` | Query domain |
| `adblock-show <type>` | Show blocklist (custom/blocklist/combined) |
| `adblock-rebuild` | Rebuild blocklist |
| `blocklist-list` | List available blocklist profiles |
| `blocklist-switch <profile>` | Switch blocklist profile |
| `blocklist-status` | Show blocklist status |
| `blocklist-add-url <url>` | Add custom blocklist URL |
| `blocklist-remove-url <url>` | Remove blocklist URL |
| `blocklist-show-urls` | Show configured blocklist URLs |
| `allowlist-list` | Show allowlisted domains |
| `allowlist-add <domain>` | Add domain to allowlist |
| `allowlist-remove <domain>` | Remove domain from allowlist |

---

## 🔐 Security Commands

| Command | Description |
|---------|-------------|
| `supply-chain-status` | Show supply chain status |
| `supply-chain-init` | Initialize checksums |
| `supply-chain-verify` | Verify integrity |
| `integrity-status` | Show integrity status |
| `integrity-init` | Initialize integrity manifest |
| `integrity-check` | Verify integrity |
| `ghost-check` | Audit open ports |

---

## 🚨 Emergency Commands

| Command | Description |
|---------|-------------|
| `panic-bypass [seconds]` | Emergency recovery mode |
| `panic-restore` | Restore from panic mode |
| `panic-status` | Show panic mode status |
| `emergency-refuse` | Refuse all DNS queries |
| `emergency-restore` | Restore normal operation |
| `killswitch-on` | Activate DNS killswitch |
| `killswitch-off` | Deactivate killswitch |

---

## 🌍 IPv6 Commands

| Command | Description |
|---------|-------------|
| `ipv6-privacy-on` | Enable IPv6 privacy |
| `ipv6-privacy-off` | Disable IPv6 privacy |
| `ipv6-privacy-status` | Show privacy status |
| `ipv6-privacy-auto` | Auto-ensure privacy |
| `ipv6-deep-reset` | Deep reset IPv6 |
| `smart-ipv6` | Smart IPv6 detection |

---

## 📍 Location Commands

| Command | Description |
|---------|-------------|
| `location-status` | Show location status |
| `location-check` | Check and advise |
| `location-add-trusted [ssid]` | Add trusted SSID |
| `location-remove-trusted <ssid>` | Remove trusted SSID |
| `location-list-trusted` | List trusted SSIDs |

---

## 🔄 Auto-Update Commands

| Command | Description |
|---------|-------------|
| `auto-update-enable` | Enable auto-updates |
| `auto-update-disable` | Disable auto-updates |
| `auto-update-status` | Show status |
| `auto-update-now` | Update now |
| `auto-update-configure` | Configure settings |

---

## 💾 Backup Commands

| Command | Description |
|---------|-------------|
| `config-backup` | Backup configuration |
| `config-restore [file]` | Restore configuration from backup |
| `config-list` | List backups |
| `config-delete <file>` | Delete backup |
| `lkg-save` | Save last-known-good |
| `lkg-restore` | Restore last-known-good |
| `lkg-status` | Show LKG status |

---

## �️ Uninstall Commands

| Command | Description |
|---------|-------------|
| `uninstall` | Complete removal (config + data) |
| `uninstall-keep-config` | Stop services, keep config |

---

## �🔧 Debug Commands

| Command | Description |
|---------|-------------|
| `nft-debug-on` | Enable NFTables debug |
| `nft-debug-off` | Disable NFTables debug |
| `nft-debug-status` | Show debug status |
| `nft-debug-logs` | Show debug logs |

---

## 🔍 Testing Commands

| Command | Description |
|---------|-------------|
| `test` | Basic DNS test |
| `test-all` | Comprehensive tests |
| `safe-test` | Safe test mode |
| `benchmark` | DNS performance benchmark |

---

## 📝 Editing Commands

| Command | Description |
|---------|-------------|
| `edit` | Edit CoreDNS config |
| `edit-dnscrypt` | Edit DNSCrypt config |

---

## 🔔 Notification Commands

| Command | Description |
|---------|-------------|
| `notify-enable` | Enable notifications |
| `notify-disable` | Disable notifications |
| `notify-status` | Show status |
| `notify-test` | Test notifications |

---

## ℹ️ Help Commands

| Command | Description |
|---------|-------------|
| `help` | Show help |
| `--help` | Show help |
| `-h` | Show help |

---

## 📚 Examples

### Basic Workflow
```bash
# 1. Install
sudo ./citadel.sh install-wizard

# 2. Configure
sudo ./citadel.sh configure-system
sudo ./citadel.sh firewall-strict

# 3. Verify
sudo ./citadel.sh verify

# 4. Monitor
sudo ./citadel.sh status
```

### Adblock Management
```bash
# Check status
sudo ./citadel.sh adblock-status

# Block custom domain
sudo ./citadel.sh adblock-add ads.example.com

# Switch to aggressive profile
sudo ./citadel.sh blocklist-switch aggressive
```

### Emergency Recovery
```bash
# If DNS stops working
sudo ./citadel.sh panic-bypass 300

# Restore after fixing
sudo ./citadel.sh panic-restore
```

---

**For detailed usage, see the [Configuration Guide](configuration.md).**
