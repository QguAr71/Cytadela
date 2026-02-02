#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ SETUP WIZARD v3.1                                             ║
# ║  Unified install/uninstall wizard                                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

export NEWT_COLORS='
root=,black
window=brightmagenta,black
border=brightgreen,black
textbox=brightmagenta,black
button=black,brightgreen
actbutton=black,brightmagenta
checkbox=brightgreen,black
actcheckbox=black,brightgreen
'

detect_citadel_installation() {
    [[ -d /etc/coredns ]] || [[ -f /etc/systemd/system/coredns.service ]] || [[ -d /opt/cytadela ]]
}

setup_wizard() {
    if detect_citadel_installation; then
        # Already installed - show management menu
        local choice
        choice=$(whiptail --title "Citadel++ Setup" \
            --menu "Citadel is already installed. Choose action:" 15 60 4 \
            "reinstall" "Reinstall with backup" \
            "uninstall" "Remove Citadel" \
            "modify" "Modify components (coming soon)" \
            "cancel" "Exit" 3>&1 1>&2 2>&3)
        
        case "$choice" in
            reinstall)
                config_backup_create
                citadel_uninstall
                install_wizard
                ;;
            uninstall)
                citadel_uninstall
                ;;
            modify)
                whiptail --msgbox "Component modification coming in v3.2" 10 40
                ;;
            *)
                return 0
                ;;
        esac
    else
        # Not installed - run install wizard
        install_wizard
    fi
}
