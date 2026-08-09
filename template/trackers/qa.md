# Tracker — QA (Unit + Integration)

**Agent:** `qa-engineer` · **Pipeline stages owned:** 7 · **WIP limit:** 3
**Sprint:** `{{S1}}` · **Updated:** 2026-08-09

> Card format: `[ID] title · pts · REQ-### · owner-agent · blocked-by`
> Move a card by cutting the row, never by editing status in place. Every Done card needs a `Changelog.md` entry.

## Definition of Ready
Acceptance criteria written · dependencies identified · data classes declared · sized ≤5 pts · test hook named.

## Definition of Done
≥85% coverage on changed lines · boundaries + error paths covered · integration on real deps via testcontainers · every bug fix has a reproducing test · zero flakes.

## Board

### 📥 Backlog
| ID | Title | Pts | REQ | Notes |
|---|---|---|---|---|
| QA-1 | pytest + vitest harness, coverage gate at 85% | 3 | — | Changed-lines coverage |
| QA-2 | testcontainers Postgres + Redis fixtures | 3 | — | No mocking the DB |
| QA-3 | IEEE 29119 test plan for first epic | 3 | — | `docs/design/test-plan-*.md` |
| QA-4 | Security test pack: authz bypass, injection, oversized input | 5 | — | Runs in CI |

### ✅ Ready
| ID | Title | Pts | REQ | Notes |
|---|---|---|---|---|
| | | | | |

### 🔨 In Progress (max 3)
| ID | Title | Pts | REQ | Started | Blocked by |
|---|---|---|---|---|---|
| | | | | | |

### 👀 Review
| ID | Title | Pts | Reviewer | Findings |
|---|---|---|---|---|
| | | | | |

### 🚫 Blocked
| ID | Title | Blocked by | Escalated | Since |
|---|---|---|---|---|
| | | | | |

### 🎉 Done (current sprint)
| ID | Title | Pts | Changelog | Date |
|---|---|---|---|---|
| | | | | |

## Sprint metrics
| Committed | Completed | Carried over | Cycle time (avg) | Tokens spent |
|---|---|---|---|---|
| | | | | |

## Retro actions
| Action | Owner | Due | Status |
|---|---|---|---|
| | | | |
