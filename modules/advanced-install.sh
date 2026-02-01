#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ ADVANCED-INSTALL MODULE v3.1                                  ║
# ║  Kernel Optimization, DoH Parallel, Editor Integration                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

optimize_kernel_priority() {
    log_section "⚡ KERNEL PRIORITY OPTIMIZATION"

    # Check if running on CachyOS/Arch
    if [[ ! -f /etc/arch-release ]]; then
        log_warning "Ta funkcja jest zoptymalizowana dla CachyOS/Arch Linux"
        return 1
    fi

    # Create priority tuning script
    sudo tee /usr/local/bin/citadel-dns-priority.sh >/dev/null <<'EOF'
#!/bin/bash
renice -10 $(pgrep dnscrypt-proxy) 2>/dev/null || true
renice -10 $(pgrep coredns) 2>/dev/null || true
ionice -c 2 -n 0 $(pgrep dnscrypt-proxy) 2>/dev/null || true
ionice -c 2 -n 0 $(pgrep coredns) 2>/dev/null || true
logger "Citadel++: Applied priority tuning to DNS processes"
EOF
    sudo chmod +x /usr/local/bin/citadel-dns-priority.sh

    # Create systemd service for DNS priority optimization
    sudo tee /etc/systemd/system/citadel-dns-priority.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Optimization
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel-dns-priority.sh
EOF

    sudo tee /etc/systemd/system/citadel-dns-priority.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Timer

[Timer]
OnCalendar=minutely
Persistent=true
Unit=citadel-dns-priority.service

[Install]
WantedBy=timers.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now citadel-dns-priority.timer

    # Apply immediately
    sudo systemctl start citadel-dns-priority.service

    log_success "Kernel priority optimization aktywny"
}

install_doh_parallel() {
    log_section "🚀 DNS-OVER-HTTPS PARALLEL RACING"

    # Create advanced DNSCrypt config with DoH parallel racing
    sudo tee /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml >/dev/null <<'EOF'
# Citadel++ DNSCrypt with DoH Parallel Racing
listen_addresses = ['127.0.0.1:5353', '[::1]:5353']
user_name = 'dnscrypt'

# Enable parallel racing for faster responses
server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

# DoH servers with parallel racing
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = false

# Parallel racing configuration
lb_strategy = 'p2'  # Power of Two load balancing
lb_estimator = true

# Performance tuning
max_clients = 500
cache_size = 1024
cache_min_ttl = 300
cache_max_ttl = 86400
timeout = 3000
keepalive = 30

# Bootstrap resolvers
bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53', '149.112.112.112:53']
ignore_system_dns = true

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    log_success "Konfiguracja DoH Parallel Racing gotowa"
    log_info "Aby aktywować: sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml"
}

install_editor_integration() {
    log_section "✏️ EDITOR INTEGRATION SETUP"

    if ! command -v yay >/dev/null 2>&1; then
        log_warning "Brak yay - nie mogę automatycznie zainstalować micro"
        return 1
    fi

    # Install micro editor
    if ! command -v micro >/dev/null; then
        log_info "Instalowanie edytora micro..."
        yay -S micro --noconfirm
    fi

    # Create citadel edit command
    sudo tee /usr/local/bin/citadel >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Editor Integration v1.0

ACTION=${1:-help}
CONFIG_DIR="/etc/coredns"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

case "$ACTION" in
    edit)
        echo "📝 Opening Citadel++ configuration in micro editor..."
        sudo micro "$CONFIG_DIR/Corefile"
        echo "🔄 Restarting CoreDNS..."
        sudo systemctl restart coredns
        echo "✓ CoreDNS reloaded with new configuration"
        ;;
    edit-dnscrypt)
        echo "📝 Opening DNSCrypt configuration..."
        sudo micro "$DNSCRYPT_CONFIG"
        echo "🔄 Restarting DNSCrypt..."
        sudo systemctl restart dnscrypt-proxy
        echo "✓ DNSCrypt reloaded with new configuration"
        ;;
    status)
        echo "📊 Citadel++ Status:"
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    logs)
        echo "📋 Recent logs:"
        journalctl -u dnscrypt-proxy -u coredns -n 20 --no-pager
        ;;
    test)
        echo "🧪 Testing DNS resolution..."
        dig +short whoami.cloudflare @127.0.0.1 || echo "❌ DNS test failed"
        ;;
    help|--help|-h)
        cat <<HELP
Citadel++ Editor Integration

Commands:
  citadel edit         Edit CoreDNS config and auto-restart
  citadel edit-dnscrypt Edit DNSCrypt config and auto-restart  
  citadel status       Show service status
  citadel logs         Show recent logs
  citadel test         Test DNS resolution
  citadel help         Show this help

Examples:
  citadel edit         # Edit CoreDNS configuration
  citadel edit-dnscrypt # Edit DNSCrypt configuration
HELP
        ;;
    *)
        echo "Unknown command. Use 'citadel help' for usage."
        exit 1
        ;;
esac
EOF

    sudo chmod +x /usr/local/bin/citadel
    log_success "Editor integration zainstalowany: użyj 'citadel edit'"
}
