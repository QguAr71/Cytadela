# 🦀 Citadel 4.0 - Rust Rewrite Roadmap

## 🎯 Vision

Przepisanie Citadel w Rust z modelem Open Core:
- **Community Edition** (GPL v3) - podstawowe funkcje, open source
- **Enterprise Edition** (Paid) - zaawansowane funkcje dla firm
- **Cloud Edition** (SaaS) - w pełni zarządzana usługa

---

## 📊 Business Model

### Community Edition (Free, GPL v3)
- Core DNS stack (DNSCrypt + CoreDNS integration)
- CLI interface
- Basic adblock (blocklist management)
- Single machine deployment
- Community support (GitHub Issues)

### Enterprise Edition ($99/year per server)
- ✅ Wszystko z Community +
- 🎨 Web Dashboard (Tauri/Leptos)
- 📊 Advanced analytics & metrics
- 🌐 Multi-device management
- 🔐 RBAC (Role-Based Access Control)
- 📧 Email notifications
- 🎯 Priority support (email/chat)
- 📝 SLA 99.9%

### Cloud Edition ($9-99/month)
- ✅ Wszystko z Enterprise +
- ☁️ Fully managed hosting
- 🔄 Auto-updates
- 💾 Automated backups
- 📈 Scalability
- 🌍 Global CDN
- 🛡️ DDoS protection

---

## 🏗️ Technical Architecture

### Core Components (Rust)

```
cytadela-core/
├── src/
│   ├── main.rs              # CLI entry point
│   ├── lib.rs               # Library exports
│   ├── dns/
│   │   ├── dnscrypt.rs      # DNSCrypt client
│   │   ├── coredns.rs       # CoreDNS integration
│   │   └── resolver.rs      # DNS resolver logic
│   ├── firewall/
│   │   ├── nftables.rs      # NFTables bindings
│   │   └── rules.rs         # Firewall rules engine
│   ├── adblock/
│   │   ├── blocklist.rs     # Blocklist management
│   │   ├── parser.rs        # Hosts file parser
│   │   └── cache.rs         # LKG cache
│   ├── config/
│   │   ├── loader.rs        # Config file loader
│   │   └── validator.rs     # Config validation
│   ├── metrics/
│   │   ├── prometheus.rs    # Prometheus exporter
│   │   └── collector.rs     # Metrics collector
│   ├── api/                 # REST API (Enterprise)
│   │   ├── server.rs        # Axum/Actix server
│   │   ├── routes.rs        # API routes
│   │   └── auth.rs          # Authentication
│   └── ui/                  # Web UI (Enterprise)
│       └── tauri/           # Tauri app
├── Cargo.toml
└── README.md
```

### Key Dependencies

```toml
[dependencies]
# Core
tokio = { version = "1.35", features = ["full"] }
anyhow = "1.0"
thiserror = "1.0"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"

# DNS
trust-dns-resolver = "0.23"
hickory-dns = "0.24"

# Firewall
nftnl = "0.6"
netlink-packet-core = "0.7"

# HTTP/API (Enterprise)
axum = "0.7"
tower = "0.4"
tower-http = "0.5"

# Database (Enterprise)
sqlx = { version = "0.7", features = ["sqlite", "runtime-tokio"] }

# Metrics
prometheus = "0.13"

# UI (Enterprise)
tauri = "1.5"
leptos = "0.6"

# CLI
clap = { version = "4.4", features = ["derive"] }
```

---

## 📅 Timeline & Milestones

### Phase 1: Foundation (Months 1-3)
**Goal:** Working CLI with core DNS functionality

**Milestones:**
- ✅ Project setup (Cargo workspace)
- ✅ CLI argument parsing (clap)
- ✅ Config file loader (TOML/YAML)
- ✅ DNSCrypt client integration
- ✅ Basic DNS resolver
- ✅ Unit tests (>80% coverage)

**Deliverable:** `cytadela-cli` binary that can:
- Start/stop DNS services
- Query DNS
- Basic configuration

**Time:** 60-80 hours (AI-assisted)
**Cost:** $150-250

---

### Phase 2: Core Features (Months 4-6)
**Goal:** Feature parity with Bash version

**Milestones:**
- ✅ NFTables integration
- ✅ Adblock system (blocklist management)
- ✅ LKG cache
- ✅ Health checks & auto-restart
- ✅ Logging & diagnostics
- ✅ Integration tests

**Deliverable:** `cytadela++ 4.0 Community Edition`
- Full DNS stack
- Firewall protection
- Adblock
- CLI interface

**Time:** 100-120 hours
**Cost:** $300-500

---

### Phase 3: Enterprise Features (Months 7-9)
**Goal:** Monetizable Enterprise Edition

**Milestones:**
- ✅ REST API (Axum)
- ✅ SQLite database (config, logs, metrics)
- ✅ Prometheus metrics exporter
- ✅ Web Dashboard (Tauri + Leptos)
- ✅ Multi-device management
- ✅ RBAC & authentication
- ✅ Email notifications

**Deliverable:** `cytadela++ 4.0 Enterprise Edition`
- Web UI
- API
- Advanced features
- Ready for sales

**Time:** 150-200 hours
**Cost:** $500-1000
**Revenue:** First customers ($500-2000/month)

---

### Phase 4: Cloud Platform (Months 10-12)
**Goal:** SaaS offering

**Milestones:**
- ✅ Multi-tenancy
- ✅ Cloud deployment (Docker/K8s)
- ✅ Auto-scaling
- ✅ Payment integration (Stripe)
- ✅ Customer portal
- ✅ Monitoring & alerting

**Deliverable:** `Citadel Cloud`
- SaaS platform
- Subscription billing
- Managed service

**Time:** 200-250 hours
**Cost:** $1000-3000/month (infra)
**Revenue:** $5000-20000/month (target)

---

## 🎨 Feature Comparison

| Feature | Community | Enterprise | Cloud |
|---------|-----------|------------|-------|
| **Core DNS** | ✅ | ✅ | ✅ |
| DNSCrypt/DoH | ✅ | ✅ | ✅ |
| Adblock | ✅ | ✅ | ✅ |
| Firewall (NFTables) | ✅ | ✅ | ✅ |
| CLI Interface | ✅ | ✅ | ✅ |
| **Advanced** | | | |
| Web Dashboard | ❌ | ✅ | ✅ |
| REST API | ❌ | ✅ | ✅ |
| Multi-device | ❌ | ✅ | ✅ |
| Analytics | Basic | Advanced | Advanced |
| RBAC | ❌ | ✅ | ✅ |
| **Support** | | | |
| Community (GitHub) | ✅ | ✅ | ✅ |
| Email Support | ❌ | ✅ | ✅ |
| Priority Support | ❌ | ✅ | ✅ |
| SLA | ❌ | 99.9% | 99.99% |
| **Deployment** | | | |
| Self-hosted | ✅ | ✅ | ❌ |
| Cloud-hosted | ❌ | ❌ | ✅ |
| Auto-updates | Manual | Manual | ✅ |
| Backups | Manual | Manual | ✅ |
| **Pricing** | | | |
| Cost | Free | $99/year | $9-99/month |

---

## 💻 Development Workflow (Human + AI)

### Your Role (Human):
1. **Architecture decisions** - wybór bibliotek, struktura projektu
2. **Feature prioritization** - co robić najpierw
3. **Testing** - manualne testy, edge cases
4. **Code review** - sprawdzanie AI-generated code
5. **Domain expertise** - DNS, security, networking
6. **Business** - marketing, sales, support

### AI Role (Claude/Cascade):
1. **Code generation** - implementacja features
2. **Refactoring** - code quality improvements
3. **Documentation** - README, API docs, comments
4. **Bug fixing** - znajdowanie i naprawianie bugów
5. **Optimization** - performance tuning
6. **Testing** - unit tests, integration tests

### Workflow:
```
You: "Implement DNSCrypt client with async/await"
AI:  *generates 500 lines of Rust code*
You: *review, test, adjust*
AI:  *fixes issues, adds tests*
You: *approve, commit*
```

**Speedup:** 5-10x faster than solo coding

---

## 🚀 Go-to-Market Strategy

### Month 1-6: Build Community
- ✅ Release Community Edition (GPL)
- ✅ GitHub marketing (README, docs)
- ✅ Reddit posts (r/selfhosted, r/privacy)
- ✅ HackerNews launch
- **Goal:** 1000 GitHub stars, 500 active users

### Month 7-9: Launch Enterprise
- ✅ Release Enterprise Edition
- ✅ Landing page + pricing
- ✅ Email marketing to community
- ✅ Direct outreach to companies
- **Goal:** 10 paying customers ($1000-2000/month)

### Month 10-12: Scale SaaS
- ✅ Launch Cloud Edition
- ✅ Content marketing (blog, tutorials)
- ✅ Paid ads (Google, Reddit)
- ✅ Partnerships (VPN providers, privacy tools)
- **Goal:** 100 subscribers ($5000-10000/month)

---

## 💰 Financial Projections

### Year 1
- **Revenue:** $0-5000/month (ramp up)
- **Costs:** $50-1000/month
- **Profit:** -$5000 to +$30000
- **Focus:** Build product, get first customers

### Year 2
- **Revenue:** $5000-20000/month
- **Costs:** $1000-3000/month
- **Profit:** $50000-200000
- **Focus:** Scale customers, improve product

### Year 3
- **Revenue:** $20000-50000/month
- **Costs:** $3000-10000/month
- **Profit:** $200000-500000
- **Focus:** Enterprise sales, team expansion

---

## 🎯 Success Metrics

### Technical KPIs:
- ⚡ Performance: <5ms DNS query latency
- 🛡️ Reliability: 99.9% uptime
- 📦 Size: <10MB binary
- 🔒 Security: Zero CVEs
- 🧪 Coverage: >80% test coverage

### Business KPIs:
- 👥 Users: 1000+ (Community)
- 💼 Customers: 50+ (Enterprise)
- ☁️ Subscribers: 200+ (Cloud)
- 💰 MRR: $10000+ (Monthly Recurring Revenue)
- ⭐ GitHub Stars: 5000+

---

## 🛠️ Tools & Infrastructure

### Development:
- **IDE:** VS Code + rust-analyzer
- **AI:** Claude/Cascade for coding
- **Version Control:** Git + GitHub
- **CI/CD:** GitHub Actions
- **Testing:** cargo test, cargo clippy

### Production:
- **Hosting:** Hetzner ($20-50/month)
- **Database:** SQLite (embedded) or PostgreSQL
- **Monitoring:** Prometheus + Grafana
- **Logging:** tracing + loki
- **Payments:** Stripe
- **Email:** SendGrid

---

## 📚 Learning Resources

### Rust:
- The Rust Book (rust-lang.org)
- Rust by Example
- Tokio tutorial (async/await)
- Axum examples (web framework)

### DNS:
- RFC 1035 (DNS specification)
- DNSCrypt protocol
- CoreDNS documentation

### Business:
- Indie Hackers (community)
- "The Mom Test" (customer interviews)
- "Traction" (marketing channels)

---

## 🚨 Risks & Mitigation

### Technical Risks:
- **Risk:** Rust learning curve
  - **Mitigation:** AI-assisted coding, start small
- **Risk:** Performance issues
  - **Mitigation:** Profiling, benchmarks, optimization
- **Risk:** Platform compatibility
  - **Mitigation:** CI testing on multiple platforms

### Business Risks:
- **Risk:** No market demand
  - **Mitigation:** Validate with community first
- **Risk:** Competition (Pi-hole, AdGuard)
  - **Mitigation:** Focus on privacy + performance
- **Risk:** Support burden
  - **Mitigation:** Good docs, community support first

---

## 🎬 Next Steps

### Immediate (This Week):
1. ✅ Create GitHub repo: `cytadela-rust`
2. ✅ Setup Cargo workspace
3. ✅ Implement basic CLI (clap)
4. ✅ Write project README

### Short-term (This Month):
1. ✅ DNSCrypt client integration
2. ✅ Config file loader
3. ✅ Basic DNS resolver
4. ✅ Unit tests

### Medium-term (3 Months):
1. ✅ Feature parity with Bash version
2. ✅ Release Community Edition
3. ✅ GitHub marketing push

---

## 📞 Contact & Support

- **GitHub:** github.com/QguAr71/cytadela-rust
- **Email:** [your-email]
- **Discord:** [community-server]
- **Twitter:** [@cytadela_dns]

---

## 📝 License

- **Community Edition:** GPL v3
- **Enterprise Edition:** Proprietary (Commercial License)
- **Cloud Edition:** SaaS (Terms of Service)

---

**Last Updated:** January 2026
**Version:** 1.0
**Status:** Planning Phase

---

## 💪 Why This Will Work

1. ✅ **Proven concept** - Bash version works, has users
2. ✅ **AI advantage** - 5-10x faster development
3. ✅ **Market timing** - Privacy concerns growing
4. ✅ **Technical edge** - Rust performance + safety
5. ✅ **Business model** - Open Core is proven (GitLab, Nextcloud)
6. ✅ **Solo-friendly** - No team needed initially
7. ✅ **Scalable** - Can grow from $0 to $500K+

**This is absolutely doable for 1 person + AI in 2026!** 🚀
