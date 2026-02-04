#!/bin/bash
# Test Core Libraries

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

echo "=== TESTING CORE LIBRARIES ==="
echo ""

# Test 1: cytadela-core.sh
echo "Test 1: Loading cytadela-core.sh..."
source "${SCRIPT_DIR}/lib/cytadela-core.sh"
log_success "cytadela-core.sh loaded"

# Test 2: Logging functions
echo ""
echo "Test 2: Logging functions..."
log_info "Info message test"
log_success "Success message test"
log_warning "Warning message test"
log_error "Error message test" 2>/dev/null || true
log_section "Section test"

# Test 3: Utility functions
echo "Test 3: Utility functions..."
require_cmd bash && log_success "require_cmd works"
require_cmds bash grep awk && log_success "require_cmds works"

# Test 4: network-utils.sh
echo ""
echo "Test 4: Loading network-utils.sh..."
source "${SCRIPT_DIR}/lib/network-utils.sh"
log_success "network-utils.sh loaded"

# Test 5: Network discovery
echo ""
echo "Test 5: Network discovery..."
iface=$(discover_active_interface)
[[ -n "$iface" ]] && log_success "Active interface: $iface" || log_warning "No interface detected"

stack=$(discover_network_stack)
log_success "Network stack: $stack"

# Test 6: module-loader.sh
echo ""
echo "Test 6: Loading module-loader.sh..."
CYTADELA_MODULES="${SCRIPT_DIR}/modules"
source "${SCRIPT_DIR}/lib/module-loader.sh"
log_success "module-loader.sh loaded"

# Test 7: Module utilities
echo ""
echo "Test 7: Module utilities..."
declare -a modules
modules=$(list_available_modules)
log_success "Available modules: ${modules:-none}"

echo ""
echo "=== ALL CORE LIBRARY TESTS PASSED ==="
