# 🚀 Quick Start Guide

Get Citadel up and running in 5 minutes!

---

## ⚡ Installation

### Step 1: Clone Repository
```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Citadel
```

### Step 2: Choose Installation Mode

**Option A: Graphical Wizard (Recommended)**
```bash
sudo ./citadel.sh install-wizard
```
- Interactive GUI with whiptail
- 7 languages support (auto-detect from $LANG)
- Step-by-step guidance

**Option B: CLI for Hardcore Users**
```bash
sudo ./citadel.sh install-all
```
- No GUI - pure CLI
- Fast, automatic installation
- Full control via logs

> **Note:** For legacy version (v3.0), see `legacy/` directory

### Step 3: Verify Installation
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
- [Commands Reference](commands.md) - All 101 commands
- [Troubleshooting](troubleshooting.md)

### Legacy Version

If you need the legacy monolithic version (v3.0):
```bash
cd legacy/
sudo ./cytadela++.sh install-all
```
See `legacy/README.md` for details.

---

**Need help?** Check the [FAQ](faq.md) or [open an issue](https://github.com/QguAr71/Cytadela/issues).
