#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Polskie Tłumaczenia (PL)                                    ║
# ║  Install Wizard i18n strings                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Legacy support: source colors if not already loaded
if [[ -z "${BLUE:-}" ]]; then
    source "$(dirname "$(dirname "${BASH_SOURCE[0]}")")/cytadela-core.sh"
fi

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
  ${CYAN}test-all${NC}              Smoke test + leak test
  ${CYAN}ghost-check${NC}           Audyt otwartych portów

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

# Tytuły kreatora
export T_WIZARD_TITLE="INTERAKTYWNY KREATOR INSTALACJI"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Kreator Instalacji"

# Komunikaty dialogowe
export T_SELECT_MODULES="Wybierz moduły do instalacji:"
export T_DIALOG_HELP="(SPACJA - zaznacz/odznacz, TAB - nawigacja, ENTER - potwierdź)"
export T_REQUIRED_NOTE="Moduły wymagane są wstępnie zaznaczone i nie można ich wyłączyć."

# Opisy modułów
export T_MOD_DNSCRYPT="Szyfrowany resolver DNS (DNSCrypt/DoH)"
export T_MOD_COREDNS="Lokalny serwer DNS z adblockiem i cache"
export T_MOD_NFTABLES="Reguły firewall (ochrona przed DNS leak)"
export T_MOD_HEALTH="Auto-restart usług przy awarii"
export T_MOD_SUPPLY="Weryfikacja binariów (sumy kontrolne)"
export T_MOD_LKG="Cache Last Known Good dla blocklist"
export T_MOD_IPV6="Zarządzanie rozszerzeniami prywatności IPv6"
export T_MOD_LOCATION="Firewall zależny od SSID"
export T_MOD_DEBUG="Łańcuch debug NFTables z logowaniem"

# Sekcja podsumowania
export T_SUMMARY_TITLE="PODSUMOWANIE INSTALACJI"
export T_SELECTED_MODULES="Wybrane moduły:"
export T_CONFIRM_WARNING="To zainstaluje i skonfiguruje usługi DNS w Twoim systemie."
export T_CONFIRM_PROMPT="Kontynuować instalację? [t/N]: "

# Sekcja instalacji
export T_INSTALLING_TITLE="INSTALOWANIE MODUŁÓW"
export T_INSTALLING="Instalowanie"
export T_INSTALLED="zainstalowany"
export T_FAILED="instalacja nie powiodła się"
export T_INITIALIZED="zainicjalizowany"
export T_INIT_FAILED="inicjalizacja nie powiodła się"
export T_CACHE_SAVED="cache zapisany"
export T_CACHE_NOT_SAVED="cache nie zapisany (zostanie utworzony przy pierwszej aktualizacji)"
export T_CONFIGURED="skonfigurowany"
export T_CONFIG_SKIPPED="konfiguracja pominięta"
export T_MODULE_LOADED="moduł załadowany"
export T_USE_COMMAND="użyj"
export T_TO_ENABLE="aby włączyć"

# Sekcja zakończenia
export T_COMPLETE_TITLE="INSTALACJA ZAKOŃCZONA"
export T_ALL_SUCCESS="Wszystkie moduły zainstalowane pomyślnie!"
export T_SOME_FAILED="instalacja modułu/ów nie powiodła się"
export T_NEXT_STEPS="Następne kroki:"
export T_STEP_TEST="Test DNS: dig +short google.com @127.0.0.1"
export T_STEP_CONFIG="Konfiguracja systemu: sudo cytadela++ configure-system"
export T_STEP_VERIFY="Weryfikacja: sudo cytadela++ verify"

# Komunikaty błędów
export T_CANCELLED="Instalacja anulowana przez użytkownika"
export T_CANCELLED_SHORT="Instalacja anulowana"
export T_UNKNOWN_MODULE="Nieznany moduł"

# Sekcja deinstalacji
export T_UNINSTALL_TITLE="DEINSTALACJA CYTADELA++"
export T_UNINSTALL_WARNING="To USUNIE wszystkie komponenty Citadel!"
export T_UNINSTALL_INFO="Usługi zostaną zatrzymane i wyłączone"
export T_UNINSTALL_CONFIG="Pliki konfiguracyjne zostaną usunięte"
export T_CONFIRM_UNINSTALL="Na pewno? Wpisz 'yes' aby kontynuować: "
export T_UNINSTALL_CANCELLED="Anulowano"
export T_CHECK_DEPS="Sprawdzanie zależności opcjonalnych..."
export T_NO_OPTIONAL_PKGS="Nie znaleziono pakietów opcjonalnych (dnsperf, curl, jq, itd.)"
export T_OPTIONAL_PKGS_FOUND="Następujące pakiety mogły być zainstalowane dla Citadel:"
export T_REMOVE_PKGS_MANUAL="Możesz usunąć je ręcznie jeśli inne aplikacje ich nie potrzebują:"
export T_REMOVE_PKGS_NOW="Usunąć te pakiety teraz? (t/N): "
export T_REMOVING="Usuwanie"
export T_NO_DEPS="(żaden inny paket nie zależy od niego)"
export T_SKIPPING="Pomijanie"
export T_REQUIRED_BY="(wymagany przez inne pakiety)"
export T_RESTORE_DNS="Przywracanie oryginalnej konfiguracji DNS..."
export T_RESTORED_BACKUP="Przywrócono z backupu"
export T_SET_FALLBACK="Ustawiono zapasowy DNS"
export T_TESTING_DNS="Testowanie łączności DNS..."
export T_DNS_OK="Łączność DNS działa"
export T_DNS_FAILED="Test DNS nie powiódł się - system może stracić internet po restarcie!"
export T_STOPPING_SERVICES="Zatrzymywanie usług..."
export T_REMOVING_FIREWALL="Usuwanie reguł firewalla..."
export T_REMOVING_CONFIG="Usuwanie plików konfiguracyjnych..."
export T_REMOVING_DATA="Usuwanie katalogów z danymi..."
export T_REMOVING_USER="Usuwanie użytkownika systemowego..."
export T_REMOVING_DASHBOARD="Usuwanie dashboardu..."
export T_REMOVING_CRON="Usuwanie zaplanowanych zadań..."
export T_REMOVING_SHORTCUTS="Usuwanie skrótów poleceń..."
export T_UNINSTALL_COMPLETE="Citadel został całkowicie usunięty"
export T_REINSTALL_HINT="Aby zainstalować ponownie: sudo ./citadel.sh install-wizard"
export T_KEEP_CONFIG_TITLE="DEINSTALACJA (Zachowaj Konfigurację)"
export T_KEEP_CONFIG_WARNING="To zatrzyma usługi ale ZACHOWA pliki konfiguracyjne"
export T_CONFIRM_KEEP_CONFIG="Kontynuować? Wpisz 'yes': "
export T_SERVICES_STOPPED="Usługi zatrzymane, konfiguracja zachowana"
export T_RESTART_HINT="Aby uruchomić ponownie: sudo ./citadel.sh install-wizard"
export T_MANUAL_FIX="Opcje naprawy manualnej:"
export T_RESTART_NM="Zrestartuj NetworkManager"
export T_RESTART_SD="Lub zrestartuj systemd-resolved"
export T_MANUAL_EDIT="Lub edytuj ręcznie"
export T_ADD_NAMESERVER="i dodaj"
export T_CONTINUE_ANYWAY="Kontynuować deinstalację pomimo problemów z DNS? (yes/no): "
export T_UNINSTALL_CANCELLED_DNS="Deinstalacja anulowana. Napraw DNS najpierw, potem uruchom deinstalację ponownie."

# Menu detekcji w install-wizard
export T_WIZARD_SETUP_TITLE="Citadel++ Setup"
export T_WIZARD_INSTALLED_MSG="Citadel jest już zainstalowany. Wybierz akcję:"
export T_WIZARD_REINSTALL="Reinstaluj z backupem"
export T_WIZARD_UNINSTALL="Usuń Citadel"
export T_WIZARD_MODIFY="Modyfikuj komponenty (wkrótce w v3.2)"
export T_WIZARD_CANCEL="Wyjście"
export T_WIZARD_MODIFY_MSG="Modyfikacja komponentów dostępna w wersji v3.2"
