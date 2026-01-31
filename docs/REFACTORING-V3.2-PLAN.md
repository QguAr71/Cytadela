# 🔄 Refactoring Plan v3.2 - Unified Module Architecture

**Version:** 3.2.0 PLANNED  
**Created:** 2026-01-31  
**Status:** Planning Phase  
**Estimated Time:** 3-4 weeks (with AI assistance)

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [Target Architecture](#target-architecture)
4. [Module Mapping](#module-mapping)
5. [Implementation Plan](#implementation-plan)
6. [Timeline & Milestones](#timeline--milestones)
7. [Testing Strategy](#testing-strategy)
8. [Rollout Strategy](#rollout-strategy)

---

## 🎯 Executive Summary

### Goals

- **Reduce complexity:** 29 modules → 6 unified modules (-79%)
- **Standardize interface:** Unified command structure
- **Eliminate duplication:** 17 duplications → 0 (-100%)
- **Reduce code:** ~8,000 → ~4,800 lines (-40%)
- **Improve maintainability:** Single source of truth

### Benefits

- ✅ Easier to learn (6 modules vs 29)
- ✅ Easier to maintain (no duplications)
- ✅ Easier to test (unified interface)
- ✅ Easier to extend (consistent patterns)
- ✅ Better user experience (simpler commands)

### Risks

- ⚠️ Breaking changes for existing users
- ⚠️ Migration complexity
- ⚠️ Testing coverage
- ⚠️ Documentation updates

### Mitigation

- ✅ Backward compatibility layer
- ✅ Comprehensive testing
- ✅ Phased rollout
- ✅ Clear migration guide

---

## 📊 Current State Analysis

### Module Inventory (29 modules)

| Module | Size | LOC | Functions | Category |
|--------|------|-----|-----------|----------|
| adblock.sh | 8.1 KB | ~280 | 8 | Ad Blocking |
| advanced-install.sh | 5.4 KB | ~180 | 4 | Installation |
| auto-update.sh | 4.4 KB | ~150 | 5 | Automation |
| blocklist-manager.sh | 10.8 KB | ~360 | 12 | Ad Blocking |
| cache-stats.sh | 5.9 KB | ~200 | 6 | Monitoring |
| check-dependencies.sh | 9.5 KB | ~320 | 10 | Installation |
| config-backup.sh | 8.3 KB | ~280 | 9 | Backup |
| diagnostics.sh | 5.1 KB | ~170 | 7 | Monitoring |
| discover.sh | 2.0 KB | ~65 | 3 | Monitoring |
| edit-tools.sh | 2.0 KB | ~70 | 4 | Configuration |
| emergency.sh | 5.2 KB | ~175 | 6 | Security |
| fix-ports.sh | 1.5 KB | ~50 | 2 | Configuration |
| ghost-check.sh | 3.5 KB | ~120 | 4 | Security |
| health.sh | 4.6 KB | ~155 | 5 | Monitoring |
| install-all.sh | 3.9 KB | ~130 | 3 | Installation |
| install-coredns.sh | 9.6 KB | ~320 | 8 | Installation |
| install-dashboard.sh | 4.5 KB | ~150 | 4 | Installation |
| install-dnscrypt.sh | 5.2 KB | ~175 | 6 | Installation |
| install-nftables.sh | 8.7 KB | ~290 | 7 | Installation |
| install-wizard.sh | 14.6 KB | ~490 | 15 | Installation |
| integrity.sh | 6.9 KB | ~230 | 8 | Security |
| ipv6.sh | 6.8 KB | ~230 | 9 | Network |
| lkg.sh | 4.8 KB | ~160 | 6 | Backup |
| location.sh | 6.5 KB | ~220 | 7 | Security |
| nft-debug.sh | 3.1 KB | ~105 | 4 | Security |
| notify.sh | 4.9 KB | ~165 | 6 | Automation |
| supply-chain.sh | 4.8 KB | ~160 | 7 | Security |
| test-module.sh | 0.3 KB | ~10 | 1 | Testing |
| test-tools.sh | 2.4 KB | ~80 | 4 | Testing |

**TOTAL:** ~150 KB, ~5,500 LOC, ~180 functions

---

## 🏗️ Target Architecture

### Unified Modules (6 modules)

#### 1. **unified-install.sh** (~1,500 LOC)

**Consolidates:**
- install-dnscrypt.sh
- install-coredns.sh
- install-nftables.sh
- install-dashboard.sh
- install-all.sh
- install-wizard.sh
- advanced-install.sh
- check-dependencies.sh

**Commands:**
```bash
citadel install dnscrypt [--dnssec] [--resolvers=...]
citadel install coredns [--port=53] [--cache=3600]
citadel install nftables [--strict|--safe]
citadel install dashboard
citadel install all [--mode=wizard|cli]
citadel install wizard [--lang=pl|en|de|...]
citadel check-deps [--install]
```

**Functions:**
- `install_component()` - Unified installer
- `check_dependencies()` - Dependency checker
- `configure_component()` - Post-install config
- `verify_installation()` - Installation verification

---

#### 2. **unified-adblock.sh** (~800 LOC)

**Consolidates:**
- adblock.sh
- blocklist-manager.sh

**Commands:**
```bash
citadel adblock status
citadel adblock update
citadel adblock rebuild
citadel adblock stats [--top=10]
citadel blocklist list
citadel blocklist switch <profile>
citadel blocklist add-url <url>
citadel blocklist remove-url <url>
```

**Functions:**
- `adblock_update()` - Update blocklists
- `adblock_rebuild()` - Rebuild combined list
- `blocklist_switch()` - Switch profile
- `blocklist_manage()` - Add/remove URLs

---

#### 3. **unified-backup.sh** (~700 LOC)

**Consolidates:**
- config-backup.sh
- lkg.sh
- auto-update.sh

**Commands:**
```bash
citadel backup create [--name=...]
citadel backup restore <backup-name>
citadel backup list
citadel backup delete <backup-name>
citadel lkg save
citadel lkg restore
citadel lkg status
citadel auto-update enable|disable|status|now
```

**Functions:**
- `backup_create()` - Create backup
- `backup_restore()` - Restore backup
- `lkg_manage()` - Last-known-good management
- `auto_update()` - Auto-update management

---

#### 4. **unified-monitor.sh** (~600 LOC)

**Consolidates:**
- diagnostics.sh
- discover.sh
- cache-stats.sh
- health.sh

**Commands:**
```bash
citadel status [--verbose]
citadel diagnostics [--full]
citadel discover
citadel cache-stats [--top=10] [--watch]
citadel health install|status|check
citadel verify
```

**Functions:**
- `system_status()` - Overall status
- `run_diagnostics()` - Full diagnostics
- `cache_statistics()` - Cache stats
- `health_check()` - Health monitoring

---

#### 5. **unified-security.sh** (~800 LOC)

**Consolidates:**
- emergency.sh
- ghost-check.sh
- integrity.sh
- location.sh
- nft-debug.sh
- supply-chain.sh

**Commands:**
```bash
citadel panic-bypass
citadel panic-restore
citadel panic-status
citadel ghost-check
citadel integrity init|check|verify
citadel supply-chain init|verify
citadel location check|add-trusted
citadel nft-debug on|off|status
citadel firewall-safe|strict
```

**Functions:**
- `emergency_mode()` - Panic bypass/restore
- `security_audit()` - Ghost check, integrity
- `supply_chain()` - Supply chain verification
- `firewall_manage()` - Firewall management

---

#### 6. **unified-network.sh** (~400 LOC)

**Consolidates:**
- ipv6.sh
- edit-tools.sh
- fix-ports.sh
- notify.sh

**Commands:**
```bash
citadel ipv6-privacy-auto
citadel ipv6-deep-reset
citadel fix-ports
citadel edit [dnscrypt|coredns|nftables]
citadel notify enable|disable|status|test
citadel configure-system
citadel restore-system
```

**Functions:**
- `ipv6_manage()` - IPv6 management
- `port_fix()` - Port conflict resolution
- `config_edit()` - Configuration editing
- `notify_manage()` - Notification management

---

## 🗺️ Module Mapping

### Installation Modules → unified-install.sh

| Old Module | New Function | Priority | Complexity |
|------------|--------------|----------|------------|
| install-dnscrypt.sh | `install_dnscrypt()` | High | Medium |
| install-coredns.sh | `install_coredns()` | High | Medium |
| install-nftables.sh | `install_nftables()` | High | Medium |
| install-dashboard.sh | `install_dashboard()` | Low | Low |
| install-all.sh | `install_all()` | High | Low |
| install-wizard.sh | `install_wizard()` | High | High |
| advanced-install.sh | `install_advanced()` | Medium | Medium |
| check-dependencies.sh | `check_dependencies()` | High | Low |

**Estimated Time:** 15-20 hours

---

### Ad Blocking Modules → unified-adblock.sh

| Old Module | New Function | Priority | Complexity |
|------------|--------------|----------|------------|
| adblock.sh | `adblock_*()` | High | Medium |
| blocklist-manager.sh | `blocklist_*()` | High | Medium |

**Estimated Time:** 6-8 hours

---

### Backup Modules → unified-backup.sh

| Old Module | New Function | Priority | Complexity |
|------------|--------------|----------|------------|
| config-backup.sh | `backup_*()` | High | Medium |
| lkg.sh | `lkg_*()` | High | Low |
| auto-update.sh | `auto_update_*()` | Medium | Low |

**Estimated Time:** 9-12 hours

---

### Monitoring Modules → unified-monitor.sh

| Old Module | New Function | Priority | Complexity |
|------------|--------------|----------|------------|
| diagnostics.sh | `diagnostics()` | High | Medium |
| discover.sh | `discover()` | Medium | Low |
| cache-stats.sh | `cache_stats()` | Medium | Low |
| health.sh | `health_*()` | Medium | Low |

**Estimated Time:** 12-15 hours

---

### Security Modules → unified-security.sh

| Old Module | New Function | Priority | Complexity |
|------------|--------------|----------|------------|
| emergency.sh | `panic_*()` | High | Medium |
| ghost-check.sh | `ghost_check()` | Medium | Low |
| integrity.sh | `integrity_*()` | High | Medium |
| location.sh | `location_*()` | Medium | Low |
| nft-debug.sh | `nft_debug_*()` | Low | Low |
| supply-chain.sh | `supply_chain_*()` | High | Medium |

**Estimated Time:** 12-15 hours

---

### Network Modules → unified-network.sh

| Old Module | New Function | Priority | Complexity |
|------------|--------------|----------|------------|
| ipv6.sh | `ipv6_*()` | Medium | Medium |
| edit-tools.sh | `edit_*()` | Low | Low |
| fix-ports.sh | `fix_ports()` | Medium | Low |
| notify.sh | `notify_*()` | Low | Low |

**Estimated Time:** 6-8 hours

---

## 📅 Implementation Plan

### Phase 1: Foundation (Week 1)

**Goal:** Create unified module structure and core libraries

**Tasks:**
1. Create `modules/unified-install.sh` skeleton
2. Create `modules/unified-adblock.sh` skeleton
3. Create `modules/unified-backup.sh` skeleton
4. Create `modules/unified-monitor.sh` skeleton
5. Create `modules/unified-security.sh` skeleton
6. Create `modules/unified-network.sh` skeleton
7. Create `lib/unified-core.sh` (shared functions)
8. Update `lib/module-loader.sh` for unified modules

**Deliverables:**
- 6 unified module skeletons
- Core library with shared functions
- Updated module loader

**Time:** 8-10 hours

---

### Phase 2: Installation Module (Week 1-2)

**Goal:** Consolidate all installation modules

**Tasks:**
1. Migrate `install-dnscrypt.sh` → `unified-install.sh`
2. Migrate `install-coredns.sh` → `unified-install.sh`
3. Migrate `install-nftables.sh` → `unified-install.sh`
4. Migrate `install-dashboard.sh` → `unified-install.sh`
5. Migrate `install-all.sh` → `unified-install.sh`
6. Migrate `install-wizard.sh` → `unified-install.sh`
7. Migrate `advanced-install.sh` → `unified-install.sh`
8. Migrate `check-dependencies.sh` → `unified-install.sh`
9. Create unified command interface
10. Add backward compatibility aliases

**Deliverables:**
- Complete `unified-install.sh` module
- Backward compatibility layer
- Unit tests

**Time:** 15-20 hours

---

### Phase 3: Ad Blocking & Backup (Week 2)

**Goal:** Consolidate adblock and backup modules

**Tasks:**
1. Migrate `adblock.sh` → `unified-adblock.sh`
2. Migrate `blocklist-manager.sh` → `unified-adblock.sh`
3. Migrate `config-backup.sh` → `unified-backup.sh`
4. Migrate `lkg.sh` → `unified-backup.sh`
5. Migrate `auto-update.sh` → `unified-backup.sh`
6. Create unified command interfaces
7. Add backward compatibility aliases

**Deliverables:**
- Complete `unified-adblock.sh` module
- Complete `unified-backup.sh` module
- Unit tests

**Time:** 15-20 hours

---

### Phase 4: Monitoring & Security (Week 3)

**Goal:** Consolidate monitoring and security modules

**Tasks:**
1. Migrate `diagnostics.sh` → `unified-monitor.sh`
2. Migrate `discover.sh` → `unified-monitor.sh`
3. Migrate `cache-stats.sh` → `unified-monitor.sh`
4. Migrate `health.sh` → `unified-monitor.sh`
5. Migrate `emergency.sh` → `unified-security.sh`
6. Migrate `ghost-check.sh` → `unified-security.sh`
7. Migrate `integrity.sh` → `unified-security.sh`
8. Migrate `location.sh` → `unified-security.sh`
9. Migrate `nft-debug.sh` → `unified-security.sh`
10. Migrate `supply-chain.sh` → `unified-security.sh`
11. Create unified command interfaces
12. Add backward compatibility aliases

**Deliverables:**
- Complete `unified-monitor.sh` module
- Complete `unified-security.sh` module
- Unit tests

**Time:** 24-30 hours

---

### Phase 5: Network & Finalization (Week 3-4)

**Goal:** Complete network module and finalize refactoring

**Tasks:**
1. Migrate `ipv6.sh` → `unified-network.sh`
2. Migrate `edit-tools.sh` → `unified-network.sh`
3. Migrate `fix-ports.sh` → `unified-network.sh`
4. Migrate `notify.sh` → `unified-network.sh`
5. Create unified command interface
6. Add backward compatibility aliases
7. Update main scripts (`citadel.sh`, `citadel_en.sh`)
8. Update module loader
9. Remove old modules (move to `legacy/`)
10. Update all documentation

**Deliverables:**
- Complete `unified-network.sh` module
- Updated main scripts
- Migrated old modules to legacy/
- Updated documentation

**Time:** 10-15 hours

---

### Phase 6: Testing & Documentation (Week 4)

**Goal:** Comprehensive testing and documentation

**Tasks:**
1. Unit tests for all unified modules
2. Integration tests
3. Smoke tests
4. Regression tests
5. Performance tests
6. Update MANUAL_PL.md
7. Update MANUAL_EN.md
8. Update quick-start.md
9. Update commands.md
10. Create migration guide
11. Update CHANGELOG.md
12. Update README.md

**Deliverables:**
- Complete test suite
- Updated documentation
- Migration guide
- Release notes

**Time:** 15-20 hours

---

## ⏰ Timeline & Milestones

### Week 1: Foundation & Installation

- **Day 1-2:** Foundation (skeletons, core library)
- **Day 3-5:** Installation module migration
- **Milestone:** `unified-install.sh` complete

### Week 2: Ad Blocking & Backup

- **Day 1-2:** Complete installation module
- **Day 3-4:** Ad blocking module migration
- **Day 5:** Backup module migration
- **Milestone:** `unified-adblock.sh` and `unified-backup.sh` complete

### Week 3: Monitoring & Security

- **Day 1-2:** Monitoring module migration
- **Day 3-5:** Security module migration
- **Milestone:** `unified-monitor.sh` and `unified-security.sh` complete

### Week 4: Network & Finalization

- **Day 1:** Network module migration
- **Day 2-3:** Main scripts update, cleanup
- **Day 4-5:** Testing and documentation
- **Milestone:** v3.2.0 ready for release

---

## 🧪 Testing Strategy

### Unit Tests

- Test each function in isolation
- Mock external dependencies
- Cover edge cases

### Integration Tests

- Test module interactions
- Test command flow
- Test error handling

### Smoke Tests

- Quick validation of basic functionality
- Run on every commit

### Regression Tests

- Ensure backward compatibility
- Test all old commands still work

### Performance Tests

- Measure execution time
- Compare with v3.1
- Ensure no performance degradation

---

## 🚀 Rollout Strategy

### Alpha Release (Internal Testing)

- **Version:** v3.2.0-alpha
- **Audience:** Developers only
- **Duration:** 1 week
- **Goal:** Find critical bugs

### Beta Release (Early Adopters)

- **Version:** v3.2.0-beta
- **Audience:** Volunteers from community
- **Duration:** 2 weeks
- **Goal:** Real-world testing

### Release Candidate

- **Version:** v3.2.0-rc
- **Audience:** All users (opt-in)
- **Duration:** 1 week
- **Goal:** Final validation

### Stable Release

- **Version:** v3.2.0
- **Audience:** All users
- **Announcement:** GitHub, Reddit, HN

---

## 📚 Documentation Updates

### User Documentation

- [ ] MANUAL_PL.md - Complete rewrite
- [ ] MANUAL_EN.md - Complete rewrite
- [ ] quick-start.md - Update commands
- [ ] commands.md - Update command list
- [ ] FAQ.md - Add migration questions
- [ ] deployment-examples.md - Update examples

### Developer Documentation

- [ ] REFACTORING-UNIFIED-INTERFACE.md - Update with actual implementation
- [ ] MODULES-LOGIC-MAP.md - Update with new structure
- [ ] CITADEL-STRUCTURE.md - Update architecture
- [ ] contributing.md - Update contribution guide

### Migration Guide

- [ ] Create MIGRATION-v3.1-to-v3.2.md
- [ ] List all breaking changes
- [ ] Provide command mappings
- [ ] Include troubleshooting

---

## ⚠️ Risks & Mitigation

### Risk 1: Breaking Changes

**Impact:** High  
**Probability:** High  
**Mitigation:**
- Backward compatibility layer
- Clear migration guide
- Deprecation warnings

### Risk 2: Testing Coverage

**Impact:** High  
**Probability:** Medium  
**Mitigation:**
- Comprehensive test suite
- Beta testing period
- Rollback plan

### Risk 3: User Adoption

**Impact:** Medium  
**Probability:** Medium  
**Mitigation:**
- Clear communication
- Migration guide
- Support in discussions

### Risk 4: Timeline Slippage

**Impact:** Low  
**Probability:** Medium  
**Mitigation:**
- Buffer time in schedule
- Prioritize critical features
- Phased rollout

---

## ✅ Success Criteria

### Technical

- ✅ 29 modules → 6 unified modules
- ✅ 0 code duplications
- ✅ All tests passing
- ✅ No performance degradation
- ✅ 100% backward compatibility

### User Experience

- ✅ Simpler command structure
- ✅ Consistent interface
- ✅ Clear documentation
- ✅ Easy migration path

### Project

- ✅ Easier to maintain
- ✅ Easier to extend
- ✅ Easier to contribute
- ✅ Better code quality

---

## 📞 Communication Plan

### Before Release

- [ ] Announcement in GitHub Discussions
- [ ] Update README with v3.2 plans
- [ ] Create tracking issue
- [ ] Weekly progress updates

### During Development

- [ ] Daily commits with clear messages
- [ ] Weekly progress reports
- [ ] Beta testing call
- [ ] Feedback collection

### After Release

- [ ] Release announcement
- [ ] Migration guide
- [ ] Support in discussions
- [ ] Bug fix releases

---

## 🎯 Next Steps

1. **Review this plan** - Get feedback from maintainer
2. **Create tracking issue** - GitHub issue for v3.2
3. **Set up branch** - `feature/v3.2-unified-modules`
4. **Start Phase 1** - Foundation work
5. **Weekly check-ins** - Progress updates

---

**Last updated:** 2026-01-31  
**Version:** 1.0  
**Status:** Planning Phase  
**Next Review:** Before Phase 1 start
