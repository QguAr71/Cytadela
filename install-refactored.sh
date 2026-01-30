#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  CYTADELA++ v3.1 - Refactored Installation Script                         ║
# ║  Installs modular version to /opt/cytadela                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${CYAN}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }

# Root check
if [[ $EUID -ne 0 ]]; then
    log_error "This script requires root privileges. Run: sudo $0"
    exit 1
fi

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
INSTALL_DIR="/opt/cytadela"

log_info "Installing Cytadela++ v3.1 (refactored) to $INSTALL_DIR"

# Create directories
log_info "Creating directory structure..."
mkdir -p "$INSTALL_DIR"/{lib,modules}

# Copy libraries
log_info "Copying core libraries..."
cp -v "$SCRIPT_DIR"/lib/*.sh "$INSTALL_DIR/lib/"
chmod +x "$INSTALL_DIR"/lib/*.sh

# Copy modules
log_info "Copying modules..."
cp -v "$SCRIPT_DIR"/modules/*.sh "$INSTALL_DIR/modules/"
chmod +x "$INSTALL_DIR"/modules/*.sh

# Copy main scripts
log_info "Copying main scripts..."
cp -v "$SCRIPT_DIR/cytadela++.new.sh" "$INSTALL_DIR/cytadela++.sh"
cp -v "$SCRIPT_DIR/citadela_en.new.sh" "$INSTALL_DIR/citadela_en.sh"
chmod +x "$INSTALL_DIR/cytadela++.sh"
chmod +x "$INSTALL_DIR/citadela_en.sh"

# Copy VERSION file
if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
    cp -v "$SCRIPT_DIR/VERSION" "$INSTALL_DIR/"
fi

# Create symlinks in /usr/local/bin
log_info "Creating symlinks..."
ln -sf "$INSTALL_DIR/cytadela++.sh" /usr/local/bin/cytadela++
ln -sf "$INSTALL_DIR/citadela_en.sh" /usr/local/bin/citadela

log_success "Installation complete!"
echo ""
log_info "You can now run:"
echo "  sudo cytadela++ help          # Polish version"
echo "  sudo citadela help            # English version"
echo ""
log_info "Installed to: $INSTALL_DIR"
log_info "Symlinks created in: /usr/local/bin"
