# 🌐 Refactoring Plan v3.4 - Web Dashboard

**Version:** 3.4.0 PLANNED  
**Created:** 2026-01-31  
**Status:** Planning Phase  
**Estimated Time:** 3-4 weeks (with AI assistance)  
**Prerequisites:** v3.3.0 (Reputation, ASN, Event Logging, Honeypot)

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Technical Architecture](#technical-architecture)
3. [Features](#features)
4. [Implementation Plan](#implementation-plan)
5. [Security Considerations](#security-considerations)
6. [Timeline & Milestones](#timeline--milestones)
7. [Testing Strategy](#testing-strategy)

---

## 🎯 Executive Summary

### Goals

- **Add Web Dashboard:** Localhost-only web UI for monitoring and management
- **Maintain Security:** Minimal attack surface, no network exposure
- **Keep Simplicity:** Lightweight stack (htmx + Bash CGI)
- **Optional Feature:** Flag `--web` to enable/disable
- **Competitive:** Match Pi-hole UX while maintaining privacy focus

### Benefits

- ✅ Lower barrier to entry (non-CLI users)
- ✅ Visual metrics (graphs, real-time stats)
- ✅ Competitive with Pi-hole/AdGuard
- ✅ Community growth (easier adoption)
- ✅ Better debugging (visual logs)

### Trade-offs

- ⚠️ +Attack surface (mitigated: localhost-only)
- ⚠️ +Maintenance overhead (UI tests, multi-lang)
- ⚠️ +Development time (~3-4 weeks)

### Non-Goals

- ❌ Network-wide access (security risk)
- ❌ Authentication (not needed for localhost)
- ❌ Heavy frameworks (React, Vue - too complex)
- ❌ Replace CLI (UI is complementary)

---

## 🔧 Technical Architecture

### Stack

**Backend:**
- Bash CGI scripts
- Netcat/socat for HTTP server
- Prometheus metrics integration
- JSON API endpoints

**Frontend:**
- htmx (hypermedia, ~14kB)
- Vanilla CSS (no frameworks)
- Minimal JavaScript (charts only)

**Server:**
- Localhost-only: `127.0.0.1:9154`
- HTTP (no HTTPS needed for localhost)
- Systemd service: `cytadela-web.service`

### Architecture Diagram

```
┌─────────────────────────────────────────┐
│  Browser (localhost:9154)               │
└─────────────────┬───────────────────────┘
                  │ HTTP
                  ↓
┌─────────────────────────────────────────┐
│  Netcat/Socat HTTP Server               │
│  (Bash CGI handler)                     │
└─────────────────┬───────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    ↓             ↓             ↓
┌─────────┐  ┌─────────┐  ┌─────────┐
│ Status  │  │ Metrics │  │ Logs    │
│ API     │  │ API     │  │ API     │
└────┬────┘  └────┬────┘  └────┬────┘
     │            │            │
     ↓            ↓            ↓
┌─────────────────────────────────────────┐
│  Cytadela Core (Bash modules)           │
│  - unified-monitor.sh                   │
│  - unified-security.sh                  │
│  - lib/reputation.sh                    │
│  - lib/event-logger.sh                  │
└─────────────────────────────────────────┘
```

---

## 🎨 Features

### 1. Dashboard (Home)

**What:** Overview of system status

**Components:**
- DNS Status (CoreDNS, DNSCrypt)
- Firewall Status (nftables)
- System Health (CPU, RAM, uptime)
- Quick Stats (queries/min, blocked, cache hit rate)

**Implementation:**
```bash
# /opt/cytadela/web/cgi-bin/dashboard.sh
#!/bin/bash
source /opt/cytadela/lib/cytadela-core.sh

# Get status
dns_status=$(systemctl is-active coredns)
firewall_status=$(nft list tables 2>/dev/null | grep -q "inet filter" && echo "active" || echo "inactive")

# Output JSON
cat <<EOF
{
  "dns": "$dns_status",
  "firewall": "$firewall_status",
  "uptime": "$(uptime -p)",
  "queries_per_min": $(get_queries_per_min)
}
EOF
```

**Frontend (htmx):**
```html
<div hx-get="/api/dashboard" hx-trigger="every 5s" hx-swap="innerHTML">
  <div class="card">
    <h3>DNS Status</h3>
    <span class="status-active">Active</span>
  </div>
</div>
```

---

### 2. Query Log

**What:** Real-time DNS query log

**Features:**
- Last 100 queries
- Filter by domain/IP
- Show blocked/allowed
- Export to CSV

**Implementation:**
```bash
# /opt/cytadela/web/cgi-bin/queries.sh
#!/bin/bash

# Parse CoreDNS logs
tail -n 100 /var/log/coredns/queries.log | \
  awk '{print $1, $2, $3, $4}' | \
  jq -R -s 'split("\n") | map(select(length > 0) | split(" ") | {
    timestamp: .[0],
    domain: .[1],
    type: .[2],
    result: .[3]
  })'
```

---

### 3. Blocklist Management

**What:** Manage adblock lists

**Features:**
- List active blocklists
- Enable/disable lists
- Add custom domains
- Rebuild blocklist

**Implementation:**
```bash
# /opt/cytadela/web/cgi-bin/blocklists.sh
#!/bin/bash

case "$REQUEST_METHOD" in
  GET)
    # List blocklists
    cat /etc/cytadela/blocklists.conf | jq -R -s 'split("\n") | map(select(length > 0))'
    ;;
  POST)
    # Add/remove blocklist
    domain="$POST_domain"
    action="$POST_action"
    
    if [[ "$action" == "add" ]]; then
      echo "$domain" >> /etc/cytadela/custom-blocklist.txt
      citadel adblock rebuild
    fi
    ;;
esac
```

---

### 4. Metrics & Graphs

**What:** Visual metrics from Prometheus

**Features:**
- Cache hit rate (line chart)
- Queries per minute (bar chart)
- Top blocked domains (pie chart)
- Historical data (last 24h)

**Implementation:**
```bash
# /opt/cytadela/web/cgi-bin/metrics.sh
#!/bin/bash

# Query Prometheus
curl -s "http://localhost:9090/api/v1/query?query=coredns_cache_hits_total" | \
  jq '.data.result[0].value[1]'
```

**Frontend (Chart.js):**
```html
<canvas id="cacheChart"></canvas>
<script>
  fetch('/api/metrics/cache')
    .then(r => r.json())
    .then(data => {
      new Chart(ctx, {
        type: 'line',
        data: { labels: data.timestamps, datasets: [{ data: data.values }] }
      });
    });
</script>
```

---

### 5. Settings

**What:** Configuration management

**Features:**
- DNS settings (upstream, cache size)
- Firewall mode (safe/strict)
- Reputation threshold
- Auto-update toggle

**Implementation:**
```bash
# /opt/cytadela/web/cgi-bin/settings.sh
#!/bin/bash

case "$REQUEST_METHOD" in
  GET)
    # Read config
    cat /etc/cytadela/config.json
    ;;
  POST)
    # Update config
    jq ".firewall_mode = \"$POST_firewall_mode\"" /etc/cytadela/config.json > /tmp/config.json
    mv /tmp/config.json /etc/cytadela/config.json
    
    # Apply changes
    citadel firewall-mode "$POST_firewall_mode"
    ;;
esac
```

---

## 📅 Implementation Plan

### Phase 1: Backend Foundation (Week 1)

**Tasks:**
1. Create HTTP server (netcat/socat)
2. Implement CGI handler (Bash)
3. Create API endpoints structure
4. Add systemd service
5. Test basic routing

**Deliverables:**
- `lib/web-server.sh` - HTTP server
- `web/cgi-bin/` - CGI scripts
- `systemd/cytadela-web.service`
- Basic API working

**Time:** 5-7 days

---

### Phase 2: API Endpoints (Week 1-2)

**Tasks:**
1. Dashboard API (`/api/dashboard`)
2. Query log API (`/api/queries`)
3. Blocklist API (`/api/blocklists`)
4. Metrics API (`/api/metrics`)
5. Settings API (`/api/settings`)
6. JSON response formatting

**Deliverables:**
- 5 working API endpoints
- JSON responses
- Error handling

**Time:** 5-7 days

---

### Phase 3: Frontend (Week 2-3)

**Tasks:**
1. HTML templates (dashboard, queries, settings)
2. CSS styling (responsive, dark mode)
3. htmx integration (auto-refresh, forms)
4. Chart.js for metrics
5. Multi-language support (PL/EN)

**Deliverables:**
- `web/public/` - HTML/CSS/JS
- Responsive UI
- Dark mode
- Multi-lang

**Time:** 7-10 days

---

### Phase 4: Integration & Testing (Week 3-4)

**Tasks:**
1. Integrate with existing modules
2. Add `citadel web start|stop|status` commands
3. Security hardening (localhost-only, input validation)
4. Performance testing (load, memory)
5. Browser testing (Chrome, Firefox)
6. Documentation

**Deliverables:**
- Full integration
- Security audit
- Performance tests
- User documentation

**Time:** 7-10 days

---

## 🔒 Security Considerations

### Threat Model

**Threats:**
1. **Local attacker** - User with shell access
2. **MITM** - Network sniffing (localhost)
3. **XSS** - Malicious input in forms
4. **CSRF** - Cross-site request forgery

### Mitigations

**1. Localhost-only**
```bash
# Bind to 127.0.0.1 only
netcat -l 127.0.0.1 9154
```

**2. Input validation**
```bash
# Sanitize user input
sanitize_input() {
    local input="$1"
    echo "$input" | sed 's/[^a-zA-Z0-9._-]//g'
}
```

**3. CSRF tokens**
```bash
# Generate token
csrf_token=$(openssl rand -hex 16)
echo "$csrf_token" > /tmp/cytadela-csrf-token

# Validate
if [[ "$POST_csrf_token" != "$(cat /tmp/cytadela-csrf-token)" ]]; then
    echo "HTTP/1.1 403 Forbidden"
    exit 1
fi
```

**4. Content-Type headers**
```bash
# Prevent XSS
echo "Content-Type: application/json"
echo "X-Content-Type-Options: nosniff"
```

**5. Rate limiting**
```bash
# Max 100 requests per minute
if (( $(wc -l < /tmp/cytadela-requests.log) > 100 )); then
    echo "HTTP/1.1 429 Too Many Requests"
    exit 1
fi
```

---

## ⏰ Timeline & Milestones

### Week 1: Backend
- **Day 1-2:** HTTP server + CGI handler
- **Day 3-4:** API endpoints (dashboard, queries)
- **Day 5:** Testing + systemd service
- **Milestone:** Backend working

### Week 2: API + Frontend Start
- **Day 1-2:** Metrics + Settings API
- **Day 3-4:** HTML templates
- **Day 5:** CSS styling
- **Milestone:** API complete, UI skeleton

### Week 3: Frontend Finish
- **Day 1-2:** htmx integration
- **Day 3-4:** Charts + multi-lang
- **Day 5:** Polish + dark mode
- **Milestone:** UI complete

### Week 4: Integration + Release
- **Day 1-2:** Integration testing
- **Day 3-4:** Security audit + docs
- **Day 5:** Release v3.4.0
- **Milestone:** Web UI released

---

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test API endpoints
test_dashboard_api() {
    response=$(curl -s http://127.0.0.1:9154/api/dashboard)
    assert_contains "$response" "dns"
    assert_contains "$response" "firewall"
}

test_blocklist_api() {
    response=$(curl -s -X POST http://127.0.0.1:9154/api/blocklists \
      -d "domain=example.com&action=add")
    assert_equals "$response" '{"status":"ok"}'
}
```

### Integration Tests

```bash
# Test full workflow
test_add_blocklist_and_rebuild() {
    # Add domain via UI
    curl -X POST http://127.0.0.1:9154/api/blocklists \
      -d "domain=ads.example.com&action=add"
    
    # Verify in blocklist
    assert_file_contains /etc/cytadela/custom-blocklist.txt "ads.example.com"
    
    # Verify rebuild triggered
    assert_file_newer /var/lib/cytadela/blocklist.txt
}
```

### Browser Tests

- Chrome 120+ (desktop, mobile)
- Firefox 120+ (desktop, mobile)
- Safari 17+ (macOS, iOS)

### Performance Tests

```bash
# Load test
ab -n 1000 -c 10 http://127.0.0.1:9154/api/dashboard

# Memory usage
ps aux | grep cytadela-web | awk '{print $6}'
```

---

## 📊 Success Criteria

### Technical

- ✅ All API endpoints working
- ✅ UI responsive (mobile + desktop)
- ✅ Load time < 1s
- ✅ Memory usage < 50MB
- ✅ Security audit passed

### User Experience

- ✅ Intuitive navigation
- ✅ Real-time updates (< 5s delay)
- ✅ Multi-language support
- ✅ Dark mode working
- ✅ No JavaScript errors

### Documentation

- ✅ Installation guide
- ✅ API documentation
- ✅ Security best practices
- ✅ Troubleshooting guide

---

## 🚀 Rollout Strategy

### Alpha (Internal)

- **Version:** v3.4.0-alpha
- **Duration:** 1 week
- **Goal:** Find critical bugs

### Beta (Early Adopters)

- **Version:** v3.4.0-beta
- **Duration:** 2 weeks
- **Goal:** Real-world testing

### Stable Release

- **Version:** v3.4.0
- **Announcement:** GitHub, Reddit (r/selfhosted, r/privacy)

---

## 📝 Documentation Updates

### User Documentation

- `docs/user/web-dashboard.md` - Web UI guide
- `docs/user/MANUAL_PL.md` - Add web UI section
- `docs/user/MANUAL_EN.md` - Add web UI section
- `docs/user/quick-start.md` - Add web UI quick start

### Developer Documentation

- `docs/developer/web-api.md` - API reference
- `docs/developer/web-architecture.md` - Architecture docs
- `CONTRIBUTING.md` - Add web UI contribution guide

---

**Last updated:** 2026-01-31  
**Version:** 1.0  
**Status:** Planning Phase  
**Next Review:** After v3.3.0 release
