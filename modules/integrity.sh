#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ INTEGRITY MODULE v3.1                                         ║
# ║  Local-First Security Policy (Issue #1)                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ==============================================================================
# INTEGRITY VERIFICATION
# ==============================================================================
integrity_verify_file() {
    local file="$1"
    local expected_hash="$2"

    # File missing
    [[ ! -f "$file" ]] && return 2

    # Calculate hash
    local actual_hash
    actual_hash=$(sha256sum "$file" | awk '{print $1}')

    # Compare
    [[ "$actual_hash" == "$expected_hash" ]] && return 0 || return 1
}

integrity_check() {
    local silent="${1:-}"
    local has_errors=0
    local has_warnings=0

    # Developer mode: bypass checks
    if [[ "$CYTADELA_MODE" == "developer" ]]; then
        [[ -z "$silent" ]] && log_info "[DEV MODE] Integrity checks bypassed"
        return 0
    fi

    # No manifest: skip (bootstrap)
    if [[ ! -f "$CYTADELA_MANIFEST" ]]; then
        log_warning "Integrity not initialized. Run: sudo $0 integrity-init"
        return 0
    fi

    [[ -z "$silent" ]] && log_info "Verifying integrity from $CYTADELA_MANIFEST ..."

    # Read manifest and verify each file
    while IFS='  ' read -r hash filepath; do
        # Skip comments and empty lines
        [[ -z "$hash" || "$hash" == "#"* ]] && continue

        # Determine file type for policy
        local is_binary=0
        [[ "$filepath" == "$CYTADELA_OPT_BIN"/* ]] && is_binary=1

        # Check if file exists
        if [[ ! -f "$filepath" ]]; then
            log_warning "Missing: $filepath"
            has_warnings=1
            continue
        fi

        # Verify integrity
        if ! integrity_verify_file "$filepath" "$hash"; then
            if [[ $is_binary -eq 1 ]]; then
                # Binary: hard fail
                log_error "INTEGRITY FAIL (binary): $filepath"
                has_errors=1
            else
                # Module/script: warn and prompt
                log_warning "INTEGRITY MISMATCH (module): $filepath"
                has_warnings=1

                # Non-interactive mode: fail
                if [[ ! -t 0 && ! -t 1 ]]; then
                    log_error "Non-interactive mode: aborting due to integrity mismatch"
                    has_errors=1
                else
                    # Interactive: prompt user
                    echo -n "Continue despite mismatch? [y/N]: "
                    read -r answer
                    [[ ! "$answer" =~ ^[Yy]$ ]] && has_errors=1
                fi
            fi
        else
            [[ -z "$silent" ]] && log_success "OK: $filepath"
        fi
    done <"$CYTADELA_MANIFEST"

    # Final verdict
    if [[ $has_errors -eq 1 ]]; then
        log_error "Integrity check FAILED. Aborting."
        exit 1
    fi

    if [[ $has_warnings -gt 0 ]]; then
        [[ -z "$silent" ]] && log_warning "Integrity check passed with $has_warnings warning(s)"
    else
        [[ -z "$silent" ]] && log_success "Integrity check passed"
    fi

    return 0
}

# ==============================================================================
# INTEGRITY INITIALIZATION
# ==============================================================================
integrity_init() {
    log_section "🔐 INTEGRITY INIT"

    # Create directories
    mkdir -p "$(dirname "$CYTADELA_MANIFEST")"
    mkdir -p "$CYTADELA_LKG_DIR"
    mkdir -p "$CYTADELA_OPT_BIN"

    # Create temporary manifest
    local manifest_tmp
    manifest_tmp=$(mktemp)

    echo "# Cytadela integrity manifest - generated $(date -Iseconds)" >"$manifest_tmp"
    echo "# Format: sha256  filepath" >>"$manifest_tmp"

    # Add main scripts
    local script_dir
    script_dir=$(dirname "$CYTADELA_SCRIPT_PATH")

    # Add current script
    if [[ -f "$CYTADELA_SCRIPT_PATH" ]]; then
        sha256sum "$CYTADELA_SCRIPT_PATH" >>"$manifest_tmp"
        log_info "Added: $CYTADELA_SCRIPT_PATH"
    fi

    # Add any other .sh scripts in script directory (auto-discover)
    for script in "${script_dir}"/*.sh; do
        if [[ -f "$script" && "$script" != "$CYTADELA_SCRIPT_PATH" ]]; then
            sha256sum "$script" >>"$manifest_tmp"
            log_info "Added: $script"
        fi
    done

    # Add lib files (if in /opt/cytadela/lib)
    if [[ -d "/opt/cytadela/lib" ]]; then
        for lib in /opt/cytadela/lib/*.sh; do
            if [[ -f "$lib" ]]; then
                sha256sum "$lib" >>"$manifest_tmp"
                log_info "Added: $lib"
            fi
        done
    fi

    # Add modules (if in /opt/cytadela/modules)
    if [[ -d "/opt/cytadela/modules" ]]; then
        for mod in /opt/cytadela/modules/*.sh; do
            if [[ -f "$mod" ]]; then
                sha256sum "$mod" >>"$manifest_tmp"
                log_info "Added: $mod"
            fi
        done
    fi

    # Add binaries from /opt/cytadela/bin
    if [[ -d "$CYTADELA_OPT_BIN" ]]; then
        for bin in "$CYTADELA_OPT_BIN"/*; do
            if [[ -f "$bin" && -x "$bin" ]]; then
                sha256sum "$bin" >>"$manifest_tmp"
                log_info "Added: $bin"
            fi
        done
    fi

    # Move to final location
    mv "$manifest_tmp" "$CYTADELA_MANIFEST"
    chmod 644 "$CYTADELA_MANIFEST"

    log_success "Manifest created: $CYTADELA_MANIFEST"
    log_info "To verify: sudo $0 integrity-check"
}

# ==============================================================================
# INTEGRITY STATUS
# ==============================================================================
integrity_status() {
    log_section "🔐 INTEGRITY STATUS"

    echo "Mode: $CYTADELA_MODE"
    echo "Manifest: $CYTADELA_MANIFEST"

    if [[ -f "$CYTADELA_MANIFEST" ]]; then
        echo "Manifest exists: YES"
        local entries
        entries=$(grep -c -v '^#' "$CYTADELA_MANIFEST" 2>/dev/null || echo 0)
        echo "Entries: $entries"
        echo "Last modified: $(stat -c %y "$CYTADELA_MANIFEST" 2>/dev/null | cut -d. -f1)"
    else
        echo "Manifest exists: NO (run integrity-init to create)"
    fi

    echo ""
    echo "LKG directory: $CYTADELA_LKG_DIR"
    if [[ -d "$CYTADELA_LKG_DIR" ]]; then
        local lkg_files
        lkg_files=$(find "$CYTADELA_LKG_DIR" -type f 2>/dev/null | wc -l)
        echo "LKG files: $lkg_files"
    else
        echo "LKG directory: NOT CREATED"
    fi

    echo ""
    echo "Binaries directory: $CYTADELA_OPT_BIN"
    if [[ -d "$CYTADELA_OPT_BIN" ]]; then
        local bin_count
        bin_count=$(find "$CYTADELA_OPT_BIN" -type f -executable 2>/dev/null | wc -l)
        echo "Binaries: $bin_count"
    else
        echo "Binaries directory: NOT CREATED"
    fi
}
