# 📋 Referencja Poleceń

Kompletna lista wszystkich poleceń Citadel.

---

## ❓ Interaktywny System Pomocy

Citadel++ zawiera teraz interaktywny system pomocy dostępny poprzez:

```bash
sudo cytadela.sh help
```

Otwiera to menu z 5 sekcjami:
1. **Instalacja** - Wszystkie polecenia instalacyjne
2. **Główny Program** - Rdzeniowa funkcjonalność
3. **Dodatki** - Adblock, blocklist, powiadomienia
4. **Zaawansowane** - LKG, auto-aktualizacje, cache, zdrowie
5. **Awaryjne i Odzyskiwanie** - Panic, kill-switch, debug

Każda sekcja wyświetla odpowiednie polecenia z opisami w Twoim języku.

---

## 🚀 Polecenia Instalacyjne

| Polecenie | Opis |
|-----------|------|
| `install-wizard` | Interaktywny kreator instalacji (zalecane) |
| `install-all` | Zainstaluj wszystkie komponenty |
| `install-dnscrypt` | Zainstaluj tylko DNSCrypt-Proxy |
| `install-coredns` | Zainstaluj tylko CoreDNS |
| `install-nftables` | Zainstaluj tylko firewall NFTables |
| `install-dashboard` | Zainstaluj dashboard terminala |
| `install-editor` | Zainstaluj integrację edytora |
| `install-doh-parallel` | Zainstaluj równoległe racing DoH |
| `check-deps` | Sprawdź zależności |
| `check-dependencies` | Sprawdź zależności (alias) |
| `check-deps --install` | Zainstaluj brakujące zależności (z fallback AUR dla Arch) |
| `verify-config` | Zweryfikuj konfigurację, usługi i DNS |
| `verify-config dns` | Testuj tylko rozwiązywanie DNS |
| `verify-config services` | Pokaż tylko status usług |
| `verify-config files` | Pokaż tylko pliki konfiguracyjne |
| `verify-config all` | Uruchom wszystkie sprawdzenia weryfikacyjne |

---

## ⚙️ Polecenia Konfiguracyjne

| Polecenie | Opis |
|-----------|------|
| `configure-system` | Przełącz system na DNS Citadel |
| `restore-system` | Przywróć oryginalną konfigurację DNS (z backupu) |
| `restore-system-default` | Przywróć fabryczną konfigurację DNS (bezpieczny fallback) |
| `firewall-safe` | Włącz bezpieczny tryb firewall |
| `firewall-strict` | Włącz ścisły tryb firewall |
| `fix-ports` | Rozwiąż konflikty portów |
| `optimize-kernel` | Zoptymalizuj priorytet kernela dla DNS |

---

## 📊 Polecenia Monitorowania

| Polecenie | Opis |
|-----------|------|
| `status` | Pokaż status usług |
| `verify` | Zweryfikuj pełny stos |
| `diagnostics` | Uruchom pełną diagnostykę |
| `health-status` | Sprawdzenie zdrowia |
| `health-install` | Zainstaluj watchdog zdrowia |
| `health-uninstall` | Odinstaluj watchdog zdrowia |
| `discover` | Snapshot sieci i firewall |
| `cache-stats` | Statystyki cache DNS |
| `cache-stats-top [N]` | Top N najczęściej zapytanych domen |
| `cache-stats-reset` | Resetuj statystyki |
| `cache-stats-watch` | Śledź statystyki na żywo |
| `logs` | Pokaż ostatnie logi |

---

## 🚫 Polecenia Adblock

| Polecenie | Opis |
|-----------|------|
| `adblock-status` | Pokaż status adblock |
| `adblock-stats` | Pokaż statystyki |
| `adblock-add <domena>` | Zablokuj własną domenę |
| `adblock-remove <domena>` | Odblokuj domenę |
| `adblock-query <domena>` | Zapytanie domeny |
| `adblock-show <typ>` | Pokaż blocklist (custom/blocklist/combined) |
| `adblock-rebuild` | Przebuduj blocklist |
| `blocklist-list` | Lista dostępnych profili blocklist |
| `blocklist-switch <profil>` | Przełącz profil blocklist |
| `blocklist-status` | Pokaż status blocklist |
| `blocklist-add-url <url>` | Dodaj własny URL blocklist |
| `blocklist-remove-url <url>` | Usuń URL blocklist |
| `blocklist-show-urls` | Pokaż skonfigurowane URL blocklist |
| `allowlist-list` | Pokaż domeny na allowlist |
| `allowlist-add <domena>` | Dodaj domenę do allowlist |
| `allowlist-remove <domena>` | Usuń domenę z allowlist |

---

## 🔐 Polecenia Bezpieczeństwa

| Polecenie | Opis |
|-----------|------|
| `supply-chain-status` | Pokaż status supply chain |
| `supply-chain-init` | Inicjalizuj checksumy |
| `supply-chain-verify` | Zweryfikuj integralność |
| `integrity-status` | Pokaż status integralności |
| `integrity-init` | Inicjalizuj manifest integralności |
| `integrity-check` | Zweryfikuj integralność |
| `ghost-check` | Audyt otwartych portów |

---

## 🚨 Polecenia Awaryjne

| Polecenie | Opis |
|-----------|------|
| `panic-bypass [sekundy]` | Tryb odzyskiwania awaryjnego |
| `panic-restore` | Przywróć z trybu panic |
| `panic-status` | Pokaż status trybu panic |
| `emergency-refuse` | Odrzuć wszystkie zapytania DNS |
| `emergency-restore` | Przywróć normalną operację |
| `killswitch-on` | Aktywuj killswitch DNS |
| `killswitch-off` | Dezaktywuj killswitch |

---

## 🌍 Polecenia IPv6

| Polecenie | Opis |
|-----------|------|
| `ipv6-privacy-on` | Włącz prywatność IPv6 |
| `ipv6-privacy-off` | Wyłącz prywatność IPv6 |
| `ipv6-privacy-status` | Pokaż status prywatności |
| `ipv6-privacy-auto` | Auto-ensure prywatności |
| `ipv6-deep-reset` | Głęboki reset IPv6 |
| `smart-ipv6` | Inteligentne wykrywanie IPv6 |

---

## 📍 Polecenia Lokalizacji

| Polecenie | Opis |
|-----------|------|
| `location-status` | Pokaż status lokalizacji |
| `location-check` | Sprawdź i doradź |
| `location-add-trusted [ssid]` | Dodaj zaufane SSID |
| `location-remove-trusted <ssid>` | Usuń zaufane SSID |
| `location-list-trusted` | Lista zaufanych SSID |

---

## 🔄 Polecenia Auto-Aktualizacji

| Polecenie | Opis |
|-----------|------|
| `auto-update-enable` | Włącz auto-aktualizacje |
| `auto-update-disable` | Wyłącz auto-aktualizacje |
| `auto-update-status` | Pokaż status |
| `auto-update-now` | Aktualizuj teraz |
| `auto-update-configure` | Skonfiguruj ustawienia |

---

## 💾 Polecenia Backup

| Polecenie | Opis |
|-----------|------|
| `config-backup` | Backup konfiguracji |
| `config-restore [plik]` | Przywróć konfigurację z backupu |
| `config-list` | Lista backupów |
| `config-delete <plik>` | Usuń backup |
| `lkg-save` | Zapisz last-known-good |
| `lkg-restore` | Przywróć last-known-good |
| `lkg-status` | Pokaż status LKG |

---

## �️ Polecenia Deinstalacji

| Polecenie | Opis |
|-----------|------|
| `uninstall` | Kompletne usunięcie (config + dane) |
| `uninstall-keep-config` | Zatrzymaj usługi, zachowaj config |

---

## �🔧 Polecenia Debug

| Polecenie | Opis |
|-----------|------|
| `nft-debug-on` | Włącz debug NFTables |
| `nft-debug-off` | Wyłącz debug NFTables |
| `nft-debug-status` | Pokaż status debug |
| `nft-debug-logs` | Pokaż logi debug |

---

## 🔍 Polecenia Testowania

| Polecenie | Opis |
|-----------|------|
| `test` | Podstawowy test DNS |
| `test-all` | Kompleksowe testy |
| `safe-test` | Tryb bezpiecznego testowania |
| `benchmark` | Benchmark wydajności DNS |

---

## 📝 Polecenia Edycji

| Polecenie | Opis |
|-----------|------|
| `edit` | Edytuj konfigurację CoreDNS |
| `edit-dnscrypt` | Edytuj konfigurację DNSCrypt |

---

## 🔔 Polecenia Powiadomień

| Polecenie | Opis |
|-----------|------|
| `notify-enable` | Włącz powiadomienia |
| `notify-disable` | Wyłącz powiadomienia |
| `notify-status` | Pokaż status |
| `notify-test` | Testuj powiadomienia |

---

## ℹ️ Polecenia Pomocy

| Polecenie | Opis |
|-----------|------|
| `help` | Pokaż pomoc |
| `--help` | Pokaż pomoc |
| `-h` | Pokaż pomoc |

---

## 📚 Przykłady

### Podstawowy Workflow
```bash
# 1. Zainstaluj
sudo ./citadel.sh install-wizard

# 2. Skonfiguruj
sudo ./citadel.sh configure-system
sudo ./citadel.sh firewall-strict

# 3. Zweryfikuj
sudo ./citadel.sh verify

# 4. Monitoruj
sudo ./citadel.sh status
```

### Zarządzanie Adblock
```bash
# Sprawdź status
sudo ./citadel.sh adblock-status

# Zablokuj własną domenę
sudo ./citadel.sh adblock-add ads.example.com

# Przełącz na agresywny profil
sudo ./citadel.sh blocklist-switch aggressive
```

### Odzyskiwanie Awaryjne
```bash
# Jeśli DNS przestanie działać
sudo ./citadel.sh panic-bypass 300

# Przywróć po naprawie
sudo ./citadel.sh panic-restore
```

---

**Aby uzyskać szczegółowe użycie, zobacz [Przewodnik Konfiguracji](configuration.md).**
