# Installation Modules

## Overview

Citadel uses separate installation modules for each component:
- `install-dnscrypt.sh` - DNS encryption
- `install-coredns.sh` - DNS server with adblock
- `install-nftables.sh` - Firewall rules

## Common Installation Flow

Each installer follows the same pattern:
1. Check prerequisites
2. Install package
3. Generate configuration
4. Enable and start service
5. Verify installation

## install-dnscrypt.sh

### Purpose
Installs and configures DNSCrypt-Proxy for encrypted DNS queries.

### Configuration
- **Port**: 127.0.0.1:5355
- **Protocols**: DoH, DoT, DNSCrypt
- **Servers**: cloudflare, google, quad9

### Generated Files
- `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`
- `/etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf`

## install-coredns.sh

### Purpose
Installs CoreDNS with caching and adblock capabilities.

### Configuration
- **Port**: 127.0.0.1:53
- **Features**: Cache, adblock, Prometheus metrics
- **Upstream**: 127.0.0.1:5355 (DNSCrypt)

### Generated Files
- `/etc/coredns/Corefile`
- `/etc/coredns/zones/blocklist.hosts`
- Blocklist download and processing

### Blocklist Sources
- StevenBlack hosts
- OISD blocklist
- Custom user lists

## install-nftables.sh

### Purpose
Configures NFTables firewall for DNS leak protection.

### Rules
- Allow localhost DNS (53, 5355)
- Block external DNS queries
- Enable counters for monitoring

### Generated Files
- `/etc/nftables.conf`
- Runtime rules in `inet citadel_dns` table

## Verification

Each installer runs post-install checks:
```bash
# Check service status
systemctl is-active [service]

# Test DNS resolution
dig +short google.com @127.0.0.1

# Verify firewall
nft list table inet citadel_dns
```

## Rollback

All installers create backups before changes:
```bash
# Backup location
/etc/cytadela/backups/

# Restore
sudo ./citadel.sh restore-system
```
