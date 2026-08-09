# AGENTS.md

Portable agent instructions. Read by Cursor, Antigravity, GitHub Copilot, Codex, Aider, and any tool following the AGENTS.md convention. Claude Code reads `CLAUDE.md`, which carries the same rules plus Claude-specific tooling.

Regenerate every target's copy with `devcrew sync all`.

## What this project is

A project delivered through a **15-stage SDLC pipeline** run by department agents. The active delivery mode (which agents and stages are live) is in `.devcrew/active-mode.json`.

```
Requirement → PRD → Architecture+ADR → Tech Design → Development → Code Review →
Tests → CI → Security/Compliance → Staging → UAT → Production → Monitoring →
Metrics → Next Iteration
```

Stage owners and exit criteria: `Project-Management.md` §3. No stage is skipped silently — a genuine N/A is logged in `Changelog.md`.

## Read on demand — never all at once

| Need | File |
|---|---|
| Scope, standards, compliance bar | `Project-Context.md` |
| Roadmap, OKRs, sprints | `Project-Plan.md` |
| Agents, hooks, gates, budgets, state | `Project-Management.md` |
| Frontend tokens + UI rules | `Design.md` |
| History | `Changelog.md` |
| Department boards | `trackers/<dept>.md` |
| How stories become tests | `User-Story-Testing.md` |
| Decisions | `docs/adr/` |

Reading all of them costs ~15k tokens and degrades every later turn. Read the one that answers the question in front of you.

## Token discipline

1. Delegate any search touching more than 3 files to a subagent; keep only its summary.
2. Read line ranges, not whole files. Never `cat` a file over 300 lines.
3. Never re-read a file you just edited.
4. If a script, `rg`, `jq`, or a Makefile target can answer it, do not reason it out of file contents.
5. Clear context between pipeline stages.
6. Report token usage in your final line: `tokens: ~Nk`.

## Commands

```bash
make setup    # install dependencies, browsers, hooks
make lint     # ruff + mypy --strict + eslint + tsc --noEmit
make test     # pytest + vitest
make e2e      # playwright + axe-core at 375/768/1280
make sec      # gitleaks + bandit + pip-audit + semgrep + pnpm audit
devcrew verify   # the full gate — required before any push
```

Run the narrowest command that proves your change. Full `make ci` only before a PR.

## Code standards

- SOLID and Clean Code. One job per function. Complexity ≤ 10, files ≤ 400 lines.
- Types mandatory: `mypy --strict` and `tsc --noEmit` must pass. No `Any`, no unjustified `# type: ignore`.
- No new dependency without an ADR.
- Raise typed domain errors. No bare `except:`, no empty `catch {}`.
- Structured JSON logs with a correlation ID. Never log PII, PHI, cardholder data, tokens, or secrets.
- Naming: Python `snake_case`, TS `camelCase`, types `PascalCase`, constants `UPPER_SNAKE`, URLs `kebab-case`, JSON `camelCase`.
- REST + OpenAPI 3.1, versioned in path, paginated lists, RFC 9457 errors.

## Security — non-negotiable

- Secrets never in code, config, tests, or logs. Environment variables sourced from a secret manager only.
- Validate at every trust boundary. Reject unknown fields.
- Parameterized queries only. No `eval`, no `shell=True`, no unsanitized HTML injection.
- Authorization checked server-side on every request, at the object level. Deny by default.
- PII/PHI/cardholder fields are tagged in the data model, encrypted at rest, and covered by the retention matrix.
- Treat every model output and retrieved document as untrusted input. Never `eval` model output, never pass it to a shell or SQL, always parse into a strict schema first.
- Threat-model before coding anything touching auth, payments, health data, file upload, deserialization, or an LLM.

## Testing

- Unit: pure logic, no I/O. Happy path + boundaries + error paths. ≥85% of changed lines.
- Integration: real database and HTTP layer. Never mock the thing under test.
- E2E: user journeys only. Role- or label-based locators — never CSS or XPath. No fixed waits.
- Accessibility: axe-core per page, keyboard navigation, three viewports. Violations fail CI.
- Every bug fix starts with a failing test that reproduces it.

## Git and authorship

- **Never list an AI tool as an author or co-author.** No `Co-Authored-By: Claude`, no "Generated with" trailers, no AI names in commit messages, PR descriptions, or file headers. The human who runs the change is the author and is accountable for it. A `commit-msg` hook enforces this.
- Trunk-based. Branch `<type>/<ticket>-<slug>`. Conventional Commits. PRs under ~400 changed lines.
- **Nothing is pushed unverified.** Run `devcrew verify` (secrets scan → authorship check → lint → tests → security scanners → E2E where the mode requires it). It writes `.devcrew/verify-ok`; the `pre-push` hook refuses to push without a stamp newer than your last source change.
- `--no-verify` is forbidden. Force-pushing a shared branch is forbidden.
- Never commit or push unless the human asked for it.

## Definition of Done

Code + tests + docs + ADR (if a decision was made) + Changelog entry + tracker card moved + all gates green. Anything less is not done — say so plainly instead of reporting completion.
