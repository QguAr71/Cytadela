#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Automated User Tests                                       ║
# ║  Safe tests for end users to verify installation                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

print_header() {
    echo -e "\n${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}\n"
}

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    echo -e "${YELLOW}  → $2${NC}"
    ((TESTS_FAILED++))
    ((TESTS_TOTAL++))
}

test_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    echo -e "${CYAN}  → $2${NC}"
}

test_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

# ==============================================================================
# TEST FUNCTIONS
# ==============================================================================

test_installation() {
    print_header "Test 1: Installation Check"
    
    # Check if cytadela++ command exists
    if command -v cytadela++ >/dev/null 2>&1; then
        test_pass "cytadela++ command found"
    else
        test_fail "cytadela++ command not found" "Run: sudo ./install.sh"
        return 1
    fi
    
    # Check if /opt/cytadela exists
    if [[ -d /opt/cytadela ]]; then
        test_pass "/opt/cytadela directory exists"
    else
        test_fail "/opt/cytadela directory not found" "Installation incomplete"
        return 1
    fi
    
    # Check version (skip if requires sudo)
    if cytadela++ --version >/dev/null 2>&1; then
        local version
        version=$(cytadela++ --version 2>/dev/null | head -1)
        test_pass "Version check: $version"
    else
        test_info "Version check skipped (requires sudo)"
    fi
}

test_services() {
    print_header "Test 2: Services Status"
    
    # Check CoreDNS
    if systemctl is-active --quiet coredns; then
        test_pass "CoreDNS is running"
    else
        test_fail "CoreDNS is not running" "Run: sudo systemctl start coredns"
    fi
    
    # Check DNSCrypt-Proxy
    if systemctl is-active --quiet dnscrypt-proxy; then
        test_pass "DNSCrypt-Proxy is running"
    else
        test_fail "DNSCrypt-Proxy is not running" "Run: sudo systemctl start dnscrypt-proxy"
    fi
    
    # Check if services are enabled
    if systemctl is-enabled --quiet coredns; then
        test_pass "CoreDNS is enabled (starts on boot)"
    else
        test_warn "CoreDNS is not enabled" "Run: sudo systemctl enable coredns"
    fi
    
    if systemctl is-enabled --quiet dnscrypt-proxy; then
        test_pass "DNSCrypt-Proxy is enabled (starts on boot)"
    else
        test_warn "DNSCrypt-Proxy is not enabled" "Run: sudo systemctl enable dnscrypt-proxy"
    fi
}

test_dns_basic() {
    print_header "Test 3: Basic DNS Functionality"
    
    # Test 1: Can resolve google.com
    if dig +short google.com @127.0.0.1 +time=3 >/dev/null 2>&1; then
        local ip
        ip=$(dig +short google.com @127.0.0.1 +time=3 2>/dev/null | head -1)
        test_pass "DNS resolution works (google.com → $ip)"
    else
        test_fail "Cannot resolve google.com" "Check DNS services: sudo systemctl status coredns"
        return 1
    fi
    
    # Test 2: Can resolve with system DNS
    if dig +short google.com >/dev/null 2>&1; then
        test_pass "System DNS works"
    else
        test_fail "System DNS not working" "Check /etc/resolv.conf"
    fi
    
    # Test 3: Check /etc/resolv.conf
    if grep -q "nameserver 127.0.0.1" /etc/resolv.conf 2>/dev/null; then
        test_pass "/etc/resolv.conf points to localhost"
    else
        test_warn "/etc/resolv.conf doesn't point to localhost" "Run: sudo cytadela++ configure-system"
    fi
}

test_adblock() {
    print_header "Test 4: Adblock Functionality"
    
    # Test known ad domains
    local ad_domains=("ads.google.com" "doubleclick.net" "adservice.google.com")
    local blocked=0
    
    for domain in "${ad_domains[@]}"; do
        local result
        result=$(dig +short "$domain" @127.0.0.1 +time=2 2>/dev/null | head -1)
        if [[ "$result" == "0.0.0.0" ]]; then
            ((blocked++))
        fi
    done
    
    if [[ $blocked -eq ${#ad_domains[@]} ]]; then
        test_pass "Adblock working (${blocked}/${#ad_domains[@]} test domains blocked)"
    elif [[ $blocked -gt 0 ]]; then
        test_warn "Adblock partially working (${blocked}/${#ad_domains[@]} domains blocked)" "Some ads may not be blocked"
    else
        test_fail "Adblock not working" "Check blocklist: sudo cytadela++ adblock-stats"
    fi
}

test_firewall() {
    print_header "Test 5: Firewall Configuration"
    
    # Check if nftables is installed
    if ! command -v nft >/dev/null 2>&1; then
        test_warn "nftables not installed" "Firewall protection unavailable"
        return 0
    fi
    
    # Check if citadel_dns table exists
    if sudo nft list tables 2>/dev/null | grep -q "citadel_dns"; then
        test_pass "Firewall table exists (citadel_dns)"
        
        # Check if rules are present
        local rules_count
        rules_count=$(sudo nft list table inet citadel_dns 2>/dev/null | grep -c "udp dport 53" || true)
        if [[ $rules_count -gt 0 ]]; then
            test_pass "DNS leak protection rules active ($rules_count rules)"
        else
            test_warn "No DNS leak protection rules found" "Run: sudo cytadela++ firewall-strict"
        fi
    else
        test_warn "Firewall not configured" "Run: sudo cytadela++ firewall-strict"
    fi
}

test_dns_leak() {
    print_header "Test 6: DNS Leak Protection"
    
    test_info "Testing if DNS queries leak to ISP..."
    
    # Test 1: Try to query external DNS directly (should fail if firewall is strict)
    if timeout 2 dig +short google.com @8.8.8.8 >/dev/null 2>&1; then
        test_warn "Direct DNS queries to 8.8.8.8 are allowed" "Firewall may not be in STRICT mode"
    else
        test_pass "Direct DNS queries blocked (firewall working)"
    fi
    
    # Test 2: Check if we can reach our own DNS
    if dig +short google.com @127.0.0.1 +time=2 >/dev/null 2>&1; then
        test_pass "Local DNS (127.0.0.1) is reachable"
    else
        test_fail "Cannot reach local DNS" "Check CoreDNS: sudo systemctl status coredns"
    fi
}

test_internet() {
    print_header "Test 7: Internet Connectivity"
    
    # Test 1: Can ping by domain (requires DNS)
    if ping -c 2 -W 3 google.com >/dev/null 2>&1; then
        test_pass "Can ping google.com (DNS + internet working)"
    else
        test_fail "Cannot ping google.com" "Check DNS and internet connection"
        return 1
    fi
    
    # Test 2: Can reach HTTPS
    if curl -s --max-time 5 https://www.google.com >/dev/null 2>&1; then
        test_pass "HTTPS connectivity works"
    else
        test_warn "HTTPS test failed" "May be temporary network issue"
    fi
}

test_dnssec() {
    print_header "Test 8: DNSSEC Validation"
    
    # Test 1: Valid DNSSEC
    if dig sigok.verteiltesysteme.net @127.0.0.1 +time=3 >/dev/null 2>&1; then
        test_pass "Valid DNSSEC signatures accepted"
    else
        test_warn "DNSSEC test domain unreachable" "May be temporary"
    fi
    
    # Test 2: Invalid DNSSEC (should fail)
    if dig sigfail.verteiltesysteme.net @127.0.0.1 +time=3 2>&1 | grep -q "SERVFAIL"; then
        test_pass "Invalid DNSSEC signatures rejected"
    else
        test_warn "DNSSEC validation may not be working" "Check DNSCrypt-Proxy config"
    fi
}

test_performance() {
    print_header "Test 9: Performance Check"
    
    # Test query time
    local query_time
    query_time=$(dig google.com @127.0.0.1 2>/dev/null | grep "Query time:" | awk '{print $4}')
    
    if [[ -n "$query_time" ]]; then
        if [[ $query_time -lt 50 ]]; then
            test_pass "DNS query time: ${query_time}ms (excellent)"
        elif [[ $query_time -lt 100 ]]; then
            test_pass "DNS query time: ${query_time}ms (good)"
        elif [[ $query_time -lt 200 ]]; then
            test_warn "DNS query time: ${query_time}ms (acceptable)" "Consider checking upstream DNS"
        else
            test_warn "DNS query time: ${query_time}ms (slow)" "Check DNSCrypt-Proxy logs"
        fi
    else
        test_warn "Cannot measure query time" "dig may not be installed"
    fi
    
    # Test cache (if available)
    if command -v cytadela++ >/dev/null 2>&1; then
        if sudo cytadela++ cache-stats >/dev/null 2>&1; then
            test_pass "Cache statistics available"
        fi
    fi
}

test_ipv6() {
    print_header "Test 10: IPv6 Support"
    
    # Check if IPv6 is available
    if ip -6 addr show | grep -q "scope global"; then
        test_pass "IPv6 is available on system"
        
        # Test IPv6 DNS
        if dig google.com AAAA @::1 +short +time=3 >/dev/null 2>&1; then
            test_pass "IPv6 DNS resolution works"
        else
            test_warn "IPv6 DNS not working" "May be expected if IPv6 is disabled"
        fi
    else
        test_info "IPv6 not available (this is OK)"
    fi
}

# ==============================================================================
# SUMMARY
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}║${NC}  TEST SUMMARY"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Total tests:  ${CYAN}${TESTS_TOTAL}${NC}"
    echo -e "  Passed:       ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "  Failed:       ${RED}${TESTS_FAILED}${NC}"
    echo ""
    
    local pass_rate=$((TESTS_PASSED * 100 / TESTS_TOTAL))
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed! Cytadela is working correctly.${NC}"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo "  • Visit https://dnsleaktest.com to verify no DNS leaks"
        echo "  • Browse normally - ads should be blocked"
        echo "  • Check cache stats: sudo cytadela++ cache-stats"
        return 0
    elif [[ $pass_rate -ge 80 ]]; then
        echo -e "${YELLOW}⚠ Most tests passed ($pass_rate%), but some issues detected.${NC}"
        echo ""
        echo -e "${CYAN}Recommended actions:${NC}"
        echo "  • Review failed tests above"
        echo "  • Check logs: sudo journalctl -u coredns -n 50"
        echo "  • See troubleshooting: cat TESTING_USER_GUIDE.md"
        return 1
    else
        echo -e "${RED}✗ Multiple tests failed ($pass_rate% passed).${NC}"
        echo ""
        echo -e "${CYAN}Recommended actions:${NC}"
        echo "  • Check service status: sudo systemctl status coredns dnscrypt-proxy"
        echo "  • Review installation: cat INSTALL.md"
        echo "  • Restore system: sudo cytadela++ restore-system"
        return 2
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
===============================================================================

   ██████╗██╗   ██╗████████╗ █████╗ ██████╗ ███████╗██╗      █████╗
  ██╔════╝╚██╗ ██╔╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║     ██╔══██╗
  ██║      ╚████╔╝    ██║   ███████║██║  ██║█████╗  ██║     ███████║
  ██║       ╚██╔╝     ██║   ██╔══██║██║  ██║██╔══╝  ██║     ██╔══██║
  ╚██████╗   ██║      ██║   ██║  ██║██████╔╝███████╗███████╗██║  ██║
   ╚═════╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝

                     Automated User Test Suite

===============================================================================
EOF
    echo -e "${NC}"
    
    test_info "Starting Cytadela++ test suite..."
    test_info "This will take about 30 seconds..."
    test_info "Note: Some tests may require sudo password"
    echo ""
    
    # Run all tests
    test_installation || true
    test_services || true
    test_dns_basic || true
    test_adblock || true
    test_firewall || true
    test_dns_leak || true
    test_internet || true
    test_dnssec || true
    test_performance || true
    test_ipv6 || true
    
    # Print summary
    print_summary
}

# Check if running as root (some tests need it)
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}Warning: Running as root. Some tests may behave differently.${NC}"
    echo ""
fi

main "$@"
