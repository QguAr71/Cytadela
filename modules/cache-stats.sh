#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ CACHE-STATS MODULE v3.1                                       ║
# ║  DNS cache statistics from CoreDNS Prometheus metrics (Issue #15)         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

METRICS_URL="http://${COREDNS_METRICS_ADDR:-127.0.0.1:9153}/metrics"

# shellcheck disable=SC2120
cache_stats() {
    log_section "󰄬 DNS CACHE STATISTICS"

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
    local cache_hits
    cache_hits=$(echo "$metrics" | grep '^coredns_cache_hits_total' | awk '{sum+=$2} END {print sum+0}')
    local cache_misses
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

cache_stats_top() {
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

cache_stats_reset() {
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

cache_stats_watch() {
    log_section "󰄮 WATCH CACHE STATS (live)"

    log_info "Updating every 2 seconds (Ctrl+C to stop)"
    echo ""

    # Disable exit on error for watch mode
    set +e
    while true; do
        clear 2>/dev/null || printf '\033[2J\033[H'
        cache_stats
        sleep 2
    done
    # Re-enable if needed (but this line never reached due to infinite loop)
}
