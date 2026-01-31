# 🔐 Refactoring Plan v3.3 - Advanced Security Features

**Version:** 3.3.0 PLANNED  
**Created:** 2026-01-31  
**Status:** Planning Phase  
**Estimated Time:** 2-3 weeks (with AI assistance)  
**Prerequisites:** v3.2.0 (Unified Module Architecture)

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [New Features Overview](#new-features-overview)
3. [Reputation System](#reputation-system)
4. [ASN Blocking](#asn-blocking)
5. [Event Logging](#event-logging)
6. [Implementation Plan](#implementation-plan)
7. [Timeline & Milestones](#timeline--milestones)
8. [Testing Strategy](#testing-strategy)

---

## 🎯 Executive Summary

### Goals

- **Add Reputation System:** Track and score IP addresses based on behavior
- **Add ASN Blocking:** Block entire networks (Autonomous Systems)
- **Add Event Logging:** Structured JSON logs for analysis and auditing
- **Add Honeypot:** Fake services to detect and auto-block scanners
- **Improve Security:** Proactive threat detection and blocking
- **Maintain Simplicity:** Keep Bash implementation, no over-engineering

### Benefits

- ✅ Automatic threat detection
- ✅ Reduced false positives (vs simple blacklists)
- ✅ Scalable blocking (ASN = hundreds of IPs)
- ✅ Better auditing (structured logs)
- ✅ Adaptive security (learns from behavior)

### Non-Goals

- ❌ Machine Learning / AI (too complex)
- ❌ Graph-based reputation (save for Aurora Mystica)
- ❌ Real-time packet inspection (kernel-level)
- ❌ Rust rewrite (stay in Bash)

---

## 🆕 New Features Overview

### 1. Reputation System

**What:** Simple scoring system for IP addresses  
**Why:** Better than blacklists, adapts to behavior  
**How:** Bash + SQLite/text database

**Example:**
```bash
# IP starts with score 1.0 (trusted)
# Failed SSH login: -0.1
# Port scan detected: -0.2
# Successful connection: +0.05
# Score < 0.15 → Auto-block
```

---

### 2. ASN Blocking

**What:** Block entire Autonomous Systems (networks)  
**Why:** One rule blocks hundreds of IPs  
**How:** Bash + whois + nftables

**Example:**
```bash
# Block known botnet ASN
citadel asn-block AS12345

# Result: ~500 IP prefixes blocked
# Much more efficient than blocking individual IPs
```

---

### 3. Event Logging (JSON)

**What:** Structured logs in JSON format  
**Why:** Easy parsing, integration with tools  
**How:** Bash + jq

**Example:**
```json
{
  "timestamp": "2026-01-31T20:00:00Z",
  "event_type": "silent_drop",
  "ip": "1.2.3.4",
  "score": 0.12,
  "reason": "low_reputation"
}
```

---

### 4. Honeypot

**What:** Fake services to detect scanners  
**Why:** Zero false positives, auto-detection  
**How:** Bash + netcat + systemd

**Example:**
```bash
# Fake SSH on port 2222
# Anyone connecting = scanner → auto-block
citadel honeypot install --port=2222 --service=ssh
```

---

## 📊 Reputation System

### Architecture

```
Event → Update Score → Check Threshold → Action
         (in DB)        (< 0.15?)        (DROP/ALLOW)
```

### Database Schema

**File:** `/var/lib/cytadela/reputation.db`

**Format:** Plain text (simple, no SQLite dependency)
```
# IP:SCORE:LAST_UPDATED:EVENTS
1.2.3.4:0.85:2026-01-31T20:00:00Z:3
5.6.7.8:0.12:2026-01-31T19:55:00Z:15
```

### Implementation

**File:** `lib/reputation.sh`

```bash
#!/bin/bash

REPUTATION_DB="/var/lib/cytadela/reputation.db"
REPUTATION_THRESHOLD="0.15"

# Initialize database
reputation_init() {
    mkdir -p "$(dirname "$REPUTATION_DB")"
    touch "$REPUTATION_DB"
}

# Get score for IP
reputation_get_score() {
    local ip="$1"
    
    if [[ -f "$REPUTATION_DB" ]]; then
        local line
        line=$(grep "^$ip:" "$REPUTATION_DB" 2>/dev/null)
        
        if [[ -n "$line" ]]; then
            echo "$line" | cut -d: -f2
        else
            echo "1.0"  # Default: trusted
        fi
    else
        echo "1.0"
    fi
}

# Update score for IP
reputation_update_score() {
    local ip="$1"
    local delta="$2"
    
    local current_score
    current_score=$(reputation_get_score "$ip")
    
    local new_score
    new_score=$(echo "$current_score + $delta" | bc -l)
    
    # Clamp to 0.0-1.0
    if (( $(echo "$new_score < 0.0" | bc -l) )); then
        new_score="0.0"
    elif (( $(echo "$new_score > 1.0" | bc -l) )); then
        new_score="1.0"
    fi
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Update or insert
    if grep -q "^$ip:" "$REPUTATION_DB" 2>/dev/null; then
        # Update existing
        local events
        events=$(grep "^$ip:" "$REPUTATION_DB" | cut -d: -f4)
        events=$((events + 1))
        
        sed -i "s|^$ip:.*|$ip:$new_score:$timestamp:$events|" "$REPUTATION_DB"
    else
        # Insert new
        echo "$ip:$new_score:$timestamp:1" >> "$REPUTATION_DB"
    fi
    
    # Check threshold
    if (( $(echo "$new_score < $REPUTATION_THRESHOLD" | bc -l) )); then
        firewall_silent_drop "$ip"
        log_event "auto_block" "$ip" "$new_score" "reputation_threshold"
    fi
    
    log_info "Reputation updated: $ip score=$new_score (delta=$delta)"
}

# Track event and update reputation
reputation_track_event() {
    local ip="$1"
    local event_type="$2"
    
    local delta
    case "$event_type" in
        "failed_ssh_login")
            delta="-0.10"
            ;;
        "port_scan")
            delta="-0.20"
            ;;
        "failed_dns_query")
            delta="-0.05"
            ;;
        "successful_connection")
            delta="+0.05"
            ;;
        "manual_trust")
            delta="+0.50"
            ;;
        *)
            delta="0.0"
            ;;
    esac
    
    reputation_update_score "$ip" "$delta"
}

# List all IPs with low reputation
reputation_list_suspicious() {
    local threshold="${1:-$REPUTATION_THRESHOLD}"
    
    if [[ ! -f "$REPUTATION_DB" ]]; then
        echo "No reputation database found"
        return
    fi
    
    echo "IPs with score < $threshold:"
    echo "IP              Score   Events  Last Updated"
    echo "------------------------------------------------"
    
    while IFS=: read -r ip score timestamp events; do
        if (( $(echo "$score < $threshold" | bc -l) )); then
            printf "%-15s %-7s %-7s %s\n" "$ip" "$score" "$events" "$timestamp"
        fi
    done < "$REPUTATION_DB"
}

# Reset reputation for IP
reputation_reset() {
    local ip="$1"
    
    sed -i "/^$ip:/d" "$REPUTATION_DB"
    log_info "Reputation reset for $ip"
}

# Clean old entries (older than 30 days)
reputation_cleanup() {
    local days="${1:-30}"
    local cutoff_date
    cutoff_date=$(date -u -d "$days days ago" +"%Y-%m-%dT%H:%M:%SZ")
    
    local temp_file
    temp_file=$(mktemp)
    
    while IFS=: read -r ip score timestamp events; do
        if [[ "$timestamp" > "$cutoff_date" ]]; then
            echo "$ip:$score:$timestamp:$events" >> "$temp_file"
        fi
    done < "$REPUTATION_DB"
    
    mv "$temp_file" "$REPUTATION_DB"
    log_info "Cleaned reputation database (older than $days days)"
}
```

### Commands

```bash
# Manual commands
citadel reputation list [--threshold=0.15]
citadel reputation reset <ip>
citadel reputation cleanup [--days=30]
citadel reputation track <ip> <event>
```

---

## 🌍 ASN Blocking

### Architecture

```
ASN → Lookup Prefixes → Add to nftables → Log
      (whois)            (IP ranges)
```

### Implementation

**File:** `lib/asn-blocking.sh`

```bash
#!/bin/bash

ASN_BLOCKLIST="/etc/cytadela/asn-blocklist.txt"
ASN_CACHE="/var/lib/cytadela/asn-cache/"

# Initialize ASN blocking
asn_init() {
    mkdir -p "$(dirname "$ASN_BLOCKLIST")"
    mkdir -p "$ASN_CACHE"
    
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        cat > "$ASN_BLOCKLIST" <<EOF
# Cytadela ASN Blocklist
# Format: AS<number> [# comment]
# Example:
# AS12345  # Known botnet
# AS67890  # Bulletproof hosting

# Add your ASNs below:

EOF
    fi
}

# Get IP prefixes for ASN
asn_get_prefixes() {
    local asn="$1"
    local cache_file="$ASN_CACHE/${asn}.txt"
    
    # Check cache (valid for 24h)
    if [[ -f "$cache_file" ]]; then
        local cache_age
        cache_age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        
        if (( cache_age < 86400 )); then
            cat "$cache_file"
            return
        fi
    fi
    
    # Fetch from whois
    local prefixes
    prefixes=$(whois -h whois.radb.net -- "-i origin $asn" 2>/dev/null | \
               grep "^route:" | \
               awk '{print $2}' | \
               sort -u)
    
    if [[ -n "$prefixes" ]]; then
        echo "$prefixes" > "$cache_file"
        echo "$prefixes"
    else
        log_error "Failed to fetch prefixes for $asn"
        return 1
    fi
}

# Block ASN
asn_block() {
    local asn="$1"
    
    log_info "Blocking ASN $asn..."
    
    local prefixes
    prefixes=$(asn_get_prefixes "$asn")
    
    if [[ -z "$prefixes" ]]; then
        log_error "No prefixes found for $asn"
        return 1
    fi
    
    local count=0
    while IFS= read -r prefix; do
        [[ -z "$prefix" ]] && continue
        
        # Add to nftables
        nft add rule inet filter input ip saddr "$prefix" drop 2>/dev/null
        
        ((count++))
    done <<< "$prefixes"
    
    log_info "Blocked $count prefixes for $asn"
    log_event "asn_block" "$asn" "$count" "manual"
}

# Unblock ASN
asn_unblock() {
    local asn="$1"
    
    log_info "Unblocking ASN $asn..."
    
    local prefixes
    prefixes=$(asn_get_prefixes "$asn")
    
    if [[ -z "$prefixes" ]]; then
        log_error "No prefixes found for $asn"
        return 1
    fi
    
    local count=0
    while IFS= read -r prefix; do
        [[ -z "$prefix" ]] && continue
        
        # Remove from nftables (find handle and delete)
        local handle
        handle=$(nft -a list ruleset | grep "$prefix" | grep -oP 'handle \K\d+')
        
        if [[ -n "$handle" ]]; then
            nft delete rule inet filter input handle "$handle" 2>/dev/null
            ((count++))
        fi
    done <<< "$prefixes"
    
    log_info "Unblocked $count prefixes for $asn"
}

# Block all ASNs from blocklist
asn_block_from_list() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        log_error "ASN blocklist not found: $ASN_BLOCKLIST"
        return 1
    fi
    
    local total=0
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        
        # Extract ASN (first word)
        local asn
        asn=$(echo "$line" | awk '{print $1}')
        
        asn_block "$asn"
        ((total++))
    done < "$ASN_BLOCKLIST"
    
    log_info "Blocked $total ASNs from blocklist"
}

# List blocked ASNs
asn_list() {
    if [[ ! -f "$ASN_BLOCKLIST" ]]; then
        echo "No ASN blocklist found"
        return
    fi
    
    echo "Blocked ASNs:"
    echo "ASN       Prefixes  Comment"
    echo "----------------------------------------"
    
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        
        local asn comment
        asn=$(echo "$line" | awk '{print $1}')
        comment=$(echo "$line" | cut -d'#' -f2- 2>/dev/null)
        
        local prefix_count=0
        if [[ -f "$ASN_CACHE/${asn}.txt" ]]; then
            prefix_count=$(wc -l < "$ASN_CACHE/${asn}.txt")
        fi
        
        printf "%-9s %-9s %s\n" "$asn" "$prefix_count" "$comment"
    done < "$ASN_BLOCKLIST"
}

# Add ASN to blocklist
asn_add() {
    local asn="$1"
    local comment="${2:-}"
    
    if grep -q "^$asn" "$ASN_BLOCKLIST" 2>/dev/null; then
        log_warn "ASN $asn already in blocklist"
        return 1
    fi
    
    if [[ -n "$comment" ]]; then
        echo "$asn  # $comment" >> "$ASN_BLOCKLIST"
    else
        echo "$asn" >> "$ASN_BLOCKLIST"
    fi
    
    log_info "Added $asn to blocklist"
    
    # Block immediately
    asn_block "$asn"
}

# Remove ASN from blocklist
asn_remove() {
    local asn="$1"
    
    if ! grep -q "^$asn" "$ASN_BLOCKLIST" 2>/dev/null; then
        log_warn "ASN $asn not in blocklist"
        return 1
    fi
    
    # Unblock first
    asn_unblock "$asn"
    
    # Remove from blocklist
    sed -i "/^$asn/d" "$ASN_BLOCKLIST"
    
    log_info "Removed $asn from blocklist"
}
```

### Commands

```bash
# Manual commands
citadel asn-block <AS12345>
citadel asn-unblock <AS12345>
citadel asn-list
citadel asn-add <AS12345> [comment]
citadel asn-remove <AS12345>
citadel asn-update  # Re-fetch all prefixes
```

---

## 📝 Event Logging

### Architecture

```
Event → Format JSON → Append to Log → Rotate
                      (/var/log/cytadela/events.json)
```

### Implementation

**File:** `lib/event-logger.sh`

```bash
#!/bin/bash

EVENT_LOG="/var/log/cytadela/events.json"
EVENT_LOG_MAX_SIZE="10M"  # Rotate after 10MB

# Initialize event logging
event_log_init() {
    mkdir -p "$(dirname "$EVENT_LOG")"
    touch "$EVENT_LOG"
}

# Log event in JSON format
log_event() {
    local event_type="$1"
    local target="$2"
    local value="$3"
    local reason="$4"
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create JSON event
    local event_json
    event_json=$(cat <<EOF
{"timestamp":"$timestamp","event_type":"$event_type","target":"$target","value":"$value","reason":"$reason"}
EOF
)
    
    # Append to log
    echo "$event_json" >> "$EVENT_LOG"
    
    # Check if rotation needed
    event_log_rotate_if_needed
}

# Rotate log if too large
event_log_rotate_if_needed() {
    if [[ ! -f "$EVENT_LOG" ]]; then
        return
    fi
    
    local size
    size=$(stat -c %s "$EVENT_LOG" 2>/dev/null || echo 0)
    local max_size
    max_size=$(numfmt --from=iec "$EVENT_LOG_MAX_SIZE")
    
    if (( size > max_size )); then
        event_log_rotate
    fi
}

# Rotate log file
event_log_rotate() {
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    
    mv "$EVENT_LOG" "${EVENT_LOG}.${timestamp}"
    gzip "${EVENT_LOG}.${timestamp}"
    
    touch "$EVENT_LOG"
    
    log_info "Rotated event log: ${EVENT_LOG}.${timestamp}.gz"
    
    # Keep only last 10 rotated logs
    ls -t "${EVENT_LOG}".*.gz 2>/dev/null | tail -n +11 | xargs rm -f
}

# Query events
event_query() {
    local event_type="${1:-}"
    local hours="${2:-24}"
    
    if [[ ! -f "$EVENT_LOG" ]]; then
        echo "No events logged"
        return
    fi
    
    local cutoff
    cutoff=$(date -u -d "$hours hours ago" +"%Y-%m-%dT%H:%M:%SZ")
    
    if command -v jq &>/dev/null; then
        # Use jq for pretty output
        if [[ -n "$event_type" ]]; then
            jq -r "select(.timestamp > \"$cutoff\" and .event_type == \"$event_type\")" "$EVENT_LOG"
        else
            jq -r "select(.timestamp > \"$cutoff\")" "$EVENT_LOG"
        fi
    else
        # Fallback: grep
        if [[ -n "$event_type" ]]; then
            grep "\"event_type\":\"$event_type\"" "$EVENT_LOG" | \
            awk -v cutoff="$cutoff" -F'"timestamp":"' '$2 > cutoff'
        else
            awk -v cutoff="$cutoff" -F'"timestamp":"' '$2 > cutoff' "$EVENT_LOG"
        fi
    fi
}

# Event statistics
event_stats() {
    local hours="${1:-24}"
    
    if [[ ! -f "$EVENT_LOG" ]]; then
        echo "No events logged"
        return
    fi
    
    local cutoff
    cutoff=$(date -u -d "$hours hours ago" +"%Y-%m-%dT%H:%M:%SZ")
    
    echo "Event statistics (last $hours hours):"
    echo "Event Type          Count"
    echo "-----------------------------"
    
    if command -v jq &>/dev/null; then
        jq -r "select(.timestamp > \"$cutoff\") | .event_type" "$EVENT_LOG" | \
        sort | uniq -c | sort -rn | \
        awk '{printf "%-20s %s\n", $2, $1}'
    else
        awk -v cutoff="$cutoff" -F'"' '
            $4 > cutoff {
                for(i=1; i<=NF; i++) {
                    if($i == "event_type") {
                        print $(i+2)
                    }
                }
            }
        ' "$EVENT_LOG" | sort | uniq -c | sort -rn | \
        awk '{printf "%-20s %s\n", $2, $1}'
    fi
}
```

### Commands

```bash
# Query events
citadel events query [event_type] [--hours=24]
citadel events stats [--hours=24]
citadel events rotate
```

---

## 📅 Implementation Plan

### Phase 1: Core Libraries (Week 1)

**Tasks:**
1. Create `lib/reputation.sh`
2. Create `lib/asn-blocking.sh`
3. Create `lib/event-logger.sh`
4. Create `lib/honeypot.sh`
5. Add to `lib/module-loader.sh`

**Deliverables:**
- 4 new library files
- Unit tests for each

**Time:** 4-5 days

---

### Phase 2: Integration (Week 1-2)

**Tasks:**
1. Integrate reputation tracking into `unified-security.sh`
2. Integrate ASN blocking into `unified-security.sh`
3. Integrate honeypot into `unified-security.sh`
4. Integrate event logging into all modules
5. Add new commands to main scripts

**Deliverables:**
- Updated `unified-security.sh`
- New commands available

**Time:** 4-5 days

---

### Phase 3: Automation (Week 2)

**Tasks:**
1. Create systemd timer for reputation cleanup
2. Create systemd timer for ASN updates
3. Create systemd service for honeypot
4. Add hooks for automatic reputation tracking
5. Configure log rotation

**Deliverables:**
- Systemd timers
- Honeypot service
- Automatic tracking hooks

**Time:** 3-4 days

---

### Phase 4: Testing & Documentation (Week 2-3)

**Tasks:**
1. Unit tests for all new functions
2. Integration tests
3. Update MANUAL_PL.md
4. Update MANUAL_EN.md
5. Update commands.md
6. Create migration guide

**Deliverables:**
- Complete test suite
- Updated documentation

**Time:** 3-5 days

---

## ⏰ Timeline & Milestones

### Week 1: Core Implementation

- **Day 1-2:** Reputation system
- **Day 3-4:** ASN blocking
- **Day 5:** Event logging + Honeypot
- **Milestone:** All libraries complete

### Week 2: Integration & Automation

- **Day 1-2:** Integration with unified modules
- **Day 3-4:** Automation (systemd timers)
- **Day 5:** Testing
- **Milestone:** All features working

### Week 3: Documentation & Release

- **Day 1-3:** Documentation updates
- **Day 4-5:** Final testing, bug fixes
- **Milestone:** v3.3.0 ready for release

---

## 🧪 Testing Strategy

### Unit Tests

```bash
# Test reputation system
test_reputation_get_score
test_reputation_update_score
test_reputation_track_event
test_reputation_cleanup

# Test ASN blocking
test_asn_get_prefixes
test_asn_block
test_asn_unblock

# Test event logging
test_log_event
test_event_query
test_event_rotate
```

### Integration Tests

```bash
# Test full flow
test_failed_ssh_triggers_reputation_update
test_low_reputation_triggers_auto_block
test_asn_block_blocks_all_prefixes
test_events_logged_correctly
```

### Manual Tests

- Trigger failed SSH login, verify reputation update
- Add ASN to blocklist, verify prefixes blocked
- Query events, verify JSON format
- Check log rotation

---

## 📊 Success Criteria

### Technical

- ✅ Reputation system tracks IPs correctly
- ✅ ASN blocking blocks all prefixes
- ✅ Event logging produces valid JSON
- ✅ All tests passing
- ✅ No performance degradation

### User Experience

- ✅ Simple commands
- ✅ Clear documentation
- ✅ Automatic operation (minimal manual intervention)
- ✅ Easy to troubleshoot

---

## 🚀 Rollout Strategy

### Alpha (Internal)

- **Version:** v3.3.0-alpha
- **Duration:** 1 week
- **Goal:** Find critical bugs

### Beta (Early Adopters)

- **Version:** v3.3.0-beta
- **Duration:** 2 weeks
- **Goal:** Real-world testing

### Stable Release

- **Version:** v3.3.0
- **Announcement:** GitHub, community

---

**Last updated:** 2026-01-31  
**Version:** 1.0  
**Status:** Planning Phase  
**Next Review:** After v3.2.0 release
