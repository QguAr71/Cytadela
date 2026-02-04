#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CITADEL v3.3.0 - HONEYPOT SYSTEM                                     ║
# ║  Fake services to detect and auto-block network scanners              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

HONEYPOT_CONFIG_DIR="/etc/cytadela/honeypot"
HONEYPOT_STATE_DIR="/var/lib/cytadela/honeypot"
HONEYPOT_SERVICE_NAME="citadel-honeypot"
HONEYPOT_LOG_FILE="/var/log/cytadela/honeypot.log"

# Default honeypot configurations
declare -A DEFAULT_HONEYPOTS=(
    ["ssh"]="22"
    ["telnet"]="23"
    ["ftp"]="21"
    ["http"]="80"
    ["https"]="443"
    ["mysql"]="3306"
    ["postgres"]="5432"
)

# ==============================================================================
# HONEYPOT MANAGEMENT
# ==============================================================================

# Initialize honeypot system
honeypot_init() {
    mkdir -p "$HONEYPOT_CONFIG_DIR"
    mkdir -p "$HONEYPOT_STATE_DIR"

    # Create default configuration if it doesn't exist
    local config_file="$HONEYPOT_CONFIG_DIR/config"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# Citadel Honeypot Configuration
# Format: port:service:enabled
# Examples:
# 22:ssh:true
# 23:telnet:false
# 3306:mysql:true

# Default honeypots (disabled by default for safety)
22:ssh:false
23:telnet:false
21:ftp:false
80:http:false
443:https:false
3306:mysql:false
5432:postgres:false
EOF
        log_info "Created default honeypot configuration: $config_file"
    fi

    # Create log file
    touch "$HONEYPOT_LOG_FILE"
    chmod 640 "$HONEYPOT_LOG_FILE" 2>/dev/null || true

    log_info "Honeypot system initialized"
}

# Deploy a honeypot on specified port
honeypot_deploy() {
    local port="$1"
    local service="${2:-auto}"

    if [[ -z "$port" ]]; then
        log_error "Port number required"
        return 1
    fi

    # Validate port number
    if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
        log_error "Invalid port number: $port"
        return 1
    fi

    # Auto-detect service if not specified
    if [[ "$service" == "auto" ]]; then
        service=$(honeypot_detect_service "$port")
    fi

    # Check if port is already in use
    if honeypot_check_port_in_use "$port"; then
        log_error "Port $port is already in use"
        return 1
    fi

    # Create honeypot configuration
    local honeypot_dir="$HONEYPOT_STATE_DIR/port_$port"
    mkdir -p "$honeypot_dir"

    # Save configuration
    cat > "$honeypot_dir/config" << EOF
PORT=$port
SERVICE=$service
DEPLOY_TIME=$(date +%s)
PID_FILE=$honeypot_dir/honeypot.pid
LOG_FILE=$honeypot_dir/connections.log
EOF

    # Start honeypot
    honeypot_start_service "$port" "$service" "$honeypot_dir"

    # Update main configuration
    honeypot_update_config "$port" "$service" "true"

    log_success "Honeypot deployed on port $port ($service)"
    log_event "honeypot_deploy" "$port" "$service" "manual"
}

# Undeploy honeypot from specified port
honeypot_undeploy() {
    local port="$1"

    if [[ -z "$port" ]]; then
        log_error "Port number required"
        return 1
    fi

    local honeypot_dir="$HONEYPOT_STATE_DIR/port_$port"

    if [[ ! -d "$honeypot_dir" ]]; then
        log_error "No honeypot found on port $port"
        return 1
    fi

    # Stop honeypot service
    honeypot_stop_service "$port" "$honeypot_dir"

    # Remove configuration
    rm -rf "$honeypot_dir"

    # Update main configuration
    honeypot_update_config "$port" "" "false"

    log_success "Honeypot undeployed from port $port"
    log_event "honeypot_undeploy" "$port" "stopped" "manual"
}

# Start honeypot service for a port
honeypot_start_service() {
    local port="$1"
    local service="$2"
    local honeypot_dir="$3"

    local config_file="$honeypot_dir/config"
    local pid_file="$honeypot_dir/honeypot.pid"
    local log_file="$honeypot_dir/connections.log"

    # Create systemd service file
    local service_file="/etc/systemd/system/${HONEYPOT_SERVICE_NAME}-$port.service"

    cat > "$service_file" << EOF
[Unit]
Description=Citadel Honeypot on port $port ($service)
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c '${CYTADELA_LIB}/honeypot.sh start $port $service'
ExecStop=/bin/bash -c '${CYTADELA_LIB}/honeypot.sh stop $port'
Restart=always
RestartSec=5
PIDFile=$pid_file

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and start service
    systemctl daemon-reload
    systemctl enable "${HONEYPOT_SERVICE_NAME}-$port"
    systemctl start "${HONEYPOT_SERVICE_NAME}-$port"

    log_debug "Started honeypot service for port $port"
}

# Stop honeypot service for a port
honeypot_stop_service() {
    local port="$1"
    local honeypot_dir="$2"

    local service_name="${HONEYPOT_SERVICE_NAME}-$port"

    # Stop and disable service
    systemctl stop "$service_name" 2>/dev/null || true
    systemctl disable "$service_name" 2>/dev/null || true

    # Remove service file
    rm -f "/etc/systemd/system/${service_name}.service"

    # Reload systemd
    systemctl daemon-reload

    # Kill any remaining processes
    if [[ -f "$honeypot_dir/honeypot.pid" ]]; then
        local pid
        pid=$(cat "$honeypot_dir/honeypot.pid" 2>/dev/null)
        if [[ -n "$pid" ]]; then
            kill -TERM "$pid" 2>/dev/null || true
        fi
        rm -f "$honeypot_dir/honeypot.pid"
    fi

    log_debug "Stopped honeypot service for port $port"
}

# ==============================================================================
# HONEYPOT MONITORING & DETECTION
# ==============================================================================

# Monitor honeypot connections and trigger actions
honeypot_monitor() {
    local port="$1"
    local honeypot_dir="$HONEYPOT_STATE_DIR/port_$port"
    local log_file="$honeypot_dir/connections.log"

    if [[ ! -f "$log_file" ]]; then
        return
    fi

    # Process new connections
    local last_processed_file="$honeypot_dir/last_processed"
    local last_processed=0

    if [[ -f "$last_processed_file" ]]; then
        last_processed=$(cat "$last_processed_file")
    fi

    # Read new log entries
    local line_num=0
    while IFS= read -r line; do
        ((line_num++))
        if (( line_num <= last_processed )); then
            continue
        fi

        # Parse connection log line (format: timestamp:ip:port:action)
        IFS=':' read -r timestamp ip remote_port action <<< "$line"

        if [[ "$action" == "connect" ]]; then
            # New connection detected
            log_info "Honeypot connection detected: $ip:$remote_port on port $port"

            # Trigger reputation system
            reputation_track_event "$ip" "honeypot_trigger"

            # Log event
            log_event "honeypot_trigger" "$ip:$port" "connection" "scanner_detected"

            # Auto-block if configured
            if [[ "${CYTADELA_HONEYPOT_AUTO_BLOCK:-true}" == "true" ]]; then
                # Add to nftables DROP rule
                if command -v nft >/dev/null 2>&1; then
                    nft add rule inet filter input ip saddr "$ip" drop 2>/dev/null || \
                    log_warning "Failed to add nftables rule for honeypot IP: $ip"
                fi
                log_info "Auto-blocked honeypot scanner: $ip"
            fi
        fi

    done < "$log_file"

    # Update last processed line
    echo "$line_num" > "$last_processed_file"
}

# Get honeypot status
honeypot_status() {
    local port="$1"

    if [[ -n "$port" ]]; then
        # Status for specific port
        local honeypot_dir="$HONEYPOT_STATE_DIR/port_$port"
        local service_name="${HONEYPOT_SERVICE_NAME}-$port"

        if [[ ! -d "$honeypot_dir" ]]; then
            echo "Port $port: No honeypot deployed"
            return 1
        fi

        echo "Port $port:"
        echo "  Service: $(systemctl is-active "$service_name" 2>/dev/null || echo "unknown")"
        echo "  Config: $honeypot_dir/config"

        if [[ -f "$honeypot_dir/connections.log" ]]; then
            local connections
            connections=$(wc -l < "$honeypot_dir/connections.log")
            echo "  Connections detected: $connections"
        else
            echo "  Connections detected: 0"
        fi

    else
        # Status for all honeypots
        echo "Citadel Honeypot Status:"
        echo "========================"

        local active_count=0
        local total_connections=0

        for honeypot_dir in "$HONEYPOT_STATE_DIR"/port_*; do
            if [[ -d "$honeypot_dir" ]]; then
                local port_num="${honeypot_dir##*port_}"
                local service_name="${HONEYPOT_SERVICE_NAME}-$port_num"

                echo "Port $port_num:"
                echo "  Service: $(systemctl is-active "$service_name" 2>/dev/null || echo "unknown")"

                if [[ -f "$honeypot_dir/connections.log" ]]; then
                    local connections
                    connections=$(wc -l < "$honeypot_dir/connections.log")
                    echo "  Connections: $connections"
                    ((total_connections += connections))
                else
                    echo "  Connections: 0"
                fi

                ((active_count++))
                echo ""
            fi
        done

        echo "Summary:"
        echo "  Active honeypots: $active_count"
        echo "  Total connections detected: $total_connections"
    fi
}

# List all deployed honeypots
honeypot_list() {
    echo "Deployed Honeypots:"
    echo "==================="

    local found=false

    for honeypot_dir in "$HONEYPOT_STATE_DIR"/port_*; do
        if [[ -d "$honeypot_dir" ]]; then
            local port_num="${honeypot_dir##*port_}"
            local config_file="$honeypot_dir/config"

            if [[ -f "$config_file" ]]; then
                source "$config_file"
                echo "Port $PORT ($SERVICE): $(systemctl is-active "${HONEYPOT_SERVICE_NAME}-$PORT" 2>/dev/null || echo "unknown")"
                found=true
            fi
        fi
    done

    if [[ "$found" != "true" ]]; then
        echo "No honeypots currently deployed"
    fi
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Detect service type based on port
honeypot_detect_service() {
    local port="$1"

    case "$port" in
        22) echo "ssh" ;;
        23) echo "telnet" ;;
        21) echo "ftp" ;;
        80) echo "http" ;;
        443) echo "https" ;;
        3306) echo "mysql" ;;
        5432) echo "postgres" ;;
        25) echo "smtp" ;;
        53) echo "dns" ;;
        110) echo "pop3" ;;
        143) echo "imap" ;;
        993) echo "imaps" ;;
        995) echo "pop3s" ;;
        *) echo "unknown" ;;
    esac
}

# Check if port is already in use
honeypot_check_port_in_use() {
    local port="$1"

    # Check if honeypot is already deployed
    if [[ -d "$HONEYPOT_STATE_DIR/port_$port" ]]; then
        return 0
    fi

    # Check if any service is listening on the port
    if command -v netstat >/dev/null 2>&1; then
        netstat -tuln 2>/dev/null | grep -q ":$port "
        return $?
    elif command -v ss >/dev/null 2>&1; then
        ss -tuln 2>/dev/null | grep -q ":$port "
        return $?
    else
        # Fallback: try to bind to port
        timeout 1 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null
        return $?
    fi
}

# Update main honeypot configuration
honeypot_update_config() {
    local port="$1"
    local service="$2"
    local enabled="$3"

    local config_file="$HONEYPOT_CONFIG_DIR/config"

    if [[ "$enabled" == "true" ]]; then
        # Add or update entry
        if grep -q "^$port:" "$config_file" 2>/dev/null; then
            sed -i "s/^$port:.*/$port:$service:true/" "$config_file"
        else
            echo "$port:$service:true" >> "$config_file"
        fi
    else
        # Disable entry
        sed -i "s/^$port:.*/$port:$service:false/" "$config_file"
    fi
}

# Clean up honeypot logs and old data
honeypot_cleanup() {
    local days="${1:-30}"

    log_info "Cleaning up honeypot data older than $days days"

    # Clean up old log files in honeypot directories
    find "$HONEYPOT_STATE_DIR" -name "*.log" -type f -mtime +"$days" -delete 2>/dev/null || true

    # Clean up main honeypot log
    if [[ -f "$HONEYPOT_LOG_FILE" ]]; then
        # Create backup of old entries
        local backup_file="${HONEYPOT_LOG_FILE}.old"
        head -n 1000 "$HONEYPOT_LOG_FILE" > "$backup_file" 2>/dev/null || true

        # Keep only recent entries (last 1000 lines)
        tail -n 1000 "$HONEYPOT_LOG_FILE" > "${HONEYPOT_LOG_FILE}.tmp" 2>/dev/null || true
        mv "${HONEYPOT_LOG_FILE}.tmp" "$HONEYPOT_LOG_FILE" 2>/dev/null || true
    fi

    log_info "Honeypot cleanup completed"
}

# ==============================================================================
# HONEYPOT SERVICE SCRIPT
# ==============================================================================

# This is called by systemd service to run the actual honeypot
honeypot_run_service() {
    local port="$1"
    local service="$2"
    local honeypot_dir="$3"

    local config_file="$honeypot_dir/config"
    local pid_file="$honeypot_dir/honeypot.pid"
    local log_file="$honeypot_dir/connections.log"

    # Write PID file
    echo $$ > "$pid_file"

    log_info "Starting honeypot service on port $port ($service)"

    # Simple honeypot using netcat or socat
    if command -v socat >/dev/null 2>&1; then
        # Use socat for better control
        while true; do
            socat -T 10 TCP-LISTEN:"$port",reuseaddr,fork \
                  SYSTEM:"echo \"$(date +%s):\$SOCAT_PEERADDR:$port:connect\" >> \"$log_file\"; echo 'Connection logged - this is a honeypot!'; sleep 1" \
                  2>/dev/null || true
            sleep 1
        done
    elif command -v ncat >/dev/null 2>&1; then
        # Use ncat (nmap netcat)
        while true; do
            ncat -l -p "$port" -c "
                echo \"$(date +%s):\$NCAT_REMOTE_ADDR:\$NCAT_REMOTE_PORT:connect\" >> \"$log_file\"
                echo 'Connection logged - this is a honeypot!'
                sleep 2
            " 2>/dev/null || true
            sleep 1
        done
    elif command -v nc >/dev/null 2>&1; then
        # Fallback to traditional netcat
        while true; do
            nc -l -p "$port" -c "
                echo \"$(date +%s):\$(echo \$NCAT_REMOTE_ADDR 2>/dev/null || echo 'unknown'):\$(echo \$NCAT_REMOTE_PORT 2>/dev/null || echo '$port'):connect\" >> \"$log_file\"
                echo 'Connection logged - this is a honeypot!'
                sleep 2
            " 2>/dev/null || true
            sleep 1
        done
    else
        log_error "No suitable network tool found (socat, ncat, nc)"
        exit 1
    fi
}

# Export functions for use by other modules
export -f honeypot_init
export -f honeypot_deploy
export -f honeypot_undeploy
export -f honeypot_start_service
export -f honeypot_stop_service
export -f honeypot_monitor
export -f honeypot_status
export -f honeypot_list
export -f honeypot_detect_service
export -f honeypot_check_port_in_use
export -f honeypot_update_config
export -f honeypot_cleanup
export -f honeypot_run_service
