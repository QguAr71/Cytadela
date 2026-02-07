#!/bin/bash
# Citadel Advanced Port Manager v1.0
# Comprehensive DNS port detection, conflict resolution and health checking

# DNS Ports used by Citadel
DNS_STANDARD_PORT=53
DNS_DOH_BASE_PORT=5353
DNS_DOH_PORT_RANGE=(5353 5354 5355 5356 5357 5358 5359)

# Port status cache
declare -A PORT_STATUS_CACHE

# ==============================================================================
# FALLBACK LOGGING FUNCTIONS (for standalone operation)
# ==============================================================================

# Define fallback logging functions if not already defined
if ! declare -f log_section >/dev/null 2>&1; then
    log_section() { echo ""; echo "=== $* ==="; }
fi
if ! declare -f log_info >/dev/null 2>&1; then
    log_info() { echo "[INFO] $*"; }
fi
if ! declare -f log_success >/dev/null 2>&1; then
    log_success() { echo "[OK] $*"; }
fi
if ! declare -f log_warning >/dev/null 2>&1; then
    log_warning() { echo "[WARN] $*" >&2; }
fi
if ! declare -f log_error >/dev/null 2>&1; then
    log_error() { echo "[ERROR] $*" >&2; }
fi

# ==============================================================================
# PORT DETECTION FUNCTIONS
# ==============================================================================

# Check if port is in use by any process
port_is_in_use() {
    local port="$1"
    if lsof -i :"$port" >/dev/null 2>&1 || ss -tlnp 2>/dev/null | grep -q ":$port"; then
        return 0
    fi
    return 1
}

# Get process using a port
port_get_process() {
    local port="$1"
    local process
    process=$(lsof -i :"$port" 2>/dev/null | tail -n +2 | head -1 | awk '{print $1}')
    if [[ -z "$process" ]]; then
        process=$(ss -tlnp 2>/dev/null | grep ":$port" | grep -oP 'users:\(\("\K[^"]+' | head -1 | cut -d',' -f1)
    fi
    echo "$process"
}

# Check if Citadel service is using port
port_is_citadel_service() {
    local port="$1"
    local process
    process=$(port_get_process "$port")
    [[ "$process" =~ ^(dnscrypt-proxy|coredns)$ ]]
}

# ==============================================================================
# DNS PORT SCANNING
# ==============================================================================

# Scan all DNS-related ports and return status
port_scan_dns_ports() {
    log_info "Skanowanie portów DNS..."
    
    local results=()
    local port
    local status
    local process
    
    # Check standard DNS port
    port="$DNS_STANDARD_PORT"
    if port_is_in_use "$port"; then
        process=$(port_get_process "$port")
        if port_is_citadel_service "$port"; then
            status="citadel"
        else
            status="conflict:$process"
        fi
    else
        status="free"
    fi
    results+=("$port:$status")
    PORT_STATUS_CACHE[$port]="$status"
    
    # Check DoH ports
    for port in "${DNS_DOH_PORT_RANGE[@]}"; do
        if port_is_in_use "$port"; then
            process=$(port_get_process "$port")
            if port_is_citadel_service "$port"; then
                status="citadel"
            else
                status="conflict:$process"
            fi
        else
            status="free"
        fi
        results+=("$port:$status")
        PORT_STATUS_CACHE[$port]="$status"
    done
    
    printf '%s\n' "${results[@]}"
}

# Find first available port in range
port_find_available() {
    local start_port="${1:-$DNS_DOH_BASE_PORT}"
    local end_port="${2:-5359}"
    local port
    
    for ((port=start_port; port<=end_port; port++)); do
        if ! port_is_in_use "$port"; then
            echo "$port"
            return 0
        fi
    done
    return 1
}

# ==============================================================================
# CONFLICT DETECTION
# ==============================================================================

# Check for critical port conflicts before installation
port_check_conflicts() {
    log_section "🔍 DETEKCJA KONFLIKTÓW PORTÓW"
    
    local conflicts=()
    local warnings=()
    local port
    local status
    local process
    
    # Scan all ports
    while IFS=: read -r port status; do
        case "$status" in
            conflict:*)
                process="${status#conflict:}"
                if [[ "$port" == "$DNS_STANDARD_PORT" ]]; then
                    conflicts+=("KRYTYCZNY: Port $port zajęty przez $process - DNS nie zadziała!")
                else
                    warnings+=("Ostrzeżenie: Port $port zajęty przez $process")
                fi
                ;;
        esac
    done < <(port_scan_dns_ports)
    
    # Report findings
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        log_error "Znaleziono krytyczne konflikty portów:"
        printf '  • %s\n' "${conflicts[@]}"
        return 1
    fi
    
    if [[ ${#warnings[@]} -gt 0 ]]; then
        log_warning "Znaleziono konflikty portów (można ominąć):"
        printf '  • %s\n' "${warnings[@]}"
    fi
    
    log_success "Brak krytycznych konfliktów portów"
    return 0
}

# ==============================================================================
# PORT RESERVATION SYSTEM
# ==============================================================================

PORT_RESERVATION_FILE="${CYTADELA_STATE_DIR:-/var/lib/cytadela}/port-reservations.conf"

# Reserve a port for Citadel use
port_reserve() {
    local service="$1"
    local port="$2"
    local timestamp
    timestamp=$(date +%s)
    
    mkdir -p "$(dirname "$PORT_RESERVATION_FILE")"
    echo "${service}:${port}:${timestamp}" >> "$PORT_RESERVATION_FILE"
    log_info "Zarezerwowano port $port dla $service"
}

# Release port reservation
port_release() {
    local service="$1"
    local port="$2"
    
    if [[ -f "$PORT_RESERVATION_FILE" ]]; then
        sed -i "/^${service}:${port}:/d" "$PORT_RESERVATION_FILE"
    fi
}

# Get reserved port for service
port_get_reserved() {
    local service="$1"
    
    if [[ -f "$PORT_RESERVATION_FILE" ]]; then
        grep "^${service}:" "$PORT_RESERVATION_FILE" | tail -1 | cut -d':' -f2
    fi
}

# ==============================================================================
# HEALTH CHECK
# ==============================================================================

# Test DNS on specific port
port_test_dns() {
    local port="$1"
    local test_domain="${2:-whoami.cloudflare}"
    
    if dig +short +time=3 "@127.0.0.1" -p "$port" "$test_domain" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Health check all Citadel DNS ports
port_health_check() {
    log_section "🏥 HEALTH CHECK PORTÓW DNS"
    
    local all_healthy=true
    local port
    local status
    
    while IFS=: read -r port status; do
        case "$status" in
            citadel)
                if port_test_dns "$port"; then
                    log_success "Port $port: DNS działa ✓"
                else
                    log_error "Port $port: DNS NIE DZIAŁA ✗"
                    all_healthy=false
                fi
                ;;
            free)
                log_info "Port $port: wolny"
                ;;
        esac
    done < <(port_scan_dns_ports)
    
    if [[ "$all_healthy" == true ]]; then
        log_success "Wszystkie porty Citadel działają poprawnie"
        return 0
    else
        log_error "Niektóre porty nie działą - wymagana naprawa"
        return 1
    fi
}

# ==============================================================================
# DOH PARALLEL PORT ASSIGNMENT
# ==============================================================================

# Find and reserve port for DoH parallel
port_assign_doh() {
    log_info "Szukanie wolnego portu dla DoH Parallel..."
    
    # First check if there's already a reserved port
    local reserved_port
    reserved_port=$(port_get_reserved "doh-parallel")
    if [[ -n "$reserved_port" ]] && ! port_is_in_use "$reserved_port"; then
        log_info "Używam zarezerwowanego portu: $reserved_port"
        echo "$reserved_port"
        return 0
    fi
    
    # Find available port
    local available_port
    available_port=$(port_find_available)
    if [[ -z "$available_port" ]]; then
        log_error "Brak wolnych portów DNS (5353-5359)"
        return 1
    fi
    
    # Reserve the port
    port_reserve "doh-parallel" "$available_port"
    
    log_success "Przypisano port $available_port dla DoH Parallel"
    echo "$available_port"
}

# ==============================================================================
# EMERGENCY RECOVERY
# ==============================================================================

# Emergency port cleanup (kill conflicting processes)
port_emergency_cleanup() {
    log_warning "EMERGENCY: Czyszczenie portów DNS..."
    
    local port
    local process
    local killed=false
    
    for port in "$DNS_STANDARD_PORT" "${DNS_DOH_PORT_RANGE[@]}"; do
        if port_is_in_use "$port"; then
            process=$(port_get_process "$port")
            if [[ -n "$process" ]] && [[ ! "$process" =~ ^(dnscrypt-proxy|coredns)$ ]]; then
                log_info "Zatrzymywanie $process na porcie $port..."
                pkill -f "$process" 2>/dev/null || true
                killed=true
            fi
        fi
    done
    
    sleep 2
    
    if [[ "$killed" == true ]]; then
        log_info "Sprawdzanie dostępności portów po czyszczeniu..."
        port_scan_dns_ports
    fi
}

# Restore port reservations from backup
port_restore_reservations() {
    if [[ -f "$PORT_RESERVATION_FILE" ]]; then
        log_info "Przywracanie rezerwacji portów..."
        cat "$PORT_RESERVATION_FILE"
    fi
}
