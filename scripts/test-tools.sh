#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ TEST-TOOLS MODULE v3.1                                        ║
# ║  Safe Test Mode and Basic DNS Test                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Load centralized test functions
source_lib "${CYTADELA_LIB}/test-core.sh"

safe_test_mode() {
    log_section "󰙨 SAFE TEST MODE"

    log_info "Uruchamiam testy bez przerywania internetu..."

    # Test 1: Check dependencies
    log_info "Sprawdzanie zależności..."
    for cmd in dnscrypt-proxy coredns nftables; do
        if command -v "$cmd" >/dev/null; then
            echo "󰄬 $cmd dostępny"
        else
            echo "󰅖 $cmd nieznaleziony"
        fi
    done

    # Test 2: Validate configurations
    log_info "Walidacja konfiguracji..."
    if [[ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]; then
        if dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check >/dev/null 2>&1; then
            echo "󰄬 DNSCrypt config poprawny"
        else
            echo "󰅖 DNSCrypt config błędny"
        fi
    fi

    # Test 3: Check ports
    log_info "Sprawdzanie portów..."
    if ss -ln | grep -q ":53"; then
        echo "󰀨 Port 53 zajęty - może wymagać zatrzymania systemd-resolved"
    else
        echo "󰄬 Port 53 wolny"
    fi

    echo ""
    log_info "Tryb bezpieczny zakończony. Użyj 'install-all' dla pełnej instalacji"
}

test_dns() {
    log_section "󰙨 DNS TEST"

    log_info "Testing DNS resolution..."

    # Detect CoreDNS port
    COREDNS_PORT=53
    if [[ -f /etc/coredns/Corefile ]]; then
        p=$(awk -F'[:}]' '/^\.:/ {gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' /etc/coredns/Corefile 2>/dev/null)
        if [[ -n "$p" ]]; then
            COREDNS_PORT="$p"
        fi
    fi

    if test_dns_resolution "whoami.cloudflare" "127.0.0.1"; then
        log_success "DNS resolution: OK"
        dig +short whoami.cloudflare @127.0.0.1 -p ${COREDNS_PORT}
    else
        log_error "DNS test failed"
        return 1
    fi
}
