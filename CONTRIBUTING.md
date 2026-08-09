# Contributing to devcrew

Thanks for helping. The kit follows its own rules — that is the main thing to know.

## Ground rules

1. **No AI attribution.** No `Co-Authored-By:` naming an AI, no "Generated with" trailers. You are the author and you are accountable for the change. The `commit-msg` hook enforces this.
2. **Verify before pushing.** `bash tests/cli.test.sh` must pass, and `npm run lint` (shell syntax check) must be clean.
3. **Conventional Commits.** `feat(cli): add uninstall command`
4. **Small PRs.** Under ~400 changed lines. Split anything larger.

## Setup

```bash
git clone https://github.com/sarveshtalele/devcrew && cd devcrew
bash tests/cli.test.sh     # full CLI test suite against a temp directory
npm run lint               # bash -n across every script
```

No build step. Everything is bash, markdown, and JSON.

## Layout

```
.claude/agents/   15 agent definitions (plugin + copied into projects)
.claude/skills/   slash commands
.claude/hooks/    agent hooks + hooks.json for the plugin
modes/modes.json  mode definitions
template/         the payload copied into target projects
bin/devcrew      the CLI
tests/            CLI test suite
```

## What makes a good change

**Agents** — keep them short. Persona, ownership, hard rules, output contract. Every extra line is loaded into that agent's context on every invocation.

**Hooks** — must be deterministic, fast (<200ms), and dependency-free beyond bash and python3. Exit 2 to block, with a message on stderr that says what to do instead. Add a case to `tests/cli.test.sh`.

**Documents** — the same discipline we ask of users: would removing this line cause a mistake? If not, cut it.

**Modes** — a new mode needs a clear "who is this for" that no existing mode covers.

## What is likely to be declined

- Anything requiring a paid service.
- Runtime dependencies beyond bash, git, and python3.
- Instructions that duplicate what a hook already enforces.
- Longer documents without more decisions supported.

## Reporting bugs

Include: OS, bash version, the command, the full output, and what you expected. For hook bugs, include the JSON you piped in.

## Security

Do not open a public issue for an unpatched vulnerability. See [SECURITY.md](SECURITY.md).
