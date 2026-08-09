#!/usr/bin/env bash
# PostToolUse: Write|Edit — format + lint ONLY the changed file. Non-blocking; feedback goes to the agent.
set -uo pipefail
FILE=$(cat | python3 -c 'import sys,json; print((json.load(sys.stdin).get("tool_input") or {}).get("file_path",""))' 2>/dev/null) || exit 0
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0
OUT=""
case "$FILE" in
  *.py)
    command -v ruff >/dev/null && { ruff format "$FILE" >/dev/null 2>&1; OUT=$(ruff check "$FILE" 2>&1 | head -20); } ;;
  *.ts|*.tsx|*.js|*.jsx)
    command -v pnpm >/dev/null && { pnpm exec prettier --write "$FILE" >/dev/null 2>&1; OUT=$(pnpm exec eslint "$FILE" 2>&1 | head -20); } ;;
  *.tf)
    command -v terraform >/dev/null && terraform fmt "$FILE" >/dev/null 2>&1 ;;
esac
[ -n "$OUT" ] && echo "QUALITY-GATE ($FILE):
$OUT" >&2
exit 0
