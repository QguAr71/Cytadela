#!/bin/bash

# Citadel Advanced Management Features
# Handles systemd integration, service management, and advanced monitoring

# Service management constants
SERVICE_PREFIX="citadel"
SERVICE_DIR="/etc/systemd/system"
CONFIG_DIR="/etc/citadel"
LOG_DIR="/var/log/citadel"
RUN_DIR="/var/run/citadel"

# Service templates
declare -A SERVICE_TEMPLATES

# Initialize advanced management features
advanced_management_init() {
    echo "Initializing advanced management features..."

    # Create necessary directories
    create_directories

    # Setup service templates
    setup_service_templates

    # Initialize systemd integration
    systemd_integration_init

    echo "Advanced management features initialized"
}

# Create necessary directories for Citadel services
create_directories() {
    echo "Creating Citadel directories..."

    # Create directories with proper permissions
    sudo mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$RUN_DIR"

    # Set proper ownership and permissions
    sudo chown root:root "$CONFIG_DIR"
    sudo chmod 755 "$CONFIG_DIR"

    sudo chown root:systemd-journal "$LOG_DIR"
    sudo chmod 755 "$LOG_DIR"

    sudo chown root:root "$RUN_DIR"
    sudo chmod 755 "$RUN_DIR"

    echo "Directories created successfully"
}

# Setup service templates for different Citadel components
setup_service_templates() {
    echo "Setting up service templates..."

    # Main Citadel service template
    SERVICE_TEMPLATES["citadel-main"]="[Unit]
Description=Citadel Main Service
After=network.target systemd-modules-load.service
Wants=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/citadel.sh daemon
ExecReload=/usr/local/bin/citadel.sh reload
ExecStop=/usr/local/bin/citadel.sh stop
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=citadel-main
Environment=CITADEL_CONFIG=/etc/citadel/config.yaml
Environment=CITADEL_LOG_LEVEL=info

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/etc/citadel /var/log/citadel /var/run/citadel
InaccessiblePaths=/home /root /boot /sys /proc /dev

# Resource limits
LimitNOFILE=65536
MemoryLimit=512M
CPUQuota=50%

[Install]
WantedBy=multi-user.target"

    # Security monitoring service template
    SERVICE_TEMPLATES["citadel-security"]="[Unit]
Description=Citadel Security Monitoring
After=citadel-main.service network.target
PartOf=citadel-main.service

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/citadel.sh security monitor
ExecStop=/usr/local/bin/citadel.sh security stop
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=citadel-security

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/etc/citadel /var/log/citadel /var/run/citadel
InaccessiblePaths=/home /root

# Resource limits
LimitNOFILE=32768
MemoryLimit=256M

[Install]
WantedBy=multi-user.target"

    # Event logging service template
    SERVICE_TEMPLATES["citadel-events"]="[Unit]
Description=Citadel Event Logger
After=citadel-main.service
PartOf=citadel-main.service

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/citadel.sh events start
ExecStop=/usr/local/bin/citadel.sh events stop
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=citadel-events

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/var/log/citadel
InaccessiblePaths=/home /root /etc

# Resource limits
LimitNOFILE=16384
MemoryLimit=128M

[Install]
WantedBy=multi-user.target"

    # Honeypot service template
    SERVICE_TEMPLATES["citadel-honeypot"]="[Unit]
Description=Citadel Honeypot Service
After=citadel-main.service network.target
PartOf=citadel-main.service

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/citadel.sh honeypot start
ExecStop=/usr/local/bin/citadel.sh honeypot stop
Restart=always
RestartSec=15
StandardOutput=journal
StandardError=journal
SyslogIdentifier=citadel-honeypot

# Security settings
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/var/log/citadel /var/run/citadel
InaccessiblePaths=/home /root /etc

# Resource limits
LimitNOFILE=8192
MemoryLimit=64M

[Install]
WantedBy=multi-user.target"

    echo "Service templates configured"
}

# Initialize systemd integration
systemd_integration_init() {
    echo "Initializing systemd integration..."

    # Check if systemd is available
    if ! command -v systemctl >/dev/null 2>&1; then
        echo "Warning: systemctl not available, systemd integration disabled"
        return 1
    fi

    # Reload systemd daemon
    sudo systemctl daemon-reload

    echo "Systemd integration initialized"
}

# Create a systemd service file
service_create() {
    local service_name="$1"
    local template_name="$2"

    if [[ -z "${SERVICE_TEMPLATES[$template_name]}" ]]; then
        echo "Error: Service template '$template_name' not found"
        return 1
    fi

    local service_file="$SERVICE_DIR/${SERVICE_PREFIX}-${service_name}.service"

    echo "Creating service file: $service_file"

    # Write service file
    echo "${SERVICE_TEMPLATES[$template_name]}" | sudo tee "$service_file" > /dev/null

    # Set proper permissions
    sudo chmod 644 "$service_file"

    # Reload systemd
    sudo systemctl daemon-reload

    echo "Service '$service_name' created successfully"
}

# Remove a systemd service
service_remove() {
    local service_name="$1"
    local service_file="$SERVICE_DIR/${SERVICE_PREFIX}-${service_name}.service"

    echo "Removing service: $service_name"

    # Stop service if running
    sudo systemctl stop "${SERVICE_PREFIX}-${service_name}.service" 2>/dev/null || true

    # Disable service
    sudo systemctl disable "${SERVICE_PREFIX}-${service_name}.service" 2>/dev/null || true

    # Remove service file
    if [[ -f "$service_file" ]]; then
        sudo rm "$service_file"
    fi

    # Reload systemd
    sudo systemctl daemon-reload

    echo "Service '$service_name' removed successfully"
}

# Start a service
service_start() {
    local service_name="$1"
    local service_unit="${SERVICE_PREFIX}-${service_name}.service"

    echo "Starting service: $service_name"

    if ! sudo systemctl start "$service_unit"; then
        echo "Error: Failed to start service '$service_name'"
        return 1
    fi

    echo "Service '$service_name' started successfully"
}

# Stop a service
service_stop() {
    local service_name="$1"
    local service_unit="${SERVICE_PREFIX}-${service_name}.service"

    echo "Stopping service: $service_name"

    if ! sudo systemctl stop "$service_unit"; then
        echo "Error: Failed to stop service '$service_name'"
        return 1
    fi

    echo "Service '$service_name' stopped successfully"
}

# Restart a service
service_restart() {
    local service_name="$1"
    local service_unit="${SERVICE_PREFIX}-${service_name}.service"

    echo "Restarting service: $service_name"

    if ! sudo systemctl restart "$service_unit"; then
        echo "Error: Failed to restart service '$service_name'"
        return 1
    fi

    echo "Service '$service_name' restarted successfully"
}

# Enable a service for auto-start
service_enable() {
    local service_name="$1"
    local service_unit="${SERVICE_PREFIX}-${service_name}.service"

    echo "Enabling service: $service_name"

    if ! sudo systemctl enable "$service_unit"; then
        echo "Error: Failed to enable service '$service_name'"
        return 1
    fi

    echo "Service '$service_name' enabled for auto-start"
}

# Disable a service from auto-start
service_disable() {
    local service_name="$1"
    local service_unit="${SERVICE_PREFIX}-${service_name}.service"

    echo "Disabling service: $service_name"

    if ! sudo systemctl disable "$service_unit"; then
        echo "Error: Failed to disable service '$service_name'"
        return 1
    fi

    echo "Service '$service_name' disabled from auto-start"
}

# Get service status
service_status() {
    local service_name="$1"
    local service_unit="${SERVICE_PREFIX}-${service_name}.service"

    echo "Status of service: $service_name"
    echo "================================="

    if ! sudo systemctl status "$service_unit" --no-pager -l; then
        echo "Error: Failed to get status for service '$service_name'"
        return 1
    fi
}

# List all Citadel services
service_list() {
    echo "Citadel Services:"
    echo "================="

    local services
    services=$(systemctl list-units --type=service --no-pager --no-legend | grep "^${SERVICE_PREFIX}-" | awk '{print $1}' || true)

    if [[ -z "$services" ]]; then
        echo "No Citadel services found"
        return 0
    fi

    echo "$services" | while read -r service_unit; do
        local service_name="${service_unit%.service}"
        service_name="${service_name#${SERVICE_PREFIX}-}"

        local state
        state=$(systemctl is-active "$service_unit" 2>/dev/null || echo "unknown")

        local enabled
        enabled=$(systemctl is-enabled "$service_unit" 2>/dev/null || echo "unknown")

        printf "  %-15s %-10s %-10s\n" "$service_name" "$state" "$enabled"
    done

    echo ""
    echo "Legend: State(active/inactive), Enabled(yes/no/static)"
}

# Setup all Citadel services
service_setup_all() {
    echo "Setting up all Citadel services..."

    # Create main service
    service_create "main" "citadel-main"

    # Create security service
    service_create "security" "citadel-security"

    # Create events service
    service_create "events" "citadel-events"

    # Create honeypot service
    service_create "honeypot" "citadel-honeypot"

    echo "All Citadel services created"
}

# Remove all Citadel services
service_remove_all() {
    echo "Removing all Citadel services..."

    # Get list of services to remove
    local services=("honeypot" "events" "security" "main")

    for service_name in "${services[@]}"; do
        service_remove "$service_name"
    done

    echo "All Citadel services removed"
}

# Advanced monitoring functions
monitoring_init() {
    echo "Initializing advanced monitoring..."

    # Setup monitoring directories
    sudo mkdir -p /var/lib/citadel/monitoring
    sudo chown root:root /var/lib/citadel/monitoring
    sudo chmod 755 /var/lib/citadel/monitoring

    echo "Advanced monitoring initialized"
}

# Get system health status
monitoring_health_check() {
    echo "Citadel System Health Check"
    echo "==========================="

    local issues=0

    # Check systemd services
    echo "Checking Citadel services..."
    local services=("citadel-main" "citadel-security" "citadel-events" "citadel-honeypot")

    for service in "${services[@]}"; do
        local status
        status=$(systemctl is-active "${service}.service" 2>/dev/null | head -1 || echo "not-found")

        if [[ "$status" == "active" ]]; then
            echo "  ✓ $service: running"
        elif [[ "$status" == "not-found" ]]; then
            echo "  - $service: not installed"
        else
            echo "  ✗ $service: $status"
            issues=$((issues + 1))
        fi
    done

    # Check configuration
    echo ""
    echo "Checking configuration..."
    if [[ -f "/etc/citadel/config.yaml" ]]; then
        echo "  ✓ Configuration file exists"
    else
        echo "  ✗ Configuration file missing"
        ((issues++))
    fi

    # Check directories
    echo ""
    echo "Checking directories..."
    local dirs=("/etc/citadel" "/var/log/citadel" "/var/run/citadel")

    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "  ✓ $dir: exists"
        else
            echo "  ✗ $dir: missing"
            ((issues++))
        fi
    done

    # Summary
    echo ""
    echo "Health Check Summary:"
    if [[ $issues -eq 0 ]]; then
        echo "  ✓ All systems healthy"
    else
        echo "  ✗ $issues issues found"
    fi
}

# Get detailed system information
monitoring_system_info() {
    echo "Citadel System Information"
    echo "=========================="

    echo "System:"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Architecture: $(uname -m)"
    echo "  Uptime: $(uptime -p)"

    echo ""
    echo "Citadel:"
    echo "  Version: v3.3.0"
    echo "  Config: /etc/citadel/config.yaml"
    echo "  Logs: /var/log/citadel/"
    echo "  Runtime: /var/run/citadel/"

    echo ""
    echo "Services:"
    service_list

    echo ""
    echo "Resources:"
    echo "  CPU: $(nproc) cores"
    echo "  Memory: $(free -h | grep '^Mem:' | awk '{print $2}') total"
    echo "  Disk: $(df -h / | tail -1 | awk '{print $2}') total on /"
}

# Export functions for external use
export -f advanced_management_init
export -f service_create
export -f service_remove
export -f service_start
export -f service_stop
export -f service_restart
export -f service_enable
export -f service_disable
export -f service_status
export -f service_list
export -f service_setup_all
export -f service_remove_all
export -f monitoring_init
export -f monitoring_health_check
export -f monitoring_system_info
