#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-DASHBOARD MODULE v3.1                                 ║
# ║  Terminal Dashboard Installation                                          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

install_citadel_top() {
    log_section "󰄬 TERMINAL DASHBOARD INSTALLATION"

    require_cmds curl jq systemctl || return 1
    if ! command -v pacman >/dev/null 2>&1; then
        log_warning "Brak pacman - pomijam instalację zależności dla dashboard"
        return 1
    fi

    # Install dependencies
    log_info "Instalowanie zależności dla dashboard..."
    pacman -Q curl jq >/dev/null || sudo pacman -S curl jq --noconfirm

    # Create citadel-top script
    sudo tee /usr/local/bin/citadel-top >/dev/null <<'EOF'
#!/bin/bash
# Citadel Terminal Dashboard v1.0

COREDNS_PORT=53
if [[ -f /etc/coredns/Corefile ]]; then
  p=$(awk -F'[:}]' '/^\.:/{gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' /etc/coredns/Corefile 2>/dev/null)
  if [[ -n "$p" ]]; then
    COREDNS_PORT="$p"
  fi
fi

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    CITADEL++ DASHBOARD                        ║"
echo "║                   Real-time DNS Monitor                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    CITADEL++ DASHBOARD                        ║"
    echo "║                   $(date '+%Y-%m-%d %H:%M:%S')                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "󰈸 SERVICE STATUS:"
    systemctl is-active dnscrypt-proxy >/dev/null && echo "󰄬 DNSCrypt-Proxy: RUNNING" || echo "󰅖 DNSCrypt-Proxy: STOPPED"
    systemctl is-active coredns >/dev/null && echo "󰄬 CoreDNS: RUNNING" || echo "󰅖 CoreDNS: STOPPED"
    if sudo -n nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "󰄬 NFTables: RULES LOADED"
    else
        systemctl is-active nftables >/dev/null && echo "󰄬 NFTables: RUNNING" || echo "󰅖 NFTables: STOPPED"
    fi
    echo ""
    
    echo "󰄬 PROMETHEUS METRICS:"
    if curl -s http://127.0.0.1:9153/metrics >/dev/null 2>&1; then
        QUERIES=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" | tail -1 | awk '{print $2}')
        CACHE_HITS=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_cache_hits_total" | tail -1 | awk '{print $2}')
        echo "  Total Queries: ${QUERIES:-0}"
        echo "  Cache Hits: ${CACHE_HITS:-0}"
    else
        echo "  Metrics unavailable"
    fi
    echo ""
    
    echo "󰌐 NETWORK STATUS:"
    echo "  DNS Resolution: $(dig +short google.com @127.0.0.1 -p ${COREDNS_PORT} 2>/dev/null | head -1 || echo "FAILED")"
    echo "  External IP: $(curl -s https://api.ipify.org 2>/dev/null || echo "UNKNOWN")"
    echo ""
    
    echo "󱐋 PERFORMANCE:"
    if command -v ss >/dev/null; then
        DNS_CONNECTIONS=$(ss -tn | grep :53 | wc -l)
        echo "  Active DNS Connections: $DNS_CONNECTIONS"
    fi
    echo ""
    
    echo "󰈸 SYSTEM LOAD:"
    echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
    echo "  Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
    echo ""
    
    echo "Press Ctrl+C to exit | Refresh: 5s"
    sleep 5
done
EOF

    sudo chmod +x /usr/local/bin/citadel-top
    log_success "Dashboard zainstalowany: uruchom 'citadel-top'"
}
