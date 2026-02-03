#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ HELP MODULE                                                   ║
# ║  Multi-language help system with i18n support                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

MODULE_NAME="help"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Multi-language help system for Citadel++"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=()
MODULE_TAGS=("help" "i18n" "documentation")

citadel_help() {
    load_i18n_module "help"
    local lang="${LANG%%_*}"
    lang="${lang:-en}"
    
    case "$lang" in
        pl) show_help_pl ;;
        en) show_help_en ;;
        de) show_help_de ;;
        es) show_help_es ;;
        fr) show_help_fr ;;
        it) show_help_it ;;
        ru) show_help_ru ;;
        *) show_help_en ;;
    esac
}

show_help_en() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║          ${T_HELP_TITLE:-CITADEL++ v3.1 - Command Reference}                              ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${GREEN}${T_HELP_SECTION_INSTALL:-1. INSTALLATION}${NC}
  ${CYAN}install-wizard${NC}        ${T_HELP_CMD_INSTALL_WIZARD:-Interactive installer (RECOMMENDED)}
  ${CYAN}install-all${NC}           ${T_HELP_CMD_INSTALL_ALL:-Install all DNS modules}
  ${CYAN}install-dnscrypt${NC}      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Install DNSCrypt-Proxy only}
  ${CYAN}install-coredns${NC}       ${T_HELP_CMD_INSTALL_COREDNS:-Install CoreDNS only}
  ${CYAN}install-nftables${NC}      ${T_HELP_CMD_INSTALL_NFTABLES:-Install NFTables rules only}

${YELLOW}${T_HELP_SECTION_MAIN:-2. MAIN PROGRAM}${NC}
  ${CYAN}configure-system${NC}      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Switch system DNS to Citadel++}
  ${CYAN}restore-system${NC}        ${T_HELP_CMD_RESTORE_SYSTEM:-Restore systemd-resolved}
  ${CYAN}firewall-safe${NC}         ${T_HELP_CMD_FIREWALL_SAFE:-SAFE mode (won't break connectivity)}
  ${CYAN}firewall-strict${NC}       ${T_HELP_CMD_FIREWALL_STRICT:-STRICT mode (DNS leak protection)}
  ${CYAN}status${NC}                ${T_HELP_CMD_STATUS:-Show service status}
  ${CYAN}diagnostics${NC}          ${T_HELP_CMD_DIAGNOSTICS:-Full system diagnostics}
  ${CYAN}verify${NC}                ${T_HELP_CMD_VERIFY:-Verify full stack}
  ${CYAN}verify-config${NC}         ${T_HELP_CMD_VERIFY_CONFIG:-Verify config and DNS}
  ${CYAN}test-all${NC}              ${T_HELP_CMD_TEST_ALL:-Smoke test + leak test}

${PURPLE}${T_HELP_SECTION_ADDONS:-3. ADD-ONS}${NC}
  ${CYAN}blocklist-list${NC}        ${T_HELP_CMD_BLOCKLIST_LIST:-Show available blocklist profiles}
  ${CYAN}blocklist-switch <p>${NC}  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Switch blocklist profile}
  ${CYAN}adblock-status${NC}        ${T_HELP_CMD_ADBLOCK_STATUS:-Show adblock status}
  ${CYAN}adblock-add <dom>${NC}     ${T_HELP_CMD_ADBLOCK_ADD:-Add domain to adblock}
  ${CYAN}notify-enable${NC}         ${T_HELP_CMD_NOTIFY_ENABLE:-Enable desktop notifications}

${RED}${T_HELP_SECTION_ADVANCED:-4. ADVANCED}${NC}
  ${CYAN}panic-bypass [s]${NC}      ${T_HELP_CMD_PANIC_BYPASS:-Emergency bypass + auto-rollback}
  ${CYAN}lkg-save${NC}              ${T_HELP_CMD_LKG_SAVE:-Save blocklist to cache}
  ${CYAN}lkg-restore${NC}           ${T_HELP_CMD_LKG_RESTORE:-Restore blocklist from cache}
  ${CYAN}auto-update-enable${NC}    ${T_HELP_CMD_AUTO_UPDATE_ENABLE:-Enable automatic updates}
  ${CYAN}cache-stats${NC}           ${T_HELP_CMD_CACHE_STATS:-Show DNS cache statistics}
  ${CYAN}health-install${NC}        ${T_HELP_CMD_HEALTH_INSTALL:-Install health watchdog}

${CYAN}${T_HELP_SECTION_WORKFLOW:-QUICK START}${NC}
  1. ${T_HELP_WORKFLOW_STEP1:-sudo ./citadel.sh install-all}
  2. ${T_HELP_WORKFLOW_STEP2:-sudo ./citadel.sh firewall-safe}
  3. ${T_HELP_WORKFLOW_STEP3:-dig +short google.com @127.0.0.1}
  4. ${T_HELP_WORKFLOW_STEP4:-sudo ./citadel.sh configure-system}

${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

show_help_pl() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║          ${T_HELP_TITLE:-CYTADELA++ v3.1 - Instrukcja}                                    ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${GREEN}${T_HELP_SECTION_INSTALL:-1. INSTALACJA}${NC}
  ${CYAN}install-wizard${NC}        ${T_HELP_CMD_INSTALL_WIZARD:-Interaktywny instalator (ZALECANE)}
  ${CYAN}install-all${NC}           ${T_HELP_CMD_INSTALL_ALL:-Instaluj wszystkie moduły DNS}
  ${CYAN}install-dnscrypt${NC}      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Instaluj tylko DNSCrypt-Proxy}
  ${CYAN}install-coredns${NC}       ${T_HELP_CMD_INSTALL_COREDNS:-Instaluj tylko CoreDNS}
  ${CYAN}install-nftables${NC}      ${T_HELP_CMD_INSTALL_NFTABLES:-Instaluj tylko reguły NFTables}

${YELLOW}${T_HELP_SECTION_MAIN:-2. GŁÓWNY PROGRAM}${NC}
  ${CYAN}configure-system${NC}      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Przełącz system na Citadel++}
  ${CYAN}restore-system${NC}        ${T_HELP_CMD_RESTORE_SYSTEM:-Przywróć systemd-resolved}
  ${CYAN}firewall-safe${NC}         ${T_HELP_CMD_FIREWALL_SAFE:-Tryb BEZPIECZNY}
  ${CYAN}firewall-strict${NC}       ${T_HELP_CMD_FIREWALL_STRICT:-Tryb ŚCISŁY}
  ${CYAN}status${NC}                ${T_HELP_CMD_STATUS:-Pokaż status usług}
  ${CYAN}diagnostics${NC}          ${T_HELP_CMD_DIAGNOSTICS:-Pełna diagnostyka}
  ${CYAN}verify${NC}                ${T_HELP_CMD_VERIFY:-Weryfikuj cały stack}
  ${CYAN}verify-config${NC}         ${T_HELP_CMD_VERIFY_CONFIG:-Weryfikacja konfiguracji}
  ${CYAN}test-all${NC}              ${T_HELP_CMD_TEST_ALL:-Smoke test + leak test}

${PURPLE}${T_HELP_SECTION_ADDONS:-3. DODATKI}${NC}
  ${CYAN}blocklist-list${NC}        ${T_HELP_CMD_BLOCKLIST_LIST:-Pokaż profile blocklist}
  ${CYAN}blocklist-switch <p>${NC}  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Przełącz profil}
  ${CYAN}adblock-status${NC}        ${T_HELP_CMD_ADBLOCK_STATUS:-Status adblock}
  ${CYAN}adblock-add <dom>${NC}     ${T_HELP_CMD_ADBLOCK_ADD:-Dodaj domenę}
  ${CYAN}notify-enable${NC}         ${T_HELP_CMD_NOTIFY_ENABLE:-Włącz powiadomienia}

${RED}${T_HELP_SECTION_ADVANCED:-4. ZAAWANSOWANE}${NC}
  ${CYAN}panic-bypass [s]${NC}      ${T_HELP_CMD_PANIC_BYPASS:-Awaryjny bypass}
  ${CYAN}lkg-save${NC}              ${T_HELP_CMD_LKG_SAVE:-Zapisz blocklist}
  ${CYAN}lkg-restore${NC}           ${T_HELP_CMD_LKG_RESTORE:-Przywróć blocklist}
  ${CYAN}auto-update-enable${NC}    ${T_HELP_CMD_AUTO_UPDATE_ENABLE:-Włącz auto-aktualizacje}
  ${CYAN}cache-stats${NC}           ${T_HELP_CMD_CACHE_STATS:-Statystyki cache}
  ${CYAN}health-install${NC}        ${T_HELP_CMD_HEALTH_INSTALL:-Instaluj health watchdog}

${CYAN}${T_HELP_SECTION_WORKFLOW:-SZYBKI START}${NC}
  1. ${T_HELP_WORKFLOW_STEP1:-sudo ./citadel.sh install-all}
  2. ${T_HELP_WORKFLOW_STEP2:-sudo ./citadel.sh firewall-safe}
  3. ${T_HELP_WORKFLOW_STEP3:-dig +short google.com @127.0.0.1}
  4. ${T_HELP_WORKFLOW_STEP4:-sudo ./citadel.sh configure-system}

${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

show_help_de() { show_help_en; }
show_help_es() { show_help_en; }
show_help_fr() { show_help_en; }
show_help_it() { show_help_en; }
show_help_ru() { show_help_en; }
