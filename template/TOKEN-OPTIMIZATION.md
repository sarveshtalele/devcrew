# Token Optimization

Rules that apply **only under the `optimized` runtime profile**. Read once per session, not per turn.

Check which profile is active:

```bash
cat .devcrew/profile          # normal | optimized
devcrew profile               # full detail
```

If it says `normal`, ignore this file — nothing here is installed.

---

## What the profile adds

Three compression layers, each attacking a different part of the bill. They compose; none replaces the others.

| Layer | Tool | Compresses | Typical saving |
|---|---|---|---|
| Output | **caveman** | what the agent writes back | ~65% of prose output; ~8.5% across a full agentic run |
| Tool results | **rtk** | what shell commands return before the model sees them | up to 90% of bash output |
| Design values | **@google/design.md** | design decisions as tokens, not re-derived prose | removes a recurring class of long explanations |

On top of the hook-level controls that run in **both** profiles: per-agent budgets, delegated exploration, on-demand reads, and fixed handoff blocks.

## caveman — output

On by default under this profile. Levels:

| Command | Effect |
|---|---|
| `/caveman` | default `full` — drops articles and filler, keeps every technical term |
| `/caveman lite` | tight but keeps full sentences; use when a human outside the team will read the transcript |
| `/caveman ultra` | maximum compression; use for long mechanical runs |
| `/caveman-stats` | output tokens saved this session |
| `/caveman-commit` | compressed commit message |
| `/caveman-review` | compressed PR review comments |
| "stop caveman" | back to normal prose for the rest of the session |

**Never compressed, at any level:** code, commands, API names, identifiers, error strings, security warnings, irreversible-action confirmations, and multi-step sequences where dropped conjunctions could change the meaning. If compressing a sentence would make it ambiguous, it stays uncompressed — correctness outranks the token count.

Agent handoff blocks are already caveman-shaped by design. Under this profile, prose around them shrinks too.

## rtk — tool results

`rtk init -g` registers a hook that rewrites Bash calls transparently: `git status` collapses by state, test runs reduce to failures with a passing count, `ls` becomes a tree with counts, `git diff` drops headers.

```bash
rtk gain        # what it has saved
rtk discover    # commands you run that it could be filtering but isn't
```

Restart the agent after `rtk init -g` or the hook won't be loaded.

**Watch for:** when you genuinely need full output — reading a specific log line, or a diff you are about to review line by line — call the command directly rather than through the filter. Compressed output you then have to re-fetch costs more than uncompressed output you read once.

## DESIGN.md — design values

Under `normal` the lint is advisory. Under `optimized` it is **blocking**: `make ci` runs `design-check`, and `devcrew doctor` reports findings.

```bash
make design          # lint + regenerate tokens.css and tailwind.tokens.json
make design-check    # lint only
```

The token saving is indirect but real: when colours, spacing, and component values are machine-readable tokens with a linter enforcing them, agents stop re-deriving the design system in prose every time they touch a component, and stop producing near-miss values that then need review comments.

## Tighter read ceiling

`token-guard` blocks unbounded reads above **600 lines** under this profile, versus 800 under `normal`. Use `offset`/`limit`, or delegate:

```
/scout how does session refresh work
```

The ceiling lives in `.devcrew/env` as `DEVCREW_READ_LIMIT`. Raise it if a specific file genuinely needs reading whole, but prefer fixing the reason it does.

## Measuring

```bash
devcrew tokens      # spend by agent and by tool, from the session meter
rtk gain            # bash output filtered
/caveman-stats      # output compression
```

Look at these before optimizing further. The usual dominant waste, in order:

1. Unbounded reads of large files
2. Tree-wide greps that should have been a subagent
3. Re-reading a file that was just edited
4. Loading several standing documents at once
5. Exploration in the main thread instead of `/scout`

Nothing on that list is fixed by caveman or rtk. **They compress the traffic; the hooks and habits reduce it.** If your report shows reads dominating, the tools are not your problem.

## When to use `normal` instead

Switch back with `devcrew profile normal` when:

- Teammates use Cursor, Antigravity, VS Code, or Copilot and won't install extra tooling — the compression layers are Claude-Code-shaped.
- You are onboarding someone and the transcripts need to read naturally.
- You are debugging something subtle and want full, unfiltered tool output.
- You are in a regulated review where compressed prose in the record is a liability.

Switching profiles never touches your code, trackers, agents, or documents. It changes how the agent runs, not what it produced.
