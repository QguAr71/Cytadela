# Unified Recovery Module - TODO Plan
# Created: 2026-02-04

## Phase 1: Analysis & Discovery
- [ ] Search all modules for recovery/restore/fix functions
- [ ] Identify overlapping functionalities
- [ ] Document current state

## Phase 2: Architecture Design
- [ ] Define unified function hierarchy
- [ ] Design integration flows
- [ ] Plan i18n structure

## Phase 3: Implementation
- [ ] Create modules/unified-recovery.sh
- [ ] Migrate panic_* functions from emergency.sh
- [ ] Migrate restore_system from install-nftables.sh
- [ ] Restore emergency_network_restore from f02f3c4
- [ ] Add connectivity testing
- [ ] Add fallback prompts
- [ ] Create lib/i18n/recovery/ translations
- [ ] Update citadel.sh dispatcher
- [ ] Add backward compatibility aliases

## Phase 4: Testing
- [ ] Test restore-system → success path
- [ ] Test restore-system → fail → emergency path
- [ ] Test panic bypass/restore flow
- [ ] Test on system with VPN
- [ ] Test on system without backup
