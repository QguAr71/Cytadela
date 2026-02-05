# Aktualny Inwentarz Poleceń - Linia Bazowa v3.1

Wygenerowano: śro, 4 lut 2026, 17:02:51 CET


## Inwentarz Poleceń - Linia Bazowa v3.1

Ten dokument zawiera listę wszystkich dostępnych poleceń w Cytadela v3.1, które muszą być zachowane
podczas refaktoryzacji zunifikowanych modułów v3.2 dla kompatybilności wstecznej.

Wygenerowano: $(date)
Źródło: dispatcher citadel.sh

### 1. Polecenia Pomocy
- help | --help | -h
  - Moduł: help
  - Funkcja: citadel_help
  - Opis: Wyświetl informacje pomocy

### 2. Polecenia Integralności
- integrity-init | integrity-check | integrity-status
  - Moduł: integrity
  - Funkcja: call_fn "$ACTION"
  - Opis: System weryfikacji integralności plików

### 3. Polecenia Odkrywania
- discover
  - Moduł: discover
  - Funkcja: call_fn "$ACTION"
  - Opis: Odkrywanie sieci/usług

### 4. Polecenia IPv6
- ipv6-privacy-on | ipv6-privacy-off | ipv6-privacy-status | ipv6-privacy-auto | ipv6-deep-reset | smart-ipv6
  - Moduł: ipv6
  - Funkcja: call_fn "$ACTION"
  - Opis: Funkcje prywatności i zarządzania IPv6

### 5. Polecenia LKG
- lkg-save | lkg-restore | lkg-status | lists-update
  - Moduł: lkg
  - Funkcja: call_fn "$ACTION"
  - Opis: Zarządzanie konfiguracją Last Known Good

### 6. Polecenia Auto-aktualizacji
- auto-update-enable | auto-update-disable | auto-update-status | auto-update-now | auto-update-configure
  - Moduł: auto-update
  - Funkcja: call_fn "$ACTION"
  - Opis: Zarządzanie automatycznymi aktualizacjami

### 7. Polecenia Awaryjne
- panic-bypass | panic-restore | panic-status | emergency-refuse | emergency-restore | killswitch-on | killswitch-off
  - Moduł: emergency
  - Funkcja: call_fn "$ACTION" "$@" || true
  - Opis: Odzyskiwanie awaryjne i bypass bezpieczeństwa

### 8. Polecenia Adblock
- adblock-status | adblock-stats | adblock-show | adblock-query | adblock-add | adblock-remove | adblock-edit | adblock-rebuild
  - Moduł: adblock
  - Funkcja: call_fn "$ACTION" "$@"
  - Opis: Zarządzanie blokowaniem reklam

### 9. Aliasy Legacy Adblock
- blocklist (alias dla adblock_show blocklist)
- combined (alias dla adblock_show combined)
- custom (alias dla adblock_show custom)
  - Moduł: adblock
  - Funkcja: adblock_show [type]
  - Opis: Aliasy wyświetlania adblock legacy

### 10. Polecenia Blocklist Manager
- blocklist-list | blocklist-switch | blocklist-status | blocklist-add-url | blocklist-remove-url | blocklist-show-urls
  - Moduł: blocklist-manager
  - Funkcja: call_fn "$ACTION" "$@"
  - Opis: Zarządzanie źródłami blocklist

### 11. Polecenia Allowlist
- allowlist-list | allowlist-add | allowlist-remove
  - Moduł: adblock
  - Funkcja: call_fn "$ACTION" "$@"
  - Opis: Zarządzanie listami wyjątków

### 12. Polecenia Ghost Check
- ghost-check
  - Moduł: ghost-check
  - Funkcja: call_fn "$ACTION"
  - Opis: Audyt bezpieczeństwa dla otwartych portów

### 13. Polecenia Zdrowia
- health-status | health-install | health-uninstall
  - Moduł: health
  - Funkcja: call_fn "$ACTION"
  - Opis: Monitorowanie zdrowia usług

### 14. Polecenia Deinstalacji
- uninstall | uninstall-keep-config
  - Moduł: uninstall
  - Funkcja: call_fn "citadel_$ACTION"
  - Opis: Deinstalacja systemu

### 15. Polecenia Supply Chain
- supply-chain-status | supply-chain-init | supply-chain-verify
  - Moduł: supply-chain
  - Funkcja: call_fn "$ACTION"
  - Opis: System weryfikacji binarnej

### 16. Polecenia Lokalizacji
- location-status | location-check | location-add-trusted | location-remove-trusted | location-list-trusted
  - Moduł: location
  - Funkcja: call_fn "$ACTION" "$@"
  - Opis: Polityki bezpieczeństwa oparte na lokalizacji

### 17. Polecenia NFT Debug
- nft-debug-on | nft-debug-off | nft-debug-status | nft-debug-logs
  - Moduł: nft-debug
  - Funkcja: call_fn "$ACTION"
  - Opis: Narzędzia debugowania firewall

### 18. Polecenia Sprawdzania Zależności
- check-deps | check-dependencies [--install]
  - Moduł: check-dependencies
  - Funkcja: check_dependencies / check_dependencies_install
  - Opis: Weryfikacja zależności systemu

### 19. Polecenia Instalacji
- install-wizard
  - Moduł: install-wizard
  - Funkcja: install_wizard
  - Opis: Interaktywny kreator instalacji

- install-dnscrypt
  - Moduł: install-dnscrypt
  - Funkcja: install_dnscrypt
  - Opis: Instalacja DNSCrypt-Proxy

- install-coredns
  - Moduł: install-coredns
  - Funkcja: install_coredns
  - Opis: Instalacja CoreDNS

- install-nftables | firewall-safe | firewall-strict | configure-system | restore-system | restore-system-default
  - Moduł: install-nftables
  - Funkcja: call_fn "$ACTION"
  - Opis: Konfiguracja firewall i systemu

- install-all
  - Moduł: install-all
  - Funkcja: install_all
  - Opis: Kompletna instalacja systemu

### 20. Polecenia Backup Konfiguracji
- config-backup | config-restore | config-list | config-delete
  - Moduł: config-backup
  - Funkcja: call_fn "$ACTION" "$@"
  - Opis: Zarządzanie backupem konfiguracji

### 21. Polecenia Statystyk Cache
- cache-stats | cache-stats-top | cache-stats-reset | cache-stats-watch
  - Moduł: cache-stats
  - Funkcja: call_fn "$ACTION" "$@"
  - Opis: Statystyki cache DNS

### 22. Polecenia Powiadomień
- notify-enable | notify-disable | notify-status | notify-test
  - Moduł: notify
  - Funkcja: call_fn "$ACTION"
  - Opis: Zarządzanie systemem powiadomień

### 23. Polecenia Zaawansowanej Instalacji
- optimize-kernel
  - Moduł: advanced-install
  - Funkcja: optimize_kernel_priority
  - Opis: Optymalizacja kernela

- install-doh-parallel
  - Moduł: advanced-install
  - Funkcja: install_doh_parallel
  - Opis: Konfiguracja równoległego resolvera DoH

- install-editor
  - Moduł: advanced-install
  - Funkcja: install_editor_integration
  - Opis: Konfiguracja integracji edytora

### 24. Polecenia Dashboard
- install-dashboard
  - Moduł: install-dashboard
  - Funkcja: install_citadel_top
  - Opis: Instalacja dashboard

### 25. Polecenia Narzędzi Edycji
- edit
  - Moduł: edit-tools
  - Funkcja: edit_config
  - Opis: Edycja plików konfiguracyjnych

- edit-dnscrypt
  - Moduł: edit-tools
  - Funkcja: edit_dnscrypt
  - Opis: Edycja konfiguracji DNSCrypt

- logs
  - Moduł: edit-tools
  - Funkcja: show_logs
  - Opis: Przeglądarka plików logów

### 26. Polecenia Narzędzi Testowania
- safe-test
  - Moduł: test-tools
  - Funkcja: safe_test_mode
  - Opis: Tryb bezpiecznego testowania

- test
  - Moduł: test-tools
  - Funkcja: test_dns
  - Opis: Testowanie DNS

### 27. Polecenia Naprawy Portów
- fix-ports
  - Moduł: fix-ports
  - Funkcja: fix_port_conflicts
  - Opis: Rozwiązywanie konfliktów portów

### 28. Polecenia Diagnostyki
- diagnostics | verify | test-all | status
  - Moduł: diagnostics
  - Funkcja: run_diagnostics / verify_stack / test_all / show_status
  - Opis: Diagnostyka systemu i weryfikacja

### 29. Polecenia Weryfikacji Konfiguracji
- verify-config [check|dns|services|files|all|help]
  - Moduł: verify-config
  - Funkcja: verify_config_*
  - Opis: Weryfikacja konfiguracji

---

## Statystyki Podsumowujące

- **Razem Grup Poleceń:** 29
- **Razem Indywidualnych Poleceń:** ~85+
- **Modułów Odwołanych:** 25
- **Funkcji do Zachowania:** 100% kompatybilności wstecznej wymagane

## Lista Sprawdzająca Weryfikację

Podczas implementacji v3.2, upewnij się:
- [ ] Wszystkie powyższe polecenia działają identycznie
- [ ] Wszystkie sygnatury funkcji zachowane
- [ ] Wszystkie komunikaty błędów utrzymane
- [ ] Wszystkie teksty pomocy zachowane
- [ ] Wszystkie aliasy funkcjonalne
- [ ] Wydajność nie pogorszona
