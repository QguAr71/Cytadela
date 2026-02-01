#!/usr/bin/env bats
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Module Loader Unit Tests                                      ║
# ║  Test module loading, dependency resolution, and error handling                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

load '../test-helper.bash'

# Test module loading function exists
@test "load_module function exists" {
    run load_module --help
    [ "$status" -eq 1 ]  # Should fail without module name
    [[ "$output" =~ "Usage:" ]]
}

# Test loading non-existent module
@test "load_module fails with non-existent module" {
    run load_module "non-existent-module"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "not found" ]]
}

# Test loading core module
@test "load_module can load core module" {
    # Source the module loader
    source "${PROJECT_ROOT}/lib/module-loader.sh"
    
    # Test loading a known module
    run load_module "diagnostics"
    [ "$status" -eq 0 ]
    
    # Check if module functions are available
    run declare -f run_diagnostics
    [ "$status" -eq 0 ]
}

# Test module path resolution
@test "module path resolution works" {
    # Test if module directory exists
    [ -d "${PROJECT_ROOT}/modules" ]
    
    # Test if module file exists
    [ -f "${PROJECT_ROOT}/modules/diagnostics.sh" ]
    
    # Test if module has required functions
    source "${PROJECT_ROOT}/modules/diagnostics.sh"
    run declare -f run_diagnostics
    [ "$status" -eq 0 ]
}

# Test module dependency tracking
@test "module dependency tracking works" {
    # Source the module loader
    source "${PROJECT_ROOT}/lib/module-loader.sh"
    
    # Load a module
    load_module "diagnostics"
    
    # Check if it's marked as loaded
    [ "${CYTADELA_LOADED_MODULES[diagnostics]}" = "1" ]
}

# Test duplicate module loading
@test "duplicate module loading is handled" {
    # Source the module loader
    source "${PROJECT_ROOT}/lib/module-loader.sh"
    
    # Load module twice
    load_module "diagnostics"
    run load_module "diagnostics"
    [ "$status" -eq 0 ]  # Should not fail, just skip
    
    # Still should be marked as loaded
    [ "${CYTADELA_LOADED_MODULES[diagnostics]}" = "1" ]
}

# Test module with syntax errors
@test "module with syntax errors fails gracefully" {
    # Create a temporary broken module
    local broken_module="${PROJECT_ROOT}/tests/fixtures/broken-module.sh"
    mkdir -p "$(dirname "$broken_module")"
    echo "invalid syntax here {" > "$broken_module"
    
    # Try to load it
    run load_module "broken-module"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "syntax error" ]]
    
    # Clean up
    rm -f "$broken_module"
}

# Test module function availability
@test "loaded module functions are available" {
    # Load diagnostics module
    source "${PROJECT_ROOT}/modules/diagnostics.sh"
    
    # Test core functions exist
    run declare -f run_diagnostics
    [ "$status" -eq 0 ]
    
    run declare -f verify_stack
    [ "$status" -eq 0 ]
    
    run declare -f show_status
    [ "$status" -eq 0 ]
}

# Test module isolation
@test "modules are properly isolated" {
    # Load two different modules
    source "${PROJECT_ROOT}/modules/diagnostics.sh"
    source "${PROJECT_ROOT}/modules/adblock.sh"
    
    # Both should have their functions available
    run declare -f run_diagnostics
    [ "$status" -eq 0 ]
    
    run declare -f adblock_status
    [ "$status" -eq 0 ]
    
    # Functions should not conflict
    run run_diagnostics --help
    [ "$status" -eq 1 ]
    
    run adblock_status --help
    [ "$status" -eq 1 ]
}

# Test module loading with arguments
@test "module loading with arguments" {
    # Some modules might accept arguments during loading
    # This tests the argument passing mechanism
    run load_module "diagnostics" "arg1" "arg2"
    [ "$status" -eq 0 ]  # Should succeed even with extra args
}

# Test module unloading (if implemented)
@test "module unloading works" {
    # This test assumes unload_module function exists
    # If not implemented, this test should be skipped
    if declare -f unload_module >/dev/null 2>&1; then
        # Load then unload
        load_module "diagnostics"
        run unload_module "diagnostics"
        [ "$status" -eq 0 ]
        
        # Module should no longer be marked as loaded
        [ -z "${CYTADELA_LOADED_MODULES[diagnostics]:-}" ]
    else
        skip "unload_module not implemented"
    fi
}

# Test module loading performance
@test "module loading is reasonably fast" {
    # Load a module and measure time
    local start_time end_time duration
    start_time=$(date +%s%N)
    
    load_module "diagnostics"
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    # Should load in less than 100ms
    [ "$duration" -lt 100 ]
}

# Test module loading with missing dependencies
@test "module loading handles missing dependencies" {
    # Create a module that depends on non-existent function
    local dep_module="${PROJECT_ROOT}/tests/fixtures/dep-module.sh"
    mkdir -p "$(dirname "$dep_module")"
    cat > "$dep_module" << 'EOF'
#!/bin/bash
test_dep_function() {
    echo "This depends on missing function"
}

# Try to use non-existent dependency
missing_function() {
    echo "This doesn't exist"
}
EOF
    
    # Try to load it
    run load_module "dep-module"
    [ "$status" -eq 1 ]
    
    # Clean up
    rm -f "$dep_module"
}
