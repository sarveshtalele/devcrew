# Tracker — Compliance / GRC

**Agent:** `compliance-officer` · **Pipeline stages owned:** 9 · **WIP limit:** 3
**Sprint:** `{{S1}}` · **Updated:** 2026-08-09

> Card format: `[ID] title · pts · REQ-### · owner-agent · blocked-by`
> Move a card by cutting the row, never by editing status in place. Every Done card needs a `Changelog.md` entry.

## Definition of Ready
Acceptance criteria written · dependencies identified · data classes declared · sized ≤5 pts · test hook named.

## Definition of Done
Active regimes determined from data classes · every control has a named evidence artifact · missing evidence = fail · scope-downs recorded as ADRs.

## Board

### 📥 Backlog
| ID | Title | Pts | REQ | Notes |
|---|---|---|---|---|
| CMP-1 | Determine active regimes from declared data classes | 2 | — | PII→GDPR, PHI→HIPAA, CHD→PCI, always SOC 2 |
| CMP-2 | Evidence log `docs/compliance/evidence-log.md` | 2 | — | Date, control, artifact, reviewer |
| CMP-3 | Data-retention matrix + automated deletion job | 5 | — | Per data class |
| CMP-4 | DSAR endpoints: access, rectify, erase, port | 5 | — | GDPR |
| CMP-5 | DPIA for high-risk processing | 3 | — | `docs/design/dpia-*.md` |
| CMP-6 | Vendor/BAA register for PHI processors | 3 | — | HIPAA |
| CMP-7 | PCI scope boundary + tokenization confirmation | 3 | — | PAN never stored |
| CMP-8 | Quarterly access review + backup restore drill | 2 | — | SOC 2 evidence |
| CMP-9 | 72h breach-notification runbook | 3 | — | GDPR |

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
