#!/usr/bin/env bash
# PreToolUse: Bash — nothing leaves the machine unverified, and nothing credits an AI as an author.
#   1. blocks `git push` / `gh pr create` unless `devcrew verify` passed AFTER the last source change
#   2. blocks bypass flags (--no-verify, --force on shared branches)
#   3. blocks AI attribution trailers in commit messages
# Exit 2 = block; stderr is returned to the agent.
set -uo pipefail
INPUT=$(cat)
deny () { echo "PUSH-GUARD: $1" >&2; exit 2; }

CMD=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print((json.load(sys.stdin).get("tool_input") or {}).get("command",""))' 2>/dev/null) || exit 0
[ -n "$CMD" ] || exit 0

# --- 1. AI attribution is never committed -------------------------------------
# Only inspect commands that actually author something. Scanning every Bash call
# would block `grep 'Co-Authored-By'`, tests, and docs work that legitimately
# names the forbidden string.
case "$CMD" in
  *"git commit"*|*"git tag"*|*"gh pr create"*|*"gh pr edit"*|*"gh release create"*)
    case "$CMD" in
      *"Co-Authored-By: Claude"*|*"Co-authored-by: Claude"*|*"Generated with [Claude Code]"*|*"Co-Authored-By: Anthropic"*)
        deny "AI attribution trailer detected. This project never credits an AI as an author or co-author. Remove the trailer and try again." ;;
    esac ;;
esac

# --- 2. no bypassing the local gates ------------------------------------------
# Scoped to real git invocations: a command that merely *mentions* these strings
# (a grep, a test fixture, a doc edit) is data, not an attempt to bypass a gate.
case "$CMD" in
  git\ *|*"; git "*|*"&& git "*|*"| git "*|gh\ *|*"&& gh "*)
    case "$CMD" in
      *"--no-verify"*) deny "--no-verify is forbidden. The pre-commit and pre-push gates are the security control; bypassing them defeats it." ;;
    esac
    case "$CMD" in
      *"push --force"*|*"push -f "*|*"push --force-with-lease"*)
        case "$CMD" in
          *" main"*|*" master"*|*" develop"*|*"push --force origin"*|*"push -f origin"*)
            deny "Force-push to a shared branch is forbidden. Open a PR instead." ;;
        esac ;;
    esac ;;
esac

# --- 3. verification must be fresher than the code ----------------------------
case "$CMD" in
  *"git push"*|*"gh pr create"*|*"gh pr merge"*)
    ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
    STAMP="$ROOT/.devcrew/verify-ok"
    [ -f "$STAMP" ] || deny "No successful verification on record. Run \`devcrew verify\` (secrets scan + lint + tests + security) and push only after it passes."
    NEWEST=$(find "$ROOT/src" "$ROOT/tests" -type f -newer "$STAMP" 2>/dev/null | head -1)
    [ -z "$NEWEST" ] || deny "Source changed after the last successful verification ($(basename "$NEWEST") is newer). Re-run \`devcrew verify\` before pushing."
    ;;
esac
exit 0
