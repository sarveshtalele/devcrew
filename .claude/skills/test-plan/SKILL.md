---
name: test-plan
description: Build an IEEE 29119 test plan for an epic and split it into concrete unit, integration, and E2E tasks. Use at the start of stage 7, or during stage 4 to define test hooks early.
---

Test plan for: $ARGUMENTS

Output `docs/design/test-plan-<epic>.md` from `templates/test-plan.md`.

0. **Method.** Follow `User-Story-Testing.md` — story format, Given/When/Then criteria, level assignment, naming, and the Definition of Ready/Done checklists.
1. **Trace first.** Every `REQ-###` gets at least one test ID. A requirement with no test is not a requirement, it is a hope. Update `docs/prd/traceability.md`.
2. **Assign the level** (ISTQB) per requirement — unit / integration / system(E2E). Push tests down: if it can be a unit test, it must not be an E2E test.
3. **Unit** (`qa-engineer`): boundaries — empty, one, many, max, max+1, null, wrong type, unicode, negative, zero, duplicate, concurrent, expired, unauthorized, malformed. ≥85% of changed lines.
4. **Integration** (`qa-engineer`): real Postgres/Redis via testcontainers, real HTTP layer. Never mock the thing under test.
5. **E2E** (`e2e-automation`): journeys only, plus one failure path. Role-based locators, zero fixed waits, self-seeded data.
6. **A11y**: axe scan per page state, keyboard journey with visible focus and focus trapping, at 375/768/1280. Zero violations.
7. **Security cases**: authz bypass as another user, injection payloads, oversized input, missing/invalid auth, rate limit, and assertions that PII/PHI/CHD appear in **neither** logs nor error bodies.
8. **Exit criteria**: coverage met, zero flakes in 3 consecutive runs, all Critical/High defects closed.
9. File each item as a card in `trackers/qa.md` or `trackers/e2e.md`.
