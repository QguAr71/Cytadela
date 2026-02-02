# Test Framework Documentation

## Overview

Citadel uses a multi-layered testing approach:
1. **Smoke Tests** - Quick functionality checks
2. **BATS Tests** - Unit and integration tests
3. **Test Core** - Reusable test utilities

## Test Files

```
tests/
├── smoke-test.sh      # Quick system checks
├── test-cytadela.sh   # Main test suite
└── unit/              # BATS unit tests
    ├── test-module-loader.bats
    └── test-network-utils.bats
```

## Test Core Functions (`lib/test-core.sh`)

### Service Tests
```bash
test_service_running <service_name>    # Check if systemd service is active
test_port_open <port> <protocol>       # Check if port is listening
test_dns_resolution [domain]           # Test DNS resolution
```

### Network Tests
```bash
test_network_connectivity              # Basic connectivity check
test_firewall_rule <table> <chain>     # Verify nftables rules
test_internet_access                   # Check external connectivity
```

### Composite Tests
```bash
test_dns_full                          # Full DNS stack test
test_full_stack                        # Complete system verification
```

## Writing Tests

### Smoke Test Example
```bash
#!/bin/bash
set -euo pipefail

source "${CYTADELA_LIB}/test-core.sh"

test_dns_resolution || exit 1
test_service_running "coredns" || exit 1
```

### BATS Test Example
```bash
#!/usr/bin/env bats

@test "DNS resolution works" {
    run dig +short google.com @127.0.0.1
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}
```

## Running Tests

```bash
# Smoke tests
bash tests/smoke-test.sh

# Full test suite
bats tests/unit/

# Specific test
bats tests/unit/test-module-loader.bats
```

## Test Categories

| Category | Purpose | Command |
|----------|---------|---------|
| Smoke | Quick health check | `bash tests/smoke-test.sh` |
| Unit | Module isolation | `bats tests/unit/` |
| Integration | Full workflow | `sudo ./citadel.sh test-all` |

## Continuous Integration

Tests run automatically on:
- Every PR via GitHub Actions
- ShellCheck static analysis
- BATS unit tests
- Smoke tests (with sudo)
