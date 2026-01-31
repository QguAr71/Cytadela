# TODO - Small Tasks

**Purpose:** Simple tasks suitable for smaller AI models or quick contributions.  
**Target:** Tasks that don't require large context or strategic decisions.

---

## 🔧 ShellCheck Fixes (Priority: Medium)

### lib/ Directory
- [ ] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_VERSION
- [ ] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_LKG_DIR
- [ ] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_OPT_BIN
- [ ] Fix SC2034 in `lib/cytadela-core.sh` - Add `export` for CYTADELA_SCRIPT_PATH
- [ ] Fix SC2034 in `lib/network-utils.sh` - Add `export` for DNSCRYPT_PORT_DEFAULT
- [ ] Fix SC2034 in `lib/network-utils.sh` - Add `export` for COREDNS_PORT_DEFAULT
- [ ] Fix SC2034 in `lib/network-utils.sh` - Add `export` for COREDNS_METRICS_ADDR
- [ ] Fix SC2004 in `lib/module-loader.sh` line 40 - Remove `$` in array index

### modules/ Directory
- [ ] Review and fix ShellCheck warnings in `modules/auto-update.sh`
- [ ] Review and fix ShellCheck warnings in `modules/blocklist-manager.sh`
- [ ] Review and fix ShellCheck warnings in `modules/cache-stats.sh`
- [ ] Review and fix ShellCheck warnings in `modules/config-backup.sh`
- [ ] Review and fix ShellCheck warnings in `modules/diagnostics.sh`
- [ ] Review and fix ShellCheck warnings in `modules/ghost-check.sh`
- [ ] Review and fix ShellCheck warnings in `modules/install-coredns.sh`
- [ ] Review and fix ShellCheck warnings in `modules/install-wizard.sh`
- [ ] Review and fix ShellCheck warnings in `modules/ipv6.sh`
- [ ] Review and fix ShellCheck warnings in `modules/location.sh`
- [ ] Review and fix ShellCheck warnings in `modules/nft-debug.sh`
- [ ] Review and fix ShellCheck warnings in `modules/notify.sh`
- [ ] Review and fix ShellCheck warnings in `modules/supply-chain.sh`
- [ ] Review and fix ShellCheck warnings in `modules/test-tools.sh`

---

## 📐 Code Formatting (Priority: Low)

- [ ] Run `shfmt -w -i 4 -ci lib/*.sh` - Format all library files
- [ ] Run `shfmt -w -i 4 -ci modules/*.sh` - Format all module files
- [ ] Run `shfmt -w -i 4 -ci citadel.sh citadel_en.sh` - Format main scripts
- [ ] Verify formatting with `shfmt -d .` - Check for inconsistencies

---

## 📝 Documentation (Priority: Medium)

### Function Documentation
- [ ] Add docstring to `panic_bypass()` in `modules/emergency.sh`
- [ ] Add docstring to `panic_restore()` in `modules/emergency.sh`
- [ ] Add docstring to `killswitch_on()` in `modules/emergency.sh`
- [ ] Add docstring to `killswitch_off()` in `modules/emergency.sh`
- [ ] Add docstring to `adblock_add()` in `modules/adblock.sh`
- [ ] Add docstring to `adblock_remove()` in `modules/adblock.sh`
- [ ] Add docstring to `adblock_rebuild()` in `modules/adblock.sh`
- [ ] Add docstring to `ghost_check()` in `modules/ghost-check.sh`
- [ ] Add docstring to `smart_ipv6()` in `modules/ipv6.sh`
- [ ] Add docstring to `supply_chain_verify()` in `modules/supply-chain.sh`

### README Updates
- [ ] Update badges in README.md (version, build status)
- [ ] Add screenshot of `citadel-top` dashboard
- [ ] Update comparison table with latest features
- [ ] Add "Quick Links" section to README

### Examples
- [ ] Create `examples/basic-setup.sh` - Simple installation example
- [ ] Create `examples/advanced-setup.sh` - Advanced configuration example
- [ ] Create `examples/emergency-recovery.sh` - Emergency procedures example

---

## 🧪 Tests (Priority: High)

### Smoke Tests
- [ ] Add test for `citadel.sh help` in `tests/smoke-test.sh`
- [ ] Add test for `citadel.sh --version` in `tests/smoke-test.sh`
- [ ] Add test for root check (should fail without sudo)
- [ ] Add test for `citadel.sh status` (basic status check)
- [ ] Add test for `citadel.sh check-deps` (dependency check)

### BATS Tests (Future)
- [ ] Create `tests/unit/test-module-loader.bats` - Module loader tests
- [ ] Create `tests/unit/test-network-utils.bats` - Network utilities tests
- [ ] Create `tests/integration/test-install.bats` - Installation tests

---

## 🌍 Translations (Priority: Low)

### German (DE)
- [ ] Translate "Honeypot enabled" in `lib/i18n-de.sh`
- [ ] Translate "Reputation system active" in `lib/i18n-de.sh`
- [ ] Translate "ASN blocking configured" in `lib/i18n-de.sh`

### French (FR)
- [ ] Translate "Honeypot enabled" in `lib/i18n-fr.sh`
- [ ] Translate "Reputation system active" in `lib/i18n-fr.sh`
- [ ] Translate "ASN blocking configured" in `lib/i18n-fr.sh`

### Spanish (ES)
- [ ] Translate "Honeypot enabled" in `lib/i18n-es.sh`
- [ ] Translate "Reputation system active" in `lib/i18n-es.sh`
- [ ] Translate "ASN blocking configured" in `lib/i18n-es.sh`

### Italian (IT)
- [ ] Translate "Honeypot enabled" in `lib/i18n-it.sh`
- [ ] Translate "Reputation system active" in `lib/i18n-it.sh`
- [ ] Translate "ASN blocking configured" in `lib/i18n-it.sh`

### Russian (RU)
- [ ] Translate "Honeypot enabled" in `lib/i18n-ru.sh`
- [ ] Translate "Reputation system active" in `lib/i18n-ru.sh`
- [ ] Translate "ASN blocking configured" in `lib/i18n-ru.sh`

---

## 🐛 Bug Fixes (Priority: High)

- [ ] Test and verify check-deps fix (${1:-} after shift)
- [ ] Verify realpath fallback works on systems without realpath
- [ ] Test call_fn() with all module functions
- [ ] Verify source_lib() error handling

---

## 🎨 UI/UX Improvements (Priority: Low)

- [ ] Add color coding to `citadel.sh status` output
- [ ] Improve error messages (more descriptive)
- [ ] Add progress indicators for long operations
- [ ] Improve help text formatting

---

## 📦 Packaging (Priority: Future)

- [ ] Create AUR package (PKGBUILD)
- [ ] Create Debian package (.deb)
- [ ] Create RPM package (.rpm)
- [ ] Create Docker image

---

## 🔒 Security (Priority: High)

- [ ] Review all `eval` usage (if any)
- [ ] Check for hardcoded credentials
- [ ] Verify input validation in all user-facing functions
- [ ] Add rate limiting to critical operations

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
