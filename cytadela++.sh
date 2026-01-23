#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL++ v3.0 - FORTIFIED DNS INFRASTRUCTURE                           ║
# ║  Advanced Hardened Resolver with Full Privacy Stack                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Architecture: Modular multi-layer defense system
# - Layer 1: DNSCrypt-Proxy (encrypted upstream + optional anonymization)
# - Layer 2: CoreDNS (caching, blocking, metrics)
# - Layer 3: NFTables (leak prevention, kill-switch)
# - Layer 4: Monitoring & Auto-update (Prometheus + systemd timers)
#
# Threat Model: ISP tracking, DNS leaks, malware, telemetry, metadata exposure
# Location: Lower Silesia, PL – Optimized EU/PL relays with IPv6 support
# ==============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${CYAN}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_section() { echo -e "\n${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"; echo -e "${BLUE}║${NC} $1"; echo -e "${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}\n"; }

# Root check
if [[ $EUID -ne 0 ]]; then
    log_error "Ten skrypt wymaga uprawnień root. Uruchom: sudo $0"
    exit 1
fi

ACTION=${1:-help}
ARG1=${2:-}
ARG2=${3:-}

 DNSCRYPT_PORT_DEFAULT=5353
 COREDNS_PORT_DEFAULT=53
 COREDNS_METRICS_ADDR="127.0.0.1:9153"

 port_in_use() {
     local port="$1"
     ss -H -lntu | awk '{print $5}' | grep -Eq "(^|:)${port}$" 2>/dev/null
 }

 pick_free_port() {
     local start="$1"
     local end="$2"
     local p
     for p in $(seq "$start" "$end"); do
         if ! port_in_use "$p"; then
             echo "$p"
             return 0
         fi
     done
     return 1
 }

 get_dnscrypt_listen_port() {
     local cfg="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
     if [[ -f "$cfg" ]]; then
         awk -F"[:']" '/^listen_addresses[[:space:]]*=/{for(i=1;i<=NF;i++){if($i ~ /^[0-9]+$/){print $i; exit}}}' "$cfg" 2>/dev/null || true
     fi
 }

 get_coredns_listen_port() {
     local cfg="/etc/coredns/Corefile"
     if [[ -f "$cfg" ]]; then
         awk -F'[:}]' '/^\.:/{gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' "$cfg" 2>/dev/null || true
     fi
 }

# ==============================================================================
# MODULE 1: DNSCrypt-Proxy - Encrypted DNS with Privacy Relays
# ==============================================================================
install_dnscrypt() {
    log_section "MODULE 1: DNSCrypt-Proxy Installation"

    # Create dedicated user
    if ! id dnscrypt &>/dev/null; then
        log_info "Tworzenie dedykowanego użytkownika 'dnscrypt'..."
        useradd -r -s /usr/bin/nologin -d /var/lib/dnscrypt dnscrypt
        log_success "User dnscrypt utworzony"
    else
        log_success "User dnscrypt już istnieje"
    fi

    # Setup directories
    mkdir -p /var/lib/dnscrypt /etc/dnscrypt-proxy
    chown -R dnscrypt:dnscrypt /var/lib/dnscrypt /etc/dnscrypt-proxy

    local dnscrypt_port
    dnscrypt_port=$(pick_free_port "$DNSCRYPT_PORT_DEFAULT" 5365 || true)
    if [[ -z "$dnscrypt_port" ]]; then
        log_error "Nie mogę znaleźć wolnego portu dla DNSCrypt (zakres ${DNSCRYPT_PORT_DEFAULT}-5365)"
        return 1
    fi

    # Create configuration - MINIMAL VERSION
    log_info "Tworzenie konfiguracji DNSCrypt (z listą resolverów + weryfikacją minisign)..."
    tee /etc/dnscrypt-proxy/dnscrypt-proxy.toml >/dev/null <<EOF
listen_addresses = ['127.0.0.1:${dnscrypt_port}']
max_clients = 250

ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = true

require_dnssec = false
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

    # Create log directory
    mkdir -p /var/log/dnscrypt-proxy
    chown -R dnscrypt:dnscrypt /var/log/dnscrypt-proxy

    # Advanced configuration file for future upgrades (with anonymization)
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

# Anonymized DNS (requires working relays)
[anonymized_dns]
routes = [
    { server_name='*', via=['anon-cs-poland', 'anon-cs-berlin', 'anon-cs-nl'] }
]

# Cloaking rules (redirect telemetry to localhost)
cloaking_rules = '/etc/dnscrypt-proxy/cloaking-rules.txt'

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    # Create cloaking rules file
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

    # Test configuration
    log_info "Testowanie konfiguracji TOML..."
    if dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check; then
        log_success "Konfiguracja DNSCrypt poprawna"
    else
        log_error "Błąd w konfiguracji TOML - sprawdź logi"
        return 1
    fi

    # Enable and start service
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

# ==============================================================================
# MODULE 2: CoreDNS - Caching, Blocking & Metrics
# ==============================================================================
install_coredns() {
    log_section "MODULE 2: CoreDNS Installation"

    # Determine current DNSCrypt listen port early (needed for bootstrap DNS)
    local dnscrypt_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    if [[ -z "$dnscrypt_port" ]]; then
        dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    fi

    # Create directories
    mkdir -p /etc/coredns/zones
    touch /etc/coredns/zones/custom.hosts
    touch /etc/coredns/zones/blocklist.hosts
    touch /etc/coredns/zones/combined.hosts
    chmod 0644 /etc/coredns/zones/custom.hosts 2>/dev/null || true
    chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
    chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true

    # Bootstrap CoreDNS so system DNS works during downloads (when resolv.conf points to 127.0.0.1)
    log_info "Bootstrap DNS (CoreDNS forward -> DNSCrypt) na czas pobierania list..."
    tee /etc/coredns/Corefile >/dev/null <<EOF
.:${COREDNS_PORT_DEFAULT} {
    bind 127.0.0.1
    errors
    forward . 127.0.0.1:${dnscrypt_port}
}
EOF
    systemctl enable --now coredns 2>/dev/null || true
    systemctl restart coredns 2>/dev/null || true
    sleep 1

    # Download blocklists
    log_info "Pobieranie blocklist (OISD + KADhosts + Polish Annoyance)..."
    {
        local tmp_raw tmp_block tmp_combined
        tmp_raw="$(mktemp)"
        tmp_block="$(mktemp)"
        tmp_combined="$(mktemp)"

        curl -fsSL https://big.oisd.nl | grep -v "^#" > "$tmp_raw"
        curl -fsSL https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt | grep -v "^#" >> "$tmp_raw"
        curl -fsSL https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt | grep -v "^#" >> "$tmp_raw"

        awk '
            function emit(d) {
                gsub(/^[*.]+/, "", d)
                gsub(/[[:space:]]+$/, "", d)
                if (d ~ /^[A-Za-z0-9.-]+$/ && d ~ /\./) print "0.0.0.0 " d
            }
            {
                line=$0
                sub(/\r$/, "", line)
                if (line ~ /^[[:space:]]*$/) next
                if (line ~ /^[[:space:]]*!/) next

                # hosts format: 0.0.0.0 domain
                if (line ~ /^(0\.0\.0\.0|127\.0\.0\.1|::)[[:space:]]+/) {
                    n=split(line, a, /[[:space:]]+/)
                    if (n >= 2) {
                        d=a[2]
                        sub(/^\|\|/, "", d)
                        sub(/[\^\/].*$/, "", d)
                        emit(d)
                    }
                    next
                }

                # adblock format: ||domain^ (or ||domain/path)
                if (line ~ /^\|\|/) {
                    sub(/^\|\|/, "", line)
                    sub(/[\^\/].*$/, "", line)
                    emit(line)
                    next
                }

                # plain domain
                if (line ~ /^[A-Za-z0-9.*-]+(\.[A-Za-z0-9.-]+)+$/) {
                    emit(line)
                    next
                }
            }
        ' "$tmp_raw" | sort -u > "$tmp_block"

        if [[ $(wc -l < "$tmp_block") -lt 1000 ]]; then
            log_warning "Blocklist wygląda na pustą/uszkodzoną ($(wc -l < "$tmp_block") wpisów) - zostawiam poprzednią"
            rm -f "$tmp_raw" "$tmp_block" "$tmp_combined"
            tmp_combined="$(mktemp)"
            cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u > "$tmp_combined"
            mv "$tmp_combined" /etc/coredns/zones/combined.hosts
            chown root:coredns /etc/coredns/zones/combined.hosts 2>/dev/null || true
            chmod 0640 /etc/coredns/zones/combined.hosts 2>/dev/null || true
        else
            mv "$tmp_block" /etc/coredns/zones/blocklist.hosts
            cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u > "$tmp_combined"
            mv "$tmp_combined" /etc/coredns/zones/combined.hosts
            rm -f "$tmp_raw"
            chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
            chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
            log_success "Blocklist pobrana ($(wc -l < /etc/coredns/zones/blocklist.hosts) wpisów)"
        fi
    } || {
        log_warning "Nie udało się pobrać blocklist - tworzę pusty plik"
        touch /etc/coredns/zones/blocklist.hosts
        adblock_rebuild 2>/dev/null || true
    }

    log_info "Tworzenie konfiguracji CoreDNS..."
    tee /etc/coredns/Corefile >/dev/null <<EOF
${COREDNS_METRICS_ADDR} {
    prometheus
}

.:${COREDNS_PORT_DEFAULT} {
    bind 127.0.0.1
    errors
    log
    hosts /etc/coredns/zones/combined.hosts {
        fallthrough
    }
    cache 30
    forward . 127.0.0.1:${dnscrypt_port}
    loop
    reload
}
EOF

    cp /etc/coredns/Corefile /etc/coredns/Corefile.citadel

    # Create auto-update service
    log_info "Konfiguracja automatycznej aktualizacji blocklist..."
    tee /etc/systemd/system/citadel-update-blocklist.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ Blocklist Auto-Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'set -e; tmp_raw="$(mktemp)"; tmp_block="$(mktemp)"; tmp_combined="$(mktemp)"; curl -fsSL https://big.oisd.nl | grep -v "^#" > "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt | grep -v "^#" >> "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt | grep -v "^#" >> "$tmp_raw"; awk "function emit(d){gsub(/^[*.]+/,\"\",d); gsub(/[[:space:]]+$/,\"\",d); if(d ~ /^[A-Za-z0-9.-]+$/ && d ~ /\\./) print \"0.0.0.0 \" d} {line=\$0; sub(/\\r$/,\"\",line); if(line ~ /^[[:space:]]*$/) next; if(line ~ /^[[:space:]]*!/) next; if(line ~ /^(0\\.0\\.0\\.0|127\\.0\\.0\\.1|::)[[:space:]]+/){n=split(line,a,/[[:space:]]+/); if(n>=2){d=a[2]; sub(/^\\|\\|/,\"\",d); sub(/[\\^\\/].*$/,\"\",d); emit(d)}; next} if(line ~ /^\\|\\|/){sub(/^\\|\\|/,\"\",line); sub(/[\\^\\/].*$/,\"\",line); emit(line); next} if(line ~ /^[A-Za-z0-9.*-]+(\\.[A-Za-z0-9.-]+)+$/){emit(line); next}}" "$tmp_raw" | sort -u > "$tmp_block"; if [ "$(wc -l < \"$tmp_block\")" -lt 1000 ]; then rm -f "$tmp_raw" "$tmp_block" "$tmp_combined"; logger "Citadel++ blocklist update failed (too few entries)"; exit 0; fi; mv "$tmp_block" /etc/coredns/zones/blocklist.hosts; cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u > "$tmp_combined"; mv "$tmp_combined" /etc/coredns/zones/combined.hosts; chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; rm -f "$tmp_raw"; systemctl reload coredns; logger "Citadel++ blocklist updated successfully"'
EOF

    tee /etc/systemd/system/citadel-update-blocklist.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel++ Daily Blocklist Update

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now citadel-update-blocklist.timer

    # Start CoreDNS
    systemctl enable --now coredns 2>/dev/null || true
    systemctl restart coredns
    sleep 2

    if systemctl is-active --quiet coredns; then
        log_success "CoreDNS działa poprawnie"
    else
        log_error "CoreDNS nie uruchomił się - sprawdź: journalctl -u coredns -n 50"
        return 1
    fi

    log_success "Moduł CoreDNS zainstalowany"
}

adblock_rebuild() {
    local custom="/etc/coredns/zones/custom.hosts"
    local blocklist="/etc/coredns/zones/blocklist.hosts"
    local combined="/etc/coredns/zones/combined.hosts"

    mkdir -p /etc/coredns/zones
    touch "$custom" "$blocklist"
    chmod 0644 "$custom" 2>/dev/null || true
    cat "$custom" "$blocklist" | sort -u > "$combined"
    chown root:coredns "$blocklist" "$combined" 2>/dev/null || true
    chmod 0640 "$blocklist" "$combined" 2>/dev/null || true
}

adblock_reload() {
    systemctl reload coredns 2>/dev/null || systemctl restart coredns 2>/dev/null || true
}

adblock_status() {
    log_section "🧱 CITADEL++ ADBLOCK STATUS"

    if systemctl is-active --quiet coredns; then
        echo "  ✓ coredns: running"
    else
        echo "  ✗ coredns: not running"
    fi

    if [[ -f /etc/coredns/Corefile ]] && grep -q '/etc/coredns/zones/combined\.hosts' /etc/coredns/Corefile; then
        echo "  ✓ Corefile: uses combined.hosts"
    else
        echo "  ✗ Corefile: missing combined.hosts"
    fi

    if [[ -f /etc/coredns/zones/custom.hosts ]]; then
        echo "  ✓ custom.hosts:   $(wc -l < /etc/coredns/zones/custom.hosts)"
    else
        echo "  ✗ custom.hosts: missing"
    fi
    if [[ -f /etc/coredns/zones/blocklist.hosts ]]; then
        echo "  ✓ blocklist.hosts: $(wc -l < /etc/coredns/zones/blocklist.hosts)"
    else
        echo "  ✗ blocklist.hosts: missing"
    fi
    if [[ -f /etc/coredns/zones/combined.hosts ]]; then
        echo "  ✓ combined.hosts:  $(wc -l < /etc/coredns/zones/combined.hosts)"
    else
        echo "  ✗ combined.hosts: missing"
    fi
}

adblock_stats() {
    log_section "📈 CITADEL++ ADBLOCK STATS"
    echo "custom.hosts:   $(wc -l < /etc/coredns/zones/custom.hosts 2>/dev/null || echo 0)"
    echo "blocklist.hosts: $(wc -l < /etc/coredns/zones/blocklist.hosts 2>/dev/null || echo 0)"
    echo "combined.hosts:  $(wc -l < /etc/coredns/zones/combined.hosts 2>/dev/null || echo 0)"
}

adblock_show() {
    local which="$1"
    case "$which" in
        custom)
            sed -n '1,200p' /etc/coredns/zones/custom.hosts 2>/dev/null || true
            ;;
        blocklist)
            sed -n '1,200p' /etc/coredns/zones/blocklist.hosts 2>/dev/null || true
            ;;
        combined)
            sed -n '1,200p' /etc/coredns/zones/combined.hosts 2>/dev/null || true
            ;;
        *)
            log_error "Użycie: adblock-show custom|blocklist|combined"
            return 1
            ;;
    esac
}

adblock_query() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: adblock-query domena"
        return 1
    fi
    dig +short @127.0.0.1 "$domain" 2>/dev/null || true
}

adblock_add() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: adblock-add domena"
        return 1
    fi
    if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Nieprawidłowa domena: $domain"
        return 1
    fi
    mkdir -p /etc/coredns/zones
    touch /etc/coredns/zones/custom.hosts
    if grep -qE "^[0-9.:]+[[:space:]]+${domain}$" /etc/coredns/zones/custom.hosts 2>/dev/null; then
        log_info "Już istnieje w custom.hosts: $domain"
    else
        printf '0.0.0.0 %s\n' "$domain" >> /etc/coredns/zones/custom.hosts
        log_success "Dodano do custom.hosts: $domain"
    fi
    adblock_rebuild
    adblock_reload
}

adblock_remove() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: adblock-remove domena"
        return 1
    fi
    if [[ ! -f /etc/coredns/zones/custom.hosts ]]; then
        log_warning "Brak /etc/coredns/zones/custom.hosts"
        return 0
    fi
    sed -i -E "/^[0-9.:]+[[:space:]]+${domain//./\.}([[:space:]]|
|$)/d" /etc/coredns/zones/custom.hosts || true
    log_success "Usunięto z custom.hosts (jeśli istniało): $domain"
    adblock_rebuild
    adblock_reload
}

adblock_edit() {
    local editor
    editor="${EDITOR:-}"
    [[ -z "$editor" ]] && command -v micro >/dev/null 2>&1 && editor="micro"
    [[ -z "$editor" ]] && editor="nano"
    mkdir -p /etc/coredns/zones
    touch /etc/coredns/zones/custom.hosts
    "$editor" /etc/coredns/zones/custom.hosts
    adblock_rebuild
    adblock_reload
}

# ==============================================================================
# MODULE 3: NFTables - Leak Prevention & Kill-Switch
# ==============================================================================
install_nftables() {
    log_section "MODULE 3: NFTables Firewall Rules"

    mkdir -p /etc/nftables.d

    local dnscrypt_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    if [[ -z "$dnscrypt_port" ]]; then
        dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    fi

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

    # Backup existing config
    if [[ -f /etc/nftables.conf ]]; then
        cp /etc/nftables.conf /etc/nftables.conf.backup-citadel
        log_info "Backup: /etc/nftables.conf -> /etc/nftables.conf.backup-citadel"
    fi

    if [[ ! -f /etc/nftables.conf ]]; then
        printf '%s\n' '#!/usr/bin/nft -f' > /etc/nftables.conf
    fi

    if ! grep -qE '^[[:space:]]*include[[:space:]]+"/etc/nftables\.d/citadel-dns\.nft"[[:space:]]*$' /etc/nftables.conf; then
        printf '\ninclude "/etc/nftables.d/citadel-dns.nft"\n' >> /etc/nftables.conf
    fi

    # Validate syntax
    log_info "Walidacja składni nftables..."
    if nft -c -f <(printf '%s\n' 'flush ruleset'; cat /etc/nftables.d/citadel-dns-safe.nft) \
        && nft -c -f <(printf '%s\n' 'flush ruleset'; cat /etc/nftables.d/citadel-dns-strict.nft);
    then
        log_success "Składnia nftables poprawna"
    else
        log_error "Błąd w składni nftables"
        return 1
    fi

    # Load rules
    systemctl enable --now nftables 2>/dev/null || true
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
    nft -f /etc/nftables.d/citadel-dns-safe.nft || log_warning "Nie udało się załadować reguł SAFE (sprawdź: sudo nft -c -f /etc/nftables.d/citadel-dns-safe.nft)"
    log_success "Firewall ustawiony na SAFE"
}

firewall_strict() {
    log_section "MODULE 3: NFTables Strict Mode"
    ln -sf /etc/nftables.d/citadel-dns-strict.nft /etc/nftables.d/citadel-dns.nft
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns-strict.nft || log_warning "Nie udało się załadować reguł STRICT (sprawdź: sudo nft -c -f /etc/nftables.d/citadel-dns-strict.nft)"
    log_success "Firewall ustawiony na STRICT"
}

# ==============================================================================
# MODULE 4: System Configuration
# ==============================================================================
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

    # Disable systemd-resolved
    log_info "Wyłączanie systemd-resolved..."
    systemctl stop systemd-resolved systemd-resolved.socket 2>/dev/null || true
    systemctl disable systemd-resolved systemd-resolved.socket 2>/dev/null || true
    systemctl mask systemd-resolved 2>/dev/null || true

    # Configure NetworkManager
    log_info "Konfiguracja NetworkManager..."
    mkdir -p /etc/NetworkManager/conf.d
    tee /etc/NetworkManager/conf.d/citadel-dns.conf >/dev/null <<'EOF'
[main]
dns=none
systemd-resolved=false
EOF
    systemctl restart NetworkManager 2>/dev/null || true

    # Lock resolv.conf
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
        log_warning "Rollback: sudo ./citadela++.sh restore-system"
    fi

    log_success "Konfiguracja systemowa zakończona"
}

 restore_system() {
     log_section "MODULE 4: Restore System DNS"

     chattr -i /etc/resolv.conf 2>/dev/null || true

     systemctl unmask systemd-resolved 2>/dev/null || true
     systemctl enable --now systemd-resolved systemd-resolved.socket 2>/dev/null || true

     rm -f /etc/NetworkManager/conf.d/citadel-dns.conf 2>/dev/null || true
     systemctl restart NetworkManager 2>/dev/null || true

     if [[ -e /run/systemd/resolve/stub-resolv.conf ]]; then
         ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
     fi

     log_success "Przywrócono systemd-resolved i ustawienia DNS"
 }

# ==============================================================================
# FULL INSTALLATION
# ==============================================================================
install_all() {
    log_section "CITADEL++ FULL INSTALLATION"

    install_dnscrypt
    install_coredns
    install_nftables

    echo ""
    log_section "🎉 INSTALACJA ZAKOŃCZONA POMYŚLNIE"

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  CITADEL++ v3.0 - FULLY OPERATIONAL                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Status check
    log_info "Status serwisów:"
    systemctl --no-pager status dnscrypt-proxy coredns nftables || true

    echo ""
    log_section "🧪 HEALTHCHECK: DNS + ADBLOCK"
    adblock_rebuild 2>/dev/null || true
    systemctl restart coredns 2>/dev/null || true
    sleep 1
    adblock_stats 2>/dev/null || true

    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
            echo "  ✓ DNS (google.com) via 127.0.0.1: OK"
        else
            echo "  ✗ DNS (google.com) via 127.0.0.1: FAILED"
        fi

        local test_domain
        test_domain="$(awk 'NF>=2 {print $2; exit}' /etc/coredns/zones/custom.hosts 2>/dev/null || true)"
        [[ -z "$test_domain" ]] && test_domain="$(awk 'NF>=2 {print $2; exit}' /etc/coredns/zones/combined.hosts 2>/dev/null || true)"
        if [[ -z "$test_domain" ]]; then
            echo "  ⚠ Adblock test: custom.hosts/combined.hosts empty/missing"
        else
            if dig +time=2 +tries=1 +short "$test_domain" @127.0.0.1 2>/dev/null | head -n 1 | grep -qx "0.0.0.0"; then
                echo "  ✓ Adblock test ($test_domain): BLOCKED (0.0.0.0)"
            else
                echo "  ✗ Adblock test ($test_domain): FAILED"
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

    log_info "Aby przełączyć system na Citadel++ (wyłączyć resolved):"
    echo "  sudo ./citadela++.sh configure-system"
    log_info "Rollback (jeśli coś pójdzie źle):"
    echo "  sudo ./citadela++.sh restore-system"
}

# ==============================================================================
# EMERGENCY MODES
# ==============================================================================
emergency_refuse() {
    log_section "⚠️  EMERGENCY REFUSE MODE"
    systemctl stop dnscrypt-proxy
    tee /etc/coredns/Corefile >/dev/null <<'EOF'
.:53 {
    errors
    refuse .
}
EOF
    systemctl restart coredns
    log_warning "DNS REFUSE MODE AKTYWNY - wszystkie zapytania odrzucane"
}

emergency_restore() {
    log_section "♻️  RESTORING NORMAL MODE"
    cp /etc/coredns/Corefile.citadel /etc/coredns/Corefile
    systemctl start dnscrypt-proxy
    systemctl restart coredns
    log_success "Normalny tryb przywrócony"
}

emergency_killswitch_on() {
    log_section "☢️  EMERGENCY KILL-SWITCH ACTIVATED"
    nft add rule inet citadel_emergency output ip daddr != 127.0.0.1 udp dport 53 drop
    nft add rule inet citadel_emergency output tcp dport 53 drop
    log_warning "Kill-switch AKTYWNY - cały ruch DNS poza localhost zablokowany"
}

emergency_killswitch_off() {
    log_section "♻️  KILL-SWITCH DEACTIVATED"
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.conf
    log_success "Kill-switch wyłączony"
}

# ==============================================================================
# DIAGNOSTIC TOOLS
# ==============================================================================
run_diagnostics() {
    log_section "🔍 CITADEL++ DIAGNOSTICS"

    echo -e "${CYAN}Service Status:${NC}"
    systemctl status --no-pager dnscrypt-proxy coredns nftables || true

    echo -e "\n${CYAN}DNS Resolution Test:${NC}"
    dig +short whoami.cloudflare @127.0.0.1 || log_error "DNS resolution failed"

    echo -e "\n${CYAN}Prometheus Metrics:${NC}"
    curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" || log_error "Metrics unavailable"

    echo -e "\n${CYAN}DNSCrypt Activity (last 20 lines):${NC}"
    journalctl -u dnscrypt-proxy -n 20 --no-pager

    echo -e "\n${CYAN}Firewall Rules:${NC}"
    nft list ruleset | grep -A 10 citadel

    echo -e "\n${CYAN}Blocklist Stats:${NC}"
    wc -l /etc/coredns/zones/blocklist.hosts
}

verify_stack() {
    log_section "✅ CITADEL++ VERIFY"

    local dnscrypt_port
    local coredns_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    coredns_port="$(get_coredns_listen_port || true)"
    [[ -z "$dnscrypt_port" ]] && dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    [[ -z "$coredns_port" ]] && coredns_port="$COREDNS_PORT_DEFAULT"

    echo -e "${CYAN}Ports:${NC}"
    echo "  DNSCrypt listen: 127.0.0.1:${dnscrypt_port}"
    echo "  CoreDNS listen:  127.0.0.1:${coredns_port}"
    echo "  Metrics:         ${COREDNS_METRICS_ADDR}"

    echo -e "\n${CYAN}Services:${NC}"
    systemctl is-active --quiet dnscrypt-proxy && echo "  ✓ dnscrypt-proxy: running" || echo "  ✗ dnscrypt-proxy: not running"
    systemctl is-active --quiet coredns && echo "  ✓ coredns:        running" || echo "  ✗ coredns:        not running"

    echo -e "\n${CYAN}Firewall:${NC}"
    if nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "  ✓ nftables rules: loaded (inet citadel_dns)"
    else
        echo "  ✗ nftables rules: not loaded"
    fi
    if [[ -L /etc/nftables.d/citadel-dns.nft ]]; then
        local target
        target=$(readlink -f /etc/nftables.d/citadel-dns.nft || true)
        case "$target" in
            */citadel-dns-safe.nft) echo "  Mode: SAFE" ;;
            */citadel-dns-strict.nft) echo "  Mode: STRICT" ;;
            *) echo "  Mode: unknown ($target)" ;;
        esac
    fi

    echo -e "\n${CYAN}DNS tests:${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 -p "$coredns_port" >/dev/null 2>&1; then
            echo "  ✓ Local DNS OK"
        else
            echo "  ✗ Local DNS FAILED"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo -e "\n${CYAN}Metrics:${NC}"
    if command -v curl >/dev/null 2>&1 && curl -s "http://${COREDNS_METRICS_ADDR}/metrics" >/dev/null 2>&1; then
        echo "  ✓ Prometheus endpoint OK"
    else
        echo "  ✗ Prometheus endpoint FAILED"
    fi
}

# ==============================================================================
# NEW FEATURES MODULE 5: Smart IPv6 Detection
# ==============================================================================
smart_ipv6_detection() {
    log_section "🔍 SMART IPv6 DETECTION & AUTO-RECONFIGURATION"
    
    # Detect IPv6 connectivity
    log_info "Sprawdzanie łączności IPv6..."
    IPV6_AVAILABLE=false
    
    if ping6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        IPV6_AVAILABLE=true
        log_success "IPv6 dostępny"
    else
        log_warning "IPv6 niedostępny - konfiguruję tylko IPv4"
    fi
    
    # Auto-reconfigure DNSCrypt based on IPv6 availability (do not touch listen_addresses/ports)
    local dnscrypt_config="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

    if [[ -f "$dnscrypt_config" ]]; then
        log_info "Aktualizacja konfiguracji DNSCrypt dla IPv6..."

        if grep -qE '^ipv6_servers[[:space:]]*=' "$dnscrypt_config"; then
            if [[ "$IPV6_AVAILABLE" == "true" ]]; then
                sed -i 's/^ipv6_servers[[:space:]]*=.*$/ipv6_servers = true/' "$dnscrypt_config"
                log_success "ipv6_servers = true"
            else
                sed -i 's/^ipv6_servers[[:space:]]*=.*$/ipv6_servers = false/' "$dnscrypt_config"
                log_success "ipv6_servers = false"
            fi
        else
            if [[ "$IPV6_AVAILABLE" == "true" ]]; then
                printf '\nipv6_servers = true\n' >> "$dnscrypt_config"
                log_success "Dodano ipv6_servers = true"
            else
                printf '\nipv6_servers = false\n' >> "$dnscrypt_config"
                log_success "Dodano ipv6_servers = false"
            fi
        fi

        systemctl is-active --quiet dnscrypt-proxy && systemctl restart dnscrypt-proxy
    fi
    
    echo "IPv6 Status: $IPV6_AVAILABLE"
}

# ==============================================================================
# NEW FEATURES MODULE 6: Terminal Dashboard
# ==============================================================================
install_citadel_top() {
    log_section "📊 TERMINAL DASHBOARD INSTALLATION"
    
    # Install dependencies
    log_info "Instalowanie zależności dla dashboard..."
    pacman -Q curl jq >/dev/null || sudo pacman -S curl jq --noconfirm
    
    # Create citadel-top script
    sudo tee /usr/local/bin/citadel-top >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Terminal Dashboard v1.0

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    CITADEL++ DASHBOARD                        ║"
echo "║                   Real-time DNS Monitor                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    CITADEL++ DASHBOARD                        ║"
    echo "║                   $(date '+%Y-%m-%d %H:%M:%S')                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "🔥 SERVICE STATUS:"
    systemctl is-active dnscrypt-proxy >/dev/null && echo "✓ DNSCrypt-Proxy: RUNNING" || echo "✗ DNSCrypt-Proxy: STOPPED"
    systemctl is-active coredns >/dev/null && echo "✓ CoreDNS: RUNNING" || echo "✗ CoreDNS: STOPPED"
    if sudo -n nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "✓ NFTables: RULES LOADED"
    else
        systemctl is-active nftables >/dev/null && echo "✓ NFTables: RUNNING" || echo "✗ NFTables: STOPPED"
    fi
    echo ""
    
    echo "📊 PROMETHEUS METRICS:"
    if curl -s http://127.0.0.1:9153/metrics >/dev/null 2>&1; then
        QUERIES=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" | tail -1 | awk '{print $2}')
        CACHE_HITS=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_cache_hits_total" | tail -1 | awk '{print $2}')
        echo "  Total Queries: ${QUERIES:-0}"
        echo "  Cache Hits: ${CACHE_HITS:-0}"
    else
        echo "  Metrics unavailable"
    fi
    echo ""
    
    echo "🌐 NETWORK STATUS:"
    echo "  DNS Resolution: $(dig +short google.com @127.0.0.1 -p ${COREDNS_PORT} 2>/dev/null | head -1 || echo "FAILED")"
    echo "  External IP: $(curl -s https://api.ipify.org 2>/dev/null || echo "UNKNOWN")"
    echo ""
    
    echo "⚡ PERFORMANCE:"
    if command -v ss >/dev/null; then
        DNS_CONNECTIONS=$(ss -tn | grep :53 | wc -l)
        echo "  Active DNS Connections: $DNS_CONNECTIONS"
    fi
    echo ""
    
    echo "🔥 SYSTEM LOAD:"
    echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
    echo "  Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
    echo ""
    
    echo "Press Ctrl+C to exit | Refresh: 5s"
    sleep 5
done
EOF
    
    sudo chmod +x /usr/local/bin/citadel-top
    log_success "Dashboard zainstalowany: uruchom 'citadel-top'"
}

# ==============================================================================
# NEW FEATURES MODULE 7: Editor Integration
# ==============================================================================
install_editor_integration() {
    log_section "✏️ EDITOR INTEGRATION SETUP"
    
    # Install micro editor
    if ! command -v micro >/dev/null; then
        log_info "Instalowanie edytora micro..."
        yay -S micro --noconfirm
    fi
    
    # Create citadel edit command
    sudo tee /usr/local/bin/citadel >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Editor Integration v1.0

ACTION=${1:-help}
CONFIG_DIR="/etc/coredns"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

case "$ACTION" in
    edit)
        echo "📝 Opening Citadel++ configuration in micro editor..."
        sudo micro "$CONFIG_DIR/Corefile"
        echo "🔄 Restarting CoreDNS..."
        sudo systemctl restart coredns
        echo "✓ CoreDNS reloaded with new configuration"
        ;;
    edit-dnscrypt)
        echo "📝 Opening DNSCrypt configuration..."
        sudo micro "$DNSCRYPT_CONFIG"
        echo "🔄 Restarting DNSCrypt..."
        sudo systemctl restart dnscrypt-proxy
        echo "✓ DNSCrypt reloaded with new configuration"
        ;;
    status)
        echo "📊 Citadel++ Status:"
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    logs)
        echo "📋 Recent logs:"
        journalctl -u dnscrypt-proxy -u coredns -n 20 --no-pager
        ;;
    test)
        echo "🧪 Testing DNS resolution..."
        dig +short whoami.cloudflare @127.0.0.1 || echo "❌ DNS test failed"
        ;;
    help|--help|-h)
        cat <<HELP
Citadel++ Editor Integration

Commands:
  citadel edit         Edit CoreDNS config and auto-restart
  citadel edit-dnscrypt Edit DNSCrypt config and auto-restart  
  citadel status       Show service status
  citadel logs         Show recent logs
  citadel test         Test DNS resolution
  citadel help         Show this help

Examples:
  citadel edit         # Edit CoreDNS configuration
  citadel edit-dnscrypt # Edit DNSCrypt configuration
HELP
        ;;
    *)
        echo "Unknown command. Use 'citadel help' for usage."
        exit 1
        ;;
esac
EOF
    
    sudo chmod +x /usr/local/bin/citadel
    log_success "Editor integration zainstalowany: użyj 'citadel edit'"
}

# ==============================================================================
# NEW FEATURES MODULE 8: Kernel Priority Optimization
# ==============================================================================
optimize_kernel_priority() {
    log_section "⚡ KERNEL PRIORITY OPTIMIZATION"
    
    # Check if running on CachyOS/Arch
    if [[ ! -f /etc/arch-release ]]; then
        log_warning "Ta funkcja jest zoptymalizowana dla CachyOS/Arch Linux"
        return 1
    fi
    
    # Create systemd service for DNS priority optimization
    sudo tee /etc/systemd/system/citadel-dns-priority.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Optimization
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '
# Set real-time priority for DNS processes
renice -20 $(pgrep dnscrypt-proxy) 2>/dev/null || true
renice -15 $(pgrep coredns) 2>/dev/null || true
ionice -c 1 -n 7 $(pgrep dnscrypt-proxy) 2>/dev/null || true
ionice -c 1 -n 7 $(pgrep coredns) 2>/dev/null || true
logger "Citadel++: Applied real-time priority to DNS processes"
'
EOF

    sudo tee /etc/systemd/system/citadel-dns-priority.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Timer
Requires=citadel-dns-priority.service

[Timer]
OnCalendar=minutely
Persistent=true

[Install]
WantedBy=timers.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now citadel-dns-priority.timer
    
    # Apply immediately
    sudo systemctl start citadel-dns-priority.service
    
    log_success "Kernel priority optimization aktywny"
}

# ==============================================================================
# NEW FEATURES MODULE 9: DNS-over-HTTPS Parallel Racing
# ==============================================================================
install_doh_parallel() {
    log_section "🚀 DNS-OVER-HTTPS PARALLEL RACING"
    
    # Create advanced DNSCrypt config with DoH parallel racing
    sudo tee /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml >/dev/null <<'EOF'
# Citadel++ DNSCrypt with DoH Parallel Racing
listen_addresses = ['127.0.0.1:5353', '[::1]:5353']
user_name = 'dnscrypt'

# Enable parallel racing for faster responses
server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

# DoH servers with parallel racing
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = false

# Parallel racing configuration
lb_strategy = 'p2'  # Power of Two load balancing
lb_estimator = true

# Performance tuning
max_clients = 500
cache_size = 1024
cache_min_ttl = 300
cache_max_ttl = 86400
timeout = 3000
keepalive = 30

# Bootstrap resolvers
bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53', '149.112.112.112:53']
ignore_system_dns = true

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    log_success "Konfiguracja DoH Parallel Racing gotowa"
    log_info "Aby aktywować: sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml"
}

# ==============================================================================
# PORT CONFLICT RESOLUTION
# ==============================================================================
fix_port_conflicts() {
    log_section "🔧 PORT CONFLICT RESOLUTION"
    
    log_info "Sprawdzanie konfliktów portów..."
    
    # Check what's using port 53
    echo "Procesy używające portu 53:"
    sudo ss -tulpn | grep :53
    
    echo ""
    log_info "Opcje naprawy:"
    echo "1. Zatrzymaj avahi: sudo systemctl stop avahi-daemon"
    echo "2. Zabij chromium procesy: pkill chromium"
    echo "3. Użyj alternatywnego portu dla CoreDNS"
    
    # Option to use different port for CoreDNS
    read -p "Czy zmienić port CoreDNS na 5354? (tak/nie): " -r
    if [[ $REPLY =~ ^(tak|TAK|yes|YES|y|Y)$ ]]; then
        log_info "Zmieniam port CoreDNS na 5354..."
        sudo sed -i 's/.:53 {/.:5354 {/g' /etc/coredns/Corefile
        sudo systemctl restart coredns
        log_success "CoreDNS działa na porcie 5354"
        log_info "Test: dig +short whoami.cloudflare @127.0.0.1 -p 5354"
    fi
}

# ==============================================================================
# HELP & USAGE
# ==============================================================================
show_help() {
    cat <<EOF

${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.0 - Command Reference                       ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Installation Commands (BEZPIECZNE):${NC}
  install-dnscrypt      Install DNSCrypt-Proxy only
  install-coredns       Install CoreDNS only
  install-nftables      Install NFTables rules only
  install-all           Install all DNS modules (NIE wyłącza systemd-resolved)

${YELLOW}NEW FEATURES v3.0:${NC}
  smart-ipv6           Smart IPv6 detection & auto-reconfiguration
  install-dashboard    Install terminal dashboard (citadel-top)
  install-editor       Install editor integration (citadel edit)
  optimize-kernel      Apply real-time priority for DNS processes
  install-doh-parallel Install DNS-over-HTTPS parallel racing
  fix-ports            Resolve port conflicts with avahi/chromium

${YELLOW}System Configuration (UWAGA - wyłącza systemd-resolved):${NC}
  configure-system      Przełącz system na Citadel++ DNS (z potwierdzeniem)
  restore-system        Przywróć systemd-resolved + DNS (rollback)

${CYAN}Emergency Commands:${NC}
  emergency-refuse      Refuse all DNS queries (emergency mode)
  emergency-restore     Restore normal operation
  killswitch-on         Activate DNS kill-switch (block all non-localhost)
  killswitch-off        Deactivate kill-switch

${CYAN}Diagnostic Commands:${NC}
  diagnostics           Run full system diagnostics
  status                Show service status
  verify                Verify full stack (ports/services/DNS/NFT/metrics)

${CYAN}Firewall Modes:${NC}
  firewall-safe         Ustaw reguły SAFE (nie zrywa internetu)
  firewall-strict       Ustaw reguły STRICT (blokuje DNS-leaks)

${GREEN}Rekomendowany workflow:${NC}
  ${CYAN}1.${NC} sudo ./citadel++.sh install-all
  ${CYAN}2.${NC} sudo ./citadel++.sh firewall-safe         ${YELLOW}# SAFE: nie zrywa internetu${NC}
  ${CYAN}3.${NC} dig +short google.com @127.0.0.1          ${YELLOW}# Test lokalnego DNS${NC}
  ${CYAN}4.${NC} sudo ./citadel++.sh configure-system       ${YELLOW}# Przełączenie systemu${NC}
  ${CYAN}5.${NC} ping -c 3 google.com                      ${YELLOW}# Test internetu${NC}
  ${CYAN}6.${NC} sudo ./citadel++.sh firewall-strict        ${YELLOW}# STRICT: pełna blokada DNS-leak${NC}

${GREEN}Nowe narzędzia v3.0${CYAN}Tools:${NC}
  citadel-top           Real-time terminal dashboard
  citadel edit          Editor with auto-restart
  citadel status        Quick status check

${CYAN}Adblock Panel (DNS):${NC}
  adblock-status        Show adblock/CoreDNS integration status
  adblock-stats         Show counts of custom/blocklist/combined
  adblock-show          Show: custom|blocklist|combined (first 200 lines)
  adblock-edit          Edit /etc/coredns/zones/custom.hosts and reload
  adblock-add           Add domain to custom.hosts (0.0.0.0 domain)
  adblock-remove        Remove domain from custom.hosts
  adblock-rebuild       Rebuild combined.hosts from custom+blocklist and reload
  adblock-query         Query a domain via local DNS (127.0.0.1)

${CYAN}Advanced Configuration:${NC}
  DNSCrypt config:      /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  DNSCrypt DoH config:  /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml
  CoreDNS config:       /etc/coredns/Corefile
  NFTables rules:       /etc/nftables.d/citadel-dns.nft

${CYAN}Dokumentacja:${NC}
  Notes:               /home/qguar/Cytadela/CITADEL++_NOTES.md

EOF
}

# ==============================================================================
# NEW FEATURES MODULE 5: Smart IPv6 Detection
# ==============================================================================
smart_ipv6_detection() {
    log_section "🔍 SMART IPv6 DETECTION & AUTO-RECONFIGURATION"
    
    # Detect IPv6 connectivity
    log_info "Sprawdzanie łączności IPv6..."
    IPV6_AVAILABLE=false
    
    if ping6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
        IPV6_AVAILABLE=true
        log_success "IPv6 dostępny"
    else
        log_warning "IPv6 niedostępny - konfiguruję tylko IPv4"
    fi
    
    # Auto-reconfigure DNSCrypt based on IPv6 availability
    local dnscrypt_config="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    
    if [[ -f "$dnscrypt_config" ]]; then
        log_info "Aktualizacja konfiguracji DNSCrypt dla IPv6..."
        
        if [[ "$IPV6_AVAILABLE" == "true" ]]; then
            # Enable IPv6
            sed -i "s|listen_addresses = \['127.0.0.1:5353'\]|listen_addresses = ['127.0.0.1:5353', '[::1]:5353']|g" "$dnscrypt_config"
            sed -i 's|ipv6_servers = false|ipv6_servers = true|g' "$dnscrypt_config"
            log_success "IPv6 włączony w konfiguracji"
        else
            # Disable IPv6 for stability
            sed -i "s|listen_addresses = \['127.0.0.1:5353', '\[::1\]:5353'\]|listen_addresses = ['127.0.0.1:5353']|g" "$dnscrypt_config"
            sed -i 's|ipv6_servers = true|ipv6_servers = false|g' "$dnscrypt_config"
            log_success "IPv6 wyłączony dla stabilności"
        fi
        
        # Restart DNSCrypt if running
        systemctl is-active --quiet dnscrypt-proxy && systemctl restart dnscrypt-proxy
    fi
    
    # Update CoreDNS for IPv6
    local coredns_config="/etc/coredns/Corefile"
    if [[ -f "$coredns_config" ]]; then
        if [[ "$IPV6_AVAILABLE" == "true" ]]; then
            sed -i 's|bind 0.0.0.0 ::|bind 0.0.0.0 ::|g' "$coredns_config"
            log_success "CoreDNS skonfigurowany dla IPv6"
        else
            sed -i 's|bind 0.0.0.0 ::|bind 0.0.0.0|g' "$coredns_config"
            log_success "CoreDNS skonfigurowany tylko dla IPv4"
        fi
    fi
    
    echo "IPv6 Status: $IPV6_AVAILABLE"
}

# ==============================================================================
# NEW FEATURES MODULE 6: Terminal Dashboard
# ==============================================================================
install_citadel_top() {
    log_section "📊 TERMINAL DASHBOARD INSTALLATION"
    
    # Install dependencies
    log_info "Instalowanie zależności dla dashboard..."
    pacman -Q curl jq || sudo pacman -S curl jq --noconfirm
    
    # Create citadel-top script
    tee /usr/local/bin/citadel-top >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Terminal Dashboard v1.0

COREDNS_PORT=53
if [[ -f /etc/coredns/Corefile ]]; then
  p=$(awk -F'[:}]' '/^\.:/{gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' /etc/coredns/Corefile 2>/dev/null)
  if [[ -n "$p" ]]; then
    COREDNS_PORT="$p"
  fi
fi

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    CITADEL++ DASHBOARD                        ║"
echo "║                   Real-time DNS Monitor                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    CITADEL++ DASHBOARD                        ║"
    echo "║                   $(date '+%Y-%m-%d %H:%M:%S')                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "🔥 SERVICE STATUS:"
    systemctl is-active dnscrypt-proxy >/dev/null && echo "✓ DNSCrypt-Proxy: RUNNING" || echo "✗ DNSCrypt-Proxy: STOPPED"
    systemctl is-active coredns >/dev/null && echo "✓ CoreDNS: RUNNING" || echo "✗ CoreDNS: STOPPED"
    systemctl is-active nftables >/dev/null && echo "✓ NFTables: RUNNING" || echo "✗ NFTables: STOPPED"
    echo ""
    
    echo "📊 PROMETHEUS METRICS:"
    if curl -s http://127.0.0.1:9153/metrics >/dev/null 2>&1; then
        QUERIES=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" | tail -1 | awk '{print $2}')
        CACHE_HITS=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_cache_hits_total" | tail -1 | awk '{print $2}')
        echo "  Total Queries: ${QUERIES:-0}"
        echo "  Cache Hits: ${CACHE_HITS:-0}"
    else
        echo "  Metrics unavailable"
    fi
    echo ""
    
    echo "🌐 NETWORK STATUS:"
    echo "  DNS Resolution: $(dig +short google.com @127.0.0.1 -p ${COREDNS_PORT} 2>/dev/null | head -1 || echo "FAILED")"
    echo "  External IP: $(curl -s https://api.ipify.org 2>/dev/null || echo "UNKNOWN")"
    echo ""
    
    echo "⚡ PERFORMANCE:"
    if command -v ss >/dev/null; then
        DNS_CONNECTIONS=$(ss -tn | grep :53 | wc -l)
        echo "  Active DNS Connections: $DNS_CONNECTIONS"
    fi
    echo ""
    
    echo "🔥 SYSTEM LOAD:"
    echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
    echo "  Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
    echo ""
    
    echo "Press Ctrl+C to exit | Refresh: 5s"
    sleep 5
done
EOF
    
    chmod +x /usr/local/bin/citadel-top
    log_success "Dashboard zainstalowany: uruchom 'citadel-top'"
}

# ==============================================================================
# NEW FEATURES MODULE 7: Editor Integration
# ==============================================================================
install_editor_integration() {
    log_section "✏️ EDITOR INTEGRATION SETUP"
    
    # Install micro editor
    if ! command -v micro >/dev/null; then
        log_info "Instalowanie edytora micro..."
        yay -S micro --noconfirm
    fi
    
    # Create citadel edit command
    tee /usr/local/bin/citadel >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Editor Integration v1.0

ACTION=${1:-help}
CONFIG_DIR="/etc/coredns"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

case "$ACTION" in
    edit)
        echo "📝 Opening Citadel++ configuration in micro editor..."
        micro "$CONFIG_DIR/Corefile"
        echo "🔄 Restarting CoreDNS..."
        sudo systemctl restart coredns
        echo "✓ CoreDNS reloaded with new configuration"
        ;;
    edit-dnscrypt)
        echo "📝 Opening DNSCrypt configuration..."
        sudo micro "$DNSCRYPT_CONFIG"
        echo "🔄 Restarting DNSCrypt..."
        sudo systemctl restart dnscrypt-proxy
        echo "✓ DNSCrypt reloaded with new configuration"
        ;;
    status)
        echo "📊 Citadel++ Status:"
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    logs)
        echo "📋 Recent logs:"
        journalctl -u dnscrypt-proxy -u coredns -n 20 --no-pager
        ;;
    test)
        echo "🧪 Testing DNS resolution..."
        dig +short whoami.cloudflare @127.0.0.1 || echo "❌ DNS test failed"
        ;;
    help|--help|-h)
        cat <<HELP
Citadel++ Editor Integration

Commands:
  citadel edit         Edit CoreDNS config and auto-restart
  citadel edit-dnscrypt Edit DNSCrypt config and auto-restart  
  citadel status       Show service status
  citadel logs         Show recent logs
  citadel test         Test DNS resolution
  citadel help         Show this help

Examples:
  citadel edit         # Edit CoreDNS configuration
  citadel edit-dnscrypt # Edit DNSCrypt configuration
HELP
        ;;
    *)
        echo "Unknown command. Use 'citadel help' for usage."
        exit 1
        ;;
esac
EOF
    
    chmod +x /usr/local/bin/citadel
    log_success "Editor integration zainstalowany: użyj 'citadel edit'"
}

# ==============================================================================
# NEW FEATURES MODULE 8: Kernel Priority Optimization
# ==============================================================================
optimize_kernel_priority() {
    log_section "⚡ KERNEL PRIORITY OPTIMIZATION"
    
    # Check if running on CachyOS/Arch
    if [[ ! -f /etc/arch-release ]]; then
        log_warning "Ta funkcja jest zoptymalizowana dla CachyOS/Arch Linux"
        return 1
    fi
    
    # Create systemd service for DNS priority optimization
    tee /etc/systemd/system/citadel-dns-priority.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Optimization
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'renice -20 $(pgrep coredns) 2>/dev/null || true; ionice -c 1 -n 7 $(pgrep coredns) 2>/dev/null || true; logger "Citadel++: Applied real-time priority to DNS processes"'
EOF

    tee /etc/systemd/system/citadel-dns-priority.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Timer
Requires=citadel-dns-priority.service

[Timer]
OnCalendar=minutely
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now citadel-dns-priority.timer
    
    # Apply immediately
    systemctl start citadel-dns-priority.service
    
    log_success "Kernel priority optimization aktywny"
}

# ==============================================================================
# NEW FEATURES MODULE 9: DNS-over-HTTPS Parallel Racing
# ==============================================================================
install_doh_parallel() {
    log_section "🚀 DNS-OVER-HTTPS PARALLEL RACING"
    
    # Create advanced DNSCrypt config with DoH parallel racing
    tee /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml >/dev/null <<'EOF'
# Citadel++ DNSCrypt with DoH Parallel Racing
listen_addresses = ['127.0.0.1:5353']
user_name = 'dnscrypt'

# Enable parallel racing for faster responses
server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

# DoH servers with parallel racing
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = false

# Parallel racing configuration
lb_strategy = 'p2'  # Power of Two load balancing
lb_estimator = true

# Performance tuning
max_clients = 500
cache_size = 1024
cache_min_ttl = 300
cache_max_ttl = 86400
timeout = 3000
keepalive = 30

# Bootstrap resolvers
bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53', '149.112.112.112:53']
ignore_system_dns = true

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    log_success "Konfiguracja DoH Parallel Racing gotowa"
    log_info "Aby aktywować: sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml"
}

# ==============================================================================
# SAFE MODE - Test without breaking internet
# ==============================================================================
safe_test_mode() {
    log_section "🧪 SAFE TEST MODE"
    
    log_info "Uruchamiam testy bez przerywania internetu..."
    
    # Test 1: Check dependencies
    log_info "Sprawdzanie zależności..."
    for cmd in dnscrypt-proxy coredns nftables; do
        if command -v "$cmd" >/dev/null; then
            echo "✓ $cmd dostępny"
        else
            echo "✗ $cmd nieznaleziony"
        fi
    done
    
    # Test 2: Validate configurations
    log_info "Walidacja konfiguracji..."
    if [[ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]; then
        if dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check >/dev/null 2>&1; then
            echo "✓ DNSCrypt config poprawny"
        else
            echo "✗ DNSCrypt config błędny"
        fi
    fi
    
    # Test 3: Check ports
    log_info "Sprawdzanie portów..."
    if ss -ln | grep -q ":53"; then
        echo "⚠ Port 53 zajęty - może wymagać zatrzymania systemd-resolved"
    else
        echo "✓ Port 53 wolny"
    fi
    
    echo ""
    log_info "Tryb bezpieczny zakończony. Użyj 'install-all' dla pełnej instalacji"
}

# ==============================================================================
# MAIN DISPATCHER
# ==============================================================================
case "$ACTION" in
    install-dnscrypt)
        install_dnscrypt
        ;;
    install-coredns)
        install_coredns
        ;;
    install-nftables)
        install_nftables
        ;;
    firewall-safe)
        firewall_safe
        ;;
    firewall-strict)
        firewall_strict
        ;;
    adblock-status)
        adblock_status
        ;;
    adblock-stats)
        adblock_stats
        ;;
    adblock-show)
        adblock_show "$ARG1"
        ;;
    adblock-edit)
        adblock_edit
        ;;
    adblock-add)
        adblock_add "$ARG1"
        ;;
    adblock-remove)
        adblock_remove "$ARG1"
        ;;
    adblock-rebuild)
        adblock_rebuild
        adblock_reload
        log_success "Adblock rebuilt + CoreDNS reloaded"
        ;;
    adblock-query)
        adblock_query "$ARG1"
        ;;
    configure-system)
        configure_system
        ;;
    restore-system)
        restore_system
        ;;
    install-all)
        install_all
        ;;
    # NEW FEATURES v3.0
    smart-ipv6)
        smart_ipv6_detection
        ;;
    install-dashboard)
        install_citadel_top
        ;;
    install-editor)
        install_editor_integration
        ;;
    optimize-kernel)
        optimize_kernel_priority
        ;;
    install-doh-parallel)
        install_doh_parallel
        ;;
    fix-ports)
        fix_port_conflicts
        ;;
    safe-test)
        safe_test_mode
        ;;
    # Emergency commands
    emergency-refuse)
        emergency_refuse
        ;;
    emergency-restore)
        emergency_restore
        ;;
    killswitch-on)
        emergency_killswitch_on
        ;;
    killswitch-off)
        emergency_killswitch_off
        ;;
    # Diagnostic commands
    diagnostics)
        run_diagnostics
        ;;
    verify)
        verify_stack
        ;;
    status)
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
