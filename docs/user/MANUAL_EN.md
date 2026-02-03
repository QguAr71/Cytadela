# 🛡️ CITADEL - COMPLETE USER MANUAL

**Version:** 3.1.1  
**Date:** 2026-02-02  
**Language:** English

---

## 📑 TABLE OF CONTENTS

1. [Introduction](#-introduction)
2. [System Requirements](#-system-requirements)
3. [Installation](#-installation)
4. [Configuration](#️-configuration)
5. [Basic Usage](#-basic-usage)
6. [Advanced Features](#-advanced-features)
7. [Ad Blocking](#-ad-blocking)
8. [Security](#-security)
9. [Monitoring](#-monitoring)
10. [Emergency Mode](#-emergency-mode)
11. [Troubleshooting](#-troubleshooting)
12. [Usage Examples](#-usage-examples)
13. [FAQ](#-faq-frequently-asked-questions)

---

## 🎯 INTRODUCTION

### Interactive Help System

Citadel++ includes an interactive help system:

```bash
sudo cytadela.sh help
```

This menu provides:
- **5 organized sections**: Installation, Main Program, Add-ons, Advanced, Emergency
- **70+ commands** with descriptions
- **7 language support**: Automatically uses your system language
- **Easy navigation**: Select section by number

---

### What is Citadel?

Citadel is an advanced DNS system with a complete privacy stack, designed for home users and small businesses. It combines:

- **DNSCrypt-Proxy** - encrypted DNS queries (DoH/DoT)
- **CoreDNS** - high-performance resolver with cache
- **NFTables** - firewall protecting against DNS leaks
- **Ad Blocking** - 325,000+ blocked domains
- **Monitoring** - real-time Prometheus metrics

### Why Citadel?

✅ **Privacy** - all DNS queries are encrypted  
✅ **Security** - protection against tracking and malware  
✅ **Performance** - intelligent caching  
✅ **Simplicity** - installation in 5 minutes (graphical wizard)  
✅ **Modularity** - 32 independent modules  
✅ **Multilingual** - 7 languages (PL, EN, DE, ES, IT, FR, RU)  
✅ **Open Source** - full code transparency

### 🌍 Support for 7 Languages

Citadel has full support for **7 languages**:

| Language | Code | Status |
|----------|------|--------|
| 🇵🇱 Polish | `pl` | ✅ Full translation |
| 🇬🇧 English | `en` | ✅ Full translation |
| 🇩🇪 German | `de` | ✅ Full translation |
| 🇪🇸 Spanish | `es` | ✅ Full translation |
| 🇮🇹 Italian | `it` | ✅ Full translation |
| 🇫🇷 French | `fr` | ✅ Full translation |
| 🇷🇺 Russian | `ru` | ✅ Full translation |

**What's translated:**
- ✅ Graphical installation wizard (install-wizard)
- ✅ All system messages
- ✅ Modules (adblock, diagnostics, help)
- ✅ Logs and error reports

**Automatic language detection:**
```bash
# System automatically detects language from $LANG
sudo ./citadel.sh install-wizard
```

**Force language:**
```bash
sudo ./citadel.sh install-wizard pl  # Polish
sudo ./citadel.sh install-wizard en  # English
sudo ./citadel.sh install-wizard de  # German
```

### 🖥️ Graphical Installation Wizard

Citadel has an **interactive graphical wizard** (whiptail/dialog) that guides you through the entire installation:

**Wizard features:**
- ✅ Graphical menu in terminal
- ✅ Checklists for component selection
- ✅ Automatic language detection
- ✅ Step by step (7 stages)
- ✅ Verification at the end

**Example appearance:**
```
┌─────────────────────────────────────────────────────┐
│    CITADEL INSTALLATION WIZARD v3.1                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Select components to install:                     │
│                                                     │
│  [X] DNSCrypt-Proxy (DNS encryption)               │
│  [X] CoreDNS (DNS server)                          │
│  [X] NFTables (firewall)                           │
│  [X] Ad blocking                                   │
│  [ ] Terminal Dashboard (optional)                 │
│  [ ] Health Watchdog (optional)                    │
│                                                     │
│         <OK>              <Cancel>                  │
└─────────────────────────────────────────────────────┘
```

### 🏗️ System Architecture

**How Citadel works:**

```
┌─────────────┐
│ Application │  Your browser, apps, etc.
└──────┬──────┘
       │ DNS query (example.com?)
       ▼
┌─────────────────────────────────┐
│ CoreDNS (127.0.0.1:53)         │  Local DNS resolver
│ ├─ Cache (85-90% hit rate)    │  Fast responses
│ ├─ Adblock (325k+ domains)    │  Blocks ads/trackers
│ └─ Metrics (Prometheus)        │  Monitoring
└──────┬──────────────────────────┘
       │ Cache miss? Forward to...
       ▼
┌─────────────────────────────────┐
│ DNSCrypt-Proxy                 │  Encryption layer
│ └─ Encrypted (DoH/DoT)         │  ISP can't see queries
└──────┬──────────────────────────┘
       │ Encrypted DNS query
       ▼
   🌐 Internet (Privacy protected)

┌─────────────────────────────────┐
│ NFTables (Kernel level)        │  Leak prevention
│ └─ Blocks external :53 ✗       │  Apps can't bypass
│    (applies to all outbound    │  System-wide enforcement
│     traffic)                   │
└─────────────────────────────────┘
```

**Why it's better:**
- ✅ **Privacy:** ISP can't see your DNS queries (encrypted)
- ✅ **Security:** Apps can't bypass DNS (kernel-level enforcement)
- ✅ **Speed:** Local cache = faster browsing (85-90% hit rate)
- ✅ **Clean:** Blocks ads/trackers at DNS level (325k+ domains)
- ✅ **Control:** Everything runs locally, no cloud dependencies

---

## 💻 SYSTEM REQUIREMENTS

### Minimum requirements:

- **Operating System:** Arch Linux, CachyOS (other distros: manual adaptation)
- **RAM:** 512 MB minimum, 1 GB recommended
- **Disk:** 100 MB for installation
- **Network:** Active internet connection
- **Privileges:** Root access (sudo)

### Recommended:

- **CPU:** 2 cores or more
- **RAM:** 2 GB or more
- **Disk:** SSD for better performance

### Checking requirements:

```bash
# Check system version
cat /etc/os-release

# Check RAM
free -h

# Check disk space
df -h

# Check internet connection
ping -c 3 1.1.1.1
```

---

## 🚀 INSTALLATION

### Step 1: Download repository

```bash
# Clone repository
git clone https://github.com/QguAr71/Cytadela.git
cd Citadel

# Check version
cat VERSION
```

### Step 2: Check dependencies

```bash
# Check missing dependencies
sudo ./citadel.sh check-deps

# Or install automatically
sudo ./citadel.sh check-deps --install
```

**Required packages:**
- `dnscrypt-proxy` - DNS encryption
- `coredns` - DNS server
- `nftables` - firewall
- `curl` - downloading blocklists
- `jq` - JSON parsing
- `dig` - DNS tests

### Step 3: Installation

**Citadel offers TWO INSTALLATION MODES:**

#### Option A: Graphical wizard (RECOMMENDED for beginners)

```bash
# Run interactive installation wizard
sudo ./citadel.sh install-wizard
```

**The wizard will guide you through:**

1. ✅ Checking dependencies
2. ✅ Selecting components to install
3. ✅ DNSCrypt-Proxy configuration
4. ✅ CoreDNS configuration
5. ✅ Firewall configuration
6. ✅ System configuration
7. ✅ Installation verification

**Example flow:**

```
╔═══════════════════════════════════════════════════════════════╗
║              CITADEL INSTALLATION WIZARD                      ║
╚═══════════════════════════════════════════════════════════════╝

[1/7] Checking dependencies...
✓ dnscrypt-proxy: installed
✓ coredns: installed
✓ nftables: installed

[2/7] Select components:
  [x] DNSCrypt-Proxy
  [x] CoreDNS
  [x] NFTables
  [x] Ad blocking
  [ ] Terminal Dashboard (optional)

[3/7] Configuring DNSCrypt-Proxy...
✓ Created /etc/dnscrypt-proxy/dnscrypt-proxy.toml

[4/7] Configuring CoreDNS...
✓ Created /etc/coredns/Corefile

[5/7] Configuring firewall...
✓ NFTables rules loaded

[6/7] Configuring system...
✓ System switched to Citadel DNS

[7/7] Verification...
✓ DNSCrypt-Proxy: RUNNING
✓ CoreDNS: RUNNING
✓ NFTables: RUNNING
✓ DNS Resolution: OK

╔═══════════════════════════════════════════════════════════════╗
║              INSTALLATION COMPLETED SUCCESSFULLY!             ║
╚═══════════════════════════════════════════════════════════════╝
```

---

#### Option B: CLI for hardcore users (fast installation)

```bash
# Install everything without GUI - one command!
sudo ./citadel.sh install-all
```

**Characteristics:**
- ✅ **No GUI** - pure CLI
- ✅ **Fast** - installs everything automatically
- ✅ **No questions** - full installation immediately
- ✅ **For advanced users** - full control via logs

**What `install-all` does:**
1. Installs DNSCrypt-Proxy
2. Installs CoreDNS
3. Installs NFTables
4. Rebuilds blocklists
5. Starts all services
6. Runs tests (DNS + adblock)
7. Shows status

**Workflow for hardcore users:**
```bash
# 1. Installation (no GUI)
sudo ./citadel.sh install-all

# 2. Firewall (safe mode)
sudo ./citadel.sh firewall-safe

# 3. Test DNS
dig +short google.com @127.0.0.1

# 4. Switch system
sudo ./citadel.sh configure-system

# 5. Verification
sudo ./citadel.sh verify
```

**5 commands, 0 GUI, full control!** 💪

---

#### Installation modes comparison

| Feature | install-wizard | install-all |
|---------|----------------|-------------|
| **GUI** | ✅ whiptail | ❌ CLI only |
| **Interactive** | ✅ Yes | ❌ No |
| **Languages** | ✅ 7 | ❌ EN/PL |
| **Component selection** | ✅ Checklist | ❌ Everything |
| **Speed** | Slower | ⚡ Faster |
| **For whom** | Beginners | 💪 Hardcore |

---

### Step 4: Verify installation

```bash
# Check status of all services
sudo ./citadel.sh status

# Run full verification
sudo ./citadel.sh verify

# Test DNS
sudo ./citadel.sh test
```

---

## 🗑️ UNINSTALLATION

### Complete removal

Removes Citadel completely including configuration and data:

```bash
sudo ./citadel.sh uninstall
```

**This will:**
- Check and optionally remove optional packages (dnsperf, curl, jq)
- **Restore DNS** (checks backup validity, uses NetworkManager if available, or sets fallback DNS)
- **Test DNS** with multiple servers (1.1.1.1, 8.8.8.8, 9.9.9.9) before proceeding
- Stop and disable services (coredns, dnscrypt-proxy)
- Remove firewall rules
- Delete configuration files (`/etc/coredns/`, `/etc/dnscrypt-proxy/`)
- Remove data directories
- Remove system user `dnscrypt`

**DNS Safety Features:**
- Ignores backup if it points to localhost (127.0.0.1)
- Attempts to use NetworkManager auto-DNS if available
- Uses 3 fallback DNS servers (Cloudflare, Google, Quad9)
- Tests DNS before continuing - warns if not working
- Allows cancellation if DNS issues detected
- Provides manual fix instructions

**Confirmation required:** Type `yes` to proceed.

### Keep configuration

Stops services but preserves all configuration files:

```bash
sudo ./citadel.sh uninstall-keep-config
```

**Use case:** Temporary shutdown, planned reinstallation.

---

## ⚙️ CONFIGURATION

### System configuration

#### Switch to Citadel DNS

```bash
sudo ./citadel.sh configure-system
```

**What this command does:**
- Creates backup of original configuration
- Modifies `/etc/resolv.conf`
- Sets `127.0.0.1` as DNS server
- Blocks changes by NetworkManager

#### Restore original configuration:

```bash
# Restore backup from before Citadel installation
sudo ./citadel.sh restore-system

# Restore factory systemd-resolved configuration (safe fallback)
sudo ./citadel.sh restore-system-default
```

**Difference:**
- `restore-system` - restores exact configuration from before Citadel (from backup)
- `restore-system-default` - restores factory systemd-resolved settings (ignores backup)

### Firewall configuration

#### Safe mode (recommended for beginners):

```bash
sudo ./citadel.sh firewall-safe
```

**Safe mode rules:**
- ✅ Blocks DNS queries outside localhost
- ✅ Allows local traffic
- ⚠️ Warns about DNS leaks

#### Strict mode (for advanced users):

```bash
sudo ./citadel.sh firewall-strict
```

**Strict mode rules:**
- ✅ Blocks ALL DNS queries outside localhost
- ✅ Blocks DoH at IP level (1.1.1.1:443, 8.8.8.8:443)
- ✅ Logs bypass attempts
- ⚠️ May block some applications

### DNSCrypt-Proxy configuration

#### Edit configuration:

```bash
sudo ./citadel.sh edit-dnscrypt
```

**Important parameters in `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`:**

```toml
# DNS servers (choose 2-3)
server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

# Security requirements
require_dnssec = true        # Require DNSSEC
require_nolog = true         # Require no-log policy
require_nofilter = false     # Allow filtering

# Performance
cache_size = 1024            # Cache size (entries)
cache_min_ttl = 300          # Min TTL (seconds)
cache_max_ttl = 86400        # Max TTL (seconds)

# Timeout
timeout = 3000               # Query timeout (ms)
```

**After changes:**

```bash
# Restart DNSCrypt-Proxy
sudo systemctl restart dnscrypt-proxy

# Check status
sudo systemctl status dnscrypt-proxy
```

### CoreDNS configuration

#### Edit configuration:

```bash
sudo ./citadel.sh edit
```

**Example configuration `/etc/coredns/Corefile`:**

```
.:53 {
    # Ad blocking
    hosts /etc/coredns/zones/combined.hosts {
        fallthrough
    }
    
    # Cache
    cache {
        success 10000 3600
        denial 1000 300
    }
    
    # Forward to DNSCrypt-Proxy
    forward . 127.0.0.1:5355
    
    # Prometheus metrics
    prometheus 127.0.0.1:9153
    
    # Logs (optional)
    # log
    
    # Errors
    errors
}
```

**After changes:**

```bash
# Restart CoreDNS
sudo systemctl restart coredns

# Check status
sudo systemctl status coredns
```

---

## 📖 BASIC USAGE

### Checking status

```bash
# Status of all services
sudo ./citadel.sh status
```

**Example output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    CITADEL STATUS                             ║
╚═══════════════════════════════════════════════════════════════╝

🔥 SERVICES:
✓ DNSCrypt-Proxy: RUNNING (PID: 12345)
✓ CoreDNS: RUNNING (PID: 12346)
✓ NFTables: RUNNING

🌐 DNS CONFIGURATION:
✓ System DNS: 127.0.0.1
✓ DNS Resolution: OK
✓ DNSCrypt: ACTIVE

📊 STATISTICS:
  Total Queries: 15,234
  Cache Hits: 12,891 (84.6%)
  Blocked Domains: 1,234
```

### Testing DNS

```bash
# Basic test
sudo ./citadel.sh test

# Full test
sudo ./citadel.sh test-all
```

### Viewing logs

```bash
# Last 20 entries
sudo ./citadel.sh logs

# Live logs
sudo journalctl -u dnscrypt-proxy -u coredns -f
```

### Diagnostics

```bash
# Full diagnostics
sudo ./citadel.sh diagnostics
```

**Diagnostics checks:**
- ✅ Service status
- ✅ DNS configuration
- ✅ Firewall rules
- ✅ Name resolution
- ✅ DNS encryption
- ✅ DNS leaks

---

## 🚀 ADVANCED FEATURES

### Auto-update blocklists

#### Enable auto-update:

```bash
sudo ./citadel.sh auto-update-enable
```

**What it does:**
- Creates systemd timer
- Updates lists every 24h
- Saves last-known-good backup
- Automatically restores on error

#### Configuration:

```bash
sudo ./citadel.sh auto-update-configure
```

**Options:**
- Update frequency (default: 24h)
- Update time (default: 03:00)
- Notifications (default: enabled)

#### Manual update:

```bash
sudo ./citadel.sh auto-update-now
```

### Backup and restore

#### Configuration backup:

```bash
sudo ./citadel.sh config-backup
```

**Backup contains:**
- `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`
- `/etc/coredns/Corefile`
- `/etc/coredns/zones/`
- NFTables rules
- System configuration

**Location:** `/var/lib/citadel/backups/citadel-backup-YYYYMMDD-HHMMSS.tar.gz`

#### List backups:

```bash
sudo ./citadel.sh config-list
```

#### Restore from backup:

```bash
sudo ./citadel.sh config-restore /var/lib/citadel/backups/citadel-backup-20260131-120000.tar.gz
```

#### Last-Known-Good (LKG):

```bash
# Save current configuration as LKG
sudo ./citadel.sh lkg-save

# Restore LKG
sudo ./citadel.sh lkg-restore

# LKG status
sudo ./citadel.sh lkg-status
```

### IPv6 Privacy

#### Enable IPv6 privacy:

```bash
sudo ./citadel.sh ipv6-privacy-on
```

**What it does:**
- Enables temporary IPv6 addresses
- Sets preference for temporary addresses
- Configures address rotation

#### Automatic management:

```bash
sudo ./citadel.sh ipv6-privacy-auto
```

**Auto-ensure:**
- Checks for temporary addresses
- Automatically enables if missing
- Monitors and repairs

#### Smart IPv6 detection:

```bash
sudo ./citadel.sh smart-ipv6
```

**Features:**
- Tests IPv6 connectivity
- Detects problems
- Automatically repairs (deep reset)

### Terminal Dashboard

#### Installation:

```bash
sudo ./citadel.sh install-dashboard
```

#### Launch:

```bash
citadel-top
```

**Dashboard shows:**
- Real-time service status
- Prometheus metrics
- Network status
- System performance
- CPU/RAM load

**Refresh:** every 5 seconds  
**Exit:** Ctrl+C

### DNS Performance Benchmark

Test DNS server performance with dnsperf:

```bash
sudo ./citadel.sh benchmark
```

**Parameters:**
- Queries: 10,000
- Concurrent clients: 50
- Duration: 60 seconds
- Target: 127.0.0.1:53

**Results:**
- QPS (Queries Per Second)
- Average latency
- Success rate
- Cache hit rate

**Interpretation:**
- >50,000 QPS: Excellent
- 20,000-50,000 QPS: Good
- 10,000-20,000 QPS: Acceptable
- <10,000 QPS: Needs optimization

---

## 🚫 AD BLOCKING

### Blocking status

```bash
sudo ./citadel.sh adblock-status
```

**Example output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    ADBLOCK STATUS                             ║
╚═══════════════════════════════════════════════════════════════╝

📊 STATISTICS:
  Total Blocked Domains: 325,847
  Custom Blocked: 42
  Allowlisted: 5
  Last Update: 2026-01-31 03:00:15

📋 BLOCKLIST PROFILE:
  Current: standard
  Available: minimal, standard, aggressive

🎯 TOP BLOCKED TODAY:
  1. ads.example.com (1,234 queries)
  2. tracker.example.com (987 queries)
  3. analytics.example.com (654 queries)
```

### Managing blocklist profiles

#### List available profiles:

```bash
sudo ./citadel.sh blocklist-list
```

**Available profiles:**

| Profile | Domains | Description |
|---------|---------|-------------|
| `minimal` | ~50K | Ads and trackers only |
| `standard` | ~325K | Ads, trackers, malware (recommended) |
| `aggressive` | ~1M+ | Maximum blocking |

#### Switch profile:

```bash
# Switch to aggressive
sudo ./citadel.sh blocklist-switch aggressive

# Switch to minimal
sudo ./citadel.sh blocklist-switch minimal
```

#### Blocklist status:

```bash
sudo ./citadel.sh blocklist-status
```

#### Manage custom blocklist URLs:

```bash
# Add custom blocklist URL
sudo ./citadel.sh blocklist-add-url https://example.com/blocklist.txt

# Remove URL
sudo ./citadel.sh blocklist-remove-url https://example.com/blocklist.txt

# Show all configured URLs
sudo ./citadel.sh blocklist-show-urls
```

#### Update blocklists with LKG fallback:

```bash
sudo ./citadel.sh lists-update
```

Uses Last Known Good (LKG) cache if update fails.

### Blocking custom domains

#### Add domain to blocklist:

```bash
sudo ./citadel.sh adblock-add ads.example.com
```

**Supports wildcards:**

```bash
# Block all subdomains
sudo ./citadel.sh adblock-add "*.ads.example.com"
```

#### Remove domain from blocklist:

```bash
sudo ./citadel.sh adblock-remove ads.example.com
```

#### Check if domain is blocked:

```bash
sudo ./citadel.sh adblock-query ads.example.com
```

**Output:**

```
✓ ads.example.com is BLOCKED
  Source: custom.hosts
  Added: 2026-01-31 12:34:56
```

### Allowlist (whitelists)

#### Add domain to allowlist:

```bash
sudo ./citadel.sh allowlist-add safe-ads.example.com
```

**Use cases:**
- Unblock false positives
- Allow access to trusted domains
- Overrides blocklists

#### List allowlist:

```bash
sudo ./citadel.sh allowlist-list
```

#### Remove from allowlist:

```bash
sudo ./citadel.sh allowlist-remove safe-ads.example.com
```

### Rebuild blocklists

```bash
sudo ./citadel.sh adblock-rebuild
```

**When to use:**
- After adding/removing many domains
- After profile change
- After manual file edits

### Display lists

```bash
# Show custom blocks
sudo ./citadel.sh custom

# Show main blocklist
sudo ./citadel.sh blocklist

# Show combined list
sudo ./citadel.sh combined
```

---

## 🔐 SECURITY

### Supply Chain Protection

#### Initialize:

```bash
sudo ./citadel.sh supply-chain-init
```

**Creates:**
- Checksums of all files
- Integrity manifest
- Digital signatures (optional)

#### Verify:

```bash
sudo ./citadel.sh supply-chain-verify
```

**Checks:**
- ✅ Binary integrity
- ✅ Script integrity
- ✅ Configuration integrity
- ⚠️ Detects modifications

#### Status:

```bash
sudo ./citadel.sh supply-chain-status
```

### Integrity Check

#### Initialize manifest:

```bash
sudo ./citadel.sh integrity-init
```

#### Check integrity:

```bash
sudo ./citadel.sh integrity-check
```

**Example output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    INTEGRITY CHECK                            ║
╚═══════════════════════════════════════════════════════════════╝

✓ /usr/bin/dnscrypt-proxy: OK
✓ /usr/bin/coredns: OK
✓ /etc/dnscrypt-proxy/dnscrypt-proxy.toml: OK
⚠ /etc/coredns/Corefile: MODIFIED
✓ /opt/citadel/modules/*.sh: OK

RESULT: 1 file modified
```

### Ghost Check (Port Audit)

```bash
sudo ./citadel.sh ghost-check
```

**Checks:**
- Open ports
- Listening services
- Unexpected connections
- Potential backdoors

**Example output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    GHOST CHECK                                ║
╚═══════════════════════════════════════════════════════════════╝

🔍 OPEN PORTS:
  ✓ 22/tcp (ssh) - EXPECTED
  ✓ 53/udp (dns) - EXPECTED
  ⚠ 8080/tcp (unknown) - UNEXPECTED

⚠ WARNING: 1 unexpected port found!
```

### Killswitch (Emergency Switch)

#### Enable killswitch:

```bash
sudo ./citadel.sh killswitch-on
```

**What it does:**
- Blocks ALL DNS queries except localhost
- Forces use of Citadel
- Prevents DNS leaks

#### Disable killswitch:

```bash
sudo ./citadel.sh killswitch-off
```

---

## 📊 MONITORING

### Health Status

```bash
sudo ./citadel.sh health-status
```

**Checks:**
- Service status
- DNS performance
- Resource usage
- Log errors
- Anomalies

#### Install Health Watchdog

```bash
sudo ./citadel.sh health-install
```

Automatically monitors services and restarts if needed.

#### Uninstall Health Watchdog

```bash
sudo ./citadel.sh health-uninstall
```

### Cache Statistics

```bash
# Basic statistics
sudo ./citadel.sh cache-stats

# Top queried domains
sudo ./citadel.sh cache-stats-top 20

# Reset statistics
sudo ./citadel.sh cache-stats-reset

# Watch live statistics
sudo ./citadel.sh cache-stats-watch
```

**Shows:**
- Cache size
- Hit rate
- Most popular domains
- Performance stats

**Example output:**

```
╔═══════════════════════════════════════════════════════════════╗
║                    CACHE STATISTICS                           ║
╚═══════════════════════════════════════════════════════════════╝

📊 CACHE METRICS:
  Total Entries: 8,234
  Hit Rate: 87.3%
  Miss Rate: 12.7%
  Evictions: 234

🔥 TOP DOMAINS (last 24h):
  1. google.com (2,345 queries)
  2. youtube.com (1,987 queries)
  3. github.com (1,234 queries)
```

### Prometheus Metrics

```bash
# Display metrics
curl http://127.0.0.1:9153/metrics
```

**Available metrics:**
- `coredns_dns_request_count_total` - query count
- `coredns_cache_hits_total` - cache hits
- `coredns_cache_misses_total` - cache misses
- `coredns_dns_request_duration_seconds` - response time

### Network Discovery

```bash
sudo ./citadel.sh discover
```

**Shows:**
- Active network interface
- IP address (IPv4/IPv6)
- Default gateway
- DNS servers
- Firewall rules

---

## 🚨 EMERGENCY MODE

### Panic Bypass

**Use when:**
- DNS stopped working
- No internet access
- Need to quickly restore connection

#### Activate (for 5 minutes):

```bash
sudo ./citadel.sh panic-bypass 300
```

**What it does:**
- Flush NFTables rules
- Temporarily switch to public DNS (1.1.1.1)
- Automatically restores after timeout

#### Activate (no time limit):

```bash
sudo ./citadel.sh panic-bypass
```

#### Manual restore:

```bash
sudo ./citadel.sh panic-restore
```

#### Panic mode status:

```bash
sudo ./citadel.sh panic-status
```

### Emergency Refuse

**Use when:**
- Suspect attack
- Want to completely block DNS

```bash
# Block all DNS queries
sudo ./citadel.sh emergency-refuse

# Restore normal operation
sudo ./citadel.sh emergency-restore
```

---

## 🔧 TROUBLESHOOTING

### Problem: DNS not working

#### Symptoms:
- No access to websites
- "could not resolve host" errors
- Timeout when pinging domains

#### Solution:

```bash
# Step 1: Check service status
sudo ./citadel.sh status

# Step 2: Check logs
sudo ./citadel.sh logs

# Step 3: Run diagnostics
sudo ./citadel.sh diagnostics

# Step 4: If nothing helps - panic bypass
sudo ./citadel.sh panic-bypass 300
```

#### Common causes:

**1. Services not running:**

```bash
# Check status
sudo systemctl status dnscrypt-proxy
sudo systemctl status coredns

# Restart services
sudo systemctl restart dnscrypt-proxy
sudo systemctl restart coredns
```

**2. Configuration error:**

```bash
# Check DNSCrypt config
dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Check CoreDNS config
coredns -conf /etc/coredns/Corefile -validate
```

**3. Firewall blocking:**

```bash
# Check rules
sudo nft list ruleset

# Temporarily disable firewall
sudo systemctl stop nftables

# If it helped - problem in rules
sudo ./citadel.sh firewall-safe
```

### Problem: Port conflicts

#### Symptoms:
- "address already in use" error
- CoreDNS can't start
- Port 53 occupied

#### Solution:

```bash
# Automatic solution
sudo ./citadel.sh fix-ports
```

**Wizard will help:**
1. Detect what's using port 53
2. Stop conflicting services (avahi, systemd-resolved)
3. Change CoreDNS port (if needed)

#### Manual solution:

```bash
# Check what's using port 53
sudo ss -tulpn | grep :53

# Stop systemd-resolved
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Stop avahi-daemon
sudo systemctl stop avahi-daemon
sudo systemctl disable avahi-daemon

# Restart CoreDNS
sudo systemctl restart coredns
```

### Problem: Slow DNS

#### Symptoms:
- Long page loading times
- Delays on first connection
- Timeout on rarely used domains

#### Solution:

**1. Check cache:**

```bash
sudo ./citadel.sh cache-stats
```

If hit rate < 70% - increase cache size:

```bash
sudo ./citadel.sh edit
```

In Corefile change:

```
cache {
    success 20000 7200  # Increase from 10000
    denial 2000 600     # Increase from 1000
}
```

**2. Change DNSCrypt servers:**

```bash
sudo ./citadel.sh edit-dnscrypt
```

Choose faster servers (geographically closer):

```toml
server_names = ['cloudflare', 'google']  # Fast, global
```

**3. Reduce timeout:**

```toml
timeout = 2000  # Reduce from 3000
```

**4. Enable parallel racing:**

```bash
sudo ./citadel.sh install-doh-parallel
```

### Problem: False positives

#### Symptoms:
- Important site doesn't work
- App can't connect
- Service is blocked

#### Solution:

**1. Check if domain is blocked:**

```bash
sudo ./citadel.sh adblock-query example.com
```

**2. Add to allowlist:**

```bash
sudo ./citadel.sh allowlist-add example.com
```

**3. Rebuild lists:**

```bash
sudo ./citadel.sh adblock-rebuild
```

**4. Test:**

```bash
dig example.com @127.0.0.1
```

### Problem: DNS leaks

#### Symptoms:
- Leak test shows ISP DNS
- Queries bypass Citadel
- Apps use their own DNS

#### Solution:

**1. Enable strict firewall:**

```bash
sudo ./citadel.sh firewall-strict
```

**2. Enable killswitch:**

```bash
sudo ./citadel.sh killswitch-on
```

**3. Check for leaks:**

```bash
# Online test
curl -s https://www.dnsleaktest.com/

# Local test
sudo ./citadel.sh diagnostics | grep -i leak
```

---

## 💡 USAGE EXAMPLES

### Example 1: Basic installation

**Scenario:** Fresh installation on clean system

```bash
# 1. Clone repository
git clone https://github.com/QguAr71/Cytadela.git
cd Citadel

# 2. Check dependencies
sudo ./citadel.sh check-deps --install

# 3. Run wizard
sudo ./citadel.sh install-wizard

# 4. Verify
sudo ./citadel.sh verify

# 5. Test
sudo ./citadel.sh test
```

**Time:** ~5-10 minutes  
**Difficulty:** Easy

### Example 2: Maximum ad blocking

**Scenario:** Aggressive ad blocking for entire network

```bash
# 1. Install with aggressive profile
sudo ./citadel.sh install-wizard

# 2. Switch to aggressive blocklist
sudo ./citadel.sh blocklist-switch aggressive

# 3. Add custom blocks
sudo ./citadel.sh adblock-add "*.ads.example.com"
sudo ./citadel.sh adblock-add "tracker.example.com"

# 4. Enable auto-update
sudo ./citadel.sh auto-update-enable

# 5. Verify blocking
sudo ./citadel.sh adblock-status
```

**Result:** 1M+ blocked domains

### Example 3: Privacy-focused setup

**Scenario:** Maximum privacy and security

```bash
# 1. Install with all security features
sudo ./citadel.sh install-wizard

# 2. Enable strict firewall
sudo ./citadel.sh firewall-strict

# 3. Enable killswitch
sudo ./citadel.sh killswitch-on

# 4. Enable IPv6 privacy
sudo ./citadel.sh ipv6-privacy-auto

# 5. Initialize supply chain protection
sudo ./citadel.sh supply-chain-init

# 6. Verify security
sudo ./citadel.sh ghost-check
sudo ./citadel.sh integrity-check
```

**Security level:** Maximum

---

## ❓ FAQ (Frequently Asked Questions)

### General

**Q: Is Citadel free?**  
A: Yes, Citadel is completely free and open-source (GPL-3.0 license).

**Q: Does Citadel work on Raspberry Pi?**  
A: Yes, but requires manual adaptation for Raspberry Pi OS (Debian-based).

**Q: Can I use Citadel with VPN?**  
A: Yes, Citadel works with VPN. DNS will be encrypted by Citadel, traffic through VPN.

**Q: Does Citadel slow down internet?**  
A: No, thanks to caching it often speeds up name resolution.

### Installation

**Q: How long does installation take?**  
A: 5-10 minutes with wizard, 3-5 minutes with CLI.

**Q: Do I need root access?**  
A: Yes, Citadel requires sudo/root privileges.

**Q: Can I install without wizard?**  
A: Yes, use `sudo ./citadel.sh install-all` for CLI installation.

### Configuration

**Q: How do I change DNS servers?**  
A: Edit `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` or use `sudo ./citadel.sh edit-dnscrypt`.

**Q: Can I use custom blocklists?**  
A: Yes, use `sudo ./citadel.sh blocklist-add-url <URL>`.

**Q: How do I backup configuration?**  
A: Use `sudo ./citadel.sh config-backup`.

### Troubleshooting

**Q: DNS stopped working, what to do?**  
A: Run `sudo ./citadel.sh diagnostics` or use `sudo ./citadel.sh panic-bypass 300`.

**Q: How do I check if DNS is encrypted?**  
A: Use `sudo ./citadel.sh diagnostics` - it checks DNS encryption.

**Q: How do I reset configuration?**  
A: `sudo ./citadel.sh restore-system` restores backup from before Citadel. If backup was broken, use `sudo ./citadel.sh restore-system-default` to restore factory settings.

---

## 📞 SUPPORT

### Documentation

- **Quick start:** [docs/user/quick-start.md](quick-start.md)
- **Commands:** [docs/user/commands.md](commands.md)
- **FAQ:** [docs/user/FAQ.md](FAQ.md)
- **Manual PL:** [docs/user/MANUAL_PL.md](MANUAL_PL.md)

### Community

- **GitHub Issues:** [github.com/QguAr71/Cytadela/issues](https://github.com/QguAr71/Cytadela/issues)
- **GitHub Discussions:** [github.com/QguAr71/Cytadela/discussions](https://github.com/QguAr71/Cytadela/discussions)

### Reporting bugs

When reporting a bug, include:

```bash
# System information
uname -a
cat /etc/os-release

# Citadel status
sudo ./citadel.sh status

# Diagnostics
sudo ./citadel.sh diagnostics

# Logs
sudo ./citadel.sh logs
```

---

## 📜 LICENSE

Citadel is open-source software licensed under **GNU General Public License v3.0**.

Full license text: [LICENSE](../../LICENSE)

---

## 🙏 ACKNOWLEDGMENTS

- **DNSCrypt-Proxy** - for DNS encryption
- **CoreDNS** - for DNS server
- **NFTables** - for firewall
- **Community** - for feedback and contributions

---

**Document version:** 1.0  
**Last updated:** 2026-01-31  
**Author:** Citadel Team

---

**Citadel - Your fortress against DNS surveillance** 🛡️
