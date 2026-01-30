#!/bin/bash
# Mini PoC - Test Wrapper
set -euo pipefail

# Paths
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LIB_DIR="${SCRIPT_DIR}/lib"
MODULES_DIR="${SCRIPT_DIR}/modules"

# Load core
source "${LIB_DIR}/test-core.sh"

# Load module
source "${MODULES_DIR}/test-module.sh"

# Test
echo "=== MINI PoC TEST ==="
echo ""

# Test 1: Core library
echo "Test 1: Core library..."
test_core_loaded

# Test 2: Module function
echo ""
echo "Test 2: Module function..."
test_function

# Test 3: Module with dependency
echo ""
echo "Test 3: Module with dependency..."
test_with_dependency

echo ""
echo "=== ALL PoC TESTS PASSED ==="
