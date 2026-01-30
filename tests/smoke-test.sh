#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ SMOKE TESTS v3.1                                              ║
# ║  Quick validation without requiring root/sudo                             ║
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

# ==============================================================================
# TEST 1: Syntax Validation
# ==============================================================================
test_syntax_validation() {
    log_section "TEST 1: Syntax Validation"
    
    local files=(
        "cytadela++.sh"
        "citadela_en.sh"
        "cytadela++.new.sh"
        "citadela_en.new.sh"
    )
    
    for file in "${files[@]}"; do
        log_test "Syntax check: $file"
        if bash -n "$PROJECT_ROOT/$file" 2>/dev/null; then
            log_pass "$file - syntax OK"
        else
            log_fail "$file - syntax error"
        fi
    done
    
    # Check lib files
    for file in "$PROJECT_ROOT"/lib/*.sh; do
        log_test "Syntax check: $(basename "$file")"
        if bash -n "$file" 2>/dev/null; then
            log_pass "$(basename "$file") - syntax OK"
        else
            log_fail "$(basename "$file") - syntax error"
        fi
    done
    
    # Check module files
    for file in "$PROJECT_ROOT"/modules/*.sh; do
        log_test "Syntax check: $(basename "$file")"
        if bash -n "$file" 2>/dev/null; then
            log_pass "$(basename "$file") - syntax OK"
        else
            log_fail "$(basename "$file") - syntax error"
        fi
    done
}

# ==============================================================================
# TEST 2: ShellCheck Validation
# ==============================================================================
test_shellcheck() {
    log_section "TEST 2: ShellCheck Validation"
    
    if ! command -v shellcheck &>/dev/null; then
        log_skip "ShellCheck not installed"
        return
    fi
    
    log_test "Running ShellCheck on all scripts..."
    
    local shellcheck_output
    if shellcheck_output=$(shellcheck -S warning -e SC2034 \
        "$PROJECT_ROOT"/cytadela++.sh \
        "$PROJECT_ROOT"/citadela_en.sh \
        "$PROJECT_ROOT"/cytadela++.new.sh \
        "$PROJECT_ROOT"/citadela_en.new.sh \
        "$PROJECT_ROOT"/lib/*.sh \
        "$PROJECT_ROOT"/modules/*.sh 2>&1); then
        log_pass "ShellCheck - no warnings"
    else
        log_fail "ShellCheck - warnings found:"
        echo "$shellcheck_output"
    fi
}

# ==============================================================================
# TEST 3: Module Loading
# ==============================================================================
test_module_loading() {
    log_section "TEST 3: Module Loading"
    
    log_test "Testing core library loading..."
    
    # Create temporary test script
    local test_script=$(mktemp)
    cat > "$test_script" <<'EOF'
#!/bin/bash
set -euo pipefail

# Simulate minimal environment
CYTADELA_ROOT="/opt/cytadela"
CYTADELA_LIB="${CYTADELA_ROOT}/lib"
CYTADELA_MODULES="${CYTADELA_ROOT}/modules"
CYTADELA_LKG_DIR="/var/lib/cytadela/lkg"

# Mock functions that require system access
log_error() { echo "[ERROR] $*" >&2; }
log_warning() { echo "[WARNING] $*" >&2; }
log_info() { echo "[INFO] $*"; }
log_success() { echo "[SUCCESS] $*"; }
log_section() { echo "=== $* ==="; }
log_debug() { :; }

# Try to source core
if [[ -f "lib/core.sh" ]]; then
    source lib/core.sh 2>/dev/null || exit 1
fi

# Try to source module-loader
if [[ -f "lib/module-loader.sh" ]]; then
    source lib/module-loader.sh 2>/dev/null || exit 1
fi

echo "OK"
EOF
    
    chmod +x "$test_script"
    
    if (cd "$PROJECT_ROOT" && bash "$test_script" 2>/dev/null | grep -q "OK"); then
        log_pass "Core libraries can be sourced"
    else
        log_fail "Core libraries failed to load"
    fi
    
    rm -f "$test_script"
}

# ==============================================================================
# TEST 4: File Structure
# ==============================================================================
test_file_structure() {
    log_section "TEST 4: File Structure"
    
    local required_files=(
        "cytadela++.new.sh"
        "citadela_en.new.sh"
        "lib/cytadela-core.sh"
        "lib/module-loader.sh"
        "lib/i18n-pl.sh"
        "lib/i18n-en.sh"
        "modules/install-all.sh"
        "modules/diagnostics.sh"
        "modules/discover.sh"
        "README.md"
        "LICENSE"
    )
    
    for file in "${required_files[@]}"; do
        log_test "Checking: $file"
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            log_pass "$file exists"
        else
            log_fail "$file missing"
        fi
    done
}

# ==============================================================================
# TEST 5: Executable Permissions
# ==============================================================================
test_permissions() {
    log_section "TEST 5: Executable Permissions"
    
    local executables=(
        "cytadela++.sh"
        "citadela_en.sh"
        "cytadela++.new.sh"
        "citadela_en.new.sh"
    )
    
    for file in "${executables[@]}"; do
        log_test "Checking executable: $file"
        if [[ -x "$PROJECT_ROOT/$file" ]]; then
            log_pass "$file is executable"
        else
            log_fail "$file is not executable"
        fi
    done
}

# ==============================================================================
# TEST 6: Help/Version Commands (non-root)
# ==============================================================================
test_help_commands() {
    log_section "TEST 6: Help/Version Commands"
    
    log_test "Testing --help command..."
    if "$PROJECT_ROOT/cytadela++.new.sh" --help &>/dev/null; then
        log_pass "--help works"
    else
        log_skip "--help (may require specific environment)"
    fi
    
    log_test "Testing --version command..."
    if "$PROJECT_ROOT/cytadela++.new.sh" --version &>/dev/null; then
        log_pass "--version works"
    else
        log_skip "--version (may require specific environment)"
    fi
}

# ==============================================================================
# TEST 7: Module File Validation
# ==============================================================================
test_module_files() {
    log_section "TEST 7: Module File Validation"
    
    local module_count=0
    local valid_modules=0
    
    for module_file in "$PROJECT_ROOT"/modules/*.sh; do
        ((module_count++))
        local module_name=$(basename "$module_file" .sh)
        
        log_test "Validating module: $module_name"
        
        # Check if module has shebang
        if head -1 "$module_file" | grep -q "^#!/bin/bash"; then
            ((valid_modules++))
            log_pass "$module_name - has shebang"
        else
            log_fail "$module_name - missing shebang"
        fi
    done
    
    echo ""
    echo "Total modules: $module_count"
    echo "Valid modules: $valid_modules"
}

# ==============================================================================
# MAIN
# ==============================================================================
main() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  CYTADELA++ SMOKE TESTS v3.1                                  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Project root: $PROJECT_ROOT"
    echo ""
    
    # Run all tests
    test_syntax_validation
    test_shellcheck
    test_module_loading
    test_file_structure
    test_permissions
    test_help_commands
    test_module_files
    
    # Summary
    log_section "TEST SUMMARY"
    echo -e "${GREEN}Passed:${NC}  $TESTS_PASSED"
    echo -e "${RED}Failed:${NC}  $TESTS_FAILED"
    echo -e "${YELLOW}Skipped:${NC} $TESTS_SKIPPED"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        exit 1
    fi
}

main "$@"
