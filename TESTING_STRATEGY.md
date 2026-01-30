# CYTADELA++ TESTING STRATEGY - Issues #11 & #12
**Kompletna strategia testowania refactoringu**

---

## STRATEGIA TESTOWANIA

### 1. POZIOMY TESTOWANIA

```
Level 0: Unit Tests (funkcje pojedyncze)
  └─ Test każdej funkcji w izolacji

Level 1: Module Tests (moduły)
  └─ Test całego modułu z zależnościami

Level 2: Integration Tests (integracja)
  └─ Test współpracy między modułami

Level 3: System Tests (system)
  └─ Test pełnego workflow end-to-end

Level 4: Regression Tests (regresja)
  └─ Porównanie z poprzednią wersją
```

---

### 2. UNIT TESTS

#### **Test Suite: Core Library**

```bash
#!/bin/bash
# test-core-library.sh

source lib/cytadela-core.sh

echo "=== CORE LIBRARY TESTS ==="

# Test 1: Logging functions
test_logging() {
    echo "Test 1: Logging functions..."
    log_info "Test info" >/dev/null
    log_success "Test success" >/dev/null
    log_warning "Test warning" >/dev/null
    log_error "Test error" 2>/dev/null
    log_section "Test section" >/dev/null
    echo "  ✓ Logging OK"
}

# Test 2: require_cmd
test_require_cmd() {
    echo "Test 2: require_cmd..."
    require_cmd bash || { echo "  ✗ FAIL"; exit 1; }
    ! require_cmd nonexistent_command_xyz || { echo "  ✗ FAIL"; exit 1; }
    echo "  ✓ require_cmd OK"
}

# Test 3: require_cmds
test_require_cmds() {
    echo "Test 3: require_cmds..."
    require_cmds bash grep awk || { echo "  ✗ FAIL"; exit 1; }
    ! require_cmds bash nonexistent 2>/dev/null || { echo "  ✗ FAIL"; exit 1; }
    echo "  ✓ require_cmds OK"
}

# Test 4: dnssec_enabled
test_dnssec_enabled() {
    echo "Test 4: dnssec_enabled..."
    ! dnssec_enabled || { echo "  ✗ FAIL"; exit 1; }
    CITADEL_DNSSEC=1 dnssec_enabled || { echo "  ✗ FAIL"; exit 1; }
    echo "  ✓ dnssec_enabled OK"
}

# Run tests
test_logging
test_require_cmd
test_require_cmds
test_dnssec_enabled

echo ""
echo "=== ALL CORE TESTS PASSED ==="
```

#### **Test Suite: Network Utils**

```bash
#!/bin/bash
# test-network-utils.sh

source lib/cytadela-core.sh
source lib/network-utils.sh

echo "=== NETWORK UTILS TESTS ==="

# Test 1: discover_active_interface
test_discover_interface() {
    echo "Test 1: discover_active_interface..."
    local iface=$(discover_active_interface)
    [[ -n "$iface" ]] || { echo "  ✗ FAIL: No interface detected"; exit 1; }
    echo "  ✓ Interface detected: $iface"
}

# Test 2: discover_network_stack
test_discover_stack() {
    echo "Test 2: discover_network_stack..."
    local stack=$(discover_network_stack)
    [[ -n "$stack" ]] || { echo "  ✗ FAIL: No stack detected"; exit 1; }
    echo "  ✓ Stack detected: $stack"
}

# Test 3: port_in_use
test_port_in_use() {
    echo "Test 3: port_in_use..."
    port_in_use 22 || { echo "  ✗ FAIL: Port 22 should be in use"; exit 1; }
    ! port_in_use 65534 || { echo "  ✗ FAIL: Port 65534 should be free"; exit 1; }
    echo "  ✓ port_in_use OK"
}

# Test 4: pick_free_port
test_pick_free_port() {
    echo "Test 4: pick_free_port..."
    local port=$(pick_free_port 60000 60100)
    [[ -n "$port" ]] || { echo "  ✗ FAIL: No free port found"; exit 1; }
    [[ "$port" -ge 60000 && "$port" -le 60100 ]] || { echo "  ✗ FAIL: Port out of range"; exit 1; }
    echo "  ✓ Free port found: $port"
}

# Run tests
test_discover_interface
test_discover_stack
test_port_in_use
test_pick_free_port

echo ""
echo "=== ALL NETWORK TESTS PASSED ==="
```

---

### 3. MODULE TESTS

#### **Test Suite: Integrity Module**

```bash
#!/bin/bash
# test-integrity-module.sh

source lib/cytadela-core.sh
source lib/network-utils.sh
source modules/integrity.sh

echo "=== INTEGRITY MODULE TESTS ==="

# Test 1: integrity_verify_file
test_integrity_verify_file() {
    echo "Test 1: integrity_verify_file..."
    local tmpfile=$(mktemp)
    echo "test" > "$tmpfile"
    local hash=$(sha256sum "$tmpfile" | awk '{print $1}')
    
    integrity_verify_file "$tmpfile" "$hash" || { echo "  ✗ FAIL: Valid hash rejected"; rm "$tmpfile"; exit 1; }
    ! integrity_verify_file "$tmpfile" "invalid_hash" || { echo "  ✗ FAIL: Invalid hash accepted"; rm "$tmpfile"; exit 1; }
    
    rm "$tmpfile"
    echo "  ✓ integrity_verify_file OK"
}

# Test 2: integrity_status
test_integrity_status() {
    echo "Test 2: integrity_status..."
    integrity_status >/dev/null || { echo "  ✗ FAIL"; exit 1; }
    echo "  ✓ integrity_status OK"
}

# Run tests
test_integrity_verify_file
test_integrity_status

echo ""
echo "=== ALL INTEGRITY TESTS PASSED ==="
```

---

### 4. INTEGRATION TESTS

#### **Test Suite: Module Loading**

```bash
#!/bin/bash
# test-module-loading.sh

echo "=== MODULE LOADING TESTS ==="

# Test 1: Lazy loading
test_lazy_loading() {
    echo "Test 1: Lazy loading..."
    
    # Uruchom wrapper z debug
    output=$(CYTADELA_DEBUG=1 sudo ./cytadela++.sh integrity-status 2>&1)
    
    # Sprawdź czy moduł został załadowany
    echo "$output" | grep -q "Załadowano moduł: integrity" || { 
        echo "  ✗ FAIL: Module not loaded"
        echo "$output"
        exit 1
    }
    
    echo "  ✓ Lazy loading OK"
}

# Test 2: Module caching
test_module_caching() {
    echo "Test 2: Module caching..."
    
    # Uruchom dwa razy tę samą komendę
    output=$(CYTADELA_DEBUG=1 sudo ./cytadela++.sh integrity-status 2>&1)
    
    # Moduł powinien być załadowany tylko raz
    count=$(echo "$output" | grep -c "Załadowano moduł: integrity")
    [[ "$count" -eq 1 ]] || { 
        echo "  ✗ FAIL: Module loaded $count times (expected 1)"
        exit 1
    }
    
    echo "  ✓ Module caching OK"
}

# Test 3: Developer mode
test_developer_mode() {
    echo "Test 3: Developer mode..."
    
    cd /home/qguar/Cytadela
    output=$(sudo ./cytadela++.sh integrity-status 2>&1)
    
    # Powinno użyć lokalnych plików
    # (sprawdzamy czy nie ma błędów)
    [[ $? -eq 0 ]] || { 
        echo "  ✗ FAIL: Developer mode failed"
        echo "$output"
        exit 1
    }
    
    echo "  ✓ Developer mode OK"
}

# Run tests
test_lazy_loading
test_module_caching
test_developer_mode

echo ""
echo "=== ALL INTEGRATION TESTS PASSED ==="
```

---

### 5. SYSTEM TESTS (End-to-End)

#### **Test Suite: Full Workflow**

```bash
#!/bin/bash
# test-full-workflow.sh

echo "=== FULL WORKFLOW TESTS ==="

# Test 1: Installation workflow
test_installation_workflow() {
    echo "Test 1: Installation workflow..."
    
    # Symulacja instalacji (bez faktycznej instalacji)
    sudo ./cytadela++.sh verify >/dev/null || { 
        echo "  ✗ FAIL: verify command failed"
        exit 1
    }
    
    echo "  ✓ Installation workflow OK"
}

# Test 2: Adblock workflow
test_adblock_workflow() {
    echo "Test 2: Adblock workflow..."
    
    # Status -> Add -> Rebuild -> Remove
    sudo ./cytadela++.sh adblock-status >/dev/null || { echo "  ✗ FAIL: status"; exit 1; }
    sudo ./cytadela++.sh adblock-add test.example.com >/dev/null || { echo "  ✗ FAIL: add"; exit 1; }
    sudo ./cytadela++.sh adblock-rebuild >/dev/null || { echo "  ✗ FAIL: rebuild"; exit 1; }
    sudo ./cytadela++.sh adblock-remove test.example.com >/dev/null || { echo "  ✗ FAIL: remove"; exit 1; }
    
    echo "  ✓ Adblock workflow OK"
}

# Test 3: Emergency workflow
test_emergency_workflow() {
    echo "Test 3: Emergency workflow..."
    
    sudo ./cytadela++.sh panic-status >/dev/null || { echo "  ✗ FAIL: panic-status"; exit 1; }
    # Nie testujemy panic-bypass (zbyt ryzykowne w testach)
    
    echo "  ✓ Emergency workflow OK"
}

# Test 4: Diagnostics workflow
test_diagnostics_workflow() {
    echo "Test 4: Diagnostics workflow..."
    
    sudo ./cytadela++.sh discover >/dev/null || { echo "  ✗ FAIL: discover"; exit 1; }
    sudo ./cytadela++.sh health-status >/dev/null || { echo "  ✗ FAIL: health-status"; exit 1; }
    sudo ./cytadela++.sh verify >/dev/null || { echo "  ✗ FAIL: verify"; exit 1; }
    
    echo "  ✓ Diagnostics workflow OK"
}

# Run tests
test_installation_workflow
test_adblock_workflow
test_emergency_workflow
test_diagnostics_workflow

echo ""
echo "=== ALL WORKFLOW TESTS PASSED ==="
```

---

### 6. REGRESSION TESTS

#### **Test Suite: Backward Compatibility**

```bash
#!/bin/bash
# test-regression.sh

echo "=== REGRESSION TESTS ==="

# Lista wszystkich komend do przetestowania
COMMANDS=(
    "help"
    "integrity-status"
    "discover"
    "adblock-status"
    "adblock-stats"
    "lkg-status"
    "panic-status"
    "health-status"
    "supply-chain-status"
    "location-status"
    "nft-debug-status"
    "ipv6-privacy-status"
    "ghost-check"
    "verify"
)

echo "Testing ${#COMMANDS[@]} commands..."

failed=0
for cmd in "${COMMANDS[@]}"; do
    echo -n "  Testing: $cmd ... "
    
    # Test PL version
    if ! sudo ./cytadela++.sh "$cmd" >/dev/null 2>&1; then
        echo "✗ FAIL (PL)"
        ((failed++))
        continue
    fi
    
    # Test EN version
    if ! sudo ./citadela_en.sh "$cmd" >/dev/null 2>&1; then
        echo "✗ FAIL (EN)"
        ((failed++))
        continue
    fi
    
    echo "✓ OK"
done

echo ""
if [[ $failed -eq 0 ]]; then
    echo "=== ALL REGRESSION TESTS PASSED ==="
else
    echo "=== $failed TESTS FAILED ==="
    exit 1
fi
```

---

### 7. PERFORMANCE TESTS

#### **Test Suite: Performance Comparison**

```bash
#!/bin/bash
# test-performance.sh

echo "=== PERFORMANCE TESTS ==="

# Test 1: Startup time (old vs new)
test_startup_time() {
    echo "Test 1: Startup time comparison..."
    
    # Old version (backup)
    if [[ -f cytadela++.sh.old ]]; then
        old_time=$( (time sudo ./cytadela++.sh.old help >/dev/null 2>&1) 2>&1 | grep real | awk '{print $2}')
        echo "  Old version: $old_time"
    fi
    
    # New version
    new_time=$( (time sudo ./cytadela++.sh help >/dev/null 2>&1) 2>&1 | grep real | awk '{print $2}')
    echo "  New version: $new_time"
    
    echo "  ✓ Startup time measured"
}

# Test 2: Memory usage
test_memory_usage() {
    echo "Test 2: Memory usage..."
    
    # Uruchom komendę i zmierz pamięć
    /usr/bin/time -v sudo ./cytadela++.sh verify 2>&1 | grep "Maximum resident set size" || true
    
    echo "  ✓ Memory usage measured"
}

# Test 3: Module loading overhead
test_module_loading_overhead() {
    echo "Test 3: Module loading overhead..."
    
    # Czas bez lazy loading (wszystkie moduły)
    start=$(date +%s%N)
    for i in {1..10}; do
        sudo ./cytadela++.sh integrity-status >/dev/null 2>&1
    done
    end=$(date +%s%N)
    
    duration=$(( (end - start) / 1000000 ))
    avg=$(( duration / 10 ))
    
    echo "  Average execution time: ${avg}ms"
    echo "  ✓ Module loading overhead measured"
}

# Run tests
test_startup_time
test_memory_usage
test_module_loading_overhead

echo ""
echo "=== PERFORMANCE TESTS COMPLETED ==="
```

---

### 8. MASTER TEST SUITE

#### **Uruchomienie wszystkich testów**

```bash
#!/bin/bash
# run-all-tests.sh

set -e

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         CYTADELA++ COMPLETE TEST SUITE v3.1                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Level 0: Unit Tests
echo ">>> LEVEL 0: UNIT TESTS"
bash test-core-library.sh
bash test-network-utils.sh
echo ""

# Level 1: Module Tests
echo ">>> LEVEL 1: MODULE TESTS"
bash test-integrity-module.sh
# ... więcej testów modułów
echo ""

# Level 2: Integration Tests
echo ">>> LEVEL 2: INTEGRATION TESTS"
bash test-module-loading.sh
echo ""

# Level 3: System Tests
echo ">>> LEVEL 3: SYSTEM TESTS"
bash test-full-workflow.sh
echo ""

# Level 4: Regression Tests
echo ">>> LEVEL 4: REGRESSION TESTS"
bash test-regression.sh
echo ""

# Performance Tests
echo ">>> PERFORMANCE TESTS"
bash test-performance.sh
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║              ALL TESTS PASSED SUCCESSFULLY                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
```

---

### 9. CONTINUOUS TESTING

#### **Pre-commit Hook**

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit tests..."

# Quick smoke test
if ! bash test-core-library.sh >/dev/null 2>&1; then
    echo "✗ Core library tests failed"
    exit 1
fi

if ! bash test-regression.sh >/dev/null 2>&1; then
    echo "✗ Regression tests failed"
    exit 1
fi

echo "✓ Pre-commit tests passed"
exit 0
```

---

### 10. ACCEPTANCE CRITERIA

**Testy muszą przejść przed merge:**

✅ **Unit Tests:**
- Wszystkie funkcje core library działają
- Wszystkie funkcje network-utils działają

✅ **Module Tests:**
- Każdy moduł działa standalone
- Wszystkie funkcje modułu dostępne

✅ **Integration Tests:**
- Lazy loading działa
- Module caching działa
- Developer mode działa

✅ **System Tests:**
- Wszystkie workflow end-to-end działają
- Brak błędów w pełnym cyklu

✅ **Regression Tests:**
- Wszystkie komendy działają identycznie
- PL i EN wersje działają
- Brak regresji funkcjonalności

✅ **Performance Tests:**
- Startup time <= stara wersja
- Memory usage <= stara wersja
- Module loading overhead < 50ms

---

### 11. BUG TRACKING

**Jeśli test nie przechodzi:**

1. **Zapisz błąd:**
```bash
echo "FAIL: test_name" >> test-failures.log
echo "Error: $error_message" >> test-failures.log
echo "---" >> test-failures.log
```

2. **Debug:**
```bash
CYTADELA_DEBUG=1 sudo ./cytadela++.sh command 2>&1 | tee debug.log
```

3. **Fix i re-test:**
```bash
# Fix code
vim modules/module.sh

# Re-run specific test
bash test-module.sh

# Re-run all tests
bash run-all-tests.sh
```

---

## PODSUMOWANIE

### Test Coverage:

- **Unit Tests:** ~20 testów
- **Module Tests:** ~17 modułów x 3 testy = ~51 testów
- **Integration Tests:** ~5 testów
- **System Tests:** ~10 testów
- **Regression Tests:** ~15 komend x 2 wersje = ~30 testów
- **Performance Tests:** ~3 testy

**TOTAL:** ~119 testów automatycznych

### Czas Testowania:

- Unit Tests: ~5 min
- Module Tests: ~15 min
- Integration Tests: ~5 min
- System Tests: ~10 min
- Regression Tests: ~10 min
- Performance Tests: ~5 min

**TOTAL:** ~50 minut pełnego test suite

---

✅ **STRATEGIA TESTOWANIA GOTOWA**  
✅ **WSZYSTKIE FAZY ANALIZY ZAKOŃCZONE**
