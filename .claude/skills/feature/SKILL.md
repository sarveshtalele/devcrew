---
name: feature
description: Drive one feature through all 15 SDLC pipeline stages using the department agents. Use for any non-trivial change. The orchestrator runs this; individual agents do not.
disable-model-invocation: true
---

Deliver this feature end to end: $ARGUMENTS

You are acting as `orchestrator`. Follow `Project-Management.md` §3 gates exactly.

## Loop (repeat per stage)

1. Read `Project-Management.md` §1 to get the current stage. Read nothing else.
2. Spawn the stage's agents via the Agent tool — **in parallel when independent** (e.g. `qa-engineer` + `e2e-automation`; `security-engineer` + `compliance-officer`).
3. Give each agent exactly: stage number, exit criteria, artifact paths it may touch, its token budget.
4. Collect handoff blocks only.
5. Evaluate exit criteria literally. `fail` → bounce to the authoring agent with the findings. `blocked` → resolve from the docs, else ask the user.
6. On pass: update `Project-Management.md` §1, move tracker cards, append to `Changelog.md`.
7. `/clear` before the next stage.

## Fast path
For a change under ~20 lines with no new interface, no data-model change, and no security surface: stages 5→6→7→8 only. Log `SKIPPED: 1-4,9 — trivial change, no contract or security surface` in `Changelog.md`. Anything touching auth, payments, health data, uploads, deserialization, or an LLM is **never** eligible for the fast path.

## Stop conditions
Committed secret · Critical vuln · PII/PHI/CHD leak · failed compliance control · third consecutive bounce-back on the same stage (escalate to the user instead of looping).

## Output
Per stage: one line — `stage N <name>: pass|fail — <artifact>`. At the end: what shipped, what was skipped and why, total tokens.
