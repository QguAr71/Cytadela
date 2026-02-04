#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3+ - GUM-ENHANCED DASHBOARD                                 ║
# ║  Interactive TUI dashboard using gum for better user experience        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Check if gum is available
if ! command -v gum >/dev/null 2>&1; then
    echo "❌ Gum is not installed. Install it first:"
    echo "   sudo pacman -S gum  # Arch/CachyOS"
    echo "   sudo apt install gum # Ubuntu/Debian"
    echo "   brew install gum     # macOS"
    exit 1
fi

# Colors and styling
HEADER_COLOR="212"
SUCCESS_COLOR="46"
ERROR_COLOR="196"
WARNING_COLOR="214"
INFO_COLOR="39"

# Main dashboard
main_dashboard() {
    clear

    # Header
    gum style --bold --foreground "$HEADER_COLOR" --border double --padding "1 2" \
        "Citadel v3.3+ Interactive Dashboard"

    echo ""
    gum style --foreground "$INFO_COLOR" "Welcome to Citadel DNS Protection System"
    echo ""

    # Main menu
    choice=$(gum choose \
        "📊 System Status" \
        "🛡️ Security Overview" \
        "🔧 Configuration" \
        "📈 Monitoring" \
        "🔄 Service Control" \
        "📋 Event Logs" \
        "🛑 Exit" \
        --header "Select an option:")

    handle_choice "$choice"
}

# Handle menu choices
handle_choice() {
    case "$1" in
        "📊 System Status")
            show_system_status
            ;;
        "🛡️ Security Overview")
            show_security_overview
            ;;
        "🔧 Configuration")
            show_configuration_menu
            ;;
        "📈 Monitoring")
            show_monitoring_menu
            ;;
        "🔄 Service Control")
            show_service_control
            ;;
        "📋 Event Logs")
            show_event_logs
            ;;
        "🛑 Exit")
            gum style --foreground "$SUCCESS_COLOR" "Goodbye! 👋"
            exit 0
            ;;
        *)
            gum style --foreground "$ERROR_COLOR" "Unknown option: $1"
            sleep 2
            main_dashboard
            ;;
    esac
}

# System Status
show_system_status() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "System Status"
    echo ""

    # DNS Services
    echo "DNS Services:" | gum style --foreground "$INFO_COLOR"
    check_service "dnscrypt-proxy" "DNSCrypt"
    check_service "coredns" "CoreDNS"
    echo ""

    # Firewall
    echo "Firewall:" | gum style --foreground "$INFO_COLOR"
    if nft list ruleset 2>/dev/null | grep -q "citadel"; then
        gum style --foreground "$SUCCESS_COLOR" "● NFTables rules active"
    else
        gum style --foreground "$WARNING_COLOR" "● NFTables rules not loaded"
    fi
    echo ""

    # DNS Resolution
    echo "DNS Resolution:" | gum style --foreground "$INFO_COLOR"
    if timeout 3 dig @127.0.0.1 google.com +short >/dev/null 2>&1; then
        gum style --foreground "$SUCCESS_COLOR" "● DNS resolution working"
    else
        gum style --foreground "$ERROR_COLOR" "● DNS resolution failed"
    fi
    echo ""

    # Blocklist
    echo "Blocklist:" | gum style --foreground "$INFO_COLOR"
    if [[ -f /etc/coredns/zones/combined.hosts ]]; then
        count=$(wc -l < /etc/coredns/zones/combined.hosts)
        gum style --foreground "$SUCCESS_COLOR" "● $count blocked domains"
    else
        gum style --foreground "$WARNING_COLOR" "● Blocklist not found"
    fi
    echo ""

    # Back to main menu
    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return to main menu..."
    read
    main_dashboard
}

# Security Overview
show_security_overview() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Security Overview"
    echo ""

    # Reputation System
    echo "Reputation System:" | gum style --foreground "$INFO_COLOR"
    if [[ -f /var/lib/cytadela/reputation.db ]]; then
        suspicious=$(grep -c "0\.[0-9]" /var/lib/cytadela/reputation.db 2>/dev/null || echo 0)
        gum style --foreground "$SUCCESS_COLOR" "● Active - $suspicious suspicious IPs"
    else
        gum style --foreground "$WARNING_COLOR" "● Not initialized"
    fi
    echo ""

    # ASN Blocking
    echo "ASN Blocking:" | gum style --foreground "$INFO_COLOR"
    if [[ -f /etc/cytadela/asn-blocklist.txt ]]; then
        asn_count=$(grep -c '^AS' /etc/cytadela/asn-blocklist.txt 2>/dev/null || echo 0)
        gum style --foreground "$SUCCESS_COLOR" "● $asn_count ASNs blocked"
    else
        gum style --foreground "$WARNING_COLOR" "● Not configured"
    fi
    echo ""

    # Event Logging
    echo "Event Logging:" | gum style --foreground "$INFO_COLOR"
    if [[ -f /var/log/cytadela/events.json ]]; then
        event_count=$(wc -l < /var/log/cytadela/events.json 2>/dev/null || echo 0)
        gum style --foreground "$SUCCESS_COLOR" "● Active - $event_count events logged"
    else
        gum style --foreground "$WARNING_COLOR" "● Not active"
    fi
    echo ""

    # Honeypot
    echo "Honeypot:" | gum style --foreground "$INFO_COLOR"
    honeypot_count=$(find /var/lib/cytadela/honeypot -name "config" 2>/dev/null | wc -l 2>/dev/null || echo 0)
    if [[ $honeypot_count -gt 0 ]]; then
        gum style --foreground "$SUCCESS_COLOR" "● $honeypot_count honeypots active"
    else
        gum style --foreground "$WARNING_COLOR" "● No honeypots deployed"
    fi
    echo ""

    # Back to main menu
    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return to main menu..."
    read
    main_dashboard
}

# Configuration Menu
show_configuration_menu() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Configuration Menu"
    echo ""

    choice=$(gum choose \
        "🔍 View Current Config" \
        "⚙️ Edit Adblock Settings" \
        "🛡️ Configure Security" \
        "🔄 Update Blocklists" \
        "⬅️ Back to Main Menu" \
        --header "Configuration Options:")

    case "$choice" in
        "🔍 View Current Config")
            view_current_config
            ;;
        "⚙️ Edit Adblock Settings")
            edit_adblock_settings
            ;;
        "🛡️ Configure Security")
            configure_security
            ;;
        "🔄 Update Blocklists")
            update_blocklists
            ;;
        "⬅️ Back to Main Menu")
            main_dashboard
            ;;
    esac
}

# Service Control
show_service_control() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Service Control"
    echo ""

    # Get service status
    dnscrypt_status=$(systemctl is-active dnscrypt-proxy 2>/dev/null || echo "unknown")
    coredns_status=$(systemctl is-active coredns 2>/dev/null || echo "unknown")

    choice=$(gum choose \
        "🔄 Restart DNSCrypt ($dnscrypt_status)" \
        "🔄 Restart CoreDNS ($coredns_status)" \
        "🔄 Restart All Services" \
        "⬅️ Back to Main Menu" \
        --header "Service Control Options:")

    case "$choice" in
        "🔄 Restart DNSCrypt"*)
            restart_service "dnscrypt-proxy" "DNSCrypt"
            ;;
        "🔄 Restart CoreDNS"*)
            restart_service "coredns" "CoreDNS"
            ;;
        "🔄 Restart All Services")
            restart_service "dnscrypt-proxy" "DNSCrypt"
            restart_service "coredns" "CoreDNS"
            ;;
        "⬅️ Back to Main Menu")
            main_dashboard
            ;;
    esac

    show_service_control
}

# Event Logs
show_event_logs() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Event Logs"
    echo ""

    if [[ ! -f /var/log/cytadela/events.json ]]; then
        gum style --foreground "$WARNING_COLOR" "No event logs found"
        echo ""
        gum style --foreground "$INFO_COLOR" "Press Enter to return..."
        read
        main_dashboard
        return
    fi

    choice=$(gum choose \
        "📊 Event Statistics" \
        "🔍 Recent Events" \
        "🔎 Search Events" \
        "⬅️ Back to Main Menu" \
        --header "Event Log Options:")

    case "$choice" in
        "📊 Event Statistics")
            show_event_stats
            ;;
        "🔍 Recent Events")
            show_recent_events
            ;;
        "🔎 Search Events")
            search_events
            ;;
        "⬅️ Back to Main Menu")
            main_dashboard
            ;;
    esac
}

# Helper functions
check_service() {
    local service="$1"
    local name="$2"

    if systemctl is-active --quiet "$service" 2>/dev/null; then
        gum style --foreground "$SUCCESS_COLOR" "● $name: RUNNING"
    else
        gum style --foreground "$ERROR_COLOR" "● $name: STOPPED"
    fi
}

restart_service() {
    local service="$1"
    local name="$2"

    gum spin --title "Restarting $name..." -- \
        sudo systemctl restart "$service"

    if systemctl is-active --quiet "$service" 2>/dev/null; then
        gum style --foreground "$SUCCESS_COLOR" "✓ $name restarted successfully"
    else
        gum style --foreground "$ERROR_COLOR" "✗ Failed to restart $name"
    fi

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to continue..."
    read
}

view_current_config() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Current Configuration"
    echo ""

    # This would show current Citadel configuration
    gum style --foreground "$WARNING_COLOR" "Configuration viewer not yet implemented"
    echo ""
    gum style --foreground "$INFO_COLOR" "Use: citadel.sh config show"
    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_configuration_menu
}

edit_adblock_settings() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Adblock Settings"
    echo ""

    # Get current profile
    current_profile="balanced"  # Default
    if [[ -f /var/lib/cytadela/blocklist-profile.txt ]]; then
        current_profile=$(cat /var/lib/cytadela/blocklist-profile.txt)
    fi

    gum style --foreground "$INFO_COLOR" "Current profile: $current_profile"
    echo ""

    new_profile=$(gum choose "light" "balanced" "aggressive" "privacy" \
        --header "Select new adblock profile:" \
        --selected "$current_profile")

    if [[ "$new_profile" != "$current_profile" ]]; then
        gum spin --title "Switching to $new_profile profile..." -- \
            sudo ./citadel.sh adblock blocklist-switch "$new_profile"

        gum style --foreground "$SUCCESS_COLOR" "✓ Profile changed to $new_profile"
    else
        gum style --foreground "$INFO_COLOR" "Profile unchanged"
    fi

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_configuration_menu
}

configure_security() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Security Configuration"
    echo ""

    gum style --foreground "$WARNING_COLOR" "Advanced security configuration not yet implemented in TUI"
    echo ""
    gum style --foreground "$INFO_COLOR" "Available commands:"
    echo "• sudo ./citadel.sh reputation-config threshold 0.15"
    echo "• sudo ./citadel.sh asn-add AS12345 'Bad actor'"
    echo "• sudo ./citadel.sh honeypot-deploy 2222 ssh"
    echo ""

    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_configuration_menu
}

update_blocklists() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Update Blocklists"
    echo ""

    gum spin --title "Updating blocklists..." -- \
        sudo ./citadel.sh backup lists-update

    gum style --foreground "$SUCCESS_COLOR" "✓ Blocklists updated"
    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_configuration_menu
}

show_monitoring_menu() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Monitoring Menu"
    echo ""

    choice=$(gum choose \
        "📊 System Status" \
        "📈 Cache Statistics" \
        "🔍 Diagnostics" \
        "✅ Verification" \
        "⬅️ Back to Main Menu" \
        --header "Monitoring Options:")

    case "$choice" in
        "📊 System Status")
            show_detailed_status
            ;;
        "📈 Cache Statistics")
            show_cache_stats
            ;;
        "🔍 Diagnostics")
            run_diagnostics
            ;;
        "✅ Verification")
            run_verification
            ;;
        "⬅️ Back to Main Menu")
            main_dashboard
            ;;
    esac
}

show_detailed_status() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Detailed System Status"
    echo ""

    gum spin --title "Getting detailed status..." -- \
        sudo ./citadel.sh monitor status | gum pager

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_monitoring_menu
}

show_cache_stats() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Cache Statistics"
    echo ""

    gum spin --title "Getting cache statistics..." -- \
        sudo ./citadel.sh monitor cache-stats | gum pager

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_monitoring_menu
}

run_diagnostics() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "System Diagnostics"
    echo ""

    gum spin --title "Running diagnostics..." -- \
        sudo ./citadel.sh monitor diagnostics | gum pager

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_monitoring_menu
}

run_verification() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "System Verification"
    echo ""

    gum spin --title "Running verification..." -- \
        sudo ./citadel.sh monitor verify | gum pager

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_monitoring_menu
}

show_event_stats() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Event Statistics"
    echo ""

    if [[ -f /var/log/cytadela/events.json ]]; then
        gum spin --title "Analyzing events..." -- \
            sudo ./citadel.sh events-stats | gum pager
    else
        gum style --foreground "$WARNING_COLOR" "No event logs found"
    fi

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_event_logs
}

show_recent_events() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Recent Events"
    echo ""

    if [[ -f /var/log/cytadela/events.json ]]; then
        gum spin --title "Getting recent events..." -- \
            sudo ./citadel.sh events-recent | gum pager
    else
        gum style --foreground "$WARNING_COLOR" "No event logs found"
    fi

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_event_logs
}

search_events() {
    clear
    gum style --bold --foreground "$HEADER_COLOR" "Search Events"
    echo ""

    event_type=$(gum input --placeholder "asn_block" --header "Event type (optional):")
    hours=$(gum input --placeholder "24" --header "Hours back:")

    if [[ -f /var/log/cytadela/events.json ]]; then
        gum spin --title "Searching events..." -- \
            sudo ./citadel.sh events-query "${event_type:-}" --hours "$hours" | gum pager
    else
        gum style --foreground "$WARNING_COLOR" "No event logs found"
    fi

    echo ""
    gum style --foreground "$INFO_COLOR" "Press Enter to return..."
    read
    show_event_logs
}

# Start the dashboard
main_dashboard
