#!/bin/bash
# ============================================================================
# CITADEL HELP SYSTEM - CONTEXTUAL HELP INTERFACE
# ============================================================================
# Contextual help system for Citadel commands and workflows
#
# Features:
# - Context-aware help based on current command/module
# - Workflow guidance for complex operations
# - Intelligent suggestions based on system state
# - Step-by-step tutorials for specific scenarios
#
# Dependencies: jq (for JSON parsing)
# ============================================================================

# Load core framework
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../framework/help-core.sh"

# ============================================================================
# CONTEXT AWARENESS FUNCTIONS
# ============================================================================

# Detect current Citadel installation state
detect_citadel_state() {
    local state="unknown"

    # Check if Citadel is installed
    if systemctl is-active --quiet coredns 2>/dev/null || systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then
        state="installed"
    elif [[ -f "/etc/coredns/Corefile" ]] || [[ -f "/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]]; then
        state="installed_partial"
    else
        state="not_installed"
    fi

    echo "$state"
}

# Detect current DNS configuration
detect_dns_state() {
    local dns_state="unknown"

    # Check if using Citadel DNS
    if grep -q "127.0.0.1" /etc/resolv.conf 2>/dev/null; then
        dns_state="citadel"
    elif grep -q "systemd-resolved" /etc/resolv.conf 2>/dev/null; then
        dns_state="systemd"
    else
        dns_state="custom"
    fi

    echo "$dns_state"
}

# Get system information for contextual help
get_system_context() {
    local context=""

    # OS information
    if command -v lsb_release >/dev/null 2>&1; then
        context+="os:$(lsb_release -si)"
    elif [[ -f /etc/os-release ]]; then
        context+="os:$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')"
    fi

    # Architecture
    context+=",arch:$(uname -m)"

    # Citadel state
    context+=",citadel:$(detect_citadel_state)"

    # DNS state
    context+=",dns:$(detect_dns_state)"

    echo "$context"
}

# ============================================================================
# WORKFLOW GUIDANCE FUNCTIONS
# ============================================================================

# Get workflow steps for specific scenario
get_workflow_steps() {
    local scenario="$1"
    local language="${2:-$(detect_help_language)}"

    case "$scenario" in
        "first_install")
            cat << EOF
1. **System Preparation**
   - Ensure you have sudo/root access
   - Check system requirements (Ubuntu/Debian/CentOS/RHEL)
   - Backup current DNS configuration if needed

2. **Run Installation Wizard**
   - Execute: \`sudo ./citadel.sh install wizard\`
   - Choose installation profile (recommended: Standard)
   - Select additional components as needed
   - Follow on-screen instructions

3. **Post-Installation**
   - Verify installation: \`citadel status\`
   - Test DNS resolution: \`dig google.com\`
   - Configure firewall: \`citadel firewall-safe\`

4. **Basic Usage**
   - Switch to Citadel DNS: \`citadel configure-system\`
   - Check status: \`citadel status\`
   - View help: \`citadel help\`
EOF
            ;;

        "dns_troubleshooting")
            cat << EOF
1. **Check Current DNS State**
   - Run: \`citadel status\`
   - Check: \`cat /etc/resolv.conf\`
   - Verify services: \`systemctl status coredns dnscrypt-proxy\`

2. **Test DNS Resolution**
   - Simple test: \`dig @127.0.0.1 google.com\`
   - External test: \`dig @8.8.8.8 google.com\`
   - Run diagnostics: \`citadel diagnostics\`

3. **Common Issues & Solutions**
   - **Port conflicts**: Run \`citadel fix-ports\`
   - **Firewall blocking**: Try \`citadel firewall-safe\`
   - **Service not running**: Check \`systemctl status\` and logs

4. **Advanced Troubleshooting**
   - Full verification: \`citadel verify\`
   - Emergency restore: \`citadel emergency-restore\`
   - Check logs: \`citadel logs\`
EOF
            ;;

        "security_hardening")
            cat << EOF
1. **Enable Strict Firewall**
   - Command: \`citadel firewall-strict\`
   - This enables DNS leak protection
   - May break some applications initially

2. **Configure Adblocking**
   - Switch profile: \`citadel blocklist-switch security\`
   - Update lists: \`citadel lists-update\`
   - Check status: \`citadel adblock-status\`

3. **Enable Monitoring**
   - Health checks: \`citadel health-install\`
   - Prometheus metrics: \`citadel prometheus-status\`
   - Security auditing: Enable logging features

4. **Additional Security**
   - Supply chain verification: \`citadel supply-init\`
   - Automatic updates: \`citadel auto-update-enable\`
   - Emergency killswitch: \`citadel killswitch-on\`
EOF
            ;;

        "performance_optimization")
            cat << EOF
1. **DNS Cache Optimization**
   - Check cache stats: \`citadel cache-stats\`
   - Monitor cache: \`citadel cache-stats-watch\`
   - Reset if needed: \`citadel cache-stats-reset\`

2. **Benchmark Current Performance**
   - DNS benchmark: \`citadel benchmark-dns\`
   - Full benchmark: \`citadel benchmark-all\`
   - Compare results: \`citadel benchmark-compare\`

3. **System Optimization**
   - Kernel priority: \`citadel optimize-kernel\`
   - Parallel DNS: \`citadel install-doh-parallel\`
   - Location awareness: \`citadel location-status\`

4. **Monitoring & Alerts**
   - Enable notifications: \`citadel notify-enable\`
   - Dashboard: \`citadel install-dashboard\`
   - Health monitoring: \`citadel health-status\`
EOF
            ;;

        "emergency_recovery")
            cat << EOF
1. **Assess Situation**
   - Check system status: \`citadel status\`
   - Run diagnostics: \`citadel diagnostics\`
   - Identify the problem (DNS, network, services)

2. **Try Safe Recovery**
   - Emergency network restore: \`citadel emergency-restore\`
   - Restore system DNS: \`citadel restore-system\`
   - Reset firewall: \`citadel firewall-safe\`

3. **Advanced Recovery Options**
   - Panic bypass: \`citadel panic-bypass\` (temporary)
   - Emergency refuse: \`citadel emergency-refuse\` (block all)
   - Killswitch: \`citadel killswitch-on\` (emergency stop)

4. **Post-Recovery**
   - Verify everything works: \`citadel verify\`
   - Test internet: \`ping 8.8.8.8\`
   - Restore normal operation: \`citadel configure-system\`
EOF
            ;;

        *)
            echo "No workflow guidance available for: $scenario"
            return 1
            ;;
    esac
}

# ============================================================================
# CONTEXTUAL HELP MAIN FUNCTIONS
# ============================================================================

# Show contextual help for specific command
contextual_command_help() {
    local command="$1"
    local context="${2:-$(get_system_context)}"
    local language="${3:-$(detect_help_language)}"

    echo "=== CONTEXTUAL HELP FOR: $command ==="
    echo ""

    # Show basic command help
    cli_show_command_help "$command" "$language"
    echo ""

    # Show contextual suggestions based on system state
    echo "=== CONTEXTUAL SUGGESTIONS ==="
    echo ""

    case "$command" in
        "install-wizard"|"install")
            if [[ "$context" == *"citadel:installed"* ]]; then
                echo "⚠️  Citadel appears to be already installed."
                echo "   Consider using 'modify installation' instead."
                echo "   Or run reinstall: citadel install wizard --reinstall"
            else
                echo "✅ System ready for Citadel installation."
                echo "   Recommended: citadel install wizard"
            fi
            ;;

        "configure-system")
            if [[ "$context" == *"dns:citadel"* ]]; then
                echo "ℹ️  System is already using Citadel DNS."
                echo "   To switch back: citadel restore-system"
            elif [[ "$context" == *"dns:systemd"* ]]; then
                echo "✅ Ready to switch to Citadel DNS."
                echo "   This will configure systemd-resolved to use Citadel."
            fi
            ;;

        "firewall-strict")
            echo "⚠️  STRICT mode provides maximum DNS leak protection."
            echo "   May break some applications that bypass local DNS."
            echo "   Start with: citadel firewall-safe"
            echo "   Upgrade to strict only when safe mode works."
            ;;

        "diagnostics")
            echo "💡 Pro tip: Run diagnostics after any configuration change."
            echo "   Also useful for troubleshooting connectivity issues."
            ;;

        "emergency-restore")
            echo "🚨 EMERGENCY USE ONLY!"
            echo "   This temporarily disables Citadel protection."
            echo "   Remember to run 'citadel configure-system' afterward."
            ;;
    esac

    echo ""
    echo "=== RELATED COMMANDS ==="
    echo ""

    # Show related commands
    case "$command" in
        "install"*)
            echo "• citadel status          - Check installation status"
            echo "• citadel verify          - Verify installation"
            echo "• citadel diagnostics     - Run system diagnostics"
            ;;

        "configure-system")
            echo "• citadel status          - Check DNS configuration"
            echo "• citadel firewall-safe   - Configure firewall"
            echo "• citadel restore-system  - Switch back to original DNS"
            ;;

        "status"|"diagnostics")
            echo "• citadel verify          - Deep verification"
            echo "• citadel test-all        - Comprehensive testing"
            echo "• citadel logs            - View detailed logs"
            ;;

        "firewall"*)
            echo "• citadel status          - Check firewall status"
            echo "• citadel verify          - Test firewall rules"
            echo "• citadel nft-debug-on    - Enable firewall debugging"
            ;;
    esac
}

# Show workflow-based help
contextual_workflow_help() {
    local workflow="$1"
    local context="${2:-$(get_system_context)}"
    local language="${3:-$(detect_help_language)}"

    echo "=== WORKFLOW GUIDANCE: $(echo "$workflow" | tr '[:lower:]' '[:upper:]' | sed 's/_/ /g') ==="
    echo ""

    # Show workflow steps
    get_workflow_steps "$workflow" "$language"

    echo ""
    echo "=== SYSTEM CONTEXT ==="
    echo "Current state: $context"
    echo ""

    # Show contextual tips based on system state
    case "$workflow" in
        "first_install")
            if [[ "$context" == *"citadel:installed"* ]]; then
                echo "⚠️  Citadel appears to already be installed."
                echo "   This workflow is for first-time installation."
                echo "   Try: citadel help --context reinstall"
            fi
            ;;

        "dns_troubleshooting")
            if [[ "$context" == *"dns:citadel"* ]]; then
                echo "ℹ️  System is using Citadel DNS."
                echo "   DNS issues may be Citadel-related."
                echo "   Try: citadel emergency-restore"
            fi
            ;;
    esac
}

# ============================================================================
# MAIN CONTEXTUAL HELP ENTRY POINT
# ============================================================================

# Main contextual help function
help_context_main() {
    local context_type="${1:-}"
    local target="${2:-}"
    local language="${HELP_LANGUAGE:-$(detect_help_language)}"

    case "$context_type" in
        "command"|"cmd")
            if [[ -n "$target" ]]; then
                contextual_command_help "$target" "" "$language"
            else
                echo "ERROR: Command name required for contextual help"
                echo "Usage: citadel help --context command <command_name>"
                return 1
            fi
            ;;

        "workflow"|"flow")
            if [[ -n "$target" ]]; then
                contextual_workflow_help "$target" "" "$language"
            else
                echo "Available workflows:"
                echo "• first_install     - Complete first-time setup"
                echo "• dns_troubleshooting - DNS connectivity issues"
                echo "• security_hardening - Enhance security settings"
                echo "• performance_optimization - Improve performance"
                echo "• emergency_recovery - System recovery procedures"
                echo ""
                echo "Usage: citadel help --context workflow <workflow_name>"
            fi
            ;;

        "auto"|"smart")
            # Try to provide intelligent contextual help
            local system_context
            system_context="$(get_system_context)"

            echo "=== SMART CONTEXTUAL HELP ==="
            echo "System context: $system_context"
            echo ""

            if [[ "$system_context" == *"citadel:not_installed"* ]]; then
                echo "💡 Citadel is not installed. Recommended actions:"
                echo "   • citadel help --context workflow first_install"
                echo "   • citadel install wizard"
            elif [[ "$system_context" == *"dns:systemd"* ]]; then
                echo "💡 System is using default DNS. Recommended actions:"
                echo "   • citadel configure-system (switch to Citadel)"
                echo "   • citadel help --context command configure-system"
            elif [[ "$system_context" == *"dns:citadel"* ]]; then
                echo "💡 System is using Citadel DNS. Current status:"
                echo "   • citadel status (check system health)"
                echo "   • citadel diagnostics (detailed diagnostics)"
            fi
            ;;

        *)
            echo "Citadel Contextual Help System"
            echo "==============================="
            echo ""
            echo "MODES:"
            echo "  command <cmd>     - Contextual help for specific command"
            echo "  workflow <name>   - Step-by-step workflow guidance"
            echo "  auto              - Intelligent contextual suggestions"
            echo ""
            echo "EXAMPLES:"
            echo "  citadel help --context command install-wizard"
            echo "  citadel help --context workflow dns_troubleshooting"
            echo "  citadel help --context auto"
            ;;
    esac
}
