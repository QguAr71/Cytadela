#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ v3.1 - Smoke Tests                                            ║
# ║  Quick verification that refactored version works                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}󰄬${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
ERRORS=0

echo "=== CYTADELA++ v3.1 SMOKE TESTS ==="
echo ""

# Test 1: Core libraries load
log_info "Test 1: Core libraries..."
if source "${SCRIPT_DIR}/lib/cytadela-core.sh" 2>/dev/null; then
    log_success "cytadela-core.sh loads"
else
    log_error "cytadela-core.sh failed to load"
    ((ERRORS++))
fi

if source "${SCRIPT_DIR}/lib/network-utils.sh" 2>/dev/null; then
    log_success "network-utils.sh loads"
else
    log_error "network-utils.sh failed to load"
    ((ERRORS++))
fi

if source "${SCRIPT_DIR}/lib/module-loader.sh" 2>/dev/null; then
    log_success "module-loader.sh loads"
else
    log_error "module-loader.sh failed to load"
    ((ERRORS++))
fi

# Test 2: i18n libraries load
log_info "Test 2: i18n libraries..."
if source "${SCRIPT_DIR}/lib/i18n-pl.sh" 2>/dev/null; then
    log_success "i18n-pl.sh loads"
else
    log_error "i18n-pl.sh failed to load"
    ((ERRORS++))
fi

if source "${SCRIPT_DIR}/lib/i18n-en.sh" 2>/dev/null; then
    log_success "i18n-en.sh loads"
else
    log_error "i18n-en.sh failed to load"
    ((ERRORS++))
fi

# Test 3: All modules exist
log_info "Test 3: Module files exist..."
EXPECTED_MODULES=(
    "integrity" "discover" "ipv6" "lkg" "emergency"
    "adblock" "ghost-check" "health" "supply-chain"
    "location" "nft-debug" "install-dnscrypt"
    "install-coredns" "install-nftables" "install-all"
    "diagnostics"
)

for mod in "${EXPECTED_MODULES[@]}"; do
    if [[ -f "${SCRIPT_DIR}/modules/${mod}.sh" ]]; then
        log_success "modules/${mod}.sh exists"
    else
        log_error "modules/${mod}.sh missing"
        ((ERRORS++))
    fi
done

# Test 4: Wrappers exist and are executable
log_info "Test 4: Wrapper scripts..."
if [[ -x "${SCRIPT_DIR}/cytadela++.new.sh" ]]; then
    log_success "cytadela++.new.sh is executable"
else
    log_error "cytadela++.new.sh not executable"
    ((ERRORS++))
fi

if [[ -x "${SCRIPT_DIR}/citadela_en.new.sh" ]]; then
    log_success "citadela_en.new.sh is executable"
else
    log_error "citadela_en.new.sh not executable"
    ((ERRORS++))
fi

# Test 5: Module loading works
log_info "Test 5: Module loading mechanism..."
export CYTADELA_MODULES="${SCRIPT_DIR}/modules"
source "${SCRIPT_DIR}/lib/cytadela-core.sh"
source "${SCRIPT_DIR}/lib/module-loader.sh"

if load_module "integrity" 2>/dev/null; then
    log_success "Module loading works (integrity)"
else
    log_error "Module loading failed"
    ((ERRORS++))
fi

# Test 6: Functions are available after loading
log_info "Test 6: Module functions available..."
if declare -f integrity_status >/dev/null 2>&1; then
    log_success "integrity_status function available"
else
    log_error "integrity_status function not found"
    ((ERRORS++))
fi

echo ""
echo "=== SMOKE TEST RESULTS ==="
if [[ $ERRORS -eq 0 ]]; then
    log_success "All smoke tests PASSED"
    exit 0
else
    log_error "$ERRORS test(s) FAILED"
    exit 1
fi
