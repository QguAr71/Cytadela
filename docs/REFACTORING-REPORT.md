# Raport zmian - Refaktoryzacja UI Citadel
## Data: 2026-02-03

---

## 1. Nowy moduł ramkowy: `lib/frame-ui.sh`

Utworzono osobny moduł do rysowania ramek UI, przeniesiony z `cytadela-core.sh`:

### Funkcje:
- `print_frame_line()` - pojedyncza linia z kolorowymi obramowaniami
- `draw_section_header()` - nagłówek sekcji z fioletową ramką (obsługa emoji)
- `draw_emergency_frame()` - ramka awaryjna na czerwono
- `log_section()` - backward compatibility (używa `draw_section_header`)

### Poprawki:
- Naprawiono liczenie szerokości emoji (emoji zajmuje 2 kolumny terminala)
- Usunięto problematyczne `wc -l` (błąd przy pustym wejściu)
- Zastąpiono przez bash regex: `[[ "$var" =~ [📦🛡🎯📋🚀✅🔐🏥🔧🔒] ]]`

---

## 2. Install-wizard (`modules/install-wizard.sh`)

### Ramki:
- 🛡️ SAFETY BACKUP - fioletowa ramka z emoji
- 📦 OPTIONAL DEPENDENCIES - fioletowa ramka
- 🎯 T_WIZARD_TITLE - fioletowa ramka
- 📋 INSTALLATION SUMMARY - fioletowa ramka
- 🚀 INSTALLING MODULES - fioletowa ramka
- ✅ INSTALACJA ZAKOŃCZONA / INSTALLATION COMPLETE - fioletowa ramka

### Poprawki:
- Dodano `|| true` przy whiptail (obsługa Cancel/Escape)
- Sprawdzanie `[[ -z "$choice" ]]` po anulowaniu

### Moduły instalacyjne (używają `draw_section_header`):
- `install-dnscrypt.sh` - MODULE 1: DNSCrypt-Proxy
- `install-coredns.sh` - MODULE 2: CoreDNS (używa log_section)
- `install-nftables.sh` - MODULE 3: NFTables Firewall
- `ipv6.sh` - 🔒 IPv6 PRIVACY AUTO-ENSURE
- `health.sh` - 🏥 HEALTH STATUS
- `supply-chain.sh` - 🔐 SUPPLY-CHAIN STATUS/INIT/VERIFY
- `nft-debug.sh` - 🔧 NFT DEBUG

---

## 3. Uninstall (`modules/uninstall.sh`)

### Ramki:
- EMERGENCY RECOVERY - czerwona ramka (na końcu uninstall)
- Wykorzystuje `draw_emergency_frame` z szablonu

### Poprawki:
- Poprawiono ścieżkę backupu DNS (`${CYTADELA_STATE_DIR}/backups`)
- Dodano brakujący `}` zamykający funkcję `citadel_uninstall()`

---

## 4. Help (`modules/help.sh`)

### Główne menu:
- Fioletowa ramka z nagłówkiem "CITADEL++ HELP"
- Fioletowe obramowanie dla wszystkich linii (`print_frame_line`)
- `[q] Quit` - kolor magenta (MAG) zamiast czerwonego

### Sekcje (wszystkie z fioletowymi ramkami):
1. **INSTALLATION** - rozszerzona lista:
   - install-wizard, install-all
   - install-dnscrypt, install-coredns, install-nftables
   - **NOWE**: install-health, install-supply-chain, install-lkg
   - **NOWE**: install-ipv6, install-location, install-nft-debug
   - install-dashboard, install-editor, install-doh-parallel

2. **MAIN PROGRAM** - 11 komend
3. **ADD-ONS** - 12 komend
4. **ADVANCED** - 15 komend
5. **EMERGENCY & RECOVERY** - 10 komend
6. **ALL COMMANDS** - pełna lista wszystkich komend

---

## 5. i18n - nowe zmienne tłumaczeń

### Dodano do wszystkich języków (en, pl, de, es, fr, it, ru):

**Nowe zmienne sekcji:**
- `T_HELP_SECTION_ALL` - "6. ALL COMMANDS" (lub tłumaczenie)

**Nowe komendy instalacyjne:**
- `T_HELP_CMD_INSTALL_HEALTH`
- `T_HELP_CMD_INSTALL_SUPPLY`
- `T_HELP_CMD_INSTALL_LKG`
- `T_HELP_CMD_INSTALL_IPV6`
- `T_HELP_CMD_INSTALL_LOCATION`
- `T_HELP_CMD_INSTALL_NFT_DEBUG`

### Pliki zaktualizowane:
- `lib/i18n/help/en.sh`
- `lib/i18n/help/pl.sh`
- `lib/i18n/help/de.sh`
- `lib/i18n/help/es.sh`
- `lib/i18n/help/fr.sh`
- `lib/i18n/help/it.sh`
- `lib/i18n/help/ru.sh`

---

## 6. Core (`lib/cytadela-core.sh`)

### Zmiany:
- Dodano zmienną `MAG` (magenta) - `\e[38;5;201m`
- Zmieniono `log_section()` - teraz wywołuje `draw_section_header()`
- Dodano ładowanie `lib/frame-ui.sh` na starcie

### Kolory:
- `EMR` - Emerald (zielony)
- `VIO` - Violet (fioletowy)
- `MAG` - Magenta (purpurowy) **NOWY**
- `RED` - Crimson (czerwony)
- `BOLD` - Pogrubienie

---

## 7. Lista commitów

```
5043 - feat: add purple frames to all section headers in install-wizard
27465ba - feat: convert all remaining log_section to purple frames
?? - fix: add missing closing brace in uninstall.sh
?? - fix: use exact print_menu_line pattern for frame drawing
?? - refactor: move frame UI to lib/frame-ui.sh, fix frame colors
?? - fix: handle whiptail cancel gracefully
?? - fix: use echo -e to properly interpret color escape sequences
?? - fix: handle emoji width in frame drawing
?? - refactor: use print_frame_line from lib in help menu
?? - style: change [q] color from red to magenta
?? - fix: show_help_full uses i18n and shows all commands
?? - i18n: add T_HELP_SECTION_ALL to all language files
?? - fix: simplify emoji detection in draw_section_header
?? - feat: add missing install commands to help (health, supply-chain, lkg, ipv6, location, nft-debug)
```

---

## 8. Testowanie

### Komendy do przetestowania:
```bash
# Test help
sudo ./citadel.sh help

# Test install-wizard (już zainstalowane - pokaże menu)
sudo ./citadel.sh install-wizard

# Test uninstall (tylko wyświetli info, nie usunie)
sudo ./citadel.sh uninstall

# Test modułów
sudo ./citadel.sh health-status
sudo ./citadel.sh supply-status
sudo ./citadel.sh nft-debug-status
```

---

## 9. Status

✅ **Zakończone:**
- Wszystkie ramki ujednolicone (fioletowe dla sekcji, czerwone dla emergency)
- Wszystkie moduły instalacyjne używają szablonu
- Help rozszerzony o wszystkie komendy
- i18n zaktualizowane dla wszystkich języków
- Poprawione błędy składni (apostrofy, brakujące nawiasy)

✅ **Gotowe do użytku**
