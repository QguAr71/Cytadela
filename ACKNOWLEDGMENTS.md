# 🙏 Acknowledgments

Cytadela (Citadel) is built on top of exceptional open-source projects. We are deeply grateful to the developers and communities behind these tools.

---

## 🔧 Core Components

### DNSCrypt-Proxy
**Project:** https://github.com/DNSCrypt/dnscrypt-proxy  
**License:** ISC License  
**Description:** A flexible DNS proxy with support for encrypted DNS protocols (DNSCrypt, DoH, Anonymized DNSCrypt, and ODoH).

**Maintainers:** Frank Denis (@jedisct1) and contributors  
**Why we use it:** DNSCrypt-Proxy provides the foundation for encrypted DNS queries, protecting users from DNS surveillance and manipulation.

---

### CoreDNS
**Project:** https://github.com/coredns/coredns  
**License:** Apache License 2.0  
**Description:** A fast and flexible DNS server written in Go, designed to be easily extended with plugins.

**Maintainers:** CoreDNS Authors and CNCF  
**Why we use it:** CoreDNS delivers high-performance DNS caching and forwarding with excellent plugin architecture for ad-blocking and custom zones.

---

### nftables
**Project:** https://git.netfilter.org/nftables/  
**License:** GPL-2.0  
**Description:** The successor to iptables, providing a modern packet filtering framework for Linux.

**Maintainers:** Netfilter Core Team  
**Why we use it:** nftables powers our DNS leak protection firewall, ensuring all DNS queries go through our secure stack.

---

## 📊 Monitoring & Metrics

### Prometheus
**Project:** https://github.com/prometheus/prometheus  
**License:** Apache License 2.0  
**Description:** An open-source monitoring system with a dimensional data model and powerful query language.

**Maintainers:** Prometheus Authors and CNCF  
**Why we use it:** Prometheus metrics integration enables real-time monitoring of DNS performance and system health.

---

## 🚫 Ad Blocking

### StevenBlack's Unified Hosts
**Project:** https://github.com/StevenBlack/hosts  
**License:** MIT License  
**Description:** Consolidating and extending hosts files from several well-curated sources.

**Maintainer:** Steven Black (@StevenBlack) and contributors  
**Why we use it:** Provides comprehensive, well-maintained blocklists for ad-blocking and malware protection.

### OISD Blocklist
**Project:** https://oisd.nl/  
**License:** CC0 1.0 Universal  
**Description:** Internet's #1 domain blocklist - blocks ads, tracking, phishing, malware, and more.

**Maintainer:** sjhgvr  
**Why we use it:** High-quality, actively maintained blocklist with excellent coverage and low false-positive rate.

---

## 🛠️ Development Tools

### Bash
**Project:** https://www.gnu.org/software/bash/  
**License:** GPL-3.0  
**Description:** The GNU Bourne Again SHell - a Unix shell and command language.

**Maintainers:** GNU Project  
**Why we use it:** Bash provides the scripting foundation for Cytadela's modular architecture.

### whiptail (newt)
**Project:** https://pagure.io/newt  
**License:** LGPL-2.0  
**Description:** A programming library for color text mode, widget-based user interfaces.

**Maintainers:** Red Hat and contributors  
**Why we use it:** Powers our interactive installation wizard with a user-friendly TUI interface.

---

## 🐧 Linux Distribution

### CachyOS
**Project:** https://cachyos.org/  
**License:** Various (Arch Linux based)  
**Description:** A Linux distribution based on Arch Linux, focused on performance and ease of use.

**Team:** CachyOS Team  
**Why we acknowledge:** Cytadela was developed and optimized for CachyOS, and the CachyOS community has been incredibly supportive.

### Arch Linux
**Project:** https://archlinux.org/  
**License:** Various  
**Description:** A lightweight and flexible Linux distribution that tries to Keep It Simple.

**Community:** Arch Linux Developers and Community  
**Why we acknowledge:** The foundation upon which CachyOS and Cytadela are built.

---

## 🌍 Community & Inspiration

### Pi-hole
**Project:** https://github.com/pi-hole/pi-hole  
**License:** EUPL-1.2  
**Description:** A network-wide ad blocker that acts as a DNS sinkhole.

**Why we acknowledge:** Pi-hole pioneered the concept of network-level ad-blocking and inspired many aspects of Cytadela's design.

### AdGuard Home
**Project:** https://github.com/AdguardTeam/AdGuardHome  
**License:** GPL-3.0  
**Description:** Network-wide ads & trackers blocking DNS server.

**Why we acknowledge:** AdGuard Home's approach to DNS filtering and user experience influenced our feature set.

---

## 📚 Documentation & Standards

### RFC Authors
We acknowledge the authors of the following RFCs that define the standards we implement:
- **RFC 7858** - DNS over TLS (DoT)
- **RFC 8484** - DNS Queries over HTTPS (DoH)
- **RFC 4033-4035** - DNSSEC specifications
- **RFC 1035** - Domain Names - Implementation and Specification

---

## 🤝 Special Thanks

- **GitHub** - For providing free hosting and collaboration tools for open-source projects
- **All contributors** - Everyone who has reported issues, suggested features, or contributed code
- **Early adopters** - Users who tested Cytadela and provided valuable feedback
- **Open Source Community** - For creating and maintaining the ecosystem that makes projects like this possible

---

## 📜 License Compliance

Cytadela respects all licenses of the software it uses and integrates. We ensure:
- All GPL/LGPL components remain separate and their source code is accessible
- All Apache/MIT licensed components are properly attributed
- All license files are preserved in their respective packages
- No proprietary code is mixed with GPL-licensed components

For detailed license information of each component, please refer to their respective repositories.

---

## 💝 How to Support These Projects

If Cytadela has been useful to you, please consider supporting the upstream projects:
- ⭐ Star their repositories on GitHub
- 💰 Donate to their projects (if they accept donations)
- 🐛 Report bugs and contribute fixes
- 📖 Improve their documentation
- 🗣️ Spread the word about their excellent work

---

**Last Updated:** 2026-02-01  
**Cytadela Version:** v3.1.0

---

*"If I have seen further, it is by standing on the shoulders of giants."* - Isaac Newton

This project would not exist without the incredible work of the open-source community. Thank you all! 🙏
