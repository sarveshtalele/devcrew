---
name: release
description: Run stages 10-12 — staging verification, UAT sign-off, change record, canary production rollout, and rollback readiness. Use when a feature is ready to ship.
disable-model-invocation: true
---

Release: $ARGUMENTS

Delegate to `release-manager`, with `devops-engineer` and `sre-observability` on call.

## Pre-flight (every line must be true, verified not assumed)
- [ ] CI green **on this exact commit** (`gh run list --commit <sha>`)
- [ ] Code review approved; security + compliance gates passed
- [ ] Staging smoke suite green
- [ ] Migrations reversible and rehearsed in both directions
- [ ] Migration is expand/contract — a rollback must never need a data restore
- [ ] Feature flag exists, defaults OFF, with a removal condition
- [ ] Rollback plan written **and timed**; trigger threshold stated numerically
- [ ] SLO dashboards and alerts live for the new paths
- [ ] Change record filed (SOC 2 evidence)
- [ ] On-call informed
- [ ] **Explicit user approval to deploy to production captured**

## Rollout
Deploy → canary 10% → watch error rate, p99, and the business metric for 15 min → 50% → 100% → 24h heightened watch. Flip the flag as a separate event: deploying is not releasing.

## Rollback
Whichever is fastest, decided before deploy: flag flip > revert commit > redeploy previous image.

## Post-release
`Changelog.md` entry with the change-record ID · tracker cards to Done · DORA metrics into `Project-Plan.md` §7 · `Project-Management.md` §1 updated.

**Never** deploy to production without explicit authorization from the user in this session. No Friday or pre-holiday releases unless fixing an active incident.
