# 🔧 CoreDNS RFC1035 Warning Fix - v3.2

**Issue:** CoreDNS logs show warning: `Warning: Domain "127.0.0.1." does not follow RFC1035 preferred syntax`

**Priority:** Low (cosmetic, doesn't affect functionality)  
**Status:** Planned for v3.2  
**Created:** 2026-02-01

---

## 📋 Problem

### Current Behavior
```
Feb 01 07:14:56 coredns[21099]: Warning: Domain "127.0.0.1." does not follow RFC1035 preferred syntax
```

### Root Cause
Current Corefile configuration uses IP:port as zone name:
```
127.0.0.1:9153 {
    prometheus
}

.:53 {
    bind 127.0.0.1
    errors
    log
    ...
}
```

CoreDNS interprets `127.0.0.1:9153` as a domain name (zone), which violates RFC1035 naming conventions (domains should contain letters, not just IP addresses).

---

## ✨ Solution

Move `prometheus` plugin into main DNS block as inline directive.

### Before (v3.1)
```corefile
127.0.0.1:9153 {
    prometheus
}

.:53 {
    bind 127.0.0.1
    errors
    log
    hosts /etc/coredns/zones/combined.hosts {
        fallthrough
    }
    cache 30
    forward . 127.0.0.1:5356
    loop
    reload
}
```

### After (v3.2)
```corefile
.:53 {
    bind 127.0.0.1
    prometheus 127.0.0.1:9153
    errors
    log
    hosts /etc/coredns/zones/combined.hosts {
        fallthrough
    }
    cache 30
    forward . 127.0.0.1:5356
    loop
    reload
}
```

---

## 🔧 Implementation

### File to Modify
`modules/unified-install.sh` (v3.2 unified module)

### Code Change
```bash
# In install_coredns() function
tee /etc/coredns/Corefile >/dev/null <<EOF
.:${COREDNS_PORT_DEFAULT} {
    bind 127.0.0.1
    prometheus ${COREDNS_METRICS_ADDR}
    errors
    log
    hosts /etc/coredns/zones/combined.hosts {
        fallthrough
    }
    cache 30
    forward . 127.0.0.1:${dnscrypt_port}
    loop
    reload
}
EOF
```

---

## ✅ Benefits

- ✅ No more RFC1035 warning in logs
- ✅ Cleaner log output
- ✅ RFC compliant configuration
- ✅ Same functionality (Prometheus metrics still work)
- ✅ No breaking changes (metrics endpoint unchanged)

---

## 🧪 Testing

### Verify Prometheus Still Works
```bash
# After applying fix
curl -s http://127.0.0.1:9153/metrics | grep coredns_dns_requests_total
```

### Verify No Warning in Logs
```bash
sudo journalctl -u coredns -n 50 | grep -i warning
# Should not show RFC1035 warning
```

### Verify DNS Still Works
```bash
dig google.com @127.0.0.1 +short
# Should return IP address
```

---

## 📚 Documentation Updates

### User Impact
- No user action required
- Automatic on fresh install (v3.2)
- Existing users: warning is cosmetic, no need to update

### Migration Note
For users upgrading from v3.1 to v3.2:
```bash
# Optional: Update Corefile manually to remove warning
sudo ./citadel.sh install-coredns --reconfigure
```

---

## 📊 Validation

**Before Fix:**
```
Feb 01 07:14:56 coredns[21099]: Warning: Domain "127.0.0.1." does not follow RFC1035 preferred syntax
Feb 01 07:14:56 coredns[21099]: 127.0.0.1.:9153
Feb 01 07:14:56 coredns[21099]: .:53 on 127.0.0.1
```

**After Fix:**
```
Feb 01 07:14:56 coredns[21099]: .:53 on 127.0.0.1
Feb 01 07:14:56 coredns[21099]: Prometheus metrics available at 127.0.0.1:9153
```

---

## 🎯 Implementation Checklist

- [ ] Update unified-install.sh with new Corefile template
- [ ] Test fresh installation
- [ ] Test metrics endpoint still works
- [ ] Verify no RFC1035 warning in logs
- [ ] Update CHANGELOG.md
- [ ] Add to v3.2 release notes

---

**Last Updated:** 2026-02-01  
**Status:** Ready for v3.2 Implementation  
**Estimated Time:** 15 minutes
