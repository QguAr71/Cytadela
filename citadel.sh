#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL++ v3.1 - FORTIFIED DNS INFRASTRUCTURE                           ║
# ║  Advanced Hardened Resolver with Full Privacy Stack                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail
set -o errtrace  # Enable ERR trap propagation in functions

# ==============================================================================
# EXIT CODES
# ==============================================================================
# 0 - Success
# 1 - No root privileges
# 2 - Missing library file
# 3 - Function not found after module load
# 4+ - Command-specific errors

# ==============================================================================
# BOOTSTRAP - Load Core Libraries
# ==============================================================================
# Determinacja katalogu skryptu: użyj realpath jeśli jest, inaczej fallback
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_DIR="$(dirname "$(realpath "$0")")"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

export CYTADELA_LIB="${SCRIPT_DIR}/lib"
export CYTADELA_MODULES="${SCRIPT_DIR}/modules"

# Early-fail: verify lib/modules directories exist
if [[ ! -d "${CYTADELA_LIB}" ]]; then
    printf 'ERROR: brak katalogu biblioteki: %s\n' "${CYTADELA_LIB}" >&2
    exit 2
fi
if [[ ! -d "${CYTADELA_MODULES}" ]]; then
    printf 'ERROR: brak katalogu modułów: %s\n' "${CYTADELA_MODULES}" >&2
    exit 2
fi

# Bezpieczne "source" z walidacją pliku i wskazówką dla ShellCheck
source_lib() {
    local libfile="$1"
    if [[ -f "$libfile" ]]; then
        # poinformuj shellcheck o ścieżce jeśli jest statyczna:
        # shellcheck source=/dev/null
        # shellcheck disable=SC1090
        source "$libfile"
    else
        printf 'ERROR: brak pliku biblioteki: %s\n' "$libfile" >&2
        exit 2
    fi
}

# Load core library (bezpiecznie)
# Jeśli chcesz, dodaj nad liniami source:  "# shellcheck source=lib/cytadela-core.sh"
source_lib "${CYTADELA_LIB}/cytadela-core.sh"
source_lib "${CYTADELA_LIB}/network-utils.sh"
source_lib "${CYTADELA_LIB}/module-loader.sh"
# domyślnie ładujemy polskie tłumaczenia; rozważ wybór na podstawie env/arg
source_lib "${CYTADELA_LIB}/i18n-pl.sh"

# Helper do bezpiecznego wywoływania funkcji dynamicznej (zamiana '-' -> '_')
call_fn() {
    local act="${1:-}"
    if [[ -z "$act" ]]; then
        log_error "Brak nazwy akcji w call_fn"
        return 2
    fi
    shift || true
    local fn="${act//-/_}"
    if declare -f "$fn" >/dev/null 2>&1; then
        "$fn" "$@"
    else
        log_error "Funkcja $fn nieznaleziona po załadowaniu modułu"
        exit 3
    fi
}

# ==============================================================================
# ROOT CHECK
# ==============================================================================
if [[ "${EUID:-}" -ne 0 ]]; then
    log_error "Ten skrypt wymaga uprawnień root. Uruchom: sudo $0"
    exit 1
fi

# Developer mode banner (defensywne ekspansje)
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
    help | --help | -h)
        show_help_pl
        ;;

    # Integrity
    integrity-init | integrity-check | integrity-status)
        load_module "integrity"
        call_fn "$ACTION"
        ;;

    # Discovery
    discover)
        load_module "discover"
        call_fn "$ACTION"
        ;;

    # IPv6
    ipv6-privacy-on | ipv6-privacy-off | ipv6-privacy-status | ipv6-privacy-auto | ipv6-deep-reset | smart-ipv6)
        load_module "ipv6"
        call_fn "$ACTION"
        ;;

    # LKG
    lkg-save | lkg-restore | lkg-status | lists-update)
        load_module "lkg"
        call_fn "$ACTION"
        ;;

    # Auto-update
    auto-update-enable | auto-update-disable | auto-update-status | auto-update-now | auto-update-configure)
        load_module "auto-update"
        call_fn "$ACTION"
        ;;

    # Emergency
    panic-bypass | panic-restore | panic-status | emergency-refuse | emergency-restore | killswitch-on | killswitch-off)
        load_module "emergency"
        call_fn "$ACTION" "$@"
        ;;

    # Adblock
    adblock-status | adblock-stats | adblock-show | adblock-query | adblock-add | adblock-remove | adblock-edit | adblock-rebuild)
        load_module "adblock"
        call_fn "$ACTION" "$@"
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
    blocklist-list | blocklist-switch | blocklist-status | blocklist-add-url | blocklist-remove-url | blocklist-show-urls)
        load_module "blocklist-manager"
        call_fn "$ACTION" "$@"
        ;;

    # Allowlist
    allowlist-list | allowlist-add | allowlist-remove)
        load_module "adblock"
        call_fn "$ACTION" "$@"
        ;;

    # Ghost Check
    ghost-check)
        load_module "ghost-check"
        call_fn "$ACTION"
        ;;

    # Health
    health-status | health-install | health-uninstall)
        load_module "health"
        call_fn "$ACTION"
        ;;

    # Uninstall
    uninstall | uninstall-keep-config)
        load_module "uninstall"
        call_fn "citadel_$ACTION"
        ;;

    # Supply Chain
    supply-chain-status | supply-chain-init | supply-chain-verify)
        load_module "supply-chain"
        call_fn "$ACTION"
        ;;

    # Location
    location-status | location-check | location-add-trusted | location-remove-trusted | location-list-trusted)
        load_module "location"
        call_fn "$ACTION" "$@"
        ;;

    # NFT Debug
    nft-debug-on | nft-debug-off | nft-debug-status | nft-debug-logs)
        load_module "nft-debug"
        call_fn "$ACTION"
        ;;

    # Dependency checker
    check-deps | check-dependencies)
        load_module "check-dependencies"
        # po wcześniejszym shift, argument --install znajduje się w $1
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

    # Setup Wizard (unified install/uninstall)
    setup-wizard)
        load_module "setup-wizard"
        load_module "uninstall"
        setup_wizard
        ;;


    install-dnscrypt)
        load_module "install-dnscrypt"
        install_dnscrypt
        ;;

    install-coredns)
        load_module "install-coredns"
        install_coredns
        ;;

    install-nftables | firewall-safe | firewall-strict | configure-system | restore-system | restore-system-default)
        load_module "install-nftables"
        call_fn "$ACTION"
        ;;

    install-all)
        load_module "install-all"
        install_all
        ;;

    # Config Backup/Restore
    config-backup | config-restore | config-list | config-delete)
        load_module "config-backup"
        call_fn "$ACTION" "$@"
        ;;

    # Cache Stats
    cache-stats | cache-stats-top | cache-stats-reset | cache-stats-watch)
        load_module "cache-stats"
        call_fn "$ACTION" "$@"
        ;;

    # Notifications
    notify-enable | notify-disable | notify-status | notify-test)
        load_module "notify"
        call_fn "$ACTION"
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
    diagnostics | verify | test-all | status)
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
