# 📦 Citadel Legacy (v3.0)

This directory contains the **legacy monolithic version** of Citadel (formerly Citadel).

## ⚠️ Status: Stable but Deprecated

- **Version:** 3.0
- **Status:** Stable, fully functional
- **Maintenance:** Security fixes only
- **Recommended:** Use the new modular version (`citadel.sh` in root directory)

## 📋 Files

- `cytadela++.sh` - Legacy Polish version (128KB)
- `citadela_en.sh` - Legacy English version (123KB)
- `docs/` - Legacy documentation

## 🚀 Usage

```bash
# Polish version
sudo ./cytadela++.sh help

# English version
sudo ./citadela_en.sh help
```

## 📚 Documentation

See `docs/` directory for:
- `NOTES_PL.md` - Polish notes
- `NOTES_EN.md` - English notes
- `MANUAL_PL.md` - Polish manual
- `MANUAL_EN.md` - English manual

## 🔄 Migration to New Version

To migrate to the new modular version:

```bash
cd ..
sudo ./citadel.sh help
```

All legacy commands are available in the new version with improved architecture.

## 📊 Comparison

| Feature | Legacy v3.0 | New v3.1+ |
|---------|-------------|-----------|
| Commands | 73 | 101 |
| Architecture | Monolithic | Modular |
| File size | 128KB | 7KB + modules |
| Maintenance | Deprecated | Active |
| New features | No | Yes |

## ℹ️ Why Legacy?

Legacy version is kept for:
- Backward compatibility
- Reference implementation
- Users who prefer monolithic scripts

**For new installations, use the new modular version!**
