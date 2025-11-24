#!/bin/bash
set -e

echo "=========================================="
echo "Testing Workshop DevContainer Environment"
echo "=========================================="
echo ""

# Test Java
echo "✓ Testing Java..."
if java -version > /dev/null 2>&1; then
    java -version 2>&1 | head -1
else
    echo "  ✗ Java not found!"
    exit 1
fi
echo ""

# Test Gradle wrapper
echo "✓ Testing Gradle wrapper..."
if which gradle > /dev/null 2>&1; then
    echo "  Gradle wrapper found at: $(which gradle)"
    cd /workspaces/workshop-advanced-instrumentation/01-instrumented/java-year 2>/dev/null || cd /workspace/01-instrumented/java-year 2>/dev/null || cd 01-instrumented/java-year
    if [ -f gradlew ]; then
        echo "  Found gradlew in project directory"
    else
        echo "  ⚠ gradlew not found (this is OK if project isn't mounted)"
    fi
else
    echo "  ✗ Gradle wrapper not found!"
    exit 1
fi
echo ""

# Test run.sh wrapper
echo "✓ Testing run.sh wrapper..."
if which run.sh > /dev/null 2>&1; then
    echo "  Run.sh wrapper found at: $(which run.sh)"
else
    echo "  ✗ Run.sh wrapper not found!"
    exit 1
fi
echo ""

# Test Python
echo "✓ Testing Python..."
if python3 --version > /dev/null 2>&1; then
    python3 --version
else
    echo "  ⚠ Python3 not found (may need initialization)"
fi
echo ""

# Test Node.js (may need nvm initialization)
echo "✓ Testing Node.js..."
if command -v node > /dev/null 2>&1; then
    node --version
elif [ -f /usr/local/share/nvm/nvm.sh ]; then
    echo "  Node.js available via nvm (will initialize on first use)"
    source /usr/local/share/nvm/nvm.sh 2>/dev/null && node --version || echo "  ⚠ Node.js needs nvm initialization"
else
    echo "  ⚠ Node.js not found"
fi
echo ""

# Test Go
echo "✓ Testing Go..."
if go version > /dev/null 2>&1; then
    go version
else
    echo "  ⚠ Go not found (may need initialization)"
fi
echo ""

echo "=========================================="
echo "✅ Core functionality verified!"
echo "=========================================="
echo ""
echo "You can now test the workshop by running:"
echo "  cd 01-instrumented"
echo "  run.sh java-year"
echo ""
















