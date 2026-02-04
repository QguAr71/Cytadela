#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ CONFIG-BACKUP MODULE v3.1                                     ║
# ║  Backup and restore configuration (Issue #14)                             ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

BACKUP_DIR="/var/lib/cytadela/backups"
BACKUP_DATE=$(date +%Y%m%d-%H%M%S)

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
Version: 3.1.1
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

config_delete() {
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
