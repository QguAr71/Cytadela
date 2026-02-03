#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ DIAGNOSTICS MODULE v3.1                                       ║
# ║  Diagnostic tools and verification                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Load centralized test functions
source_lib "${CYTADELA_LIB}/test-core.sh"

run_diagnostics() {
    # Load i18n for diagnostics module
    load_i18n_module "diagnostics"
    
    log_section "🔍 ${T_DIAG_TITLE:-CITADEL++ DIAGNOSTICS}"

    echo -e "${CYAN}${T_DIAG_SERVICE_STATUS:-Service Status:}${NC}"
    systemctl status --no-pager dnscrypt-proxy coredns nftables || true

    echo -e "\n${CYAN}${T_DIAG_DNS_TEST:-DNS Resolution Test:}${NC}"
    # Test 1: DNS stack verification (działa z Orange)
    local DNS_IP=""
    DNS_IP=$(dig +short wikipedia.org @127.0.0.1 +time=2 +tries=1 2>/dev/null) || true
    if [[ -n "$DNS_IP" ]]; then
        log_success "${T_DIAG_DNS_WORKING:-DNS resolution working} (Exit IP: $DNS_IP)"
    else
        log_error "${T_DIAG_DNS_FAILED:-DNS resolution failed}"
    fi

    # Test 2: Upstream DNS status (community info)
    echo -e "\n${CYAN}${T_DIAG_UPSTREAM_STATUS:-DNSCrypt Upstream Status:}${NC}"
    upstream=$(sudo journalctl -u dnscrypt-proxy --since "24 hours ago" | grep "Server with the lowest initial latency" | tail -1) || true
    if [[ $upstream =~ Server.*lowest.*latency:\ *([a-z0-9-]+).*\(rtt:\ *([0-9]+)ms ]]; then
        server="${BASH_REMATCH[1]}"
        rtt="${BASH_REMATCH[2]}"
        log_success "${T_DIAG_UPSTREAM_SUCCESS:-Upstream}: ${server^} (${rtt}ms) ${T_DIAG_UPSTREAM_VIA:-via DNSCrypt}"
        
        # Test 3: Quality assessment
        if [[ "$rtt" -lt 50 ]]; then
            echo -e "${GREEN}✅ ${T_DIAG_UPSTREAM_EXCELLENT:-Excellent DNSCrypt performance}${NC}"
        elif [[ "$rtt" -lt 150 ]]; then
            echo -e "${YELLOW}⚠️  ${T_DIAG_UPSTREAM_MODERATE:-Moderate latency - check ISP throttling}${NC}"
        else
            echo -e "${RED}✖ ${T_DIAG_UPSTREAM_HIGH:-High latency - possible ISP interference}${NC}"
        fi
    else
        log_error "${T_DIAG_UPSTREAM_ERROR:-Unable to get upstream info}"
    fi

    # Test 4: Internet connectivity (bonus)
    EXIT_IP=$(curl -s https://1.1.1.1/cdn-cgi/trace 2>/dev/null | grep -oP 'ip=\K.*' || true)
    if [[ -n "$EXIT_IP" ]]; then
        log_success "${T_DIAG_CONNECTIVITY:-Internet connectivity} (Public IP: $EXIT_IP)"
    fi

    echo -e "\n${CYAN}${T_DIAG_METRICS:-Prometheus Metrics:}${NC}"
    local metrics
    metrics=$(curl -s http://127.0.0.1:9153/metrics 2>/dev/null)
    if echo "$metrics" | grep -q "^coredns_"; then
        echo "$metrics" | grep "^coredns_" | head -5
    else
        log_error "${T_DIAG_METRICS_ERROR:-Metrics unavailable}"
    fi

    echo -e "\n${CYAN}${T_DIAG_DNSCRYPT_ACTIVITY:-DNSCrypt Activity (last 20 lines):}${NC}"
    journalctl -u dnscrypt-proxy -n 20 --no-pager

    echo -e "\n${CYAN}${T_DIAG_FIREWALL:-Firewall Rules:}${NC}"
    nft list ruleset | grep -A 10 citadel

    echo -e "\n${CYAN}${T_DIAG_BLOCKLIST:-Blocklist Stats:}${NC}"
    wc -l /etc/coredns/zones/blocklist.hosts
}

verify_stack() {
    # Load i18n for diagnostics module if not already loaded
    if [[ -z "${T_DIAG_TITLE:-}" ]]; then
        load_i18n_module "diagnostics"
    fi
    
    log_section "✅ ${T_VERIFY_TITLE:-CITADEL++ VERIFY}"

    local dnscrypt_port
    local coredns_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    coredns_port="$(get_coredns_listen_port || true)"
    [[ -z "$dnscrypt_port" ]] && dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    [[ -z "$coredns_port" ]] && coredns_port="$COREDNS_PORT_DEFAULT"

    echo -e "${CYAN}${T_VERIFY_PORTS:-Ports:}${NC}"
    echo "  DNSCrypt listen: 127.0.0.1:${dnscrypt_port}"
    echo "  CoreDNS listen:  127.0.0.1:${coredns_port}"
    echo "  Metrics:         ${COREDNS_METRICS_ADDR}"

    echo -e "\n${CYAN}${T_VERIFY_SERVICES:-Services:}${NC}"
    systemctl is-active --quiet dnscrypt-proxy && echo "  ✓ dnscrypt-proxy: ${T_VERIFY_RUNNING:-running}" || echo "  ✗ dnscrypt-proxy: ${T_VERIFY_NOT_RUNNING:-not running}"
    systemctl is-active --quiet coredns && echo "  ✓ coredns:        ${T_VERIFY_RUNNING:-running}" || echo "  ✗ coredns:        ${T_VERIFY_NOT_RUNNING:-not running}"

    echo -e "\n${CYAN}${T_VERIFY_FIREWALL:-Firewall:}${NC}"
    if nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "  ✓ nftables rules: ${T_VERIFY_FIREWALL_LOADED:-loaded} (inet citadel_dns)"
    else
        echo "  ✗ nftables rules: ${T_VERIFY_FIREWALL_NOT_LOADED:-not loaded}"
    fi
    if [[ -L /etc/nftables.d/citadel-dns.nft ]]; then
        local target
        target=$(readlink -f /etc/nftables.d/citadel-dns.nft || true)
        case "$target" in
            */citadel-dns-safe.nft) echo "  ${T_VERIFY_MODE_SAFE:-Mode: SAFE}" ;;
            */citadel-dns-strict.nft) echo "  ${T_VERIFY_MODE_STRICT:-Mode: STRICT}" ;;
            *) echo "  ${T_VERIFY_MODE_UNKNOWN:-Mode: unknown} ($target)" ;;
        esac
    fi

    echo -e "\n${CYAN}${T_DIAG_DNS_TESTS:-DNS tests:}${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 -p "$coredns_port" >/dev/null 2>&1; then
            echo "  ✓ Local DNS OK"
        else
            echo "  ✗ Local DNS FAILED"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo -e "\n${CYAN}${T_DIAG_METRICS:-Metrics:}${NC}"
    if command -v curl >/dev/null 2>&1 && curl -s "http://${COREDNS_METRICS_ADDR}/metrics" >/dev/null 2>&1; then
        echo "  ✓ Prometheus endpoint OK"
    else
        echo "  ✗ Prometheus endpoint FAILED"
    fi
}

test_all() {
    # Load i18n for diagnostics module if not already loaded
    if [[ -z "${T_DIAG_TITLE:-}" ]]; then
        load_i18n_module "diagnostics"
    fi
    
    log_section "🧪 ${T_TEST_ALL_TITLE:-CITADEL++ TEST-ALL}"

    verify_stack

    echo ""
    echo -e "${CYAN}${T_TEST_LEAK:-Leak test (STRICT expected to block):}${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 @1.1.1.1 test.com >/dev/null 2>&1; then
            echo "  ✗ Leak test: NOT blocked (dig @1.1.1.1 succeeded)"
        else
            echo "  ✓ Leak test: blocked/time-out (expected in STRICT)"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo ""
    echo -e "${CYAN}${T_TEST_IPV6:-IPv6 test:}${NC}"
    if command -v ping6 >/dev/null 2>&1; then
        if ping6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
            echo "  ✓ IPv6 connectivity OK"
        else
            echo "  ⚠ IPv6 connectivity FAILED"
        fi
    else
        echo "  (ping6 not installed)"
    fi
}

show_status() {
    # Load i18n for diagnostics module if not already loaded
    if [[ -z "${T_DIAG_TITLE:-}" ]]; then
        load_i18n_module "diagnostics"
    fi
    
    log_section "📊 ${T_STATUS_TITLE:-CYTADELA++ STATUS}"

    echo -e "${CYAN}Services:${NC}"
    for svc in dnscrypt-proxy coredns; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            printf "  ${GREEN}●${NC} %-20s ${GREEN}ACTIVE${NC}\n" "$svc"
        else
            printf "  ${RED}●${NC} %-20s ${RED}INACTIVE${NC}\n" "$svc"
        fi
    done

    echo ""
    echo -e "${CYAN}Firewall:${NC}"
    if nft list tables 2>/dev/null | grep -q "citadel"; then
        printf "  ${GREEN}●${NC} NFTables rules ${GREEN}LOADED${NC}\n"
    else
        printf "  ${YELLOW}●${NC} NFTables rules ${YELLOW}NOT LOADED${NC}\n"
    fi

    echo ""
    echo -e "${CYAN}DNS Resolution:${NC}"
    if command -v dig >/dev/null 2>&1 && dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
        printf "  ${GREEN}●${NC} DNS resolution ${GREEN}WORKING${NC}\n"
    else
        printf "  ${RED}●${NC} DNS resolution ${RED}FAILED${NC}\n"
    fi

    echo ""
    echo -e "${CYAN}Blocklist:${NC}"
    if [[ -f /etc/coredns/zones/blocklist.hosts ]]; then
        local count
        count=$(wc -l < /etc/coredns/zones/blocklist.hosts 2>/dev/null || echo "0")
        printf "  ${GREEN}●${NC} Blocklist entries: ${GREEN}%s${NC}\n" "$count"
    else
        printf "  ${YELLOW}●${NC} Blocklist file ${YELLOW}NOT FOUND${NC}\n"
    fi

    echo ""
    echo -e "${CYAN}Metrics:${NC}"
    if curl -s http://127.0.0.1:9153/metrics >/dev/null 2>&1; then
        printf "  ${GREEN}●${NC} Prometheus metrics ${GREEN}AVAILABLE${NC}\n"
    else
        printf "  ${YELLOW}●${NC} Prometheus metrics ${YELLOW}UNAVAILABLE${NC}\n"
    fi
}
