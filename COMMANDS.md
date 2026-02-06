# Cytadela++ Complete Command Reference

Generated: 2026-02-06

## Command Categories

### 1. Installation Commands

| Command | Function | Module |
|---------|----------|--------|
| `install` | Install dispatcher with subcommands | unified-install |
| `install wizard` | Interactive installation wizard | install-wizard |
| `install dnscrypt` | Install DNSCrypt-Proxy | unified-install |
| `install coredns` | Install CoreDNS | unified-install |
| `install nftables` | Configure nftables firewall | unified-install |
| `install firewall-safe` | Safe firewall mode | unified-install |
| `install firewall-strict` | Strict firewall mode | unified-install |
| `install all` | Install all components | unified-install |
| `install dashboard` | Install terminal dashboard | unified-install |
| `install check-deps` | Check dependencies | check-dependencies |
| `install configure-system` | Configure system DNS | unified-install |
| `install-dnscrypt` | Legacy: Install DNSCrypt | unified-install |
| `install-coredns` | Legacy: Install CoreDNS | unified-install |
| `install-nftables` | Legacy: Install firewall | unified-install |
| `install-all` | Legacy: Install everything | unified-install |
| `install-dashboard` | Legacy: Install dashboard | unified-install |
| `install-editor` | Install editor integration | advanced-install |
| `install-doh-parallel` | Install DoH parallel | advanced-install |
| `optimize-kernel` | Optimize kernel priority | advanced-install |

### 2. Uninstall Commands

| Command | Function | Module |
|---------|----------|--------|
| `uninstall` | Full uninstallation | uninstall |
| `uninstall-keep-config` | Uninstall keeping config | uninstall |

### 3. Adblock Commands

| Command | Function | Module |
|---------|----------|--------|
| `adblock-status` | Show adblock status | unified-adblock |
| `adblock-stats` | Show statistics | unified-adblock |
| `adblock-show` | Show lists (custom/blocklist/combined) | unified-adblock |
| `adblock-query` | Query domain | unified-adblock |
| `adblock-add` | Add domain to blocklist | unified-adblock |
| `adblock-remove` | Remove domain from blocklist | unified-adblock |
| `adblock-edit` | Edit custom blocklist | unified-adblock |
| `adblock-rebuild` | Rebuild combined list | unified-adblock |
| `blocklist` | Alias: show blocklist | unified-adblock |
| `combined` | Alias: show combined | unified-adblock |
| `custom` | Alias: show custom | unified-adblock |

### 4. Blocklist Manager Commands

| Command | Function | Module |
|---------|----------|--------|
| `blocklist-list` | List available profiles | unified-adblock |
| `blocklist-switch` | Switch profile | unified-adblock |
| `blocklist-status` | Show current status | unified-adblock |
| `blocklist-add-url` | Add custom URL | unified-adblock |
| `blocklist-remove-url` | Remove custom URL | unified-adblock |
| `blocklist-show-urls` | Show custom URLs | unified-adblock |

### 5. Allowlist Commands

| Command | Function | Module |
|---------|----------|--------|
| `allowlist-list` | List allowed domains | unified-adblock |
| `allowlist-add` | Add domain to allowlist | unified-adblock |
| `allowlist-remove` | Remove domain from allowlist | unified-adblock |

### 6. Backup & Restore Commands

| Command | Function | Module |
|---------|----------|--------|
| `backup` | Backup dispatcher | unified-backup |
| `backup config-backup` | Create config backup | unified-backup |
| `backup config-restore` | Restore from backup | unified-backup |
| `backup config-list` | List available backups | unified-backup |
| `backup config-delete` | Delete backup | unified-backup |
| `backup lists-update` | Update blocklists | unified-backup |
| `backup lkg-save` | Save Last Known Good | unified-backup |
| `backup lkg-restore` | Restore from LKG | unified-backup |
| `backup lkg-status` | Show LKG status | unified-backup |
| `backup auto-update-enable` | Enable auto-update | unified-backup |
| `backup auto-update-disable` | Disable auto-update | unified-backup |
| `backup auto-update-status` | Show auto-update status | unified-backup |
| `backup auto-update-now` | Run update now | unified-backup |
| `backup auto-update-configure` | Configure schedule | unified-backup |
| `config-backup` | Legacy: Create backup | unified-backup |
| `config-restore` | Legacy: Restore backup | unified-backup |
| `config-list` | Legacy: List backups | unified-backup |
| `config-delete` | Legacy: Delete backup | unified-backup |

### 7. Cache Statistics Commands

| Command | Function | Module |
|---------|----------|--------|
| `cache-stats` | Show cache statistics | unified-monitor |
| `cache-stats-top` | Show top domains | unified-monitor |
| `cache-stats-reset` | Reset statistics | unified-monitor |
| `cache-stats-watch` | Watch live stats | unified-monitor |

### 8. Diagnostics & Monitoring Commands

| Command | Function | Module |
|---------|----------|--------|
| `diagnostics` | Run comprehensive diagnostics | unified-monitor |
| `run-diagnostics` | Alias for diagnostics | unified-monitor |
| `status` | Show system status | unified-monitor |
| `test-all` | Run all tests | unified-monitor |
| `verify-config` | Verify configuration | unified-monitor |
| `verify-stack` | Alias: verify stack | unified-monitor |
| `verify-config-check` | Verify config files | unified-monitor |
| `verify-config-dns` | Verify DNS | unified-monitor |
| `discover` | Discover network stack | discover |
| `monitor` | Monitor dispatcher with subcommands | unified-monitor |
| `monitor status` | Show status | unified-monitor |
| `monitor diagnostics` | Run diagnostics | unified-monitor |
| `monitor verify` | Verify config | unified-monitor |
| `monitor test-all` | Run tests | unified-monitor |
| `monitor cache-stats` | Cache statistics | unified-monitor |
| `monitor benchmark-dns` | DNS benchmark | unified-monitor |

### 9. Benchmark Commands

| Command | Function | Module |
|---------|----------|--------|
| `benchmark-dns` | Benchmark DNS performance | unified-monitor |
| `benchmark-all` | Run all benchmarks | unified-monitor |
| `benchmark-report` | Generate report | unified-monitor |
| `benchmark-compare` | Compare results | unified-monitor |

### 10. Prometheus Commands

| Command | Function | Module |
|---------|----------|--------|
| `prometheus-export` | Export metrics | unified-monitor |
| `prometheus-collect` | Collect metrics | unified-monitor |
| `prometheus-serve` | Serve metrics | unified-monitor |
| `prometheus-status` | Show status | unified-monitor |

### 11. Security Commands

| Command | Function | Module |
|---------|----------|--------|
| `ghost-check` | Audit firewall/open ports | unified-security |
| `integrity-init` | Initialize integrity manifest | unified-security |
| `integrity-check` | Check file integrity | unified-security |
| `integrity-status` | Show integrity status | unified-security |
| `supply-chain-init` | Init supply chain | unified-security |
| `supply-chain-verify` | Verify supply chain | unified-security |
| `supply-chain-status` | Show supply chain status | unified-security |
| `nft-debug-on` | Enable NFT debug | unified-security |
| `nft-debug-off` | Disable NFT debug | unified-security |
| `nft-debug-status` | Show debug status | unified-security |
| `nft-debug-logs` | Show debug logs | unified-security |

### 12. Location Commands

| Command | Function | Module |
|---------|----------|--------|
| `location-status` | Show location status | unified-security |
| `location-check` | Check current location | unified-security |
| `location-add-trusted` | Add trusted SSID | unified-security |
| `location-remove-trusted` | Remove trusted SSID | unified-security |
| `location-list-trusted` | List trusted SSIDs | unified-security |

### 13. ASN Blocking Commands

| Command | Function | Module |
|---------|----------|--------|
| `asn-block` | Block ASN | unified-security |
| `asn-unblock` | Unblock ASN | unified-security |
| `asn-list` | List blocked ASNs | unified-security |
| `asn-add` | Add ASN with description | unified-security |
| `asn-remove` | Remove ASN | unified-security |
| `asn-info` | Show ASN info | unified-security |
| `asn-stats` | Show ASN statistics | unified-security |
| `asn-update-cache` | Update ASN cache | unified-security |

### 14. Reputation Commands

| Command | Function | Module |
|---------|----------|--------|
| `reputation-list` | List reputation scores | unified-security |
| `reputation-reset` | Reset reputation | unified-security |
| `reputation-stats` | Show statistics | unified-security |
| `reputation-config` | Configure scoring | unified-security |
| `reputation-manual` | Manual score setting | unified-security |

### 15. Event Logging Commands

| Command | Function | Module |
|---------|----------|--------|
| `events-query` | Query events | unified-security |
| `events-stats` | Show event stats | unified-security |
| `events-recent` | Show recent events | unified-security |
| `events-export` | Export events | unified-security |
| `events-analyze` | Analyze events | unified-security |

### 16. Honeypot Commands

| Command | Function | Module |
|---------|----------|--------|
| `honeypot-deploy` | Deploy honeypot | unified-security |
| `honeypot-undeploy` | Remove honeypot | unified-security |
| `honeypot-status` | Show honeypot status | unified-security |
| `honeypot-list` | List honeypots | unified-security |
| `honeypot-cleanup` | Cleanup old honeypots | unified-security |

### 17. Emergency/Recovery Commands

| Command | Function | Module |
|---------|----------|--------|
| `panic-bypass` | Emergency DNS bypass | unified-recovery |
| `panic-restore` | Restore from panic mode | unified-recovery |
| `panic-status` | Check panic mode status | unified-recovery |
| `emergency-network-restore` | Full network restore | unified-recovery |
| `emergency-network-fix` | Quick DNS fix | unified-recovery |
| `restore-system` | Restore system from backup | unified-recovery |
| `restore-system-default` | Restore to defaults | unified-recovery |

### 18. IPv6 Commands

| Command | Function | Module |
|---------|----------|--------|
| `ipv6-privacy-on` | Enable IPv6 privacy | unified-network |
| `ipv6-privacy-off` | Disable IPv6 privacy | unified-network |
| `ipv6-privacy-status` | Show IPv6 status | unified-network |
| `ipv6-privacy-auto` | Auto-ensure privacy | unified-network |

### 19. Network Tools Commands

| Command | Function | Module |
|---------|----------|--------|
| `edit` | Edit CoreDNS config | unified-network |
| `edit-dnscrypt` | Edit DNSCrypt config | unified-network |
| `logs` | Show service logs | unified-network |
| `fix-ports` | Fix port conflicts | unified-network |

### 20. Notification Commands

| Command | Function | Module |
|---------|----------|--------|
| `notify-enable` | Enable desktop notifications | unified-network |
| `notify-disable` | Disable notifications | unified-network |
| `notify-status` | Show notification status | unified-network |
| `notify-test` | Send test notification | unified-network |

### 21. Health Commands

| Command | Function | Module |
|---------|----------|--------|
| `health-status` | Show health status | health |
| `health-install` | Install health monitoring | health |
| `health-uninstall` | Remove health monitoring | health |

### 22. Dependency Commands

| Command | Function | Module |
|---------|----------|--------|
| `check-deps` | Check dependencies | check-dependencies |
| `check-dependencies` | Alias for check-deps | check-dependencies |

### 23. Test Commands

| Command | Function | Module |
|---------|----------|--------|
| `test` | Test DNS resolution | test-tools |
| `safe-test` | Safe test mode | test-tools |

### 24. Advanced Management Commands

| Command | Function | Module |
|---------|----------|--------|
| `service-create` | Create service | advanced-management |
| `service-remove` | Remove service | advanced-management |
| `service-start` | Start service | advanced-management |
| `service-stop` | Stop service | advanced-management |
| `service-restart` | Restart service | advanced-management |
| `service-enable` | Enable service | advanced-management |
| `service-disable` | Disable service | advanced-management |
| `service-status` | Show service status | advanced-management |
| `service-list` | List services | advanced-management |
| `service-setup-all` | Setup all services | advanced-management |
| `service-remove-all` | Remove all services | advanced-management |
| `monitoring-health-check` | Health check | advanced-management |
| `monitoring-system-info` | System info | advanced-management |

### 25. Enterprise Commands

| Command | Function | Module |
|---------|----------|--------|
| `enterprise-init` | Init enterprise features | enterprise-features |
| `enterprise-status` | Show enterprise status | enterprise-features |
| `enterprise-metrics` | Show metrics | enterprise-features |
| `enterprise-security-init` | Init security | enterprise-features |
| `prometheus-setup` | Setup Prometheus | enterprise-features |
| `grafana-setup` | Setup Grafana | enterprise-features |
| `docker-setup` | Setup Docker | enterprise-features |
| `scalability-init` | Init scalability | enterprise-features |

### 26. Configuration Management Commands

| Command | Function | Module |
|---------|----------|--------|
| `config-init` | Initialize config | config-management |
| `config-get` | Get config value | config-management |
| `config-set` | Set config value | config-management |
| `config-validate` | Validate config | config-management |
| `config-show` | Show config | config-management |
| `config-export` | Export config | config-management |
| `config-import` | Import config | config-management |
| `config-diff` | Compare configs | config-management |
| `config-reset` | Reset config | config-management |
| `config-list-profiles` | List profiles | config-management |
| `config-switch-profile` | Switch profile | config-management |
| `config-apply` | Apply config | config-management |

### 27. Module Management Commands

| Command | Function | Module |
|---------|----------|--------|
| `module-list` | List modules | module-management |
| `module-load` | Load module | module-management |
| `module-unload` | Unload module | module-management |
| `module-reload` | Reload module | module-management |
| `module-info` | Show module info | module-management |
| `module-load-all` | Load all modules | module-management |
| `module-unload-all` | Unload all modules | module-management |
| `module-discover` | Discover modules | module-management |

### 28. Help Commands

| Command | Function | Module |
|---------|----------|--------|
| `help` | Show help | help |
| `help --tui` | TUI help | help |
| `help --cli` | CLI help | help |
| `help --context` | Contextual help | help |

## Internal Functions (Not Direct Commands)

### Private Helper Functions
- `_test_connectivity` - Test network connectivity
- `_test_dns_resolution` - Test DNS
- `_test_ping_connectivity` - Test ICMP
- `_test_ipv6_connectivity` - Test IPv6
- `_offer_emergency_restore` - Prompt for restore
- `_restore_dns_with_fallback` - DNS restoration
- `_restore_dns_fallback` - Fallback DNS
- `_restore_systemd_resolved_state` - Restore systemd-resolved
- `_cleanup_networkmanager` - Cleanup NM config
- `_stop_citadel_services` - Stop services
- `_flush_all_firewall` - Flush firewall
- `_detect_vpn_interfaces` - Detect VPN
- `_restart_all_network_services` - Restart network
- `_flush_dns_caches` - Flush DNS cache
- `_verify_final_connectivity` - Verify connectivity
- `_benchmark_basic` - Basic benchmark
- `_benchmark_blocklist` - Blocklist benchmark
- `_benchmark_cache` - Cache benchmark
- `_check_benchmark_tools` - Check tools
- `_collect_blocklist_metrics` - Collect metrics
- `_collect_dns_metrics` - Collect DNS metrics
- `_collect_service_metrics` - Collect service metrics
- `_collect_system_metrics` - Collect system metrics

## Statistics

- **Total Commands**: ~140
- **Unified Modules**: 7 (adblock, backup, install, monitor, network, recovery, security)
- **Legacy Modules**: 35 (some still used)
- **Library Functions**: ~50 helper functions
- **Command Categories**: 28
