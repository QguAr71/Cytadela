#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ DISCOVER MODULE v3.1                                          ║
# ║  Network & Firewall Snapshot (Issue #10)                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Note: discover_active_interface() and discover_network_stack() 
# are defined in lib/network-utils.sh - use those instead

discover_nftables_status() {
    if command -v nft &>/dev/null; then
        local tables
        tables=$(nft list tables 2>/dev/null | wc -l)
        if [[ $tables -gt 0 ]]; then
            echo "active ($tables tables)"
        else
            echo "installed (no tables)"
        fi
    else
        echo "not installed"
    fi
}

discover() {
    log_section "🔍 DISCOVER - Network & Firewall Snapshot"

    # Get network info from lib/network-utils.sh
    local iface
    iface=$(discover_active_interface)
    local stack
    stack=$(discover_network_stack)
    local nft_status
    nft_status=$(discover_nftables_status)

    echo "Active Interface: ${iface:-none detected}"
    echo "Network Stack: $stack"
    echo "NFTables: $nft_status"

    # IPv4 info
    if [[ -n "$iface" ]]; then
        local ipv4_addr
        ipv4_addr=$(ip -4 addr show dev "$iface" 2>/dev/null | awk '/inet / {print $2; exit}' || true)
        echo "IPv4 Address: ${ipv4_addr:-none}"

        # IPv6 info
        local ipv6_global
        ipv6_global=$(ip -6 addr show dev "$iface" scope global 2>/dev/null | grep -v temporary | awk '/inet6/ {print $2; exit}' || true)
        local ipv6_temp
        ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ {print $2; exit}' || true)
        echo "IPv6 Global: ${ipv6_global:-none}"
        echo "IPv6 Temporary: ${ipv6_temp:-none}"
    fi

    # DNS stack status
    echo ""
    echo "DNS Stack:"
    for svc in dnscrypt-proxy coredns; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "  $svc: active"
        else
            echo "  $svc: inactive"
        fi
    done
}
