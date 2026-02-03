#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ EDIT-TOOLS MODULE v3.1                                        ║
# ║  Configuration Editing and Logs                                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

CONFIG_DIR="/etc/coredns"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

edit_config() {
    log_section "📝 EDIT COREDNS CONFIG"

    if command -v micro &>/dev/null; then
        log_info "Opening Corefile in micro editor..."
        sudo micro "$CONFIG_DIR/Corefile"
    elif command -v nano &>/dev/null; then
        log_info "Opening Corefile in nano editor..."
        sudo nano "$CONFIG_DIR/Corefile"
    else
        log_error "No editor found (micro or nano)"
        return 1
    fi

    log_info "Restarting CoreDNS..."
    sudo systemctl restart coredns
    log_success "CoreDNS reloaded with new configuration"
}

edit_dnscrypt() {
    log_section "📝 EDIT DNSCRYPT CONFIG"

    if command -v micro &>/dev/null; then
        log_info "Opening DNSCrypt config in micro editor..."
        sudo micro "$DNSCRYPT_CONFIG"
    elif command -v nano &>/dev/null; then
        log_info "Opening DNSCrypt config in nano editor..."
        sudo nano "$DNSCRYPT_CONFIG"
    else
        log_error "No editor found (micro or nano)"
        return 1
    fi

    log_info "Restarting DNSCrypt..."
    sudo systemctl restart dnscrypt-proxy
    log_success "DNSCrypt reloaded with new configuration"
}

show_logs() {
    log_section "󰓍 RECENT LOGS"

    log_info "Showing last 20 log entries..."
    journalctl -u dnscrypt-proxy -u coredns -n 20 --no-pager
}
