# Citadel v3.2+ Revised Roadmap

**Date:** 2026-02-01  
**Status:** DRAFT - Internal Review  
**Replaces:** REFACTORING-V3.2-PLAN.md

---

## Problem Statement

Existing v3.2 plan (`REFACTORING-V3.2-PLAN.md`) was written **before** v3.1 completion and contains:
- **Outdated assumptions** (plans to create `lib/cytadela-core.sh` which already exists in v3.1)
- **Conflicting scope** (refactor 29→6 modules vs Gateway Mode feature)
- **Unrealistic timeline** (3-4 weeks for 150KB refactor + tests + docs)

---

## Decision: Hybrid Approach (Recommended)

### Philosophy
- **Don't break working architecture** - v3.1 modular design is solid
- **Incremental improvement** over revolutionary rewrite
- **User value first** - features before refactoring

---

## Revised Timeline

### v3.2 (Q1 2026) - Gateway Focus
**Goal:** Network Gateway Mode for home users

**Features:**
1. **Gateway Mode** (PRIORITY #1)
   - DHCP server (dnsmasq)
   - NAT & routing (nftables)
   - Per-device stats
   - Commands: `gateway-wizard`, `gateway-status`, `gateway-devices`
   - **Effort:** ~20-25h

2. **Terminal UI (TUI)**
   - ncurses dashboard
   - Works over SSH
   - Commands: `tui-start`, `tui-status`
   - **Effort:** ~10-12h

3. **Bug fixes from v3.1**
   - Continue fixing edge cases
   - **Effort:** ~5h

**Total:** ~35-42h (6-7 weeks realistic)

---

### v3.3 (Q2 2026) - Automation & Control
**Goal:** Parental Control + Full Automation

**Features:**
1. **Parental Control** (Issue #26)
   - Kids/Teens profiles
   - Time schedules
   - Category blocking
   - **Effort:** ~12-15h

2. **Full Auto-update** (Issue #27)
   - Auto-update all components
   - Pre-update backup
   - Auto-rollback on failure
   - **Effort:** ~10-12h

3. **Full Backup/Restore** (Issue #28)
   - One-command full system backup
   - Cloud backup option (rsync/Nextcloud)
   - **Effort:** ~8-10h

**Total:** ~30-37h (5-6 weeks)

---

### v3.4 (Q3 2026) - Unified Architecture (Refactor)
**Goal:** Consolidate modules without breaking changes

**Approach:** Gradual migration, not big-bang rewrite

**Phase 1: Foundation**
- Create `lib/unified-helpers.sh` with shared functions
- Extract common patterns from existing modules
- No breaking changes
- **Effort:** ~8-10h

**Phase 2: Module Consolidation (per-release)**
- v3.4.0: Merge `adblock.sh` + `blocklist-manager.sh` → `adblock-unified.sh`
- v3.4.1: Merge `config-backup.sh` + `lkg.sh` + `auto-update.sh` → `backup-unified.sh`
- v3.4.2: Merge `diagnostics.sh` + `discover.sh` + `health.sh` → `monitor-unified.sh`
- Each: ~6-8h + testing

**Phase 3: Cleanup**
- Deprecate old modules (keep for 2 releases)
- Update documentation
- **Effort:** ~5h

**Total:** ~25-35h over 3 minor releases

---

### v3.5+ (2027+) - Advanced Features
**Goal:** Enterprise features (low priority)

- Grafana/Prometheus (#19)
- IDS DNS (#20)
- Per-device policies (#21)
- DNS Sinkhole (#22)
- Immutable OS (#23)
- Geo/ASN Firewall (#24)

**Only if** community demand exists.

---

## Technical Decisions

### 1. No Breaking Changes in v3.2-v3.3
- Keep existing 29-module structure
- Add new modules alongside existing
- Old commands continue working

### 2. Refactor in v3.4 (Gradual)
- Create unified modules as **new files**
- Old modules call new ones (compatibility layer)
- After 2 releases, remove old modules

### 3. Command Structure

**v3.2-v3.3 (Current style):**
```bash
cytadela++ gateway-wizard
cytadela++ parental-add --profile=kids
```

**v3.4+ (Optional new style):**
```bash
cytadela++ gateway wizard      # new unified
cytadela++ parental add --profile=kids  # new unified
# OR keep old style via compatibility layer
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Gateway too complex | Start with basic DHCP+NAT, add features iteratively |
| TUI adds deps | Make optional, fallback to CLI if ncurses missing |
| v3.4 refactor breaks things | Keep old modules for 2 releases, parallel testing |
| Timeline slip | Cut scope, not quality. Gateway MVP without per-device stats ok |

---

## Success Criteria

**v3.2:**
- [ ] Gateway mode works on 2-ethernet machine
- [ ] TUI runs without GUI
- [ ] All v3.1 commands still work

**v3.3:**
- [ ] Parental control blocks adult sites
- [ ] Auto-update works 7 days without issues
- [ ] Backup/restore migrates to new machine

**v3.4:**
- [ ] Module count reduced (29 → ~15)
- [ ] No functional regressions
- [ ] Tests pass for all unified modules

---

## Next Steps

1. **Review this plan** - Confirm direction
2. **Create v3.2 tracking issue** - Gateway Mode
3. **Start Gateway Mode** - DHCP + NAT foundation
4. **Weekly check-ins** - Scope adjustment as needed

---

**Decision needed:** Confirm Hybrid Approach or choose Alternative:
- **Alt A:** Full refactor first (v3.2 = 6 unified modules, push features to v3.4)
- **Alt B:** Skip refactor entirely (keep 29 modules, add features only)
