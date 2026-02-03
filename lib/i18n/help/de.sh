#!/bin/bash
# Help - Translations (EN)

# Title
export T_HELP_TITLE="CITADEL++ v3.1 - Command Reference"

# Sections
export T_HELP_SECTION_INSTALL="1. INSTALLATION"
export T_HELP_SECTION_MAIN="2. MAIN PROGRAM"
export T_HELP_SECTION_ADDONS="3. ADD-ONS"
export T_HELP_SECTION_ADVANCED="4. ADVANCED"
export T_HELP_SECTION_WORKFLOW="QUICK START"

# Installation commands
export T_HELP_CMD_INSTALL_WIZARD="Interactive installer (RECOMMENDED)"
export T_HELP_CMD_INSTALL_ALL="Install all DNS modules"
export T_HELP_CMD_INSTALL_DNSCRYPT="Install DNSCrypt-Proxy only"
export T_HELP_CMD_INSTALL_COREDNS="Install CoreDNS only"
export T_HELP_CMD_INSTALL_NFTABLES="Install NFTables rules only"

# Main program commands
export T_HELP_CMD_CONFIGURE_SYSTEM="Switch system DNS to Citadel++"
export T_HELP_CMD_RESTORE_SYSTEM="Restore systemd-resolved"
export T_HELP_CMD_FIREWALL_SAFE="SAFE mode (won't break connectivity)"
export T_HELP_CMD_FIREWALL_STRICT="STRICT mode (DNS leak protection)"
export T_HELP_CMD_STATUS="Show service status"
export T_HELP_CMD_DIAGNOSTICS="Full system diagnostics"
export T_HELP_CMD_VERIFY="Verify full stack"
export T_HELP_CMD_VERIFY_CONFIG="Verify config and DNS"
export T_HELP_CMD_TEST_ALL="Smoke test + leak test"

# Add-ons commands
export T_HELP_CMD_BLOCKLIST_LIST="Show available blocklist profiles"
export T_HELP_CMD_BLOCKLIST_SWITCH="Switch blocklist profile"
export T_HELP_CMD_ADBLOCK_STATUS="Show adblock status"
export T_HELP_CMD_ADBLOCK_ADD="Add domain to adblock"
export T_HELP_CMD_NOTIFY_ENABLE="Enable desktop notifications"

# Advanced commands
export T_HELP_CMD_PANIC_BYPASS="Emergency bypass + auto-rollback"
export T_HELP_CMD_LKG_SAVE="Save blocklist to cache"
export T_HELP_CMD_LKG_RESTORE="Restore blocklist from cache"
export T_HELP_CMD_AUTO_UPDATE_ENABLE="Enable automatic updates"
export T_HELP_CMD_CACHE_STATS="Show DNS cache statistics"
export T_HELP_CMD_HEALTH_INSTALL="Install health watchdog"

# Workflow
export T_HELP_WORKFLOW_STEP1="sudo ./citadel.sh install-all"
export T_HELP_WORKFLOW_STEP2="sudo ./citadel.sh firewall-safe"
export T_HELP_WORKFLOW_STEP3="dig +short google.com @127.0.0.1"
export T_HELP_WORKFLOW_STEP4="sudo ./citadel.sh configure-system"

# Docs
export T_HELP_GITHUB="GitHub: https://github.com/QguAr71/Cytadela"
