# CYTADELA++ ARCHITECTURE DESIGN - Issues #11 & #12
**Deduplikacja PL/EN + Modularyzacja**

---

## PHASE 2: PROJEKTOWANIE ARCHITEKTURY

### 2.1 STRUKTURA KATALOGÓW

```
/opt/cytadela/
├── bin/                          # Binarne (CoreDNS, DNSCrypt) - Issue #1
│   └── .gitkeep
├── lib/                          # Biblioteki współdzielone
│   ├── cytadela-core.sh         # Core utilities (log_*, require_*, trap)
│   ├── network-utils.sh         # Network discovery & port utils
│   ├── i18n-pl.sh               # Polskie komunikaty
│   └── i18n-en.sh               # Angielskie komunikaty
├── modules/                      # Moduły funkcjonalne (lazy loading)
│   ├── integrity.sh             # Integrity checking (Issue #1)
│   ├── adblock.sh               # Adblock management
│   ├── emergency.sh             # Panic/emergency modes
│   ├── health.sh                # Health checks & watchdog
│   ├── supply-chain.sh          # Supply-chain verification
│   ├── location.sh              # Location-aware advisory
│   ├── ghost-check.sh           # Port exposure audit
│   ├── ipv6.sh                  # IPv6 management
│   ├── discover.sh              # Network discovery
│   ├── lkg.sh                   # Last Known Good
│   ├── nft-debug.sh             # NFTables debug
│   ├── install-dnscrypt.sh      # DNSCrypt installation
│   ├── install-coredns.sh       # CoreDNS installation
│   ├── install-nftables.sh      # NFTables installation
│   ├── install-all.sh           # Full installation
│   ├── diagnostics.sh           # Diagnostic tools
│   └── extras.sh                # New features v3.0
└── version                       # Version file

/home/qguar/Cytadela/            # Git repo (development)
├── cytadela++.sh                # Polish wrapper (nowy, mały)
├── citadela_en.sh               # English wrapper (nowy, mały)
├── lib/ -> /opt/cytadela/lib/   # Symlink do /opt (dev mode)
├── modules/ -> /opt/cytadela/modules/  # Symlink (dev mode)
└── install.sh                   # Installer (kopiuje do /opt)

/var/lib/cytadela/               # Runtime state
├── lkg/                         # Last Known Good cache
│   ├── blocklist.hosts
│   └── blocklist.meta
├── panic.state                  # Panic mode state
└── resolv.conf.pre-panic        # Backup resolv.conf

/etc/cytadela/                   # Configuration
├── manifest.sha256              # Integrity manifest
├── checksums.sha256             # Supply-chain checksums
└── trusted-ssids.txt            # Location-aware trusted SSIDs
```

---

### 2.2 NOWA ARCHITEKTURA GŁÓWNYCH SKRYPTÓW

#### **cytadela++.sh** (Polski wrapper - ~500 linii)

```bash
#!/bin/bash
# Citadel v3.1 - Polish Wrapper
set -euo pipefail

# === PATHS ===
CYTADELA_ROOT="/opt/cytadela"
CYTADELA_LIB="${CYTADELA_ROOT}/lib"
CYTADELA_MODULES="${CYTADELA_ROOT}/modules"

# Developer mode: use local files if in git repo
if [[ -f "$(dirname "$0")/lib/cytadela-core.sh" ]]; then
    CYTADELA_LIB="$(dirname "$0")/lib"
    CYTADELA_MODULES="$(dirname "$0")/modules"
    export CYTADELA_MODE="developer"
fi

# === LOAD CORE ===
source "${CYTADELA_LIB}/cytadela-core.sh"
source "${CYTADELA_LIB}/network-utils.sh"
source "${CYTADELA_LIB}/i18n-pl.sh"

# === LAZY MODULE LOADER ===
load_module() {
    local module="$1"
    local module_file="${CYTADELA_MODULES}/${module}.sh"
    
    if [[ ! -f "$module_file" ]]; then
        log_error "Moduł nie znaleziony: $module"
        return 1
    fi
    
    # Check if already loaded
    if [[ -n "${CYTADELA_LOADED_MODULES[$module]:-}" ]]; then
        return 0
    fi
    
    # Integrity check in secure mode
    if [[ "$CYTADELA_MODE" == "secure" ]]; then
        integrity_check_module "$module_file" || return 1
    fi
    
    source "$module_file"
    CYTADELA_LOADED_MODULES[$module]=1
    log_debug "Załadowano moduł: $module"
}

# === MODULE MAPPING ===
declare -A MODULE_MAP=(
    ["integrity-init"]="integrity"
    ["integrity-check"]="integrity"
    ["integrity-status"]="integrity"
    ["adblock-status"]="adblock"
    ["adblock-add"]="adblock"
    ["adblock-remove"]="adblock"
    ["adblock-rebuild"]="adblock"
    ["panic-bypass"]="emergency"
    ["panic-restore"]="emergency"
    ["panic-status"]="emergency"
    ["health-status"]="health"
    ["health-install"]="health"
    ["lkg-save"]="lkg"
    ["lkg-restore"]="lkg"
    ["lkg-status"]="lkg"
    ["lists-update"]="lkg"
    ["ipv6-privacy-auto"]="ipv6"
    ["ipv6-deep-reset"]="ipv6"
    ["discover"]="discover"
    ["ghost-check"]="ghost-check"
    ["location-status"]="location"
    ["location-check"]="location"
    ["nft-debug-on"]="nft-debug"
    ["nft-debug-off"]="nft-debug"
    ["supply-chain-init"]="supply-chain"
    ["supply-chain-verify"]="supply-chain"
    ["install-dnscrypt"]="install-dnscrypt"
    ["install-coredns"]="install-coredns"
    ["install-nftables"]="install-nftables"
    ["install-all"]="install-all"
    ["diagnostics"]="diagnostics"
    ["verify"]="diagnostics"
    ["test-all"]="diagnostics"
    ["install-dashboard"]="extras"
    ["install-editor"]="extras"
)

# === MAIN DISPATCHER ===
ACTION="${1:-help}"
shift || true

# Root check
[[ $EUID -ne 0 ]] && { log_error "Wymagane uprawnienia root. Uruchom: sudo $0"; exit 1; }

# Load required module
if [[ -n "${MODULE_MAP[$ACTION]:-}" ]]; then
    load_module "${MODULE_MAP[$ACTION]}"
fi

# Execute command
case "$ACTION" in
    help|--help|-h)
        show_help_pl
        ;;
    *)
        # Try to call function directly
        if declare -f "$ACTION" >/dev/null 2>&1; then
            "$ACTION" "$@"
        else
            # Try with underscores
            ACTION_FUNC="${ACTION//-/_}"
            if declare -f "$ACTION_FUNC" >/dev/null 2>&1; then
                "$ACTION_FUNC" "$@"
            else
                log_error "Nieznana komenda: $ACTION"
                show_help_pl
                exit 1
            fi
        fi
        ;;
esac
```

#### **citadela_en.sh** (English wrapper - ~500 linii)

```bash
#!/bin/bash
# Citadel++ v3.1 - English Wrapper
set -euo pipefail

# === PATHS ===
CYTADELA_ROOT="/opt/cytadela"
CYTADELA_LIB="${CYTADELA_ROOT}/lib"
CYTADELA_MODULES="${CYTADELA_ROOT}/modules"

# Developer mode: use local files if in git repo
if [[ -f "$(dirname "$0")/lib/cytadela-core.sh" ]]; then
    CYTADELA_LIB="$(dirname "$0")/lib"
    CYTADELA_MODULES="$(dirname "$0")/modules"
    export CYTADELA_MODE="developer"
fi

# === LOAD CORE ===
source "${CYTADELA_LIB}/cytadela-core.sh"
source "${CYTADELA_LIB}/network-utils.sh"
source "${CYTADELA_LIB}/i18n-en.sh"

# === LAZY MODULE LOADER ===
# (identyczny jak w wersji polskiej)

# === MODULE MAPPING ===
# (identyczny jak w wersji polskiej)

# === MAIN DISPATCHER ===
# (identyczny jak w wersji polskiej, tylko show_help_en)
```

---

### 2.3 BIBLIOTEKI WSPÓŁDZIELONE

#### **lib/cytadela-core.sh** (~300 linii)

```bash
#!/bin/bash
# Cytadela Core Library v3.1
# Shared utilities for all modules

# === GLOBAL VARIABLES ===
CYTADELA_VERSION="3.1.0"
CYTADELA_MANIFEST="/etc/cytadela/manifest.sha256"
CYTADELA_STATE_DIR="/var/lib/cytadela"
CYTADELA_LKG_DIR="${CYTADELA_STATE_DIR}/lkg"
CYTADELA_OPT_BIN="/opt/cytadela/bin"
CYTADELA_MODE="${CYTADELA_MODE:-secure}"
CYTADELA_SCRIPT_PATH="$(realpath "$0")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Loaded modules tracking
declare -gA CYTADELA_LOADED_MODULES

# === LOGGING FUNCTIONS ===
log_info() { echo -e "${CYAN}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }
log_section() { 
    echo -e "\n${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬${NC}\n"
}
log_debug() {
    [[ "${CYTADELA_DEBUG:-0}" == "1" ]] && echo -e "${BLUE}[DEBUG]${NC} $1" >&2
}

# === ERROR TRAP ===
trap_err_handler() {
    local exit_code=$?
    local line_no=${BASH_LINENO[0]}
    local func_name=${FUNCNAME[1]:-main}
    local command="$BASH_COMMAND"
    echo -e "${RED}✗ ERROR in ${func_name}() at line ${line_no}: '${command}' exited with code ${exit_code}${NC}" >&2
}
trap 'trap_err_handler' ERR

# === UTILITY FUNCTIONS ===
require_cmd() {
    command -v "$1" >/dev/null 2>&1
}

require_cmds() {
    local missing=()
    for cmd in "$@"; do
        require_cmd "$cmd" || missing+=("$cmd")
    done
    if (( ${#missing[@]} > 0 )); then
        log_error "Missing required tools: ${missing[*]}"
        return 1
    fi
}

dnssec_enabled() {
    [[ "${CITADEL_DNSSEC:-}" =~ ^(1|true|yes|on)$ ]] && return 0
    [[ "${1:-}" == "--dnssec" || "${2:-}" == "--dnssec" ]] && return 0
    return 1
}

# === INTEGRITY CHECK FOR MODULES ===
integrity_check_module() {
    local module_file="$1"
    
    [[ "$CYTADELA_MODE" == "developer" ]] && return 0
    [[ ! -f "$CYTADELA_MANIFEST" ]] && return 0
    
    local expected_hash
    expected_hash=$(grep -F "$module_file" "$CYTADELA_MANIFEST" 2>/dev/null | awk '{print $1}')
    
    [[ -z "$expected_hash" ]] && return 0
    
    local actual_hash
    actual_hash=$(sha256sum "$module_file" | awk '{print $1}')
    
    if [[ "$actual_hash" != "$expected_hash" ]]; then
        log_warning "Module integrity mismatch: $module_file"
        if [[ ! -t 0 ]]; then
            log_error "Non-interactive mode: aborting"
            return 1
        fi
        echo -n "Continue despite mismatch? [y/N]: "
        read -r answer
        [[ "$answer" =~ ^[Yy]$ ]] || return 1
    fi
    
    return 0
}
```

#### **lib/network-utils.sh** (~200 linii)

```bash
#!/bin/bash
# Cytadela Network Utilities v3.1

# Ports
DNSCRYPT_PORT_DEFAULT=5353
COREDNS_PORT_DEFAULT=53
COREDNS_METRICS_ADDR="127.0.0.1:9153"

# === INTERFACE DISCOVERY ===
discover_active_interface() {
    local iface=""
    iface=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}' || true)
    [[ -z "$iface" ]] && iface=$(ip -6 route get 2001:4860:4860::8888 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}' || true)
    echo "$iface"
}

discover_network_stack() {
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        echo "NetworkManager"
    elif systemctl is-active --quiet systemd-networkd 2>/dev/null; then
        echo "systemd-networkd"
    elif command -v nmcli &>/dev/null && nmcli -t -f RUNNING general 2>/dev/null | grep -q running; then
        echo "NetworkManager"
    else
        echo "unknown"
    fi
}

discover_nftables_status() {
    local nft_version="" citadel_tables=""
    if command -v nft &>/dev/null; then
        nft_version=$(nft --version 2>/dev/null | head -1 || echo "unknown")
        citadel_tables=$(nft list tables 2>/dev/null | grep -c "citadel" || echo "0")
    else
        nft_version="not installed"
        citadel_tables="0"
    fi
    echo "version:${nft_version}|citadel_tables:${citadel_tables}"
}

# === PORT UTILITIES ===
port_in_use() {
    local port="$1"
    ss -H -lntu | awk '{print $5}' | grep -Eq "(^|:)${port}$" 2>/dev/null
}

pick_free_port() {
    local start="$1" end="$2"
    for p in $(seq "$start" "$end"); do
        port_in_use "$p" || { echo "$p"; return 0; }
    done
    return 1
}

get_dnscrypt_listen_port() {
    local cfg="/etc/dnscrypt-proxy/dnscrypt-proxy.toml"
    [[ -f "$cfg" ]] && awk -F"[:']" '/^listen_addresses[[:space:]]*=/{for(i=1;i<=NF;i++){if($i ~ /^[0-9]+$/){print $i; exit}}}' "$cfg" 2>/dev/null || true
}

get_coredns_listen_port() {
    local cfg="/etc/coredns/Corefile"
    [[ -f "$cfg" ]] && awk -F'[:}]' '/^\.:/{gsub(/[^0-9]/,"",$2); if($2!=""){print $2; exit}}' "$cfg" 2>/dev/null || true
}
```

#### **lib/i18n-pl.sh** (~200 linii - tylko komunikaty)

```bash
#!/bin/bash
# Cytadela i18n - Polish Messages

# === HELP FUNCTION ===
show_help_pl() {
    cat <<'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                  CITADEL++ v3.1 - Instrukcja                              ║
╚═══════════════════════════════════════════════════════════════════════════╝

Instalacja:
  install-dnscrypt      Instaluj tylko DNSCrypt-Proxy
  install-coredns       Instaluj tylko CoreDNS
  install-nftables      Instaluj tylko NFTables
  install-all           Pełna instalacja

Zarządzanie:
  adblock-status        Status adblock
  adblock-add <domena>  Dodaj domenę do blokady
  lists-update          Aktualizuj blocklist

Diagnostyka:
  discover              Snapshot sieci
  health-status         Status zdrowia
  verify                Weryfikacja stacku

Pomoc:
  help                  Ten ekran pomocy

Więcej: https://github.com/QguAr71/Cytadela
EOF
}

# === I18N MESSAGES ===
MSG_ROOT_REQUIRED="Ten skrypt wymaga uprawnień root. Uruchom: sudo \$0"
MSG_MODULE_NOT_FOUND="Moduł nie znaleziony"
MSG_UNKNOWN_COMMAND="Nieznana komenda"
# ... więcej komunikatów
```

#### **lib/i18n-en.sh** (~200 linii - tylko komunikaty)

```bash
#!/bin/bash
# Cytadela i18n - English Messages

show_help_en() {
    cat <<'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║                  CITADEL++ v3.1 - Help                                    ║
╚═══════════════════════════════════════════════════════════════════════════╝

Installation:
  install-dnscrypt      Install DNSCrypt-Proxy only
  install-coredns       Install CoreDNS only
  install-nftables      Install NFTables only
  install-all           Full installation

Management:
  adblock-status        Show adblock status
  adblock-add <domain>  Add domain to blocklist
  lists-update          Update blocklist

Diagnostics:
  discover              Network snapshot
  health-status         Health status
  verify                Verify stack

Help:
  help                  This help screen

More: https://github.com/QguAr71/Cytadela
EOF
}

MSG_ROOT_REQUIRED="This script requires root privileges. Run: sudo \$0"
MSG_MODULE_NOT_FOUND="Module not found"
MSG_UNKNOWN_COMMAND="Unknown command"
# ... more messages
```

---

### 2.4 PRZYKŁADOWY MODUŁ

#### **modules/integrity.sh** (~300 linii)

```bash
#!/bin/bash
# Cytadela Integrity Module v3.1
# Local-First Security Policy (Issue #1)

# === INTEGRITY FUNCTIONS ===
integrity_verify_file() {
    local file="$1" expected_hash="$2"
    [[ ! -f "$file" ]] && return 2
    local actual_hash=$(sha256sum "$file" | awk '{print $1}')
    [[ "$actual_hash" == "$expected_hash" ]]
}

integrity_check() {
    local silent="${1:-}"
    local has_errors=0 has_warnings=0
    
    [[ "$CYTADELA_MODE" == "developer" ]] && {
        [[ -z "$silent" ]] && log_info "[DEV MODE] Integrity checks bypassed"
        return 0
    }
    
    [[ ! -f "$CYTADELA_MANIFEST" ]] && {
        log_warning "Integrity not initialized. Run: sudo $0 integrity-init"
        return 0
    }
    
    [[ -z "$silent" ]] && log_info "Verifying integrity from $CYTADELA_MANIFEST ..."
    
    while IFS='  ' read -r hash filepath; do
        [[ -z "$hash" || "$hash" == "#"* ]] && continue
        
        local is_binary=0
        [[ "$filepath" == "$CYTADELA_OPT_BIN"/* ]] && is_binary=1
        
        if [[ ! -f "$filepath" ]]; then
            log_warning "Missing: $filepath"
            has_warnings=1
            continue
        fi
        
        if ! integrity_verify_file "$filepath" "$hash"; then
            if [[ $is_binary -eq 1 ]]; then
                log_error "INTEGRITY FAIL (binary): $filepath"
                has_errors=1
            else
                log_warning "INTEGRITY MISMATCH (module): $filepath"
                has_warnings=1
                if [[ ! -t 0 && ! -t 1 ]]; then
                    log_error "Non-interactive mode: aborting due to integrity mismatch"
                    has_errors=1
                else
                    echo -n "Continue despite mismatch? [y/N]: "
                    read -r answer
                    [[ ! "$answer" =~ ^[Yy]$ ]] && has_errors=1
                fi
            fi
        else
            [[ -z "$silent" ]] && log_success "OK: $filepath"
        fi
    done < "$CYTADELA_MANIFEST"
    
    if [[ $has_errors -eq 1 ]]; then
        log_error "Integrity check FAILED. Aborting."
        exit 1
    fi
    
    [[ $has_warnings -gt 0 ]] && [[ -z "$silent" ]] && log_warning "Integrity check passed with $has_warnings warning(s)"
    [[ $has_warnings -eq 0 ]] && [[ -z "$silent" ]] && log_success "Integrity check passed"
    return 0
}

integrity_init() {
    log_section "🔐 INTEGRITY INIT"
    mkdir -p "$(dirname "$CYTADELA_MANIFEST")" "$CYTADELA_LKG_DIR" "$CYTADELA_OPT_BIN"
    
    local manifest_tmp=$(mktemp)
    echo "# Cytadela integrity manifest - generated $(date -Iseconds)" > "$manifest_tmp"
    echo "# Format: sha256  filepath" >> "$manifest_tmp"
    
    # Add main scripts
    for script in "$CYTADELA_SCRIPT_PATH" "$(dirname "$CYTADELA_SCRIPT_PATH")/cytadela++.sh" "$(dirname "$CYTADELA_SCRIPT_PATH")/citadela_en.sh"; do
        [[ -f "$script" ]] && { sha256sum "$script" >> "$manifest_tmp"; log_info "Added: $script"; }
    done
    
    # Add lib files
    for lib in "${CYTADELA_LIB}"/*.sh; do
        [[ -f "$lib" ]] && { sha256sum "$lib" >> "$manifest_tmp"; log_info "Added: $lib"; }
    done
    
    # Add modules
    for mod in "${CYTADELA_MODULES}"/*.sh; do
        [[ -f "$mod" ]] && { sha256sum "$mod" >> "$manifest_tmp"; log_info "Added: $mod"; }
    done
    
    # Add binaries
    if [[ -d "$CYTADELA_OPT_BIN" ]]; then
        for bin in "$CYTADELA_OPT_BIN"/*; do
            [[ -f "$bin" && -x "$bin" ]] && { sha256sum "$bin" >> "$manifest_tmp"; log_info "Added: $bin"; }
        done
    fi
    
    mv "$manifest_tmp" "$CYTADELA_MANIFEST"
    chmod 644 "$CYTADELA_MANIFEST"
    
    log_success "Manifest created: $CYTADELA_MANIFEST"
    log_info "To verify: sudo $0 integrity-check"
}

integrity_status() {
    log_section "🔐 INTEGRITY STATUS"
    echo "Mode: $CYTADELA_MODE"
    echo "Manifest: $CYTADELA_MANIFEST"
    if [[ -f "$CYTADELA_MANIFEST" ]]; then
        echo "Manifest exists: YES"
        echo "Entries: $(grep -c -v '^#' "$CYTADELA_MANIFEST" 2>/dev/null || echo 0)"
    else
        echo "Manifest exists: NO (run integrity-init to create)"
    fi
    echo "LKG directory: $CYTADELA_LKG_DIR"
    [[ -d "$CYTADELA_LKG_DIR" ]] && echo "LKG files: $(find "$CYTADELA_LKG_DIR" -type f 2>/dev/null | wc -l)"
}
```

---

## PODSUMOWANIE ARCHITEKTURY

### Zalety Nowego Podejścia:

1. **Deduplikacja:** ~3600 linii oszczędności (50%)
2. **Modularność:** Lazy loading - ładuj tylko potrzebne moduły
3. **Utrzymywalność:** Jedna logika, dwie wersje językowe
4. **Bezpieczeństwo:** Integrity check dla każdego modułu
5. **Developer Mode:** Automatyczna detekcja git repo
6. **Backward Compatibility:** Wszystkie komendy działają tak samo

### Struktura Plików:

- **Core:** ~500 linii (cytadela-core.sh + network-utils.sh)
- **i18n:** 2x ~200 linii (komunikaty PL/EN)
- **Wrappers:** 2x ~500 linii (cytadela++.sh + citadela_en.sh)
- **Moduły:** ~15 plików x ~200-400 linii = ~4000 linii
- **RAZEM:** ~6000 linii (vs 7153 obecnie)

✅ **PHASE 2 ZAKOŃCZONA**  
➡️ **PHASE 3:** Plan migracji i strategia testowania
