# Release Instructions

This document describes how to create a new release of Citadel.

## 🚀 Automated Release (Recommended)

### Prerequisites
- All tests must pass in CI
- CHANGELOG.md must be updated
- VERSION file must contain the correct version

### Steps
1. **Update version number:**
   ```bash
   # Update VERSION file
   echo "3.1.1" > VERSION
   
   # Update version in cytadela-core.sh
   sed -i 's/CYTADELA_VERSION=".*"/CYTADELA_VERSION="3.1.1"/' lib/cytadela-core.sh
   
   # Update README badges if needed
   ```

2. **Update CHANGELOG.md:**
   ```bash
   # Add new version section
   echo "## [3.1.1] - $(date +%Y-%m-%d)" >> CHANGELOG.md
   echo "" >> CHANGELOG.md
   echo "### Bug Fixes" >> CHANGELOG.md
   echo "- Fixed critical issue in module loading" >> CHANGELOG.md
   ```

3. **Commit and tag:**
   ```bash
   git add VERSION CHANGELOG.md lib/cytadela-core.sh README.md
   git commit -m "release: Bump version to 3.1.1"
   git tag -a v3.1.1 -m "Release v3.1.1"
   git push origin main --tags
   ```

4. **Trigger release:**
   - GitHub Actions will automatically create the release
   - Check the [Actions tab](https://github.com/QguAr71/Cytadela/actions)
   - Release will be created with auto-generated changelog

## 📝 Manual Release (Fallback)

If automated release fails, follow these steps:

1. **Create source archive:**
   ```bash
   VERSION=$(cat VERSION)
   tar --exclude='.git' \
       --exclude='.github' \
       --exclude='legacy' \
       --exclude='*.log' \
       --exclude='tests/reports' \
       -czf "cytadela-${VERSION}.tar.gz" .
   ```

2. **Generate checksum:**
   ```bash
   sha256sum "cytadela-${VERSION}.tar.gz" > "cytadela-${VERSION}.tar.gz.sha256"
   ```

3. **Create GitHub release:**
   - Go to [Releases page](https://github.com/QguAr71/Cytadela/releases)
   - Click "Create a new release"
   - Choose tag (e.g., `v3.1.1`)
   - Copy changelog from CHANGELOG.md
   - Upload archive and checksum files

## 📋 Pre-Release Checklist

- [ ] All CI tests pass
- [ ] CHANGELOG.md updated
- [ ] VERSION file updated
- [ ] Version updated in lib/cytadela-core.sh
- [ ] README badges updated (if needed)
- [ ] Documentation updated (if breaking changes)
- [ ] Manual testing completed (if possible)

## 🏷️ Version Format

Citadel uses [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 3.1.0)
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Version Examples
- `3.1.0` - Major release with new features
- `3.1.1` - Patch release with bug fixes
- `3.2.0` - Minor release with new features
- `4.0.0` - Major breaking changes

## 🔄 Release Frequency

- **Patch releases**: As needed for critical bugs
- **Minor releases**: Every 2-3 months for features
- **Major releases**: Every 6-12 months for breaking changes

## 📊 Post-Release Tasks

- [ ] Update website/documentation
- [ ] Announce on social media (optional)
- [ ] Monitor issues for new bugs
- [ ] Update package repositories (AUR, etc.)
- [ ] Create Docker image (if applicable)

## 🆘 Troubleshooting

### Release Workflow Fails
1. Check Actions tab for error details
2. Verify tag format (must be `vX.Y.Z`)
3. Ensure VERSION file matches tag
4. Check for merge conflicts

### Changelog Generation Issues
1. Verify git history is accessible
2. Check for malformed commit messages
3. Manual changelog entry can be added

### Asset Upload Fails
1. Check file size (< 2GB per GitHub limit)
2. Verify file permissions
3. Manual upload via GitHub UI

---

**Remember:** Always test thoroughly before releasing! 🧪
