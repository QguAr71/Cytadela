# CYTADELA++ REFACTORING ANALYSIS - Issues #11 & #12
**Data:** 2026-01-30  
**Cel:** Deduplikacja PL/EN + Modularyzacja

---

## PHASE 1: ANALIZA KODU

### 1.1 Statystyki Podstawowe

| Plik | Linie | Funkcje | Rozmiar |
|------|-------|---------|---------|
| `cytadela++.sh` (PL) | 3644 | 84 | ~150KB |
| `citadela_en.sh` (EN) | 3509 | 84 | ~145KB |
| **RAZEM** | **7153** | **168** | **~295KB** |

**Potencjał oszczędności:** ~3000-3500 linii po deduplikacji

---

### 1.2 FUNKCJE IDENTYCZNE (100% duplikacja logiki)

Funkcje te mają **identyczną logikę**, różnią się tylko komunikatami w języku naturalnym:

#### **Grupa A: Integrity & Security (Local-First)**
1. `trap_err_handler()` - Global error trap
2. `integrity_verify_file()` - Weryfikacja SHA256
3. `integrity_check()` - Sprawdzanie manifestu
4. `integrity_init()` - Tworzenie manifestu
5. `integrity_status()` - Status integrity

#### **Grupa B: Network Discovery**
6. `discover_active_interface()` - Wykrywanie aktywnego interfejsu
7. `discover_network_stack()` - Wykrywanie NetworkManager/systemd-networkd
8. `discover_nftables_status()` - Status NFTables
9. `discover()` - Pełny snapshot sieci

#### **Grupa C: IPv6 Management**
10. `ipv6_privacy_auto_ensure()` - Auto-konfiguracja privacy extensions
11. `ipv6_deep_reset()` - Reset IPv6 stack
12. `ipv6_privacy_on()` - Włączanie privacy extensions
13. `ipv6_privacy_off()` - Wyłączanie privacy extensions
14. `ipv6_privacy_status()` - Status privacy extensions
15. `smart_ipv6_detection()` - Auto-detekcja IPv6

#### **Grupa D: LKG (Last Known Good)**
16. `lkg_validate_blocklist()` - Walidacja blocklist
17. `lkg_save_blocklist()` - Zapis do cache
18. `lkg_restore_blocklist()` - Przywracanie z cache
19. `lkg_status()` - Status LKG
20. `lists_update()` - Aktualizacja z LKG fallback

#### **Grupa E: Panic/Emergency Mode**
21. `panic_bypass()` - Tryb awaryjny z auto-rollback
22. `panic_restore()` - Przywracanie z panic mode
23. `panic_status()` - Status panic mode
24. `emergency_refuse()` - DNS refuse mode
25. `emergency_restore()` - Przywracanie normalnego trybu
26. `emergency_killswitch_on()` - Aktywacja kill-switch
27. `emergency_killswitch_off()` - Deaktywacja kill-switch

#### **Grupa F: Ghost-Check & Port Audit**
28. `ghost_check()` - Audyt otwartych portów

#### **Grupa G: Health Checks**
29. `health_check_dns()` - Probe DNS
30. `health_status()` - Status zdrowia systemu
31. `install_health_watchdog()` - Instalacja watchdog
32. `uninstall_health_watchdog()` - Usuwanie watchdog

#### **Grupa H: Supply-Chain Verification**
33. `supply_chain_verify_file()` - Weryfikacja pliku
34. `supply_chain_download()` - Pobieranie z weryfikacją
35. `supply_chain_status()` - Status supply-chain
36. `supply_chain_init()` - Inicjalizacja checksums
37. `supply_chain_verify()` - Weryfikacja całości

#### **Grupa I: Location-Aware Advisory**
38. `location_get_ssid()` - Pobieranie SSID
39. `location_is_trusted()` - Sprawdzanie zaufania
40. `location_get_firewall_mode()` - Tryb firewall
41. `location_status()` - Status lokalizacji
42. `location_check()` - Sprawdzanie i advisory
43. `location_add_trusted()` - Dodawanie SSID
44. `location_remove_trusted()` - Usuwanie SSID
45. `location_list_trusted()` - Lista zaufanych

#### **Grupa J: NFTables Debug**
46. `nft_debug_on()` - Włączanie debug chain
47. `nft_debug_off()` - Wyłączanie debug chain
48. `nft_debug_status()` - Status debug
49. `nft_debug_logs()` - Logi debug

#### **Grupa K: Utility Functions**
50. `require_cmd()` - Sprawdzanie dostępności komendy
51. `require_cmds()` - Sprawdzanie wielu komend
52. `dnssec_enabled()` - Sprawdzanie flagi DNSSEC
53. `port_in_use()` - Sprawdzanie portu
54. `pick_free_port()` - Wybór wolnego portu
55. `get_dnscrypt_listen_port()` - Port DNSCrypt
56. `get_coredns_listen_port()` - Port CoreDNS

#### **Grupa L: Core Installation Modules**
57. `install_dnscrypt()` - Instalacja DNSCrypt-Proxy
58. `install_coredns()` - Instalacja CoreDNS
59. `install_nftables()` - Instalacja NFTables
60. `firewall_safe()` - Firewall SAFE mode
61. `firewall_strict()` - Firewall STRICT mode
62. `configure_system()` - Konfiguracja systemu
63. `restore_system()` - Przywracanie systemd-resolved
64. `install_all()` - Pełna instalacja

#### **Grupa M: Adblock Management**
65. `adblock_rebuild()` - Rebuild combined.hosts
66. `adblock_reload()` - Reload CoreDNS
67. `adblock_status()` - Status adblock
68. `adblock_stats()` - Statystyki
69. `adblock_show()` - Wyświetlanie list
70. `adblock_query()` - Query DNS
71. `adblock_add()` - Dodawanie domeny
72. `adblock_remove()` - Usuwanie domeny
73. `adblock_edit()` - Edycja custom.hosts
74. `allowlist_list()` - Lista allowlist
75. `allowlist_add()` - Dodawanie do allowlist
76. `allowlist_remove()` - Usuwanie z allowlist

#### **Grupa N: Diagnostics**
77. `run_diagnostics()` - Pełna diagnostyka
78. `verify_stack()` - Weryfikacja stacku
79. `test_all()` - Wszystkie testy

#### **Grupa O: New Features v3.0**
80. `install_citadel_top()` - Terminal dashboard
81. `install_editor_integration()` - Integracja edytora
82. `optimize_kernel_priority()` - Optymalizacja priorytetów
83. `install_doh_parallel()` - DoH parallel racing
84. `fix_port_conflicts()` - Rozwiązywanie konfliktów portów
85. `safe_test_mode()` - Tryb testowy

#### **Grupa P: Logging (inline functions)**
86. `log_info()` - Info message
87. `log_success()` - Success message
88. `log_warning()` - Warning message
89. `log_error()` - Error message
90. `log_section()` - Section header

---

### 1.3 FUNKCJE SPECYFICZNE DLA JĘZYKA

**TYLKO komunikaty różnią się:**
- `show_help()` - Pełny help w PL/EN (różne teksty, ta sama struktura)

**Wszystkie pozostałe funkcje są identyczne pod względem logiki!**

---

### 1.4 ZMIENNE GLOBALNE I STAŁE

#### Identyczne w obu wersjach:
```bash
# Paths
CYTADELA_MANIFEST="/etc/cytadela/manifest.sha256"
CYTADELA_STATE_DIR="/var/lib/cytadela"
CYTADELA_LKG_DIR="${CYTADELA_STATE_DIR}/lkg"
CYTADELA_OPT_BIN="/opt/cytadela/bin"
CYTADELA_MODE="secure"
CYTADELA_SCRIPT_PATH="$(realpath "$0")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Ports
DNSCRYPT_PORT_DEFAULT=5353
COREDNS_PORT_DEFAULT=53
COREDNS_METRICS_ADDR="127.0.0.1:9153"

# LKG
LKG_BLOCKLIST="${CYTADELA_LKG_DIR}/blocklist.hosts"
LKG_BLOCKLIST_META="${CYTADELA_LKG_DIR}/blocklist.meta"

# Panic
PANIC_STATE_FILE="${CYTADELA_STATE_DIR}/panic.state"
PANIC_BACKUP_RESOLV="${CYTADELA_STATE_DIR}/resolv.conf.pre-panic"
PANIC_ROLLBACK_TIMER=300

# Ghost-Check
GHOST_ALLOWED_PORTS=(22 53 5353 9153)

# Health
HEALTH_CHECK_SERVICES=(dnscrypt-proxy coredns)

# Supply-Chain
SUPPLY_CHAIN_CHECKSUMS="/etc/cytadela/checksums.sha256"

# Location
TRUSTED_SSIDS_FILE="/etc/cytadela/trusted-ssids.txt"

# NFT Debug
NFT_DEBUG_TABLE="citadel_debug"
```

---

## PHASE 1 PODSUMOWANIE

### Kluczowe Odkrycia:

1. **~90 funkcji jest identycznych** - różnią się tylko komunikatami użytkownika
2. **Duplikacja wynosi ~95%** kodu logicznego
3. **Tylko 1 funkcja** (`show_help`) wymaga osobnej wersji PL/EN
4. **Wszystkie zmienne globalne są identyczne**
5. **Case statement w main()** jest identyczny (tylko wywołania funkcji)

### Potencjał Optymalizacji:

- **Przed:** 7153 linie w 2 plikach
- **Po deduplikacji:** ~2000-2500 linii core + 2x ~500 linii wrapper = **~3500 linii**
- **Oszczędność:** **~3600 linii (50%)**

### Następne Kroki:

✅ **PHASE 1 ZAKOŃCZONA**  
➡️ **PHASE 2:** Projektowanie architektury
