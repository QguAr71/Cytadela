#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ HELP MODULE                                                   ║
# ║  Multi-language help system with i18n support                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# =============================================================================
# MODULE METADATA
# =============================================================================

MODULE_NAME="help"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Multi-language help system for Citadel++"
MODULE_AUTHOR="Citadel++ Team"
MODULE_DEPENDS=()
MODULE_TAGS=("help" "i18n" "documentation")

# =============================================================================
# MAIN HELP FUNCTION - Routes to language-specific help
# =============================================================================

citadel_help() {
    # Load i18n for help module
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
        *) show_help_en ;;  # Fallback to English
    esac
}

# =============================================================================
# POLISH HELP
# =============================================================================

show_help_pl() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  ${T_HELP_TITLE:-CYTADELA++ v3.1 - Instrukcja}                              ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${GREEN}${T_HELP_SECTION_INSTALL:-🚀 Instalacja (ZALECANE):}${NC}
  ${CYAN}install-wizard${NC}        🎯 ${T_HELP_CMD_INSTALL_WIZARD:-Interaktywny instalator z checklistą}
  ${CYAN}install-all${NC}           ${T_HELP_CMD_INSTALL_ALL:-Instaluj wszystkie moduły DNS}
  ${CYAN}install-dnscrypt${NC}      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Instaluj tylko DNSCrypt-Proxy}
  ${CYAN}install-coredns${NC}       ${T_HELP_CMD_INSTALL_COREDNS:-Instaluj tylko CoreDNS}
  ${CYAN}install-nftables${NC}      ${T_HELP_CMD_INSTALL_NFTABLES:-Instaluj tylko reguły NFTables}

${YELLOW}${T_HELP_SECTION_CONFIG:-⚙️  Konfiguracja systemu:}${NC}
  ${CYAN}configure-system${NC}      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Przełącz system na Citadel++ DNS}
  ${CYAN}restore-system${NC}        ${T_HELP_CMD_RESTORE_SYSTEM:-Przywróć systemd-resolved}
  ${CYAN}firewall-safe${NC}         ${T_HELP_CMD_FIREWALL_SAFE:-Tryb bezpieczny (nie zrywa internetu)}
  ${CYAN}firewall-strict${NC}       ${T_HELP_CMD_FIREWALL_STRICT:-Tryb ścisły (pełna blokada DNS-leak)}

${RED}${T_HELP_SECTION_EMERGENCY:-🚨 Awaryjne:}${NC}
  ${CYAN}panic-bypass [s]${NC}      ${T_HELP_CMD_PANIC_BYPASS:-Wyłącz ochronę + auto-rollback}
  ${CYAN}panic-restore${NC}         ${T_HELP_CMD_PANIC_RESTORE:-Przywróć tryb chroniony}
  ${CYAN}emergency-refuse${NC}      ${T_HELP_CMD_EMERGENCY_REFUSE:-Odrzuć wszystkie zapytania DNS}
  ${CYAN}killswitch-on${NC}         ${T_HELP_CMD_KILLSWITCH_ON:-Aktywuj DNS kill-switch}
  ${CYAN}killswitch-off${NC}        ${T_HELP_CMD_KILLSWITCH_OFF:-Dezaktywuj kill-switch}

${GREEN}${T_HELP_SECTION_DIAGNOSTICS:-📊 Status i diagnostyka:}${NC}
  ${CYAN}status${NC}                ${T_HELP_CMD_STATUS:-Pokaż status usług}
  ${CYAN}diagnostics${NC}          ${T_HELP_CMD_DIAGNOSTICS:-Pełna diagnostyka systemu}
  ${CYAN}verify${NC}                ${T_HELP_CMD_VERIFY:-Weryfikuj cały stack}
  ${CYAN}verify-config${NC}         ${T_HELP_CMD_VERIFY_CONFIG:-Weryfikacja konfiguracji i DNS}
  ${CYAN}verify-config dns${NC}     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-Tylko test DNS}
  ${CYAN}verify-config all${NC}     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-Wszystkie testy}
  ${CYAN}test-all${NC}              ${T_HELP_CMD_TEST_ALL:-Smoke test + leak test}
  ${CYAN}ghost-check${NC}           ${T_HELP_CMD_GHOST_CHECK:-Audyt otwartych portów}
  ${CYAN}check-deps${NC}            ${T_HELP_CMD_CHECK_DEPS:-Sprawdź zależności}
  ${CYAN}check-deps --install${NC}  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Zainstaluj brakujące (z AUR dla Arch)}

${BLUE}${T_HELP_SECTION_BLOCKLIST:-🔧 Zarządzanie blocklist:}${NC}
  ${CYAN}blocklist-list${NC}        ${T_HELP_CMD_BLOCKLIST_LIST:-Pokaż dostępne profile}
  ${CYAN}blocklist-switch <p>${NC}  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Przełącz profil}
  ${CYAN}lists-update${NC}          ${T_HELP_CMD_LISTS_UPDATE:-Aktualizuj z LKG fallback}
  ${CYAN}lkg-save${NC}              ${T_HELP_CMD_LKG_SAVE:-Zapisz blocklist do cache}
  ${CYAN}lkg-restore${NC}           ${T_HELP_CMD_LKG_RESTORE:-Przywróć z cache}

${PURPLE}${T_HELP_SECTION_ADBLOCK:-🛡️  Adblock:}${NC}
  ${CYAN}adblock-status${NC}        ${T_HELP_CMD_ADBLOCK_STATUS:-Status adblock}
  ${CYAN}adblock-add <dom>${NC}     ${T_HELP_CMD_ADBLOCK_ADD:-Dodaj domenę}
  ${CYAN}adblock-remove <dom>${NC}  ${T_HELP_CMD_ADBLOCK_REMOVE:-Usuń domenę}
  ${CYAN}adblock-query <dom>${NC}   ${T_HELP_CMD_ADBLOCK_QUERY:-Sprawdź domenę}
  ${CYAN}allowlist-add <dom>${NC}   ${T_HELP_CMD_ALLOWLIST_ADD:-Dodaj do allowlist}

${CYAN}${T_HELP_SECTION_NEW:-🔍 Nowe funkcje v3.1:}${NC}
  ${CYAN}smart-ipv6${NC}            ${T_HELP_CMD_SMART_IPV6:-Smart IPv6 detection}
  ${CYAN}discover${NC}              ${T_HELP_CMD_DISCOVER:-Network sanity snapshot}
  ${CYAN}install-dashboard${NC}     ${T_HELP_CMD_INSTALL_DASHBOARD:-Terminal dashboard}
  ${CYAN}cache-stats${NC}           ${T_HELP_CMD_CACHE_STATS:-Statystyki DNS cache}
  ${CYAN}notify-enable${NC}         ${T_HELP_CMD_NOTIFY_ENABLE:-Powiadomienia systemowe}

${GREEN}${T_HELP_SECTION_WORKFLOW:-📋 Przykładowy workflow:}${NC}
  ${YELLOW}1.${NC} ${T_HELP_WORKFLOW_STEP1:-sudo cytadela.sh install-all}
  ${YELLOW}2.${NC} ${T_HELP_WORKFLOW_STEP2:-sudo cytadela.sh firewall-safe}
  ${YELLOW}3.${NC} ${T_HELP_WORKFLOW_STEP3:-dig +short google.com @127.0.0.1}
  ${YELLOW}4.${NC} ${T_HELP_WORKFLOW_STEP4:-sudo cytadela.sh configure-system}
  ${YELLOW}5.${NC} ${T_HELP_WORKFLOW_STEP5:-sudo cytadela.sh firewall-strict}

${CYAN}${T_HELP_SECTION_DOCS:-📚 Dokumentacja:}${NC}
  ${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

# =============================================================================
# ENGLISH HELP
# =============================================================================

show_help_en() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  ${T_HELP_TITLE:-CITADEL++ v3.1 - Command Reference}                       ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}${T_HELP_SECTION_INSTALL:-Installation commands (SAFE):}${NC}
  install-wizard        🎯 ${T_HELP_CMD_INSTALL_WIZARD:-Interactive installer with checklist (RECOMMENDED)}
  install-all           ${T_HELP_CMD_INSTALL_ALL:-Install all DNS modules (does NOT disable systemd-resolved)}
  install-dnscrypt      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Install DNSCrypt-Proxy only}
  install-coredns       ${T_HELP_CMD_INSTALL_COREDNS:-Install CoreDNS only}
  install-nftables      ${T_HELP_CMD_INSTALL_NFTABLES:-Install NFTables rules only}

${YELLOW}${T_HELP_SECTION_CONFIG:-System Configuration (WARNING - disables systemd-resolved):}${NC}
  configure-system      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Switch system DNS to Citadel++ (with confirmation)}
  restore-system        ${T_HELP_CMD_RESTORE_SYSTEM:-Restore systemd-resolved + DNS (rollback)}
  firewall-safe         ${T_HELP_CMD_FIREWALL_SAFE:-Set SAFE rules (won't break connectivity)}
  firewall-strict       ${T_HELP_CMD_FIREWALL_STRICT:-Set STRICT rules (blocks DNS leaks)}

${RED}${T_HELP_SECTION_EMERGENCY:-Emergency Commands:}${NC}
  emergency-refuse      ${T_HELP_CMD_EMERGENCY_REFUSE:-Refuse all DNS queries (emergency mode)}
  emergency-restore     ${T_HELP_CMD_EMERGENCY_RESTORE:-Restore normal operation}
  killswitch-on         ${T_HELP_CMD_KILLSWITCH_ON:-Activate DNS kill-switch (block all non-localhost)}
  killswitch-off        ${T_HELP_CMD_KILLSWITCH_OFF:-Deactivate kill-switch}

${RED}Panic Bypass (SPOF recovery):${NC}
  panic-bypass [secs]   ${T_HELP_CMD_PANIC_BYPASS:-Disable protection + auto-rollback (default 300s)}
  panic-restore         ${T_HELP_CMD_PANIC_RESTORE:-Manually restore protected mode}
  panic-status          ${T_HELP_CMD_PANIC_STATUS:-Show panic mode status}

${YELLOW}${T_HELP_SECTION_DIAGNOSTICS:-Diagnostic Commands:}${NC}
  diagnostics           ${T_HELP_CMD_DIAGNOSTICS:-Run full system diagnostics}
  status                ${T_HELP_CMD_STATUS:-Show service status}
  verify                ${T_HELP_CMD_VERIFY:-Verify full stack (ports/services/DNS/NFT/metrics)}
  verify-config         ${T_HELP_CMD_VERIFY_CONFIG:-Verify configuration and DNS}
  verify-config dns     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-DNS resolution tests only}
  verify-config all     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-All verification checks}
  check-deps            ${T_HELP_CMD_CHECK_DEPS:-Check dependencies}
  check-deps --install  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Install missing deps (with AUR fallback for Arch)}
  ghost-check           ${T_HELP_CMD_GHOST_CHECK:-Port exposure audit (warn about 0.0.0.0/::)}
  test-all              ${T_HELP_CMD_TEST_ALL:-Smoke test (verify + leak test + IPv6)}

${BLUE}${T_HELP_SECTION_BLOCKLIST:-Blocklist Management:}${NC}
  blocklist-list        ${T_HELP_CMD_BLOCKLIST_LIST:-Show available profiles}
  blocklist-switch <p>  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Switch profile}
  lists-update          ${T_HELP_CMD_LISTS_UPDATE:-Update blocklist with LKG fallback}
  lkg-save              ${T_HELP_CMD_LKG_SAVE:-Save current blocklist to cache}
  lkg-restore           ${T_HELP_CMD_LKG_RESTORE:-Restore blocklist from cache}

${PURPLE}${T_HELP_SECTION_ADBLOCK:-Adblock:}${NC}
  adblock-status        ${T_HELP_CMD_ADBLOCK_STATUS:-Show adblock status}
  adblock-add <dom>     ${T_HELP_CMD_ADBLOCK_ADD:-Add domain}
  adblock-remove <dom>  ${T_HELP_CMD_ADBLOCK_REMOVE:-Remove domain}
  adblock-query <dom>   ${T_HELP_CMD_ADBLOCK_QUERY:-Check domain}

${CYAN}${T_HELP_SECTION_NEW:-NEW FEATURES v3.1:}${NC}
  smart-ipv6            ${T_HELP_CMD_SMART_IPV6:-Smart IPv6 detection & auto-reconfiguration}
  discover              ${T_HELP_CMD_DISCOVER:-Network & firewall sanity snapshot}
  install-dashboard     ${T_HELP_CMD_INSTALL_DASHBOARD:-Install terminal dashboard (citadel-top)}
  cache-stats           ${T_HELP_CMD_CACHE_STATS:-Show DNS cache statistics}
  notify-enable         ${T_HELP_CMD_NOTIFY_ENABLE:-Enable desktop notifications}

${GREEN}${T_HELP_SECTION_WORKFLOW:-Recommended workflow:}${NC}
  ${CYAN}1.${NC} ${T_HELP_WORKFLOW_STEP1:-sudo ./citadel.sh install-all}
  ${CYAN}2.${NC} ${T_HELP_WORKFLOW_STEP2:-sudo ./citadel.sh firewall-safe}
  ${CYAN}3.${NC} ${T_HELP_WORKFLOW_STEP3:-dig +short google.com @127.0.0.1}
  ${CYAN}4.${NC} ${T_HELP_WORKFLOW_STEP4:-sudo ./citadel.sh configure-system}
  ${CYAN}5.${NC} ${T_HELP_WORKFLOW_STEP5:-ping -c 3 google.com}
  ${CYAN}6.${NC} ${T_HELP_WORKFLOW_STEP6:-sudo ./citadel.sh firewall-strict}

${CYAN}${T_HELP_SECTION_DOCS:-Documentation:}${NC}
  ${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

# =============================================================================
# GERMAN HELP
# =============================================================================

show_help_de() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  ${T_HELP_TITLE:-CITADEL++ v3.1 - Befehlsreferenz}                         ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}${T_HELP_SECTION_INSTALL:-Installationsbefehle (SICHER):}${NC}
  install-wizard        🎯 ${T_HELP_CMD_INSTALL_WIZARD:-Interaktiver Installer mit Checkliste (EMPFOHLEN)}
  install-all           ${T_HELP_CMD_INSTALL_ALL:-Alle DNS-Module installieren}
  install-dnscrypt      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Nur DNSCrypt-Proxy installieren}
  install-coredns       ${T_HELP_CMD_INSTALL_COREDNS:-Nur CoreDNS installieren}
  install-nftables      ${T_HELP_CMD_INSTALL_NFTABLES:-Nur NFTables-Regeln installieren}

${YELLOW}${T_HELP_SECTION_CONFIG:-Systemkonfiguration:}${NC}
  configure-system      ${T_HELP_CMD_CONFIGURE_SYSTEM:-System-DNS auf Citadel++ umstellen}
  restore-system        ${T_HELP_CMD_RESTORE_SYSTEM:-systemd-resolved wiederherstellen}
  firewall-safe         ${T_HELP_CMD_FIREWALL_SAFE:-SICHERER Modus (unterbricht nicht Internet)}
  firewall-strict       ${T_HELP_CMD_FIREWALL_STRICT:-STRENGER Modus (blockiert DNS-Leaks)}

${RED}${T_HELP_SECTION_EMERGENCY:-Notfall:}${NC}
  panic-bypass [s]      ${T_HELP_CMD_PANIC_BYPASS:-Schutz deaktivieren + Auto-Rollback}
  panic-restore         ${T_HELP_CMD_PANIC_RESTORE:-Geschützten Modus wiederherstellen}
  emergency-refuse      ${T_HELP_CMD_EMERGENCY_REFUSE:-Alle DNS-Anfragen ablehnen}
  killswitch-on         ${T_HELP_CMD_KILLSWITCH_ON:-DNS-Kill-Switch aktivieren}
  killswitch-off        ${T_HELP_CMD_KILLSWITCH_OFF:-Kill-Switch deaktivieren}

${GREEN}${T_HELP_SECTION_DIAGNOSTICS:-Status und Diagnose:}${NC}
  status                ${T_HELP_CMD_STATUS:-Dienststatus anzeigen}
  diagnostics           ${T_HELP_CMD_DIAGNOSTICS:-Vollständige Systemdiagnose}
  verify                ${T_HELP_CMD_VERIFY:-Gesamten Stack überprüfen}
  verify-config         ${T_HELP_CMD_VERIFY_CONFIG:-Konfiguration und DNS überprüfen}
  verify-config dns     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-Nur DNS-Test}
  verify-config all     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-Alle Tests}
  check-deps            ${T_HELP_CMD_CHECK_DEPS:-Abhängigkeiten prüfen}
  check-deps --install  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Fehlende installieren (mit AUR für Arch)}
  ghost-check           ${T_HELP_CMD_GHOST_CHECK:-Offene Ports auditieren}

${BLUE}${T_HELP_SECTION_BLOCKLIST:-Blocklist-Verwaltung:}${NC}
  blocklist-list        ${T_HELP_CMD_BLOCKLIST_LIST:-Verfügbare Profile anzeigen}
  blocklist-switch <p>  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Profil wechseln}
  lists-update          ${T_HELP_CMD_LISTS_UPDATE:-Mit LKG-Fallback aktualisieren}
  lkg-save              ${T_HELP_CMD_LKG_SAVE:-Blocklist in Cache speichern}
  lkg-restore           ${T_HELP_CMD_LKG_RESTORE:-Aus Cache wiederherstellen}

${PURPLE}${T_HELP_SECTION_ADBLOCK:-Adblock:}${NC}
  adblock-status        ${T_HELP_CMD_ADBLOCK_STATUS:-Adblock-Status anzeigen}
  adblock-add <dom>     ${T_HELP_CMD_ADBLOCK_ADD:-Domain hinzufügen}
  adblock-remove <dom>  ${T_HELP_CMD_ADBLOCK_REMOVE:-Domain entfernen}
  adblock-query <dom>   ${T_HELP_CMD_ADBLOCK_QUERY:-Domain prüfen}

${CYAN}${T_HELP_SECTION_DOCS:-Dokumentation:}${NC}
  ${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

# =============================================================================
# SPANISH HELP
# =============================================================================

show_help_es() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  ${T_HELP_TITLE:-CITADEL++ v3.1 - Referencia de Comandos}                  ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}${T_HELP_SECTION_INSTALL:-Comandos de instalación (SEGURO):}${NC}
  install-wizard        🎯 ${T_HELP_CMD_INSTALL_WIZARD:-Instalador interactivo con lista de verificación (RECOMENDADO)}
  install-all           ${T_HELP_CMD_INSTALL_ALL:-Instalar todos los módulos DNS}
  install-dnscrypt      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Instalar solo DNSCrypt-Proxy}
  install-coredns       ${T_HELP_CMD_INSTALL_COREDNS:-Instalar solo CoreDNS}
  install-nftables      ${T_HELP_CMD_INSTALL_NFTABLES:-Instalar solo reglas NFTables}

${YELLOW}${T_HELP_SECTION_CONFIG:-Configuración del sistema:}${NC}
  configure-system      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Cambiar DNS del sistema a Citadel++}
  restore-system        ${T_HELP_CMD_RESTORE_SYSTEM:-Restaurar systemd-resolved}
  firewall-safe         ${T_HELP_CMD_FIREWALL_SAFE:-Modo SEGURO (no rompe internet)}
  firewall-strict       ${T_HELP_CMD_FIREWALL_STRICT:-Modo ESTRICTO (bloquea fugas DNS)}

${RED}${T_HELP_SECTION_EMERGENCY:-Emergencia:}${NC}
  panic-bypass [s]      ${T_HELP_CMD_PANIC_BYPASS:-Desactivar protección + auto-rollback}
  panic-restore         ${T_HELP_CMD_PANIC_RESTORE:-Restaurar modo protegido}
  emergency-refuse      ${T_HELP_CMD_EMERGENCY_REFUSE:-Rechazar todas las consultas DNS}
  killswitch-on         ${T_HELP_CMD_KILLSWITCH_ON:-Activar kill-switch DNS}
  killswitch-off        ${T_HELP_CMD_KILLSWITCH_OFF:-Desactivar kill-switch}

${GREEN}${T_HELP_SECTION_DIAGNOSTICS:-Estado y diagnóstico:}${NC}
  status                ${T_HELP_CMD_STATUS:-Mostrar estado de servicios}
  diagnostics           ${T_HELP_CMD_DIAGNOSTICS:-Diagnóstico completo del sistema}
  verify                ${T_HELP_CMD_VERIFY:-Verificar stack completo}
  verify-config         ${T_HELP_CMD_VERIFY_CONFIG:-Verificar configuración y DNS}
  verify-config dns     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-Solo prueba DNS}
  verify-config all     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-Todas las pruebas}
  check-deps            ${T_HELP_CMD_CHECK_DEPS:-Verificar dependencias}
  check-deps --install  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Instalar faltantes (con AUR para Arch)}
  ghost-check           ${T_HELP_CMD_GHOST_CHECK:-Auditar puertos abiertos}

${BLUE}${T_HELP_SECTION_BLOCKLIST:-Gestión de blocklist:}${NC}
  blocklist-list        ${T_HELP_CMD_BLOCKLIST_LIST:-Mostrar perfiles disponibles}
  blocklist-switch <p>  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Cambiar perfil}
  lists-update          ${T_HELP_CMD_LISTS_UPDATE:-Actualizar con fallback LKG}
  lkg-save              ${T_HELP_CMD_LKG_SAVE:-Guardar blocklist en caché}
  lkg-restore           ${T_HELP_CMD_LKG_RESTORE:-Restaurar desde caché}

${PURPLE}${T_HELP_SECTION_ADBLOCK:-Adblock:}${NC}
  adblock-status        ${T_HELP_CMD_ADBLOCK_STATUS:-Mostrar estado de adblock}
  adblock-add <dom>     ${T_HELP_CMD_ADBLOCK_ADD:-Agregar dominio}
  adblock-remove <dom>  ${T_HELP_CMD_ADBLOCK_REMOVE:-Eliminar dominio}
  adblock-query <dom>   ${T_HELP_CMD_ADBLOCK_QUERY:-Consultar dominio}

${CYAN}${T_HELP_SECTION_DOCS:-Documentación:}${NC}
  ${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

# =============================================================================
# FRENCH HELP
# =============================================================================

show_help_fr() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  ${T_HELP_TITLE:-CITADEL++ v3.1 - Référence des Commandes}                 ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}${T_HELP_SECTION_INSTALL:-Commandes d'installation (SÛR):}${NC}
  install-wizard        🎯 ${T_HELP_CMD_INSTALL_WIZARD:-Installateur interactif avec checklist (RECOMMANDÉ)}
  install-all           ${T_HELP_CMD_INSTALL_ALL:-Installer tous les modules DNS}
  install-dnscrypt      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Installer uniquement DNSCrypt-Proxy}
  install-coredns       ${T_HELP_CMD_INSTALL_COREDNS:-Installer uniquement CoreDNS}
  install-nftables      ${T_HELP_CMD_INSTALL_NFTABLES:-Installer uniquement les règles NFTables}

${YELLOW}${T_HELP_SECTION_CONFIG:-Configuration système:}${NC}
  configure-system      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Basculer le DNS système sur Citadel++}
  restore-system        ${T_HELP_CMD_RESTORE_SYSTEM:-Restaurer systemd-resolved}
  firewall-safe         ${T_HELP_CMD_FIREWALL_SAFE:-Mode SÛR (ne coupe pas internet)}
  firewall-strict       ${T_HELP_CMD_FIREWALL_STRICT:-Mode STRICT (bloque les fuites DNS)}

${RED}${T_HELP_SECTION_EMERGENCY:-Urgence:}${NC}
  panic-bypass [s]      ${T_HELP_CMD_PANIC_BYPASS:-Désactiver protection + auto-rollback}
  panic-restore         ${T_HELP_CMD_PANIC_RESTORE:-Restaurer mode protégé}
  emergency-refuse      ${T_HELP_CMD_EMERGENCY_REFUSE:-Refuser toutes les requêtes DNS}
  killswitch-on         ${T_HELP_CMD_KILLSWITCH_ON:-Activer kill-switch DNS}
  killswitch-off        ${T_HELP_CMD_KILLSWITCH_OFF:-Désactiver kill-switch}

${GREEN}${T_HELP_SECTION_DIAGNOSTICS:-Statut et diagnostic:}${NC}
  status                ${T_HELP_CMD_STATUS:-Afficher statut des services}
  diagnostics           ${T_HELP_CMD_DIAGNOSTICS:-Diagnostic complet du système}
  verify                ${T_HELP_CMD_VERIFY:-Vérifier stack complet}
  verify-config         ${T_HELP_CMD_VERIFY_CONFIG:-Vérifier configuration et DNS}
  verify-config dns     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-Test DNS uniquement}
  verify-config all     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-Tous les tests}
  check-deps            ${T_HELP_CMD_CHECK_DEPS:-Vérifier dépendances}
  check-deps --install  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Installer manquantes (avec AUR pour Arch)}
  ghost-check           ${T_HELP_CMD_GHOST_CHECK:-Auditer ports ouverts}

${BLUE}${T_HELP_SECTION_BLOCKLIST:-Gestion blocklist:}${NC}
  blocklist-list        ${T_HELP_CMD_BLOCKLIST_LIST:-Afficher profils disponibles}
  blocklist-switch <p>  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Changer profil}
  lists-update          ${T_HELP_CMD_LISTS_UPDATE:-Mettre à jour avec fallback LKG}
  lkg-save              ${T_HELP_CMD_LKG_SAVE:-Sauvegarder blocklist dans cache}
  lkg-restore           ${T_HELP_CMD_LKG_RESTORE:-Restaurer depuis cache}

${PURPLE}${T_HELP_SECTION_ADBLOCK:-Adblock:}${NC}
  adblock-status        ${T_HELP_CMD_ADBLOCK_STATUS:-Afficher statut adblock}
  adblock-add <dom>     ${T_HELP_CMD_ADBLOCK_ADD:-Ajouter domaine}
  adblock-remove <dom>  ${T_HELP_CMD_ADBLOCK_REMOVE:-Supprimer domaine}
  adblock-query <dom>   ${T_HELP_CMD_ADBLOCK_QUERY:-Vérifier domaine}

${CYAN}${T_HELP_SECTION_DOCS:-Documentation:}${NC}
  ${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

# =============================================================================
# ITALIAN HELP
# =============================================================================

show_help_it() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  ${T_HELP_TITLE:-CITADEL++ v3.1 - Riferimento Comandi}                     ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}${T_HELP_SECTION_INSTALL:-Comandi di installazione (SICURO):}${NC}
  install-wizard        🎯 ${T_HELP_CMD_INSTALL_WIZARD:-Installatore interattivo con checklist (CONSIGLIATO)}
  install-all           ${T_HELP_CMD_INSTALL_ALL:-Installa tutti i moduli DNS}
  install-dnscrypt      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Installa solo DNSCrypt-Proxy}
  install-coredns       ${T_HELP_CMD_INSTALL_COREDNS:-Installa solo CoreDNS}
  install-nftables      ${T_HELP_CMD_INSTALL_NFTABLES:-Installa solo regole NFTables}

${YELLOW}${T_HELP_SECTION_CONFIG:-Configurazione sistema:}${NC}
  configure-system      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Passa DNS di sistema a Citadel++}
  restore-system        ${T_HELP_CMD_RESTORE_SYSTEM:-Ripristina systemd-resolved}
  firewall-safe         ${T_HELP_CMD_FIREWALL_SAFE:-Modalità SICURA (non interrompe internet)}
  firewall-strict       ${T_HELP_CMD_FIREWALL_STRICT:-Modalità STRETTA (blocca leak DNS)}

${RED}${T_HELP_SECTION_EMERGENCY:-Emergenza:}${NC}
  panic-bypass [s]      ${T_HELP_CMD_PANIC_BYPASS:-Disabilita protezione + auto-rollback}
  panic-restore         ${T_HELP_CMD_PANIC_RESTORE:-Ripristina modalità protetta}
  emergency-refuse      ${T_HELP_CMD_EMERGENCY_REFUSE:-Rifiuta tutte le query DNS}
  killswitch-on         ${T_HELP_CMD_KILLSWITCH_ON:-Attiva kill-switch DNS}
  killswitch-off        ${T_HELP_CMD_KILLSWITCH_OFF:-Disattiva kill-switch}

${GREEN}${T_HELP_SECTION_DIAGNOSTICS:-Stato e diagnostica:}${NC}
  status                ${T_HELP_CMD_STATUS:-Mostra stato servizi}
  diagnostics           ${T_HELP_CMD_DIAGNOSTICS:-Diagnostica completa sistema}
  verify                ${T_HELP_CMD_VERIFY:-Verifica stack completo}
  verify-config         ${T_HELP_CMD_VERIFY_CONFIG:-Verifica configurazione e DNS}
  verify-config dns     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-Solo test DNS}
  verify-config all     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-Tutti i test}
  check-deps            ${T_HELP_CMD_CHECK_DEPS:-Verifica dipendenze}
  check-deps --install  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Installa mancanti (con AUR per Arch)}
  ghost-check           ${T_HELP_CMD_GHOST_CHECK:-Audita porte aperte}

${BLUE}${T_HELP_SECTION_BLOCKLIST:-Gestione blocklist:}${NC}
  blocklist-list        ${T_HELP_CMD_BLOCKLIST_LIST:-Mostra profili disponibili}
  blocklist-switch <p>  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Cambia profilo}
  lists-update          ${T_HELP_CMD_LISTS_UPDATE:-Aggiorna con fallback LKG}
  lkg-save              ${T_HELP_CMD_LKG_SAVE:-Salva blocklist in cache}
  lkg-restore           ${T_HELP_CMD_LKG_RESTORE:-Ripristina da cache}

${PURPLE}${T_HELP_SECTION_ADBLOCK:-Adblock:}${NC}
  adblock-status        ${T_HELP_CMD_ADBLOCK_STATUS:-Mostra stato adblock}
  adblock-add <dom>     ${T_HELP_CMD_ADBLOCK_ADD:-Aggiungi dominio}
  adblock-remove <dom>  ${T_HELP_CMD_ADBLOCK_REMOVE:-Rimuovi dominio}
  adblock-query <dom>   ${T_HELP_CMD_ADBLOCK_QUERY:-Controlla dominio}

${CYAN}${T_HELP_SECTION_DOCS:-Documentazione:}${NC}
  ${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}

# =============================================================================
# RUSSIAN HELP
# =============================================================================

show_help_ru() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  ${T_HELP_TITLE:-CITADEL++ v3.1 - Справочник Команд}                       ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}${T_HELP_SECTION_INSTALL:-Команды установки (БЕЗОПАСНО):}${NC}
  install-wizard        🎯 ${T_HELP_CMD_INSTALL_WIZARD:-Интерактивный установщик с чеклистом (РЕКОМЕНДУЕТСЯ)}
  install-all           ${T_HELP_CMD_INSTALL_ALL:-Установить все DNS-модули}
  install-dnscrypt      ${T_HELP_CMD_INSTALL_DNSCRYPT:-Установить только DNSCrypt-Proxy}
  install-coredns       ${T_HELP_CMD_INSTALL_COREDNS:-Установить только CoreDNS}
  install-nftables      ${T_HELP_CMD_INSTALL_NFTABLES:-Установить только правила NFTables}

${YELLOW}${T_HELP_SECTION_CONFIG:-Настройка системы:}${NC}
  configure-system      ${T_HELP_CMD_CONFIGURE_SYSTEM:-Переключить системный DNS на Citadel++}
  restore-system        ${T_HELP_CMD_RESTORE_SYSTEM:-Восстановить systemd-resolved}
  firewall-safe         ${T_HELP_CMD_FIREWALL_SAFE:-БЕЗОПАСНЫЙ режим (не разрывает интернет)}
  firewall-strict       ${T_HELP_CMD_FIREWALL_STRICT:-СТРОГИЙ режим (блокирует утечки DNS)}

${RED}${T_HELP_SECTION_EMERGENCY:-Аварийный режим:}${NC}
  panic-bypass [s]      ${T_HELP_CMD_PANIC_BYPASS:-Отключить защиту + авто-откат}
  panic-restore         ${T_HELP_CMD_PANIC_RESTORE:-Восстановить защищённый режим}
  emergency-refuse      ${T_HELP_CMD_EMERGENCY_REFUSE:-Отклонить все DNS-запросы}
  killswitch-on         ${T_HELP_CMD_KILLSWITCH_ON:-Активировать kill-switch DNS}
  killswitch-off        ${T_HELP_CMD_KILLSWITCH_OFF:-Деактивировать kill-switch}

${GREEN}${T_HELP_SECTION_DIAGNOSTICS:-Статус и диагностика:}${NC}
  status                ${T_HELP_CMD_STATUS:-Показать статус служб}
  diagnostics           ${T_HELP_CMD_DIAGNOSTICS:-Полная диагностика системы}
  verify                ${T_HELP_CMD_VERIFY:-Проверить весь стек}
  verify-config         ${T_HELP_CMD_VERIFY_CONFIG:-Проверить конфигурацию и DNS}
  verify-config dns     ${T_HELP_CMD_VERIFY_CONFIG_DNS:-Только тест DNS}
  verify-config all     ${T_HELP_CMD_VERIFY_CONFIG_ALL:-Все тесты}
  check-deps            ${T_HELP_CMD_CHECK_DEPS:-Проверить зависимости}
  check-deps --install  ${T_HELP_CMD_CHECK_DEPS_INSTALL:-Установить недостающие (с AUR для Arch)}
  ghost-check           ${T_HELP_CMD_GHOST_CHECK:-Аудит открытых портов}

${BLUE}${T_HELP_SECTION_BLOCKLIST:-Управление blocklist:}${NC}
  blocklist-list        ${T_HELP_CMD_BLOCKLIST_LIST:-Показать доступные профили}
  blocklist-switch <p>  ${T_HELP_CMD_BLOCKLIST_SWITCH:-Переключить профиль}
  lists-update          ${T_HELP_CMD_LISTS_UPDATE:-Обновить с LKG fallback}
  lkg-save              ${T_HELP_CMD_LKG_SAVE:-Сохранить blocklist в кэш}
  lkg-restore           ${T_HELP_CMD_LKG_RESTORE:-Восстановить из кэша}

${PURPLE}${T_HELP_SECTION_ADBLOCK:-Adblock:}${NC}
  adblock-status        ${T_HELP_CMD_ADBLOCK_STATUS:-Показать статус adblock}
  adblock-add <dom>     ${T_HELP_CMD_ADBLOCK_ADD:-Добавить домен}
  adblock-remove <dom>  ${T_HELP_CMD_ADBLOCK_REMOVE:-Удалить домен}
  adblock-query <dom>   ${T_HELP_CMD_ADBLOCK_QUERY:-Проверить домен}

${CYAN}${T_HELP_SECTION_DOCS:-Документация:}${NC}
  ${T_HELP_GITHUB:-GitHub: https://github.com/QguAr71/Cytadela}
"
}
