# Threat Model — <Component>

**Owner:** security-engineer · **Date:** · **Reviewed by:** architect

## Data flow & trust boundaries
```mermaid
flowchart LR
```
List every boundary. Threats live on boundaries.

## Assets
| Asset | Data class | Impact if compromised |
|---|---|---|

## STRIDE
| # | Threat | Category | Boundary | Exploit path (concrete) | Existing control | Gap | Mitigation | Verifying test | Severity |
|---|---|---|---|---|---|---|---|---|---|

> A threat with no concrete exploit path is speculation. Cut it.

## LLM controls (if any model call exists — OWASP LLM Top 10)
| Risk | Control | Implemented | Test |
|---|---|---|---|
| Prompt injection (untrusted-data framing, tool allowlist) | | | |
| Insecure output handling (schema-parse before use) | | | |
| Sensitive info disclosure (redact before prompt, filter output) | | | |
| Excessive agency (scoped identity, human confirm) | | | |
| Unbounded consumption (rate + token limits, cost alarm) | | | |
| Supply chain (pinned model IDs, versioned prompts) | | | |
| Data/model poisoning (corpus provenance) | | | |
| Guardrails (input/output classifiers, blocks logged) | | | |

## Residual risk
Accepted by: · Date: · Review date:
