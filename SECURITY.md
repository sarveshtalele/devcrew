# Security Policy

## Reporting a vulnerability

**Do not open a public issue for an unpatched vulnerability.**

Use GitHub's private vulnerability reporting (Security → Report a vulnerability) on this repository.

Include: affected version or commit, reproduction steps, impact, and any suggested fix.

**Response targets:** acknowledgement within 3 business days · assessment within 7 days · fix or mitigation for Critical and High within 30 days. We will credit you in the release notes unless you prefer otherwise.

## Scope

**In scope**
- The CLI (`bin/devcrew`) and the installer (`install.sh`)
- Hook scripts under `hooks/` and `template/githooks/` — especially any bypass of `secret-guard`, `push-guard`, or the commit-msg authorship check
- Command injection through file paths, mode names, or tool input
- Any path where the kit could exfiltrate repository contents or credentials

**Out of scope**
- Vulnerabilities in projects *generated* by the kit (that is your code — the kit provides gates, not guarantees)
- Issues in caveman, rtk, or any AI agent — report those upstream
- Missing hardening that is documented as a deliberate trade-off

## Design notes for reviewers

- The kit runs entirely locally and makes no network calls after installation.
- Hooks parse tool input with `python3 -c` reading stdin; they never `eval` tool input.
- `install.sh` clones over HTTPS and writes only to `$DEVCREW_HOME` and `$DEVCREW_BIN`.
- The `verify` gate is a defense in depth, not a substitute for branch protection and code review.

## Supported versions

The latest minor release receives security fixes.
