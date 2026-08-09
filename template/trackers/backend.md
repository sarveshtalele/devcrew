# Tracker — Backend

**Agent:** `backend-engineer` · **Pipeline stages owned:** 5 · **WIP limit:** 3
**Sprint:** `{{S1}}` · **Updated:** 2026-08-09

> Card format: `[ID] title · pts · REQ-### · owner-agent · blocked-by`
> Move a card by cutting the row, never by editing status in place. Every Done card needs a `Changelog.md` entry.

## Definition of Ready
Acceptance criteria written · dependencies identified · data classes declared · sized ≤5 pts · test hook named.

## Definition of Done
mypy --strict clean · validation at boundaries · authz object-level · no PII/PHI/CHD in logs · migrations reversible both ways · tests green with evidence.

## Board

### 📥 Backlog
| ID | Title | Pts | REQ | Notes |
|---|---|---|---|---|
| BE-1 | FastAPI skeleton + health/ready endpoints | 2 | — | Walking skeleton |
| BE-2 | Structured JSON logging + correlation ID + PII redactor | 3 | — | Redactor reads pii-tagged fields |
| BE-3 | Auth middleware + object-level authz helper | 5 | — | Deny by default |
| BE-4 | Alembic baseline + reversible migration test | 3 | — | Test both directions |
| BE-5 | Secret-manager integration (zero literals) | 2 | — | gitleaks blocks otherwise |

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
