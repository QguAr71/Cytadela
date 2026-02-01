#!/usr/bin/env bats
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ - Test Helper Functions                                        ║
# ║  Common setup and teardown functions for BATS tests                           ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Determine project root
if [[ -z "${PROJECT_ROOT:-}" ]]; then
    PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
fi

# Export for tests
export PROJECT_ROOT

# Common setup function
setup() {
    # Create test fixtures directory
    mkdir -p "${PROJECT_ROOT}/tests/fixtures"
    
    # Set up test environment variables
    export CYTADELA_TEST_MODE=1
    export CYTADELA_STATE_DIR="${PROJECT_ROOT}/tests/test-state"
    export CYTADELA_LOG_DIR="${PROJECT_ROOT}/tests/test-logs"
    
    # Create test directories
    mkdir -p "$CYTADELA_STATE_DIR"
    mkdir -p "$CYTADELA_LOG_DIR"
}

# Common teardown function
teardown() {
    # Clean up test directories
    if [[ -d "${PROJECT_ROOT}/tests/fixtures" ]]; then
        rm -rf "${PROJECT_ROOT}/tests/fixtures"
    fi
    
    if [[ -d "$CYTADELA_STATE_DIR" ]]; then
        rm -rf "$CYTADELA_STATE_DIR"
    fi
    
    if [[ -d "$CYTADELA_LOG_DIR" ]]; then
        rm -rf "$CYTADELA_LOG_DIR"
    fi
    
    # Unset test environment variables
    unset CYTADELA_TEST_MODE
    unset CYTADELA_STATE_DIR
    unset CYTADELA_LOG_DIR
}

# Helper function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Helper function to check if service exists
service_exists() {
    systemctl list-unit-files | grep -q "$1"
}

# Helper function to check if port is in use
port_in_use() {
    local port="$1"
    if command_exists ss; then
        ss -tuln | grep -q ":$port "
    elif command_exists netstat; then
        netstat -tuln | grep -q ":$port "
    else
        return 1
    fi
}

# Helper function to create test config file
create_test_config() {
    local config_file="$1"
    local content="$2"
    
    mkdir -p "$(dirname "$config_file")"
    echo "$content" > "$config_file"
}

# Helper function to create test service
create_test_service() {
    local service_name="$1"
    local service_file="/etc/systemd/system/${service_name}.service"
    
    if [[ ! -f "$service_file" ]]; then
        create_test_config "$service_file" "[Unit]
Description=Test service for Cytadela++
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/echo 'Test service running'

[Install]
WantedBy=multi-user.target"
        
        systemctl daemon-reload
    fi
}

# Helper function to remove test service
remove_test_service() {
    local service_name="$1"
    local service_file="/etc/systemd/system/${service_name}.service"
    
    if [[ -f "$service_file" ]]; then
        systemctl stop "$service_name" 2>/dev/null || true
        systemctl disable "$service_name" 2>/dev/null || true
        rm -f "$service_file"
        systemctl daemon-reload
    fi
}

# Helper function to wait for service
wait_for_service() {
    local service_name="$1"
    local timeout="${2:-10}"
    local count=0
    
    while [ $count -lt $timeout ]; do
        if systemctl is-active "$service_name" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    
    return 1
}

# Helper function to check DNS resolution
check_dns_resolution() {
    local domain="$1"
    local server="${2:-}"
    
    if command_exists dig; then
        if [[ -n "$server" ]]; then
            dig +short "$domain" @"$server" >/dev/null 2>&1
        else
            dig +short "$domain" >/dev/null 2>&1
        fi
    elif command_exists nslookup; then
        nslookup "$domain" >/dev/null 2>&1
    else
        return 1
    fi
}

# Helper function to check network connectivity
check_connectivity() {
    local host="$1"
    local timeout="${2:-5}"
    
    if command_exists ping; then
        ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
    else
        return 1
    fi
}

# Helper function to create temporary file
create_temp_file() {
    local prefix="${1:-test}"
    local suffix="${2:-tmp}"
    
    mktemp -t "${prefix}.${suffix}"
}

# Helper function to capture command output
capture_output() {
    local cmd="$1"
    local output_file
    output_file=$(create_temp_file capture)
    
    if eval "$cmd" > "$output_file" 2>&1; then
        cat "$output_file"
        rm -f "$output_file"
        return 0
    else
        cat "$output_file"
        rm -f "$output_file"
        return 1
    fi
}

# Helper function to compare files
compare_files() {
    local file1="$1"
    local file2="$2"
    
    if [[ ! -f "$file1" ]] || [[ ! -f "$file2" ]]; then
        return 1
    fi
    
    diff -q "$file1" "$file2" >/dev/null 2>&1
}

# Helper function to count lines in file
count_lines() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        wc -l < "$file" | awk '{print $1}'
    else
        echo "0"
    fi
}

# Helper function to check file permissions
check_permissions() {
    local file="$1"
    local expected_perms="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    local actual_perms
    actual_perms=$(stat -c "%a" "$file" 2>/dev/null)
    
    [[ "$actual_perms" == "$expected_perms" ]]
}

# Helper function to check file ownership
check_ownership() {
    local file="$1"
    local expected_owner="$2"
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    local actual_owner
    actual_owner=$(stat -c "%U:%G" "$file" 2>/dev/null)
    
    [[ "$actual_owner" == "$expected_owner" ]]
}

# Helper function to create test blocklist
create_test_blocklist() {
    local blocklist_file="$1"
    local entries="${2:-10}"
    
    mkdir -p "$(dirname "$blocklist_file")"
    
    # Create test blocklist entries
    {
        echo "# Test blocklist"
        for i in $(seq 1 "$entries"); do
            echo "0.0.0.0 test$i.blocked.local"
        done
    } > "$blocklist_file"
}

# Helper function to validate blocklist format
validate_blocklist() {
    local blocklist_file="$1"
    
    if [[ ! -f "$blocklist_file" ]]; then
        return 1
    fi
    
    # Check if file has valid entries
    local valid_entries
    valid_entries=$(grep -v "^#" "$blocklist_file" | grep -v "^$" | wc -l)
    
    [[ "$valid_entries" -gt 0 ]]
}

# Helper function to simulate network delay
simulate_delay() {
    local delay_ms="${1:-100}"
    
    if command_exists tc; then
        # Use tc if available (requires root)
        tc qdisc add dev lo root netem delay "${delay_ms}ms" 2>/dev/null || true
        sleep 0.1
        tc qdisc del dev lo root 2>/dev/null || true
    else
        # Fallback to sleep
        sleep "$(echo "scale=3; $delay_ms / 1000" | bc -l)"
    fi
}

# Helper function to test function existence
function_exists() {
    local function_name="$1"
    declare -f "$function_name" >/dev/null 2>&1
}

# Helper function to test variable existence
variable_exists() {
    local var_name="$1"
    [[ -n "${!var_name:-}" ]]
}

# Helper function to get random port
get_random_port() {
    local min="${1:-10000"
    local max="${2:-20000"
    
    # Generate random port in range
    echo $((RANDOM % (max - min + 1) + min))
}

# Helper function to check if port is available
is_port_available() {
    local port="$1"
    
    if port_in_use "$port"; then
        return 1
    else
        return 0
    fi
}

# Helper function to get available port
get_available_port() {
    local min="${1:-10000"
    local max="${2:-20000"
    local max_attempts="${3:-100}"
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local port
        port=$(get_random_port "$min" "$max")
        
        if is_port_available "$port"; then
            echo "$port"
            return 0
        fi
        
        attempt=$((attempt + 1))
    done
    
    return 1
}

# Helper function to create test network namespace
create_test_namespace() {
    local ns_name="$1"
    
    if command_exists ip; then
        ip netns add "$ns_name" 2>/dev/null || true
        ip netns exec "$ns_name" ip link set lo up 2>/dev/null || true
    fi
}

# Helper function to remove test network namespace
remove_test_namespace() {
    local ns_name="$1"
    
    if command_exists ip; then
        ip netns delete "$ns_name" 2>/dev/null || true
    fi
}

# Export helper functions for use in tests
export -f setup teardown
export -f command_exists service_exists port_in_use
export -f create_test_config create_test_service remove_test_service
export -f wait_for_service check_dns_resolution check_connectivity
export -f create_temp_file capture_output compare_files
export -f count_lines check_permissions check_ownership
export -f create_test_blocklist validate_blocklist
export -f simulate_delay function_exists variable_exists
export -f get_random_port is_port_available get_available_port
export -f create_test_namespace remove_test_namespace
