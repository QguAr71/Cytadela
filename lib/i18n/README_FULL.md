# 🌍 Citadel Full Internationalization System

## Overview

Citadel now has a complete i18n system that supports translating the entire application, not just the installer.

## Structure

```
lib/i18n/
├── installer/       # Install wizard translations (7 languages)
│   ├── en.sh, pl.sh, de.sh, fr.sh, es.sh, it.sh, ru.sh
│   └── README.md
├── common/          # Shared strings across all modules
│   ├── en.sh
│   └── pl.sh
├── diagnostics/     # Diagnostics & verify commands
│   ├── en.sh
│   └── pl.sh
├── adblock/         # Adblock module
│   ├── en.sh
│   └── pl.sh
└── help/            # Help system
    ├── en.sh
    └── pl.sh
```

## Usage

### Setting Language

**Auto-detection from $LANG:**
```bash
LANG=pl_PL.UTF-8 sudo cytadela++ verify
```

**Force specific language:**
```bash
CYTADELA_LANG=pl sudo cytadela++ verify
CYTADELA_LANG=en sudo cytadela++ adblock-add example.com
```

### In Modules

Load i18n at the start of your module:

```bash
#!/bin/bash
# modules/your-module.sh

# Load i18n
load_i18n_module "your-module"

# Use translated strings
your_function() {
    log_success "$YOUR_MODULE_SUCCESS"
    log_error "$YOUR_MODULE_FAILED"
}
```

## Available String Categories

### Common (`lib/i18n/common/`)
- Status messages (MSG_SUCCESS, MSG_FAILED, etc.)
- Actions (ACT_INSTALLING, ACT_CONFIGURING, etc.)
- Questions (Q_CONTINUE, Q_CONFIRM, etc.)
- Services (SVC_COREDNS, SVC_DNSCRYPT, etc.)
- States (STATE_RUNNING, STATE_STOPPED, etc.)

### Diagnostics (`lib/i18n/diagnostics/`)
- Verify command output
- Service status
- Firewall status
- DNS tests
- Metrics

### Adblock (`lib/i18n/adblock/`)
- Add/remove operations
- Query results
- Allowlist management
- Statistics

### Help (`lib/i18n/help/`)
- Help system headers
- Command categories
- Common help strings

## Adding a New Module Translation

1. Create directory: `mkdir -p lib/i18n/your-module`

2. Create English file: `lib/i18n/your-module/en.sh`
```bash
#!/bin/bash
export YOUR_MODULE_SUCCESS="Operation successful"
export YOUR_MODULE_FAILED="Operation failed"
```

3. Create Polish file: `lib/i18n/your-module/pl.sh`
```bash
#!/bin/bash
export YOUR_MODULE_SUCCESS="Operacja zakończona sukcesem"
export YOUR_MODULE_FAILED="Operacja nie powiodła się"
```

4. Load in your module:
```bash
load_i18n_module "your-module"
```

## Current Status

### Fully Translated (EN + PL)
- ✅ Installer (7 languages: EN, PL, DE, FR, ES, IT, RU)
- ✅ Common strings
- ✅ Diagnostics
- ✅ Adblock
- ✅ Help system

### To Be Translated
- ⏳ Health module
- ⏳ IPv6 module
- ⏳ Location module
- ⏳ NFT Debug module
- ⏳ Supply chain module

## Contributing

To add translations for a new language:

1. Copy `en.sh` files to `XX.sh` (where XX is language code)
2. Translate all exported variables
3. Test with: `CYTADELA_LANG=XX sudo cytadela++ verify`
4. Submit a Pull Request

## Language Codes

- `en` - English
- `pl` - Polish (Polski)
- `de` - German (Deutsch)
- `fr` - French (Français)
- `es` - Spanish (Español)
- `it` - Italian (Italiano)
- `ru` - Russian (Русский)

## Notes

- All strings use `export` to be available in subshells
- Variable naming convention: `MODULE_CATEGORY_DESCRIPTION`
- Keep strings concise but descriptive
- Use UPPERCASE for exported variables
- Test all translations before committing
