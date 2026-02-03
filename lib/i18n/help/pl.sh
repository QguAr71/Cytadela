#!/bin/bash
# Help - Tłumaczenia (PL)

export T_HELP_TITLE="CYTADELA++ v3.1 - Instrukcja"

# Sekcje
export T_HELP_SECTION_INSTALL="🚀 Instalacja (ZALECANE):"
export T_HELP_SECTION_CONFIG="⚙️  Konfiguracja systemu:"
export T_HELP_SECTION_EMERGENCY="🚨 Awaryjne:"
export T_HELP_SECTION_DIAGNOSTICS="📊 Status i diagnostyka:"
export T_HELP_SECTION_BLOCKLIST="🔧 Zarządzanie blocklist:"
export T_HELP_SECTION_ADBLOCK="��️  Adblock:"
export T_HELP_SECTION_NEW="🔍 Nowe funkcje v3.1:"
export T_HELP_SECTION_WORKFLOW="📋 Przykładowy workflow:"
export T_HELP_SECTION_DOCS="📚 Dokumentacja:"

# Komendy instalacji
export T_HELP_CMD_INSTALL_WIZARD="Interaktywny instalator z checklistą"
export T_HELP_CMD_INSTALL_ALL="Instaluj wszystkie moduły DNS"
export T_HELP_CMD_INSTALL_DNSCRYPT="Instaluj tylko DNSCrypt-Proxy"
export T_HELP_CMD_INSTALL_COREDNS="Instaluj tylko CoreDNS"
export T_HELP_CMD_INSTALL_NFTABLES="Instaluj tylko reguły NFTables"

# Konfiguracja
export T_HELP_CMD_CONFIGURE_SYSTEM="Przełącz system na Citadel++ DNS"
export T_HELP_CMD_RESTORE_SYSTEM="Przywróć systemd-resolved"
export T_HELP_CMD_FIREWALL_SAFE="Tryb bezpieczny (nie zrywa internetu)"
export T_HELP_CMD_FIREWALL_STRICT="Tryb ścisły (pełna blokada DNS-leak)"

# Awaryjne
export T_HELP_CMD_PANIC_BYPASS="Wyłącz ochronę + auto-rollback"
export T_HELP_CMD_PANIC_RESTORE="Przywróć tryb chroniony"
export T_HELP_CMD_EMERGENCY_REFUSE="Odrzuć wszystkie zapytania DNS"
export T_HELP_CMD_KILLSWITCH_ON="Aktywuj DNS kill-switch"
export T_HELP_CMD_KILLSWITCH_OFF="Dezaktywuj kill-switch"

# Diagnostyka
export T_HELP_CMD_STATUS="Pokaż status usług"
export T_HELP_CMD_DIAGNOSTICS="Pełna diagnostyka systemu"
export T_HELP_CMD_VERIFY="Weryfikuj cały stack"
export T_HELP_CMD_VERIFY_CONFIG="Weryfikacja konfiguracji i DNS"
export T_HELP_CMD_VERIFY_CONFIG_DNS="Tylko test DNS"
export T_HELP_CMD_VERIFY_CONFIG_ALL="Wszystkie testy"
export T_HELP_CMD_TEST_ALL="Smoke test + leak test"
export T_HELP_CMD_GHOST_CHECK="Audyt otwartych portów"
export T_HELP_CMD_CHECK_DEPS="Sprawdź zależności"
export T_HELP_CMD_CHECK_DEPS_INSTALL="Zainstaluj brakujące (z AUR dla Arch)"

# Blocklist
export T_HELP_CMD_BLOCKLIST_LIST="Pokaż dostępne profile"
export T_HELP_CMD_BLOCKLIST_SWITCH="Przełącz profil"
export T_HELP_CMD_LISTS_UPDATE="Aktualizuj z LKG fallback"
export T_HELP_CMD_LKG_SAVE="Zapisz blocklist do cache"
export T_HELP_CMD_LKG_RESTORE="Przywróć z cache"

# Adblock
export T_HELP_CMD_ADBLOCK_STATUS="Status adblock"
export T_HELP_CMD_ADBLOCK_ADD="Dodaj domenę"
export T_HELP_CMD_ADBLOCK_REMOVE="Usuń domenę"
export T_HELP_CMD_ADBLOCK_QUERY="Sprawdź domenę"
export T_HELP_CMD_ALLOWLIST_ADD="Dodaj do allowlist"

# Nowe funkcje
export T_HELP_CMD_SMART_IPV6="Smart IPv6 detection"
export T_HELP_CMD_DISCOVER="Network sanity snapshot"
export T_HELP_CMD_INSTALL_DASHBOARD="Terminal dashboard"
export T_HELP_CMD_CACHE_STATS="Statystyki DNS cache"
export T_HELP_CMD_NOTIFY_ENABLE="Powiadomienia systemowe"

# Workflow
export T_HELP_WORKFLOW_STEP1="sudo cytadela.sh install-all"
export T_HELP_WORKFLOW_STEP2="sudo cytadela.sh firewall-safe"
export T_HELP_WORKFLOW_STEP3="dig +short google.com @127.0.0.1"
export T_HELP_WORKFLOW_STEP4="sudo cytadela.sh configure-system"
export T_HELP_WORKFLOW_STEP5="sudo cytadela.sh firewall-strict"

# Dokumentacja
export T_HELP_GITHUB="GitHub: https://github.com/QguAr71/Cytadela"

# Dodatkowe etykiety
export T_HELP_RECOMMENDED="ZALECANE"
export T_HELP_SAFE="SAFE"
export T_HELP_STRICT="STRICT"
