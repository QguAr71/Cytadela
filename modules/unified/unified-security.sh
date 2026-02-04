#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-SECURITY MODULE v3.2                               ║
# ║  Unified security functions: integrity, location, supply-chain        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

# Integrity verification settings
CYTADELA_MANIFEST="${CYTADELA_STATE_DIR}/integrity/manifest.sha256"
CYTADELA_LKG_DIR="${CYTADELA_STATE_DIR}/integrity/lkg"
CYTADELA_OPT_BIN="/opt/cytadela/bin"

# Load reputation system
if [[ -f "lib/reputation.sh" ]]; then
    source "lib/reputation.sh"
else
    log_warning "Reputation system library not found"
fi

# Initialize reputation system if enabled
if [[ "${CYTADELA_SECURITY_REPUTATION:-true}" == "true" ]]; then
    reputation_init
fi

# Load ASN blocking system
if [[ -f "lib/asn-blocking.sh" ]]; then
    source "lib/asn-blocking.sh"
else
    log_warning "ASN blocking system library not found"
fi

# Initialize ASN blocking if enabled
if [[ "${CYTADELA_SECURITY_ASN_BLOCKING:-true}" == "true" ]]; then
    asn_init
fi

# Load event logging system
if [[ -f "lib/event-logger.sh" ]]; then
    source "lib/event-logger.sh"
else
    log_warning "Event logging system library not found"
fi

# Initialize event logging if enabled
if [[ "${CYTADELA_SECURITY_EVENT_LOGGING:-true}" == "true" ]]; then
    event_log_init
fi

# Load honeypot system
if [[ -f "lib/honeypot.sh" ]]; then
    source "lib/honeypot.sh"
else
    log_warning "Honeypot system library not found"
fi

# Initialize honeypot system if enabled
if [[ "${CYTADELA_SECURITY_HONEYPOT:-false}" == "true" ]]; then
    honeypot_init
fi

# Location-based security settings
LOCATION_TRUSTED_FILE="${CYTADELA_STATE_DIR}/location/trusted-ssids.txt"

# Supply chain verification settings
SUPPLY_CHAIN_MANIFEST="${CYTADELA_STATE_DIR}/supply-chain/manifest.json"

# ==============================================================================
# INTEGRITY VERIFICATION FUNCTIONS (migrated from integrity.sh)
# ==============================================================================

# Verify file integrity
integrity_verify_file() {
    local file="$1"
    local expected_hash="$2"

    # File missing
    [[ ! -f "$file" ]] && return 2

    # Calculate hash
    local actual_hash
    actual_hash=$(sha256sum "$file" | awk '{print $1}')

    # Compare
    [[ "$actual_hash" == "$expected_hash" ]] && return 0 || return 1
}

# Check integrity of all files
integrity_check() {
    local silent="${1:-}"
    local has_errors=0
    local has_warnings=0

    # Developer mode: bypass checks
    if [[ "$CYTADELA_MODE" == "developer" ]]; then
        [[ -z "$silent" ]] && log_info "[DEV MODE] Integrity checks bypassed"
        return 0
    fi

    # No manifest: skip (bootstrap)
    if [[ ! -f "$CYTADELA_MANIFEST" ]]; then
        log_warning "Integrity not initialized. Run: sudo $0 integrity-init"
        return 0
    fi

    [[ -z "$silent" ]] && log_info "Verifying integrity from $CYTADELA_MANIFEST ..."

    # Read manifest and verify each file
    while IFS='  ' read -r hash filepath; do
        # Skip comments and empty lines
        [[ -z "$hash" || "$hash" == "#"* ]] && continue

        # Determine file type for policy
        local is_binary=0
        [[ "$filepath" == "$CYTADELA_OPT_BIN"/* ]] && is_binary=1

        # Check if file exists
        if [[ ! -f "$filepath" ]]; then
            log_warning "Missing: $filepath"
            has_warnings=1
            continue
        fi

        # Verify integrity
        if ! integrity_verify_file "$filepath" "$hash"; then
            if [[ $is_binary -eq 1 ]]; then
                # Binary: hard fail
                log_error "INTEGRITY FAIL (binary): $filepath"
                has_errors=1
            else
                # Module/script: warn and prompt
                log_warning "INTEGRITY MISMATCH (module): $filepath"
                has_warnings=1

                # Non-interactive mode: fail
                if [[ ! -t 0 && ! -t 1 ]]; then
                    log_error "Non-interactive mode: aborting due to integrity mismatch"
                    has_errors=1
                else
                    # Interactive: prompt user
                    echo -n "Continue despite mismatch? [y/N]: "
                    read -r answer
                    [[ ! "$answer" =~ ^[Yy]$ ]] && has_errors=1
                fi
            fi
        else
            [[ -z "$silent" ]] && log_success "OK: $filepath"
        fi
    done <"$CYTADELA_MANIFEST"

    # Final verdict
    if [[ $has_errors -eq 1 ]]; then
        log_error "Integrity check FAILED. Aborting."
        exit 1
    fi

    if [[ $has_warnings -gt 0 ]]; then
        [[ -z "$silent" ]] && log_warning "Integrity check passed with $has_warnings warning(s)"
    else
        [[ -z "$silent" ]] && log_success "Integrity check passed"
    fi

    return 0
}

# Initialize integrity manifest
integrity_init() {
    log_section "󰯄 INTEGRITY INIT"

    # Create directories
    mkdir -p "$(dirname "$CYTADELA_MANIFEST")"
    mkdir -p "$CYTADELA_LKG_DIR"
    mkdir -p "$CYTADELA_OPT_BIN"

    # Create temporary manifest
    local manifest_tmp
    manifest_tmp=$(mktemp)

    echo "# Cytadela integrity manifest - generated $(date -Iseconds)" >"$manifest_tmp"
    echo "# Format: sha256  filepath" >>"$manifest_tmp"

    # Add main scripts
    local script_dir
    script_dir=$(dirname "$CYTADELA_SCRIPT_PATH")

    # Add current script
    if [[ -f "$CYTADELA_SCRIPT_PATH" ]]; then
        sha256sum "$CYTADELA_SCRIPT_PATH" >>"$manifest_tmp"
        log_info "Added: $CYTADELA_SCRIPT_PATH"
    fi

    # Add any other .sh scripts in script directory (auto-discover)
    for script in "${script_dir}"/*.sh; do
        if [[ -f "$script" && "$script" != "$CYTADELA_SCRIPT_PATH" ]]; then
            sha256sum "$script" >>"$manifest_tmp"
            log_info "Added: $script"
        fi
    done

    # Add lib files (if in /opt/cytadela/lib)
    if [[ -d "/opt/cytadela/lib" ]]; then
        for lib in /opt/cytadela/lib/*.sh; do
            if [[ -f "$lib" ]]; then
                sha256sum "$lib" >>"$manifest_tmp"
                log_info "Added: $lib"
            fi
        done
    fi

    # Add modules (if in /opt/cytadela/modules)
    if [[ -d "/opt/cytadela/modules" ]]; then
        for mod in /opt/cytadela/modules/*.sh; do
            if [[ -f "$mod" ]]; then
                sha256sum "$mod" >>"$manifest_tmp"
                log_info "Added: $mod"
            fi
        done
    fi

    # Add binaries from /opt/cytadela/bin
    if [[ -d "$CYTADELA_OPT_BIN" ]]; then
        for bin in "$CYTADELA_OPT_BIN"/*; do
            if [[ -f "$bin" && -x "$bin" ]]; then
                sha256sum "$bin" >>"$manifest_tmp"
                log_info "Added: $bin"
            fi
        done
    fi

    # Move to final location
    mv "$manifest_tmp" "$CYTADELA_MANIFEST"
    chmod 644 "$CYTADELA_MANIFEST"

    log_success "Manifest created: $CYTADELA_MANIFEST"
    log_info "To verify: sudo $0 integrity-check"
}

# Show integrity status
integrity_status() {
    log_section "󰯄 INTEGRITY STATUS"

    echo "Mode: $CYTADELA_MODE"
    echo "Manifest: $CYTADELA_MANIFEST"

    if [[ -f "$CYTADELA_MANIFEST" ]]; then
        echo "Manifest exists: YES"
        local entries
        entries=$(grep -c -v '^#' "$CYTADELA_MANIFEST" 2>/dev/null || echo 0)
        echo "Entries: $entries"
        echo "Last modified: $(stat -c %y "$CYTADELA_MANIFEST" 2>/dev/null | cut -d. -f1)"
    else
        echo "Manifest exists: NO (run integrity-init to create)"
    fi

    echo ""
    echo "LKG directory: $CYTADELA_LKG_DIR"
    if [[ -d "$CYTADELA_LKG_DIR" ]]; then
        local lkg_files
        lkg_files=$(find "$CYTADELA_LKG_DIR" -type f 2>/dev/null | wc -l)
        echo "LKG files: $lkg_files"
    else
        echo "LKG directory: NOT CREATED"
    fi

    echo ""
    echo "Binaries directory: $CYTADELA_OPT_BIN"
    if [[ -d "$CYTADELA_OPT_BIN" ]]; then
        local bin_count
        bin_count=$(find "$CYTADELA_OPT_BIN" -type f -executable 2>/dev/null | wc -l)
        echo "Binaries: $bin_count"
    else
        echo "Binaries directory: NOT CREATED"
    fi
}

# ==============================================================================
# LOCATION-BASED SECURITY FUNCTIONS (migrated from location.sh)
# ==============================================================================

# Check current location security status
location_check() {
    log_section "󰍜 LOCATION SECURITY CHECK"

    # Get current SSID
    local current_ssid=""
    if command -v nmcli &>/dev/null; then
        current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2- | head -1)
    elif command -v iwconfig &>/dev/null; then
        current_ssid=$(iwconfig 2>/dev/null | grep 'ESSID:' | head -1 | sed 's/.*ESSID:"//' | sed 's/".*//')
    fi

    if [[ -z "$current_ssid" ]]; then
        log_warning "Could not detect current WiFi network"
        return 1
    fi

    log_info "Current network: $current_ssid"

    # Check if trusted
    if location_is_trusted "$current_ssid"; then
        log_success "✓ Network '$current_ssid' is trusted"
        return 0
    else
        log_warning "⚠ Network '$current_ssid' is not trusted"
        log_info "Consider adding it with: location-add-trusted '$current_ssid'"
        return 1
    fi
}

# Add trusted SSID
location_add_trusted() {
    local ssid="$1"

    if [[ -z "$ssid" ]]; then
        log_error "Usage: location-add-trusted <SSID>"
        return 1
    fi

    mkdir -p "$(dirname "$LOCATION_TRUSTED_FILE")"

    if grep -q "^${ssid}$" "$LOCATION_TRUSTED_FILE" 2>/dev/null; then
        log_warning "SSID '$ssid' is already trusted"
        return 1
    fi

    echo "$ssid" >> "$LOCATION_TRUSTED_FILE"
    log_success "Added trusted network: $ssid"
}

# Remove trusted SSID
location_remove_trusted() {
    local ssid="$1"

    if [[ -z "$ssid" ]]; then
        log_error "Usage: location-remove-trusted <SSID>"
        return 1
    fi

    if [[ ! -f "$LOCATION_TRUSTED_FILE" ]]; then
        log_error "No trusted networks file found"
        return 1
    fi

    if ! grep -q "^${ssid}$" "$LOCATION_TRUSTED_FILE"; then
        log_warning "SSID '$ssid' is not in trusted list"
        return 1
    fi

    sed -i "/^${ssid}$/d" "$LOCATION_TRUSTED_FILE"
    log_success "Removed trusted network: $ssid"
}

# List trusted SSIDs
location_list_trusted() {
    log_section "󰍜 TRUSTED NETWORKS"

    if [[ ! -f "$LOCATION_TRUSTED_FILE" ]]; then
        log_info "No trusted networks configured"
        return 0
    fi

    echo "Trusted WiFi networks:"
    while IFS= read -r ssid; do
        [[ -z "$ssid" ]] && continue
        echo "  • $ssid"
    done < "$LOCATION_TRUSTED_FILE"
}

# Show location status
location_status() {
    log_section "󰍜 LOCATION STATUS"

    # Current network
    local current_ssid=""
    if command -v nmcli &>/dev/null; then
        current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2- | head -1)
    elif command -v iwconfig &>/dev/null; then
        current_ssid=$(iwconfig 2>/dev/null | grep 'ESSID:' | head -1 | sed 's/.*ESSID:"//' | sed 's/".*//')
    fi

    echo "Current network: ${current_ssid:-Not detected}"

    # Trusted networks count
    if [[ -f "$LOCATION_TRUSTED_FILE" ]]; then
        local trusted_count
        trusted_count=$(grep -c '^[^#]' "$LOCATION_TRUSTED_FILE" 2>/dev/null || echo 0)
        echo "Trusted networks: $trusted_count"
    else
        echo "Trusted networks: 0 (none configured)"
    fi

    # Security status
    if [[ -n "$current_ssid" ]] && location_is_trusted "$current_ssid"; then
        echo "Security status: ✓ TRUSTED NETWORK"
    else
        echo "Security status: ⚠ UNTRUSTED NETWORK"
    fi
}

# Check if SSID is trusted (helper)
location_is_trusted() {
    local ssid="$1"
    [[ -f "$LOCATION_TRUSTED_FILE" ]] && grep -q "^${ssid}$" "$LOCATION_TRUSTED_FILE"
}

# ==============================================================================
# SUPPLY CHAIN VERIFICATION FUNCTIONS (migrated from supply-chain.sh)
# ==============================================================================

# Initialize supply chain verification
supply_chain_init() {
    log_section "󰷚 SUPPLY CHAIN INIT"

    mkdir -p "$(dirname "$SUPPLY_CHAIN_MANIFEST")"

    # Create basic manifest
    cat > "$SUPPLY_CHAIN_MANIFEST" << 'EOF'
{
  "version": "1.0",
  "description": "Cytadela supply chain verification manifest",
  "sources": {
    "dnscrypt-resolvers": {
      "url": "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md",
      "key": "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3",
      "type": "minisign"
    },
    "oisd-blocklist": {
      "url": "https://big.oisd.nl",
      "type": "https"
    },
    "kadhosts": {
      "url": "https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt",
      "type": "https"
    }
  },
  "binaries": {
    "coredns": {
      "source": "https://github.com/coredns/coredns/releases",
      "verification": "sha256"
    },
    "dnscrypt-proxy": {
      "source": "https://github.com/DNSCrypt/dnscrypt-proxy/releases",
      "verification": "sha256"
    }
  }
}
EOF

    log_success "Supply chain manifest created: $SUPPLY_CHAIN_MANIFEST"
}

# Verify supply chain for sources
supply_chain_verify() {
    log_section "󰷚 SUPPLY CHAIN VERIFY"

    if [[ ! -f "$SUPPLY_CHAIN_MANIFEST" ]]; then
        log_error "Supply chain manifest not found. Run supply-chain-init first."
        return 1
    fi

    log_info "Verifying supply chain integrity..."

    # For now, just check if manifest exists and is valid JSON
    if command -v jq &>/dev/null && jq . "$SUPPLY_CHAIN_MANIFEST" >/dev/null 2>&1; then
        log_success "Supply chain manifest is valid"
    else
        log_error "Supply chain manifest is invalid or corrupted"
        return 1
    fi

    log_info "Supply chain verification completed"
}

# Show supply chain status
supply_chain_status() {
    log_section "󰷚 SUPPLY CHAIN STATUS"

    if [[ -f "$SUPPLY_CHAIN_MANIFEST" ]]; then
        echo "Manifest: EXISTS"
        echo "Location: $SUPPLY_CHAIN_MANIFEST"

        if command -v jq &>/dev/null; then
            local sources_count
            sources_count=$(jq '.sources | length' "$SUPPLY_CHAIN_MANIFEST" 2>/dev/null || echo "?")
            local binaries_count
            binaries_count=$(jq '.binaries | length' "$SUPPLY_CHAIN_MANIFEST" 2>/dev/null || echo "?")

            echo "Configured sources: $sources_count"
            echo "Configured binaries: $binaries_count"
        else
            echo "jq not available for detailed analysis"
        fi
    else
        echo "Manifest: NOT FOUND (run supply-chain-init)"
    fi
}

# ==============================================================================
# GHOST CHECK FUNCTIONS (migrated from ghost-check.sh)
# ==============================================================================

# Perform security audit for open ports and services
ghost_check() {
    log_section "👻 GHOST CHECK - Security Audit"

    log_info "Checking for open ports and potential security issues..."

    # Check if netstat or ss is available
    local net_tool=""
    if command -v ss &>/dev/null; then
        net_tool="ss"
    elif command -v netstat &>/dev/null; then
        net_tool="netstat"
    else
        log_warning "Neither 'ss' nor 'netstat' found - cannot check open ports"
        return 1
    fi

    # Get listening ports
    local listening_ports
    if [[ "$net_tool" == "ss" ]]; then
        listening_ports=$(ss -tuln | grep LISTEN | awk '{print $5}' | cut -d: -f2 | sort -u)
    else
        listening_ports=$(netstat -tuln | grep LISTEN | awk '{print $4}' | cut -d: -f2 | sort -u)
    fi

    echo "Open listening ports:"
    for port in $listening_ports; do
        # Skip common safe ports
        case "$port" in
            22|53|80|443|5353) continue ;; # SSH, DNS, HTTP, HTTPS, DNSCrypt
        esac

        local service="unknown"
        if [[ -f /etc/services ]]; then
            service=$(grep "^${port}/tcp" /etc/services | head -1 | awk '{print $1}' || echo "unknown")
        fi

        echo "  ⚠ Port $port ($service) - investigate if unexpected"
    done

    # Check for suspicious processes
    log_info "Checking for suspicious processes..."
    local suspicious_procs=$(ps aux | grep -E "(nc|netcat|nmap|masscan|nikto|dirb|gobuster)" | grep -v grep || true)

    if [[ -n "$suspicious_procs" ]]; then
        log_warning "Potential security scanning tools detected:"
        echo "$suspicious_procs" | while read -r line; do
            echo "  ⚠ $line"
        done
    else
        log_success "No suspicious scanning tools detected"
    fi

    log_success "Ghost check completed"
}

# ==============================================================================
# NFT DEBUG FUNCTIONS (migrated from nft-debug.sh)
# ==============================================================================

# Enable NFTables debug chain
nft_debug_on() {
    log_section "󰳌 NFT DEBUG ON"

    # Add debug chain
    nft add table inet cytadel_debug 2>/dev/null || true
    nft add chain inet cytadel_debug debug_chain { type filter hook input priority -500 \; } 2>/dev/null || true

    # Add debug rules
    nft add rule inet cytadel_debug debug_chain tcp dport != {22,53,80,443} limit rate 5/minute log prefix "NFT-DEBUG: " 2>/dev/null || true

    log_success "NFT debug chain enabled"
}

# Disable NFTables debug chain
nft_debug_off() {
    log_section "󰳍 NFT DEBUG OFF"

    nft delete table inet cytadel_debug 2>/dev/null || true
    log_success "NFT debug chain disabled"
}

# Show NFTables debug status
nft_debug_status() {
    log_section "󰳎 NFT DEBUG STATUS"

    if nft list table inet cytadel_debug >/dev/null 2>&1; then
        echo "Debug chain: ENABLED"
        nft list table inet cytadel_debug
    else
        echo "Debug chain: DISABLED"
    fi
}

# Show NFTables debug logs
nft_debug_logs() {
    log_section "󰳏 NFT DEBUG LOGS"

    if command -v journalctl &>/dev/null; then
        journalctl -k --grep="NFT-DEBUG" --since="1 hour ago" | tail -20
    else
        log_warning "journalctl not available for log viewing"
        dmesg | grep "NFT-DEBUG" | tail -10 || log_info "No NFT debug logs found in dmesg"
    fi
}
