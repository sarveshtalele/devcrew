# Changelog

Every change to this project is recorded here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) + SemVer. Newest first.

**Rules**
- One entry per merged PR or per completed pipeline stage. Written by the agent that did the work, not by the orchestrator.
- Entry format: `- <type>(<scope>): <what changed> — <why> [<agent>] [<REQ-###|ADR-###>] (<PR link>)`
- Types: `feat` `fix` `perf` `refactor` `docs` `test` `build` `ci` `chore` `security` `revert`
- **Security and compliance-relevant changes MUST also state the control affected** — this file doubles as SOC 2 change-management evidence and HIPAA/PCI audit trail.
- Skipped pipeline stages are logged here as `SKIPPED: <stage> — <reason> [orchestrator]`.
- Never rewrite history in this file. Corrections are new entries.

---

## [Unreleased]

### Added
- Project template scaffold: `CLAUDE.md`, `Project-Context.md`, `Project-Plan.md`, `Design.md`, `Project-Management.md`, `Changelog.md` — establishes the SDLC control plane before any code exists [orchestrator]
- 15 department agents in `.claude/agents/` with isolated contexts, tool allowlists, and per-agent token budgets [orchestrator]
- Per-department Kanban+Scrum trackers in `trackers/` [orchestrator]
- Deterministic hook gates: token-guard, secret-guard, quality-gate, session-meter, changelog-nudge [orchestrator]
- Skills: `project-init`, `feature`, `adr`, `threat-model`, `test-plan`, `release`, `token-report` [orchestrator]
- Templates: PRD (IEEE 29148), ADR (MADR), technical design, threat model (STRIDE + OWASP LLM), test plan (IEEE 29119), runbook, DPIA [orchestrator]

### Security
- Baseline set to OWASP ASVS L2 + OWASP LLM Top 10; SOC 2, GDPR, HIPAA, PCI DSS control maps documented in `Project-Context.md` §4 — controls: change management, data classification, secret handling [compliance-officer]

---

<!--
## [1.0.0] - YYYY-MM-DD
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
-->
