# Cytadela++ - Draft Posts for Reddit/HackerNews

## 📝 Reddit Post (r/privacy, r/selfhosted, r/archlinux)

### Title Options:

**Option 1 (Technical):**
`[Project] Cytadela++ v3.1 - Hardened Local DNS Stack with Kernel-Level Leak Prevention (DNSCrypt + CoreDNS + NFTables)`

**Option 2 (Privacy-focused):**
`I built a privacy-first DNS stack that blocks leaks at the kernel level - Cytadela++ v3.1`

**Option 3 (Problem-solution):**
`Tired of DNS leaks? I created a local DNS stack with NFTables enforcement - No cloud, no telemetry`

---

### Post Body (r/privacy):

```markdown
# Cytadela++ v3.1 - Hardened Local DNS Stack

**TL;DR:** Open-source DNS privacy stack for Linux that encrypts queries (DNSCrypt/DoH), blocks ads/trackers (318k+ domains), and prevents DNS leaks at the kernel level using NFTables. No cloud, no telemetry, local-only control.

## What is it?

Cytadela++ is a Bash-based automation tool that builds a secure DNS infrastructure on your Linux machine:

- **Layer 1:** DNSCrypt-Proxy (encrypted upstream via DNSCrypt/DoH)
- **Layer 2:** CoreDNS (local cache + DNS-based adblocking)
- **Layer 3:** NFTables (kernel-level DNS leak prevention)

## Why I built it

Most DNS privacy solutions focus on encryption but ignore leak prevention. Applications can still bypass your secure DNS resolver by directly querying external DNS servers (`:53`). Cytadela++ solves this by using NFTables to block all DNS traffic except to localhost - similar to how Qubes OS or Whonix Gateway work.

## Key Features

✅ **DNS Encryption** - DNSCrypt/DoH prevents ISP snooping
✅ **Kernel-level leak prevention** - NFTables blocks DNS bypass attempts
✅ **DNS-based adblocking** - 318k+ domains blocked (Hagezi Pro + PolishFilters)
✅ **Local cache** - CoreDNS with Prometheus metrics
✅ **Supply-chain verification** - SHA256 integrity checks
✅ **Panic recovery** - Emergency bypass and rollback
✅ **Modular architecture** - 17 modules, lazy loading
✅ **No web UI** - CLI-only, no attack surface
✅ **No cloud/telemetry** - Everything runs locally

## How it compares

| Feature | Cytadela++ | Pi-hole | AdGuard Home | Unbound | NextDNS |
|---------|------------|---------|--------------|---------|---------|
| DNS Encryption | ✅ Built-in | ❌ Optional | ✅ Built-in | ✅ DoT/DoH | ✅ DoH |
| Leak Prevention | ✅ Kernel-level | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ❌ Cloud |
| Adblock | ✅ 318k+ | ✅ Extensive | ✅ Extensive | ❌ Native | ✅ Cloud |
| Local/Cloud | ✅ Local | ✅ Local | ✅ Local | ✅ Local | ❌ Cloud |
| Web UI | ❌ CLI only | ✅ Full UI | ✅ Full UI | ❌ CLI | ✅ Web |
| Privacy Focus | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

**Common Alternatives:**
- **NextDNS:** Cloud-based, convenient but requires trusting third party
- **Unbound:** Excellent privacy, but no native adblock or leak prevention
- **Pi-hole + Unbound:** Popular combo, but leak prevention still manual

**Cytadela++ is ideal for:**
- Privacy-conscious Linux users who want local-only control
- Single-device or gateway setups
- Users who prefer CLI over web UI
- Arch/CachyOS enthusiasts
- Those who want kernel-level leak prevention without manual NFTables config

## Technical Details

**Architecture:**
```
Application → CoreDNS (127.0.0.1:53) → DNSCrypt-Proxy → Encrypted DNS
                ↓
         NFTables blocks external :53
```

**Leak Prevention:**
```bash
# STRICT mode blocks all DNS except localhost
nft add rule inet citadel_filter output udp dport 53 ip daddr != 127.0.0.0/8 drop
nft add rule inet citadel_filter output tcp dport 53 ip daddr != 127.0.0.0/8 drop
```

**Testing:**
```bash
# This should timeout in STRICT mode
nslookup google.com 8.8.8.8
# Output: ;; connection timed out; no servers could be reached
```

## Installation

```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./install-refactored.sh
sudo cytadela++ install-all
sudo cytadela++ firewall-safe
sudo cytadela++ configure-system
sudo cytadela++ verify
```

## What's New in v3.1

- ✨ Modular architecture (45% code reduction)
- 🎯 Interactive installer wizard
- 📦 Multi-blocklist support (6 profiles)
- 🔄 Auto-update with LKG fallback
- 💾 Config backup/restore
- 📊 Cache statistics (Prometheus)
- 🔔 Desktop notifications
- 🧪 Complete testing framework (CI/CD)

## Project Status

- **License:** GPLv3
- **Language:** 100% Bash
- **Platform:** Linux (Arch/CachyOS optimized)
- **CI/CD:** ShellCheck + Smoke Tests (73 tests)
- **Documentation:** Bilingual (EN/PL)

## Links

- **GitHub:** https://github.com/QguAr71/Cytadela
- **Documentation:** [English Manual](https://github.com/QguAr71/Cytadela/blob/main/CITADEL_EN_COMPLETE_MANUAL.md)
- **Contributing:** [CONTRIBUTING.md](https://github.com/QguAr71/Cytadela/blob/main/CONTRIBUTING.md)

## Disclaimer

This is a hobby project provided "as-is" without warranties. It's a security tool, not a product. Use it if it fits your threat model.

## Questions?

Happy to answer questions about the architecture, implementation, or privacy considerations!

**Discussion starter:** What's your current DNS privacy setup? Are you using encrypted DNS? How do you prevent leaks?

---

**Note:** This is my first major open-source project. Feedback and contributions are welcome!
```

---

### Post Body (r/selfhosted):

```markdown
# Self-hosted DNS Privacy Stack with Adblocking - Cytadela++ v3.1

I've been working on a local DNS stack for privacy-conscious self-hosters. It's basically Pi-hole + DNSCrypt + NFTables leak prevention, but CLI-only and optimized for single-device/gateway setups.

## What it does

- **Encrypts DNS queries** (DNSCrypt/DoH) before they leave your machine
- **Blocks ads/trackers** at DNS level (318k+ domains)
- **Prevents DNS leaks** using NFTables (kernel-level enforcement)
- **Local cache** with Prometheus metrics
- **No web UI** - pure CLI, no attack surface

## Why not Pi-hole?

Pi-hole is great for network-wide blocking, but:
- Doesn't enforce DNS encryption by default
- Requires web UI (attack surface)
- Leak prevention is manual

Cytadela++ is designed for paranoid users who want kernel-level enforcement and no web dependencies.

## Quick Start

```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./install-refactored.sh
sudo cytadela++ install-all
```

Full docs: https://github.com/QguAr71/Cytadela

## Tech Stack

- DNSCrypt-Proxy (encrypted upstream)
- CoreDNS (cache + adblock)
- NFTables (leak prevention)
- Bash (automation)

## Comparison

| Feature | Cytadela++ | Pi-hole | Unbound | NextDNS |
|---------|------------|---------|---------|---------|
| Encryption | ✅ Built-in | ⚠️ Optional | ✅ DoT/DoH | ✅ Cloud |
| Leak Prevention | ✅ Kernel | ⚠️ Manual | ⚠️ Manual | ❌ N/A |
| Adblock | ✅ 318k+ | ✅ Extensive | ❌ Native | ✅ Cloud |
| Local Control | ✅ Full | ✅ Full | ✅ Full | ❌ Cloud |

## Performance

- **Cache hit rate:** ~85-90% (Prometheus metrics)
- **Query latency:** <5ms local, <50ms upstream
- **Resource usage:** ~50MB RAM, minimal CPU
- **Homelab integration:** Pair with WireGuard for network-wide privacy

## For Self-Hosters

Works great as a DNS gateway for your homelab. Set it up on a dedicated machine/VM and point your network to it. All devices benefit from encrypted DNS + adblocking + leak prevention.

**Question:** How do you handle DNS leaks in your self-hosted setup? Manual NFTables rules or something else?
```

---

### Post Body (r/archlinux):

```markdown
# Cytadela++ - Privacy-focused DNS Stack for Arch

Fellow Arch users, I've been developing a DNS privacy tool optimized for Arch/CachyOS. It's a modular Bash stack that combines DNSCrypt, CoreDNS, and NFTables for maximum DNS privacy.

## Features

- DNSCrypt/DoH encryption
- DNS-based adblocking (318k+ domains)
- NFTables leak prevention (kernel-level)
- Modular architecture (17 modules)
- CI/CD with ShellCheck
- No systemd-resolved conflicts

## Why Arch-optimized?

- **KISS principle:** Pure Bash, no extra deps beyond pacman
- **Arch Way:** User-centric, pragmatic simplicity
- Uses native packages (dnscrypt-proxy, coredns, nftables)
- No systemd-resolved conflicts (clean integration)
- Tested on CachyOS - optimized for low DNS cache latency
- No bloat, no web UI, no telemetry
- Full control via CLI

## Installation

```bash
git clone https://github.com/QguAr71/Cytadela.git
cd Cytadela
sudo ./install-refactored.sh
```

## AUR Package?

Considering creating an AUR package if there's interest. Would need help with PKGBUILD - anyone experienced with packaging Bash tools?

**Discussion:** Interest in AUR PKGBUILD? Let's collaborate! Also curious - what's your DNS setup on Arch?

GitHub: https://github.com/QguAr71/Cytadela

Feedback welcome!
```

---

## 📰 HackerNews Post

### Title:

`Cytadela++ – Hardened Local DNS Stack with Kernel-Level Leak Prevention`

### Post Body:

```
I built a DNS privacy stack for Linux that enforces leak prevention at the kernel level, not just configuration.

Problem: Most DNS solutions (Pi-hole, AdGuard) encrypt queries but don't prevent apps from bypassing your resolver. Apps can still query 8.8.8.8:53 directly.

Solution: NFTables blocks all DNS traffic except to localhost - inspired by Qubes/Whonix gateway model, but lightweight for single-device use.

Architecture:
- DNSCrypt-Proxy: Encrypted upstream (DNSCrypt/DoH/DoT, supports racing)
- CoreDNS: Local cache + adblocking (318k+ domains)
- NFTables: Kernel enforcement (drops external :53)

vs Alternatives:
- Unbound/NextDNS: No native leak prevention
- Pi-hole: Requires manual NFTables config
- Oblivious DoH: Considered, but adds latency for local-first use case

Implementation: 100% Bash, modular (17 modules), 73 automated tests, SHA256 integrity checks.

Repo: https://github.com/QguAr71/Cytadela

Thoughts on NFTables vs iptables for DNS leak prevention? Open to feedback on the architecture.
```

---

## 🎯 Posting Strategy

### Timing

**Best times to post:**
- **Reddit:** Tuesday-Thursday, 8-10 AM EST or 6-8 PM EST
- **HackerNews:** Monday-Wednesday, 9-11 AM EST

### Order

1. **Start with r/privacy** (most relevant audience)
2. **Wait 24 hours**, then post to r/selfhosted
3. **Wait 24 hours**, then post to r/archlinux
4. **Wait 48 hours**, then post to HackerNews

### Engagement

**Be ready to answer:**
- Why not use Pi-hole/AdGuard?
- How does leak prevention work?
- Performance impact?
- Multi-device support?
- Security audit status?
- Comparison with VPN?

**Common concerns & responses:**
- **"Why Bash?"** → "Auditable (no compiled binaries), no runtime dependencies, easy to modify. For a security tool, transparency matters more than performance."
- **"Why no web UI?"** → "Attack surface reduction. Web UIs add complexity and potential vulnerabilities. CLI-only keeps it simple and secure."
- **"Single-device only?"** → "Works as gateway too - set it up on a VM/Pi and point your network to it. Just not optimized for web-based multi-device management like Pi-hole."
- **"Tested?"** → "73 automated tests (smoke + integration), CI/CD with ShellCheck. See tests/README.md for details."
- **"Why not just use Unbound?"** → "Unbound is great for privacy, but doesn't include adblocking or automated leak prevention. Cytadela++ combines all three."
- **"Performance vs Pi-hole?"** → "Similar cache performance (~85-90% hit rate), but adds encryption and kernel-level leak prevention. Minimal overhead (~50MB RAM)."

### Follow-up

**After posting:**
1. Monitor comments for first 2-4 hours
2. Respond quickly to questions
3. Be humble and open to feedback
4. Don't be defensive about criticism
5. Thank contributors and supporters

**Important:** 
- Cross-post only if subreddit mods approve (r/privacy is strict)
- Use tools like RedditMetis to monitor traffic
- If traction: Enable GitHub Discussions for Q&A

**If post gains traction:**
1. Update README with FAQ
2. Create GitHub Discussions
3. Consider creating demo video
4. Write blog post with technical deep-dive

---

## 📊 Success Metrics

**Good response:**
- 50+ upvotes on Reddit
- 10+ comments with questions
- 5+ GitHub stars
- 1-2 issues/PRs

**Great response:**
- 200+ upvotes
- Front page of subreddit
- 50+ GitHub stars
- Active discussions
- Media mentions

---

## ⚠️ Important Notes

**Do NOT:**
- Spam multiple subreddits at once
- Be defensive about criticism
- Ignore negative feedback
- Over-promise features
- Compare aggressively with competitors

**DO:**
- Be humble and open
- Acknowledge limitations
- Thank contributors
- Respond to questions
- Update based on feedback

---

*Draft created: 2026-01-30*  
*Project: Cytadela++ v3.1*  
*Author: QguAr71*
