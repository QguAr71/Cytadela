# Dokumentacja Framework Testowania

## Przegląd

Cytadela używa wielowarstwowego podejścia do testowania:
1. **Testy Smoke** - Szybkie sprawdzenia funkcjonalności
2. **Testy BATS** - Testy jednostkowe i integracyjne
3. **Test Core** - Wielokrotnego użytku narzędzia testowe

## Pliki Testowe

```
tests/
├── smoke-test.sh      # Szybkie sprawdzenia systemu
├── test-cytadela.sh   # Główny zestaw testów
└── unit/              # Testy jednostkowe BATS
    ├── test-module-loader.bats
    └── test-network-utils.bats
```

## Funkcje Test Core (`lib/test-core.sh`)

### Testy Usług
```bash
test_service_running <nazwa_usługi>    # Sprawdź czy usługa systemd jest aktywna
test_port_open <port> <protocol>       # Sprawdź czy port nasłuchuje
test_dns_resolution [domena]           # Test rozwiązywania DNS
```

### Testy Sieci
```bash
test_network_connectivity              # Podstawowe sprawdzenie łączności
test_firewall_rule <table> <chain>     # Zweryfikuj reguły nftables
test_internet_access                   # Sprawdź łączność zewnętrzną
```

### Testy Kompozytowe
```bash
test_dns_full                          # Pełny test stosu DNS
test_full_stack                        # Kompletna weryfikacja systemu
```

## Pisanie Testów

### Przykład Testu Smoke
```bash
#!/bin/bash
set -euo pipefail

source "${CYTADELA_LIB}/test-core.sh"

test_dns_resolution || exit 1
test_service_running "coredns" || exit 1
```

### Przykład Testu BATS
```bash
#!/usr/bin/env bats

@test "DNS resolution works" {
    run dig +short google.com @127.0.0.1
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}
```

## Uruchamianie Testów

```bash
# Testy smoke
bash tests/smoke-test.sh

# Pełny zestaw testów
bats tests/unit/

# Konkretny test
bats tests/unit/test-module-loader.bats
```

## Kategorie Testów

| Kategoria | Cel | Polecenie |
|-----------|-----|-----------|
| Smoke | Szybkie sprawdzenie zdrowia | `bash tests/smoke-test.sh` |
| Unit | Izolacja modułów | `bats tests/unit/` |
| Integration | Pełny workflow | `sudo ./citadel.sh test-all` |

## Continuous Integration

Testy uruchamiają się automatycznie przy:
- Każdym PR przez GitHub Actions
- Analiza statyczna ShellCheck
- Testy jednostkowe BATS
- Testy smoke (z sudo)
