# Docker Deployment Guide

Quick Docker deployment for Citadel DNS Infrastructure.

## 🚀 Quick Start

### Using Docker Run
```bash
# Build image
docker build -t citadel-dns:latest .

# Run with host networking (recommended for DNS)
docker run -d \
  --name citadel-dns \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -v citadel-config:/etc/cytadela \
  -v citadel-data:/var/lib/cytadela \
  citadel-dns:latest install-all
```

### Using Docker Compose
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📁 Volumes

- `/etc/cytadela` - Configuration files
- `/var/lib/cytadela` - Runtime data and cache

## 🔌 Ports

- `53/tcp` - DNS
- `53/udp` - DNS
- `853/tcp` - DNS-over-TLS
- `9153/tcp` - CoreDNS metrics
- `9100/tcp` - Citadel metrics (optional)

## 🐳 Docker Compose Profiles

### Basic DNS
```bash
docker-compose up -d citadel
```

### With Monitoring
```bash
docker-compose --profile monitoring up -d
```

Access Grafana at http://localhost:3000 (admin/admin)

## 🔧 Commands

```bash
# Enter container
docker-compose exec citadel bash

# Run Citadel commands
docker-compose exec citadel citadel status
docker-compose exec citadel citadel diagnostics

# View metrics
docker-compose exec citadel cat /var/lib/cytadela/metrics/citadel.prom
```

## 🏥 Health Check

Container includes automatic health check:
```bash
docker ps  # Check status
docker inspect --format='{{.State.Health.Status}}' citadel-dns
```

## 📝 Notes

- Host networking recommended for DNS performance
- NET_ADMIN required for nftables firewall rules
- Persistent volumes for configuration retention
