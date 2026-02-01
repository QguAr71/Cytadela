# 🚀 Installation Simplification Plan - v3.2 (Weles-SysQ)

**Version:** 3.2.0 PLANNED  
**Created:** 2026-02-01  
**Status:** Planning Phase  
**Priority:** High (User Experience)

---

## 📋 Problem Statement

### Current Installation Flow (v3.1.0)
```bash
1. sudo ./citadel.sh check-deps
2. sudo ./citadel.sh install-wizard
3. sudo ./citadel.sh configure-system  ← Easy to forget!
4. sudo ./citadel.sh verify
```

**Issues:**
- ⚠️ **4 separate commands** - too many steps
- ⚠️ **configure-system is critical** but easy to forget
- ⚠️ **Confusing for new users** - "Why isn't DNS working?"
- ⚠️ **No clear indication** that step 3 is mandatory

**User Impact:**
- Users install Citadel but forget `configure-system`
- System continues using systemd-resolved instead of Citadel
- DNS queries are NOT encrypted/filtered
- Users report "Citadel not working" when it's just not configured

---

## ✨ Proposed Solution: Auto-Configure

### New Installation Flow (v3.2)
```bash
1. sudo ./citadel.sh check-deps
2. sudo ./citadel.sh install-wizard  ← Auto-configures system!
   # (or: sudo ./citadel.sh install-all)
```

**Result:** **4 steps → 2 steps** (-50%)

---

## 🔧 Technical Implementation

### 1. Auto-Configure by Default

**Location:** `modules/unified-install.sh` (v3.2 unified module)

**Code:**
```bash
# Global flag
AUTO_CONFIGURE=true

# Parse command-line flags
parse_install_flags() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-configure)
                AUTO_CONFIGURE=false
                log_info "Auto-configure disabled (--no-configure flag)"
                shift
                ;;
            --silent)
                SILENT_MODE=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# At the end of install_wizard() and install_all()
finalize_installation() {
    if [[ "$AUTO_CONFIGURE" == "true" ]]; then
        log_section "🔧 CONFIGURING SYSTEM"
        log_info "Switching from systemd-resolved to Citadel DNS..."
        
        # Call configure_system from unified-network.sh
        configure_system
        
        if [[ $? -eq 0 ]]; then
            log_success "System configured successfully!"
            log_info "Backup created: /var/lib/cytadela/backups/"
        else
            log_error "Configuration failed!"
            log_info "You can try manually: sudo ./citadel.sh configure-system"
            return 1
        fi
    else
        log_warning "⚠️  AUTO-CONFIGURE DISABLED"
        log_warning "Citadel is installed but NOT active!"
        log_warning "System still uses systemd-resolved."
        echo ""
        log_info "To activate Citadel, run:"
        echo "  sudo ./citadel.sh configure-system"
        echo ""
    fi
}
```

---

### 2. Opt-Out for Advanced Users

**Use Cases:**
- Testing installation without activating
- Custom configuration before activation
- CI/CD pipelines with separate config step
- Multi-stage deployments

**Usage:**
```bash
# Standard installation (auto-configure)
sudo ./citadel.sh install-wizard

# Advanced: install without configuring
sudo ./citadel.sh install-wizard --no-configure

# Later, configure manually
sudo ./citadel.sh configure-system
```

---

### 3. Smart Detection & Warnings

**Check if system is already configured:**
```bash
is_citadel_configured() {
    # Check if /etc/resolv.conf points to 127.0.0.1
    if grep -q "nameserver 127.0.0.1" /etc/resolv.conf 2>/dev/null; then
        # Check if systemd-resolved is masked
        if systemctl is-enabled systemd-resolved 2>/dev/null | grep -q "masked"; then
            return 0  # Configured
        fi
    fi
    return 1  # Not configured
}

# Before auto-configure
if is_citadel_configured; then
    log_warning "System already configured - skipping configure-system"
    return 0
fi
```

**Warning if not configured:**
```bash
# In status command
check_configuration_status() {
    if ! is_citadel_configured; then
        log_warning "⚠️  CITADEL NOT CONFIGURED"
        log_warning "Citadel is installed but system still uses systemd-resolved"
        log_info "To activate: sudo ./citadel.sh configure-system"
        return 1
    fi
}
```

---

## 📚 Documentation Requirements

### 1. README.md Updates

**Before (v3.1):**
```bash
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard
sudo ./citadel.sh configure-system  # Don't forget!
sudo ./citadel.sh verify
```

**After (v3.2):**
```bash
# Quick Start (auto-configures system)
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard

# Advanced: Install without auto-configure
sudo ./citadel.sh install-wizard --no-configure
sudo ./citadel.sh configure-system  # Manual configuration
```

**Add prominent note:**
> **v3.2 Change:** Installation now automatically configures your system by default. Use `--no-configure` flag to disable auto-configuration.

---

### 2. Quick Start Guide Updates

**File:** `docs/user/quick-start.md`

**Add new section:**
```markdown
### Step 3: Install Citadel

**Option A: Standard Installation (Recommended)**
```bash
sudo ./citadel.sh install-wizard
```
- Interactive GUI with 7 languages
- **Automatically configures system** (new in v3.2!)
- Creates backup of original configuration
- Enables DNS leak protection

**Option B: Install Without Auto-Configure**
```bash
sudo ./citadel.sh install-wizard --no-configure
```
- For advanced users who want manual control
- System remains on systemd-resolved until you run:
  ```bash
  sudo ./citadel.sh configure-system
  ```

> **Important:** In v3.2, `install-wizard` automatically runs `configure-system` at the end. This is a breaking change from v3.1 where it was a separate step.
```

---

### 3. Migration Guide

**File:** `docs/MIGRATION-v3.1-to-v3.2.md`

**Section: Installation Changes**
```markdown
## Installation Simplification

### What Changed
- `install-wizard` and `install-all` now **automatically configure system**
- `configure-system` is called internally at the end of installation
- New `--no-configure` flag to disable auto-configuration

### Impact on Your Workflow

**v3.1 (Old):**
```bash
sudo ./citadel.sh install-wizard
sudo ./citadel.sh configure-system  # Separate step
```

**v3.2 (New):**
```bash
sudo ./citadel.sh install-wizard  # Auto-configures!
```

### Breaking Changes
- **Scripts/automation:** If your scripts rely on separate `configure-system` step, add `--no-configure` flag
- **CI/CD pipelines:** Update to use `--no-configure` if you need staged deployment
- **Testing:** Use `--no-configure` for test installations

### Backward Compatibility
- `configure-system` command still exists and works
- Can be called manually if needed
- Safe to call multiple times (idempotent)
```

---

### 4. MANUAL Updates

**Files:** `docs/user/MANUAL_PL.md`, `docs/user/MANUAL_EN.md`

**Add to Installation section:**

**English:**
```markdown
### Automatic System Configuration (v3.2+)

Starting with v3.2, Citadel automatically configures your system during installation:

1. **Backs up** original DNS configuration to `/var/lib/cytadela/backups/`
2. **Disables** systemd-resolved service
3. **Configures** /etc/resolv.conf to use Citadel (127.0.0.1)
4. **Enables** DNS leak protection firewall

**To disable auto-configuration:**
```bash
sudo ./citadel.sh install-wizard --no-configure
```

**To configure manually later:**
```bash
sudo ./citadel.sh configure-system
```

**To restore original configuration:**
```bash
sudo ./citadel.sh restore-system
```
```

**Polish:**
```markdown
### Automatyczna Konfiguracja Systemu (v3.2+)

Od wersji v3.2, Citadel automatycznie konfiguruje system podczas instalacji:

1. **Tworzy backup** oryginalnej konfiguracji DNS w `/var/lib/cytadela/backups/`
2. **Wyłącza** usługę systemd-resolved
3. **Konfiguruje** /etc/resolv.conf aby używać Citadel (127.0.0.1)
4. **Włącza** firewall ochrony przed wyciekiem DNS

**Aby wyłączyć auto-konfigurację:**
```bash
sudo ./citadel.sh install-wizard --no-configure
```

**Aby skonfigurować ręcznie później:**
```bash
sudo ./citadel.sh configure-system
```

**Aby przywrócić oryginalną konfigurację:**
```bash
sudo ./citadel.sh restore-system
```
```

---

### 5. FAQ Updates

**File:** `docs/user/FAQ.md`

**Add new questions:**

**Q: Why does v3.2 automatically configure my system?**
A: To simplify installation and prevent users from forgetting the critical `configure-system` step. In v3.1, many users installed Citadel but forgot to configure it, resulting in DNS not being encrypted/filtered. Use `--no-configure` flag if you want manual control.

**Q: Can I disable auto-configuration?**
A: Yes, use `--no-configure` flag:
```bash
sudo ./citadel.sh install-wizard --no-configure
```

**Q: What if auto-configuration fails?**
A: The installer will show an error and suggest running `configure-system` manually. Your system will remain on systemd-resolved (safe fallback).

**Q: Is auto-configuration safe?**
A: Yes. It creates a backup of your original configuration before making any changes. You can restore anytime with `restore-system`.

**Q: I upgraded from v3.1 - do I need to reconfigure?**
A: No. If your system is already configured, the installer detects it and skips auto-configuration.

---

### 6. Commands Reference

**File:** `docs/user/commands.md`

**Update install-wizard entry:**
```markdown
### install-wizard

**Syntax:**
```bash
sudo ./citadel.sh install-wizard [language] [--no-configure] [--silent]
```

**Description:**
Interactive installation wizard with graphical interface (whiptail).

**Parameters:**
- `language` (optional) - Force specific language: pl, en, de, es, it, fr, ru
- `--no-configure` - Skip automatic system configuration (v3.2+)
- `--silent` - Non-interactive mode for automation

**Behavior (v3.2+):**
- Automatically runs `configure-system` at the end
- Creates backup of original DNS configuration
- Disables systemd-resolved and enables Citadel DNS
- Use `--no-configure` to disable auto-configuration

**Examples:**
```bash
# Standard installation (auto-configures)
sudo ./citadel.sh install-wizard

# Force Polish language
sudo ./citadel.sh install-wizard pl

# Install without configuring system
sudo ./citadel.sh install-wizard --no-configure

# Silent installation for automation
sudo ./citadel.sh install-wizard --silent
```
```

---

## 🧪 Testing Requirements

### Unit Tests
```bash
# Test auto-configure enabled (default)
test_install_wizard_auto_configure() {
    AUTO_CONFIGURE=true
    install_wizard
    assert_citadel_configured
}

# Test auto-configure disabled
test_install_wizard_no_configure() {
    AUTO_CONFIGURE=false
    install_wizard
    assert_citadel_not_configured
}

# Test already configured (skip)
test_install_wizard_already_configured() {
    configure_system  # Pre-configure
    install_wizard
    assert_no_duplicate_configuration
}
```

### Integration Tests
```bash
# Full installation flow
test_full_installation() {
    check_deps
    install_wizard
    verify_installation
    assert_dns_working
    assert_leak_protection_active
}

# Install with --no-configure
test_install_no_configure() {
    install_wizard --no-configure
    assert_citadel_not_configured
    configure_system
    assert_citadel_configured
}
```

### User Acceptance Tests
- [ ] New user can install with single command
- [ ] Advanced user can use --no-configure
- [ ] Error messages are clear if configuration fails
- [ ] Backup is created before configuration
- [ ] restore-system works after auto-configure

---

## 📊 Success Metrics

### User Experience
- ✅ Installation steps: 4 → 2 (-50%)
- ✅ "Citadel not working" reports: Expected -80%
- ✅ Time to first working DNS: <5 minutes
- ✅ User confusion: Significantly reduced

### Technical
- ✅ Auto-configure success rate: >95%
- ✅ Backup creation: 100%
- ✅ Rollback success rate: 100%
- ✅ No breaking changes for advanced users

---

## 🚨 Risks & Mitigation

### Risk 1: Auto-configuration fails
**Impact:** High  
**Probability:** Low  
**Mitigation:**
- Comprehensive error handling
- Clear error messages with manual steps
- Safe fallback to systemd-resolved
- Backup always created before changes

### Risk 2: Users don't want auto-configure
**Impact:** Medium  
**Probability:** Low  
**Mitigation:**
- `--no-configure` flag for opt-out
- Clear documentation
- Backward compatible (configure-system still works)

### Risk 3: Breaking existing scripts
**Impact:** Medium  
**Probability:** Medium  
**Mitigation:**
- Migration guide with examples
- Deprecation warnings in v3.1.x
- `--no-configure` flag for old behavior

---

## 📅 Implementation Timeline

### Phase 1: Code Implementation (Week 1)
- [ ] Add AUTO_CONFIGURE flag to unified-install.sh
- [ ] Implement parse_install_flags()
- [ ] Implement finalize_installation()
- [ ] Add is_citadel_configured() check
- [ ] Add smart warnings

### Phase 2: Documentation (Week 2)
- [ ] Update README.md
- [ ] Update quick-start.md
- [ ] Update MANUAL_PL.md
- [ ] Update MANUAL_EN.md
- [ ] Update commands.md
- [ ] Update FAQ.md
- [ ] Create MIGRATION-v3.1-to-v3.2.md

### Phase 3: Testing (Week 3)
- [ ] Unit tests
- [ ] Integration tests
- [ ] User acceptance tests
- [ ] Beta testing with volunteers

### Phase 4: Release (Week 4)
- [ ] Final documentation review
- [ ] Release notes
- [ ] Announcement
- [ ] Support preparation

---

## 📝 Release Notes Template

```markdown
## v3.2.0 - Installation Simplification

### 🚀 Major Changes

**Simplified Installation Process**
- Installation now automatically configures your system
- Reduced from 4 steps to 2 steps
- No more forgetting `configure-system`!

**Before (v3.1):**
```bash
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard
sudo ./citadel.sh configure-system  # Easy to forget!
sudo ./citadel.sh verify
```

**After (v3.2):**
```bash
sudo ./citadel.sh check-deps
sudo ./citadel.sh install-wizard  # Auto-configures!
```

### ⚙️ Advanced Users

Use `--no-configure` flag to disable auto-configuration:
```bash
sudo ./citadel.sh install-wizard --no-configure
```

### 📚 Documentation

See [MIGRATION-v3.1-to-v3.2.md](docs/MIGRATION-v3.1-to-v3.2.md) for detailed migration guide.
```

---

## 🎯 Conclusion

**Benefits:**
- ✅ Simpler installation (4 → 2 steps)
- ✅ Fewer user errors
- ✅ Better first-time experience
- ✅ Maintains flexibility for advanced users
- ✅ Comprehensive documentation

**Key Success Factor:** **Excellent Documentation**
- Clear migration guide
- Updated manuals (PL + EN)
- FAQ entries
- Examples for all use cases
- Warning messages in code

---

**Last Updated:** 2026-02-01  
**Status:** Approved for v3.2 Implementation  
**Next Steps:** Begin Phase 1 (Code Implementation)
