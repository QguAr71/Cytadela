#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - German Translations (DE)                                    ║
# ║  Install Wizard i18n strings                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Wizard titles
export T_WIZARD_TITLE="INTERAKTIVER INSTALLATIONSASSISTENT"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Installationsassistent"

# Dialog messages
export T_SELECT_MODULES="Wählen Sie Module zur Installation aus:"
export T_DIALOG_HELP="(LEERTASTE zum Umschalten, TAB zur Navigation, ENTER zum Bestätigen)"
export T_REQUIRED_NOTE="Erforderliche Module sind vorausgewählt und können nicht deaktiviert werden."

# Module descriptions
export T_MOD_DNSCRYPT="Verschlüsselter DNS-Resolver (DNSCrypt/DoH)"
export T_MOD_COREDNS="Lokaler DNS-Server mit Adblock + Cache"
export T_MOD_NFTABLES="Firewall-Regeln (DNS-Leak-Schutz)"
export T_MOD_HEALTH="Automatischer Neustart von Diensten bei Ausfall"
export T_MOD_SUPPLY="Binärverifizierung (Prüfsummen)"
export T_MOD_LKG="Last Known Good Blocklist-Cache"
export T_MOD_IPV6="IPv6-Datenschutzerweiterungen-Verwaltung"
export T_MOD_LOCATION="SSID-basierte Firewall-Beratung"
export T_MOD_DEBUG="NFTables Debug-Chain mit Protokollierung"

# Summary section
export T_SUMMARY_TITLE="INSTALLATIONSÜBERSICHT"
export T_SELECTED_MODULES="Ausgewählte Module:"
export T_CONFIRM_WARNING="Dies wird DNS-Dienste auf Ihrem System installieren und konfigurieren."
export T_CONFIRM_PROMPT="Mit der Installation fortfahren? [j/N]: "

# Installation section
export T_INSTALLING_TITLE="MODULE WERDEN INSTALLIERT"
export T_INSTALLING="Installiere"
export T_INSTALLED="installiert"
export T_FAILED="Installation fehlgeschlagen"
export T_INITIALIZED="initialisiert"
export T_INIT_FAILED="Initialisierung fehlgeschlagen"
export T_CACHE_SAVED="Cache gespeichert"
export T_CACHE_NOT_SAVED="Cache nicht gespeichert (wird beim ersten Update erstellt)"
export T_CONFIGURED="konfiguriert"
export T_CONFIG_SKIPPED="Konfiguration übersprungen"
export T_MODULE_LOADED="Modul geladen"
export T_USE_COMMAND="verwenden"
export T_TO_ENABLE="zum Aktivieren"

# Completion section
export T_COMPLETE_TITLE="INSTALLATION ABGESCHLOSSEN"
export T_ALL_SUCCESS="Alle Module erfolgreich installiert!"
export T_SOME_FAILED="Modul(e) konnten nicht installiert werden"
export T_NEXT_STEPS="Nächste Schritte:"
export T_STEP_TEST="DNS testen: dig +short google.com @127.0.0.1"
export T_STEP_CONFIG="System konfigurieren: sudo cytadela++ configure-system"
export T_STEP_VERIFY="Überprüfen: sudo cytadela++ verify"

# Error messages
export T_CANCELLED="Installation vom Benutzer abgebrochen"
export T_CANCELLED_SHORT="Installation abgebrochen"
export T_UNKNOWN_MODULE="Unbekanntes Modul"
