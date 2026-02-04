#!/bin/bash
# Direct Citadel v3.2 Installation Script - Bypasses dispatcher issues

set -e

echo "🚀 Citadel v3.2 - Direct Installation Script"
echo "=========================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📍 Working directory: $SCRIPT_DIR"

# Function to run module directly
run_module() {
    local module="$1"
    local func="${2:-main}"
    local script="$SCRIPT_DIR/modules/${module}.sh"
    
    if [[ -f "$script" ]]; then
        echo "▶️ Running $module..."
        chmod +x "$script" 2>/dev/null || true
        source "$script"
        if declare -f "$func" >/dev/null 2>&1; then
            "$func"
        else
            echo "⚠️ Function $func not found in $module, trying direct execution..."
            bash "$script"
        fi
    else
        echo "❌ Module $script not found"
        return 1
    fi
}

echo ""
echo "1️⃣ Checking dependencies..."
run_module "check-dependencies"

echo ""
echo "2️⃣ Installing DNSCrypt..."
run_module "install-dnscrypt"

echo ""
echo "3️⃣ Installing CoreDNS..."
run_module "install-coredns"

echo ""
echo "4️⃣ Configuring NFTables firewall..."
run_module "install-nftables" "install_firewall_safe"

echo ""
echo "5️⃣ Configuring system DNS..."
# Direct DNS configuration
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf.backup 2>/dev/null || true

echo ""
echo "✅ Installation completed!"
echo ""
echo "🔍 Verifying installation..."
systemctl status dnscrypt-proxy --no-pager -l || echo "⚠️ DNSCrypt status check failed"
systemctl status coredns --no-pager -l || echo "⚠️ CoreDNS status check failed"
nft list ruleset | head -10 || echo "⚠️ NFTables check failed"

echo ""
echo "🧪 Testing DNS..."
dig @127.0.0.1 google.com +short || echo "⚠️ DNS test failed"

echo ""
echo "📚 Next steps:"
echo "• Run: citadel-top (terminal dashboard)"
echo "• Update blocklists: sudo ./citadel.sh backup lists-update"
echo "• Enable auto-updates: sudo ./citadel.sh backup auto-update-enable"
echo ""
echo "🎉 Citadel v3.2 installation complete!"
