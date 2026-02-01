#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ PROMETHEUS METRICS EXPORT v3.1                                 ║
# ║  Export Citadel metrics for Prometheus monitoring                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

METRICS_DIR="/var/lib/cytadela/metrics"
METRICS_FILE="${METRICS_DIR}/citadel.prom"
METRICS_PORT="${CITADEL_METRICS_PORT:-9100}"

# ==============================================================================
# METRICS COLLECTION
# ==============================================================================

prometheus_collect() {
    log_section "📊 PROMETHEUS METRICS EXPORT"

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

_collect_dns_metrics() {
    local metrics_url="http://${COREDNS_METRICS_ADDR:-127.0.0.1:9153}/metrics"
    local core_metrics

    if core_metrics=$(curl -s "$metrics_url" 2>/dev/null); then
        # Parse cache hits/misses
        local cache_hits cache_misses
        cache_hits=$(echo "$core_metrics" | grep '^coredns_cache_hits_total' 2>/dev/null | awk '{sum+=$2} END {print sum+0}' || echo 0)
        cache_misses=$(echo "$core_metrics" | grep '^coredns_cache_misses_total' 2>/dev/null | awk '{sum+=$2} END {print sum+0}' || echo 0)

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
        req_a=$(echo "$core_metrics" | grep 'coredns_dns_requests_total.*type="A"' 2>/dev/null | awk '{sum+=$2} END {print sum+0}' || echo 0)
        req_aaaa=$(echo "$core_metrics" | grep 'coredns_dns_requests_total.*type="AAAA"' 2>/dev/null | awk '{sum+=$2} END {print sum+0}' || echo 0)
        req_ptr=$(echo "$core_metrics" | grep 'coredns_dns_requests_total.*type="PTR"' 2>/dev/null | awk '{sum+=$2} END {print sum+0}' || echo 0)

        echo ""
        echo "# HELP citadel_dns_requests_total Total DNS requests by type"
        echo "# TYPE citadel_dns_requests_total counter"
        echo "citadel_dns_requests_total{type=\"A\"} ${req_a}"
        echo "citadel_dns_requests_total{type=\"AAAA\"} ${req_aaaa}"
        echo "citadel_dns_requests_total{type=\"PTR\"} ${req_ptr}"
    fi
}

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

# ==============================================================================
# METRICS SERVER (Optional - requires busybox/netcat)
# ==============================================================================

prometheus_serve() {
    log_section "🌐 PROMETHEUS METRICS SERVER"
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

    log_success "Metrics server started on port ${METRICS_PORT}"
    log_info "Access: http://localhost:${METRICS_PORT}/metrics"
}

# ==============================================================================
# METRICS COMMANDS
# ==============================================================================

prometheus_export() {
    prometheus_collect
}

prometheus_serve_start() {
    prometheus_export
    prometheus_serve
}

prometheus_status() {
    log_section "📊 PROMETHEUS STATUS"

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
        log_error "Metrics file not found. Run: citadel.sh prometheus-export"
        return 1
    fi
}
