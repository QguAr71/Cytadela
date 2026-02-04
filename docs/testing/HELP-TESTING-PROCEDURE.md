# Citadel Interactive Help - Testing Procedure

## Overview
Test the new interactive help system with 5 sections and i18n support.

## Pre-requisites
- Citadel installed
- All i18n files present in `lib/i18n/help/`

## Test Cases

### TC1: Basic Menu Display
```bash
sudo ./citadel.sh help
```
**Expected:** Menu displays with 6 options (1-5 + q)

### TC2-TC7: All Menu Sections
Test sections 1-6 in menu

### TC8-TC12: Error handling and i18n

## Sign-off Criteria
- [ ] All TC1-TC12 pass
- [ ] No bash errors
- [ ] All 70+ commands visible
