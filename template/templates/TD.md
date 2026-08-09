# Technical Design — <Epic>

**Owner:** tech-lead · **ADRs:** ADR-### · **PRD:** docs/prd/PRD-<epic>.md

## 1. Interfaces
Exact signatures. Endpoints with method, path, request schema, response schema, status codes.

## 2. Data model
| Entity | Field | Type | Nullable | Data class | Index |
|---|---|---|---|---|---|

Migration plan — **forward and reverse**, expand/contract only.

## 3. Error contract
| Failure | Typed error | HTTP | RFC 9457 `type` | Retryable |
|---|---|---|---|---|

## 4. NFR allocation
How the `Project-Context.md` §5 budget splits across components. "p95 300ms" means naming who gets which milliseconds.

## 5. Test hooks
What must be injectable, seedable, or freezable for tests to be deterministic. Decided now, not after the code exists.

## 6. Feature flag
Name · default · removal condition.

## 7. Task breakdown
| Task | Dept | Pts | Acceptance criterion | Test hook | Depends on |
|---|---|---|---|---|---|

Sequence so the walking skeleton ships first.

## 8. Sequence diagram
```mermaid
sequenceDiagram
```
