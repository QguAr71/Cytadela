#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ REGRESSION TESTS v3.2                                       ║
# ║  Testing backward compatibility of all legacy commands                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Test configuration
REGRESSION_LOG="test/regression/regression-tests-$(date +%Y%m%d-%H%M%S).log"
PASSED_TESTS=0
FAILED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_test() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [REGRESSION] $*" | tee -a "$REGRESSION_LOG"
}

log_pass() {
    echo -e "${GREEN}✓ PASS:${NC} $*" | tee -a "$REGRESSION_LOG"
    ((PASSED_TESTS++))
}

log_fail() {
    echo -e "${RED}✗ FAIL:${NC} $*" | tee -a "$REGRESSION_LOG"
    ((FAILED_TESTS++))
}

log_warn() {
    echo -e "${YELLOW}⚠ WARN:${NC} $*" | tee -a "$REGRESSION_LOG"
}

log_info() {
    echo -e "${BLUE}ℹ INFO:${NC} $*" | tee -a "$REGRESSION_LOG"
}

# Setup test environment
setup_regression_env() {
    log_test "Setting up regression test environment..."

    mkdir -p test/regression

    # Create test log header
    cat > "$REGRESSION_LOG" << EOF
Citadel v3.2 Regression Tests
Started: $(date)
Test Environment: $(uname -a)
Bash Version: $BASH_VERSION
Working Directory: $(pwd)

Testing backward compatibility of legacy commands with unified modules.
EOF

    log_pass "Regression test environment setup complete"
}

# Test legacy command compatibility
test_legacy_command() {
    local cmd="$1"
    local expected_pattern="$2"
    local description="$3"

    log_test "Testing legacy command: $cmd ($description)"

    # Run command and check if it executes without critical errors
    if output=$(./citadel.sh "$cmd" 2>&1); then
        # Check for specific success patterns
        if [[ -n "$expected_pattern" ]] && echo "$output" | grep -q "$expected_pattern"; then
            log_pass "Command '$cmd' executed successfully with expected output"
            return 0
        elif [[ -z "$expected_pattern" ]] && ! echo "$output" | grep -qi "unknown\|error\|failed\|not found"; then
            log_pass "Command '$cmd' executed without errors"
            return 0
        else
            log_fail "Command '$cmd' executed but output doesn't match expected pattern"
            echo "  Output: $output" >> "$REGRESSION_LOG"
            return 1
        fi
    else
        # Command failed - check if it's due to root requirement (expected)
        if echo "$output" | grep -q "wymaga uprawnień root\|requires root"; then
            log_pass "Command '$cmd' properly requires root privileges"
            return 0
        else
            log_fail "Command '$cmd' failed unexpectedly"
            echo "  Error: $output" >> "$REGRESSION_LOG"
            return 1
        fi
    fi
}

# Test recovery commands
test_recovery_commands() {
    log_test "Testing Recovery Module Commands..."

    # Panic commands
    test_legacy_command "panic-status" "Panic mode" "Check panic status"
    test_legacy_command "emergency-network-restore" "EMERGENCY NETWORK RESTORE" "Emergency network restore"

    # Restore commands
    test_legacy_command "restore-system" "System Restore" "System restore"
    test_legacy_command "restore-system-default" "System Restore" "Default system restore"
}

# Test installation commands
test_installation_commands() {
    log_test "Testing Installation Module Commands..."

    # Core installation
    test_legacy_command "install-dnscrypt" "DNSCrypt-Proxy" "DNSCrypt installation"
    test_legacy_command "install-coredns" "CoreDNS" "CoreDNS installation"
    test_legacy_command "install-nftables" "NFTables" "Firewall installation"
    test_legacy_command "install-dashboard" "TERMINAL DASHBOARD" "Dashboard installation"
    test_legacy_command "install-all" "FULL INSTALLATION" "Complete installation"

    # System configuration
    test_legacy_command "configure-system" "System Configuration" "System configuration"
    test_legacy_command "firewall-safe" "Safe Mode" "Safe firewall mode"
    test_legacy_command "firewall-strict" "Strict Mode" "Strict firewall mode"

    # Dependencies
    test_legacy_command "check-dependencies" "MISSING DEPENDENCIES" "Dependency check"
}

# Test security commands
test_security_commands() {
    log_test "Testing Security Module Commands..."

    # Integrity
    test_legacy_command "integrity-check" "Integrity check" "Integrity verification"
    test_legacy_command "integrity-status" "INTEGRITY STATUS" "Integrity status"

    # Location
    test_legacy_command "location-check" "LOCATION SECURITY" "Location check"
    test_legacy_command "location-status" "LOCATION STATUS" "Location status"
    test_legacy_command "location-list-trusted" "TRUSTED NETWORKS" "List trusted networks"

    # Supply chain
    test_legacy_command "supply-chain-init" "SUPPLY CHAIN INIT" "Supply chain init"
    test_legacy_command "supply-chain-verify" "SUPPLY CHAIN VERIFY" "Supply chain verify"

    # Ghost check
    test_legacy_command "ghost-check" "GHOST CHECK" "Security audit"

    # NFT debug
    test_legacy_command "nft-debug-status" "DEBUG STATUS" "NFT debug status"
}

# Test network commands
test_network_commands() {
    log_test "Testing Network Module Commands..."

    # IPv6
    test_legacy_command "ipv6-privacy-on" "IPv6 PRIVACY ON" "IPv6 privacy enable"
    test_legacy_command "ipv6-privacy-off" "IPv6 PRIVACY OFF" "IPv6 privacy disable"
    test_legacy_command "ipv6-privacy-status" "IPv6 PRIVACY STATUS" "IPv6 privacy status"
    test_legacy_command "ipv6-privacy-auto" "IPv6 PRIVACY AUTO" "IPv6 privacy auto"

    # Edit tools
    test_legacy_command "edit" "not found" "Edit CoreDNS config (should require root)"
    test_legacy_command "edit-dnscrypt" "not found" "Edit DNSCrypt config (should require root)"
    test_legacy_command "logs" "system logs" "Show logs"

    # Port fixing
    test_legacy_command "fix-ports" "PORT CONFLICT" "Port conflict fixing"

    # Notifications
    test_legacy_command "notify-status" "NOTIFICATION STATUS" "Notification status"
}

# Test adblock commands
test_adblock_commands() {
    log_test "Testing Adblock Module Commands..."

    # Adblock management
    test_legacy_command "adblock-status" "ADBLOCK STATUS" "Adblock status"
    test_legacy_command "adblock-stats" "ADBLOCK STATS" "Adblock statistics"
    test_legacy_command "adblock-show" "0.0.0.0" "Show adblock list"

    # Domain management
    test_legacy_command "adblock-add test-domain.com" "added to" "Add domain to blocklist"
    test_legacy_command "adblock-remove test-domain.com" "removed" "Remove domain from blocklist"

    # Blocklist management
    test_legacy_command "blocklist-list" "Available profiles" "List blocklist profiles"
    test_legacy_command "blocklist-status" "BLOCKLIST STATUS" "Blocklist status"

    # Allowlist
    test_legacy_command "allowlist-list" "" "List allowlist"
    test_legacy_command "allowlist-add test-allow.com" "added to allowlist" "Add to allowlist"
}

# Test backup commands
test_backup_commands() {
    log_test "Testing Backup Module Commands..."

    # Config backup
    test_legacy_command "config-list" "Available backups" "List backups"
    test_legacy_command "config-backup" "Backup created" "Create backup"

    # LKG
    test_legacy_command "lkg-status" "LKG STATUS" "LKG status"
    test_legacy_command "lists-update" "LISTS UPDATE" "Update blocklists"

    # Auto-update
    test_legacy_command "auto-update-status" "AUTO-UPDATE STATUS" "Auto-update status"
}

# Test monitor commands
test_monitor_commands() {
    log_test "Testing Monitor Module Commands..."

    # Diagnostics
    test_legacy_command "diagnostics" "CITADEL++ DIAGNOSTICS" "Run diagnostics"
    test_legacy_command "verify-stack" "CITADEL++ VERIFY" "Verify configuration"
    test_legacy_command "test-all" "CITADELA++ TEST-ALL" "Run all tests"
    test_legacy_command "status" "CYTADELA++ STATUS" "Show status"

    # Cache stats
    test_legacy_command "cache-stats" "CACHE STATISTICS" "Cache statistics"
    test_legacy_command "cache-stats-top" "TOP DOMAINS" "Top domains"

    # Health
    test_legacy_command "health-status" "HEALTH STATUS" "Health status"

    # Prometheus
    test_legacy_command "prometheus-status" "PROMETHEUS STATUS" "Prometheus status"

    # Benchmarks
    test_legacy_command "benchmark-report" "BENCHMARK REPORTS" "Benchmark reports"
}

# Generate regression summary
generate_regression_summary() {
    local total_tests=$((PASSED_TESTS + FAILED_TESTS))
    local success_rate=0

    if [[ $total_tests -gt 0 ]]; then
        success_rate=$((PASSED_TESTS * 100 / total_tests))
    fi

    cat >> "$REGRESSION_LOG" << EOF

=== REGRESSION TEST SUMMARY ===
Total Tests: $total_tests
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Success Rate: ${success_rate}%

Test completed: $(date)
EOF

    echo ""
    echo "=== REGRESSION TEST SUMMARY ==="
    echo "Total Tests: $total_tests"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Success Rate: ${success_rate}%"
    echo ""
    echo "Detailed log: $REGRESSION_LOG"

    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All regression tests passed!${NC}"
        echo "✅ Backward compatibility fully maintained"
        return 0
    else
        echo -e "${RED}❌ Some regression tests failed. Check log for details.${NC}"
        echo "⚠️  Backward compatibility may have issues"
        return 1
    fi
}

# Main regression test runner
main() {
    echo "Citadel v3.2 Regression Tests"
    echo "================================="
    echo ""
    echo "Testing backward compatibility of legacy commands..."
    echo "This ensures all old commands still work with unified modules."
    echo ""

    setup_regression_env

    # Run all regression test suites
    test_recovery_commands
    echo ""
    test_installation_commands
    echo ""
    test_security_commands
    echo ""
    test_network_commands
    echo ""
    test_adblock_commands
    echo ""
    test_backup_commands
    echo ""
    test_monitor_commands
    echo ""

    # Generate summary
    generate_regression_summary
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
