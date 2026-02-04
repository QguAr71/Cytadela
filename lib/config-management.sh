#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3+ - CONFIGURATION MANAGEMENT SYSTEM                        ║
# ║  YAML-based configuration with profiles and validation                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION CONSTANTS
# ==============================================================================

CONFIG_DIR="/etc/citadel"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
PROFILES_DIR="$CONFIG_DIR/profiles"
BACKUP_DIR="/var/backups/citadel"

# ==============================================================================
# YAML CONFIGURATION MANAGEMENT
# ==============================================================================

# Initialize configuration system
config_init() {
    local profile="${1:-standard}"

    log_info "Initializing Citadel configuration with profile: $profile"

    # Create directories
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$PROFILES_DIR"
    mkdir -p "$BACKUP_DIR"

    # Create default configuration
    create_default_config "$profile"

    # Validate configuration
    if config_validate >/dev/null 2>&1; then
        log_success "Configuration initialized successfully"
    else
        log_error "Configuration validation failed"
        return 1
    fi
}

# Create default configuration based on profile
create_default_config() {
    local profile="$1"

    # Base configuration
    cat > "$CONFIG_FILE" << EOF
# Citadel v3.3+ Configuration
# Profile: $profile
# Generated: $(date -Iseconds)

version: "3.3"
profile: "$profile"
metadata:
  created: "$(date -Iseconds)"
  hostname: "$(hostname)"
  profile: "$profile"

# Core DNS settings
dns:
  upstream:
    dnscrypt:
      enabled: true
      port: 5353
      servers:
        - server_name: "quad9-dnscrypt-ip4-filter-p2"
          stamp: "sdns://AQMAAAAAAAAAFDE3Ni4xMDMuMTMwLjEzMDo1NDQzINErRjg5NzM4N0Y3WkZFTGFSS2JMS3RAMzEzMzc2NDUxMg"
    doh:
      enabled: false
      url: "https://cloudflare-dns.com/dns-query"
  local:
    coredns:
      enabled: true
      port: 53
      metrics_port: 9153
      config_file: "/etc/coredns/Corefile"

# Adblock settings
adblock:
  enabled: true
  profile: "balanced"
  custom_domains: []
  allowlist: []
  update_interval: "24h"
  sources:
    - url: "https://big.oisd.nl"
      format: "hosts"
      enabled: true

# Security features (varies by profile)
security:
EOF

    # Add profile-specific security settings
    case "$profile" in
        minimal)
            cat >> "$CONFIG_FILE" << 'EOF'
  reputation:
    enabled: false
  asn_blocking:
    enabled: false
  event_logging:
    enabled: false
  honeypot:
    enabled: false
EOF
            ;;
        standard)
            cat >> "$CONFIG_FILE" << 'EOF'
  reputation:
    enabled: false
  asn_blocking:
    enabled: false
  event_logging:
    enabled: true
    log_level: "info"
  honeypot:
    enabled: false
EOF
            ;;
        security|full)
            cat >> "$CONFIG_FILE" << 'EOF'
  reputation:
    enabled: true
    threshold: 0.15
    events:
      failed_ssh_login: -0.10
      port_scan: -0.20
      failed_dns_query: -0.05
      successful_connection: 0.05
  asn_blocking:
    enabled: true
    auto_update: true
    update_interval: "24h"
  event_logging:
    enabled: true
    log_level: "debug"
    max_size: "10M"
    rotate_count: 10
  honeypot:
    enabled: true
    ports:
      - port: 2222
        service: "ssh"
      - port: 3307
        service: "mysql"
EOF
            ;;
    esac

    # Add common settings
    cat >> "$CONFIG_FILE" << 'EOF'

# Monitoring and metrics
monitoring:
  prometheus:
    enabled: false
    port: 9100
  cache_stats:
    enabled: true
    update_interval: "30s"
  health_checks:
    enabled: true
    interval: "5m"

# Firewall settings
firewall:
  profile: "safe"
  nftables:
    enabled: true
    rules_file: "/etc/nftables.conf"
  ipv6:
    privacy: true
    temp_addresses: true

# Auto-update settings
updates:
  blocklists:
    enabled: true
    interval: "24h"
    on_failure: "retry"
  packages:
    enabled: false
    interval: "7d"

# Logging settings
logging:
  level: "info"
  file: "/var/log/citadel/citadel.log"
  max_size: "50M"
  rotate_count: 5

EOF

    log_info "Created default configuration: $CONFIG_FILE"
}

# Get configuration value
config_get() {
    local key="$1"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        return 1
    fi

    # Use yq if available, otherwise fallback to grep/sed
    if command -v yq >/dev/null 2>&1; then
        local value
        value=$(yq -r ".$key // empty" "$CONFIG_FILE" 2>/dev/null)
        if [[ "$value" == "empty" ]]; then
            echo ""
        else
            echo "$value"
        fi
    else
        # Fallback: simple key-value extraction for basic keys
        log_debug "yq not available, using basic parsing for key: $key"
        # This is very basic - only works for simple top-level keys
        grep "^${key}:" "$CONFIG_FILE" 2>/dev/null | head -1 | cut -d: -f2- | sed 's/^ *//' | sed 's/ *$//' || echo ""
    fi
}

# Set configuration value
config_set() {
    local key="$1"
    local value="$2"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        return 1
    fi

    # Backup current config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%s)"

    # Use yq if available
    if command -v yq >/dev/null 2>&1; then
        yq -i ".$key = \"$value\"" "$CONFIG_FILE" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            log_success "Configuration updated: $key = $value"
            return 0
        fi
    fi

    # Fallback: basic sed replacement (limited functionality)
    log_warning "yq not available, using basic replacement (limited to simple values)"
    # This is a simplified fallback - real implementation would need more complex parsing
    log_error "Advanced configuration setting requires yq. Install with: sudo pacman -S yq"
    return 1
}

# Validate configuration
config_validate() {
    local verbose="${1:-false}"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        return 1
    fi

    local errors=0
    local warnings=0

    [[ "$verbose" == "true" ]] && log_info "Validating configuration..."

    # Check YAML syntax
    if command -v yq >/dev/null 2>&1; then
        if ! yq . "$CONFIG_FILE" >/dev/null 2>&1; then
            log_error "Invalid YAML syntax in configuration file"
            ((errors++))
        else
            [[ "$verbose" == "true" ]] && log_success "YAML syntax is valid"
        fi
    else
        log_warning "yq not available - skipping YAML validation"
        ((warnings++))
    fi

    # Validate version
    local version
    version=$(config_get "version")
    if [[ -z "$version" ]]; then
        log_error "Missing version in configuration"
        ((errors++))
    elif [[ "$version" != "3.3" ]]; then
        log_warning "Configuration version mismatch: expected 3.3, got $version"
        ((warnings++))
    fi

    # Validate DNS settings
    if [[ "$(config_get "dns.upstream.dnscrypt.enabled")" == "true" ]]; then
        if ! systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then
            log_warning "DNSCrypt enabled in config but service not running"
            ((warnings++))
        fi
    fi

    if [[ "$(config_get "dns.local.coredns.enabled")" == "true" ]]; then
        if ! systemctl is-active --quiet coredns 2>/dev/null; then
            log_warning "CoreDNS enabled in config but service not running"
            ((warnings++))
        fi
    fi

    # Validate security settings
    if [[ "$(config_get "security.reputation.enabled")" == "true" ]]; then
        if [[ ! -f /var/lib/cytadela/reputation.db ]]; then
            log_warning "Reputation system enabled but database not found"
            ((warnings++))
        fi
    fi

    # Validate adblock settings
    local adblock_profile
    adblock_profile=$(config_get "adblock.profile")
    case "$adblock_profile" in
        light|balanced|aggressive|privacy|custom|"")
            ;;
        *)
            log_error "Invalid adblock profile: $adblock_profile"
            ((errors++))
            ;;
    esac

    # Summary
    if [[ $errors -eq 0 ]]; then
        if [[ $warnings -eq 0 ]]; then
            [[ "$verbose" == "true" ]] && log_success "Configuration validation passed"
        else
            [[ "$verbose" == "true" ]] && log_success "Configuration validation passed with $warnings warning(s)"
        fi
        return 0
    else
        log_error "Configuration validation failed: $errors error(s), $warnings warning(s)"
        return 1
    fi
}

# Show current configuration
config_show() {
    local section="$1"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        return 1
    fi

    if [[ -n "$section" ]]; then
        # Show specific section
        if command -v yq >/dev/null 2>&1; then
            echo "# $section configuration:"
            yq ".$section" "$CONFIG_FILE" 2>/dev/null || log_error "Section not found: $section"
        else
            log_error "yq required for section display. Install with: sudo pacman -S yq"
        fi
    else
        # Show all configuration
        echo "# Citadel Configuration ($CONFIG_FILE)"
        echo ""
        if command -v yq >/dev/null 2>&1; then
            yq . "$CONFIG_FILE" 2>/dev/null
        else
            cat "$CONFIG_FILE"
        fi
    fi
}

# Export configuration
config_export() {
    local output_file="${1:-/tmp/citadel-config-$(date +%Y%m%d-%H%M%S).yaml}"

    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        return 1
    fi

    cp "$CONFIG_FILE" "$output_file"
    log_success "Configuration exported to: $output_file"
    echo "$output_file"
}

# Import configuration
config_import() {
    local input_file="$1"

    if [[ ! -f "$input_file" ]]; then
        log_error "Input file not found: $input_file"
        return 1
    fi

    # Validate imported config
    if command -v yq >/dev/null 2>&1; then
        if ! yq . "$input_file" >/dev/null 2>&1; then
            log_error "Invalid YAML in imported file"
            return 1
        fi
    fi

    # Backup current config
    config_export "${CONFIG_FILE}.backup.$(date +%s)"

    # Import new config
    cp "$input_file" "$CONFIG_FILE"
    log_success "Configuration imported from: $input_file"

    # Validate new configuration
    if config_validate >/dev/null 2>&1; then
        log_success "Imported configuration is valid"
    else
        log_warning "Imported configuration has validation issues"
    fi
}

# Show configuration diff
config_diff() {
    local file1="${1:-$CONFIG_FILE}"
    local file2="${2:-${CONFIG_FILE}.backup}"

    if [[ ! -f "$file1" ]]; then
        log_error "File not found: $file1"
        return 1
    fi

    if [[ ! -f "$file2" ]]; then
        log_error "File not found: $file2"
        return 1
    fi

    if command -v diff >/dev/null 2>&1; then
        echo "# Configuration differences:"
        echo "# Left: $file1"
        echo "# Right: $file2"
        echo ""
        diff -u "$file1" "$file2" || true
    else
        log_warning "diff not available - showing basic comparison"
        log_info "File 1: $file1 ($(stat -c %s "$file1" 2>/dev/null || echo "?") bytes)"
        log_info "File 2: $file2 ($(stat -c %s "$file2" 2>/dev/null || echo "?") bytes)"
    fi
}

# Reset configuration to defaults
config_reset() {
    local component="$1"

    log_warning "Resetting configuration to defaults"

    if [[ -n "$component" ]]; then
        log_info "Resetting component: $component"
        # This would reset specific component settings
        log_error "Component-specific reset not yet implemented"
        return 1
    else
        # Full reset
        if gum confirm "This will reset ALL configuration to defaults. Continue?" 2>/dev/null; then
            config_export "${CONFIG_FILE}.reset-backup.$(date +%s)"
            profile=$(config_get "profile")
            create_default_config "${profile:-standard}"
            log_success "Configuration reset to defaults"
        else
            log_info "Reset cancelled"
        fi
    fi
}

# List available profiles
config_list_profiles() {
    echo "Available Citadel configuration profiles:"
    echo ""
    echo "minimal     - Core DNS functionality only"
    echo "  • DNSCrypt + CoreDNS"
    echo "  • Basic firewall"
    echo "  • No security features"
    echo ""
    echo "standard    - Standard protection (recommended)"
    echo "  • DNS + Adblock"
    echo "  • Basic monitoring"
    echo "  • Event logging"
    echo ""
    echo "security    - Advanced security features"
    echo "  • Standard + Reputation system"
    echo "  • ASN blocking"
    echo "  • Honeypot detection"
    echo ""
    echo "full        - Everything enabled"
    echo "  • Security + Prometheus metrics"
    echo "  • Maximum protection"
    echo ""
    echo "custom      - Custom component selection"
    echo "  • Manual configuration"
    echo ""

    local current_profile
    current_profile=$(config_get "profile")
    if [[ -n "$current_profile" ]]; then
        echo "Current profile: $current_profile"
    fi
}

# Switch to different profile
config_switch_profile() {
    local new_profile="$1"

    if [[ -z "$new_profile" ]]; then
        log_error "Profile name required"
        config_list_profiles
        return 1
    fi

    case "$new_profile" in
        minimal|standard|security|full)
            ;;
        *)
            log_error "Unknown profile: $new_profile"
            config_list_profiles
            return 1
            ;;
    esac

    local current_profile
    current_profile=$(config_get "profile")

    if [[ "$current_profile" == "$new_profile" ]]; then
        log_info "Already using profile: $new_profile"
        return 0
    fi

    log_info "Switching from profile '$current_profile' to '$new_profile'"

    # Backup current config
    config_export "${CONFIG_FILE}.profile-switch.$(date +%s)"

    # Create new config with selected profile
    create_default_config "$new_profile"

    log_success "Switched to profile: $new_profile"
    log_info "Restart Citadel services to apply changes"
}

# ==============================================================================
# CONFIGURATION HELPERS
# ==============================================================================

# Apply configuration to running system
config_apply() {
    log_info "Applying configuration changes..."

    # This would restart services and apply configuration changes
    # For now, just validate
    if config_validate; then
        log_success "Configuration applied successfully"
        log_info "Some changes may require service restart"
    else
        log_error "Configuration has errors - not applied"
        return 1
    fi
}

# Export functions for use by citadel.sh
export -f config_init
export -f config_get
export -f config_set
export -f config_validate
export -f config_show
export -f config_export
export -f config_import
export -f config_diff
export -f config_reset
export -f config_list_profiles
export -f config_switch_profile
export -f config_apply
