---
name: threat-model
description: STRIDE + OWASP LLM threat model for a component. Run BEFORE coding anything touching auth, payments, health data, file upload, deserialization, or a model call.
---

Threat-model: $ARGUMENTS

Delegate to the `security-engineer` agent. Output to `docs/design/threat-model-<component>.md` from `templates/threat-model.md`.

1. **Draw the boundaries.** Data flow diagram: entities, processes, stores, and every trust boundary crossed. Threats live on boundaries.
2. **STRIDE per boundary** — Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege.
3. **Per threat**: asset at risk · entry point · concrete exploit path · existing control · gap · mitigation · **the test that proves the mitigation**. A threat without an exploit path is speculation — cut it.
4. **Data classes**: which PII/PHI/CHD crosses which boundary, and is it encrypted, minimized, and absent from logs?
5. **If an LLM is involved**, add the OWASP LLM Top 10 pass: prompt injection (untrusted-data framing, tool allowlist), insecure output handling (schema-parse before use), sensitive disclosure (redact before prompt), excessive agency (scoped identity, human confirm on irreversible actions), unbounded consumption (rate + token limits), supply chain (pinned model IDs), poisoning (corpus provenance), guardrails (input/output classifiers with logged blocks).
6. **File every unmitigated gap** as a card in `trackers/security.md` with a severity. Nothing gets closed by assertion.

Rank by exploitability × impact. Fix Critical and High before stage 10.
