#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ NETWORK UTILITIES                                             ║
# ║  Shared network functions for all modules                                 ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# PORT CONFIGURATION
# ==============================================================================
export DNSCRYPT_PORT_DEFAULT=5353
export COREDNS_PORT_DEFAULT=53
export COREDNS_METRICS_ADDR="127.0.0.1:9153"

# ==============================================================================
# INTERFACE DISCOVERY
# ==============================================================================
discover_active_interface() {
    # Detect active interface via route lookup (IPv4 primary, IPv6 fallback)
    local iface=""
    # Try IPv4 first
    iface=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}' || true)
    if [[ -z "$iface" ]]; then
        # Fallback to IPv6
        iface=$(ip -6 route get 2001:4860:4860::8888 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}' || true)
    fi
    echo "$iface"
}

discover_network_stack() {
    # Detect which network manager is active
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        echo "NetworkManager"
    elif systemctl is-active --quiet systemd-networkd 2>/dev/null; then
        echo "systemd-networkd"
    elif command -v nmcli &>/dev/null && nmcli -t -f RUNNING general 2>/dev/null | grep -q running; then
        echo "NetworkManager"
    else
        echo "unknown"
    fi
}

discover_nftables_status() {
    # Check nftables version and Citadel tables
    local nft_version=""
    local citadel_tables=""

    if command -v nft &>/dev/null; then
        nft_version=$(nft --version 2>/dev/null | head -1 || echo "unknown")
        citadel_tables=$(nft list tables 2>/dev/null | grep -c "citadel" || echo "0")
    else
        nft_version="not installed"
        citadel_tables="0"
    fi

    echo "version:${nft_version}|citadel_tables:${citadel_tables}"
}

# ==============================================================================
# PORT UTILITIES
# ==============================================================================
port_in_use() {
    local port="$1"
    ss -H -lntu | awk '{print $5}' | grep -Eq "(^|:)${port}$" 2>/dev/null
}

pick_free_port() {
    local start="$1"
    local end="$2"
    for p in $(seq "$start" "$end"); do
        if ! port_in_use "$p"; then
            echo "$p"
            return 0
        fi
    done
    return 1
}

get_dnscrypt_listen_port() {
    local cfg="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    if [[ -f "$cfg" ]]; then
        awk -F"[:']" '/^listen_addresses[[:space:]]*=/{for(i=1;i<=NF;i++){if($i ~ /^[0-9]+$/){print $i; exit}}}' "$cfg" 2>/dev/null || true
    fi
}

get_coredns_listen_port() {
    local cfg="/etc/coredns/Corefile"
    if [[ -f "$cfg" ]]; then
        awk -F'[:}]' '/^\.:/{gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' "$cfg" 2>/dev/null || true
    fi
}
