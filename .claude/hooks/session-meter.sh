#!/usr/bin/env bash
# PostToolUse: * — append a rough token-cost record per tool call. Never blocks.
set -uo pipefail
STATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/state"
mkdir -p "$STATE_DIR"
cat | python3 -c '
import sys, json, datetime, os
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
tool = d.get("tool_name", "?")
resp = d.get("tool_response", "")
if not isinstance(resp, str):
    resp = json.dumps(resp)
inp = json.dumps(d.get("tool_input", {}))
rec = {
    "ts": datetime.datetime.now().isoformat(timespec="seconds"),
    "tool": tool,
    "agent": os.environ.get("CLAUDE_AGENT_NAME", "main"),
    "in_tok": len(inp) // 4,
    "out_tok": len(resp) // 4,
}
path = os.path.join(sys.argv[1], "tokens.jsonl")
with open(path, "a") as f:
    f.write(json.dumps(rec) + "\n")
' "$STATE_DIR" 2>/dev/null
exit 0
