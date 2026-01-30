#!/bin/bash
# Mini PoC - Test Core Library

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${CYAN}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }

# Test function
test_core_loaded() {
    log_success "Core library loaded successfully!"
}
