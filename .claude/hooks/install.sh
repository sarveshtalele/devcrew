#!/usr/bin/env bash
# Make hooks executable and verify prerequisites.
set -euo pipefail
cd "$(dirname "$0")"
chmod +x ./*.sh
mkdir -p ../state
echo "hooks installed:"; ls -1 *.sh
command -v python3 >/dev/null || echo "WARN: python3 missing — token-guard/secret-guard will no-op"
command -v ruff    >/dev/null || echo "note: ruff not installed (quality-gate skips python)"
command -v pnpm    >/dev/null || echo "note: pnpm not installed (quality-gate skips ts)"
