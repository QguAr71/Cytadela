#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ PERFORMANCE BENCHMARKS v3.1                                    ║
# ║  DNS performance testing and benchmarking suite                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

BENCHMARK_DIR="/var/lib/cytadela/benchmarks"
BENCHMARK_REPORT="${BENCHMARK_DIR}/latest.txt"
BENCHMARK_HISTORY="${BENCHMARK_DIR}/history.csv"

# ==============================================================================
# BENCHMARK TOOLS CHECK
# ==============================================================================

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

# ==============================================================================
# DNS PERFORMANCE BENCHMARK
# ==============================================================================

benchmark_dns_performance() {
    log_section "🚀 DNS PERFORMANCE BENCHMARK"

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
    queries_sent=$(echo "$benchmark_output" | grep "Queries sent:" | awk '{print $3}')
    queries_completed=$(echo "$benchmark_output" | grep "Queries completed:" | awk '{print $3}')
    qps=$(echo "$benchmark_output" | grep "Queries per second:" | awk '{print $4}')
    avg_latency=$(echo "$benchmark_output" | grep "Average Latency" | awk '{print $3}')

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

_benchmark_basic() {
    log_info "Running basic DNS benchmark..."

    local domains=("cloudflare.com" "google.com" "github.com" "stackoverflow.com" "reddit.com")
    local total_time=0
    local success_count=0
    local fail_count=0

    for domain in "${domains[@]}"; do
        local start_time end_time duration
        start_time=$(date +%s%N)

        if dig @127.0.0.1 -p 53 "$domain" +short +timeout=5 >/dev/null 2>&1; then
            end_time=$(date +%s%N)
            duration=$(( (end_time - start_time) / 1000000 ))  # Convert to ms
            total_time=$((total_time + duration))
            ((success_count++))
            printf "  ✓ %s: %d ms\n" "$domain" "$duration"
        else
            ((fail_count++))
            printf "  ✗ %s: FAILED\n" "$domain"
        fi
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

# ==============================================================================
# CACHE PERFORMANCE TEST
# ==============================================================================

benchmark_cache() {
    log_section "💾 CACHE PERFORMANCE TEST"

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

# ==============================================================================
# BLOCKLIST PERFORMANCE
# ==============================================================================

benchmark_blocklist() {
    log_section "🚫 BLOCKLIST PERFORMANCE"

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

    local avg_time=$((total_time / ${#blocked_domains[@]}))

    log_success "Blocklist benchmark completed!"
    printf "  Blocklist size:    %'d entries\n" "$entries"
    printf "  Block lookup time: %d ms avg\n" "$avg_time"
}

# ==============================================================================
# COMPREHENSIVE BENCHMARK
# ==============================================================================

benchmark_all() {
    log_section "🎯 COMPREHENSIVE BENCHMARK SUITE"

    mkdir -p "$BENCHMARK_DIR"

    local start_time
    start_time=$(date +%s)

    # Run all benchmarks
    benchmark_dns_performance
    benchmark_cache
    benchmark_blocklist

    local end_time
    end_time=$(date +%s)
    local total_duration=$((end_time - start_time))

    echo ""
    log_success "All benchmarks completed in ${total_duration}s!"
    log_info "Reports saved to: $BENCHMARK_DIR"
}

# ==============================================================================
# BENCHMARK REPORTS
# ==============================================================================

benchmark_show_report() {
    log_section "📊 BENCHMARK REPORTS"

    if [[ -f "$BENCHMARK_REPORT" ]]; then
        echo "Latest benchmark report:"
        echo ""
        cat "$BENCHMARK_REPORT"
    else
        log_error "No benchmark report found"
        log_info "Run: citadel.sh benchmark-dns"
        return 1
    fi

    if [[ -f "$BENCHMARK_HISTORY" ]]; then
        echo ""
        echo "Benchmark history (last 5 runs):"
        echo "Timestamp,Queries Sent,Queries Completed,QPS,Avg Latency"
        tail -5 "$BENCHMARK_HISTORY"
    fi
}

benchmark_compare() {
    log_section "📈 BENCHMARK COMPARISON"

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
