#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-ALL MODULE v3.1                                       ║
# ║  Complete installation of all modules                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

install_all() {
    log_section "󱓞 CITADEL++ FULL INSTALLATION"

    log_info "Instalacja wszystkich modułów DNS..."

    if ! declare -f install_dnscrypt >/dev/null 2>&1; then
        load_module "install-dnscrypt"
    fi
    if ! declare -f install_coredns >/dev/null 2>&1; then
        load_module "install-coredns"
    fi
    if ! declare -f install_nftables >/dev/null 2>&1; then
        load_module "install-nftables"
    fi

    install_dnscrypt
    install_coredns
    install_nftables

    echo ""
    log_section "󰇏 INSTALACJA ZAKOŃCZONA POMYŚLNIE"

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  CITADEL++ v3.1 - FULLY OPERATIONAL                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    log_info "Status serwisów:"
    systemctl --no-pager status dnscrypt-proxy coredns nftables || true

    echo ""
    log_section "󰙨 HEALTHCHECK: DNS + ADBLOCK"

    if ! declare -f adblock_rebuild >/dev/null 2>&1; then
        load_module "adblock"
    fi

    adblock_rebuild 2>/dev/null || true
    systemctl restart coredns 2>/dev/null || true
    sleep 1
    adblock_stats 2>/dev/null || true

    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
            echo "  󰄬 DNS (google.com) via 127.0.0.1: OK"
        else
            echo "  󰅖 DNS (google.com) via 127.0.0.1: FAILED"
        fi

        local test_domain
        test_domain="$(awk 'NF>=2 {print $2; exit}' /etc/coredns/zones/custom.hosts 2>/dev/null || true)"
        [[ -z "$test_domain" ]] && test_domain="$(awk 'NF>=2 {print $2; exit}' /etc/coredns/zones/combined.hosts 2>/dev/null || true)"
        if [[ -z "$test_domain" ]]; then
            echo "  󰀨 Adblock test: custom.hosts/combined.hosts empty/missing"
        else
            if dig +time=2 +tries=1 +short "$test_domain" @127.0.0.1 2>/dev/null | head -n 1 | grep -qx "0.0.0.0"; then
                echo "  󰄬 Adblock test ($test_domain): BLOCKED (0.0.0.0)"
            else
                echo "  󰅖 Adblock test ($test_domain): FAILED"
            fi
        fi
    else
        log_warning "Brak narzędzia 'dig' - pomijam testy DNS/Adblock"
    fi

    echo ""
    log_info "Testy diagnostyczne:"
    echo "  1. Test DNS:        dig +short google.com @127.0.0.1"
    echo "  2. Test metryki:    curl -s http://127.0.0.1:9153/metrics | grep coredns_"
    echo "  3. DNSCrypt logi:   journalctl -u dnscrypt-proxy -f"
    echo "  4. CoreDNS logi:    journalctl -u coredns -f"
    echo "  5. Firewall:        sudo nft list ruleset | grep citadel"
    echo "  6. Leak test:       dig @8.8.8.8 test.com (powinno być zablokowane)"
    echo ""

    log_info "Aby przełączyć system na Citadel (wyłączyć resolved):"
    echo "  sudo ./Citadel.sh configure-system"
    log_info "Rollback (jeśli coś pójdzie źle):"
    echo "  sudo ./Citadel.sh restore-system"
}
