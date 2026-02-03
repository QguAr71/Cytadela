#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ SUPPLY-CHAIN MODULE v3.1                                      ║
# ║  Supply-chain verification for downloads                                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

SUPPLY_CHAIN_CHECKSUMS="/etc/cytadela/checksums.sha256"

supply_chain_verify_file() {
    local file="$1"
    local expected_hash="$2"

    [[ ! -f "$file" ]] && {
        log_error "File not found: $file"
        return 2
    }

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

    mv "$staging" "$dest"
    log_success "Downloaded: $dest"
    return 0
}

supply_chain_status() {
    draw_section_header "🔐 SUPPLY-CHAIN STATUS"

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
    draw_section_header "🔐 SUPPLY-CHAIN INIT"

    mkdir -p "$(dirname "$SUPPLY_CHAIN_CHECKSUMS")"

    local tmp
    tmp=$(mktemp)

    echo "# Cytadela Supply-Chain Checksums" >"$tmp"
    echo "# Generated: $(date -Iseconds)" >>"$tmp"
    echo "# Format: sha256  url  description" >>"$tmp"
    echo "" >>"$tmp"

    log_info "Fetching current blocklist hash..."
    local blocklist_url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.txt"
    local blocklist_hash
    blocklist_hash=$(curl -sSL --connect-timeout 10 "$blocklist_url" 2>/dev/null | sha256sum | awk '{print $1}')

    if [[ -n "$blocklist_hash" && "$blocklist_hash" != "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]]; then
        echo "$blocklist_hash  $blocklist_url  # Hagezi Pro blocklist" >>"$tmp"
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
    echo ""
    echo -e "${VIO}╔══════════════════════════════════════════════════════════════╗${NC}"
    printf "${VIO}║${NC} %b%*s ${VIO}║${NC}\n" "${BOLD}🔐 SUPPLY-CHAIN VERIFY${NC}" $((60 - 21)) ""
    echo -e "${VIO}╚══════════════════════════════════════════════════════════════╝${NC}"

    if [[ ! -f "$SUPPLY_CHAIN_CHECKSUMS" ]]; then
        log_warning "No checksums file. Run 'supply-chain-init' first."
        return 0
    fi

    local errors=0

    if [[ -f "$CYTADELA_MANIFEST" ]]; then
        log_info "Verifying integrity manifest..."
        while IFS=$'\t' read -r hash filepath; do
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
        done <"$CYTADELA_MANIFEST"
    fi

    if [[ $errors -eq 0 ]]; then
        log_success "All supply-chain checks passed"
    else
        log_error "$errors verification error(s)"
        return 1
    fi
}
