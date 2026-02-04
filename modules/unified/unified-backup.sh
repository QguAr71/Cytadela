#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ UNIFIED-BACKUP MODULE v3.2                                 ║
# ║  Unified backup, restore, and auto-update functionality               ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# CONFIGURATION & CONSTANTS
# ==============================================================================

# Backup settings
BACKUP_DIR="/var/lib/cytadela/backups"
BACKUP_DATE=$(date +%Y%m%d-%H%M%S)

# LKG (Last Known Good) settings
LKG_BLOCKLIST="${CYTADELA_LKG_DIR}/blocklist.hosts"
LKG_BLOCKLIST_META="${CYTADELA_LKG_DIR}/blocklist.meta"

# Auto-update settings
AUTO_UPDATE_SERVICE="/etc/systemd/system/cytadela-auto-update.service"
AUTO_UPDATE_TIMER="/etc/systemd/system/cytadela-auto-update.timer"

# ==============================================================================
# CONFIG BACKUP FUNCTIONS (migrated from config-backup.sh)
# ==============================================================================

# Create configuration backup
config_backup() {
    log_section "󰇉 CONFIG BACKUP"

    mkdir -p "$BACKUP_DIR"

    local backup_file="${BACKUP_DIR}/cytadela-backup-${BACKUP_DATE}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    log_info "Creating backup: $backup_file"

    # DNSCrypt config
    if [[ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]]; then
        mkdir -p "${tmp_dir}/dnscrypt-proxy"
        cp /etc/dnscrypt-proxy/dnscrypt-proxy.toml "${tmp_dir}/dnscrypt-proxy/"
        [[ -f /etc/dnscrypt-proxy/cloaking-rules.txt ]] && cp /etc/dnscrypt-proxy/cloaking-rules.txt "${tmp_dir}/dnscrypt-proxy/"
        log_info "󰄬 DNSCrypt config"
    fi

    # CoreDNS config
    if [[ -f /etc/coredns/Corefile ]]; then
        mkdir -p "${tmp_dir}/coredns"
        cp /etc/coredns/Corefile "${tmp_dir}/coredns/"
        [[ -f /etc/coredns/Corefile.citadel ]] && cp /etc/coredns/Corefile.citadel "${tmp_dir}/coredns/"
        log_info "󰄬 CoreDNS config"
    fi

    # CoreDNS zones
    if [[ -d /etc/coredns/zones ]]; then
        mkdir -p "${tmp_dir}/coredns/zones"
        cp /etc/coredns/zones/custom.hosts "${tmp_dir}/coredns/zones/" 2>/dev/null || true
        cp /etc/coredns/zones/allowlist.txt "${tmp_dir}/coredns/zones/" 2>/dev/null || true
        log_info "󰄬 CoreDNS zones (custom.hosts, allowlist.txt)"
    fi

    # NFTables config
    if [[ -d /etc/nftables.d ]]; then
        mkdir -p "${tmp_dir}/nftables.d"
        cp /etc/nftables.d/citadel-*.nft "${tmp_dir}/nftables.d/" 2>/dev/null || true
        [[ -f /etc/nftables.conf ]] && cp /etc/nftables.conf "${tmp_dir}/"
        log_info "󰄬 NFTables config"
    fi

    # NetworkManager config
    if [[ -f /etc/NetworkManager/conf.d/citadel-dns.conf ]]; then
        mkdir -p "${tmp_dir}/NetworkManager/conf.d"
        cp /etc/NetworkManager/conf.d/citadel-dns.conf "${tmp_dir}/NetworkManager/conf.d/"
        log_info "󰄬 NetworkManager config"
    fi

    # Cytadela state
    if [[ -d /var/lib/cytadela ]]; then
        mkdir -p "${tmp_dir}/cytadela-state"
        cp /var/lib/cytadela/manifest.sha256 "${tmp_dir}/cytadela-state/" 2>/dev/null || true
        cp /var/lib/cytadela/panic.state "${tmp_dir}/cytadela-state/" 2>/dev/null || true
        cp /var/lib/cytadela/location-trusted.txt "${tmp_dir}/cytadela-state/" 2>/dev/null || true
        log_info "󰄬 Cytadela state files"
    fi

    # Systemd services
    mkdir -p "${tmp_dir}/systemd"
    cp /etc/systemd/system/cytadela-*.service "${tmp_dir}/systemd/" 2>/dev/null || true
    cp /etc/systemd/system/cytadela-*.timer "${tmp_dir}/systemd/" 2>/dev/null || true
    cp /etc/systemd/system/citadel-*.service "${tmp_dir}/systemd/" 2>/dev/null || true
    cp /etc/systemd/system/citadel-*.timer "${tmp_dir}/systemd/" 2>/dev/null || true
    log_info "󰄬 Systemd units"

    # Create metadata
    cat >"${tmp_dir}/backup-metadata.txt" <<EOF
Citadel Backup
Created: $(date -Iseconds)
Hostname: $(hostname)
Version: 3.2.0
EOF

    # Create tarball
    tar -czf "$backup_file" -C "$tmp_dir" . 2>/dev/null

    # Cleanup
    rm -rf "$tmp_dir"

    # Set permissions
    chmod 600 "$backup_file"

    log_success "Backup created: $backup_file"
    echo "  Size: $(du -h "$backup_file" | cut -f1)"
}

# Restore configuration from backup
config_restore() {
    log_section "󰜸  CONFIG RESTORE"

    local backup_file="$1"

    if [[ -z "$backup_file" ]]; then
        log_error "Usage: config-restore <backup-file>"
        echo ""
        echo "Available backups:"
        config_list
        return 1
    fi

    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi

    log_warning "This will restore configuration from backup."
    log_warning "Current config will be backed up first."
    echo ""
    read -p "Continue? [y/N]: " answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        log_info "Cancelled"
        return 0
    fi

    # Backup current config first
    log_info "Backing up current config..."
    config_backup

    log_info "Creating backup archive..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    log_info "Extracting backup..."
    tar -xzf "$backup_file" -C "$tmp_dir"

    # Show metadata
    if [[ -f "${tmp_dir}/backup-metadata.txt" ]]; then
        echo ""
        cat "${tmp_dir}/backup-metadata.txt"
        echo ""
    fi

    # Restore files
    log_info "Restoring configuration files..."

    # DNSCrypt
    if [[ -d "${tmp_dir}/dnscrypt-proxy" ]]; then
        cp "${tmp_dir}/dnscrypt-proxy"/* /etc/dnscrypt-proxy/ 2>/dev/null || true
        log_info "󰄬 DNSCrypt config restored"
    fi

    # CoreDNS
    if [[ -d "${tmp_dir}/coredns" ]]; then
        cp "${tmp_dir}/coredns/Corefile" /etc/coredns/ 2>/dev/null || true
        cp "${tmp_dir}/coredns/Corefile.citadel" /etc/coredns/ 2>/dev/null || true
        log_info "󰄬 CoreDNS config restored"
    fi

    # CoreDNS zones
    if [[ -d "${tmp_dir}/coredns/zones" ]]; then
        cp "${tmp_dir}/coredns/zones"/* /etc/coredns/zones/ 2>/dev/null || true
        log_info "󰄬 CoreDNS zones restored"
    fi

    # NFTables
    if [[ -d "${tmp_dir}/nftables.d" ]]; then
        cp "${tmp_dir}/nftables.d"/* /etc/nftables.d/ 2>/dev/null || true
        [[ -f "${tmp_dir}/nftables.conf" ]] && cp "${tmp_dir}/nftables.conf" /etc/
        log_info "󰄬 NFTables config restored"
    fi

    # NetworkManager
    if [[ -d "${tmp_dir}/NetworkManager" ]]; then
        mkdir -p /etc/NetworkManager/conf.d
        cp "${tmp_dir}/NetworkManager/conf.d"/* /etc/NetworkManager/conf.d/ 2>/dev/null || true
        log_info "󰄬 NetworkManager config restored"
    fi

    # Cytadela state
    if [[ -d "${tmp_dir}/cytadela-state" ]]; then
        mkdir -p /var/lib/cytadela
        cp "${tmp_dir}/cytadela-state"/* /var/lib/cytadela/ 2>/dev/null || true
        log_info "󰄬 Cytadela state restored"
    fi

    # Systemd units
    if [[ -d "${tmp_dir}/systemd" ]]; then
        cp "${tmp_dir}/systemd"/* /etc/systemd/system/ 2>/dev/null || true
        systemctl daemon-reload
        log_info "󰄬 Systemd units restored"
    fi

    # Cleanup
    rm -rf "$tmp_dir"

    log_success "Configuration restored from: $backup_file"
    log_warning "Restart services to apply changes:"
    echo "  sudo systemctl restart dnscrypt-proxy coredns"
}

# List available backups
config_list() {
    log_section "󰓍 AVAILABLE BACKUPS"

    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo "No backups found in $BACKUP_DIR"
        return 0
    fi

    echo "Backups in $BACKUP_DIR:"
    echo ""

    for file in "$BACKUP_DIR"/cytadela-backup-*.tar.gz; do
        [[ ! -f "$file" ]] && continue
        local size
        size=$(du -h "$file" | cut -f1)
        local date
        date=$(stat -c %y "$file" | cut -d'.' -f1)

        printf "  ${GREEN}%s${NC}\n" "$(basename "$file")"
        printf "    Date: %s\n" "$date"
        printf "    Size: %s\n" "$size"
        echo ""
    done
}

# Delete backup file
config_delete() {
config_list() {
    log_section "󰓍 AVAILABLE BACKUPS"
    
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo "No backups found in $BACKUP_DIR"
        return 0
    fi
    
    echo "Backups in $BACKUP_DIR:"
    echo ""
    
    for file in "$BACKUP_DIR"/cytadela-backup-*.tar.gz; do
        [[ ! -f "$file" ]] && continue
        local size
        size=$(du -h "$file" | cut -f1)
        local date
        date=$(stat -c %y "$file" | cut -d'.' -f1)
        
        printf "  ${GREEN}%s${NC}
" "$(basename "$file")"
        printf "    Date: %s
" "$date"
        printf "    Size: %s
" "$size"
        echo ""
    done
}
    log_section "󰩹  DELETE BACKUP"

    local backup_file="$1"

    if [[ -z "$backup_file" ]]; then
        log_error "Usage: config-delete <backup-file>"
        return 1
    fi

    if [[ ! -f "$backup_file" ]]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi

    log_warning "Delete backup: $backup_file"
    read -p "Are you sure? [y/N]: " answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        rm -f "$backup_file"
        log_success "Backup deleted"
    else
        log_info "Cancelled"
    fi
}

# ==============================================================================
# LKG (Last Known Good) FUNCTIONS (migrated from lkg.sh)
# ==============================================================================

# Validate blocklist file
lkg_validate_blocklist() {
    local file="$1"
    local min_lines=1000

    [[ ! -f "$file" ]] && return 1

    local lines
    lines=$(wc -l <"$file")
    [[ $lines -lt $min_lines ]] && {
        log_warning "LKG: File too small ($lines lines, min $min_lines): $file"
        return 1
    }

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

# Save current blocklist as LKG
lkg_save_blocklist() {
    local source="/etc/coredns/zones/blocklist.hosts"

    [[ ! -f "$source" ]] && {
        log_warning "LKG: No blocklist to save"
        return 1
    }

    if ! lkg_validate_blocklist "$source"; then
        log_warning "LKG: Current blocklist failed validation, not saving"
        return 1
    fi

    mkdir -p "$CYTADELA_LKG_DIR"
    cp "$source" "$LKG_BLOCKLIST"
    echo "saved=$(date -Iseconds)" >"$LKG_BLOCKLIST_META"
    echo "lines=$(wc -l <"$LKG_BLOCKLIST")" >>"$LKG_BLOCKLIST_META"
    echo "sha256=$(sha256sum "$LKG_BLOCKLIST" | awk '{print $1}')" >>"$LKG_BLOCKLIST_META"

    log_success "LKG: Blocklist saved ($(wc -l <"$LKG_BLOCKLIST") lines)"
}

# Restore blocklist from LKG
lkg_restore_blocklist() {
    local target="/etc/coredns/zones/blocklist.hosts"

    [[ ! -f "$LKG_BLOCKLIST" ]] && {
        log_warning "LKG: No saved blocklist to restore"
        return 1
    }

    if ! lkg_validate_blocklist "$LKG_BLOCKLIST"; then
        log_error "LKG: Saved blocklist failed validation"
        return 1
    fi

    cp "$LKG_BLOCKLIST" "$target"
    chown root:coredns "$target" 2>/dev/null || true
    chmod 0640 "$target" 2>/dev/null || true

    log_success "LKG: Blocklist restored from cache"
}

# Show LKG status
lkg_status() {
    log_section "󰏗 LKG (Last Known Good) STATUS"

    echo "LKG Directory: $CYTADELA_LKG_DIR"

    if [[ -f "$LKG_BLOCKLIST" ]]; then
        echo "Blocklist cache: EXISTS"
        echo "  Lines: $(wc -l <"$LKG_BLOCKLIST")"
        [[ -f "$LKG_BLOCKLIST_META" ]] && cat "$LKG_BLOCKLIST_META" | sed 's/^/  /'
    else
        echo "Blocklist cache: NOT FOUND"
        echo "  Run: sudo $0 lkg-save"
    fi
}

# Update lists with LKG fallback
lists_update() {
    log_section "󰇚 LISTS UPDATE (with LKG fallback)"

    local staging_file
    staging_file=$(mktemp)
    local target="/etc/coredns/zones/blocklist.hosts"

    # Get current profile (default: balanced)
    local current_profile
    current_profile=$(cat /var/lib/cytadela/blocklist-profile.txt 2>/dev/null || echo "balanced")

    # Define URLs for each profile (must match blocklist-manager.sh)
    local blocklist_url=""
    case "$current_profile" in
        light)
            blocklist_url="https://small.oisd.nl"
            ;;
        balanced)
            blocklist_url="https://big.oisd.nl"
            ;;
        aggressive)
            blocklist_url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.plus.txt"
            ;;
        privacy)
            blocklist_url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/tif.txt"
            ;;
        polish)
            blocklist_url="https://hole.cert.pl/domains/domains_hosts.txt"
            ;;
        custom)
            # Custom profile - use first custom URL or fallback
            if [[ -f /var/lib/cytadela/blocklist-custom-urls.txt ]]; then
                blocklist_url=$(grep -v '^#' /var/lib/cytadela/blocklist-custom-urls.txt 2>/dev/null | head -1)
            fi
            ;;
    esac

    # Fallback if no URL determined
    [[ -z "$blocklist_url" ]] && blocklist_url="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/hosts/pro.txt"

    log_info "Profile: $current_profile"
    log_info "Downloading: $blocklist_url..."

    # Progress indicator
    local progress_chars="/-\\|"
    local i=0

    # Start download with progress
    (
        while kill -0 $$ 2>/dev/null; do
            printf "\r${CYAN}Downloading...${progress_chars:$((i%4)):1}${NC}"
            sleep 0.5
            ((i++))
        done
    ) &
    local progress_pid=$!

    if curl -sSL --connect-timeout 10 --max-time 60 "$blocklist_url" -o "$staging_file" 2>/dev/null; then
        kill "$progress_pid" 2>/dev/null || true
        printf "\r${GREEN}Download complete${NC}\n"
        log_info "Validating..."

        if lkg_validate_blocklist "$staging_file"; then
            mv "$staging_file" "$target"
            chown root:coredns "$target" 2>/dev/null || true
            chmod 0640 "$target" 2>/dev/null || true

            log_success "Blocklist updated ($(wc -l <"$target") lines)"

            lkg_save_blocklist

            # Load adblock module if not loaded
            if ! declare -f adblock_rebuild >/dev/null 2>&1; then
                load_module "adblock"
            fi

            adblock_rebuild
            adblock_reload
            log_success "Adblock rebuilt + CoreDNS reloaded"
        else
            kill "$progress_pid" 2>/dev/null || true
            printf "\r${YELLOW}Download failed${NC}\n"
            log_warning "Downloaded blocklist failed validation"
            rm -f "$staging_file"
            log_info "Keeping current blocklist"
        fi
    else
        kill "$progress_pid" 2>/dev/null || true
        printf "\r${RED}Download failed${NC}\n"
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

# ==============================================================================
# AUTO-UPDATE FUNCTIONS (migrated from auto-update.sh)
# ==============================================================================

# Enable automatic updates
auto_update_enable() {
    log_section "󰜝 ENABLING AUTO-UPDATE"

    # Check if LKG module is available
    if ! declare -f lists_update >/dev/null 2>&1; then
        load_module "lkg"
    fi

    # Create systemd service
    log_info "Creating systemd service..."
    tee "$AUTO_UPDATE_SERVICE" >/dev/null <<'EOF'
[Unit]
Description=Citadel Automatic Blocklist Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/Citadel lists-update
StandardOutput=journal
StandardError=journal
SyslogIdentifier=cytadela-auto-update

# Restart on failure
Restart=on-failure
RestartSec=300

[Install]
WantedBy=multi-user.target
EOF

    # Create systemd timer
    log_info "Creating systemd timer (daily updates)..."
    tee "$AUTO_UPDATE_TIMER" >/dev/null <<'EOF'
[Unit]
Description=Citadel Daily Blocklist Update Timer
Requires=cytadela-auto-update.service

[Timer]
OnCalendar=daily
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Reload systemd
    systemctl daemon-reload

    # Enable and start timer
    systemctl enable cytadela-auto-update.timer
    systemctl start cytadela-auto-update.timer

    log_success "Auto-update enabled (daily updates with 1h random delay)"

    # Show status
    auto_update_status
}

# Disable automatic updates
auto_update_disable() {
    log_section "🛑 DISABLING AUTO-UPDATE"

    # Stop and disable timer
    systemctl stop cytadela-auto-update.timer 2>/dev/null || true
    systemctl disable cytadela-auto-update.timer 2>/dev/null || true

    log_success "Auto-update disabled"
}

# Show auto-update status
auto_update_status() {
    log_section "📊 AUTO-UPDATE STATUS"

    if systemctl is-enabled cytadela-auto-update.timer &>/dev/null; then
        echo -e "${GREEN}Status: ENABLED${NC}"
    else
        echo -e "${YELLOW}Status: DISABLED${NC}"
    fi

    if systemctl is-active cytadela-auto-update.timer &>/dev/null; then
        echo -e "${GREEN}Timer: ACTIVE${NC}"
    else
        echo -e "${YELLOW}Timer: INACTIVE${NC}"
    fi

    echo ""
    echo "Schedule:"
    systemctl list-timers cytadela-auto-update.timer --no-pager 2>/dev/null || echo "  Timer not found"

    echo ""
    echo "Last update logs:"
    journalctl -u cytadela-auto-update.service -n 10 --no-pager 2>/dev/null || echo "  No logs available"
}

# Run manual update now
auto_update_now() {
    log_section "󰜝 MANUAL UPDATE NOW"

    if ! declare -f lists_update >/dev/null 2>&1; then
        load_module "lkg"
    fi

    log_info "Running blocklist update..."
    if lists_update; then
        log_success "Blocklist updated successfully"
    else
        log_error "Blocklist update failed"
        return 1
    fi
}

# Configure auto-update schedule
auto_update_configure() {
    log_section "⚙️  CONFIGURE AUTO-UPDATE"

    echo "Select update frequency:"
    echo "  1) Daily (default)"
    echo "  2) Weekly"
    echo "  3) Custom"
    echo ""
    read -p "Choice [1-3]: " choice

    local calendar="daily"
    case "$choice" in
        1) calendar="daily" ;;
        2) calendar="weekly" ;;
        3)
            echo ""
            echo "Enter systemd OnCalendar format (e.g., 'Mon *-*-* 03:00:00'):"
            read -p "Calendar: " calendar
            ;;
        *)
            log_warning "Invalid choice, using daily"
            calendar="daily"
            ;;
    esac

    log_info "Updating timer to: $calendar"

    # Update timer file
    sed -i "s/^OnCalendar=.*/OnCalendar=$calendar/" "$AUTO_UPDATE_TIMER"

    # Reload and restart
    systemctl daemon-reload
    systemctl restart cytadela-auto-update.timer

    log_success "Auto-update configured: $calendar"
    auto_update_status
}
