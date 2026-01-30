#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL++ v3.1 - FORTIFIED DNS INFRASTRUCTURE                           ║
# ║  Advanced Hardened Resolver with Full Privacy Stack                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ==============================================================================
# BOOTSTRAP - Load Core Libraries
# ==============================================================================
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
export CYTADELA_LIB="${SCRIPT_DIR}/lib"
export CYTADELA_MODULES="${SCRIPT_DIR}/modules"

# Load core library
source "${CYTADELA_LIB}/cytadela-core.sh"
source "${CYTADELA_LIB}/network-utils.sh"
source "${CYTADELA_LIB}/module-loader.sh"
source "${CYTADELA_LIB}/i18n-pl.sh"

# ==============================================================================
# ROOT CHECK
# ==============================================================================
if [[ $EUID -ne 0 ]]; then
    log_error "Ten skrypt wymaga uprawnień root. Uruchom: sudo $0"
    exit 1
fi

# Developer mode banner
if [[ "$CYTADELA_MODE" == "developer" ]]; then
    echo -e "${YELLOW}[!] Cytadela running in DEVELOPER MODE - integrity checks relaxed${NC}"
fi

# ==============================================================================
# COMMAND ROUTING WITH AUTO-DISCOVERY
# ==============================================================================
ACTION="${1:-help}"
shift || true

case "$ACTION" in
    # Help
    help|--help|-h)
        show_help_pl
        ;;
    
    # Integrity
    integrity-init|integrity-check|integrity-status)
        load_module "integrity"
        ${ACTION//-/_}
        ;;
    
    # Discovery
    discover)
        load_module "discover"
        discover
        ;;
    
    # IPv6
    ipv6-privacy-on|ipv6-privacy-off|ipv6-privacy-status|ipv6-privacy-auto|ipv6-deep-reset|smart-ipv6)
        load_module "ipv6"
        ${ACTION//-/_}
        ;;
    
    # LKG
    lkg-save|lkg-restore|lkg-status|lists-update)
        load_module "lkg"
        ${ACTION//-/_}
        ;;
    
    # Auto-update
    auto-update-enable|auto-update-disable|auto-update-status|auto-update-now|auto-update-configure)
        load_module "auto-update"
        ${ACTION//-/_}
        ;;
    
    # Emergency
    panic-bypass|panic-restore|panic-status|emergency-refuse|emergency-restore|killswitch-on|killswitch-off)
        load_module "emergency"
        ${ACTION//-/_} "$@"
        ;;
    
    # Adblock
    adblock-status|adblock-stats|adblock-show|adblock-query|adblock-add|adblock-remove|adblock-edit|adblock-rebuild)
        load_module "adblock"
        ${ACTION//-/_} "$@"
        ;;
    
    # Blocklist Manager
    blocklist-list|blocklist-switch|blocklist-status|blocklist-add-url|blocklist-remove-url|blocklist-show-urls)
        load_module "blocklist-manager"
        ${ACTION//-/_} "$@"
        ;;
    
    # Allowlist
    allowlist-list|allowlist-add|allowlist-remove)
        load_module "adblock"
        ${ACTION//-/_} "$@"
        ;;
    
    # Ghost Check
    ghost-check)
        load_module "ghost-check"
        ghost_check
        ;;
    
    # Health
    health-status|health-install|health-uninstall)
        load_module "health"
        ${ACTION//-/_}
        ;;
    
    # Supply Chain
    supply-chain-status|supply-chain-init|supply-chain-verify)
        load_module "supply-chain"
        ${ACTION//-/_}
        ;;
    
    # Location
    location-status|location-check|location-add-trusted|location-remove-trusted|location-list-trusted)
        load_module "location"
        ${ACTION//-/_} "$@"
        ;;
    
    # NFT Debug
    nft-debug-on|nft-debug-off|nft-debug-status|nft-debug-logs)
        load_module "nft-debug"
        ${ACTION//-/_}
        ;;
    
    # Installation
    install-wizard)
        load_module "install-wizard"
        install_wizard
        ;;
    
    install-dnscrypt)
        load_module "install-dnscrypt"
        install_dnscrypt
        ;;
    
    install-coredns)
        load_module "install-coredns"
        install_coredns
        ;;
    
    install-nftables|firewall-safe|firewall-strict|configure-system|restore-system)
        load_module "install-nftables"
        ${ACTION//-/_}
        ;;
    
    install-all)
        load_module "install-all"
        install_all
        ;;
    
    # Config Backup/Restore
    config-backup|config-restore|config-list|config-delete)
        load_module "config-backup"
        ${ACTION//-/_} "$@"
        ;;
    
    # Cache Stats
    cache-stats|cache-stats-top|cache-stats-reset|cache-stats-watch)
        load_module "cache-stats"
        ${ACTION//-/_} "$@"
        ;;
    
    # Notifications
    notify-enable|notify-disable|notify-status|notify-test)
        load_module "notify"
        ${ACTION//-/_}
        ;;
    
    # Diagnostics
    diagnostics|verify|test-all|status)
        load_module "diagnostics"
        case "$ACTION" in
            diagnostics) run_diagnostics ;;
            verify) verify_stack ;;
            test-all) test_all ;;
            status) show_status ;;
        esac
        ;;
    
    # Unknown command
    *)
        log_error "Nieznana komenda: $ACTION"
        echo ""
        echo "Użyj: $0 help"
        exit 1
        ;;
esac
