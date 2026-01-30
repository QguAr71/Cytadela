#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ BLOCKLIST-MANAGER MODULE v3.1                                 ║
# ║  Multi-blocklist support with profiles (Issue #17)                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

BLOCKLIST_PROFILE_FILE="/var/lib/cytadela/blocklist-profile.txt"
BLOCKLIST_CUSTOM_URLS="/var/lib/cytadela/blocklist-custom-urls.txt"

# Profile definitions: name|description|urls (space-separated)
declare -A BLOCKLIST_PROFILES=(
    [light]="Light|Fast, minimal blocking (~50k domains)|https://small.oisd.nl"
    
    [balanced]="Balanced|Default profile (~1.2M domains)|https://big.oisd.nl https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/light.txt"
    
    [aggressive]="Aggressive|Maximum blocking (~2M+ domains)|https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.plus.txt https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts https://raw.githubusercontent.com/badmojr/1Hosts/master/Pro/hosts.txt"
    
    [privacy]="Privacy|Focus on telemetry & tracking|https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/tif.txt https://raw.githubusercontent.com/nextdns/metadata/master/privacy/native/tracking https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
    
    [polish]="Polish|Optimized for Poland|https://raw.githubusercontent.com/FiltersHeroes/KADhosts/master/KADhosts.txt https://raw.githubusercontent.com/PolishFiltersTeam/PolishAnnoyanceFilters/master/PPB.txt https://hole.cert.pl/domains/domains_hosts.txt https://big.oisd.nl"
    
    [custom]="Custom|User-defined URLs|CUSTOM"
)

blocklist_list() {
    log_section "📋 AVAILABLE BLOCKLIST PROFILES"
    
    local current_profile=$(cat "$BLOCKLIST_PROFILE_FILE" 2>/dev/null || echo "balanced")
    
    echo "Available profiles:"
    echo ""
    
    for profile in light balanced aggressive privacy polish custom; do
        IFS='|' read -r name desc urls <<< "${BLOCKLIST_PROFILES[$profile]}"
        
        if [[ "$profile" == "$current_profile" ]]; then
            printf "  ${GREEN}✓ %-12s${NC} %s\n" "$profile" "$desc"
        else
            printf "    %-12s %s\n" "$profile" "$desc"
        fi
    done
    
    echo ""
    echo "Current profile: ${GREEN}$current_profile${NC}"
    echo ""
    echo "Usage: sudo cytadela++ blocklist-switch <profile>"
}

blocklist_switch() {
    local new_profile="$1"
    
    if [[ -z "$new_profile" ]]; then
        log_error "Usage: blocklist-switch <profile>"
        echo ""
        blocklist_list
        return 1
    fi
    
    if [[ -z "${BLOCKLIST_PROFILES[$new_profile]}" ]]; then
        log_error "Unknown profile: $new_profile"
        echo ""
        blocklist_list
        return 1
    fi
    
    log_section "🔄 SWITCHING BLOCKLIST PROFILE"
    
    local current_profile=$(cat "$BLOCKLIST_PROFILE_FILE" 2>/dev/null || echo "balanced")
    
    if [[ "$new_profile" == "$current_profile" ]]; then
        log_warning "Already using profile: $new_profile"
        return 0
    fi
    
    IFS='|' read -r name desc urls <<< "${BLOCKLIST_PROFILES[$new_profile]}"
    
    log_info "Switching from: $current_profile"
    log_info "Switching to:   $new_profile ($desc)"
    echo ""
    
    # Backup current blocklist
    if [[ -f /etc/coredns/zones/blocklist.hosts ]]; then
        log_info "Backing up current blocklist..."
        if ! declare -f lkg_save_blocklist >/dev/null 2>&1; then
            load_module "lkg"
        fi
        lkg_save_blocklist
    fi
    
    # Download new blocklist
    log_info "Downloading blocklist for profile: $new_profile"
    
    local tmp_raw=$(mktemp)
    local tmp_block=$(mktemp)
    local download_failed=0
    
    if [[ "$urls" == "CUSTOM" ]]; then
        # Use custom URLs
        if [[ ! -f "$BLOCKLIST_CUSTOM_URLS" ]]; then
            log_error "No custom URLs defined. Use: blocklist-add-url <url>"
            rm -f "$tmp_raw" "$tmp_block"
            return 1
        fi
        
        while IFS= read -r url; do
            [[ -z "$url" || "$url" == "#"* ]] && continue
            log_info "Downloading: $url"
            curl -fsSL "$url" 2>/dev/null | grep -v "^#" >> "$tmp_raw" || {
                log_warning "Failed to download: $url"
                download_failed=1
            }
        done < "$BLOCKLIST_CUSTOM_URLS"
    else
        # Use predefined URLs
        for url in $urls; do
            log_info "Downloading: $url"
            curl -fsSL "$url" 2>/dev/null | grep -v "^#" >> "$tmp_raw" || {
                log_warning "Failed to download: $url"
                download_failed=1
            }
        done
    fi
    
    if [[ $download_failed -eq 1 ]]; then
        log_warning "Some downloads failed, but continuing with available data"
    fi
    
    # Parse and normalize
    log_info "Processing blocklist..."
    awk '
        function emit(d) {
            gsub(/^[*.]+/, "", d)
            gsub(/[[:space:]]+$/, "", d)
            if (d ~ /^[A-Za-z0-9.-]+$/ && d ~ /\./) print "0.0.0.0 " d
        }
        {
            line=$0
            sub(/\r$/, "", line)
            if (line ~ /^[[:space:]]*$/) next
            if (line ~ /^[[:space:]]*!/) next

            if (line ~ /^(0\.0\.0\.0|127\.0\.0\.1|::)[[:space:]]+/) {
                n=split(line, a, /[[:space:]]+/)
                if (n >= 2) {
                    d=a[2]
                    sub(/^\|\|/, "", d)
                    sub(/[\^\/].*$/, "", d)
                    emit(d)
                }
                next
            }

            if (line ~ /^\|\|/) {
                sub(/^\|\|/, "", line)
                sub(/[\^\/].*$/, "", line)
                emit(line)
                next
            }

            if (line ~ /^[A-Za-z0-9.*-]+(\.[A-Za-z0-9.-]+)+$/) {
                emit(line)
                next
            }
        }
    ' "$tmp_raw" | sort -u > "$tmp_block"
    
    # Validate
    local entry_count=$(wc -l < "$tmp_block")
    log_info "Processed entries: $entry_count"
    
    if [[ $entry_count -lt 1000 ]]; then
        log_error "Blocklist too small ($entry_count entries) - aborting"
        log_warning "Restoring from LKG cache..."
        rm -f "$tmp_raw" "$tmp_block"
        
        if ! declare -f lkg_restore_blocklist >/dev/null 2>&1; then
            load_module "lkg"
        fi
        lkg_restore_blocklist
        return 1
    fi
    
    # Install new blocklist
    mv "$tmp_block" /etc/coredns/zones/blocklist.hosts
    rm -f "$tmp_raw"
    
    # Rebuild combined hosts
    if ! declare -f adblock_rebuild >/dev/null 2>&1; then
        load_module "adblock"
    fi
    adblock_rebuild
    
    # Save profile
    mkdir -p "$(dirname "$BLOCKLIST_PROFILE_FILE")"
    echo "$new_profile" > "$BLOCKLIST_PROFILE_FILE"
    
    # Reload CoreDNS
    log_info "Reloading CoreDNS..."
    systemctl reload coredns 2>/dev/null || systemctl restart coredns
    
    log_success "Switched to profile: $new_profile"
    log_info "Blocklist entries: $entry_count"
}

blocklist_status() {
    log_section "📊 BLOCKLIST STATUS"
    
    local current_profile=$(cat "$BLOCKLIST_PROFILE_FILE" 2>/dev/null || echo "balanced")
    IFS='|' read -r name desc urls <<< "${BLOCKLIST_PROFILES[$current_profile]}"
    
    echo "Current profile: ${GREEN}$current_profile${NC}"
    echo "Description: $desc"
    echo ""
    
    if [[ -f /etc/coredns/zones/blocklist.hosts ]]; then
        local total=$(wc -l < /etc/coredns/zones/blocklist.hosts)
        printf "Blocked domains: %'d\n" "$total"
    else
        echo "Blocked domains: N/A (blocklist not found)"
    fi
    
    if [[ -f /etc/coredns/zones/combined.hosts ]]; then
        local combined=$(wc -l < /etc/coredns/zones/combined.hosts)
        printf "Total entries:   %'d (blocklist + custom)\n" "$combined"
    fi
    
    echo ""
    echo "Profile URLs:"
    if [[ "$urls" == "CUSTOM" ]]; then
        if [[ -f "$BLOCKLIST_CUSTOM_URLS" ]]; then
            cat "$BLOCKLIST_CUSTOM_URLS" | grep -v "^#" | sed 's/^/  - /'
        else
            echo "  (no custom URLs defined)"
        fi
    else
        for url in $urls; do
            echo "  - $url"
        done
    fi
}

blocklist_add_url() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        log_error "Usage: blocklist-add-url <url>"
        return 1
    fi
    
    log_section "➕ ADD CUSTOM URL"
    
    mkdir -p "$(dirname "$BLOCKLIST_CUSTOM_URLS")"
    touch "$BLOCKLIST_CUSTOM_URLS"
    
    # Check if already exists
    if grep -qF "$url" "$BLOCKLIST_CUSTOM_URLS" 2>/dev/null; then
        log_warning "URL already in custom list: $url"
        return 0
    fi
    
    # Add URL
    echo "$url" >> "$BLOCKLIST_CUSTOM_URLS"
    log_success "Added URL: $url"
    
    # Switch to custom profile if not already
    local current_profile=$(cat "$BLOCKLIST_PROFILE_FILE" 2>/dev/null || echo "balanced")
    if [[ "$current_profile" != "custom" ]]; then
        log_info "Switching to custom profile..."
        blocklist_switch custom
    else
        log_info "Rebuilding custom blocklist..."
        blocklist_switch custom
    fi
}

blocklist_remove_url() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        log_error "Usage: blocklist-remove-url <url>"
        return 1
    fi
    
    log_section "➖ REMOVE CUSTOM URL"
    
    if [[ ! -f "$BLOCKLIST_CUSTOM_URLS" ]]; then
        log_error "No custom URLs defined"
        return 1
    fi
    
    # Remove URL
    grep -vF "$url" "$BLOCKLIST_CUSTOM_URLS" > "${BLOCKLIST_CUSTOM_URLS}.tmp"
    mv "${BLOCKLIST_CUSTOM_URLS}.tmp" "$BLOCKLIST_CUSTOM_URLS"
    
    log_success "Removed URL: $url"
    
    # Rebuild if using custom profile
    local current_profile=$(cat "$BLOCKLIST_PROFILE_FILE" 2>/dev/null || echo "balanced")
    if [[ "$current_profile" == "custom" ]]; then
        log_info "Rebuilding custom blocklist..."
        blocklist_switch custom
    fi
}

blocklist_show_urls() {
    log_section "📋 CUSTOM URLS"
    
    if [[ ! -f "$BLOCKLIST_CUSTOM_URLS" ]] || [[ ! -s "$BLOCKLIST_CUSTOM_URLS" ]]; then
        echo "No custom URLs defined"
        echo ""
        echo "Add URLs with: sudo cytadela++ blocklist-add-url <url>"
        return 0
    fi
    
    echo "Custom URLs:"
    cat "$BLOCKLIST_CUSTOM_URLS" | grep -v "^#" | nl -w2 -s'. '
}
