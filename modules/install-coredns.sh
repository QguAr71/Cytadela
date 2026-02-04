#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INSTALL-COREDNS MODULE v3.1                                   ║
# ║  CoreDNS installation with adblocking                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

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
            log_warning "Could not set capabilities on CoreDNS binary"
            log_warning "CoreDNS may need to run as root or with systemd CapabilityBoundingSet"
        }
    fi

    # Create auto-update blocklist service
    tee /etc/systemd/system/citadel-update-blocklist.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ Blocklist Auto-Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'set -e; tmp_raw="$(mktemp)"; tmp_block="$(mktemp)"; tmp_combined="$(mktemp)"; allowlist="/etc/coredns/zones/allowlist.txt"; curl -fsSL https://big.oisd.nl | grep -v "^#" > "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt | grep -v "^#" >> "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt | grep -v "^#" >> "$tmp_raw"; curl -fsSL https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/light.txt | grep -v "^#" >> "$tmp_raw"; awk "function emit(d){gsub(/^[*.]+/,\"\",d); gsub(/[[:space:]]+$/,\"\",d); if(d ~ /^[A-Za-z0-9.-]+$/ && d ~ /\\./) print \"0.0.0.0 \" d} {line=\\$0; sub(/\\r$/,\"\",line); if(line ~ /^[[:space:]]*$/) next; if(line ~ /^[[:space:]]*!/) next; if(line ~ /^(0\\.0\\.0\\.0|127\\.0\\.0\\.1|::)[[:space:]]+/){n=split(line,a,/[[:space:]]+/); if(n>=2){d=a[2]; sub(/^\\|\\|/,\"\",d); sub(/[\\^\\/].*$/,\"\",d); emit(d)}; next} if(line ~ /^\\|\\|/){sub(/^\\|\\|/,\"\",line); sub(/[\\^\\/].*$/,\"\",line); emit(line); next} if(line ~ /^[A-Za-z0-9.*-]+(\\\\.[A-Za-z0-9.-]+)+$/){emit(line); next}}" "$tmp_raw" | sort -u > "$tmp_block"; if [ "$(wc -l < \"$tmp_block\")" -lt 1000 ]; then rm -f "$tmp_raw" "$tmp_block" "$tmp_combined"; logger "Citadel++ blocklist update failed (too few entries)"; exit 0; fi; mv "$tmp_block" /etc/coredns/zones/blocklist.hosts; cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u | awk -v AL="$allowlist" "BEGIN{while((getline l < AL)>0){sub(/\\r$/,\"\",l); gsub(/^[[:space:]]+|[[:space:]]+$/,\"\",l); if(l!=\"\" && l !~ /^#/){k=tolower(l); a[k]=1; esc=k; gsub(/\\./,\"\\\\.\",esc); r[k]=\"\\\\.\" esc \"$\"}}} {d=\\$2; if(d==\"\") next; dl=tolower(d); for(k in a){ if(dl==k || dl ~ r[k]) next } print}" > "$tmp_combined"; mv "$tmp_combined" /etc/coredns/zones/combined.hosts; chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; systemctl reload coredns || systemctl restart coredns; rm -f "$tmp_raw"'
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
