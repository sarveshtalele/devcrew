## What
<!-- One sentence. -->

## Why
<!-- Link REQ-### / ADR-### / tracker card. -->

## Risk
<!-- L/M/H + what could break + blast radius. -->

## Rollback
<!-- Flag flip / revert / redeploy. Decided BEFORE merge. -->

## Checklist
- [ ] `make lint` and the relevant tests pass locally (output pasted below)
- [ ] Tests added; they fail if the change is reverted
- [ ] No secrets, no PII/PHI/CHD in code, logs, or fixtures
- [ ] Data-class annotations added for any new sensitive field
- [ ] Migration reversible (expand/contract), tested both directions
- [ ] `Changelog.md` entry added
- [ ] ADR written if a significant decision was made
- [ ] Diff under ~400 lines
