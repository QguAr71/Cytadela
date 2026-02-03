#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ FIX-PORTS MODULE v3.1                                         ║
# ║  Port Conflict Resolution                                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

fix_port_conflicts() {
    log_section "󰊠 PORT CONFLICT RESOLUTION"

    log_info "Sprawdzanie konfliktów portów..."

    # Check what's using port 53
    echo "Procesy używające portu 53:"
    sudo ss -tulpn | grep :53

    echo ""
    log_info "Opcje naprawy:"
    echo "1. Zatrzymaj avahi: sudo systemctl stop avahi-daemon"
    echo "2. Zabij chromium procesy: pkill chromium"
    echo "3. Użyj alternatywnego portu dla CoreDNS"

    # Option to use different port for CoreDNS
    read -p "Czy zmienić port CoreDNS na 5354? (tak/nie): " -r
    if [[ $REPLY =~ ^(tak|TAK|yes|YES|y|Y)$ ]]; then
        log_info "Zmieniam port CoreDNS na 5354..."
        sudo sed -i 's/.:53 {/.:5354 {/g' /etc/coredns/Corefile
        sudo systemctl restart coredns
        log_success "CoreDNS działa na porcie 5354"
        log_info "Test: dig +short whoami.cloudflare @127.0.0.1 -p 5354"
    fi
}
