---
name: adr
description: Write an Architecture Decision Record in MADR format. Use for any new dependency, data store, protocol, boundary, auth model, or hard-to-reverse choice.
---

Write an ADR for: $ARGUMENTS

1. Next number: `ls docs/adr | tail -1`. File: `docs/adr/ADR-<NNN>-<kebab-slug>.md` from `templates/ADR.md`.
2. State the **quality attributes** driving the decision (`Project-Context.md` §5). An architecture decision is a trade-off between NFRs; name them.
3. List **at least two real alternatives**, each with cost, risk, reversibility, and operational burden. "Do nothing" is a valid alternative and often the right one.
4. Recommend one, plainly, and say what would make you change your mind.
5. **Consequences must include the bad ones.** An ADR listing only benefits is marketing, not a record.
6. Note the compliance/data-classification impact if the decision moves PII/PHI/CHD across a boundary.
7. Use `context7` MCP for current facts about any library or service involved. Do not decide from memory.
8. Status starts `Proposed`; `security-engineer` reviews before `Accepted`.
9. Link it from `Changelog.md` and the relevant tracker card.

Keep it under 2 pages. An unread ADR is worthless.
