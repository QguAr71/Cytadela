# 🚀 Quick Start Guide

Get Citadel up and running in 5 minutes!

---

## ⚡ Installation

### Step 1: Clone Repository
```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Citadel
```

### Step 2: Check Dependencies
```bash
sudo ./citadel.sh check-deps
```

### Step 3: Choose Installation Mode

**Option A: Graphical Wizard (Recommended)**
```bash
sudo ./citadel.sh install-wizard
```
- Interactive GUI with whiptail
- 7 languages support in wizard (auto-detect from $LANG): PL, EN, DE, ES, IT, FR, RU
- Step-by-step guidance

> **Note:** Currently only **PL and EN** have full documentation (MANUAL_PL.md, MANUAL_EN.md). Other 5 languages (DE, ES, IT, FR, RU) are available only in install-wizard interface. Complete i18n for all CLI commands, modules, and documentation is planned for **v3.2** (Weles-SysQ release).

**Option B: CLI for Hardcore Users**
```bash
sudo ./citadel.sh install-all
```
- No GUI - pure CLI
- Fast, automatic installation
- Full control via logs

> **Note:** For legacy version (v3.0), see `legacy/` directory

### Step 4: Configure System (Critical!)
```bash
sudo ./citadel.sh configure-system
```
- Switches from systemd-resolved to Citadel DNS
- Creates backup of original configuration
- Enables DNS leak protection

> **Important:** Without this step, Citadel is installed but not active. System still uses systemd-resolved.

### Step 5: Verify Installation
```bash
sudo ./citadel.sh verify
```

---

## 🎯 Basic Usage

### Check Status
```bash
sudo ./citadel.sh status
```

### Test DNS Resolution
```bash
sudo ./citadel.sh test
```

### View Adblock Statistics
```bash
sudo ./citadel.sh adblock-status
```

---

## 🔧 Essential Commands

```bash
# System Configuration
sudo ./citadel.sh configure-system    # Switch to Citadel DNS
sudo ./citadel.sh firewall-strict     # Enable strict firewall

# Monitoring
sudo ./citadel.sh health-status       # Health check
sudo ./citadel.sh cache-stats         # Cache statistics

# Maintenance
sudo ./citadel.sh auto-update-enable  # Enable auto-updates
sudo ./citadel.sh config-backup       # Backup configuration
```

---

## 🆘 Troubleshooting

### DNS Not Working?
```bash
sudo ./citadel.sh diagnostics
```

### Port Conflicts?
```bash
sudo ./citadel.sh fix-ports
```

### Emergency Recovery
```bash
sudo ./citadel.sh panic-bypass
```

---

## 📚 Next Steps

- [Full Manual (PL)](MANUAL_PL.md) - Complete Polish guide
- [Full Manual (EN)](MANUAL_EN.md) - Complete English guide
- [Commands Reference](commands.md) - All available commands
- [FAQ](FAQ.md) - Frequently asked questions

### Legacy Version

If you need the legacy monolithic version (v3.0):
```bash
cd legacy/
sudo ./cytadela++.sh install-all
```
See `legacy/README.md` for details.

---

**Need help?** Check the [FAQ](FAQ.md) or [open an issue](https://github.com/QguAr71/Cytadela/issues).
