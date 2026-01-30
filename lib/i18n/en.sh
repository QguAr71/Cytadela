#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - English Translations (EN)                                   ║
# ║  Install Wizard i18n strings                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Wizard titles
export T_WIZARD_TITLE="INTERACTIVE INSTALLER WIZARD"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Installation Wizard"

# Dialog messages
export T_SELECT_MODULES="Select modules to install:"
export T_DIALOG_HELP="(SPACE to toggle, TAB to navigate, ENTER to confirm)"
export T_REQUIRED_NOTE="Required modules are pre-selected and cannot be disabled."

# Module descriptions
export T_MOD_DNSCRYPT="Encrypted DNS resolver (DNSCrypt/DoH)"
export T_MOD_COREDNS="Local DNS server with adblock + cache"
export T_MOD_NFTABLES="Firewall rules (DNS leak prevention)"
export T_MOD_HEALTH="Auto-restart services on failure"
export T_MOD_SUPPLY="Binary verification (checksums)"
export T_MOD_LKG="Last Known Good blocklist cache"
export T_MOD_IPV6="IPv6 privacy extensions management"
export T_MOD_LOCATION="SSID-based firewall advisory"
export T_MOD_DEBUG="NFTables debug chain with logging"

# Summary section
export T_SUMMARY_TITLE="INSTALLATION SUMMARY"
export T_SELECTED_MODULES="Selected modules:"
export T_CONFIRM_WARNING="This will install and configure DNS services on your system."
export T_CONFIRM_PROMPT="Proceed with installation? [y/N]: "

# Installation section
export T_INSTALLING_TITLE="INSTALLING MODULES"
export T_INSTALLING="Installing"
export T_INSTALLED="installed"
export T_FAILED="installation failed"
export T_INITIALIZED="initialized"
export T_INIT_FAILED="initialization failed"
export T_CACHE_SAVED="cache saved"
export T_CACHE_NOT_SAVED="cache not saved (will be created on first update)"
export T_CONFIGURED="configured"
export T_CONFIG_SKIPPED="configuration skipped"
export T_MODULE_LOADED="module loaded"
export T_USE_COMMAND="use"
export T_TO_ENABLE="to enable"

# Completion section
export T_COMPLETE_TITLE="INSTALLATION COMPLETE"
export T_ALL_SUCCESS="All modules installed successfully!"
export T_SOME_FAILED="module(s) failed to install"
export T_NEXT_STEPS="Next steps:"
export T_STEP_TEST="Test DNS: dig +short google.com @127.0.0.1"
export T_STEP_CONFIG="Configure system: sudo cytadela++ configure-system"
export T_STEP_VERIFY="Verify: sudo cytadela++ verify"

# Error messages
export T_CANCELLED="Installation cancelled by user"
export T_CANCELLED_SHORT="Installation cancelled"
export T_UNKNOWN_MODULE="Unknown module"
