#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ HEALTH MODULE v3.1                                            ║
# ║  Health checks and watchdog                                               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Load centralized test functions
source_lib "${CYTADELA_LIB}/test-core.sh"

HEALTH_CHECK_SERVICES=(dnscrypt-proxy coredns)

health_check_dns() {
    test_dns_resolution "cloudflare.com"
}

health_status() {
    draw_section_header "󰓙 HEALTH STATUS"

    local all_healthy=1

    echo "=== SERVICES ==="
    for svc in "${HEALTH_CHECK_SERVICES[@]}"; do
        if test_service_active "$svc"; then
            printf "${GREEN}%-20s ACTIVE${NC}\n" "$svc"
        else
            printf "${RED}%-20s INACTIVE${NC}\n" "$svc"
            all_healthy=0
        fi
    done

    echo ""
    echo "=== DNS PROBE ==="
    if health_check_dns; then
        log_success "DNS resolution working (127.0.0.1)"
    else
        log_error "DNS resolution FAILED"
        all_healthy=0
    fi

    echo ""
    echo "=== FIREWALL ==="
    if test_nftables_citadel; then
        log_success "Citadel firewall rules loaded"
    else
        log_warning "Citadel firewall rules NOT loaded"
    fi

    echo ""
    if [[ $all_healthy -eq 1 ]]; then
        log_success "All health checks PASSED"
        return 0
    else
        log_error "Some health checks FAILED"
        return 1
    fi
}

install_health_watchdog() {
    log_section "󰊠 INSTALLING HEALTH WATCHDOG"

    log_info "Creating health check script..."
    cat >/usr/local/bin/citadel-health-check <<'EOF'
#!/bin/bash
if dig +short +time=2 cloudflare.com @127.0.0.1 >/dev/null 2>&1; then
    exit 0
else
    systemctl restart coredns 2>/dev/null
    sleep 2
    if dig +short +time=2 cloudflare.com @127.0.0.1 >/dev/null 2>&1; then
        exit 0
    fi
    exit 1
fi
EOF
    chmod +x /usr/local/bin/citadel-health-check

    log_info "Creating systemd overrides..."
    mkdir -p /etc/systemd/system/dnscrypt-proxy.service.d
    cat >/etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf <<'EOF'
[Service]
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=5
EOF

    mkdir -p /etc/systemd/system/coredns.service.d
    cat >/etc/systemd/system/coredns.service.d/citadel-restart.conf <<'EOF'
[Service]
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=5
EOF

    log_info "Creating health check timer..."
    cat >/etc/systemd/system/citadel-health-check.service <<'EOF'
[Unit]
Description=Citadel DNS Health Check
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel-health-check
EOF

    cat >/etc/systemd/system/citadel-health-check.timer <<'EOF'
[Unit]
Description=Citadel DNS Health Check Timer

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now citadel-health-check.timer

    log_success "Health watchdog installed"
    log_info "Services will auto-restart on failure"
    log_info "Health checks run every 5 minutes"
}

uninstall_health_watchdog() {
    log_section "󰩹 UNINSTALLING HEALTH WATCHDOG"

    systemctl stop citadel-health-check.timer 2>/dev/null || true
    systemctl disable citadel-health-check.timer 2>/dev/null || true

    rm -f /etc/systemd/system/citadel-health-check.service
    rm -f /etc/systemd/system/citadel-health-check.timer
    rm -f /usr/local/bin/citadel-health-check
    rm -f /etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf
    rm -f /etc/systemd/system/coredns.service.d/citadel-restart.conf

    rmdir /etc/systemd/system/dnscrypt-proxy.service.d 2>/dev/null || true
    rmdir /etc/systemd/system/coredns.service.d 2>/dev/null || true

    systemctl daemon-reload

    log_success "Health watchdog uninstalled"
}
