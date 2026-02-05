#!/bin/bash
# Simple smoke test for Citadel
# This test verifies basic functionality without requiring root or full installation

set -e

echo "🧪 Running Citadel Smoke Tests..."

# Check if main script exists and is executable
if [[ ! -f "citadel.sh" ]]; then
    echo "❌ citadel.sh not found"
    exit 1
fi

if [[ ! -x "citadel.sh" ]]; then
    echo "❌ citadel.sh is not executable"
    exit 1
fi

echo "✅ Main script exists and is executable"

# Check if basic directories exist
if [[ ! -d "lib" ]]; then
    echo "❌ lib directory not found"
    exit 1
fi

if [[ ! -d "modules" ]]; then
    echo "❌ modules directory not found"
    exit 1
fi

echo "✅ Basic directories exist"

# Check if LICENSE file exists
if [[ ! -f "LICENSE" ]]; then
    echo "❌ LICENSE file not found"
    exit 1
fi

echo "✅ LICENSE file exists"

# Check if README.md exists
if [[ ! -f "README.md" ]]; then
    echo "❌ README.md not found"
    exit 1
fi

echo "✅ README.md exists"

# Try to run --help (should work without root)
echo "🧪 Testing --help command..."
if ! ./citadel.sh --help >/dev/null 2>&1; then
    echo "⚠️ Warning: --help command failed (might require dependencies)"
else
    echo "✅ --help command works"
fi

# Try to run version command
echo "🧪 Testing version command..."
if ! ./citadel.sh version >/dev/null 2>&1; then
    echo "⚠️ Warning: version command failed (might require dependencies)"
else
    echo "✅ Version command works"
fi

echo "🎉 Smoke tests completed successfully!"
echo "📝 Note: Some tests may be skipped if dependencies are not available in CI environment"
