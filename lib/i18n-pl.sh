#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ i18n - POLISH MESSAGES v3.1                                   ║
# ║  Polskie komunikaty i help                                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

show_help_pl() {
    cat <<EOF

${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.1 - Instrukcja                              ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Komendy instalacyjne (BEZPIECZNE):${NC}
  install-wizard        🎯 Interaktywny instalator z checklistą (ZALECANE)
  install-all           Instaluj wszystkie moduły DNS (NIE wyłącza systemd-resolved)
  install-dnscrypt      Instaluj tylko DNSCrypt-Proxy
  install-coredns       Instaluj tylko CoreDNS
  install-nftables      Instaluj tylko reguły NFTables

${CYAN}DNSSEC (opcjonalnie):${NC}
  CITADEL_DNSSEC=1       Wygeneruj DNSCrypt z require_dnssec = true
  --dnssec               Alternatywnie: dodaj flagę przy install-dnscrypt/install-all

${YELLOW}NOWE FUNKCJE v3.1:${NC}
  smart-ipv6           Smart IPv6 detection & auto-reconfiguration
  ipv6-privacy-on      Włącz IPv6 Privacy Extensions (prefer temporary)
  ipv6-privacy-off     Wyłącz IPv6 Privacy Extensions
  ipv6-privacy-status  Pokaż status IPv6 Privacy Extensions
  ipv6-privacy-auto    Auto-ensure IPv6 privacy (detect + fix if needed)
  discover             Network & firewall sanity snapshot
  install-dashboard    Instaluj terminal dashboard (citadel-top)
  install-editor       Instaluj integrację edytora (citadel edit)
  optimize-kernel      Zastosuj real-time priority dla procesów DNS
  install-doh-parallel Instaluj DNS-over-HTTPS parallel racing
  fix-ports            Rozwiąż konflikty portów z avahi/chromium

${YELLOW}Konfiguracja systemu (UWAGA - wyłącza systemd-resolved):${NC}
  configure-system      Przełącz system na Citadel++ DNS (z potwierdzeniem)
  restore-system        Przywróć systemd-resolved + DNS (rollback)

${CYAN}Komendy awaryjne:${NC}
  emergency-refuse      Refuse all DNS queries (tryb awaryjny)
  emergency-restore     Przywróć normalną pracę
  killswitch-on         Aktywuj DNS kill-switch (blokuj wszystko poza localhost)
  killswitch-off        Dezaktywuj kill-switch

${RED}Panic Bypass (odzyskiwanie SPOF):${NC}
  panic-bypass [secs]   Wyłącz ochronę + auto-rollback (domyślnie 300s)
  panic-restore         Ręcznie przywróć tryb chroniony
  panic-status          Pokaż status trybu panic

${YELLOW}LKG (Last Known Good):${NC}
  lkg-save              Zapisz obecną blocklist do cache
  lkg-restore           Przywróć blocklist z cache
  lkg-status            Pokaż status cache LKG
  lists-update          Aktualizuj blocklist z LKG fallback

${CYAN}Komendy diagnostyczne:${NC}
  diagnostics           Uruchom pełną diagnostykę systemu
  status                Pokaż status usług
  verify                Weryfikuj pełny stack (porty/usługi/DNS/NFT/metryki)
  ghost-check           Audyt ekspozycji portów (ostrzeż o 0.0.0.0/::)
  ipv6-deep-reset       Flush IPv6 + neighbor cache + reconnect
  test-all              Smoke test (verify + leak test + IPv6)

${GREEN}Health Watchdog:${NC}
  health-status         Pokaż status zdrowia (usługi, DNS probe, firewall)
  health-install        Instaluj auto-restart + health check timer
  health-uninstall      Usuń health watchdog

${GREEN}Weryfikacja Supply-Chain:${NC}
  supply-chain-status   Pokaż status pliku checksums
  supply-chain-init     Inicjalizuj checksumy dla znanych zasobów
  supply-chain-verify   Weryfikuj lokalne pliki względem manifestu

${CYAN}Location-Aware Advisory:${NC}
  location-status       Pokaż obecny SSID, status zaufania, tryb firewall
  location-check        Sprawdź i doradź tryb firewall
  location-add-trusted  Dodaj SSID do listy zaufanych (lub obecny jeśli brak arg)
  location-remove-trusted Usuń SSID z listy zaufanych
  location-list-trusted Lista wszystkich zaufanych SSID

${CYAN}NFT Debug Chain:${NC}
  nft-debug-on          Włącz debug chain z rate-limited logging
  nft-debug-off         Wyłącz debug chain
  nft-debug-status      Pokaż status debug chain i liczniki
  nft-debug-logs        Pokaż ostatnie wpisy CITADEL log

${YELLOW}Integrity (Local-First):${NC}
  integrity-init        Utwórz manifest integrity dla skryptów/binariów
  integrity-check       Weryfikuj integrity względem manifestu
  integrity-status      Pokaż tryb integrity i info manifestu
  --dev                 Uruchom w trybie developer (relaxed integrity checks)

${CYAN}Tryby Firewall:${NC}
  firewall-safe         Ustaw reguły SAFE (nie zrywa internetu)
  firewall-strict       Ustaw reguły STRICT (blokuje DNS-leaks)

${GREEN}Rekomendowany workflow:${NC}
  ${CYAN}1.${NC} sudo ./cytadela++.sh install-all
  ${CYAN}2.${NC} sudo ./cytadela++.sh firewall-safe         ${YELLOW}# SAFE: nie zrywa internetu${NC}
  ${CYAN}3.${NC} dig +short google.com @127.0.0.1          ${YELLOW}# Test lokalnego DNS${NC}
  ${CYAN}4.${NC} sudo ./cytadela++.sh configure-system       ${YELLOW}# Przełączenie systemu${NC}
  ${CYAN}5.${NC} ping -c 3 google.com                      ${YELLOW}# Test internetu${NC}
  ${CYAN}6.${NC} sudo ./cytadela++.sh firewall-strict        ${YELLOW}# STRICT: pełna blokada DNS-leak${NC}

${GREEN}Nowe narzędzia v3.1:${NC}
  cytadela-top          Real-time terminal dashboard
  cytadela edit         Editor z auto-restart
  cytadela status       Szybki check statusu

${CYAN}Panel Adblock (DNS):${NC}
  adblock-status        Pokaż status integracji adblock/CoreDNS
  adblock-stats         Pokaż liczby custom/blocklist/combined
  adblock-show          Pokaż: custom|blocklist|combined (pierwsze 200 linii)
  adblock-edit          Edytuj /etc/coredns/zones/custom.hosts i przeładuj
  adblock-add           Dodaj domenę do custom.hosts (0.0.0.0 domain)
  adblock-remove        Usuń domenę z custom.hosts
  adblock-rebuild       Przebuduj combined.hosts z custom+blocklist i przeładuj
  adblock-query         Zapytaj domenę przez lokalny DNS (127.0.0.1)
  allowlist-list        Pokaż allowlist (domeny wyłączone z blokady)
  allowlist-add         Dodaj domenę do allowlist
  allowlist-remove      Usuń domenę z allowlist

${CYAN}Zaawansowana konfiguracja:${NC}
  DNSCrypt config:      /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  DNSCrypt DoH config:  /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml
  CoreDNS config:       /etc/coredns/Corefile
  NFTables rules:       /etc/nftables.d/citadel-dns.nft

${CYAN}Dokumentacja:${NC}
  GitHub:              https://github.com/QguAr71/Cytadela

EOF
}
