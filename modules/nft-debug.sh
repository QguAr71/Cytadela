#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ NFT-DEBUG MODULE v3.1                                         ║
# ║  NFTables debug chain with rate-limited logging                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

NFT_DEBUG_TABLE="citadel_debug"

nft_debug_on() {
    load_i18n_module "nft-debug"
    draw_section_header "󰊠 ${T_NFT_DEBUG_ON:-NFT DEBUG - ENABLING}"

    log_info "${T_CREATING_DEBUG:-Creating debug table with rate-limited logging...}"

    nft add table inet $NFT_DEBUG_TABLE 2>/dev/null || true
    nft add chain inet $NFT_DEBUG_TABLE debug_log '{ type filter hook forward priority -10; policy accept; }' 2>/dev/null || true
    nft flush chain inet $NFT_DEBUG_TABLE debug_log 2>/dev/null || true

    nft add rule inet $NFT_DEBUG_TABLE debug_log udp dport 53 limit rate 5/minute counter log prefix \"[CITADEL-DNS] \" 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 53 limit rate 5/minute counter log prefix \"[CITADEL-DNS] \" 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 853 limit rate 5/minute counter log prefix \"[CITADEL-DOT] \" 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 443 ip daddr '{ 8.8.8.8, 8.8.4.4, 1.1.1.1, 1.0.0.1, 9.9.9.9 }' limit rate 5/minute counter log prefix '"[CITADEL-DOH] "' 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log counter 2>/dev/null || true

    log_success "${T_DEBUG_ENABLED:-Debug chain enabled}"
    log_info "${T_VIEW_LOGS:-View logs:} journalctl -f | grep CITADEL"
    log_info "${T_VIEW_COUNTERS:-View counters:} sudo $0 nft-debug-status"
}

nft_debug_off() {
    load_i18n_module "nft-debug"
    draw_section_header "󰊠 ${T_NFT_DEBUG_OFF:-NFT DEBUG - DISABLING}"

    if nft list tables 2>/dev/null | grep -q "$NFT_DEBUG_TABLE"; then
        nft delete table inet $NFT_DEBUG_TABLE 2>/dev/null || true
        log_success "${T_DEBUG_DISABLED:-Debug chain disabled}"
    else
        log_info "${T_DEBUG_NOT_ENABLED:-Debug chain was not enabled}"
    fi
}

nft_debug_status() {
    load_i18n_module "nft-debug"
    draw_section_header "󰊠 ${T_NFT_DEBUG_STATUS:-NFT DEBUG STATUS}"

    if nft list tables 2>/dev/null | grep -q "$NFT_DEBUG_TABLE"; then
        printf "${T_DEBUG_CHAIN:-Debug chain}: ${GREEN}${T_ENABLED:-ENABLED}${NC}\n"
        echo ""
        echo "=== RULES & COUNTERS ==="
        nft list table inet $NFT_DEBUG_TABLE 2>/dev/null | grep -E "(counter|log)" | sed 's/^/  /'
    else
        printf "${T_DEBUG_CHAIN:-Debug chain}: ${YELLOW}${T_DISABLED:-DISABLED}${NC}\n"
        log_info "${T_ENABLE_WITH:-Enable with:} sudo $0 nft-debug-on"
    fi

    echo ""
    echo "=== CITADEL TABLES ==="
    nft list tables 2>/dev/null | grep citadel | sed 's/^/  /' || echo "  (none)"
}

nft_debug_logs() {
    load_i18n_module "nft-debug"
    draw_section_header "󰊠 ${T_NFT_DEBUG_LOGS:-NFT DEBUG LOGS (last 50)}"

    echo "${T_SEARCHING_LOGS:-Searching for CITADEL log entries...}"
    echo ""

    journalctl --no-pager -n 50 2>/dev/null | grep -E "CITADEL-(DNS|DOT|DOH)" || echo "${T_NO_RECENT_LOGS:-No recent CITADEL log entries found}"

    echo ""
    log_info "${T_FOR_LIVE_LOGS:-For live logs:} journalctl -f | grep CITADEL"
}
