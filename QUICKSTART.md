# Quickstart — 10 minutes to your first shipped feature

Zero to a running SDLC pipeline. Every command here is copy-pasteable. If something goes wrong, `devcrew doctor` diagnoses it.

---

## 0. Prerequisites (30 seconds)

`git`, `python3`, and a POSIX shell — Git Bash or WSL on Windows. That is all you install by hand.

The token-reduction tools are installed for you when you pick the `optimized` profile in step 2:

| Tool | Repo | Compresses |
|---|---|---|
| caveman | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | what the agent writes |
| rtk | [rtk-ai/rtk](https://github.com/rtk-ai/rtk) | what tool calls return |
| DESIGN.md linter | [google-labs-code/design.md](https://github.com/google-labs-code/design.md) | design values, via `npx` — no install |

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

## 2. Pick a runtime profile

`devcrew init` asks; you can also pass it.

| | Choose `normal` if | Choose `optimized` if |
|---|---|---|
| | You use Cursor, Antigravity, VS Code, or Copilot, or teammates won't install extra tooling | You use Claude Code and context or cost is your binding constraint |
| Installs | none | caveman + rtk (the script does it, after asking) |
| Output | plain prose | caveman-compressed |
| Bash results | full | rtk-filtered |
| Design lint | advisory | blocking |

Choosing `optimized` installs and wires the three tools from step 0, scoped to this project folder.

It detects your platform and picks the right commands: homebrew on macOS, the prebuilt binary or `cargo` on Linux and WSL, scoop or cargo on Windows, and a node install hint matching your package manager (`apt-get`, `dnf`, `pacman`, `zypper`, `apk`, `winget`, `scoop`, `choco`). Git Bash is detected and told to install rtk from PowerShell instead. Full matrix in the [README](README.md#how-the-installer-behaves-per-platform).

Change your mind later: `devcrew profile normal` or `devcrew profile optimized`. Nothing about your code or documents changes.

## 3. Scaffold (1 minute)

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

## 4. Initialize (3 minutes)

Open the project in Claude Code, Cursor, or Antigravity, then:

```
/project-init
```

You'll be asked about the product, your users and data classes, the technical setup, your budget, and delivery cadence. Answer honestly — **the data-class answer decides which compliance regimes activate**, and getting it wrong is the one mistake that's expensive to undo.

If you want a zero-cost stack, say so: there's a free-tier branch that picks GitHub Actions, Cloudflare/Fly/Render free tiers, Neon or Supabase free Postgres, and free-tier observability, then records the choice as an ADR with its ceilings written down.

When it finishes: placeholders filled, compliance scoped via ADR-001, unused agents pruned, first epic on the board.

---

## 5. Build something (the rest of the time)

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

## 6. Ship

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
