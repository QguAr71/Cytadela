# CYTADELA++ FUNCTION DEPENDENCY MAP
**Analiza zależności między funkcjami dla Issues #11 & #12**

---

## MAPA ZALEŻNOŚCI FUNKCJI

### 1. CORE UTILITIES (Poziom 0 - brak zależności)

```
log_info()
log_success()
log_warning()
log_error()
log_section()
trap_err_handler()
require_cmd()
require_cmds()
dnssec_enabled()
```

**Charakterystyka:**
- Nie wywołują innych funkcji z projektu
- Używane przez wszystkie inne moduły
- Kandydaci do `cytadela-core.sh`

---

### 2. NETWORK UTILITIES (Poziom 1 - zależą tylko od Core)

```
discover_active_interface()
  └─ używa: ip, awk (external)

discover_network_stack()
  └─ używa: systemctl, nmcli (external)

discover_nftables_status()
  └─ używa: nft (external)

port_in_use()
  └─ używa: ss, awk, grep (external)

pick_free_port()
  └─ wywołuje: port_in_use()

get_dnscrypt_listen_port()
  └─ używa: awk (external)

get_coredns_listen_port()
  └─ używa: awk (external)
```

**Charakterystyka:**
- Zależą tylko od external tools
- Używane przez moduły wyższego poziomu
- Kandydaci do `lib/network-utils.sh`

---

### 3. INTEGRITY MODULE (Poziom 1-2)

```
integrity_verify_file()
  └─ używa: sha256sum (external)

integrity_check()
  ├─ wywołuje: integrity_verify_file()
  ├─ wywołuje: log_info(), log_success(), log_warning(), log_error()
  └─ używa: CYTADELA_MODE, CYTADELA_MANIFEST

integrity_init()
  ├─ wywołuje: log_info(), log_success(), log_section()
  └─ używa: sha256sum (external)

integrity_status()
  ├─ wywołuje: log_section()
  └─ używa: grep, find (external)
```

**Charakterystyka:**
- Moduł samodzielny
- Kandydat do `modules/integrity.sh`

---

### 4. LKG MODULE (Poziom 2)

```
lkg_validate_blocklist()
  ├─ wywołuje: log_warning()
  └─ używa: wc, grep (external)

lkg_save_blocklist()
  ├─ wywołuje: lkg_validate_blocklist()
  ├─ wywołuje: log_warning(), log_success()
  └─ używa: cp, sha256sum (external)

lkg_restore_blocklist()
  ├─ wywołuje: lkg_validate_blocklist()
  ├─ wywołuje: log_warning(), log_error(), log_success()
  └─ używa: cp, chown, chmod (external)

lkg_status()
  ├─ wywołuje: log_section()
  └─ używa: wc, cat (external)

lists_update()
  ├─ wywołuje: log_section(), log_info(), log_warning(), log_success()
  ├─ wywołuje: lkg_validate_blocklist()
  ├─ wywołuje: lkg_save_blocklist()
  ├─ wywołuje: lkg_restore_blocklist()
  ├─ wywołuje: adblock_rebuild()
  ├─ wywołuje: adblock_reload()
  └─ używa: curl, mktemp (external)
```

**Charakterystyka:**
- Zależny od adblock module
- Kandydat do `modules/lkg.sh`

---

### 5. ADBLOCK MODULE (Poziom 1-2)

```
adblock_rebuild()
  └─ używa: cat, sort, awk (external)

adblock_reload()
  └─ używa: systemctl (external)

adblock_status()
  ├─ wywołuje: log_section()
  └─ używa: systemctl, grep, wc (external)

adblock_stats()
  ├─ wywołuje: log_section()
  └─ używa: wc (external)

adblock_show()
  ├─ wywołuje: log_error()
  └─ używa: sed (external)

adblock_query()
  ├─ wywołuje: log_error()
  └─ używa: dig (external)

adblock_add()
  ├─ wywołuje: log_error(), log_info(), log_success()
  ├─ wywołuje: adblock_rebuild()
  ├─ wywołuje: adblock_reload()
  └─ używa: grep, printf (external)

adblock_remove()
  ├─ wywołuje: log_error(), log_warning(), log_success()
  ├─ wywołuje: adblock_rebuild()
  ├─ wywołuje: adblock_reload()
  └─ używa: sed (external)

adblock_edit()
  ├─ wywołuje: adblock_rebuild()
  ├─ wywołuje: adblock_reload()
  └─ używa: $EDITOR (external)

allowlist_list()
  └─ używa: cat (external)

allowlist_add()
  ├─ wywołuje: log_error(), log_info(), log_success()
  ├─ wywołuje: adblock_rebuild()
  ├─ wywołuje: adblock_reload()
  └─ używa: grep, printf (external)

allowlist_remove()
  ├─ wywołuje: log_error(), log_warning(), log_success()
  ├─ wywołuje: adblock_rebuild()
  ├─ wywołuje: adblock_reload()
  └─ używa: sed (external)
```

**Charakterystyka:**
- Moduł samodzielny z wewnętrznymi zależnościami
- Kandydat do `modules/adblock.sh`

---

### 6. PANIC/EMERGENCY MODULE (Poziom 2)

```
panic_bypass()
  ├─ wywołuje: log_section(), log_warning(), log_info(), log_success()
  └─ używa: cp, nft, date, cat (external)

panic_restore()
  ├─ wywołuje: log_section(), log_info(), log_success()
  └─ używa: rm, cp, nft, systemctl (external)

panic_status()
  ├─ wywołuje: log_section(), log_warning(), log_info(), log_success()
  └─ używa: cat (external)

emergency_refuse()
  ├─ wywołuje: log_section(), log_warning()
  └─ używa: systemctl, tee (external)

emergency_restore()
  ├─ wywołuje: log_section(), log_success()
  └─ używa: cp, systemctl (external)

emergency_killswitch_on()
  ├─ wywołuje: log_section(), log_warning()
  └─ używa: nft (external)

emergency_killswitch_off()
  ├─ wywołuje: log_section(), log_success()
  └─ używa: nft (external)
```

**Charakterystyka:**
- Moduł samodzielny
- Kandydat do `modules/emergency.sh`

---

### 7. IPv6 MODULE (Poziom 2)

```
ipv6_privacy_auto_ensure()
  ├─ wywołuje: log_section(), log_info(), log_warning(), log_success()
  ├─ wywołuje: discover_active_interface()
  ├─ wywołuje: discover_network_stack()
  └─ używa: ip, sysctl, cat, nmcli, networkctl (external)

ipv6_deep_reset()
  ├─ wywołuje: log_section(), log_info(), log_warning(), log_success(), log_error()
  ├─ wywołuje: discover_active_interface()
  ├─ wywołuje: discover_network_stack()
  └─ używa: ip, nmcli, networkctl, rdisc6 (external)

ipv6_privacy_on()
  ├─ wywołuje: log_section(), log_info()
  ├─ wywołuje: ipv6_privacy_status()
  └─ używa: tee, sysctl (external)

ipv6_privacy_off()
  ├─ wywołuje: log_section(), log_info()
  ├─ wywołuje: ipv6_privacy_status()
  └─ używa: tee, sysctl (external)

ipv6_privacy_status()
  ├─ wywołuje: log_section()
  └─ używa: sysctl, ip (external)

smart_ipv6_detection()
  ├─ wywołuje: log_section(), log_info(), log_warning(), log_success()
  └─ używa: ip, ping6, sed, awk, systemctl (external)
```

**Charakterystyka:**
- Zależny od network-utils
- Kandydat do `modules/ipv6.sh`

---

### 8. DISCOVER MODULE (Poziom 2)

```
discover()
  ├─ wywołuje: log_section()
  ├─ wywołuje: discover_active_interface()
  ├─ wywołuje: discover_network_stack()
  ├─ wywołuje: discover_nftables_status()
  └─ używa: ip, systemctl (external)
```

**Charakterystyka:**
- Agregator network-utils
- Kandydat do `modules/discover.sh`

---

### 9. GHOST-CHECK MODULE (Poziom 2)

```
ghost_check()
  ├─ wywołuje: log_section(), log_info(), log_warning(), log_success()
  ├─ wywołuje: discover_active_interface()
  └─ używa: ss, awk, grep, nft (external)
```

**Charakterystyka:**
- Moduł samodzielny
- Kandydat do `modules/ghost-check.sh`

---

### 10. HEALTH MODULE (Poziom 2)

```
health_check_dns()
  └─ używa: dig, nslookup, ss (external)

health_status()
  ├─ wywołuje: log_section(), log_success(), log_error(), log_warning()
  ├─ wywołuje: health_check_dns()
  └─ używa: systemctl, nft (external)

install_health_watchdog()
  ├─ wywołuje: log_section(), log_info(), log_success()
  └─ używa: cat, tee, chmod, systemctl (external)

uninstall_health_watchdog()
  ├─ wywołuje: log_section(), log_success()
  └─ używa: systemctl, rm, rmdir (external)
```

**Charakterystyka:**
- Moduł samodzielny
- Kandydat do `modules/health.sh`

---

### 11. SUPPLY-CHAIN MODULE (Poziom 2)

```
supply_chain_verify_file()
  ├─ wywołuje: log_error()
  └─ używa: sha256sum (external)

supply_chain_download()
  ├─ wywołuje: log_info(), log_error(), log_warning(), log_success()
  └─ używa: mktemp, curl, sha256sum (external)

supply_chain_status()
  ├─ wywołuje: log_section(), log_info()
  └─ używa: grep, cat (external)

supply_chain_init()
  ├─ wywołuje: log_section(), log_info(), log_warning(), log_success()
  └─ używa: mktemp, curl, sha256sum, chmod (external)

supply_chain_verify()
  ├─ wywołuje: log_section(), log_warning(), log_info(), log_success(), log_error()
  ├─ wywołuje: supply_chain_verify_file()
  └─ używa: grep (external)
```

**Charakterystyka:**
- Moduł samodzielny
- Kandydat do `modules/supply-chain.sh`

---

### 12. LOCATION MODULE (Poziom 2)

```
location_get_ssid()
  └─ używa: nmcli (external)

location_is_trusted()
  └─ używa: grep (external)

location_get_firewall_mode()
  └─ używa: nft (external)

location_status()
  ├─ wywołuje: log_section(), log_info()
  ├─ wywołuje: location_get_ssid()
  ├─ wywołuje: location_is_trusted()
  ├─ wywołuje: location_get_firewall_mode()
  └─ używa: grep, sed (external)

location_check()
  ├─ wywołuje: log_section(), log_warning(), log_info(), log_success()
  ├─ wywołuje: location_get_ssid()
  ├─ wywołuje: location_is_trusted()
  ├─ wywołuje: location_get_firewall_mode()
  ├─ wywołuje: install_nftables_strict()
  └─ używa: read (builtin)

location_add_trusted()
  ├─ wywołuje: log_error(), log_info(), log_success()
  ├─ wywołuje: location_get_ssid()
  └─ używa: mkdir, touch, grep (external)

location_remove_trusted()
  ├─ wywołuje: log_error(), log_warning(), log_success(), log_info()
  └─ używa: grep (external)

location_list_trusted()
  ├─ wywołuje: log_section(), log_info()
  ├─ wywołuje: location_get_ssid()
  └─ używa: grep (external)
```

**Charakterystyka:**
- Moduł samodzielny
- Kandydat do `modules/location.sh`

---

### 13. NFT-DEBUG MODULE (Poziom 1)

```
nft_debug_on()
  ├─ wywołuje: log_section(), log_info(), log_success()
  └─ używa: nft (external)

nft_debug_off()
  ├─ wywołuje: log_section(), log_info(), log_success()
  └─ używa: nft (external)

nft_debug_status()
  ├─ wywołuje: log_section(), log_info()
  └─ używa: nft, grep, sed (external)

nft_debug_logs()
  ├─ wywołuje: log_section(), log_info()
  └─ używa: journalctl, grep (external)
```

**Charakterystyka:**
- Moduł samodzielny
- Kandydat do `modules/nft-debug.sh`

---

### 14. INSTALLATION MODULES (Poziom 3 - najwyższy)

```
install_dnscrypt()
  ├─ wywołuje: log_section(), log_info(), log_success(), log_error()
  ├─ wywołuje: require_cmds()
  ├─ wywołuje: pick_free_port()
  ├─ wywołuje: dnssec_enabled()
  └─ używa: useradd, mkdir, chown, tee, systemctl (external)

install_coredns()
  ├─ wywołuje: log_section(), log_info(), log_warning(), log_success()
  ├─ wywołuje: require_cmds()
  ├─ wywołuje: get_dnscrypt_listen_port()
  ├─ wywołuje: adblock_rebuild()
  └─ używa: mkdir, touch, chmod, chown, tee, curl, awk, systemctl (external)

install_nftables()
  ├─ wywołuje: log_section(), log_info(), log_success(), log_error()
  ├─ wywołuje: require_cmds()
  ├─ wywołuje: get_dnscrypt_listen_port()
  └─ używa: mkdir, tee, ln, cp, nft, systemctl (external)

firewall_safe()
  ├─ wywołuje: log_section(), log_warning(), log_success()
  └─ używa: ln, nft (external)

firewall_strict()
  ├─ wywołuje: log_section(), log_warning(), log_success()
  └─ używa: ln, nft (external)

configure_system()
  ├─ wywołuje: log_section(), log_warning(), log_info(), log_success()
  ├─ wywołuje: firewall_safe()
  ├─ wywołuje: firewall_strict()
  └─ używa: systemctl, mkdir, tee, chattr, dig (external)

restore_system()
  ├─ wywołuje: log_section(), log_success()
  └─ używa: chattr, systemctl, rm, ln (external)

install_all()
  ├─ wywołuje: log_section(), log_info()
  ├─ wywołuje: install_dnscrypt()
  ├─ wywołuje: install_coredns()
  ├─ wywołuje: install_nftables()
  ├─ wywołuje: adblock_rebuild()
  ├─ wywołuje: adblock_stats()
  └─ używa: systemctl, dig, awk (external)
```

**Charakterystyka:**
- Główne moduły instalacyjne
- Kandydaci do `modules/install-*.sh`

---

### 15. DIAGNOSTICS MODULE (Poziom 3)

```
run_diagnostics()
  ├─ wywołuje: log_section(), log_error()
  └─ używa: systemctl, dig, curl, journalctl, nft, wc (external)

verify_stack()
  ├─ wywołuje: log_section()
  ├─ wywołuje: get_dnscrypt_listen_port()
  ├─ wywołuje: get_coredns_listen_port()
  └─ używa: systemctl, nft, dig, curl (external)

test_all()
  ├─ wywołuje: log_section()
  ├─ wywołuje: verify_stack()
  └─ używa: dig, ping6 (external)
```

**Charakterystyka:**
- Moduł diagnostyczny
- Kandydat do `modules/diagnostics.sh`

---

### 16. NEW FEATURES v3.0 (Poziom 2-3)

```
install_citadel_top()
  ├─ wywołuje: log_section(), log_warning(), log_info(), log_success()
  ├─ wywołuje: require_cmds()
  └─ używa: pacman, tee, chmod (external)

install_editor_integration()
  ├─ wywołuje: log_section(), log_warning(), log_info(), log_success()
  └─ używa: yay, tee, chmod (external)

optimize_kernel_priority()
  ├─ wywołuje: log_section(), log_warning(), log_success()
  └─ używa: tee, systemctl (external)

install_doh_parallel()
  ├─ wywołuje: log_section(), log_success(), log_info()
  └─ używa: tee (external)

fix_port_conflicts()
  ├─ wywołuje: log_section(), log_info(), log_success()
  └─ używa: ss, sed, systemctl (external)

safe_test_mode()
  ├─ wywołuje: log_section(), log_info()
  └─ używa: dnscrypt-proxy, ss (external)
```

**Charakterystyka:**
- Dodatkowe features
- Kandydaci do `modules/extras.sh`

---

## PODSUMOWANIE ZALEŻNOŚCI

### Hierarchia Modułów (od najniższego do najwyższego):

```
Poziom 0: Core Utilities
  └─ cytadela-core.sh (log_*, trap_err_handler, require_*)

Poziom 1: Network & Basic Utils
  └─ lib/network-utils.sh (discover_*, port_*, get_*_port)
  └─ lib/nft-debug.sh (nft_debug_*)

Poziom 2: Feature Modules (niezależne)
  ├─ modules/integrity.sh
  ├─ modules/adblock.sh
  ├─ modules/emergency.sh
  ├─ modules/health.sh
  ├─ modules/supply-chain.sh
  ├─ modules/location.sh
  ├─ modules/ghost-check.sh
  └─ modules/extras.sh

Poziom 2: Feature Modules (zależne od network-utils)
  ├─ modules/ipv6.sh (używa discover_*)
  ├─ modules/discover.sh (używa discover_*)
  └─ modules/lkg.sh (używa adblock_*)

Poziom 3: Installation & Diagnostics
  ├─ modules/install-dnscrypt.sh
  ├─ modules/install-coredns.sh
  ├─ modules/install-nftables.sh
  ├─ modules/install-all.sh
  └─ modules/diagnostics.sh
```

### Kolejność Ładowania Modułów:

1. `cytadela-core.sh` (zawsze)
2. `lib/network-utils.sh` (zawsze)
3. Moduły Poziomu 2 (lazy loading)
4. Moduły Poziomu 3 (lazy loading)

---

## NASTĘPNE KROKI

✅ Mapa zależności gotowa  
➡️ Projektowanie struktury katalogów i mechanizmu ładowania
