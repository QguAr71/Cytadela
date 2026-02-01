#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ LOCATION MODULE v3.1                                          ║
# ║  Location-aware advisory (SSID-based security)                            ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

TRUSTED_SSIDS_FILE="/etc/cytadela/trusted-ssids.txt"

location_get_ssid() {
    local ssid=""
    if command -v nmcli &>/dev/null; then
        # Support multiple locales: yes/tak/ja/si/sì/oui/да (EN/PL/DE/ES/IT/FR/RU)
        ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -E '^(yes|tak|ja|si|sì|oui|да):' | cut -d: -f2 | head -1)
    fi
    echo "$ssid"
}

location_is_trusted() {
    local ssid="$1"

    [[ -z "$ssid" ]] && return 1
    [[ ! -f "$TRUSTED_SSIDS_FILE" ]] && return 1

    grep -qxF "$ssid" "$TRUSTED_SSIDS_FILE" 2>/dev/null && return 0 || return 1
}

location_get_firewall_mode() {
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
        is_trusted=1
    fi

    echo "Firewall mode: $fw_mode"
    echo ""

    if [[ $is_trusted -eq 0 && "$fw_mode" == "SAFE" ]]; then
        log_warning "You are on an UNTRUSTED network with SAFE firewall!"
        log_info "Recommendation: Switch to STRICT mode for better protection"

        if [[ -t 0 && -t 1 ]]; then
            echo -n "Switch to STRICT mode? [y/N]: "
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                if ! declare -f firewall_strict >/dev/null 2>&1; then
                    load_module "install-nftables"
                fi
                firewall_strict
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
        echo "$ssid" >>"$TRUSTED_SSIDS_FILE"
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
        grep -vxF "$ssid" "$TRUSTED_SSIDS_FILE" >"${TRUSTED_SSIDS_FILE}.tmp"
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
