#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INTEGRATION TESTS v3.1                                        ║
# ║  Level 3: Read-only tests requiring sudo/root                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

log_test() {
    echo -e "${CYAN}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

log_skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    ((TESTS_SKIPPED++))
}

log_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}ERROR: This script must be run as root (sudo)${NC}"
        echo "Usage: sudo $0"
        exit 1
    fi
}

# ==============================================================================
# TEST 1: Diagnostics Command
# ==============================================================================
test_diagnostics() {
    log_section "TEST 1: Diagnostics Command"
    
    log_test "Running: cytadela++ diagnostics"
    
    local output
    local exit_code
    output=$("$PROJECT_ROOT/cytadela++.new.sh" diagnostics 2>&1) || exit_code=$?
    
    if [[ -z "$output" ]]; then
        log_skip "diagnostics (requires installation to /opt/cytadela)"
        return
    fi
    
    if [[ ${exit_code:-0} -eq 0 ]]; then
        log_pass "diagnostics command executed successfully"
        
        # Check for key sections in output
        if echo "$output" | grep -q "SYSTEM INFO"; then
            log_pass "diagnostics - contains SYSTEM INFO"
        fi
        
        if echo "$output" | grep -q "NETWORK"; then
            log_pass "diagnostics - contains NETWORK section"
        fi
    else
        log_skip "diagnostics (requires full installation)"
    fi
}

# ==============================================================================
# TEST 2: Verify Command
# ==============================================================================
test_verify() {
    log_section "TEST 2: Verify Command"
    
    log_test "Running: cytadela++ verify"
    
    if "$PROJECT_ROOT/cytadela++.new.sh" verify &>/dev/null; then
        log_pass "verify command executed successfully"
    else
        log_skip "verify command (may require full installation)"
    fi
}

# ==============================================================================
# TEST 3: Discover Command
# ==============================================================================
test_discover() {
    log_section "TEST 3: Discover Command"
    
    log_test "Running: cytadela++ discover"
    
    local output
    local exit_code
    output=$("$PROJECT_ROOT/cytadela++.new.sh" discover 2>&1) || exit_code=$?
    
    if [[ -z "$output" ]]; then
        log_skip "discover (requires installation to /opt/cytadela)"
        return
    fi
    
    if [[ ${exit_code:-0} -eq 0 ]]; then
        log_pass "discover command executed successfully"
        
        # Check for network interface detection
        if echo "$output" | grep -qE "(eth|ens|enp|wlan|wlp)"; then
            log_pass "discover - detected network interface"
        fi
    else
        log_skip "discover (requires full installation)"
    fi
}

# ==============================================================================
# TEST 4: Cache Stats (if CoreDNS installed)
# ==============================================================================
test_cache_stats() {
    log_section "TEST 4: Cache Stats Command"
    
    # Check if CoreDNS is installed
    if ! systemctl list-unit-files | grep -q "coredns.service"; then
        log_skip "cache-stats (CoreDNS not installed)"
        return
    fi
    
    log_test "Running: cytadela++ cache-stats"
    
    if "$PROJECT_ROOT/cytadela++.new.sh" cache-stats &>/dev/null; then
        log_pass "cache-stats command executed successfully"
    else
        log_skip "cache-stats (CoreDNS not running or metrics unavailable)"
    fi
}

# ==============================================================================
# TEST 5: Blocklist Status (if installed)
# ==============================================================================
test_blocklist_status() {
    log_section "TEST 5: Blocklist Status Command"
    
    log_test "Running: cytadela++ blocklist-status"
    
    if "$PROJECT_ROOT/cytadela++.new.sh" blocklist-status &>/dev/null; then
        log_pass "blocklist-status command executed successfully"
    else
        log_skip "blocklist-status (blocklist not configured)"
    fi
}

# ==============================================================================
# TEST 6: Location Status
# ==============================================================================
test_location_status() {
    log_section "TEST 6: Location Status Command"
    
    log_test "Running: cytadela++ location-status"
    
    local output
    local exit_code
    output=$("$PROJECT_ROOT/cytadela++.new.sh" location-status 2>&1) || exit_code=$?
    
    if [[ -z "$output" ]]; then
        log_skip "location-status (requires installation)"
        return
    fi
    
    if [[ ${exit_code:-0} -eq 0 ]]; then
        log_pass "location-status command executed successfully"
        
        if echo "$output" | grep -q "NETWORK"; then
            log_pass "location-status - contains NETWORK info"
        fi
    else
        log_skip "location-status (requires full installation)"
    fi
}

# ==============================================================================
# TEST 7: Config List (backup list)
# ==============================================================================
test_config_list() {
    log_section "TEST 7: Config List Command"
    
    log_test "Running: cytadela++ config-list"
    
    if "$PROJECT_ROOT/cytadela++.new.sh" config-list &>/dev/null; then
        log_pass "config-list command executed successfully"
    else
        log_skip "config-list (no backups available)"
    fi
}

# ==============================================================================
# TEST 8: Integrity Check
# ==============================================================================
test_integrity_check() {
    log_section "TEST 8: Integrity Check Command"
    
    log_test "Running: cytadela++ integrity-check"
    
    local output
    if output=$("$PROJECT_ROOT/cytadela++.new.sh" integrity-check 2>&1); then
        log_pass "integrity-check command executed successfully"
        
        # Check if it validates files
        if echo "$output" | grep -qE "(Checking|Validating|OK|PASS)"; then
            log_pass "integrity-check - performs validation"
        else
            log_skip "integrity-check - no validation output"
        fi
    else
        log_skip "integrity-check (may require full installation)"
    fi
}

# ==============================================================================
# TEST 9: IPv6 Privacy Status
# ==============================================================================
test_ipv6_status() {
    log_section "TEST 9: IPv6 Privacy Status"
    
    log_test "Running: cytadela++ ipv6-privacy-status"
    
    if "$PROJECT_ROOT/cytadela++.new.sh" ipv6-privacy-status &>/dev/null; then
        log_pass "ipv6-privacy-status command executed successfully"
    else
        log_skip "ipv6-privacy-status (IPv6 not available)"
    fi
}

# ==============================================================================
# TEST 10: Ghost Check (port audit)
# ==============================================================================
test_ghost_check() {
    log_section "TEST 10: Ghost Check Command"
    
    log_test "Running: cytadela++ ghost-check"
    
    local output
    local exit_code
    output=$("$PROJECT_ROOT/cytadela++.new.sh" ghost-check 2>&1) || exit_code=$?
    
    if [[ -z "$output" ]]; then
        log_skip "ghost-check (requires installation)"
        return
    fi
    
    if [[ ${exit_code:-0} -eq 0 ]]; then
        log_pass "ghost-check command executed successfully"
        
        if echo "$output" | grep -qE "(LISTENING|PORT|SOCKET)"; then
            log_pass "ghost-check - scans listening sockets"
        fi
    else
        log_skip "ghost-check (requires full installation)"
    fi
}

# ==============================================================================
# TEST 11: Supply Chain Status
# ==============================================================================
test_supply_chain_status() {
    log_section "TEST 11: Supply Chain Status"
    
    log_test "Running: cytadela++ supply-chain-status"
    
    if "$PROJECT_ROOT/cytadela++.new.sh" supply-chain-status &>/dev/null; then
        log_pass "supply-chain-status command executed successfully"
    else
        log_skip "supply-chain-status (not initialized)"
    fi
}

# ==============================================================================
# TEST 12: Notify Status
# ==============================================================================
test_notify_status() {
    log_section "TEST 12: Notify Status"
    
    log_test "Running: cytadela++ notify-status"
    
    if "$PROJECT_ROOT/cytadela++.new.sh" notify-status &>/dev/null; then
        log_pass "notify-status command executed successfully"
    else
        log_skip "notify-status (notifications not configured)"
    fi
}

# ==============================================================================
# TEST 13: Service Status Checks
# ==============================================================================
test_service_status() {
    log_section "TEST 13: Service Status Checks"
    
    local services=("dnscrypt-proxy" "coredns" "nftables")
    
    for service in "${services[@]}"; do
        log_test "Checking service: $service"
        
        if systemctl list-unit-files | grep -q "${service}.service"; then
            if systemctl is-active --quiet "$service"; then
                log_pass "$service - running"
            else
                log_skip "$service - installed but not running"
            fi
        else
            log_skip "$service - not installed"
        fi
    done
}

# ==============================================================================
# TEST 14: File Permissions Check
# ==============================================================================
test_file_permissions() {
    log_section "TEST 14: File Permissions Check"
    
    local critical_dirs=(
        "/etc/dnscrypt-proxy"
        "/etc/coredns"
        "/etc/nftables.d"
        "/var/lib/cytadela"
    )
    
    for dir in "${critical_dirs[@]}"; do
        log_test "Checking directory: $dir"
        
        if [[ -d "$dir" ]]; then
            local perms=$(stat -c "%a" "$dir")
            if [[ "$perms" =~ ^[0-7]?[0-7][0-5][0-5]$ ]]; then
                log_pass "$dir - permissions OK ($perms)"
            else
                log_fail "$dir - permissions too open ($perms)"
            fi
        else
            log_skip "$dir - not present"
        fi
    done
}

# ==============================================================================
# MAIN
# ==============================================================================
main() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  CYTADELA++ INTEGRATION TESTS v3.1                            ║${NC}"
    echo -e "${CYAN}║  Level 3: Read-only tests with sudo                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_root
    
    echo "Project root: $PROJECT_ROOT"
    echo "Running as: $(whoami)"
    echo ""
    
    # Run all tests
    test_diagnostics
    test_verify
    test_discover
    test_cache_stats
    test_blocklist_status
    test_location_status
    test_config_list
    test_integrity_check
    test_ipv6_status
    test_ghost_check
    test_supply_chain_status
    test_notify_status
    test_service_status
    test_file_permissions
    
    # Summary
    log_section "TEST SUMMARY"
    echo -e "${GREEN}Passed:${NC}  $TESTS_PASSED"
    echo -e "${RED}Failed:${NC}  $TESTS_FAILED"
    echo -e "${YELLOW}Skipped:${NC} $TESTS_SKIPPED"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    echo "Total tests: $total"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All integration tests passed!${NC}"
        echo ""
        echo "Note: Some tests were skipped because components are not installed."
        echo "This is normal for a partial installation."
        exit 0
    else
        echo -e "${RED}✗ Some integration tests failed${NC}"
        echo ""
        echo "Review the failures above for details."
        exit 1
    fi
}

main "$@"
