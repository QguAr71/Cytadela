# DNS Testing Module Documentation
# Cytadela Multi-Level DNS Connectivity Testing
# Version: 3.2
# Date: 2026-02-06

---

## Overview

The `dns-testing.sh` module provides advanced, multi-level DNS connectivity testing for the Citadel uninstaller. It replaces the previous single-command DNS test with a comprehensive, intelligent testing system that prevents false-positive failures.

## Architecture

### Module Structure
```
modules/dns-testing.sh
├── test_dns_connectivity()          # Main entry point
├── test_system_dns()               # Level 1: System resolvers
├── test_system_resolvers()         # Level 2: System services
├── test_direct_servers()           # Level 3: Direct DNS servers
├── diagnose_dns_issues()           # Level 4: Problem diagnostics
├── check_dns_health()              # Utility: Quick health check
└── get_dns_config()                # Utility: Configuration summary
```

### Multi-Level Testing Approach

The module uses a progressive testing strategy:

1. **Level 1: System DNS** - Tests native system resolvers (nslookup, getent, host)
2. **Level 2: System Services** - Tests systemd-resolved, NetworkManager, dhcpcd
3. **Level 3: Direct Servers** - Tests direct DNS servers with tolerance (dig with timeouts)
4. **Level 4: Diagnostics** - Analyzes firewall, IPv6, routing issues

## API Reference

### test_dns_connectivity()

**Purpose:** Main function for comprehensive DNS connectivity testing

**Returns:**
- `0` - DNS connectivity verified
- `1` - DNS connectivity failed

**Usage:**
```bash
if test_dns_connectivity; then
    echo "DNS is working"
else
    echo "DNS has issues"
fi
```

**Flow:**
```
Start testing
├── Level 1: System DNS
│   └── Success → Return OK
├── Level 2: System Services
│   └── Success → Return OK
├── Level 3: Direct Servers
│   └── Success → Return OK
└── Level 4: Diagnostics
    └── Show issues → Return FAIL
```

### test_system_dns()

**Purpose:** Tests system-level DNS resolution

**Tests:**
- `nslookup google.com` - System resolver test
- `getent hosts google.com` - glibc resolver test
- `host google.com` - Host command test

**Returns:** 0 on success, 1 on failure

### test_system_resolvers()

**Purpose:** Tests system DNS services

**Tests:**
- `systemd-resolved` - Via resolvectl
- `NetworkManager` - Via nmcli + nslookup
- `dhcpcd` - Via direct nslookup

**Returns:** 0 on success, 1 on failure

### test_direct_servers()

**Purpose:** Tests direct DNS server connectivity

**Tests:**
- `1.1.1.1` (Cloudflare)
- `8.8.8.8` (Google)
- `9.9.9.9` (Quad9)
- `208.67.222.222` (OpenDNS)

**Configuration:**
- Timeout: 3 seconds
- Tries: 2 attempts
- Uses `dig` with tolerant settings

**Returns:** 0 on success, 1 on failure

### diagnose_dns_issues()

**Purpose:** Analyzes and reports DNS connectivity problems

**Checks:**
- Firewall blocking UDP/53
- IPv6 connectivity issues
- Routing problems
- Configuration issues (/etc/resolv.conf)
- Missing DNS services

**Output:** Detailed diagnostic messages in Polish

## Configuration

### Constants
```bash
TEST_DNS_HOSTS=("google.com" "cloudflare.com" "github.com")
DIRECT_DNS_SERVERS=("1.1.1.1" "8.8.8.8" "9.9.9.9" "208.67.222.222")
DNS_TEST_TIMEOUT=3
DNS_TEST_RETRIES=2
DNS_SYSTEM_TIMEOUT=3
```

### Logging
- Uses `[DNS-TEST]` prefix for log messages
- Integrates with Citadel logging system
- Supports both stderr and log file output

## Integration

### Uninstall.sh Integration
```bash
# Load the module
if [[ -f "modules/dns-testing.sh" ]]; then
    source "modules/dns-testing.sh"
fi

# Use in uninstall flow
if ! test_dns_connectivity; then
    offer_emergency_recovery
fi
```

### Translation Support
All messages use translation variables from `lib/i18n/uninstall/pl.sh`:

- `T_STARTING_DNS_TEST` - "Rozpoczynanie kompleksowego testu..."
- `T_TESTING_SYSTEM_DNS` - "Testowanie rozwiązywania nazw..."
- `T_DNS_OK` - "DNS connectivity verified via"
- `T_DNS_TEST_FAILED` - "DNS connectivity test failed"

## Benefits

### Accuracy
- **Eliminates false positives** from the old dig-only test
- **Recognizes different DNS systems** (systemd-resolved, NetworkManager, etc.)
- **Provides detailed diagnostics** instead of binary pass/fail

### Safety
- **Doesn't panic users** with unnecessary emergency options
- **Tests actual system functionality** rather than direct server access
- **Progressive testing** - stops at first working level

### Compatibility
- **Works with all DNS configurations** (local, remote, VPN, etc.)
- **Handles different Linux distributions** and network setups
- **Unicode-only output** for terminal compatibility

## Testing

### Manual Testing
```bash
# Load and test
source modules/dns-testing.sh
test_dns_connectivity

# Quick health check
check_dns_health

# Configuration summary
get_dns_config
```

### Integration Testing
The module is automatically tested during uninstall operations that encounter DNS issues.

## Future Enhancements

### Possible Improvements
- IPv6-specific testing
- DNSSEC validation testing
- Performance benchmarking
- Custom DNS server testing
- Integration with Citadel monitoring

### Compatibility Notes
- Requires `dig`, `nslookup`, `getent`, `host` commands
- Works with all Citadel-supported Linux distributions
- Compatible with VPN and proxy configurations

---

## Summary

The DNS Testing Module provides Citadel with intelligent, multi-level DNS connectivity testing that prevents false-positive failures and provides users with accurate diagnostic information. It replaces the previous simplistic dig-based test with a comprehensive system that understands different DNS configurations and provides appropriate feedback.

**Status:** ✅ Production Ready
**Integration:** ✅ Complete
**Documentation:** ✅ Current
