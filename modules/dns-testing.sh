#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ DNS TESTING MODULE v3.2                                     ║
# ║  Multi-level DNS connectivity testing with system resolver detection   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Test hosts
TEST_DNS_HOSTS=("google.com" "cloudflare.com" "github.com")

# Direct DNS servers (fallback testing)
DIRECT_DNS_SERVERS=("1.1.1.1" "8.8.8.8" "9.9.9.9" "208.67.222.222")

# Timeouts and retries
DNS_TEST_TIMEOUT=3
DNS_TEST_RETRIES=2
DNS_SYSTEM_TIMEOUT=3

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE:-}[DNS-TEST]${NC:-} $1" >&2
}

log_success() {
    echo -e "${GREEN:-}[DNS-TEST]${NC:-} $1" >&2
}

log_warning() {
    echo -e "${YELLOW:-}[DNS-TEST]${NC:-} $1" >&2
}

log_error() {
    echo -e "${RED:-}[DNS-TEST]${NC:-} $1" >&2
}

# ============================================================================
# LEVEL 1: SYSTEM DNS TESTING
# ============================================================================

test_system_dns() {
    log_info "${T_TESTING_SYSTEM_DNS:-Testing system DNS resolution...}"

    # Test 1: nslookup with system resolver
    if nslookup -timeout="$DNS_SYSTEM_TIMEOUT" "${TEST_DNS_HOSTS[0]}" >/dev/null 2>&1; then
        log_success "${T_NSLOOKUP_WORKS:-nslookup works with system resolver}"
        return 0
    fi

    # Test 2: getent hosts (glibc resolver)
    if getent hosts "${TEST_DNS_HOSTS[0]}" >/dev/null 2>&1; then
        log_success "${T_GETENT_WORKS:-getent hosts works}"
        return 0
    fi

    # Test 3: host command
    if host -t A -W "$DNS_SYSTEM_TIMEOUT" "${TEST_DNS_HOSTS[0]}" >/dev/null 2>&1; then
        log_success "${T_HOST_WORKS:-host command works}"
        return 0
    fi

    log_warning "${T_SYSTEM_DNS_FAILED:-System DNS resolution failed}"
    return 1
}

# ============================================================================
# LEVEL 2: SYSTEM SERVICE TESTING
# ============================================================================

test_system_resolvers() {
    log_info "${T_TESTING_SYSTEM_SERVICES:-Testing system DNS services...}"

    # Test systemd-resolved
    if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        log_info "${T_TESTING_RESOLVED:-Testing systemd-resolved...}"
        if resolvectl query "${TEST_DNS_HOSTS[0]}" >/dev/null 2>&1; then
            log_success "${T_RESOLVED_WORKS:-systemd-resolved works}"
            return 0
        else
            log_warning "${T_RESOLVED_FAILED:-systemd-resolved query failed}"
        fi
    fi

    # Test NetworkManager
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        log_info "${T_TESTING_NM:-Testing NetworkManager DNS...}"
        if nmcli dev show 2>/dev/null | grep -q "DNS"; then
            if nslookup -timeout="$DNS_SYSTEM_TIMEOUT" "${TEST_DNS_HOSTS[0]}" >/dev/null 2>&1; then
                log_success "${T_NM_WORKS:-NetworkManager DNS works}"
                return 0
            else
                log_warning "${T_NM_FAILED:-NetworkManager DNS failed}"
            fi
        else
            log_info "${T_NM_NO_DNS:-NetworkManager has no DNS configured}"
        fi
    fi

    # Test dhcpcd
    if systemctl is-active --quiet dhcpcd 2>/dev/null; then
        log_info "${T_TESTING_DHCPCD:-Testing dhcpcd DNS...}"
        if nslookup -timeout="$DNS_SYSTEM_TIMEOUT" "${TEST_DNS_HOSTS[0]}" >/dev/null 2>&1; then
            log_success "${T_DHCPCD_WORKS:-dhcpcd DNS works}"
            return 0
        else
            log_warning "${T_DHCPCD_FAILED:-dhcpcd DNS failed}"
        fi
    fi

    log_warning "${T_SYSTEM_SERVICES_FAILED:-No working system DNS services found}"
    return 1
}

# ============================================================================
# LEVEL 3: DIRECT SERVER TESTING
# ============================================================================

test_direct_servers() {
    log_info "${T_TESTING_DIRECT_SERVERS:-Testing direct DNS servers...}"

    for server in "${DIRECT_DNS_SERVERS[@]}"; do
        log_info "${T_TESTING_SERVER:-Testing server:} $server"

        # Use more tolerant dig settings
        if dig +time="$DNS_TEST_TIMEOUT" +tries="$DNS_TEST_RETRIES" @"$server" "${TEST_DNS_HOSTS[0]}" >/dev/null 2>&1; then
            log_success "${T_SERVER_WORKS:-Direct DNS server works:} $server"
            return 0
        else
            log_warning "${T_SERVER_FAILED:-Direct DNS server failed:} $server"
        fi
    done

    log_warning "${T_DIRECT_SERVERS_FAILED:-All direct DNS servers failed}"
    return 1
}

# ============================================================================
# LEVEL 4: DIAGNOSTICS
# ============================================================================

diagnose_dns_issues() {
    log_info "${T_DIAGNOSING_ISSUES:-Diagnosing DNS connectivity issues...}"

    # Check firewall rules
    if command -v nft >/dev/null 2>&1; then
        if nft list ruleset 2>/dev/null | grep -q "drop.*53\|reject.*53"; then
            log_warning "${T_FIREWALL_BLOCKING:-Firewall may be blocking DNS queries (UDP port 53)}"
        fi
    fi

    # Check IPv6 connectivity
    if ! ping -6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        log_warning "${T_IPV6_ISSUES:-IPv6 connectivity issues detected - DNS may work only with IPv4}"
    fi

    # Check routing to DNS servers
    for server in "${DIRECT_DNS_SERVERS[@]}"; do
        if ! ip route get "$server" >/dev/null 2>&1; then
            log_warning "${T_ROUTING_ISSUE:-No route to DNS server:} $server"
        fi
    done

    # Check /etc/resolv.conf
    if [[ ! -f /etc/resolv.conf ]] || ! grep -q "^nameserver" /etc/resolv.conf; then
        log_warning "${T_RESOLV_CONF_ISSUE:-/etc/resolv.conf may be misconfigured or missing nameservers}"
    fi

    # Check if DNS service is running
    if ! pgrep -x "systemd-resolved\|dnsmasq\|named\|unbound" >/dev/null 2>&1; then
        log_warning "${T_NO_DNS_SERVICE:-No local DNS service detected (systemd-resolved, dnsmasq, bind, unbound)}"
    fi
}

# ============================================================================
# MAIN DNS CONNECTIVITY TEST
# ============================================================================

test_dns_connectivity() {
    log_info "${T_STARTING_DNS_TEST:-Starting comprehensive DNS connectivity test...}"

    # Level 1: System DNS resolution
    if test_system_dns; then
        log_success "${T_DNS_WORKING_VIA_SYSTEM:-DNS connectivity verified via system resolver}"
        return 0
    fi

    # Level 2: System service resolvers
    if test_system_resolvers; then
        log_success "${T_DNS_WORKING_VIA_SERVICES:-DNS connectivity verified via system services}"
        return 0
    fi

    # Level 3: Direct server testing (fallback)
    if test_direct_servers; then
        log_success "${T_DNS_WORKING_VIA_DIRECT:-DNS connectivity verified via direct servers}"
        return 0
    fi

    # Level 4: Diagnostics and suggestions
    diagnose_dns_issues

    log_error "${T_DNS_TEST_FAILED:-DNS connectivity test failed - internet may not work properly}"
    return 1
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Quick DNS health check (for other modules)
check_dns_health() {
    # Simple check - just one quick test
    if nslookup -timeout=2 google.com >/dev/null 2>&1; then
        echo "DNS_OK"
        return 0
    else
        echo "DNS_FAIL"
        return 1
    fi
}

# Get current DNS configuration summary
get_dns_config() {
    echo "=== DNS CONFIGURATION SUMMARY ==="

    echo "1. /etc/resolv.conf:"
    cat /etc/resolv.conf 2>/dev/null || echo "  File not readable"

    echo ""
    echo "2. systemd-resolved status:"
    if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
        echo "  Active"
        resolvectl status 2>/dev/null | grep -E "(DNS Servers|Current DNS)" | head -3 || echo "  Status not readable"
    else
        echo "  Not active"
    fi

    echo ""
    echo "3. NetworkManager DNS:"
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        nmcli dev show 2>/dev/null | grep -A2 "DNS" || echo "  No DNS info available"
    else
        echo "  Not active"
    fi
}

# ============================================================================
# MODULE LOADING CHECK
# ============================================================================

# Check if module loaded correctly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "DNS Testing Module v3.2"
    echo "Usage: source $0 in other scripts"
    echo ""
    echo "Available functions:"
    echo "  test_dns_connectivity    - Full multi-level DNS test"
    echo "  check_dns_health         - Quick DNS health check"
    echo "  get_dns_config           - Show current DNS configuration"
    exit 1
fi
