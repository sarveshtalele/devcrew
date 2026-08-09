---
name: compact-docs
description: Shrink the project's markdown documents so every future session costs less. Use when CLAUDE.md drifts past ~200 lines, when agents start ignoring rules, or after a sprint of accumulated edits.
disable-model-invocation: true
---

Compact: $ARGUMENTS (default: `CLAUDE.md`, `AGENTS.md`, and the four root documents)

**Why.** `CLAUDE.md` is loaded on every single turn. A line that earns nothing costs tokens forever. And a bloated instruction file causes the *important* rules to be ignored, so bloat is a correctness problem, not just a cost one.

## Procedure

1. **Measure first.**

   ```bash
   wc -l CLAUDE.md AGENTS.md Project-Context.md Project-Plan.md Project-Management.md Design.md
   ```

2. **Apply the deletion test to every line.** *Would removing this cause an agent to make a mistake?* If not, delete it. Specifically cut:
   - Anything the model already does correctly without being told ("write clean code", "handle errors").
   - Standard language conventions — PEP 8 and Airbnb style do not need restating.
   - Anything a hook already enforces deterministically. A rule duplicated by `secret-guard` is dead weight; the hook cannot be ignored and the sentence can.
   - Long rationale. Keep the rule, move the reasoning to an ADR.
   - File-by-file descriptions of the codebase — that is what `.devcrew/project-facts.json` and reading the code are for.
   - Anything that has changed twice this month. Volatile facts belong in the trackers, not in instructions.
3. **Convert, don't just delete.** A rule that keeps being violated should become a hook. A rule that is only relevant sometimes should become a skill. Both remove it from every-turn context.
4. **Compress what survives.** Tables over prose. Fragments over sentences. One line per rule.
5. **Verify behavior did not change.** Re-read the diff and name, for each deleted line, why its absence is safe. If you cannot, put it back.
6. **Record** the before/after line counts in `Changelog.md`.

## Targets

| File | Ceiling | Why |
|---|---|---|
| `CLAUDE.md` / `AGENTS.md` | ~200 lines | loaded every turn |
| Agent definitions | ~60 lines | loaded on every invocation of that agent |
| `Project-Context.md` | ~250 lines | read on demand, but read often |
| Skills | ~80 lines | loaded when invoked |

## Do not

- Do not delete a security, compliance, or authorship rule to save tokens. Those are the ones worth paying for.
- Do not compress `Changelog.md`, ADRs, or the evidence log — they are records, not instructions, and they are never auto-loaded.
- Do not "compress" by moving text into a file that gets imported anyway. That is the same tokens with extra steps.
