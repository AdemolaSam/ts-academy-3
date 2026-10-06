#!/bin/bash

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

FAIL=0

REQUIRED_FILES=(
    "README.md"
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "Dockerfile"
    "compose.yaml"
    ".dockerignore"
    ".github/workflows/ci.yml"
)

echo "----- Checking required files -----"
for f in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        echo "OK   : $f"
    else
        echo "MISSING: $f"
        FAIL=1
    fi
done

echo
echo "----- Checking Bash syntax -----"
for f in app/*.sh scripts/*.sh tests/*.sh; do
    [[ -f "$f" ]] || continue
    if bash -n "$f" 2>/dev/null; then
        echo "OK   : $f"
    else
        echo "SYNTAX ERROR: $f"
        FAIL=1
    fi
done

if command -v shellcheck >/dev/null 2>&1; then
    echo
    echo "----- ShellCheck (informational) -----"
    for f in app/*.sh scripts/*.sh tests/*.sh; do
        [[ -f "$f" ]] || continue
        shellcheck "$f" || true
    done
fi

if [[ $FAIL -eq 0 ]]; then
    echo
    echo "Lint passed."
    exit 0
else
    echo
    echo "Lint failed."
    exit 1
fi
