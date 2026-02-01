#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Emergency Recovery Example                                   ║
# ║  Emergency procedures when DNS fails or system is broken                     ║
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

log_emergency() {
    echo -e "${PURPLE}[EMERGENCY]${NC} $1"
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
        log_error "Cytadela++ not found. This script requires Cytadela++."
        log_info "Download from: https://github.com/QguAr71/Cytadela"
        exit 1
    fi
}

# Emergency DNS bypass (when DNS completely fails)
emergency_dns_bypass() {
    log_emergency "ACTIVATING EMERGENCY DNS BYPASS"
    log_warning "This will temporarily disable all DNS protection!"
    log_info "Auto-rollback in 60 seconds unless manually restored"
    
    # Activate panic bypass for 60 seconds
    if cytadela.sh panic-bypass 60; then
        log_success "Emergency DNS bypass activated"
        log_info "You now have 60 seconds to fix issues or test connectivity"
        log_warning "Run 'cytadela.sh panic-restore' to restore protection manually"
        
        # Test basic connectivity
        log_info "Testing emergency DNS connectivity..."
        if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
            log_success "Emergency connectivity working"
        else
            log_error "Even emergency connectivity failed - network issues"
        fi
        
        # Test DNS resolution
        log_info "Testing DNS resolution..."
        if nslookup google.com >/dev/null 2>&1; then
            log_success "DNS resolution working"
        else
            log_warning "DNS resolution still failing"
        fi
    else
        log_error "Failed to activate emergency bypass"
        return 1
    fi
}

# Restore protection after emergency fix
restore_protection() {
    log_emergency "RESTORING DNS PROTECTION"
    
    if cytadela.sh panic-restore; then
        log_success "DNS protection restored"
    else
        log_error "Failed to restore protection"
        return 1
    fi
}

# Kill switch (block all DNS except localhost)
activate_killswitch() {
    log_emergency "ACTIVATING DNS KILL-SWITCH"
    log_warning "This will block ALL DNS except localhost!"
    log_info "Use this when you suspect DNS leakage or attacks"
    
    if cytadela.sh killswitch-on; then
        log_success "Kill-switch activated"
        log_info "Only localhost (127.0.0.1) DNS is allowed"
        log_warning "Run 'cytadela.sh killswitch-off' to disable"
    else
        log_error "Failed to activate kill-switch"
        return 1
    fi
}

# Disable kill switch
disable_killswitch() {
    log_info "Disabling DNS kill-switch..."
    
    if cytadela.sh killswitch-off; then
        log_success "Kill-switch disabled"
    else
        log_error "Failed to disable kill-switch"
        return 1
    fi
}

# Emergency refuse mode (CoreDNS refuses all queries)
emergency_refuse_mode() {
    log_emergency "ACTIVATING EMERGENCY REFUSE MODE"
    log_warning "CoreDNS will refuse ALL DNS queries!"
    log_info "Use this to completely disable DNS service"
    
    if cytadela.sh emergency-refuse; then
        log_success "Emergency refuse mode activated"
        log_info "All DNS queries will be refused"
        log_warning "Run 'cytadela.sh emergency-restore' to restore"
    else
        log_error "Failed to activate refuse mode"
        return 1
    fi
}

# Restore from emergency refuse mode
restore_emergency() {
    log_info "Restoring from emergency mode..."
    
    if cytadela.sh emergency-restore; then
        log_success "Normal operation restored"
    else
        log_error "Failed to restore from emergency mode"
        return 1
    fi
}

# Restore system to original state
restore_system() {
    log_emergency "RESTORING SYSTEM TO ORIGINAL STATE"
    log_warning "This will restore systemd-resolved and remove Cytadela++ DNS"
    
    if cytadela.sh restore-system; then
        log_success "System restored to original state"
        log_info "systemd-resolved is now active"
    else
        log_error "Failed to restore system"
        return 1
    fi
}

# Deep IPv6 reset (when IPv6 is broken)
deep_ipv6_reset() {
    log_emergency "PERFORMING DEEP IPv6 RESET"
    log_warning "This will flush IPv6 cache and reconnect interfaces"
    
    if cytadela.sh ipv6-deep-reset; then
        log_success "IPv6 reset completed"
    else
        log_error "IPv6 reset failed"
        return 1
    fi
}

# Check system status
check_status() {
    log_info "Checking current system status..."
    echo ""
    
    # Cytadela status
    log_info "Cytadela++ status:"
    cytadela.sh status
    
    echo ""
    
    # Panic status
    log_info "Panic mode status:"
    cytadela.sh panic-status
    
    echo ""
    
    # Network connectivity
    log_info "Network connectivity:"
    if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
        log_success "IPv4 connectivity: OK"
    else
        log_error "IPv4 connectivity: FAILED"
    fi
    
    if ping6 -c 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        log_success "IPv6 connectivity: OK"
    else
        log_error "IPv6 connectivity: FAILED"
    fi
    
    echo ""
    
    # DNS resolution
    log_info "DNS resolution test:"
    if nslookup google.com >/dev/null 2>&1; then
        log_success "DNS resolution: OK"
    else
        log_error "DNS resolution: FAILED"
    fi
    
    echo ""
    
    # Port exposure audit
    log_info "Port exposure audit:"
    cytadela.sh ghost-check
}

# Last Known Good recovery
lkg_recovery() {
    log_emergency "LAST KNOWN GOOD RECOVERY"
    log_info "Attempting to restore from LKG cache..."
    
    # Restore blocklist from LKG
    if cytadela.sh lkg-restore; then
        log_success "Blocklist restored from LKG cache"
    else
        log_warning "LKG restore failed or no cache available"
    fi
    
    # Update blocklist with LKG fallback
    log_info "Updating blocklist with LKG fallback..."
    if cytadela.sh lists-update; then
        log_success "Blocklist updated successfully"
    else
        log_error "Blocklist update failed"
        return 1
    fi
}

# Interactive emergency menu
emergency_menu() {
    while true; do
        echo ""
        echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║                  CYTADELA++ - EMERGENCY MENU                            ║${NC}"
        echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "1) Emergency DNS bypass (60s)"
        echo "2) Restore protection"
        echo "3) Activate kill-switch"
        echo "4) Disable kill-switch"
        echo "5) Emergency refuse mode"
        echo "6) Restore from emergency"
        echo "7) Restore system completely"
        echo "8) Deep IPv6 reset"
        echo "9) Check system status"
        echo "10) LKG recovery"
        echo "11) Run full diagnostics"
        echo "0) Exit"
        echo ""
        echo -n "${BLUE}Select option [0-11]:${NC} "
        read -r choice
        
        case $choice in
            1)
                emergency_dns_bypass
                ;;
            2)
                restore_protection
                ;;
            3)
                activate_killswitch
                ;;
            4)
                disable_killswitch
                ;;
            5)
                emergency_refuse_mode
                ;;
            6)
                restore_emergency
                ;;
            7)
                restore_system
                ;;
            8)
                deep_ipv6_reset
                ;;
            9)
                check_status
                ;;
            10)
                lkg_recovery
                ;;
            11)
                log_info "Running full diagnostics..."
                cytadela.sh diagnostics
                ;;
            0)
                log_info "Exiting emergency menu"
                break
                ;;
            *)
                log_error "Invalid option. Please select 0-11."
                ;;
        esac
        
        echo ""
        echo -n "${BLUE}Press Enter to continue...${NC}"
        read -r
    done
}

# Show help
show_help() {
    echo "Cytadela++ Emergency Recovery Script"
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  menu          Show interactive emergency menu"
    echo "  bypass        Emergency DNS bypass (60 seconds)"
    echo "  restore       Restore DNS protection"
    echo "  killswitch    Activate DNS kill-switch"
    echo "  unkill        Disable DNS kill-switch"
    echo "  refuse        Emergency refuse mode"
    echo "  unrefuse      Restore from emergency"
    echo "  restore-all   Restore system completely"
    echo "  ipv6-reset    Deep IPv6 reset"
    echo "  status        Check system status"
    echo "  lkg           Last Known Good recovery"
    echo "  diagnostics   Run full diagnostics"
    echo "  help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 menu              # Interactive menu"
    echo "  $0 bypass            # Quick emergency bypass"
    echo "  $0 status            # Check current status"
    echo ""
    echo "In emergency, run: sudo $0 menu"
}

# Main execution
main() {
    # Check for root and Cytadela
    check_root
    check_cytadela
    
    # Parse command line arguments
    case "${1:-menu}" in
        menu)
            emergency_menu
            ;;
        bypass)
            emergency_dns_bypass
            ;;
        restore)
            restore_protection
            ;;
        killswitch)
            activate_killswitch
            ;;
        unkill)
            disable_killswitch
            ;;
        refuse)
            emergency_refuse_mode
            ;;
        unrefuse)
            restore_emergency
            ;;
        restore-all)
            restore_system
            ;;
        ipv6-reset)
            deep_ipv6_reset
            ;;
        status)
            check_status
            ;;
        lkg)
            lkg_recovery
            ;;
        diagnostics)
            log_info "Running full diagnostics..."
            cytadela.sh diagnostics
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
