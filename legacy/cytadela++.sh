#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL++ v3.0 - FORTIFIED DNS INFRASTRUCTURE                           ║
# ║  Advanced Hardened Resolver with Full Privacy Stack                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# Architecture: Modular multi-layer defense system
# - Layer 1: DNSCrypt-Proxy (encrypted upstream + optional anonymization)
# - Layer 2: CoreDNS (caching, blocking, metrics)
# - Layer 3: NFTables (leak prevention, kill-switch)
# - Layer 4: Monitoring & Auto-update (Prometheus + systemd timers)
#
# Threat Model: ISP tracking, DNS leaks, malware, telemetry, metadata exposure
# Location: Lower Silesia, PL – Optimized EU/PL relays with IPv6 support
# ==============================================================================

set -euo pipefail

# ==============================================================================
# GLOBAL ERROR TRAP - Better debugging (Roadmap: fail-fast)
# ==============================================================================
trap_err_handler() {
    local exit_code=$?
    local line_no=${BASH_LINENO[0]}
    local func_name=${FUNCNAME[1]:-main}
    local command="$BASH_COMMAND"
    echo -e "\033[0;31m✗ ERROR in ${func_name}() at line ${line_no}: '${command}' exited with code ${exit_code}\033[0m" >&2
}
trap 'trap_err_handler' ERR

# ==============================================================================
# INTEGRITY LAYER - Local-First Security Policy
# ==============================================================================
CYTADELA_MANIFEST="/etc/cytadela/manifest.sha256"
CYTADELA_STATE_DIR="/var/lib/cytadela"
CYTADELA_LKG_DIR="${CYTADELA_STATE_DIR}/lkg"
CYTADELA_OPT_BIN="/opt/cytadela/bin"
CYTADELA_MODE="secure"
CYTADELA_SCRIPT_PATH="$(realpath "$0")"

# Parse --dev flag from any position in argv
for arg in "$@"; do
    if [[ "$arg" == "--dev" ]]; then
        CYTADELA_MODE="developer"
    fi
done
# Also check for developer mode file
if [[ -f "${HOME}/.cytadela_dev" ]] || [[ -f "/root/.cytadela_dev" ]]; then
    CYTADELA_MODE="developer"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${CYAN}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}󰄬${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_section() { echo -e "\n${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"; echo -e "${BLUE}║${NC} $1"; echo -e "${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}\n"; }

# ==============================================================================
# INTEGRITY FUNCTIONS
# ==============================================================================
integrity_verify_file() {
    local file="$1"
    local expected_hash="$2"
    if [[ ! -f "$file" ]]; then
        return 2  # file missing
    fi
    local actual_hash
    actual_hash=$(sha256sum "$file" | awk '{print $1}')
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        return 0  # match
    else
        return 1  # mismatch
    fi
}

integrity_check() {
    local silent="${1:-}"
    local has_errors=0
    local has_warnings=0

    if [[ "$CYTADELA_MODE" == "developer" ]]; then
        [[ -z "$silent" ]] && log_info "[DEV MODE] Integrity checks bypassed"
        return 0
    fi

    if [[ ! -f "$CYTADELA_MANIFEST" ]]; then
        log_warning "Integrity not initialized. Run: sudo $0 integrity-init"
        return 0  # don't fail on missing manifest (bootstrap)
    fi

    [[ -z "$silent" ]] && log_info "Verifying integrity from $CYTADELA_MANIFEST ..."

    while IFS='  ' read -r hash filepath; do
        [[ -z "$hash" || "$hash" == "#"* ]] && continue
        
        # Determine file type for policy
        local is_binary=0
        if [[ "$filepath" == "$CYTADELA_OPT_BIN"/* ]]; then
            is_binary=1
        fi

        if [[ ! -f "$filepath" ]]; then
            log_warning "Missing: $filepath"
            has_warnings=1
            continue
        fi

        if ! integrity_verify_file "$filepath" "$hash"; then
            if [[ $is_binary -eq 1 ]]; then
                log_error "INTEGRITY FAIL (binary): $filepath"
                has_errors=1
            else
                log_warning "INTEGRITY MISMATCH (module): $filepath"
                has_warnings=1
                # In secure mode without TTY: fail
                if [[ ! -t 0 && ! -t 1 ]]; then
                    log_error "Non-interactive mode: aborting due to integrity mismatch"
                    has_errors=1
                else
                    # TTY present: prompt
                    echo -n "Continue despite mismatch? [y/N]: "
                    read -r answer
                    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
                        has_errors=1
                    fi
                fi
            fi
        else
            [[ -z "$silent" ]] && log_success "OK: $filepath"
        fi
    done < "$CYTADELA_MANIFEST"

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

integrity_init() {
    log_section "󰯄 INTEGRITY INIT"

    # Create directories if needed
    mkdir -p "$(dirname "$CYTADELA_MANIFEST")"
    mkdir -p "$CYTADELA_LKG_DIR"
    mkdir -p "$CYTADELA_OPT_BIN"

    local manifest_tmp
    manifest_tmp=$(mktemp)

    echo "# Cytadela integrity manifest - generated $(date -Iseconds)" > "$manifest_tmp"
    echo "# Format: sha256  filepath" >> "$manifest_tmp"

    # Add main scripts
    for script in "$CYTADELA_SCRIPT_PATH" "$(dirname "$CYTADELA_SCRIPT_PATH")/citadela_en.sh"; do
        if [[ -f "$script" ]]; then
            sha256sum "$script" >> "$manifest_tmp"
            log_info "Added: $script"
        fi
    done

    # Add English version if exists (same directory)
    local script_dir
    script_dir=$(dirname "$CYTADELA_SCRIPT_PATH")
    if [[ -f "${script_dir}/citadela_en.sh" ]]; then
        sha256sum "${script_dir}/citadela_en.sh" >> "$manifest_tmp"
        log_info "Added: ${script_dir}/citadela_en.sh"
    fi

    # Add binaries from /opt/cytadela/bin if any
    if [[ -d "$CYTADELA_OPT_BIN" ]]; then
        for bin in "$CYTADELA_OPT_BIN"/*; do
            if [[ -f "$bin" && -x "$bin" ]]; then
                sha256sum "$bin" >> "$manifest_tmp"
                log_info "Added: $bin"
            fi
        done
    fi

    mv "$manifest_tmp" "$CYTADELA_MANIFEST"
    chmod 644 "$CYTADELA_MANIFEST"

    log_success "Manifest created: $CYTADELA_MANIFEST"
    log_info "To verify: sudo $0 integrity-check"
}

integrity_status() {
    log_section "󰯄 INTEGRITY STATUS"
    echo "Mode: $CYTADELA_MODE"
    echo "Manifest: $CYTADELA_MANIFEST"
    if [[ -f "$CYTADELA_MANIFEST" ]]; then
        echo "Manifest exists: YES"
        echo "Entries: $(grep -c -v '^#' "$CYTADELA_MANIFEST" 2>/dev/null || echo 0)"
    else
        echo "Manifest exists: NO (run integrity-init to create)"
    fi
    echo "LKG directory: $CYTADELA_LKG_DIR"
    if [[ -d "$CYTADELA_LKG_DIR" ]]; then
        echo "LKG files: $(find "$CYTADELA_LKG_DIR" -type f 2>/dev/null | wc -l)"
    fi
}

# ==============================================================================
# DISCOVER - Network & Firewall Sanity Snapshot (Issue #10)
# ==============================================================================
discover_active_interface() {
    # Detect active interface via route lookup (IPv4 primary, IPv6 fallback)
    local iface=""
    # Try IPv4 first
    iface=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}' || true)
    if [[ -z "$iface" ]]; then
        # Fallback to IPv6
        iface=$(ip -6 route get 2001:4860:4860::8888 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}' || true)
    fi
    echo "$iface"
}

discover_network_stack() {
    # Detect which network manager is active
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        echo "NetworkManager"
    elif systemctl is-active --quiet systemd-networkd 2>/dev/null; then
        echo "systemd-networkd"
    elif command -v nmcli &>/dev/null && nmcli -t -f RUNNING general 2>/dev/null | grep -q running; then
        echo "NetworkManager"
    else
        echo "unknown"
    fi
}

discover_nftables_status() {
    # Check nftables version and Citadel tables
    local nft_version=""
    local citadel_tables=""
    
    if command -v nft &>/dev/null; then
        nft_version=$(nft --version 2>/dev/null | head -1 || echo "unknown")
        citadel_tables=$(nft list tables 2>/dev/null | grep -c "citadel" || echo "0")
    else
        nft_version="not installed"
        citadel_tables="0"
    fi
    
    echo "version:${nft_version}|citadel_tables:${citadel_tables}"
}

discover() {
    log_section "🔍 DISCOVER - Network & Firewall Snapshot"
    
    local iface
    iface=$(discover_active_interface)
    local stack
    stack=$(discover_network_stack)
    local nft_status
    nft_status=$(discover_nftables_status)
    
    echo "Active Interface: ${iface:-none detected}"
    echo "Network Stack: $stack"
    echo "NFTables: $nft_status"
    
    # IPv4 info
    if [[ -n "$iface" ]]; then
        local ipv4_addr
        ipv4_addr=$(ip -4 addr show dev "$iface" 2>/dev/null | awk '/inet / {print $2; exit}' || true)
        echo "IPv4 Address: ${ipv4_addr:-none}"
        
        # IPv6 info
        local ipv6_global
        ipv6_global=$(ip -6 addr show dev "$iface" scope global 2>/dev/null | awk '/inet6/ {print $2; exit}' || true)
        local ipv6_temp
        ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ {print $2; exit}' || true)
        echo "IPv6 Global: ${ipv6_global:-none}"
        echo "IPv6 Temporary: ${ipv6_temp:-none}"
    fi
    
    # DNS stack status
    echo ""
    echo "DNS Stack:"
    for svc in dnscrypt-proxy coredns; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "  $svc: active"
        else
            echo "  $svc: inactive"
        fi
    done
}

# ==============================================================================
# IPv6 PRIVACY AUTO-ENSURE (Issue #9)
# ==============================================================================
ipv6_privacy_auto_ensure() {
    log_section "󰌾 IPv6 PRIVACY AUTO-ENSURE"
    
    # Step 1: Detect active interface
    local iface
    iface=$(discover_active_interface)
    if [[ -z "$iface" ]]; then
        log_warning "No active interface detected. Skipping."
        return 0
    fi
    log_info "Active interface: $iface"
    
    # Step 2: Check IPv6 availability
    local ipv6_global
    ipv6_global=$(ip -6 addr show dev "$iface" scope global 2>/dev/null | grep -v temporary | awk '/inet6/ {print $2; exit}' || true)
    if [[ -z "$ipv6_global" ]]; then
        log_info "No global IPv6 on $iface. Ensuring sysctl is configured anyway."
    fi
    
    # Step 3: Check for usable temporary address
    local ipv6_temp
    ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ && /preferred_lft/ {print $2; exit}' || true)
    
    # Also check preferred_lft > 0
    local temp_preferred=0
    if [[ -n "$ipv6_temp" ]]; then
        local pref_lft
        pref_lft=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | grep -oP 'preferred_lft \K[0-9]+' | head -1 || echo "0")
        if [[ "$pref_lft" -gt 0 ]]; then
            temp_preferred=1
        fi
    fi
    
    if [[ $temp_preferred -eq 1 ]]; then
        log_success "Usable temporary IPv6 address found: $ipv6_temp"
        log_success "IPv6 Privacy Extensions are working correctly."
        return 0
    fi
    
    # Step 4: Remediation needed
    log_warning "No usable temporary IPv6 address. Applying remediation..."
    
    # 4a: Ensure sysctl config is set (persistent)
    local sysctl_file="/etc/sysctl.d/40-citadel-ipv6-privacy.conf"
    log_info "Setting sysctl for IPv6 privacy extensions..."
    cat > "$sysctl_file" <<EOF
# Cytadela IPv6 Privacy Extensions
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.${iface}.use_tempaddr = 2
EOF
    sysctl --system >/dev/null 2>&1 || true
    log_success "Sysctl configured: use_tempaddr=2"
    
    # 4b: Trigger address regeneration (stack-aware)
    local stack
    stack=$(discover_network_stack)
    log_info "Network stack: $stack. Triggering address regeneration..."
    
    if [[ "$stack" == "NetworkManager" ]]; then
        # NM: reconnect interface
        if command -v nmcli &>/dev/null; then
            log_info "Reconnecting $iface via NetworkManager..."
            nmcli dev disconnect "$iface" 2>/dev/null || true
            sleep 1
            nmcli dev connect "$iface" 2>/dev/null || true
            sleep 2
        fi
    elif [[ "$stack" == "systemd-networkd" ]]; then
        # networkd: reconfigure
        if command -v networkctl &>/dev/null; then
            log_info "Reconfiguring $iface via systemd-networkd..."
            networkctl reconfigure "$iface" 2>/dev/null || true
            sleep 2
        fi
    else
        # Fallback: just apply sysctl, user may need to reconnect manually
        log_warning "Unknown network stack. Sysctl applied, but you may need to reconnect manually."
    fi
    
    # Verify result
    sleep 1
    ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ {print $2; exit}' || true)
    if [[ -n "$ipv6_temp" ]]; then
        log_success "Temporary IPv6 address now active: $ipv6_temp"
    else
        log_warning "Temporary address not yet visible. It may take a moment to appear."
        log_info "Check with: ip -6 addr show dev $iface scope global temporary"
    fi
}

# ==============================================================================
# LKG (Last Known Good) - Blocklist Cache Management (Issue #1 part 2)
# ==============================================================================
LKG_BLOCKLIST="${CYTADELA_LKG_DIR}/blocklist.hosts"
LKG_BLOCKLIST_META="${CYTADELA_LKG_DIR}/blocklist.meta"

lkg_validate_blocklist() {
    local file="$1"
    local min_lines=1000
    
    # Check if file exists and is not empty
    if [[ ! -s "$file" ]]; then
        log_warning "LKG: File empty or missing: $file"
        return 1
    fi
    
    # Check minimum line count
    local lines
    lines=$(wc -l < "$file")
    if [[ $lines -lt $min_lines ]]; then
        log_warning "LKG: File too small ($lines lines, min $min_lines): $file"
        return 1
    fi
    
    # Check for error page markers
    if grep -qiE '<html|<!DOCTYPE|AccessDenied|404 Not Found|403 Forbidden' "$file" 2>/dev/null; then
        log_warning "LKG: File looks like error page: $file"
        return 1
    fi
    
    # Check format (should have hosts-style entries)
    if ! head -100 "$file" | grep -qE '^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]' 2>/dev/null; then
        log_warning "LKG: File doesn't look like hosts format: $file"
        return 1
    fi
    
    return 0
}

lkg_save_blocklist() {
    local source="/etc/coredns/zones/blocklist.hosts"
    
    if [[ ! -f "$source" ]]; then
        log_warning "LKG: No blocklist to save"
        return 1
    fi
    
    if ! lkg_validate_blocklist "$source"; then
        log_warning "LKG: Current blocklist failed validation, not saving"
        return 1
    fi
    
    mkdir -p "$CYTADELA_LKG_DIR"
    cp "$source" "$LKG_BLOCKLIST"
    echo "saved=$(date -Iseconds)" > "$LKG_BLOCKLIST_META"
    echo "lines=$(wc -l < "$LKG_BLOCKLIST")" >> "$LKG_BLOCKLIST_META"
    echo "sha256=$(sha256sum "$LKG_BLOCKLIST" | awk '{print $1}')" >> "$LKG_BLOCKLIST_META"
    
    log_success "LKG: Blocklist saved ($(wc -l < "$LKG_BLOCKLIST") lines)"
}

lkg_restore_blocklist() {
    local target="/etc/coredns/zones/blocklist.hosts"
    
    if [[ ! -f "$LKG_BLOCKLIST" ]]; then
        log_warning "LKG: No saved blocklist to restore"
        return 1
    fi
    
    if ! lkg_validate_blocklist "$LKG_BLOCKLIST"; then
        log_error "LKG: Saved blocklist failed validation"
        return 1
    fi
    
    cp "$LKG_BLOCKLIST" "$target"
    chown root:coredns "$target" 2>/dev/null || true
    chmod 0640 "$target" 2>/dev/null || true
    
    log_success "LKG: Blocklist restored from cache"
}

lkg_status() {
    log_section "󰏗 LKG (Last Known Good) STATUS"
    
    echo "LKG Directory: $CYTADELA_LKG_DIR"
    
    if [[ -f "$LKG_BLOCKLIST" ]]; then
        echo "Blocklist cache: EXISTS"
        echo "  Lines: $(wc -l < "$LKG_BLOCKLIST")"
        if [[ -f "$LKG_BLOCKLIST_META" ]]; then
            cat "$LKG_BLOCKLIST_META" | sed 's/^/  /'
        fi
    else
        echo "Blocklist cache: NOT FOUND"
        echo "  Run: sudo $0 lkg-save"
    fi
}

lists_update() {
    log_section "📥 LISTS UPDATE (with LKG fallback)"
    
    local blocklist_url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.txt"
    local staging_file
    staging_file=$(mktemp)
    local target="/etc/coredns/zones/blocklist.hosts"
    
    log_info "Downloading blocklist..."
    
    if curl -sSL --connect-timeout 10 --max-time 60 "$blocklist_url" -o "$staging_file" 2>/dev/null; then
        log_info "Download complete. Validating..."
        
        if lkg_validate_blocklist "$staging_file"; then
            # Atomic swap
            mv "$staging_file" "$target"
            chown root:coredns "$target" 2>/dev/null || true
            chmod 0640 "$target" 2>/dev/null || true
            
            log_success "Blocklist updated ($(wc -l < "$target") lines)"
            
            # Save to LKG
            lkg_save_blocklist
            
            # Rebuild combined
            adblock_rebuild
            adblock_reload
            log_success "Adblock rebuilt + CoreDNS reloaded"
        else
            log_warning "Downloaded blocklist failed validation"
            rm -f "$staging_file"
            log_info "Keeping current blocklist"
        fi
    else
        log_warning "Download failed. Using LKG fallback..."
        rm -f "$staging_file"
        
        if lkg_restore_blocklist; then
            adblock_rebuild
            adblock_reload
            log_success "Restored from LKG cache"
        else
            log_warning "No LKG available. Keeping current blocklist."
        fi
    fi
}

# ==============================================================================
# PANIC-BYPASS / RECOVERY MODE (Roadmap: SPOF mitigation)
# ==============================================================================
PANIC_STATE_FILE="${CYTADELA_STATE_DIR}/panic.state"
PANIC_BACKUP_RESOLV="${CYTADELA_STATE_DIR}/resolv.conf.pre-panic"
PANIC_ROLLBACK_TIMER=300  # 5 minutes default

panic_bypass() {
    log_section "🚨 PANIC BYPASS - Emergency Recovery Mode"
    
    local rollback_seconds="${1:-$PANIC_ROLLBACK_TIMER}"
    
    # Check if already in panic mode
    if [[ -f "$PANIC_STATE_FILE" ]]; then
        log_warning "Already in panic mode. Use 'panic-restore' to exit."
        return 1
    fi
    
    log_warning "This will temporarily disable DNS protection!"
    log_info "Auto-rollback in ${rollback_seconds} seconds (or run 'panic-restore')"
    
    # Confirm if TTY
    if [[ -t 0 && -t 1 ]]; then
        echo -n "Continue? [y/N]: "
        read -r answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            log_info "Cancelled."
            return 0
        fi
    fi
    
    mkdir -p "$CYTADELA_STATE_DIR"
    
    # Save current state
    log_info "Saving current state..."
    cp /etc/resolv.conf "$PANIC_BACKUP_RESOLV" 2>/dev/null || true
    nft list ruleset > "${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true
    
    # Record panic state
    echo "started=$(date -Iseconds)" > "$PANIC_STATE_FILE"
    echo "rollback_at=$(date -d "+${rollback_seconds} seconds" -Iseconds 2>/dev/null || date -Iseconds)" >> "$PANIC_STATE_FILE"
    echo "rollback_seconds=$rollback_seconds" >> "$PANIC_STATE_FILE"
    
    # Step 1: Flush nftables (allow all traffic)
    log_info "Flushing nftables rules..."
    nft flush ruleset 2>/dev/null || true
    
    # Step 2: Set temporary resolv.conf to public DNS
    log_info "Setting temporary public DNS..."
    # Remove symlink if exists (systemd-resolved creates symlink)
    rm -f /etc/resolv.conf 2>/dev/null || true
    cat > /etc/resolv.conf <<EOF
# CYTADELA PANIC MODE - Temporary public DNS
# Auto-rollback scheduled or run: sudo cytadela++.sh panic-restore
nameserver 9.9.9.9
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF
    
    log_success "Panic bypass ACTIVE"
    log_warning "DNS protection DISABLED - using public DNS"
    log_info "Restore with: sudo $0 panic-restore"
    
    # Schedule auto-rollback (background)
    if [[ $rollback_seconds -gt 0 ]]; then
        log_info "Auto-rollback scheduled in ${rollback_seconds}s..."
        (
            sleep "$rollback_seconds"
            if [[ -f "$PANIC_STATE_FILE" ]]; then
                "$CYTADELA_SCRIPT_PATH" panic-restore --auto 2>/dev/null || true
            fi
        ) &
        disown
    fi
}

panic_restore() {
    log_section "󰜝 PANIC RESTORE - Returning to Protected Mode"
    
    local auto_mode="${1:-}"
    
    if [[ ! -f "$PANIC_STATE_FILE" ]]; then
        log_info "Not in panic mode. Nothing to restore."
        return 0
    fi
    
    if [[ "$auto_mode" == "--auto" ]]; then
        log_info "Auto-rollback triggered"
    fi
    
    # Restore resolv.conf
    log_info "Restoring resolv.conf..."
    rm -f /etc/resolv.conf 2>/dev/null || true
    if [[ -f "$PANIC_BACKUP_RESOLV" ]]; then
        cp "$PANIC_BACKUP_RESOLV" /etc/resolv.conf
    else
        # Fallback to localhost
        cat > /etc/resolv.conf <<EOF
# Generated by Cytadela
nameserver 127.0.0.1
EOF
    fi
    
    # Restore nftables
    log_info "Restoring nftables rules..."
    if [[ -f "${CYTADELA_STATE_DIR}/nft.pre-panic" ]]; then
        nft -f "${CYTADELA_STATE_DIR}/nft.pre-panic" 2>/dev/null || true
    else
        # Reload from system config
        systemctl restart nftables 2>/dev/null || true
    fi
    
    # Restart DNS services
    log_info "Restarting DNS services..."
    systemctl restart dnscrypt-proxy 2>/dev/null || true
    systemctl restart coredns 2>/dev/null || true
    
    # Clean up state
    rm -f "$PANIC_STATE_FILE"
    rm -f "$PANIC_BACKUP_RESOLV"
    rm -f "${CYTADELA_STATE_DIR}/nft.pre-panic"
    
    log_success "Panic mode DEACTIVATED"
    log_success "DNS protection RESTORED"
}

panic_status() {
    log_section "🚨 PANIC MODE STATUS"
    
    if [[ -f "$PANIC_STATE_FILE" ]]; then
        echo "Status: PANIC MODE ACTIVE"
        echo ""
        cat "$PANIC_STATE_FILE" | sed 's/^/  /'
        echo ""
        log_warning "DNS protection is DISABLED"
        log_info "Restore with: sudo $0 panic-restore"
    else
        echo "Status: Normal (protected mode)"
        log_success "DNS protection is ACTIVE"
    fi
}

# ==============================================================================
# GHOST-CHECK - Port Audit (Roadmap: firewall/exposure audit)
# ==============================================================================
GHOST_ALLOWED_PORTS=(22 53 5353 9153)  # SSH, DNS, DNSCrypt, CoreDNS metrics

ghost_check() {
    log_section "👻 GHOST-CHECK - Port Exposure Audit"
    
    local warnings=0
    local iface
    iface=$(discover_active_interface)
    
    log_info "Scanning listening sockets..."
    echo ""
    
    # Get all listening TCP/UDP sockets
    echo "=== LISTENING SOCKETS ==="
    printf "%-8s %-25s %-20s %s\n" "PROTO" "LOCAL ADDRESS" "STATE" "PROCESS"
    echo "-------------------------------------------------------------------"
    
    while IFS= read -r line; do
        local proto addr state process port bind_addr
        proto=$(echo "$line" | awk '{print $1}')
        addr=$(echo "$line" | awk '{print $5}')
        state=$(echo "$line" | awk '{print $2}')
        process=$(echo "$line" | awk '{print $7}' | sed 's/users:(("//' | sed 's/".*$//')
        
        # Extract port and bind address
        port=$(echo "$addr" | grep -oE '[0-9]+$')
        bind_addr=$(echo "$addr" | sed "s/:${port}$//")
        
        # Check if bound to 0.0.0.0 or :: (all interfaces)
        local exposed=0
        local exposure_type=""
        if [[ "$bind_addr" == "0.0.0.0" ]]; then
            exposed=1
            exposure_type="IPv4-ALL"
        elif [[ "$bind_addr" == "*" ]]; then
            exposed=1
            exposure_type="ALL"
        elif [[ "$bind_addr" == "::" ]]; then
            exposed=1
            exposure_type="IPv6-ALL"
        elif [[ "$bind_addr" == "[::]" ]]; then
            exposed=1
            exposure_type="IPv6-ALL"
        fi
        
        # Format output
        if [[ $exposed -eq 1 ]]; then
            # Check if port is in allowed list
            local allowed=0
            for p in "${GHOST_ALLOWED_PORTS[@]}"; do
                if [[ "$port" == "$p" ]]; then
                    allowed=1
                    break
                fi
            done
            
            if [[ $allowed -eq 0 ]]; then
                printf "${YELLOW}%-8s %-25s %-20s %s${NC} ⚠ EXPOSED (%s)\n" "$proto" "$addr" "$state" "$process" "$exposure_type"
                ((warnings++))
            else
                printf "${GREEN}%-8s %-25s %-20s %s${NC} 󰄬 (allowed)\n" "$proto" "$addr" "$state" "$process"
            fi
        else
            printf "%-8s %-25s %-20s %s\n" "$proto" "$addr" "$state" "$process"
        fi
    done < <(ss -tulnp 2>/dev/null | tail -n +2)
    
    echo ""
    echo "=== SUMMARY ==="
    echo "Allowed ports: ${GHOST_ALLOWED_PORTS[*]}"
    
    if [[ $warnings -gt 0 ]]; then
        log_warning "$warnings port(s) exposed to all interfaces (not in allowed list)"
        log_info "Review above and consider binding to 127.0.0.1 or specific interface"
    else
        log_success "No unexpected exposed ports found"
    fi
    
    # NFTables check
    echo ""
    echo "=== NFTABLES STATUS ==="
    if command -v nft &>/dev/null; then
        local tables
        tables=$(nft list tables 2>/dev/null | wc -l)
        echo "Active tables: $tables"
        if nft list tables 2>/dev/null | grep -q "citadel"; then
            log_success "Citadel firewall rules loaded"
        else
            log_warning "Citadel firewall rules NOT loaded"
        fi
    else
        log_warning "nftables not installed"
    fi
}

# ==============================================================================
# IPv6 DEEP RESET (Roadmap: refresh IPv6 without router UI)
# ==============================================================================
ipv6_deep_reset() {
    log_section "󰜝 IPv6 DEEP RESET"
    
    local iface
    iface=$(discover_active_interface)
    if [[ -z "$iface" ]]; then
        log_error "No active interface detected"
        return 1
    fi
    log_info "Active interface: $iface"
    
    # Show current state
    log_info "Current IPv6 addresses:"
    ip -6 addr show dev "$iface" scope global 2>/dev/null | grep inet6 || echo "  (none)"
    
    # Confirm if TTY
    if [[ -t 0 && -t 1 ]]; then
        echo ""
        log_warning "This will temporarily disrupt IPv6 connectivity!"
        echo -n "Continue? [y/N]: "
        read -r answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            log_info "Cancelled."
            return 0
        fi
    fi
    
    # Step 1: Flush IPv6 neighbor cache
    log_info "Flushing IPv6 neighbor cache..."
    ip -6 neigh flush dev "$iface" 2>/dev/null || true
    
    # Step 2: Flush IPv6 addresses (global scope only)
    log_info "Flushing global IPv6 addresses..."
    ip -6 addr flush dev "$iface" scope global 2>/dev/null || true
    
    # Step 3: Trigger Router Advertisement solicitation (stack-aware)
    local stack
    stack=$(discover_network_stack)
    log_info "Network stack: $stack"
    
    if [[ "$stack" == "NetworkManager" ]]; then
        log_info "Reconnecting via NetworkManager..."
        nmcli dev disconnect "$iface" 2>/dev/null || true
        sleep 1
        nmcli dev connect "$iface" 2>/dev/null || true
    elif [[ "$stack" == "systemd-networkd" ]]; then
        log_info "Reconfiguring via systemd-networkd..."
        networkctl reconfigure "$iface" 2>/dev/null || true
    else
        # Manual: bring interface down/up
        log_info "Cycling interface..."
        ip link set "$iface" down 2>/dev/null || true
        sleep 1
        ip link set "$iface" up 2>/dev/null || true
    fi
    
    # Wait for RA
    log_info "Waiting for Router Advertisement..."
    sleep 3
    
    # Step 4: Optionally send RS manually (if rdisc6 available)
    if command -v rdisc6 &>/dev/null; then
        log_info "Sending Router Solicitation..."
        rdisc6 "$iface" 2>/dev/null || true
        sleep 2
    fi
    
    # Show new state
    echo ""
    log_info "New IPv6 addresses:"
    ip -6 addr show dev "$iface" scope global 2>/dev/null | grep inet6 || echo "  (none - may take a moment)"
    
    # Check for temporary address
    local ipv6_temp
    ipv6_temp=$(ip -6 addr show dev "$iface" scope global temporary 2>/dev/null | awk '/inet6/ {print $2; exit}' || true)
    if [[ -n "$ipv6_temp" ]]; then
        log_success "Temporary address active: $ipv6_temp"
    else
        log_info "No temporary address yet. Run 'ipv6-privacy-auto' if needed."
    fi
    
    log_success "IPv6 deep reset complete"
}

# ==============================================================================
# SYSTEMD HEALTH CHECKS (Roadmap: restart/watchdog + health probes)
# ==============================================================================
HEALTH_CHECK_SERVICES=(dnscrypt-proxy coredns)

health_check_dns() {
    # Quick DNS health probe - returns 0 if healthy
    local test_domain="cloudflare.com"
    local timeout=3
    
    if command -v dig &>/dev/null; then
        dig +short +time=$timeout "$test_domain" @127.0.0.1 >/dev/null 2>&1
        return $?
    elif command -v nslookup &>/dev/null; then
        timeout $timeout nslookup "$test_domain" 127.0.0.1 >/dev/null 2>&1
        return $?
    else
        # Fallback: just check if coredns is listening
        ss -ln | grep -q ":53 " && return 0 || return 1
    fi
}

health_status() {
    log_section "󰓙 HEALTH STATUS"
    
    local all_healthy=1
    
    # Check services
    echo "=== SERVICES ==="
    for svc in "${HEALTH_CHECK_SERVICES[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            printf "${GREEN}%-20s ACTIVE${NC}\n" "$svc"
        else
            printf "${RED}%-20s INACTIVE${NC}\n" "$svc"
            all_healthy=0
        fi
    done
    
    # Check DNS resolution
    echo ""
    echo "=== DNS PROBE ==="
    if health_check_dns; then
        log_success "DNS resolution working (127.0.0.1)"
    else
        log_error "DNS resolution FAILED"
        all_healthy=0
    fi
    
    # Check nftables
    echo ""
    echo "=== FIREWALL ==="
    if nft list tables 2>/dev/null | grep -q "citadel"; then
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
    
    # Create health check script
    log_info "Creating health check script..."
    cat > /usr/local/bin/citadel-health-check <<'EOF'
#!/bin/bash
# Citadel DNS Health Check - for systemd watchdog

# Quick DNS probe
if dig +short +time=2 cloudflare.com @127.0.0.1 >/dev/null 2>&1; then
    exit 0
else
    # Try restart before failing
    systemctl restart coredns 2>/dev/null
    sleep 2
    if dig +short +time=2 cloudflare.com @127.0.0.1 >/dev/null 2>&1; then
        exit 0
    fi
    exit 1
fi
EOF
    chmod +x /usr/local/bin/citadel-health-check
    
    # Create systemd override for dnscrypt-proxy
    log_info "Creating systemd overrides..."
    mkdir -p /etc/systemd/system/dnscrypt-proxy.service.d
    cat > /etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf <<'EOF'
[Service]
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=5
EOF
    
    # Create systemd override for coredns
    mkdir -p /etc/systemd/system/coredns.service.d
    cat > /etc/systemd/system/coredns.service.d/citadel-restart.conf <<'EOF'
[Service]
Restart=on-failure
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=5
EOF
    
    # Create health check timer
    log_info "Creating health check timer..."
    cat > /etc/systemd/system/citadel-health.service <<'EOF'
[Unit]
Description=Citadel DNS Health Check
After=network.target coredns.service dnscrypt-proxy.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel-health-check
EOF
    
    cat > /etc/systemd/system/citadel-health.timer <<'EOF'
[Unit]
Description=Citadel DNS Health Check Timer

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF
    
    systemctl daemon-reload
    systemctl enable --now citadel-health.timer
    
    log_success "Health watchdog installed"
    log_info "Services will auto-restart on failure"
    log_info "Health check runs every 5 minutes"
}

uninstall_health_watchdog() {
    log_section "🗑️ UNINSTALLING HEALTH WATCHDOG"
    
    systemctl disable --now citadel-health.timer 2>/dev/null || true
    rm -f /etc/systemd/system/citadel-health.service
    rm -f /etc/systemd/system/citadel-health.timer
    rm -f /etc/systemd/system/dnscrypt-proxy.service.d/citadel-restart.conf
    rm -f /etc/systemd/system/coredns.service.d/citadel-restart.conf
    rm -f /usr/local/bin/citadel-health-check
    rmdir /etc/systemd/system/dnscrypt-proxy.service.d 2>/dev/null || true
    rmdir /etc/systemd/system/coredns.service.d 2>/dev/null || true
    systemctl daemon-reload
    
    log_success "Health watchdog uninstalled"
}

# ==============================================================================
# SUPPLY-CHAIN VERIFICATION (Roadmap: sha256/gpg verification)
# ==============================================================================
SUPPLY_CHAIN_CHECKSUMS="/etc/cytadela/checksums.sha256"

supply_chain_verify_file() {
    local file="$1"
    local expected_hash="$2"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 2
    fi
    
    local actual_hash
    actual_hash=$(sha256sum "$file" | awk '{print $1}')
    
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        return 0
    else
        log_error "Hash mismatch for $file"
        log_error "  Expected: $expected_hash"
        log_error "  Actual:   $actual_hash"
        return 1
    fi
}

supply_chain_download() {
    local url="$1"
    local dest="$2"
    local expected_hash="${3:-}"
    
    log_info "Downloading: $url"
    
    local staging
    staging=$(mktemp)
    
    if ! curl -sSL --connect-timeout 10 --max-time 120 "$url" -o "$staging" 2>/dev/null; then
        log_error "Download failed: $url"
        rm -f "$staging"
        return 1
    fi
    
    # Verify hash if provided
    if [[ -n "$expected_hash" ]]; then
        local actual_hash
        actual_hash=$(sha256sum "$staging" | awk '{print $1}')
        
        if [[ "$actual_hash" != "$expected_hash" ]]; then
            log_error "Hash verification FAILED for $url"
            log_error "  Expected: $expected_hash"
            log_error "  Actual:   $actual_hash"
            rm -f "$staging"
            return 1
        fi
        log_success "Hash verified: $actual_hash"
    else
        log_warning "No hash provided - skipping verification"
    fi
    
    # Atomic move
    mv "$staging" "$dest"
    log_success "Downloaded: $dest"
    return 0
}

supply_chain_status() {
    log_section "󰯄 SUPPLY-CHAIN STATUS"
    
    echo "Checksums file: $SUPPLY_CHAIN_CHECKSUMS"
    
    if [[ -f "$SUPPLY_CHAIN_CHECKSUMS" ]]; then
        echo "Status: EXISTS"
        echo "Entries: $(grep -c -v '^#' "$SUPPLY_CHAIN_CHECKSUMS" 2>/dev/null || echo 0)"
        echo ""
        echo "Contents:"
        cat "$SUPPLY_CHAIN_CHECKSUMS" | head -20
    else
        echo "Status: NOT FOUND"
        log_info "Run 'supply-chain-init' to create checksums file"
    fi
}

supply_chain_init() {
    log_section "󰯄 SUPPLY-CHAIN INIT"
    
    mkdir -p "$(dirname "$SUPPLY_CHAIN_CHECKSUMS")"
    
    local tmp
    tmp=$(mktemp)
    
    echo "# Cytadela Supply-Chain Checksums" > "$tmp"
    echo "# Generated: $(date -Iseconds)" >> "$tmp"
    echo "# Format: sha256  url  description" >> "$tmp"
    echo "" >> "$tmp"
    
    # Add known blocklist URLs with current hashes
    log_info "Fetching current blocklist hash..."
    local blocklist_url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.txt"
    local blocklist_hash
    blocklist_hash=$(curl -sSL --connect-timeout 10 "$blocklist_url" 2>/dev/null | sha256sum | awk '{print $1}')
    
    if [[ -n "$blocklist_hash" && "$blocklist_hash" != "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]]; then
        echo "$blocklist_hash  $blocklist_url  # Hagezi Pro blocklist" >> "$tmp"
        log_success "Added blocklist hash"
    else
        log_warning "Could not fetch blocklist hash"
    fi
    
    mv "$tmp" "$SUPPLY_CHAIN_CHECKSUMS"
    chmod 644 "$SUPPLY_CHAIN_CHECKSUMS"
    
    log_success "Supply-chain checksums initialized: $SUPPLY_CHAIN_CHECKSUMS"
    log_info "Note: Blocklist hashes change frequently - use for audit, not strict enforcement"
}

supply_chain_verify() {
    log_section "󰯄 SUPPLY-CHAIN VERIFY"
    
    if [[ ! -f "$SUPPLY_CHAIN_CHECKSUMS" ]]; then
        log_warning "No checksums file. Run 'supply-chain-init' first."
        return 0
    fi
    
    local errors=0
    
    # Verify local files from integrity manifest
    if [[ -f "$CYTADELA_MANIFEST" ]]; then
        log_info "Verifying integrity manifest..."
        while IFS='  ' read -r hash filepath; do
            [[ -z "$hash" || "$hash" == "#"* ]] && continue
            
            if [[ -f "$filepath" ]]; then
                if supply_chain_verify_file "$filepath" "$hash"; then
                    log_success "OK: $filepath"
                else
                    ((errors++))
                fi
            else
                log_warning "Missing: $filepath"
            fi
        done < "$CYTADELA_MANIFEST"
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "All supply-chain checks passed"
    else
        log_error "$errors verification error(s)"
        return 1
    fi
}

# ==============================================================================
# LOCATION-AWARE ADVISORY (Roadmap: SSID-based security)
# ==============================================================================
TRUSTED_SSIDS_FILE="/etc/cytadela/trusted-ssids.txt"

location_get_ssid() {
    # Get current WiFi SSID via NetworkManager
    local ssid=""
    if command -v nmcli &>/dev/null; then
        ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 | head -1)
    fi
    echo "$ssid"
}

location_is_trusted() {
    local ssid="$1"
    
    if [[ -z "$ssid" ]]; then
        return 1  # No SSID = not trusted (wired or no connection)
    fi
    
    if [[ ! -f "$TRUSTED_SSIDS_FILE" ]]; then
        return 1  # No trusted list = not trusted
    fi
    
    if grep -qxF "$ssid" "$TRUSTED_SSIDS_FILE" 2>/dev/null; then
        return 0  # Found in trusted list
    fi
    
    return 1
}

location_get_firewall_mode() {
    # Check if STRICT or SAFE mode is active
    if nft list table inet citadel_dns 2>/dev/null | grep -q "drop"; then
        echo "STRICT"
    elif nft list tables 2>/dev/null | grep -q "citadel"; then
        echo "SAFE"
    else
        echo "NONE"
    fi
}

location_status() {
    log_section "📍 LOCATION STATUS"
    
    local ssid
    ssid=$(location_get_ssid)
    local fw_mode
    fw_mode=$(location_get_firewall_mode)
    
    echo "=== NETWORK ==="
    if [[ -n "$ssid" ]]; then
        echo "Connection: WiFi"
        echo "SSID: \"$ssid\""
        if location_is_trusted "$ssid"; then
            printf "Trusted: ${GREEN}YES${NC}\n"
        else
            printf "Trusted: ${YELLOW}NO${NC}\n"
        fi
    else
        echo "Connection: Wired or no WiFi"
        echo "SSID: (none)"
        echo "Trusted: N/A (wired networks not tracked)"
    fi
    
    echo ""
    echo "=== FIREWALL ==="
    echo "Mode: $fw_mode"
    
    echo ""
    echo "=== TRUSTED SSIDS ==="
    if [[ -f "$TRUSTED_SSIDS_FILE" ]]; then
        local count
        count=$(grep -c -v '^#' "$TRUSTED_SSIDS_FILE" 2>/dev/null || echo 0)
        echo "File: $TRUSTED_SSIDS_FILE"
        echo "Count: $count"
        if [[ $count -gt 0 ]]; then
            echo "List:"
            grep -v '^#' "$TRUSTED_SSIDS_FILE" | sed 's/^/  - /'
        fi
    else
        echo "File: NOT FOUND"
        log_info "Run 'location-add-trusted <SSID>' to add trusted networks"
    fi
}

location_check() {
    log_section "📍 LOCATION CHECK"
    
    local ssid
    ssid=$(location_get_ssid)
    local fw_mode
    fw_mode=$(location_get_firewall_mode)
    local is_trusted=0
    
    if [[ -n "$ssid" ]]; then
        echo "Current SSID: \"$ssid\""
        if location_is_trusted "$ssid"; then
            is_trusted=1
            printf "Trusted: ${GREEN}YES${NC}\n"
        else
            printf "Trusted: ${YELLOW}NO${NC}\n"
        fi
    else
        echo "Current SSID: (wired/none)"
        is_trusted=1  # Wired = trusted by default
    fi
    
    echo "Firewall mode: $fw_mode"
    echo ""
    
    # Advisory logic
    if [[ $is_trusted -eq 0 && "$fw_mode" == "SAFE" ]]; then
        log_warning "You are on an UNTRUSTED network with SAFE firewall!"
        log_info "Recommendation: Switch to STRICT mode for better protection"
        
        if [[ -t 0 && -t 1 ]]; then
            echo -n "Switch to STRICT mode? [y/N]: "
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                install_nftables_strict
                log_success "Firewall switched to STRICT"
            else
                log_info "Keeping SAFE mode"
            fi
        fi
    elif [[ $is_trusted -eq 1 && "$fw_mode" == "STRICT" ]]; then
        log_info "You are on a TRUSTED network with STRICT firewall"
        log_info "You may switch to SAFE mode if needed: firewall-safe"
    elif [[ $is_trusted -eq 0 && "$fw_mode" == "STRICT" ]]; then
        log_success "Good: UNTRUSTED network + STRICT firewall"
    elif [[ $is_trusted -eq 1 && "$fw_mode" == "SAFE" ]]; then
        log_success "Good: TRUSTED network + SAFE firewall"
    elif [[ "$fw_mode" == "NONE" ]]; then
        log_warning "No Citadel firewall rules loaded!"
        log_info "Run: firewall-safe or firewall-strict"
    fi
}

location_add_trusted() {
    local ssid="$1"
    
    if [[ -z "$ssid" ]]; then
        # If no argument, use current SSID
        ssid=$(location_get_ssid)
        if [[ -z "$ssid" ]]; then
            log_error "No SSID provided and no WiFi connection detected"
            log_info "Usage: location-add-trusted <SSID>"
            return 1
        fi
        log_info "Using current SSID: \"$ssid\""
    fi
    
    mkdir -p "$(dirname "$TRUSTED_SSIDS_FILE")"
    touch "$TRUSTED_SSIDS_FILE"
    
    if grep -qxF "$ssid" "$TRUSTED_SSIDS_FILE" 2>/dev/null; then
        log_info "Already in trusted list: \"$ssid\""
    else
        echo "$ssid" >> "$TRUSTED_SSIDS_FILE"
        log_success "Added to trusted list: \"$ssid\""
    fi
}

location_remove_trusted() {
    local ssid="$1"
    
    if [[ -z "$ssid" ]]; then
        log_error "Usage: location-remove-trusted <SSID>"
        return 1
    fi
    
    if [[ ! -f "$TRUSTED_SSIDS_FILE" ]]; then
        log_warning "No trusted SSID list found"
        return 0
    fi
    
    if grep -qxF "$ssid" "$TRUSTED_SSIDS_FILE" 2>/dev/null; then
        grep -vxF "$ssid" "$TRUSTED_SSIDS_FILE" > "${TRUSTED_SSIDS_FILE}.tmp"
        mv "${TRUSTED_SSIDS_FILE}.tmp" "$TRUSTED_SSIDS_FILE"
        log_success "Removed from trusted list: \"$ssid\""
    else
        log_info "Not in trusted list: \"$ssid\""
    fi
}

location_list_trusted() {
    log_section "📍 TRUSTED SSIDS"
    
    if [[ -f "$TRUSTED_SSIDS_FILE" ]]; then
        local count
        count=$(grep -c -v '^#' "$TRUSTED_SSIDS_FILE" 2>/dev/null || echo 0)
        echo "Count: $count"
        if [[ $count -gt 0 ]]; then
            echo ""
            grep -v '^#' "$TRUSTED_SSIDS_FILE" | while read -r ssid; do
                [[ -z "$ssid" ]] && continue
                local current_ssid
                current_ssid=$(location_get_ssid)
                if [[ "$ssid" == "$current_ssid" ]]; then
                    printf "  ${GREEN}● %s${NC} (current)\n" "$ssid"
                else
                    printf "  ○ %s\n" "$ssid"
                fi
            done
        fi
    else
        echo "No trusted SSIDs configured"
        log_info "Add with: location-add-trusted <SSID>"
    fi
}

# ==============================================================================
# NFTABLES DEBUG CHAIN (Roadmap: rate-limited logging/counters)
# ==============================================================================
NFT_DEBUG_TABLE="citadel_debug"

nft_debug_on() {
    log_section "󰊠 NFT DEBUG - ENABLING"
    
    # Create debug table with logging chain
    log_info "Creating debug table with rate-limited logging..."
    
    nft add table inet $NFT_DEBUG_TABLE 2>/dev/null || true
    
    # Create debug chain
    nft add chain inet $NFT_DEBUG_TABLE debug_log '{ type filter hook forward priority -10; policy accept; }' 2>/dev/null || true
    
    # Add counters and rate-limited logging
    nft flush chain inet $NFT_DEBUG_TABLE debug_log 2>/dev/null || true
    
    # Log DNS attempts (rate limited: 5/minute)
    nft add rule inet $NFT_DEBUG_TABLE debug_log udp dport 53 limit rate 5/minute counter log prefix \"[CITADEL-DNS] \" 2>/dev/null || true
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 53 limit rate 5/minute counter log prefix \"[CITADEL-DNS] \" 2>/dev/null || true
    
    # Log DoT attempts
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 853 limit rate 5/minute counter log prefix \"[CITADEL-DOT] \" 2>/dev/null || true
    
    # Log DoH attempts (common ports)
    nft add rule inet $NFT_DEBUG_TABLE debug_log tcp dport 443 ip daddr '{ 8.8.8.8, 8.8.4.4, 1.1.1.1, 1.0.0.1, 9.9.9.9 }' limit rate 5/minute counter log prefix '"[CITADEL-DOH] "' 2>/dev/null || true
    
    # General counter for all forwarded traffic
    nft add rule inet $NFT_DEBUG_TABLE debug_log counter 2>/dev/null || true
    
    log_success "Debug chain enabled"
    log_info "View logs: journalctl -f | grep CITADEL"
    log_info "View counters: sudo $0 nft-debug-status"
}

nft_debug_off() {
    log_section "󰊠 NFT DEBUG - DISABLING"
    
    if nft list tables 2>/dev/null | grep -q "$NFT_DEBUG_TABLE"; then
        nft delete table inet $NFT_DEBUG_TABLE 2>/dev/null || true
        log_success "Debug chain disabled"
    else
        log_info "Debug chain was not enabled"
    fi
}

nft_debug_status() {
    log_section "󰊠 NFT DEBUG STATUS"
    
    if nft list tables 2>/dev/null | grep -q "$NFT_DEBUG_TABLE"; then
        printf "Debug chain: ${GREEN}ENABLED${NC}\n"
        echo ""
        echo "=== RULES & COUNTERS ==="
        nft list table inet $NFT_DEBUG_TABLE 2>/dev/null | grep -E "(counter|log)" | sed 's/^/  /'
    else
        printf "Debug chain: ${YELLOW}DISABLED${NC}\n"
        log_info "Enable with: sudo $0 nft-debug-on"
    fi
    
    echo ""
    echo "=== CITADEL TABLES ==="
    nft list tables 2>/dev/null | grep citadel | sed 's/^/  /' || echo "  (none)"
}

nft_debug_logs() {
    log_section "󰊠 NFT DEBUG LOGS (last 50)"
    
    echo "Searching for CITADEL log entries..."
    echo ""
    
    journalctl --no-pager -n 50 2>/dev/null | grep -E "CITADEL-(DNS|DOT|DOH)" || echo "No recent CITADEL log entries found"
    
    echo ""
    log_info "For live logs: journalctl -f | grep CITADEL"
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1
}

require_cmds() {
    local missing=()
    local c
    for c in "$@"; do
        if ! require_cmd "$c"; then
            missing+=("$c")
        fi
    done
    if (( ${#missing[@]} > 0 )); then
        log_error "Brak wymaganych narzędzi: ${missing[*]}"
        return 1
    fi
}

dnssec_enabled() {
    if [[ "${CITADEL_DNSSEC:-}" =~ ^(1|true|yes|on)$ ]]; then
        return 0
    fi
    if [[ "${ARG1:-}" == "--dnssec" || "${ARG2:-}" == "--dnssec" ]]; then
        return 0
    fi
    return 1
}

# Root check
if [[ $EUID -ne 0 ]]; then
    log_error "Ten skrypt wymaga uprawnień root. Uruchom: sudo $0"
    exit 1
fi

# Developer mode banner
if [[ "$CYTADELA_MODE" == "developer" ]]; then
    echo -e "${YELLOW}[!] Cytadela running in DEVELOPER MODE - integrity checks relaxed${NC}"
fi

# Filter out --dev from ACTION parsing
ACTION="help"
for arg in "$@"; do
    if [[ "$arg" != "--dev" ]]; then
        ACTION="$arg"
        break
    fi
done
ARG1=${2:-}
ARG2=${3:-}

 DNSCRYPT_PORT_DEFAULT=5353
 COREDNS_PORT_DEFAULT=53
 COREDNS_METRICS_ADDR="127.0.0.1:9153"

 port_in_use() {
     local port="$1"
     ss -H -lntu | awk '{print $5}' | grep -Eq "(^|:)${port}$" 2>/dev/null
 }

 pick_free_port() {
     local start="$1"
     local end="$2"
     local p
     for p in $(seq "$start" "$end"); do
         if ! port_in_use "$p"; then
             echo "$p"
             return 0
         fi
     done
     return 1
 }

 get_dnscrypt_listen_port() {
     local cfg="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
     if [[ -f "$cfg" ]]; then
         awk -F"[:']" '/^listen_addresses[[:space:]]*=/{for(i=1;i<=NF;i++){if($i ~ /^[0-9]+$/){print $i; exit}}}' "$cfg" 2>/dev/null || true
     fi
 }

 get_coredns_listen_port() {
     local cfg="/etc/coredns/Corefile"
     if [[ -f "$cfg" ]]; then
         awk -F'[:}]' '/^\.:/{gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' "$cfg" 2>/dev/null || true
     fi
 }

# ==============================================================================
# MODULE 1: DNSCrypt-Proxy - Encrypted DNS with Privacy Relays
# ==============================================================================
install_dnscrypt() {
    log_section "MODULE 1: DNSCrypt-Proxy Installation"

    require_cmds ss awk grep tee systemctl dnscrypt-proxy || return 1

    # Create dedicated user
    if ! id dnscrypt &>/dev/null; then
        log_info "Tworzenie dedykowanego użytkownika 'dnscrypt'..."
        useradd -r -s /usr/bin/nologin -d /var/lib/dnscrypt dnscrypt
        log_success "User dnscrypt utworzony"
    else
        log_success "User dnscrypt już istnieje"
    fi

    # Setup directories
    mkdir -p /var/lib/dnscrypt /etc/dnscrypt-proxy
    chown -R dnscrypt:dnscrypt /var/lib/dnscrypt /etc/dnscrypt-proxy

    local dnscrypt_port
    dnscrypt_port=$(pick_free_port "$DNSCRYPT_PORT_DEFAULT" 5365 || true)
    if [[ -z "$dnscrypt_port" ]]; then
        log_error "Nie mogę znaleźć wolnego portu dla DNSCrypt (zakres ${DNSCRYPT_PORT_DEFAULT}-5365)"
        return 1
    fi

    # Create configuration - MINIMAL VERSION
    log_info "Tworzenie konfiguracji DNSCrypt (z listą resolverów + weryfikacją minisign)..."
    local dnssec_value="false"
    if dnssec_enabled; then
        dnssec_value="true"
    fi
    tee /etc/dnscrypt-proxy/dnscrypt-proxy.toml >/dev/null <<EOF
listen_addresses = ['127.0.0.1:${dnscrypt_port}']
max_clients = 250

ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = true

require_dnssec = ${dnssec_value}
require_nolog = true
require_nofilter = false

bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53']
ignore_system_dns = true

server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

log_level = 2

[sources.'public-resolvers']
urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md']
minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
cache_file = 'public-resolvers.md'
EOF

    # Create log directory
    mkdir -p /var/log/dnscrypt-proxy
    chown -R dnscrypt:dnscrypt /var/log/dnscrypt-proxy

    # Advanced configuration file for future upgrades (with anonymization)
    log_info "Tworzenie zaawansowanej konfiguracji (opcjonalnie)..."
    tee /etc/dnscrypt-proxy/dnscrypt-proxy-advanced.toml >/dev/null <<'EOF'
# Citadel++ DNSCrypt ADVANCED Configuration
# USE ONLY IF YOUR dnscrypt-proxy VERSION SUPPORTS IT
# To activate: sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy-advanced.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml

listen_addresses = ['127.0.0.1:5353', '[::1]:5353']
max_clients = 250

cache_size = 512
cache_min_ttl = 600
cache_max_ttl = 86400

ipv4_servers = true
ipv6_servers = true
dnscrypt_servers = true
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = false

bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53', '149.112.112.112:53']

[sources.'public-resolvers']
urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md']
minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
cache_file = 'public-resolvers.md'

# Anonymized DNS (requires working relays)
[anonymized_dns]
routes = [
    { server_name='*', via=['anon-cs-poland', 'anon-cs-berlin', 'anon-cs-nl'] }
]

# Cloaking rules (redirect telemetry to localhost)
cloaking_rules = '/etc/dnscrypt-proxy/cloaking-rules.txt'

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    # Create cloaking rules file
    tee /etc/dnscrypt-proxy/cloaking-rules.txt >/dev/null <<'EOF'
# Microsoft Telemetry
vortex.data.microsoft.com                127.0.0.1
vortex-win.data.microsoft.com            127.0.0.1
telemetry.microsoft.com                  127.0.0.1
watson.telemetry.microsoft.com           127.0.0.1
settings-win.data.microsoft.com          127.0.0.1

# Google Analytics & Firebase
google-analytics.com                     127.0.0.1
firebase.googleapis.com                  127.0.0.1
firebaseinstallations.googleapis.com     127.0.0.1

# Amazon Metrics
device-metrics.us-east-1.amazonaws.com   127.0.0.1
unagi.amazon.com                         127.0.0.1

# Facebook/Meta
graph.facebook.com                       127.0.0.1
pixel.facebook.com                       127.0.0.1
EOF

    chown -R dnscrypt:dnscrypt /etc/dnscrypt-proxy

    # Test configuration
    log_info "Testowanie konfiguracji TOML..."
    if dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check; then
        log_success "Konfiguracja DNSCrypt poprawna"
    else
        log_error "Błąd w konfiguracji TOML - sprawdź logi"
        return 1
    fi

    # Enable and start service
    systemctl enable --now dnscrypt-proxy 2>/dev/null || true
    systemctl restart dnscrypt-proxy
    sleep 2

    if systemctl is-active --quiet dnscrypt-proxy; then
        log_success "DNSCrypt-Proxy działa poprawnie"
    else
        log_error "DNSCrypt-Proxy nie uruchomił się - sprawdź: journalctl -u dnscrypt-proxy -n 50"
        return 1
    fi

    log_success "Moduł DNSCrypt zainstalowany"
}

# ==============================================================================
# MODULE 2: CoreDNS - Caching, Blocking & Metrics
# ==============================================================================
install_coredns() {
    log_section "MODULE 2: CoreDNS Installation"

    require_cmds coredns curl awk sort wc mktemp systemctl || return 1

    # Determine current DNSCrypt listen port early (needed for bootstrap DNS)
    local dnscrypt_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    if [[ -z "$dnscrypt_port" ]]; then
        dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    fi

    # Create directories
    mkdir -p /etc/coredns/zones
    touch /etc/coredns/zones/custom.hosts
    touch /etc/coredns/zones/allowlist.txt
    touch /etc/coredns/zones/blocklist.hosts
    touch /etc/coredns/zones/combined.hosts
    chmod 0644 /etc/coredns/zones/custom.hosts 2>/dev/null || true
    chmod 0644 /etc/coredns/zones/allowlist.txt 2>/dev/null || true
    chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
    chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true

    # Bootstrap CoreDNS so system DNS works during downloads (when resolv.conf points to 127.0.0.1)
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

    # Download blocklists
    log_info "Pobieranie blocklist (OISD + KADhosts + Polish Annoyance + HaGeZi Multi Light)..."
    {
        local tmp_raw tmp_block tmp_combined
        tmp_raw="$(mktemp)"
        tmp_block="$(mktemp)"
        tmp_combined="$(mktemp)"

        curl -fsSL https://big.oisd.nl | grep -v "^#" > "$tmp_raw"
        curl -fsSL https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt | grep -v "^#" >> "$tmp_raw"
        curl -fsSL https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt | grep -v "^#" >> "$tmp_raw"
        curl -fsSL https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/light.txt | grep -v "^#" >> "$tmp_raw"

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

                # hosts format: 0.0.0.0 domain
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

                # adblock format: ||domain^ (or ||domain/path)
                if (line ~ /^\|\|/) {
                    sub(/^\|\|/, "", line)
                    sub(/[\^\/].*$/, "", line)
                    emit(line)
                    next
                }

                # plain domain
                if (line ~ /^[A-Za-z0-9.*-]+(\.[A-Za-z0-9.-]+)+$/) {
                    emit(line)
                    next
                }
            }
        ' "$tmp_raw" | sort -u > "$tmp_block"

        if [[ $(wc -l < "$tmp_block") -lt 1000 ]]; then
            log_warning "Blocklist wygląda na pustą/uszkodzoną ($(wc -l < "$tmp_block") wpisów) - zostawiam poprzednią"
            rm -f "$tmp_raw" "$tmp_block" "$tmp_combined"
            tmp_combined="$(mktemp)"
            cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u > "$tmp_combined"
            mv "$tmp_combined" /etc/coredns/zones/combined.hosts
            chown root:coredns /etc/coredns/zones/combined.hosts 2>/dev/null || true
            chmod 0640 /etc/coredns/zones/combined.hosts 2>/dev/null || true
        else
            mv "$tmp_block" /etc/coredns/zones/blocklist.hosts
            cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u > "$tmp_combined"
            mv "$tmp_combined" /etc/coredns/zones/combined.hosts
            rm -f "$tmp_raw"
            chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
            chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts 2>/dev/null || true
            log_success "Blocklist pobrana ($(wc -l < /etc/coredns/zones/blocklist.hosts) wpisów)"
        fi
    } || {
        log_warning "Nie udało się pobrać blocklist - tworzę pusty plik"
        touch /etc/coredns/zones/blocklist.hosts
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

    cp /etc/coredns/Corefile /etc/coredns/Corefile.citadel

    # Create auto-update service
    log_info "Konfiguracja automatycznej aktualizacji blocklist..."
    tee /etc/systemd/system/citadel-update-blocklist.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ Blocklist Auto-Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'set -e; tmp_raw="$(mktemp)"; tmp_block="$(mktemp)"; tmp_combined="$(mktemp)"; allowlist="/etc/coredns/zones/allowlist.txt"; curl -fsSL https://big.oisd.nl | grep -v "^#" > "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt | grep -v "^#" >> "$tmp_raw"; curl -fsSL https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt | grep -v "^#" >> "$tmp_raw"; curl -fsSL https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/light.txt | grep -v "^#" >> "$tmp_raw"; awk "function emit(d){gsub(/^[*.]+/,\"\",d); gsub(/[[:space:]]+$/,\"\",d); if(d ~ /^[A-Za-z0-9.-]+$/ && d ~ /\\./) print \"0.0.0.0 \" d} {line=\\$0; sub(/\\r$/,\"\",line); if(line ~ /^[[:space:]]*$/) next; if(line ~ /^[[:space:]]*!/) next; if(line ~ /^(0\\.0\\.0\\.0|127\\.0\\.0\\.1|::)[[:space:]]+/){n=split(line,a,/[[:space:]]+/); if(n>=2){d=a[2]; sub(/^\\|\\|/,\"\",d); sub(/[\\^\\/].*$/,\"\",d); emit(d)}; next} if(line ~ /^\\|\\|/){sub(/^\\|\\|/,\"\",line); sub(/[\\^\\/].*$/,\"\",line); emit(line); next} if(line ~ /^[A-Za-z0-9.*-]+(\\\\.[A-Za-z0-9.-]+)+$/){emit(line); next}}" "$tmp_raw" | sort -u > "$tmp_block"; if [ "$(wc -l < \"$tmp_block\")" -lt 1000 ]; then rm -f "$tmp_raw" "$tmp_block" "$tmp_combined"; logger "Citadel++ blocklist update failed (too few entries)"; exit 0; fi; mv "$tmp_block" /etc/coredns/zones/blocklist.hosts; cat /etc/coredns/zones/custom.hosts /etc/coredns/zones/blocklist.hosts | sort -u | awk -v AL="$allowlist" "BEGIN{while((getline l < AL)>0){sub(/\\r$/,\"\",l); gsub(/^[[:space:]]+|[[:space:]]+$/,\"\",l); if(l!=\"\" && l !~ /^#/){k=tolower(l); a[k]=1; esc=k; gsub(/\\./,\"\\\\.\",esc); r[k]=\"\\\\.\" esc \"$\"}}} {d=\\$2; if(d==\"\") next; dl=tolower(d); for(k in a){ if(dl==k || dl ~ r[k]) next } print}" > "$tmp_combined"; mv "$tmp_combined" /etc/coredns/zones/combined.hosts; chown root:coredns /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; chmod 0640 /etc/coredns/zones/blocklist.hosts /etc/coredns/zones/combined.hosts || true; rm -f "$tmp_raw"; systemctl reload coredns; logger "Citadel++ blocklist updated successfully"'
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

adblock_reload() {
    systemctl reload coredns 2>/dev/null || systemctl restart coredns 2>/dev/null || true
}

adblock_status() {
    log_section "󰁣 CITADEL++ ADBLOCK STATUS"

    if systemctl is-active --quiet coredns; then
        echo "  󰄬 coredns: running"
    else
        echo "  ✗ coredns: not running"
    fi

    if [[ -f /etc/coredns/Corefile ]] && grep -q '/etc/coredns/zones/combined\.hosts' /etc/coredns/Corefile; then
        echo "  󰄬 Corefile: uses combined.hosts"
    else
        echo "  ✗ Corefile: missing combined.hosts"
    fi

    if [[ -f /etc/coredns/zones/custom.hosts ]]; then
        echo "  󰄬 custom.hosts:   $(wc -l < /etc/coredns/zones/custom.hosts)"
    else
        echo "  ✗ custom.hosts: missing"
    fi
    if [[ -f /etc/coredns/zones/blocklist.hosts ]]; then
        echo "  󰄬 blocklist.hosts: $(wc -l < /etc/coredns/zones/blocklist.hosts)"
    else
        echo "  ✗ blocklist.hosts: missing"
    fi
    if [[ -f /etc/coredns/zones/combined.hosts ]]; then
        echo "  󰄬 combined.hosts:  $(wc -l < /etc/coredns/zones/combined.hosts)"
    else
        echo "  ✗ combined.hosts: missing"
    fi
}

adblock_stats() {
    log_section "󰓇 CITADEL++ ADBLOCK STATS"
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
    sed -i -E "/^[0-9.:]+[[:space:]]+${domain//./\.}([[:space:]]|
|$)/d" /etc/coredns/zones/custom.hosts || true
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

# ==============================================================================
# MODULE 3: NFTables - Leak Prevention & Kill-Switch
# ==============================================================================
install_nftables() {
    log_section "MODULE 3: NFTables Firewall Rules"

    require_cmds nft grep awk systemctl || return 1

    mkdir -p /etc/nftables.d

    local dnscrypt_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    if [[ -z "$dnscrypt_port" ]]; then
        dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    fi

    log_info "Tworzenie reguł firewall..."
    tee /etc/nftables.d/citadel-dns-safe.nft >/dev/null <<EOF
table inet citadel_dns {
    chain output {
        type filter hook output priority -400; policy accept;

        ip daddr {127.0.0.1, 127.0.0.53, 127.0.0.54} udp dport 53 counter accept
        ip daddr {127.0.0.1, 127.0.0.53, 127.0.0.54} tcp dport 53 counter accept
        ip daddr 127.0.0.1 udp dport ${dnscrypt_port} counter accept
        ip daddr 127.0.0.1 tcp dport ${dnscrypt_port} counter accept
        ip6 daddr ::1 udp dport {53, ${dnscrypt_port}} counter accept
        ip6 daddr ::1 tcp dport {53, ${dnscrypt_port}} counter accept

        ip daddr {9.9.9.9, 1.1.1.1, 149.112.112.112} udp dport 53 counter accept
        ip daddr {9.9.9.9, 1.1.1.1, 149.112.112.112} tcp dport 53 counter accept

        meta skuid "systemd-resolve" udp dport {53, 443, 853} counter accept
        meta skuid "systemd-resolve" tcp dport {53, 443, 853} counter accept

        ip daddr != {127.0.0.1, 127.0.0.53, 127.0.0.54} udp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
        ip daddr != {127.0.0.1, 127.0.0.53, 127.0.0.54} tcp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
    }
}

table inet citadel_emergency {
    chain output {
        type filter hook output priority -300; policy accept;
    }
}
EOF

    tee /etc/nftables.d/citadel-dns-strict.nft >/dev/null <<EOF
table inet citadel_dns {
    chain output {
        type filter hook output priority -400; policy accept;

        ip daddr 127.0.0.1 udp dport 53 counter accept
        ip daddr 127.0.0.1 tcp dport 53 counter accept
        ip6 daddr ::1 udp dport 53 counter accept
        ip6 daddr ::1 tcp dport 53 counter accept

        ip daddr 127.0.0.1 udp dport ${dnscrypt_port} counter accept
        ip daddr 127.0.0.1 tcp dport ${dnscrypt_port} counter accept
        ip6 daddr ::1 udp dport ${dnscrypt_port} counter accept
        ip6 daddr ::1 tcp dport ${dnscrypt_port} counter accept

        udp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
        tcp dport 53 limit rate 10/second counter log prefix "CITADEL DNS LEAK: " drop
    }
}

table inet citadel_emergency {
    chain output {
        type filter hook output priority -300; policy accept;
    }
}
EOF

    ln -sf /etc/nftables.d/citadel-dns-safe.nft /etc/nftables.d/citadel-dns.nft

    # Backup existing config
    if [[ -f /etc/nftables.conf ]]; then
        cp /etc/nftables.conf /etc/nftables.conf.backup-citadel
        log_info "Backup: /etc/nftables.conf -> /etc/nftables.conf.backup-citadel"
    fi

    if [[ ! -f /etc/nftables.conf ]]; then
        printf '%s\n' '#!/usr/bin/nft -f' > /etc/nftables.conf
    fi

    # Deduplicate Citadel include line (in case older runs appended it multiple times)
    if [[ $(grep -cE '^[[:space:]]*include[[:space:]]+"/etc/nftables\.d/citadel-dns\.nft"[[:space:]]*$' /etc/nftables.conf 2>/dev/null || echo 0) -gt 1 ]]; then
        local tmp_nftconf
        tmp_nftconf="$(mktemp)"
        awk 'BEGIN{seen=0}
            /^[[:space:]]*include[[:space:]]+"\/etc\/nftables\.d\/citadel-dns\.nft"[[:space:]]*$/ { if (seen==0) { print; seen=1 } ; next }
            { print }
        ' /etc/nftables.conf > "$tmp_nftconf"
        mv "$tmp_nftconf" /etc/nftables.conf
    fi

    if ! grep -qE '^[[:space:]]*include[[:space:]]+"/etc/nftables\.d/citadel-dns\.nft"[[:space:]]*$' /etc/nftables.conf; then
        printf '\ninclude "/etc/nftables.d/citadel-dns.nft"\n' >> /etc/nftables.conf
    fi

    # Validate syntax
    log_info "Walidacja składni nftables..."
    if nft -c -f <(printf '%s\n' 'flush ruleset'; cat /etc/nftables.d/citadel-dns-safe.nft) \
        && nft -c -f <(printf '%s\n' 'flush ruleset'; cat /etc/nftables.d/citadel-dns-strict.nft);
    then
        log_success "Składnia nftables poprawna"
    else
        log_error "Błąd w składni nftables"
        return 1
    fi

    # Load rules
    systemctl enable --now nftables 2>/dev/null || true
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns.nft

    log_success "Moduł NFTables zainstalowany"
}

firewall_safe() {
    log_section "MODULE 3: NFTables Safe Mode"
    ln -sf /etc/nftables.d/citadel-dns-safe.nft /etc/nftables.d/citadel-dns.nft
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns-safe.nft || log_warning "Nie udało się załadować reguł SAFE (sprawdź: sudo nft -c -f /etc/nftables.d/citadel-dns-safe.nft)"
    log_success "Firewall ustawiony na SAFE"
}

firewall_strict() {
    log_section "MODULE 3: NFTables Strict Mode"
    ln -sf /etc/nftables.d/citadel-dns-strict.nft /etc/nftables.d/citadel-dns.nft
    nft flush table inet citadel_dns 2>/dev/null || true
    nft flush table inet citadel_emergency 2>/dev/null || true
    nft delete table inet citadel_dns 2>/dev/null || true
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.d/citadel-dns-strict.nft || log_warning "Nie udało się załadować reguł STRICT (sprawdź: sudo nft -c -f /etc/nftables.d/citadel-dns-strict.nft)"
    log_success "Firewall ustawiony na STRICT"
}

# ==============================================================================
# MODULE 4: System Configuration
# ==============================================================================
configure_system() {
    log_section "MODULE 4: System Configuration"

    log_warning "Ten krok zmienia DNS systemu (może chwilowo przerwać internet jeśli DNS nie działa)."
    read -p "Czy na pewno chcesz kontynuować? (tak/nie): " -r
    if [[ ! $REPLY =~ ^(tak|TAK|yes|YES|y|Y)$ ]]; then
        log_info "Anulowano"
        return 0
    fi

    if command -v nft >/dev/null 2>&1 && [[ -f /etc/nftables.conf ]]; then
        firewall_safe 2>/dev/null || true
    fi

    # Disable systemd-resolved
    log_info "Wyłączanie systemd-resolved..."
    systemctl stop systemd-resolved systemd-resolved.socket 2>/dev/null || true
    systemctl disable systemd-resolved systemd-resolved.socket 2>/dev/null || true
    systemctl mask systemd-resolved 2>/dev/null || true

    # Configure NetworkManager
    log_info "Konfiguracja NetworkManager..."
    mkdir -p /etc/NetworkManager/conf.d
    tee /etc/NetworkManager/conf.d/citadel-dns.conf >/dev/null <<'EOF'
[main]
dns=none
systemd-resolved=false
EOF
    systemctl restart NetworkManager 2>/dev/null || true

    # Lock resolv.conf
    log_info "Blokowanie /etc/resolv.conf..."
    chattr -i /etc/resolv.conf 2>/dev/null || true
    tee /etc/resolv.conf >/dev/null <<'EOF'
# Citadel++ DNS Configuration
nameserver 127.0.0.1
options edns0 trust-ad
EOF
    chattr +i /etc/resolv.conf 2>/dev/null || true

    log_info "Test lokalnego DNS po przełączeniu..."
    if command -v dig >/dev/null 2>&1 && dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
        log_success "DNS działa (localhost)"
        if command -v nft >/dev/null 2>&1 && [[ -f /etc/nftables.conf ]]; then
            log_info "Włączam firewall STRICT (pełna blokada DNS-leak)..."
            firewall_strict 2>/dev/null || true
        fi
    else
        log_warning "Test DNS nieudany - zostawiam firewall SAFE"
        log_warning "Rollback: sudo ./citadela++.sh restore-system"
    fi

    log_success "Konfiguracja systemowa zakończona"
}

 restore_system() {
     log_section "MODULE 4: Restore System DNS"

     chattr -i /etc/resolv.conf 2>/dev/null || true

     systemctl unmask systemd-resolved 2>/dev/null || true
     systemctl enable --now systemd-resolved systemd-resolved.socket 2>/dev/null || true

     rm -f /etc/NetworkManager/conf.d/citadel-dns.conf 2>/dev/null || true
     systemctl restart NetworkManager 2>/dev/null || true

     if [[ -e /run/systemd/resolve/stub-resolv.conf ]]; then
         ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
     fi

     log_success "Przywrócono systemd-resolved i ustawienia DNS"
 }

# ==============================================================================
# FULL INSTALLATION
# ==============================================================================
install_all() {
    log_section "CITADEL++ FULL INSTALLATION"

    install_dnscrypt
    install_coredns
    install_nftables

    echo ""
    log_section "🎉 INSTALACJA ZAKOŃCZONA POMYŚLNIE"

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  CITADEL++ v3.0 - FULLY OPERATIONAL                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Status check
    log_info "Status serwisów:"
    systemctl --no-pager status dnscrypt-proxy coredns nftables || true

    echo ""
    log_section "🧪 HEALTHCHECK: DNS + ADBLOCK"
    adblock_rebuild 2>/dev/null || true
    systemctl restart coredns 2>/dev/null || true
    sleep 1
    adblock_stats 2>/dev/null || true

    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 >/dev/null 2>&1; then
            echo "  󰄬 DNS (google.com) via 127.0.0.1: OK"
        else
            echo "  ✗ DNS (google.com) via 127.0.0.1: FAILED"
        fi

        local test_domain
        test_domain="$(awk 'NF>=2 {print $2; exit}' /etc/coredns/zones/custom.hosts 2>/dev/null || true)"
        [[ -z "$test_domain" ]] && test_domain="$(awk 'NF>=2 {print $2; exit}' /etc/coredns/zones/combined.hosts 2>/dev/null || true)"
        if [[ -z "$test_domain" ]]; then
            echo "  ⚠ Adblock test: custom.hosts/combined.hosts empty/missing"
        else
            if dig +time=2 +tries=1 +short "$test_domain" @127.0.0.1 2>/dev/null | head -n 1 | grep -qx "0.0.0.0"; then
                echo "  󰄬 Adblock test ($test_domain): BLOCKED (0.0.0.0)"
            else
                echo "  ✗ Adblock test ($test_domain): FAILED"
            fi
        fi
    else
        log_warning "Brak narzędzia 'dig' - pomijam testy DNS/Adblock"
    fi

    echo ""
    log_info "Testy diagnostyczne:"
    echo "  1. Test DNS:        dig +short google.com @127.0.0.1"
    echo "  2. Test metryki:    curl -s http://127.0.0.1:9153/metrics | grep coredns_"
    echo "  3. DNSCrypt logi:   journalctl -u dnscrypt-proxy -f"
    echo "  4. CoreDNS logi:    journalctl -u coredns -f"
    echo "  5. Firewall:        sudo nft list ruleset | grep citadel"
    echo "  6. Leak test:       dig @8.8.8.8 test.com (powinno być zablokowane)"
    echo ""

    log_info "Aby przełączyć system na Citadel++ (wyłączyć resolved):"
    echo "  sudo ./cytadela++.sh configure-system"
    log_info "Rollback (jeśli coś pójdzie źle):"
    echo "  sudo ./cytadela++.sh restore-system"
}

# ==============================================================================
# EMERGENCY MODES
# ==============================================================================
emergency_refuse() {
    log_section "⚠️  EMERGENCY REFUSE MODE"
    systemctl stop dnscrypt-proxy
    tee /etc/coredns/Corefile >/dev/null <<'EOF'
.:53 {
    errors
    refuse .
}
EOF
    systemctl restart coredns
    log_warning "DNS REFUSE MODE AKTYWNY - wszystkie zapytania odrzucane"
}

emergency_restore() {
    log_section "♻️  RESTORING NORMAL MODE"
    cp /etc/coredns/Corefile.citadel /etc/coredns/Corefile
    systemctl start dnscrypt-proxy
    systemctl restart coredns
    log_success "Normalny tryb przywrócony"
}

emergency_killswitch_on() {
    log_section "☢️  EMERGENCY KILL-SWITCH ACTIVATED"
    nft add rule inet citadel_emergency output ip daddr != 127.0.0.1 udp dport 53 drop
    nft add rule inet citadel_emergency output tcp dport 53 drop
    log_warning "Kill-switch AKTYWNY - cały ruch DNS poza localhost zablokowany"
}

emergency_killswitch_off() {
    log_section "♻️  KILL-SWITCH DEACTIVATED"
    nft delete table inet citadel_emergency 2>/dev/null || true
    nft -f /etc/nftables.conf
    log_success "Kill-switch wyłączony"
}

# ==============================================================================
# DIAGNOSTIC TOOLS
# ==============================================================================
run_diagnostics() {
    log_section "🔍 CITADEL++ DIAGNOSTICS"

    echo -e "${CYAN}Service Status:${NC}"
    systemctl status --no-pager dnscrypt-proxy coredns nftables || true

    echo -e "\n${CYAN}DNS Resolution Test:${NC}"
    dig +short whoami.cloudflare @127.0.0.1 || log_error "DNS resolution failed"

    echo -e "\n${CYAN}Prometheus Metrics:${NC}"
    curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" || log_error "Metrics unavailable"

    echo -e "\n${CYAN}DNSCrypt Activity (last 20 lines):${NC}"
    journalctl -u dnscrypt-proxy -n 20 --no-pager

    echo -e "\n${CYAN}Firewall Rules:${NC}"
    nft list ruleset | grep -A 10 citadel

    echo -e "\n${CYAN}Blocklist Stats:${NC}"
    wc -l /etc/coredns/zones/blocklist.hosts
}

verify_stack() {
    log_section "󰄬 CITADEL++ VERIFY"

    local dnscrypt_port
    local coredns_port
    dnscrypt_port="$(get_dnscrypt_listen_port || true)"
    coredns_port="$(get_coredns_listen_port || true)"
    [[ -z "$dnscrypt_port" ]] && dnscrypt_port="$DNSCRYPT_PORT_DEFAULT"
    [[ -z "$coredns_port" ]] && coredns_port="$COREDNS_PORT_DEFAULT"

    echo -e "${CYAN}Ports:${NC}"
    echo "  DNSCrypt listen: 127.0.0.1:${dnscrypt_port}"
    echo "  CoreDNS listen:  127.0.0.1:${coredns_port}"
    echo "  Metrics:         ${COREDNS_METRICS_ADDR}"

    echo -e "\n${CYAN}Services:${NC}"
    systemctl is-active --quiet dnscrypt-proxy && echo "  󰄬 dnscrypt-proxy: running" || echo "  ✗ dnscrypt-proxy: not running"
    systemctl is-active --quiet coredns && echo "  󰄬 coredns:        running" || echo "  ✗ coredns:        not running"

    echo -e "\n${CYAN}Firewall:${NC}"
    if nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "  󰄬 nftables rules: loaded (inet citadel_dns)"
    else
        echo "  ✗ nftables rules: not loaded"
    fi
    if [[ -L /etc/nftables.d/citadel-dns.nft ]]; then
        local target
        target=$(readlink -f /etc/nftables.d/citadel-dns.nft || true)
        case "$target" in
            */citadel-dns-safe.nft) echo "  Mode: SAFE" ;;
            */citadel-dns-strict.nft) echo "  Mode: STRICT" ;;
            *) echo "  Mode: unknown ($target)" ;;
        esac
    fi

    echo -e "\n${CYAN}DNS tests:${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 +short google.com @127.0.0.1 -p "$coredns_port" >/dev/null 2>&1; then
            echo "  󰄬 Local DNS OK"
        else
            echo "  ✗ Local DNS FAILED"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo -e "\n${CYAN}Metrics:${NC}"
    if command -v curl >/dev/null 2>&1 && curl -s "http://${COREDNS_METRICS_ADDR}/metrics" >/dev/null 2>&1; then
        echo "  󰄬 Prometheus endpoint OK"
    else
        echo "  ✗ Prometheus endpoint FAILED"
    fi
}

test_all() {
    log_section "🧪 CITADEL++ TEST-ALL"

    verify_stack

    echo ""
    echo -e "${CYAN}Leak test (STRICT expected to block):${NC}"
    if command -v dig >/dev/null 2>&1; then
        if dig +time=2 +tries=1 @1.1.1.1 test.com >/dev/null 2>&1; then
            echo "  ✗ Leak test: NOT blocked (dig @1.1.1.1 succeeded)"
        else
            echo "  󰄬 Leak test: blocked/time-out (expected in STRICT)"
        fi
    else
        echo "  (dig not installed)"
    fi

    echo ""
    echo -e "${CYAN}IPv6 test:${NC}"
    if command -v ping6 >/dev/null 2>&1; then
        if ping6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
            echo "  󰄬 IPv6 connectivity OK"
        else
            echo "  ⚠ IPv6 connectivity FAILED"
        fi
    else
        echo "  (ping6 not installed)"
    fi
}

# ==============================================================================
# NEW FEATURES MODULE 5: Smart IPv6 Detection
# ==============================================================================
smart_ipv6_detection() {
    log_section "🔍 SMART IPv6 DETECTION & AUTO-RECONFIGURATION"
    
    # Detect IPv6 connectivity
    log_info "Sprawdzanie łączności IPv6..."
    IPV6_AVAILABLE=false
    
    if ip -6 route get 2001:4860:4860::8888 >/dev/null 2>&1; then
        IPV6_AVAILABLE=true
        log_success "IPv6 dostępny"
    elif (command -v ping >/dev/null 2>&1 && ping -6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1) || (command -v ping6 >/dev/null 2>&1 && ping6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1); then
        IPV6_AVAILABLE=true
        log_success "IPv6 dostępny"
    else
        log_warning "IPv6 niedostępny - konfiguruję tylko IPv4"
    fi
    
    # Auto-reconfigure DNSCrypt based on IPv6 availability (do not touch listen_addresses/ports)
    local dnscrypt_config="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    local coredns_corefile="/etc/coredns/Corefile"

    if [[ -f "$dnscrypt_config" ]]; then
        log_info "Aktualizacja konfiguracji DNSCrypt dla IPv6..."

        if grep -qE '^ipv6_servers[[:space:]]*=' "$dnscrypt_config"; then
            if [[ "$IPV6_AVAILABLE" == "true" ]]; then
                sed -i 's/^ipv6_servers[[:space:]]*=.*$/ipv6_servers = true/' "$dnscrypt_config"
                log_success "ipv6_servers = true"
            else
                sed -i 's/^ipv6_servers[[:space:]]*=.*$/ipv6_servers = false/' "$dnscrypt_config"
                log_success "ipv6_servers = false"
            fi
        else
            if [[ "$IPV6_AVAILABLE" == "true" ]]; then
                printf '\nipv6_servers = true\n' >> "$dnscrypt_config"
                log_success "Dodano ipv6_servers = true"
            else
                printf '\nipv6_servers = false\n' >> "$dnscrypt_config"
                log_success "Dodano ipv6_servers = false"
            fi
        fi

        systemctl is-active --quiet dnscrypt-proxy && systemctl restart dnscrypt-proxy
    fi

    if [[ -f "$coredns_corefile" ]]; then
        log_info "Aktualizacja konfiguracji CoreDNS dla IPv6..."

        sed -i '/^[[:space:]]*template[[:space:]]\+IN[[:space:]]\+AAAA[[:space:]]*{/,/^[[:space:]]*}[[:space:]]*$/d' "$coredns_corefile" || true

        if [[ "$IPV6_AVAILABLE" != "true" ]]; then
            awk '
                BEGIN{added=0}
                /^[[:space:]]*forward[[:space:]]+\.[[:space:]]+/ {
                    if (added==0) {
                        print "    template IN AAAA {"
                        print "        rcode NXDOMAIN"
                        print "    }"
                        added=1
                    }
                }
                { print }
            ' "$coredns_corefile" > "${coredns_corefile}.citadel.tmp" && mv "${coredns_corefile}.citadel.tmp" "$coredns_corefile"
        fi

        systemctl is-active --quiet coredns && systemctl restart coredns
    fi
    
    echo "IPv6 Status: $IPV6_AVAILABLE"
}

ipv6_privacy_on() {
    local sysctl_file="/etc/sysctl.d/40-citadel-ipv6-privacy.conf"

    log_section "󰌾 IPV6 PRIVACY EXTENSIONS"
    log_info "Włączanie IPv6 Privacy Extensions (prefer temporary addresses)..."

    sudo tee "$sysctl_file" >/dev/null <<'EOF'
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
EOF

    sudo sysctl --system >/dev/null 2>&1 || true
    ipv6_privacy_status
}

ipv6_privacy_off() {
    local sysctl_file="/etc/sysctl.d/40-citadel-ipv6-privacy.conf"

    log_section "󰌿 IPV6 PRIVACY EXTENSIONS"
    log_info "Wyłączanie IPv6 Privacy Extensions..."

    sudo tee "$sysctl_file" >/dev/null <<'EOF'
net.ipv6.conf.all.use_tempaddr = 0
net.ipv6.conf.default.use_tempaddr = 0
EOF

    sudo sysctl --system >/dev/null 2>&1 || true
    ipv6_privacy_status
}

ipv6_privacy_status() {
    log_section "🔎 IPV6 PRIVACY EXTENSIONS STATUS"

    echo "net.ipv6.conf.all.use_tempaddr = $(sysctl -n net.ipv6.conf.all.use_tempaddr 2>/dev/null || echo '?')"
    echo "net.ipv6.conf.default.use_tempaddr = $(sysctl -n net.ipv6.conf.default.use_tempaddr 2>/dev/null || echo '?')"
    echo ""
    echo "Adresy IPv6 (global/temporary):"
    ip -6 addr show scope global 2>/dev/null | sed -n '1,120p' || true
}

# ==============================================================================
# NEW FEATURES MODULE 6: Terminal Dashboard
# ==============================================================================
install_citadel_top() {
    log_section "📊 TERMINAL DASHBOARD INSTALLATION"

    require_cmds curl jq systemctl || return 1
    if ! command -v pacman >/dev/null 2>&1; then
        log_warning "Brak pacman - pomijam instalację zależności dla dashboard"
        return 1
    fi
    
    # Install dependencies
    log_info "Instalowanie zależności dla dashboard..."
    pacman -Q curl jq >/dev/null || sudo pacman -S curl jq --noconfirm
    
    # Create citadel-top script
    sudo tee /usr/local/bin/citadel-top >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Terminal Dashboard v1.0

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    CITADEL++ DASHBOARD                        ║"
echo "║                   Real-time DNS Monitor                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    CITADEL++ DASHBOARD                        ║"
    echo "║                   $(date '+%Y-%m-%d %H:%M:%S')                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "🔥 SERVICE STATUS:"
    systemctl is-active dnscrypt-proxy >/dev/null && echo "󰄬 DNSCrypt-Proxy: RUNNING" || echo "✗ DNSCrypt-Proxy: STOPPED"
    systemctl is-active coredns >/dev/null && echo "󰄬 CoreDNS: RUNNING" || echo "✗ CoreDNS: STOPPED"
    if sudo -n nft list table inet citadel_dns >/dev/null 2>&1; then
        echo "󰄬 NFTables: RULES LOADED"
    else
        systemctl is-active nftables >/dev/null && echo "󰄬 NFTables: RUNNING" || echo "✗ NFTables: STOPPED"
    fi
    echo ""
    
    echo "📊 PROMETHEUS METRICS:"
    if curl -s http://127.0.0.1:9153/metrics >/dev/null 2>&1; then
        QUERIES=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" | tail -1 | awk '{print $2}')
        CACHE_HITS=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_cache_hits_total" | tail -1 | awk '{print $2}')
        echo "  Total Queries: ${QUERIES:-0}"
        echo "  Cache Hits: ${CACHE_HITS:-0}"
    else
        echo "  Metrics unavailable"
    fi
    echo ""
    
    echo "🌐 NETWORK STATUS:"
    echo "  DNS Resolution: $(dig +short google.com @127.0.0.1 -p ${COREDNS_PORT} 2>/dev/null | head -1 || echo "FAILED")"
    echo "  External IP: $(curl -s https://api.ipify.org 2>/dev/null || echo "UNKNOWN")"
    echo ""
    
    echo "⚡ PERFORMANCE:"
    if command -v ss >/dev/null; then
        DNS_CONNECTIONS=$(ss -tn | grep :53 | wc -l)
        echo "  Active DNS Connections: $DNS_CONNECTIONS"
    fi
    echo ""
    
    echo "🔥 SYSTEM LOAD:"
    echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
    echo "  Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
    echo ""
    
    echo "Press Ctrl+C to exit | Refresh: 5s"
    sleep 5
done
EOF
    
    sudo chmod +x /usr/local/bin/citadel-top
    log_success "Dashboard zainstalowany: uruchom 'citadel-top'"
}

# ==============================================================================
# NEW FEATURES MODULE 7: Editor Integration
# ==============================================================================
install_editor_integration() {
    log_section "✏️ EDITOR INTEGRATION SETUP"

    if ! command -v yay >/dev/null 2>&1; then
        log_warning "Brak yay - nie mogę automatycznie zainstalować micro"
        return 1
    fi
    
    # Install micro editor
    if ! command -v micro >/dev/null; then
        log_info "Instalowanie edytora micro..."
        yay -S micro --noconfirm
    fi
    
    # Create citadel edit command
    sudo tee /usr/local/bin/citadel >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Editor Integration v1.0

ACTION=${1:-help}
CONFIG_DIR="/etc/coredns"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

case "$ACTION" in
    edit)
        echo "📝 Opening Citadel++ configuration in micro editor..."
        sudo micro "$CONFIG_DIR/Corefile"
        echo "󰜝 Restarting CoreDNS..."
        sudo systemctl restart coredns
        echo "󰄬 CoreDNS reloaded with new configuration"
        ;;
    edit-dnscrypt)
        echo "📝 Opening DNSCrypt configuration..."
        sudo micro "$DNSCRYPT_CONFIG"
        echo "󰜝 Restarting DNSCrypt..."
        sudo systemctl restart dnscrypt-proxy
        echo "󰄬 DNSCrypt reloaded with new configuration"
        ;;
    status)
        echo "📊 Citadel++ Status:"
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    logs)
        echo "󰓍 Recent logs:"
        journalctl -u dnscrypt-proxy -u coredns -n 20 --no-pager
        ;;
    test)
        echo "🧪 Testing DNS resolution..."
        dig +short whoami.cloudflare @127.0.0.1 || echo "❌ DNS test failed"
        ;;
    help|--help|-h)
        cat <<HELP
Citadel++ Editor Integration

Commands:
  citadel edit         Edit CoreDNS config and auto-restart
  citadel edit-dnscrypt Edit DNSCrypt config and auto-restart  
  citadel status       Show service status
  citadel logs         Show recent logs
  citadel test         Test DNS resolution
  citadel help         Show this help

Examples:
  citadel edit         # Edit CoreDNS configuration
  citadel edit-dnscrypt # Edit DNSCrypt configuration
HELP
        ;;
    *)
        echo "Unknown command. Use 'citadel help' for usage."
        exit 1
        ;;
esac
EOF
    
    sudo chmod +x /usr/local/bin/citadel
    log_success "Editor integration zainstalowany: użyj 'citadel edit'"
}

# ==============================================================================
# NEW FEATURES MODULE 8: Kernel Priority Optimization
# ==============================================================================
optimize_kernel_priority() {
    log_section "⚡ KERNEL PRIORITY OPTIMIZATION"
    
    # Check if running on CachyOS/Arch
    if [[ ! -f /etc/arch-release ]]; then
        log_warning "Ta funkcja jest zoptymalizowana dla CachyOS/Arch Linux"
        return 1
    fi
    
    # Create systemd service for DNS priority optimization
    sudo tee /etc/systemd/system/citadel-dns-priority.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Optimization
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '
renice -10 $(pgrep dnscrypt-proxy) 2>/dev/null || true
renice -10 $(pgrep coredns) 2>/dev/null || true
ionice -c 2 -n 0 $(pgrep dnscrypt-proxy) 2>/dev/null || true
ionice -c 2 -n 0 $(pgrep coredns) 2>/dev/null || true
logger "Citadel++: Applied priority tuning to DNS processes"
'
EOF

    sudo tee /etc/systemd/system/citadel-dns-priority.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Timer
Requires=citadel-dns-priority.service

[Timer]
OnCalendar=minutely
Persistent=true

[Install]
WantedBy=timers.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now citadel-dns-priority.timer
    
    # Apply immediately
    sudo systemctl start citadel-dns-priority.service
    
    log_success "Kernel priority optimization aktywny"
}

# ==============================================================================
# NEW FEATURES MODULE 9: DNS-over-HTTPS Parallel Racing
# ==============================================================================
install_doh_parallel() {
    log_section "󱓞 DNS-OVER-HTTPS PARALLEL RACING"
    
    # Create advanced DNSCrypt config with DoH parallel racing
    sudo tee /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml >/dev/null <<'EOF'
# Citadel++ DNSCrypt with DoH Parallel Racing
listen_addresses = ['127.0.0.1:5353', '[::1]:5353']
user_name = 'dnscrypt'

# Enable parallel racing for faster responses
server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

# DoH servers with parallel racing
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = false

# Parallel racing configuration
lb_strategy = 'p2'  # Power of Two load balancing
lb_estimator = true

# Performance tuning
max_clients = 500
cache_size = 1024
cache_min_ttl = 300
cache_max_ttl = 86400
timeout = 3000
keepalive = 30

# Bootstrap resolvers
bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53', '149.112.112.112:53']
ignore_system_dns = true

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    log_success "Konfiguracja DoH Parallel Racing gotowa"
    log_info "Aby aktywować: sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml"
}

# ==============================================================================
# PORT CONFLICT RESOLUTION
# ==============================================================================
fix_port_conflicts() {
    log_section "󰊠 PORT CONFLICT RESOLUTION"
    
    log_info "Sprawdzanie konfliktów portów..."
    
    # Check what's using port 53
    echo "Procesy używające portu 53:"
    sudo ss -tulpn | grep :53
    
    echo ""
    log_info "Opcje naprawy:"
    echo "1. Zatrzymaj avahi: sudo systemctl stop avahi-daemon"
    echo "2. Zabij chromium procesy: pkill chromium"
    echo "3. Użyj alternatywnego portu dla CoreDNS"
    
    # Option to use different port for CoreDNS
    read -p "Czy zmienić port CoreDNS na 5354? (tak/nie): " -r
    if [[ $REPLY =~ ^(tak|TAK|yes|YES|y|Y)$ ]]; then
        log_info "Zmieniam port CoreDNS na 5354..."
        sudo sed -i 's/.:53 {/.:5354 {/g' /etc/coredns/Corefile
        sudo systemctl restart coredns
        log_success "CoreDNS działa na porcie 5354"
        log_info "Test: dig +short whoami.cloudflare @127.0.0.1 -p 5354"
    fi
}

# ==============================================================================
# HELP & USAGE
# ==============================================================================
show_help() {
    cat <<EOF

${BLUE}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${BLUE}║                  CITADEL++ v3.0 - Command Reference                       ║${NC}
${BLUE}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Installation Commands (BEZPIECZNE):${NC}
  install-dnscrypt      Install DNSCrypt-Proxy only
  install-coredns       Install CoreDNS only
  install-nftables      Install NFTables rules only
  install-all           Install all DNS modules (NIE wyłącza systemd-resolved)

${CYAN}DNSSEC (opcjonalnie):${NC}
  CITADEL_DNSSEC=1       Wygeneruj DNSCrypt z require_dnssec = true
  --dnssec               Alternatywnie: dodaj flagę przy install-dnscrypt/install-all

${YELLOW}NEW FEATURES v3.0:${NC}
  smart-ipv6           Smart IPv6 detection & auto-reconfiguration
  ipv6-privacy-on      Włącz IPv6 Privacy Extensions (prefer temporary)
  ipv6-privacy-off     Wyłącz IPv6 Privacy Extensions
  ipv6-privacy-status  Pokaż status IPv6 Privacy Extensions
  ipv6-privacy-auto    Auto-ensure IPv6 privacy (detect + fix if needed)
  discover             Network & firewall sanity snapshot (Issue #10)
  install-dashboard    Install terminal dashboard (citadel-top)
  install-editor       Install editor integration (citadel edit)
  optimize-kernel      Apply real-time priority for DNS processes
  install-doh-parallel Install DNS-over-HTTPS parallel racing
  fix-ports            Resolve port conflicts with avahi/chromium

${YELLOW}System Configuration (UWAGA - wyłącza systemd-resolved):${NC}
  configure-system      Przełącz system na Citadel++ DNS (z potwierdzeniem)
  restore-system        Przywróć systemd-resolved + DNS (rollback)

${CYAN}Emergency Commands:${NC}
  emergency-refuse      Refuse all DNS queries (emergency mode)
  emergency-restore     Restore normal operation
  killswitch-on         Activate DNS kill-switch (block all non-localhost)
  killswitch-off        Deactivate kill-switch

${RED}Panic Bypass (SPOF recovery):${NC}
  panic-bypass [secs]   Disable protection + auto-rollback (default 300s)
  panic-restore         Manually restore protected mode
  panic-status          Show panic mode status

${YELLOW}LKG (Last Known Good):${NC}
  lkg-save              Save current blocklist to cache
  lkg-restore           Restore blocklist from cache
  lkg-status            Show LKG cache status
  lists-update          Update blocklist with LKG fallback

${CYAN}Diagnostic Commands:${NC}
  diagnostics           Run full system diagnostics
  status                Show service status
  verify                Verify full stack (ports/services/DNS/NFT/metrics)
  ghost-check           Port exposure audit (warn about 0.0.0.0/::)
  ipv6-deep-reset       Flush IPv6 + neighbor cache + reconnect
  test-all              Smoke test (verify + leak test + IPv6)

${GREEN}Health Watchdog:${NC}
  health-status         Show health status (services, DNS probe, firewall)
  health-install        Install auto-restart + health check timer
  health-uninstall      Remove health watchdog

${GREEN}Supply-Chain Verification:${NC}
  supply-chain-status   Show checksums file status
  supply-chain-init     Initialize checksums for known assets
  supply-chain-verify   Verify local files against manifest

${CYAN}Location-Aware Advisory:${NC}
  location-status       Show current SSID, trust status, firewall mode
  location-check        Check and advise on firewall mode
  location-add-trusted  Add SSID to trusted list (or current if no arg)
  location-remove-trusted Remove SSID from trusted list
  location-list-trusted List all trusted SSIDs

${CYAN}NFT Debug Chain:${NC}
  nft-debug-on          Enable debug chain with rate-limited logging
  nft-debug-off         Disable debug chain
  nft-debug-status      Show debug chain status and counters
  nft-debug-logs        Show recent CITADEL log entries

${YELLOW}Integrity (Local-First):${NC}
  integrity-init        Create integrity manifest for scripts/binaries
  integrity-check       Verify integrity against manifest
  integrity-status      Show integrity mode and manifest info
  --dev                 Run in developer mode (relaxed integrity checks)

${CYAN}Firewall Modes:${NC}
  firewall-safe         Ustaw reguły SAFE (nie zrywa internetu)
  firewall-strict       Ustaw reguły STRICT (blokuje DNS-leaks)

${GREEN}Rekomendowany workflow:${NC}
  ${CYAN}1.${NC} sudo ./citadel++.sh install-all
  ${CYAN}2.${NC} sudo ./citadel++.sh firewall-safe         ${YELLOW}# SAFE: nie zrywa internetu${NC}
  ${CYAN}3.${NC} dig +short google.com @127.0.0.1          ${YELLOW}# Test lokalnego DNS${NC}
  ${CYAN}4.${NC} sudo ./citadel++.sh configure-system       ${YELLOW}# Przełączenie systemu${NC}
  ${CYAN}5.${NC} ping -c 3 google.com                      ${YELLOW}# Test internetu${NC}
  ${CYAN}6.${NC} sudo ./citadel++.sh firewall-strict        ${YELLOW}# STRICT: pełna blokada DNS-leak${NC}

${GREEN}Nowe narzędzia v3.0${CYAN}Tools:${NC}
  citadel-top           Real-time terminal dashboard
  citadel edit          Editor with auto-restart
  citadel status        Quick status check

${CYAN}Adblock Panel (DNS):${NC}
  adblock-status        Show adblock/CoreDNS integration status
  adblock-stats         Show counts of custom/blocklist/combined
  adblock-show          Show: custom|blocklist|combined (first 200 lines)
  adblock-edit          Edit /etc/coredns/zones/custom.hosts and reload
  adblock-add           Add domain to custom.hosts (0.0.0.0 domain)
  adblock-remove        Remove domain from custom.hosts
  adblock-rebuild       Rebuild combined.hosts from custom+blocklist and reload
  adblock-query         Query a domain via local DNS (127.0.0.1)

${CYAN}Advanced Configuration:${NC}
  DNSCrypt config:      /etc/dnscrypt-proxy/dnscrypt-proxy.toml
  DNSCrypt DoH config:  /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml
  CoreDNS config:       /etc/coredns/Corefile
  NFTables rules:       /etc/nftables.d/citadel-dns.nft

${CYAN}Dokumentacja:${NC}
  Notes:               /home/qguar/Cytadela/CITADEL++_NOTES.md

EOF
}

# ==============================================================================
# NEW FEATURES MODULE 5: Smart IPv6 Detection
# ==============================================================================
smart_ipv6_detection() {
    log_section "🔍 SMART IPv6 DETECTION & AUTO-RECONFIGURATION"
    
    # Detect IPv6 connectivity
    log_info "Sprawdzanie łączności IPv6..."
    IPV6_AVAILABLE=false
    
    if ip -6 route get 2001:4860:4860::8888 >/dev/null 2>&1; then
        IPV6_AVAILABLE=true
        log_success "IPv6 dostępny"
    elif (command -v ping >/dev/null 2>&1 && ping -6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1) || (command -v ping6 >/dev/null 2>&1 && ping6 -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1); then
        IPV6_AVAILABLE=true
        log_success "IPv6 dostępny"
    else
        log_warning "IPv6 niedostępny - konfiguruję tylko IPv4"
    fi
    
    # Auto-reconfigure DNSCrypt based on IPv6 availability
    # NOTE: do not touch listen_addresses/ports here to avoid breaking custom configs.
    local dnscrypt_config="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    local coredns_corefile="/etc/coredns/Corefile"

    if [[ -f "$dnscrypt_config" ]]; then
        log_info "Aktualizacja konfiguracji DNSCrypt dla IPv6..."

        if grep -qE '^ipv6_servers[[:space:]]*=' "$dnscrypt_config"; then
            if [[ "$IPV6_AVAILABLE" == "true" ]]; then
                sed -i 's/^ipv6_servers[[:space:]]*=.*$/ipv6_servers = true/' "$dnscrypt_config"
                log_success "ipv6_servers = true"
            else
                sed -i 's/^ipv6_servers[[:space:]]*=.*$/ipv6_servers = false/' "$dnscrypt_config"
                log_success "ipv6_servers = false"
            fi
        else
            if [[ "$IPV6_AVAILABLE" == "true" ]]; then
                printf '\nipv6_servers = true\n' >> "$dnscrypt_config"
                log_success "Dodano ipv6_servers = true"
            else
                printf '\nipv6_servers = false\n' >> "$dnscrypt_config"
                log_success "Dodano ipv6_servers = false"
            fi
        fi

        systemctl is-active --quiet dnscrypt-proxy && systemctl restart dnscrypt-proxy
    fi

    if [[ -f "$coredns_corefile" ]]; then
        log_info "Aktualizacja konfiguracji CoreDNS dla IPv6..."

        sed -i '/^[[:space:]]*template[[:space:]]\+IN[[:space:]]\+AAAA[[:space:]]*{/,/^[[:space:]]*}[[:space:]]*$/d' "$coredns_corefile" || true

        if [[ "$IPV6_AVAILABLE" != "true" ]]; then
            awk '
                BEGIN{added=0}
                /^[[:space:]]*forward[[:space:]]+\.[[:space:]]+/ {
                    if (added==0) {
                        print "    template IN AAAA {"
                        print "        rcode NXDOMAIN"
                        print "    }"
                        added=1
                    }
                }
                { print }
            ' "$coredns_corefile" > "${coredns_corefile}.citadel.tmp" && mv "${coredns_corefile}.citadel.tmp" "$coredns_corefile"
        fi

        systemctl is-active --quiet coredns && systemctl restart coredns
    fi

    echo "IPv6 Status: $IPV6_AVAILABLE"
}

# ==============================================================================
# NEW FEATURES MODULE 6: Terminal Dashboard
# ==============================================================================
install_citadel_top() {
    log_section "📊 TERMINAL DASHBOARD INSTALLATION"

    require_cmds curl jq systemctl || return 1
    if ! command -v pacman >/dev/null 2>&1; then
        log_warning "Brak pacman - pomijam instalację zależności dla dashboard"
        return 1
    fi
    
    # Install dependencies
    log_info "Instalowanie zależności dla dashboard..."
    pacman -Q curl jq >/dev/null || sudo pacman -S curl jq --noconfirm
    
    # Create citadel-top script
    tee /usr/local/bin/citadel-top >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Terminal Dashboard v1.0

COREDNS_PORT=53
if [[ -f /etc/coredns/Corefile ]]; then
  p=$(awk -F'[:}]' '/^\.:/{gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' /etc/coredns/Corefile 2>/dev/null)
  if [[ -n "$p" ]]; then
    COREDNS_PORT="$p"
  fi
fi

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    CITADEL++ DASHBOARD                        ║"
echo "║                   Real-time DNS Monitor                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    CITADEL++ DASHBOARD                        ║"
    echo "║                   $(date '+%Y-%m-%d %H:%M:%S')                    ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "🔥 SERVICE STATUS:"
    systemctl is-active dnscrypt-proxy >/dev/null && echo "󰄬 DNSCrypt-Proxy: RUNNING" || echo "✗ DNSCrypt-Proxy: STOPPED"
    systemctl is-active coredns >/dev/null && echo "󰄬 CoreDNS: RUNNING" || echo "✗ CoreDNS: STOPPED"
    systemctl is-active nftables >/dev/null && echo "󰄬 NFTables: RUNNING" || echo "✗ NFTables: STOPPED"
    echo ""
    
    echo "📊 PROMETHEUS METRICS:"
    if curl -s http://127.0.0.1:9153/metrics >/dev/null 2>&1; then
        QUERIES=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_dns_request_count_total" | tail -1 | awk '{print $2}')
        CACHE_HITS=$(curl -s http://127.0.0.1:9153/metrics | grep "coredns_cache_hits_total" | tail -1 | awk '{print $2}')
        echo "  Total Queries: ${QUERIES:-0}"
        echo "  Cache Hits: ${CACHE_HITS:-0}"
    else
        echo "  Metrics unavailable"
    fi
    echo ""
    
    echo "🌐 NETWORK STATUS:"
    echo "  DNS Resolution: $(dig +short google.com @127.0.0.1 -p ${COREDNS_PORT} 2>/dev/null | head -1 || echo "FAILED")"
    echo "  External IP: $(curl -s https://api.ipify.org 2>/dev/null || echo "UNKNOWN")"
    echo ""
    
    echo "⚡ PERFORMANCE:"
    if command -v ss >/dev/null; then
        DNS_CONNECTIONS=$(ss -tn | grep :53 | wc -l)
        echo "  Active DNS Connections: $DNS_CONNECTIONS"
    fi
    echo ""
    
    echo "🔥 SYSTEM LOAD:"
    echo "  CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
    echo "  Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
    echo ""
    
    echo "Press Ctrl+C to exit | Refresh: 5s"
    sleep 5
done
EOF
    
    chmod +x /usr/local/bin/citadel-top
    log_success "Dashboard zainstalowany: uruchom 'citadel-top'"
}

# ==============================================================================
# NEW FEATURES MODULE 7: Editor Integration
# ==============================================================================
install_editor_integration() {
    log_section "✏️ EDITOR INTEGRATION SETUP"
    
    # Install micro editor
    if ! command -v micro >/dev/null; then
        log_info "Instalowanie edytora micro..."
        yay -S micro --noconfirm
    fi
    
    # Create citadel edit command
    tee /usr/local/bin/citadel >/dev/null <<'EOF'
#!/bin/bash
# Citadel++ Editor Integration v1.0

ACTION=${1:-help}
CONFIG_DIR="/etc/coredns"
DNSCRYPT_CONFIG="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"

case "$ACTION" in
    edit)
        echo "📝 Opening Citadel++ configuration in micro editor..."
        micro "$CONFIG_DIR/Corefile"
        echo "󰜝 Restarting CoreDNS..."
        sudo systemctl restart coredns
        echo "󰄬 CoreDNS reloaded with new configuration"
        ;;
    edit-dnscrypt)
        echo "📝 Opening DNSCrypt configuration..."
        sudo micro "$DNSCRYPT_CONFIG"
        echo "󰜝 Restarting DNSCrypt..."
        sudo systemctl restart dnscrypt-proxy
        echo "󰄬 DNSCrypt reloaded with new configuration"
        ;;
    status)
        echo "📊 Citadel++ Status:"
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    logs)
        echo "󰓍 Recent logs:"
        journalctl -u dnscrypt-proxy -u coredns -n 20 --no-pager
        ;;
    test)
        echo "🧪 Testing DNS resolution..."
        dig +short whoami.cloudflare @127.0.0.1 || echo "❌ DNS test failed"
        ;;
    help|--help|-h)
        cat <<HELP
Citadel++ Editor Integration

Commands:
  citadel edit         Edit CoreDNS config and auto-restart
  citadel edit-dnscrypt Edit DNSCrypt config and auto-restart  
  citadel status       Show service status
  citadel logs         Show recent logs
  citadel test         Test DNS resolution
  citadel help         Show this help

Examples:
  citadel edit         # Edit CoreDNS configuration
  citadel edit-dnscrypt # Edit DNSCrypt configuration
HELP
        ;;
    *)
        echo "Unknown command. Use 'citadel help' for usage."
        exit 1
        ;;
esac
EOF
    
    chmod +x /usr/local/bin/citadel
    log_success "Editor integration zainstalowany: użyj 'citadel edit'"
}

# ==============================================================================
# NEW FEATURES MODULE 8: Kernel Priority Optimization
# ==============================================================================
optimize_kernel_priority() {
    log_section "⚡ KERNEL PRIORITY OPTIMIZATION"
    
    # Check if running on CachyOS/Arch
    if [[ ! -f /etc/arch-release ]]; then
        log_warning "Ta funkcja jest zoptymalizowana dla CachyOS/Arch Linux"
        return 1
    fi
    
    # Create systemd service for DNS priority optimization
    tee /etc/systemd/system/citadel-dns-priority.service >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Optimization
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'renice -10 $(pgrep coredns) 2>/dev/null || true; ionice -c 2 -n 0 $(pgrep coredns) 2>/dev/null || true; logger "Citadel++: Applied priority tuning to DNS processes"'
EOF

    tee /etc/systemd/system/citadel-dns-priority.timer >/dev/null <<'EOF'
[Unit]
Description=Citadel++ DNS Priority Timer
Requires=citadel-dns-priority.service

[Timer]
OnCalendar=minutely
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable --now citadel-dns-priority.timer
    
    # Apply immediately
    systemctl start citadel-dns-priority.service
    
    log_success "Kernel priority optimization aktywny"
}

# ==============================================================================
# NEW FEATURES MODULE 9: DNS-over-HTTPS Parallel Racing
# ==============================================================================
install_doh_parallel() {
    log_section "󱓞 DNS-OVER-HTTPS PARALLEL RACING"
    
    # Create advanced DNSCrypt config with DoH parallel racing
    tee /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml >/dev/null <<'EOF'
# Citadel++ DNSCrypt with DoH Parallel Racing
listen_addresses = ['127.0.0.1:5353']
user_name = 'dnscrypt'

# Enable parallel racing for faster responses
server_names = ['cloudflare', 'google', 'quad9-dnscrypt-ip4-filter-pri']

# DoH servers with parallel racing
doh_servers = true
require_dnssec = true
require_nolog = true
require_nofilter = false

# Parallel racing configuration
lb_strategy = 'p2'  # Power of Two load balancing
lb_estimator = true

# Performance tuning
max_clients = 500
cache_size = 1024
cache_min_ttl = 300
cache_max_ttl = 86400
timeout = 3000
keepalive = 30

# Bootstrap resolvers
bootstrap_resolvers = ['9.9.9.9:53', '1.1.1.1:53', '149.112.112.112:53']
ignore_system_dns = true

log_level = 2
log_file = '/var/log/dnscrypt-proxy/dnscrypt-proxy.log'
EOF

    log_success "Konfiguracja DoH Parallel Racing gotowa"
    log_info "Aby aktywować: sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy-doh.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml"
}

# ==============================================================================
# SAFE MODE - Test without breaking internet
# ==============================================================================
safe_test_mode() {
    log_section "🧪 SAFE TEST MODE"
    
    log_info "Uruchamiam testy bez przerywania internetu..."
    
    # Test 1: Check dependencies
    log_info "Sprawdzanie zależności..."
    for cmd in dnscrypt-proxy coredns nftables; do
        if command -v "$cmd" >/dev/null; then
            echo "󰄬 $cmd dostępny"
        else
            echo "✗ $cmd nieznaleziony"
        fi
    done
    
    # Test 2: Validate configurations
    log_info "Walidacja konfiguracji..."
    if [[ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]; then
        if dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check >/dev/null 2>&1; then
            echo "󰄬 DNSCrypt config poprawny"
        else
            echo "✗ DNSCrypt config błędny"
        fi
    fi
    
    # Test 3: Check ports
    log_info "Sprawdzanie portów..."
    if ss -ln | grep -q ":53"; then
        echo "⚠ Port 53 zajęty - może wymagać zatrzymania systemd-resolved"
    else
        echo "󰄬 Port 53 wolny"
    fi
    
    echo ""
    log_info "Tryb bezpieczny zakończony. Użyj 'install-all' dla pełnej instalacji"
}

# ==============================================================================
# MAIN DISPATCHER
# ==============================================================================
case "$ACTION" in
    install-dnscrypt)
        install_dnscrypt
        ;;
    install-coredns)
        install_coredns
        ;;
    install-nftables)
        install_nftables
        ;;
    firewall-safe)
        firewall_safe
        ;;
    firewall-strict)
        firewall_strict
        ;;
    adblock-status)
        adblock_status
        ;;
    adblock-stats)
        adblock_stats
        ;;
    adblock-show)
        adblock_show "$ARG1"
        ;;
    adblock-edit)
        adblock_edit
        ;;
    adblock-add)
        adblock_add "$ARG1"
        ;;
    adblock-remove)
        adblock_remove "$ARG1"
        ;;
    adblock-rebuild)
        adblock_rebuild
        adblock_reload
        log_success "Adblock rebuilt + CoreDNS reloaded"
        ;;
    adblock-query)
        adblock_query "$ARG1"
        ;;
    allowlist-list)
        allowlist_list
        ;;
    allowlist-add)
        allowlist_add "$ARG1"
        ;;
    allowlist-remove)
        allowlist_remove "$ARG1"
        ;;
    configure-system)
        configure_system
        ;;
    restore-system)
        restore_system
        ;;
    install-all)
        install_all
        ;;
    # NEW FEATURES v3.0
    smart-ipv6)
        smart_ipv6_detection
        ;;
    ipv6-privacy-on)
        ipv6_privacy_on
        ;;
    ipv6-privacy-off)
        ipv6_privacy_off
        ;;
    ipv6-privacy-status)
        ipv6_privacy_status
        ;;
    ipv6-privacy-auto)
        ipv6_privacy_auto_ensure
        ;;
    discover)
        discover
        ;;
    install-dashboard)
        install_citadel_top
        ;;
    install-editor)
        install_editor_integration
        ;;
    optimize-kernel)
        optimize_kernel_priority
        ;;
    install-doh-parallel)
        install_doh_parallel
        ;;
    fix-ports)
        fix_port_conflicts
        ;;
    safe-test)
        safe_test_mode
        ;;
    test-all)
        test_all
        ;;
    # Emergency commands
    emergency-refuse)
        emergency_refuse
        ;;
    emergency-restore)
        emergency_restore
        ;;
    killswitch-on)
        emergency_killswitch_on
        ;;
    killswitch-off)
        emergency_killswitch_off
        ;;
    # LKG (Last Known Good) commands
    lkg-save)
        lkg_save_blocklist
        ;;
    lkg-restore)
        lkg_restore_blocklist
        adblock_rebuild
        adblock_reload
        ;;
    lkg-status)
        lkg_status
        ;;
    lists-update)
        lists_update
        ;;
    # Panic bypass commands
    panic-bypass)
        panic_bypass "$ARG1"
        ;;
    panic-restore)
        panic_restore "$ARG1"
        ;;
    panic-status)
        panic_status
        ;;
    # Ghost-Check and IPv6 Deep Reset
    ghost-check)
        ghost_check
        ;;
    ipv6-deep-reset)
        ipv6_deep_reset
        ;;
    # Health checks
    health-status)
        health_status
        ;;
    health-install)
        install_health_watchdog
        ;;
    health-uninstall)
        uninstall_health_watchdog
        ;;
    # Supply-chain verification
    supply-chain-status)
        supply_chain_status
        ;;
    supply-chain-init)
        supply_chain_init
        ;;
    supply-chain-verify)
        supply_chain_verify
        ;;
    # Location-aware advisory
    location-status)
        location_status
        ;;
    location-check)
        location_check
        ;;
    location-add-trusted)
        location_add_trusted "$ARG1"
        ;;
    location-remove-trusted)
        location_remove_trusted "$ARG1"
        ;;
    location-list-trusted)
        location_list_trusted
        ;;
    # NFT debug chain
    nft-debug-on)
        nft_debug_on
        ;;
    nft-debug-off)
        nft_debug_off
        ;;
    nft-debug-status)
        nft_debug_status
        ;;
    nft-debug-logs)
        nft_debug_logs
        ;;
    # Diagnostic commands
    diagnostics)
        run_diagnostics
        ;;
    verify)
        verify_stack
        ;;
    status)
        systemctl status --no-pager dnscrypt-proxy coredns nftables
        ;;
    # Integrity commands (Local-First)
    integrity-init)
        integrity_init
        ;;
    integrity-check)
        integrity_check ""
        ;;
    integrity-status)
        integrity_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
