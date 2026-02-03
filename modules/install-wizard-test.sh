#!/bin/bash
# ULTRA MINIMAL INSTALL WIZARD - TEST

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'

install_wizard() {
    while true; do
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║  SELECT LANGUAGE                                             ║"
        echo "╠══════════════════════════════════════════════════════════════╣"
        echo "║  [1] English                                                 ║"
        echo "║  [2] Polski                                                  ║"
        echo "║  [3] Deutsch                                                 ║"
        echo "║  [q] Cancel                                                  ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo -n "Choice: "
        read -r choice </dev/tty
        
        case "$choice" in
            1|2|3) break ;;
            q) return 1 ;;
        esac
    done
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  CITADEL++ INSTALL WIZARD                                    ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                              ║"
    echo "║  This wizard will install Citadel++ DNS system               ║"
    echo "║                                                              ║"
    echo "║  Required: Root privileges                                   ║"
    echo "║  Time: ~5 minutes                                            ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "Press Enter to continue..."
    read </dev/tty
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║  INSTALLATION SUMMARY                                        ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  Modules to install:                                         ║"
    echo "║  ✓ DNSCrypt-Proxy                                            ║"
    echo "║  ✓ CoreDNS                                                   ║"
    echo "║  ✓ NFTables                                                  ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo -n "Proceed? [y/N]: "
    read -r answer </dev/tty
    
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Installation started..."
    else
        echo "Cancelled."
        return 1
    fi
}
