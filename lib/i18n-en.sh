#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ i18n - ENGLISH MESSAGES v3.1                                  ║
# ║  English messages and help                                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

show_help_en() {
    cat <<EOF

${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Command Reference                       ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Installation Commands (SAFE):${NC}
  install-dnscrypt      Install DNSCrypt-Proxy only
  install-coredns       Install CoreDNS only
  install-nftables      Install NFTables rules only
  install-all           Install all DNS modules (does NOT disable systemd-resolved)

${CYAN}DNSSEC (optional):${NC}
  CITADEL_DNSSEC=1       Generate DNSCrypt with require_dnssec = true
  --dnssec               Alternatively: pass flag to install-dnscrypt/install-all

${YELLOW}NEW FEATURES v3.1:${NC}
  smart-ipv6           Smart IPv6 detection & auto-reconfiguration
  ipv6-privacy-on      Enable IPv6 Privacy Extensions (prefer temporary)
  ipv6-privacy-off     Disable IPv6 Privacy Extensions
  ipv6-privacy-status  Show IPv6 Privacy Extensions status
  ipv6-privacy-auto    Auto-ensure IPv6 privacy (detect + fix if needed)
  discover             Network & firewall sanity snapshot
  install-dashboard    Install terminal dashboard (citadel-top)
  install-editor       Install editor integration (citadel edit)
  optimize-kernel      Apply real-time priority for DNS processes
  install-doh-parallel Install DNS-over-HTTPS parallel racing
  fix-ports            Resolve port conflicts with avahi/chromium

${YELLOW}System Configuration (WARNING - disables systemd-resolved):${NC}
  configure-system      Switch system DNS to Citadel++ (with confirmation)
  restore-system        Restore systemd-resolved + DNS (rollback)

${CYAN}Emergency Commands:${NC}
  emergency-refuse      Refuse all DNS queries (emergency mode)
  emergency-restore     Restore normal operation
  killswitch-on         Activate DNS kill-switch (block all non-localhost)
  killswitch-off        Deactivate kill-switch

${RED}Panic Bypass (SPOF recovery):${NC}
  panic-bypass [secs]   Disable protection + auto-rollback (default 300s)
  panic-restore         Manually restore protected mode
  panic-status          Show panic mode status

${YELLOW}LKG (Last Known Good):${NC}
  lkg-save              Save current blocklist to cache
  lkg-restore           Restore blocklist from cache
  lkg-status            Show LKG cache status
  lists-update          Update blocklist with LKG fallback

${CYAN}Diagnostic Commands:${NC}
  diagnostics           Run full system diagnostics
  status                Show service status
  verify                Verify full stack (ports/services/DNS/NFT/metrics)
  ghost-check           Port exposure audit (warn about 0.0.0.0/::)
  ipv6-deep-reset       Flush IPv6 + neighbor cache + reconnect
  test-all              Smoke test (verify + leak test + IPv6)

${GREEN}Health Watchdog:${NC}
  health-status         Show health status (services, DNS probe, firewall)
  health-install        Install auto-restart + health check timer
  health-uninstall      Remove health watchdog

${GREEN}Supply-Chain Verification:${NC}
  supply-chain-status   Show checksums file status
  supply-chain-init     Initialize checksums for known assets
  supply-chain-verify   Verify local files against manifest

${CYAN}Location-Aware Advisory:${NC}
  location-status       Show current SSID, trust status, firewall mode
  location-check        Check and advise on firewall mode
  location-add-trusted  Add SSID to trusted list (or current if no arg)
  location-remove-trusted Remove SSID from trusted list
  location-list-trusted List all trusted SSIDs

${CYAN}NFT Debug Chain:${NC}
  nft-debug-on          Enable debug chain with rate-limited logging
  nft-debug-off         Disable debug chain
  nft-debug-status      Show debug chain status and counters
  nft-debug-logs        Show recent CITADEL log entries

${YELLOW}Integrity (Local-First):${NC}
  integrity-init        Create integrity manifest for scripts/binaries
  integrity-check       Verify integrity against manifest
  integrity-status      Show integrity mode and manifest info
  --dev                 Run in developer mode (relaxed integrity checks)

${CYAN}Firewall Modes:${NC}
  firewall-safe         Set SAFE rules (won't break connectivity)
  firewall-strict       Set STRICT rules (blocks DNS leaks)

${GREEN}Recommended workflow:${NC}
  ${CYAN}1.${NC} sudo ./citadela_en.sh install-all
  ${CYAN}2.${NC} sudo ./citadela_en.sh firewall-safe         ${YELLOW}# SAFE: won't break connectivity${NC}
  ${CYAN}3.${NC} dig +short google.com @127.0.0.1          ${YELLOW}# Test local DNS${NC}
  ${CYAN}4.${NC} sudo ./citadela_en.sh configure-system       ${YELLOW}# Switch system DNS${NC}
  ${CYAN}5.${NC} ping -c 3 google.com                      ${YELLOW}# Test connectivity${NC}
  ${CYAN}6.${NC} sudo ./citadela_en.sh firewall-strict        ${YELLOW}# STRICT: full DNS leak protection${NC}

${GREEN}New tools v3.1:${NC}
  citadela-top          Real-time terminal dashboard
  citadela edit         Editor with auto-restart
  citadela status       Quick status check

${CYAN}Adblock Panel (DNS):${NC}
  adblock-status        Show adblock/CoreDNS integration status
  adblock-stats         Show counts of custom/blocklist/combined
  adblock-show          Show: custom|blocklist|combined (first 200 lines)
  adblock-edit          Edit /etc/coredns/zones/custom.hosts and reload
  adblock-add           Add domain to custom.hosts (0.0.0.0 domain)
  adblock-remove        Remove domain from custom.hosts
  adblock-rebuild       Rebuild combined.hosts from custom+blocklist and reload
  adblock-query         Query a domain via local DNS (127.0.0.1)
  allowlist-list        Show allowlist (domains excluded from blocking)
  allowlist-add         Add domain to allowlist
  allowlist-remove      Remove domain from allowlist

${CYAN}Advanced Configuration:${NC}
  DNSCrypt config:      /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  DNSCrypt DoH config:  /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml
  CoreDNS config:       /etc/coredns/Corefile
  NFTables rules:       /etc/nftables.d/citadel-dns.nft

${CYAN}Documentation:${NC}
  GitHub:              https://github.com/QguAr71/Cytadela

EOF
}
