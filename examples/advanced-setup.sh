#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Advanced Setup Example                                        ║
# ║  Advanced configuration with custom blocklist and monitoring                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if Cytadela++ is installed
check_cytadela() {
    if ! command -v cytadela.sh >/dev/null 2>&1; then
        log_error "Cytadela++ not found. Please install it first."
        log_info "Download from: https://github.com/QguAr71/Cytadela"
        exit 1
    fi
}

# Full installation with all features
full_install() {
    log_step "Installing all Cytadela++ components..."
    
    # Install all components
    if cytadela.sh install-all; then
        log_success "Installation completed successfully"
    else
        log_error "Installation failed"
        return 1
    fi
}

# Install additional tools
install_tools() {
    log_step "Installing additional tools..."
    
    # Install terminal dashboard
    log_info "Installing citadel-top dashboard..."
    if cytadela.sh install-dashboard; then
        log_success "Dashboard installed"
    else
        log_warning "Dashboard installation failed (optional)"
    fi
    
    # Install editor integration
    log_info "Installing editor integration..."
    if cytadela.sh install-editor; then
        log_success "Editor integration installed"
    else
        log_warning "Editor integration failed (optional)"
    fi
    
    # Optimize kernel for DNS
    log_info "Optimizing kernel priorities..."
    if cytadela.sh optimize-kernel; then
        log_success "Kernel optimization applied"
    else
        log_warning "Kernel optimization failed (optional)"
    fi
}

# Configure aggressive blocklist
configure_blocklist() {
    log_step "Configuring aggressive blocklist profile..."
    
    # Switch to aggressive profile
    if cytadela.sh blocklist-switch aggressive; then
        log_success "Aggressive blocklist activated"
    else
        log_warning "Failed to switch to aggressive profile, using default"
    fi
    
    # Show blocklist status
    log_info "Blocklist status:"
    cytadela.sh blocklist-status
}

# Configure strict firewall
configure_firewall() {
    log_step "Configuring strict firewall mode..."
    
    # Start with safe mode
    log_info "Applying safe firewall mode first..."
    if cytadela.sh firewall-safe; then
        log_success "Safe mode applied"
    else
        log_error "Safe firewall failed"
        return 1
    fi
    
    # Test local DNS
    log_info "Testing local DNS..."
    if dig +short google.com @127.0.0.1 >/dev/null 2>&1; then
        log_success "Local DNS working"
    else
        log_warning "Local DNS test failed (expected before system switch)"
    fi
    
    # Switch system DNS
    log_info "Switching system to Cytadela++ DNS..."
    if cytadela.sh configure-system; then
        log_success "System DNS switched"
    else
        log_error "System DNS switch failed"
        return 1
    fi
    
    # Apply strict mode
    log_info "Applying strict firewall mode..."
    if cytadela.sh firewall-strict; then
        log_success "Strict mode applied"
    else
        log_error "Strict mode failed"
        return 1
    fi
}

# Enable monitoring and notifications
setup_monitoring() {
    log_step "Setting up monitoring and notifications..."
    
    # Enable health watchdog
    log_info "Enabling health watchdog..."
    if cytadela.sh health-install; then
        log_success "Health watchdog enabled"
    else
        log_warning "Health watchdog failed (optional)"
    fi
    
    # Enable desktop notifications
    log_info "Enabling desktop notifications..."
    if cytadela.sh notify-enable; then
        log_success "Desktop notifications enabled"
    else
        log_warning "Desktop notifications failed (optional)"
    fi
    
    # Test notifications
    log_info "Sending test notification..."
    if cytadela.sh notify-test; then
        log_success "Test notification sent"
    else
        log_warning "Test notification failed"
    fi
}

# Configure auto-update
setup_auto_update() {
    log_step "Configuring automatic blocklist updates..."
    
    # Enable auto-update
    log_info "Enabling daily blocklist updates..."
    if cytadela.sh auto-update-enable; then
        log_success "Auto-update enabled"
    else
        log_warning "Auto-update failed (optional)"
    fi
    
    # Show auto-update status
    log_info "Auto-update status:"
    cytadela.sh auto-update-status
}

# Run comprehensive diagnostics
run_diagnostics() {
    log_step "Running comprehensive diagnostics..."
    
    # Full diagnostics
    log_info "Running full system diagnostics..."
    cytadela.sh diagnostics
    
    echo ""
    
    # Verify stack
    log_info "Verifying complete stack..."
    cytadela.sh verify
    
    echo ""
    
    # Test all
    log_info "Running smoke tests..."
    cytadela.sh test-all
}

# Show final status and usage
show_final_status() {
    log_step "Final system status..."
    
    # Show status
    cytadela.sh status
    
    echo ""
    log_success "Advanced Cytadela++ setup completed!"
    echo ""
    log_info "System features enabled:"
    echo "  ✓ Aggressive blocklist filtering"
    echo "  ✓ Strict firewall mode (DNS leak protection)"
    echo "  ✓ Health monitoring"
    echo "  ✓ Desktop notifications"
    echo "  ✓ Automatic blocklist updates"
    echo "  ✓ Terminal dashboard (citadel-top)"
    echo "  ✓ Editor integration"
    echo "  ✓ Kernel optimization"
    echo ""
    log_info "Useful commands:"
    echo "  cytadela-top                    - Real-time dashboard"
    echo "  cytadela edit                   - Edit configuration"
    echo "  cytadela status                 - Check status"
    echo "  cytadela cache-stats             - DNS cache statistics"
    echo "  cytadela adblock-stats           - Adblock statistics"
    echo "  cytadela diagnostics             - Full diagnostics"
    echo "  cytadela ghost-check             - Port exposure audit"
    echo ""
    log_info "Blocklist management:"
    echo "  cytadela blocklist-list          - List available profiles"
    echo "  cytadela blocklist-switch <name> - Switch profile"
    echo "  cytadela adblock-add <domain>    - Add domain to block"
    echo "  cytadela adblock-remove <domain> - Remove domain from block"
    echo ""
    log_info "Emergency commands:"
    echo "  cytadela panic-bypass [seconds]  - Emergency DNS bypass"
    echo "  cytadela panic-restore           - Restore protection"
    echo "  cytadela killswitch-on           - Block all DNS except localhost"
    echo "  cytadela killswitch-off          - Disable kill-switch"
    echo ""
    log_warning "Keep this script for reference or emergency recovery"
}

# Main execution
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                  CYTADELA++ - ADVANCED SETUP                           ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_root
    check_cytadela
    
    # Step 1: Full installation
    if ! full_install; then
        log_error "Installation failed. Exiting."
        exit 1
    fi
    
    echo ""
    
    # Step 2: Install additional tools
    install_tools
    
    echo ""
    
    # Step 3: Configure aggressive blocklist
    if ! configure_blocklist; then
        log_warning "Blocklist configuration had issues, continuing..."
    fi
    
    echo ""
    
    # Step 4: Configure strict firewall
    if ! configure_firewall; then
        log_error "Firewall configuration failed. Exiting."
        exit 1
    fi
    
    echo ""
    
    # Step 5: Setup monitoring
    setup_monitoring
    
    echo ""
    
    # Step 6: Setup auto-update
    setup_auto_update
    
    echo ""
    
    # Step 7: Run diagnostics
    run_diagnostics
    
    echo ""
    
    # Step 8: Show final status
    show_final_status
}

# Run main function
main "$@"
