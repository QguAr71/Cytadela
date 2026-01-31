# Issue #27 - Full Auto-update

**Wersja:** v3.3  
**Priorytet:** Średni  
**Effort:** ~8-12h  
**Status:** Planned (Q2 2026)

---

## 📋 Opis

Pełna automatyczna aktualizacja wszystkich komponentów Citadel - blocklists, resolvers, CoreDNS, skrypty, z automatycznym backupem i rollbackiem.

---

## 🎯 Cele

1. Auto-update wszystkiego (nie tylko blocklist)
2. Automatyczny backup przed każdą aktualizacją
3. Auto-rollback przy błędzie
4. Powiadomienia o aktualizacjach
5. Bezpieczne aktualizacje bez przerywania usługi

---

## 🔧 Funkcjonalność

### Włączenie full auto-update

```bash
# Włącz pełną auto-aktualizację
sudo citadel.sh full-update-enable

# Konfiguracja
sudo citadel.sh full-update-configure
# - Częstotliwość: daily/weekly
# - Godzina: 03:00 (domyślnie)
# - Co aktualizować: blocklists/resolvers/coredns/scripts/all
# - Powiadomienia: yes/no
```

### Status i kontrola

```bash
# Status auto-update
sudo citadel.sh full-update-status

# Historia aktualizacji
sudo citadel.sh full-update-history

# Rollback do poprzedniej wersji
sudo citadel.sh full-update-rollback

# Rollback do konkretnej wersji
sudo citadel.sh full-update-rollback --version 2026-02-15-03:00
```

### Ręczna aktualizacja

```bash
# Aktualizuj wszystko teraz
sudo citadel.sh full-update-now

# Aktualizuj tylko wybrane komponenty
sudo citadel.sh full-update-now --components blocklists,resolvers
```

---

## 🏗️ Implementacja

### Nowy moduł: `modules/full-auto-update.sh`

**Funkcje:**
- `full_update_enable()` - włącz auto-update
- `full_update_disable()` - wyłącz auto-update
- `full_update_configure()` - konfiguracja
- `full_update_status()` - status
- `full_update_now()` - aktualizuj teraz
- `full_update_history()` - historia
- `full_update_rollback()` - rollback

### Komponenty do aktualizacji

**1. Blocklists**
- Hagezi Pro, OISD, StevenBlack, etc.
- Sprawdzenie sum kontrolnych
- LKG fallback

**2. DNS Resolvers**
- DNSCrypt-Proxy server list
- DoH/DoT endpoints
- Weryfikacja dostępności

**3. CoreDNS**
- Nowa wersja binariów (jeśli dostępna)
- Sprawdzenie kompatybilności
- Backup starej wersji

**4. Citadel Scripts**
- Git pull z repozytorium
- Integrity check (SHA256)
- Backup przed aktualizacją

### Systemd Timer

```bash
# /etc/systemd/system/citadel-full-update.timer
[Unit]
Description=Citadel Full Auto-update Timer
Requires=citadel-full-update.service

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=1800

[Install]
WantedBy=timers.target
```

```bash
# /etc/systemd/system/citadel-full-update.service
[Unit]
Description=Citadel Full Auto-update
After=network-online.target

[Service]
Type=oneshot
ExecStartPre=/usr/local/bin/citadel.sh full-backup --auto
ExecStart=/usr/local/bin/citadel.sh full-update-now --auto
ExecStartPost=/usr/local/bin/citadel.sh full-update-verify
User=root
```

---

## 🔄 Proces aktualizacji

### 1. Pre-update checks
```bash
# Sprawdź połączenie internetowe
# Sprawdź dostępność repozytoriów
# Sprawdź miejsce na dysku (min 500 MB)
# Sprawdź czy usługi działają
```

### 2. Backup
```bash
# Automatyczny backup przed aktualizacją
/var/lib/citadel/backups/pre-update-YYYYMMDD-HHMMSS.tar.gz
```

### 3. Update components
```bash
# Aktualizuj po kolei:
# 1. Blocklists (najłatwiejsze do rollback)
# 2. Resolvers (zmiana konfiguracji)
# 3. CoreDNS (restart usługi)
# 4. Scripts (może wymagać restartu)
```

### 4. Verification
```bash
# Sprawdź czy wszystko działa:
# - DNS resolution test
# - Service status check
# - Connectivity test
# - Blocklist integrity
```

### 5. Post-update
```bash
# Jeśli OK:
# - Usuń stare backupy (keep last 5)
# - Wyślij powiadomienie (success)
# - Log do /var/log/citadel/full-update.log

# Jeśli BŁĄD:
# - Auto-rollback do backupu
# - Wyślij powiadomienie (failure)
# - Log błędu
```

---

## 📊 Baza danych aktualizacji

```bash
# /var/lib/citadel/updates/history.json
{
  "updates": [
    {
      "timestamp": "2026-02-15T03:00:00Z",
      "version": "3.3.0",
      "components": ["blocklists", "resolvers", "coredns"],
      "status": "success",
      "duration": "2m 34s",
      "backup": "/var/lib/citadel/backups/pre-update-20260215-030000.tar.gz"
    },
    {
      "timestamp": "2026-02-14T03:00:00Z",
      "version": "3.3.0",
      "components": ["blocklists"],
      "status": "failed",
      "error": "Network timeout",
      "rollback": true
    }
  ]
}
```

---

## 🔐 Bezpieczeństwo

### Supply Chain Protection
- Weryfikacja sum kontrolnych (SHA256)
- GPG signatures dla skryptów
- Integrity check przed i po aktualizacji

### Safe Updates
- Backup przed każdą aktualizacją
- Weryfikacja po aktualizacji
- Auto-rollback przy błędzie
- Nie przerywaj usługi (rolling updates)

### Notifications
- Email (opcjonalnie)
- Desktop notifications
- Log do systemd journal

---

## 🧪 Testowanie

```bash
# Test aktualizacji (dry-run)
sudo citadel.sh full-update-test

# Symulacja błędu
sudo citadel.sh full-update-test --simulate-failure

# Weryfikacja rollback
sudo citadel.sh full-update-test --test-rollback
```

---

## 📝 Konfiguracja

```bash
# /etc/citadel/full-update.conf
FULL_UPDATE_ENABLED=true
FULL_UPDATE_SCHEDULE="daily"
FULL_UPDATE_TIME="03:00"
FULL_UPDATE_COMPONENTS="all"  # or: blocklists,resolvers,coredns,scripts
FULL_UPDATE_NOTIFICATIONS=true
FULL_UPDATE_AUTO_ROLLBACK=true
FULL_UPDATE_KEEP_BACKUPS=5
```

---

## 📚 Dokumentacja

- User guide: `docs/user/full-auto-update.md`
- Configuration: `docs/user/configuration.md` (nowa sekcja)
- Troubleshooting: `docs/user/troubleshooting.md` (nowa sekcja)

---

## 🎯 Milestone

**v3.3 (Q2 2026)**
- [ ] Moduł full-auto-update.sh
- [ ] Systemd timer/service
- [ ] Backup przed aktualizacją
- [ ] Weryfikacja po aktualizacji
- [ ] Auto-rollback przy błędzie
- [ ] Historia aktualizacji
- [ ] Powiadomienia
- [ ] Supply chain protection
- [ ] Dokumentacja
- [ ] Testy

---

**Effort:** ~8-12h  
**Zależności:** 
- Issue #14 (Backup/Restore) - już zaimplementowane
- Issue #13 (Auto-update blocklist) - już zaimplementowane
