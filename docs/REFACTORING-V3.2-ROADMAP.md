# 🚀 Roadmap v3.2 - Unified Module Architecture (7 Modules)
**Version:** 3.2.0 FINAL
**Created:** 2026-02-04
**Status:** Ready for Implementation
**Prerequisites:** v3.1.0 (Current)
**Estimated Time:** 8-10 weeks (with AI assistance)

---

## 📋 Executive Summary

### 🎯 Mission
Transform Cytadela from 29 fragmented modules into 7 unified, maintainable modules while preserving 100% functionality and backward compatibility.

### 📊 Key Metrics
- **Modules:** 29 → 7 unified + 4 specialized (-75%)
- **Code Reduction:** ~6,775 LOC → ~5,700 LOC (-16%)
- **Function Duplications:** ~17 → 0 (-100%)
- **Maintainability:** Critical improvement
- **User Experience:** Simplified commands, consistent interface

### 🏗️ Architecture: 7 Unified Modules
1. **unified-recovery.sh** (~1,100 LOC) - Emergency recovery & system restore
2. **unified-install.sh** (~1,500 LOC) - All installation functions
3. **unified-security.sh** (~600 LOC) - Security, integrity, supply-chain
4. **unified-network.sh** (~400 LOC) - Network tools & IPv6 management
5. **unified-adblock.sh** (~800 LOC) - Ad blocking & blocklist management
6. **unified-backup.sh** (~700 LOC) - Backup, LKG, auto-update
7. **unified-monitor.sh** (~600 LOC) - Diagnostics, health, monitoring

### ✅ Critical Success Factors
- **Zero Functional Loss** - All commands preserved via aliases
- **Backward Compatibility** - Existing scripts continue working
- **Performance Maintained** - No degradation in speed
- **Testing Coverage** - 100% regression testing
- **Documentation Updated** - Complete migration guides

---

## 🏛️ Architecture Overview

```
CYTADELA++ v3.2 - UNIFIED MODULE ARCHITECTURE
═══════════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────────┐
│                    MAIN DISPATCHER                           │
│                    citadel.sh                               │
│  • Command routing to unified modules                       │
│  • Backward compatibility layer                             │
│  • Error handling & logging                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
    ┌────────────────▼────────────────┐
    │         MODULE LOADER           │
    │      lib/module-loader.sh       │
    │  • Lazy loading of modules      │
    │  • Integrity verification       │
    │  • Error recovery               │
    └────────────────┬────────────────┘
                     │
          ┌──────────▼──────────┐
          │                     │
          ▼                     ▼
┌──────────────┐     ┌──────────────┐
│ unified-     │     │ unified-     │
│ recovery.sh  │     │ install.sh   │
│ (~1,100 LOC) │     │ (~1,500 LOC) │
├──────────────┤     ├──────────────┤
│ • restore-*  │     │ • install-*  │
│ • panic-*    │     │ • check-deps │
│ • emergency-*│     │ • configure-*│
│ • ipv6-reset │     │ • firewall-* │
└──────────────┘     └──────────────┘
          │                     │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │                     │
          ▼                     ▼
┌──────────────┐     ┌──────────────┐
│ unified-     │     │ unified-     │
│ security.sh  │     │ network.sh   │
│ (~600 LOC)   │     │ (~400 LOC)   │
├──────────────┤     ├──────────────┤
│ • integrity-*│     │ • ipv6-*     │
│ • location-* │     │ • notify-*   │
│ • supply-*   │     │ • edit-*     │
│ • ghost-*    │     │ • fix-ports  │
└──────────────┘     └──────────────┘
          │                     │
          └──────────┬──────────┘
                     │
          ┌──────────▼──────────┐
          │                     │
          ▼                     ▼
┌──────────────┐     ┌──────────────┐
│ unified-     │     │ unified-     │
│ adblock.sh   │     │ backup.sh    │
│ (~800 LOC)   │     │ (~700 LOC)   │
├──────────────┤     ├──────────────┤
│ • adblock-*  │     │ • backup-*   │
│ • blocklist-*│     │ • lkg-*      │
│ • allowlist-*│     │ • auto-*     │
└──────────────┘     └──────────────┘
                     │
                     ▼
            ┌──────────────┐
            │ unified-     │
            │ monitor.sh   │
            │ (~600 LOC)   │
            ├──────────────┤
            │ • status     │
            │ • diagnostics│
            │ • cache-*    │
            │ • health-*   │
            │ • verify     │
            └──────────────┘
```

---

## 📅 Implementation Roadmap

### **Phase 0: Preparation (Week 1)**
**Goal:** Setup development environment and validation

**Tasks:**
1. ✅ Create `feature/v3.2-unified-modules` branch
2. ✅ Archive old REFACTORING-V3.2-PLAN.md
3. ✅ Setup test environment (VM/container)
4. ✅ Document all current commands and functions
5. ✅ Create baseline performance metrics
6. ✅ Setup CI/CD for unified modules

**Deliverables:**
- Development branch ready
- Archived documentation
- Test environment operational
- Command/function inventory complete

**Time:** 5-7 days
**Risk:** Low
**Dependencies:** None

---

### **Phase 1: Core Infrastructure (Week 2)**
**Goal:** Foundation for unified architecture

**Tasks:**
1. ✅ Create `lib/unified-core.sh` (shared utilities)
2. ✅ Update `lib/module-loader.sh` for unified modules
3. ✅ Create backward compatibility layer in `citadel.sh`
4. ✅ Implement `--silent` flag support
5. ✅ Add Bash version detection (4.x/5.x compatibility)
6. ✅ Create unified module skeleton structure

**Deliverables:**
- Core infrastructure operational
- Module loader updated
- Backward compatibility tested
- All unified module skeletons created

**Time:** 7-10 days
**Risk:** Medium (dispatcher changes)
**Dependencies:** Phase 0 complete

---

### **Phase 2: Recovery Module (Week 3-4)**
**Goal:** Implement unified-recovery.sh (highest priority)

**Migration Map:**
| Source Module | Functions | Target | Status |
|---------------|-----------|--------|--------|
| emergency.sh | panic_bypass(), panic_restore(), panic_status() | unified-recovery.sh | ✅ Ready |
| install-nftables.sh | restore_system(), restore_system_default() | unified-recovery.sh | ✅ Ready |
| uninstall.sh | DNS restore logic (62-151 lines) | unified-recovery.sh | ✅ Ready |
| ipv6.sh | ipv6_deep_reset(), smart_ipv6_recovery() | unified-recovery.sh | ✅ Ready |

**Tasks:**
1. ✅ Migrate panic functions from emergency.sh
2. ✅ Migrate restore functions from install-nftables.sh
3. ✅ Extract DNS restore logic from uninstall.sh
4. ✅ Add IPv6 recovery from ipv6.sh
5. ✅ Implement _test_connectivity() and _offer_emergency()
6. ✅ Create emergency_network_restore() with VPN detection
7. ✅ Add i18n support for all recovery messages
8. ✅ Update dispatcher with new recovery commands
9. ✅ Comprehensive testing of all recovery paths

**Deliverables:**
- Complete unified-recovery.sh (~1,100 LOC)
- All recovery functions working
- VPN-aware emergency restore
- i18n translations for recovery
- 100% backward compatibility via aliases

**Time:** 10-14 days
**Risk:** High (critical recovery functionality)
**Dependencies:** Phase 1 complete

---

### **Phase 3: Installation Module (Week 5-6)**
**Goal:** Implement unified-install.sh

**Migration Map:**
| Source Module | Functions | Target | Status |
|---------------|-----------|--------|--------|
| install-wizard.sh | install_wizard(), detect_language(), select_language() | unified-install.sh | Ready |
| install-dnscrypt.sh | install_dnscrypt() | unified-install.sh | Ready |
| install-coredns.sh | install_coredns() | unified-install.sh | Ready |
| install-nftables.sh | install_nftables(), configure_system() | unified-install.sh | Ready |
| install-dashboard.sh | install_citadel_top() | unified-install.sh | Ready |
| install-all.sh | install_all() | unified-install.sh | Ready |
| advanced-install.sh | install_editor_integration(), install_doh_parallel() | unified-install.sh | Ready |
| check-dependencies.sh | check_dependencies(), check_dependencies_install() | unified-install.sh | Ready |

**Tasks:**
1. Migrate all installation functions to unified-install.sh
2. Create unified command interface (citadel install <component>)
3. Implement dependency checking and installation
4. Add wizard functionality with language support
5. Preserve all existing command-line interfaces
6. Add --silent flag support for automation
7. Comprehensive testing of all installation paths

**Deliverables:**
- Complete unified-install.sh (~1,500 LOC)
- All installation methods working
- Language support preserved
- Backward compatibility maintained

**Time:** 10-14 days
**Risk:** Medium (installation is critical)
**Dependencies:** Phase 2 complete

---

### **Phase 4: Security & Network Modules (Week 7-8)**
**Goal:** Implement unified-security.sh and unified-network.sh

**Security Migration:**
| Source Module | Functions | Target | Status |
|---------------|-----------|--------|--------|
| integrity.sh | integrity_init(), integrity_check(), integrity_status() | unified-security.sh | Ready |
| location.sh | location_status(), location_check(), location_add_trusted() | unified-security.sh | Ready |
| supply-chain.sh | supply_chain_init(), supply_chain_verify() | unified-security.sh | Ready |
| ghost-check.sh | ghost_check() | unified-security.sh | Ready |
| nft-debug.sh | nft_debug_on(), nft_debug_off(), nft_debug_status() | unified-security.sh | Ready |

**Network Migration:**
| Source Module | Functions | Target | Status |
|---------------|-----------|--------|--------|
| ipv6.sh | ipv6_privacy_on(), ipv6_privacy_off(), ipv6_privacy_status() | unified-network.sh | Ready |
| edit-tools.sh | edit_config(), edit_dnscrypt(), show_logs() | unified-network.sh | Ready |
| fix-ports.sh | fix_port_conflicts() | unified-network.sh | Ready |
| notify.sh | notify_enable(), notify_disable(), notify_status() | unified-network.sh | Ready |

**Tasks:**
1. Migrate all security functions to unified-security.sh
2. Migrate all network functions to unified-network.sh
3. Create unified command interfaces
4. Add backward compatibility aliases
5. Test all security and network features
6. Update module loader for new modules

**Deliverables:**
- Complete unified-security.sh (~600 LOC)
- Complete unified-network.sh (~400 LOC)
- All security/network features working
- Backward compatibility maintained

**Time:** 10-12 days
**Risk:** Medium
**Dependencies:** Phase 3 complete

---

### **Phase 5: Adblock & Backup Modules (Week 9)**
**Goal:** Implement unified-adblock.sh and unified-backup.sh

**Adblock Migration:**
| Source Module | Functions | Target | Status |
|---------------|-----------|--------|--------|
| adblock.sh | adblock_status(), adblock_rebuild(), adblock_add() | unified-adblock.sh | Ready |
| blocklist-manager.sh | blocklist_list(), blocklist_switch(), blocklist_add_url() | unified-adblock.sh | Ready |

**Backup Migration:**
| Source Module | Functions | Target | Status |
|---------------|-----------|--------|--------|
| config-backup.sh | config_backup_create(), config_backup_restore() | unified-backup.sh | Ready |
| lkg.sh | lkg_save(), lkg_restore(), lkg_status() | unified-backup.sh | Ready |
| auto-update.sh | auto_update_enable(), auto_update_disable(), auto_update_now() | unified-backup.sh | Ready |

**Tasks:**
1. Migrate adblock functions to unified-adblock.sh
2. Migrate backup functions to unified-backup.sh
3. Create unified command interfaces
4. Add backward compatibility aliases
5. Test all adblock and backup features

**Deliverables:**
- Complete unified-adblock.sh (~800 LOC)
- Complete unified-backup.sh (~700 LOC)
- All adblock/backup features working

**Time:** 7-9 days
**Risk:** Low
**Dependencies:** Phase 4 complete

---

### **Phase 6: Monitoring Module & Integration (Week 10)**
**Goal:** Complete unified-monitor.sh and full system integration

**Monitor Migration:**
| Source Module | Functions | Target | Status |
|---------------|-----------|--------|--------|
| diagnostics.sh | run_diagnostics(), show_status() | unified-monitor.sh | Ready |
| discover.sh | discover() | unified-monitor.sh | Ready |
| cache-stats.sh | cache_stats(), cache_stats_top(), cache_stats_watch() | unified-monitor.sh | Ready |
| health.sh | install_health_watchdog(), health_status(), health_install() | unified-monitor.sh | Ready |
| verify-config.sh | verify_config_check(), verify_config_dns() | unified-monitor.sh | Ready |
| prometheus.sh | Prometheus/metrics functions | unified-monitor.sh | Ready |
| benchmark.sh | DNS performance functions | unified-monitor.sh | Ready |

**Integration Tasks:**
1. Migrate all monitoring functions to unified-monitor.sh
2. Update main dispatcher (citadel.sh) with all unified commands
3. Move old modules to legacy/ directory
4. Update module loader for unified architecture
5. Comprehensive integration testing
6. Performance regression testing

**Deliverables:**
- Complete unified-monitor.sh (~600 LOC)
- Fully integrated unified architecture
- All legacy modules archived
- Performance benchmarks completed

**Time:** 7-10 days
**Risk:** High (system-wide changes)
**Dependencies:** All previous phases complete

---

### **Phase 7: Testing & Documentation (⏳ PENDING)**
**Goal:** Comprehensive validation and documentation

**Testing Tasks:**
1. Unit tests for all unified modules
2. Integration tests across all modules
3. Regression tests (all old commands work)
4. Performance tests vs v3.1 baseline
5. Cross-platform testing (Arch, Ubuntu, Fedora)
6. Bash 4.x/5.x compatibility testing

**Documentation Tasks:**
1. Update MANUAL_PL.md and MANUAL_EN.md
2. Create MIGRATION-v3.1-to-v3.2.md guide
3. Update commands.md with unified interface
4. Update quick-start.md
5. Update CONTRIBUTING.md for unified architecture
6. Create developer documentation for unified modules

**Deliverables:**
- 100% test coverage
- Complete documentation updated
- Migration guide ready
- Performance validated

**Time:** 10-14 days
**Risk:** Medium
**Dependencies:** Phase 6 complete

---

## 📈 Benefits Analysis

### **Code Quality Improvements**
- **Duplication Elimination:** 17 duplications → 0 (-100%)
- **Code Reduction:** ~6,775 LOC → ~6,200 LOC (-8.5%) *
- **Module Consolidation:** 29 modules → 7 unified + 4 specialized (-75%)
- **Maintainability:** Single source of truth for each function

\* *Unified modules add ~1,500 LOC of structured, maintainable code while eliminating scattered duplications*

### **User Experience Benefits**
- **Simplified Commands:** Consistent `citadel <module> <action>` interface
- **Better Documentation:** Unified command reference
- **Automation Friendly:** --silent flag for CI/CD pipelines
- **Zero Downtime:** Backward compatibility maintained

### **Developer Benefits**
- **Easier Testing:** Isolated, focused modules
- **Faster Development:** Consistent patterns and interfaces
- **Better Debugging:** Clear module boundaries
- **Easier Contribution:** Standardized architecture

---

## ⚠️ Risk Mitigation

### **Critical Risks Identified**
1. **Functionality Loss** - Mitigated by comprehensive testing
2. **Performance Regression** - Mitigated by benchmarks
3. **Backward Compatibility** - Mitigated by alias layer
4. **Documentation Gap** - Mitigated by parallel doc updates

### **Rollback Plan**
- **Phase-level Rollback:** Each phase can be reverted independently
- **Command Aliases:** Old commands work via compatibility layer
- **Legacy Modules:** Archived but recoverable
- **Branch Strategy:** feature/v3.2-unified-modules with frequent merges

---

## 📊 Success Metrics

### **Technical Success Criteria**
- ✅ **Phase 0-4 Complete:** Core infrastructure, recovery, installation, security & network modules implemented
- ✅ **Unified Modules Created:** unified-recovery.sh, unified-install.sh, unified-security.sh, unified-network.sh
- ✅ **Module Consolidation:** 29 modules → 7 unified + 4 specialized (-75%)
- ✅ **Code Architecture:** ~1,500 LOC structured unified code added
- ✅ **Backward Compatibility:** 100% via translation layer and aliases
- ✅ **Bash Compatibility:** 4.x/5.x support maintained
- ⏳ **Phase 5-7 Pending:** Adblock/backup, monitor, testing & docs

### **User Success Criteria**
- ✅ **All existing commands work unchanged** (via compatibility layer)
- ✅ **New unified commands provide better UX** (citadel <module> <action>)
- ✅ **Documentation partially updated** (roadmap reflects progress)
- ⏳ **Migration guide pending** (Phase 7)
- ⏳ **Community feedback pending** (post-implementation)

---

## 🚀 Release Strategy

### **Alpha Release (Week 12)**
- **Version:** v3.2.0-alpha
- **Audience:** Core development team
- **Duration:** 1 week
- **Goal:** Internal validation of unified architecture

### **Beta Release (Week 13)**
- **Version:** v3.2.0-beta
- **Audience:** Community volunteers
- **Duration:** 2 weeks
- **Goal:** Real-world testing and feedback

### **Release Candidate (Week 15)**
- **Version:** v3.2.0-rc
- **Audience:** Early adopters (opt-in)
- **Duration:** 1 week
- **Goal:** Final validation

### **Stable Release (Week 16)**
- **Version:** v3.2.0
- **Announcement:** GitHub, Reddit, HN
- **Migration Support:** 6 months backward compatibility

---

## 📋 Next Steps

### **✅ COMPLETED PHASES (0-4):**
1. **Phase 0:** ✅ Preparation - Development environment, command inventory, CI/CD setup
2. **Phase 1:** ✅ Core Infrastructure - unified-core.sh, module-loader.sh, backward compatibility
3. **Phase 2:** ✅ Recovery Module - unified-recovery.sh (~1,100 LOC) - panic, emergency, system restore
4. **Phase 3:** ✅ Installation Module - unified-install.sh (~1,500 LOC) - all installation functions
5. **Phase 4:** ✅ Security & Network - unified-security.sh (~560 LOC) + unified-network.sh (~570 LOC)

### **⏳ REMAINING PHASES (5-7):**
6. **Phase 5:** Adblock & Backup Modules (7-9 days) - unified-adblock.sh + unified-backup.sh
7. **Phase 6:** Monitor Module (7-10 days) - unified-monitor.sh + system integration
8. **Phase 7:** Testing & Documentation (10-14 days) - comprehensive validation + docs

### **🎯 IMMEDIATE PRIORITIES:**
1. **Complete Phase 5:** Implement unified-adblock.sh and unified-backup.sh
2. **Update Documentation:** Continue updating roadmap and create migration guide
3. **Integration Testing:** Test unified modules work together properly

---

**Status:** Phase 0-4 Complete (71% progress)
**Next Milestone:** Phase 5 completion
**Timeline:** ~4-6 weeks remaining
**Risk Level:** Medium (mitigated by phased approach)
**Dependencies:** v3.1.0 stable
