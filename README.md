<div align="center">

# devcrew

### Your AI agent writes code. **devcrew makes it ship like a team.**

15 department subagents, a gated 15-stage SDLC pipeline, agile trackers, and security, compliance, and token controls that are shell hooks — not polite suggestions. One command into any project. No paid tools, ever.

[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](LICENSE)
[![Runtime](https://img.shields.io/badge/runtime-bash%20%2B%20python3-black.svg)](#requirements)
[![Agents](https://img.shields.io/badge/agents-15-black.svg)](#the-agents)
[![Modes](https://img.shields.io/badge/modes-5-black.svg)](#delivery-modes)
[![Editors](https://img.shields.io/badge/works%20in-Claude%20Code%20%C2%B7%20Cursor%20%C2%B7%20Antigravity-black.svg)](#works-in-your-editor)
[![Cost](https://img.shields.io/badge/paid%20tools-none-black.svg)](#zero-paid-software)

```bash
curl -fsSL https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.sh | bash
devcrew init my-app --mode core
```

[**Quickstart &rarr;**](QUICKSTART.md) · [See it work](Example.md) · [Guide](Guide.md) · [Modes](#delivery-modes) · [Agents](#the-agents) · [Gates](#gates-that-are-code-not-advice)

</div>

---

## The problem

AI coding agents write code quickly and skip everything around it.

No requirements you can test against. No architecture decision record, so nobody remembers why. No threat model before the auth code. Secrets in a commit. Tests written after the fact that pass whether or not the feature works. A merge with no reviewer that isn't the author. And a context window that fills with files nobody needed, until the agent forgets the instruction you gave it twenty turns ago.

Teams solve this with Jira, Linear, Snyk, SonarQube, Vanta, Datadog — a stack that costs thousands a month and still doesn't tell the agent what to do.

**devcrew puts the process in the repository, where the agent reads it.**

## What it is

A folder you install into any project. It contains:

- **15 department agents** — product, UX, architecture, tech lead, backend, frontend, code review, QA, E2E, DevOps, security, compliance, SRE, release — coordinated by an orchestrator. Each has its own persona, tool allowlist, token budget, and Kanban board.
- **A 15-stage pipeline** from requirement to production to feedback, with named owners and literal exit criteria. Stages cannot be skipped silently.
- **Deterministic gates** as shell hooks, not polite instructions: blocked secrets, blocked unverified pushes, blocked context-blowout reads, blocked AI authorship trailers.
- **Standards baked in** — OWASP ASVS L2, OWASP LLM Top 10, SOC 2, GDPR, HIPAA, PCI DSS, IEEE 29148 requirements, IEEE 29119 testing, ISO/IEC 25010 quality, C4 + ADRs, WCAG 2.2 AA, DORA metrics.
- **Five delivery modes** so a weekend project runs 4 agents and a regulated product runs all 15.
- **Two runtime profiles** — `normal` runs anywhere with zero installs; `optimized` adds caveman, rtk, and a blocking design-token lint, installed for you by one script.
- **A CLI** to install into a new or existing project, switch modes, verify before push, and report token spend.

## Why it's different

| | Typical AI agent setup | Enterprise SaaS stack | **devcrew** |
|---|---|---|---|
| Process | none, or one long prompt | in Jira/Linear, invisible to the agent | in the repo, read by the agent |
| Roles | one generalist agent | human teams | 15 specialists with isolated context |
| Security | "please be secure" | Snyk + Vanta + a consultant | STRIDE + OWASP LLM + blocking hooks |
| Compliance | absent | Vanta / Drata subscription | SOC 2 / GDPR / HIPAA / PCI control maps + evidence log |
| Tests | written when remembered | mandated in a doc nobody reads | required by stage 7 exit criteria |
| Push safety | hope | branch protection you pay for | local gate that blocks unverified pushes |
| Context cost | grows until it breaks | not addressed | per-agent budgets, enforced by hooks |
| Authorship | AI credited as co-author | n/a | blocked at commit-msg |
| Price | — | \$2k–\$10k+/month | **\$0** |

### devcrew vs. Spec Kit vs. OpenSpec

All three exist because prompting an agent straight into code produces the wrong thing. They solve different slices of that.

| | [Spec Kit](https://github.com/github/spec-kit) | [OpenSpec](https://github.com/Fission-AI/OpenSpec) | **devcrew** |
|---|---|---|---|
| **Owner** | GitHub | Fission AI | community |
| **Core idea** | Specifications become executable — spec first, then code | A lightweight planning layer before code, fluid not rigid | The whole lifecycle, with the rules enforced by hooks |
| **Covers** | constitution → specify → plan → tasks → implement → converge | explore → propose → apply → archive | requirement → PRD → architecture → design → code → review → tests → CI → security → staging → UAT → prod → monitoring → metrics |
| **Stops at** | implementation | implementation | production, then feedback into the next iteration |
| **Roles** | one agent, phase by phase | one agent, phase by phase | **15 specialists**, each with isolated context and its own budget |
| **Enforcement** | phase gates in the workflow | convention | **shell hooks with exit codes** — secrets, unverified pushes, AI authorship, and context blowouts are blocked, not discouraged |
| **Review** | — | — | fresh-context `code-reviewer` that never saw the code being written |
| **Security** | — | — | STRIDE threat models, OWASP ASVS L2 + LLM Top 10, SAST/SCA/secrets in CI |
| **Compliance** | — | — | SOC 2 / GDPR / HIPAA / PCI control maps + append-only evidence log |
| **Testing** | tasks may include tests | tasks may include tests | story → acceptance criteria → assigned test level, traceability matrix, axe + keyboard + 3 viewports |
| **Ops** | — | — | SLOs, runbooks, canary + rollback, DORA metrics |
| **Design system** | — | — | DESIGN.md tokens, contrast-linted in CI |
| **Token control** | — | — | per-agent budgets, `token-guard`, `/scout`, `/compact-docs`, measured spend |
| **Brownfield** | supported | a stated design goal | `add` is non-destructive; the repo is scanned into `project-facts.json` |
| **Artifacts** | specs, plans, tasks, checklists | proposals, specs, design, tasks | all of that **plus** ADRs, threat models, test plans, trackers, runbooks, change records, evidence log |
| **Scales down** | phases are fixed | yes, by design | 5 modes, 4→15 agents |
| **Runtime** | Python CLI (`uv`) | Node CLI | bash + python3, no install into your project |

**Honest summary.** Spec Kit and OpenSpec are *specification* tools: they make sure the agent builds the right thing. devcrew is a *delivery* system: it also decides who reviews it, what must be true before it merges, what cannot be pushed, and what has to exist before it reaches users.

If you only want a better plan before coding, those are lighter and you should use them. If your problem is what happens *after* the plan — review, tests, security, compliance, release, on-call — that's the gap devcrew fills. They compose: keep OpenSpec's `openspec/` proposals as your stage-2 artifact and let devcrew run stages 3–15 around them; nothing in the pipeline requires the PRD to come from `product-manager`.

### Zero paid software

Every capability maps to something free and self-hosted:

| Need | Usually | Here |
|---|---|---|
| Issue tracking, sprints | Jira, Linear | Markdown Kanban in `trackers/` |
| Requirements management | Jama, DOORS | IEEE 29148 PRDs + traceability matrix |
| Design system handoff | Figma paid seats | `Design.md` tokens generating Tailwind config |
| SAST / SCA / secrets | Snyk, Checkmarx | semgrep, bandit, pip-audit, gitleaks |
| Compliance automation | Vanta, Drata | control maps + append-only evidence log |
| Test management | TestRail | IEEE 29119 plans + traceable test IDs |
| APM / SLOs | Datadog, New Relic | OpenTelemetry + runbook + SLO templates |
| Architecture governance | LeanIX | C4 diagrams + ADRs in `docs/adr/` |
| Code review | paid review bots | `code-reviewer` agent in a fresh context |

Nothing phones home. Everything is a file you can read, diff, and change.

---

## Requirements

**Required:** `git`, `python3`, and a POSIX shell.

| Platform | Shell | Notes |
|---|---|---|
| macOS, Linux | system `bash` | nothing extra |
| **Windows** | **Git Bash** (ships with Git for Windows) or **WSL** | `install.ps1` detects either and creates a `devcrew`-style shim on your PATH |

Windows needs a POSIX shell because the gates are shell hooks — the same shell git hooks, Claude Code, and Cursor already use there. `install.ps1` fails with the exact `winget` command if neither is present.

Per-stack tooling (`uv`, `pnpm`, `ruff`, `pytest`, `gitleaks`, …) is optional — `devcrew verify` skips what isn't installed and tells you.

### Prerequisites: cut your token bill first

devcrew reduces token use through process discipline — budgets, delegation, on-demand reads. Two external tools cut it further, at a different layer. **Install both before you start.** They are free, local, and open source.

#### 1. caveman — compresses what the agent *writes*

Terse output, byte-exact code and errors. Reports ~65% fewer output tokens on prose, ~8.5% across full agentic runs.

```bash
# macOS / Linux / WSL — requires Node ≥18
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

```powershell
# Windows PowerShell 5.1+
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
```

Levels: `lite`, `full` (default), `ultra`, plus classical-Chinese variants.

| Command | Effect |
|---|---|
| `/caveman` | On, at the default `full` level |
| `/caveman lite` | Tight but keeps full sentences |
| `/caveman ultra` | Maximum compression |
| `/caveman-stats` | Output-token savings this session |
| `/caveman-commit` · `/caveman-review` | Compressed commit messages and PR comments |
| "stop caveman" | Back to normal prose |

Installs to `~/.claude/skills/caveman/` for Claude Code; other agents have their own registry paths ([full matrix](https://github.com/JuliusBrussee/caveman/blob/main/INSTALL.md)). To default it on for every session, add to `~/.claude/CLAUDE.md`: *"Invoke the `caveman` skill at the start of every session unless I say otherwise."*

→ **<https://github.com/JuliusBrussee/caveman>**

#### 2. rtk — compresses what the agent *reads*

A Rust binary that intercepts shell commands and filters their output before it reaches the context: `git status` collapsed by state, test runs reduced to failures, `ls` as a tree with counts. Up to **90% of bash output** removed.

```bash
brew install rtk && rtk init -g
# or
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh && rtk init -g
```

`rtk init -g` installs a hook so Bash calls are rewritten automatically. Check savings with `rtk gain`.
→ **<https://github.com/rtk-ai/rtk>**

Together: **caveman** trims output, **rtk** trims tool results, **devcrew** trims what gets read at all. Different layers, they compose.

Verify all three with `devcrew doctor`.

---

## Quick start

### Install the kit

```bash
curl -fsSL https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.sh | bash
```

```powershell
# Windows PowerShell
irm https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.ps1 | iex
```

<details>
<summary>Other install methods</summary>

```bash
# npx — no global install
npx devcrew init my-app

# git clone
git clone https://github.com/sarveshtalele/devcrew ~/.devcrew
ln -s ~/.devcrew/bin/devcrew ~/.local/bin/devcrew

# Claude Code plugin (agents, skills, and hooks, no CLI)
/plugin marketplace add sarveshtalele/devcrew
/plugin install devcrew
```
</details>

### New project

```bash
devcrew init my-app --mode core
cd my-app
```

Creates the folder, initializes git, installs the payload and both git hooks, prunes agents to the mode.

### Existing project

```bash
cd my-existing-repo
devcrew add . --mode secure
```

**Non-destructive by construction.** Every file that already exists is skipped and printed; `add` only writes what is missing. Your `README.md`, `Makefile`, CI, and source are untouched. An existing `CLAUDE.md` or `AGENTS.md` is preserved — `/project-init` merges devcrew's rules into it rather than overwriting your conventions. `--force` replaces kit-owned files only, never your source.

It also scans the repo once into `.devcrew/project-facts.json` — stack, manifests, test directories, CI, IaC, repo age. Agents read those facts instead of spending 20k tokens rediscovering your stack on every session.

`devcrew init` refuses to run in a non-empty directory and tells you to use `add`, so there is no path where it can clobber an existing project.

Start brownfield projects in `lite` or `core`. Retrofitting `full` onto a live codebase produces findings nobody has time to act on.

### Then

```bash
devcrew doctor        # confirm prerequisites and health
```

Open the project in your agent and run:

```
/project-init          # 16-question intake, fills placeholders, scopes compliance
/feature checkout-flow # drives the feature through every stage of the pipeline
```

Ship it:

```bash
devcrew verify && git push
```

---

## Two axes: mode and profile

They are independent, and the distinction matters.

- **Delivery mode** decides **who works on the code** — which agents exist and which pipeline stages run. Scale it with the stakes.
- **Runtime profile** decides **how the agent runs** — portability versus token cost. Scale it with your tooling.

| | `normal` | `optimized` |
|---|---|---|
| **For** | Cursor, Antigravity, VS Code, Copilot, Codex, mixed teams | Claude Code, or any agent with skills and command hooks |
| **Installs** | nothing | caveman + rtk, by script, after asking |
| **Agent output** | plain prose | caveman-compressed (~65% fewer output tokens on prose) |
| **Tool results** | full | filtered by rtk (up to 90% of bash output) |
| **DESIGN.md lint** | advisory | **blocking** in `make ci` and `devcrew doctor` |
| **Unbounded read ceiling** | 800 lines | 600 lines |
| **Portable configs** | AGENTS.md, Cursor, Antigravity, Copilot | same — portability is never traded away |

Both profiles keep every hook-level control: per-agent budgets, delegated exploration, on-demand reads, fixed handoff blocks. `normal` is not "unoptimized" — it just doesn't require anyone to install anything.

```bash
devcrew init my-app --profile normal        # default
devcrew init my-app --profile optimized     # runs the installer
devcrew profile                             # what's active
devcrew profile optimized                   # switch, any time
```

Run `devcrew init` interactively with no `--profile` and it asks. Non-interactive runs default to `normal` and never install software silently — including the installer itself, which skips every install when there's no terminal unless you pass `DEVCREW_YES=1`.

Switching profiles touches no code, trackers, agents, or documents. It changes how the agent runs, not what it produced.

### What `--profile optimized` actually does

`scripts/setup-optimized.sh` (and `setup-optimized.ps1` on Windows), copied into every project at `.devcrew/bin/`:

1. installs **caveman** if missing — asks first, skips cleanly if node is absent;
2. installs **rtk** via brew, scoop, cargo, or the upstream script, then offers `rtk init -g`;
3. checks **`Design.md`** against Google's linter and reports findings;
4. writes `.devcrew/active-profile.json`, drops the read ceiling to 600 lines, makes `make ci` block on `design-check`, adds `TOKEN-OPTIMIZATION.md`, and points `CLAUDE.md` and `AGENTS.md` at it;
5. verifies all of the above and prints what is still missing.

Idempotent. Re-run it after installing anything it had to skip.

### How the installer behaves per platform

It detects the OS, architecture, and package manager, then picks the right path. Nothing is assumed.

| Platform | devcrew itself | caveman | rtk | Notes |
|---|---|---|---|---|
| **macOS** (Intel / Apple silicon) | `install.sh` | `curl \| bash`, needs node ≥18 | `brew install rtk`, falling back to the upstream script | `brew install node` if node is missing |
| **Linux** (Debian/Fedora/Arch/SUSE/Alpine) | `install.sh` | `curl \| bash`, needs node ≥18 | upstream script → prebuilt binary for your arch; `cargo install rtk` if that fails | node hint matches your package manager: `apt-get`, `dnf`, `pacman`, `zypper`, `apk` |
| **WSL** | `install.sh` | same as Linux | same as Linux | detected via `/proc/version`; treated as Linux, not Windows |
| **Windows PowerShell** | `install.ps1` | `irm … \| iex` | `scoop install rtk`, else `cargo install rtk` | rtk has no MSI or winget package; node hint follows scoop/winget/choco |
| **Windows Git Bash** | `install.sh` | works | **not here** — the script tells you to install rtk from PowerShell | the bash installer detects `MINGW*`/`MSYS*` and says so |

Common to every platform: `git` and `python3` are required, the linter runs through `npx` so it needs no install, and the script is idempotent — re-run it after installing whatever it had to skip. If a binary installs but isn't found afterward, it warns about `~/.local/bin` and `~/.cargo/bin` not being on `PATH`.

Windows needs a POSIX shell for the gates themselves — `install.ps1` finds Git Bash or WSL and writes a shim, and `.gitattributes` pins every script to LF so CRLF never turns a hook into a syntax error.

## Delivery modes

Rigor should match the stakes. Switch any time with `devcrew mode <name>` — agents are added or pruned and gate strictness changes.

| Mode | Agents | Stages | Security | Compliance | E2E | For |
|---|:---:|:---:|:---:|:---:|:---:|---|
| `lite` | 4 | 5 | advisory | off | – | Prototypes, scripts, solo work |
| **`core`** | **7** | **9** | **blocking** | advisory | – | **Default. Most products.** |
| `secure` | 11 | 11 | blocking | advisory | ✓ | User data, money, or auth |
| `ai` | 12 | 13 | blocking | advisory | ✓ | A model call in the critical path |
| `full` | 15 | 15 | blocking | blocking | ✓ | Regulated or audited delivery |

**Core 7:** orchestrator · product-manager · architect · backend-engineer · frontend-engineer · code-reviewer · qa-engineer.

`ai` mode activates the full OWASP LLM Top 10 control set: prompt-injection framing, output schema validation, tool allowlists, scoped agent identities, token ceilings, and guardrail logging.

---

## The agents

Each runs in its own context with its own tools and token budget, and reports back a fixed handoff block — so only a summary reaches the orchestrator, never the files the agent read.

| Agent | Owns | Included in |
|---|---|---|
| `orchestrator` | Routes every stage, enforces gates, talks to you | all |
| `product-manager` | Requirements (IEEE 29148), PRDs, stories, UAT | core+ |
| `architect` | C4 diagrams, ADRs, boundaries | core+ |
| `backend-engineer` | API, domain logic, data access, migrations | core+ |
| `frontend-engineer` | UI from design tokens, a11y | core+ |
| `code-reviewer` | Fresh-context diff review, blocking findings | all |
| `qa-engineer` | Unit + integration tests, IEEE 29119 plans | all |
| `tech-lead` | Interfaces, schemas, error contracts, task sizing | lite, secure+ |
| `e2e-automation` | Playwright journeys, axe-core, keyboard, 3 viewports | secure+ |
| `security-engineer` | STRIDE threat models, OWASP ASVS + LLM, scanner triage | secure+ |
| `devops-engineer` | CI/CD, IaC, reproducible builds, SBOM | secure+ |
| `ux-designer` | Flows, UI specs, design system | ai, full |
| `sre-observability` | SLOs, dashboards, alerts, runbooks, DORA | ai, full |
| `compliance-officer` | SOC 2 / GDPR / HIPAA / PCI controls and evidence | full |
| `release-manager` | Change records, canary rollout, rollback | full |

Agents never call each other. Everything routes through the orchestrator.

---

## The pipeline

```
Product Requirement → PRD / User Stories → Architecture + ADR → Technical Design
   → Development → Code Review → Automated Tests → CI Pipeline
   → Security / Compliance → Staging → UAT → Production Deployment
   → Monitoring → Feedback / Metrics → Next Iteration
```

Every stage has an owner and exit criteria that are checked literally. A stage that genuinely does not apply is logged in `Changelog.md` as `SKIPPED: <stage> — <reason>`. Silence is never a skip.

Small changes take the fast path — stages 5→8 only — unless they touch auth, payments, health data, uploads, deserialization, or an LLM, which are never eligible.

---

## Gates that are code, not advice

Instructions in a markdown file are advisory; an agent under context pressure will drift. These are shell scripts with exit codes.

| Gate | Blocks |
|---|---|
| `secret-guard` | Writing `.env`, keys, or credential-shaped literals; edits to `migrations/`, `infra/prod/`, `.github/workflows/` |
| `push-guard` | `git push` / `gh pr create` without a fresh verification stamp · `--no-verify` · force-push to shared branches · **AI attribution trailers** |
| `token-guard` | Unbounded reads of files over 800 lines, tree-wide greps, `cat`, `find /` |
| `quality-gate` | (warns) Formats and lints the changed file immediately, before CI sees it |
| `session-meter` | Nothing — records per-tool token cost for `devcrew tokens` |
| `commit-msg` | AI co-author trailers, non-conventional commit subjects |
| `pre-push` | Any push whose verification stamp is older than the last source change |

### Nothing ships unverified

```bash
devcrew verify
```

Runs in order — **secrets scan → authorship check → lint and types → unit and integration tests → SAST/SCA → E2E and accessibility** (where the mode requires it). Secrets run first: a leaked credential makes every later result irrelevant.

On success it writes `.devcrew/verify-ok`. Both the git `pre-push` hook and the agent-level `push-guard` refuse to push without a stamp newer than your last change under `src/` or `tests/`. Editing code invalidates the stamp automatically.

### Human authorship

No AI tool is ever credited as an author or co-author. No `Co-Authored-By: Claude`, no "Generated with" trailers, in commits or PR bodies. Enforced at three layers: the agent instructions, the `push-guard` hook, and the `commit-msg` git hook. The human who runs the change is accountable for it.

---

## Token economics

The context window is the binding constraint on agent quality, so the kit treats it as a budget.

- **Per-agent budgets** in `Project-Management.md` §4, enforced by `token-guard` rather than good intentions.
- **Deterministic-first.** If `rg`, `jq`, or a Makefile target can answer it, no agent may reason it out of file contents. A script costs ~0 tokens; reading costs thousands.
- **Delegate, don't read.** Any search across more than 3 files goes to a subagent; only its handoff block returns.
- **Read on demand.** The root documents are never loaded together — that alone is ~15k tokens.
- **Fixed handoff blocks** keep the orchestrator's context flat no matter how many stages run.
- **Measured, not assumed.** `devcrew tokens` reports actual spend by agent and by tool from the session meter.

Three skills do the work directly:

| Skill | Cuts |
|---|---|
| `/scout <question>` | Exploration — searches in a subagent, returns a 6-line answer instead of twelve files. The single biggest win. |
| `/compact-docs` | Standing cost — shrinks `CLAUDE.md` and friends, converts repeated rules into hooks, so every future turn is cheaper |
| `/token-report` | Diagnosis — names the dominant waste pattern and one concrete fix |

Plus `.devcrew/project-facts.json`, written once at install: agents read the stack from there rather than rediscovering it every session.

Layered with **caveman** (output) and **rtk** (tool results), each attacks a different part of the bill.

---

## Works in your editor

| Tool | Support | Reads |
|---|---|---|
| **Claude Code** | full — agents, skills, hooks, plugin | `CLAUDE.md`, `.claude/` |
| **Cursor** | full — rules, docs, CLI gates | `AGENTS.md`, `.cursor/rules/` |
| **Antigravity** | full — docs, CLI gates | `AGENTS.md`, `.agent/` |
| **GitHub Copilot** | instructions + CLI gates | `.github/copilot-instructions.md` |
| **Codex / Aider / Cline / Windsurf** | instructions + CLI gates | `AGENTS.md` |
| **Any other agent** | CLI + git hooks always apply | `AGENTS.md` |

`AGENTS.md` and `CLAUDE.md` carry the same rules. Regenerate every target from one source:

```bash
devcrew sync all
```

Subagent orchestration needs an agent runtime that supports it (Claude Code today). Everywhere else you get the standards, the pipeline, the trackers, and every gate — the CLI and git hooks are editor-independent by design.

---

## CLI reference

```
SETUP
  devcrew init [dir]      Scaffold a new project
  devcrew add  [dir]      Add to an existing project — never overwrites your files
  devcrew doctor          Check prerequisites and installation health
  devcrew uninstall       Remove kit files, leave your source alone

OPERATE
  devcrew mode [name]     Show or switch delivery mode
  devcrew agents          List agents active in the current mode
  devcrew verify          The full gate. Required before push.
  devcrew tokens          Token consumption report
  devcrew sync <target>   Regenerate config for claude | cursor | antigravity | all

OPTIONS
  --mode <name>   --stack <name>   --no-git   --force   -h   -v
```

---

## What gets installed

```
your-project/
├── CLAUDE.md                  # agent instructions (Claude Code)
├── AGENTS.md                  # same rules, portable
├── Project-Context.md         # what this is + which standards bind it
├── Project-Plan.md            # roadmap, OKRs, sprints, risks
├── Project-Management.md      # agents, gates, hooks, budgets, live state
├── Design.md                  # design tokens + UI rules → Tailwind config
├── System-Design.md           # capacity, data, consistency, failure, scaling, cost
├── User-Story-Testing.md      # story → acceptance criteria → tests
├── Changelog.md               # append-only; doubles as SOC 2 change evidence
├── trackers/                  # one Kanban board per department
├── docs/{adr,prd,design,compliance}/
├── templates/                 # PRD, ADR, tech design, threat model, DPIA, runbook…
├── scripts/                   # token report and helpers
├── .claude/{agents,skills,hooks,settings.json}
├── .cursor/rules/             # Cursor
├── .agent/                    # Antigravity
├── .devcrew/                  # mode, verification stamp, project facts, local CLI
├── Makefile                   # setup, lint, test, e2e, sec, ci
├── .github/workflows/ci.yml   # fail-fast pipeline with SBOM
└── .pre-commit-config.yaml    # gitleaks, ruff, large-file and private-key checks
```

<details>
<summary>Layout of this repository (for contributors)</summary>

```
.claude/
├── agents/        15 agent definitions — the canonical source
├── skills/        slash commands
├── hooks/         gate scripts + hooks.json for plugin installs
└── settings.json  the repo runs its own gates on itself
.claude-plugin/    plugin + marketplace manifests, pointing at .claude/
template/          the payload copied into target projects
modes/modes.json   mode definitions
bin/devcrew       the CLI
tests/cli.test.sh  108 assertions across the CLI, hooks, git hooks, plugin schema, and design tooling
```

Agents and skills live in `.claude/` so that opening this repository in Claude Code gives you the full team immediately — no setup step, and one source of truth for both the plugin and the CLI.
</details>

---

## The design system

`Design.md` follows the [DESIGN.md format from Google Labs](https://github.com/google-labs-code/design.md): YAML front matter holds machine-readable tokens, the prose below holds the rationale. Agents read both — the tokens so they produce exact values, the prose so they know when a value applies.

devcrew ships a filled-in system rather than an empty schema: a modern-SaaS palette in **light and dark as equal first-class themes**, an 8-step type scale, 4px spacing grid, 5 elevation levels, and component specs for buttons, inputs, cards, dialogs, toasts, badges, and tables — all at WCAG 2.2 AA.

The important part is that it is **verified, not asserted**:

```bash
make design          # lint, then export tokens.css + tailwind.tokens.json
make design-check    # lint only — runs in CI on every push
```

Under the hood that is Google's linter, no install needed:

```bash
npx -y @google/design.md lint Design.md
npx -y @google/design.md export --format css-tailwind Design.md
npx -y @google/design.md diff Design.md Design-v2.md
```

It checks broken token references, **contrast ratios**, orphaned tokens, unknown keys, missing typography, and canonical section order. A contrast failure fails the build, so "we'll fix accessibility later" never becomes a decision anyone gets to make.

The shipped `Design.md` passes: **0 errors, 0 contrast findings.** Six `orphaned-tokens` warnings remain and are explained in the file — `border`, `borderStrong`, and `focus` (plus dark variants) exist as values but the spec's component sub-tokens (`backgroundColor`, `textColor`, `typography`, `rounded`, `padding`, `size`, `height`, `width`) have no border or outline slot, so nothing can reference them. Running the linter is what found that, and an earlier draft that *looked* conformant but wasn't.

The Tailwind theme is generated from the front matter. `frontend-engineer` is forbidden from transcribing a token value into a component or hand-editing generated files — need a value that doesn't exist, add the token and regenerate. That one rule is why a devcrew UI stays consistent after twenty features.

To use your own brand: edit the `colors` block, run `make design`, fix whatever the contrast rule flags. Nothing else needs to change.

## Documentation

| Document | Read it for |
|---|---|
| **[Guide.md](Guide.md)** | The complete manual — every command, agent, gate, mode, customization, CI integration, and troubleshooting |
| **[Example.md](Example.md)** | One user story walked through all 15 stages, with the real artifacts and the six defects the process caught |
| **[User-Story-Testing.md](template/User-Story-Testing.md)** | How a story becomes executable tests: Given/When/Then criteria, level assignment, traceability, anti-patterns |
| **[QUICKSTART.md](QUICKSTART.md)** | Ten minutes from nothing to a shipped feature |
| **[template/System-Design.md](template/System-Design.md)** | System design end to end — capacity, data, consistency, failure, scaling, cost, and a complete **zero-cost stack** |
| [CONTRIBUTING.md](CONTRIBUTING.md) · [SECURITY.md](SECURITY.md) | Working on the kit itself |

New here? Start with [QUICKSTART.md](QUICKSTART.md), then read [Example.md](Example.md) — it is faster than the Guide and shows what the process is actually for.

---

## FAQ

<details>
<summary><b>Is this only for Claude Code?</b></summary>

No. Subagent orchestration currently needs Claude Code, but the standards, pipeline, trackers, CLI, and git hooks work with any agent or none at all. Cursor and Antigravity read `AGENTS.md` and get everything except automatic agent handoffs.
</details>

<details>
<summary><b>Will 15 agents burn my budget?</b></summary>

That's what modes are for. `core` (7 agents) is the default; `lite` runs 4. Budgets are enforced by hooks, handoff blocks keep the orchestrator's context flat, and `devcrew tokens` shows exactly where spend went. With caveman and rtk installed, a `core` feature typically costs less than an unstructured session that re-reads the same files.
</details>

<details>
<summary><b>Do I have to use all four compliance regimes?</b></summary>

No. `/project-init` asks which data classes you handle and activates only what applies — PII activates GDPR, PHI activates HIPAA, cardholder data activates PCI DSS, SOC 2 is always on. The scope-down is recorded as ADR-001. Carrying regimes you don't need costs tokens every session.
</details>

<details>
<summary><b>Can I add it to a large existing codebase?</b></summary>

Yes — `devcrew add .` is non-destructive and skips every file you already have. Start in `lite` or `core` and scale up when the project earns it.
</details>

<details>
<summary><b>Why block AI attribution?</b></summary>

Accountability. A commit author is who you ask when something breaks in production. Attribution trailers also leak tooling choices into public history and confuse `git blame`. If you want the opposite, delete the check in `template/githooks/commit-msg` — but decide it deliberately.
</details>

<details>
<summary><b>How do I customize the standards?</b></summary>

They're markdown. Edit `Project-Context.md` for standards, `Design.md` for tokens, agent files in `.claude/agents/`, gates in `.claude/hooks/`. Nothing is compiled or hidden.
</details>

---

## Contributing

Issues and pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md). The kit follows its own rules: `devcrew verify` before every push, no AI attribution, conventional commits.

## Security

Report vulnerabilities per [SECURITY.md](SECURITY.md). Do not open a public issue for an unpatched vulnerability.

## License

[MIT](LICENSE). Use it commercially, fork it, ship it.

## Credits

Built to compose with [caveman](https://github.com/JuliusBrussee/caveman) by Julius Brussee and [rtk](https://github.com/rtk-ai/rtk) by the rtk-ai team. Standards from OWASP, NIST, IEEE, ISO, and the C4 model.
