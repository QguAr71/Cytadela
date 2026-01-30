#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ AUTO-UPDATE MODULE v3.1                                       ║
# ║  Automatic blocklist updates with systemd timer (Issue #13)               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

AUTO_UPDATE_SERVICE="/etc/systemd/system/cytadela-auto-update.service"
AUTO_UPDATE_TIMER="/etc/systemd/system/cytadela-auto-update.timer"

auto_update_enable() {
    log_section "🔄 ENABLING AUTO-UPDATE"
    
    # Check if LKG module is available
    if ! declare -f lists_update >/dev/null 2>&1; then
        load_module "lkg"
    fi
    
    # Create systemd service
    log_info "Creating systemd service..."
    tee "$AUTO_UPDATE_SERVICE" >/dev/null <<'EOF'
[Unit]
Description=Cytadela++ Automatic Blocklist Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/cytadela++ lists-update
StandardOutput=journal
StandardError=journal
SyslogIdentifier=cytadela-auto-update

# Restart on failure
Restart=on-failure
RestartSec=300

[Install]
WantedBy=multi-user.target
EOF
    
    # Create systemd timer
    log_info "Creating systemd timer (daily updates)..."
    tee "$AUTO_UPDATE_TIMER" >/dev/null <<'EOF'
[Unit]
Description=Cytadela++ Daily Blocklist Update Timer
Requires=cytadela-auto-update.service

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF
    
    # Reload systemd
    systemctl daemon-reload
    
    # Enable and start timer
    systemctl enable cytadela-auto-update.timer
    systemctl start cytadela-auto-update.timer
    
    log_success "Auto-update enabled (daily updates with 1h random delay)"
    
    # Show status
    auto_update_status
}

auto_update_disable() {
    log_section "🛑 DISABLING AUTO-UPDATE"
    
    # Stop and disable timer
    systemctl stop cytadela-auto-update.timer 2>/dev/null || true
    systemctl disable cytadela-auto-update.timer 2>/dev/null || true
    
    log_success "Auto-update disabled"
}

auto_update_status() {
    log_section "📊 AUTO-UPDATE STATUS"
    
    if systemctl is-enabled cytadela-auto-update.timer &>/dev/null; then
        echo -e "${GREEN}Status: ENABLED${NC}"
    else
        echo -e "${YELLOW}Status: DISABLED${NC}"
    fi
    
    if systemctl is-active cytadela-auto-update.timer &>/dev/null; then
        echo -e "${GREEN}Timer: ACTIVE${NC}"
    else
        echo -e "${YELLOW}Timer: INACTIVE${NC}"
    fi
    
    echo ""
    echo "Schedule:"
    systemctl list-timers cytadela-auto-update.timer --no-pager 2>/dev/null || echo "  Timer not found"
    
    echo ""
    echo "Last update logs:"
    journalctl -u cytadela-auto-update.service -n 10 --no-pager 2>/dev/null || echo "  No logs available"
}

auto_update_now() {
    log_section "🔄 MANUAL UPDATE NOW"
    
    if ! declare -f lists_update >/dev/null 2>&1; then
        load_module "lkg"
    fi
    
    log_info "Running blocklist update..."
    if lists_update; then
        log_success "Blocklist updated successfully"
    else
        log_error "Blocklist update failed"
        return 1
    fi
}

auto_update_configure() {
    log_section "⚙️  CONFIGURE AUTO-UPDATE"
    
    echo "Select update frequency:"
    echo "  1) Daily (default)"
    echo "  2) Weekly"
    echo "  3) Custom"
    echo ""
    read -p "Choice [1-3]: " choice
    
    local calendar="daily"
    case "$choice" in
        1) calendar="daily" ;;
        2) calendar="weekly" ;;
        3)
            echo ""
            echo "Enter systemd OnCalendar format (e.g., 'Mon *-*-* 03:00:00'):"
            read -p "Calendar: " calendar
            ;;
        *)
            log_warning "Invalid choice, using daily"
            calendar="daily"
            ;;
    esac
    
    log_info "Updating timer to: $calendar"
    
    # Update timer file
    sed -i "s/^OnCalendar=.*/OnCalendar=$calendar/" "$AUTO_UPDATE_TIMER"
    
    # Reload and restart
    systemctl daemon-reload
    systemctl restart cytadela-auto-update.timer
    
    log_success "Auto-update configured: $calendar"
    auto_update_status
}
