# Compliance Evidence Log

Append-only. Each row is audit evidence — never delete or rewrite a row; corrections are new rows.

| Date | Regime | Control | Evidence artifact (path/link) | Result | Reviewer |
|---|---|---|---|---|---|
| 2026-08-09 | SOC 2 | Change management — all changes via reviewed PR with green CI | `.github/workflows/ci.yml`, `.github/pull_request_template.md` | pass | compliance-officer |
| 2026-08-09 | SOC 2 | Secure SDLC — documented 15-stage pipeline with gates | `Project-Management.md` §3 | pass | compliance-officer |
| 2026-08-09 | All | Data classification scheme defined | `Project-Context.md` §4.1 | pass | compliance-officer |
| 2026-08-09 | All | Secret handling — scanner in pre-commit and CI | `.pre-commit-config.yaml`, `.claude/hooks/secret-guard.sh` | pass | security-engineer |
