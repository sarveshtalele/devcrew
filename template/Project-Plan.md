# Project-Plan.md

**Purpose:** what we are building, in what order, by when, and how we know it worked. `Project-Context.md` holds the *standards*; this file holds the *plan*.

**Status:** TEMPLATE. The `project-init` skill runs the intake questionnaire (§0) and rewrites §1–§7.

---

## 0. Intake questionnaire (answered at init — never skip)

The orchestrator MUST get answers to these before any PRD is written. Unanswered → assume nothing, ask.

**Product**
1. What problem, for whom, and what happens today without us?
2. What is the single success metric, and its baseline + target?
3. What is explicitly out of scope for v1?
4. Hard deadline or event we are tied to?

**Users & data**
5. Who are the user roles, and what can each do?
6. Which data classes are handled — PII / PHI / cardholder / none? *(drives which compliance regime activates)*
7. Expected scale: users, requests/sec, data volume at 12 months?
8. Any data residency constraint (EU-only, US-only)?

**Technical**
9. Greenfield or integrating with existing systems? Which contracts are fixed?
10. Cloud provider + existing accounts/orgs?
11. Auth: build, or use `{{Auth0/Cognito/Entra ID}}`?
12. Any AI/LLM component? If yes: which model, what data reaches the prompt?

**Delivery**
13. Team size and which departments are actually staffed?
14. Sprint length and release cadence?
15. Environments available (dev/staging/prod)? Who approves prod?
16. Budget ceiling — infra and model spend?

**Decisions already fixed by this template** (change only via ADR):
Compliance bar SOC 2 + GDPR + HIPAA + PCI DSS + OWASP ASVS L2 + OWASP LLM Top 10 · Stack Python/FastAPI + React/TS · Tracker Markdown Kanban+Scrum · Design Modern-SaaS-vibrant, light+dark, WCAG 2.2 AA, Inter + Tailwind + shadcn/ui · A11y testing axe-core + keyboard + 3 viewports · Token governance hard hook gates.

---

## 1. Vision & OKRs

**Vision:** `{{one paragraph}}`

| Objective | Key result | Baseline | Target | Owner |
|---|---|---|---|---|
| O1 `{{}}` | KR1.1 `{{}}` | `{{}}` | `{{}}` | product-manager |
| | KR1.2 `{{}}` | | | |

## 2. Scope

**In v1:** `{{}}`
**Explicitly out:** `{{}}`
**Assumptions:** `{{}}`
**Constraints:** `{{}}`

## 3. Milestones

| # | Milestone | Exit criteria | Target date | Status |
|---|---|---|---|---|
| M0 | Discovery complete | PRD approved, ADR-001 merged, threat model drafted | `{{}}` | ⬜ |
| M1 | Walking skeleton | one journey end-to-end through CI to staging | `{{}}` | ⬜ |
| M2 | Feature complete | all v1 stories Done, NFR budget met | `{{}}` | ⬜ |
| M3 | Hardened | pen-test findings closed, compliance evidence collected | `{{}}` | ⬜ |
| M4 | GA | prod deploy, SLOs live, runbooks published | `{{}}` | ⬜ |

## 4. Epic → story map

| Epic | Stories | Dept owners | Priority (RICE) | Milestone |
|---|---|---|---|---|
| `{{EP-1}}` | `{{US-1..n}}` | product-manager → architect → backend/frontend → qa | `{{}}` | M1 |

Requirement IDs are `REQ-###` (IEEE 29148) and MUST trace: `REQ-### → US-### → test ID → tracker card`. The traceability matrix lives in `docs/prd/traceability.md`.

## 5. Sprint cadence

- Sprint length `{{2}}` weeks. Planning Mon · daily async standup via `/standup` · review + retro last Fri.
- WIP limit per department: **3** cards In Progress. Exceeding it blocks pulling new work.
- Story points: Fibonacci 1/2/3/5/8. An 8 must be split before it enters Ready.
- Capacity reserved each sprint: **20% security + tech debt**, non-negotiable.

## 6. Risk register

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R1 | Compliance scope creep (4 regimes active) | M | H | Scope down per-regime at init via ADR; only activate what the data classes require | compliance-officer |
| R2 | LLM prompt injection via user content | M | H | Untrusted-data framing, output schema validation, scoped tool identity | security-engineer |
| R3 | E2E suite flakiness stalls CI | M | M | Role-based locators only, zero fixed waits, quarantine lane with a 5-day fix SLA | e2e-automation |
| R4 | Agent context exhaustion → rework | H | M | Hook-enforced token budgets, subagent delegation, `/clear` per stage | orchestrator |
| R5 | `{{}}` | | | | |

## 7. Metrics review (per sprint)

| Sprint | Deploy freq | Lead time | CFR | MTTR | Escaped defects | Coverage | Token spend | Error budget left |
|---|---|---|---|---|---|---|---|---|
| S1 | | | | | | | | |

## 8. Release plan

Trunk → CI green → auto-deploy staging → UAT sign-off by product-manager → manual approval → canary 10% → full prod → 24h watch. Rollback = revert the merge commit or flip the feature flag; whichever is faster, decided **before** deploy and written in the PR.
