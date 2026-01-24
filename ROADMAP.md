# Roadmap

This file tracks planned changes and feature ideas. It is intentionally short and outcome-oriented.

## Planned / Ideas

### IPv6

- **IPv6 Reset (deep reset)**
  - Refresh IPv6 without touching router UI.
  - Example actions: flush IPv6 neighbor cache, reconnect interface, send Router Solicitation / wait for RA.
  - Goal: recover from transient IPv6 failures when `ping -6` by IP fails.

- **IPv6 Privacy: auto-ensure**
  - Ensure temporary IPv6 addresses (`temporary`) exist after sleep/resume.
  - If missing: re-apply `use_tempaddr=2` and reconnect interface.

### DNS resiliency

- **DNS bypass / switcher (emergency)**
  - Temporarily bypass local DNS stack when apps work by IP but DNS is stuck.
  - Must be explicit and reversible (state file + restore command) and must not silently weaken leak protection.

### Operational hardening

- **Fail-fast + better debugging**
  - Global `trap ERR` with actionable error output (line/function/command) to speed up troubleshooting.

- **Panic-bypass / recovery mode**
  - One command to temporarily restore connectivity (flush nftables + temporary resolv.conf), ideally with auto-rollback timer.
  - Goal: reduce operator lock-out / SPOF risk.

- **Systemd restart/watchdog + health checks**
  - Improve restart policy and add health checks to detect DNS stack stalls.

### Supply chain / updates

- **Supply-chain protection for updates**
  - Optional verification for downloaded assets (sha256/gpg/minisign).

### nftables observability

- **Optional nft debug chain**
  - Rate-limited logging and/or counters for debugging leak blocks.

### Location-aware security (advisory)

- **Location-aware firewall advisory (SSID/profile based)**
  - Detect a "trusted" location via SSID (NetworkManager `nmcli`), with user-configured SSID list.
  - Run a port exposure audit (list listening sockets bound to `0.0.0.0` / `::`) and warn about unexpected ports.
  - If outside trusted location and firewall is in SAFE mode: prompt to switch to STRICT.
  - Optional: manage a separate nftables include (e.g. `/etc/nftables.d/citadel-location.nft`) for location-specific allowances.

### Network stack detection

- **Detect network manager (NetworkManager vs systemd-networkd)**
  - Add a small helper to detect which network stack manages interfaces.
  - Use it as a prerequisite for modules like IPv6 reset and SSID-based location logic.

### Firewall / exposure audit

- **Ghost-Check (port audit)**
  - Enumerate listening sockets and highlight ones bound to `0.0.0.0` / `::`.
  - Optional allowlist (e.g., Sunshine/Moonlight) and warnings for unexpected exposure.
  - Prefer nftables-aware checks (project uses nftables, not UFW).

## Notes

- Features should be ISP-agnostic (no Orange/FunBox assumptions).
- Prefer safe operations; network resets must warn about dropping connectivity.
