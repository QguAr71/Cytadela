# Changelog

All notable changes to this repository will be documented in this file.

## Unreleased

- Add fail-fast dependency checks in install modules.
- Add optional DNSSEC toggle for generated DNSCrypt config (`CITADEL_DNSSEC=1` or `--dnssec`).
- Make Arch/CachyOS-specific helper modules degrade gracefully when `pacman`/`yay` are missing.
- Lower priority tuning aggressiveness in `optimize-kernel`.

## 2026-01-23

- Make CoreDNS install resilient when DNSCrypt port changes (bootstrap CoreDNS forward to current port during downloads).
- Add DNS adblock panel (`adblock-*`) and hardened blocklist parsing + atomic updates.
- Fix CoreDNS hosts usage by combining custom + blocklist into a single `combined.hosts`.
- Fix CoreDNS hosts file permissions for `User=coredns`.
- Add `install-all` healthcheck (DNS + adblock).
- Add bilingual docs (`README.md`, notes PL/EN) and English script entrypoint (`citadela_en.sh`).
- Make nftables install idempotent (flush tables + dedupe include line).
- Update docs: recommend `verify` + leak test after updates.
