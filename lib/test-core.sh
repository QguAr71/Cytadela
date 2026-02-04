#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ TEST CORE LIBRARY v3.1                                        ║
# ║  Centralized test functions for all modules                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# DNS TEST FUNCTIONS
# ==============================================================================

# Test DNS resolution
test_dns_resolution() {
    local domain="${1:-google.com}"
    local server="${2:-127.0.0.1}"
    
    if dig +short +time=3 +tries=1 "$domain" @"$server" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Test DNS encryption (DNSCrypt)
test_dns_encryption() {
    systemctl is-active --quiet dnscrypt-proxy 2>/dev/null
}

# Test DNS leaks
test_dns_leaks() {
    local external_dns
    external_dns=$(dig +time=3 +tries=1 google.com 2>/dev/null | grep "SERVER:" | awk '{print $2}' || true)
    [[ "$external_dns" == "127.0.0.1"* ]]
}

# Test DNSSEC validation
test_dnssec_validation() {
    local result
    result=$(dig +short +dnssec dnssec-failed.org 2>/dev/null || true)
    [[ -z "$result" ]]
}

# ==============================================================================
# SERVICE TEST FUNCTIONS
# ==============================================================================

# Test if service is active
test_service_active() {
    local service="$1"
    systemctl is-active --quiet "$service" 2>/dev/null
}

# Test service health
test_service_health() {
    local service="$1"
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# NETWORK TEST FUNCTIONS
# ==============================================================================

# Test network connectivity
test_network_connectivity() {
    local target="${1:-1.1.1.1}"
    ping -c 1 -W 3 "$target" >/dev/null 2>&1
}

# Test DNS resolution
test_dns_resolution() {
    local domain="${1:-google.com}"
    dig +short "$domain" @127.0.0.1 +time=3 >/dev/null 2>&1
}

# Test if interface has IP
test_interface_ip() {
    local iface="$1"
    ip addr show dev "$iface" 2>/dev/null | grep -q "inet "
}

# ==============================================================================
# FIREWALL TEST FUNCTIONS
# ==============================================================================

# Test if nftables has citadel rules
test_nftables_citadel() {
    nft list table inet citadel_dns >/dev/null 2>&1
}

# Test if specific port is blocked
test_port_blocked() {
    local port="$1"
    local proto="${2:-udp}"
    nft list ruleset 2>/dev/null | grep -q "${proto} dport ${port} drop"
}

# ==============================================================================
# COMPOSITE TEST FUNCTIONS
# ==============================================================================

# Full DNS stack test
test_dns_full() {
    local results=()
    
    test_dns_resolution && results+=("resolution:OK") || results+=("resolution:FAIL")
    test_dns_encryption && results+=("encryption:OK") || results+=("encryption:FAIL")
    test_dns_leaks && results+=("leaks:OK") || results+=("leaks:FAIL")
    test_dnssec_validation && results+=("dnssec:OK") || results+=("dnssec:FAIL")
    
    echo "${results[*]}"
}

# Full stack test
test_full_stack() {
    local failed=0
    
    # Test services
    test_service_active "dnscrypt-proxy" || ((failed++))
    test_service_active "coredns" || ((failed++))
    
    # Test DNS
    test_dns_resolution || ((failed++))
    
    # Test firewall
    test_nftables_citadel || ((failed++))
    
    return $failed
}
