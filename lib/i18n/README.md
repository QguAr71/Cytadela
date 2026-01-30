# 🌍 Cytadela++ Internationalization (i18n)

## Adding a New Language

Want to add support for a new language? It's easy! Just follow these steps:

### Step 1: Create Translation File

Copy the English template and translate all strings:

```bash
cp lib/i18n/en.sh lib/i18n/de.sh  # For German
# or
cp lib/i18n/en.sh lib/i18n/fr.sh  # For French
```

Edit the new file and translate all `T_*` variables:

```bash
# lib/i18n/de.sh
export T_WIZARD_TITLE="INTERAKTIVER INSTALLATIONSASSISTENT"
export T_DIALOG_TITLE="Cytadela++ v3.1 - Installationsassistent"
export T_SELECT_MODULES="Wählen Sie Module aus:"
# ... etc
```

### Step 2: Update Language Detection

Edit `modules/install-wizard.sh` and add your language to `detect_language()`:

```bash
detect_language() {
    if [[ "${LANG}" =~ ^pl ]]; then
        echo "pl"
    elif [[ "${LANG}" =~ ^de ]]; then  # ← ADD THIS
        echo "de"
    else
        echo "en"
    fi
}
```

### Step 3: Add to Language Menu

Add your language to the selection menu in `select_language()`:

```bash
choice=$(whiptail --title "Language / Język / Sprache" \
    --menu "Select language / Wybierz język / Sprache wählen:" 12 50 3 \
    "en" "English" \
    "pl" "Polski" \
    "de" "Deutsch" \    # ← ADD THIS
    3>&1 1>&2 2>&3)
```

### Step 4: Update Module Descriptions

Add translated module descriptions in `install_wizard()`:

```bash
if [[ "$WIZARD_LANG" == "pl" ]]; then
    MODULES=(...)
elif [[ "$WIZARD_LANG" == "de" ]]; then  # ← ADD THIS
    MODULES=(
        [dnscrypt]="DNSCrypt-Proxy|$T_MOD_DNSCRYPT|1|1"
        [coredns]="CoreDNS|$T_MOD_COREDNS|1|1"
        [nftables]="NFTables|$T_MOD_NFTABLES|1|1"
        [health]="Health Watchdog|$T_MOD_HEALTH|0|0"
        [supply-chain]="Supply-chain|$T_MOD_SUPPLY|0|0"
        [lkg]="LKG Cache|$T_MOD_LKG|1|0"
        [ipv6]="IPv6 Privacy|$T_MOD_IPV6|0|0"
        [location]="Location-aware|$T_MOD_LOCATION|0|0"
        [nft-debug]="NFT Debug|$T_MOD_DEBUG|0|0"
    )
else
    MODULES=(...)  # English
fi
```

### Step 5: Test Your Translation

```bash
sudo cytadela++ install-wizard de  # Force German
# or
LANG=de_DE.UTF-8 sudo cytadela++ install-wizard  # Auto-detect
```

---

## Translation File Structure

Each translation file (`lib/i18n/*.sh`) contains exported variables:

| Variable | Description | Example (EN) | Example (PL) |
|----------|-------------|--------------|--------------|
| `T_WIZARD_TITLE` | Main wizard title | "INTERACTIVE INSTALLER WIZARD" | "INTERAKTYWNY KREATOR INSTALACJI" |
| `T_DIALOG_TITLE` | Whiptail dialog title | "Installation Wizard" | "Kreator Instalacji" |
| `T_SELECT_MODULES` | Module selection prompt | "Select modules to install:" | "Wybierz moduły do instalacji:" |
| `T_INSTALLING` | Installing message | "Installing" | "Instalowanie" |
| `T_INSTALLED` | Success message | "installed" | "zainstalowany" |
| ... | ... | ... | ... |

**Total strings to translate: ~35**

---

## Supported Languages

- 🇬🇧 **English** (`en`) - Default
- 🇵🇱 **Polish** (`pl`) - Complete
- 🇩🇪 **German** (`de`) - Template ready (needs translation)
- 🇫🇷 **French** (`fr`) - Template ready (needs translation)
- 🇪🇸 **Spanish** (`es`) - Template ready (needs translation)

---

## Contributing Translations

1. Fork the repository
2. Create a new translation file: `lib/i18n/XX.sh` (where XX is language code)
3. Translate all `T_*` variables
4. Update `modules/install-wizard.sh` (steps 2-4 above)
5. Test your translation
6. Submit a Pull Request

**Thank you for helping make Cytadela++ accessible to more users!** 🌍

---

## Language Codes

Use ISO 639-1 two-letter codes:

- `en` - English
- `pl` - Polish (Polski)
- `de` - German (Deutsch)
- `fr` - French (Français)
- `es` - Spanish (Español)
- `it` - Italian (Italiano)
- `ru` - Russian (Русский)
- `ja` - Japanese (日本語)
- `zh` - Chinese (中文)

---

## Auto-Detection

Cytadela++ automatically detects language from `$LANG` environment variable:

```bash
LANG=pl_PL.UTF-8  → Polish
LANG=de_DE.UTF-8  → German
LANG=en_US.UTF-8  → English
```

Users can override with parameter:

```bash
sudo cytadela++ install-wizard en  # Force English
sudo cytadela++ install-wizard pl  # Force Polish
```
