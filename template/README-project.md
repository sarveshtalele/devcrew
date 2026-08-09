# {{PROJECT_NAME}}

{{ONE_LINER}}

> This project is delivered with [devcrew](https://github.com/sarveshtalele/devcrew) — a department-agent SDLC pipeline with deterministic security, compliance, and token gates. Run `/project-init` in your agent to replace these placeholders.

## Status

| | |
|---|---|
| Stage | see `Project-Management.md` §1 |
| Delivery mode | `.devcrew/active-mode.json` — change with `devcrew mode <name>` |
| Compliance scope | `Project-Context.md` §4 (set by ADR-001) |

## Getting started

```bash
make setup     # dependencies, browsers, git hooks
make test      # unit + integration
make e2e       # Playwright + axe at 375/768/1280
make design    # lint Design.md tokens + regenerate the Tailwind theme
```

## Shipping

```bash
devcrew verify && git push
```

`verify` runs secrets scan → authorship check → lint and types → tests → SAST/SCA → E2E where the mode requires it. The `pre-push` hook refuses any push without a stamp newer than your last source change. `--no-verify` is not an option here.

**No AI tool is ever credited as an author or co-author.** Enforced by the `commit-msg` hook.

## Documentation

| File | Answers |
|---|---|
| `CLAUDE.md` / `AGENTS.md` | How agents work in this repo |
| `Project-Context.md` | What this is and which standards bind it |
| `Project-Plan.md` | Roadmap, OKRs, sprints, risks |
| `Project-Management.md` | Agents, gates, budgets, live state |
| `Design.md` | Design tokens and UI rules ([DESIGN.md format](https://github.com/google-labs-code/design.md), contrast-linted in CI) |
| `System-Design.md` | Capacity, data model, consistency, failure, scaling, cost |
| `User-Story-Testing.md` | Story → acceptance criteria → tests |
| `Changelog.md` | Every change, append-only |
| `trackers/` | One board per department |
| `docs/adr/` | Why things are the way they are |

Read the one that answers your question. Loading all of them costs about 15k tokens.

## Architecture

C4 Context and Container diagrams: `docs/design/c4-*.md`. Decisions: `docs/adr/`.

## Contributing

Trunk-based, Conventional Commits, PRs under ~400 lines stating what, why, risk, and rollback. Every change needs tests, a `Changelog.md` entry, and its tracker card moved. Definition of Done is in `CLAUDE.md`.

## License

{{LICENSE}}
