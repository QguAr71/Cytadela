#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ LKG MODULE v3.1                                               ║
# ║  Last Known Good - Blocklist Cache Management (Issue #1)                  ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

LKG_BLOCKLIST="${CYTADELA_LKG_DIR}/blocklist.hosts"
LKG_BLOCKLIST_META="${CYTADELA_LKG_DIR}/blocklist.meta"

lkg_validate_blocklist() {
    local file="$1"
    local min_lines=1000
    
    [[ ! -f "$file" ]] && return 1
    
    local lines
    lines=$(wc -l < "$file")
    [[ $lines -lt $min_lines ]] && { log_warning "LKG: File too small ($lines lines, min $min_lines): $file"; return 1; }
    
    if grep -qiE '<html|<!DOCTYPE|AccessDenied|404 Not Found|403 Forbidden' "$file" 2>/dev/null; then
        log_warning "LKG: File looks like error page: $file"
        return 1
    fi
    
    if ! head -100 "$file" | grep -qE '^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]' 2>/dev/null; then
        log_warning "LKG: File doesn't look like hosts format: $file"
        return 1
    fi
    
    return 0
}

lkg_save_blocklist() {
    local source="/etc/coredns/zones/blocklist.hosts"
    
    [[ ! -f "$source" ]] && { log_warning "LKG: No blocklist to save"; return 1; }
    
    if ! lkg_validate_blocklist "$source"; then
        log_warning "LKG: Current blocklist failed validation, not saving"
        return 1
    fi
    
    mkdir -p "$CYTADELA_LKG_DIR"
    cp "$source" "$LKG_BLOCKLIST"
    echo "saved=$(date -Iseconds)" > "$LKG_BLOCKLIST_META"
    echo "lines=$(wc -l < "$LKG_BLOCKLIST")" >> "$LKG_BLOCKLIST_META"
    echo "sha256=$(sha256sum "$LKG_BLOCKLIST" | awk '{print $1}')" >> "$LKG_BLOCKLIST_META"
    
    log_success "LKG: Blocklist saved ($(wc -l < "$LKG_BLOCKLIST") lines)"
}

lkg_restore_blocklist() {
    local target="/etc/coredns/zones/blocklist.hosts"
    
    [[ ! -f "$LKG_BLOCKLIST" ]] && { log_warning "LKG: No saved blocklist to restore"; return 1; }
    
    if ! lkg_validate_blocklist "$LKG_BLOCKLIST"; then
        log_error "LKG: Saved blocklist failed validation"
        return 1
    fi
    
    cp "$LKG_BLOCKLIST" "$target"
    chown root:coredns "$target" 2>/dev/null || true
    chmod 0640 "$target" 2>/dev/null || true
    
    log_success "LKG: Blocklist restored from cache"
}

lkg_status() {
    log_section "📦 LKG (Last Known Good) STATUS"
    
    echo "LKG Directory: $CYTADELA_LKG_DIR"
    
    if [[ -f "$LKG_BLOCKLIST" ]]; then
        echo "Blocklist cache: EXISTS"
        echo "  Lines: $(wc -l < "$LKG_BLOCKLIST")"
        [[ -f "$LKG_BLOCKLIST_META" ]] && cat "$LKG_BLOCKLIST_META" | sed 's/^/  /'
    else
        echo "Blocklist cache: NOT FOUND"
        echo "  Run: sudo $0 lkg-save"
    fi
}

lists_update() {
    log_section "📥 LISTS UPDATE (with LKG fallback)"
    
    local blocklist_url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.txt"
    local staging_file
    staging_file=$(mktemp)
    local target="/etc/coredns/zones/blocklist.hosts"
    
    log_info "Downloading fresh blocklist..."
    
    if curl -sSL --connect-timeout 10 --max-time 60 "$blocklist_url" -o "$staging_file" 2>/dev/null; then
        log_info "Download complete. Validating..."
        
        if lkg_validate_blocklist "$staging_file"; then
            mv "$staging_file" "$target"
            chown root:coredns "$target" 2>/dev/null || true
            chmod 0640 "$target" 2>/dev/null || true
            
            log_success "Blocklist updated ($(wc -l < "$target") lines)"
            
            lkg_save_blocklist
            
            # Load adblock module if not loaded
            if ! declare -f adblock_rebuild >/dev/null 2>&1; then
                load_module "adblock"
            fi
            
            adblock_rebuild
            adblock_reload
            log_success "Adblock rebuilt + CoreDNS reloaded"
        else
            log_warning "Downloaded blocklist failed validation"
            rm -f "$staging_file"
            log_info "Keeping current blocklist"
        fi
    else
        log_warning "Download failed. Using LKG fallback..."
        rm -f "$staging_file"
        
        if lkg_restore_blocklist; then
            if ! declare -f adblock_rebuild >/dev/null 2>&1; then
                load_module "adblock"
            fi
            adblock_rebuild
            adblock_reload
            log_success "Restored from LKG cache"
        else
            log_warning "No LKG available. Keeping current blocklist."
        fi
    fi
}
