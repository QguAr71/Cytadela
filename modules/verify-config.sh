#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ VERIFY-CONFIG MODULE                                          ║
# ║  Verifies Citadel++ configuration files and service status                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# =============================================================================
# MODULE METADATA
# =============================================================================

MODULE_NAME="verify-config"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Verifies Citadel configuration, services, and DNS functionality"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=("systemctl" "dig" "ip" "nft")
MODULE_TAGS=("config" "verify" "diagnostics")

# =============================================================================
# MAIN MODULE FUNCTION
# =============================================================================

verify_config() {
    # Load i18n strings based on language
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    local module_dir="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
    if [[ -f "${module_dir}/lib/i18n/${lang}.sh" ]]; then
        # shellcheck source=/dev/null
        source "${module_dir}/lib/i18n/${lang}.sh"
    fi
    
    # Parse arguments
    local action="${1:-check}"
    
    case "$action" in
        check|verify|status)
            verify_config_check
            ;;
        dns|test)
            verify_config_dns
            ;;
        services)
            verify_config_services
            ;;
        files)
            verify_config_files
            ;;
        all)
            verify_config_check
            verify_config_dns
            ;;
        help|--help|-h)
            verify_config_help
            ;;
        *)
            log_error "${T_UNKNOWN_ACTION:-Unknown action}: $action"
            verify_config_help
            return 1
            ;;
    esac
}

# =============================================================================
# MODULE IMPLEMENTATION
# =============================================================================

verify_config_check() {
    log_section "🔍 ${T_VERIFY_CONFIG_TITLE:-CONFIGURATION VERIFICATION}"
    
    local errors=0
    local warnings=0
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        log_warning "${T_VERIFY_NOT_ROOT:-Not running as root - some checks may fail}"
        ((warnings++))
    fi
    
    # Check CoreDNS configuration
    echo ""
    log_info "${T_VERIFY_COREDNS:-Checking CoreDNS configuration...}"
    if [[ -f /etc/coredns/Corefile ]]; then
        if coredns -conf /etc/coredns/Corefile -check 2>/dev/null; then
            log_success "  󰄬 ${T_VERIFY_COREDNS_OK:-CoreDNS configuration valid}"
        else
            log_error "  ✗ ${T_VERIFY_COREDNS_ERROR:-CoreDNS configuration has errors}"
            ((errors++))
        fi
    else
        log_error "  ✗ ${T_VERIFY_COREDNS_MISSING:-Corefile not found at /etc/coredns/Corefile}"
        ((errors++))
    fi
    
    # Check DNSCrypt configuration
    echo ""
    log_info "${T_VERIFY_DNSCRYPT:-Checking DNSCrypt configuration...}"
    if [[ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]; then
        if dnscrypt-proxy -check -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml 2>/dev/null; then
            log_success "  󰄬 ${T_VERIFY_DNSCRYPT_OK:-DNSCrypt configuration valid}"
        else
            log_error "  ✗ ${T_VERIFY_DNSCRYPT_ERROR:-DNSCrypt configuration has errors}"
            ((errors++))
        fi
    else
        log_error "  ✗ ${T_VERIFY_DNSCRYPT_MISSING:-DNSCrypt config not found}"
        ((errors++))
    fi
    
    # Check NFTables rules
    echo ""
    log_info "${T_VERIFY_NFT:-Checking NFTables configuration...}"
    if nft list table inet citadel_dns &>/dev/null; then
        log_success "  󰄬 ${T_VERIFY_NFT_OK:-Citadel NFTables table exists}"
    else
        log_error "  ✗ ${T_VERIFY_NFT_MISSING:-Citadel NFTables table not found}"
        ((errors++))
    fi
    
    # Check services
    echo ""
    log_info "${T_VERIFY_SERVICES:-Checking services...}"
    for service in coredns dnscrypt-proxy; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            log_success "  󰄬 $service ${T_VERIFY_RUNNING:-is running}"
        else
            log_error "  ✗ $service ${T_VERIFY_NOT_RUNNING:-is not running}"
            ((errors++))
        fi
    done
    
    # Check DNS resolution
    echo ""
    log_info "${T_VERIFY_DNS:-Testing DNS resolution...}"
    if dig +short +time=3 @127.0.0.1 google.com &>/dev/null; then
        log_success "  󰄬 ${T_VERIFY_DNS_OK:-Local DNS resolver working}"
    else
        log_error "  ✗ ${T_VERIFY_DNS_ERROR:-Local DNS resolver not responding}"
        ((errors++))
    fi
    
    # Summary
    echo ""
    echo "=== ${T_VERIFY_SUMMARY:-VERIFICATION SUMMARY} ==="
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        log_success "${T_VERIFY_ALL_OK:-All checks passed! Citadel is properly configured.}"
        return 0
    else
        [[ $warnings -gt 0 ]] && log_warning "$warnings ${T_VERIFY_WARNINGS:-warnings}"
        [[ $errors -gt 0 ]] && log_error "$errors ${T_VERIFY_ERRORS:-errors found}"
        return 1
    fi
}

verify_config_dns() {
    log_section "🌐 ${T_VERIFY_DNS_TITLE:-DNS VERIFICATION TEST}"
    
    local test_domains=("google.com" "cloudflare.com" "github.com")
    local failed=0
    
    echo ""
    log_info "${T_VERIFY_DNS_TEST:-Testing DNS resolution through Citadel...}"
    
    for domain in "${test_domains[@]}"; do
        local result
        result=$(dig +short +time=5 @127.0.0.1 "$domain" 2>/dev/null | head -1)
        if [[ -n "$result" ]]; then
            log_success "  󰄬 $domain → $result"
        else
            log_error "  ✗ $domain ${T_VERIFY_DNS_FAIL:-failed to resolve}"
            ((failed++))
        fi
    done
    
    # Check DNSSEC
    echo ""
    log_info "${T_VERIFY_DNSSEC:-Checking DNSSEC validation...}"
    if dig +dnssec +short @127.0.0.1 dnssec-failed.org 2>/dev/null | grep -q "SERVFAIL"; then
        log_success "  󰄬 ${T_VERIFY_DNSSEC_OK:-DNSSEC validation working}"
    else
        log_warning "  ⚠ ${T_VERIFY_DNSSEC_WARN:-DNSSEC validation may not be enforced}"
    fi
    
    if [[ $failed -eq 0 ]]; then
        echo ""
        log_success "${T_VERIFY_DNS_ALL_OK:-All DNS tests passed!}"
        return 0
    else
        echo ""
        log_error "$failed ${T_VERIFY_DNS_FAILED:-DNS tests failed}"
        return 1
    fi
}

verify_config_services() {
    log_section "⚙️  ${T_VERIFY_SERVICES_TITLE:-SERVICE STATUS}"
    
    local services=("coredns" "dnscrypt-proxy" "nftables")
    
    for service in "${services[@]}"; do
        echo ""
        if [[ "$service" == "nftables" ]]; then
            # Special handling for nftables
            if systemctl is-active --quiet nftables 2>/dev/null || systemctl is-active --quiet nft 2>/dev/null; then
                log_success "$service: ${T_VERIFY_ACTIVE:-active}"
            else
                log_warning "$service: ${T_VERIFY_INACTIVE:-inactive} (may be managed differently)"
            fi
        else
            local status
            status=$(systemctl is-active "$service" 2>/dev/null || echo "unknown")
            local enabled
            enabled=$(systemctl is-enabled "$service" 2>/dev/null || echo "unknown")
            
            if [[ "$status" == "active" ]]; then
                log_success "$service: ${T_VERIFY_ACTIVE:-active} (${T_VERIFY_ENABLED:-enabled}: $enabled)"
            else
                log_error "$service: $status (${T_VERIFY_ENABLED:-enabled}: $enabled)"
            fi
        fi
    done
}

verify_config_files() {
    log_section "📁 ${T_VERIFY_FILES_TITLE:-CONFIGURATION FILES}"
    
    local files=(
        "/etc/coredns/Corefile"
        "/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
        "/etc/resolv.conf"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            local size
            size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "unknown")
            local modified
            modified=$(stat -c%y "$file" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
            log_success "$file (${size} bytes, $modified)"
            
            # Show first few lines for resolv.conf
            if [[ "$file" == "/etc/resolv.conf" ]]; then
                echo "  Content:"
                grep "^nameserver" "$file" 2>/dev/null | head -3 | sed 's/^/    /'
            fi
        else
            log_error "$file ${T_VERIFY_NOT_FOUND:-not found}"
        fi
    done
}

verify_config_help() {
    cat <<EOF
🔍 ${T_VERIFY_CONFIG_TITLE:-VERIFY-CONFIG} - ${MODULE_DESCRIPTION}

${T_USAGE:-USAGE}:
  cytadela++ verify-config [check|dns|services|files|all|help]

${T_OPTIONS:-OPTIONS}:
  check      ${T_VERIFY_HELP_CHECK:-Full configuration check (default)}
  dns        ${T_VERIFY_HELP_DNS:-Test DNS resolution only}
  services   ${T_VERIFY_HELP_SERVICES:-Show service status only}
  files      ${T_VERIFY_HELP_FILES:-Show configuration files only}
  all        ${T_VERIFY_HELP_ALL:-Run all checks including DNS tests}
  help       ${T_VERIFY_HELP_HELP:-Show this help}

${T_EXAMPLES:-EXAMPLES}:
  cytadela++ verify-config              # Quick configuration check
  cytadela++ verify-config dns          # Test DNS functionality
  cytadela++ verify-config all          # Comprehensive verification

EOF
}
