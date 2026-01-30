#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-DNSCRYPT MODULE v3.1                                  ║
# ║  DNSCrypt-Proxy installation and configuration                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

install_dnscrypt() {
    log_section "MODULE 1: DNSCrypt-Proxy Installation"

    require_cmds ss awk grep tee systemctl dnscrypt-proxy || return 1

    if ! id dnscrypt &>/dev/null; then
        log_info "Tworzenie dedykowanego użytkownika 'dnscrypt'..."
        useradd -r -s /usr/bin/nologin -d /var/lib/dnscrypt dnscrypt
        log_success "User dnscrypt utworzony"
    else
        log_success "User dnscrypt już istnieje"
    fi

    mkdir -p /var/lib/dnscrypt /etc/dnscrypt-proxy
    chown -R dnscrypt:dnscrypt /var/lib/dnscrypt /etc/dnscrypt-proxy

    local dnscrypt_port
    dnscrypt_port=$(pick_free_port "$DNSCRYPT_PORT_DEFAULT" 5365 || true)
    if [[ -z "$dnscrypt_port" ]]; then
        log_error "Nie mogę znaleźć wolnego portu dla DNSCrypt (zakres ${DNSCRYPT_PORT_DEFAULT}-5365)"
        return 1
    fi

    log_info "Tworzenie konfiguracji DNSCrypt (z listą resolverów + weryfikacją minisign)..."
    local dnssec_value="false"
    if dnssec_enabled; then
        dnssec_value="true"
    fi
    
    tee /etc/dnscrypt-proxy/dnscrypt-proxy.toml >/dev/null <<EOF
listen_addresses = ['127.0.0.1:${dnscrypt_port}']
max_clients = 250

ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = true

require_dnssec = ${dnssec_value}
require_nolog = true
require_nofilter = false

bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53']
ignore_system_dns = true

server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

log_level = 2

[sources.'public-resolvers']
urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md']
minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
cache_file = 'public-resolvers.md'
EOF

    mkdir -p /var/log/dnscrypt-proxy
    chown -R dnscrypt:dnscrypt /var/log/dnscrypt-proxy

    log_info "Tworzenie zaawansowanej konfiguracji (opcjonalnie)..."
    tee /etc/dnscrypt-proxy/dnscrypt-proxy-advanced.toml >/dev/null <<'EOF'
# Citadel++ DNSCrypt ADVANCED Configuration
# USE ONLY IF YOUR dnscrypt-proxy VERSION SUPPORTS IT
# To activate: sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy-advanced.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

listen_addresses = ['127.0.0.1:5353', '[::1]:5353']
max_clients = 250

cache_size = 512
cache_min_ttl = 600
cache_max_ttl = 86400

ipv4_servers = true
ipv6_servers = true
dnscrypt_servers = true
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = false

bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53', '149.112.112.112:53']

[sources.'public-resolvers']
urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md']
minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
cache_file = 'public-resolvers.md'

[anonymized_dns]
routes = [
    { server_name='*', via=['anon-cs-poland', 'anon-cs-berlin', 'anon-cs-nl'] }
]

cloaking_rules = '/etc/dnscrypt-proxy/cloaking-rules.txt'

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    tee /etc/dnscrypt-proxy/cloaking-rules.txt >/dev/null <<'EOF'
# Microsoft Telemetry
vortex.data.microsoft.com                127.0.0.1
vortex-win.data.microsoft.com            127.0.0.1
telemetry.microsoft.com                  127.0.0.1
watson.telemetry.microsoft.com           127.0.0.1
settings-win.data.microsoft.com          127.0.0.1

# Google Analytics & Firebase
google-analytics.com                     127.0.0.1
firebase.googleapis.com                  127.0.0.1
firebaseinstallations.googleapis.com     127.0.0.1

# Amazon Metrics
device-metrics.us-east-1.amazonaws.com   127.0.0.1
unagi.amazon.com                         127.0.0.1

# Facebook/Meta
graph.facebook.com                       127.0.0.1
pixel.facebook.com                       127.0.0.1
EOF

    chown -R dnscrypt:dnscrypt /etc/dnscrypt-proxy

    log_info "Testowanie konfiguracji TOML..."
    if dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check; then
        log_success "Konfiguracja DNSCrypt poprawna"
    else
        log_error "Błąd w konfiguracji TOML - sprawdź logi"
        return 1
    fi

    systemctl enable --now dnscrypt-proxy 2>/dev/null || true
    systemctl restart dnscrypt-proxy
    sleep 2

    if systemctl is-active --quiet dnscrypt-proxy; then
        log_success "DNSCrypt-Proxy działa poprawnie"
    else
        log_error "DNSCrypt-Proxy nie uruchomił się - sprawdź: journalctl -u dnscrypt-proxy -n 50"
        return 1
    fi

    log_success "Moduł DNSCrypt zainstalowany"
}
