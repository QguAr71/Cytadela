# TODO: Prometheus/Grafana Setup Manual

## Priority: High

Need to create comprehensive manual for:

### Prometheus Setup
- Installation (pacman/yay)
- Configuration file (prometheus.yml)
- Service management (systemd)
- Target configuration for Citadel
- Troubleshooting common issues

### Grafana Setup  
- Installation options (pacman/Docker)
- Data source configuration
- Dashboard import process
- User authentication setup
- Troubleshooting connection issues

### Citadel Integration
- prometheus-export command
- prometheus-serve-start command
- Metrics file location
- Port configuration (9100)
- Required dependencies (netcat)

### Required Dependencies to Document

**For Prometheus Metrics Server:**
- `openbsd-netcat` (nc) - for HTTP server on port 9100
- `python3` - fallback HTTP server option

**For Benchmarks:**
- `dnsperf` - performance testing (dnsperf package)
- Alternative: `bind-tools` (for dig command)

**For Grafana:**
- `grafana` (AUR or pacman) OR Docker
- `prometheus` - metrics collection and storage

**Optional:**
- `curl` - testing endpoints
- `lsof` or `ss` - checking port usage

### Quick Start Options
1. Docker Compose (easiest)
2. Native pacman install
3. Manual Python HTTP server (fallback)

Status: To be completed in future session
