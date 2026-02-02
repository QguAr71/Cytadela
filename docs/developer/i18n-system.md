# Internationalization (i18n) System

## Overview

Citadel uses a flexible internationalization system supporting 7 languages:
- 🇵🇱 Polish (pl)
- 🇬🇧 English (en) - default
- 🇩🇪 German (de)
- 🇪🇸 Spanish (es)
- 🇮🇹 Italian (it)
- 🇫🇷 French (fr)
- 🇷🇺 Russian (ru)

## File Structure

```
lib/i18n/
├── common/           # Common strings for all modules
│   ├── en.sh
│   ├── pl.sh
│   ├── de.sh
│   ├── es.sh
│   ├── it.sh
│   ├── fr.sh
│   └── ru.sh
└── [module]/         # Module-specific translations
    ├── en.sh
    └── pl.sh
```

## Adding a New Language

1. Create language files in `lib/i18n/common/` and `lib/i18n/[module]/`
2. Follow the naming convention: `[language_code].sh`
3. Copy structure from existing language (e.g., `en.sh`)
4. Translate all strings
5. Add language to `detect_language()` in `lib/cytadela-core.sh`

## Language File Format

```bash
#!/bin/bash
# strings_[LANG].sh - [Language Name] translations

# Module: [module_name]
I18N_MODULE_NAME="Translated Module Name"
I18N_WELCOME="Welcome message"
# ... etc
```

## Loading Translations

```bash
# In your module
load_i18n_module "module_name"
```

This automatically loads:
1. Common strings for current language
2. Module-specific strings for current language
3. Falls back to English if translation missing

## Testing Translations

```bash
# Force specific language
CYTADELA_LANG=pl sudo ./citadel.sh [command]

# Check loaded strings
sudo ./citadel.sh debug-i18n
```

## Current Status

- ✅ install-wizard: 7 languages
- ⚠️  Other modules: EN/PL only (v3.2+)
