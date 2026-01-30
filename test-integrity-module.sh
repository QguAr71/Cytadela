#!/bin/bash
# Test Integrity Module

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Load dependencies
source "${SCRIPT_DIR}/lib/cytadela-core.sh"
source "${SCRIPT_DIR}/lib/network-utils.sh"

# Set CYTADELA_MODULES after loading core
export CYTADELA_MODULES="${SCRIPT_DIR}/modules"

source "${SCRIPT_DIR}/lib/module-loader.sh"

echo "=== TESTING INTEGRITY MODULE ==="
echo ""

# Test 1: Load module
echo "Test 1: Loading integrity module..."
load_module "integrity"
log_success "Module loaded"

# Test 2: integrity_status
echo ""
echo "Test 2: integrity_status..."
integrity_status

# Test 3: integrity_verify_file
echo ""
echo "Test 3: integrity_verify_file..."
tmpfile=$(mktemp)
echo "test" > "$tmpfile"
hash=$(sha256sum "$tmpfile" | awk '{print $1}')

if integrity_verify_file "$tmpfile" "$hash"; then
    log_success "Valid hash accepted"
else
    log_error "Valid hash rejected"
    exit 1
fi

if integrity_verify_file "$tmpfile" "invalid_hash"; then
    log_error "Invalid hash accepted"
    exit 1
else
    log_success "Invalid hash rejected"
fi

rm "$tmpfile"

echo ""
echo "=== INTEGRITY MODULE TESTS PASSED ==="
