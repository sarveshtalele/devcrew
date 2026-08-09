# Example — one user story, end to end

A complete walkthrough of a single story moving through all 15 pipeline stages, with the real artifacts produced at each one. Nothing here is aspirational: every file, gate, and command is what the kit actually does.

**The story:** a workspace admin needs to revoke a departing employee's access immediately.
**Mode:** `secure` (11 agents) — the product handles PII and authentication.
**Elapsed:** roughly one working day of agent time, spread across seven sessions.

---

## Setup

```bash
devcrew init acme-workspace --mode secure
cd acme-workspace
devcrew doctor
```

In the agent:

```
/project-init
```

Intake answers that shape everything downstream: B2B SaaS, workspace-scoped RBAC, **PII yes / PHI no / cardholder no**, AWS, 2-week sprints, prod approved by the tech lead.

`compliance-officer` activates **SOC 2 + GDPR** and records the scope-down:

> `docs/adr/ADR-001-compliance-scope.md` — HIPAA and PCI DSS out of scope: no health data is processed and payments are handled entirely by Stripe Checkout, so no cardholder data touches our systems. Revisit if either changes.

Then:

```
/feature instant-revoke
```

The orchestrator takes over.

---

## Stage 1 — Product requirement

**Owner:** `product-manager`

> **Problem.** When an employee leaves, admins remove them from the workspace and assume access ends. It doesn't — the existing session stays valid until it expires, up to 30 days. Three customers have raised it; one is a security-review blocker.
>
> **Success metric.** Time-to-revocation p95 under 5 seconds. Baseline: up to 30 days.
>
> **Non-goals.** SCIM provisioning. Bulk revocation. Device-level remote wipe.

Written into `Project-Plan.md` §1–2.

---

## Stage 2 — PRD and user stories

**Owners:** `product-manager` + `ux-designer`

`docs/prd/PRD-access-control.md`:

| ID | Requirement | Priority | Acceptance criterion |
|---|---|---|---|
| REQ-041 | A workspace admin can revoke a member's access | MUST | Given an active member, when the admin revokes them, then they are removed from the member list |
| REQ-042 | Revocation invalidates existing sessions within 5 seconds | MUST | Given a member with an active session, when revoked, then any request with that session returns 401 within 5s |
| REQ-043 | Every revocation is recorded in the audit log | MUST | Given a revocation, then an event `member.revoked` exists with actor, target, and timestamp |

**Story US-014** with four acceptance criteria — the happy path, a member attempting to revoke someone (403), a cross-tenant attempt (404), and idempotence. Written in Given/When/Then per [`User-Story-Testing.md`](template/User-Story-Testing.md) §3.

**Data classes:** PII — member email and name. This is the flag that keeps GDPR controls alive through the rest of the pipeline.

`ux-designer` specs the member-list row: destructive action behind a confirmation naming the person, an optimistic removal with rollback on failure, and an empty state for a workspace of one.

---

## Stage 3 — Architecture and ADR

**Owner:** `architect`

The real decision is how a stateless JWT gets invalidated before it expires.

`docs/adr/ADR-014-session-revocation.md`:

| Option | Cost | Risk | Reversibility | Verdict |
|---|---|---|---|---|
| **Redis denylist keyed by session ID, TTL = token lifetime** | low | Redis becomes an auth dependency | high | **chosen** |
| Short-lived tokens (5 min) + refresh | medium | refresh traffic ×20, latency on every call | medium | rejected — cost is permanent, benefit is rare |
| Stateful sessions in Postgres | high | a DB read on every request | low | rejected — throws away the reason we chose JWTs |

**Consequences, including the bad ones:** auth now fails closed if Redis is unavailable, which is a new availability dependency on the login path. Mitigated with a local LRU cache of denylist entries and an SLO alarm. Recorded, not glossed over.

---

## Stage 4 — Technical design

**Owner:** `tech-lead`

`docs/design/TD-instant-revoke.md`:

```
DELETE /v1/workspaces/{workspace_id}/members/{member_id}
  200 → { "revoked_at": "2026-08-09T10:04:11Z" }
  403 → problem+json, type=/errors/insufficient-role      (actor is not an admin)
  404 → problem+json, type=/errors/member-not-found       (also returned cross-tenant — no existence leak)
  409 → problem+json, type=/errors/cannot-revoke-self
```

- **Data model:** `audit_events` gains `actor_id`, `target_id`, `event_type`. `target_email` is annotated `pii: True` so the log redactor and retention job find it.
- **Denylist:** `revoked:{session_id} → 1`, TTL equal to the remaining token lifetime.
- **NFR allocation:** of the 300ms p95 budget, 40ms for the denylist check, 60ms for the write, 200ms headroom.
- **Test hooks:** the clock is injectable, the Redis client is swappable for a fake, and audit events are queryable in tests.
- **Tasks:** BE-101 endpoint + authz (3), BE-102 denylist + middleware (3), BE-103 audit event (2), FE-201 member row + confirm dialog (3), FE-202 optimistic update + rollback (2).
- **Flag:** `feat_instant_revoke`, removed once revocation p95 holds under 5s for two weeks.

---

## Threat model — before any code

```
/threat-model instant-revoke
```

**Owner:** `security-engineer`. `docs/design/threat-model-instant-revoke.md`, STRIDE across the boundaries. Two findings that mattered:

| # | Threat | Exploit path | Mitigation | Verifying test |
|---|---|---|---|---|
| T1 | Elevation of privilege | `member_id` is taken from the path and looked up globally. An admin of workspace A passes a member ID from workspace B and revokes them. | Scope every lookup by `workspace_id`; return 404, never 403, so existence doesn't leak | AC-014-3 |
| T2 | Denial of service | Unbounded revocation calls fill Redis with denylist keys | Rate limit per admin; TTL bounded by token lifetime | `test_revoke_rate_limited` |

Both filed as blocking cards in `trackers/security.md` **before** stage 5 opens. This is the whole point of the ordering: T1 costs five minutes to prevent here and a disclosure notice to fix in production.

---

## Stage 5 — Development

**Owners:** `backend-engineer`, `frontend-engineer` (parallel)

Backend implements BE-101–103 from the design. Two gates fire during the session:

```
SECRET-GUARD: Hardcoded credential literal detected. Read it from the environment instead.
```

A Redis URL with an inline password had been pasted into `settings.py`. Blocked at the write, not at review.

```
QUALITY-GATE (src/workspaces/revoke.py):
  src/workspaces/revoke.py:42: error: Argument 1 has incompatible type "str | None"; expected "str"
```

Caught immediately after the edit, roughly 200 tokens — the same error found by CI would have cost a full pipeline run.

Frontend builds the member row from `Design.md` tokens: `button.destructive` for the action, `dialog` for the confirmation naming the person, skeleton row while pending, `aria-live` announcement on completion.

---

## Stage 6 — Code review

**Owner:** `code-reviewer`, fresh context, sees only the diff.

> **CRITICAL — `src/workspaces/revoke.py:58`**
> The denylist write and the audit-event insert are not in the same transaction. If the process dies between them, the session is dead with no audit record — a revocation that cannot be proven, which fails the SOC 2 audit control this story exists to satisfy.
> **Failing case:** kill the worker after the Redis write; `audit_events` has no row; the member is revoked with no trace.
> **Fix:** write the audit event first inside the DB transaction, then the denylist; on denylist failure, roll back and return 503.

> **HIGH — `tests/unit/test_revoke.py:31`**
> `test_ac_014_4_revoke_is_idempotent` passes with the implementation reverted. It asserts a 200 that the route returns regardless. Assert exactly one audit event exists.

Bounced to `backend-engineer`. Both fixed, re-reviewed, passed. Neither would have been found by the agent that wrote the code — that is what the fresh context buys.

---

## Stage 7 — Automated tests

**Owners:** `qa-engineer` + `e2e-automation` (parallel)

Per [`User-Story-Testing.md`](template/User-Story-Testing.md), each criterion runs at the cheapest level that can honestly verify it:

| Criterion | Level | Test |
|---|---|---|
| AC-014-1 removal | unit + integration | `test_ac_014_1_revoke_removes_member`, `test_ac_014_1_session_invalidated` |
| AC-014-2 member cannot revoke | integration | `test_ac_014_2_member_gets_403` |
| AC-014-3 cross-tenant | integration | `test_ac_014_3_cross_tenant_returns_404` |
| AC-014-4 idempotence | unit | `test_ac_014_4_revoke_is_idempotent` |
| Journey | E2E | `AC-014-1: admin revokes a member` |

```bash
$ make test
94 passed in 6.21s
changed-line coverage: 91%

$ make e2e
  3 passed (375px) · 3 passed (768px) · 3 passed (1280px)
  axe: 0 violations · keyboard journey: pass
```

The E2E suite ran three times consecutively with no flakes before the card moved. `docs/prd/traceability.md` updated in the same PR.

---

## Stage 8 — CI

**Owner:** `devops-engineer`. `lint → test → build → SCA/secrets/SAST → e2e → SBOM`, green in 4m12s. CycloneDX SBOM attached to the build.

---

## Stage 9 — Security and compliance

**Owners:** `security-engineer` + `compliance-officer` (parallel)

`security-engineer`: both threat-model findings closed with the tests that prove them; semgrep, bandit, pip-audit, gitleaks all zero Critical/High; confirmed no email address appears in any log line or error body.

`compliance-officer`, walking only the active regimes:

| Regime | Control | Evidence |
|---|---|---|
| SOC 2 | Change management | PR #482, two approvals, CI run 1194 |
| SOC 2 | Access control — revocation is enforced and logged | `audit_events` schema, AC-014-1 test |
| GDPR | Art. 17 erasure support unaffected | revocation removes access; deletion remains a separate flow |
| GDPR | Data minimization | audit event stores member ID and email only — no name, no IP |

Appended to `docs/compliance/evidence-log.md`. Missing evidence would have been a fail even with the control working.

---

## Stage 10 — Staging

**Owners:** `devops-engineer` + `release-manager`. Deployed behind `feat_instant_revoke=off`. Migration applied and rolled back once to prove reversibility. Smoke suite green. Synthetic data only — no production PII in staging, ever.

---

## Stage 11 — UAT

**Owner:** `product-manager`. Flag on for the internal workspace. All four criteria demonstrated live; measured revocation at 1.8s p95 against a 5s target. Sign-off recorded in `Changelog.md`.

---

## Stage 12 — Production

**Owner:** `release-manager`

```bash
devcrew verify
```

```
✓ secrets (gitleaks)
✓ authorship (no AI attribution)
✓ lint + types
✓ unit + integration tests
✓ SAST + SCA
✓ E2E + a11y

All checks passed. Push is unblocked until src/ or tests/ changes again.
```

```bash
git push
```

Change record `CR-031` filed: rollback = flag flip, ~10 seconds, triggered if auth error rate exceeds 2× baseline for 5 minutes. Canary 10% → 15 minutes of watching → 50% → 100%. Deploy and release stayed separate events: the code shipped dark, the flag turned it on.

---

## Stage 13 — Monitoring

**Owner:** `sre-observability`. Live **before** the flag flip:

- SLI `revocation_latency_seconds` with a 5s objective, and `auth_denylist_errors_total`
- RED dashboard for the endpoint; USE for Redis
- Burn-rate alerts, 2%/1h fast and 5%/6h slow, each linked to `docs/design/runbook-auth.md`
- A test asserting no email address appears in any span attribute — telemetry is the most common PII leak path

---

## Stage 14 — Feedback and metrics

**Owner:** `product-manager` + `sre-observability`

| Metric | Before | After |
|---|---|---|
| Time to revocation (p95) | up to 30 days | **1.8s** |
| Support tickets on stale access | 3/month | 0 |
| Change failure rate | 8% | 8% |
| Lead time for this story | — | 1.1 days |

---

## Stage 15 — Next iteration

**Owner:** `orchestrator`. Retro actions filed as cards: the Redis dependency on the login path needs a documented degradation mode (SRE), and bulk revocation — deliberately out of scope here — moves to the backlog with a RICE score.

Flag `feat_instant_revoke` scheduled for removal in two weeks, with a card so it doesn't become permanent debt.

---

## What the process actually caught

Worth being concrete, because the value of ceremony is only visible in what it prevents:

| Stage | Caught | Cost if it had shipped |
|---|---|---|
| Threat model | Cross-tenant revocation (T1) | Any admin revoking any user in any workspace — a disclosure event |
| Code review | Non-transactional audit write | Unprovable revocations, failed SOC 2 control |
| Code review | A test that passed with the code reverted | False confidence in the exact criterion the story existed for |
| secret-guard | Redis password in source | A secret in git history, rotation, incident write-up |
| quality-gate | Type error, in-session | One CI cycle |
| ADR | New availability dependency on Redis | Discovered during an outage instead of on paper |

Six defects, none of which reached production. Total tooling spend: **$0**.

---

## Token spend

```bash
$ devcrew tokens
calls=312  est_tokens=486,200

by agent:
  backend-engineer        118,400   24.4%
  frontend-engineer        94,100   19.4%
  code-reviewer            61,300   12.6%
  security-engineer        52,800   10.9%
  qa-engineer              48,900   10.1%
  e2e-automation           41,200    8.5%
  architect                28,700    5.9%
  orchestrator             18,900    3.9%
  ...
```

The orchestrator sat at 3.9% across fifteen stages — that is the handoff-block contract doing its job. With caveman and rtk installed, the same run measured roughly 40% lower than an unstructured session that re-read the same files on every turn.

---

## Try it

```bash
devcrew init demo --mode secure
cd demo
```

Then, in your agent:

```
/project-init
/feature <your first story>
```
