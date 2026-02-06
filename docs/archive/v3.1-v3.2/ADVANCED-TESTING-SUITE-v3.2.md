# 🧪 Advanced Testing Suite - v3.2 Plan

**Version:** 3.2.0 PLANNED  
**Created:** 2026-02-01  
**Status:** Planning Phase  
**Priority:** Medium

---

## 📋 Overview

This document outlines the advanced testing suite planned for v3.2, addressing the limitations identified in v3.1.0 testing. The goal is to provide comprehensive, automated testing that covers edge cases, stress scenarios, and long-term stability.

**Current State (v3.1.0):**
- ✅ 7 basic tests (DNS leak, crash recovery, backup/restore, DNSSEC, IPv6, malware blocking, performance)
- ✅ Manual testing with documented results
- ⚠️ Missing: Edge cases, stress testing, long-term stability, automation

**Target State (v3.2):**
- ✅ All v3.1.0 tests automated
- ✅ Edge case coverage (DDoS, interference, false positives)
- ✅ Long-term stability tests (24h+)
- ✅ CI/CD integration
- ✅ Regression detection

---

## 🎯 Test Categories

### 1. High Load / DDoS Simulation

**Current Gap:**
- v3.1.0 tested normal load (76K QPS sustained, 30s)
- Missing: Extreme load, flood attacks, rate limiting validation

**Planned Tests:**

#### 1.1 Flood Attack Simulation
```bash
# hping3 DNS flood
sudo hping3 -2 -p 53 --flood 127.0.0.1

# Expected behavior:
# - Rate limiting kicks in (10 QPS limit)
# - Logs show "CITADEL DNS LEAK" entries
# - Service remains responsive
# - No crash or memory leak
```

#### 1.2 Sustained High Load (60s+)
```bash
# dnsperf with 500 concurrent clients, 300s duration
dnsperf -s 127.0.0.1 -d queries.txt -c 500 -l 300

# Expected metrics:
# - QPS: 50K+ sustained
# - Packet loss: <1%
# - Latency: <5ms avg
# - Memory: Stable (no leaks)
```

#### 1.3 Query Amplification Attack
```bash
# Large DNS queries (EDNS0, ANY records)
dig @127.0.0.1 . ANY +bufsize=4096

# Expected behavior:
# - Proper EDNS0 handling
# - No amplification vulnerability
# - Rate limiting applies
```

**Tools Required:**
- hping3
- dnsperf
- mz (Mausezahn)
- Custom flood scripts

**Success Criteria:**
- ✅ Service survives flood attacks
- ✅ Rate limiting works correctly
- ✅ Logs capture attack attempts
- ✅ No memory leaks under stress
- ✅ Recovery time <30s after attack stops

---

### 2. DNSSEC + Adblock Interference

**Current Gap:**
- DNSSEC and adblock tested separately
- Missing: Interaction testing, blocked DNSSEC domains

**Planned Tests:**

#### 2.1 DNSSEC-Signed Blocked Domains
```bash
# Test domains that are:
# 1. DNSSEC-signed
# 2. On blocklist

# Expected behavior:
# - Domain blocked (0.0.0.0)
# - No DNSSEC validation error
# - Proper logging
```

#### 2.2 DNSSEC Validation with Adblock Enabled
```bash
# Test multiple DNSSEC-signed domains
dig @127.0.0.1 icann.org +dnssec
dig @127.0.0.1 ietf.org +dnssec
dig @127.0.0.1 ripe.net +dnssec

# Expected:
# - AD flag present
# - RRSIG records present
# - No interference from adblock
```

#### 2.3 Invalid DNSSEC with Adblock
```bash
# Test invalid DNSSEC signature
dig @127.0.0.1 dnssec-failed.org

# Expected:
# - SERVFAIL (DNSSEC validation failure)
# - Not blocked by adblock (validation happens first)
```

**Success Criteria:**
- ✅ DNSSEC validation works with adblock enabled
- ✅ Blocked domains don't trigger DNSSEC errors
- ✅ Invalid signatures properly rejected
- ✅ No false positives in DNSSEC validation

---

### 3. Long-term Stability

**Current Gap:**
- Short-term tests only (30s-60s)
- Missing: Memory leaks, resource exhaustion, sustained load

**Planned Tests:**

#### 3.1 24-Hour Memory Leak Test
```bash
# Monitor memory usage over 24h
while true; do
    echo "$(date): $(ps aux | grep -E 'coredns|dnscrypt' | awk '{print $6}')" >> memory.log
    sleep 60
done

# Expected:
# - Memory usage stable (±5%)
# - No continuous growth
# - RSS < 200MB for CoreDNS
# - RSS < 100MB for DNSCrypt-Proxy
```

#### 3.2 Sustained Load (24h)
```bash
# Run dnsperf for 24 hours
dnsperf -s 127.0.0.1 -d queries.txt -c 100 -l 86400

# Expected:
# - QPS stable throughout
# - No degradation over time
# - 0% packet loss
# - Latency consistent
```

#### 3.3 Crash Recovery Stress Test
```bash
# Kill services repeatedly over 24h
for i in {1..100}; do
    sudo killall -9 coredns dnscrypt-proxy
    sleep 300  # Wait 5 minutes
done

# Expected:
# - Auto-restart every time
# - Recovery time <30s
# - No permanent failures
# - Logs show all restarts
```

**Monitoring:**
- Memory usage (RSS, VSZ)
- CPU usage
- File descriptors
- Network connections
- Disk I/O
- Cache hit rate

**Success Criteria:**
- ✅ Memory stable over 24h (±5%)
- ✅ No resource exhaustion
- ✅ Performance consistent
- ✅ Auto-recovery works 100% of time

---

### 4. IPv6 Privacy Extensions

**Current Gap:**
- IPv6 leak protection tested
- Missing: Privacy extensions, temporary addresses

**Planned Tests:**

#### 4.1 Temporary Address Validation
```bash
# Check for temporary IPv6 addresses
ip -6 addr show | grep "scope global temporary"

# Expected:
# - At least one temporary address present
# - Privacy extensions enabled
# - Addresses rotate periodically
```

#### 4.2 Privacy Extensions Configuration
```bash
# Verify sysctl settings
sysctl net.ipv6.conf.all.use_tempaddr
sysctl net.ipv6.conf.default.use_tempaddr

# Expected:
# - use_tempaddr = 2 (prefer temporary)
# - temp_valid_lft configured
# - temp_prefered_lft configured
```

#### 4.3 IPv6 DNS Leak with Privacy Extensions
```bash
# Test DNS leak with temporary addresses
dig @2001:4860:4860::8888 google.com AAAA +time=2

# Expected:
# - Timeout (blocked by firewall)
# - No leak via temporary addresses
# - Logs show blocked attempt
```

**Success Criteria:**
- ✅ Temporary addresses present
- ✅ Privacy extensions enabled
- ✅ No IPv6 DNS leaks
- ✅ Address rotation works

---

### 5. Adblock False Positives

**Current Gap:**
- Only malware domains tested
- Missing: Legitimate sites verification

**Planned Tests:**

#### 5.1 Top 100 Sites Test
```bash
# Test top 100 Alexa/Tranco sites
for site in $(cat top100.txt); do
    result=$(dig @127.0.0.1 "$site" +short)
    if [[ "$result" == "0.0.0.0" ]]; then
        echo "FALSE POSITIVE: $site"
    fi
done

# Expected:
# - 0 false positives
# - All legitimate sites resolve
```

#### 5.2 CDN and Cloud Services
```bash
# Test major CDNs (should never be blocked)
dig @127.0.0.1 cloudflare.com
dig @127.0.0.1 akamai.com
dig @127.0.0.1 fastly.com
dig @127.0.0.1 cloudfront.net

# Expected:
# - All resolve correctly
# - No false blocks
```

#### 5.3 Developer Tools
```bash
# Test developer sites (critical for users)
dig @127.0.0.1 github.com
dig @127.0.0.1 stackoverflow.com
dig @127.0.0.1 gitlab.com
dig @127.0.0.1 npmjs.com
dig @127.0.0.1 pypi.org

# Expected:
# - All resolve correctly
# - No interference with development
```

**Automated Test:**
```bash
# Added to tests/smoke-test.sh (TEST 8)
test_adblock_false_positives() {
    # Tests 8 legitimate sites
    # Fails if any blocked
}
```

**Success Criteria:**
- ✅ 0 false positives in top 100 sites
- ✅ CDNs never blocked
- ✅ Developer tools accessible
- ✅ Automated test in smoke-test.sh

---

### 6. Additional DNSSEC Domains

**Current Gap:**
- Only 2 domains tested (cloudflare-dns.com, dnssec-failed.org)
- Missing: Broader DNSSEC coverage

**Planned Tests:**

#### 6.1 Signed Root Zone
```bash
dig @127.0.0.1 . DNSKEY +dnssec

# Expected:
# - DNSKEY records present
# - RRSIG present
# - AD flag set
```

#### 6.2 Major Organizations
```bash
# Test DNSSEC-signed domains
dig @127.0.0.1 icann.org +dnssec
dig @127.0.0.1 ietf.org +dnssec
dig @127.0.0.1 ripe.net +dnssec
dig @127.0.0.1 iana.org +dnssec

# Expected:
# - All show AD flag
# - RRSIG records present
# - Validation successful
```

#### 6.3 TLD DNSSEC
```bash
# Test TLD DNSSEC
dig @127.0.0.1 se. DNSKEY +dnssec  # Sweden
dig @127.0.0.1 nl. DNSKEY +dnssec  # Netherlands
dig @127.0.0.1 cz. DNSKEY +dnssec  # Czech Republic

# Expected:
# - TLD DNSSEC working
# - Chain of trust validated
```

**Success Criteria:**
- ✅ Root zone DNSSEC validated
- ✅ 10+ signed domains tested
- ✅ TLD DNSSEC working
- ✅ Chain of trust verified

---

## 🤖 CI/CD Integration

**Goal:** Automate all tests in GitHub Actions

### Workflow Structure

```yaml
name: Advanced Testing Suite

on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  smoke-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run smoke tests
        run: ./tests/smoke-test.sh
  
  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Install dependencies
        run: sudo apt-get install -y dnsperf bind9-dnsutils
      - name: Run performance benchmark
        run: ./tests/performance-test.sh
      - name: Check regression
        run: ./tests/check-regression.sh
  
  stress-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Install stress tools
        run: sudo apt-get install -y hping3
      - name: Run stress tests
        run: ./tests/stress-test.sh
  
  dnssec-tests:
    runs-on: ubuntu-latest
    steps:
      - name: Run DNSSEC validation
        run: ./tests/dnssec-test.sh
```

### Test Scripts to Create

1. **tests/performance-test.sh** - Automated performance benchmarks
2. **tests/stress-test.sh** - DDoS simulation and high load
3. **tests/dnssec-test.sh** - Comprehensive DNSSEC validation
4. **tests/check-regression.sh** - Compare with baseline metrics
5. **tests/long-term-test.sh** - 24h stability (manual trigger)

---

## 📊 Metrics and Reporting

### Performance Baseline (v3.1.0)

```yaml
baseline:
  qps: 76323
  latency_avg: 1.29ms
  latency_min: 0.01ms
  latency_max: 202ms
  packet_loss: 0%
  cache_hit_rate: 99.99%
```

### Regression Detection

```bash
# Compare current run with baseline
if [[ $current_qps -lt $((baseline_qps * 90 / 100)) ]]; then
    echo "REGRESSION: QPS dropped by >10%"
    exit 1
fi
```

### Test Reports

- **Format:** Markdown + JSON
- **Storage:** `tests/reports/`
- **Artifacts:** GitHub Actions artifacts
- **Notifications:** Slack/Discord on failures

---

## 🗓️ Implementation Timeline

### Phase 1: Test Scripts (Week 1-2)
- [ ] Create performance-test.sh
- [ ] Create stress-test.sh
- [ ] Create dnssec-test.sh
- [ ] Create check-regression.sh
- [ ] Update smoke-test.sh (already done)

### Phase 2: CI/CD Integration (Week 3)
- [ ] Create GitHub Actions workflow
- [ ] Set up test environment
- [ ] Configure artifacts and reporting
- [ ] Add regression detection

### Phase 3: Long-term Tests (Week 4)
- [ ] Create 24h stability test
- [ ] Set up monitoring (Prometheus/Grafana)
- [ ] Document manual test procedures
- [ ] Create test report templates

### Phase 4: Documentation (Week 5)
- [ ] Update TESTING-RESULTS template
- [ ] Create test execution guide
- [ ] Document CI/CD setup
- [ ] Add troubleshooting guide

---

## ✅ Success Criteria

**v3.2 Advanced Testing Suite is complete when:**

1. ✅ All 6 test categories implemented
2. ✅ CI/CD workflow running on every PR
3. ✅ Regression detection active
4. ✅ 24h stability test documented
5. ✅ Test coverage >90%
6. ✅ All tests automated (except 24h)
7. ✅ Documentation complete

---

## 🔗 Related Documents

- [TESTING-RESULTS-2026-02-01.md](TESTING-RESULTS-2026-02-01.md) - v3.1.0 test results
- [REFACTORING-V3.2-PLAN.md](REFACTORING-V3.2-PLAN.md) - v3.2 refactoring plan
- [tests/smoke-test.sh](../tests/smoke-test.sh) - Current smoke tests

---

**Status:** Planning Phase  
**Target Release:** v3.2.0  
**Priority:** Medium  
**Estimated Effort:** 5 weeks
