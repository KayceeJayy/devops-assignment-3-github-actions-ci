#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "===== VALIDATING REQUIRED FILES ====="

REQUIRED=(
    README.md
    app/app.sh
    scripts/lint.sh
    scripts/build.sh
    tests/test.sh
    Dockerfile
    compose.yaml
    .dockerignore
    .github/workflows/ci.yml
)

for file in "${REQUIRED[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "FAIL: Missing $file"
        exit 1
    fi

    echo "PASS: $file"
done

echo
echo "===== CHECKING BASH SYNTAX ====="

for file in app/*.sh scripts/*.sh tests/*.sh; do
    bash -n "$file"
    echo "PASS: $file"
done

if [[ -f grade.sh ]]; then
    bash -n grade.sh
    echo "PASS: grade.sh"
fi

echo
echo "===== CHECKING EXECUTABLE PERMISSIONS ====="

for file in app/*.sh scripts/*.sh tests/*.sh; do
    test -x "$file"
    echo "PASS: Executable $file"
done

echo
echo "LINT PASSED"
