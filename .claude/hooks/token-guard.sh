#!/usr/bin/env bash
# PreToolUse: Read|Grep|Bash — blocks context-blowout patterns.
# Exit 2 = block, stderr is returned to the agent as feedback.
set -uo pipefail
# Ceiling is profile-driven: 800 under "normal", 600 under "optimized".
READ_LIMIT="${DEVCREW_READ_LIMIT:-800}"
INPUT=$(cat)

deny () { echo "TOKEN-GUARD: $1" >&2; exit 2; }

read -r TOOL FILE PATTERN GPATH LIMIT CMD <<<"$(printf '%s' "$INPUT" | python3 -c '
import sys, json
d = json.load(sys.stdin)
t = d.get("tool_name", "")
i = d.get("tool_input", {}) or {}
def g(k):
    v = i.get(k)
    return str(v).replace(" ", "\x01") if v not in (None, "") else "-"
print(t or "-", g("file_path"), g("pattern"), g("path"), g("limit"), g("command"))
' 2>/dev/null)" || exit 0
CMD=${CMD//$'\x01'/ }
FILE=${FILE//$'\x01'/ }

case "$TOOL" in
  Read)
    [ "$FILE" = "-" ] && exit 0
    [ -f "$FILE" ] || exit 0
    LINES=$(wc -l < "$FILE" | tr -d ' ')
    if [ "$LINES" -gt "$READ_LIMIT" ] && [ "$LIMIT" = "-" ]; then
      deny "$FILE is $LINES lines. Use offset/limit, or delegate to a subagent. Unbounded reads over $READ_LIMIT lines are blocked (CLAUDE.md token discipline #2)."
    fi
    ;;
  Grep)
    if [ "$GPATH" = "-" ] && [ "${#PATTERN}" -lt 4 ]; then
      deny "Tree-wide Grep with a <4-char pattern is blocked. Scope it with 'path', or delegate the search to a subagent (CLAUDE.md token discipline #1)."
    fi
    ;;
  Bash)
    case "$CMD" in
      *"grep -r"*|*"rg "*)
        case "$CMD" in
          *" -l"*|*"--files-with-matches"*|*"| head"*|*"|head"*) : ;;
          *) case "$CMD" in
               *"grep -r "*/*|*"rg "*/*) : ;;
               *) deny "Unscoped recursive search. Add a path, pipe to head, or use -l. Raw recursive greps flood context." ;;
             esac ;;
        esac ;;
    esac
    case "$CMD" in
      "cat "*|*" cat "*)
        case "$CMD" in *"| "*|*">"*|*"<<"*) : ;; *) deny "Use the Read tool with offset/limit instead of cat (CLAUDE.md harness rules)." ;; esac ;;
    esac
    case "$CMD" in
      "find / "*|"find /"*|*" find / "*) deny "Filesystem-wide find is blocked. Scope to the project directory." ;;
    esac
    ;;
esac
exit 0
