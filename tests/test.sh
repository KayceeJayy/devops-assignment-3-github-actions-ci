#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

APP="./app/app.sh"

PASS=0
FAIL=0
OUTPUT="$(mktemp)"
trap 'rm -f "$OUTPUT"' EXIT

check_exit() {
    local expected="$1"
    local description="$2"
    shift 2

    local actual=0

    "$@" >"$OUTPUT" 2>&1 || actual=$?

    if (( actual == expected )); then
        echo "PASS: $description"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $description"
        echo "Expected: $expected | Actual: $actual"
        cat "$OUTPUT"
        FAIL=$((FAIL + 1))
    fi
}

echo "===== FUNCTIONAL TESTS ====="

check_exit 0 "Help command" \
    "$APP" help

check_exit 0 "System information" \
    "$APP" system-info

check_exit 2 "Missing command" \
    "$APP"

check_exit 2 "Invalid command" \
    "$APP" invalid-command

check_exit 2 "Missing host" \
    "$APP" check-host

check_exit 0 "Valid localhost host" \
    "$APP" check-host localhost

check_exit 2 "Invalid hostname" \
    "$APP" check-host 'bad/host'

check_exit 2 "Missing TCP host and port" \
    "$APP" check-port

check_exit 2 "Missing TCP port" \
    "$APP" check-port localhost

check_exit 2 "Non-numeric TCP port" \
    "$APP" check-port localhost abc

check_exit 2 "Port zero rejected" \
    "$APP" check-port localhost 0

check_exit 2 "Port above 65535 rejected" \
    "$APP" check-port localhost 65536

check_exit 2 "Invalid TCP hostname" \
    "$APP" check-port 'bad/host' 80

check_exit 2 "Unexpected help arguments" \
    "$APP" help extra

check_exit 2 "Unexpected system arguments" \
    "$APP" system-info extra

echo
echo "===== VERIFY VALID PORT INPUT ====="

PORT_RC=0
"$APP" check-port localhost 65535 \
    >"$OUTPUT" 2>&1 || PORT_RC=$?

if (( PORT_RC == 0 || PORT_RC == 1 )); then
    echo "PASS: Valid TCP port accepted"
    PASS=$((PASS + 1))
else
    echo "FAIL: Valid TCP port rejected"
    cat "$OUTPUT"
    FAIL=$((FAIL + 1))
fi

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

(( FAIL == 0 ))
