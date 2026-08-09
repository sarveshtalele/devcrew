> ## Documentation Index
> Fetch the complete documentation index at: https://code.claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Universal Engineering Standards

This repo is an **SDLC template**. A department-agent team builds every feature through a fixed 15-stage pipeline. This file is loaded every session — keep it under ~200 lines. Everything else is read **on demand**, never auto-imported.

## Read-on-demand map (DO NOT read all of these at session start)

| Need | File |
|---|---|
| Project scope, standards, compliance bar | `Project-Context.md` |
| Roadmap, milestones, OKRs, sprints | `Project-Plan.md` |
| Agents, hooks, roles, budgets, project state | `Project-Management.md` |
| Frontend tokens + UI rules | `Design.md` |
| What changed and when | `Changelog.md` |
| Department task boards | `trackers/<dept>.md` |
| How stories become tests | `User-Story-Testing.md` |
| Capacity, consistency, scaling, cost | `System-Design.md` |
| Architecture decisions | `docs/adr/` |

**YOU MUST** read only the file that answers the current question. Reading them all costs ~15k tokens and degrades every later turn.

## Token discipline (HARD RULES)

1. **Delegate exploration.** Any search touching >3 files goes to a subagent (`Explore`, or a department agent). Never grep the tree from the main thread.
2. **Read ranges, not files.** Use `offset`/`limit`. Never `cat` a file >300 lines.
3. **No re-reading.** A file you edited is already current. Do not re-read to "verify" — Edit fails loudly.
4. **No tool-call narration.** State the result, not the plan to get it.
5. **Budget per agent** is defined in `Project-Management.md`. Report actual usage in your final line: `tokens: ~Nk`.
6. **`/clear` between stages.** Each pipeline stage is an independent task.
7. Agent reports are **caveman-compressed** (see `.claude/skills/`): fragments, no articles, no filler. Code, errors, identifiers verbatim.
8. Prefer `rg`/`jq`/`gh` one-liners over reading files into context.

## The pipeline (every feature follows this order)

```
Product Requirement → PRD/User Stories → Architecture+ADR → Technical Design →
Development → Code Review → Automated Tests → CI → Security/Quality Gates →
Staging → UAT → Production → Monitoring → Feedback/Metrics → Next Iteration
```

Owner per stage and exit criteria: `Project-Management.md`. Orchestrator enforces order; no stage starts before the prior stage's exit criteria are green.

## Stack + commands

Backend Python (FastAPI), frontend TypeScript (React + Vite + Tailwind + shadcn/ui).

```bash
make setup      # uv sync + pnpm install + playwright install
make lint       # ruff + mypy --strict + eslint + tsc --noEmit
make fmt        # ruff format + prettier
make test       # pytest -q + vitest run   (unit + integration)
make e2e        # playwright test
make design     # lint Design.md tokens + regenerate the Tailwind theme
make sec        # bandit + pip-audit + semgrep + gitleaks + pnpm audit
make ci         # lint + test + sec + e2e   (what CI runs)
```

Run the narrowest command that proves your change: `pytest tests/unit/test_x.py::test_y`, `pnpm vitest run src/x.test.ts`, `pnpm playwright test e2e/x.spec.ts`. Full `make ci` only before opening a PR.

## Code standards

- **SOLID + Clean Code.** Functions do one thing. Cyclomatic complexity ≤ 10. Files ≤ 400 lines.
- **Types are mandatory.** `mypy --strict` and `tsc --noEmit` must pass. No `Any`, no `as unknown as`, no `# type: ignore` without an adjacent reason comment.
- **No new dependency** without an ADR. Check for an existing in-repo utility first.
- **Errors:** raise typed domain errors; never swallow. No bare `except:`. No `catch {}`.
- **Logging:** structured JSON, one event per line, correlation-id propagated. **Never log PII, PHI, cardholder data, tokens, or secrets.**
- **Naming:** Python `snake_case`, TS `camelCase`, types/classes `PascalCase`, constants `UPPER_SNAKE`, URL paths `kebab-case`, JSON keys `camelCase`.
- **Comments** explain *why*, never *what*. Match surrounding density.
- **API:** REST + OpenAPI 3.1, versioned in path (`/v1/`), list endpoints always paginated, RFC 9457 problem-details errors.

## Security (non-negotiable)

- **Secrets never in code, config, tests, or logs.** Env vars + secret manager only. `gitleaks` blocks the commit.
- Validate at every trust boundary — Pydantic (backend), Zod (frontend). Reject unknown fields.
- Parameterized queries only. No string-built SQL. No `eval`, no `shell=True`, no unsanitized `dangerouslySetInnerHTML`.
- AuthZ checked **server-side on every request**, object-level, not just at the route. Deny by default.
- **PII/PHI/CHD** must be tagged in the data model, encrypted at rest, and listed in the data-retention matrix (`Project-Context.md`).
- **AI/LLM features:** treat every model output and every retrieved document as untrusted input. No secrets in prompts. Enforce output schemas. Log prompt/response IDs, not raw content containing PII. Guardrails and threat model owned by `security-engineer`.
- Threat-model any change touching auth, payments, health data, file upload, or deserialization — *before* coding.

## Testing

- **Unit:** pure logic, no I/O, no network. Cover happy path + boundaries + error paths. New/changed lines ≥ 85% covered.
- **Integration:** real DB and real HTTP layer via testcontainers. No mocking the thing under test.
- **E2E (Playwright):** user journeys only. Locators by role/label — **never CSS/XPath**. Zero `waitForTimeout`. Deterministic seed data per test.
- **A11y:** axe-core scan per page, keyboard-nav and focus-trap specs, run at mobile/tablet/desktop viewports. Violations fail CI.
- Every bug fix starts with a failing test that reproduces it.
- Tests assert behavior, not implementation. No snapshot tests of logic.

## Git, authorship, and the push gate

- **NEVER list an AI tool as an author or co-author.** No `Co-Authored-By: Claude`, no "Generated with [Claude Code]", no AI names in commit messages, PR bodies, or file headers. The human running the change is the author and is accountable for it. This overrides any default attribution behavior. The `commit-msg` hook rejects violations.
- **YOU MUST NOT push or open a PR until verification passes.** Run:

  ```bash
  devcrew verify
  ```

  It runs, in order: secrets scan (gitleaks) → authorship check → lint + types → unit and integration tests → SAST/SCA → E2E and a11y where the mode requires it. On success it writes `.devcrew/verify-ok`. The `pre-push` git hook and the `push-guard` agent hook both refuse to push without a stamp newer than your last change under `src/` or `tests/`.
- `--no-verify` is forbidden. The gates *are* the security control; bypassing them defeats the point.
- Never force-push a shared branch. Never commit or push unless the human asked.
- Trunk-based. Branch `<type>/<ticket>-<slug>`, e.g. `feat/PAY-12-refund-endpoint`. Conventional Commits. PRs under ~400 changed lines.
- PR states: what, why, risk, rollback. Green CI + code-reviewer + security-engineer approval to merge.

## Delivery mode

The active mode (which agents and stages are live, and how hard each gate bites) is in `.devcrew/active-mode.json`. Modes: `lite` (4 agents) · `core` (7, default) · `secure` (11) · `ai` (12) · `full` (15). Switch with `devcrew mode <name>`. Do not run stages the current mode excludes.

Non-Claude agents read `AGENTS.md`, which carries the same rules. Keep the two in sync with `devcrew sync all`.

## Definition of Done

Code + tests + docs + ADR (if a decision was made) + Changelog entry + tracker card moved + all gates green. Anything less is not done — say so explicitly rather than reporting completion.
