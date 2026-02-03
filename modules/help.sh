#!/bin/bash
# CYTADELA++ INTERACTIVE HELP MODULE

MODULE_NAME="help"
MODULE_VERSION="2.0.0"
MODULE_DESCRIPTION="Interactive multi-language help system"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=()
MODULE_TAGS=("help" "i18n" "documentation" "interactive")

# =============================================================================
# HELPER: Print menu line with proper alignment (handles ANSI colors)
# =============================================================================

print_menu_line() {
    local text="$1"
    local total_width=60
    
    # Strip ANSI colors for length calculation
    local visible_text=$(echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g')
    local visible_len=${#visible_text}
    local padding=$((total_width - visible_len))
    
    printf "║ %b%*s ║\n" "$text" "$padding" ""
}

# =============================================================================
# MAIN HELP FUNCTION - Interactive menu
# =============================================================================

citadel_help() {
    load_i18n_module "help"
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    
    while true; do
        clear 2>/dev/null || echo ""
        
        # Display menu with purple frame using template
        draw_section_header "${T_HELP_MENU_TITLE:-CITADEL++ HELP}"
        echo -e "${VIO}╠══════════════════════════════════════════════════════════════╣${NC}"
        print_frame_line "${GREEN}[1]${NC} ${T_HELP_MENU_1:-1. Installation}"
        print_frame_line "${GREEN}[2]${NC} ${T_HELP_MENU_2:-2. Main Program}"
        print_frame_line "${GREEN}[3]${NC} ${T_HELP_MENU_3:-3. Add-ons}"
        print_frame_line "${GREEN}[4]${NC} ${T_HELP_MENU_4:-4. Advanced}"
        print_frame_line "${GREEN}[5]${NC} ${T_HELP_MENU_5:-5. Emergency}"
        print_frame_line "${YELLOW}[6]${NC} ${T_HELP_MENU_6:-6. All Commands}"
        print_frame_line ""
        print_frame_line "${MAG}[q]${NC} ${T_HELP_MENU_QUIT:-Quit}"
        echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"
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
                echo -e "${RED}Invalid choice${NC}"
                sleep 1
                ;;
        esac
        
        if [[ "$choice" != "q" && "$choice" != "Q" ]]; then
            echo ""
            echo -n "Press Enter to return to menu..."
            read
        fi
    done
}

show_help_section_install() {
    draw_section_header "${T_HELP_SECTION_INSTALL:-1. INSTALLATION}"
    echo ""
    echo -e "${CYAN}install-wizard${NC}       - ${T_HELP_CMD_INSTALL_WIZARD:-Interactive installer (RECOMMENDED)}"
    echo -e "${CYAN}install-all${NC}          - ${T_HELP_CMD_INSTALL_ALL:-Install all DNS modules}"
    echo -e "${CYAN}install-dnscrypt${NC}     - ${T_HELP_CMD_INSTALL_DNSCRYPT:-Install DNSCrypt-Proxy only}"
    echo -e "${CYAN}install-coredns${NC}      - ${T_HELP_CMD_INSTALL_COREDNS:-Install CoreDNS only}"
    echo -e "${CYAN}install-nftables${NC}     - ${T_HELP_CMD_INSTALL_NFTABLES:-Install NFTables rules only}"
    echo -e "${CYAN}install-dashboard${NC}    - ${T_HELP_CMD_INSTALL_DASHBOARD:-Install terminal dashboard}"
    echo -e "${CYAN}install-editor${NC}       - ${T_HELP_CMD_INSTALL_EDITOR:-Install editor integration}"
    echo -e "${CYAN}install-doh-parallel${NC} - ${T_HELP_CMD_INSTALL_DOH_PARALLEL:-Install DNS-over-HTTPS parallel}"
}

show_help_section_main() {
    draw_section_header "${T_HELP_SECTION_MAIN:-2. MAIN PROGRAM}"
    echo ""
    echo -e "${CYAN}configure-system${NC}   - ${T_HELP_CMD_CONFIGURE_SYSTEM:-Switch system DNS to Citadel++}"
    echo -e "${CYAN}restore-system${NC}     - ${T_HELP_CMD_RESTORE_SYSTEM:-Restore systemd-resolved}"
    echo -e "${CYAN}firewall-safe${NC}      - ${T_HELP_CMD_FIREWALL_SAFE:-SAFE mode (won\'t break connectivity)}"
    echo -e "${CYAN}firewall-strict${NC}    - ${T_HELP_CMD_FIREWALL_STRICT:-STRICT mode (DNS leak protection)}"
    echo -e "${CYAN}status${NC}             - ${T_HELP_CMD_STATUS:-Show service status}"
    echo -e "${CYAN}diagnostics${NC}        - ${T_HELP_CMD_DIAGNOSTICS:-Full system diagnostics}"
    echo -e "${CYAN}verify${NC}             - ${T_HELP_CMD_VERIFY:-Verify full stack}"
    echo -e "${CYAN}verify-config${NC}      - ${T_HELP_CMD_VERIFY_CONFIG:-Verify config and DNS}"
    echo -e "${CYAN}test-all${NC}           - ${T_HELP_CMD_TEST_ALL:-Smoke test + leak test}"
    echo -e "${CYAN}check-deps${NC}         - ${T_HELP_CMD_CHECK_DEPS:-Check dependencies}"
    echo -e "${CYAN}check-deps-install${NC} - ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Install missing deps}"
}

show_help_section_addons() {
    draw_section_header "${T_HELP_SECTION_ADDONS:-3. ADD-ONS}"
    echo ""
    echo -e "${CYAN}blocklist-list${NC}     - ${T_HELP_CMD_BLOCKLIST_LIST:-Show available blocklist profiles}"
    echo -e "${CYAN}blocklist-switch${NC}   - ${T_HELP_CMD_BLOCKLIST_SWITCH:-Switch blocklist profile}"
    echo -e "${CYAN}lists-update${NC}       - ${T_HELP_CMD_LISTS_UPDATE:-Update blocklist with LKG fallback}"
    echo -e "${CYAN}adblock-status${NC}     - ${T_HELP_CMD_ADBLOCK_STATUS:-Show adblock status}"
    echo -e "${CYAN}adblock-add${NC}        - ${T_HELP_CMD_ADBLOCK_ADD:-Add domain to adblock}"
    echo -e "${CYAN}adblock-remove${NC}     - ${T_HELP_CMD_ADBLOCK_REMOVE:-Remove domain from adblock}"
    echo -e "${CYAN}adblock-query${NC}      - ${T_HELP_CMD_ADBLOCK_QUERY:-Check domain in adblock}"
    echo -e "${CYAN}allowlist-add${NC}      - ${T_HELP_CMD_ALLOWLIST_ADD:-Add domain to allowlist}"
    echo -e "${CYAN}notify-enable${NC}      - ${T_HELP_CMD_NOTIFY_ENABLE:-Enable desktop notifications}"
    echo -e "${CYAN}notify-disable${NC}     - ${T_HELP_CMD_NOTIFY_DISABLE:-Disable notifications}"
    echo -e "${CYAN}notify-status${NC}      - ${T_HELP_CMD_NOTIFY_STATUS:-Show notification status}"
    echo -e "${CYAN}notify-test${NC}        - ${T_HELP_CMD_NOTIFY_TEST:-Send test notification}"
}

show_help_section_advanced() {
    draw_section_header "${T_HELP_SECTION_ADVANCED:-4. ADVANCED}"
    echo ""
    echo -e "${CYAN}lkg-save${NC}           - ${T_HELP_CMD_LKG_SAVE:-Save blocklist to cache}"
    echo -e "${CYAN}lkg-restore${NC}        - ${T_HELP_CMD_LKG_RESTORE:-Restore blocklist from cache}"
    echo -e "${CYAN}lkg-status${NC}         - ${T_HELP_CMD_LKG_STATUS:-Show LKG cache status}"
    echo -e "${CYAN}auto-update-enable${NC} - ${T_HELP_CMD_AUTO_UPDATE_ENABLE:-Enable automatic updates}"
    echo -e "${CYAN}auto-update-disable${NC}  - ${T_HELP_CMD_AUTO_UPDATE_DISABLE:-Disable automatic updates}"
    echo -e "${CYAN}auto-update-status${NC} - ${T_HELP_CMD_AUTO_UPDATE_STATUS:-Show auto-update status}"
    echo -e "${CYAN}auto-update-now${NC}    - ${T_HELP_CMD_AUTO_UPDATE_NOW:-Run update now}"
    echo -e "${CYAN}cache-stats${NC}        - ${T_HELP_CMD_CACHE_STATS:-Show DNS cache statistics}"
    echo -e "${CYAN}health-status${NC}      - ${T_HELP_CMD_HEALTH_STATUS:-Show health status}"
    echo -e "${CYAN}health-install${NC}     - ${T_HELP_CMD_HEALTH_INSTALL:-Install health watchdog}"
    echo -e "${CYAN}config-backup${NC}      - ${T_HELP_CMD_CONFIG_BACKUP:-Create backup}"
    echo -e "${CYAN}supply-init${NC}        - ${T_HELP_CMD_SUPPLY_INIT:-Initialize checksums}"
    echo -e "${CYAN}location-status${NC}    - ${T_HELP_CMD_LOCATION_STATUS:-Show current SSID}"
}

show_help_section_emergency() {
    draw_section_header "${T_HELP_SECTION_EMERGENCY:-5. EMERGENCY & RECOVERY}"
    echo ""
    echo -e "${CYAN}panic-bypass${NC}       - ${T_HELP_CMD_PANIC_BYPASS:-Disable protection + auto-rollback}"
    echo -e "${CYAN}panic-restore${NC}      - ${T_HELP_CMD_PANIC_RESTORE:-Restore protected mode}"
    echo -e "${CYAN}panic-status${NC}       - ${T_HELP_CMD_PANIC_STATUS:-Show panic status}"
    echo -e "${CYAN}emergency-refuse${NC}   - ${T_HELP_CMD_EMERGENCY_REFUSE:-Refuse all DNS queries}"
    echo -e "${CYAN}emergency-restore${NC}  - ${T_HELP_CMD_EMERGENCY_RESTORE:-Restore normal operation}"
    echo -e "${CYAN}killswitch-on${NC}      - ${T_HELP_CMD_KILLSWITCH_ON:-Activate DNS kill-switch}"
    echo -e "${CYAN}killswitch-off${NC}     - ${T_HELP_CMD_KILLSWITCH_OFF:-Deactivate kill-switch}"
    echo -e "${CYAN}nft-debug-on${NC}       - ${T_HELP_CMD_NFT_DEBUG_ON:-Enable debug chain}"
    echo -e "${CYAN}nft-debug-off${NC}      - ${T_HELP_CMD_NFT_DEBUG_OFF:-Disable debug chain}"
    echo -e "${CYAN}nft-debug-status${NC}   - ${T_HELP_CMD_NFT_DEBUG_STATUS:-Show debug status}"
    echo -e "${CYAN}nft-debug-logs${NC}     - ${T_HELP_CMD_NFT_DEBUG_LOGS:-Show recent logs}"
}

show_help_full() {
    draw_section_header "${T_HELP_SECTION_ALL:-6. ALL COMMANDS}"
    echo ""
    echo -e "${EMR}=== ${T_HELP_SECTION_INSTALL:-1. INSTALLATION} ===${NC}"
    echo -e "${CYAN}install-wizard${NC}       - ${T_HELP_CMD_INSTALL_WIZARD:-Interactive installer (RECOMMENDED)}"
    echo -e "${CYAN}install-all${NC}          - ${T_HELP_CMD_INSTALL_ALL:-Install all DNS modules}"
    echo -e "${CYAN}install-dnscrypt${NC}     - ${T_HELP_CMD_INSTALL_DNSCRYPT:-Install DNSCrypt-Proxy only}"
    echo -e "${CYAN}install-coredns${NC}      - ${T_HELP_CMD_INSTALL_COREDNS:-Install CoreDNS only}"
    echo -e "${CYAN}install-nftables${NC}     - ${T_HELP_CMD_INSTALL_NFTABLES:-Install NFTables rules only}"
    echo -e "${CYAN}install-dashboard${NC}    - ${T_HELP_CMD_INSTALL_DASHBOARD:-Install terminal dashboard}"
    echo -e "${CYAN}install-editor${NC}       - ${T_HELP_CMD_INSTALL_EDITOR:-Install editor integration}"
    echo -e "${CYAN}install-doh-parallel${NC} - ${T_HELP_CMD_INSTALL_DOH_PARALLEL:-Install DNS-over-HTTPS parallel}"
    echo ""
    echo -e "${EMR}=== ${T_HELP_SECTION_MAIN:-2. MAIN PROGRAM} ===${NC}"
    echo -e "${CYAN}configure-system${NC}   - ${T_HELP_CMD_CONFIGURE_SYSTEM:-Switch system DNS to Citadel++}"
    echo -e "${CYAN}restore-system${NC}     - ${T_HELP_CMD_RESTORE_SYSTEM:-Restore systemd-resolved}"
    echo -e "${CYAN}firewall-safe${NC}      - ${T_HELP_CMD_FIREWALL_SAFE:-SAFE mode (won\'t break connectivity)}"
    echo -e "${CYAN}firewall-strict${NC}    - ${T_HELP_CMD_FIREWALL_STRICT:-STRICT mode (DNS leak protection)}"
    echo -e "${CYAN}status${NC}             - ${T_HELP_CMD_STATUS:-Show service status}"
    echo -e "${CYAN}diagnostics${NC}        - ${T_HELP_CMD_DIAGNOSTICS:-Full system diagnostics}"
    echo -e "${CYAN}verify${NC}             - ${T_HELP_CMD_VERIFY:-Verify full stack}"
    echo -e "${CYAN}verify-config${NC}      - ${T_HELP_CMD_VERIFY_CONFIG:-Verify config and DNS}"
    echo -e "${CYAN}test-all${NC}           - ${T_HELP_CMD_TEST_ALL:-Smoke test + leak test}"
    echo -e "${CYAN}check-deps${NC}         - ${T_HELP_CMD_CHECK_DEPS:-Check dependencies}"
    echo -e "${CYAN}check-deps-install${NC} - ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Install missing deps}"
    echo ""
    echo -e "${EMR}=== ${T_HELP_SECTION_ADDONS:-3. ADD-ONS} ===${NC}"
    echo -e "${CYAN}blocklist-list${NC}     - ${T_HELP_CMD_BLOCKLIST_LIST:-Show available blocklist profiles}"
    echo -e "${CYAN}blocklist-switch${NC}   - ${T_HELP_CMD_BLOCKLIST_SWITCH:-Switch blocklist profile}"
    echo -e "${CYAN}lists-update${NC}       - ${T_HELP_CMD_LISTS_UPDATE:-Update blocklist with LKG fallback}"
    echo -e "${CYAN}adblock-status${NC}     - ${T_HELP_CMD_ADBLOCK_STATUS:-Show adblock status}"
    echo -e "${CYAN}adblock-add${NC}        - ${T_HELP_CMD_ADBLOCK_ADD:-Add domain to adblock}"
    echo -e "${CYAN}adblock-remove${NC}     - ${T_HELP_CMD_ADBLOCK_REMOVE:-Remove domain from adblock}"
    echo -e "${CYAN}adblock-query${NC}      - ${T_HELP_CMD_ADBLOCK_QUERY:-Check domain in adblock}"
    echo -e "${CYAN}allowlist-add${NC}      - ${T_HELP_CMD_ALLOWLIST_ADD:-Add domain to allowlist}"
    echo -e "${CYAN}notify-enable${NC}      - ${T_HELP_CMD_NOTIFY_ENABLE:-Enable desktop notifications}"
    echo -e "${CYAN}notify-disable${NC}     - ${T_HELP_CMD_NOTIFY_DISABLE:-Disable notifications}"
    echo -e "${CYAN}notify-status${NC}      - ${T_HELP_CMD_NOTIFY_STATUS:-Show notification status}"
    echo -e "${CYAN}notify-test${NC}        - ${T_HELP_CMD_NOTIFY_TEST:-Send test notification}"
    echo ""
    echo -e "${EMR}=== ${T_HELP_SECTION_ADVANCED:-4. ADVANCED} ===${NC}"
    echo -e "${CYAN}lkg-save${NC}           - ${T_HELP_CMD_LKG_SAVE:-Save blocklist to cache}"
    echo -e "${CYAN}lkg-restore${NC}        - ${T_HELP_CMD_LKG_RESTORE:-Restore blocklist from cache}"
    echo -e "${CYAN}lkg-status${NC}         - ${T_HELP_CMD_LKG_STATUS:-Show LKG cache status}"
    echo -e "${CYAN}auto-update-enable${NC} - ${T_HELP_CMD_AUTO_UPDATE_ENABLE:-Enable automatic updates}"
    echo -e "${CYAN}auto-update-disable${NC}  - ${T_HELP_CMD_AUTO_UPDATE_DISABLE:-Disable automatic updates}"
    echo -e "${CYAN}auto-update-status${NC} - ${T_HELP_CMD_AUTO_UPDATE_STATUS:-Show auto-update status}"
    echo -e "${CYAN}auto-update-now${NC}    - ${T_HELP_CMD_AUTO_UPDATE_NOW:-Run update now}"
    echo -e "${CYAN}cache-stats${NC}        - ${T_HELP_CMD_CACHE_STATS:-Show DNS cache statistics}"
    echo -e "${CYAN}health-status${NC}      - ${T_HELP_CMD_HEALTH_STATUS:-Show health status}"
    echo -e "${CYAN}health-install${NC}     - ${T_HELP_CMD_HEALTH_INSTALL:-Install health watchdog}"
    echo -e "${CYAN}config-backup${NC}      - ${T_HELP_CMD_CONFIG_BACKUP:-Create backup}"
    echo -e "${CYAN}supply-init${NC}        - ${T_HELP_CMD_SUPPLY_INIT:-Initialize checksums}"
    echo -e "${CYAN}location-status${NC}    - ${T_HELP_CMD_LOCATION_STATUS:-Show current SSID}"
    echo ""
    echo -e "${EMR}=== ${T_HELP_SECTION_EMERGENCY:-5. EMERGENCY & RECOVERY} ===${NC}"
    echo -e "${CYAN}panic-bypass${NC}       - ${T_HELP_CMD_PANIC_BYPASS:-Disable protection + auto-rollback}"
    echo -e "${CYAN}panic-restore${NC}      - ${T_HELP_CMD_PANIC_RESTORE:-Restore protected mode}"
    echo -e "${CYAN}panic-status${NC}       - ${T_HELP_CMD_PANIC_STATUS:-Show panic status}"
    echo -e "${CYAN}emergency-refuse${NC}   - ${T_HELP_CMD_EMERGENCY_REFUSE:-Refuse all DNS queries}"
    echo -e "${CYAN}emergency-restore${NC}  - ${T_HELP_CMD_EMERGENCY_RESTORE:-Restore normal operation}"
    echo -e "${CYAN}killswitch-on${NC}      - ${T_HELP_CMD_KILLSWITCH_ON:-Activate DNS kill-switch}"
    echo -e "${CYAN}killswitch-off${NC}     - ${T_HELP_CMD_KILLSWITCH_OFF:-Deactivate kill-switch}"
    echo -e "${CYAN}nft-debug-on${NC}       - ${T_HELP_CMD_NFT_DEBUG_ON:-Enable debug chain}"
    echo -e "${CYAN}nft-debug-off${NC}      - ${T_HELP_CMD_NFT_DEBUG_OFF:-Disable debug chain}"
    echo -e "${CYAN}nft-debug-status${NC}   - ${T_HELP_CMD_NFT_DEBUG_STATUS:-Show debug status}"
    echo -e "${CYAN}nft-debug-logs${NC}     - ${T_HELP_CMD_NFT_DEBUG_LOGS:-Show recent logs}"
}
