# Program Board — Orchestrator

**Agent:** `orchestrator` · **Scope:** all 15 pipeline stages across all departments
**Sprint:** `{{S1}}` · **Updated:** 2026-08-09

This is the only board that crosses departments. Department detail lives in `trackers/<dept>.md` — do not duplicate it here.

## Pipeline state — current epic: `{{EPIC}}`

| # | Stage | Owner | Status | Exit criteria met? | Artifact |
|---|---|---|---|---|---|
| 1 | Product Requirement | product-manager | ⬜ | | |
| 2 | PRD / User Stories | product-manager, ux-designer | ⬜ | | |
| 3 | Architecture + ADR | architect | ⬜ | | |
| 4 | Technical Design | tech-lead, ux-designer | ⬜ | | |
| 5 | Development | backend-engineer, frontend-engineer | ⬜ | | |
| 6 | Code Review | code-reviewer | ⬜ | | |
| 7 | Automated Tests | qa-engineer, e2e-automation | ⬜ | | |
| 8 | CI Pipeline | devops-engineer | ⬜ | | |
| 9 | Security / Quality | security-engineer, compliance-officer | ⬜ | | |
| 10 | Staging | devops-engineer, release-manager | ⬜ | | |
| 11 | UAT / Validation | product-manager | ⬜ | | |
| 12 | Production Deploy | release-manager | ⬜ | | |
| 13 | Monitoring | sre-observability | ⬜ | | |
| 14 | Feedback / Metrics | product-manager, sre-observability | ⬜ | | |
| 15 | Next Iteration | orchestrator | ⬜ | | |

Legend: ⬜ not started · 🔵 in progress · ✅ passed · ❌ bounced back · ⏭️ skipped (reason logged in `Changelog.md`)

## Epic queue

| Priority | Epic | RICE | Milestone | Stage reached | Blocked by |
|---|---|---|---|---|---|
| 1 | `{{EP-1}}` | | M1 | 0 | intake questionnaire unanswered |

## Cross-department blockers

| ID | Blocker | Blocks | Owner | Escalated to user? | Since |
|---|---|---|---|---|---|
| B-1 | `/project-init` intake (Project-Plan §0) not answered — no product decisions can be made | all stages | user | yes | 2026-08-09 |

## WIP check (limit 3 per department)

| Dept | In progress | Over limit? |
|---|---|---|
| product | 0 | no |
| design | 0 | no |
| architecture | 0 | no |
| tech-lead | 0 | no |
| backend | 0 | no |
| frontend | 0 | no |
| code-review | 0 | no |
| qa | 0 | no |
| e2e | 0 | no |
| devops | 0 | no |
| security | 0 | no |
| compliance | 0 | no |
| sre | 0 | no |
| release | 0 | no |

## Token ledger (per stage, this epic)

| Stage | Agent(s) | Budget | Actual | Over? |
|---|---|---|---|---|
| | | | | |

Source data: `.claude/state/tokens.jsonl` · render with `/token-report`.

## Sprint summary

| Committed pts | Completed | Carry-over | Deploys | CFR | MTTR | Escaped defects |
|---|---|---|---|---|---|---|
| | | | | | | |

## Retro actions (program level)

| Action | Owner dept | Due | Status |
|---|---|---|---|
| | | | |
