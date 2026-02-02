#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - French Translations (FR)                                    ║
# ║  Install Wizard i18n strings                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Wizard titles
export T_WIZARD_TITLE="ASSISTANT D'INSTALLATION INTERACTIF"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Assistant d'Installation"

# Dialog messages
export T_SELECT_MODULES="Sélectionnez les modules à installer :"
export T_DIALOG_HELP="(ESPACE pour basculer, TAB pour naviguer, ENTRÉE pour confirmer)"
export T_REQUIRED_NOTE="Les modules requis sont présélectionnés et ne peuvent pas être désactivés."

# Module descriptions
export T_MOD_DNSCRYPT="Résolveur DNS chiffré (DNSCrypt/DoH)"
export T_MOD_COREDNS="Serveur DNS local avec adblock + cache"
export T_MOD_NFTABLES="Règles de pare-feu (prévention des fuites DNS)"
export T_MOD_HEALTH="Redémarrage automatique des services en cas d'échec"
export T_MOD_SUPPLY="Vérification des binaires (sommes de contrôle)"
export T_MOD_LKG="Cache de liste de blocage Last Known Good"
export T_MOD_IPV6="Gestion des extensions de confidentialité IPv6"
export T_MOD_LOCATION="Conseil de pare-feu basé sur SSID"
export T_MOD_DEBUG="Chaîne de débogage NFTables avec journalisation"

# Summary section
export T_SUMMARY_TITLE="RÉSUMÉ DE L'INSTALLATION"
export T_SELECTED_MODULES="Modules sélectionnés :"
export T_CONFIRM_WARNING="Cela installera et configurera les services DNS sur votre système."
export T_CONFIRM_PROMPT="Continuer l'installation ? [o/N] : "

# Installation section
export T_INSTALLING_TITLE="INSTALLATION DES MODULES"
export T_INSTALLING="Installation"
export T_INSTALLED="installé"
export T_FAILED="échec de l'installation"
export T_INITIALIZED="initialisé"
export T_INIT_FAILED="échec de l'initialisation"
export T_CACHE_SAVED="cache enregistré"
export T_CACHE_NOT_SAVED="cache non enregistré (sera créé lors de la première mise à jour)"
export T_CONFIGURED="configuré"
export T_CONFIG_SKIPPED="configuration ignorée"
export T_MODULE_LOADED="module chargé"
export T_USE_COMMAND="utiliser"
export T_TO_ENABLE="pour activer"

# Completion section
export T_COMPLETE_TITLE="INSTALLATION TERMINÉE"
export T_ALL_SUCCESS="Tous les modules installés avec succès !"
export T_SOME_FAILED="module(s) n'ont pas pu être installé(s)"
export T_NEXT_STEPS="Prochaines étapes :"
export T_STEP_TEST="Tester DNS : dig +short google.com @127.0.0.1"
export T_STEP_CONFIG="Configurer le système : sudo cytadela++ configure-system"
export T_STEP_VERIFY="Vérifier : sudo cytadela++ verify"

# Error messages
export T_CANCELLED="Installation annulée par l'utilisateur"
export T_CANCELLED_SHORT="Installation annulée"
export T_UNKNOWN_MODULE="Module inconnu"
