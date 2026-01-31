#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL++ v3.1 - FORTIFIED DNS INFRASTRUCTURE                           ║
# ║  Advanced Hardened Resolver with Full Privacy Stack                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ==============================================================================
# BOOTSTRAP - Load Core Libraries
# ==============================================================================

# Determine script directory (with fallback for systems without realpath)
if command -v realpath &>/dev/null; then
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
else
    # Fallback: use readlink or BASH_SOURCE
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

export CYTADELA_LIB="${SCRIPT_DIR}/lib"
export CYTADELA_MODULES="${SCRIPT_DIR}/modules"

# Safe source function - checks file existence before sourcing
source_lib() {
    local lib_file="$1"
    if [[ ! -f "$lib_file" ]]; then
        echo "ERROR: Required library not found: $lib_file" >&2
        exit 1
    fi
    # shellcheck source=/dev/null
    source "$lib_file"
}

# Load core libraries
source_lib "${CYTADELA_LIB}/cytadela-core.sh"
source_lib "${CYTADELA_LIB}/network-utils.sh"
source_lib "${CYTADELA_LIB}/module-loader.sh"
source_lib "${CYTADELA_LIB}/i18n-pl.sh"

# ==============================================================================
# ROOT CHECK
# ==============================================================================
if [[ $EUID -ne 0 ]]; then
    log_error "Ten skrypt wymaga uprawnień root. Uruchom: sudo $0"
    exit 1
fi

# Developer mode banner (defensive expansion)
if [[ "${CYTADELA_MODE:-}" == "developer" ]]; then
    echo -e "${YELLOW:-}[!] Cytadela running in DEVELOPER MODE - integrity checks relaxed${NC:-}"
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
        fn="${ACTION//-/_}"
        if declare -f "$fn" &>/dev/null; then
            "$fn"
        else
            log_error "Function $fn not found"
            exit 1
        fi
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
    
    # Adblock aliases (legacy compatibility)
    blocklist)
        load_module "adblock"
        adblock_show blocklist
        ;;
    
    combined)
        load_module "adblock"
        adblock_show combined
        ;;
    
    custom)
        load_module "adblock"
        adblock_show custom
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
    
    # Dependency checker
    check-deps)
        load_module "check-dependencies"
        # Fix: after shift, --install is in $1, not $2
        if [[ "${1:-}" == "--install" ]]; then
            check_dependencies_install
        else
            check_dependencies
        fi
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
    
    # Advanced Install
    optimize-kernel)
        load_module "advanced-install"
        optimize_kernel_priority
        ;;
    
    install-doh-parallel)
        load_module "advanced-install"
        install_doh_parallel
        ;;
    
    install-editor)
        load_module "advanced-install"
        install_editor_integration
        ;;
    
    # Install Dashboard
    install-dashboard)
        load_module "install-dashboard"
        install_citadel_top
        ;;
    
    # Edit Tools
    edit)
        load_module "edit-tools"
        edit_config
        ;;
    
    edit-dnscrypt)
        load_module "edit-tools"
        edit_dnscrypt
        ;;
    
    logs)
        load_module "edit-tools"
        show_logs
        ;;
    
    # Test Tools
    safe-test)
        load_module "test-tools"
        safe_test_mode
        ;;
    
    test)
        load_module "test-tools"
        test_dns
        ;;
    
    # Fix Ports
    fix-ports)
        load_module "fix-ports"
        fix_port_conflicts
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
