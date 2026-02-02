# 📦 Deployment Examples

This guide provides real-world deployment scenarios for Citadel.

---

## 📋 Table of Contents

1. [Home User Setup](#-home-user-setup)
2. [Small Office Setup](#️-small-office-setup)
3. [Gateway Mode Setup](#-gateway-mode-setup)
4. [Raspberry Pi Setup](#-raspberry-pi-setup)
5. [Multi-Device Setup](#️-multi-device-setup)

---

## 🏠 Home User Setup

**Scenario:** Single user, personal laptop/desktop, basic privacy needs.

### Requirements

- 1 Linux machine (Arch/CachyOS)
- 2 GB RAM minimum
- Active internet connection

### Installation

```bash
# 1. Clone repository
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# 2. Run interactive installer
sudo ./citadel.sh install-wizard

# 3. Select components (recommended):
#    [x] DNSCrypt-Proxy
#    [x] CoreDNS
#    [x] NFTables
#    [x] Ad blocking (balanced profile)
#    [ ] Terminal Dashboard (optional)

# 4. Configure system
sudo ./citadel.sh configure-system

# 5. Enable firewall
sudo ./citadel.sh firewall-safe

# 6. Verify installation
sudo ./citadel.sh verify
```

### Configuration

```bash
# Enable auto-updates
sudo ./citadel.sh auto-update-enable

# Configure backup
sudo ./citadel.sh config-backup

# Enable IPv6 privacy
sudo ./citadel.sh ipv6-privacy-auto
```

### Daily Usage

```bash
# Check status
sudo ./citadel.sh status

# View statistics
sudo ./citadel.sh cache-stats
sudo ./citadel.sh adblock-stats

# Update blocklists
sudo ./citadel.sh adblock-update
```

### Maintenance

```bash
# Weekly: Check for updates
sudo ./citadel.sh auto-update-status

# Monthly: Backup configuration
sudo ./citadel.sh config-backup

# As needed: View logs
sudo ./citadel.sh logs
```

---

## 👨‍💼 Small Office Setup

**Scenario:** 5-10 users, shared network, business privacy needs.

### Requirements

- 1 Linux server (dedicated or VM)
- 4 GB RAM minimum
- Static IP address
- Network access for all clients

### Installation

```bash
# 1. Clone repository
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# 2. Install all components
sudo ./citadel.sh install-all

# 3. Configure for network use
sudo ./citadel.sh configure-system

# 4. Enable strict firewall
sudo ./citadel.sh firewall-strict

# 5. Install monitoring
sudo ./citadel.sh install-dashboard
```

### Network Configuration

```bash
# 1. Set static IP (example: 192.168.1.10)
sudo nano /etc/systemd/network/20-wired.network

# Add:
[Match]
Name=eth0

[Network]
Address=192.168.1.10/24
Gateway=192.168.1.1
DNS=127.0.0.1

# 2. Allow DNS from network
sudo nano /etc/coredns/Corefile

# Change:
.:53 {
    bind 192.168.1.10  # Listen on network interface
    forward . 127.0.0.1:5300
    cache 3600
    prometheus :9153
}

# 3. Configure firewall for network
sudo nano /etc/nftables.conf

# Add:
table inet citadel {
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Allow DNS from local network
        ip saddr 192.168.1.0/24 tcp dport 53 accept
        ip saddr 192.168.1.0/24 udp dport 53 accept
        
        # Allow established connections
        ct state established,related accept
    }
}

# 4. Restart services
sudo systemctl restart coredns nftables
```

### Client Configuration

**On each client machine:**

```bash
# Method 1: NetworkManager
sudo nmcli connection modify "Wired connection 1" ipv4.dns "192.168.1.10"
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"

# Method 2: Manual
sudo nano /etc/resolv.conf
# Add:
nameserver 192.168.1.10

# Method 3: DHCP (on router)
# Set DNS server to 192.168.1.10
```

### Monitoring

```bash
# View real-time stats
citadel-top

# Check cache performance
sudo ./citadel.sh cache-stats

# Monitor queries
sudo journalctl -u coredns -f

# View blocked domains
sudo ./citadel.sh adblock-stats
```

---

## 🌐 Gateway Mode Setup

**Scenario:** Citadel as network gateway, protecting entire home/office network.

**Note:** Gateway mode is planned for v3.2 (Q1 2026). This is a preview.

### Requirements

- 1 Linux machine with 2 network interfaces
- 4 GB RAM minimum
- WAN connection (to internet)
- LAN connection (to local network)

### Installation

```bash
# 1. Install Citadel
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./citadel.sh install-all

# 2. Run gateway wizard (v3.2+)
sudo ./citadel.sh gateway-wizard

# This will:
# - Configure network interfaces (WAN/LAN)
# - Set up DHCP server
# - Configure NAT/routing
# - Enable DNS forwarding
# - Configure firewall
```

### Manual Configuration (v3.1)

```bash
# 1. Configure interfaces
sudo nano /etc/systemd/network/10-wan.network
[Match]
Name=eth0

[Network]
DHCP=yes

sudo nano /etc/systemd/network/20-lan.network
[Match]
Name=eth1

[Network]
Address=192.168.100.1/24
DHCPServer=yes

# 2. Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

# 3. Configure NAT
sudo nano /etc/nftables.conf
table inet citadel_gateway {
    chain postrouting {
        type nat hook postrouting priority 100;
        oifname "eth0" masquerade
    }
}

# 4. Configure DNS forwarding
sudo nano /etc/coredns/Corefile
.:53 {
    bind 192.168.100.1
    forward . 127.0.0.1:5300
    cache 3600
}

# 5. Restart services
sudo systemctl restart systemd-networkd coredns nftables
```

### Client Configuration

Clients will automatically receive:
- IP address via DHCP (192.168.100.x)
- DNS server (192.168.100.1)
- Gateway (192.168.100.1)

No manual configuration needed!

---

## 🍓 Raspberry Pi Setup

**Scenario:** Low-power DNS server for home network.

### Requirements

- Raspberry Pi 3/4/5
- 2 GB RAM minimum
- SD card (16 GB+)
- Arch Linux ARM or Raspbian

### Installation

```bash
# 1. Update system
sudo pacman -Syu  # Arch ARM
# OR
sudo apt update && sudo apt upgrade  # Raspbian

# 2. Install dependencies
sudo pacman -S dnscrypt-proxy coredns nftables  # Arch ARM
# OR
# Manual installation for Raspbian (see docs)

# 3. Clone Citadel
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela

# 4. Install (CLI mode recommended)
sudo ./citadel.sh install-all

# 5. Configure
sudo ./citadel.sh configure-system
sudo ./citadel.sh firewall-safe
```

### Optimization for Pi

```bash
# 1. Reduce cache size (save RAM)
sudo nano /etc/coredns/Corefile
# Change cache from 3600 to 1800

# 2. Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable cups

# 3. Enable swap (if needed)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 4. Monitor resources
htop
sudo ./citadel.sh cache-stats
```

### Performance Tips

- Use wired Ethernet (not WiFi)
- Use fast SD card (Class 10+)
- Keep system updated
- Monitor temperature (keep < 80°C)

---

## 🖥️ Multi-Device Setup

**Scenario:** Multiple devices using Citadel DNS server.

### Architecture

```
Internet
    ↓
Router (192.168.1.1)
    ↓
Citadel Server (192.168.1.10)
    ↓
├── Laptop (192.168.1.20)
├── Desktop (192.168.1.21)
├── Phone (192.168.1.22)
└── Tablet (192.168.1.23)
```

### Server Setup

```bash
# 1. Install Citadel on server
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./citadel.sh install-all

# 2. Configure for network
sudo nano /etc/coredns/Corefile
.:53 {
    bind 192.168.1.10
    forward . 127.0.0.1:5300
    cache 3600
}

# 3. Allow network access
sudo nano /etc/nftables.conf
# Add rules to allow DNS from 192.168.1.0/24

# 4. Restart services
sudo systemctl restart coredns nftables
```

### Client Setup

**Linux:**
```bash
sudo nmcli connection modify "Wired connection 1" ipv4.dns "192.168.1.10"
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"
```

**Windows:**
```
Control Panel → Network → Change adapter settings
→ Right-click connection → Properties
→ IPv4 → Properties
→ Use the following DNS server: 192.168.1.10
```

**macOS:**
```
System Preferences → Network
→ Select connection → Advanced
→ DNS → Add 192.168.1.10
```

**Android:**
```
Settings → WiFi → Long press network
→ Modify network → Advanced options
→ IP settings: Static
→ DNS 1: 192.168.1.10
```

**iOS:**
```
Settings → WiFi → (i) next to network
→ Configure DNS → Manual
→ Add Server: 192.168.1.10
```

---

## 🔧 Troubleshooting

### Common Issues

**DNS not resolving:**
```bash
# Check server status
sudo ./citadel.sh status

# Test DNS locally
dig +short google.com @192.168.1.10

# Check firewall
sudo nft list ruleset | grep 53
```

**Slow performance:**
```bash
# Check cache stats
sudo ./citadel.sh cache-stats

# Increase cache size
sudo nano /etc/coredns/Corefile
# Change cache to 7200

# Restart CoreDNS
sudo systemctl restart coredns
```

**Clients can't connect:**
```bash
# Check firewall rules
sudo nft list ruleset

# Test connectivity
ping 192.168.1.10  # From client

# Check logs
sudo journalctl -u coredns -f
```

---

## 📚 Additional Resources

- [Full Manual (PL)](MANUAL_PL.md)
- [Full Manual (EN)](MANUAL_EN.md)
- [Quick Start Guide](quick-start.md)
- [FAQ](FAQ.md)
- [Commands Reference](commands.md)

---

**Last updated:** 2026-01-31  
**Version:** 3.1.1
