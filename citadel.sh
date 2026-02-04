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

# Load systemd detection module (cross-distribution compatibility)
source_lib "${CYTADELA_LIB}/systemd-detection.sh"

# Load unified core library (v3.2 backward compatibility)
source_lib "${CYTADELA_LIB}/unified-core.sh"

# Initialize unified core
unified_core_init "$@"

# Detect and verify systemd (required for Citadel)
if ! detect_systemd; then
    log_error "Citadel v3.2 requires a systemd-based Linux distribution."
    log_error "Please ensure you're running on a systemd-compatible system."
    exit 1
fi

# Note: i18n is now loaded modularly - each module calls load_i18n_module() when needed

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

# ==============================================================================
# V3.2 BACKWARD COMPATIBILITY - Command Translation
# ==============================================================================
# Translate legacy commands to unified interface for seamless migration
TRANSLATED_ACTION=$(translate_command "$ACTION")

if [[ "$TRANSLATED_ACTION" != "$ACTION" ]]; then
    log_debug "Translated legacy command: '$ACTION' → '$TRANSLATED_ACTION'"
    ACTION="$TRANSLATED_ACTION"
fi

# Parse --silent and --verbose flags
parse_silent_flag "$@"

case "$ACTION" in
    # Help
    help | --help | -h)
        load_module "help"
        citadel_help
        ;;

    # Integrity - now uses unified-security
    integrity-init | integrity-check | integrity-status)
        smart_load_module "security"
        call_fn "$ACTION"
        ;;

    # Discovery
    discover)
        load_module "discover"
        call_fn "$ACTION"
        ;;

    # IPv6 - now uses unified-network (non-recovery functions only)
    ipv6-privacy-on | ipv6-privacy-off | ipv6-privacy-status | ipv6-privacy-auto)
        smart_load_module "network"
        call_fn "$ACTION"
        ;;

    # Config Backup/Restore - now uses unified-backup
    config-backup | config-restore | config-list | config-delete)
        smart_load_module "backup"
        call_fn "$ACTION" "$@"
        ;;

    # LKG - now uses unified-backup
    lkg-save | lkg-restore | lkg-status | lists-update)
        smart_load_module "backup"
        call_fn "$ACTION"
        ;;

    # Auto-update - now uses unified-backup
    auto-update-enable | auto-update-disable | auto-update-status | auto-update-now | auto-update-configure)
        smart_load_module "backup"
        call_fn "$ACTION"
        ;;

    # Emergency (Panic Mode) - now uses unified-recovery
    panic-bypass | panic-restore | panic-status)
        smart_load_module "recovery"
        call_fn "$ACTION" "$@" || true
        ;;

    # Emergency Network Recovery - now uses unified-recovery
    emergency-network-restore | emergency-network-fix)
        smart_load_module "recovery"
        call_fn "$ACTION"
        ;;

    # Adblock - now uses unified-adblock
    adblock-status | adblock-stats | adblock-show | adblock-query | adblock-add | adblock-remove | adblock-edit | adblock-rebuild)
        smart_load_module "adblock"
        call_fn "$ACTION" "$@"
        ;;

    # Adblock aliases (legacy compatibility)
    blocklist)
        smart_load_module "adblock"
        adblock_show blocklist
        ;;

    combined)
        smart_load_module "adblock"
        adblock_show combined
        ;;

    custom)
        smart_load_module "adblock"
        adblock_show custom
        ;;

    # Blocklist Manager - now uses unified-adblock
    blocklist-list | blocklist-switch | blocklist-status | blocklist-add-url | blocklist-remove-url | blocklist-show-urls)
        smart_load_module "adblock"
        call_fn "$ACTION" "$@"
        ;;

    # Allowlist - now uses unified-adblock
    allowlist-list | allowlist-add | allowlist-remove)
        smart_load_module "adblock"
        call_fn "$ACTION" "$@"
        ;;

    # Ghost Check - now uses unified-security
    ghost-check)
        smart_load_module "security"
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

    # Supply Chain - now uses unified-security
    supply-chain-status | supply-chain-init | supply-chain-verify)
        smart_load_module "security"
        call_fn "$ACTION"
        ;;

    # Reputation System (v3.3.0) - now uses unified-security
    reputation-list | reputation-reset | reputation-stats | reputation-config | reputation-manual)
        smart_load_module "security"
        case "$ACTION" in
            reputation-list) call_fn "reputation_list" "$1" ;;
            reputation-reset) call_fn "reputation_reset" "$1" ;;
            reputation-stats) call_fn "reputation_stats" ;;
            reputation-config) call_fn "reputation_config" "$1" "$2" "$3" ;;
            reputation-manual) call_fn "reputation_manual" "$1" "$2" "$3" ;;
        esac
        ;;

    # ASN Blocking (v3.3.0) - now uses unified-security
    asn-block | asn-unblock | asn-list | asn-add | asn-remove | asn-info | asn-stats | asn-update-cache)
        smart_load_module "security"
        case "$ACTION" in
            asn-block) call_fn "asn_block" "$1" ;;
            asn-unblock) call_fn "asn_unblock" "$1" ;;
            asn-list) call_fn "asn_list" ;;
            asn-add) call_fn "asn_add" "$1" "$2" ;;
            asn-remove) call_fn "asn_remove" "$1" ;;
            asn-info) call_fn "asn_info" "$1" ;;
            asn-stats) call_fn "asn_stats" ;;
            asn-update-cache) call_fn "asn_update_cache" ;;
        esac
        ;;

    # Event Logging (v3.3.0) - now uses unified-security
    events-query | events-stats | events-recent | events-export | events-analyze)
        smart_load_module "security"
        case "$ACTION" in
            events-query) call_fn "event_query" "$1" "$2" "$3" ;;
            events-stats) call_fn "event_stats" "$1" ;;
            events-recent) call_fn "event_recent" "$1" ;;
            events-export) call_fn "event_export" "$1" "$2" ;;
            events-analyze) call_fn "event_analyze" "$1" ;;
        esac
        ;;

    # Honeypot (v3.3.0) - now uses unified-security
    honeypot-deploy | honeypot-undeploy | honeypot-status | honeypot-list | honeypot-cleanup)
        smart_load_module "security"
        case "$ACTION" in
            honeypot-deploy) call_fn "honeypot_deploy" "$1" "$2" ;;
            honeypot-undeploy) call_fn "honeypot_undeploy" "$1" ;;
            honeypot-status) call_fn "honeypot_status" "$1" ;;
            honeypot-list) call_fn "honeypot_list" ;;
            honeypot-cleanup) call_fn "honeypot_cleanup" "$1" ;;
        esac
        ;;

    # Location - now uses unified-security
    location-status | location-check | location-add-trusted | location-remove-trusted | location-list-trusted)
        smart_load_module "security"
        call_fn "$ACTION" "$@"
        ;;

    # NFT Debug - now uses unified-security
    nft-debug-on | nft-debug-off | nft-debug-status | nft-debug-logs)
        smart_load_module "security"
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

    # Advanced Management (v3.3+)
    service-create | service-remove | service-start | service-stop | service-restart | service-enable | service-disable | service-status | service-list | service-setup-all | service-remove-all | monitoring-health-check | monitoring-system-info)
        # Load advanced management system
        if [[ -f "lib/advanced-management.sh" ]]; then
            source "lib/advanced-management.sh"
        else
            log_error "Advanced management system not found"
            exit 1
        fi

        case "$ACTION" in
            service-create) call_fn "service_create" "${1:-}" "${2:-}" ;;
            service-remove) call_fn "service_remove" "${1:-}" ;;
            service-start) call_fn "service_start" "${1:-}" ;;
            service-stop) call_fn "service_stop" "${1:-}" ;;
            service-restart) call_fn "service_restart" "${1:-}" ;;
            service-enable) call_fn "service_enable" "${1:-}" ;;
            service-disable) call_fn "service_disable" "${1:-}" ;;
            service-status) call_fn "service_status" "${1:-}" ;;
            service-list) call_fn "service_list" ;;
            service-setup-all) call_fn "service_setup_all" ;;
            service-remove-all) call_fn "service_remove_all" ;;
            monitoring-health-check) call_fn "monitoring_health_check" ;;
            monitoring-system-info) call_fn "monitoring_system_info" ;;
        esac
        ;;
    # Enterprise Features (v3.3)
    enterprise-init | enterprise-status | enterprise-metrics | enterprise-security-init)
        # Load enterprise features system
        if [[ -f "lib/enterprise-features.sh" ]]; then
            source "lib/enterprise-features.sh"
        else
            log_error "Enterprise features system not found"
            exit 1
        fi

        case "$ACTION" in
            enterprise-init) call_fn "enterprise_init" ;;
            enterprise-status) call_fn "enterprise_status" ;;
            enterprise-metrics) call_fn "enterprise_metrics" ;;
            prometheus-setup) call_fn "setup_prometheus_integration" ;;
            grafana-setup) call_fn "setup_grafana_integration" ;;
            docker-setup) call_fn "setup_docker_integration" ;;
            enterprise-security-init) call_fn "enterprise_security_init" ;;
            scalability-init) call_fn "scalability_init" ;;
        esac
        ;;
    # Install command dispatcher
    install)
        # Dispatch to appropriate install subcommand based on $1
        case "${1:-}" in
            check-deps | check-dependencies)
                load_module "check-dependencies"
                check_dependencies
                ;;
            wizard)
                load_module "install-wizard"
                install_wizard
                ;;
            dnscrypt)
                load_module "install-dnscrypt"
                install_dnscrypt
                ;;
            coredns)
                load_module "install-coredns"
                install_coredns
                ;;
            nftables | firewall-safe | firewall-strict | configure-system)
                load_module "install-nftables"
                call_fn "$1"
                ;;
            all)
                load_module "install-all"
                install_all
                ;;
            dashboard)
                load_module "install-dashboard"
                install_citadel_top
                ;;
            *)
                log_error "Nieznana komenda instalacji: install $1"
                echo "Dostępne komendy instalacji:"
                echo "  install check-deps        - sprawdź zależności"
                echo "  install wizard           - kreator instalacji"
                echo "  install dnscrypt         - zainstaluj DNSCrypt"
                echo "  install coredns          - zainstaluj CoreDNS"
                echo "  install nftables         - skonfiguruj firewall"
                echo "  install firewall-safe    - bezpieczna konfiguracja firewalla"
                echo "  install firewall-strict  - ścisła konfiguracja firewalla"
                echo "  install configure-system - skonfiguruj system DNS"
                echo "  install all              - zainstaluj wszystko"
                echo "  install dashboard        - zainstaluj dashboard"
                exit 1
                ;;
        esac
        ;;

    # Setup Wizard (unified install/uninstall)
    install-dnscrypt)
        load_module "install-dnscrypt"
        install_dnscrypt
        ;;

    install-coredns)
        load_module "install-coredns"
        install_coredns
        ;;

    install-nftables | firewall-safe | firewall-strict | configure-system)
        load_module "install-nftables"
        call_fn "$ACTION"
        ;;

    # System Restore - now uses unified-recovery
    restore-system | restore-system-default)
        smart_load_module "recovery"
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

    # Cache Stats - now uses unified-monitor
    cache-stats)
        smart_load_module "monitor"
        monitor_cache_stats "$@"
        ;;

    cache-stats-top | cache-stats-reset | cache-stats-watch)
        smart_load_module "monitor"
        case "$ACTION" in
            cache-stats-top) monitor_cache_top "$2" ;;
            cache-stats-reset) monitor_cache_reset ;;
            cache-stats-watch) monitor_cache_watch ;;
        esac
        ;;

    # Diagnostics - now uses unified-monitor
    diagnostics | run-diagnostics)
        smart_load_module "monitor"
        monitor_diagnostics
        ;;

    verify-config | verify-stack)
        smart_load_module "monitor"
        monitor_verify
        ;;

    test-all)
        smart_load_module "monitor"
        monitor_test_all
        ;;

    status)
        smart_load_module "monitor"
        monitor_status
        ;;

    # Verify Config - now uses unified-monitor
    verify-config-check | verify-config-dns)
        smart_load_module "monitor"
        case "$ACTION" in
            verify-config-check) monitor_verify_config ;;
            verify-config-dns) monitor_verify_dns ;;
        esac
        ;;

    # Prometheus - now uses unified-monitor
    prometheus-export | prometheus-collect)
        smart_load_module "monitor"
        monitor_prometheus_collect
        ;;

    prometheus-serve | prometheus-status)
        smart_load_module "monitor"
        case "$ACTION" in
            prometheus-serve) monitor_prometheus_serve ;;
            prometheus-status) monitor_prometheus_status ;;
        esac
        ;;

    # Benchmark - now uses unified-monitor
    benchmark-dns | benchmark-all | benchmark-report | benchmark-compare)
        smart_load_module "monitor"
        case "$ACTION" in
            benchmark-dns) monitor_benchmark_dns ;;
            benchmark-all) monitor_benchmark_all ;;
            benchmark-report) monitor_benchmark_report ;;
            benchmark-compare) monitor_benchmark_compare ;;
        esac
        ;;

    # Fix Ports - now uses unified-network
    fix-ports)
        smart_load_module "network"
        fix_port_conflicts
        ;;

    # Notifications - now uses unified-network
    notify-enable | notify-disable | notify-status | notify-test)
        smart_load_module "network"
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

    # Edit Tools - now uses unified-network
    edit)
        smart_load_module "network"
        edit_config
        ;;

    edit-dnscrypt)
        smart_load_module "network"
        edit_dnscrypt
        ;;

    logs)
        smart_load_module "network"
        show_logs "$@"
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

    # Verify Config
    verify-config)
        load_module "verify-config"
        subcmd="${1:-check}"
        case "$subcmd" in
            check) verify_config_check ;;
            dns) verify_config_dns ;;
            services) verify_config_services ;;
            files) verify_config_files ;;
            all) verify_config_check && verify_config_dns ;;
            help|--help|-h) verify_config_help ;;
            *) verify_config "$subcmd" ;;
        esac
        ;;
    # Configuration Management (v3.3+)
    config-init | config-get | config-set | config-validate | config-show | config-export | config-import | config-diff | config-reset | config-list-profiles | config-switch-profile | config-apply)
        # Load configuration management module
        if [[ -f "lib/config-management.sh" ]]; then
            source "lib/config-management.sh"
        else
            log_error "Configuration management module not found"
            exit 1
        fi

        case "$ACTION" in
            config-init) call_fn "config_init" "$1" ;;
            config-get) call_fn "config_get" "$1" ;;
            config-set) call_fn "config_set" "$1" "$2" ;;
            config-validate) call_fn "config_validate" "true" ;;
            config-show) call_fn "config_show" "$1" ;;
            config-export) call_fn "config_export" "$1" ;;
            config-import) call_fn "config_import" "$1" ;;
            config-diff) call_fn "config_diff" "$1" "$2" ;;
            config-reset) call_fn "config_reset" "$1" ;;
            config-list-profiles) call_fn "config_list_profiles" ;;
            config-switch-profile) call_fn "config_switch_profile" "$1" ;;
            config-apply) call_fn "config_apply" ;;
        esac
        ;;
    # Module Management (v3.3+)
    module-list | module-load | module-unload | module-reload | module-info | module-load-all | module-unload-all | module-discover)
        # Load module management system
        if [[ -f "lib/module-management.sh" ]]; then
            source "lib/module-management.sh"
            # Initialize module management system
            module_management_init
        else
            log_error "Module management system not found"
            exit 1
        fi

        case "$ACTION" in
            module-list) call_fn "module_list" "${1:-}" ;;
            module-load) call_fn "module_load" "${1:-}" ;;
            module-unload) call_fn "module_unload" "${1:-}" ;;
            module-reload) call_fn "module_reload" "${1:-}" ;;
            module-info) call_fn "module_info" "${1:-}" ;;
            module-load-all) call_fn "module_load_all" ;;
            module-unload-all) call_fn "module_unload_all" ;;
            module-discover) call_fn "module_discover" ;;
        esac
        ;;
    monitor)
        # Dispatch to appropriate monitor subcommand based on $1
        case "${1:-}" in
            status)
                smart_load_module "monitor"
                monitor_status
                ;;
            diagnostics|run-diagnostics)
                smart_load_module "monitor"
                monitor_diagnostics
                ;;
            verify|verify-config|verify-stack)
                smart_load_module "monitor"
                monitor_verify
                ;;
            test-all)
                smart_load_module "monitor"
                monitor_test_all
                ;;
            cache-stats)
                smart_load_module "monitor"
                monitor_cache_stats
                ;;
            cache-stats-top)
                smart_load_module "monitor"
                monitor_cache_top "$2"
                ;;
            cache-stats-reset)
                smart_load_module "monitor"
                monitor_cache_reset
                ;;
            cache-stats-watch)
                smart_load_module "monitor"
                monitor_cache_watch
                ;;
            verify-config-check)
                smart_load_module "monitor"
                monitor_verify_config
                ;;
            verify-config-dns)
                smart_load_module "monitor"
                monitor_verify_dns
                ;;
            benchmark-dns)
                smart_load_module "monitor"
                monitor_benchmark_dns
                ;;
            benchmark-all)
                smart_load_module "monitor"
                monitor_benchmark_all
                ;;
            benchmark-report)
                smart_load_module "monitor"
                monitor_benchmark_report
                ;;
            benchmark-compare)
                smart_load_module "monitor"
                monitor_benchmark_compare
                ;;
            prometheus-export|prometheus-collect)
                smart_load_module "monitor"
                monitor_prometheus_collect
                ;;
            prometheus-serve)
                smart_load_module "monitor"
                monitor_prometheus_serve
                ;;
            prometheus-status)
                smart_load_module "monitor"
                monitor_prometheus_status
                ;;
            *)
                log_error "Nieznana komenda monitor: monitor $1"
                echo "Dostępne komendy monitor:"
                echo "  monitor status              - ogólny status systemu"
                echo "  monitor diagnostics         - szczegółowa diagnostyka"
                echo "  monitor verify              - weryfikacja konfiguracji"
                echo "  monitor test-all            - pełne testy systemu"
                echo "  monitor cache-stats         - statystyki cache DNS"
                echo "  monitor cache-stats-top     - top domen w cache"
                echo "  monitor cache-stats-reset   - reset statystyk cache"
                echo "  monitor cache-stats-watch   - monitorowanie cache na żywo"
                echo "  monitor benchmark-dns       - benchmark DNS"
                echo "  monitor benchmark-all       - pełne benchmarki"
                echo "  monitor prometheus-export   - eksport metryk Prometheus"
                exit 1
                ;;
        esac
        ;;
    *)
        log_error "Nieznana komenda: $ACTION"
        echo ""
        echo "Użyj: $0 help"
        exit 1
        ;;
esac
