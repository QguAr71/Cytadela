#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ ADBLOCK MODULE v3.1                                           ║
# ║  DNS-based adblocking with allowlist support                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

adblock_rebuild() {
    local custom="/etc/coredns/zones/custom.hosts"
    local allowlist="/etc/coredns/zones/allowlist.txt"
    local blocklist="/etc/coredns/zones/blocklist.hosts"
    local combined="/etc/coredns/zones/combined.hosts"

    mkdir -p /etc/coredns/zones
    touch "$custom" "$allowlist" "$blocklist"
    chmod 0644 "$custom" 2>/dev/null || true
    chmod 0644 "$allowlist" 2>/dev/null || true
    
    if [[ -s "$allowlist" ]]; then
        cat "$custom" "$blocklist" | sort -u | awk -v AL="$allowlist" 'BEGIN{while((getline l < AL)>0){sub(/\r$/,"",l); gsub(/^[[:space:]]+|[[:space:]]+$/,"",l); if(l!="" && l !~ /^#/){k=tolower(l); a[k]=1; esc=k; gsub(/\./,"\\.",esc); r[k]="\\." esc "$"}}} {d=$2; if(d=="") next; dl=tolower(d); for(k in a){ if(dl==k || dl ~ r[k]) next } print}' > "$combined"
    else
        cat "$custom" "$blocklist" | sort -u > "$combined"
    fi
    
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
    
    sed -i -E "/^[0-9.:]+[[:space:]]+${domain//./\.}([[:space:]]|$)/d" /etc/coredns/zones/custom.hosts || true
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

allowlist_list() {
    mkdir -p /etc/coredns/zones
    touch /etc/coredns/zones/allowlist.txt
    chmod 0644 /etc/coredns/zones/allowlist.txt 2>/dev/null || true
    cat /etc/coredns/zones/allowlist.txt 2>/dev/null || true
}

allowlist_add() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: allowlist-add domena"
        return 1
    fi
    if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Nieprawidłowa domena: $domain"
        return 1
    fi
    
    mkdir -p /etc/coredns/zones
    touch /etc/coredns/zones/allowlist.txt
    chmod 0644 /etc/coredns/zones/allowlist.txt 2>/dev/null || true
    
    if grep -qiE "^${domain//./\.}$" /etc/coredns/zones/allowlist.txt 2>/dev/null; then
        log_info "Już istnieje w allowlist: $domain"
    else
        printf '%s\n' "$domain" >> /etc/coredns/zones/allowlist.txt
        log_success "Dodano do allowlist: $domain"
    fi
    
    adblock_rebuild
    adblock_reload
}

allowlist_remove() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: allowlist-remove domena"
        return 1
    fi
    
    if [[ ! -f /etc/coredns/zones/allowlist.txt ]]; then
        log_warning "Brak /etc/coredns/zones/allowlist.txt"
        return 0
    fi
    
    sed -i -E "/^[[:space:]]*${domain//./\.}[[:space:]]*$/Id" /etc/coredns/zones/allowlist.txt || true
    log_success "Usunięto z allowlist (jeśli istniało): $domain"
    
    adblock_rebuild
    adblock_reload
}
