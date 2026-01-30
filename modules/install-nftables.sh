#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-NFTABLES MODULE v3.1                                  ║
# ║  NFTables firewall rules installation                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

install_nftables() {
    log_section "MODULE 3: NFTables Firewall Rules"

    require_cmds nft grep awk systemctl || return 1

    mkdir -p /etc/nftables.d

    local dnscrypt_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    [[ -z "$dnscrypt_port" ]] && dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"

    log_info "Tworzenie reguł firewall..."
    tee /etc/nftables.d/citadel-dns-safe.nft >/dev/null <<EOF
table inet citadel_dns {
    chain output {
        type filter hook output priority -400; policy accept;

        ip daddr {127.0.0.1, 127.0.0.53, 127.0.0.54} udp dport 53 counter accept
        ip daddr {127.0.0.1, 127.0.0.53, 127.0.0.54} tcp dport 53 counter accept
        ip daddr 127.0.0.1 udp dport ${dnscrypt_port} counter accept
        ip daddr 127.0.0.1 tcp dport ${dnscrypt_port} counter accept
        ip6 daddr ::1 udp dport {53, ${dnscrypt_port}} counter accept
        ip6 daddr ::1 tcp dport {53, ${dnscrypt_port}} counter accept

        ip daddr {9.9.9.9, 1.1.1.1, 149.112.112.112} udp dport 53 counter accept
        ip daddr {9.9.9.9, 1.1.1.1, 149.112.112.112} tcp dport 53 counter accept

        meta skuid "systemd-resolve" udp dport {53, 443, 853} counter accept
        meta skuid "systemd-resolve" tcp dport {53, 443, 853} counter accept

        ip daddr != {127.0.0.1, 127.0.0.53, 127.0.0.54} udp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
        ip daddr != {127.0.0.1, 127.0.0.53, 127.0.0.54} tcp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
    }
}

table inet citadel_emergency {
    chain output {
        type filter hook output priority -300; policy accept;
    }
}
EOF

    tee /etc/nftables.d/citadel-dns-strict.nft >/dev/null <<EOF
table inet citadel_dns {
    chain output {
        type filter hook output priority -400; policy accept;

        ip daddr 127.0.0.1 udp dport 53 counter accept
        ip daddr 127.0.0.1 tcp dport 53 counter accept
        ip6 daddr ::1 udp dport 53 counter accept
        ip6 daddr ::1 tcp dport 53 counter accept

        ip daddr 127.0.0.1 udp dport ${dnscrypt_port} counter accept
        ip daddr 127.0.0.1 tcp dport ${dnscrypt_port} counter accept
        ip6 daddr ::1 udp dport ${dnscrypt_port} counter accept
        ip6 daddr ::1 tcp dport ${dnscrypt_port} counter accept

        udp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
        tcp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
    }
}

table inet citadel_emergency {
    chain output {
        type filter hook output priority -300; policy accept;
    }
}
EOF

    ln -sf /etc/nftables.d/citadel-dns-safe.nft /etc/nftables.d/citadel-dns.nft

    if [[ -f /etc/nftables.conf ]]; then
        cp /etc/nftables.conf /etc/nftables.conf.backup-citadel
        log_info "Backup: /etc/nftables.conf -> /etc/nftables.conf.backup-citadel"
    fi

    if [[ ! -f /etc/nftables.conf ]]; then
        printf '%s\n' '#!/usr/bin/nft -f' > /etc/nftables.conf
    fi

    if [[ $(grep -cE '^[[:space:]]*include[[:space:]]+"/etc/nftables\.d/citadel-dns\.nft"[[:space:]]*$' /etc/nftables.conf 2>/dev/null || echo 0) -gt 1 ]]; then
        local tmp_nftconf=$(mktemp)
        awk 'BEGIN{seen=0}
            /^[[:space:]]*include[[:space:]]+"\/etc\/nftables\.d\/citadel-dns\.nft"[[:space:]]*$/ { if (seen==0) { print; seen=1 } ; next }
            { print }
        ' /etc/nftables.conf > "$tmp_nftconf"
        mv "$tmp_nftconf" /etc/nftables.conf
    fi

    if ! grep -qE '^[[:space:]]*include[[:space:]]+"/etc/nftables\.d/citadel-dns\.nft"[[:space:]]*$' /etc/nftables.conf; then
        printf '\ninclude "/etc/nftables.d/citadel-dns.nft"\n' >> /etc/nftables.conf
    fi

    log_info "Walidacja składni nftables..."
    if nft -c -f <(printf '%s\n' 'flush ruleset'; cat /etc/nftables.d/citadel-dns-safe.nft) \
        && nft -c -f <(printf '%s\n' 'flush ruleset'; cat /etc/nftables.d/citadel-dns-strict.nft);
    then
        log_success "Składnia nftables poprawna"
    else
        log_error "Błąd w składni nftables"
        return 1
    fi

    systemctl enable --now nftables 2>/dev/null || true
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns.nft

    log_success "Moduł NFTables zainstalowany"
}

firewall_safe() {
    log_section "MODULE 3: NFTables Safe Mode"
    ln -sf /etc/nftables.d/citadel-dns-safe.nft /etc/nftables.d/citadel-dns.nft
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns-safe.nft || log_warning "Nie udało się załadować reguł SAFE"
    log_success "Firewall ustawiony na SAFE"
}

firewall_strict() {
    log_section "MODULE 3: NFTables Strict Mode"
    ln -sf /etc/nftables.d/citadel-dns-strict.nft /etc/nftables.d/citadel-dns.nft
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns-strict.nft || log_warning "Nie udało się załadować reguł STRICT"
    log_success "Firewall ustawiony na STRICT"
}

configure_system() {
    log_section "MODULE 4: System Configuration"

    log_warning "Ten krok zmienia DNS systemu (może chwilowo przerwać internet jeśli DNS nie działa)."
    read -p "Czy na pewno chcesz kontynuować? (tak/nie): " -r
    if [[ ! $REPLY =~ ^(tak|TAK|yes|YES|y|Y)$ ]]; then
        log_info "Anulowano"
        return 0
    fi

    if command -v nft >/dev/null 2>&1 && [[ -f /etc/nftables.conf ]]; then
        firewall_safe 2>/dev/null || true
    fi

    log_info "Wyłączanie systemd-resolved..."
    systemctl stop systemd-resolved systemd-resolved.socket 2>/dev/null || true
    systemctl disable systemd-resolved systemd-resolved.socket 2>/dev/null || true
    systemctl mask systemd-resolved 2>/dev/null || true

    log_info "Konfiguracja NetworkManager..."
    mkdir -p /etc/NetworkManager/conf.d
    tee /etc/NetworkManager/conf.d/citadel-dns.conf >/dev/null <<'EOF'
[main]
dns=none
systemd-resolved=false
EOF
    systemctl restart NetworkManager 2>/dev/null || true

    log_info "Blokowanie /etc/resolv.conf..."
    chattr -i /etc/resolv.conf 2>/dev/null || true
    tee /etc/resolv.conf >/dev/null <<'EOF'
# Citadel++ DNS Configuration
nameserver 127.0.0.1
options edns0 trust-ad
EOF
    chattr +i /etc/resolv.conf 2>/dev/null || true

    log_info "Test lokalnego DNS po przełączeniu..."
    if command -v dig >/dev/null 2>&1 && dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
        log_success "DNS działa (localhost)"
        if command -v nft >/dev/null 2>&1 && [[ -f /etc/nftables.conf ]]; then
            log_info "Włączam firewall STRICT (pełna blokada DNS-leak)..."
            firewall_strict 2>/dev/null || true
        fi
    else
        log_warning "Test DNS nieudany - zostawiam firewall SAFE"
        log_warning "Rollback: sudo ./cytadela++.sh restore-system"
    fi

    log_success "Konfiguracja systemowa zakończona"
}

restore_system() {
    log_section "MODULE 4: System Restore"

    log_info "Przywracanie systemd-resolved..."
    systemctl unmask systemd-resolved 2>/dev/null || true
    systemctl enable systemd-resolved 2>/dev/null || true
    systemctl start systemd-resolved 2>/dev/null || true

    log_info "Usuwanie konfiguracji NetworkManager..."
    rm -f /etc/NetworkManager/conf.d/citadel-dns.conf
    systemctl restart NetworkManager 2>/dev/null || true

    log_info "Przywracanie /etc/resolv.conf..."
    chattr -i /etc/resolv.conf 2>/dev/null || true
    rm -f /etc/resolv.conf
    ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf 2>/dev/null || true

    log_success "System przywrócony do stanu przed Citadel++"
}
