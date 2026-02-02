# Contributing to Cytadela++

Thank you for your interest in contributing to Cytadela++! This document provides guidelines for contributing to the project.

## 🎯 Project Philosophy

Cytadela++ is a **hobby project** focused on:
- **Privacy-first DNS stack** (DNSCrypt + CoreDNS + NFTables)
- **Local-only control** (no cloud, no telemetry)
- **Security hardening** (leak prevention, integrity checks)
- **Simplicity** (Bash scripts, system dependencies)

## 🤝 How to Contribute

### Reporting Issues

Before creating an issue:
1. Check [existing issues](https://github.com/QguAr71/Cytadela/issues)
2. Search [closed issues](https://github.com/QguAr71/Cytadela/issues?q=is%3Aissue+is%3Aclosed)
3. Review [ROADMAP.md](ROADMAP.md) for planned features

**Good issue reports include:**
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- System information (OS, version, architecture)
- Relevant logs (from `cytadela++ diagnostics`)

**Use issue templates:**
- Bug Report: `.github/ISSUE_TEMPLATE/bug_report.md`
- Feature Request: `.github/ISSUE_TEMPLATE/feature_request.md`

### Suggesting Features

Feature requests are welcome! Please:
1. Check [ROADMAP.md](ROADMAP.md) first
2. Explain the **use case** (not just the feature)
3. Consider **security implications**
4. Keep it **privacy-focused**

**Priority areas (v3.2+):**
- Monitoring/metrics improvements
- Automation enhancements
- Security hardening
- Documentation improvements

### Pull Requests

**Before submitting a PR:**
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (see Testing section below)
5. Update documentation if needed
6. Commit with clear messages

**PR Guidelines:**
- One feature/fix per PR
- Follow existing code style
- Add tests for new features
- Update relevant documentation
- Reference related issues

**PR Checklist:**
- [ ] Code follows project style (Bash best practices)
- [ ] All tests pass (`./tests/smoke-test.sh`)
- [ ] ShellCheck passes (no warnings)
- [ ] Documentation updated
- [ ] **i18n complete** (if adding/modifying modules - see i18n section below)
- [ ] Commit messages are clear
- [ ] No breaking changes (or clearly documented)

## 🧪 Testing

### Running Tests

**Smoke Tests (no sudo required):**
```bash
cd /path/to/Cytadela
./tests/smoke-test.sh
```

**Integration Tests (requires sudo):**
```bash
sudo ./tests/integration-test.sh
```

**ShellCheck:**
```bash
shellcheck -S warning -e SC2034 cytadela++.sh lib/*.sh modules/*.sh
```

### Writing Tests

When adding new features:
1. Add smoke tests to `tests/smoke-test.sh`
2. Add integration tests to `tests/integration-test.sh`
3. Ensure tests are idempotent
4. Document expected behavior

See `tests/README.md` for testing framework details.

## 📝 Code Style

### Bash Best Practices

**Required:**
- Use `set -euo pipefail` at script start
- Quote all variables: `"$variable"`
- Use `[[ ]]` instead of `[ ]`
- Check command success: `if command; then`
- Use functions for reusable code
- Add error handling

**Naming conventions:**
- Functions: `snake_case` (e.g., `install_coredns`)
- Variables: `UPPER_CASE` for globals, `lower_case` for locals
- Files: `kebab-case.sh` (e.g., `module-loader.sh`)

**Example:**
```bash
#!/bin/bash
set -euo pipefail

my_function() {
    local input="$1"
    
    if [[ -z "$input" ]]; then
        echo "Error: input required" >&2
        return 1
    fi
    
    echo "Processing: $input"
}
```

### Security Considerations

**Always:**
- Validate user input
- Use absolute paths
- Check file permissions
- Avoid `eval` and command injection
- Use `mktemp` for temporary files
- Clean up on exit (trap)

**Never:**
- Trust external input without validation
- Use `curl` without HTTPS
- Store secrets in code
- Run unnecessary commands as root

## 📚 Documentation

### What to Document

**Code documentation:**
- Function purpose and parameters
- Complex logic explanations
- Security considerations
- Known limitations

**User documentation:**
- Update `CYTADELA_INSTRUKCJA.md` (Polish)
- Update `CITADEL_EN_COMPLETE_MANUAL.md` (English)
- Update `README.md` if needed
- Add examples for new features

### Documentation Style

- Clear and concise
- Include examples
- Explain **why**, not just **what**
- Use proper formatting (Markdown)

## 🔒 Security

### Reporting Security Issues

**DO NOT** open public issues for security vulnerabilities.

Instead:
1. Email the maintainer (check GitHub profile)
2. Include detailed description
3. Provide steps to reproduce
4. Suggest a fix if possible

We will respond within 48 hours.

### Security Review Process

All security-related PRs will be:
1. Reviewed carefully
2. Tested thoroughly
3. Documented in release notes
4. Credited appropriately

## 🌍 Internationalization (i18n)

Cytadela++ supports **7 languages** with full translations:
- 🇵🇱 Polish (pl)
- 🇬🇧 English (en)
- 🇩🇪 German (de)
- 🇪🇸 Spanish (es)
- 🇮🇹 Italian (it)
- 🇫🇷 French (fr)
- 🇷🇺 Russian (ru)

### For New Modules

**Every new module MUST have full i18n support.** Follow the workflow:
```bash
# Use the new module workflow
cat .windsurf/workflows/add-new-module.md
```

**Requirements:**
1. All user-facing strings use `${T_VAR:-fallback}` pattern
2. Add translations to ALL 7 language files in `lib/i18n/`:
   - `en.sh`, `pl.sh`, `de.sh`, `es.sh`, `fr.sh`, `it.sh`, `ru.sh`
3. Use descriptive variable names: `T_MODULE_ACTION_DESC`
4. Include help text translations
5. Test in at least 2 languages before submitting PR

**Example:**
```bash
# In your module
log_info "${T_MYMODULE_RUNNING:-Running my module...}"

# In lib/i18n/en.sh
export T_MYMODULE_RUNNING="Running my module..."

# In lib/i18n/pl.sh
export T_MYMODULE_RUNNING="Uruchamianie mojego modułu..."
# ... and 5 more languages
```

**PR Checklist for i18n:**
- [ ] All strings use `T_*` variables (no hardcoded text)
- [ ] Translations added to all 7 language files
- [ ] Help text translated
- [ ] Tested with `LANG=pl_PL.UTF-8` and `LANG=en_US.UTF-8`
- [ ] Workflow `.windsurf/workflows/add-new-module.md` followed

See `docs/developer/I18N-REQUIREMENTS.md` for detailed guidelines.

## 🎨 Project Structure

```
Cytadela/
├── cytadela++.new.sh          # Main Polish wrapper
├── citadela_en.new.sh         # Main English wrapper
├── lib/                       # Core libraries
│   ├── cytadela-core.sh       # Core functions
│   ├── module-loader.sh       # Module loading
│   ├── i18n-pl.sh            # Polish translations
│   └── i18n-en.sh            # English translations
├── modules/                   # Functional modules
│   ├── install-*.sh          # Installation modules
│   ├── diagnostics.sh        # Diagnostics
│   ├── adblock.sh            # Adblock management
│   └── ...                   # Other modules
├── tests/                     # Testing framework
│   ├── smoke-test.sh         # Level 2 tests
│   ├── integration-test.sh   # Level 3 tests
│   └── README.md             # Testing docs
└── docs/                      # Documentation
```

## 🚀 Release Process

Releases are managed by the maintainer:
1. Version bump (semantic versioning)
2. Update CHANGELOG
3. Run full test suite
4. Create git tag
5. Publish GitHub release

See `CYTADELA_PUBLIKACJA.md` for detailed release process.

## 📞 Communication

### Where to Ask Questions

- **GitHub Issues:** Bug reports, feature requests
- **GitHub Discussions:** General questions, ideas (if enabled)
- **Pull Requests:** Code review, implementation discussion

### Response Time

This is a hobby project:
- Issues: Response within 1-7 days
- PRs: Review within 1-14 days
- Security: Response within 48 hours

Please be patient!

## 🏆 Recognition

Contributors will be:
- Listed in release notes
- Credited in commit messages
- Mentioned in documentation (if significant contribution)

## 📜 License

By contributing, you agree that your contributions will be licensed under the **GNU General Public License v3.0**.

See [LICENSE](LICENSE) for details.

## 🙏 Thank You!

Every contribution helps make Cytadela++ better for the privacy-conscious community!

**Special thanks to:**
- All future contributors
- Users who report issues
- Community members who spread the word

---

## Quick Links

- [README](README.md)
- [ROADMAP](ROADMAP.md)
- [Testing Guide](tests/README.md)
- [Architecture Design](ARCHITECTURE_DESIGN.md)
- [Polish Manual](CYTADELA_INSTRUKCJA.md)
- [English Manual](CITADEL_EN_COMPLETE_MANUAL.md)

---

*Last updated: 2026-01-30*  
*Project: Cytadela++ v3.1*  
*Maintainer: QguAr71*
