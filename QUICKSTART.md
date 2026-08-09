# Quickstart — 10 minutes to your first shipped feature

Zero to a running SDLC pipeline. Every command here is copy-pasteable. If something goes wrong, `devcrew doctor` diagnoses it.

---

## 0. Prerequisites (3 minutes)

You need `git`, `python3`, and a POSIX shell. Then install the two token-reduction tools — **do this first**, they change what everything below costs.

### macOS / Linux / WSL

```bash
# caveman — compresses what the agent writes (~65% fewer output tokens on prose)
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash

# rtk — compresses what the agent reads (up to 90% of bash output)
brew install rtk && rtk init -g
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
scoop install rtk    # or: cargo install rtk
rtk init -g
```

Restart your agent afterward so `rtk init -g` takes effect.

**Using caveman:** it installs as a skill you invoke by name.

| Command | Effect |
|---|---|
| `/caveman` | Turn it on at the default `full` level |
| `/caveman lite` | Professional but tight — keeps full sentences |
| `/caveman ultra` | Maximum compression |
| `/caveman-stats` | Output-token savings this session |
| `/caveman-commit` | Compressed commit message |
| `/caveman-review` | Compressed PR review comments |
| "stop caveman" | Back to normal prose |

Installed to `~/.claude/skills/caveman/` for Claude Code; other agents get their own registry path — see [the caveman INSTALL matrix](https://github.com/JuliusBrussee/caveman/blob/main/INSTALL.md). To make it the default for every session, add a line to `~/.claude/CLAUDE.md`:

```markdown
Invoke the `caveman` skill at the start of every session unless I say otherwise.
```

---

## 1. Install devcrew (1 minute)

```bash
curl -fsSL https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.sh | bash
```

```powershell
irm https://raw.githubusercontent.com/sarveshtalele/devcrew/main/install.ps1 | iex
```

```bash
devcrew doctor
```

Everything under **Required** should be green. Yellow warnings for optional toolchain are fine — `devcrew verify` skips what isn't installed.

---

## 2. Scaffold (1 minute)

### New project

```bash
devcrew init my-app --mode core
cd my-app
```

### Existing project

```bash
cd my-existing-repo
devcrew add . --mode core
```

Nothing you already have is overwritten. Your README, Makefile, CI, and source are untouched; every skipped file is printed. The scan writes `.devcrew/project-facts.json` so agents read your stack instead of rediscovering it.

**Pick a mode by what's at stake**, not by ambition:

| Stakes | Mode |
|---|---|
| Prototype, no users | `lite` (4 agents) |
| Real users, no sensitive data | `core` (7) ← start here |
| Auth, payments, or personal data | `secure` (11) |
| A model call users can reach | `ai` (12) |
| An auditor will read this | `full` (15) |

Change any time: `devcrew mode secure`.

---

## 3. Initialize (3 minutes)

Open the project in Claude Code, Cursor, or Antigravity, then:

```
/project-init
```

You'll be asked about the product, your users and data classes, the technical setup, your budget, and delivery cadence. Answer honestly — **the data-class answer decides which compliance regimes activate**, and getting it wrong is the one mistake that's expensive to undo.

If you want a zero-cost stack, say so: there's a free-tier branch that picks GitHub Actions, Cloudflare/Fly/Render free tiers, Neon or Supabase free Postgres, and free-tier observability, then records the choice as an ADR with its ceilings written down.

When it finishes: placeholders filled, compliance scoped via ADR-001, unused agents pruned, first epic on the board.

---

## 4. Build something (the rest of the time)

```
/feature user-login
```

The orchestrator runs the pipeline: requirement → PRD → architecture → design → code → review → tests → CI → security. You'll see one line per stage and get asked whenever a decision is genuinely yours.

Useful mid-flight:

| Command | When |
|---|---|
| `/scout how does session refresh work` | Before touching unfamiliar code — searches in a subagent so files don't enter your context |
| `/adr <decision>` | Any new dependency, data store, or hard-to-reverse choice |
| `/threat-model <component>` | **Before** coding auth, payments, health data, uploads, or an LLM call |
| `/test-plan <epic>` | Turn acceptance criteria into concrete test tasks |
| `/token-report` | Where your context actually went |

---

## 5. Ship

```bash
devcrew verify && git push
```

`verify` runs secrets → authorship → lint → tests → SAST/SCA → E2E, in that order, and writes `.devcrew/verify-ok`. The `pre-push` hook refuses to push without a stamp newer than your last source change. Edit code after verifying and the stamp goes stale automatically — that's the design, not a bug.

---

## What you just got

- 7–15 specialist agents with isolated contexts and token budgets
- A 15-stage pipeline with exit criteria that are checked, not felt
- Blocking gates: no secrets, no unverified pushes, no AI authorship, no context blowouts
- Kanban boards per department, ADRs, threat models, evidence log
- OWASP ASVS L2, SOC 2 / GDPR / HIPAA / PCI control maps, WCAG 2.2 AA, DORA metrics
- **$0 in tooling**

---

## Next

| | |
|---|---|
| See it work end to end | [Example.md](Example.md) — one story through all 15 stages |
| How stories become tests | [template/User-Story-Testing.md](template/User-Story-Testing.md) |
| System design principles | [template/System-Design.md](template/System-Design.md) |
| Everything else | [Guide.md](Guide.md) |

## If something breaks

```bash
devcrew doctor
```

| Symptom | Fix |
|---|---|
| `devcrew: command not found` | Add `~/.local/bin` to `PATH`, or use `.devcrew/bin/devcrew` |
| Hooks don't fire | `chmod +x .claude/hooks/*.sh`, then restart the agent |
| Push blocked after verifying | You edited `src/` or `tests/` after. Re-run `devcrew verify` |
| Agent ignores instructions | `CLAUDE.md` is too long or context is full. Run `/compact-docs`, or clear context between stages |
| Placeholders still in the docs | Run `/project-init` |

Full troubleshooting: [Guide.md §18](Guide.md#18-troubleshooting).
