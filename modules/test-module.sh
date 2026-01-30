#!/bin/bash
# Mini PoC - Test Module

test_function() {
    log_info "Test module function called"
    log_success "Module works correctly!"
}

test_with_dependency() {
    log_info "Testing with core dependency..."
    test_core_loaded
    log_success "Dependencies work!"
}
