---
name: token-report
allowed-tools: Bash(python3 *), Read, Edit
description: Report token consumption for this session and project, per agent and per tool, from the session-meter hook log. Use to find context waste and check budget compliance.
---

Render the token ledger.

Run this — do not read the log file into context, that would defeat the purpose:

```bash
python3 - <<'PY'
import json, collections, os
p = ".claude/state/tokens.jsonl"
if not os.path.exists(p):
    print("no data — is session-meter.sh installed? run: bash .claude/hooks/install.sh"); raise SystemExit
by_agent, by_tool, total = collections.Counter(), collections.Counter(), 0
n = 0
for line in open(p):
    try: r = json.loads(line)
    except Exception: continue
    t = r["in_tok"] + r["out_tok"]
    by_agent[r.get("agent","main")] += t; by_tool[r["tool"]] += t; total += t; n += 1
print(f"calls={n}  est_tokens={total:,}")
print("\nby agent:");  [print(f"  {k:22} {v:>9,}  {v/total:5.1%}") for k, v in by_agent.most_common()]
print("\nby tool:");   [print(f"  {k:22} {v:>9,}  {v/total:5.1%}") for k, v in by_tool.most_common(12)]
PY
```

Then, in **three lines**:
1. Which agent or tool dominates, and whether it exceeded its `Project-Management.md` §4 budget.
2. The single biggest waste pattern (usual suspects: unbounded `Read`, tree-wide `Grep`, re-reading an edited file, exploration that should have been a subagent).
3. One concrete fix — a tighter hook rule, a new Makefile target, or a script that replaces reasoning over file contents.

Write the totals into `trackers/00-program-board.md` token ledger. Do not paste the raw log.
