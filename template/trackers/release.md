# Tracker — Release Management

**Agent:** `release-manager` · **Pipeline stages owned:** 10, 11, 12 · **WIP limit:** 3
**Sprint:** `{{S1}}` · **Updated:** 2026-08-09

> Card format: `[ID] title · pts · REQ-### · owner-agent · blocked-by`
> Move a card by cutting the row, never by editing status in place. Every Done card needs a `Changelog.md` entry.

## Definition of Ready
Acceptance criteria written · dependencies identified · data classes declared · sized ≤5 pts · test hook named.

## Definition of Done
Change record filed · rollback plan written and timed before deploy · canary healthy · approval captured · Changelog + tracker + DORA updated post-release.

## Board

### 📥 Backlog
| ID | Title | Pts | REQ | Notes |
|---|---|---|---|---|
| REL-1 | Change-record template (SOC 2 evidence) | 2 | — | |
| REL-2 | Canary rollout: 10%→50%→100% with watch windows | 3 | — | Deploy ≠ release |
| REL-3 | Rollback runbook + timed rehearsal | 3 | — | Flag flip > revert > redeploy |
| REL-4 | Expand/contract migration policy | 2 | — | Rollback never needs a restore |
| REL-5 | Release calendar rules (no Friday/pre-holiday) | 1 | — | Except active incidents |

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
