#!/usr/bin/env python3
"""Render the session token ledger written by .claude/hooks/session-meter.sh."""
import collections
import json
import os
import sys

LOG = ".claude/state/tokens.jsonl"


def main() -> int:
    if not os.path.exists(LOG):
        print("no data — run: bash .claude/hooks/install.sh")
        return 0
    by_agent: collections.Counter[str] = collections.Counter()
    by_tool: collections.Counter[str] = collections.Counter()
    total = calls = 0
    with open(LOG) as fh:
        for line in fh:
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            cost = rec.get("in_tok", 0) + rec.get("out_tok", 0)
            by_agent[rec.get("agent", "main")] += cost
            by_tool[rec.get("tool", "?")] += cost
            total += cost
            calls += 1
    if not total:
        print("no data")
        return 0
    print(f"calls={calls}  est_tokens={total:,}\n")
    print("by agent:")
    for name, cost in by_agent.most_common():
        print(f"  {name:22} {cost:>9,}  {cost / total:5.1%}")
    print("\nby tool:")
    for name, cost in by_tool.most_common(12):
        print(f"  {name:22} {cost:>9,}  {cost / total:5.1%}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
