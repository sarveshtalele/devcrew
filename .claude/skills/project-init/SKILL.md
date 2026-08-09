---
name: project-init
description: Bootstrap devcrew into a real project. Interviews the user on product, data, system design, and budget; fills every placeholder; scopes compliance to what the data actually requires; adapts to an existing codebase; seeds the first epic. Run once, before anything else.
disable-model-invocation: true
---

Initialize the project: $ARGUMENTS

**Nothing is assumed.** Every downstream stage inherits these answers, so a wrong assumption here is expensive later. Ask, then build.

## Step 1 — Read the free facts

```bash
cat .devcrew/project-facts.json
```

Written by `devcrew init/add`. It tells you greenfield vs. brownfield, manifests, file counts, test dirs, CI, IaC, existing agent config, and repo age. **Do not re-derive any of this by reading the tree** — it is already computed and costs nothing.

**If brownfield:** you are adapting to a system that exists, not designing one. Additional rules:
- Never propose replacing a working stack. Record what is there in `Project-Context.md` §2 as observed fact.
- Existing `CLAUDE.md` / `AGENTS.md` were preserved by `add`. Merge devcrew's rules into them rather than overwriting; keep the project's own conventions where they conflict with defaults, and note the divergence.
- Start in `lite` or `core`. Retrofitting `full` onto a live codebase generates noise nobody acts on.
- The first epic is a real change the team already wants — not a migration to devcrew's preferences.

## Step 2 — Interview

Use `AskUserQuestion`, batched 4 at a time, in this order. Skip any question `project-facts.json` already answers. Do not interview forever: five batches, then build.

**Batch A — Product**
1. What problem, for whom, and what do they do today without you?
2. What is the single success metric, with baseline and target?
3. What is explicitly out of scope for v1?
4. Hard deadline or event you're tied to?

**Batch B — Users and data** *(this batch decides the compliance regime — get it right)*
5. What are the user roles, and what can each do?
6. Which data classes are handled: none / PII / PHI / cardholder?
7. Expected scale at 12 months: users, requests/sec, data volume?
8. Any data-residency constraint (EU-only, US-only, on-prem)?

**Batch C — Budget and platform** *(ask this before technical design; money constrains architecture)*
9. What is the monthly infrastructure budget?
   - **"Zero / free tier only"** → take the free-tier branch in Step 3.
   - A number → normal cloud selection, with a budget alarm set at 80%.
10. Existing cloud accounts or vendor commitments?
11. Who operates this in production, and are they on call?
12. Is there an AI/LLM component? If yes: which model, and what data reaches the prompt?

**Batch D — System design** *(from `System-Design.md`; ask only what the answers to A–C leave open)*
13. Which quality attribute wins when they conflict — latency, consistency, cost, or availability?
14. Read-heavy, write-heavy, or balanced? (drives caching and replicas)
15. Does any workflow need multi-step coordination or compensation, or is everything a single transaction?
16. What is an acceptable RTO and RPO if the primary datastore is lost?

**Batch E — Delivery**
17. Team size, and which departments are actually staffed?
18. Sprint length and release cadence?
19. Environments available, and who approves production?
20. Any fixed integration or contract you cannot change?

## Step 3 — Platform selection

**If the budget is zero**, use the zero-cost baseline in `System-Design.md` §11 and write `docs/adr/ADR-002-zero-cost-stack.md`. The ADR must record, per component: the chosen free service, **the specific ceiling that ends the free tier**, what happens when it's hit, and the migration path off it. A free tier you outgrow without noticing is an outage.

Default zero-cost shape: GitHub (source, Actions CI, GHCR, Issues, Pages) · Cloudflare Workers/Pages or Fly.io (compute) · Neon or Supabase (Postgres) · Upstash or Cloudflare KV (cache) · Cloudflare R2 (objects, no egress fee) · Sentry free (errors) · Grafana Cloud free or self-hosted Prometheus (metrics) · UptimeRobot (uptime) · gitleaks, semgrep, Dependabot, CodeQL (security, free on public repos).

Set GitHub Actions expectations explicitly: 2,000 free minutes/month on private repos, unlimited on public. Cache aggressively and keep the E2E matrix small, or that is the first wall you hit.

**If there is a budget**, choose the provider from Batch C, apply Well-Architected principles, and set a budget alarm before the first deploy.

## Step 4 — Scope compliance

From the Batch B answer: `PII → GDPR`, `PHI → HIPAA`, `cardholder → PCI DSS`, `SOC 2 always`.

Write `docs/adr/ADR-001-compliance-scope.md` recording which regimes are **out** of scope and why. Then **delete the inactive checklists** from `Project-Context.md` §4.2 — carrying dead controls costs tokens on every session that reads the file.

## Step 5 — Fill and prune

1. Replace every `{{PLACEHOLDER}}` in `Project-Context.md`, `Project-Plan.md`, `Design.md` meta, `Project-Management.md`, and `README.md`. Verify: `rg -n '\{\{' --glob '*.md'`.
2. Prune agents to the staffed departments (Batch E). Fifteen agents on a two-person project is overhead, not rigor: `devcrew mode <name>`.
3. If the brand differs from the default violet→teal, update only the `colors` block in `Design.md` front matter and re-verify AA contrast.
4. Record the Batch D answers in `Project-Context.md` §5 as the NFR budget, and in `System-Design.md` where they pin a design choice.

## Step 6 — Seed and verify

1. Create the first epic in `trackers/00-program-board.md`; move each department's standing setup cards from Backlog to Ready.
2. `bash .claude/hooks/install.sh`
3. `python3 -m json.tool .claude/settings.json > /dev/null`
4. `devcrew doctor` — everything under Required green.
5. Append the init entry to `Changelog.md`; set `Project-Management.md` §1 to `Stage 1`.

## Rules

- Do not write product code in this skill. It ends at a filled-in plan and a seeded board.
- Do not invent answers to skipped questions. An unanswered question blocks stage 1 and is listed as a blocker on the program board.
- Report at the end: active compliance regimes, chosen platform and its cost ceiling, agents pruned, and the first epic.
