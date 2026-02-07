#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-ADBLOCK MODULE v3.2                                ║
# ║  Unified ad blocking and blocklist management                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Load i18n strings - try new i18n-engine first, fallback to legacy
local lang="${CYTADELA_LANG:-${LANG%%_*}:-en}"
lang="${lang:-en}"

# Try new i18n-engine
if [[ -f "modules/i18n-engine/i18n-engine.sh" ]]; then
    source "modules/i18n-engine/i18n-engine.sh" 2>/dev/null && {
        i18n_engine_init 2>/dev/null || true
        i18n_engine_load "adblock" "$lang" 2>/dev/null || true
    }
fi

# Fallback to legacy i18n if available
if [[ -f "lib/i18n/${lang}.sh" ]]; then
    source "lib/i18n/${lang}.sh" 2>/dev/null || true
fi

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

# Adblock directories
ADBLOCK_ZONES_DIR="/etc/coredns/zones"
CUSTOM_HOSTS="${ADBLOCK_ZONES_DIR}/custom.hosts"
ALLOWLIST_FILE="${ADBLOCK_ZONES_DIR}/allowlist.txt"
BLOCKLIST_FILE="${ADBLOCK_ZONES_DIR}/blocklist.hosts"
COMBINED_FILE="${ADBLOCK_ZONES_DIR}/combined.hosts"

# Blocklist manager settings
BLOCKLIST_PROFILE_FILE="/var/lib/cytadela/blocklist-profile.txt"
BLOCKLIST_CUSTOM_URLS="/var/lib/cytadela/blocklist-custom-urls.txt"

# ==============================================================================
# ADBLOCK CORE FUNCTIONS (migrated from adblock.sh)
# ==============================================================================

# Rebuild combined blocklist from sources
adblock_rebuild() {
    local custom="$CUSTOM_HOSTS"
    local allowlist="$ALLOWLIST_FILE"
    local blocklist="$BLOCKLIST_FILE"
    local combined="$COMBINED_FILE"

    mkdir -p "$ADBLOCK_ZONES_DIR"
    touch "$custom" "$allowlist" "$blocklist"

    chmod 0644 "$custom" 2>/dev/null || true
    chmod 0644 "$allowlist" 2>/dev/null || true

    if [[ -s "$allowlist" ]]; then
        cat "$custom" "$blocklist" | sort -u | awk -v AL="$allowlist" 'BEGIN{while((getline l < AL)>0){sub(/\r$/,"",l); gsub(/^[[:space:]]+|[[:space:]]+$/,"",l); if(l!="" && l !~ /^#/){k=tolower(l); a[k]=1; esc=k; gsub(/\./,"\\.",esc); r[k]="\\." esc "$"}}} {d=$2; if(d=="") next; dl=tolower(d); for(k in a){ if(dl==k || dl ~ r[k]) next } print}' >"$combined"
    else
        cat "$custom" "$blocklist" | sort -u >"$combined"
    fi

    chown root:coredns "$blocklist" "$combined" 2>/dev/null || true
    chmod 0640 "$blocklist" "$combined" 2>/dev/null || true
}

# Reload CoreDNS after adblock changes
adblock_reload() {
    systemctl reload coredns 2>/dev/null || systemctl restart coredns 2>/dev/null || true
}

# Show adblock status
adblock_status() {
    log_section "󰁣 CITADEL++ ADBLOCK STATUS"

    if systemctl is-active --quiet coredns; then
        echo "  󰄬 coredns: running"
    else
        echo "  󰅖 coredns: not running"
    fi

    if [[ -f /etc/coredns/Corefile ]] && grep -q '/etc/coredns/zones/combined\.hosts' /etc/coredns/Corefile; then
        echo "  󰄬 Corefile: uses combined.hosts"
    else
        echo "  󰅖 Corefile: missing combined.hosts"
    fi

    if [[ -f "$CUSTOM_HOSTS" ]]; then
        echo "  󰄬 custom.hosts:   $(wc -l <"$CUSTOM_HOSTS")"
    else
        echo "  󰅖 custom.hosts: missing"
    fi

    if [[ -f "$BLOCKLIST_FILE" ]]; then
        echo "  󰄬 blocklist.hosts: $(wc -l <"$BLOCKLIST_FILE")"
    else
        echo "  󰅖 blocklist.hosts: missing"
    fi

    if [[ -f "$COMBINED_FILE" ]]; then
        echo "  󰄬 combined.hosts:  $(wc -l <"$COMBINED_FILE")"
    else
        echo "  󰅖 combined.hosts: missing"
    fi
}

# Show adblock statistics
adblock_stats() {
    log_section "󰓇 CITADEL++ ADBLOCK STATS"
    echo "custom.hosts:   $(wc -l <"$CUSTOM_HOSTS" 2>/dev/null || echo 0)"
    echo "blocklist.hosts: $(wc -l <"$BLOCKLIST_FILE" 2>/dev/null || echo 0)"
    echo "combined.hosts:  $(wc -l <"$COMBINED_FILE" 2>/dev/null || echo 0)"
}

# Show adblock lists
adblock_show() {
    local which="$1"
    case "$which" in
        custom)
            sed -n '1,200p' "$CUSTOM_HOSTS" 2>/dev/null || true
            ;;
        blocklist)
            sed -n '1,200p' "$BLOCKLIST_FILE" 2>/dev/null || true
            ;;
        combined)
            sed -n '1,200p' "$COMBINED_FILE" 2>/dev/null || true
            ;;
        *)
            log_error "Użycie: adblock-show custom|blocklist|combined\n  Przykład: citadel.sh adblock-show blocklist"
            return 1
            ;;
    esac
}

# Query domain against adblock
adblock_query() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: adblock-query <domena>\n  Przykład: citadel.sh adblock-query google.com"
        return 1
    fi

    # Validate domain format (prevent injection)
    if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Invalid domain format: $domain"
        return 1
    fi

    dig +short @127.0.0.1 "$domain" 2>/dev/null || true
}

# Add domain to custom blocklist
adblock_add() {
    local domain="$1"

    if [[ -z "$domain" ]]; then
        log_error "Użycie: adblock-add <domena>\n  Przykład: citadel.sh adblock-add ads.example.com"
        return 1
    fi

    # Validate domain format (prevent injection)
    if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Invalid domain format: $domain"
        log_error "Domain must contain only alphanumeric characters, dots, and hyphens"
        return 1
    fi

    # Check for suspicious characters
    if [[ "$domain" =~ [[:space:]\;\|\&\$\`\\] ]]; then
        log_error "Domain contains invalid characters: $domain"
        return 1
    fi

    # Add to custom.hosts (with duplicate check)
    mkdir -p "$ADBLOCK_ZONES_DIR"
    touch "$CUSTOM_HOSTS"

    if grep -qE "^[0-9.:]+[[:space:]]+${domain}$" "$CUSTOM_HOSTS" 2>/dev/null; then
        log_info "Już istnieje w custom.hosts: $domain"
    else
        printf '0.0.0.0 %s\n' "$domain" >>"$CUSTOM_HOSTS"
        log_success "Dodano do custom.hosts: $domain"
    fi

    # Fix permissions for ZFS compatibility (Issue #25)
    chmod 644 "$CUSTOM_HOSTS"
    chown root:root "$CUSTOM_HOSTS"

    adblock_rebuild
    adblock_reload
}

# Remove domain from custom blocklist
adblock_remove() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: adblock-remove <domena>\n  Przykład: citadel.sh adblock-remove ads.example.com"
        return 1
    fi

    # Validate domain format (prevent injection)
    if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Invalid domain format: $domain"
        return 1
    fi

    if [[ ! -f "$CUSTOM_HOSTS" ]]; then
        log_warning "Brak $CUSTOM_HOSTS"
        return 0
    fi

    sed -i -E "/^[0-9.:]+[[:space:]]+${domain//./\.}([[:space:]]|$)/d" "$CUSTOM_HOSTS" || true
    log_success "Usunięto z custom.hosts (jeśli istniało): $domain"

    adblock_rebuild
    adblock_reload
}

# Edit custom blocklist
adblock_edit() {
    local editor
    editor="${EDITOR:-}"
    [[ -z "$editor" ]] && command -v micro >/dev/null 2>&1 && editor="micro"
    [[ -z "$editor" ]] && editor="nano"

    mkdir -p "$ADBLOCK_ZONES_DIR"
    touch "$CUSTOM_HOSTS"

    "$editor" "$CUSTOM_HOSTS"

    adblock_rebuild
adblock_status() {
    log_section "󰁣 CITADEL++ ADBLOCK STATUS"
    
    if systemctl is-active --quiet coredns; then
        echo "  󰄬 coredns: running"
    else
        echo "  󰅖 coredns: not running"
    fi
    
    if [[ -f /etc/coredns/Corefile ]] && grep -q '/etc/coredns/zones/combined.hosts' /etc/coredns/Corefile; then
        echo "  󰄬 Corefile: uses combined.hosts"
    else
        echo "  󰅖 Corefile: missing combined.hosts"
    fi
    
    if [[ -f "$CUSTOM_HOSTS" ]]; then
        echo "  󰄬 custom.hosts:   $(wc -l <"$CUSTOM_HOSTS")"
    else
        echo "  󰅖 custom.hosts: missing"
    fi
    
    if [[ -f "$BLOCKLIST_FILE" ]]; then
        echo "  󰄬 blocklist.hosts: $(wc -l <"$BLOCKLIST_FILE")"
    else
        echo "  󰅖 blocklist.hosts: missing"
    fi
    
    if [[ -f "$COMBINED_FILE" ]]; then
        echo "  󰄬 combined.hosts:  $(wc -l <"$COMBINED_FILE")"
    else
        echo "  󰅖 combined.hosts: missing"
    fi
}
    adblock_reload
}

# ==============================================================================
# ALLOWLIST FUNCTIONS (migrated from adblock.sh)
# ==============================================================================

# List allowlist entries
allowlist_list() {
    mkdir -p "$ADBLOCK_ZONES_DIR"
    touch "$ALLOWLIST_FILE"
    chmod 0644 "$ALLOWLIST_FILE" 2>/dev/null || true
    cat "$ALLOWLIST_FILE" 2>/dev/null || true
}

# Add domain to allowlist
allowlist_add() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: allowlist-add <domena>\n  Przykład: citadel.sh allowlist-add trusted.example.com"
        return 1
    fi
    if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Nieprawidłowa domena: $domain"
        return 1
    fi

    mkdir -p "$ADBLOCK_ZONES_DIR"
    touch "$ALLOWLIST_FILE"
    chmod 0644 "$ALLOWLIST_FILE" 2>/dev/null || true

    if grep -qiE "^${domain//./\.}$" "$ALLOWLIST_FILE" 2>/dev/null; then
        log_info "Już istnieje w allowlist: $domain"
    else
        printf '%s\n' "$domain" >>"$ALLOWLIST_FILE"
        log_success "Dodano do allowlist: $domain"
    fi

    adblock_rebuild
    adblock_reload
}

# Remove domain from allowlist
allowlist_remove() {
    local domain="$1"
    if [[ -z "$domain" ]]; then
        log_error "Użycie: allowlist-remove <domena>\n  Przykład: citadel.sh allowlist-remove trusted.example.com"
        return 1
    fi

    # Validate domain format (prevent injection)
    if [[ ! "$domain" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        log_error "Invalid domain format: $domain"
        return 1
    fi

    if [[ ! -f "$ALLOWLIST_FILE" ]]; then
        log_warning "Brak $ALLOWLIST_FILE"
        return 0
    fi

    sed -i -E "/^[[:space:]]*${domain//./\.}[[:space:]]*$/Id" "$ALLOWLIST_FILE" || true
    log_success "Usunięto z allowlist (jeśli istniało): $domain"

    adblock_rebuild
adblock_status() {
    log_section "󰁣 CITADEL++ ADBLOCK STATUS"
    
    if systemctl is-active --quiet coredns; then
        echo "  󰄬 coredns: running"
    else
        echo "  󰅖 coredns: not running"
    fi
    
    if [[ -f /etc/coredns/Corefile ]] && grep -q '/etc/coredns/zones/combined.hosts' /etc/coredns/Corefile; then
        echo "  󰄬 Corefile: uses combined.hosts"
    else
        echo "  󰅖 Corefile: missing combined.hosts"
    fi
    
    if [[ -f "$CUSTOM_HOSTS" ]]; then
        echo "  󰄬 custom.hosts:   $(wc -l <"$CUSTOM_HOSTS")"
    else
        echo "  󰅖 custom.hosts: missing"
    fi
    
    if [[ -f "$BLOCKLIST_FILE" ]]; then
        echo "  󰄬 blocklist.hosts: $(wc -l <"$BLOCKLIST_FILE")"
    else
        echo "  󰅖 blocklist.hosts: missing"
    fi
    
    if [[ -f "$COMBINED_FILE" ]]; then
        echo "  󰄬 combined.hosts:  $(wc -l <"$COMBINED_FILE")"
    else
        echo "  󰅖 combined.hosts: missing"
    fi
}
    adblock_reload
}

# ==============================================================================
# BLOCKLIST MANAGER FUNCTIONS (migrated from blocklist-manager.sh)
# ==============================================================================

# List available blocklist profiles
blocklist_list() {
    log_section "󰓍 ${T_ADBLOCK_BLOCKLIST_PROFILES:-BLOCKLIST PROFILES}"

    echo "${T_ADBLOCK_AVAILABLE_PROFILES:-Available profiles:}"
    echo "  ${T_ADBLOCK_PROFILE_LIGHT:-light      - Minimal blocking (~50K domains)}"
    echo "  ${T_ADBLOCK_PROFILE_BALANCED:-balanced   - Standard blocking (~500K domains) - RECOMMENDED}"
    echo "  ${T_ADBLOCK_PROFILE_AGGRESSIVE:-aggressive - Heavy blocking (~1M+ domains)}"
    echo "  ${T_ADBLOCK_PROFILE_PRIVACY:-privacy    - Privacy-focused blocking}"
    echo "  ${T_ADBLOCK_PROFILE_POLISH:-polish     - Polish-focused blocking}"
    echo "  ${T_ADBLOCK_PROFILE_CUSTOM:-custom     - Custom URLs from /var/lib/cytadela/blocklist-custom-urls.txt}"
    echo ""

    # Show current profile
    if [[ -f "$BLOCKLIST_PROFILE_FILE" ]]; then
        local current
        current=$(cat "$BLOCKLIST_PROFILE_FILE" 2>/dev/null || echo "unknown")
        echo "${T_ADBLOCK_CURRENT_PROFILE:-Current profile:} $current"
    else
        echo "${T_ADBLOCK_CURRENT_PROFILE_DEFAULT:-Current profile: balanced (default)}"
    fi

    echo ""
    echo "${T_ADBLOCK_SWITCH_PROFILE:-To switch profile: citadel adblock blocklist-switch <profile>}"
}

# Switch blocklist profile
blocklist_switch() {
    local profile="$1"

    if [[ -z "$profile" ]]; then
        log_error "${T_ADBLOCK_USAGE_BLOCKLIST_SWITCH:-Usage: blocklist-switch <profile>}"
        blocklist_list
        return 1
    fi

    # Validate profile
    case "$profile" in
        light|balanced|aggressive|privacy|polish|custom)
            ;;
        *)
            log_error "${T_ADBLOCK_INVALID_PROFILE:-Invalid profile:} $profile"
            blocklist_list
            return 1
            ;;
    esac

    # Save profile
    echo "$profile" > "$BLOCKLIST_PROFILE_FILE"
    log_success "${T_ADBLOCK_SWITCHED_TO_PROFILE:-Switched to profile:} $profile"

    # Trigger update
    if declare -f lists_update >/dev/null 2>&1; then
        log_info "${T_ADBLOCK_UPDATING_BLOCKLIST:-Updating blocklist...}"
        lists_update
    else
        log_warning "${T_ADBLOCK_LKG_NOT_AVAILABLE:-LKG module not available for update}"
    fi
}

# Show current blocklist status
blocklist_status() {
    log_section "󰓍 ${T_ADBLOCK_BLOCKLIST_STATUS:-BLOCKLIST STATUS}"

    # Current profile
    local profile="balanced"
    if [[ -f "$BLOCKLIST_PROFILE_FILE" ]]; then
        profile=$(cat "$BLOCKLIST_PROFILE_FILE")
    fi
    echo "${T_ADBLOCK_CURRENT_PROFILE_STATUS:-Current profile:} $profile"

    # Profile URL
    local url=""
    case "$profile" in
        light) url="https://small.oisd.nl" ;;
        balanced) url="https://big.oisd.nl" ;;
        aggressive) url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.plus.txt" ;;
        privacy) url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/tif.txt" ;;
        polish) url="https://hole.cert.pl/domains/domains_hosts.txt" ;;
        custom)
            if [[ -f "$BLOCKLIST_CUSTOM_URLS" ]]; then
                url=$(grep -v '^#' "$BLOCKLIST_CUSTOM_URLS" 2>/dev/null | head -1 || echo "none")
            else
                url="${T_ADBLOCK_NONE_CONFIGURE:-none (configure $BLOCKLIST_CUSTOM_URLS)}"
            fi
            ;;
    esac
    echo "${T_ADBLOCK_BLOCKLIST_URL:-Blocklist URL:} $url"

    # File status
    if [[ -f "$BLOCKLIST_FILE" ]]; then
        local lines
        lines=$(wc -l < "$BLOCKLIST_FILE")
        echo "${T_ADBLOCK_BLOCKLIST_FILE:-Blocklist file:} $lines ${T_ADBLOCK_ENTRIES:-entries}"
    else
        echo "${T_ADBLOCK_BLOCKLIST_FILE_NOT_DOWNLOADED:-Blocklist file: NOT DOWNLOADED}"
    fi
}

# Add custom blocklist URL
blocklist_add_url() {
    local url="$1"

    if [[ -z "$url" ]]; then
        log_error "${T_ADBLOCK_USAGE_BLOCKLIST_ADD_URL:-Usage: blocklist-add-url <url>}"
        return 1
    fi

    # Basic URL validation
    if [[ ! "$url" =~ ^https?:// ]]; then
        log_error "${T_ADBLOCK_URL_MUST_START_WITH_HTTP:-URL must start with http:// or https://}"
        return 1
    fi

    mkdir -p "$(dirname "$BLOCKLIST_CUSTOM_URLS")"
    echo "$url" >> "$BLOCKLIST_CUSTOM_URLS"
    log_success "${T_ADBLOCK_ADDED_CUSTOM_URL:-Added custom URL:} $url"

    # Switch to custom profile if not already
    if [[ ! -f "$BLOCKLIST_PROFILE_FILE" ]] || [[ "$(cat "$BLOCKLIST_PROFILE_FILE")" != "custom" ]]; then
        echo "custom" > "$BLOCKLIST_PROFILE_FILE"
        log_info "${T_ADBLOCK_SWITCHED_TO_CUSTOM_PROFILE:-Switched to custom profile}"
    fi
}

# Remove custom blocklist URL
blocklist_remove_url() {
    local url="$1"

    if [[ -z "$url" ]]; then
        log_error "${T_ADBLOCK_USAGE_BLOCKLIST_REMOVE_URL:-Usage: blocklist-remove-url <url>}"
        return 1
    fi

    if [[ ! -f "$BLOCKLIST_CUSTOM_URLS" ]]; then
        log_warning "${T_ADBLOCK_NO_CUSTOM_URLS_CONFIGURED:-No custom URLs configured}"
        return 1
    fi

    sed -i "\|^${url}$|d" "$BLOCKLIST_CUSTOM_URLS"
    log_success "${T_ADBLOCK_REMOVED_URL:-Removed URL:} $url"
}

# Show custom URLs
blocklist_show_urls() {
    log_section "󰓍 ${T_ADBLOCK_CUSTOM_BLOCKLIST_URLS:-CUSTOM BLOCKLIST URLs}"

    if [[ ! -f "$BLOCKLIST_CUSTOM_URLS" ]]; then
        echo "${T_ADBLOCK_NO_CUSTOM_URLS_CONFIGURED:-No custom URLs configured}"
        echo "${T_ADBLOCK_ADD_URLS_WITH:-Add URLs with: citadel adblock blocklist-add-url <url>}"
        return 0
    fi

    echo "${T_ADBLOCK_CUSTOM_BLOCKLIST_URLS_LIST:-Custom blocklist URLs:}"
    local i=1
    while IFS= read -r url; do
        [[ -z "$url" || "$url" == "#"* ]] && continue
        echo "  $i) $url"
        ((i++))
    done < "$BLOCKLIST_CUSTOM_URLS"
}
