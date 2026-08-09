# Tracker — DevOps / Platform

**Agent:** `devops-engineer` · **Pipeline stages owned:** 8, 10 · **WIP limit:** 3
**Sprint:** `{{S1}}` · **Updated:** 2026-08-09

> Card format: `[ID] title · pts · REQ-### · owner-agent · blocked-by`
> Move a card by cutting the row, never by editing status in place. Every Done card needs a `Changelog.md` entry.

## Definition of Ready
Acceptance criteria written · dependencies identified · data classes declared · sized ≤5 pts · test hook named.

## Definition of Done
Pipeline green and reproducible · pinned SHAs + lockfiles · SBOM produced · secrets masked and OIDC-federated · staging matches prod except scale and data.

## Board

### 📥 Backlog
| ID | Title | Pts | REQ | Notes |
|---|---|---|---|---|
| OPS-1 | CI workflow: lint→unit→build→sec→integration→e2e→SBOM | 5 | — | Fail fast, cheapest first |
| OPS-2 | Makefile targets (setup/lint/fmt/test/e2e/sec/ci) | 2 | — | Deterministic, token-cheap |
| OPS-3 | Dockerfiles (multi-stage, non-root, pinned base) | 3 | — | Reproducible builds |
| OPS-4 | Terraform baseline + OIDC federation (no static keys) | 5 | — | Least privilege |
| OPS-5 | Staging env with synthetic data only | 3 | — | Never a prod PII copy |
| OPS-6 | CI caching: uv, pnpm, Playwright browsers | 2 | — | CI minutes are a budget |

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
