# Moduł Unified Recovery - Plan TODO
# Utworzono: 2026-02-04

## Faza 1: Analiza i Odkrywanie
- [ ] Przeszukać wszystkie moduły pod kątem funkcji recovery/restore/fix
- [ ] Zidentyfikować nakładające się funkcjonalności
- [ ] Udokumentować aktualny stan

## Faza 2: Projekt Architektury
- [ ] Zdefiniować zunifikowaną hierarchię funkcji
- [ ] Zaprojektować przepływy integracji
- [ ] Zaplanować strukturę i18n

## Faza 3: Implementacja
- [ ] Utworzyć modules/unified-recovery.sh
- [ ] Migrować funkcje panic_* z emergency.sh
- [ ] Migrować restore_system z install-nftables.sh
- [ ] Przywrócić emergency_network_restore z f02f3c4
- [ ] Dodać testowanie łączności
- [ ] Dodać prompts fallback
- [ ] Utworzyć tłumaczenia lib/i18n/recovery/
- [ ] Zaktualizować dispatcher citadel.sh
- [ ] Dodać aliasy kompatybilności wstecznej

## Faza 4: Testowanie
- [ ] Testować restore-system → ścieżka sukcesu
- [ ] Testować restore-system → fail → ścieżka awaryjna
- [ ] Testować przepływ panic bypass/restore
- [ ] Testować na systemie z VPN
- [ ] Testować na systemie bez backupu
