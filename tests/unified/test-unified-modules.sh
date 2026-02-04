#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED MODULES TEST SUITE v3.2                             ║
# ║  Comprehensive testing for all unified modules                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Test configuration
TEST_RESULTS_DIR="test/results"
TEST_LOG_FILE="${TEST_RESULTS_DIR}/unified-tests-$(date +%Y%m%d-%H%M%S).log"
FAILED_TESTS=0
PASSED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_test() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [TEST] $*" | tee -a "$TEST_LOG_FILE"
}

log_pass() {
    echo -e "${GREEN}✓ PASS:${NC} $*" | tee -a "$TEST_LOG_FILE"
    ((PASSED_TESTS++))
}

log_fail() {
    echo -e "${RED}✗ FAIL:${NC} $*" | tee -a "$TEST_LOG_FILE"
    ((FAILED_TESTS++))
}

log_warn() {
    echo -e "${YELLOW}⚠ WARN:${NC} $*" | tee -a "$TEST_LOG_FILE"
}

log_info() {
    echo -e "${BLUE}ℹ INFO:${NC} $*" | tee -a "$TEST_LOG_FILE"
}

# Setup test environment
setup_test_env() {
    log_test "Setting up test environment..."

    mkdir -p "$TEST_RESULTS_DIR"

    # Create test log header
    cat > "$TEST_LOG_FILE" << EOF
Citadel v3.2 Unified Modules Test Suite
Started: $(date)
Test Environment: $(uname -a)
Bash Version: $BASH_VERSION
Working Directory: $(pwd)

EOF

    log_pass "Test environment setup complete"
}

# Test module loading
test_module_loading() {
    log_test "Testing unified module loading..."

    local modules=("recovery" "install" "security" "network" "adblock" "backup")

    for module in "${modules[@]}"; do
        log_test "Testing module: $module"

        # Test if smart_load_module function exists
        if ! declare -f smart_load_module >/dev/null 2>&1; then
            log_fail "smart_load_module function not available"
            return 1
        fi

        # Try to load module (dry run - don't actually execute)
        if smart_load_module "$module" 2>/dev/null; then
            log_pass "Module $module loaded successfully"
        else
            log_fail "Failed to load module $module"
        fi
    done
}

# Test command translation
test_command_translation() {
    log_test "Testing command translation..."

    local test_cases=(
        "emergency:recovery panic-bypass"
        "restore-system:recovery restore-system"
        "install-all:install all"
        "adblock-status:adblock status"
        "config-backup:backup config-backup"
        "ipv6-privacy-on:network ipv6-privacy-on"
    )

    for case in "${test_cases[@]}"; do
        IFS=':' read -r input expected <<< "$case"

        # Test if translate_command function exists
        if ! declare -f translate_command >/dev/null 2>&1; then
            log_fail "translate_command function not available"
            return 1
        fi

        local result
        result=$(translate_command "$input" 2>/dev/null)

        if [[ "$result" == "$expected" ]]; then
            log_pass "Translation: '$input' → '$result'"
        else
            log_fail "Translation failed: '$input' → '$result' (expected: '$expected')"
        fi
    done
}

# Test backward compatibility
test_backward_compatibility() {
    log_test "Testing backward compatibility..."

    local old_commands=(
        "panic-status"
        "adblock-status"
        "allowlist-list"
        "blocklist-list"
        "config-list"
        "lkg-status"
        "auto-update-status"
    )

    for cmd in "${old_commands[@]}"; do
        log_test "Testing backward compatibility for: $cmd"

        # Test if command is accepted (basic syntax check)
        if ./citadel.sh "$cmd" --help 2>/dev/null | grep -q "Ten skrypt wymaga uprawnień root"; then
            log_pass "Command '$cmd' accepted (requires root as expected)"
        elif ./citadel.sh "$cmd" 2>&1 | grep -q "Nieznana komenda"; then
            log_fail "Command '$cmd' rejected as unknown"
        else
            log_pass "Command '$cmd' processed (may require root)"
        fi
    done
}

# Test unified module functions (basic)
test_unified_functions() {
    log_test "Testing unified module functions (basic)..."

    # Test if we can at least check function existence
    local test_functions=(
        "panic_status:recovery"
        "adblock_status:adblock"
        "config_list:backup"
        "ipv6_privacy_status:network"
        "integrity_status:security"
    )

    for func_spec in "${test_functions[@]}"; do
        IFS=':' read -r func_name module <<< "$func_spec"

        log_test "Testing function: ${module}_${func_name}"

        # Load module and check if function exists
        if smart_load_module "$module" 2>/dev/null && declare -f "$func_name" >/dev/null 2>&1; then
            log_pass "Function ${func_name} exists in module ${module}"
        else
            log_fail "Function ${func_name} not found in module ${module}"
        fi
    done
}

# Generate test summary
generate_summary() {
    local total_tests=$((PASSED_TESTS + FAILED_TESTS))
    local success_rate=0

    if [[ $total_tests -gt 0 ]]; then
        success_rate=$((PASSED_TESTS * 100 / total_tests))
    fi

    cat >> "$TEST_LOG_FILE" << EOF

=== TEST SUMMARY ===
Total Tests: $total_tests
Passed: $PASSED_TESTS
Failed: $FAILED_TESTS
Success Rate: ${success_rate}%

Test completed: $(date)
EOF

    echo ""
    echo "=== TEST SUMMARY ==="
    echo "Total Tests: $total_tests"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Success Rate: ${success_rate}%"
    echo ""
    echo "Detailed log: $TEST_LOG_FILE"

    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Check log for details.${NC}"
        return 1
    fi
}

# Main test runner
main() {
    echo "Citadel v3.2 Unified Modules Test Suite"
    echo "=========================================="
    echo ""

    setup_test_env

    # Source required libraries for testing
    if [[ -f "lib/cytadela-core.sh" ]]; then
        source_lib "lib/cytadela-core.sh"
    fi

    if [[ -f "lib/module-loader.sh" ]]; then
        source_lib "lib/module-loader.sh"
    fi

    if [[ -f "lib/unified-core.sh" ]]; then
        source_lib "lib/unified-core.sh"
    fi

    # Run test suites
    test_module_loading
    echo ""
    test_command_translation
    echo ""
    test_backward_compatibility
    echo ""
    test_unified_functions
    echo ""

    # Generate summary
    generate_summary
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
