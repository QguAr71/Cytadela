#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Basic Setup Example                                           ║
# ║  Simple installation and configuration for home users                          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
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

# Basic installation
basic_install() {
    log_info "Starting basic Cytadela++ installation..."
    
    # Install all components
    log_info "Installing DNSCrypt, CoreDNS, and NFTables..."
    if cytadela.sh install-all; then
        log_success "Installation completed successfully"
    else
        log_error "Installation failed"
        return 1
    fi
}

# Configure system safely
configure_system() {
    log_info "Configuring system with SAFE firewall mode..."
    
    # Use safe mode first (doesn't break internet)
    if cytadela.sh firewall-safe; then
        log_success "Safe firewall mode activated"
    else
        log_error "Firewall configuration failed"
        return 1
    fi
    
    # Test local DNS
    log_info "Testing local DNS resolution..."
    if dig +short google.com @127.0.0.1 >/dev/null 2>&1; then
        log_success "Local DNS is working"
    else
        log_warning "Local DNS test failed - this might be expected before system switch"
    fi
}

# Switch to Cytadela++ DNS
switch_dns() {
    log_info "Switching system to use Cytadela++ DNS..."
    log_warning "This will disable systemd-resolved"
    
    # Switch system DNS
    if cytadela.sh configure-system; then
        log_success "System switched to Cytadela++ DNS"
    else
        log_error "DNS switch failed"
        return 1
    fi
    
    # Test internet connectivity
    log_info "Testing internet connectivity..."
    if ping -c 3 google.com >/dev/null 2>&1; then
        log_success "Internet connectivity OK"
    else
        log_error "Internet connectivity failed"
        return 1
    fi
}

# Enable strict mode (optional)
enable_strict() {
    log_info "Enabling STRICT firewall mode..."
    log_warning "This will block all DNS leaks"
    
    if cytadela.sh firewall-strict; then
        log_success "Strict mode enabled"
    else
        log_error "Failed to enable strict mode"
        return 1
    fi
}

# Show status
show_status() {
    log_info "Cytadela++ status:"
    cytadela.sh status
}

# Main execution
main() {
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                  CYTADELA++ - BASIC SETUP                              ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_root
    check_cytadela
    
    # Step 1: Install
    if ! basic_install; then
        log_error "Installation failed. Exiting."
        exit 1
    fi
    
    echo ""
    
    # Step 2: Configure safely
    if ! configure_system; then
        log_error "Safe configuration failed. Exiting."
        exit 1
    fi
    
    echo ""
    
    # Step 3: Switch DNS
    if ! switch_dns; then
        log_error "DNS switch failed. You may need to restore manually:"
        log_info "  sudo cytadela.sh restore-system"
        exit 1
    fi
    
    echo ""
    
    # Step 4: Enable strict mode (optional but recommended)
    if ! enable_strict; then
        log_warning "Failed to enable strict mode, but basic setup is working"
    fi
    
    echo ""
    
    # Step 5: Show final status
    show_status
    
    echo ""
    log_success "Basic Cytadela++ setup completed!"
    echo ""
    log_info "Useful commands:"
    echo "  cytadela.sh status          - Check status"
    echo "  cytadela.sh diagnostics     - Run diagnostics"
    echo "  cytadela.sh adblock-status  - Check adblock"
    echo "  cytadela.sh restore-system - Restore original DNS (if needed)"
    echo ""
    log_info "For advanced configuration, see: examples/advanced-setup.sh"
}

# Run main function
main "$@"
