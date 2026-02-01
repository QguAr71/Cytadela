#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Italian Translations (IT)                                   ║
# ║  Install Wizard i18n strings                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Wizard titles
export T_WIZARD_TITLE="ASSISTENTE DI INSTALLAZIONE INTERATTIVO"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Assistente di Installazione"

# Dialog messages
export T_SELECT_MODULES="Seleziona i moduli da installare:"
export T_DIALOG_HELP="(SPAZIO per attivare/disattivare, TAB per navigare, INVIO per confermare)"
export T_REQUIRED_NOTE="I moduli richiesti sono preselezionati e non possono essere disabilitati."

# Module descriptions
export T_MOD_DNSCRYPT="Risolutore DNS crittografato (DNSCrypt/DoH)"
export T_MOD_COREDNS="Server DNS locale con adblock + cache"
export T_MOD_NFTABLES="Regole firewall (prevenzione perdite DNS)"
export T_MOD_HEALTH="Riavvio automatico dei servizi in caso di errore"
export T_MOD_SUPPLY="Verifica dei binari (checksum)"
export T_MOD_LKG="Cache blocklist Last Known Good"
export T_MOD_IPV6="Gestione estensioni privacy IPv6"
export T_MOD_LOCATION="Firewall basato su SSID"
export T_MOD_DEBUG="Catena debug NFTables con logging"

# Summary section
export T_SUMMARY_TITLE="RIEPILOGO INSTALLAZIONE"
export T_SELECTED_MODULES="Moduli selezionati:"
export T_CONFIRM_WARNING="Questo installerà e configurerà i servizi DNS sul tuo sistema."
export T_CONFIRM_PROMPT="Procedere con l'installazione? [s/N]: "

# Installation section
export T_INSTALLING_TITLE="INSTALLAZIONE MODULI"
export T_INSTALLING="Installazione"
export T_INSTALLED="installato"
export T_FAILED="installazione fallita"
export T_INITIALIZED="inizializzato"
export T_INIT_FAILED="inizializzazione fallita"
export T_CACHE_SAVED="cache salvata"
export T_CACHE_NOT_SAVED="cache non salvata (verrà creata al primo aggiornamento)"
export T_CONFIGURED="configurato"
export T_CONFIG_SKIPPED="configurazione saltata"
export T_MODULE_LOADED="modulo caricato"
export T_USE_COMMAND="usa"
export T_TO_ENABLE="per abilitare"

# Completion section
export T_COMPLETE_TITLE="INSTALLAZIONE COMPLETATA"
export T_ALL_SUCCESS="Tutti i moduli installati con successo!"
export T_SOME_FAILED="modulo/i non installato/i"
export T_NEXT_STEPS="Prossimi passi:"
export T_STEP_TEST="Test DNS: dig +short google.com @127.0.0.1"
export T_STEP_CONFIG="Configura sistema: sudo cytadela++ configure-system"
export T_STEP_VERIFY="Verifica: sudo cytadela++ verify"

# Error messages
export T_CANCELLED="Installazione annullata dall'utente"
export T_CANCELLED_SHORT="Installazione annullata"
export T_UNKNOWN_MODULE="Modulo sconosciuto"

# Advanced features (v3.2+)
export T_HONEYPOT_ENABLED="Honeypot attivato"
export T_REPUTATION_ACTIVE="Sistema di reputazione attivo"
export T_ASN_BLOCKING_CONFIGURED="Blocco ASN configurato"
