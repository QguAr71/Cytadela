#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3.0 - EVENT LOGGING SYSTEM                                 ║
# ║  Structured JSON logging for security events and analysis             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

EVENT_LOG_DIR="/var/log/cytadela"
EVENT_LOG_FILE="${EVENT_LOG_DIR}/events.json"
EVENT_LOG_MAX_SIZE="10M"
EVENT_LOG_ROTATE_COUNT="10"

# Event types
EVENT_TYPES=(
    "auto_block"
    "asn_block"
    "asn_unblock"
    "reputation_update"
    "honeypot_trigger"
    "failed_ssh_login"
    "port_scan"
    "nft_rule_add"
    "nft_rule_remove"
    "service_restart"
    "config_change"
)

# ==============================================================================
# LOG MANAGEMENT
# ==============================================================================

# Initialize event logging system
event_log_init() {
    mkdir -p "$EVENT_LOG_DIR"

    # Create log file if it doesn't exist
    if [[ ! -f "$EVENT_LOG_FILE" ]]; then
        touch "$EVENT_LOG_FILE"
        log_info "Created event log file: $EVENT_LOG_FILE"
    fi

    # Set appropriate permissions
    chmod 640 "$EVENT_LOG_FILE" 2>/dev/null || true
    chown root:adm "$EVENT_LOG_FILE" 2>/dev/null || true

    log_info "Event logging system initialized"
}

# Check if log rotation is needed
event_log_check_rotation() {
    if [[ ! -f "$EVENT_LOG_FILE" ]]; then
        return 0
    fi

    local current_size
    current_size=$(stat -c %s "$EVENT_LOG_FILE" 2>/dev/null || echo 0)

    local max_size
    max_size=$(numfmt --from=iec "$EVENT_LOG_MAX_SIZE" 2>/dev/null || echo 10485760)

    if (( current_size > max_size )); then
        event_log_rotate
    fi
}

# Rotate log file
event_log_rotate() {
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")

    local rotated_file="${EVENT_LOG_FILE}.${timestamp}"

    # Compress old log
    if command -v gzip >/dev/null 2>&1; then
        gzip -c "$EVENT_LOG_FILE" > "${rotated_file}.gz"
        rm -f "$EVENT_LOG_FILE"
    else
        mv "$EVENT_LOG_FILE" "$rotated_file"
    fi

    # Create new log file
    touch "$EVENT_LOG_FILE"
    chmod 640 "$EVENT_LOG_FILE" 2>/dev/null || true

    # Clean up old rotated logs
    event_log_cleanup_old

    log_info "Rotated event log: ${rotated_file}.gz"
}

# Clean up old rotated log files
event_log_cleanup_old() {
    local count=0

    # Keep only the most recent rotated logs
    for file in $(ls -t "${EVENT_LOG_FILE}".*.gz 2>/dev/null | tail -n +$((EVENT_LOG_ROTATE_COUNT + 1))); do
        rm -f "$file"
        ((count++))
    done

    if (( count > 0 )); then
        log_info "Cleaned up $count old rotated event log files"
    fi
}

# ==============================================================================
# EVENT LOGGING
# ==============================================================================

# Log an event in JSON format
log_event() {
    local event_type="$1"
    local target="$2"
    local value="$3"
    local reason="$4"

    # Validate event type
    if [[ ! " ${EVENT_TYPES[*]} " =~ " $event_type " ]]; then
        log_warning "Unknown event type: $event_type"
    fi

    # Create event data
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local hostname
    hostname=$(hostname 2>/dev/null || echo "unknown")

    local pid
    pid=$$

    # Create JSON event (use printf for better portability)
    local event_json
    event_json=$(printf '{"timestamp":"%s","hostname":"%s","pid":%d,"event_type":"%s","target":"%s","value":"%s","reason":"%s"}' \
                "$timestamp" "$hostname" "$pid" "$event_type" "$target" "$value" "$reason")

    # Append to log file
    echo "$event_json" >> "$EVENT_LOG_FILE"

    # Check rotation
    event_log_check_rotation

    # Debug logging
    log_debug "Event logged: $event_type $target $value ($reason)"
}

# Log multiple events at once
log_events() {
    local event_array=("$@")

    for event_data in "${event_array[@]}"; do
        # Parse event data (format: "type:target:value:reason")
        IFS=':' read -r event_type target value reason <<< "$event_data"
        log_event "$event_type" "$target" "$value" "$reason"
    done
}

# ==============================================================================
# EVENT QUERYING & ANALYSIS
# ==============================================================================

# Query events with filters
event_query() {
    local event_type="${1:-}"
    local hours="${2:-24}"
    local limit="${3:-100}"

    if [[ ! -f "$EVENT_LOG_FILE" ]]; then
        echo "No event log file found"
        return 1
    fi

    # Calculate cutoff time
    local cutoff_time
    cutoff_time=$(date -u -d "$hours hours ago" +"%Y-%m-%dT%H:%M:%SZ")

    local count=0

    # Read events and filter
    while IFS= read -r line; do
        # Skip empty lines
        [[ -z "$line" ]] && continue

        # Parse JSON (basic parsing without jq dependency)
        local timestamp event_type_line

        # Extract timestamp
        timestamp=$(echo "$line" | sed 's/.*"timestamp":"\([^"]*\)".*/\1/')

        # Extract event_type
        event_type_line=$(echo "$line" | sed 's/.*"event_type":"\([^"]*\)".*/\1/')

        # Check time filter
        if [[ "$timestamp" < "$cutoff_time" ]]; then
            continue
        fi

        # Check event type filter
        if [[ -n "$event_type" && "$event_type_line" != "$event_type" ]]; then
            continue
        fi

        # Output the event
        echo "$line"

        # Apply limit
        ((count++))
        if (( count >= limit )); then
            echo "... (truncated - use higher limit for more results)"
            break
        fi

    done < "$EVENT_LOG_FILE"

    if (( count == 0 )); then
        echo "No events found matching criteria"
    fi
}

# Generate event statistics
event_stats() {
    local hours="${1:-24}"

    if [[ ! -f "$EVENT_LOG_FILE" ]]; then
        echo "No event log file found"
        return 1
    fi

    echo "Event Statistics (last $hours hours):"
    echo "====================================="

    # Calculate cutoff time
    local cutoff_time
    cutoff_time=$(date -u -d "$hours hours ago" +"%Y-%m-%dT%H:%M:%SZ")

    # Count events by type
    declare -A event_counts

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        # Extract timestamp and event_type
        local timestamp event_type_line

        timestamp=$(echo "$line" | sed 's/.*"timestamp":"\([^"]*\)".*/\1/')
        event_type_line=$(echo "$line" | sed 's/.*"event_type":"\([^"]*\)".*/\1/')

        # Check time filter
        [[ "$timestamp" < "$cutoff_time" ]] && continue

        # Count event type
        ((event_counts["$event_type_line"]++))
    done < "$EVENT_LOG_FILE"

    # Display results
    printf "%-20s %s\n" "Event Type" "Count"
    echo "----------------------------------------"

    local total=0
    for event_type in "${!event_counts[@]}"; do
        printf "%-20s %d\n" "$event_type" "${event_counts[$event_type]}"
        ((total += event_counts[$event_type]))
    done

    echo "----------------------------------------"
    printf "%-20s %d\n" "TOTAL" "$total"

    # Additional statistics
    local unique_ips
    unique_ips=$(grep -o '"target":"[^"]*"' "$EVENT_LOG_FILE" 2>/dev/null | \
                 sed 's/"target":"//' | sed 's/"//' | sort | uniq | wc -l 2>/dev/null || echo 0)

    echo ""
    echo "Additional Statistics:"
    echo "  Unique targets: $unique_ips"
    echo "  Log file size: $(du -h "$EVENT_LOG_FILE" 2>/dev/null | cut -f1 || echo "unknown")"
}

# Get recent events summary
event_recent() {
    local count="${1:-10}"

    echo "Recent Events (last $count):"
    echo "============================"

    if [[ ! -f "$EVENT_LOG_FILE" ]]; then
        echo "No event log file found"
        return 1
    fi

    # Get last N lines and format them
    tail -n "$count" "$EVENT_LOG_FILE" | while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        # Extract key fields
        local timestamp event_type target reason
        timestamp=$(echo "$line" | sed 's/.*"timestamp":"\([^"]*\)".*/\1/')
        event_type=$(echo "$line" | sed 's/.*"event_type":"\([^"]*\)".*/\1/')
        target=$(echo "$line" | sed 's/.*"target":"\([^"]*\)".*/\1/')
        reason=$(echo "$line" | sed 's/.*"reason":"\([^"]*\)".*/\1/')

        # Format output
        printf "%-20s %-15s %-15s %s\n" "${timestamp:0:19}" "$event_type" "$target" "$reason"
    done
}

# ==============================================================================
# EVENT EXPORT & BACKUP
# ==============================================================================

# Export events to different formats
event_export() {
    local format="${1:-json}"
    local output_file="${2:-/tmp/citadel-events-export.$(date +%Y%m%d-%H%M%S)}"

    if [[ ! -f "$EVENT_LOG_FILE" ]]; then
        log_error "No event log file found"
        return 1
    fi

    case "$format" in
        json)
            cp "$EVENT_LOG_FILE" "$output_file"
            ;;
        csv)
            # Convert JSON to CSV
            {
                echo "timestamp,hostname,pid,event_type,target,value,reason"
                while IFS= read -r line; do
                    [[ -z "$line" ]] && continue
                    # Basic CSV conversion (simplified)
                    echo "$line" | sed 's/[{}]//g' | sed 's/"//g' | sed 's/:/,/g'
                done < "$EVENT_LOG_FILE"
            } > "$output_file"
            ;;
        *)
            log_error "Unsupported export format: $format (supported: json, csv)"
            return 1
            ;;
    esac

    log_success "Events exported to: $output_file (format: $format)"
    echo "$output_file"
}

# Backup event logs
event_backup() {
    local backup_dir="${1:-/var/backups/citadel-events}"
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")

    mkdir -p "$backup_dir"

    # Compress current log
    if [[ -f "$EVENT_LOG_FILE" ]]; then
        local backup_file="${backup_dir}/events-${timestamp}.json.gz"
        gzip -c "$EVENT_LOG_FILE" > "$backup_file"
        log_success "Event log backed up to: $backup_file"
        echo "$backup_file"
    else
        log_warning "No event log file to backup"
    fi
}

# ==============================================================================
# EVENT ANALYSIS & ALERTING
# ==============================================================================

# Analyze event patterns
event_analyze() {
    local hours="${1:-24}"

    echo "Event Analysis (last $hours hours):"
    echo "==================================="

    if [[ ! -f "$EVENT_LOG_FILE" ]]; then
        echo "No event log file found"
        return 1
    fi

    # Calculate cutoff time
    local cutoff_time
    cutoff_time=$(date -u -d "$hours hours ago" +"%Y-%m-%dT%H:%M:%SZ")

    # Analyze patterns
    echo "Top event types:"
    awk -v cutoff="$cutoff_time" '
        BEGIN { FS="\""; }
        {
            # Extract timestamp and event_type
            for(i=1; i<=NF; i++) {
                if($i == "timestamp") { timestamp = $(i+2); }
                if($i == "event_type") { event_type = $(i+2); }
            }
            if(timestamp >= cutoff) {
                counts[event_type]++;
            }
        }
        END {
            for(type in counts) {
                print counts[type], type;
            }
        }
    ' "$EVENT_LOG_FILE" | sort -nr | head -10

    echo ""
    echo "Suspicious patterns:"

    # Check for rapid-fire events from same IP
    local suspicious_ips
    suspicious_ips=$(awk -v cutoff="$cutoff_time" '
        BEGIN { FS="\""; }
        {
            for(i=1; i<=NF; i++) {
                if($i == "timestamp") { timestamp = $(i+2); }
                if($i == "target") { target = $(i+2); }
            }
            if(timestamp >= cutoff && target ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
                events[target]++;
            }
        }
        END {
            for(ip in events) {
                if(events[ip] > 10) {
                    print events[ip], ip;
                }
            }
        }
    ' "$EVENT_LOG_FILE")

    if [[ -n "$suspicious_ips" ]]; then
        echo "$suspicious_ips" | while read -r count ip; do
            echo "  $ip: $count events (POTENTIAL ATTACK)"
        done
    else
        echo "  No suspicious patterns detected"
    fi
}

# ==============================================================================
# EVENT HOOKS FOR OTHER SYSTEMS
# ==============================================================================

# Hook for reputation system events
event_hook_reputation() {
    local ip="$1"
    local old_score="$2"
    local new_score="$3"

    log_event "reputation_update" "$ip" "$new_score" "score_change"
}

# Hook for ASN blocking events
event_hook_asn_block() {
    local asn="$1"
    local prefix_count="$2"

    log_event "asn_block" "$asn" "$prefix_count" "manual"
}

# Hook for honeypot events
event_hook_honeypot() {
    local ip="$1"
    local port="$2"
    local service="$3"

    log_event "honeypot_trigger" "$ip:$port" "$service" "scanner_detected"
}

# Hook for service events
event_hook_service() {
    local service="$1"
    local action="$2"  # start/stop/restart
    local result="$3"  # success/failure

    log_event "service_action" "$service" "$action" "$result"
}

# Export functions for use by other modules
export -f event_log_init
export -f event_log_check_rotation
export -f event_log_rotate
export -f event_log_cleanup_old
export -f log_event
export -f log_events
export -f event_query
export -f event_stats
export -f event_recent
export -f event_export
export -f event_backup
export -f event_analyze
export -f event_hook_reputation
export -f event_hook_asn_block
export -f event_hook_honeypot
export -f event_hook_service
