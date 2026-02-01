# TODO - Small Tasks

**Purpose:** Simple tasks suitable for smaller AI models or quick contributions.  
**Target:** Tasks that don't require large context or strategic decisions.

---

## 🔧 ShellCheck Fixes (Priority: Medium)

### lib/ Directory
- [x] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_VERSION
- [x] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_LKG_DIR
- [x] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_OPT_BIN
- [x] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_SCRIPT_PATH
- [x] Fix SC2034 in `lib/network-utils.sh` - Add `export` for DNSCRYPT_PORT_DEFAULT
- [x] Fix SC2034 in `lib/network-utils.sh` - Add `export` for COREDNS_PORT_DEFAULT
- [x] Fix SC2034 in `lib/network-utils.sh` - Add `export` for COREDNS_METRICS_ADDR
- [x] Fix SC2004 in `lib/module-loader.sh` line 40 - Remove `$` in array index (not applicable - false positive)

### modules/ Directory
- [x] Review and fix ShellCheck warnings in `modules/auto-update.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/blocklist-manager.sh` (done - name→_name)
- [x] Review and fix ShellCheck warnings in `modules/cache-stats.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/config-backup.sh` (done - removed unused var)
- [x] Review and fix ShellCheck warnings in `modules/diagnostics.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/ghost-check.sh` (done - added shellcheck disable)
- [x] Review and fix ShellCheck warnings in `modules/install-coredns.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/install-wizard.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/ipv6.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/location.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/nft-debug.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/notify.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/supply-chain.sh` (clean - no warnings)
- [x] Review and fix ShellCheck warnings in `modules/test-tools.sh` (clean - no warnings)

---

## 📐 Code Formatting (Priority: Low)

- [x] Run `shfmt -w -i 4 -ci lib/*.sh` - Format all library files
- [x] Run `shfmt -w -i 4 -ci modules/*.sh` - Format all module files
- [x] Run `shfmt -w -i 4 -ci citadel.sh citadel_en.sh` - Format main scripts
- [x] Verify formatting with `shfmt -d .` - Check for inconsistencies

---

## 📝 Documentation (Priority: Medium)

### Function Documentation
- [x] Add docstring to `panic_bypass()` in `modules/emergency.sh`
- [x] Add docstring to `panic_restore()` in `modules/emergency.sh`
- [x] Add docstring to `killswitch_on()` in `modules/emergency.sh`
- [x] Add docstring to `killswitch_off()` in `modules/emergency.sh`
- [x] Add docstring to `adblock_add()` in `modules/adblock.sh`
- [x] Add docstring to `adblock_remove()` in `modules/adblock.sh`
- [x] Add docstring to `adblock_rebuild()` in `modules/adblock.sh`
- [x] Add docstring to `ghost_check()` in `modules/ghost-check.sh`
- [x] Add docstring to `smart_ipv6()` in `modules/ipv6.sh`
- [x] Add docstring to `supply_chain_verify()` in `modules/supply-chain.sh`

### README Updates
- [ ] Update badges in README.md (version, build status)
- [ ] Add screenshot of `citadel-top` dashboard
- [ ] Update comparison table with latest features
- [ ] Add "Quick Links" section to README

### Examples
- [x] Create `examples/basic-setup.sh` - Simple installation example
- [x] Create `examples/advanced-setup.sh` - Advanced configuration example
- [x] Create `examples/emergency-recovery.sh` - Emergency procedures example

---

## 🧪 Tests (Priority: High)

### Smoke Tests
- [x] Add test for `citadel.sh help` in `tests/smoke-test.sh`
- [x] Add test for `citadel.sh --version` in `tests/smoke-test.sh`
- [x] Add test for root check (should fail without sudo)
- [x] Add test for `citadel.sh status` (basic status check)
- [x] Add test for `citadel.sh check-deps` (dependency check)

### BATS Tests (Future)
- [ ] Create `tests/unit/test-module-loader.bats` - Module loader tests
- [ ] Create `tests/unit/test-network-utils.bats` - Network utilities tests
- [ ] Create `tests/integration/test-install.bats` - Installation tests

---

## 🌍 Translations (Priority: Low)

### German (DE)
- [x] Translate "Honeypot enabled" in `lib/i18n-de.sh`
- [x] Translate "Reputation system active" in `lib/i18n-de.sh`
- [x] Translate "ASN blocking configured" in `lib/i18n-de.sh`

### French (FR)
- [x] Translate "Honeypot enabled" in `lib/i18n-fr.sh`
- [x] Translate "Reputation system active" in `lib/i18n-fr.sh`
- [x] Translate "ASN blocking configured" in `lib/i18n-fr.sh`

### Spanish (ES)
- [x] Translate "Honeypot enabled" in `lib/i18n-es.sh`
- [x] Translate "Reputation system active" in `lib/i18n-es.sh`
- [x] Translate "ASN blocking configured" in `lib/i18n-es.sh`

### Italian (IT)
- [x] Translate "Honeypot enabled" in `lib/i18n-it.sh`
- [x] Translate "Reputation system active" in `lib/i18n-it.sh`
- [x] Translate "ASN blocking configured" in `lib/i18n-it.sh`

### Russian (RU)
- [x] Translate "Honeypot enabled" in `lib/i18n-ru.sh`
- [x] Translate "Reputation system active" in `lib/i18n-ru.sh`
- [x] Translate "ASN blocking configured" in `lib/i18n-ru.sh`

---

## 🐛 Bug Fixes (Priority: High)

- [x] Test and verify check-deps fix (${1:-} after shift) - verified, works correctly
- [x] Verify realpath fallback works on systems without realpath - verified, has fallback
- [x] Test call_fn() with all module functions - verified, works correctly
- [x] Verify source_lib() error handling - verified, exits with code 2

---

## 🎨 UI/UX Improvements (Priority: Low)

- [x] Add color coding to `citadel.sh status` output - enhanced with more sections
- [x] Improve error messages (more descriptive) - added examples to adblock commands
- [x] Add progress indicators for long operations - added to lists_update
- [x] Improve help text formatting - restructured with emojis and better colors

---

## 📦 Packaging (Priority: Future)

- [ ] Create AUR package (PKGBUILD)
- [ ] Create Debian package (.deb)
- [ ] Create RPM package (.rpm)
- [ ] Create Docker image

---

## 🔒 Security (Priority: High)

- [x] Review all `eval` usage (if any) - none found in code
- [x] Check for hardcoded credentials - verified, only public keys
- [x] Verify input validation in all user-facing functions - basic validation present
- [ ] Add rate limiting to critical operations - needs implementation

---

## 📊 Metrics (Priority: Low)

- [ ] Add Prometheus metrics export
- [ ] Create Grafana dashboard template
- [ ] Add performance benchmarks

---

## Notes

**For Contributors:**
- Pick any task from this list
- Mark as completed when done
- Add new small tasks as needed
- Keep tasks simple (1 file, 1 function, 1 feature)

**For Smaller AI Models:**
- Focus on single-file changes
- Avoid strategic decisions
- Use existing patterns
- Test changes locally

**Last Updated:** 2026-01-31
