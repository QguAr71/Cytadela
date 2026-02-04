# Skrypt instalacji podstawowej Citadel

#!/bin/bash
# Basic Citadel Installation Script
# Ten skrypt instaluje Citadel z podstawowymi ustawieniami

set -euo pipefail

# Kolory dla wyjścia
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funkcje pomocnicze
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Sprawdź czy użytkownik jest root'em
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Ten skrypt musi być uruchomiony z uprawnieniami root"
        log_info "Spróbuj: sudo $0"
        exit 1
    fi
}

# Sprawdź wymagania systemowe
check_requirements() {
    log_info "Sprawdzanie wymagań systemowych..."

    # Sprawdź systemd
    if ! command -v systemctl >/dev/null 2>&1; then
        log_error "systemd jest wymagany ale nie został znaleziony"
        exit 1
    fi

    # Sprawdź bash
    if ! command -v bash >/dev/null 2>&1; then
        log_error "bash jest wymagany ale nie został znaleziony"
        exit 1
    fi

    log_info "Wymagania systemowe spełnione"
}

# Zainstaluj zależności
install_dependencies() {
    log_info "Instalowanie zależności..."

    if command -v apt-get >/dev/null 2>&1; then
        # Ubuntu/Debian
        apt-get update
        apt-get install -y curl wget jq nftables systemd
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora/RHEL
        dnf install -y curl wget jq nftables systemd
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        pacman -S --noconfirm curl wget jq nftables systemd
    else
        log_warn "Nie rozpoznano menadżera pakietów. Zainstaluj ręcznie: curl wget jq nftables"
    fi

    log_info "Zależności zainstalowane"
}

# Skopiuj pliki Citadel
install_files() {
    log_info "Instalowanie plików Citadel..."

    # Utwórz katalogi
    mkdir -p /usr/local/lib/citadel
    mkdir -p /etc/citadel
    mkdir -p /var/log/citadel
    mkdir -p /var/run/citadel

    # Skopiuj pliki
    cp -r lib/* /usr/local/lib/citadel/
    cp citadel.sh /usr/local/bin/citadel.sh
    chmod +x /usr/local/bin/citadel.sh

    # Ustaw uprawnienia
    chown -R root:root /usr/local/lib/citadel
    chown -R root:systemd-journal /var/log/citadel
    chown -R root:root /var/run/citadel

    chmod -R 755 /usr/local/lib/citadel
    chmod -R 755 /var/log/citadel
    chmod -R 755 /var/run/citadel

    log_info "Pliki Citadel zainstalowane"
}

# Zainicjalizuj konfigurację
initialize_config() {
    log_info "Inicjalizowanie konfiguracji..."

    # Kopiuj przykładową konfigurację
    if [[ -f "examples/basic-config.yaml" ]]; then
        cp examples/basic-config.yaml /etc/citadel/config.yaml
        chown root:root /etc/citadel/config.yaml
        chmod 644 /etc/citadel/config.yaml
        log_info "Konfiguracja podstawowa skopiowana"
    else
        log_warn "Plik examples/basic-config.yaml nie znaleziony, używam domyślnej konfiguracji"
    fi
}

# Główna funkcja instalacji
main() {
    echo "=================================================="
    echo "  Citadel v3.3 - Instalacja Podstawowa"
    echo "=================================================="

    check_root
    check_requirements
    install_dependencies
    install_files
    initialize_config

    echo ""
    log_info "Instalacja Citadel zakończona pomyślnie!"
    echo ""
    log_info "Następne kroki:"
    echo "  1. Uruchom: citadel.sh config-init"
    echo "  2. Uruchom: citadel.sh unified-security-init"
    echo "  3. Uruchom: citadel.sh status"
    echo ""
    log_info "Dla pełnej funkcjonalności uruchom także:"
    echo "  citadel.sh service-setup-all"
    echo "  citadel.sh service-start citadel-main"
}

# Uruchom instalację
main "$@"
