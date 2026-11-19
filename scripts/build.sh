#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

IMAGE="${DEVOPS_IMAGE:-devops-tool:local}"

echo "===== BUILD DOCKER IMAGE ====="

docker build -t "$IMAGE" .

echo
echo "===== DOCKER HELP SMOKE TEST ====="
docker run --rm "$IMAGE" help

echo
echo "===== DOCKER SYSTEM SMOKE TEST ====="
docker run --rm "$IMAGE" system-info

echo
echo "===== DOCKER INVALID COMMAND TEST ====="

rc=0
docker run --rm "$IMAGE" invalid-command \
    >/dev/null 2>&1 || rc=$?

if (( rc != 2 )); then
    echo "FAIL: Invalid command returned $rc, expected 2"
    exit 1
fi

echo "PASS: Invalid command returned exit 2"

echo
echo "===== VERIFY COMPOSE CONFIGURATION ====="
docker compose config --quiet

echo
echo "DOCKER BUILD AND SMOKE TESTS PASSED"
