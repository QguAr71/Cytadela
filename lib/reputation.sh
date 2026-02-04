#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3.0 - REPUTATION SYSTEM                                     ║
# ║  IP reputation scoring and automatic threat detection                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

REPUTATION_DB="/var/lib/cytadela/reputation.db"
REPUTATION_THRESHOLD="0.15"
REPUTATION_DEFAULT_SCORE="1.0"
REPUTATION_MAX_EVENTS="1000"

# Event scoring deltas
declare -A REPUTATION_EVENT_DELTAS=(
    ["failed_ssh_login"]="-0.10"
    ["port_scan"]="-0.20"
    ["failed_dns_query"]="-0.05"
    ["successful_connection"]="+0.05"
    ["manual_trust"]="+0.50"
    ["honeypot_trigger"]="-0.30"
)

# ==============================================================================
# DATABASE MANAGEMENT
# ==============================================================================

# Initialize reputation database
reputation_init() {
    mkdir -p "$(dirname "$REPUTATION_DB")"
    touch "$REPUTATION_DB"
    log_info "Reputation database initialized: $REPUTATION_DB"
}

# Clean old entries (older than specified days)
reputation_cleanup() {
    local days="${1:-30}"
    local cutoff_date
    cutoff_date=$(date -u -d "$days days ago" +"%Y-%m-%dT%H:%M:%SZ")

    local temp_file
    temp_file=$(mktemp)

    local cleaned=0
    while IFS=: read -r ip score timestamp events; do
        if [[ "$timestamp" > "$cutoff_date" ]]; then
            echo "$ip:$score:$timestamp:$events" >> "$temp_file"
        else
            ((cleaned++))
        fi
    done < "$REPUTATION_DB"

    mv "$temp_file" "$REPUTATION_DB"
    log_info "Cleaned $cleaned old reputation entries (older than $days days)"
}

# Backup reputation database
reputation_backup() {
    local backup_file="${REPUTATION_DB}.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$REPUTATION_DB" "$backup_file"
    log_info "Reputation database backed up to: $backup_file"
    echo "$backup_file"
}

# Restore reputation database
reputation_restore() {
    local backup_file="$1"
    if [[ -f "$backup_file" ]]; then
        cp "$backup_file" "$REPUTATION_DB"
        log_info "Reputation database restored from: $backup_file"
    else
        log_error "Backup file not found: $backup_file"
        return 1
    fi
}

# ==============================================================================
# CORE REPUTATION FUNCTIONS
# ==============================================================================

# Get reputation score for IP
reputation_get_score() {
    local ip="$1"

    if [[ ! -f "$REPUTATION_DB" ]]; then
        echo "$REPUTATION_DEFAULT_SCORE"
        return
    fi

    local line
    line=$(grep "^$ip:" "$REPUTATION_DB" 2>/dev/null)

    if [[ -n "$line" ]]; then
        echo "$line" | cut -d: -f2
    else
        echo "$REPUTATION_DEFAULT_SCORE"
    fi
}

# Update reputation score for IP
reputation_update_score() {
    local ip="$1"
    local delta="$2"

    # Get current score
    local current_score
    current_score=$(reputation_get_score "$ip")

    # Calculate new score
    local new_score
    new_score=$(echo "$current_score + $delta" | bc -l 2>/dev/null)

    # Clamp to 0.0-1.0 range
    if (( $(echo "$new_score < 0.0" | bc -l 2>/dev/null) )); then
        new_score="0.0"
    elif (( $(echo "$new_score > 1.0" | bc -l 2>/dev/null) )); then
        new_score="1.0"
    fi

    # Get current timestamp
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update or insert record
    if grep -q "^$ip:" "$REPUTATION_DB" 2>/dev/null; then
        # Update existing entry
        local current_events
        current_events=$(grep "^$ip:" "$REPUTATION_DB" | cut -d: -f4)
        local new_events=$((current_events + 1))

        sed -i "s|^$ip:.*|$ip:$new_score:$timestamp:$new_events|" "$REPUTATION_DB"
    else
        # Insert new entry
        echo "$ip:$new_score:$timestamp:1" >> "$REPUTATION_DB"
    fi

    # Check threshold for automatic blocking
    if (( $(echo "$new_score < $REPUTATION_THRESHOLD" | bc -l 2>/dev/null) )); then
        reputation_auto_block "$ip" "$new_score"
    fi

    log_debug "Reputation updated: $ip score=$new_score (delta=$delta)"
}

# Track event and update reputation
reputation_track_event() {
    local ip="$1"
    local event_type="$2"
    local custom_delta="${3:-}"

    local delta
    if [[ -n "$custom_delta" ]]; then
        delta="$custom_delta"
    elif [[ -n "${REPUTATION_EVENT_DELTAS[$event_type]}" ]]; then
        delta="${REPUTATION_EVENT_DELTAS[$event_type]}"
    else
        delta="0.0"
        log_warning "Unknown event type: $event_type (using delta=0.0)"
    fi

    reputation_update_score "$ip" "$delta"

    # Log the event
    log_event "reputation_update" "$ip" "$delta" "$event_type"
}

# Auto-block IP when reputation drops too low
reputation_auto_block() {
    local ip="$1"
    local score="$2"

    log_info "Auto-blocking IP due to low reputation: $ip (score=$score)"

    # Add to nftables DROP rule
    if command -v nft >/dev/null 2>&1; then
        nft add rule inet filter input ip saddr "$ip" drop 2>/dev/null || \
        log_warning "Failed to add nftables rule for $ip"
    fi

    # Log the blocking event
    log_event "auto_block" "$ip" "$score" "low_reputation"
}

# Reset reputation for IP
reputation_reset() {
    local ip="$1"

    if grep -q "^$ip:" "$REPUTATION_DB" 2>/dev/null; then
        sed -i "/^$ip:/d" "$REPUTATION_DB"
        log_info "Reputation reset for IP: $ip"

        # Remove from nftables if blocked
        reputation_unblock "$ip"
    else
        log_warning "IP not found in reputation database: $ip"
    fi
}

# Unblock IP (remove from nftables)
reputation_unblock() {
    local ip="$1"

    if command -v nft >/dev/null 2>&1; then
        # Find and delete the rule
        local handle
        handle=$(nft -a list ruleset 2>/dev/null | grep "$ip" | grep -oP 'handle \K\d+' | head -1)

        if [[ -n "$handle" ]]; then
            nft delete rule inet filter input handle "$handle" 2>/dev/null && \
            log_info "Removed nftables rule for IP: $ip" || \
            log_warning "Failed to remove nftables rule for $ip"
        fi
    fi
}

# ==============================================================================
# QUERY & REPORTING FUNCTIONS
# ==============================================================================

# List all IPs with reputation data
reputation_list() {
    local threshold="${1:-}"

    if [[ ! -f "$REPUTATION_DB" ]]; then
        echo "Reputation database not found"
        return 1
    fi

    echo "IP Address          Score   Events  Last Updated"
    echo "--------------------------------------------------"

    while IFS=: read -r ip score timestamp events; do
        if [[ -z "$threshold" ]] || (( $(echo "$score < $threshold" | bc -l 2>/dev/null) )); then
            printf "%-18s %-7s %-7s %s\n" "$ip" "$score" "$events" "$timestamp"
        fi
    done < "$REPUTATION_DB"
}

# Get reputation statistics
reputation_stats() {
    if [[ ! -f "$REPUTATION_DB" ]]; then
        echo "Reputation database not found"
        return 1
    fi

    local total_ips=0
    local suspicious_ips=0
    local blocked_ips=0

    while IFS=: read -r ip score _ _; do
        ((total_ips++))
        if (( $(echo "$score < $REPUTATION_THRESHOLD" | bc -l 2>/dev/null) )); then
            ((suspicious_ips++))
            if (( $(echo "$score <= 0.0" | bc -l 2>/dev/null) )); then
                ((blocked_ips++))
            fi
        fi
    done < "$REPUTATION_DB"

    echo "Reputation Statistics:"
    echo "  Total IPs tracked: $total_ips"
    echo "  Suspicious IPs (< $REPUTATION_THRESHOLD): $suspicious_ips"
    echo "  Auto-blocked IPs (≤ 0.0): $blocked_ips"
    echo "  Current threshold: $REPUTATION_THRESHOLD"
}

# ==============================================================================
# CONFIGURATION FUNCTIONS
# ==============================================================================

# Set reputation threshold
reputation_set_threshold() {
    local new_threshold="$1"

    # Validate threshold
    if ! [[ "$new_threshold" =~ ^[0-1](\.[0-9]+)?$ ]]; then
        log_error "Invalid threshold value: $new_threshold (must be 0.0-1.0)"
        return 1
    fi

    REPUTATION_THRESHOLD="$new_threshold"
    log_info "Reputation threshold set to: $new_threshold"
}

# Configure event scoring
reputation_configure_event() {
    local event_type="$1"
    local delta="$2"

    # Validate delta
    if ! [[ "$delta" =~ ^[-+]?[0-9]*\.?[0-9]+$ ]]; then
        log_error "Invalid delta value: $delta"
        return 1
    fi

    REPUTATION_EVENT_DELTAS["$event_type"]="$delta"
    log_info "Event '$event_type' scoring set to: $delta"
}

# ==============================================================================
# INTEGRATION HOOKS
# ==============================================================================

# Hook for failed SSH login
reputation_hook_ssh_failed() {
    local ip="$1"
    reputation_track_event "$ip" "failed_ssh_login"
}

# Hook for port scan detection
reputation_hook_port_scan() {
    local ip="$1"
    reputation_track_event "$ip" "port_scan"
}

# Hook for honeypot trigger
reputation_hook_honeypot() {
    local ip="$1"
    reputation_track_event "$ip" "honeypot_trigger"
}

# Hook for successful legitimate connection
reputation_hook_successful_connection() {
    local ip="$1"
    reputation_track_event "$ip" "successful_connection"
}

# Export functions for use by other modules
export -f reputation_init
export -f reputation_cleanup
export -f reputation_backup
export -f reputation_restore
export -f reputation_get_score
export -f reputation_update_score
export -f reputation_track_event
export -f reputation_auto_block
export -f reputation_reset
export -f reputation_unblock
export -f reputation_list
export -f reputation_stats
export -f reputation_set_threshold
export -f reputation_configure_event
export -f reputation_hook_ssh_failed
export -f reputation_hook_port_scan
export -f reputation_hook_honeypot
export -f reputation_hook_successful_connection
