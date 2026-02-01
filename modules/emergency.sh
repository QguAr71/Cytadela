#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ EMERGENCY MODULE v3.1                                         ║
# ║  Panic Bypass & Emergency Recovery (SPOF mitigation)                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

PANIC_STATE_FILE="${CYTADELA_STATE_DIR}/panic.state"
PANIC_BACKUP_RESOLV="${CYTADELA_STATE_DIR}/resolv.conf.pre-panic"
PANIC_ROLLBACK_TIMER=300

panic_bypass() {
    log_section "🚨 PANIC BYPASS - Emergency Recovery Mode"

    # Rate limiting: max 3 attempts per 60 seconds
    if declare -f rate_limit_check >/dev/null 2>&1; then
        if ! rate_limit_check "panic-bypass" 3 60; then
            return 1
        fi
    fi

    local rollback_seconds="${1:-$PANIC_ROLLBACK_TIMER}"

    [[ -f "$PANIC_STATE_FILE" ]] && {
        log_warning "Already in panic mode. Use 'panic-restore' to exit."
        return 1
    }

    log_warning "This will temporarily disable DNS protection!"
    log_info "Auto-rollback in ${rollback_seconds} seconds (or run 'panic-restore')"

    if [[ -t 0 && -t 1 ]]; then
        echo -n "Continue? [y/N]: "
        read -r answer
        [[ ! "$answer" =~ ^[Yy]$ ]] && {
            log_info "Cancelled."
            return 0
        }
    fi

    mkdir -p "$CYTADELA_STATE_DIR"

    log_info "Saving current state..."
    cp /etc/resolv.conf "$PANIC_BACKUP_RESOLV" 2>/dev/null || true
    nft list ruleset >"${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true

    echo "started=$(date -Iseconds)" >"$PANIC_STATE_FILE"
    echo "rollback_at=$(date -d "+${rollback_seconds} seconds" -Iseconds 2>/dev/null || date -Iseconds)" >>"$PANIC_STATE_FILE"
    echo "rollback_seconds=$rollback_seconds" >>"$PANIC_STATE_FILE"

    log_info "Flushing nftables rules..."
    nft flush ruleset 2>/dev/null || true

    log_info "Setting temporary public DNS..."
    rm -f /etc/resolv.conf 2>/dev/null || true
    cat >/etc/resolv.conf <<EOF
# CYTADELA PANIC MODE - Temporary public DNS
nameserver 9.9.9.9
nameserver 149.112.112.112
nameserver 2620:fe::fe
nameserver 2620:fe::9
EOF

    log_success "Panic mode ACTIVE. Protection disabled."
    log_warning "Auto-rollback in ${rollback_seconds}s. Run 'panic-restore' to restore manually."

    (
        sleep "$rollback_seconds"
        if [[ -f "$PANIC_STATE_FILE" ]]; then
            log_warning "Auto-rollback timer expired. Restoring protection..."
            panic_restore
        fi
    ) &

    log_info "Background rollback timer started (PID: $!)"
}

panic_restore() {
    log_section "🔄 PANIC RESTORE"

    [[ ! -f "$PANIC_STATE_FILE" ]] && {
        log_info "Not in panic mode."
        return 0
    }

    log_info "Restoring protected mode..."

    if [[ -f "$PANIC_BACKUP_RESOLV" ]]; then
        cp "$PANIC_BACKUP_RESOLV" /etc/resolv.conf
        log_success "Restored resolv.conf"
    fi

    if [[ -f "${CYTADELA_STATE_DIR}/nft.pre-panic" ]]; then
        nft -f "${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true
        log_success "Restored nftables rules"
    fi

    rm -f "$PANIC_STATE_FILE"
    log_success "Panic mode DEACTIVATED. Protection restored."
}

panic_status() {
    log_section "🚨 PANIC MODE STATUS"

    if [[ -f "$PANIC_STATE_FILE" ]]; then
        log_warning "PANIC MODE: ACTIVE"
        cat "$PANIC_STATE_FILE" | sed 's/^/  /'
    else
        log_success "PANIC MODE: INACTIVE (protected)"
    fi
}

emergency_refuse() {
    log_section "🚫 EMERGENCY REFUSE MODE"
    log_warning "This will make CoreDNS refuse all DNS queries!"

    local corefile="/etc/coredns/Corefile"
    [[ ! -f "$corefile" ]] && {
        log_error "CoreDNS not installed"
        return 1
    }

    cp "$corefile" "${corefile}.backup" 2>/dev/null || true

    cat >"$corefile" <<'EOF'
. {
    refuse
    log
}
EOF

    systemctl reload coredns 2>/dev/null || systemctl restart coredns
    log_success "Emergency refuse mode activated"
}

emergency_restore() {
    log_section "✅ EMERGENCY RESTORE"

    local corefile="/etc/coredns/Corefile"
    [[ -f "${corefile}.backup" ]] && cp "${corefile}.backup" "$corefile"

    systemctl reload coredns 2>/dev/null || systemctl restart coredns
    log_success "Normal operation restored"
}

emergency_killswitch_on() {
    log_section "🔒 KILL-SWITCH ON"
    log_warning "This will block all DNS except localhost!"

    nft add rule inet citadel filter_output ip daddr != 127.0.0.0/8 udp dport 53 drop 2>/dev/null || true
    nft add rule inet citadel filter_output ip6 daddr != ::1 udp dport 53 drop 2>/dev/null || true

    log_success "Kill-switch activated"
}

emergency_killswitch_off() {
    log_section "🔓 KILL-SWITCH OFF"

    nft delete rule inet citadel filter_output ip daddr != 127.0.0.0/8 udp dport 53 drop 2>/dev/null || true
    nft delete rule inet citadel filter_output ip6 daddr != ::1 udp dport 53 drop 2>/dev/null || true

    log_success "Kill-switch deactivated"
}

# Aliases for compatibility with cytadela++.new.sh
killswitch_on() {
    emergency_killswitch_on
}

killswitch_off() {
    emergency_killswitch_off
}
