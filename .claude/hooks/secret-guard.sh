#!/usr/bin/env bash
# PreToolUse: Write|Edit — blocks secrets and unauthorized edits to protected paths.
set -uo pipefail
INPUT=$(cat)
deny () { echo "SECRET-GUARD: $1" >&2; exit 2; }

PAYLOAD=$(printf '%s' "$INPUT" | python3 -c '
import sys, json
d = json.load(sys.stdin)
i = d.get("tool_input", {}) or {}
print(i.get("file_path", ""))
print(i.get("content", "") or i.get("new_string", ""))
' 2>/dev/null) || exit 0
FILE=$(printf '%s' "$PAYLOAD" | head -1)
BODY=$(printf '%s' "$PAYLOAD" | tail -n +2)

case "$FILE" in
  *.env|*.env.*|*/id_rsa|*.pem|*.p12|*.pfx|*.keystore)
    case "$FILE" in *.env.example|*.env.template) : ;; *) deny "Refusing to write $FILE. Secrets live in the secret manager, never in the repo (Project-Context.md §4.4)." ;; esac ;;
esac

case "$FILE" in
  */migrations/*|*/infra/prod/*|*/.github/workflows/*)
    [ "${CLAUDE_ALLOW_PROTECTED:-0}" = "1" ] || deny "$FILE is a protected path (migrations / prod infra / CI). Set CLAUDE_ALLOW_PROTECTED=1 for this session only with an explicit ticket reference." ;;
esac

if printf '%s' "$BODY" | grep -qiE '(aws_secret_access_key|private[_-]?key|BEGIN [A-Z ]*PRIVATE KEY|xox[baprs]-|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16})'; then
  deny "Credential-shaped content detected in the write. Use an env var sourced from the secret manager."
fi
if printf '%s' "$BODY" | grep -qiE '(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'{$][^"'"'"']{7,}'; then
  deny "Hardcoded credential literal detected. Read it from the environment instead (CLAUDE.md Security)."
fi
exit 0
