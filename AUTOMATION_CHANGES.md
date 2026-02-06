# Cytadela++ Automation Changes - Advanced Install Module

Date: 2026-02-06
File: modules/advanced-install.sh

## Changes Made

### 1. install_doh_parallel() - Automated Activation

**Before:**
- Only created config file
- Required manual activation: `sudo cp ... && restart`

**After:**
- Creates config file
- Automatic backup with timestamp: `dnscrypt-proxy.toml.backup.YYYYMMDDhhmmss`
- Auto-activation by copying to main config
- Config validation: `dnscrypt-proxy -config ... -check`
- Service restart
- DNS test: `dig @127.0.0.1:5353`
- Auto-rollback if test fails

### 2. optimize_kernel_priority() - Multi-Distro Support

**Before:**
- Only Arch/CachyOS support (checked `/etc/arch-release`)
- Simple script without error handling
- No verification if DNS processes exist

**After:**
- Multi-distro detection:
  - `/etc/arch-release` → Arch
  - `/etc/debian_version` → Debian/Ubuntu
  - `/etc/fedora-release` → Fedora/RHEL
  - Unknown → generic commands
- Systemd availability check
- DNS installation verification
- Universal script with `set_priority()` function
- PID verification before renice (kill -0)
- Immediate application if services running
- Displays current priorities: `ps -eo pid,comm,nice,pri`
- Improved timer: `OnBootSec=30` + `OnUnitActiveSec=60s`

## Universal Priority Script

Location: `/usr/local/bin/citadel-dns-priority.sh`

Functions:
- `set_priority(pid, name)` - safe priority setting
- Checks if process exists before renice
- Logs to system logger
- Handles multiple DNSCrypt/CoreDNS instances

## Systemd Units Created

### Service: `/etc/systemd/system/citadel-dns-priority.service`
```ini
[Unit]
After=network.target dnscrypt-proxy.service coredns.service
Wants=dnscrypt-proxy.service coredns.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/citadel-dns-priority.sh
```

### Timer: `/etc/systemd/system/citadel-dns-priority.timer`
```ini
[Timer]
OnBootSec=30
OnUnitActiveSec=60s
AccuracySec=1s
Persistent=true
```

Runs:
- 30 seconds after boot
- Every 60 seconds thereafter

## Usage

```bash
# Automated DoH with parallel racing
sudo ./citadel.sh install-doh-parallel

# Automated kernel priority optimization
sudo ./citadel.sh optimize-kernel
```

## Testing

Syntax check passed:
```bash
bash -n modules/advanced-install.sh
# Result: OK
```

## Status

- ✅ install-doh-parallel: Fully automated with backup/restore
- ✅ optimize-kernel: Multi-distro, universal script
- ✅ install-editor: Unchanged (already automated)
