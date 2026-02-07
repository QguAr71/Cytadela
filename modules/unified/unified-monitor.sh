#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-MONITOR MODULE v3.2                                ║
# ║  Unified monitoring, diagnostics, and performance tools               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

# Cache stats settings
METRICS_URL="http://${COREDNS_METRICS_ADDR:-127.0.0.1:9153}/metrics"

# Benchmark settings
BENCHMARK_DIR="/var/lib/cytadela/benchmarks"
BENCHMARK_REPORT="${BENCHMARK_DIR}/latest.txt"
BENCHMARK_HISTORY="${BENCHMARK_DIR}/history.csv"

# Prometheus settings
METRICS_DIR="/var/lib/cytadela/metrics"
METRICS_FILE="${METRICS_DIR}/citadel.prom"
METRICS_PORT="${CITADEL_METRICS_PORT:-9100}"

# Health settings
HEALTH_CHECK_SERVICES=(dnscrypt-proxy coredns)

# ==============================================================================
# DIAGNOSTICS FUNCTIONS (migrated from diagnostics.sh)
# ==============================================================================

# Run comprehensive diagnostics
monitor_diagnostics() {
    # Load i18n strings based on language
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    if [[ -f "lib/i18n/${lang}.sh" ]]; then
        source "lib/i18n/${lang}.sh"
    fi

    log_section "󰍉 ${T_DIAG_TITLE:-CITADEL++ DIAGNOSTICS}"

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
    local upstream
    upstream=$(sudo journalctl -u dnscrypt-proxy --since "24 hours ago" | grep "Server with the lowest initial latency" | tail -1) || true
    if [[ $upstream =~ Server.*lowest.*latency:\ *([a-z0-9-]+).*\(rtt:\ *([0-9]+)ms ]]; then
        local server="${BASH_REMATCH[1]}"
        local rtt="${BASH_REMATCH[2]}"
        log_success "${T_DIAG_UPSTREAM_SUCCESS:-Upstream}: ${server^} (${rtt}ms) ${T_DIAG_UPSTREAM_VIA:-via DNSCrypt}"

        # Test 3: Quality assessment
        if [[ "$rtt" -lt 50 ]]; then
            echo -e "${GREEN}󰄬 ${T_DIAG_UPSTREAM_EXCELLENT:-Excellent DNSCrypt performance}${NC}"
        elif [[ "$rtt" -lt 150 ]]; then
            echo -e "${YELLOW}󰀨  ${T_DIAG_UPSTREAM_MODERATE:-Moderate latency - check ISP throttling}${NC}"
        else
            echo -e "${RED}󰅖 ${T_DIAG_UPSTREAM_HIGH:-High latency - possible ISP interference}${NC}"
        fi
    else
        log_error "${T_DIAG_UPSTREAM_ERROR:-Unable to get upstream info}"
    fi

    # Test 4: Internet connectivity (bonus)
    local EXIT_IP
    EXIT_IP=$(curl -s https://1.1.1.1/cdn-cgi/trace 2>/dev/null | grep -oP 'ip=\K.*' || true)
    if [[ -n "$EXIT_IP" ]]; then
        log_success "${T_DIAG_CONNECTIVITY:-Internet connectivity} (Public IP: $EXIT_IP)"
    fi

    echo -e "\n${CYAN}${T_DIAG_METRICS:-Prometheus Metrics:}${NC}"
    local metrics
    metrics=$(curl -s "$METRICS_URL" 2>/dev/null)
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
    wc -l /etc/coredns/zones/combined.hosts
}

# Verify configuration and stack
monitor_verify() {
    # Load i18n strings based on language
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    if [[ -f "lib/i18n/${lang}.sh" ]]; then
        source "lib/i18n/${lang}.sh"
    fi

    log_section "󰄬 ${T_VERIFY_TITLE:-CITADEL++ VERIFY}"

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
    systemctl is-active --quiet dnscrypt-proxy && echo "  󰄬 dnscrypt-proxy: ${T_VERIFY_RUNNING:-running}" || echo "  󰅖 dnscrypt-proxy: ${T_VERIFY_NOT_RUNNING:-not running}"
    systemctl is-active --quiet coredns && echo "  󰄬 coredns:        ${T_VERIFY_RUNNING:-running}" || echo "  󰅖 coredns:        ${T_VERIFY_NOT_RUNNING:-not running}"

    echo -e "\n${CYAN}${T_VERIFY_FIREWALL:-Firewall:}${NC}"
    if nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "  󰄬 ${T_VERIFY_NFT_OK:-Citadel NFTables table exists}"
    else
        echo "  󰅖 ${T_VERIFY_NFT_MISSING:-Citadel NFTables table not found}"
    fi

    echo -e "\n${CYAN}${T_DIAG_DNS_TESTS:-DNS tests:}${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 -p "$coredns_port" >/dev/null 2>&1; then
            echo "  󰄬 Local DNS OK"
        else
            echo "  󰅖 Local DNS FAILED"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo -e "\n${CYAN}${T_DIAG_METRICS:-Metrics:}${NC}"
    if command -v curl >/dev/null 2>&1 && curl -s "${COREDNS_METRICS_ADDR}/metrics" >/dev/null 2>&1; then
        echo "  󰄬 Prometheus endpoint OK"
    else
        echo "  󰅖 Prometheus endpoint FAILED"
    fi
}

# Run all diagnostic tests
monitor_test_all() {
    # Load i18n strings - try new i18n-engine first, fallback to legacy
    local lang="${CYTADELA_LANG:-${LANG%%_*}:-en}"
    lang="${lang:-en}"
    
    # Try new i18n-engine
    if [[ -f "modules/i18n-engine/i18n-engine.sh" ]]; then
        source "modules/i18n-engine/i18n-engine.sh" 2>/dev/null && {
            i18n_engine_init 2>/dev/null || true
            i18n_engine_load "diagnostics" "$lang" 2>/dev/null || true
        }
    fi
    
    # Fallback to legacy i18n if available
    if [[ -f "lib/i18n/${lang}.sh" ]]; then
        source "lib/i18n/${lang}.sh" 2>/dev/null || true
    fi

    # Load benchmark library for unified functionality
    if [[ -f "lib/benchmark.sh" ]]; then
        source "lib/benchmark.sh" 2>/dev/null || true
    fi

    log_section "󰙨 ${T_TEST_ALL_TITLE:-CITADEL++ TEST-ALL}"

    monitor_verify

    echo ""
    echo -e "${CYAN}${T_TEST_LEAK:-Leak test (STRICT expected to block):}${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 @1.1.1.1 test.com >/dev/null 2>&1; then
            echo "  󰅖 Leak test: NOT blocked (dig @1.1.1.1 succeeded)"
        else
            echo "  󰄬 Leak test: blocked/time-out (expected in STRICT)"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo ""
    echo -e "${CYAN}${T_TEST_IPV6:-IPv6 test:}${NC}"
    if command -v ping6 >/dev/null 2>&1; then
        if ping6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
            echo "  󰄬 IPv6 connectivity OK"
        else
            echo "  󰀨 IPv6 connectivity FAILED"
        fi
    else
        echo "  (ping6 not installed)"
    fi

    # Test optimize-kernel (priority optimization)
    echo ""
    echo -e "${CYAN}${T_TEST_OPTIMIZE_KERNEL:-Kernel Priority Optimization (optimize-kernel):}${NC}"
    local priority_ok=true
    
    # Check if timer exists and is active
    if systemctl list-timers --all 2>/dev/null | grep -q "citadel-dns-priority"; then
        if systemctl is-active --quiet citadel-dns-priority.timer 2>/dev/null; then
            echo "  󰄬 ${T_TEST_PRIORITY_TIMER:-Priority timer}: ACTIVE"
        else
            echo "  󰀨 ${T_TEST_PRIORITY_TIMER:-Priority timer}: inactive (enabled but not running)"
        fi
    else
        echo "  󰅖 ${T_TEST_PRIORITY_TIMER:-Priority timer}: NOT FOUND"
        priority_ok=false
    fi
    
    # Check if priority script exists
    if [[ -f "/usr/local/bin/citadel-dns-priority.sh" ]]; then
        echo "  󰄬 ${T_TEST_PRIORITY_SCRIPT:-Priority script}: EXISTS"
    else
        echo "  󰅖 ${T_TEST_PRIORITY_SCRIPT:-Priority script}: NOT FOUND"
        priority_ok=false
    fi
    
    # Check if DNS processes have elevated priorities
    local dnscrypt_nice=$(ps -o nice= -p $(pgrep -x dnscrypt-proxy 2>/dev/null || echo 0) 2>/dev/null || echo "N/A")
    if [[ "$dnscrypt_nice" != "N/A" && "$dnscrypt_nice" -lt 0 ]]; then
        echo "  󰄬 ${T_TEST_DNSCRYPT_PRIORITY:-DNSCrypt priority}: ELEVATED (nice: $dnscrypt_nice)"
    else
        echo "  󰀨 ${T_TEST_DNSCRYPT_PRIORITY:-DNSCrypt priority}: normal (nice: ${dnscrypt_nice:-N/A})"
    fi
    
    if [[ "$priority_ok" == true ]]; then
        log_success "${T_TEST_OPTIMIZE_KERNEL_OK:-Kernel priority optimization: CONFIGURED}"
    else
        log_warning "${T_TEST_OPTIMIZE_KERNEL_NA:-Kernel priority optimization: NOT DETECTED}"
    fi

    # Test doh-parallel (DoH parallel racing)
    echo ""
    echo -e "${CYAN}${T_TEST_DOH_PARALLEL:-DNS-over-HTTPS Parallel (doh-parallel):}${NC}"
    local doh_ok=false
    local doh_port=""
    
    # Check if DoH config exists
    if [[ -f "/etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml" ]]; then
        echo "  󰄬 ${T_TEST_DOH_CONFIG:-DoH config}: EXISTS"
        
        # Extract port from config
        doh_port=$(grep "listen_addresses" /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml 2>/dev/null | grep -oP '127\.0\.0\.1:\K[0-9]+' || echo "")
        if [[ -n "$doh_port" ]]; then
            echo "  󰄬 ${T_TEST_DOH_PORT:-DoH port}: $doh_port"
            
            # Test DNS on DoH port
            if dig +time=2 +tries=1 @127.0.0.1 -p "$doh_port" whoami.cloudflare +short >/dev/null 2>&1; then
                echo "  󰄬 ${T_TEST_DOH_DNS:-DoH DNS test}: WORKING (port $doh_port)"
                doh_ok=true
            else
                echo "  󰀨 ${T_TEST_DOH_DNS:-DoH DNS test}: FAILED (port $doh_port)"
            fi
        else
            echo "  󰀨 ${T_TEST_DOH_PORT:-DoH port}: NOT DETECTED in config"
        fi
    else
        echo "  󰅖 ${T_TEST_DOH_CONFIG:-DoH config}: NOT FOUND"
    fi
    
    # Check if current DNSCrypt config has DoH settings
    if [[ -f "/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]]; then
        if grep -q "doh_servers.*=.*true" /etc/dnscrypt-proxy/dnscrypt-proxy.toml 2>/dev/null; then
            echo "  󰄬 ${T_TEST_DOH_ENABLED:-DoH enabled}: YES (in active config)"
            doh_ok=true
        else
            echo "  󰀨 ${T_TEST_DOH_ENABLED:-DoH enabled}: NO (in active config)"
        fi
        
        if grep -q "lb_strategy.*=.*'p2'" /etc/dnscrypt-proxy/dnscrypt-proxy.toml 2>/dev/null; then
            echo "  󰄬 ${T_TEST_PARALLEL_RACING:-Parallel racing (p2)}: ENABLED"
        else
            echo "  󰀨 ${T_TEST_PARALLEL_RACING:-Parallel racing (p2)}: NOT ENABLED"
        fi
    fi
    
    if [[ "$doh_ok" == true ]]; then
        log_success "${T_TEST_DOH_OK:-DoH Parallel Racing: ACTIVE}"
    else
        log_warning "${T_TEST_DOH_NA:-DoH Parallel Racing: NOT DETECTED}"
    fi

    # Test editor-integration
    echo ""
    echo -e "${CYAN}${T_TEST_EDITOR:-Editor Integration (editor-integration):}${NC}"
    if [[ -f "/usr/local/bin/citadel" ]]; then
        echo "  󰄬 ${T_TEST_EDITOR_CMD:-citadel command}: EXISTS"
        if /usr/local/bin/citadel help >/dev/null 2>&1; then
            echo "  󰄬 ${T_TEST_EDITOR_HELP:-citadel help}: WORKING"
        else
            echo "  󰀨 ${T_TEST_EDITOR_HELP:-citadel help}: NOT RESPONDING"
        fi
    else
        echo "  󰅖 ${T_TEST_EDITOR_CMD:-citadel command}: NOT FOUND"
    fi
    
    if command -v micro >/dev/null 2>&1; then
        echo "  󰄬 ${T_TEST_MICRO_EDITOR:-Micro editor}: INSTALLED"
    else
        echo "  󰀨 ${T_TEST_MICRO_EDITOR:-Micro editor}: NOT INSTALLED"
    fi
}

# Show system status
monitor_status() {
    # Load i18n strings based on language
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    if [[ -f "lib/i18n/${lang}.sh" ]]; then
        source "lib/i18n/${lang}.sh"
    fi

    log_section "󰄬 ${T_STATUS_TITLE:-CYTADELA++ STATUS}"

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
    if [[ -f /etc/coredns/zones/combined.hosts ]]; then
        local count
        count=$(wc -l < /etc/coredns/zones/combined.hosts)
        printf "  ${GREEN}●${NC} Blocklist entries: ${GREEN}%s${NC}\n" "$count"
    else
        printf "  ${YELLOW}●${NC} Blocklist file ${YELLOW}NOT FOUND${NC}\n"
    fi

    echo ""
    echo -e "${CYAN}Metrics:${NC}"
    if curl -s "$METRICS_URL" >/dev/null 2>&1; then
        printf "  ${GREEN}●${NC} Prometheus metrics ${GREEN}AVAILABLE${NC}\n"
    else
        printf "  ${YELLOW}●${NC} Prometheus metrics ${YELLOW}UNAVAILABLE${NC}\n"
    fi
}

# ==============================================================================
# CACHE STATS FUNCTIONS (migrated from cache-stats.sh)
# ==============================================================================

# Show cache statistics
monitor_cache_stats() {
    log_section "📊 DNS CACHE STATISTICS"

    local top_n="${1:-10}"

    # Check if CoreDNS is running
    if ! systemctl is-active --quiet coredns; then
        log_error "CoreDNS is not running"
        return 1
    fi

    # Fetch metrics
    local metrics
    if ! metrics=$(curl -s "$METRICS_URL" 2>/dev/null); then
        log_error "Failed to fetch metrics from $METRICS_URL"
        return 1
    fi

    # Parse cache hits/misses
    local cache_hits cache_misses
    cache_hits=$(echo "$metrics" | grep '^coredns_cache_hits_total' | awk '{sum+=$2} END {print sum+0}')
    cache_misses=$(echo "$metrics" | grep '^coredns_cache_misses_total' | awk '{sum+=$2} END {print sum+0}')
    local total_requests=$((cache_hits + cache_misses))

    # Calculate hit rate
    local hit_rate=0
    if [[ $total_requests -gt 0 ]]; then
        hit_rate=$(awk "BEGIN {printf \"%.2f\", ($cache_hits / $total_requests) * 100}")
    fi

    # Cache size
    local cache_size
    cache_size=$(echo "$metrics" | grep '^coredns_cache_entries' | grep 'type="success"' | awk '{print $2}')

    # Display stats
    echo -e "${CYAN}Cache Performance:${NC}"
    printf "  Total requests: %'d\n" "$total_requests"
    printf "  Cache hits:     %'d\n" "$cache_hits"
    printf "  Cache misses:   %'d\n" "$cache_misses"
    printf "  Hit rate:       ${GREEN}%s%%${NC}\n" "$hit_rate"
    printf "  Cache entries:  %s\n" "${cache_size:-0}"

    echo ""
    echo -e "${CYAN}Request Types:${NC}"

    # Parse request types - handle empty results gracefully
    local type_a type_aaaa type_ptr type_other
    type_a=$(echo "$metrics" | grep 'coredns_dns_requests_total.*type="A"' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)
    type_aaaa=$(echo "$metrics" | grep 'coredns_dns_requests_total.*type="AAAA"' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)
    type_ptr=$(echo "$metrics" | grep 'coredns_dns_requests_total.*type="PTR"' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)
    type_other=$(echo "$metrics" | grep 'coredns_dns_requests_total' | grep -v 'type="A"' | grep -v 'type="AAAA"' | grep -v 'type="PTR"' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)

    printf "  A (IPv4):       %'d\n" "$type_a"
    printf "  AAAA (IPv6):    %'d\n" "$type_aaaa"
    printf "  PTR (reverse):  %'d\n" "$type_ptr"
    printf "  Other:          %'d\n" "$type_other"

    echo ""
    echo -e "${CYAN}Response Codes:${NC}"

    # Parse response codes - handle empty results gracefully
    local rcode_success rcode_nxdomain rcode_servfail
    rcode_success=$(echo "$metrics" | grep 'coredns_dns_responses_total.*rcode="NOERROR"' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)
    rcode_nxdomain=$(echo "$metrics" | grep 'coredns_dns_responses_total.*rcode="NXDOMAIN"' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)
    rcode_servfail=$(echo "$metrics" | grep 'coredns_dns_responses_total.*rcode="SERVFAIL"' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)

    printf "  NOERROR:        %'d\n" "$rcode_success"
    printf "  NXDOMAIN:       %'d\n" "$rcode_nxdomain"
    printf "  SERVFAIL:       %'d\n" "$rcode_servfail"

    # Top blocked domains (from adblock stats)
    if [[ -f /etc/coredns/zones/combined.hosts ]]; then
        echo ""
        echo -e "${CYAN}Adblock Stats:${NC}"
        local total_blocked
        total_blocked=$(wc -l </etc/coredns/zones/combined.hosts)
        printf "  Total blocked:  %'d domains\n" "$total_blocked"
    fi

    # Query latency
    echo ""
    echo -e "${CYAN}Query Latency:${NC}"
    local latency_sum latency_count
    latency_sum=$(echo "$metrics" | grep 'coredns_dns_request_duration_seconds_sum' | awk '{sum+=$2} END {print sum}' 2>/dev/null | tr -d '\n' || echo 0)
    latency_count=$(echo "$metrics" | grep 'coredns_dns_request_duration_seconds_count' | awk '{sum+=$2} END {print sum+0}' 2>/dev/null | tr -d '\n' || echo 0)

    if [[ $latency_count -gt 0 ]]; then
        local avg_latency
        avg_latency=$(awk "BEGIN {printf \"%.2f\", ($latency_sum / $latency_count) * 1000}" 2>/dev/null || echo 0)
        printf "  Average:        ${GREEN}%s ms${NC}\n" "$avg_latency"
    else
        printf "  Average:        N/A\n"
    fi
}

# Show top domains
monitor_cache_top() {
    log_section "🔝 TOP DOMAINS"

    local top_n="${1:-20}"

    # This requires CoreDNS query logging to be enabled
    # For now, show top blocked domains from blocklist

    if [[ ! -f /etc/coredns/zones/combined.hosts ]]; then
        log_warning "No blocklist found"
        return 1
    fi

    echo "Top $top_n most common blocked domains (by TLD):"
    echo ""

    awk '{print $2}' /etc/coredns/zones/combined.hosts 2>/dev/null |
        sed 's/.*\.\([^.]*\.[^.]*\)$/\1/' |
        sort | uniq -c | sort -rn | head -n "$top_n" |
        awk '{printf "  %8d  %s\n", $1, $2}'
}

# Reset cache statistics
monitor_cache_reset() {
    log_section "󰜝 RESET CACHE STATS"

    log_warning "This will restart CoreDNS (metrics will be reset)"
    read -p "Continue? [y/N]: " answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        systemctl restart coredns
        log_success "CoreDNS restarted, metrics reset"
    else
        log_info "Cancelled"
    fi
}

# Watch cache stats live
monitor_cache_watch() {
    log_section "👁️  WATCH CACHE STATS (live)"

    log_info "Updating every 2 seconds (Ctrl+C to stop)"
    echo ""

    # Disable exit on error for watch mode
    set +e
    while true; do
        clear 2>/dev/null || printf '\033[2J\033[H'
        monitor_cache_stats
        sleep 2
    done
    # Re-enable if needed (but this line never reached due to infinite loop)
}

# ==============================================================================
# HEALTH FUNCTIONS (migrated from health.sh)
# ==============================================================================

# Check DNS health
monitor_health_dns_check() {
    test_dns_resolution "cloudflare.com"
}

# Show health status
monitor_health_status() {
    draw_section_header "󰓙 HEALTH STATUS"

    local all_healthy=1

    echo "=== SERVICES ==="
    for svc in "${HEALTH_CHECK_SERVICES[@]}"; do
        if test_service_active "$svc"; then
            printf "${GREEN}%-20s ACTIVE${NC}\n" "$svc"
        else
            printf "${RED}%-20s INACTIVE${NC}\n" "$svc"
            all_healthy=0
        fi
    done

    echo ""
    echo "=== DNS PROBE ==="
    if monitor_health_dns_check; then
        log_success "DNS resolution working (127.0.0.1)"
    else
        log_error "DNS resolution FAILED"
        all_healthy=0
    fi

    echo ""
    echo "=== FIREWALL ==="
    if test_nftables_citadel; then
        log_success "Citadel firewall rules loaded"
    else
        log_warning "Citadel firewall rules NOT loaded"
    fi

    echo ""
    if [[ $all_healthy -eq 1 ]]; then
        log_success "All health checks PASSED"
        return 0
    else
        log_error "Some health checks FAILED"
        return 1
    fi
}

# Install health watchdog
monitor_health_watchdog_install() {
    log_section "󰊠 INSTALLING HEALTH WATCHDOG"

    log_info "Creating health check script..."
    cat >/usr/local/bin/citadel-health-check <<'EOF'
#!/bin/bash
if dig +short +time=2 cloudflare.com @127.0.0.1 >/dev/null 2>&1; then
    exit 0
else
    systemctl restart coredns 2>/dev/null
    sleep 2
    if dig +short +time=2 cloudflare.com @127.0.0.1 >/dev/null 2>&1; then
        exit 0
    fi
    exit 1
fi
EOF
    chmod +x /usr/local/bin/citadel-health-check

    log_info "Creating systemd overrides..."
    mkdir -p /etc/systemd/system/dnscrypt-proxy.service.d
    cat >/etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf <<'EOF'
[Service]
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=5
EOF

    mkdir -p /etc/systemd/system/coredns.service.d
    cat >/etc/systemd/system/coredns.service.d/citadel-restart.conf <<'EOF'
[Service]
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=5
EOF

    log_info "Creating health check timer..."
    cat >/etc/systemd/system/citadel-health-check.service <<'EOF'
[Unit]
Description=Citadel DNS Health Check
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel-health-check
EOF

    cat >/etc/systemd/system/citadel-health-check.timer <<'EOF'
[Unit]
Description=Citadel DNS Health Check Timer

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now citadel-health-check.timer

    log_success "Health watchdog installed"
    log_info "Services will auto-restart on failure"
    log_info "Health checks run every 5 minutes"
}

# Uninstall health watchdog
monitor_health_watchdog_uninstall() {
    log_section "󰩹 UNINSTALLING HEALTH WATCHDOG"

    systemctl stop citadel-health-check.timer 2>/dev/null || true
    systemctl disable citadel-health-check.timer 2>/dev/null || true

    rm -f /etc/systemd/system/citadel-health-check.service
    rm -f /etc/systemd/system/citadel-health-check.timer
    rm -f /usr/local/bin/citadel-health-check
    rm -f /etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf
    rm -f /etc/systemd/system/coredns.service.d/citadel-restart.conf

    rmdir /etc/systemd/system/dnscrypt-proxy.service.d 2>/dev/null || true
    rmdir /etc/systemd/system/coredns.service.d 2>/dev/null || true

    systemctl daemon-reload

    log_success "Health watchdog uninstalled"
}

# ==============================================================================
# VERIFY CONFIG FUNCTIONS (migrated from verify-config.sh)
# ==============================================================================

# Verify configuration check
monitor_verify_config() {
    log_section "󰍉 ${T_VERIFY_CONFIG_TITLE:-CONFIGURATION VERIFICATION}"

    local errors=0
    local warnings=0

    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_warning "${T_VERIFY_NOT_ROOT:-Not running as root - some checks may fail}"
        ((warnings++))
    fi

    # Check CoreDNS configuration
    echo ""
    log_info "${T_VERIFY_COREDNS:-Checking CoreDNS configuration...}"
    if [[ -f /etc/coredns/Corefile ]]; then
        if coredns -conf /etc/coredns/Corefile -check 2>/dev/null; then
            log_success "  󰄬 ${T_VERIFY_COREDNS_OK:-CoreDNS configuration valid}"
        else
            log_error "  󰅖 ${T_VERIFY_COREDNS_ERROR:-CoreDNS configuration has errors}"
            ((errors++))
        fi
    else
        log_error "  󰅖 ${T_VERIFY_COREDNS_MISSING:-Corefile not found at /etc/coredns/Corefile}"
        ((errors++))
    fi

    # Check DNSCrypt configuration
    echo ""
    log_info "${T_VERIFY_DNSCRYPT:-Checking DNSCrypt configuration...}"
    if [[ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]; then
        if dnscrypt-proxy -check -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml 2>/dev/null; then
            log_success "  󰄬 ${T_VERIFY_DNSCRYPT_OK:-DNSCrypt configuration valid}"
        else
            log_error "  󰅖 ${T_VERIFY_DNSCRYPT_ERROR:-DNSCrypt configuration has errors}"
            ((errors++))
        fi
    else
        log_error "  󰅖 ${T_VERIFY_DNSCRYPT_MISSING:-DNSCrypt config not found}"
        ((errors++))
    fi

    # Check NFTables rules
    echo ""
    log_info "${T_VERIFY_NFT:-Checking NFTables configuration...}"
    if nft list table inet citadel_dns >/dev/null 2>&1; then
        log_success "  󰄬 ${T_VERIFY_NFT_OK:-Citadel NFTables table exists}"
    else
        log_error "  󰅖 ${T_VERIFY_NFT_MISSING:-Citadel NFTables table not found}"
        ((errors++))
    fi

    # Check services
    echo ""
    log_info "${T_VERIFY_SERVICES:-Checking services...}"
    for service in coredns dnscrypt-proxy; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            log_success "  󰄬 $service ${T_VERIFY_RUNNING:-is running}"
        else
            log_error "  󰅖 $service ${T_VERIFY_NOT_RUNNING:-is not running}"
            ((errors++))
        fi
    done

    # Check DNS resolution
    echo ""
    log_info "${T_VERIFY_DNS:-Testing DNS resolution...}"
    if dig +short +time=3 @127.0.0.1 google.com >/dev/null 2>&1; then
        log_success "  󰄬 ${T_VERIFY_DNS_OK:-Local DNS resolver working}"
    else
        log_error "  󰅖 ${T_VERIFY_DNS_ERROR:-Local DNS resolver not responding}"
        ((errors++))
    fi

    # Summary
    echo ""
    echo "=== ${T_VERIFY_SUMMARY:-VERIFICATION SUMMARY} ==="
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        log_success "${T_VERIFY_ALL_OK:-All checks passed! Citadel is properly configured.}"
        return 0
    else
        [[ $warnings -gt 0 ]] && log_warning "$warnings ${T_VERIFY_WARNINGS:-warnings}"
        [[ $errors -gt 0 ]] && log_error "$errors ${T_VERIFY_ERRORS:-errors found}"
        return 1
    fi
}

# Verify DNS functionality
monitor_verify_dns() {
    log_section "󰌐 ${T_VERIFY_DNS_TITLE:-DNS VERIFICATION TEST}"

    local test_domains=("google.com" "cloudflare.com" "github.com")
    local failed=0

    echo ""
    log_info "${T_VERIFY_DNS_TEST:-Testing DNS resolution through Citadel...}"

    for domain in "${test_domains[@]}"; do
        local result
        result=$(dig +short +time=5 @127.0.0.1 "$domain" 2>/dev/null | head -1)
        if [[ -n "$result" ]]; then
            log_success "  󰄬 $domain → $result"
        else
            log_error "  󰅖 $domain ${T_VERIFY_DNS_FAIL:-failed to resolve}"
            ((failed++))
        fi
    done

    # Check DNSSEC
    echo ""
    log_info "${T_VERIFY_DNSSEC:-Checking DNSSEC validation...}"
    if dig +dnssec +short @127.0.0.1 dnssec-failed.org 2>/dev/null | grep -q "SERVFAIL"; then
        log_success "  󰄬 ${T_VERIFY_DNSSEC_OK:-DNSSEC validation working}"
    else
        log_warning "  󰀨 ${T_VERIFY_DNSSEC_WARN:-DNSSEC validation may not be enforced}"
    fi

    if [[ $failed -eq 0 ]]; then
        echo ""
        log_success "${T_VERIFY_DNS_ALL_OK:-All DNS tests passed!}"
        return 0
    else
        echo ""
        log_error "$failed ${T_VERIFY_DNS_FAILED:-DNS tests failed}"
        return 1
    fi
}

# ==============================================================================
# DISCOVER FUNCTIONS (migrated from discover.sh)
# ==============================================================================

# Discover system information
monitor_discover() {
    log_section "󰍉 DISCOVER - Network & Firewall Snapshot"

    # Get network info from lib/network-utils.sh
    local iface
    iface=$(discover_active_interface)
    local stack
    stack=$(discover_network_stack)
    local nft_status
    nft_status=$(monitor_discover_nftables_status)

    echo "Active Interface: ${iface:-none detected}"
    echo "Network Stack: $stack"
    echo "NFTables: $nft_status"

    # IPv4 info
    if [[ -n "$iface" ]]; then
        local ipv4_addr
        ipv4_addr=$(ip -4 addr show dev "$iface" 2>/dev/null | awk '/inet / {print $2; exit}' || true)
        echo "IPv4 Address: ${ipv4_addr:-none}"

        # IPv6 info
        local ipv6_global
        ipv6_global=$(ip -6 addr show dev "$iface" scope global 2>/dev/null | grep -v temporary | awk '/inet6/ {print $2; exit}' || true)
        local ipv6_temp
        ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ {print $2; exit}' || true)
        echo "IPv6 Global: ${ipv6_global:-none}"
        echo "IPv6 Temporary: ${ipv6_temp:-none}"
    fi

    # DNS stack status
    echo ""
    echo "DNS Stack:"
    for svc in dnscrypt-proxy coredns; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "  $svc: active"
        else
            echo "  $svc: inactive"
        fi
    done
}

# Check NFTables status
monitor_discover_nftables_status() {
    if command -v nft &>/dev/null; then
        local tables
        tables=$(nft list tables 2>/dev/null | wc -l)
        if [[ $tables -gt 0 ]]; then
            echo "active ($tables tables)"
        else
            echo "installed (no tables)"
        fi
    else
        echo "not installed"
    fi
}

# ==============================================================================
# PROMETHEUS FUNCTIONS (migrated from prometheus.sh)
# ==============================================================================

# Collect Prometheus metrics
monitor_prometheus_collect() {
    log_section "󰄬 PROMETHEUS METRICS EXPORT"

    mkdir -p "$METRICS_DIR"

    local timestamp
    timestamp=$(date +%s)

    # Start metrics file
    cat > "$METRICS_FILE" << EOF
# Citadel DNS Infrastructure Metrics
# HELP citadel_info Citadel version information
# TYPE citadel_info gauge
citadel_info{version="${CYTADELA_VERSION}",mode="${CYTADELA_MODE}"} 1

# HELP citadel_timestamp Unix timestamp of metrics collection
# TYPE citadel_timestamp gauge
citadel_timestamp ${timestamp}
EOF

    # Collect service status metrics
    _collect_service_metrics >> "$METRICS_FILE"

    # Collect DNS performance metrics
    _collect_dns_metrics >> "$METRICS_FILE"

    # Collect blocklist metrics
    _collect_blocklist_metrics >> "$METRICS_FILE"

    # Collect system metrics
    _collect_system_metrics >> "$METRICS_FILE"

    log_success "Metrics exported to: $METRICS_FILE"
    log_info "Metrics available at: http://localhost:${METRICS_PORT}/metrics"
}

# Helper function for service metrics
_collect_service_metrics() {
    local services=("dnscrypt-proxy" "coredns")
    local service_status=1

    echo ""
    echo "# HELP citadel_service_up Service status (1=up, 0=down)"
    echo "# TYPE citadel_service_up gauge"

    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            service_status=1
        else
            service_status=0
        fi
        echo "citadel_service_up{service=\"${service}\"} ${service_status}"
    done

    # DNS resolution test
    echo ""
    echo "# HELP citadel_dns_resolution DNS resolution status (1=success, 0=fail)"
    echo "# TYPE citadel_dns_resolution gauge"
    if dig @127.0.0.1 -p 53 cloudflare.com +short +timeout=2 >/dev/null 2>&1; then
        echo "citadel_dns_resolution 1"
    else
        echo "citadel_dns_resolution 0"
    fi
}

# Helper function for DNS metrics
_collect_dns_metrics() {
    local metrics_url="$METRICS_URL"
    local core_metrics

    if core_metrics=$(curl -s "$metrics_url" 2>/dev/null); then
        # Cache metrics
        local cache_hits cache_misses
        cache_hits=$(echo "$core_metrics" | grep '^coredns_cache_hits_total' | awk '{sum+=$2} END {print sum+0}')
        cache_misses=$(echo "$core_metrics" | grep '^coredns_cache_misses_total' | awk '{sum+=$2} END {print sum+0}')

        echo ""
        echo "# HELP citadel_dns_cache_hits_total Total DNS cache hits"
        echo "# TYPE citadel_dns_cache_hits_total counter"
        echo "citadel_dns_cache_hits_total ${cache_hits}"

        echo ""
        echo "# HELP citadel_dns_cache_misses_total Total DNS cache misses"
        echo "# TYPE citadel_dns_cache_misses_total counter"
        echo "citadel_dns_cache_misses_total ${cache_misses}"

        # Request types
        local req_a req_aaaa req_ptr
        req_a=$(echo "$core_metrics" | grep 'coredns_dns_requests_total.*type="A"' | awk '{sum+=$2} END {print sum+0}')
        req_aaaa=$(echo "$core_metrics" | grep 'coredns_dns_requests_total.*type="AAAA"' | awk '{sum+=$2} END {print sum+0}')
        req_ptr=$(echo "$core_metrics" | grep 'coredns_dns_requests_total.*type="PTR"' | awk '{sum+=$2} END {print sum+0}')

        echo ""
        echo "# HELP citadel_dns_requests_total Total DNS requests by type"
        echo "# TYPE citadel_dns_requests_total counter"
        echo "citadel_dns_requests_total{type=\"A\"} ${req_a}"
        echo "citadel_dns_requests_total{type=\"AAAA\"} ${req_aaaa}"
        echo "citadel_dns_requests_total{type=\"PTR\"} ${req_ptr}"
    fi
}

# Helper function for blocklist metrics
_collect_blocklist_metrics() {
    local blocklist_file="/etc/coredns/zones/combined.hosts"
    local blocklist_entries=0

    if [[ -f "$blocklist_file" ]]; then
        blocklist_entries=$(wc -l < "$blocklist_file" 2>/dev/null || echo 0)
    fi

    echo ""
    echo "# HELP citadel_blocklist_entries Number of blocklist entries"
    echo "# TYPE citadel_blocklist_entries gauge"
    echo "citadel_blocklist_entries ${blocklist_entries}"

    # Last update time
    local last_update=0
    if [[ -f "$blocklist_file" ]]; then
        last_update=$(stat -c %Y "$blocklist_file" 2>/dev/null || echo 0)
    fi

    echo ""
    echo "# HELP citadel_blocklist_last_update Unix timestamp of last blocklist update"
    echo "# TYPE citadel_blocklist_last_update gauge"
    echo "citadel_blocklist_last_update ${last_update}"
}

# Helper function for system metrics
_collect_system_metrics() {
    # Firewall status
    echo ""
    echo "# HELP citadel_firewall_active Firewall status (1=active, 0=inactive)"
    echo "# TYPE citadel_firewall_active gauge"
    if nft list ruleset 2>/dev/null | grep -q "coredns"; then
        echo "citadel_firewall_active 1"
    else
        echo "citadel_firewall_active 0"
    fi

    # System load
    local load_avg
    load_avg=$(cut -d' ' -f1 /proc/loadavg 2>/dev/null || echo 0)

    echo ""
    echo "# HELP citadel_system_load_average System load average (1min)"
    echo "# TYPE citadel_system_load_average gauge"
    echo "citadel_system_load_average ${load_avg}"
}

# Export Prometheus metrics
monitor_prometheus_export() {
    monitor_prometheus_collect
}

# Start Prometheus metrics server
monitor_prometheus_serve() {
    monitor_prometheus_collect
    log_section "� PROMETHEUS METRICS SERVER"
    log_info "Starting metrics server on port ${METRICS_PORT}..."

    # Simple HTTP server using netcat
    while true; do
        {
            echo "HTTP/1.1 200 OK"
            echo "Content-Type: text/plain; charset=utf-8"
            echo "Connection: close"
            echo ""
            cat "$METRICS_FILE" 2>/dev/null || echo "# Metrics not available"
        } | nc -l -p "$METRICS_PORT" -q 1 2>/dev/null || {
            log_error "Failed to start metrics server (netcat required)"
            return 1
        }
    done &
}

# Show Prometheus status
monitor_prometheus_status() {
    log_section "󰄬 PROMETHEUS STATUS"

    if [[ -f "$METRICS_FILE" ]]; then
        local last_update
        last_update=$(stat -c %Y "$METRICS_FILE" 2>/dev/null || echo 0)
        local age=$(( $(date +%s) - last_update ))

        log_info "Metrics file: $METRICS_FILE"
        log_info "Last update: ${age}s ago"
        log_info "Metrics port: ${METRICS_PORT}"

        # Show sample metrics
        echo ""
        echo "Sample metrics:"
        head -20 "$METRICS_FILE"
    else
        log_error "Metrics file not found. Run: citadel.sh monitor prometheus-export"
        return 1
    fi
}

# ==============================================================================
# BENCHMARK FUNCTIONS (migrated from benchmark.sh)
# ==============================================================================

# Run DNS performance benchmark
monitor_benchmark_dns() {
    log_section "󱓞 DNS PERFORMANCE BENCHMARK"

    if ! _check_benchmark_tools; then
        log_info "Running basic benchmark without dnsperf..."
        _benchmark_basic
        return $?
    fi

    mkdir -p "$BENCHMARK_DIR"

    # Create test query file
    local query_file="${BENCHMARK_DIR}/queries.txt"
    cat > "$query_file" << EOF
cloudflare.com A
google.com A
github.com A
stackoverflow.com A
reddit.com A
EOF

    log_info "Running dnsperf benchmark..."
    log_info "Target: 127.0.0.1:53"
    log_info "Duration: 60 seconds"
    log_info "Clients: 200 concurrent"

    # Run dnsperf
    local benchmark_output
    benchmark_output=$(dnsperf -s 127.0.0.1 -p 53 -d "$query_file" \
        -c 200 -l 60 -Q 100000 2>&1) || true

    # Parse results
    local queries_sent queries_completed qps avg_latency
    queries_sent=$(echo "$benchmark_output" | grep "Queries sent:" | awk '{print $3}' || echo "0")
    queries_completed=$(echo "$benchmark_output" | grep "Queries completed:" | awk '{print $3}' || echo "0")
    qps=$(echo "$benchmark_output" | grep "Queries per second:" | awk '{print $4}' || echo "0")
    avg_latency=$(echo "$benchmark_output" | grep "Average Latency" | awk '{print $3}' || echo "N/A")

    # Save report
    cat > "$BENCHMARK_REPORT" << EOF
Citadel DNS Performance Benchmark
Generated: $(date)
================================

Configuration:
- Target: 127.0.0.1:53
- Duration: 60 seconds
- Concurrent clients: 200
- Max queries: 100000

Results:
- Queries sent: ${queries_sent:-N/A}
- Queries completed: ${queries_completed:-N/A}
- Queries per second: ${qps:-N/A}
- Average latency: ${avg_latency:-N/A}

Raw output:
${benchmark_output}
EOF

    # Save to history
    local timestamp
    timestamp=$(date +%s)
    echo "${timestamp},${queries_sent:-0},${queries_completed:-0},${qps:-0},${avg_latency:-0}" >> "$BENCHMARK_HISTORY"

    # Display results
    log_success "Benchmark completed!"
    echo ""
    echo "Results:"
    printf "  Queries sent:      %'d\n" "${queries_sent:-0}"
    printf "  Queries completed: %'d\n" "${queries_completed:-0}"
    printf "  QPS:               %'d\n" "${qps:-0}"
    printf "  Avg latency:       %s ms\n" "${avg_latency:-N/A}"

    log_info "Full report: $BENCHMARK_REPORT"
}

# Check benchmark tools
_check_benchmark_tools() {
    local missing=()

    if ! command -v dnsperf >/dev/null 2>&1; then
        missing+=("dnsperf")
    fi

    if ! command -v resperf >/dev/null 2>&1; then
        missing+=("resperf")
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_warning "Missing benchmark tools: ${missing[*]}"
        log_info "Install with: pacman -S dnsperf"
        return 1
    fi

    return 0
}

# Basic benchmark (fallback)
_benchmark_basic() {
    log_info "Running basic DNS benchmark..."

    local domains=("cloudflare.com" "google.com" "github.com" "stackoverflow.com" "reddit.com")
    local total_time=0
    local success_count=0
    local fail_count=0

    for domain in "${domains[@]}"; do
        local start_time end_time duration
        start_time=$(date +%s%N)
        dig @127.0.0.1 -p 53 "$domain" +short +timeout=5 >/dev/null 2>&1
        end_time=$(date +%s%N)
        duration=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + duration))
        ((success_count++))
        printf "  󰄬 %s: %d ms\n" "$domain" "$duration"
    done

    local avg_time=0
    if [[ $success_count -gt 0 ]]; then
        avg_time=$((total_time / success_count))
    fi

    echo ""
    log_success "Basic benchmark completed!"
    printf "  Success: %d/%d\n" "$success_count" "${#domains[@]}"
    printf "  Failed:  %d\n" "$fail_count"
    printf "  Avg latency: %d ms\n" "$avg_time"
}

# Run comprehensive benchmark suite
monitor_benchmark_all() {
    log_section "󰇄 COMPREHENSIVE BENCHMARK SUITE"

    mkdir -p "$BENCHMARK_DIR"

    local start_time
    start_time=$(date +%s)

    # Run all benchmarks
    monitor_benchmark_dns
    _benchmark_cache
    _benchmark_blocklist

    local end_time
    end_time=$(date +%s)
    local total_duration=$((end_time - start_time))

    echo ""
    log_success "All benchmarks completed in ${total_duration}s!"
    log_info "Reports saved to: $BENCHMARK_DIR"
}

# Show benchmark reports
monitor_benchmark_report() {
    log_section "󰄬 BENCHMARK REPORTS"

    if [[ -f "$BENCHMARK_REPORT" ]]; then
        echo "Latest benchmark report:"
        echo ""
        cat "$BENCHMARK_REPORT"
    else
        log_error "No benchmark report found"
        log_info "Run: citadel.sh monitor benchmark-dns"
        return 1
    fi

    if [[ -f "$BENCHMARK_HISTORY" ]]; then
        echo ""
        echo "Benchmark history (last 5 runs):"
        echo "Timestamp,Queries Sent,Queries Completed,QPS,Avg Latency"
        tail -5 "$BENCHMARK_HISTORY"
    fi
}

# Compare benchmark results
monitor_benchmark_compare() {
    log_section "󰓇 BENCHMARK COMPARISON"

    if [[ ! -f "$BENCHMARK_HISTORY" ]]; then
        log_error "No benchmark history found"
        return 1
    fi

    local line_count
    line_count=$(wc -l < "$BENCHMARK_HISTORY" 2>/dev/null || echo 0)

    if [[ $line_count -lt 2 ]]; then
        log_warning "Need at least 2 benchmarks for comparison"
        return 1
    fi

    echo "Comparing latest benchmark with previous:"
    echo ""

    # Get latest and previous results
    local latest previous
    latest=$(tail -1 "$BENCHMARK_HISTORY")
    previous=$(tail -2 "$BENCHMARK_HISTORY" | head -1)

    # Parse QPS values
    local latest_qps previous_qps
    latest_qps=$(echo "$latest" | cut -d',' -f4)
    previous_qps=$(echo "$previous" | cut -d',' -f4)

    if [[ -n "$latest_qps" && -n "$previous_qps" && "$previous_qps" -gt 0 ]]; then
        local qps_diff=$((latest_qps - previous_qps))
        local qps_percent=$(( (qps_diff * 100) / previous_qps ))

        printf "QPS change: %+d (%+d%%)\n" "$qps_diff" "$qps_percent"

        if [[ $qps_diff -gt 0 ]]; then
            log_success "Performance improved!"
        elif [[ $qps_diff -lt 0 ]]; then
            log_warning "Performance degraded"
        else
            log_info "Performance unchanged"
        fi
    fi
}

# Cache performance test
_benchmark_cache() {
    log_section "󰇉 CACHE PERFORMANCE TEST"

    log_info "Testing cache hit/miss ratio..."

    local test_domains=("example.com" "test.com" "demo.com")
    local cold_times=()
    local warm_times=()

    for domain in "${test_domains[@]}"; do
        # Cold query (cache miss expected)
        local cold_start cold_end cold_duration
        cold_start=$(date +%s%N)
        dig @127.0.0.1 -p 53 "$domain" +short +timeout=5 >/dev/null 2>&1
        cold_end=$(date +%s%N)
        cold_duration=$(( (cold_end - cold_start) / 1000000 ))
        cold_times+=("$cold_duration")

        # Warm query (cache hit expected)
        local warm_start warm_end warm_duration
        warm_start=$(date +%s%N)
        dig @127.0.0.1 -p 53 "$domain" +short +timeout=5 >/dev/null 2>&1
        warm_end=$(date +%s%N)
        warm_duration=$(( (warm_end - warm_start) / 1000000 ))
        warm_times+=("$warm_duration")
    done

    # Calculate averages
    local cold_avg=0 warm_avg=0
    for time in "${cold_times[@]}"; do
        cold_avg=$((cold_avg + time))
    done
    for time in "${warm_times[@]}"; do
        warm_avg=$((warm_avg + time))
    done

    cold_avg=$((cold_avg / ${#cold_times[@]}))
    warm_avg=$((warm_avg / ${#warm_times[@]}))

    echo ""
    log_success "Cache test completed!"
    printf "  Cold query (cache miss): %d ms avg\n" "$cold_avg"
    printf "  Warm query (cache hit):  %d ms avg\n" "$warm_avg"

    local improvement=0
    if [[ $cold_avg -gt 0 ]]; then
        improvement=$(( ((cold_avg - warm_avg) * 100) / cold_avg ))
    fi
    printf "  Cache improvement:       %d%%\n" "$improvement"
}

# Blocklist performance test
_benchmark_blocklist() {
    log_section "󰁑 BLOCKLIST PERFORMANCE"

    local blocklist_file="/etc/coredns/zones/combined.hosts"

    if [[ ! -f "$blocklist_file" ]]; then
        log_error "Blocklist file not found: $blocklist_file"
        return 1
    fi

    local entries
    entries=$(wc -l < "$blocklist_file" 2>/dev/null || echo 0)

    log_info "Blocklist entries: $entries"

    # Test blocked domain lookup speed
    local blocked_domains=("doubleclick.net" "googletagmanager.com" "facebook.com")
    local total_time=0

    for domain in "${blocked_domains[@]}"; do
        local start_time end_time duration
        start_time=$(date +%s%N)
        dig @127.0.0.1 -p 53 "$domain" +short +timeout=5 >/dev/null 2>&1
        end_time=$(date +%s%N)
        duration=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + duration))
    done

    local avg_time=0
    local domain_count=${#blocked_domains[@]}
    if [[ $domain_count -gt 0 ]]; then
        avg_time=$((total_time / domain_count))
    fi

    log_success "Blocklist benchmark completed!"
    printf "  Blocklist size:    %'d entries\n" "$entries"
    printf "  Block lookup time: %d ms avg\n" "$avg_time"
}

# ==============================================================================
# BENCHMARK FUNCTIONS (integrated from benchmark.sh)
# ==============================================================================

# Run DNS performance benchmark
monitor_benchmark_dns() {
    if declare -f benchmark_dns_performance >/dev/null 2>&1; then
        benchmark_dns_performance "$@"
    else
        log_error "Benchmark library not loaded - cannot run DNS benchmark"
        return 1
    fi
}

# Run cache performance test
monitor_benchmark_cache() {
    if declare -f _benchmark_cache >/dev/null 2>&1; then
        _benchmark_cache "$@"
    else
        log_error "Benchmark library not loaded - cannot run cache benchmark"
        return 1
    fi
}

# Run blocklist performance test
monitor_benchmark_blocklist() {
    if declare -f _benchmark_blocklist >/dev/null 2>&1; then
        _benchmark_blocklist "$@"
    else
        log_error "Benchmark library not loaded - cannot run blocklist benchmark"
        return 1
    fi
}

# Run comprehensive benchmark suite
monitor_benchmark_all() {
    if declare -f _benchmark_all >/dev/null 2>&1; then
        _benchmark_all "$@"
    else
        log_error "Benchmark library not loaded - cannot run comprehensive benchmark"
        return 1
    fi
}

# Show benchmark reports
monitor_benchmark_show_report() {
    if declare -f benchmark_show_report >/dev/null 2>&1; then
        benchmark_show_report "$@"
    else
        log_error "Benchmark library not loaded - cannot show benchmark report"
        return 1
    fi
}

# Compare benchmark results
monitor_benchmark_compare() {
    if declare -f benchmark_compare >/dev/null 2>&1; then
        benchmark_compare "$@"
    else
        log_error "Benchmark library not loaded - cannot compare benchmarks"
        return 1
    fi
}
