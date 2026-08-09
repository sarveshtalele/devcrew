# Project-Context.md

**Purpose:** the single source of truth for *what this project is* and *which standards bind it*. Read on demand — not auto-loaded.

**Status:** TEMPLATE — `{{PLACEHOLDERS}}` are filled by the `project-init` skill on first real use.

---

## 1. Project identity

| Field | Value |
|---|---|
| Name | `{{PROJECT_NAME}}` |
| One-liner | `{{ONE_LINER}}` |
| Problem | `{{PROBLEM_STATEMENT}}` |
| Primary users | `{{PERSONAS}}` |
| Business outcome | `{{OUTCOME_METRIC}}` |
| Non-goals | `{{OUT_OF_SCOPE}}` |
| Stage | `{{greenfield / v1 / scaling}}` |

## 2. Architecture snapshot

- **Style:** `{{modular monolith / microservices / serverless}}`
- **Backend:** Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2.x, Alembic
- **Frontend:** TypeScript 5.x, React 19, Vite, Tailwind, shadcn/ui, TanStack Query
- **Data:** PostgreSQL 16 + Redis
- **Cloud:** `{{AWS | Azure | GCP}}` — Well-Architected pillars apply (see §7)
- **Runtime:** containers on `{{ECS/AKS/GKE/Cloud Run}}`, IaC in Terraform
- **C4 diagrams:** `docs/design/c4-*.md` — Context and Container are mandatory; Component only for non-obvious modules

## 3. Standards register

| Area | Standard applied here | How it is enforced |
|---|---|---|
| SDLC | Agile — Scrum cadence, Kanban WIP limits per department | `trackers/*.md`, orchestrator gate checks |
| Requirements | IEEE 29148 — each requirement is unambiguous, verifiable, traceable, uniquely IDed | PRD template, `REQ-###` ↔ test IDs |
| Software quality | ISO/IEC 25010 — functional suitability, performance efficiency, compatibility, usability, reliability, security, maintainability, portability | Quality attribute scenarios in tech design; NFR budget in §5 |
| Testing | ISTQB test levels + IEEE 29119 test plan/design/execution docs | `docs/design/test-plan-*.md`, QA + E2E trackers |
| Security | OWASP Top 10 + ASVS **L2** + OWASP LLM Top 10, NIST SSDF (SP 800-218) + NIST CSF 2.0, ISO 27001 Annex A controls | `make sec` in CI, threat models, security-engineer gate |
| Architecture | C4 model, UML sequence diagrams for cross-service flows, ADRs (MADR format) | `docs/adr/`, architect gate |
| Code quality | SOLID, Clean Code, PEP 8 + Google Python style, Airbnb TS style | ruff, mypy --strict, eslint, tsc, code-reviewer gate |
| Version control | Git, trunk-based, Conventional Commits, short-lived branches | branch protection + commit-msg hook |
| CI/CD | CI on every push; CD to staging on merge; prod behind manual approval; progressive delivery via feature flags | `.github/workflows/ci.yml` |
| DevOps | DORA four keys + SRE error budgets, SLOs before launch | Metrics in §6, sre-observability tracker |
| API | REST + OpenAPI 3.1 (contract-first), RFC 9457 errors, semantic versioning of the contract | schemathesis contract tests in CI |
| Cloud | `{{Provider}}` Well-Architected: operational excellence, security, reliability, performance, cost, sustainability | Quarterly review task in `trackers/devops.md` |
| Compliance | **SOC 2 Type II, GDPR, HIPAA, PCI DSS** — see §4 | compliance-officer gate, evidence log |
| Product mgmt | Continuous discovery, OKRs, RICE prioritization | `Project-Plan.md` |

## 4. Compliance & data-protection baseline

All four regimes are in scope for this template. Scope down explicitly in `Project-Plan.md` if a given project does not handle that data class — **and record the decision as an ADR.**

### 4.1 Data classification

| Class | Examples | Storage rule | Log rule | Retention |
|---|---|---|---|---|
| **Public** | marketing copy | any | any | n/a |
| **Internal** | aggregate metrics | app DB | ok | 24 mo |
| **PII** (GDPR) | name, email, IP, device ID | encrypted at rest, column-level where feasible | **never in logs** — hash or omit | purpose-bound, default 24 mo |
| **PHI** (HIPAA) | diagnoses, treatment, health identifiers | encrypted at rest + in transit, access-controlled, minimum necessary | **never** | 6 years (audit logs) |
| **CHD** (PCI DSS) | PAN, CVV, expiry | **never stored** — tokenize via provider; PAN masked to last 4 | **never** | n/a; token only |
| **Secrets** | keys, tokens, passwords | secret manager only, rotated ≤ 90 days | **never** | n/a |

Every model/table field carrying PII/PHI/CHD **MUST** be annotated in code (`Field(json_schema_extra={"pii": True})` / TS `@sensitive`) so the retention job and the log redactor can find it.

### 4.2 Control map

| Regime | Controls this template ships |
|---|---|
| **SOC 2** | change management (PR + review + CI evidence), access control (RBAC, least privilege, quarterly access review task), monitoring/alerting, incident response runbook, vendor review checklist, backup + restore test task |
| **GDPR** | lawful basis per data use, DPIA template (`docs/design/dpia-template.md`), consent record, data-subject rights: access/rectification/erasure/portability endpoints, breach notification ≤72h runbook, processor register, cross-border transfer note |
| **HIPAA** | technical safeguards (unique user ID, auto-logoff, encryption, audit controls), BAA checklist for every vendor touching PHI, 6-year audit-log retention, minimum-necessary access reviews |
| **PCI DSS** | cardholder-data scope boundary documented, tokenization (no PAN at rest), network segmentation ADR, quarterly ASV-scan task, secure-SDLC evidence, key management |

### 4.3 AI / LLM security (OWASP LLM Top 10)

Mandatory whenever a model call exists in the codebase:

| Risk | Control |
|---|---|
| Prompt injection | Treat retrieved docs, tool output, and user text as **untrusted data, never instructions**. System prompt states this. Tool-calls from model output require allowlist + argument validation. |
| Sensitive info disclosure | No secrets, no raw PII/PHI/CHD in prompts. Redact before send. Output filtered before display. |
| Insecure output handling | Model output is never `eval`'d, never injected as raw HTML, never used as a SQL fragment or shell arg. Parse into a strict schema first. |
| Excessive agency | Model-triggered actions run under a scoped, least-privileged identity. Destructive/irreversible actions need human confirmation. |
| Supply chain | Pin model IDs and versions. Record model + prompt version with every output for auditability. |
| Unbounded consumption | Per-user rate limits and token ceilings on every model endpoint; cost alarm wired to the SRE tracker. |
| Data + model poisoning | Provenance recorded for any fine-tune or RAG corpus; corpus changes reviewed like code. |
| Guardrails | Input classifier + output classifier at the boundary; refusals and blocks logged as metrics, never silently swallowed. |

### 4.4 Credential & secret handling

- Secrets: secret manager (`{{AWS Secrets Manager / Key Vault / Secret Manager}}`), injected at runtime. Zero secrets in `.env` committed files, CI logs, tests, or fixtures.
- `gitleaks` in pre-commit **and** CI. A hit blocks the merge — no exceptions, no `--no-verify`.
- Rotation ≤ 90 days; break-glass credentials rotate immediately after use.
- Auth: OIDC/OAuth2, short-lived access tokens + rotating refresh tokens, argon2id for any password at rest, MFA for admin paths.

## 5. Non-functional requirement budget (ISO 25010)

| Attribute | Target | Verified by |
|---|---|---|
| Latency | p95 API < `{{300}}` ms, p99 < `{{800}}` ms | load test in CI nightly |
| Availability | `{{99.9}}` % monthly SLO | SLO dashboard, error budget |
| Throughput | `{{1000}}` rps sustained | k6 test |
| Frontend | LCP < 2.5 s, INL < 200 ms, CLS < 0.1 | Lighthouse CI |
| A11y | WCAG 2.2 **AA** | axe-core in Playwright, CI-blocking |
| Security | 0 Critical/High in `make sec` | CI gate |
| Maintainability | complexity ≤ 10, duplication < 3% | ruff/eslint + sonar-equivalent |
| Recovery | RTO `{{4h}}`, RPO `{{15m}}` | quarterly restore drill |

## 6. Delivery metrics (DORA + SRE)

Deployment frequency · lead time for change · change failure rate · MTTR · SLO burn rate · error budget remaining. Recorded per sprint in `Project-Plan.md` §Metrics.

## 7. Cloud Well-Architected checklist (per release)

Operational excellence (runbook + alarms exist) · Security (least privilege, encryption, logging) · Reliability (multi-AZ, retries with backoff + jitter, graceful degradation) · Performance (right-sized, cached) · Cost (tagged resources, budget alarm) · Sustainability (autoscaling down, no idle envs).

## 8. Glossary

`{{Domain terms — fill at init. Ambiguous language is the #1 source of rework.}}`
