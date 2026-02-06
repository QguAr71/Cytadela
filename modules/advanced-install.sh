#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ ADVANCED-INSTALL MODULE v3.1                                  ║
# ║  Kernel Optimization, DoH Parallel, Editor Integration                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

optimize_kernel_priority() {
    log_section "󱐋 KERNEL PRIORITY OPTIMIZATION"

    # Check if systemd is available (required for timer)
    if ! command -v systemctl >/dev/null 2>&1; then
        log_warning "systemd nie jest dostępny - pomijanie optymalizacji priorytetu"
        return 1
    fi

    # Check if DNS processes are installed
    if ! command -v dnscrypt-proxy >/dev/null 2>&1 && ! command -v coredns >/dev/null 2>&1; then
        log_warning "DNSCrypt ani CoreDNS nie są zainstalowane"
        return 1
    fi

    # Distribution detection and warning
    local distro="unknown"
    if [[ -f /etc/arch-release ]]; then
        distro="arch"
    elif [[ -f /etc/debian_version ]]; then
        distro="debian"
        log_info "Wykryto Debian/Ubuntu - dostosowanie komend..."
    elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
        distro="redhat"
        log_info "Wykryto Fedora/RHEL - dostosowanie komend..."
    else
        log_info "Dystrybucja nieznana - użycie ogólnych komend"
    fi

    # Create priority tuning script (universal)
    log_info "Tworzenie skryptu optymalizacji priorytetów..."
    sudo tee /usr/local/bin/citadel-dns-priority.sh >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ DNS Priority Optimization Script
# Universal version - works on any Linux distribution

# Function to set priority if process exists
set_priority() {
    local pid="$1"
    local name="$2"
    
    if [[ -n "$pid" ]] && [[ "$pid" =~ ^[0-9]+$ ]]; then
        # Check if process still exists
        if kill -0 "$pid" 2>/dev/null; then
            renice -10 "$pid" 2>/dev/null && logger "Citadel++: renice -10 $name (PID: $pid)"
            ionice -c 2 -n 0 -p "$pid" 2>/dev/null && logger "Citadel++: ionice set for $name"
        fi
    fi
}

# Apply to DNSCrypt
DNSCRYPT_PIDS=$(pgrep -x dnscrypt-proxy 2>/dev/null)
if [[ -n "$DNSCRYPT_PIDS" ]]; then
    for pid in $DNSCRYPT_PIDS; do
        set_priority "$pid" "dnscrypt-proxy"
    done
else
    logger "Citadel++: dnscrypt-proxy not running"
fi

# Apply to CoreDNS
COREDNS_PIDS=$(pgrep -x coredns 2>/dev/null)
if [[ -n "$COREDNS_PIDS" ]]; then
    for pid in $COREDNS_PIDS; do
        set_priority "$pid" "coredns"
    done
else
    logger "Citadel++: coredns not running"
fi

# Summary log
if [[ -n "$DNSCRYPT_PIDS" ]] || [[ -n "$COREDNS_PIDS" ]]; then
    logger "Citadel++: DNS priority optimization applied"
else
    logger "Citadel++: No DNS processes found to optimize"
fi
EOF
    sudo chmod +x /usr/local/bin/citadel-dns-priority.sh
    log_success "Skrypt optymalizacji utworzony"

    # Create systemd service
    log_info "Tworzenie systemd service..."
    sudo tee /etc/systemd/system/citadel-dns-priority.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Optimization
After=network.target dnscrypt-proxy.service coredns.service
Wants=dnscrypt-proxy.service coredns.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel-dns-priority.sh
RemainAfterExit=no
EOF
    log_success "Service utworzony"

    # Create systemd timer
    log_info "Tworzenie systemd timer (co minutę)..."
    sudo tee /etc/systemd/system/citadel-dns-priority.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Timer

[Timer]
OnBootSec=30
OnUnitActiveSec=60s
AccuracySec=1s
Persistent=true
Unit=citadel-dns-priority.service

[Install]
WantedBy=timers.target
EOF
    log_success "Timer utworzony"

    # Reload systemd and enable timer
    log_info "Aktywacja timer-a..."
    sudo systemctl daemon-reload
    sudo systemctl enable --now citadel-dns-priority.timer 2>/dev/null || {
        log_warning "Nie udało się włączyć timer-a (może brak uprawnień)"
        return 1
    }

    # Apply immediately if services are running
    log_info "Natychmiastowe zastosowanie priorytetów..."
    local applied=false
    
    if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then
        sleep 1  # Wait for service to fully start
        local dpid=$(pgrep -x dnscrypt-proxy | head -1)
        if [[ -n "$dpid" ]]; then
            sudo renice -10 "$dpid" 2>/dev/null && {
                log_success "DNSCrypt (PID: $dpid) priorytet -10"
                applied=true
            }
        fi
    fi

    if systemctl is-active --quiet coredns 2>/dev/null; then
        sleep 1
        local cpid=$(pgrep -x coredns | head -1)
        if [[ -n "$cpid" ]]; then
            sudo renice -10 "$cpid" 2>/dev/null && {
                log_success "CoreDNS (PID: $cpid) priorytet -10"
                applied=true
            }
        fi
    fi

    # Summary
    if [[ "$applied" == true ]]; then
        log_success "Kernel priority optimization AKTYWNY"
        log_info "Timer: co 60 sekund przypomina procesom DNS o wysokim priorytecie"
        log_info "Skrypt: /usr/local/bin/citadel-dns-priority.sh"
        
        # Show current priorities
        echo ""
        log_info "Aktualne priorytety procesów DNS:"
        ps -eo pid,comm,nice,pri | grep -E "(dnscrypt-proxy|coredns)" | while read line; do
            echo "  $line"
        done
    else
        log_warning "Usługi DNS nie działają - priorytety zostaną zastosowane przy starcie"
        log_info "Timer jest aktywny i zadziała gdy procesy DNS się pojawią"
    fi

    # Show timer status
    echo ""
    log_info "Status timer-a:"
    systemctl status citadel-dns-priority.timer --no-pager 2>/dev/null || true
}

install_doh_parallel() {
    log_section "󱓞 DNS-OVER-HTTPS PARALLEL RACING"

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

    log_success "Konfiguracja DoH Parallel Racing utworzona"

    # Auto-activation with backup
    local config_file="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    local backup_file="${config_file}.backup.$(date +%Y%m%d%H%M%S)"

    if [[ -f "$config_file" ]]; then
        log_info "Tworzenie backupu starej konfiguracji..."
        cp "$config_file" "$backup_file"
        log_success "Backup: $backup_file"
    fi

    log_info "Aktywacja DoH Parallel Racing..."
    cp /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml "$config_file"

    # Validate config
    log_info "Walidacja konfiguracji..."
    if dnscrypt-proxy -config "$config_file" -check 2>/dev/null; then
        log_success "Konfiguracja poprawna"
    else
        log_warning "Walidacja zwróciła ostrzeżenia (może być nowsza składnia)"
    fi

    # Restart service
    log_info "Restart DNSCrypt..."
    systemctl restart dnscrypt-proxy
    sleep 2

    # Test
    log_info "Testowanie DoH..."
    if systemctl is-active --quiet dnscrypt-proxy; then
        if dig +short +time=5 whoami.cloudflare @127.0.0.1 -p 5353 >/dev/null 2>&1; then
            log_success "DoH Parallel Racing AKTYWNY i działa!"
            log_info "Serwery: Cloudflare, Google, Quad9 (parallel racing)"
            log_info "Strategia: p2 (Power of Two load balancing)"
        else
            log_warning "DNSCrypt działa ale test DNS nie przeszedł"
        fi
    else
        log_error "DNSCrypt nie uruchomił się - przywracanie backupu..."
        if [[ -f "$backup_file" ]]; then
            cp "$backup_file" "$config_file"
            systemctl restart dnscrypt-proxy
            log_info "Przywrócono starą konfigurację"
        fi
        return 1
    fi
}

install_editor_integration() {
    log_section "󰏫 EDITOR INTEGRATION SETUP"

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
        echo "󰗉 Opening Citadel++ configuration in micro editor..."
        sudo micro "$CONFIG_DIR/Corefile"
        echo "󰜝 Restarting CoreDNS..."
        sudo systemctl restart coredns
        echo "󰄬 CoreDNS reloaded with new configuration"
        ;;
    edit-dnscrypt)
        echo "󰗉 Opening DNSCrypt configuration..."
        sudo micro "$DNSCRYPT_CONFIG"
        echo "󰜝 Restarting DNSCrypt..."
        sudo systemctl restart dnscrypt-proxy
        echo "󰄬 DNSCrypt reloaded with new configuration"
        ;;
    status)
        echo "󰄬 Citadel++ Status:"
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    logs)
        echo "󰓍 Recent logs:"
        journalctl -u dnscrypt-proxy -u coredns -n 20 --no-pager
        ;;
    test)
        echo "󰙨 Testing DNS resolution..."
        dig +short whoami.cloudflare @127.0.0.1 || echo "󰅖 DNS test failed"
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
