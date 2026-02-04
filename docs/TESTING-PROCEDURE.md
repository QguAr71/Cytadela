# Citadel v3.2 - Environment Testing Procedure

**Version:** 3.2.0
**Date:** 2026-02-04
**Purpose:** Complete testing procedure for Citadel v3.2 in user environment
**Risk Level:** Low (rollback procedures included)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Preparation](#environment-preparation)
3. [Safe Testing Setup](#safe-testing-setup)
4. [Unified Modules Testing](#unified-modules-testing)
5. [Backward Compatibility Testing](#backward-compatibility-testing)
6. [Critical Functions Testing](#critical-functions-testing)
7. [Performance Testing](#performance-testing)
8. [Integration Testing](#integration-testing)
9. [Documentation Verification](#documentation-verification)
10. [Cleanup Procedures](#cleanup-procedures)
11. [Troubleshooting](#troubleshooting)
12. [Success Criteria](#success-criteria)

---

## Prerequisites

### System Requirements
```bash
# Required packages (install if missing)
pacman -S bash coreutils grep awk sed curl jq  # Arch Linux
apt install bash coreutils grep awk sed curl jq  # Ubuntu/Debian
dnf install bash coreutils grep awk sed curl jq  # Fedora/RHEL

# Optional but recommended for full testing
pacman -S dnsperf htop iotop  # Arch Linux
apt install dnsperf htop iotop  # Ubuntu/Debian
dnf install dnsperf htop iotop  # Fedora/RHEL
```

### Backup Your Current System
```bash
# Create system backup before testing
sudo mkdir -p /var/lib/cytadela/backups
sudo cp /etc/resolv.conf /var/lib/cytadela/backups/resolv.conf.backup
sudo cp -r /etc/coredns /var/lib/cytadela/backups/coredns.backup 2>/dev/null || true
sudo cp -r /etc/dnscrypt-proxy /var/lib/cytadela/backups/dnscrypt.backup 2>/dev/null || true

echo "Backup created in /var/lib/cytadela/backups/"
```

### Test Environment Isolation
```bash
# Create isolated test directory
mkdir -p ~/cytadela-test
cd ~/cytadela-test

# Clone fresh copy for testing
git clone https://github.com/your-org/cytadela.git .
git checkout develop  # or v3.2 branch

# Make scripts executable
chmod +x citadel.sh
find modules/unified -name "*.sh" -exec chmod +x {} \;
```

---

## Environment Preparation

### 1. System Information Gathering
```bash
# Gather system information
echo "=== SYSTEM INFORMATION ==="
uname -a
echo "Bash version: $BASH_VERSION"
echo "User: $(whoami)"
echo "Working directory: $(pwd)"
echo "Available memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Available disk: $(df -h . | tail -1 | awk '{print $4}')"
```

### 2. Network Connectivity Test
```bash
# Test basic network connectivity
echo "=== NETWORK CONNECTIVITY ==="
ping -c 3 8.8.8.8
ping -c 3 google.com
curl -s https://1.1.1.1/cdn-cgi/trace | head -5
```

### 3. DNS Resolution Test
```bash
# Test current DNS resolution
echo "=== CURRENT DNS RESOLUTION ==="
echo "DNS servers in /etc/resolv.conf:"
grep nameserver /etc/resolv.conf

echo "DNS resolution test:"
dig +short google.com @127.0.0.1 2>/dev/null || echo "Local DNS not responding (expected)"

# Backup current resolv.conf
sudo cp /etc/resolv.conf /etc/resolv.conf.backup-test
```

### 4. Service Status Check
```bash
# Check if DNS services are running
echo "=== CURRENT SERVICE STATUS ==="
systemctl is-active --quiet systemd-resolved && echo "systemd-resolved: ACTIVE" || echo "systemd-resolved: INACTIVE"
systemctl is-active --quiet dnscrypt-proxy && echo "dnscrypt-proxy: ACTIVE" || echo "dnscrypt-proxy: INACTIVE"
systemctl is-active --quiet coredns && echo "coredns: ACTIVE" || echo "coredns: INACTIVE"
```

---

## Safe Testing Setup

### 1. Isolated Configuration
```bash
# Create test-specific configuration
export CYTADELA_TEST_MODE=1
export CYTADELA_STATE_DIR="/tmp/cytadela-test-state"
mkdir -p "$CYTADELA_STATE_DIR"

# Use test-specific directories
export COREDNS_CONFIG_DIR="/tmp/cytadela-test-coredns"
export DNSCRYPT_CONFIG_DIR="/tmp/cytadela-test-dnscrypt"
mkdir -p "$COREDNS_CONFIG_DIR" "$DNSCRYPT_CONFIG_DIR"

echo "Test environment isolated:"
echo "State dir: $CYTADELA_STATE_DIR"
echo "CoreDNS dir: $COREDNS_CONFIG_DIR"
echo "DNSCrypt dir: $DNSCRYPT_CONFIG_DIR"
```

### 2. Test DNS Setup
```bash
# Create test DNS configuration (doesn't affect system)
cat > "$COREDNS_CONFIG_DIR/Corefile.test" << 'EOF'
.:53 {
    bind 127.0.0.1
    forward . 8.8.8.8 1.1.1.1
    log
}
EOF

echo "Test DNS configuration created in $COREDNS_CONFIG_DIR/Corefile.test"
```

### 3. Test Script Preparation
```bash
# Create test runner script
cat > test-environment.sh << 'EOF'
#!/bin/bash
# Citadel Environment Test Runner

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

# Test functions will be added here
EOF

chmod +x test-environment.sh
echo "Test runner script created: test-environment.sh"
```

---

## Unified Modules Testing

### 1. Module Loading Tests
```bash
echo "=== TESTING UNIFIED MODULE LOADING ==="

# Test each unified module loads without errors
modules=("recovery" "install" "security" "network" "adblock" "backup" "monitor")

for module in "${modules[@]}"; do
    echo "Testing module: $module"
    if ./citadel.sh "$module" status 2>&1 | grep -q "status\|Status\|STATUS"; then
        echo "✓ Module $module loaded successfully"
    else
        echo "✗ Module $module failed to load"
        ./citadel.sh "$module" status 2>&1 | head -5
    fi
    echo ""
done
```

### 2. Module Syntax Tests
```bash
echo "=== TESTING MODULE SYNTAX ==="

for module_file in modules/unified/*.sh; do
    echo "Testing syntax: $(basename "$module_file")"
    if bash -n "$module_file" 2>&1; then
        echo "✓ Syntax OK"
    else
        echo "✗ Syntax errors found:"
        bash -n "$module_file"
    fi
    echo ""
done
```

### 3. Function Availability Tests
```bash
echo "=== TESTING FUNCTION AVAILABILITY ==="

# Test critical functions exist
test_functions=(
    "recovery panic-status"
    "install check-deps"
    "security integrity-status"
    "network ipv6-privacy-status"
    "adblock status"
    "backup config-list"
    "monitor diagnostics"
)

for func in "${test_functions[@]}"; do
    echo "Testing function: $func"
    if ./citadel.sh $func 2>&1 | grep -q "status\|Status\|available\|Available"; then
        echo "✓ Function $func available"
    else
        echo "✗ Function $func not available or failed"
        ./citadel.sh $func 2>&1 | head -3
    fi
    echo ""
done
```

---

## Backward Compatibility Testing

### 1. Legacy Command Tests
```bash
echo "=== TESTING BACKWARD COMPATIBILITY ==="

# Test old commands still work
legacy_commands=(
    "panic-status"
    "install-all"
    "adblock-status"
    "allowlist-list"
    "blocklist-list"
    "config-list"
    "lkg-status"
    "auto-update-status"
    "diagnostics"
    "verify-stack"
)

for cmd in "${legacy_commands[@]}"; do
    echo "Testing legacy command: $cmd"
    if ./citadel.sh "$cmd" 2>&1 | grep -q "status\|Status\|available\|Available\|OK\|ok"; then
        echo "✓ Legacy command '$cmd' works"
    elif ./citadel.sh "$cmd" 2>&1 | grep -q "root\|sudo"; then
        echo "~ Legacy command '$cmd' requires root (expected)"
    else
        echo "✗ Legacy command '$cmd' failed"
        ./citadel.sh "$cmd" 2>&1 | head -3
    fi
    echo ""
done
```

### 2. Alias Compatibility Tests
```bash
echo "=== TESTING COMMAND ALIASES ==="

# Test that old aliases still work
alias_tests=(
    "blocklist:blocklist-list"
    "combined:adblock show combined"
    "custom:adblock show custom"
)

for alias_test in "${alias_tests[@]}"; do
    IFS=':' read -r alias_cmd expected <<< "$alias_test"
    echo "Testing alias: $alias_cmd"

    output=$(./citadel.sh "$alias_cmd" 2>&1)
    if echo "$output" | grep -q "blocklist\|Blocklist\|entries\|Entries"; then
        echo "✓ Alias '$alias_cmd' works"
    else
        echo "✗ Alias '$alias_cmd' failed"
        echo "$output" | head -3
    fi
    echo ""
done
```

---

## Critical Functions Testing

### 1. DNS Functionality Tests
```bash
echo "=== TESTING DNS FUNCTIONALITY ==="

# Test DNS resolution with different resolvers
resolvers=("8.8.8.8" "1.1.1.1" "208.67.222.222")

for resolver in "${resolvers[@]}"; do
    echo "Testing DNS resolver: $resolver"
    if dig +short +time=3 @${resolver} google.com | grep -q "[0-9]"; then
        echo "✓ DNS resolver $resolver working"
    else
        echo "✗ DNS resolver $resolver failed"
    fi
done

# Test local DNS (if configured)
echo "Testing local DNS resolution:"
if dig +short +time=3 @127.0.0.1 google.com 2>/dev/null | grep -q "[0-9]"; then
    echo "✓ Local DNS (127.0.0.1) working"
else
    echo "~ Local DNS not configured or not running (expected in test environment)"
fi
```

### 2. Configuration Validation Tests
```bash
echo "=== TESTING CONFIGURATION VALIDATION ==="

# Test configuration file validation
config_tests=(
    "lib/unified-core.sh:bash -n"
    "lib/module-loader.sh:bash -n"
    "citadel.sh:bash -n"
)

for config_test in "${config_tests[@]}"; do
    IFS=':' read -r file validator <<< "$config_test"
    echo "Testing config: $file"

    if [[ -f "$file" ]] && $validator "$file" 2>/dev/null; then
        echo "✓ Config file $file valid"
    else
        echo "✗ Config file $file invalid or missing"
    fi
done
```

### 3. Security Checks
```bash
echo "=== TESTING SECURITY FEATURES ==="

# Test file permissions
security_tests=(
    "citadel.sh:executable"
    "modules/unified/:readable"
    "lib/:readable"
)

for security_test in "${security_tests[@]}"; do
    IFS=':' read -r path check <<< "$security_test"
    echo "Testing security: $path ($check)"

    case $check in
        executable)
            if [[ -x "$path" ]]; then
                echo "✓ File $path is executable"
            else
                echo "✗ File $path is not executable"
            fi
            ;;
        readable)
            if [[ -r "$path" ]]; then
                echo "✓ Path $path is readable"
            else
                echo "✗ Path $path is not readable"
            fi
            ;;
    esac
done
```

---

## Performance Testing

### 1. Module Load Time Tests
```bash
echo "=== TESTING MODULE LOAD TIMES ==="

for module in "${modules[@]}"; do
    echo "Testing load time for module: $module"
    start_time=$(date +%s%N)
    ./citadel.sh "$module" status >/dev/null 2>&1
    end_time=$(date +%s%N)
    load_time=$(( (end_time - start_time) / 1000000 ))

    if [[ $load_time -lt 2000 ]]; then
        echo "✓ Module $module loaded in ${load_time}ms"
    else
        echo "⚠ Module $module slow load: ${load_time}ms"
    fi
done
```

### 2. Memory Usage Tests
```bash
echo "=== TESTING MEMORY USAGE ==="

# Get initial memory
initial_mem=$(ps -o rss= $$)

# Load all modules
for module in "${modules[@]}"; do
    ./citadel.sh "$module" status >/dev/null 2>&1
done

# Get final memory
final_mem=$(ps -o rss= $$)
mem_increase=$((final_mem - initial_mem))

echo "Memory usage:"
echo "  Initial: $initial_mem KB"
echo "  Final: $final_mem KB"
echo "  Increase: $mem_increase KB"

if [[ $mem_increase -lt 50000 ]]; then
    echo "✓ Memory usage acceptable"
else
    echo "⚠ High memory usage detected"
fi
```

---

## Integration Testing

### 1. End-to-End Workflow Tests
```bash
echo "=== TESTING END-TO-END WORKFLOWS ==="

# Test complete workflow sequences
workflows=(
    "Unified command workflow:install check-deps → security integrity-init → network ipv6-privacy-status"
    "Legacy compatibility workflow:adblock-status → allowlist-list → blocklist-list"
    "Mixed workflow:monitor diagnostics → backup config-list → recovery panic-status"
)

for workflow in "${workflows[@]}"; do
    echo "Testing workflow: $workflow"
    echo "~ Manual testing required for full workflows"
    echo "~ Commands are available and should work in sequence"
    echo ""
done
```

### 2. Cross-Module Interaction Tests
```bash
echo "=== TESTING CROSS-MODULE INTERACTIONS ==="

# Test that modules can work together
echo "Testing adblock + backup integration:"
echo "~ adblock rebuild should work with backup LKG"
echo "~ Manual verification needed"

echo ""
echo "Testing security + network integration:"
echo "~ integrity checks should work with network configs"
echo "~ Manual verification needed"
```

---

## Documentation Verification

### 1. Manual Verification
```bash
echo "=== VERIFYING DOCUMENTATION ==="

docs=(
    "docs/MANUAL_EN.md"
    "docs/MANUAL_PL.md"
    "docs/UNIFIED-MODULES-DOCUMENTATION.md"
    "docs/REFACTORING-V3.2-ROADMAP.md"
)

for doc in "${docs[@]}"; do
    echo "Checking documentation: $doc"
    if [[ -f "$doc" ]] && [[ -s "$doc" ]]; then
        lines=$(wc -l < "$doc")
        echo "✓ Documentation $doc exists ($lines lines)"
    else
        echo "✗ Documentation $doc missing or empty"
    fi
done
```

### 2. Help System Verification
```bash
echo "=== TESTING HELP SYSTEM ==="

# Test main help
echo "Testing main help:"
./citadel.sh --help | head -10

# Test module-specific help (if available)
echo ""
echo "Testing module help:"
./citadel.sh install help 2>/dev/null || echo "~ Install help not available"
./citadel.sh adblock help 2>/dev/null || echo "~ Adblock help not available"
```

---

## Cleanup Procedures

### 1. Test Environment Cleanup
```bash
echo "=== CLEANING UP TEST ENVIRONMENT ==="

# Remove test directories
sudo rm -rf "$CYTADELA_STATE_DIR"
sudo rm -rf "$COREDNS_CONFIG_DIR"
sudo rm -rf "$DNSCRYPT_CONFIG_DIR"

# Remove test files
rm -rf ~/cytadela-test

echo "✓ Test environment cleaned up"
```

### 2. System Restore
```bash
echo "=== RESTORING SYSTEM CONFIGURATION ==="

# Restore resolv.conf if modified
if [[ -f /etc/resolv.conf.backup-test ]]; then
    sudo mv /etc/resolv.conf.backup-test /etc/resolv.conf
    echo "✓ resolv.conf restored"
else
    echo "~ No resolv.conf backup found"
fi

# Restart services if needed
echo "Consider restarting DNS services:"
echo "  sudo systemctl restart systemd-resolved"
echo "  sudo systemctl restart dnscrypt-proxy"
echo "  sudo systemctl restart coredns"
```

### 3. Backup Verification
```bash
echo "=== VERIFYING BACKUPS ==="

if [[ -d /var/lib/cytadela/backups ]]; then
    echo "Available backups:"
    ls -la /var/lib/cytadela/backups/
else
    echo "~ No backups directory found"
fi
```

---

## Troubleshooting

### Common Test Issues

#### "Command not found" Errors
```bash
# Check if scripts are executable
ls -la citadel.sh
chmod +x citadel.sh

# Check if unified modules exist
ls -la modules/unified/
```

#### Permission Errors
```bash
# Some tests require root privileges
echo "Tests requiring root:"
echo "  - Service status checks"
echo "  - Configuration file access"
echo "  - System service management"

# Run with sudo for root tests
sudo ./citadel.sh monitor status
```

#### Network Connectivity Issues
```bash
# Check network connectivity
ping -c 3 8.8.8.8
curl -s https://1.1.1.1/cdn-cgi/trace | head -3

# DNS resolution test
dig @8.8.8.8 google.com
```

#### Module Loading Failures
```bash
# Check module syntax
bash -n modules/unified/unified-recovery.sh

# Check library dependencies
ls -la lib/

# Debug module loading
bash -x ./citadel.sh recovery status
```

---

## Success Criteria

### Minimum Success Criteria
- ✅ **File Structure:** All unified module files exist and are readable
- ✅ **Basic Syntax:** All scripts have valid bash syntax
- ✅ **Module Loading:** All unified modules load without critical errors
- ✅ **Backward Compatibility:** Legacy commands work or show appropriate messages
- ✅ **Documentation:** All documentation files exist and are readable

### Full Success Criteria
- ✅ **All Minimum Criteria Met**
- ✅ **Function Availability:** All documented functions are available
- ✅ **Integration:** Modules work together without conflicts
- ✅ **Performance:** Module loading < 2 seconds
- ✅ **Memory Usage:** Reasonable memory consumption
- ✅ **End-to-End:** Complete workflows function correctly

### Test Results Summary
```bash
echo "=== FINAL TEST RESULTS ==="
echo "Date: $(date)"
echo "Environment: $(uname -a)"
echo "Tester: $(whoami)"
echo ""
echo "Test Categories Completed:"
echo "  - Environment Preparation: [ ]"
echo "  - Unified Modules Testing: [ ]"
echo "  - Backward Compatibility: [ ]"
echo "  - Critical Functions: [ ]"
echo "  - Performance: [ ]"
echo "  - Integration: [ ]"
echo "  - Documentation: [ ]"
echo "  - Cleanup: [ ]"
echo ""
echo "Overall Assessment: [PASS/FAIL]"
echo "Ready for Production: [YES/NO]"
```

---

## Quick Test Commands

### Run All Tests
```bash
# Run comprehensive test suite
./test/regression/test-regression.sh    # Backward compatibility
./test/integration/test-integration.sh  # Integration tests
```

### Individual Module Tests
```bash
# Test specific modules
./citadel.sh recovery panic-status
./citadel.sh install check-deps
./citadel.sh security integrity-status
./citadel.sh network ipv6-privacy-status
./citadel.sh adblock status
./citadel.sh backup config-list
./citadel.sh monitor diagnostics
```

### Quick Health Check
```bash
# Quick system health check
./citadel.sh monitor status
./citadel.sh monitor verify
```

---

**Citadel v3.2 Environment Testing Procedure**
**Last Updated:** 2026-02-04
**Test Duration:** 30-60 minutes
**Risk Level:** Low (with proper backup and cleanup)
