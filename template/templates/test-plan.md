# Test Plan — <Epic>  (IEEE 29119)

**Owner:** qa-engineer · **E2E owner:** e2e-automation

## Scope & items under test
## Test levels & traceability
| REQ | Level (unit/integration/E2E) | Test ID | Owner | Status |
|---|---|---|---|---|

## Approach
- **Unit:** boundaries — empty, one, many, max, max+1, null, wrong type, unicode, negative, zero, duplicate, concurrent, expired, unauthorized, malformed. ≥85% changed-line coverage.
- **Integration:** testcontainers Postgres + Redis, real HTTP layer, no mocking the unit under test.
- **E2E:** journeys + one failure path. Role-based locators, zero fixed waits, self-seeded data.
- **A11y:** axe per page state, keyboard journey, focus trapping, 375/768/1280.
- **Security:** authz bypass as another user, injection, oversized input, missing auth, rate limit, PII/PHI absent from logs and error bodies.

## Environment & data
Synthetic data only. No production PII/PHI in any test environment.

## Entry criteria
## Exit criteria
Coverage met · zero flakes across 3 consecutive runs · all Critical/High defects closed · axe violations zero.

## Risks & contingencies
