#!/usr/bin/env bash
# scripts/build.sh — builds the Docker image and runs smoke tests against it.
# Called directly by developers, and by the "docker" CI job.

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

IMAGE="devops-tool"
FAIL=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAIL=1; }

echo "----- Building image -----"
if docker build -t "$IMAGE" . ; then
    pass "image builds"
else
    fail "image build"
    exit 1
fi

echo
echo "----- Smoke tests -----"

docker run --rm "$IMAGE" help >/dev/null 2>&1
[[ $? -eq 0 ]] && pass "help" || fail "help"

docker run --rm "$IMAGE" system-info >/dev/null 2>&1
[[ $? -eq 0 ]] && pass "system-info" || fail "system-info"

docker run --rm "$IMAGE" invalid-command >/dev/null 2>&1
[[ $? -ne 0 ]] && pass "invalid command rejected" || fail "invalid command should be rejected"

if [[ $FAIL -eq 0 ]]; then
    echo
    echo "Build and smoke tests passed."
    exit 0
else
    echo
    echo "Build and smoke tests failed."
    exit 1
fi
