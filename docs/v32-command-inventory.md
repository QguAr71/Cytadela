# Current Command Inventory - v3.1 Baseline

Generated: śro, 4 lut 2026, 17:02:51 CET


## Command Inventory - v3.1 Baseline

This document lists all available commands in Cytadela v3.1 that must be preserved
during v3.2 unified module refactoring for backward compatibility.

Generated: $(date)
Source: citadel.sh dispatcher

### 1. Help Commands
- help | --help | -h
  - Module: help
  - Function: citadel_help
  - Description: Show help information

### 2. Integrity Commands  
- integrity-init | integrity-check | integrity-status
  - Module: integrity
  - Function: call_fn "$ACTION"
  - Description: File integrity verification system

### 3. Discovery Commands
- discover
  - Module: discover
  - Function: call_fn "$ACTION"
  - Description: Network/service discovery

### 4. IPv6 Commands
- ipv6-privacy-on | ipv6-privacy-off | ipv6-privacy-status | ipv6-privacy-auto | ipv6-deep-reset | smart-ipv6
  - Module: ipv6
  - Function: call_fn "$ACTION"
  - Description: IPv6 privacy and management features

### 5. LKG Commands
- lkg-save | lkg-restore | lkg-status | lists-update
  - Module: lkg
  - Function: call_fn "$ACTION"
  - Description: Last Known Good configuration management

### 6. Auto-update Commands
- auto-update-enable | auto-update-disable | auto-update-status | auto-update-now | auto-update-configure
  - Module: auto-update
  - Function: call_fn "$ACTION"
  - Description: Automatic update management

### 7. Emergency Commands
- panic-bypass | panic-restore | panic-status | emergency-refuse | emergency-restore | killswitch-on | killswitch-off
  - Module: emergency
  - Function: call_fn "$ACTION" "$@" || true
  - Description: Emergency recovery and security bypass

### 8. Adblock Commands
- adblock-status | adblock-stats | adblock-show | adblock-query | adblock-add | adblock-remove | adblock-edit | adblock-rebuild
  - Module: adblock
  - Function: call_fn "$ACTION" "$@"
  - Description: Ad blocking management

### 9. Adblock Legacy Aliases
- blocklist (alias for adblock_show blocklist)
- combined (alias for adblock_show combined)
- custom (alias for adblock_show custom)
  - Module: adblock
  - Function: adblock_show [type]
  - Description: Legacy adblock display aliases

### 10. Blocklist Manager Commands
- blocklist-list | blocklist-switch | blocklist-status | blocklist-add-url | blocklist-remove-url | blocklist-show-urls
  - Module: blocklist-manager
  - Function: call_fn "$ACTION" "$@"
  - Description: Blocklist source management

### 11. Allowlist Commands
- allowlist-list | allowlist-add | allowlist-remove
  - Module: adblock
  - Function: call_fn "$ACTION" "$@"
  - Description: Exception list management

### 12. Ghost Check Commands
- ghost-check
  - Module: ghost-check
  - Function: call_fn "$ACTION"
  - Description: Security audit for open ports

### 13. Health Commands
- health-status | health-install | health-uninstall
  - Module: health
  - Function: call_fn "$ACTION"
  - Description: Service health monitoring

### 14. Uninstall Commands
- uninstall | uninstall-keep-config
  - Module: uninstall
  - Function: call_fn "citadel_$ACTION"
  - Description: System uninstallation

### 15. Supply Chain Commands
- supply-chain-status | supply-chain-init | supply-chain-verify
  - Module: supply-chain
  - Function: call_fn "$ACTION"
  - Description: Binary verification system

### 16. Location Commands
- location-status | location-check | location-add-trusted | location-remove-trusted | location-list-trusted
  - Module: location
  - Function: call_fn "$ACTION" "$@"
  - Description: Location-based security policies

### 17. NFT Debug Commands
- nft-debug-on | nft-debug-off | nft-debug-status | nft-debug-logs
  - Module: nft-debug
  - Function: call_fn "$ACTION"
  - Description: Firewall debugging tools

### 18. Dependency Checker Commands
- check-deps | check-dependencies [--install]
  - Module: check-dependencies
  - Function: check_dependencies / check_dependencies_install
  - Description: System dependency verification

### 19. Installation Commands
- install-wizard
  - Module: install-wizard
  - Function: install_wizard
  - Description: Interactive installation wizard

- install-dnscrypt
  - Module: install-dnscrypt
  - Function: install_dnscrypt
  - Description: DNSCrypt-Proxy installation

- install-coredns
  - Module: install-coredns
  - Function: install_coredns
  - Description: CoreDNS installation

- install-nftables | firewall-safe | firewall-strict | configure-system | restore-system | restore-system-default
  - Module: install-nftables
  - Function: call_fn "$ACTION"
  - Description: Firewall and system configuration

- install-all
  - Module: install-all
  - Function: install_all
  - Description: Complete system installation

### 20. Config Backup Commands
- config-backup | config-restore | config-list | config-delete
  - Module: config-backup
  - Function: call_fn "$ACTION" "$@"
  - Description: Configuration backup management

### 21. Cache Stats Commands
- cache-stats | cache-stats-top | cache-stats-reset | cache-stats-watch
  - Module: cache-stats
  - Function: call_fn "$ACTION" "$@"
  - Description: DNS cache statistics

### 22. Notification Commands
- notify-enable | notify-disable | notify-status | notify-test
  - Module: notify
  - Function: call_fn "$ACTION"
  - Description: Notification system management

### 23. Advanced Install Commands
- optimize-kernel
  - Module: advanced-install
  - Function: optimize_kernel_priority
  - Description: Kernel optimization

- install-doh-parallel
  - Module: advanced-install
  - Function: install_doh_parallel
  - Description: DoH parallel resolver setup

- install-editor
  - Module: advanced-install
  - Function: install_editor_integration
  - Description: Editor integration setup

### 24. Dashboard Commands
- install-dashboard
  - Module: install-dashboard
  - Function: install_citadel_top
  - Description: Dashboard installation

### 25. Edit Tools Commands
- edit
  - Module: edit-tools
  - Function: edit_config
  - Description: Configuration file editing

- edit-dnscrypt
  - Module: edit-tools
  - Function: edit_dnscrypt
  - Description: DNSCrypt config editing

- logs
  - Module: edit-tools
  - Function: show_logs
  - Description: Log file viewer

### 26. Test Tools Commands
- safe-test
  - Module: test-tools
  - Function: safe_test_mode
  - Description: Safe testing mode

- test
  - Module: test-tools
  - Function: test_dns
  - Description: DNS testing

### 27. Fix Ports Commands
- fix-ports
  - Module: fix-ports
  - Function: fix_port_conflicts
  - Description: Port conflict resolution

### 28. Diagnostics Commands
- diagnostics | verify | test-all | status
  - Module: diagnostics
  - Function: run_diagnostics / verify_stack / test_all / show_status
  - Description: System diagnostics and verification

### 29. Verify Config Commands
- verify-config [check|dns|services|files|all|help]
  - Module: verify-config
  - Function: verify_config_*
  - Description: Configuration verification

---

## Summary Statistics

- **Total Command Groups:** 29
- **Total Individual Commands:** ~85+ 
- **Modules Referenced:** 25
- **Functions to Preserve:** 100% backward compatibility required

## Verification Checklist

During v3.2 implementation, ensure:
- [ ] All commands above work identically
- [ ] All function signatures preserved
- [ ] All error messages maintained
- [ ] All help text preserved
- [ ] All aliases functional
- [ ] Performance not degraded

