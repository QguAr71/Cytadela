#!/usr/bin/env bats
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Installation Integration Tests                                 ║
# ║  Test complete installation process and system integration                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

load '../test-helper.bash'

# Test prerequisites
@test "system has required prerequisites" {
    # Check if running as root
    [ "$EUID" -eq 0 ] || skip "Tests must run as root"
    
    # Check basic commands
    command -v systemctl >/dev/null
    command -v iptables >/dev/null || command -v nft >/dev/null
    command -v dig >/dev/null || command -v nslookup >/dev/null
}

@test "cytadela.sh script exists and is executable" {
    [ -f "${PROJECT_ROOT}/citadel.sh" ]
    [ -x "${PROJECT_ROOT}/citadel.sh" ]
}

@test "check-deps command works" {
    run "${PROJECT_ROOT}/citadel.sh" check-deps
    [ "$status" -eq 0 ]
    [[ "$output" =~ "All dependencies satisfied" ]] || [[ "$output" =~ "Missing dependencies" ]]
}

@test "install-wizard command exists" {
    run "${PROJECT_ROOT}/citadel.sh" install-wizard --help
    [ "$status" -eq 1 ]  # Should fail without proper args
    [[ "$output" =~ "install-wizard" ]]
}

# Test individual component installation
@test "install-all command exists" {
    run "${PROJECT_ROOT}/citadel.sh" install-all --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "install-all" ]]
}

@test "install-dnscrypt command exists" {
    run "${PROJECT_ROOT}/citadel.sh" install-dnscrypt --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "install-dnscrypt" ]]
}

@test "install-coredns command exists" {
    run "${PROJECT_ROOT}/citadel.sh" install-coredns --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "install-coredns" ]]
}

@test "install-nftables command exists" {
    run "${PROJECT_ROOT}/citadel.sh" install-nftables --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "install-nftables" ]]
}

# Test system integration
@test "systemd services can be managed" {
    # Check if systemd is available
    command -v systemctl >/dev/null || skip "systemd not available"
    
    # Test systemctl basic functionality
    run systemctl --version
    [ "$status" -eq 0 ]
    
    # Check if we can query services
    run systemctl list-unit-files --type=service | grep -E "(dnscrypt|coredns|nftables)" || true
    # Services might not be installed yet, that's OK
}

@test "network interfaces are available" {
    # Check if network interfaces exist
    run ip link show
    [ "$status" -eq 0 ]
    
    # Should have at least loopback interface
    [[ "$output" =~ "lo:" ]]
    
    # Should have at least one non-loopback interface
    run ip link show | grep -v "lo:" | grep "^[0-9]"
    [ "$status" -eq 0 ]
}

@test "DNS resolution works before installation" {
    # Test basic DNS resolution
    if command -v dig >/dev/null 2>&1; then
        run dig +short google.com
        [ "$status" -eq 0 ]
        [ -n "$output" ]
    elif command -v nslookup >/dev/null 2>&1; then
        run nslookup google.com
        [ "$status" -eq 0 ]
    else
        skip "No DNS resolution tools available"
    fi
}

# Test installation process (dry run where possible)
@test "installation process can start" {
    # Test if we can begin installation
    # We won't actually install to avoid system changes
    
    # Check if install script can be sourced
    run bash -n "${PROJECT_ROOT}/citadel.sh"
    [ "$status" -eq 0 ]
    
    # Check if modules are loadable
    run bash -c "source '${PROJECT_ROOT}/lib/module-loader.sh' && echo 'Module loader OK'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Module loader OK" ]]
}

@test "core libraries can be loaded" {
    # Test if core libraries can be sourced
    run bash -c "source '${PROJECT_ROOT}/lib/cytadela-core.sh' && echo 'Core library OK'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Core library OK" ]]
    
    run bash -c "source '${PROJECT_ROOT}/lib/network-utils.sh' && echo 'Network utils OK'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Network utils OK" ]]
}

@test "modules directory structure is correct" {
    # Check if modules directory exists
    [ -d "${PROJECT_ROOT}/modules" ]
    
    # Check if key modules exist
    [ -f "${PROJECT_ROOT}/modules/diagnostics.sh" ]
    [ -f "${PROJECT_ROOT}/modules/adblock.sh" ]
    [ -f "${PROJECT_ROOT}/modules/ipv6.sh" ]
    [ -f "${PROJECT_ROOT}/modules/emergency.sh" ]
    
    # Check if modules have proper shebang
    run head -n1 "${PROJECT_ROOT}/modules/diagnostics.sh"
    [[ "$output" =~ "#!/bin/bash" ]]
}

@test "module syntax is valid" {
    # Check syntax of all modules
    for module in "${PROJECT_ROOT}/modules"/*.sh; do
        if [ -f "$module" ]; then
            run bash -n "$module"
            [ "$status" -eq 0 ] || {
                echo "Syntax error in $module"
                false
            }
        fi
    done
}

@test "configuration files can be created" {
    # Test if we can create configuration directories
    local test_config_dir="${PROJECT_ROOT}/tests/test-config"
    mkdir -p "$test_config_dir"
    
    # Test creating a sample config
    cat > "$test_config_dir/test.conf" << 'EOF'
# Test configuration
listen_port = 5353
server_name = test
EOF
    
    [ -f "$test_config_dir/test.conf" ]
    
    # Clean up
    rm -rf "$test_config_dir"
}

@test "log directories can be created" {
    # Test if we can create log directories
    local test_log_dir="${PROJECT_ROOT}/tests/test-logs"
    mkdir -p "$test_log_dir"
    
    # Test creating a log file
    echo "Test log entry" > "$test_log_dir/test.log"
    
    [ -f "$test_log_dir/test.log" ]
    
    # Clean up
    rm -rf "$test_log_dir"
}

@test "backup directories can be created" {
    # Test if we can create backup directories
    local test_backup_dir="${PROJECT_ROOT}/tests/test-backup"
    mkdir -p "$test_backup_dir"
    
    # Test creating a backup file
    tar -czf "$test_backup_dir/test-backup.tar.gz" -C "${PROJECT_ROOT}/tests" README.md
    
    [ -f "$test_backup_dir/test-backup.tar.gz" ]
    
    # Clean up
    rm -rf "$test_backup_dir"
}

# Test post-installation verification
@test "status command exists" {
    run "${PROJECT_ROOT}/citadel.sh" status --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "status" ]]
}

@test "verify command exists" {
    run "${PROJECT_ROOT}/citadel.sh" verify --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "verify" ]]
}

@test "diagnostics command exists" {
    run "${PROJECT_ROOT}/citadel.sh" diagnostics --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "diagnostics" ]]
}

# Test error handling
@test "installation handles missing dependencies" {
    # Create a scenario where a dependency is missing
    # This is a dry run test
    
    # Check if check-deps properly reports missing deps
    # We can't actually remove dependencies, but we can test the reporting
    run "${PROJECT_ROOT}/citadel.sh" check-deps
    [ "$status" -eq 0 ]  # Should either succeed or report missing deps
}

@test "installation handles permission errors" {
    # Test with non-root user (should fail gracefully)
    if [ "$EUID" -ne 0 ]; then
        run "${PROJECT_ROOT}/citadel.sh" install-all
        [ "$status" -ne 0 ]
        [[ "$output" =~ "root" ]] || [[ "$output" =~ "permission" ]]
    else
        skip "Running as root, cannot test permission error"
    fi
}

@test "installation handles invalid arguments" {
    # Test with invalid arguments
    run "${PROJECT_ROOT}/citadel.sh" install-all --invalid-flag
    [ "$status" -ne 0 ]
}

# Test cleanup and rollback
@test "rollback functionality exists" {
    # Test if restore commands exist
    run "${PROJECT_ROOT}/citadel.sh" restore-system --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "restore-system" ]]
}

@test "backup functionality exists" {
    # Test if backup commands exist
    run "${PROJECT_ROOT}/citadel.sh" config-backup --help
    [ "$status" -eq 1 ]
    [[ "$output" =~ "config-backup" ]]
}

# Test performance
@test "installation scripts are reasonably fast" {
    # Test script loading time
    local start_time end_time duration
    start_time=$(date +%s%N)
    
    # Source the main script (dry run)
    bash -c "source '${PROJECT_ROOT}/citadel.sh'" >/dev/null 2>&1
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    # Should load in less than 2 seconds
    [ "$duration" -lt 2000 ]
}

@test "module loading is efficient" {
    # Test loading multiple modules
    local start_time end_time duration
    start_time=$(date +%s%N)
    
    # Load several modules
    for module in diagnostics adblock ipv6; do
        bash -c "source '${PROJECT_ROOT}/modules/${module}.sh'" >/dev/null 2>&1
    done
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    # Should load in less than 500ms for 3 modules
    [ "$duration" -lt 500 ]
}

# Test integration with system services
@test "can interact with systemd services" {
    command -v systemctl >/dev/null || skip "systemd not available"
    
    # Test systemctl basic operations
    run systemctl --version
    [ "$status" -eq 0 ]
    
    # Test if we can list services (might be empty)
    run systemctl list-unit-files --type=service --no-pager
    [ "$status" -eq 0 ]
}

@test "can interact with network interfaces" {
    command -v ip >/dev/null || skip "ip command not available"
    
    # Test ip command basic operations
    run ip --version
    [ "$status" -eq 0 ]
    
    # Test listing interfaces
    run ip link show
    [ "$status" -eq 0 ]
    
    # Should have loopback
    [[ "$output" =~ "lo:" ]]
}

@test "can interact with firewall" {
    # Test with nftables or iptables
    if command -v nft >/dev/null 2>&1; then
        run nft --version
        [ "$status" -eq 0 ]
        
        run nft list tables
        [ "$status" -eq 0 ]
    elif command -v iptables >/dev/null 2>&1; then
        run iptables --version
        [ "$status" -eq 0 ]
        
        run iptables -L
        [ "$status" -eq 0 ]
    else
        skip "No firewall tool available"
    fi
}
