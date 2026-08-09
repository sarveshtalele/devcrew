# Tracker — Security (AppSec + AI)

**Agent:** `security-engineer` · **Pipeline stages owned:** 9 · **WIP limit:** 3
**Sprint:** `{{S1}}` · **Updated:** 2026-08-09

> Card format: `[ID] title · pts · REQ-### · owner-agent · blocked-by`
> Move a card by cutting the row, never by editing status in place. Every Done card needs a `Changelog.md` entry.

## Definition of Ready
Acceptance criteria written · dependencies identified · data classes declared · sized ≤5 pts · test hook named.

## Definition of Done
Threat model current · 0 Critical/High across SAST/SCA/secrets/DAST · every mitigation has a verifying test · LLM guardrails in place where a model call exists.

## Board

### 📥 Backlog
| ID | Title | Pts | REQ | Notes |
|---|---|---|---|---|
| SEC-1 | Threat model (STRIDE) for first epic | 5 | — | Before code, not after |
| SEC-2 | Wire semgrep, bandit, pip-audit, pnpm audit, gitleaks into CI | 3 | — | 0 Critical/High to pass |
| SEC-3 | pre-commit gitleaks hook | 1 | — | Blocks the commit, no --no-verify |
| SEC-4 | ASVS L2 checklist pass | 5 | — | Evidence per control |
| SEC-5 | LLM guardrails: injection framing, output schema, tool allowlist | 5 | — | OWASP LLM Top 10 |
| SEC-6 | Rate limits + token ceilings + cost alarms on model endpoints | 3 | — | Unbounded consumption |
| SEC-7 | Secret rotation policy (≤90d) + break-glass procedure | 2 | — | |

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
