# Project-Management.md

**Purpose:** the control plane. Who exists, what they own, which gate they hold, what they cost, and where the project currently stands. Orchestrator reads this; individual agents read only their own row.

---

## 1. Project state (update every stage transition)

| Field | Value |
|---|---|
| Delivery mode | see `.devcrew/active-mode.json` (`devcrew mode`) — who works on the code |
| Runtime profile | see `.devcrew/active-profile.json` (`devcrew profile`) — how the agent runs |
| Current stage | `0 — Not started (template)` |
| Active sprint | `—` |
| Active epic | `—` |
| Blocked on | `—` |
| Last green CI | `—` |
| Open Critical/High security findings | `0` |
| Error budget remaining | `—` |
| Last updated | `2026-08-09` |

## 1b. Method documents

| Topic | File |
|---|---|
| Standards register, data classification, NFR budget | `Project-Context.md` |
| Roadmap, OKRs, sprints, risks | `Project-Plan.md` |
| Design tokens and UI rules | `Design.md` |
| **Story → acceptance criteria → tests** | `User-Story-Testing.md` |
| Capacity, data, consistency, failure, scaling, cost, zero-cost stack | `System-Design.md` |
| An end-to-end worked example of the pipeline | [Example.md](https://github.com/sarveshtalele/devcrew/blob/main/Example.md) |

## 2. Departments & agents

All agents live in `.claude/agents/`. Each has its own context, its own tool allowlist, and its own tracker.

| # | Agent | Department | Owns stages | Tracker | Model | Tools |
|---|---|---|---|---|---|---|
| 0 | `orchestrator` | Delivery Management | all — routes, gates, never writes product code | `trackers/00-program-board.md` | opus | Agent, Read, Write, Edit, Bash, TaskCreate |
| 1 | `product-manager` | Product | 1 Requirement · 2 PRD/Stories · 11 UAT · 14 Feedback | `trackers/product.md` | opus | Read, Write, Edit, WebFetch |
| 2 | `ux-designer` | Design | 2 (with PM) · 4 UI design | `trackers/design.md` | sonnet | Read, Write, Edit, Browser |
| 3 | `architect` | Architecture | 3 Architecture + ADR | `trackers/architecture.md` | opus | Read, Write, Edit, Grep, Glob |
| 4 | `tech-lead` | Engineering Leadership | 4 Technical Design · task breakdown | `trackers/tech-lead.md` | opus | Read, Write, Edit, Grep, Glob |
| 5 | `backend-engineer` | Backend | 5 Development (API, domain, data) | `trackers/backend.md` | sonnet | Read, Write, Edit, Bash, Grep, Glob |
| 6 | `frontend-engineer` | Frontend | 5 Development (UI) | `trackers/frontend.md` | sonnet | Read, Write, Edit, Bash, Grep, Glob, Browser |
| 7 | `code-reviewer` | Quality Engineering | 6 Code Review | `trackers/code-review.md` | opus | Read, Grep, Glob, Bash(git*), ReportFindings |
| 8 | `qa-engineer` | QA | 7 Unit + Integration tests | `trackers/qa.md` | sonnet | Read, Write, Edit, Bash |
| 9 | `e2e-automation` | QA Automation | 7 E2E + a11y (Playwright) | `trackers/e2e.md` | sonnet | Read, Write, Edit, Bash, Browser |
| 10 | `devops-engineer` | DevOps/Platform | 8 CI · 10 Staging · 12 Prod deploy | `trackers/devops.md` | sonnet | Read, Write, Edit, Bash |
| 11 | `security-engineer` | Security (AppSec + AI) | 9 Security gate · threat models | `trackers/security.md` | opus | Read, Grep, Glob, Bash, WebFetch |
| 12 | `compliance-officer` | GRC | 9 Compliance gate · evidence | `trackers/compliance.md` | opus | Read, Write, Edit, Grep |
| 13 | `sre-observability` | SRE | 13 Monitoring · SLOs · incidents | `trackers/sre.md` | sonnet | Read, Write, Edit, Bash |
| 14 | `release-manager` | Release | 10–12 promotion, change record, rollback | `trackers/release.md` | sonnet | Read, Write, Edit, Bash |

### Interaction contract

Agents do **not** call each other directly. All routing is through `orchestrator`, which:
1. picks the next stage from §3,
2. spawns exactly the agents that stage needs (parallel where independent),
3. collects each agent's **handoff block** (see below),
4. checks exit criteria, then advances or bounces back.

Every agent's final output MUST be exactly this block — nothing else enters the orchestrator's context:

```
STATUS: pass | fail | blocked
DID: <≤3 fragments>
ARTIFACTS: <paths written>
NEXT: <agent + what they need>
RISKS: <≤2, or none>
TOKENS: ~Nk
```

Bounce-backs are explicit: `code-reviewer` fails → returns to the authoring engineer with findings, not to the orchestrator's judgment.

## 3. Pipeline gates

| # | Stage | Owner | Exit criteria (all must be true) | Artifact |
|---|---|---|---|---|
| 1 | Product Requirement | product-manager | Problem, users, success metric, non-goals stated | `Project-Plan.md` §1–2 |
| 2 | PRD / User Stories | product-manager + ux-designer | Every `REQ-###` unambiguous + verifiable (IEEE 29148); acceptance criteria in Given/When/Then | `docs/prd/PRD-<epic>.md` |
| 3 | Architecture + ADR | architect | C4 Context + Container drawn; every significant decision has an ADR with alternatives + consequences | `docs/design/c4-*.md`, `docs/adr/ADR-###.md` |
| 4 | Technical Design | tech-lead + ux-designer | Interfaces/schemas/errors defined; NFR budget allocated; tasks sized ≤5 pts; UI specced against `Design.md` | `docs/design/TD-<epic>.md` |
| 5 | Development | backend/frontend-engineer | Code compiles, `make lint` clean, feature-flagged, no TODOs left | branch |
| 6 | Code Review | code-reviewer | No Critical/High findings; standards met; ≤400 line diff | PR review |
| 7 | Automated Tests | qa-engineer + e2e-automation | Unit ≥85% on changed lines; integration on real deps; E2E journey + axe + keyboard at 3 viewports; zero flakes in 3 consecutive runs | `tests/**` |
| 8 | CI Pipeline | devops-engineer | `make ci` green, build reproducible, SBOM produced | `.github/workflows/ci.yml` |
| 9 | Security / Quality | security-engineer + compliance-officer | 0 Critical/High from SAST/SCA/secrets/DAST; threat model updated; evidence logged for the active regimes | `docs/design/threat-model-*.md` |
| 10 | Staging | devops + release-manager | Deployed, smoke suite green, migrations reversible | staging env |
| 11 | UAT / Validation | product-manager | Acceptance criteria demonstrated against the real env; sign-off recorded | `Changelog.md` |
| 12 | Production Deploy | release-manager | Change record + rollback plan; canary healthy; approval captured | prod |
| 13 | Monitoring | sre-observability | Dashboards, SLOs, alerts, runbook live before traffic | `docs/design/runbook-*.md` |
| 14 | Feedback / Metrics | product-manager + sre | DORA + product metrics recorded | `Project-Plan.md` §7 |
| 15 | Next Iteration | orchestrator | Retro actions in trackers; backlog reprioritized | `trackers/*` |

**A stage may not be skipped.** If a stage is genuinely N/A (e.g. no UI change → stage 4 UI portion), the orchestrator records `SKIPPED: <stage> — <reason>` in `Changelog.md`. Silence is not a skip.

## 4. Token governance (hard-enforced)

Budgets per agent invocation. Exceeding = stop, summarize, hand back. Budget is a design constraint, not a suggestion.

| Agent | Budget/invocation | Typical inputs |
|---|---|---|
| orchestrator | 30k | this file §1–3, handoff blocks only |
| product-manager | 25k | Project-Plan, PRD template |
| ux-designer | 25k | Design.md, target components |
| architect | 40k | ADRs, C4, interface files |
| tech-lead | 40k | TD template, affected modules |
| backend-engineer | 50k | its own module only |
| frontend-engineer | 50k | its own components + Design.md |
| code-reviewer | 35k | diff only — never the whole repo |
| qa-engineer | 35k | unit under test + its tests |
| e2e-automation | 35k | journey spec + page objects |
| devops-engineer | 25k | workflow + Makefile |
| security-engineer | 40k | diff + threat model |
| compliance-officer | 25k | control map + evidence log |
| sre-observability | 25k | dashboards + runbook |
| release-manager | 20k | change record |

**Mechanisms (deterministic, not advisory):**
1. `.claude/hooks/token-guard.sh` (PreToolUse) — blocks unbounded `Read` on files >800 lines, blocks `grep -r`/`rg` without a path scope, blocks `cat`/`find /`, blocks `Read` on the root MD files when the agent's role doesn't own them.
2. `.claude/hooks/session-meter.sh` (PostToolUse) — appends per-tool token estimates to `.claude/state/tokens.jsonl`; `/token-report` renders it.
3. `.claude/hooks/quality-gate.sh` (PostToolUse on Edit/Write) — formats + lints only the changed file. Catches errors at ~200 tokens instead of a 5k-token failed CI run.
4. **Deterministic-first rule:** if a script, `rg`, `jq`, or a Makefile target can answer it, the agent MUST NOT reason it out from file contents. Scripts cost ~0 tokens; reading costs thousands.
5. **Delegate-don't-read:** exploration >3 files goes to a subagent; only its handoff block returns.
6. `/clear` between stages — enforced by the orchestrator's stage transition.

## 5. Hooks

| Hook | Event | Script | Blocking | Purpose |
|---|---|---|---|---|
| token-guard | PreToolUse `Read|Grep|Bash` | `.claude/hooks/token-guard.sh` | ✅ | context-blowout prevention |
| secret-guard | PreToolUse `Write|Edit` | `.claude/hooks/secret-guard.sh` | ✅ | blocks writing secrets / `.env` / key material |
| protected-paths | PreToolUse `Write|Edit` | `.claude/hooks/secret-guard.sh` | ✅ | blocks edits to `migrations/`, `infra/prod/`, `.github/workflows/` without explicit ticket |
| push-guard | PreToolUse `Bash` | `.claude/hooks/push-guard.sh` | ✅ | blocks unverified push/PR, `--no-verify`, shared-branch force-push, and AI attribution trailers |
| quality-gate | PostToolUse `Write|Edit` | `.claude/hooks/quality-gate.sh` | ⚠️ warns | format + lint the changed file |
| session-meter | PostToolUse `*` | `.claude/hooks/session-meter.sh` | ❌ | token accounting |
| changelog-nudge | Stop | `.claude/hooks/changelog-nudge.sh` | ❌ | reminds if code changed but `Changelog.md` didn't |

Git hooks installed by `devcrew init/add`:

| Hook | Blocking | Purpose |
|---|---|---|
| `commit-msg` | ✅ | rejects AI author/co-author trailers; enforces Conventional Commits |
| `pre-push` | ✅ | refuses any push whose `.devcrew/verify-ok` stamp is older than the last change under `src/` or `tests/` |

Install/verify: `bash .claude/hooks/install.sh`. Config lives in `.claude/settings.json`.

## 6. Skills (invoked, not auto-loaded)

| Skill | Command | Purpose |
|---|---|---|
| project-init | `/project-init` | Runs the §0 intake, fills all `{{PLACEHOLDERS}}`, prunes unused compliance regimes via ADR |
| feature | `/feature <name>` | Drives stages 1→15 for one feature |
| adr | `/adr <decision>` | Writes an ADR in MADR format |
| threat-model | `/threat-model <component>` | STRIDE + OWASP LLM pass |
| test-plan | `/test-plan <epic>` | IEEE 29119 plan → concrete unit/integration/E2E tasks |
| release | `/release <version>` | Stages 10–12 with change record + rollback |
| token-report | `/token-report` | Renders `.claude/state/tokens.jsonl` |
| scout | `/scout <question>` | Answers a codebase question in a subagent — files never enter the main context |
| compact-docs | `/compact-docs` | Shrinks standing documents; converts repeated rules into hooks |

## 6b. CLI (deterministic, token-cheap — prefer these over reasoning)

| Command | Purpose |
|---|---|
| `devcrew verify` | The push gate: secrets → authorship → lint → tests → SAST/SCA → E2E. **Required before any push.** |
| `devcrew mode [name]` | Show or switch delivery mode |
| `devcrew profile [name]` | Show or switch runtime profile (`normal` / `optimized`) |
| `devcrew agents` | Which agents are active right now |
| `devcrew doctor` | Prerequisites and installation health |
| `devcrew tokens` | Token spend by agent and tool |
| `devcrew sync all` | Regenerate `AGENTS.md` and editor configs |

## 7. Plugins / MCP

| Name | Status | Used for |
|---|---|---|
| `engineering` plugin (github, linear/asana, datadog, pagerduty) | ⚠️ needs auth | issue sync, alerting, on-call |
| `context7` MCP | ✅ connected | current library docs — **use instead of guessing APIs** |
| `firecrawl` MCP | ✅ connected | competitor/standards research |
| Playwright | via `make e2e` | E2E + a11y |
| `gh` CLI | preferred over GitHub MCP | cheapest way to touch GitHub |

Unauthenticated MCP servers must be authorized by the user via claude.ai connector settings or `claude mcp` / `/mcp` in an interactive session. Until then those capabilities are unavailable — agents must not fake them.

## 8. RACI (condensed)

| Activity | R | A | C | I |
|---|---|---|---|---|
| Scope & priority | product-manager | orchestrator | tech-lead, ux-designer | all |
| Architecture | architect | tech-lead | security-engineer, devops | all |
| Implementation | backend/frontend | tech-lead | architect | qa |
| Merge approval | code-reviewer | tech-lead | security-engineer | — |
| Prod release | release-manager | orchestrator | devops, sre | all |
| Security acceptance | security-engineer | compliance-officer | architect | all |
| Incident command | sre-observability | orchestrator | all | all |

## 9. Escalation

Agent blocked → returns `STATUS: blocked` with the specific decision needed → orchestrator resolves from `Project-Context.md`/`Project-Plan.md` → if not answerable there, **asks the user**. Agents never invent product, security, or compliance decisions.

Any of these stop the pipeline immediately: secret committed · Critical vuln · PII/PHI/CHD leak · prod SLO burn > 2x · failed compliance control.
