#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INTERACTIVE HELP MODULE                                       ║
# ║  Multi-language help system with menu navigation                          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

MODULE_NAME="help"
MODULE_VERSION="2.0.0"
MODULE_DESCRIPTION="Interactive multi-language help system for Citadel++"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=()
MODULE_TAGS=("help" "i18n" "documentation" "interactive")

# =============================================================================
# MAIN HELP FUNCTION - Interactive menu
# =============================================================================

citadel_help() {
    load_i18n_module "help"
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    
    while true; do
        clear 2>/dev/null || echo ""
        
        # Display menu header
        echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║${NC}       ${CYAN}${T_HELP_MENU_TITLE:-CITADEL++ HELP - Select Section}${NC}        ${BLUE}║${NC}"
        echo -e "${BLUE}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}║${NC} ${GREEN}[1]${NC} ${T_HELP_MENU_1:-1. Installation}${NC}                                        ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${GREEN}[2]${NC} ${T_HELP_MENU_2:-2. Main Program}${NC}                                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${GREEN}[3]${NC} ${T_HELP_MENU_3:-3. Add-ons}${NC}                                           ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${GREEN}[4]${NC} ${T_HELP_MENU_4:-4. Advanced}${NC}                                          ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${GREEN}[5]${NC} ${T_HELP_MENU_5:-5. Emergency}${NC}                                         ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${YELLOW}[6]${NC} ${T_HELP_MENU_6:-6. All Commands}${NC}                                      ${BLUE}║${NC}"
        echo -e "${BLUE}║${NC} ${RED}[q]${NC} ${T_HELP_MENU_QUIT:-Quit}${NC}                                            ${BLUE}║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -n "${T_HELP_PROMPT:-Your choice}: "
        read choice
        
        case "$choice" in
            1) show_help_section_install "$lang" ;;
            2) show_help_section_main "$lang" ;;
            3) show_help_section_addons "$lang" ;;
            4) show_help_section_advanced "$lang" ;;
            5) show_help_section_emergency "$lang" ;;
            6) show_help_full "$lang" ;;
            q|Q) break ;;
            *) 
                echo -e "${RED}${T_HELP_INVALID:-Invalid choice}${NC}"
                sleep 1
                ;;
        esac
        
        if [[ "$choice" != "q" && "$choice" != "Q" ]]; then
            echo ""
            echo -n "${T_HELP_CONTINUE:-Press Enter to return to menu...}"
            read
        fi
    done
}

# =============================================================================
# SECTION 1: INSTALLATION
# =============================================================================

show_help_section_install() {
    local lang="$1"
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}${T_HELP_SECTION_INSTALL:-1. INSTALLATION}${NC}                                    ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}install-wizard${NC}        ${T_HELP_CMD_INSTALL_WIZARD:-Interactive installer (RECOMMENDED)}"
    echo -e "${CYAN}install-all${NC}           ${T_HELP_CMD_INSTALL_ALL:-Install all DNS modules}"
    echo -e "${CYAN}install-dnscrypt${NC}      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Install DNSCrypt-Proxy only}"
    echo -e "${CYAN}install-coredns${NC}       ${T_HELP_CMD_INSTALL_COREDNS:-Install CoreDNS only}"
    echo -e "${CYAN}install-nftables${NC}      ${T_HELP_CMD_INSTALL_NFTABLES:-Install NFTables rules only}"
    echo -e "${CYAN}install-dashboard${NC}     ${T_HELP_CMD_INSTALL_DASHBOARD:-Install terminal dashboard}"
    echo -e "${CYAN}install-editor${NC}        ${T_HELP_CMD_INSTALL_EDITOR:-Install editor integration}"
    echo -e "${CYAN}install-doh-parallel${NC}  ${T_HELP_CMD_INSTALL_DOH_PARALLEL:-Install DNS-over-HTTPS parallel}"
}

# =============================================================================
# SECTION 2: MAIN PROGRAM
# =============================================================================

show_help_section_main() {
    local lang="$1"
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${YELLOW}${T_HELP_SECTION_MAIN:-2. MAIN PROGRAM}${NC}                                  ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}configure-system${NC}      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Switch system DNS to Citadel++}"
    echo -e "${CYAN}restore-system${NC}        ${T_HELP_CMD_RESTORE_SYSTEM:-Restore systemd-resolved}"
    echo -e "${CYAN}firewall-safe${NC}         ${T_HELP_CMD_FIREWALL_SAFE:-SAFE mode (will not break connectivity)}"
    echo -e "${CYAN}firewall-strict${NC}       ${T_HELP_CMD_FIREWALL_STRICT:-STRICT mode (DNS leak protection)}"
    echo ""
    echo -e "${CYAN}status${NC}                ${T_HELP_CMD_STATUS:-Show service status}"
    echo -e "${CYAN}diagnostics${NC}          ${T_HELP_CMD_DIAGNOSTICS:-Full system diagnostics}"
    echo -e "${CYAN}verify${NC}                ${T_HELP_CMD_VERIFY:-Verify full stack}"
    echo -e "${CYAN}verify-config${NC}         ${T_HELP_CMD_VERIFY_CONFIG:-Verify config and DNS}"
    echo -e "${CYAN}verify-config dns${NC}     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-DNS resolution tests only}"
    echo -e "${CYAN}verify-config all${NC}     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-All verification checks}"
    echo -e "${CYAN}test-all${NC}              ${T_HELP_CMD_TEST_ALL:-Smoke test + leak test}"
    echo -e "${CYAN}check-deps${NC}            ${T_HELP_CMD_CHECK_DEPS:-Check dependencies}"
    echo -e "${CYAN}check-deps --install${NC}  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Install missing deps}"
}

# =============================================================================
# SECTION 3: ADD-ONS
# =============================================================================

show_help_section_addons() {
    local lang="$1"
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${PURPLE}${T_HELP_SECTION_ADDONS:-3. ADD-ONS}${NC}                                        ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}Blocklist:${NC}"
    echo -e "  ${CYAN}blocklist-list${NC}        ${T_HELP_CMD_BLOCKLIST_LIST:-Show available blocklist profiles}"
    echo -e "  ${CYAN}blocklist-switch <p>${NC}  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Switch blocklist profile}"
    echo -e "  ${CYAN}lists-update${NC}          ${T_HELP_CMD_LISTS_UPDATE:-Update blocklist with LKG fallback}"
    echo ""
    echo -e "${YELLOW}Adblock:${NC}"
    echo -e "  ${CYAN}adblock-status${NC}        ${T_HELP_CMD_ADBLOCK_STATUS:-Show adblock status}"
    echo -e "  ${CYAN}adblock-add <dom>${NC}     ${T_HELP_CMD_ADBLOCK_ADD:-Add domain to adblock}"
    echo -e "  ${CYAN}adblock-remove <dom>${NC}  ${T_HELP_CMD_ADBLOCK_REMOVE:-Remove domain from adblock}"
    echo -e "  ${CYAN}adblock-query <dom>${NC}   ${T_HELP_CMD_ADBLOCK_QUERY:-Check domain in adblock}"
    echo -e "  ${CYAN}allowlist-add <dom>${NC}   ${T_HELP_CMD_ALLOWLIST_ADD:-Add domain to allowlist}"
    echo ""
    echo -e "${YELLOW}Notifications:${NC}"
    echo -e "  ${CYAN}notify-enable${NC}         ${T_HELP_CMD_NOTIFY_ENABLE:-Enable desktop notifications}"
    echo -e "  ${CYAN}notify-disable${NC}        ${T_HELP_CMD_NOTIFY_DISABLE:-Disable notifications}"
    echo -e "  ${CYAN}notify-status${NC}         ${T_HELP_CMD_NOTIFY_STATUS:-Show notification status}"
    echo -e "  ${CYAN}notify-test${NC}           ${T_HELP_CMD_NOTIFY_TEST:-Send test notification}"
}

# =============================================================================
# SECTION 4: ADVANCED
# =============================================================================

show_help_section_advanced() {
    local lang="$1"
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${RED}${T_HELP_SECTION_ADVANCED:-4. ADVANCED}${NC}                                        ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}LKG (Last Known Good):${NC}"
    echo -e "  ${CYAN}lkg-save${NC}              ${T_HELP_CMD_LKG_SAVE:-Save blocklist to cache}"
    echo -e "  ${CYAN}lkg-restore${NC}           ${T_HELP_CMD_LKG_RESTORE:-Restore blocklist from cache}"
    echo -e "  ${CYAN}lkg-status${NC}            ${T_HELP_CMD_LKG_STATUS:-Show LKG cache status}"
    echo ""
    echo -e "${YELLOW}Auto-update:${NC}"
    echo -e "  ${CYAN}auto-update-enable${NC}    ${T_HELP_CMD_AUTO_UPDATE_ENABLE:-Enable automatic updates}"
    echo -e "  ${CYAN}auto-update-disable${NC}   ${T_HELP_CMD_AUTO_UPDATE_DISABLE:-Disable automatic updates}"
    echo -e "  ${CYAN}auto-update-status${NC}    ${T_HELP_CMD_AUTO_UPDATE_STATUS:-Show auto-update status}"
    echo -e "  ${CYAN}auto-update-now${NC}       ${T_HELP_CMD_AUTO_UPDATE_NOW:-Run update now}"
    echo -e "  ${CYAN}auto-update-configure${NC} ${T_HELP_CMD_AUTO_UPDATE_CONFIGURE:-Configure frequency}"
    echo ""
    echo -e "${YELLOW}Cache Stats:${NC}"
    echo -e "  ${CYAN}cache-stats${NC}         ${T_HELP_CMD_CACHE_STATS:-Show DNS cache statistics}"
    echo -e "  ${CYAN}cache-stats-top${NC}     ${T_HELP_CMD_CACHE_STATS_TOP:-Top N domains}"
    echo -e "  ${CYAN}cache-stats-reset${NC}   ${T_HELP_CMD_CACHE_STATS_RESET:-Reset statistics}"
    echo -e "  ${CYAN}cache-stats-watch${NC}   ${T_HELP_CMD_CACHE_STATS_WATCH:-Live monitoring}"
    echo ""
    echo -e "${YELLOW}Health:${NC}"
    echo -e "  ${CYAN}health-status${NC}       ${T_HELP_CMD_HEALTH_STATUS:-Show health status}"
    echo -e "  ${CYAN}health-install${NC}      ${T_HELP_CMD_HEALTH_INSTALL:-Install health watchdog}"
    echo -e "  ${CYAN}health-uninstall${NC}    ${T_HELP_CMD_HEALTH_UNINSTALL:-Remove health watchdog}"
    echo ""
    echo -e "${YELLOW}Config Backup:${NC}"
    echo -e "  ${CYAN}config-backup${NC}       ${T_HELP_CMD_CONFIG_BACKUP:-Create backup}"
    echo -e "  ${CYAN}config-restore${NC}      ${T_HELP_CMD_CONFIG_RESTORE:-Restore from backup}"
    echo -e "  ${CYAN}config-list${NC}         ${T_HELP_CMD_CONFIG_LIST:-List backups}"
    echo -e "  ${CYAN}config-delete${NC}       ${T_HELP_CMD_CONFIG_DELETE:-Delete backup}"
    echo ""
    echo -e "${YELLOW}Supply Chain:${NC}"
    echo -e "  ${CYAN}supply-chain-status${NC} ${T_HELP_CMD_SUPPLY_STATUS:-Show checksums status}"
    echo -e "  ${CYAN}supply-chain-init${NC}   ${T_HELP_CMD_SUPPLY_INIT:-Initialize checksums}"
    echo -e "  ${CYAN}supply-chain-verify${NC} ${T_HELP_CMD_SUPPLY_VERIFY:-Verify files}"
    echo ""
    echo -e "${YELLOW}Location:${NC}"
    echo -e "  ${CYAN}location-status${NC}     ${T_HELP_CMD_LOCATION_STATUS:-Show current SSID}"
    echo -e "  ${CYAN}location-check${NC}      ${T_HELP_CMD_LOCATION_CHECK:-Check firewall mode}"
    echo -e "  ${CYAN}location-add-trusted${NC} ${T_HELP_CMD_LOCATION_ADD_TRUSTED:-Add SSID to trusted}"
    echo ""
    echo -e "${YELLOW}Optimization:${NC}"
    echo -e "  ${CYAN}optimize-kernel${NC}     ${T_HELP_CMD_OPTIMIZE_KERNEL:-Apply real-time priority}"
    echo -e "  ${CYAN}fix-ports${NC}           ${T_HELP_CMD_FIX_PORTS:-Fix port conflicts}"
    echo -e "  ${CYAN}smart-ipv6${NC}          ${T_HELP_CMD_SMART_IPV6:-Smart IPv6 detection}"
}

# =============================================================================
# SECTION 5: EMERGENCY & RECOVERY
# =============================================================================

show_help_section_emergency() {
    local lang="$1"
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${RED}${T_HELP_SECTION_EMERGENCY:-5. EMERGENCY & RECOVERY}${NC}                          ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}Panic Bypass (SPOF recovery):${NC}"
    echo -e "  ${CYAN}panic-bypass [s]${NC}      ${T_HELP_CMD_PANIC_BYPASS:-Disable protection + auto-rollback}"
    echo -e "  ${CYAN}panic-restore${NC}         ${T_HELP_CMD_PANIC_RESTORE:-Restore protected mode}"
    echo -e "  ${CYAN}panic-status${NC}          ${T_HELP_CMD_PANIC_STATUS:-Show panic status}"
    echo ""
    echo -e "${YELLOW}Emergency:${NC}"
    echo -e "  ${CYAN}emergency-refuse${NC}      ${T_HELP_CMD_EMERGENCY_REFUSE:-Refuse all DNS queries}"
    echo -e "  ${CYAN}emergency-restore${NC}     ${T_HELP_CMD_EMERGENCY_RESTORE:-Restore normal operation}"
    echo ""
    echo -e "${YELLOW}Kill Switch:${NC}"
    echo -e "  ${CYAN}killswitch-on${NC}         ${T_HELP_CMD_KILLSWITCH_ON:-Activate DNS kill-switch}"
    echo -e "  ${CYAN}killswitch-off${NC}        ${T_HELP_CMD_KILLSWITCH_OFF:-Deactivate kill-switch}"
    echo ""
    echo -e "${YELLOW}NFT Debug:${NC}"
    echo -e "  ${CYAN}nft-debug-on${NC}          ${T_HELP_CMD_NFT_DEBUG_ON:-Enable debug chain}"
    echo -e "  ${CYAN}nft-debug-off${NC}         ${T_HELP_CMD_NFT_DEBUG_OFF:-Disable debug chain}"
    echo -e "  ${CYAN}nft-debug-status${NC}      ${T_HELP_CMD_NFT_DEBUG_STATUS:-Show debug status}"
    echo -e "  ${CYAN}nft-debug-logs${NC}        ${T_HELP_CMD_NFT_DEBUG_LOGS:-Show recent logs}"
}

# =============================================================================
# FULL HELP (ALL COMMANDS)
# =============================================================================

show_help_full() {
    local lang="$1"
    show_help_section_install "$lang"
    echo ""
    show_help_section_main "$lang"
    echo ""
    show_help_section_addons "$lang"
    echo ""
    show_help_section_advanced "$lang"
    echo ""
    show_help_section_emergency "$lang"
}
