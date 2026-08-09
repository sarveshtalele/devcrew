# devcrew — Complete Guide

Everything the [README](README.md) summarizes, in full.

**Contents**

1. [Concepts](#1-concepts)
2. [Installation](#2-installation)
3. [CLI reference](#3-cli-reference)
4. [Delivery modes](#4-delivery-modes)
5. [The pipeline, stage by stage](#5-the-pipeline-stage-by-stage)
6. [Agents](#6-agents)
7. [Skills — the slash commands](#7-skills--the-slash-commands)
8. [Gates and hooks](#8-gates-and-hooks)
9. [The verification and push workflow](#9-the-verification-and-push-workflow)
10. [The documents](#10-the-documents)
11. [Design system workflow](#11-design-system-workflow)
12. [Testing](#12-testing)
13. [Security and compliance](#13-security-and-compliance)
14. [Token optimization playbook](#14-token-optimization-playbook)
15. [Editor setup](#15-editor-setup)
16. [CI integration](#16-ci-integration)
17. [Customization](#17-customization)
18. [Troubleshooting](#18-troubleshooting)
19. [Worked example](#19-worked-example)
20. [Glossary](#20-glossary)

---

## 1. Concepts

Five ideas explain the whole design.

**Departments, not one generalist.** A single agent asked to design, build, review, and secure a feature does all four at the level of the weakest. Splitting the work gives each specialist a focused prompt and — critically — a *fresh context*. The reviewer never sees the reasoning that produced the code, so it evaluates the diff on its own terms.

**Stages with exit criteria.** "Done" is the most expensive word in software. Every stage names what must be true before the next one starts, and those criteria are checked literally rather than felt.

**Gates as code.** Markdown rules are advisory; an agent 40 turns into a session will drift past them. A shell script with exit code 2 will not. Anything that must never happen is a hook, not a sentence.

**Context is the budget.** Model quality degrades as the window fills. Every design choice — on-demand reads, subagent delegation, fixed handoff blocks, per-agent budgets — exists to keep the window small.

**Rigor should be adjustable.** A weekend prototype and a HIPAA product do not deserve the same ceremony. Modes change how many agents run, which stages execute, and how hard the gates bite.

---

## 2. Installation

### 2.1 Requirements

| | |
|---|---|
| **Required** | `git`, `python3`, and a POSIX shell |
| **Platforms** | macOS, Linux, WSL, Windows (via Git Bash) |
| **Optional per stack** | `uv`, `pnpm`, `node ≥18`, `make`, `gitleaks`, `ruff`, `mypy`, `pytest`, `semgrep`, `gh` |

`devcrew verify` skips checks whose tool isn't installed and says so — it never silently passes a check it couldn't run.

### 2.2 Token-reduction prerequisites

Install both before your first session. They are free, local, open source, and attack different parts of the token bill.

**caveman** — compresses what the agent writes.

```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

Windows PowerShell 5.1+:

```powershell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
```

Requires Node ≥18. Works across 30+ agents. Levels `lite`, `full`, `ultra`, plus classical-Chinese variants; switch with `/caveman <level>`. Reported ~65% fewer output tokens on prose and ~8.5% across full agentic runs. Extra commands: `/caveman-stats`, `/caveman-commit`, `/caveman-review`, `/caveman-compress`.
<https://github.com/JuliusBrussee/caveman>

**rtk** — compresses what the agent reads.

```bash
brew install rtk && rtk init -g
```

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh && rtk init -g
```

A single Rust binary that intercepts shell commands and filters their output before it enters context — `git status` collapsed by state, test output reduced to failures, `ls` as a tree with counts, `git diff` with headers stripped. Up to 90% of bash output removed. `rtk init -g` installs a hook that rewrites Bash calls automatically; restart your agent afterward. `rtk gain` shows savings, `rtk discover` finds missed opportunities.
<https://github.com/rtk-ai/rtk>

> These are complementary, not alternatives. caveman shrinks output tokens, rtk shrinks tool-result tokens, devcrew shrinks what is read in the first place.

### 2.2b Windows

The gates are POSIX shell scripts, so Windows needs Git Bash or WSL — the same shell git hooks, Claude Code, and Cursor already use there.

```powershell
irm https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.ps1 | iex
```

The installer:

1. checks for `git` and `python`, failing with the exact `winget` command if either is missing;
2. locates `bash.exe` from Git for Windows, falling back to WSL;
3. clones to `%USERPROFILE%\.devcrew` with `core.autocrlf false` — **CRLF line endings are a syntax error in a shell script**, and `.gitattributes` pins every script to LF;
4. writes `%LOCALAPPDATA%\devcrew\bin\devcrew.cmd` shimming through that shell;
5. adds the bin directory to your user PATH.

Restart your terminal, then `devcrew doctor`.

**If you edit hook scripts on Windows**, make sure your editor saves LF. `.gitattributes` handles git; it cannot fix an editor writing CRLF into an untracked file. `.vscode/settings.json` sets `files.eol` to `\n` for exactly this reason.

Prerequisites on Windows:

```powershell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
scoop install rtk    # or: cargo install rtk
rtk init -g
```

### 2.3 Install the kit

```bash
# recommended
curl -fsSL https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.sh | bash

# npx, no global install
npx devcrew init my-app

# manual
git clone https://github.com/sarveshtalele/devcrew ~/.devcrew
ln -s ~/.devcrew/bin/devcrew ~/.local/bin/devcrew
```

The installer clones to `~/.devcrew`, symlinks `~/.local/bin/devcrew`, and warns if that directory is not on your `PATH`. Re-running updates in place. Override with `DEVCREW_HOME`, `DEVCREW_BIN`, `DEVCREW_REPO`, `DEVCREW_REF`.

**As a Claude Code plugin** (agents, skills, and hooks — no CLI):

```
/plugin marketplace add sarveshtalele/devcrew
/plugin install devcrew
```

Use the plugin for agents everywhere and the CLI per project for the documents, trackers, and push gate.

### 2.4 Scaffold a project

```bash
devcrew init my-app --mode core     # new
devcrew add . --mode secure         # existing, non-destructive
devcrew doctor                      # verify
```

`init` refuses to run in a non-empty directory — use `add` there. `add` skips every file that already exists and prints what it skipped; `--force` replaces kit files only, never your source.

Both install the `commit-msg` and `pre-push` git hooks when the target is a git repository. Skip with `--no-git`.

---

## 3. CLI reference

### `devcrew init [dir]`

Scaffolds a new project: creates the directory, copies the payload, initializes git, installs git hooks, prunes agents to the mode, generates `AGENTS.md` and editor configs.

| Flag | Default | Meaning |
|---|---|---|
| `--mode <name>` | `core` | Delivery mode |
| `--stack <name>` | `py-ts` | `py-ts`, `ts`, `py`, `none` |
| `--no-git` | off | Skip `git init` and git hooks |

Fails if the directory exists and is non-empty.

### `devcrew add [dir]`

Adds the kit to an existing project. **Never overwrites.** Existing files are skipped and reported. `--force` replaces kit-owned files (agents, hooks, trackers, templates) but never your source, README, or CI.

Defaults to the mode already recorded in `.devcrew/mode`, or `core`.

### `devcrew mode [name]`

No argument: lists modes and marks the active one. With a name: restores the full agent set, prunes to that mode, and rewrites `.devcrew/mode` and `.devcrew/active-mode.json`.

Switching is safe and reversible. Your trackers, documents, and history are untouched — only which agents exist changes.

### `devcrew agents`

Lists active agents with a one-line description each.

### `devcrew verify`

The push gate. See [§9](#9-the-verification-and-push-workflow). Exit 0 writes `.devcrew/verify-ok`; any failure removes the stamp and exits 1.

### `devcrew doctor`

Checks required tools, caveman and rtk, per-stack toolchain, the presence and executability of kit files, git hook installation, and leftover `{{PLACEHOLDERS}}`. Run it first whenever something behaves oddly.

### `devcrew sync <target>`

Regenerates `AGENTS.md`, `.cursor/rules/devcrew.mdc`, `.agent/AGENTS.md`, and `.github/copilot-instructions.md` from one source. Targets: `claude`, `cursor`, `antigravity`, `all`.

### `devcrew tokens`

Renders `.claude/state/tokens.jsonl` — estimated tokens by agent and by tool. Written by the `session-meter` hook.

### `devcrew uninstall [dir]`

Removes kit-owned files. Keeps `CLAUDE.md` and `Changelog.md`, which usually contain your edits. Never touches `src/`, `tests/`, or CI.

---

## 4. Delivery modes

| Mode | Agents | Stages | Security gate | Compliance gate | Coverage | E2E | a11y | LLM controls |
|---|:---:|:---:|---|---|:---:|:---:|:---:|:---:|
| `lite` | 4 | 4–8 | advisory | off | 70% | – | – | – |
| `core` | 7 | 1–9 | blocking | advisory | 85% | – | ✓ | – |
| `secure` | 11 | 1–10, 12 | blocking | advisory | 85% | ✓ | ✓ | – |
| `ai` | 12 | 1–10, 12–14 | blocking | advisory | 85% | ✓ | ✓ | ✓ |
| `full` | 15 | 1–15 | blocking | blocking | 85% | ✓ | ✓ | ✓ |

**Choosing:** start one level below where you think you belong and move up when the project earns it. Ceremony you don't need is ceremony you'll route around, and a process people route around is worse than none.

- No users yet → `lite`
- Real users, no sensitive data → `core`
- Auth, payments, or personal data → `secure`
- A model call users can reach → `ai`
- An auditor will read this → `full`

Mode definitions live in `modes/modes.json` (and `.devcrew/modes/` inside each project). Add your own by copying an entry.

---

## 5. The pipeline, stage by stage

| # | Stage | Owner | Exit criteria | Artifact |
|---|---|---|---|---|
| 1 | Product Requirement | product-manager | Problem, users, success metric, non-goals stated | `Project-Plan.md` §1–2 |
| 2 | PRD / User Stories | product-manager + ux-designer | Every `REQ-###` unambiguous and verifiable; acceptance criteria in Given/When/Then; data classes declared | `docs/prd/PRD-<epic>.md` |
| 3 | Architecture + ADR | architect | C4 Context + Container drawn; every significant decision has an ADR with real alternatives and consequences | `docs/adr/`, `docs/design/c4-*.md` |
| 4 | Technical Design | tech-lead + ux-designer | Interfaces, schemas, error contract defined; NFR budget allocated; tasks ≤5 points with test hooks | `docs/design/TD-<epic>.md` |
| 5 | Development | backend + frontend | Compiles, lint clean, feature-flagged, no TODOs | branch |
| 6 | Code Review | code-reviewer | No Critical/High findings; matches the design; diff under ~400 lines | PR review |
| 7 | Automated Tests | qa-engineer + e2e-automation | ≥85% changed-line coverage; integration on real dependencies; E2E + axe + keyboard at 3 viewports; no flakes in 3 runs | `tests/**` |
| 8 | CI Pipeline | devops-engineer | `make ci` green, build reproducible, SBOM produced | `.github/workflows/ci.yml` |
| 9 | Security / Compliance | security-engineer + compliance-officer | 0 Critical/High from SAST/SCA/secrets/DAST; threat model current; evidence logged | `docs/design/threat-model-*.md` |
| 10 | Staging | devops + release-manager | Deployed, smoke green, migrations reversible | staging |
| 11 | UAT | product-manager | Acceptance criteria demonstrated on the real environment; sign-off recorded | `Changelog.md` |
| 12 | Production | release-manager | Change record, rollback plan, canary healthy, approval captured | prod |
| 13 | Monitoring | sre-observability | Dashboards, SLOs, alerts, runbook live *before* traffic | `docs/design/runbook-*.md` |
| 14 | Feedback / Metrics | product-manager + sre | DORA and product metrics recorded | `Project-Plan.md` §7 |
| 15 | Next Iteration | orchestrator | Retro actions filed; backlog reprioritized | `trackers/` |

### Skipping

A stage that genuinely does not apply is logged:

```
SKIPPED: 3 Architecture — no boundary or dependency change [orchestrator]
```

Silence is never a skip. If you cannot write the reason, the stage applies.

### Fast path

Changes under ~20 lines with no new interface, no data-model change, and no security surface run stages 5→8 only. **Never eligible:** anything touching auth, payments, health data, file upload, deserialization, or an LLM.

### Bounce-backs

A failed gate returns to the authoring agent with the specific findings — not to the orchestrator's judgment. Three consecutive bounces on one stage escalates to you instead of looping.

---

## 6. Agents

### 6.1 The handoff contract

Every agent's final output is exactly this block. Nothing else enters the orchestrator's context — this is what keeps the orchestrator flat across a 15-stage run.

```
STATUS: pass | fail | blocked
DID: <≤3 fragments>
ARTIFACTS: <paths written>
NEXT: <agent + what they need>
RISKS: <≤2, or none>
TOKENS: ~Nk
```

### 6.2 Roster

| Agent | Model | Budget | Owns |
|---|---|---:|---|
| `orchestrator` | opus | 30k | Routing, gates, the only agent that talks to you |
| `product-manager` | opus | 25k | Requirements, PRDs, stories, UAT, metrics |
| `ux-designer` | sonnet | 25k | Flows, UI specs, design system |
| `architect` | opus | 40k | C4, ADRs, boundaries |
| `tech-lead` | opus | 40k | Interfaces, schemas, error contracts, task sizing |
| `backend-engineer` | sonnet | 50k | API, domain, data, migrations |
| `frontend-engineer` | sonnet | 50k | UI from tokens, accessibility |
| `code-reviewer` | opus | 35k | Fresh-context diff review |
| `qa-engineer` | sonnet | 35k | Unit + integration tests |
| `e2e-automation` | sonnet | 35k | Playwright, axe, keyboard, viewports |
| `devops-engineer` | sonnet | 25k | CI/CD, IaC, SBOM |
| `security-engineer` | opus | 40k | Threat models, ASVS, OWASP LLM, scanner triage |
| `compliance-officer` | opus | 25k | SOC 2 / GDPR / HIPAA / PCI evidence |
| `sre-observability` | sonnet | 25k | SLOs, alerts, runbooks, DORA |
| `release-manager` | sonnet | 20k | Change records, canary, rollback |

### 6.3 Invoking

Usually you don't — `/feature` routes for you. To call one directly:

```
Use the security-engineer agent to threat-model the file upload endpoint.
```

### 6.4 Adding your own

Create `.claude/agents/<name>.md`:

```markdown
---
name: data-engineer
description: Owns pipelines, warehouse schemas, and data quality. Use for ETL and analytics work.
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

You are the Data Engineer.

## Persona
<one or two lines — this is what makes the agent behave distinctly>

## Owns
<stages>

## Hard rules
<the things that must never happen>

## Output
Handoff block. Budget ~Nk.
```

Add it to a mode in `modes/modes.json`, give it a tracker in `trackers/`, and add a row to `Project-Management.md` §2 and §4.

**Keep agent files short.** They are loaded into that agent's context every invocation. Persona, ownership, hard rules, output contract — nothing else.

---

## 7. Skills — the slash commands

| Command | What it does |
|---|---|
| `/project-init` | 16-question intake, fills placeholders, scopes compliance via ADR-001, prunes agents, seeds the board |
| `/feature <name>` | Drives one feature through every stage of the pipeline |
| `/adr <decision>` | Writes an ADR in MADR format |
| `/threat-model <component>` | STRIDE + OWASP LLM pass, files gaps as tracker cards |
| `/test-plan <epic>` | IEEE 29119 plan split into concrete unit, integration, and E2E tasks |
| `/release <version>` | Stages 10–12: staging, UAT, change record, canary, rollback |
| `/scout <question>` | Answers a codebase question in a subagent — files never enter your context |
| `/compact-docs` | Shrinks the standing documents so every future turn costs less |
| `/token-report` | Where the context actually went, with one concrete fix |

`/project-init`, `/feature`, and `/release` have side effects and are manual-invocation only. The rest can also be applied automatically when relevant.

---

## 8. Gates and hooks

### 8.1 Agent hooks

Configured in `.claude/settings.json` (or `hooks/hooks.json` for the plugin). Exit code 2 blocks the tool call and returns stderr to the agent as feedback.

| Hook | Event | Blocking | Blocks |
|---|---|:---:|---|
| `token-guard` | PreToolUse `Read\|Grep\|Bash` | ✅ | Unbounded reads >800 lines, tree-wide greps with short patterns, `cat`, `find /` |
| `secret-guard` | PreToolUse `Write\|Edit` | ✅ | `.env`/key files, credential-shaped literals, protected paths |
| `push-guard` | PreToolUse `Bash` | ✅ | Unverified push, `--no-verify`, shared-branch force-push, AI attribution trailers |
| `quality-gate` | PostToolUse `Write\|Edit` | ⚠️ | Formats and lints the changed file, returns errors as feedback |
| `session-meter` | PostToolUse `*` | ❌ | Records token cost |
| `changelog-nudge` | Stop | ❌ | Warns when code changed but `Changelog.md` didn't |

### 8.2 Git hooks

| Hook | Blocks |
|---|---|
| `commit-msg` | AI co-author trailers; non-conventional commit subjects |
| `pre-push` | Any push without a verification stamp newer than the last source change |

### 8.3 Protected paths

`secret-guard` refuses edits to `migrations/`, `infra/prod/`, and `.github/workflows/`. Intentional changes:

```bash
CLAUDE_ALLOW_PROTECTED=1 claude
```

Set it deliberately, for one session, with a ticket in hand.

### 8.4 Tuning

Every hook is a readable shell script in `.claude/hooks/`. Raise the read limit, add a path exemption, add a scanner — edit the file. Test one with:

```bash
echo '{"tool_name":"Read","tool_input":{"file_path":"big.py"}}' | .claude/hooks/token-guard.sh; echo "exit=$?"
```

Exit 2 with a message on stderr means the block works.

---

## 9. The verification and push workflow

### 9.1 The rule

**Nothing leaves the machine unverified.** Not a push, not a PR, not a merge.

```bash
devcrew verify && git push
```

### 9.2 What runs, in order

| # | Check | Why here |
|---|---|---|
| 1 | Secrets (`gitleaks`) | First — a leaked credential makes every later result irrelevant |
| 2 | Authorship | No AI attribution trailers in the commits about to be pushed |
| 3 | Lint + types (`make lint`) | Cheap, catches most of it |
| 4 | Unit + integration (`make test`) | Correctness |
| 5 | SAST + SCA (`make sec`) | bandit, semgrep, pip-audit, pnpm audit |
| 6 | E2E + a11y (`make e2e`) | Only when the mode requires it |

Missing tools are skipped with a visible note. Failures print the first 15 lines of output — enough to act on, not enough to flood context.

### 9.3 The stamp

Success writes `.devcrew/verify-ok` with a timestamp and the verifier's name. Both the git `pre-push` hook and the agent `push-guard` compare it against the newest file under `src/` and `tests/`. Editing code after verifying invalidates the stamp automatically — there is no way to push stale approval.

### 9.4 Authorship

No AI tool is credited as author or co-author, anywhere. Enforced in the agent instructions, in `push-guard`, and in `commit-msg`. Reasons: accountability (a commit author is who you ask at 3am), clean `git blame`, and not leaking tooling choices into public history.

To opt out, delete the check in `template/githooks/commit-msg` — deliberately, not by accident.

### 9.5 `--no-verify`

Forbidden, and blocked at the agent layer. The gates *are* the control. If a gate is wrong, fix the gate.

---

## 10. The documents

| File | Purpose | Who edits |
|---|---|---|
| `CLAUDE.md` | Agent instructions, Claude Code. Loaded every session — keep under ~200 lines | you |
| `AGENTS.md` | The same rules, portable. Generated by `devcrew sync` | generated |
| `Project-Context.md` | What this project is, which standards bind it, data classification, NFR budget | product + architect |
| `Project-Plan.md` | Intake answers, OKRs, scope, milestones, story map, sprints, risks, metrics | product-manager |
| `Project-Management.md` | Live state, agent roster, gates, token budgets, hooks, RACI, escalation | orchestrator |
| `Design.md` | Design tokens (YAML front matter) + UI rules | ux-designer |
| `System-Design.md` | Capacity, data model, consistency, failure, scaling, cost, zero-cost stack | architect + tech-lead |
| `User-Story-Testing.md` | Story → acceptance criteria → test level → traceability | product + QA |
| `Changelog.md` | Append-only history; doubles as SOC 2 change evidence | every agent |
| `trackers/*.md` | One Kanban+Scrum board per department | each department |

**The read-on-demand rule.** Never load all of these at once — roughly 15k tokens, and it degrades every later turn. `CLAUDE.md` carries a routing table; agents read the one file that answers the question in front of them.

**Keeping `CLAUDE.md` lean.** For each line ask: *would removing this cause a mistake?* If not, cut it. A bloated instruction file causes the important rules to be ignored, which is worse than not having them.

---

## 11. Design system workflow

`Design.md` has two layers: YAML front matter with machine-readable tokens, and prose explaining application. Tokens are the source of truth; the Tailwind config is generated from them.

Defaults: modern-SaaS vibrant (violet→teal gradient), light and dark as equal first-class themes, WCAG 2.2 AA, Inter + JetBrains Mono, Tailwind + shadcn/ui.

**Rules that matter most:**

- Every value comes from tokens. A raw hex in a diff is a review failure. Need a value that isn't there? Add a token in a PR.
- Both themes are first-class. Dark is not an inversion — it lifts brand lightness because saturated hues vibrate on dark surfaces.
- Contrast floors: 4.5:1 body text, 3:1 large text and UI, 3:1 focus ring against both the component and its surroundings.
- Nested radius: inner = outer − padding. Concentric corners separate designed UI from assembled UI.
- One gradient per screen, never behind body text.
- Every component ships all states: default, hover, active, focus-visible, disabled, loading, error, empty.
- Anything rendering PII, PHI, or cardholder data is masked by default and excluded from analytics and session replay.

Changing the palette: edit only the `colors` block, re-verify contrast, regenerate the Tailwind config. Never hand-edit generated config.

---

## 12. Testing

### 12.1 Levels

**Unit** — pure logic, no I/O, no network, no sleeping. Happy path, every boundary, every error path. ≥85% of changed lines.

Boundary checklist: empty · one · many · max · max+1 · null · wrong type · unicode/emoji · negative · zero · duplicate · concurrent · expired token · unauthorized user · malformed payload.

**Integration** — real Postgres and Redis via testcontainers, real HTTP layer. Never mock the thing under test.

**E2E (Playwright)** — user journeys only, plus one failure path per journey.

- Locators by role, label, or text. **CSS and XPath are forbidden** — add an `aria-label` to the app instead.
- Zero `waitForTimeout`. Web-first assertions and `waitForResponse` only.
- Each test seeds its own data and cleans up. No inter-test dependencies.
- Must pass 3 consecutive runs before merging. Flakes go to a quarantine lane with a 5-day fix SLA — not `test.skip` and forgotten.

**Accessibility** — axe-core scan per page state, keyboard journey with visible focus and focus trapping, at 375 / 768 / 1280. Violations fail CI.

**Security cases** — authorization bypass as another user, injection payloads, oversized input, missing or invalid auth, rate limits, and assertions that PII and PHI appear in neither logs nor error bodies.

### 12.2 Rules

- Every bug fix begins with a test that fails before the fix and passes after. Prove both.
- Assert behavior, not implementation. No snapshot tests of logic.
- Deterministic: seeded data, frozen clock, no shared mutable state, no ordering dependency.
- A test that doesn't fail when you revert the change is not a test.

---

## 13. Security and compliance

### 13.1 Threat modeling

Run `/threat-model <component>` **before** writing code that touches auth, payments, health data, file upload, deserialization, or an LLM.

STRIDE per trust boundary. Each threat records asset, entry point, concrete exploit path, existing control, gap, mitigation, and **the test that proves the mitigation**. A threat with no exploit path is speculation and gets cut. Unmitigated gaps become cards in `trackers/security.md`.

### 13.2 AI/LLM controls (OWASP LLM Top 10)

Mandatory wherever a model call exists — automatic in `ai` and `full` modes.

| Risk | Control |
|---|---|
| Prompt injection | Retrieved documents, tool output, and user text are untrusted **data, never instructions**. Model-requested tool calls hit an allowlist with validated arguments. |
| Sensitive disclosure | Redact PII/PHI/cardholder data and secrets before the prompt; filter output before display. |
| Insecure output handling | Never `eval`, never raw HTML, never a SQL fragment or shell argument. Parse into a strict schema first. |
| Excessive agency | Scoped least-privilege identity. Irreversible actions need human confirmation. |
| Unbounded consumption | Per-user rate limits and token ceilings, with cost alarms. |
| Supply chain | Pinned model IDs; model and prompt version recorded with every output. |
| Poisoning | Provenance recorded for any fine-tune or RAG corpus; corpus changes reviewed like code. |
| Guardrails | Input and output classifiers at the boundary; blocks emitted as metrics, never silently swallowed. |

### 13.3 Data classification

Every field is classified, and the class drives the controls:

| Class | Storage | Logs | Retention |
|---|---|---|---|
| PII | encrypted at rest, column-level where feasible | **never** | purpose-bound, default 24 months |
| PHI | encrypted, access-controlled, minimum necessary | **never** | 6 years (audit logs) |
| Cardholder | **never stored** — tokenize; PAN masked to last 4 | **never** | token only |
| Secrets | secret manager only, rotated ≤90 days | **never** | n/a |

Fields must be annotated in code so the log redactor and retention job can find them.

### 13.4 Compliance scoping

`/project-init` asks which data classes you handle and activates only the applicable regimes: PII → GDPR, PHI → HIPAA, cardholder → PCI DSS, SOC 2 always. The scope-down is recorded as ADR-001 and the unused checklists are deleted — carrying them costs tokens every session.

Evidence goes to `docs/compliance/evidence-log.md`, append-only. **A control that works but cannot be shown to have worked fails the audit anyway.**

---

## 14. Token optimization playbook

### 14.1 The stack

| Layer | Tool | Cuts |
|---|---|---|
| What the agent writes | caveman | ~65% of prose output |
| What tools return | rtk | up to 90% of bash output |
| What gets read at all | devcrew | budgets, delegation, on-demand reads |

### 14.2 Rules the kit enforces

1. **Delegate exploration.** Any search over more than 3 files goes to a subagent; only its handoff block returns.
2. **Read ranges, not files.** `token-guard` blocks unbounded reads over 800 lines.
3. **Never re-read** a file you just edited.
4. **Deterministic-first.** If `rg`, `jq`, or a Makefile target can answer it, do not reason it out of file contents. A script costs ~0 tokens; reading costs thousands.
5. **Clear context between stages.** Each stage is an independent task.
6. **Fixed handoff blocks** keep the orchestrator flat regardless of stage count.
7. **Per-agent budgets** in `Project-Management.md` §4.

### 14.3 Measuring

```bash
devcrew tokens     # by agent and by tool
rtk gain            # bash output saved
/caveman-stats      # output compression
```

Usual waste, in order: unbounded reads · tree-wide greps · re-reading edited files · exploration that should have been a subagent · loading all six documents at once.

---

## 15. Editor setup

### Claude Code

Everything works: agents, skills, hooks, plugin install.

```bash
devcrew add .
```

`.claude/settings.json` wires the hooks. Confirm with `/context` that `CLAUDE.md` loaded. Or install as a plugin for agents across all projects.

### Cursor

```bash
devcrew add .
devcrew sync cursor
```

Writes `.cursor/rules/devcrew.mdc` with `alwaysApply: true`, pointing at `AGENTS.md`. Subagent orchestration isn't available; run stages yourself with the department docs as instructions. CLI and git hooks work unchanged.

### Antigravity

```bash
devcrew add .
devcrew sync antigravity
```

Writes `AGENTS.md` and `.agent/AGENTS.md`.

### GitHub Copilot

`devcrew sync all` writes `.github/copilot-instructions.md`.

### Windows, any editor

Everything works through Git Bash or WSL. `devcrew.cmd` on your PATH makes `devcrew verify` behave identically to macOS and Linux, and git hooks run under the same shell git already uses.

### Anything else

`AGENTS.md` is the portable contract. The CLI and git hooks are editor-independent — the push gate holds even with no agent at all.

---

## 16. CI integration

The shipped `.github/workflows/ci.yml` runs fail-fast, cheapest first:

```
lint → unit/integration → build → SCA + secrets + SAST → e2e + axe → SBOM
```

With pinned action SHAs, pinned base images, lockfile installs, OIDC federation instead of long-lived cloud keys, masked secrets, and cached uv/pnpm/Playwright.

Run the same gate in CI:

```yaml
- name: devcrew verify
  run: |
    curl -fsSL https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.sh | bash
    ~/.local/bin/devcrew verify
```

Branch protection should require the CI check, one review, and no force-push — the local gate catches things early; branch protection is what stops a determined bypass.

---

## 17. Customization

| Want | Edit |
|---|---|
| Different standards | `Project-Context.md` §3 |
| Different stack or commands | `Makefile` + `CLAUDE.md` §Stack |
| Different design tokens | `Design.md` front matter, then regenerate Tailwind |
| New agent | `.claude/agents/<name>.md` + `modes/modes.json` + tracker + `Project-Management.md` |
| New mode | copy an entry in `modes/modes.json` |
| Different token budgets | `Project-Management.md` §4 and `token-guard.sh` |
| Different gate strictness | the mode's `gates` block |
| Allow AI attribution | delete the check in `githooks/commit-msg` and `push-guard.sh` |
| Different tracker format | rewrite `trackers/*.md`; nothing parses them but agents |

Nothing is compiled, minified, or hidden. Every behavior is a markdown file or a shell script you can read in a minute.

---

## 18. Troubleshooting

**`devcrew: command not found`** — `~/.local/bin` isn't on `PATH`. Add `export PATH="$HOME/.local/bin:$PATH"` to your shell profile, or use `.devcrew/bin/devcrew` inside the project.

**Hooks don't fire** — run `devcrew doctor`. Usually not executable: `chmod +x .claude/hooks/*.sh`. In Claude Code, confirm `.claude/settings.json` is valid JSON. Hook changes need a session restart.

**`verify` fails on a tool you don't use** — it skips missing tools. If a Makefile target fails because the stack isn't set up, remove that target or run `devcrew init --stack none`.

**Push blocked after verifying** — you edited `src/` or `tests/` afterward. That is the design. Re-run `devcrew verify`.

**`token-guard` blocks a legitimate read** — pass `offset`/`limit`, or raise the 800-line threshold in `.claude/hooks/token-guard.sh`.

**`secret-guard` blocks a legitimate file** — for protected paths, `CLAUDE_ALLOW_PROTECTED=1`. For a false positive on credential-shaped content, read the value from the environment instead; if it's genuinely a fixture, narrow the pattern in the hook.

**Agent ignores instructions** — `CLAUDE.md` is probably too long, or context is full. Prune the file, or clear context between stages. If the same correction happens twice, clear and restart with a better prompt.

**Agent for the current mode is missing** — `devcrew mode <name>` restores the full set and prunes again.

**Placeholders still present** — run `/project-init`. Check with `rg -n '\{\{' --glob '*.md'`.

---

## 19. Worked example

Adding a refund endpoint to a payments product, in `secure` mode.

```bash
devcrew mode secure
```

**Stage 1–2.** `product-manager` writes `REQ-041: an admin can refund a captured payment within 90 days`, with Given/When/Then acceptance criteria and the data classes declared — cardholder data touched, PCI controls activate.

**Stage 3.** `architect` writes ADR-014: refunds through the existing PSP rather than a ledger reversal. Alternatives, consequences, and the fact that the PSP owns idempotency all recorded.

**Stage 4.** `tech-lead` produces the technical design: `POST /v1/payments/{id}/refunds`, request and response schemas, six typed errors with RFC 9457 shapes, an idempotency key, the expand/contract migration, and the test hooks that make PSP calls injectable.

**Threat model.** `/threat-model refunds` before any code. Finds two gaps: no object-level authorization on the payment ID (an admin of tenant A could refund tenant B), and PSP webhook signatures unverified. Both filed as blocking cards.

**Stage 5.** `backend-engineer` implements from the design. `secret-guard` blocks a hardcoded PSP test key on the first attempt; the key moves to an environment variable.

**Stage 6.** `code-reviewer`, in a fresh context, finds a race: two concurrent refunds for the same payment both pass the amount check. Blocking. Fixed with a row-level lock plus a test that reproduces the race.

**Stage 7.** `qa-engineer` covers boundaries — zero amount, over-refund, expired window, already refunded, unauthorized tenant. `e2e-automation` writes the admin journey plus the failure path, runs axe, and passes at all three viewports.

**Stage 8–9.** CI green. `security-engineer` confirms both threat-model gaps are closed with tests and that no PAN appears in logs or responses.

**Ship.**

```bash
devcrew verify   # secrets → authorship → lint → tests → SAST/SCA → e2e
git push
```

`Changelog.md` gets the entry with the affected PCI control. The tracker card moves to Done. Total: one feature, every gate, nothing paid for.

---

## 20. Glossary

**ADR** — Architecture Decision Record. A short document capturing a decision, its alternatives, and its consequences.
**ASVS** — OWASP Application Security Verification Standard. L2 is the standard bar for applications handling sensitive data.
**C4** — A model for describing architecture at four zoom levels: Context, Container, Component, Code.
**DORA metrics** — Deployment frequency, lead time for change, change failure rate, MTTR.
**Exit criteria** — What must be true before a stage is complete.
**Gate** — An enforced check between stages. Blocking gates stop the pipeline.
**Handoff block** — The fixed-format summary each agent returns; the only thing that enters the orchestrator's context.
**IEEE 29148** — Requirements engineering standard: necessary, unambiguous, singular, verifiable, traceable, feasible.
**IEEE 29119** — Software testing standard covering test plans, design, and execution.
**Mode** — A preset selecting agents, stages, and gate strictness.
**RED / USE** — Rate-Errors-Duration for services; Utilization-Saturation-Errors for resources.
**SLO** — Service Level Objective. The reliability target an error budget is derived from.
**STRIDE** — Threat categories: Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege.
**Verification stamp** — `.devcrew/verify-ok`, written by `devcrew verify`; required by the push gates.

---

*Found a gap in this guide? Open an issue — documentation defects are defects.*
