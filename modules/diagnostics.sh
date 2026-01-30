#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ DIAGNOSTICS MODULE v3.1                                       ║
# ║  Diagnostic tools and verification                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

run_diagnostics() {
    log_section "🔍 CITADEL++ DIAGNOSTICS"

    echo -e "${CYAN}Service Status:${NC}"
    systemctl status --no-pager dnscrypt-proxy coredns nftables || true

    echo -e "\n${CYAN}DNS Resolution Test:${NC}"
    dig +short whoami.cloudflare @127.0.0.1 || log_error "DNS resolution failed"

    echo -e "\n${CYAN}Prometheus Metrics:${NC}"
    curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" || log_error "Metrics unavailable"

    echo -e "\n${CYAN}DNSCrypt Activity (last 20 lines):${NC}"
    journalctl -u dnscrypt-proxy -n 20 --no-pager

    echo -e "\n${CYAN}Firewall Rules:${NC}"
    nft list ruleset | grep -A 10 citadel

    echo -e "\n${CYAN}Blocklist Stats:${NC}"
    wc -l /etc/coredns/zones/blocklist.hosts
}

verify_stack() {
    log_section "✅ CITADEL++ VERIFY"

    local dnscrypt_port
    local coredns_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    coredns_port="$(get_coredns_listen_port || true)"
    [[ -z "$dnscrypt_port" ]] && dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    [[ -z "$coredns_port" ]] && coredns_port="$COREDNS_PORT_DEFAULT"

    echo -e "${CYAN}Ports:${NC}"
    echo "  DNSCrypt listen: 127.0.0.1:${dnscrypt_port}"
    echo "  CoreDNS listen:  127.0.0.1:${coredns_port}"
    echo "  Metrics:         ${COREDNS_METRICS_ADDR}"

    echo -e "\n${CYAN}Services:${NC}"
    systemctl is-active --quiet dnscrypt-proxy && echo "  ✓ dnscrypt-proxy: running" || echo "  ✗ dnscrypt-proxy: not running"
    systemctl is-active --quiet coredns && echo "  ✓ coredns:        running" || echo "  ✗ coredns:        not running"

    echo -e "\n${CYAN}Firewall:${NC}"
    if nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "  ✓ nftables rules: loaded (inet citadel_dns)"
    else
        echo "  ✗ nftables rules: not loaded"
    fi
    if [[ -L /etc/nftables.d/citadel-dns.nft ]]; then
        local target
        target=$(readlink -f /etc/nftables.d/citadel-dns.nft || true)
        case "$target" in
            */citadel-dns-safe.nft) echo "  Mode: SAFE" ;;
            */citadel-dns-strict.nft) echo "  Mode: STRICT" ;;
            *) echo "  Mode: unknown ($target)" ;;
        esac
    fi

    echo -e "\n${CYAN}DNS tests:${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 -p "$coredns_port" >/dev/null 2>&1; then
            echo "  ✓ Local DNS OK"
        else
            echo "  ✗ Local DNS FAILED"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo -e "\n${CYAN}Metrics:${NC}"
    if command -v curl >/dev/null 2>&1 && curl -s "http://${COREDNS_METRICS_ADDR}/metrics" >/dev/null 2>&1; then
        echo "  ✓ Prometheus endpoint OK"
    else
        echo "  ✗ Prometheus endpoint FAILED"
    fi
}

test_all() {
    log_section "🧪 CITADEL++ TEST-ALL"

    verify_stack

    echo ""
    echo -e "${CYAN}Leak test (STRICT expected to block):${NC}"
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
    echo -e "${CYAN}IPv6 test:${NC}"
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
    log_section "📊 CITADEL++ STATUS"
    
    echo "Services:"
    for svc in dnscrypt-proxy coredns; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            printf "  ${GREEN}✓${NC} %-20s ACTIVE\n" "$svc"
        else
            printf "  ${RED}✗${NC} %-20s INACTIVE\n" "$svc"
        fi
    done
    
    echo ""
    echo "Firewall:"
    if nft list tables 2>/dev/null | grep -q "citadel"; then
        printf "  ${GREEN}✓${NC} NFTables rules loaded\n"
    else
        printf "  ${YELLOW}⚠${NC} NFTables rules NOT loaded\n"
    fi
    
    echo ""
    echo "DNS Test:"
    if command -v dig >/dev/null 2>&1 && dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
        printf "  ${GREEN}✓${NC} DNS resolution working\n"
    else
        printf "  ${RED}✗${NC} DNS resolution FAILED\n"
    fi
}
