# BATS Tests for Citadel

This directory contains BATS (Bash Automated Testing System) tests for Citadel.

## Installation

First, install BATS on Arch Linux:

```bash
sudo pacman -S bats bats-assert bats-file bats-support
```

## Running Tests

### Run all tests
```bash
bats tests/
```

### Run specific test suite
```bash
# Unit tests
bats tests/unit/

# Integration tests
bats tests/integration/
```

### Run specific test file
```bash
bats tests/unit/test-module-loader.bats
bats tests/integration/test-install.bats
```

### Run with verbose output
```bash
bats --verbose tests/
```

### Run with timing information
```bash
bats --timing tests/
```

## Test Structure

### Unit Tests (`tests/unit/`)
- `test-module-loader.bats` - Module loading and dependency resolution
- `test-network-utils.bats` - Network utility functions and interface discovery

### Integration Tests (`tests/integration/`)
- `test-install.bats` - Complete installation process and system integration

### Test Helper (`tests/test-helper.bats`)
- Common setup/teardown functions
- Utility functions for testing
- Mock and simulation helpers

## Test Coverage

### Module Loader Tests
- ✅ Function existence and availability
- ✅ Module path resolution
- ✅ Dependency tracking
- ✅ Duplicate loading handling
- ✅ Error handling for broken modules
- ✅ Performance testing

### Network Utils Tests
- ✅ Port configuration variables
- ✅ Interface discovery
- ✅ DNS resolution testing
- ✅ Network connectivity
- ✅ Firewall detection
- ✅ Configuration parsing

### Installation Tests
- ✅ Prerequisites checking
- ✅ Command availability
- ✅ System integration
- ✅ Error handling
- ✅ Performance testing
- ✅ Service management

## Writing New Tests

1. Create a new `.bats` file in the appropriate directory
2. Load the test helper: `load '../test-helper.bats'`
3. Use `@test` annotations for test cases
4. Use helper functions for common operations
5. Follow naming conventions: `test-feature-description.bats`

### Example Test

```bash
#!/usr/bin/env bats
load '../test-helper.bats'

@test "example test case" {
    # Setup
    setup
    
    # Test
    run some_command
    [ "$status" -eq 0 ]
    [[ "$output" =~ "expected" ]]
    
    # Teardown
    teardown
}
```

## Test Environment

Tests run in a controlled environment:
- `CYTADELA_TEST_MODE=1` - Enables test mode
- `CYTADELA_STATE_DIR` - Temporary state directory
- `CYTADELA_LOG_DIR` - Temporary log directory

## Continuous Integration

These tests are designed to run in CI environments:
- No external dependencies (except standard system tools)
- Isolated test environment
- Fast execution (most tests complete in <1s)
- Proper cleanup and teardown

## Troubleshooting

### Tests Fail Due to Missing Dependencies
```bash
# Install missing dependencies
sudo pacman -S bats bats-assert bats-file bats-support
```

### Tests Fail Due to Permissions
```bash
# Run tests as root (required for system integration tests)
sudo bats tests/integration/
```

### Tests Fail Due to Network Issues
```bash
# Skip network-dependent tests
bats --filter "network" tests/
```

## Contributing

When adding new tests:
1. Follow the existing naming conventions
2. Use the test helper functions
3. Add appropriate setup/teardown
4. Include both positive and negative test cases
5. Document any special requirements

## Coverage Reports

To generate a coverage report:
```bash
# Install coverage tools
sudo pacman -S bashcov

# Run tests with coverage
bashcov bats tests/
```
