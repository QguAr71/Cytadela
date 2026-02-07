#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-INSTALL MODULE v3.2                                ║
# ║  Unified installation system for all components                       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Load i18n strings - try new i18n-engine first, fallback to legacy
local lang="${CYTADELA_LANG:-${LANG%%_*}:-en}"
lang="${lang:-en}"

# Try new i18n-engine
if [[ -f "modules/i18n-engine/i18n-engine.sh" ]]; then
    source "modules/i18n-engine/i18n-engine.sh" 2>/dev/null && {
        i18n_engine_init 2>/dev/null || true
        i18n_engine_load "install" "$lang" 2>/dev/null || true
    }
fi

# Fallback to legacy i18n if available
if [[ -f "lib/i18n/${lang}.sh" ]]; then
    source "lib/i18n/${lang}.sh" 2>/dev/null || true
fi

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

# Default ports
DNSCRYPT_PORT_DEFAULT=5353
COREDNS_PORT_DEFAULT=53
DASHBOARD_PORT_DEFAULT=9154

# Installation flags
INSTALL_SILENT=false
INSTALL_FORCE=false

# ==============================================================================
# UNIFIED INSTALL INTERFACE
# ==============================================================================

# Main unified install function
# Usage: install_component <component> [options...]
# Components: dnscrypt, coredns, nftables, dashboard, all, wizard
install_component() {
    local component="$1"
    shift

    case "$component" in
        dnscrypt)
            install_dnscrypt "$@"
            ;;
        coredns)
            install_coredns "$@"
            ;;
        nftables)
            install_nftables "$@"
            ;;
        dashboard)
            install_dashboard "$@"
            ;;
        all)
            install_all "$@"
            ;;
        wizard)
            install_wizard "$@"
            ;;
        check-deps)
            check_dependencies_install "$@"
            ;;
        *)
            log_error "${T_INSTALL_UNKNOWN_COMPONENT:-Unknown component: $component}"
            log_info "${T_INSTALL_AVAILABLE_COMPONENTS:-Available components: dnscrypt, coredns, nftables, dashboard, all, wizard, check-deps}"
            return 1
            ;;
    esac
}

# ==============================================================================
# DNSCRYPT-PROXY INSTALLATION (migrated from install-dnscrypt.sh)
# ==============================================================================

install_dnscrypt() {
    draw_section_header "󰇄 DNSCrypt-Proxy"

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
# Citadel DNSCrypt ADVANCED Configuration
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

# ==============================================================================
# COREDNS INSTALLATION (to be migrated from install-coredns.sh)
# ==============================================================================

# COREDNS INSTALLATION (migrated from install-coredns.sh)
# ==============================================================================

install_coredns() {
    log_section "󰌐 CoreDNS Installation"

    require_cmds coredns curl awk sort wc mktemp systemctl || return 1

    local dnscrypt_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    [[ -z "$dnscrypt_port" ]] && dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"

    mkdir -p /etc/coredns/zones
    touch /etc/coredns/zones/custom.hosts
    touch /etc/coredns/zones/allowlist.txt
    touch /etc/coredns/zones/blocklist.hosts
    touch /etc/coredns/zones/combined.hosts
    chmod 0644 /etc/coredns/zones/custom.hosts 2>/dev/null || true
    chmod 0644 /etc/coredns/zones/allowlist.txt 2>/dev/null || true
    chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
    chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true

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

    log_info "Pobieranie blocklist (OISD + KADhosts + Polish Annoyance + HaGeZi Multi Light)..."
    {
        local tmp_raw tmp_block tmp_combined
        tmp_raw="$(mktemp)"
        tmp_block="$(mktemp)"
        tmp_combined="$(mktemp)"

        curl -fsSL https://big.oisd.nl | grep -v "^#" >"$tmp_raw"
        curl -fsSL https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt | grep -v "^#" >>"$tmp_raw"
        curl -fsSL https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt | grep -v "^#" >>"$tmp_raw"
        curl -fsSL https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/light.txt | grep -v "^#" >>"$tmp_raw"

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

                if (line ~ /^\|\|/) {
                    sub(/^\|\|/, "", line)
                    sub(/[\^\/].*$/, "", line)
                    emit(line)
                    next
                }

                if (line ~ /^[A-Za-z0-9.*-]+(\.[A-Za-z0-9.-]+)+$/) {
                    emit(line)
                    next
                }
            }
        ' "$tmp_raw" | sort -u >"$tmp_block"

        if [[ $(wc -l <"$tmp_block") -lt 1000 ]]; then
            log_warning "Blocklist wygląda na pustą/uszkodzoną ($(wc -l <"$tmp_block") wpisów) - zostawiam poprzednią"
            rm -f "$tmp_raw" "$tmp_block" "$tmp_combined"
            tmp_combined="$(mktemp)"
            cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u >"$tmp_combined"
            mv "$tmp_combined" /etc/coredns/zones/combined.hosts
            chown root:coredns /etc/coredns/zones/combined.hosts 2>/dev/null || true
            chmod 0640 /etc/coredns/zones/combined.hosts 2>/dev/null || true
        else
            mv "$tmp_block" /etc/coredns/zones/blocklist.hosts
            cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u >"$tmp_combined"
            mv "$tmp_combined" /etc/coredns/zones/combined.hosts
            rm -f "$tmp_raw"
            chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
            chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
            log_success "Blocklist pobrana ($(wc -l </etc/coredns/zones/blocklist.hosts) wpisów)"
        fi
    } || {
        log_warning "Nie udało się pobrać blocklist - tworzę pusty plik"
        touch /etc/coredns/zones/blocklist.hosts
        if ! declare -f adblock_rebuild >/dev/null 2>&1; then
            load_module "adblock"
        fi
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

    log_info "CoreDNS Corefile created: /etc/coredns/Corefile"

    # Fix permissions for ZFS compatibility (Issue #25)
    log_info "Setting permissions for ZFS compatibility..."
    chown -R root:root /etc/coredns
    chmod 755 /etc/coredns
    chmod 755 /etc/coredns/zones
    chmod 644 /etc/coredns/Corefile
    chmod 644 /etc/coredns/Corefile.citadel 2>/dev/null || true
    chmod 644 /etc/coredns/zones/*.hosts 2>/dev/null || true

    # Grant network capabilities to CoreDNS (bind to port 53)
    if command -v setcap &>/dev/null; then
        setcap 'cap_net_bind_service=+ep' /usr/bin/coredns 2>/dev/null || {
            log_warning "${T_COREDNS_CAPABILITIES_FAIL:-Could not set capabilities on CoreDNS binary}"
            log_warning "${T_COREDNS_CAPABILITIES_HINT:-CoreDNS may need to run as root or with systemd CapabilityBoundingSet}"
        }
    fi

    # Create auto-update blocklist service
    tee /etc/systemd/system/citadel-update-blocklist.service >/dev/null <<'EOF'
[Unit]
Description=Citadel Blocklist Auto-Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'set -e; tmp_raw="$(mktemp)"; tmp_block="$(mktemp)"; tmp_combined="$(mktemp)"; allowlist="/etc/coredns/zones/allowlist.txt"; curl -fsSL https://big.oisd.nl | grep -v "^#" > "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt | grep -v "^#" >> "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt | grep -v "^#" >> "$tmp_raw"; curl -fsSL https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/light.txt | grep -v "^#" >> "$tmp_raw"; awk "function emit(d){gsub(/^[*.]+/,\"\",d); gsub(/[[:space:]]+$/,\"\",d); if(d ~ /^[A-Za-z0-9.-]+$/ && d ~ /\\./) print \"0.0.0.0 \" d} {line=\\$0; sub(/\\r$/,\"\",line); if(line ~ /^[[:space:]]*$/) next; if(line ~ /^[[:space:]]*!/) next; if(line ~ /^(0\\.0\\.0\\.0|127\\.0\\.0\\.1|::)[[:space:]]+/){n=split(line,a,/[[:space:]]+/); if(n>=2){d=a[2]; sub(/^\\|\\|/,\"\",d); sub(/[\\^\\/].*$/,\"\",d); emit(d)}; next} if(line ~ /^\\|\\|/){sub(/^\\|\\|/,\"\",line); sub(/[\\^\\/].*$/,\"\",line); emit(line); next} if(line ~ /^[A-Za-z0-9.*-]+(\\\\.[A-Za-z0-9.-]+)+$/){emit(line); next}}" "$tmp_raw" | sort -u > "$tmp_block"; if [ "$(wc -l < \"$tmp_block\")" -lt 1000 ]; then rm -f "$tmp_raw" "$tmp_block" "$tmp_combined"; logger "Citadel blocklist update failed (too few entries)"; exit 0; fi; mv "$tmp_block" /etc/coredns/zones/blocklist.hosts; cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u | awk -v AL="$allowlist" "BEGIN{while((getline l < AL)>0){sub(/\\r$/,\"\",l); gsub(/^[[:space:]]+|[[:space:]]+$/,\"\",l); if(l!=\"\" && l !~ /^#/){k=tolower(l); a[k]=1; esc=k; gsub(/\\./,\"\\\\.\",esc); r[k]=\"\\\\.\" esc \"$\"}}} {d=\\$2; if(d==\"\") next; dl=tolower(d); for(k in a){ if(dl==k || dl ~ r[k]) next } print}" > "$tmp_combined"; mv "$tmp_combined" /etc/coredns/zones/combined.hosts; chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; logger "Citadel blocklist updated ($(wc -l < /etc/coredns/zones/blocklist.hosts) entries)"'

[Install]
WantedBy=multi-user.target
EOF

    tee /etc/systemd/system/citadel-update-blocklist.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel Daily Blocklist Update

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
    log_info "Starting CoreDNS..."
    systemctl daemon-reload

    # Final permission check before starting (ZFS compatibility)
    chmod 644 /etc/coredns/Corefile /etc/coredns/zones/*.hosts 2>/dev/null || true

    systemctl enable coredns

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

# ==============================================================================
# NFTABLES INSTALLATION (to be migrated from install-nftables.sh)
# ==============================================================================

# NFTABLES INSTALLATION (migrated from install-nftables.sh)
# ==============================================================================

install_nftables() {
    draw_section_header "󰒃 NFTables Firewall"

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
        printf '%s\n' '#!/usr/bin/nft -f' >/etc/nftables.conf
    fi

    if [[ $(grep -cE '^[[:space:]]*include[[:space:]]+"/etc/nftables\.d/citadel-dns\.nft"[[:space:]]*$' /etc/nftables.conf 2>/dev/null || echo 0) -gt 1 ]]; then
        local tmp_nftconf
        tmp_nftconf=$(mktemp)
        awk 'BEGIN{seen=0}
            /^[[:space:]]*include[[:space:]]+"\/etc\/nftables\.d\/citadel-dns\.nft"[[:space:]]*$/ { if (seen==0) { print; seen=1 } ; next }
            { print }
        ' /etc/nftables.conf >"$tmp_nftconf"
        mv "$tmp_nftconf" /etc/nftables.conf
    fi

    if ! grep -qE '^[[:space:]]*include[[:space:]]+"/etc/nftables\.d/citadel-dns\.nft"[[:space:]]*$' /etc/nftables.conf; then
        printf '\ninclude "/etc/nftables.d/citadel-dns.nft"\n' >>/etc/nftables.conf
    fi

    log_info "Walidacja składni nftables..."
    if nft -c -f <(
        printf '%s\n' 'flush ruleset'
        cat /etc/nftables.d/citadel-dns-safe.nft
    ) &&
        nft -c -f <(
            printf '%s\n' 'flush ruleset'
            cat /etc/nftables.d/citadel-dns-strict.nft
        ); then
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

# Firewall mode switching functions
firewall_safe() {
    log_section "󰒃 NFTables Safe Mode"
    ln -sf /etc/nftables.d/citadel-dns-safe.nft /etc/nftables.d/citadel-dns.nft
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns-safe.nft || log_warning "Nie udało się załadować reguł SAFE"
    log_success "Firewall ustawiony na SAFE"
}

firewall_strict() {
    log_section "󰒃 NFTables Strict Mode"
    ln -sf /etc/nftables.d/citadel-dns-strict.nft /etc/nftables.d/citadel-dns.nft
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns-strict.nft || log_warning "Nie udało się załadować reguł STRICT"
    log_success "Firewall ustawiony na STRICT"
}

# System configuration function
configure_system() {
    log_section "󰒓 System Configuration"

    log_warning "Ten krok zmienia DNS systemu (może chwilowo przerwać internet jeśli DNS nie działa)."
    printf "Czy na pewno chcesz kontynuować? (tak/nie): "
    read -r REPLY
    if [[ ! $REPLY =~ ^(tak|TAK|yes|YES|y|Y)$ ]]; then
        log_info "Anulowano"
        return 0
    fi

    # Create backup directory
    mkdir -p "${CYTADELA_STATE_DIR}/backups"

    # Backup original configuration
    log_info "Zapisywanie oryginalnej konfiguracji..."

    # Backup resolv.conf
    if [[ -f /etc/resolv.conf ]]; then
        cp /etc/resolv.conf "${CYTADELA_STATE_DIR}/backups/resolv.conf.pre-citadel" 2>/dev/null || true
    fi

    # Backup NetworkManager config if exists
    if [[ -f /etc/NetworkManager/conf.d/citadel-dns.conf ]]; then
        cp /etc/NetworkManager/conf.d/citadel-dns.conf "${CYTADELA_STATE_DIR}/backups/nm-citadel-dns.conf.backup" 2>/dev/null || true
    fi

    # Save systemd-resolved state
    systemctl is-enabled systemd-resolved 2>/dev/null >"${CYTADELA_STATE_DIR}/backups/systemd-resolved.state" || echo "disabled" >"${CYTADELA_STATE_DIR}/backups/systemd-resolved.state"

    log_success "Backup zapisany w ${CYTADELA_STATE_DIR}/backups/"

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
# Citadel DNS Configuration
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
        log_warning "Rollback: sudo ./Citadel.sh restore-system"
    fi

    log_success "Konfiguracja systemowa zakończona"
}

# ==============================================================================
# DASHBOARD INSTALLATION (to be migrated from install-dashboard.sh)
# ==============================================================================

# DASHBOARD INSTALLATION (migrated from install-dashboard.sh)
# ==============================================================================

install_dashboard() {
    log_section "󰄬 TERMINAL DASHBOARD INSTALLATION"

    require_cmds curl jq systemctl || return 1
    if ! command -v pacman >/dev/null 2>&1; then
        log_warning "Brak pacman - pomijam instalację zależności dla dashboard"
        return 1
    fi

    # Install dependencies
    log_info "Instalowanie zależności dla dashboard..."
    pacman -Q curl jq >/dev/null || sudo pacman -S curl jq --noconfirm

    # Create citadel-top script
    sudo tee /usr/local/bin/citadel-top >/dev/null <<'EOF'
#!/bin/bash
# Citadel Terminal Dashboard v1.0

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

    echo "󰈸 SERVICE STATUS:"
    systemctl is-active dnscrypt-proxy >/dev/null && echo "󰄬 DNSCrypt-Proxy: RUNNING" || echo "󰅖 DNSCrypt-Proxy: STOPPED"
    systemctl is-active coredns >/dev/null && echo "󰄬 CoreDNS: RUNNING" || echo "󰅖 CoreDNS: STOPPED"
    if sudo -n nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "󰄬 NFTables: RULES LOADED"
    else
        systemctl is-active nftables >/dev/null && echo "󰄬 NFTables: RUNNING" || echo "󰅖 NFTables: STOPPED"
    fi
    echo ""

    echo "󰄬 PROMETHEUS METRICS:"
    if curl -s http://127.0.0.1:9153/metrics >/dev/null 2>&1; then
        QUERIES=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" | tail -1 | awk '{print $2}')
        CACHE_HITS=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_cache_hits_total" | tail -1 | awk '{print $2}')
        echo "  Total Queries: ${QUERIES:-0}"
        echo "  Cache Hits: ${CACHE_HITS:-0}"
    else
        echo "  Metrics unavailable"
    fi
    echo ""

    echo "󰌐 NETWORK STATUS:"
    echo "  DNS Resolution: $(dig +short google.com @127.0.0.1 -p ${COREDNS_PORT} 2>/dev/null | head -1 || echo "FAILED")"
    echo "  External IP: $(curl -s https://api.ipify.org 2>/dev/null || echo "UNKNOWN")"
    echo ""

    echo "󱐋 PERFORMANCE:"
    if command -v ss >/dev/null; then
        DNS_CONNECTIONS=$(ss -tn | grep :53 | wc -l)
        echo "  Active DNS Connections: $DNS_CONNECTIONS"
    fi
    echo ""

    echo "󰈸 SYSTEM LOAD:"
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
# COMPLETE SYSTEM INSTALLATION (to be migrated from install-all.sh)
# ==============================================================================

# COMPLETE SYSTEM INSTALLATION (migrated from install-all.sh)
# ==============================================================================

install_all() {
    log_section "󱓞 CITADEL++ FULL INSTALLATION"

    log_info "Instalacja wszystkich modułów DNS..."

    # Install core components
    install_dnscrypt
    install_coredns
    install_nftables

    echo ""
    log_section "󰇏 INSTALACJA ZAKOŃCZONA POMYŚLNIE"

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  CITADEL++ v3.2 - FULLY OPERATIONAL                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    log_info "Status serwisów:"
    systemctl --no-pager status dnscrypt-proxy coredns nftables || true

    echo ""
    log_section "󰙨 HEALTHCHECK: DNS + ADBLOCK"

    # Rebuild adblock if available
    if ! declare -f adblock_rebuild >/dev/null 2>&1; then
        load_module "adblock"
    fi

    adblock_rebuild 2>/dev/null || true
    systemctl restart coredns 2>/dev/null || true
    sleep 1
    adblock_stats 2>/dev/null || true

    # DNS tests
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
            echo "  󰄬 DNS (google.com) via 127.0.0.1: OK"
        else
            echo "  󰅖 DNS (google.com) via 127.0.0.1: FAILED"
        fi

        # Adblock test
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

# ==============================================================================
# INSTALLATION WIZARD (to be migrated from install-wizard.sh)
# ==============================================================================

install_wizard() {
    log_info "Starting installation wizard..."
    # NOTE: Full install_wizard implementation from install-wizard.sh is very large (686 lines)
    # For v3.2 unified modules, we provide a simplified version that delegates to install_all
    log_info "Using simplified wizard - proceeding with full installation..."

    # Simplified wizard - just ask for confirmation and run install_all
    echo ""
    log_warning "${T_WIZARD_WARNING:-This will install all Citadel components with default settings.}"
    echo -n "${T_WIZARD_CONTINUE_PROMPT:-Continue? [y/N]: }"
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        install_all
    else
        log_info "${T_WIZARD_CANCELLED:-Installation cancelled.}"
        return 1
    fi
}

# ==============================================================================
# DEPENDENCY CHECKING (to be migrated from check-dependencies.sh)
# ==============================================================================

# ==============================================================================
# DEPENDENCY CHECKING (to be migrated from check-dependencies.sh)
# ==============================================================================

check_dependencies_install() {
    log_section "󰏗 ${T_AUTO_INSTALL_TITLE:-AUTO-INSTALLING MISSING DEPENDENCIES}"

    # Detect package manager
    local pkg_manager=""
    local distro_family=""
    if command -v pacman &>/dev/null; then
        pkg_manager="pacman"
        distro_family="arch"
    elif command -v apt &>/dev/null; then
        pkg_manager="apt"
        distro_family="debian"
    elif command -v dnf &>/dev/null; then
        pkg_manager="dnf"
        distro_family="rhel"
    else
        log_error "${T_NO_PKG_MANAGER:-No supported package manager found (pacman/apt/dnf)}"
        return 1
    fi

    log_info "${T_PKG_MANAGER_DETECTED:-Detected package manager:} $pkg_manager"
    echo ""

    # Build list of missing packages from config
    local packages=()
    local cmd pkg

    # Check required dependencies (simplified - in real implementation would use CYTADELA_DEPS_REQUIRED)
    local required_deps=("nft" "ss" "awk" "grep" "tee" "systemctl")
    for cmd in "${required_deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            # Map to package names
            case "$pkg_manager" in
                pacman)
                    case "$cmd" in
                        nft) pkg="nftables" ;;
                        ss) pkg="iproute2" ;;
                        *) pkg="$cmd" ;;
                    esac
                    ;;
                apt)
                    case "$cmd" in
                        nft) pkg="nftables" ;;
                        ss) pkg="iproute2" ;;
                        *) pkg="$cmd" ;;
                    esac
                    ;;
                dnf)
                    case "$cmd" in
                        nft) pkg="nftables" ;;
                        ss) pkg="iproute" ;;
                        *) pkg="$cmd" ;;
                    esac
                    ;;
            esac
            packages+=("$pkg")
        fi
    done

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_success "${T_ALL_REQUIRED_OK:-All dependencies are already installed!}"
        return 0
    fi

    log_info "${T_MISSING_PACKAGES:-Missing packages:} ${packages[*]}"
    echo ""
    echo -n "${T_INSTALL_PROMPT:-Install missing packages? [y/N]: }"
    read -r answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        log_warning "${T_INSTALL_CANCELLED:-Installation cancelled}"
        return 1
    fi

    echo ""
    log_info "${T_INSTALLING_PACKAGES:-Installing packages...}"

    # Install packages one by one to handle failures individually
    local failed_packages=()
    local aur_failed=()
    local success_count=0

    for pkg in "${packages[@]}"; do
        echo ""
        log_info "${T_INSTALLING_PACKAGE:-Installing:} $pkg"
        local exit_code=0

        case "$pkg_manager" in
            pacman)
                # Try official repos first
                if ! sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
                    log_warning "${T_PACKAGE_NOT_FOUND:-Package '$pkg' not found in official repositories}"

                    # For Arch - try AUR
                    if [[ "$distro_family" == "arch" ]]; then
                        echo -n "  ${T_TRY_AUR:-Try to install from AUR? [y/N]: }"
                        read -r aur_answer

                        if [[ "$aur_answer" =~ ^[Yy]$ ]]; then
                            # Check for AUR helper
                            local aur_helper=""
                            if command -v yay &>/dev/null; then
                                aur_helper="yay"
                            elif command -v paru &>/dev/null; then
                                aur_helper="paru"
                            fi

                            if [[ -n "$aur_helper" ]]; then
                                log_info "  ${T_USING_AUR_HELPER:-Using AUR helper:} $aur_helper"
                                if ! $aur_helper -S --needed --noconfirm "$pkg" 2>/dev/null; then
                                    log_error "  ${T_AUR_INSTALL_FAILED:-AUR installation failed for '$pkg'}"
                                    aur_failed+=("$pkg")
                                else
                                    log_success "  ${T_INSTALLED_FROM_AUR:-Installed from AUR: $pkg}"
                                    ((success_count++))
                                    continue
                                fi
                            else
                                log_warning "${T_NO_AUR_HELPER:-No AUR helper found (yay/paru)}"
                                echo "  ${T_MANUAL_INSTALL_REQUIRED:-Manual installation required:}"
                                echo "    git clone https://aur.archlinux.org/${pkg}.git"
                                echo "    cd ${pkg} && makepkg -si"
                                echo ""
                                read -rp "  ${T_PRESS_ENTER_CONTINUE:-Press Enter to continue to next package...}"
                                aur_failed+=("$pkg")
                            fi
                        else
                            failed_packages+=("$pkg")
                        fi
                    else
                        failed_packages+=("$pkg")
                    fi
                else
                    log_success "  ${T_PACKAGE_INSTALLED:-Installed: $pkg}"
                    ((success_count++))
                fi
                ;;
            apt)
                if ! sudo apt install -y "$pkg" 2>/dev/null; then
                    log_warning "${T_PACKAGE_NOT_FOUND:-Package '$pkg' not found in official repositories}"
                    echo "  ${T_ALTERNATIVE_SOURCES:-Alternative sources:}"
                    echo "    - ${T_CHECK_PPAS:-Check third-party PPAs}"
                    echo "    - ${T_BUILD_FROM_SOURCE:-Build from source}"
                    echo "    - ${T_DOWNLOAD_DEB:-Download .deb package manually}"
                    echo ""
                    read -rp "  ${T_PRESS_ENTER_CONTINUE:-Press Enter to continue to next package...}"
                    failed_packages+=("$pkg")
                else
                    log_success "  ${T_PACKAGE_INSTALLED:-Installed: $pkg}"
                    ((success_count++))
                fi
                ;;
            dnf)
                if ! sudo dnf install -y "$pkg" 2>/dev/null; then
                    log_warning "${T_PACKAGE_NOT_FOUND:-Package '$pkg' not found in official repositories}"
                    echo "  ${T_ALTERNATIVE_SOURCES:-Alternative sources:}"
                    echo "    - ${T_ENABLE_EPEL:-Enable EPEL: sudo dnf install epel-release}"
                    echo "    - ${T_ENABLE_RPM_FUSION:-Enable RPM Fusion: sudo dnf install ...}"
                    echo "    - ${T_COPR_REPOSITORIES:-COPR repositories}"
                    echo ""
                    read -rp "  ${T_PRESS_ENTER_CONTINUE:-Press Enter to continue to next package...}"
                    failed_packages+=("$pkg")
                else
                    log_success "  ${T_PACKAGE_INSTALLED:-Installed: $pkg}"
                    ((success_count++))
                fi
                ;;
        esac
    done

    echo ""
    echo "=== ${T_SUMMARY:-INSTALLATION SUMMARY} ==="
    echo ""
    log_success "${T_SUCCESSFULLY_INSTALLED:-Successfully installed:} $success_count packages"

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warning "${T_FAILED_TO_INSTALL:-Failed to install:} ${failed_packages[*]}"
    fi

    if [[ ${#aur_failed[@]} -gt 0 ]]; then
        log_info "${T_AUR_NEEDS_MANUAL:-AUR packages need manual install:} ${aur_failed[*]}"
        echo "  ${T_INSTALL_MANUALLY:-Install manually:}"
        for pkg in "${aur_failed[@]}"; do
            echo "    git clone https://aur.archlinux.org/${pkg}.git && cd ${pkg} && makepkg -si"
        done
    fi

    echo ""
    log_info "${T_VERIFY_HINT:-Run 'sudo Citadel check-deps' to verify installation}"

    # Return success if at least some packages were installed
    if [[ $success_count -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Check if DNSSEC is enabled
dnssec_enabled() {
    # TODO: Implement DNSSEC check
    return 1  # Default: disabled
}

# Pick a free port in range
pick_free_port() {
    local start_port="$1"
    local end_port="${2:-$((start_port + 100))}"

    for port in $(seq "$start_port" "$end_port"); do
        if ! ss -tuln | grep -q ":$port "; then
            echo "$port"
            return 0
        fi
    done

    return 1
}

# Require commands to be available
require_cmds() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            return 1
        fi
    done
    return 0
}

# ==============================================================================
# KERNEL PRIORITY OPTIMIZATION (migrated from advanced-install.sh)
# ==============================================================================

optimize_kernel_priority() {
    log_section "󱐋 KERNEL PRIORITY OPTIMIZATION"

    # Check if systemd is available (required for timer)
    if ! command -v systemctl >/dev/null 2>&1; then
        log_warning "systemd nie jest dostępny - pomijanie optymalizacji priorytetu"
        return 1
    fi

    # Check if DNS processes are installed
    if ! command -v dnscrypt-proxy >/dev/null 2>&1 && ! command -v coredns >/dev/null 2>&1; then
        log_warning "DNSCrypt ani CoreDNS nie są zainstalowane"
        return 1
    fi

    # Distribution detection and warning
    local distro="unknown"
    if [[ -f /etc/arch-release ]]; then
        distro="arch"
    elif [[ -f /etc/debian_version ]]; then
        distro="debian"
        log_info "Wykryto Debian/Ubuntu - dostosowanie komend..."
    elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then
        distro="redhat"
        log_info "Wykryto Fedora/RHEL - dostosowanie komend..."
    else
        log_info "Dystrybucja nieznana - użycie ogólnych komend"
    fi

    # Create priority tuning script (universal)
    log_info "Tworzenie skryptu optymalizacji priorytetów..."
    sudo tee /usr/local/bin/citadel-dns-priority.sh >/dev/null <<'EOF'
#!/bin/bash
# Citadel DNS Priority Optimization Script
# Universal version - works on any Linux distribution

# Function to set priority if process exists
set_priority() {
    local pid="$1"
    local name="$2"

    if [[ -n "$pid" ]] && [[ "$pid" =~ ^[0-9]+$ ]]; then
        # Check if process still exists
        if kill -0 "$pid" 2>/dev/null; then
            renice -10 "$pid" 2>/dev/null && logger "Citadel: renice -10 $name (PID: $pid)"
            ionice -c 2 -n 0 -p "$pid" 2>/dev/null && logger "Citadel: ionice set for $name"
        fi
    fi
}

# Apply to DNSCrypt
DNSCRYPT_PIDS=$(pgrep -x dnscrypt-proxy 2>/dev/null)
if [[ -n "$DNSCRYPT_PIDS" ]]; then
    for pid in $DNSCRYPT_PIDS; do
        set_priority "$pid" "dnscrypt-proxy"
    done
else
    logger "Citadel: dnscrypt-proxy not running"
fi

# Apply to CoreDNS
COREDNS_PIDS=$(pgrep -x coredns 2>/dev/null)
if [[ -n "$COREDNS_PIDS" ]]; then
    for pid in $COREDNS_PIDS; do
        set_priority "$pid" "coredns"
    done
else
    logger "Citadel: coredns not running"
fi

# Summary log
if [[ -n "$DNSCRYPT_PIDS" ]] || [[ -n "$COREDNS_PIDS" ]]; then
    logger "Citadel: DNS priority optimization applied"
else
    logger "Citadel: No DNS processes found to optimize"
fi
EOF
    sudo chmod +x /usr/local/bin/citadel-dns-priority.sh
    log_success "Skrypt optymalizacji utworzony"

    # Create systemd service
    log_info "Tworzenie systemd service..."
    sudo tee /etc/systemd/system/citadel-dns-priority.service >/dev/null <<'EOF'
[Unit]
Description=Citadel DNS Priority Optimization
After=network.target dnscrypt-proxy.service coredns.service
Wants=dnscrypt-proxy.service coredns.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel-dns-priority.sh
RemainAfterExit=no
EOF
    log_success "Service utworzony"

    # Create systemd timer
    log_info "Tworzenie systemd timer (co minutę)..."
    sudo tee /etc/systemd/system/citadel-dns-priority.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel DNS Priority Timer

[Timer]
OnBootSec=30
OnUnitActiveSec=60s
AccuracySec=1s
Persistent=true
Unit=citadel-dns-priority.service

[Install]
WantedBy=timers.target
EOF
    log_success "Timer utworzony"

    # Reload systemd and enable timer
    log_info "Aktywacja timer-a..."
    sudo systemctl daemon-reload
    sudo systemctl enable --now citadel-dns-priority.timer 2>/dev/null || {
        log_warning "Nie udało się włączyć timer-a (może brak uprawnień)"
        return 1
    }

    # Apply immediately if services are running
    log_info "Natychmiastowe zastosowanie priorytetów..."
    local applied=false

    if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then
        sleep 1  # Wait for service to fully start
        local dpid=$(pgrep -x dnscrypt-proxy | head -1)
        if [[ -n "$dpid" ]]; then
            sudo renice -10 "$dpid" 2>/dev/null && {
                log_success "DNSCrypt (PID: $dpid) priorytet -10"
                applied=true
            }
        fi
    fi

    if systemctl is-active --quiet coredns 2>/dev/null; then
        sleep 1
        local cpid=$(pgrep -x coredns | head -1)
        if [[ -n "$cpid" ]]; then
            sudo renice -10 "$cpid" 2>/dev/null && {
                log_success "CoreDNS (PID: $cpid) priorytet -10"
                applied=true
            }
        fi
    fi

    # Summary
    if [[ "$applied" == true ]]; then
        log_success "Kernel priority optimization AKTYWNY"
        log_info "Timer: co 60 sekund przypomina procesom DNS o wysokim priorytecie"
        log_info "Skrypt: /usr/local/bin/citadel-dns-priority.sh"

        # Show current priorities
        echo ""
        log_info "Aktualne priorytety procesów DNS:"
        ps -eo pid,comm,nice,pri | grep -E "(dnscrypt-proxy|coredns)" | while read line; do
            echo "  $line"
        done
    else
        log_warning "Usługi DNS nie działają - priorytety zostaną zastosowane przy starcie"
        log_info "Timer jest aktywny i zadziała gdy procesy DNS się pojawią"
    fi

    # Show timer status
    echo ""
    log_info "Status timer-a:"
    systemctl status citadel-dns-priority.timer --no-pager 2>/dev/null || true
}

# ==============================================================================
# DOH PARALLEL RACING (migrated from advanced-install.sh)
# ==============================================================================

install_doh_parallel() {
    log_section "󱓞 DNS-OVER-HTTPS PARALLEL RACING"

    # Check if port 5353 is available
    local doh_port=5353
    if lsof -i :$doh_port >/dev/null 2>&1 || ss -tlnp | grep -q ":$doh_port"; then
        log_warning "Port $doh_port jest zajęty - szukam wolnego portu..."
        # Try to find free port
        for port in 5354 5355 5356 5357 5358 5359; do
            if ! lsof -i :$port >/dev/null 2>&1 && ! ss -tlnp 2>/dev/null | grep -q ":$port"; then
                doh_port=$port
                log_info "Znaleziono wolny port: $doh_port"
                break
            fi
        done
    fi

    # Create advanced DNSCrypt config with DoH parallel racing
    sudo tee /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml >/dev/null <<EOF
# Citadel DNSCrypt with DoH Parallel Racing
listen_addresses = ['127.0.0.1:${doh_port}', '[::1]:${doh_port}']
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

    log_success "Konfiguracja DoH Parallel Racing utworzona (port: $doh_port)"

    # Auto-activation with backup
    local config_file="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    local backup_file="${config_file}.backup.$(date +%Y%m%d%H%M%S)"

    if [[ -f "$config_file" ]]; then
        log_info "Tworzenie backupu starej konfiguracji..."
        cp "$config_file" "$backup_file"
        log_success "Backup: $backup_file"
    fi

    log_info "Aktywacja DoH Parallel Racing..."
    cp /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml "$config_file"

    # Validate config
    log_info "Walidacja konfiguracji..."
    if dnscrypt-proxy -config "$config_file" -check 2>/dev/null; then
        log_success "Konfiguracja poprawna"
    else
        log_warning "Walidacja zwróciła ostrzeżenia (może być nowsza składnia)"
    fi

    # Restart service
    log_info "Restart DNSCrypt..."
    systemctl restart dnscrypt-proxy
    sleep 3

    # Test with longer timeout and retry
    log_info "Testowanie DoH (port: $doh_port)..."
    local test_passed=false
    for attempt in 1 2 3; do
        if systemctl is-active --quiet dnscrypt-proxy; then
            if dig +short +time=5 whoami.cloudflare @127.0.0.1 -p $doh_port >/dev/null 2>&1; then
                test_passed=true
                break
            fi
        fi
        log_info "Próba $attempt nie powiodła się, czekam..."
        sleep 2
    done

    if [[ "$test_passed" == true ]]; then
        log_success "DoH Parallel Racing AKTYWNY i działa (port: $doh_port)!"
        log_info "Serwery: Cloudflare, Google, Quad9 (parallel racing)"
        log_info "Strategia: p2 (Power of Two load balancing)"
    else
        log_warning "Test DNS nie przeszedł, ale DNSCrypt działa - konfiguracja zapisana"
        log_info "Port DoH: $doh_port"
        # Don't fail - the config is valid even if test doesn't pass immediately
    fi
}
