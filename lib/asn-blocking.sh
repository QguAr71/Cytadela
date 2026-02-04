#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3.0 - ASN BLOCKING SYSTEM                                  ║
# ║  Block entire Autonomous Systems (networks) for enhanced security      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

ASN_BLOCKLIST="/etc/cytadela/asn-blocklist.txt"
ASN_CACHE_DIR="/var/lib/cytadela/asn-cache"
ASN_WHOIS_SERVER="whois.radb.net"
ASN_CACHE_TTL="86400"  # 24 hours in seconds

# ==============================================================================
# DATABASE MANAGEMENT
# ==============================================================================

# Initialize ASN blocking system
asn_init() {
    mkdir -p "$(dirname "$ASN_BLOCKLIST")"
    mkdir -p "$ASN_CACHE_DIR"

    # Create default blocklist if it doesn't exist
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        cat > "$ASN_BLOCKLIST" << 'EOF'
# Cytadela ASN Blocklist
# Format: AS<number> [# optional comment]
# Example:
# AS12345  # Known botnet
# AS67890  # Bulletproof hosting

# Default entries - known malicious ASNs
AS32934   # Facebook (often abused)
AS14061   # DigitalOcean (frequently abused)
AS16276   # OVH Telecom (some malicious activity)

EOF
        log_info "Created default ASN blocklist: $ASN_BLOCKLIST"
    fi

    log_info "ASN blocking system initialized"
}

# Backup ASN blocklist
asn_backup() {
    local backup_file="${ASN_BLOCKLIST}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$ASN_BLOCKLIST" "$backup_file"
    log_info "ASN blocklist backed up to: $backup_file"
    echo "$backup_file"
}

# Clean old cache files
asn_cleanup_cache() {
    local days="${1:-7}"
    local cutoff_time
    cutoff_time=$(date -d "$days days ago" +%s)

    local cleaned=0
    for cache_file in "$ASN_CACHE_DIR"/*.txt; do
        if [[ -f "$cache_file" ]]; then
            local file_time
            file_time=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
            if (( file_time < cutoff_time )); then
                rm -f "$cache_file"
                ((cleaned++))
            fi
        fi
    done

    log_info "Cleaned $cleaned old ASN cache files (older than $days days)"
}

# ==============================================================================
# ASN LOOKUP & RESOLUTION
# ==============================================================================

# Get IP prefixes for an ASN from whois
asn_get_prefixes() {
    local asn="$1"
    local cache_file="$ASN_CACHE_DIR/${asn}.txt"

    # Check cache first
    if [[ -f "$cache_file" ]]; then
        local cache_age
        cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0) ))

        if (( cache_age < ASN_CACHE_TTL )); then
            log_debug "Using cached prefixes for $asn"
            cat "$cache_file"
            return 0
        fi
    fi

    log_debug "Fetching prefixes for ASN $asn from whois"

    # Query RADB whois for route objects
    local prefixes
    prefixes=$(whois -h "$ASN_WHOIS_SERVER" -- "-i origin $asn" 2>/dev/null | \
               grep "^route:" | \
               awk '{print $2}' | \
               sort -u)

    if [[ -z "$prefixes" ]]; then
        log_error "No prefixes found for ASN $asn"
        return 1
    fi

    # Cache the results
    echo "$prefixes" > "$cache_file"

    # Return the prefixes
    echo "$prefixes"
}

# Validate ASN format
asn_validate() {
    local asn="$1"

    if [[ ! "$asn" =~ ^AS[0-9]+$ ]]; then
        log_error "Invalid ASN format: $asn (expected: AS12345)"
        return 1
    fi

    # Check if ASN number is reasonable (1-4294967295)
    local asn_num="${asn#AS}"
    if (( asn_num < 1 || asn_num > 4294967295 )); then
        log_error "ASN number out of valid range: $asn_num"
        return 1
    fi

    return 0
}

# Get ASN information
asn_info() {
    local asn="$1"

    if ! asn_validate "$asn"; then
        return 1
    fi

    echo "ASN: $asn"

    # Get prefixes
    local prefixes
    prefixes=$(asn_get_prefixes "$asn")

    if [[ -n "$prefixes" ]]; then
        local prefix_count
        prefix_count=$(echo "$prefixes" | wc -l)
        echo "Prefixes: $prefix_count"

        echo "Sample prefixes:"
        echo "$prefixes" | head -5 | while read -r prefix; do
            echo "  $prefix"
        done

        if (( prefix_count > 5 )); then
            echo "  ... and $((prefix_count - 5)) more"
        fi
    else
        echo "Prefixes: None found"
    fi
}

# ==============================================================================
# BLOCKING & UNBLOCKING
# ==============================================================================

# Block an ASN
asn_block() {
    local asn="$1"

    if ! asn_validate "$asn"; then
        return 1
    fi

    log_info "Blocking ASN: $asn"

    # Get prefixes for this ASN
    local prefixes
    prefixes=$(asn_get_prefixes "$asn")

    if [[ -z "$prefixes" ]]; then
        log_error "Cannot block $asn: no prefixes found"
        return 1
    fi

    local blocked_count=0

    # Add nftables rules for each prefix
    while IFS= read -r prefix; do
        [[ -z "$prefix" ]] && continue

        log_debug "Blocking prefix: $prefix"

        # Add DROP rule in nftables
        if nft add rule inet filter input ip saddr "$prefix" drop 2>/dev/null; then
            ((blocked_count++))
        else
            log_warning "Failed to add nftables rule for $prefix"
        fi
    done <<< "$prefixes"

    if (( blocked_count > 0 )); then
        log_success "Successfully blocked $blocked_count prefixes for $asn"
        log_event "asn_block" "$asn" "$blocked_count" "manual"
    else
        log_error "Failed to block any prefixes for $asn"
        return 1
    fi
}

# Unblock an ASN
asn_unblock() {
    local asn="$1"

    if ! asn_validate "$asn"; then
        return 1
    fi

    log_info "Unblocking ASN: $asn"

    # Get prefixes for this ASN
    local prefixes
    prefixes=$(asn_get_prefixes "$asn")

    if [[ -z "$prefixes" ]]; then
        log_error "Cannot unblock $asn: no prefixes found"
        return 1
    fi

    local unblocked_count=0

    # Remove nftables rules for each prefix
    while IFS= read -r prefix; do
        [[ -z "$prefix" ]] && continue

        log_debug "Unblocking prefix: $prefix"

        # Find and delete the nftables rule
        local handle
        handle=$(nft -a list ruleset 2>/dev/null | \
                 grep "$prefix" | \
                 grep -oP 'handle \K\d+' | \
                 head -1)

        if [[ -n "$handle" ]]; then
            if nft delete rule inet filter input handle "$handle" 2>/dev/null; then
                ((unblocked_count++))
                log_debug "Removed rule for $prefix"
            else
                log_warning "Failed to remove nftables rule for $prefix"
            fi
        fi
    done <<< "$prefixes"

    if (( unblocked_count > 0 )); then
        log_success "Successfully unblocked $unblocked_count prefixes for $asn"
        log_event "asn_unblock" "$asn" "$unblocked_count" "manual"
    else
        log_warning "No active rules found for $asn (may already be unblocked)"
    fi
}

# ==============================================================================
# BLOCKLIST MANAGEMENT
# ==============================================================================

# Add ASN to blocklist
asn_add() {
    local asn="$1"
    local comment="${2:-}"

    if ! asn_validate "$asn"; then
        return 1
    fi

    # Check if already in blocklist
    if grep -q "^$asn" "$ASN_BLOCKLIST" 2>/dev/null; then
        log_warning "ASN $asn is already in blocklist"
        return 1
    fi

    # Add to blocklist
    if [[ -n "$comment" ]]; then
        echo "$asn  # $comment" >> "$ASN_BLOCKLIST"
    else
        echo "$asn" >> "$ASN_BLOCKLIST"
    fi

    log_success "Added $asn to blocklist"

    # Block immediately
    asn_block "$asn"
}

# Remove ASN from blocklist
asn_remove() {
    local asn="$1"

    if ! asn_validate "$asn"; then
        return 1
    fi

    # Check if in blocklist
    if ! grep -q "^$asn" "$ASN_BLOCKLIST" 2>/dev/null; then
        log_warning "ASN $asn is not in blocklist"
        return 1
    fi

    # Unblock first
    asn_unblock "$asn"

    # Remove from blocklist
    sed -i "/^$asn/d" "$ASN_BLOCKLIST"

    log_success "Removed $asn from blocklist"
}

# List blocked ASNs
asn_list() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        echo "ASN blocklist not found"
        return 1
    fi

    echo "Blocked ASNs:"
    echo "ASN       Prefixes  Status    Comment"
    echo "----------------------------------------"

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue

        # Parse line
        local asn comment
        asn=$(echo "$line" | awk '{print $1}')
        comment=$(echo "$line" | cut -d'#' -f2- | sed 's/^[[:space:]]*//' 2>/dev/null)

        # Get prefix count
        local prefix_count="?"
        if [[ -f "$ASN_CACHE_DIR/${asn}.txt" ]]; then
            prefix_count=$(wc -l < "$ASN_CACHE_DIR/${asn}.txt")
        fi

        # Check if actively blocked
        local status="unknown"
        if command -v nft >/dev/null 2>&1; then
            local active_rules
            active_rules=$(nft list ruleset 2>/dev/null | grep -c "$asn" 2>/dev/null || echo 0)
            if (( active_rules > 0 )); then
                status="blocked"
            else
                status="inactive"
            fi
        fi

        printf "%-9s %-9s %-9s %s\n" "$asn" "$prefix_count" "$status" "$comment"
    done < "$ASN_BLOCKLIST"
}

# Block all ASNs from blocklist
asn_block_all() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        log_error "ASN blocklist not found"
        return 1
    fi

    local blocked_count=0
    local total_count=0

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue

        local asn
        asn=$(echo "$line" | awk '{print $1}')

        ((total_count++))

        if asn_block "$asn" >/dev/null 2>&1; then
            ((blocked_count++))
        fi
    done < "$ASN_BLOCKLIST"

    log_success "Blocked $blocked_count out of $total_count ASNs from blocklist"
}

# Update all cached prefixes
asn_update_cache() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        log_error "ASN blocklist not found"
        return 1
    fi

    local updated_count=0
    local total_count=0

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue

        local asn
        asn=$(echo "$line" | awk '{print $1}')

        ((total_count++))

        if asn_get_prefixes "$asn" >/dev/null 2>&1; then
            ((updated_count++))
            log_debug "Updated cache for $asn"
        fi
    done < "$ASN_BLOCKLIST"

    log_success "Updated cache for $updated_count out of $total_count ASNs"
}

# ==============================================================================
# STATISTICS & REPORTING
# ==============================================================================

# Get ASN blocking statistics
asn_stats() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        echo "ASN blocklist not found"
        return 1
    fi

    local total_asns=0
    local cached_asns=0
    local active_rules=0

    # Count ASNs in blocklist
    total_asns=$(grep -v '^#' "$ASN_BLOCKLIST" | grep -c '^AS' 2>/dev/null || echo 0)

    # Count cached ASN files
    if [[ -d "$ASN_CACHE_DIR" ]]; then
        cached_asns=$(find "$ASN_CACHE_DIR" -name "*.txt" | wc -l 2>/dev/null || echo 0)
    fi

    # Count active nftables rules
    if command -v nft >/dev/null 2>&1; then
        active_rules=$(nft list ruleset 2>/dev/null | grep -c "drop" 2>/dev/null || echo 0)
    fi

    echo "ASN Blocking Statistics:"
    echo "  ASNs in blocklist: $total_asns"
    echo "  Cached ASN data: $cached_asns"
    echo "  Active nftables rules: $active_rules"
    echo "  Cache directory: $ASN_CACHE_DIR"

    # Show cache size
    if [[ -d "$ASN_CACHE_DIR" ]]; then
        local cache_size
        cache_size=$(du -sh "$ASN_CACHE_DIR" 2>/dev/null | cut -f1 || echo "unknown")
        echo "  Cache size: $cache_size"
    fi
}

# Export functions for use by other modules
export -f asn_init
export -f asn_backup
export -f asn_cleanup_cache
export -f asn_get_prefixes
export -f asn_validate
export -f asn_info
export -f asn_block
export -f asn_unblock
export -f asn_add
export -f asn_remove
export -f asn_list
export -f asn_block_all
export -f asn_update_cache
export -f asn_stats
