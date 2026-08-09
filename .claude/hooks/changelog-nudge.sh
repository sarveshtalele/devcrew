#!/usr/bin/env bash
# Stop — advisory: code changed this session but Changelog.md did not.
set -uo pipefail
cd "$(cd "$(dirname "$0")/../.." && pwd)" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
CHANGED=$(git status --porcelain -- src tests 2>/dev/null | wc -l | tr -d ' ')
LOGGED=$(git status --porcelain -- Changelog.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$CHANGED" -gt 0 ] && [ "$LOGGED" -eq 0 ]; then
  echo "CHANGELOG-NUDGE: $CHANGED changed file(s) under src/ or tests/ with no Changelog.md entry. Definition of Done requires one." >&2
fi
exit 0
