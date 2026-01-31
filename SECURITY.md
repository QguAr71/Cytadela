# Security Policy

## 🔒 Supported Versions

| Version | Supported          | Status |
| ------- | ------------------ | ------ |
| 3.1.x   | ✅ Yes            | Stable |
| 3.0.x   | ⚠️ Limited        | Legacy |
| < 3.0   | ❌ No             | Deprecated |

**Current stable version:** v3.1.0 (2026-01-31)

---

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability in Citadel, please report it responsibly:

### Preferred Method: Private Security Advisory

1. Go to [Security Advisories](https://github.com/QguAr71/Cytadela/security/advisories)
2. Click "Report a vulnerability"
3. Provide detailed information about the vulnerability

### Alternative Method: Email

Send an email to: **security@citadel-project.org** (if available)

**Please include:**
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Time

- **Initial response:** Within 48 hours
- **Status update:** Within 7 days
- **Fix timeline:** Depends on severity (see below)

---

## 🎯 Severity Levels

| Severity | Description | Response Time | Example |
|----------|-------------|---------------|---------|
| **Critical** | Remote code execution, privilege escalation | 24-48 hours | RCE in installer |
| **High** | Data exposure, authentication bypass | 3-7 days | DNS leak, config exposure |
| **Medium** | DoS, information disclosure | 7-14 days | Service crash, version disclosure |
| **Low** | Minor issues, cosmetic | 14-30 days | Log verbosity, UI issues |

---

## 🛡️ Security Best Practices

### For Users

1. **Always verify downloads:**
   ```bash
   # Verify git repository
   git clone https://github.com/QguAr71/Cytadela.git
   cd Cytadela
   git verify-commit HEAD  # If signed
   ```

2. **Use integrity checking:**
   ```bash
   sudo ./citadel.sh integrity-init
   sudo ./citadel.sh integrity-check
   ```

3. **Keep system updated:**
   ```bash
   sudo ./citadel.sh auto-update-enable
   ```

4. **Review configuration:**
   ```bash
   sudo ./citadel.sh diagnostics
   sudo ./citadel.sh verify
   ```

5. **Use emergency features:**
   ```bash
   # If something goes wrong
   sudo ./citadel.sh panic-bypass
   sudo ./citadel.sh restore-system
   ```

### For Developers

1. **Code review:** All PRs require review
2. **Testing:** Run tests before committing
   ```bash
   bash tests/smoke-test.sh
   shellcheck citadel.sh lib/*.sh modules/*.sh
   ```

3. **No hardcoded secrets:** Use environment variables
4. **Input validation:** Always validate user input
5. **Principle of least privilege:** Run with minimum required permissions

---

## 🔐 Security Features

### Built-in Security

- ✅ **Supply-chain protection** - Integrity verification for binaries
- ✅ **DNS encryption** - DoH/DoT via DNSCrypt-Proxy
- ✅ **Firewall hardening** - NFTables strict rules
- ✅ **Emergency recovery** - Panic-bypass mode
- ✅ **Integrity monitoring** - File integrity checks
- ✅ **Local-first** - No cloud dependencies

### Security Commands

```bash
# Initialize security
sudo ./citadel.sh supply-chain-init
sudo ./citadel.sh integrity-init

# Verify integrity
sudo ./citadel.sh supply-chain-verify
sudo ./citadel.sh integrity-check

# Emergency mode
sudo ./citadel.sh panic-bypass    # Bypass DNS/firewall
sudo ./citadel.sh panic-restore   # Restore normal mode

# Firewall audit
sudo ./citadel.sh ghost-check     # Check open ports
sudo ./citadel.sh location-check  # Check network location
```

---

## 🚫 Known Security Considerations

### Shell Script Limitations

**Issue:** Bash scripts can be vulnerable to injection attacks.

**Mitigation:**
- All user input is validated
- ShellCheck used for static analysis
- Quotes used consistently
- No `eval` or dynamic code execution

### Root Privileges

**Issue:** Citadel requires root for system configuration.

**Mitigation:**
- Clear documentation of required permissions
- Minimal privilege usage
- Audit trail in logs
- Emergency recovery mode

### DNS Privacy

**Issue:** DNS queries can leak information.

**Mitigation:**
- DNSCrypt-Proxy encryption (DoH/DoT)
- NFTables leak prevention
- No-log DNS resolvers
- IPv6 privacy extensions

---

## 📋 Security Checklist

Before deploying Citadel in production:

- [ ] Review all configuration files
- [ ] Enable integrity checking
- [ ] Configure firewall (strict mode)
- [ ] Test emergency recovery
- [ ] Enable auto-updates
- [ ] Review DNS resolver selection
- [ ] Test DNS leak prevention
- [ ] Configure backup/restore
- [ ] Review logs regularly
- [ ] Document custom changes

---

## 🔄 Security Updates

Security updates are released as soon as possible after a vulnerability is confirmed.

**Update process:**
```bash
# Check for updates
sudo ./citadel.sh auto-update-status

# Update manually
cd /path/to/Cytadela
git pull
sudo ./citadel.sh verify
```

**Notification channels:**
- GitHub Security Advisories
- Release notes (CHANGELOG.md)
- GitHub Releases

---

## 📚 Additional Resources

- [Full Manual (PL)](docs/user/MANUAL_PL.md)
- [Full Manual (EN)](docs/user/MANUAL_EN.md)
- [Architecture Documentation](docs/CITADEL-STRUCTURE.md)
- [Contributing Guidelines](docs/developer/contributing.md)

---

## 🙏 Acknowledgments

We appreciate responsible disclosure and will credit security researchers who report vulnerabilities (unless they prefer to remain anonymous).

**Hall of Fame:** (To be added)

---

**Last updated:** 2026-01-31  
**Version:** 3.1.0
