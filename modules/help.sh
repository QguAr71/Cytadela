#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ HELP MODULE                                                   ║
# ║  Multi-language help system                                               ║
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
${BLUE}║                  CYTADELA++ v3.1 - Instrukcja                              ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${GREEN}🚀 Instalacja (ZALECANE):${NC}
  ${CYAN}install-wizard${NC}        🎯 Interaktywny instalator z checklistą
  ${CYAN}install-all${NC}           Instaluj wszystkie moduły DNS
  ${CYAN}install-dnscrypt${NC}      Instaluj tylko DNSCrypt-Proxy
  ${CYAN}install-coredns${NC}       Instaluj tylko CoreDNS
  ${CYAN}install-nftables${NC}      Instaluj tylko reguły NFTables

${YELLOW}⚙️  Konfiguracja systemu:${NC}
  ${CYAN}configure-system${NC}      Przełącz system na Citadel++ DNS
  ${CYAN}restore-system${NC}        Przywróć systemd-resolved
  ${CYAN}firewall-safe${NC}         Tryb bezpieczny (nie zrywa internetu)
  ${CYAN}firewall-strict${NC}       Tryb ścisły (pełna blokada DNS-leak)

${RED}🚨 Awaryjne:${NC}
  ${CYAN}panic-bypass [s]${NC}      Wyłącz ochronę + auto-rollback
  ${CYAN}panic-restore${NC}         Przywróć tryb chroniony
  ${CYAN}emergency-refuse${NC}      Odrzuć wszystkie zapytania DNS
  ${CYAN}killswitch-on${NC}         Aktywuj DNS kill-switch
  ${CYAN}killswitch-off${NC}        Dezaktywuj kill-switch

${GREEN}📊 Status i diagnostyka:${NC}
  ${CYAN}status${NC}                Pokaż status usług
  ${CYAN}diagnostics${NC}          Pełna diagnostyka systemu
  ${CYAN}verify${NC}                Weryfikuj cały stack
  ${CYAN}verify-config${NC}         Weryfikacja konfiguracji i DNS
  ${CYAN}verify-config dns${NC}     Tylko test DNS
  ${CYAN}verify-config all${NC}     Wszystkie testy
  ${CYAN}test-all${NC}              Smoke test + leak test
  ${CYAN}ghost-check${NC}           Audyt otwartych portów
  ${CYAN}check-deps${NC}            Sprawdź zależności
  ${CYAN}check-deps --install${NC}  Zainstaluj brakujące (z AUR dla Arch)

${BLUE}🔧 Zarządzanie blocklist:${NC}
  ${CYAN}blocklist-list${NC}        Pokaż dostępne profile
  ${CYAN}blocklist-switch <p>${NC}  Przełącz profil
  ${CYAN}lists-update${NC}          Aktualizuj z LKG fallback
  ${CYAN}lkg-save${NC}              Zapisz blocklist do cache
  ${CYAN}lkg-restore${NC}           Przywróć z cache

${PURPLE}🛡️  Adblock:${NC}
  ${CYAN}adblock-status${NC}        Status adblock
  ${CYAN}adblock-add <dom>${NC}     Dodaj domenę
  ${CYAN}adblock-remove <dom>${NC}  Usuń domenę
  ${CYAN}adblock-query <dom>${NC}   Sprawdź domenę
  ${CYAN}allowlist-add <dom>${NC}   Dodaj do allowlist

${CYAN}🔍 Nowe funkcje v3.1:${NC}
  ${CYAN}smart-ipv6${NC}            Smart IPv6 detection
  ${CYAN}discover${NC}              Network sanity snapshot
  ${CYAN}install-dashboard${NC}     Terminal dashboard
  ${CYAN}cache-stats${NC}           Statystyki DNS cache
  ${CYAN}notify-enable${NC}         Powiadomienia systemowe

${GREEN}📋 Przykładowy workflow:${NC}
  ${YELLOW}1.${NC} sudo cytadela.sh install-all
  ${YELLOW}2.${NC} sudo cytadela.sh firewall-safe
  ${YELLOW}3.${NC} dig +short google.com @127.0.0.1
  ${YELLOW}4.${NC} sudo cytadela.sh configure-system
  ${YELLOW}5.${NC} sudo cytadela.sh firewall-strict

${CYAN}📚 Dokumentacja:${NC}
  GitHub: https://github.com/QguAr71/Cytadela
"
}

# =============================================================================
# ENGLISH HELP
# =============================================================================

show_help_en() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Command Reference                       ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Installation commands (SAFE):${NC}
  install-wizard        🎯 Interactive installer with checklist (RECOMMENDED)
  install-all           Install all DNS modules (does NOT disable systemd-resolved)
  install-dnscrypt      Install DNSCrypt-Proxy only
  install-coredns       Install CoreDNS only
  install-nftables      Install NFTables rules only

${CYAN}DNSSEC (optional):${NC}
  CITADEL_DNSSEC=1       Generate DNSCrypt with require_dnssec = true
  --dnssec               Alternatively: pass flag to install-dnscrypt/install-all

${YELLOW}NEW FEATURES v3.1:${NC}
  smart-ipv6           Smart IPv6 detection & auto-reconfiguration
  ipv6-privacy-on      Enable IPv6 Privacy Extensions (prefer temporary)
  ipv6-privacy-off     Disable IPv6 Privacy Extensions
  ipv6-privacy-status  Show IPv6 Privacy Extensions status
  ipv6-privacy-auto    Auto-ensure IPv6 privacy (detect + fix if needed)
  discover             Network & firewall sanity snapshot
  install-dashboard    Install terminal dashboard (citadel-top)
  install-editor       Install editor integration (citadel edit)
  optimize-kernel      Apply real-time priority for DNS processes
  install-doh-parallel Install DNS-over-HTTPS parallel racing
  fix-ports            Resolve port conflicts with avahi/chromium

${YELLOW}System Configuration (WARNING - disables systemd-resolved):${NC}
  configure-system      Switch system DNS to Citadel++ (with confirmation)
  restore-system        Restore systemd-resolved + DNS (rollback)

${CYAN}Emergency Commands:${NC}
  emergency-refuse      Refuse all DNS queries (emergency mode)
  emergency-restore     Restore normal operation
  killswitch-on         Activate DNS kill-switch (block all non-localhost)
  killswitch-off        Deactivate kill-switch

${RED}Panic Bypass (SPOF recovery):${NC}
  panic-bypass [secs]   Disable protection + auto-rollback (default 300s)
  panic-restore         Manually restore protected mode
  panic-status          Show panic mode status

${YELLOW}LKG (Last Known Good):${NC}
  lkg-save              Save current blocklist to cache
  lkg-restore           Restore blocklist from cache
  lkg-status            Show LKG cache status
  lists-update          Update blocklist with LKG fallback

${YELLOW}Auto-update:${NC}
  auto-update-enable    Enable automatic blocklist updates (daily)
  auto-update-disable   Disable automatic updates
  auto-update-status    Show auto-update status
  auto-update-now       Run update now (manual)
  auto-update-configure Configure frequency (daily/weekly/custom)

${YELLOW}Config Backup/Restore:${NC}
  config-backup         Create configuration backup (tar.gz)
  config-restore <file> Restore configuration from backup
  config-list           Show available backups
  config-delete <file>  Delete backup

${YELLOW}Cache Stats:${NC}
  cache-stats [N]       Show DNS cache statistics (hit rate, latency)
  cache-stats-top [N]   Top N most common domains (default 20)
  cache-stats-reset     Reset statistics (restart CoreDNS)
  cache-stats-watch     Live monitoring (2s refresh)

${YELLOW}Desktop Notifications:${NC}
  notify-enable         Enable desktop notifications
  notify-disable        Disable notifications
  notify-status         Show notification status
  notify-test           Send test notification

${CYAN}Diagnostic Commands:${NC}
  diagnostics           Run full system diagnostics
  status                Show service status
  verify                Verify full stack (ports/services/DNS/NFT/metrics)
  verify-config         Verify configuration and DNS
  verify-config dns     DNS resolution tests only
  verify-config all     All verification checks
  check-deps            Check dependencies
  check-deps --install  Install missing deps (with AUR fallback for Arch)
  ghost-check           Port exposure audit (warn about 0.0.0.0/::)
  ipv6-deep-reset       Flush IPv6 + neighbor cache + reconnect
  test-all              Smoke test (verify + leak test + IPv6)

${GREEN}Health Watchdog:${NC}
  health-status         Show health status (services, DNS probe, firewall)
  health-install        Install auto-restart + health check timer
  health-uninstall      Remove health watchdog

${GREEN}Supply-Chain Verification:${NC}
  supply-chain-status   Show checksums file status
  supply-chain-init     Initialize checksums for known assets
  supply-chain-verify   Verify local files against manifest

${CYAN}Location-Aware Advisory:${NC}
  location-status       Show current SSID, trust status, firewall mode
  location-check        Check and advise on firewall mode
  location-add-trusted  Add SSID to trusted list (or current if no arg)
  location-remove-trusted Remove SSID from trusted list
  location-list-trusted List all trusted SSIDs

${CYAN}NFT Debug Chain:${NC}
  nft-debug-on          Enable debug chain with rate-limited logging
  nft-debug-off         Disable debug chain
  nft-debug-status      Show debug chain status and counters
  nft-debug-logs        Show recent CITADEL log entries

${CYAN}Firewall Modes:${NC}
  firewall-safe         Set SAFE rules (won't break connectivity)
  firewall-strict       Set STRICT rules (blocks DNS leaks)

${GREEN}Recommended workflow:${NC}
  ${CYAN}1.${NC} sudo ./citadel.sh install-all
  ${CYAN}2.${NC} sudo ./citadel.sh firewall-safe         ${YELLOW}# SAFE: won't break connectivity${NC}
  ${CYAN}3.${NC} dig +short google.com @127.0.0.1          ${YELLOW}# Test local DNS${NC}
  ${CYAN}4.${NC} sudo ./citadel.sh configure-system       ${YELLOW}# Switch system DNS${NC}
  ${CYAN}5.${NC} ping -c 3 google.com                      ${YELLOW}# Test connectivity${NC}
  ${CYAN}6.${NC} sudo ./citadel.sh firewall-strict        ${YELLOW}# STRICT: full DNS leak protection${NC}

${CYAN}Documentation:${NC}
  GitHub: https://github.com/QguAr71/Cytadela
"
}

# =============================================================================
# GERMAN HELP
# =============================================================================

show_help_de() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Befehlsreferenz                         ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Installationsbefehle (SICHER):${NC}
  install-wizard        🎯 Interaktiver Installer mit Checkliste (EMPFOHLEN)
  install-all           Alle DNS-Module installieren
  install-dnscrypt      Nur DNSCrypt-Proxy installieren
  install-coredns       Nur CoreDNS installieren
  install-nftables      Nur NFTables-Regeln installieren

${YELLOW}Systemkonfiguration:${NC}
  configure-system      System-DNS auf Citadel++ umstellen
  restore-system        systemd-resolved wiederherstellen
  firewall-safe         SICHERER Modus (unterbricht nicht Internet)
  firewall-strict       STRENGER Modus (blockiert DNS-Leaks)

${RED}Notfall:${NC}
  panic-bypass [s]      Schutz deaktivieren + Auto-Rollback
  panic-restore         Geschützten Modus wiederherstellen
  emergency-refuse      Alle DNS-Anfragen ablehnen
  killswitch-on         DNS-Kill-Switch aktivieren
  killswitch-off        Kill-Switch deaktivieren

${GREEN}Status und Diagnose:${NC}
  status                Dienststatus anzeigen
  diagnostics           Vollständige Systemdiagnose
  verify                Gesamten Stack überprüfen
  verify-config         Konfiguration und DNS überprüfen
  verify-config dns     Nur DNS-Test
  verify-config all     Alle Tests
  check-deps            Abhängigkeiten prüfen
  check-deps --install  Fehlende installieren (mit AUR für Arch)
  ghost-check           Offene Ports auditieren

${BLUE}Blocklist-Verwaltung:${NC}
  blocklist-list        Verfügbare Profile anzeigen
  blocklist-switch <p>  Profil wechseln
  lists-update          Mit LKG-Fallback aktualisieren
  lkg-save              Blocklist in Cache speichern
  lkg-restore           Aus Cache wiederherstellen

${PURPLE}Adblock:${NC}
  adblock-status        Adblock-Status anzeigen
  adblock-add <dom>     Domain hinzufügen
  adblock-remove <dom>  Domain entfernen
  adblock-query <dom>   Domain prüfen

${CYAN}Dokumentation:${NC}
  GitHub: https://github.com/QguAr71/Cytadela
"
}

# =============================================================================
# SPANISH HELP
# =============================================================================

show_help_es() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Referencia de Comandos                  ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Comandos de instalación (SEGURO):${NC}
  install-wizard        🎯 Instalador interactivo con lista de verificación (RECOMENDADO)
  install-all           Instalar todos los módulos DNS
  install-dnscrypt      Instalar solo DNSCrypt-Proxy
  install-coredns       Instalar solo CoreDNS
  install-nftables      Instalar solo reglas NFTables

${YELLOW}Configuración del sistema:${NC}
  configure-system      Cambiar DNS del sistema a Citadel++
  restore-system        Restaurar systemd-resolved
  firewall-safe         Modo SEGURO (no rompe internet)
  firewall-strict       Modo ESTRICTO (bloquea fugas DNS)

${RED}Emergencia:${NC}
  panic-bypass [s]      Desactivar protección + auto-rollback
  panic-restore         Restaurar modo protegido
  emergency-refuse      Rechazar todas las consultas DNS
  killswitch-on         Activar kill-switch DNS
  killswitch-off        Desactivar kill-switch

${GREEN}Estado y diagnóstico:${NC}
  status                Mostrar estado de servicios
  diagnostics           Diagnóstico completo del sistema
  verify                Verificar stack completo
  verify-config         Verificar configuración y DNS
  verify-config dns     Solo prueba DNS
  verify-config all     Todas las pruebas
  check-deps            Verificar dependencias
  check-deps --install  Instalar faltantes (con AUR para Arch)
  ghost-check           Auditar puertos abiertos

${BLUE}Gestión de blocklist:${NC}
  blocklist-list        Mostrar perfiles disponibles
  blocklist-switch <p>  Cambiar perfil
  lists-update          Actualizar con fallback LKG
  lkg-save              Guardar blocklist en caché
  lkg-restore           Restaurar desde caché

${PURPLE}Adblock:${NC}
  adblock-status        Mostrar estado de adblock
  adblock-add <dom>     Agregar dominio
  adblock-remove <dom>  Eliminar dominio
  adblock-query <dom>   Consultar dominio

${CYAN}Documentación:${NC}
  GitHub: https://github.com/QguAr71/Cytadela
"
}

# =============================================================================
# FRENCH HELP
# =============================================================================

show_help_fr() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Référence des Commandes                 ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Commandes d'installation (SÛR):${NC}
  install-wizard        🎯 Installateur interactif avec checklist (RECOMMANDÉ)
  install-all           Installer tous les modules DNS
  install-dnscrypt      Installer uniquement DNSCrypt-Proxy
  install-coredns       Installer uniquement CoreDNS
  install-nftables      Installer uniquement les règles NFTables

${YELLOW}Configuration système:${NC}
  configure-system      Basculer le DNS système sur Citadel++
  restore-system        Restaurer systemd-resolved
  firewall-safe         Mode SÛR (ne coupe pas internet)
  firewall-strict       Mode STRICT (bloque les fuites DNS)

${RED}Urgence:${NC}
  panic-bypass [s]      Désactiver protection + auto-rollback
  panic-restore         Restaurer mode protégé
  emergency-refuse      Refuser toutes les requêtes DNS
  killswitch-on         Activer kill-switch DNS
  killswitch-off        Désactiver kill-switch

${GREEN}Statut et diagnostic:${NC}
  status                Afficher statut des services
  diagnostics           Diagnostic complet du système
  verify                Vérifier stack complet
  verify-config         Vérifier configuration et DNS
  verify-config dns     Test DNS uniquement
  verify-config all     Tous les tests
  check-deps            Vérifier dépendances
  check-deps --install  Installer manquantes (avec AUR pour Arch)
  ghost-check           Auditer ports ouverts

${BLUE}Gestion blocklist:${NC}
  blocklist-list        Afficher profils disponibles
  blocklist-switch <p>  Changer profil
  lists-update          Mettre à jour avec fallback LKG
  lkg-save              Sauvegarder blocklist dans cache
  lkg-restore           Restaurer depuis cache

${PURPLE}Adblock:${NC}
  adblock-status        Afficher statut adblock
  adblock-add <dom>     Ajouter domaine
  adblock-remove <dom>  Supprimer domaine
  adblock-query <dom>   Vérifier domaine

${CYAN}Documentation:${NC}
  GitHub: https://github.com/QguAr71/Cytadela
"
}

# =============================================================================
# ITALIAN HELP
# =============================================================================

show_help_it() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Riferimento Comandi                     ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Comandi di installazione (SICURO):${NC}
  install-wizard        🎯 Installatore interattivo con checklist (CONSIGLIATO)
  install-all           Installa tutti i moduli DNS
  install-dnscrypt      Installa solo DNSCrypt-Proxy
  install-coredns       Installa solo CoreDNS
  install-nftables      Installa solo regole NFTables

${YELLOW}Configurazione sistema:${NC}
  configure-system      Passa DNS di sistema a Citadel++
  restore-system        Ripristina systemd-resolved
  firewall-safe         Modalità SICURA (non interrompe internet)
  firewall-strict       Modalità STRETTA (blocca leak DNS)

${RED}Emergenza:${NC}
  panic-bypass [s]      Disabilita protezione + auto-rollback
  panic-restore         Ripristina modalità protetta
  emergency-refuse      Rifiuta tutte le query DNS
  killswitch-on         Attiva kill-switch DNS
  killswitch-off        Disattiva kill-switch

${GREEN}Stato e diagnostica:${NC}
  status                Mostra stato servizi
  diagnostics           Diagnostica completa sistema
  verify                Verifica stack completo
  verify-config         Verifica configurazione e DNS
  verify-config dns     Solo test DNS
  verify-config all     Tutti i test
  check-deps            Verifica dipendenze
  check-deps --install  Installa mancanti (con AUR per Arch)
  ghost-check           Audita porte aperte

${BLUE}Gestione blocklist:${NC}
  blocklist-list        Mostra profili disponibili
  blocklist-switch <p>  Cambia profilo
  lists-update          Aggiorna con fallback LKG
  lkg-save              Salva blocklist in cache
  lkg-restore           Ripristina da cache

${PURPLE}Adblock:${NC}
  adblock-status        Mostra stato adblock
  adblock-add <dom>     Aggiungi dominio
  adblock-remove <dom>  Rimuovi dominio
  adblock-query <dom>   Controlla dominio

${CYAN}Documentazione:${NC}
  GitHub: https://github.com/QguAr71/Cytadela
"
}

# =============================================================================
# RUSSIAN HELP
# =============================================================================

show_help_ru() {
    echo -e "
${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Справочник Команд                       ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Команды установки (БЕЗОПАСНО):${NC}
  install-wizard        🎯 Интерактивный установщик с чеклистом (РЕКОМЕНДУЕТСЯ)
  install-all           Установить все DNS-модули
  install-dnscrypt      Установить только DNSCrypt-Proxy
  install-coredns       Установить только CoreDNS
  install-nftables      Установить только правила NFTables

${YELLOW}Настройка системы:${NC}
  configure-system      Переключить системный DNS на Citadel++
  restore-system        Восстановить systemd-resolved
  firewall-safe         БЕЗОПАСНЫЙ режим (не разрывает интернет)
  firewall-strict       СТРОГИЙ режим (блокирует утечки DNS)

${RED}Аварийный режим:${NC}
  panic-bypass [s]      Отключить защиту + авто-откат
  panic-restore         Восстановить защищённый режим
  emergency-refuse      Отклонить все DNS-запросы
  killswitch-on         Активировать kill-switch DNS
  killswitch-off        Деактивировать kill-switch

${GREEN}Статус и диагностика:${NC}
  status                Показать статус служб
  diagnostics           Полная диагностика системы
  verify                Проверить весь стек
  verify-config         Проверить конфигурацию и DNS
  verify-config dns     Только тест DNS
  verify-config all     Все тесты
  check-deps            Проверить зависимости
  check-deps --install  Установить недостающие (с AUR для Arch)
  ghost-check           Аудит открытых портов

${BLUE}Управление blocklist:${NC}
  blocklist-list        Показать доступные профили
  blocklist-switch <p>  Переключить профиль
  lists-update          Обновить с LKG fallback
  lkg-save              Сохранить blocklist в кэш
  lkg-restore           Восстановить из кэша

${PURPLE}Adblock:${NC}
  adblock-status        Показать статус adblock
  adblock-add <dom>     Добавить домен
  adblock-remove <dom>  Удалить домен
  adblock-query <dom>   Проверить домен

${CYAN}Документация:${NC}
  GitHub: https://github.com/QguAr71/Cytadela
"
}
