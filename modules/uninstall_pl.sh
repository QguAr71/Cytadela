#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNINSTALL MODULE v3.1 (Polish Version)                        ║
# ║  Kompletna deinstalacja z polskimi komunikatami                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

citadel_uninstall_pl() {
    # Wczytaj tłumaczenia polskie
    local module_dir
    module_dir="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
    if [[ -f "${module_dir}/lib/i18n/pl.sh" ]]; then
        # shellcheck source=/dev/null
        source "${module_dir}/lib/i18n/pl.sh"
    fi

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║  ${T_UNINSTALL_TITLE:-DEINSTALACJA CYTADELA++}                                        ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo ""

    echo "⚠️  ${T_UNINSTALL_WARNING:-To USUNIE wszystkie komponenty Citadel!}"
    echo "ℹ️  ${T_UNINSTALL_INFO:-Usługi zostaną zatrzymane i wyłączone}"
    echo "ℹ️  ${T_UNINSTALL_CONFIG:-Pliki konfiguracyjne zostaną usunięte}"
    echo ""
    read -rp "${T_CONFIRM_UNINSTALL:-Na pewno? Wpisz 'yes' aby kontynuować: }" confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "ℹ️  ${T_UNINSTALL_CANCELLED:-Anulowano}"
        return 0
    fi

    # Sprawdź pakiety opcjonalne
    echo ""
    echo "ℹ️  ${T_CHECK_DEPS:-Sprawdzanie zależności opcjonalnych...}"
    local optional_packages=()
    local pkg
    for pkg in dnsperf curl jq whiptail notify-send shellcheck; do
        if command -v "$pkg" >/dev/null 2>&1; then
            if pacman -Qq "$pkg" 2>/dev/null | grep -q "^$pkg$"; then
                optional_packages+=("$pkg")
            fi
        fi
    done

    if [[ ${#optional_packages[@]} -gt 0 ]]; then
        echo "⚠️  ${T_OPTIONAL_PKGS_FOUND:-Następujące pakiety mogły być zainstalowane dla Citadel:}"
        printf "  • %s\n" "${optional_packages[@]}"
        echo "ℹ️  ${T_REMOVE_PKGS_MANUAL:-Możesz usunąć je ręcznie jeśli inne aplikacje ich nie potrzebują:}"
        echo "   sudo pacman -R ${optional_packages[*]}"
        echo ""
        read -rp "${T_REMOVE_PKGS_NOW:-Usunąć te pakiety teraz? (t/N): }" remove_pkgs
        if [[ "$remove_pkgs" =~ ^[Tt]$ ]]; then
            echo "ℹ️  ${T_REMOVING:-Usuwanie} pakietów..."
            for pkg in "${optional_packages[@]}"; do
                if pacman -Qi "$pkg" 2>/dev/null | grep -q "^Required By.*None"; then
                    echo "ℹ️  ${T_REMOVING:-Usuwanie} $pkg ${T_NO_DEPS:-(żaden inny pakiet nie zależy od niego)}"
                    pacman -R --noconfirm "$pkg" 2>/dev/null || echo "⚠️  Nie udało się usunąć $pkg"
                else
                    echo "ℹ️  ${T_SKIPPING:-Pomijanie} $pkg ${T_REQUIRED_BY:-(wymagany przez inne pakiety)}"
                fi
            done
        fi
    else
        echo "ℹ️  ${T_NO_OPTIONAL_PKGS:-Nie znaleziono pakietów opcjonalnych (dnsperf, curl, jq, itd.)}"
    fi

    echo ""

    # Przywróć DNS (krytyczne!)
    echo "ℹ️  ${T_RESTORE_DNS:-Przywracanie oryginalnej konfiguracji DNS...}"
    if [[ -f /etc/resolv.conf.bak ]]; then
        local backup_dns
        backup_dns=$(grep "^nameserver" /etc/resolv.conf.bak | head -1 | awk '{print $2}')
        if [[ "$backup_dns" != "127.0.0.1" && -n "$backup_dns" ]]; then
            mv /etc/resolv.conf.bak /etc/resolv.conf 2>/dev/null || true
            echo "✅ ${T_RESTORED_BACKUP:-Przywrócono z backupu} (DNS: $backup_dns)"
        else
            echo "⚠️  Backup wskazuje na localhost, ignorowanie..."
            rm -f /etc/resolv.conf.bak 2>/dev/null || true
            echo "nameserver 1.1.1.1" > /etc/resolv.conf
            echo "ℹ️  ${T_SET_FALLBACK:-Ustawiono zapasowy DNS} (1.1.1.1)"
        fi
    else
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
        echo "ℹ️  ${T_SET_FALLBACK:-Ustawiono zapasowy DNS} (1.1.1.1)"
    fi

    # Test DNS
    echo "ℹ️  ${T_TESTING_DNS:-Testowanie łączności DNS...}"
    if dig +time=2 +tries=1 @1.1.1.1 google.com >/dev/null 2>&1; then
        echo "✅ ${T_DNS_OK:-Łączność DNS działa}"
    else
        echo "⚠️  ${T_DNS_FAILED:-Test DNS nie powiódł się - system może stracić internet po restarcie!}"
    fi

    echo ""

    # Zatrzymaj usługi
    echo "ℹ️  ${T_STOPPING_SERVICES:-Zatrzymywanie usług...}"
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl disable coredns dnscrypt-proxy 2>/dev/null || true

    # Usuń konfigurację systemd
    echo "ℹ️  Usuwanie konfiguracji systemd..."
    rm -rf /etc/systemd/system/coredns.service.d/ 2>/dev/null || true
    rm -rf /etc/systemd/system/dnscrypt-proxy.service.d/ 2>/dev/null || true
    systemctl daemon-reload 2>/dev/null || true

    # Usuń firewall
    echo "ℹ️  ${T_REMOVING_FIREWALL:-Usuwanie reguł firewalla...}"
    nft delete table inet citadel_dns 2>/dev/null || true
    rm -f /etc/nftables.d/citadel-dns.nft 2>/dev/null || true

    # Usuń pliki konfiguracyjne
    echo "ℹ️  ${T_REMOVING_CONFIG:-Usuwanie plików konfiguracyjnych...}"
    rm -rf /etc/coredns/ 2>/dev/null || true
    rm -rf /etc/dnscrypt-proxy/ 2>/dev/null || true

    # Usuń katalogi z danymi
    echo "ℹ️  ${T_REMOVING_DATA:-Usuwanie katalogów z danymi...}"
    rm -rf /var/lib/dnscrypt/ 2>/dev/null || true
    rm -rf /var/log/dnscrypt-proxy/ 2>/dev/null || true
    rm -rf /opt/cytadela/ 2>/dev/null || true
    rm -rf /var/cache/cytadela/ 2>/dev/null || true

    # Usuń użytkownika
    echo "ℹ️  ${T_REMOVING_USER:-Usuwanie użytkownika systemowego...}"
    userdel dnscrypt 2>/dev/null || true

    # Usuń dashboard
    echo "ℹ️  ${T_REMOVING_DASHBOARD:-Usuwanie dashboardu...}"
    rm -f /usr/local/bin/citadel-top 2>/dev/null || true
    rm -f /etc/systemd/system/citadel-dashboard.service 2>/dev/null || true

    # Usuń crony
    echo "ℹ️  ${T_REMOVING_CRON:-Usuwanie zaplanowanych zadań...}"
    rm -f /etc/cron.d/cytadela-* 2>/dev/null || true

    # Usuń skróty
    echo "ℹ️  ${T_REMOVING_SHORTCUTS:-Usuwanie skrótów poleceń...}"
    rm -f /usr/local/bin/citadel 2>/dev/null || true

    echo ""
    echo "✅ ${T_UNINSTALL_COMPLETE:-Citadel został całkowicie usunięty}"
    echo ""
    echo "ℹ️  ${T_REINSTALL_HINT:-Aby zainstalować ponownie: sudo ./citadel.sh install-wizard}"
}

citadel_uninstall_keep_config_pl() {
    # Wczytaj tłumaczenia polskie
    local module_dir
    module_dir="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
    if [[ -f "${module_dir}/lib/i18n/pl.sh" ]]; then
        # shellcheck source=/dev/null
        source "${module_dir}/lib/i18n/pl.sh"
    fi

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║  ${T_KEEP_CONFIG_TITLE:-DEINSTALACJA (Zachowaj Konfigurację)}                              ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo ""

    echo "⚠️  ${T_KEEP_CONFIG_WARNING:-To zatrzyma usługi ale ZACHOWA pliki konfiguracyjne}"
    echo ""
    read -rp "Kontynuować? Wpisz 'yes': " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "ℹ️  ${T_UNINSTALL_CANCELLED:-Anulowano}"
        return 0
    fi

    echo "ℹ️  ${T_STOPPING_SERVICES:-Zatrzymywanie usług...}"
    systemctl stop coredns dnscrypt-proxy 2>/dev/null || true
    systemctl disable coredns dnscrypt-proxy 2>/dev/null || true

    echo "✅ ${T_SERVICES_STOPPED:-Usługi zatrzymane, konfiguracja zachowana}"
    echo "ℹ️  ${T_RESTART_HINT:-Aby uruchomić ponownie: sudo ./citadel.sh install-wizard}"
}
