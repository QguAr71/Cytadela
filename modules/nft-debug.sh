#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ NFT-DEBUG MODULE v3.1                                         ║
# ║  NFTables debug chain with rate-limited logging                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

NFT_DEBUG_TABLE="citadel_debug"

nft_debug_on() {
    log_section "🔧 NFT DEBUG - ENABLING"

    log_info "Creating debug table with rate-limited logging..."

    nft add table inet $NFT_DEBUG_TABLE 2>/dev/null || true
    nft add chain inet $NFT_DEBUG_TABLE debug_log '{ type filter hook forward priority -10; policy accept; }' 2>/dev/null || true
    nft flush chain inet $NFT_DEBUG_TABLE debug_log 2>/dev/null || true

    nft add rule inet $NFT_DEBUG_TABLE debug_log udp dport 53 limit rate 5/minute counter log prefix \"[CITADEL-DNS] \" 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 53 limit rate 5/minute counter log prefix \"[CITADEL-DNS] \" 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 853 limit rate 5/minute counter log prefix \"[CITADEL-DOT] \" 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 443 ip daddr '{ 8.8.8.8, 8.8.4.4, 1.1.1.1, 1.0.0.1, 9.9.9.9 }' limit rate 5/minute counter log prefix '"[CITADEL-DOH] "' 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log counter 2>/dev/null || true

    log_success "Debug chain enabled"
    log_info "View logs: journalctl -f | grep CITADEL"
    log_info "View counters: sudo $0 nft-debug-status"
}

nft_debug_off() {
    log_section "🔧 NFT DEBUG - DISABLING"

    if nft list tables 2>/dev/null | grep -q "$NFT_DEBUG_TABLE"; then
        nft delete table inet $NFT_DEBUG_TABLE 2>/dev/null || true
        log_success "Debug chain disabled"
    else
        log_info "Debug chain was not enabled"
    fi
}

nft_debug_status() {
    log_section "🔧 NFT DEBUG STATUS"

    if nft list tables 2>/dev/null | grep -q "$NFT_DEBUG_TABLE"; then
        printf "Debug chain: ${GREEN}ENABLED${NC}\n"
        echo ""
        echo "=== RULES & COUNTERS ==="
        nft list table inet $NFT_DEBUG_TABLE 2>/dev/null | grep -E "(counter|log)" | sed 's/^/  /'
    else
        printf "Debug chain: ${YELLOW}DISABLED${NC}\n"
        log_info "Enable with: sudo $0 nft-debug-on"
    fi

    echo ""
    echo "=== CITADEL TABLES ==="
    nft list tables 2>/dev/null | grep citadel | sed 's/^/  /' || echo "  (none)"
}

nft_debug_logs() {
    log_section "🔧 NFT DEBUG LOGS (last 50)"

    echo "Searching for CITADEL log entries..."
    echo ""

    journalctl --no-pager -n 50 2>/dev/null | grep -E "CITADEL-(DNS|DOT|DOH)" || echo "No recent CITADEL log entries found"

    echo ""
    log_info "For live logs: journalctl -f | grep CITADEL"
}
