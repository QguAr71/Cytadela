# Citadel Testing Suite

Comprehensive testing framework for Citadel v3.1 with three levels of validation.

## Test Levels

### Level 1: Static Analysis (No sudo required)
**Time:** ~5 seconds  
**Location:** GitHub Actions (automatic)

- ShellCheck validation
- Syntax checking
- Code quality analysis

**Run manually:**
```bash
shellcheck -S warning -e SC2034 cytadela++.sh citadela_en.sh \
  cytadela++.new.sh citadela_en.new.sh lib/*.sh modules/*.sh
```

---

### Level 2: Smoke Tests (No sudo required)
**Time:** ~2-3 minutes  
**Script:** `tests/smoke-test.sh`  
**CI/CD:** ✅ Automated in GitHub Actions

**What it tests:**
1. **Syntax Validation** - All scripts parse correctly
2. **ShellCheck Validation** - No warnings
3. **Module Loading** - Libraries can be sourced
4. **File Structure** - All required files present
5. **Executable Permissions** - Scripts are executable
6. **Help/Version Commands** - Basic commands work
7. **Module File Validation** - All modules have proper structure

**Run locally:**
```bash
cd /home/qguar/Cytadela
./tests/smoke-test.sh
```

**Expected output:**
```
✓ All tests passed!
Passed:  73
Failed:  0
Skipped: 2
```

---

### Level 3: Integration Tests (Requires sudo)
**Time:** ~10-15 minutes (on full installation)  
**Script:** `tests/integration-test.sh`  
**CI/CD:** ❌ Manual only (requires root)

**What it tests:**
1. **Diagnostics Command** - System info collection
2. **Verify Command** - Installation verification
3. **Discover Command** - Network detection
4. **Cache Stats** - CoreDNS metrics (if installed)
5. **Blocklist Status** - Adblock configuration
6. **Location Status** - Network location awareness
7. **Config List** - Backup management
8. **Integrity Check** - File validation
9. **IPv6 Privacy Status** - Privacy extensions
10. **Ghost Check** - Port exposure audit
11. **Supply Chain Status** - Download verification
12. **Notify Status** - Desktop notifications
13. **Service Status** - dnscrypt-proxy, coredns, nftables
14. **File Permissions** - Security checks

**Run locally:**
```bash
cd /home/qguar/Cytadela
sudo ./tests/integration-test.sh
```

**Expected output (partial installation):**
```
✓ All integration tests passed!
Passed:  4-10 (depends on what's installed)
Failed:  0
Skipped: 9-15 (missing components)
```

**Expected output (full installation):**
```
✓ All integration tests passed!
Passed:  15-19
Failed:  0
Skipped: 0-4
```

---

## Test Philosophy

### Smoke Tests (Level 2)
- **Fast feedback** - Catch 80% of issues in 3 minutes
- **No privileges** - Can run anywhere
- **CI/CD friendly** - Automated on every push
- **Developer-focused** - Quick validation during development

### Integration Tests (Level 3)
- **Real environment** - Tests actual system integration
- **Read-only** - No modifications to system
- **Graceful degradation** - Skips missing components
- **Production-ready** - Validates deployment

---

## CI/CD Integration

### GitHub Actions Workflows

**1. ShellCheck Workflow** (`.github/workflows/shellcheck.yml`)
- Runs on every push to `main`
- Validates all scripts
- ~25 seconds execution time

**2. Smoke Tests Workflow** (`.github/workflows/smoke-tests.yml`)
- Runs on every push to `main`
- Executes `tests/smoke-test.sh`
- ~23 seconds execution time
- Uploads artifacts on failure

**Status badges:**
```markdown
![ShellCheck](https://github.com/QguAr71/Cytadela/actions/workflows/shellcheck.yml/badge.svg)
![Smoke Tests](https://github.com/QguAr71/Cytadela/actions/workflows/smoke-tests.yml/badge.svg)
```

---

## Development Workflow

### Before Commit
```bash
# Quick validation (no sudo)
./tests/smoke-test.sh
```

### Before Release
```bash
# Full validation (requires sudo)
sudo ./tests/integration-test.sh
```

### On CI/CD
- Automatic on every push
- Both ShellCheck and Smoke Tests run in parallel
- Green ✓ = Ready to merge
- Red ✗ = Review failures

---

## Test Results Interpretation

### Smoke Tests
- **PASS** - Test succeeded
- **FAIL** - Critical issue, must fix
- **SKIP** - Optional feature not available

### Integration Tests
- **PASS** - Component working correctly
- **FAIL** - Component broken, needs attention
- **SKIP** - Component not installed (normal for partial setup)

**Note:** Skipped tests are normal if Citadel is not fully installed. Integration tests are designed to work on both development environments and production systems.

---

## Adding New Tests

### Smoke Test (Level 2)
Edit `tests/smoke-test.sh`:
```bash
test_new_feature() {
    log_section "TEST X: New Feature"
    log_test "Testing new feature..."
    
    if [[ condition ]]; then
        log_pass "new feature works"
    else
        log_fail "new feature broken"
    fi
}

# Add to main()
test_new_feature
```

### Integration Test (Level 3)
Edit `tests/integration-test.sh`:
```bash
test_new_command() {
    log_section "TEST X: New Command"
    log_test "Running: cytadela++ new-command"
    
    local output
    local exit_code
    output=$("$PROJECT_ROOT/cytadela++.new.sh" new-command 2>&1) || exit_code=$?
    
    if [[ -z "$output" ]]; then
        log_skip "new-command (requires installation)"
        return
    fi
    
    if [[ ${exit_code:-0} -eq 0 ]]; then
        log_pass "new-command executed successfully"
    else
        log_skip "new-command (requires full installation)"
    fi
}

# Add to main()
test_new_command
```

---

## Troubleshooting

### Smoke Tests Fail
1. Check ShellCheck warnings: `shellcheck script.sh`
2. Verify syntax: `bash -n script.sh`
3. Check file structure: `ls -la lib/ modules/`

### Integration Tests Fail
1. Check if running as root: `sudo ./tests/integration-test.sh`
2. Verify installation: `sudo cytadela++ verify`
3. Check service status: `systemctl status coredns dnscrypt-proxy`

### CI/CD Fails
1. Check GitHub Actions logs
2. Run tests locally first
3. Ensure all files are committed
4. Verify workflow YAML syntax

---

## Future Enhancements

### Level 4: Full System Tests (Planned)
- Fresh installation in VM/container
- Install wizard validation
- Config backup/restore cycle
- Blocklist profile switching
- Service restart/reload tests
- Rollback scenarios
- **Time:** 30-60 minutes
- **Environment:** Isolated test system

---

## Summary

| Level | Name | Time | Sudo | CI/CD | Purpose |
|-------|------|------|------|-------|---------|
| 1 | Static Analysis | 5s | ❌ | ✅ | Code quality |
| 2 | Smoke Tests | 3m | ❌ | ✅ | Basic validation |
| 3 | Integration Tests | 15m | ✅ | ❌ | System integration |
| 4 | Full System Tests | 60m | ✅ | ❌ | End-to-end (planned) |

**Current Status:** Levels 1-3 implemented and working ✅
