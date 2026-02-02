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

### Known Issues to Document
- Port conflicts (9100 occupied)
- "expected a valid start token" error
- Connection refused errors
- Docker vs native installation

### Quick Start Options
1. Docker Compose (easiest)
2. Native pacman install
3. Manual Python HTTP server (fallback)

Status: To be completed in future session
