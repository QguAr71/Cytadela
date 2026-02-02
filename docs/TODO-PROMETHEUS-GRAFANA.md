# Prometheus + Grafana Integration TODO

## Overview

This document tracks the implementation of Prometheus metrics and Grafana dashboard for Citadel.

## Current Status

✅ **CoreDNS Prometheus endpoint** - `http://127.0.0.1:9153/metrics`
✅ **Basic metrics collection** - Cache hits, response times, query counts
✅ **Dashboard preview** - Terminal-based `citadel-top`

## Prometheus Metrics Available

### CoreDNS Metrics (Port 9153)

| Metric | Description |
|--------|-------------|
| `coredns_build_info` | CoreDNS version info |
| `coredns_cache_entries` | Number of entries in cache |
| `coredns_cache_hits_total` | Total cache hits |
| `coredns_cache_misses_total` | Total cache misses |
| `coredns_dns_request_count_total` | Total DNS requests |
| `coredns_dns_request_duration_seconds` | Request latency histogram |

### Custom Citadel Metrics (Planned)

| Metric | Description | Status |
|--------|-------------|--------|
| `cytadela_blocked_queries_total` | Blocked by adblock | 🔄 TODO |
| `cytadela_upstream_latency_ms` | DNSCrypt latency | 🔄 TODO |
| `cytadela_firewall_blocks_total` | Blocked by firewall | 🔄 TODO |
| `cytadela_active_connections` | Active DNS connections | 🔄 TODO |

## Grafana Dashboard

### Existing
- `docs/grafana-dashboard.json` - Basic dashboard template

### Planned Widgets
- [ ] DNS Query Rate (QPS)
- [ ] Cache Hit Ratio
- [ ] Blocked Queries %
- [ ] Upstream Latency
- [ ] Top Blocked Domains
- [ ] Geographic Query Map

## Implementation Steps

### Phase 1: Prometheus Server
```bash
# Install Prometheus
sudo pacman -S prometheus

# Configure scraping
cat > /etc/prometheus/prometheus.yml << 'EOF'
scrape_configs:
  - job_name: 'coredns'
    static_configs:
      - targets: ['localhost:9153']
EOF

# Enable service
sudo systemctl enable --now prometheus
```

### Phase 2: Grafana
```bash
# Install Grafana
sudo pacman -S grafana

# Import dashboard
sudo cp docs/grafana-dashboard.json /var/lib/grafana/dashboards/

# Enable service
sudo systemctl enable --now grafana
```

### Phase 3: Custom Exporter (Optional)
Create custom exporter for Citadel-specific metrics beyond CoreDNS.

## Access

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)
- **CoreDNS Metrics**: http://localhost:9153/metrics

## Commands

```bash
# View metrics manually
curl -s http://127.0.0.1:9153/metrics | grep "coredns_"

# Check Prometheus targets
sudo ./citadel.sh prometheus-status

# View in terminal
curl -s http://127.0.0.1:9153/metrics | grep "^coredns_" | head -10
```

## Resources

- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [CoreDNS Metrics](https://coredns.io/plugins/metrics/)
