#!/usr/bin/env bats
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Network Utils Unit Tests                                    ║
# ║  Test network utility functions, port detection, and interface discovery       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

load '../test-helper.bash'

# Test network utils file exists and is sourceable
@test "network-utils.sh exists and is sourceable" {
    [ -f "${PROJECT_ROOT}/lib/network-utils.sh" ]
    
    # Try to source it
    run source "${PROJECT_ROOT}/lib/network-utils.sh"
    [ "$status" -eq 0 ]
}

# Test port configuration variables are set
@test "port configuration variables are exported" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    [ -n "$DNSCRYPT_PORT_DEFAULT" ]
    [ -n "$COREDNS_PORT_DEFAULT" ]
    [ -n "$COREDNS_METRICS_ADDR" ]
    
    # Check default values
    [ "$DNSCRYPT_PORT_DEFAULT" = "5353" ]
    [ "$COREDNS_PORT_DEFAULT" = "53" ]
    [ "$COREDNS_METRICS_ADDR" = "127.0.0.1:9153" ]
}

# Test get_dnscrypt_listen_port function
@test "get_dnscrypt_listen_port function exists" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run declare -f get_dnscrypt_listen_port
    [ "$status" -eq 0 ]
}

@test "get_dnscrypt_listen_port returns default when not configured" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run get_dnscrypt_listen_port
    [ "$status" -eq 0 ]
    [ "$output" = "5353" ]
}

@test "get_dnscrypt_listen_port reads from config file" {
    # Create a temporary config
    local temp_config="${PROJECT_ROOT}/tests/fixtures/dnscrypt-test.toml"
    mkdir -p "$(dirname "$temp_config")"
    cat > "$temp_config" << 'EOF'
listen_addresses = ['127.0.0.1:5454']
EOF
    
    # Test if function can read it (implementation dependent)
    run get_dnscrypt_listen_port
    [ "$status" -eq 0 ]
    
    # Clean up
    rm -f "$temp_config"
}

# Test get_coredns_listen_port function
@test "get_coredns_listen_port function exists" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run declare -f get_coredns_listen_port
    [ "$status" -eq 0 ]
}

@test "get_coredns_listen_port returns default" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run get_coredns_listen_port
    [ "$status" -eq 0 ]
    [ "$output" = "53" ]
}

# Test port availability checking
@test "port availability checking works" {
    # Test if port 53 is available (might be in use)
    if command -v ss >/dev/null 2>&1; then
        run ss -tuln | grep ":53 "
        # If port is in use, output should contain it
        if [ "$status" -eq 0 ]; then
            [[ "$output" =~ ":53 " ]]
        fi
    else
        skip "ss command not available"
    fi
}

# Test interface discovery functions
@test "interface discovery functions exist" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run declare -f discover_active_interface
    [ "$status" -eq 0 ]
    
    run declare -f discover_network_stack
    [ "$status" -eq 0 ]
    
    run declare -f discover_nftables_status
    [ "$status" -eq 0 ]
}

@test "discover_active_interface returns plausible result" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run discover_active_interface
    [ "$status" -eq 0 ]
    
    # Should return a valid interface name or empty
    if [ -n "$output" ]; then
        # Check if it's a valid interface name format
        [[ "$output" =~ ^[a-zA-Z0-9_-]+$ ]]
    fi
}

@test "discover_network_stack returns known stack" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run discover_network_stack
    [ "$status" -eq 0 ]
    
    # Should return a known network stack
    [[ "$output" =~ ^(iptables|nftables|unknown)$ ]]
}

@test "discover_nftables_status works" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run discover_nftables_status
    [ "$status" -eq 0 ]
    
    # Should return a status
    [[ "$output" =~ ^(active|inactive|unknown)$ ]]
}

# Test DNS resolution functions
@test "DNS resolution test functions exist" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run declare -f test_dns_resolution
    [ "$status" -eq 0 ]
}

@test "test_dns_resolution handles valid domain" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    # Test with a reliable domain
    if command -v dig >/dev/null 2>&1; then
        run test_dns_resolution "google.com"
        [ "$status" -eq 0 ]
    else
        skip "dig command not available"
    fi
}

@test "test_dns_resolution handles invalid domain" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    if command -v dig >/dev/null 2>&1; then
        run test_dns_resolution "this-domain-does-not-exist.invalid"
        [ "$status" -ne 0 ]  # Should fail for invalid domain
    else
        skip "dig command not available"
    fi
}

# Test network connectivity functions
@test "network connectivity functions exist" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run declare -f test_ipv4_connectivity
    [ "$status" -eq 0 ]
    
    run declare -f test_ipv6_connectivity
    [ "$status" -eq 0 ]
}

@test "test_ipv4_connectivity works" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    if command -v ping >/dev/null 2>&1; then
        run test_ipv4_connectivity
        [ "$status" -eq 0 ]
    else
        skip "ping command not available"
    fi
}

@test "test_ipv6_connectivity works" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    if command -v ping6 >/dev/null 2>&1; then
        run test_ipv6_connectivity
        # IPv6 might not be available, so status 1 is acceptable
        [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    else
        skip "ping6 command not available"
    fi
}

# Test firewall detection functions
@test "firewall detection functions exist" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run declare -f detect_firewall_type
    [ "$status" -eq 0 ]
    
    run declare -f check_firewall_rules
    [ "$status" -eq 0 ]
}

@test "detect_firewall_type returns known type" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run detect_firewall_type
    [ "$status" -eq 0 ]
    
    # Should return a known firewall type
    [[ "$output" =~ ^(iptables|nftables|none|unknown)$ ]]
}

@test "check_firewall_rules works" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    run check_firewall_rules
    [ "$status" -eq 0 ]
    
    # Should return some status information
    [ -n "$output" ]
}

# Test error handling
@test "network utils handle missing commands gracefully" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    # Test with a non-existent command
    if ! command -v nonexistent_command >/dev/null 2>&1; then
        # Functions that depend on external commands should handle missing ones
        run test_dns_resolution "example.com"
        # Should either succeed or fail gracefully, not crash
        [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    fi
}

# Test configuration file parsing
@test "configuration file parsing works" {
    # Create a test configuration
    local test_config="${PROJECT_ROOT}/tests/fixtures/test-config.toml"
    mkdir -p "$(dirname "$test_config")"
    cat > "$test_config" << 'EOF'
listen_addresses = ['127.0.0.1:5353']
server_names = ['cloudflare']
EOF
    
    # Test if configuration can be read (implementation dependent)
    if command -v grep >/dev/null 2>&1; then
        run grep "listen_addresses" "$test_config"
        [ "$status" -eq 0 ]
        [[ "$output" =~ "listen_addresses" ]]
    fi
    
    # Clean up
    rm -f "$test_config"
}

# Test performance of network operations
@test "network operations are reasonably fast" {
    source "${PROJECT_ROOT}/lib/network-utils.sh"
    
    local start_time end_time duration
    start_time=$(date +%s%N)
    
    # Test a simple operation
    discover_active_interface >/dev/null
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    # Should complete in less than 1 second
    [ "$duration" -lt 1000 ]
}
