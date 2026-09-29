#!/usr/bin/env bash
# tests/test.sh — 8+ tests for app/app.sh. Run directly against the script,
# no Docker required (Docker smoke tests live in scripts/build.sh).

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

APP="./app/app.sh"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

expect_exit() {
    local name="$1" expected="$2"
    shift 2
    "$APP" "$@" >/dev/null 2>&1
    local rc=$?
    if [[ $rc -eq $expected ]]; then
        pass "$name (exit $rc)"
    else
        fail "$name (expected $expected, got $rc)"
    fi
}

# 1
expect_exit "help succeeds"                        0 help
# 2
expect_exit "system-info succeeds"                 0 system-info
# 3
expect_exit "no command is invalid"                2
# 4
expect_exit "unknown command is invalid"           2 bogus-command
# 5
expect_exit "check-host missing host is invalid"   2 check-host
# 6
expect_exit "check-host with localhost succeeds"   0 check-host localhost
# 7
expect_exit "check-port missing port is invalid"   2 check-port localhost
# 8
expect_exit "check-port non-numeric port is invalid" 2 check-port localhost abc
# 9
expect_exit "check-port out-of-range port (0) is invalid" 2 check-port localhost 0
# 10
expect_exit "check-port out-of-range port (65536) is invalid" 2 check-port localhost 65536

echo
echo "Passed: $PASS  Failed: $FAIL"
[[ $FAIL -eq 0 ]]
