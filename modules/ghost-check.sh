#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ GHOST-CHECK MODULE v3.1                                       ║
# ║  Port Exposure Audit                                                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

GHOST_ALLOWED_PORTS=(22 53 5353 9153)

ghost_check() {
    log_section "👻 GHOST-CHECK: Port Exposure Audit"

    # Ensure network-utils functions are available
    if ! declare -f discover_active_interface >/dev/null 2>&1; then
        source_lib "${CYTADELA_LIB}/network-utils.sh"
    fi

    local warnings=0
    # shellcheck disable=SC2034
    local iface
    iface=$(discover_active_interface)

    log_info "Scanning listening sockets..."
    echo ""

    echo "=== LISTENING SOCKETS ==="
    printf "%-8s %-25s %-20s %s\n" "PROTO" "LOCAL ADDRESS" "STATE" "PROCESS"
    echo "-------------------------------------------------------------------"

    while IFS= read -r line; do
        local proto addr state process port bind_addr
        proto=$(echo "$line" | awk '{print $1}')
        addr=$(echo "$line" | awk '{print $5}')
        state=$(echo "$line" | awk '{print $2}')
        process=$(echo "$line" | awk '{print $7}' | sed 's/users:(("//' | sed 's/".*$//')

        port=$(echo "$addr" | grep -oE '[0-9]+$')
        bind_addr=$(echo "$addr" | sed "s/:${port}$//")

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

        if [[ $exposed -eq 1 ]]; then
            local allowed=0
            for p in "${GHOST_ALLOWED_PORTS[@]}"; do
                [[ "$port" == "$p" ]] && {
                    allowed=1
                    break
                }
            done

            if [[ $allowed -eq 0 ]]; then
                printf "${YELLOW}%-8s %-25s %-20s %s${NC} 󰀨 EXPOSED (%s)\n" "$proto" "$addr" "$state" "$process" "$exposure_type"
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
