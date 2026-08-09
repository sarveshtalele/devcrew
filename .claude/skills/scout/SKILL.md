---
name: scout
description: Answer a codebase question by delegating the search to a subagent, so only the answer enters the main context — not the files. Use before any change to unfamiliar code, and instead of grepping the tree yourself.
---

Investigate: $ARGUMENTS

**Why this exists.** Exploration is the single largest source of wasted context. Reading twelve files to answer one question costs 15–40k tokens and leaves all twelve in your window for the rest of the session. A subagent reads them in its own context and returns six lines.

## Procedure

1. **Check the cheap sources first.** In order, stop as soon as one answers it:
   - `.devcrew/project-facts.json` — stack, manifests, test dirs, CI, size. Already computed, costs nothing.
   - `docs/adr/` — if the question is "why", the answer is probably already written down.
   - `rg -l '<symbol>' --glob '!node_modules'` — file list only, not contents.
2. **Then delegate.** One subagent, scoped narrowly:

   > Search only `<paths>`. Answer exactly: `<question>`. Return the handoff block — file:line references and a ≤6-line answer. Do not paste file contents.

3. **Parallelize independent questions** in a single message. Three subagents at once cost the same wall-clock as one.
4. **Record the answer** where it belongs — an ADR if it is a decision, `Project-Context.md` if it is a standing fact. A question answered twice is a documentation defect.

## Rules

- Never run a tree-wide `grep`/`rg` for content from the main thread. `token-guard` blocks the worst of it; this skill is the alternative.
- Scope every search to a directory. "Search the repo" is not a scope.
- Ask one question per subagent. A subagent asked three things returns a summary of a summary.
- Reject file dumps. If a subagent returns 200 lines of source, the prompt was wrong — re-ask with "file:line references only".

## Output

```
ANSWER: <≤6 lines>
EVIDENCE: <file:line, file:line>
CONFIDENCE: high | medium | low — <what would raise it>
TOKENS: ~Nk (subagent), ~Nk (returned)
```
