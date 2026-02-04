# Unified Recovery Module - Raport Analizy Kompletnej
# Data: 2026-02-04

## STATUS: ANALIZA ZAKOŃCZONA

---

## 1. PODSUMOWANIE KOMEND (58 komend)

### Komendy do unified-recovery (9 komend):
- panic-bypass, panic-restore, panic-status
- restore-system, restore-system-default
- emergency-network-restore, emergency-network-fix (NOWA)
- ipv6-emergency-reset, smart-ipv6-recovery

### Komendy pozostające w emergency.sh (4 komendy):
- emergency-refuse, emergency-restore, killswitch-on, killswitch-off

### Komendy niezwiązane z recovery (45 komend):
- install-*, adblock-*, blocklist-*, allowlist-*, health-*, ipv6-privacy-*
- auto-update-*, supply-chain-*, location-*, nft-debug-*, cache-stats-*
- notify-*, check-deps*, diagnostics, verify, test-all, status
- verify-config, edit*, logs, fix-ports, safe-test, test
- optimize-kernel, discover, integrity-*, help

---

## 2. KOD DO MIGRACJI

| Moduł | Funkcje | LOC |
|-------|---------|-----|
| emergency.sh | panic_bypass, panic_restore, panic_status | 119 |
| install-nftables.sh | restore_system, restore_system_default | 84 |
| uninstall.sh | DNS restore logic, DNS test | 90 |
| ipv6.sh | ipv6_deep_reset, smart_ipv6_detection | 70 |
| ~~f02f3c4~~ | ~~emergency_network_restore~~ | ~~171~~ |
| **RAZEM** | | **534 LOC** |

---

## 3. ARCHITEKTURA unified-recovery.sh

### GŁÓWNE FUNKCJE (public):
- restore_system() - przywracanie systemu z testem + fallback
- restore_system_default() - fabryczne przywracanie
- emergency_network_restore() - pełna naprawa sieci (z historii)
- emergency_network_fix() - szybka naprawa DNS
- panic_bypass() - tymczasowe wyłączenie ochrony
- panic_restore() - przywrócenie ochrony
- panic_status() - status panic
- ipv6_emergency_reset() - reset IPv6

### HELPERS (private):
- _test_connectivity() - test ping + DNS + opcjonalnie HTTP
- _offer_emergency_restore() - prompt przy failu
- _restore_dns_from_backup() - przywracanie z backupu
- _restore_dns_fallback() - fallback do public DNS
- _stop_citadel_services() - stop usług
- _flush_all_firewall() - flush nftables
- _detect_vpn_interfaces() - detekcja VPN
- _restart_all_network_services() - restart NM/systemd/dhcpcd
- _flush_dns_caches() - czyszczenie cache

---

## 4. OSZCZĘDNOŚĆ KODU

| Moduł | Obecnie | Po | Zmiana |
|-------|---------|-----|--------|
| unified-recovery.sh | 0 | 1100 | +1100 |
| emergency.sh | 213 | 94 | -119 |
| install-nftables.sh | 307 | 223 | -84 |
| uninstall.sh | 233 | 143 | -90 |
| ipv6.sh | 207 | 137 | -70 |
| **RAZEM** | **960** | **1697** | **-363 netto** |

**Netto:** +1100 - 363 = +737 LOC (dodatkowa funkcjonalność)

---

## 5. ZALETY (PROS)

1. **Centralizacja** - jedno miejsce dla wszystkich funkcji recovery
2. **Niezawodność** - restore-system zawsze testuje łączność przed zakończeniem
3. **Graceful degradation** - automatyczny fallback do emergency-network-restore
4. **VPN-aware** - emergency_network_restore obsługuje VPN (tun, wg, ovpn)
5. **Deduplikacja** - jedna funkcja _test_dns_connectivity() zamiast 3 kopii
6. **Łatwiejsze testowanie** - jeden moduł do przetestowania
7. **Spójność UX** - jednolity styl komunikatów
8. **i18n łatwiejsze** - wszystkie tłumaczenia recovery w jednym miejscu

---

## 6. WADY (CONS)

1. **Złożoność modułu** - 1100 LOC w jednym pliku
2. **Zależności** - unified-recovery musi być załadowany przed użyciem
3. **Refactoring** - zmiana wymaga przetestowania wielu ścieżek
4. **Backward compat** - trzeba zachować aliasy w oryginalnych modułach
5. **Czas implementacji** - ~8-10h pracy
6. **Ryzyko regresji** - zmiana krytycznych funkcji recovery

---

## 7. WPŁYW NA PROJEKT

### Co się zmieni:
- emergency.sh: uproszczenie (94 LOC)
- install-nftables.sh: bez restore_system (223 LOC)
- uninstall.sh: uproszczenie logiki DNS (143 LOC)
- ipv6.sh: bez deep_reset (137 LOC)
- Nowy moduł: unified-recovery.sh (~1100 LOC)

### Co się NIE zmieni:
- Wszystkie komendy pozostają dostępne
- Funkcjonalność identyczna
- Dispatcher w citadel.sh tylko zmienia moduł docelowy

### Ryzyka:
- Potencjalne błędy w migracji
- Zależności cykliczne jeśli niepoprawnie zaimplementowane

---

## 8. REKOMENDACJE

### Opcja A: FULL MIGRATION (zalecana)
- Zaimplementować unified-recovery.sh ze wszystkimi funkcjami
- Przenieść panic_*(), restore_system(), ipv6_deep_reset()
- Przywrócić emergency_network_restore() z historii
- Dodać integrację restore-system → emergency fallback

### Opcja B: PARTIAL (bezpieczniejsza)
- Tylko przywrócić emergency_network_restore()
- Dodać ją jako osobną komendę
- Nie ruszać panic_*() i restore_system()

### Opcja C: NO CHANGE
- Oznaczyć emergency-network-restore jako "deprecated"
- Zmienić UI na używanie panic-restore lub restore-system
- Nie dodawać nowego kodu

---

## REKOMENDACJA AUTORA: OPCJA A

Zalety przeważają nad wadami:
- Lepsza architektura (centralizacja)
- Większa niezawodność (testowanie + fallback)
- Lepsze UX (użytkownik nigdy nie zostaje bez internetu)
- Łatwiejsze utrzymanie (jeden moduł zamiast 4)

---

## NASTĘPNE KROKI

1. Zatwierdzenie architektury przez użytkownika
2. Aktualizacja REFACTORING-V3.2-PLAN.md
3. Implementacja unified-recovery.sh
4. Migracja funkcji z istniejących modułów
5. Aktualizacja dispatcher'a w citadel.sh
6. Dodanie i18n dla recovery
7. Testowanie wszystkich ścieżek
8. Dokumentacja zmian
