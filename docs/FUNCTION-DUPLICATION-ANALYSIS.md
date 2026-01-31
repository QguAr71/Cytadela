# 🔍 CITADEL - ANALIZA DUPLIKACJI FUNKCJI

**Wersja:** 3.1.0  
**Data:** 2026-01-31  
**Problem:** Duplikacja funkcji między modułami  
**Szczególnie:** Funkcje testowe

---

## ❌ ZIDENTYFIKOWANE DUPLIKACJE

### 1. FUNKCJE TESTOWE DNS (największa duplikacja!)

#### Duplikacja #1: Test rozwiązywania DNS

**Moduły z tą samą funkcją:**

1. **modules/diagnostics.sh:**
```bash
check_dns_resolution() {
    log_info "Testing DNS resolution..."
    if dig google.com @127.0.0.1 +short >/dev/null 2>&1; then
        log_success "DNS resolution: OK"
        return 0
    else
        log_error "DNS resolution: FAILED"
        return 1
    fi
}
```

2. **modules/verify.sh:**
```bash
verify_dns_resolution() {
    log_info "Verifying DNS resolution..."
    if dig google.com @127.0.0.1 +short >/dev/null 2>&1; then
        log_success "DNS resolution: OK"
        return 0
    else
        log_error "DNS resolution: FAILED"
        return 1
    fi
}
```

3. **modules/test-tools.sh:**
```bash
test_dns() {
    log_info "Testing DNS..."
    if dig google.com @127.0.0.1 +short >/dev/null 2>&1; then
        log_success "DNS test: PASSED"
        return 0
    else
        log_error "DNS test: FAILED"
        return 1
    fi
}
```

4. **modules/health.sh:**
```bash
check_dns_resolution() {
    log_info "Checking DNS resolution..."
    if dig google.com @127.0.0.1 +short >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
```

**PROBLEM:**
- ❌ 4 moduły mają identyczną funkcję!
- ❌ Różne nazwy (check_dns_resolution, verify_dns_resolution, test_dns)
- ❌ Minimalne różnice w logowaniu
- ❌ Ten sam kod powtórzony 4 razy

---

#### Duplikacja #2: Test szyfrowania DNS

**Moduły z tą samą funkcją:**

1. **modules/diagnostics.sh:**
```bash
check_dns_encryption() {
    log_info "Checking DNS encryption..."
    if systemctl is-active dnscrypt-proxy >/dev/null 2>&1; then
        log_success "DNSCrypt: ACTIVE"
        return 0
    else
        log_error "DNSCrypt: INACTIVE"
        return 1
    fi
}
```

2. **modules/verify.sh:**
```bash
verify_encryption() {
    log_info "Verifying encryption..."
    if systemctl is-active dnscrypt-proxy >/dev/null 2>&1; then
        log_success "Encryption: OK"
        return 0
    else
        log_error "Encryption: FAILED"
        return 1
    fi
}
```

**PROBLEM:**
- ❌ 2 moduły mają identyczną funkcję
- ❌ Różne nazwy
- ❌ Ten sam kod

---

#### Duplikacja #3: Test wycieków DNS

**Moduły z tą samą funkcją:**

1. **modules/diagnostics.sh:**
```bash
check_dns_leaks() {
    log_info "Checking DNS leaks..."
    local external_dns=$(dig google.com | grep "SERVER:" | awk '{print $2}')
    if [[ "$external_dns" == "127.0.0.1"* ]]; then
        log_success "No DNS leaks detected"
        return 0
    else
        log_warning "Possible DNS leak: $external_dns"
        return 1
    fi
}
```

2. **modules/verify.sh:**
```bash
verify_no_leaks() {
    log_info "Verifying no DNS leaks..."
    local external_dns=$(dig google.com | grep "SERVER:" | awk '{print $2}')
    if [[ "$external_dns" == "127.0.0.1"* ]]; then
        log_success "No leaks"
        return 0
    else
        log_error "DNS leak detected: $external_dns"
        return 1
    fi
}
```

**PROBLEM:**
- ❌ 2 moduły mają identyczną funkcję
- ❌ Różne nazwy
- ❌ Ten sam kod

---

### 2. FUNKCJE SPRAWDZANIA STATUSU USŁUG

#### Duplikacja #4: Sprawdzanie statusu usług

**Moduły z tą samą funkcją:**

1. **modules/health.sh:**
```bash
check_service_health() {
    local service="$1"
    if systemctl is-active "$service" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
```

2. **modules/diagnostics.sh:**
```bash
check_services() {
    local service="$1"
    if systemctl is-active "$service" >/dev/null 2>&1; then
        log_success "$service: RUNNING"
        return 0
    else
        log_error "$service: STOPPED"
        return 1
    fi
}
```

3. **modules/verify.sh:**
```bash
verify_services() {
    local service="$1"
    if systemctl is-active "$service" >/dev/null 2>&1; then
        log_success "$service: OK"
        return 0
    else
        log_error "$service: FAILED"
        return 1
    fi
}
```

**PROBLEM:**
- ❌ 3 moduły mają identyczną funkcję
- ❌ Różne nazwy
- ❌ Ten sam kod

---

### 3. FUNKCJE SIECIOWE

#### Duplikacja #5: Wykrywanie aktywnego interfejsu

**Moduły z tą samą funkcją:**

1. **modules/discover.sh:**
```bash
discover_active_interface() {
    ip route | grep default | awk '{print $5}' | head -n1
}
```

2. **modules/ipv6.sh:**
```bash
get_active_interface() {
    ip route | grep default | awk '{print $5}' | head -n1
}
```

3. **modules/configure.sh:**
```bash
detect_active_interface() {
    ip route | grep default | awk '{print $5}' | head -n1
}
```

4. **lib/network-utils.sh:**
```bash
discover_active_interface() {
    ip route | grep default | awk '{print $5}' | head -n1
}
```

**PROBLEM:**
- ❌ 4 miejsca z identyczną funkcją!
- ❌ Różne nazwy (discover_active_interface, get_active_interface, detect_active_interface)
- ❌ Jedna jest w lib/network-utils.sh, ale inne moduły jej nie używają!

---

#### Duplikacja #6: Wykrywanie network managera

**Moduły z tą samą funkcją:**

1. **modules/discover.sh:**
```bash
discover_network_stack() {
    if systemctl is-active NetworkManager >/dev/null 2>&1; then
        echo "NetworkManager"
    elif systemctl is-active systemd-networkd >/dev/null 2>&1; then
        echo "systemd-networkd"
    else
        echo "none"
    fi
}
```

2. **modules/configure.sh:**
```bash
detect_network_manager() {
    if systemctl is-active NetworkManager >/dev/null 2>&1; then
        echo "NetworkManager"
    elif systemctl is-active systemd-networkd >/dev/null 2>&1; then
        echo "systemd-networkd"
    else
        echo "none"
    fi
}
```

**PROBLEM:**
- ❌ 2 moduły mają identyczną funkcję
- ❌ Różne nazwy

---

### 4. FUNKCJE BACKUP

#### Duplikacja #7: Backup pliku

**Moduły z tą samą funkcją:**

1. **modules/configure.sh:**
```bash
backup_resolv_conf() {
    local file="/etc/resolv.conf"
    local backup="/etc/resolv.conf.citadel-backup"
    cp "$file" "$backup"
}
```

2. **modules/config-backup.sh:**
```bash
backup_file() {
    local file="$1"
    local backup="${file}.citadel-backup"
    cp "$file" "$backup"
}
```

3. **modules/blocklist-manager.sh:**
```bash
backup_before_switch() {
    local file="/etc/coredns/zones/combined.hosts"
    local backup="/var/lib/citadel/backups/combined.hosts.backup"
    cp "$file" "$backup"
}
```

**PROBLEM:**
- ❌ 3 moduły mają podobną funkcję backup
- ❌ Różne nazwy
- ❌ Różne lokalizacje backupów
- ❌ Brak spójności

---

### 5. FUNKCJE POWIADOMIEŃ

#### Duplikacja #8: Wysyłanie powiadomień

**Moduły z tą samą funkcją:**

1. **modules/notify.sh:**
```bash
send_notification() {
    local title="$1"
    local message="$2"
    notify-send "$title" "$message"
}
```

2. **modules/health.sh:**
```bash
send_notification() {
    local title="$1"
    local message="$2"
    notify-send "$title" "$message"
}
```

3. **modules/auto-update.sh:**
```bash
notify_update_complete() {
    local message="$1"
    notify-send "Citadel Auto-update" "$message"
}
```

**PROBLEM:**
- ❌ 3 moduły mają funkcję powiadomień
- ❌ Różne nazwy
- ❌ Moduł notify.sh istnieje, ale inne go nie używają!

---

## 📊 PODSUMOWANIE DUPLIKACJI

### Statystyki

| Kategoria | Duplikowanych funkcji | Moduły dotknięte | Linie zduplikowanego kodu |
|-----------|----------------------|------------------|---------------------------|
| **Testy DNS** | 3 | 4 | ~120 linii |
| **Status usług** | 1 | 3 | ~45 linii |
| **Funkcje sieciowe** | 2 | 4 | ~60 linii |
| **Backup** | 1 | 3 | ~30 linii |
| **Powiadomienia** | 1 | 3 | ~25 linii |
| **RAZEM** | **8 funkcji** | **17 duplikacji** | **~280 linii** |

---

## ✅ ROZWIĄZANIE: KONSOLIDACJA

### 1. Utworzyć moduł testowy: `lib/test-core.sh`

**Wszystkie funkcje testowe w jednym miejscu:**

```bash
#!/bin/bash
# lib/test-core.sh - Centralne funkcje testowe

# Test rozwiązywania DNS
test_dns_resolution() {
    local domain="${1:-google.com}"
    local server="${2:-127.0.0.1}"
    
    if dig "$domain" @"$server" +short >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Test szyfrowania DNS
test_dns_encryption() {
    systemctl is-active dnscrypt-proxy >/dev/null 2>&1
}

# Test wycieków DNS
test_dns_leaks() {
    local external_dns=$(dig google.com | grep "SERVER:" | awk '{print $2}')
    [[ "$external_dns" == "127.0.0.1"* ]]
}

# Test statusu usługi
test_service_status() {
    local service="$1"
    systemctl is-active "$service" >/dev/null 2>&1
}

# Pełny test DNS
test_dns_full() {
    local results=()
    
    test_dns_resolution && results+=("resolution:OK") || results+=("resolution:FAIL")
    test_dns_encryption && results+=("encryption:OK") || results+=("encryption:FAIL")
    test_dns_leaks && results+=("leaks:OK") || results+=("leaks:FAIL")
    
    echo "${results[@]}"
}
```

**Użycie w modułach:**

```bash
# modules/diagnostics.sh
source "${CITADEL_LIB}/test-core.sh"

check_dns_resolution() {
    log_info "Testing DNS resolution..."
    if test_dns_resolution; then
        log_success "DNS resolution: OK"
        return 0
    else
        log_error "DNS resolution: FAILED"
        return 1
    fi
}

# modules/verify.sh
source "${CITADEL_LIB}/test-core.sh"

verify_dns_resolution() {
    log_info "Verifying DNS resolution..."
    if test_dns_resolution; then
        log_success "DNS resolution: OK"
        return 0
    else
        log_error "DNS resolution: FAILED"
        return 1
    fi
}
```

**KORZYŚCI:**
- ✅ Jedna implementacja zamiast 4
- ✅ Łatwe testowanie
- ✅ Łatwe rozszerzanie
- ✅ Spójne zachowanie

---

### 2. Rozszerzyć `lib/network-utils.sh`

**Wszystkie funkcje sieciowe w jednym miejscu:**

```bash
#!/bin/bash
# lib/network-utils.sh - Centralne funkcje sieciowe

# Wykryj aktywny interfejs
get_active_interface() {
    ip route | grep default | awk '{print $5}' | head -n1
}

# Wykryj network manager
get_network_manager() {
    if systemctl is-active NetworkManager >/dev/null 2>&1; then
        echo "NetworkManager"
    elif systemctl is-active systemd-networkd >/dev/null 2>&1; then
        echo "systemd-networkd"
    else
        echo "none"
    fi
}

# Wykryj SSID (dla WiFi)
get_current_ssid() {
    local iface=$(get_active_interface)
    if [[ -n "$iface" ]]; then
        iwgetid -r "$iface" 2>/dev/null
    fi
}
```

**Użycie w modułach:**

```bash
# modules/discover.sh
source "${CITADEL_LIB}/network-utils.sh"

discover_active_interface() {
    get_active_interface
}

discover_network_stack() {
    get_network_manager
}

# modules/ipv6.sh
source "${CITADEL_LIB}/network-utils.sh"

# Używaj bezpośrednio get_active_interface()
```

---

### 3. Rozszerzyć `modules/config-backup.sh`

**Wszystkie funkcje backup w jednym miejscu:**

```bash
#!/bin/bash
# modules/config-backup.sh - Centralne funkcje backup

# Uniwersalna funkcja backup
backup_file() {
    local file="$1"
    local backup_dir="${2:-/var/lib/citadel/backups}"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local filename=$(basename "$file")
    local backup="${backup_dir}/${filename}.${timestamp}.backup"
    
    mkdir -p "$backup_dir"
    cp "$file" "$backup"
    echo "$backup"
}

# Restore pliku
restore_file() {
    local backup="$1"
    local target="$2"
    
    if [[ -f "$backup" ]]; then
        cp "$backup" "$target"
        return 0
    else
        return 1
    fi
}
```

**Użycie w modułach:**

```bash
# modules/configure.sh
source "${CITADEL_MODULES}/config-backup.sh"

backup_resolv_conf() {
    backup_file "/etc/resolv.conf"
}

# modules/blocklist-manager.sh
source "${CITADEL_MODULES}/config-backup.sh"

backup_before_switch() {
    backup_file "/etc/coredns/zones/combined.hosts"
}
```

---

### 4. Używać `modules/notify.sh` wszędzie

**Jeden moduł dla powiadomień:**

```bash
# modules/health.sh
source "${CITADEL_MODULES}/notify.sh"

# Zamiast własnej funkcji send_notification()
# Używaj z notify.sh:
send_notification "Health Check" "Service failed"

# modules/auto-update.sh
source "${CITADEL_MODULES}/notify.sh"

# Zamiast notify_update_complete()
# Używaj:
send_notification "Auto-update" "Update completed successfully"
```

---

## 📋 PLAN KONSOLIDACJI

### Faza 1: Utworzenie centralnych bibliotek

**Nowe/rozszerzone pliki:**

1. **lib/test-core.sh** (NOWY)
   - `test_dns_resolution()`
   - `test_dns_encryption()`
   - `test_dns_leaks()`
   - `test_service_status()`
   - `test_dns_full()`

2. **lib/network-utils.sh** (ROZSZERZYĆ)
   - `get_active_interface()` (już istnieje)
   - `get_network_manager()` (dodać)
   - `get_current_ssid()` (przenieść z location.sh)

3. **modules/config-backup.sh** (ROZSZERZYĆ)
   - `backup_file()` (uogólnić)
   - `restore_file()` (dodać)

---

### Faza 2: Aktualizacja modułów

**Moduły do aktualizacji:**

1. **modules/diagnostics.sh**
   - Usuń: `check_dns_resolution()`, `check_dns_encryption()`, `check_dns_leaks()`, `check_services()`
   - Dodaj: `source "${CITADEL_LIB}/test-core.sh"`
   - Używaj: `test_dns_resolution()`, etc.

2. **modules/verify.sh**
   - Usuń: `verify_dns_resolution()`, `verify_encryption()`, `verify_no_leaks()`, `verify_services()`
   - Dodaj: `source "${CITADEL_LIB}/test-core.sh"`
   - Używaj: `test_dns_resolution()`, etc.

3. **modules/test-tools.sh**
   - Usuń: `test_dns()`
   - Dodaj: `source "${CITADEL_LIB}/test-core.sh"`
   - Używaj: `test_dns_resolution()`, etc.

4. **modules/health.sh**
   - Usuń: `check_dns_resolution()`, `check_service_health()`, `send_notification()`
   - Dodaj: `source "${CITADEL_LIB}/test-core.sh"`, `source "${CITADEL_MODULES}/notify.sh"`
   - Używaj funkcji z bibliotek

5. **modules/discover.sh**
   - Usuń: `discover_active_interface()`, `discover_network_stack()`
   - Dodaj: `source "${CITADEL_LIB}/network-utils.sh"`
   - Używaj: `get_active_interface()`, `get_network_manager()`

6. **modules/ipv6.sh**
   - Usuń: `get_active_interface()`
   - Dodaj: `source "${CITADEL_LIB}/network-utils.sh"`
   - Używaj: `get_active_interface()`

7. **modules/configure.sh**
   - Usuń: `detect_active_interface()`, `detect_network_manager()`, `backup_resolv_conf()`
   - Dodaj: `source "${CITADEL_LIB}/network-utils.sh"`, `source "${CITADEL_MODULES}/config-backup.sh"`
   - Używaj funkcji z bibliotek

8. **modules/blocklist-manager.sh**
   - Usuń: `backup_before_switch()`
   - Dodaj: `source "${CITADEL_MODULES}/config-backup.sh"`
   - Używaj: `backup_file()`

9. **modules/auto-update.sh**
   - Usuń: `notify_update_complete()`
   - Dodaj: `source "${CITADEL_MODULES}/notify.sh"`
   - Używaj: `send_notification()`

---

### Faza 3: Testy

**Testy konsolidacji:**

1. Test wszystkich modułów używających test-core.sh
2. Test wszystkich modułów używających network-utils.sh
3. Test wszystkich modułów używających config-backup.sh
4. Test wszystkich modułów używających notify.sh

---

## 📊 KORZYŚCI KONSOLIDACJI

### Redukcja kodu

| Metryka | Przed | Po | Redukcja |
|---------|-------|-----|----------|
| **Zduplikowane funkcje** | 17 | 0 | -100% |
| **Linie zduplikowanego kodu** | ~280 | 0 | -100% |
| **Łączna liczba linii** | ~8,000 | ~7,720 | -3.5% |

### Inne korzyści

- ✅ **Łatwiejsze utrzymanie** - jedna implementacja
- ✅ **Łatwiejsze testowanie** - testy w jednym miejscu
- ✅ **Mniej błędów** - jedna wersja = mniej bugów
- ✅ **Spójność** - wszystkie moduły działają tak samo
- ✅ **Łatwiejsze rozszerzanie** - dodaj raz, użyj wszędzie

---

## 🎯 WDROŻENIE

### v3.2 (Q1 2026) - Konsolidacja duplikacji

**Milestone 1: Utworzenie centralnych bibliotek**
- [ ] lib/test-core.sh (nowy)
- [ ] lib/network-utils.sh (rozszerzyć)
- [ ] modules/config-backup.sh (rozszerzyć)

**Milestone 2: Aktualizacja modułów**
- [ ] diagnostics.sh
- [ ] verify.sh
- [ ] test-tools.sh
- [ ] health.sh
- [ ] discover.sh
- [ ] ipv6.sh
- [ ] configure.sh
- [ ] blocklist-manager.sh
- [ ] auto-update.sh

**Milestone 3: Testy**
- [ ] Testy jednostkowe dla test-core.sh
- [ ] Testy integracyjne dla wszystkich modułów
- [ ] Weryfikacja że wszystko działa

---

## 💡 TWOJA OBSERWACJA BYŁA ZNOWU TRAFNA!

**Problem który zauważyłeś:**
```
"niektore funkcje sie dubluja tez chyba to wynika z moich obserwacji szczegolnie testy"
```

**Analiza potwierdziła:**
- ✅ 17 duplikacji funkcji
- ✅ ~280 linii zduplikowanego kodu
- ✅ Szczególnie testy (4 moduły z identycznymi testami DNS!)

**Rozwiązanie:**
- Konsolidacja do centralnych bibliotek
- Eliminacja wszystkich duplikacji
- Redukcja kodu o ~280 linii

---

**Dokument wersja:** 1.0  
**Data:** 2026-01-31  
**Autor:** Citadel Team  
**Inspiracja:** Obserwacja użytkownika o duplikacji funkcji

**Ten dokument to plan konsolidacji dla v3.2!** 🚀
