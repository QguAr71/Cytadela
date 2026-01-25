# CITADEL++ v3.0 — COMPLETE MANUAL

> **Fortified DNS Infrastructure** — Advanced Hardened Resolver with Full Privacy Stack

* * *

# PROJECT EVALUATION

## 🛡️ Protection Level: **8.5/10**

| Layer | Protection | Rating |
| --- | --- | --- |
| **DNS Encryption** | DNSCrypt/DoH encrypts queries before ISP | ⭐⭐⭐⭐⭐ |
| **DNS Leak Prevention** | nftables enforces localhost, blocks bypass | ⭐⭐⭐⭐⭐ |
| **Adblock** | 318k+ domains blocked (Hagezi Pro) | ⭐⭐⭐⭐⭐ |
| **IPv6 Privacy** | Temporary addresses, auto-ensure | ⭐⭐⭐⭐ |
| **Integrity** | SHA256 manifest, supply-chain verification | ⭐⭐⭐⭐ |
| **Resilience** | LKG cache, panic-bypass, health watchdog | ⭐⭐⭐⭐⭐ |

### What it protects:

-   ✅ ISP cannot see DNS queries
-   ✅ Applications cannot bypass local resolver
-   ✅ Ads/trackers/malware blocked at DNS level
-   ✅ IPv6 does not reveal permanent MAC address
-   ✅ System works even if upstream fails (LKG)

### What it does not protect:

-   ❌ HTTP/HTTPS traffic (VPN needed)
-   ❌ Browser fingerprinting
-   ❌ Connection metadata (target IPs)

* * *

## 👤 Usefulness for Users: **9/10**

| Aspect | Rating | Notes |
| --- | --- | --- |
| **Installation** | ⭐⭐⭐⭐ | Single script, simple workflow |
| **Diagnostics** | ⭐⭐⭐⭐⭐ | discover, health-status, ghost-check |
| **Recovery** | ⭐⭐⭐⭐⭐ | panic-bypass with auto-rollback |
| **Documentation** | ⭐⭐⭐⭐⭐ | Complete manual, built-in help |
| **Maintenance** | ⭐⭐⭐⭐⭐ | Health watchdog, auto-restart |
| **Flexibility** | ⭐⭐⭐⭐ | SAFE/STRICT modes, location-aware |

### Ideal for:

-   🎯 Privacy-conscious users
-   🎯 Home network admins
-   🎯 Arch/CachyOS users
-   🎯 People wanting network-level ad blocking

### Learning Curve:

-   **Basic Use:** Easy (install-all → configure-system)
-   **Advanced:** Medium (requires understanding of DNS/firewall)

* * *

## 📊 Comparison with Alternatives

| Solution | DNS Protection | Adblock | Leak Prevention | Ease of Use |
| --- | --- | --- | --- | --- |
| **Citadel++** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Pi-hole | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| AdGuard Home | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| DNSCrypt Only | ⭐⭐⭐⭐⭐ | ❌ | ⭐⭐ | ⭐⭐⭐ |

### Citadel's Advantage:

-   Full nftables integration (leak prevention)
-   Modular architecture
-   Panic recovery
-   IPv6 privacy management

* * *

## 🎯 Summary

**Citadel++ is a solid, comprehensive DNS security solution for advanced Linux users.**

-   **Protection:** Very good for DNS/adblock, requires VPN for full privacy
-   **Usefulness:** High, especially thanks to diagnostics and recovery
-   **Uniqueness:** Combination of DNSCrypt + CoreDNS + nftables + health monitoring

### Final Rating: 8.5/10 🛡️

* * *

# TABLE OF CONTENTS

1.  Architecture
2.  Installation
3.  Security Modules
4.  Diagnostic Commands
5.  Emergency Commands
6.  Adblock Panel
7.  IPv6 Management
8.  Firewall Modes
9.  Additional Tools
10.  Configuration Files
11.  Troubleshooting

* * *

# ARCHITECTURE

## Protection Layers (Defense in Depth)

text

    ┌─────────────────────────────────────────────────────────────┐
    │                    APPLICATIONS (Firefox, curl, etc.)       │
    └─────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  LAYER 3: NFTables (leak prevention, kill-switch)          │
    │  - Blocks DNS to external servers                          │
    │  - Enforces use of local resolver                          │
    │  - Kill-switch in STRICT mode                              │
    └─────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  LAYER 2: CoreDNS (caching, blocking, metrics)             │
    │  - DNS cache (faster responses)                           │
    │  - Adblock (domain blocking)                               │
    │  - Prometheus metrics (:9153)                              │
    │  - Listens on 127.0.0.1:53                                 │
    └─────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  LAYER 1: DNSCrypt-Proxy (encrypted upstream)              │
    │  - Encrypted DNS queries (DNSCrypt/DoH)                    │
    │  - Anonymization (optional)                                │
    │  - DNSSEC validation (optional)                            │
    │  - Listens on 127.0.0.1:5355                               │
    └─────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
    ┌─────────────────────────────────────────────────────────────┐
    │  INTERNET (encrypted queries to resolvers)                 │
    │  - Quad9, Cloudflare, Mullvad, etc.                        │
    └─────────────────────────────────────────────────────────────┘

## Threat Model

-   **ISP tracking** — DNS encryption prevents ISP from viewing queries
-   **DNS leaks** — nftables enforces use of local resolver
-   **Malware/telemetry** — adblock blocks known domains
-   **Metadata exposure** — Privacy Extensions for IPv6

* * *

# INSTALLATION

## Installation Commands

| Command | Description |
| --- | --- |
| install-dnscrypt | Install only DNSCrypt-Proxy |
| install-coredns | Install only CoreDNS |
| install-nftables | Install only NFTables rules |
| install-all | Install all DNS modules (DOES NOT disable systemd-resolved) |

## Recommended Workflow

Bash

    # 1. Install all modules
    sudo ./cytadela++.sh install-all
    
    # 2. Set firewall SAFE (does not break internet)
    sudo ./cytadela++.sh firewall-safe
    
    # 3. Test local DNS
    dig +short google.com @127.0.0.1
    
    # 4. Switch system to Citadel++ DNS
    sudo ./cytadela++.sh configure-system
    
    # 5. Test internet
    ping -c 3 google.com
    
    # 6. Switch to STRICT (full DNS-leak block)
    sudo ./cytadela++.sh firewall-strict

## DNSSEC Options

Bash

    # Method 1: Environment variable
    CITADEL_DNSSEC=1 sudo ./cytadela++.sh install-dnscrypt
    
    # Method 2: Flag
    sudo ./cytadela++.sh install-all --dnssec

* * *

# SECURITY MODULES

## 1\. Integrity Layer (Local-First)

**Purpose:** Verify integrity of scripts and binaries before execution.

### Commands

Bash

    integrity-init        # Create SHA256 manifest for scripts/binaries
    integrity-check       # Verify integrity against manifest
    integrity-status      # Show mode and manifest info
    --dev                 # Run in developer mode (bypass checks)

### Modes

-   **secure** (default) — full integrity verification
-   **developer** — bypassed checks (for developers)

### Files

text

    /etc/cytadela/manifest.sha256    # Manifest with SHA256 hashes
    ~/.cytadela_dev                  # File enabling developer mode

### Operation

1.  integrity-init generates SHA256 hashes for:
    -   Main scripts (cytadela++.sh, citadela\_en.sh)
    -   Binaries in /opt/cytadela/bin/
2.  integrity-check compares current hashes with manifest
3.  In secure mode: binary mismatch = hard fail, module mismatch = prompt

* * *

## 2\. LKG (Last Known Good) — Blocklist Cache

**Purpose:** Ensure adblock works even if upstream is unavailable.

### Commands

Bash

    lkg-save              # Save current blocklist to cache
    lkg-restore           # Restore blocklist from cache
    lkg-status            # Show cache status
    lists-update          # Update blocklist with LKG fallback

### Files

text

    /var/lib/cytadela/lkg/blocklist.hosts    # Cached blocklist
    /var/lib/cytadela/lkg/blocklist.meta     # Metadata (date, lines, sha256)

### Blocklist Validation

Before saving to LKG, blocklist is validated:

-   Min. 1000 lines
-   Hosts format (0.0.0.0 domain)
-   No error pages (<html>, 404, 403)

### lists-update Flow

text

    1. Download blocklist to staging
    2. Validate downloaded file
    3. If OK → atomic swap + save to LKG
    4. If validation fail → keep current
    5. If download fail → restore from LKG

* * *

## 3\. Supply-Chain Verification

**Purpose:** SHA256 verification of downloaded assets.

### Commands

Bash

    supply-chain-status   # Show checksums file status
    supply-chain-init     # Initialize checksums for known assets
    supply-chain-verify   # Verify local files against manifest

### Files

text

    /etc/cytadela/checksums.sha256    # Checksums for external assets

### Operation

-   supply-chain-init downloads current blocklist hashes
-   supply-chain-verify checks files with integrity manifest
-   supply\_chain\_download() verifies hash before saving

* * *

## 4\. Health Watchdog

**Purpose:** Automatic service restart on failure + periodic health checks.

### Commands

Bash

    health-status         # Show health status (services, DNS probe, firewall)
    health-install        # Install auto-restart + health check timer
    health-uninstall      # Remove health watchdog

### What health-install Installs

1.  **Health check script** (/usr/local/bin/citadel-health-check)
    -   Checks DNS resolution
    -   If fail → restarts coredns
2.  **Systemd overrides** for dnscrypt-proxy and coredns:
    
    ini
    
        [Service]
        Restart=on-failure
        RestartSec=5
        StartLimitIntervalSec=300
        StartLimitBurst=5
    
3.  **Health check timer** (every 5 minutes)

### Created Files

text

    /usr/local/bin/citadel-health-check
    /etc/systemd/system/citadel-health.service
    /etc/systemd/system/citadel-health.timer
    /etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf
    /etc/systemd/system/coredns.service.d/citadel-restart.conf

* * *

## 5\. Location-Aware Advisory

**Purpose:** Firewall mode advice based on WiFi network.

### Commands

Bash

    location-status           # Show SSID, trust status, firewall mode
    location-check            # Check and suggest mode change
    location-add-trusted      # Add SSID to trusted (or current if no arg)
    location-remove-trusted   # Remove SSID from trusted
    location-list-trusted     # Show trusted SSID list

### Files

text

    /etc/cytadela/trusted-ssids.txt    # Trusted SSID list

### location-check Logic

| Network | Firewall | Action |
| --- | --- | --- |
| UNTRUSTED + SAFE | ⚠️ | Prompt: switch to STRICT? |
| UNTRUSTED + STRICT | ✅ | Good |
| TRUSTED + SAFE | ✅ | Good |
| TRUSTED + STRICT | ℹ️ | Info: you can switch to SAFE |
| Wired | — | Treated as trusted |

* * *

## 6\. NFT Debug Chain

**Purpose:** Firewall rules debugging with rate-limited logging.

### Commands

Bash

    nft-debug-on          # Enable debug chain with logging
    nft-debug-off         # Disable debug chain
    nft-debug-status      # Show status and counters
    nft-debug-logs        # Show recent CITADEL logs

### What is Logged

-   \[CITADEL-DNS\] — DNS queries (port 53)
-   \[CITADEL-DOT\] — DNS-over-TLS (port 853)
-   \[CITADEL-DOH\] — DNS-over-HTTPS to known resolvers

### Rate Limiting

5 logs/minute per rule (to avoid flooding journal)

### Log Preview

Bash

    journalctl -f | grep CITADEL

* * *

# DIAGNOSTIC COMMANDS

## Basic

| Command | Description |
| --- | --- |
| status | Show services status (dnscrypt, coredns, nftables) |
| diagnostics | Full system diagnostics |
| verify | Verify entire stack (ports/services/DNS/NFT/metrics) |
| test-all | Smoke test (verify + leak test + IPv6) |

## Discover

Bash

    sudo ./cytadela++.sh discover

Shows:

-   Active network interface
-   Network stack (NetworkManager/systemd-networkd)
-   nftables status
-   IPv4/IPv6 addresses
-   DNS services status

## Ghost-Check (Port Audit)

Bash

    sudo ./cytadela++.sh ghost-check

Scans all listening ports and warns about:

-   Ports bound to 0.0.0.0 (all IPv4 interfaces)
-   Ports bound to :: (all IPv6 interfaces)

**Allowed Ports (default):** 22, 53, 5353, 9153

* * *

# EMERGENCY COMMANDS

## Emergency Commands

| Command | Description |
| --- | --- |
| emergency-refuse | Reject all DNS queries (emergency mode) |
| emergency-restore | Restore normal operation |
| killswitch-on | Activate DNS kill-switch (block all non-localhost) |
| killswitch-off | Deactivate kill-switch |

## Panic Bypass (SPOF Recovery)

**Purpose:** Temporarily disable protection when DNS fails.

### Commands

Bash

    panic-bypass [secs]   # Disable protection + auto-rollback (default 300s)
    panic-restore         # Manually restore protected mode
    panic-status          # Show panic mode status

### What panic-bypass Does

1.  Saves state: resolv.conf, nftables ruleset
2.  Flush nftables (allow all traffic)
3.  Set public DNS (9.9.9.9, 1.1.1.1, 8.8.8.8)
4.  Starts auto-rollback timer in background

### What panic-restore Does

1.  Restores resolv.conf from backup
2.  Restores nftables from backup
3.  Restarts dnscrypt-proxy + coredns
4.  Cleans state files

### Files

text

    /var/lib/cytadela/panic.state              # Panic mode state
    /var/lib/cytadela/resolv.conf.pre-panic    # resolv.conf backup
    /var/lib/cytadela/nft.pre-panic            # nftables backup

* * *

# ADBLOCK PANEL

## Commands

| Command | Description |
| --- | --- |
| adblock-status | Show adblock/CoreDNS status |
| adblock-stats | Show numbers: custom/blocklist/combined |
| adblock-show \[type\] | Show: custom|blocklist|combined (first 200 lines) |
| adblock-edit | Edit custom.hosts and reload |
| adblock-add <domain> | Add domain to custom.hosts |
| adblock-remove <domain> | Remove domain from custom.hosts |
| adblock-rebuild | Rebuild combined.hosts and reload |
| adblock-query <domain> | Query domain through local DNS |

## Files

text

    /etc/coredns/zones/custom.hosts      # Your own blocks
    /etc/coredns/zones/blocklist.hosts   # External blocklist (Hagezi)
    /etc/coredns/zones/combined.hosts    # custom + blocklist (used by CoreDNS)

## Allowlist (whitelist)

| Command | Description |
| --- | --- |
| allowlist-add <domain> | Add domain to allowlist |
| allowlist-remove <domain> | Remove domain from allowlist |
| allowlist-list | Show allowlist |

Domains from allowlist are removed from combined.hosts during adblock-rebuild.

* * *

# IPv6 MANAGEMENT

## Commands

| Command | Description |
| --- | --- |
| smart-ipv6 | Smart IPv6 detection & auto-reconfiguration |
| ipv6-privacy-on | Enable IPv6 Privacy Extensions |
| ipv6-privacy-off | Disable IPv6 Privacy Extensions |
| ipv6-privacy-status | Show Privacy Extensions status |
| ipv6-privacy-auto | Auto-ensure IPv6 privacy (detect + fix) |
| ipv6-deep-reset | Full IPv6 reset (flush + reconnect) |

## IPv6 Privacy Auto

**Purpose:** Automatically ensure temporary IPv6 addresses.

### Operation

1.  Detect active interface
2.  Check if usable temporary address exists
3.  If not:
    -   Set sysctl use\_tempaddr=2
    -   Reconnect interface (stack-aware)
4.  Verify result

## IPv6 Deep Reset

**Purpose:** Full IPv6 reset when ping fails despite visible address.

### Operation

1.  Flush IPv6 neighbor cache
2.  Flush global IPv6 addresses
3.  Reconnect interface (NM/networkd/manual)
4.  Wait for Router Advertisement
5.  Optionally send Router Solicitation (rdisc6)

### Difference vs ipv6-privacy-auto

-   ipv6-privacy-auto — only ensures temporary address
-   ipv6-deep-reset — full IPv6 reset (flush everything)

* * *

# FIREWALL MODES

## Modes

| Mode | Command | Description |
| --- | --- | --- |
| **SAFE** | firewall-safe | Does not break internet, basic protection |
| **STRICT** | firewall-strict | Full DNS-leak block, enforces localhost |

## SAFE Mode

-   Allows DNS to localhost
-   Logs DNS leak attempts
-   Does not block traffic

## STRICT Mode

-   Blocks DNS to everything except localhost
-   DNS kill-switch
-   Enforces use of local resolver

## nftables Tables

text

    table inet citadel_dns        # Main DNS rules
    table inet citadel_emergency  # Emergency/killswitch rules
    table inet citadel_debug      # Debug chain (optional)

* * *

# ADDITIONAL TOOLS

## Terminal Dashboard

Bash

    sudo ./cytadela++.sh install-dashboard
    citadel-top

Real-time dashboard showing:

-   Services status
-   Prometheus metrics
-   DNS resolution
-   External IP
-   System load

## Editor Integration

Bash

    sudo ./cytadela++.sh install-editor
    citadel edit           # Edit CoreDNS config
    citadel edit-dnscrypt  # Edit DNSCrypt config
    citadel status         # Quick status
    citadel logs           # Recent logs
    citadel test           # Test DNS

## Kernel Priority Optimization

Bash

    sudo ./cytadela++.sh optimize-kernel

Sets higher priority for DNS processes (renice, ionice).

## DoH Parallel Racing

Bash

    sudo ./cytadela++.sh install-doh-parallel

Creates DNSCrypt config with parallel racing for faster responses.

* * *

# CONFIGURATION FILES

## Main

| File | Description |
| --- | --- |
| /etc/dnscrypt-proxy/dnscrypt-proxy.toml | DNSCrypt configuration |
| /etc/coredns/Corefile | CoreDNS configuration |
| /etc/nftables.d/citadel-dns.nft | nftables rules |

## Citadel State

| File | Description |
| --- | --- |
| /etc/cytadela/manifest.sha256 | Integrity manifest |
| /etc/cytadela/checksums.sha256 | Supply-chain checksums |
| /etc/cytadela/trusted-ssids.txt | Trusted networks WiFi |
| /var/lib/cytadela/ | State directory |
| /var/lib/cytadela/lkg/ | LKG blocklist cache |

## Logs

Bash

    journalctl -u dnscrypt-proxy -f    # DNSCrypt logs
    journalctl -u coredns -f           # CoreDNS logs
    journalctl | grep CITADEL          # nftables debug logs

* * *

# TROUBLESHOOTING

## DNS Not Working

Bash

    # 1. Check services status
    sudo ./cytadela++.sh health-status
    
    # 2. Check if port 53 is occupied
    ss -ln | grep :53
    
    # 3. Test local DNS
    dig +short google.com @127.0.0.1
    
    # 4. Check logs
    journalctl -u coredns -n 50
    
    # 5. Panic bypass (last resort)
    sudo ./cytadela++.sh panic-bypass 60

## Port 53 Occupied

Bash

    # Check what occupies the port
    sudo ss -tlnp | grep :53
    
    # Usually systemd-resolved or avahi
    sudo systemctl stop systemd-resolved
    sudo systemctl stop avahi-daemon
    
    # Or use fix-ports
    sudo ./cytadela++.sh fix-ports

## IPv6 Not Working

Bash

    # 1. Check status
    sudo ./cytadela++.sh discover
    
    # 2. Deep reset
    sudo ./cytadela++.sh ipv6-deep-reset
    
    # 3. Check Privacy Extensions
    sudo ./cytadela++.sh ipv6-privacy-auto

## Firewall Blocks Too Much

Bash

    # 1. Check mode
    sudo ./cytadela++.sh location-status
    
    # 2. Switch to SAFE
    sudo ./cytadela++.sh firewall-safe
    
    # 3. Enable debug
    sudo ./cytadela++.sh nft-debug-on
    journalctl -f | grep CITADEL

## System Restore

Bash

    # Full rollback to systemd-resolved
    sudo ./cytadela++.sh restore-system

* * *

# GLOBAL ERROR TRAP

Citadel++ has a built-in global error trap that shows:

-   Function where error occurred
-   Line number
-   Command that failed
-   Exit code

Example:

text

    ✗ ERROR in install_coredns() at line 1234: 'systemctl restart coredns' exited with code 1

* * *

# SUMMARY OF COMMANDS

## All Commands (Alphabetically)

text

    adblock-add           adblock-edit          adblock-query
    adblock-rebuild       adblock-remove        adblock-show
    adblock-stats         adblock-status        allowlist-add
    allowlist-list        allowlist-remove      configure-system
    diagnostics           discover              emergency-refuse
    emergency-restore     firewall-safe         firewall-strict
    fix-ports             ghost-check           health-install
    health-status         health-uninstall      install-all
    install-coredns       install-dashboard     install-dnscrypt
    install-doh-parallel  install-editor        install-nftables
    integrity-check       integrity-init        integrity-status
    ipv6-deep-reset       ipv6-privacy-auto     ipv6-privacy-off
    ipv6-privacy-on       ipv6-privacy-status   killswitch-off
    killswitch-on         lkg-restore           lkg-save
    lkg-status            lists-update          location-add-trusted
    location-check        location-list-trusted location-remove-trusted
    location-status       nft-debug-logs        nft-debug-off
    nft-debug-on          nft-debug-status      optimize-kernel
    panic-bypass          panic-restore         panic-status
    restore-system        smart-ipv6            status
    supply-chain-init     supply-chain-status   supply-chain-verify
    test-all              verify

* * *

# VERSIONS

-   **v3.0** — Current version with all modules
-   **Commits from session 2026-01-25:**
    -   96cce16 — integrity layer
    -   fb17ca9 — trap ERR, discover, ipv6-privacy-auto
    -   e01b935 — LKG, panic-bypass
    -   a91e801 — fix symlink (bypass)
    -   04c556e — fix symlink (restore)
    -   1c41fdc — ghost-check, ipv6-deep-reset
    -   ab74d7a — health watchdog, supply-chain
    -   4b4122a — location-aware, nft-debug

* * *

# FUTURE IDEAS (v3.1+)

## Code Optimizations

### Issue #11: Deduplication PL/EN

**Priority:** Medium

Extract common logic to /opt/cytadela/lib/cytadela-core.sh:

-   Wrappers cytadela++.sh and citadela\_en.sh only with translations
-   **Gain:** ~3000 lines less to maintain

### Issue #12: Modularization (lazy loading)

**Priority:** Medium

Split script into modules:

text

    /opt/cytadela/modules/
    ├── health.sh
    ├── location.sh
    ├── ipv6.sh
    ├── integrity.sh
    ├── lkg.sh
    ├── panic.sh
    └── nft-debug.sh

-   Lazy loading — load only needed modules
-   **Gain:** Faster execution, easier development

* * *

## New Features

### Issue #13: Auto-update blocklist

**Priority:** Medium

Bash

    auto-update-enable [interval]   # Enable (daily/weekly)
    auto-update-disable             # Disable
    auto-update-status              # Timer status

-   Systemd timer for automatic update
-   Integration with LKG fallback

### Issue #14: Backup/Restore config

**Priority:** Medium

Bash

    config-backup [path]    # Export to tar.gz
    config-restore <path>   # Import from archive

Files: dnscrypt, coredns, nftables, cytadela state

### Issue #15: DNS Cache Stats

**Priority:** Low

Bash

    cache-stats           # Cache statistics
    cache-stats --top 20  # Top blocked domains

-   Hit rate, query count, top blocked

### Issue #16: Desktop Notifications

**Priority:** Low

-   Notifications when health check fails
-   Integration with notify-send
-   Optional (requires DE)

### Issue #17: Multi-blocklist support

**Priority:** Low

Bash

    blocklist-list              # Available blocklists
    blocklist-switch <name>     # Switch

Available: Hagezi Pro/Light/Ultimate, OISD, Steven Black

### Issue #18: Web Dashboard

**Priority:** Low

-   Local dashboard (localhost:9154)
-   Status, metrics, blocked domains
-   Optional

* * *

## Implementation Priority

| # | Feature | Priority | Difficulty |
| --- | --- | --- | --- |
| 11 | Deduplication PL/EN | ⭐⭐⭐ | Medium |
| 12 | Modularization | ⭐⭐⭐ | Medium |
| 13 | Auto-update blocklist | ⭐⭐⭐ | Low |
| 14 | Backup/Restore | ⭐⭐⭐ | Low |
| 15 | DNS Cache Stats | ⭐⭐ | Low |
| 16 | Desktop Notifications | ⭐⭐ | Low |
| 17 | Multi-blocklist | ⭐⭐ | Medium |
| 18 | Web Dashboard | ⭐ | High |

**Recommended Order:** #13 → #14 → #11 → #12 → #15 → #17 → #16 → #18

* * *

_Documentation generated: 2026-01-25_ _Author: QguAr71_ _Project: [https://github.com/QguAr71/Cytadela](https://github.com/QguAr71/Cytadela)_
