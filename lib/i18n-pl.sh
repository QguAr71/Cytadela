#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ i18n - POLISH MESSAGES v3.1                                   ║
# ║  Polskie komunikaty i help                                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

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
