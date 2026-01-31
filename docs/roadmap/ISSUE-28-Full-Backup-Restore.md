# Issue #28 - Full Backup/Restore

**Wersja:** v3.3  
**Priorytet:** Średni  
**Effort:** ~6-10h  
**Status:** Planned (Q2 2026)

---

## 📋 Opis

Pełny system backup/restore dla Citadel - jedna komenda do pełnego backupu wszystkiego (config + blocklists + state), łatwa migracja na nowy komputer, opcjonalny cloud backup.

---

## 🎯 Cele

1. Pełny backup jedną komendą (wszystko)
2. Łatwa migracja na nowy komputer
3. Cloud backup (opcjonalnie - Nextcloud, rsync)
4. Scheduled backups (daily/weekly)
5. Szybkie przywracanie

---

## 🔧 Funkcjonalność

### Pełny backup

```bash
# Pełny backup wszystkiego
sudo citadel.sh full-backup

# Backup z opisem
sudo citadel.sh full-backup --description "Przed aktualizacją do v3.3"

# Backup do cloud
sudo citadel.sh full-backup --cloud nextcloud
```

### Przywracanie

```bash
# Lista backupów
sudo citadel.sh full-backup-list

# Przywróć z backupu
sudo citadel.sh full-restore /var/lib/citadel/full-backups/citadel-full-20260215-030000.tar.gz

# Przywróć z cloud
sudo citadel.sh full-restore --cloud nextcloud --date 2026-02-15
```

### Scheduled backups

```bash
# Włącz automatyczne backupy
sudo citadel.sh full-backup-schedule --enable --frequency weekly --time 04:00

# Status scheduled backups
sudo citadel.sh full-backup-schedule --status

# Wyłącz
sudo citadel.sh full-backup-schedule --disable
```

---

## 🏗️ Implementacja

### Rozszerzenie modułu: `modules/config-backup.sh`

**Nowe funkcje:**
- `full_backup()` - pełny backup wszystkiego
- `full_restore()` - pełne przywracanie
- `full_backup_list()` - lista pełnych backupów
- `full_backup_schedule()` - zarządzanie harmonogramem
- `full_backup_cloud_sync()` - synchronizacja z cloud

### Co jest w pełnym backupie?

**1. Konfiguracja:**
- `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`
- `/etc/coredns/Corefile`
- `/etc/coredns/zones/`
- `/etc/citadel/` (wszystkie pliki config)
- Reguły NFTables

**2. Blocklists:**
- `/etc/coredns/zones/*.hosts`
- Custom blocklists
- Allowlists

**3. State:**
- `/var/lib/citadel/` (baza danych, cache, state)
- LKG cache
- Parental control profiles (jeśli włączone)
- Auto-update history
- Integrity manifests

**4. Logi (opcjonalnie):**
- `/var/log/citadel/` (ostatnie 7 dni)

**5. Metadata:**
- Wersja Citadel
- Data backupu
- Hostname
- OS info
- Lista zainstalowanych komponentów

### Struktura backupu

```bash
citadel-full-20260215-030000.tar.gz
├── metadata.json
├── config/
│   ├── dnscrypt-proxy.toml
│   ├── Corefile
│   └── citadel/
├── zones/
│   ├── blocklist.hosts
│   ├── custom.hosts
│   └── allowlist.txt
├── state/
│   ├── lkg-cache/
│   ├── parental/
│   └── updates/
├── nftables/
│   └── citadel-rules.nft
└── logs/ (optional)
    └── citadel.log
```

### Metadata JSON

```json
{
  "version": "3.3.0",
  "backup_date": "2026-02-15T03:00:00Z",
  "hostname": "citadel-gateway",
  "os": "Arch Linux",
  "components": [
    "dnscrypt-proxy",
    "coredns",
    "nftables",
    "parental-control",
    "auto-update"
  ],
  "description": "Przed aktualizacją do v3.3",
  "size": "45.2 MB",
  "checksum": "sha256:abc123..."
}
```

---

## ☁️ Cloud Backup

### Nextcloud

```bash
# Konfiguracja Nextcloud
sudo citadel.sh full-backup-cloud-configure nextcloud
# - URL: https://cloud.example.com
# - Username: citadel-backup
# - Password: ********
# - Path: /Backups/Citadel/

# Synchronizacja
sudo citadel.sh full-backup --cloud nextcloud
```

### Rsync

```bash
# Konfiguracja rsync
sudo citadel.sh full-backup-cloud-configure rsync
# - Host: backup.example.com
# - User: backup
# - Path: /backups/citadel/
# - SSH Key: /root/.ssh/citadel-backup

# Synchronizacja
sudo citadel.sh full-backup --cloud rsync
```

### S3-compatible (opcjonalnie)

```bash
# Konfiguracja S3
sudo citadel.sh full-backup-cloud-configure s3
# - Endpoint: s3.example.com
# - Bucket: citadel-backups
# - Access Key: ********
# - Secret Key: ********

# Synchronizacja
sudo citadel.sh full-backup --cloud s3
```

---

## 🔄 Migracja na nowy komputer

### Eksport z starego komputera

```bash
# Na starym komputerze
sudo citadel.sh full-backup --export /tmp/citadel-migration.tar.gz

# Skopiuj plik na nowy komputer
scp /tmp/citadel-migration.tar.gz user@new-computer:/tmp/
```

### Import na nowym komputerze

```bash
# Na nowym komputerze
# 1. Zainstaluj Citadel
git clone https://github.com/yourusername/Citadel.git
cd Citadel
sudo ./citadel.sh install-wizard

# 2. Przywróć backup
sudo ./citadel.sh full-restore /tmp/citadel-migration.tar.gz

# 3. Weryfikacja
sudo ./citadel.sh verify
```

---

## 📅 Scheduled Backups

### Systemd Timer

```bash
# /etc/systemd/system/citadel-full-backup.timer
[Unit]
Description=Citadel Full Backup Timer
Requires=citadel-full-backup.service

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

```bash
# /etc/systemd/system/citadel-full-backup.service
[Unit]
Description=Citadel Full Backup
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel.sh full-backup --auto
ExecStartPost=/usr/local/bin/citadel.sh full-backup-cleanup --keep 10
User=root
```

### Retention Policy

```bash
# Automatyczne czyszczenie starych backupów
sudo citadel.sh full-backup-cleanup --keep 10

# Konfiguracja retention
sudo citadel.sh full-backup-configure --retention 10
```

---

## 🔐 Bezpieczeństwo

### Szyfrowanie backupów (opcjonalnie)

```bash
# Backup z szyfrowaniem
sudo citadel.sh full-backup --encrypt --password

# Przywracanie zaszyfrowanego backupu
sudo citadel.sh full-restore backup.tar.gz.gpg --decrypt
```

### Weryfikacja integralności

```bash
# Sprawdź integralność backupu
sudo citadel.sh full-backup-verify /var/lib/citadel/full-backups/citadel-full-20260215.tar.gz

# Automatyczna weryfikacja po utworzeniu
# (domyślnie włączone)
```

---

## 📊 Baza danych backupów

```bash
# /var/lib/citadel/full-backups/index.json
{
  "backups": [
    {
      "filename": "citadel-full-20260215-030000.tar.gz",
      "date": "2026-02-15T03:00:00Z",
      "size": "45.2 MB",
      "checksum": "sha256:abc123...",
      "description": "Przed aktualizacją do v3.3",
      "components": ["dnscrypt-proxy", "coredns", "nftables"],
      "cloud_synced": true,
      "encrypted": false
    }
  ]
}
```

---

## 🧪 Testowanie

```bash
# Test pełnego backupu
sudo citadel.sh full-backup-test

# Test restore (dry-run)
sudo citadel.sh full-restore --test backup.tar.gz

# Weryfikacja migracji
sudo citadel.sh full-backup-test-migration
```

---

## 📝 Konfiguracja

```bash
# /etc/citadel/full-backup.conf
FULL_BACKUP_DIR="/var/lib/citadel/full-backups"
FULL_BACKUP_RETENTION=10
FULL_BACKUP_INCLUDE_LOGS=false
FULL_BACKUP_ENCRYPT=false
FULL_BACKUP_CLOUD_ENABLED=false
FULL_BACKUP_CLOUD_PROVIDER="nextcloud"
FULL_BACKUP_SCHEDULE_ENABLED=false
FULL_BACKUP_SCHEDULE_FREQUENCY="weekly"
FULL_BACKUP_SCHEDULE_TIME="04:00"
```

---

## 📚 Dokumentacja

- User guide: `docs/user/full-backup-restore.md`
- Migration guide: `docs/user/migration.md` (nowy)
- Cloud backup setup: `docs/user/cloud-backup.md` (nowy)

---

## 🎯 Milestone

**v3.3 (Q2 2026)**
- [ ] Rozszerzenie modułu config-backup.sh
- [ ] Pełny backup (config + blocklists + state)
- [ ] Pełne przywracanie
- [ ] Scheduled backups (systemd timer)
- [ ] Cloud backup (Nextcloud, rsync, S3)
- [ ] Migracja na nowy komputer
- [ ] Szyfrowanie backupów (opcjonalnie)
- [ ] Retention policy
- [ ] Dokumentacja
- [ ] Testy

---

**Effort:** ~6-10h  
**Zależności:** 
- Issue #14 (Backup/Restore config) - już zaimplementowane (rozszerzamy)
