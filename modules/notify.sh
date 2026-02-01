#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ NOTIFY MODULE v3.1                                            ║
# ║  Desktop notifications (Issue #16)                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

NOTIFY_ENABLED_FILE="/var/lib/cytadela/notify-enabled"

notify_send() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"
    local icon="${4:-dialog-information}"

    # Check if notifications are enabled
    [[ ! -f "$NOTIFY_ENABLED_FILE" ]] && return 0

    # Check if notify-send is available
    if ! command -v notify-send &>/dev/null; then
        return 0
    fi

    # Get user who should receive notification
    local notify_user
    notify_user=$(cat "$NOTIFY_ENABLED_FILE" 2>/dev/null)
    [[ -z "$notify_user" ]] && return 0

    # Send notification as user
    local user_id
    user_id=$(id -u "$notify_user")
    sudo -u "$notify_user" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${user_id}/bus \
        notify-send -u "$urgency" -i "$icon" "$title" "$message" 2>/dev/null || true
}

notify_enable() {
    log_section "🔔 ENABLE DESKTOP NOTIFICATIONS"

    # Check if notify-send is available
    if ! command -v notify-send &>/dev/null; then
        log_error "notify-send not found. Install it first:"
        echo "  Arch/Manjaro: sudo pacman -S libnotify"
        echo "  Debian/Ubuntu: sudo apt install libnotify-bin"
        echo "  Fedora: sudo dnf install libnotify"
        return 1
    fi

    # Get current user
    local current_user="${SUDO_USER:-$USER}"

    log_info "Enabling notifications for user: $current_user"

    # Save to file
    mkdir -p /var/lib/cytadela
    echo "$current_user" >"$NOTIFY_ENABLED_FILE"

    # Test notification
    notify_send "Cytadela++" "Desktop notifications enabled" "normal" "security-high"

    log_success "Notifications enabled for $current_user"
    log_info "Notifications will be sent for:"
    echo "  - Health check failures"
    echo "  - Service restarts"
    echo "  - Blocklist updates"
    echo "  - Panic mode activation"
}

notify_disable() {
    log_section "🔕 DISABLE DESKTOP NOTIFICATIONS"

    rm -f "$NOTIFY_ENABLED_FILE"
    log_success "Notifications disabled"
}

notify_status() {
    log_section "📊 NOTIFICATION STATUS"

    if [[ -f "$NOTIFY_ENABLED_FILE" ]]; then
        local notify_user
        notify_user=$(cat "$NOTIFY_ENABLED_FILE")
        echo -e "${GREEN}Status: ENABLED${NC}"
        echo "User: $notify_user"

        if command -v notify-send &>/dev/null; then
            echo -e "notify-send: ${GREEN}available${NC}"
        else
            echo -e "notify-send: ${RED}NOT INSTALLED${NC}"
        fi
    else
        echo -e "${YELLOW}Status: DISABLED${NC}"
    fi
}

notify_test() {
    log_section "🧪 TEST NOTIFICATION"

    if [[ ! -f "$NOTIFY_ENABLED_FILE" ]]; then
        log_error "Notifications are disabled. Enable first: notify-enable"
        return 1
    fi

    log_info "Sending test notifications..."

    notify_send "Cytadela++ Test" "Normal priority notification" "normal" "dialog-information"
    sleep 1
    notify_send "Cytadela++ Warning" "Low priority notification" "low" "dialog-warning"
    sleep 1
    notify_send "Cytadela++ Critical" "Critical priority notification" "critical" "dialog-error"

    log_success "Test notifications sent"
}

# Hook functions for integration with other modules

notify_health_failure() {
    local service="$1"
    notify_send "Cytadela++ Health Check" \
        "Service $service is not responding" \
        "critical" \
        "dialog-error"
}

notify_service_restart() {
    local service="$1"
    notify_send "Cytadela++ Service" \
        "Service $service has been restarted" \
        "normal" \
        "view-refresh"
}

notify_blocklist_updated() {
    local count="$1"
    notify_send "Cytadela++ Blocklist" \
        "Blocklist updated: $count domains" \
        "low" \
        "security-medium"
}

notify_panic_mode() {
    local action="$1"
    if [[ "$action" == "activated" ]]; then
        notify_send "Cytadela++ PANIC MODE" \
            "Emergency bypass activated" \
            "critical" \
            "security-low"
    else
        notify_send "Cytadela++ PANIC MODE" \
            "Normal mode restored" \
            "normal" \
            "security-high"
    fi
}

notify_dns_leak_detected() {
    notify_send "Cytadela++ DNS LEAK" \
        "DNS leak detected - check firewall rules" \
        "critical" \
        "dialog-error"
}
