# User-Story-Based Testing

How a user story becomes executable tests in this project. Read this before writing tests; `Project-Context.md` §3 has the standards, this file has the method.

The rule everything follows: **a story is not done because code exists — it is done because the story's acceptance criteria run green in CI.**

---

## 1. The chain

```
REQ-###  →  US-###  →  AC-###  →  test IDs  →  tracker card  →  Changelog entry
```

Every link is checkable, and `docs/prd/traceability.md` holds the matrix. Two failure modes it catches:

- **Orphan requirement** — a `REQ` with no test. Not a requirement, a hope.
- **Orphan test** — a test with no `REQ`. Scope creep, or a test protecting something nobody asked for.

Both are findings at the stage-7 gate.

## 2. Story format

```
US-014
  As a          workspace admin
  I want        to revoke a member's access immediately
  So that       a departing employee loses access before their laptop is returned

  Traces:       REQ-041, REQ-042
  Data classes: PII (member email, name)
  Size:         3 points
  Flag:         feat_instant_revoke
```

A story that cannot name its *so that* is a task, not a story. Send it back.

## 3. Acceptance criteria — Given/When/Then

Each criterion is atomic, observable, and written before implementation.

```gherkin
Feature: Immediate access revocation
  Background:
    Given a workspace "acme" with an admin "ada@acme.test"
    And a member "bob@acme.test" with an active session

  # AC-014-1 — the happy path
  Scenario: Admin revokes a member
    When the admin revokes "bob@acme.test"
    Then the member is removed from the workspace member list
    And the member's existing session is invalidated within 5 seconds
    And an audit event "member.revoked" is recorded with the actor and target

  # AC-014-2 — authorization
  Scenario: A member cannot revoke anyone
    Given the actor is the member "bob@acme.test"
    When they attempt to revoke "carol@acme.test"
    Then the response is 403
    And no audit event is recorded
    And the member list is unchanged

  # AC-014-3 — cross-tenant isolation
  Scenario: An admin cannot revoke outside their workspace
    Given "dana@other.test" belongs to workspace "other"
    When the admin of "acme" attempts to revoke "dana@other.test"
    Then the response is 404
    And "dana@other.test" retains access

  # AC-014-4 — idempotence
  Scenario: Revoking an already-revoked member
    Given "bob@acme.test" has already been revoked
    When the admin revokes "bob@acme.test" again
    Then the response is 200
    And exactly one audit event exists for the revocation
```

### Rules for writing criteria

- **Observable outcomes only.** "The service calls `revoke_session()`" is implementation. "The member's session is invalidated within 5 seconds" is behavior.
- **One assertion of intent per scenario.** Multiple `Then` lines are fine when they describe one outcome; two unrelated outcomes are two scenarios.
- **No UI mechanics in the criterion.** "Clicks the red button in the top right" breaks when the design changes. "Revokes the member" does not.
- **Numbers, not adjectives.** "within 5 seconds", not "quickly".
- **Every story needs at least one negative scenario.** Authorization, validation, or conflict — pick the one that would hurt most.

## 4. Which level tests which criterion

Push every criterion to the cheapest level that can honestly verify it.

| Criterion type | Level | Owner | Example |
|---|---|---|---|
| Business rule, calculation, state machine | **unit** | qa-engineer | revoke is idempotent; expiry boundary at exactly 90 days |
| Persistence, transaction, cross-service contract | **integration** | qa-engineer | session rows deleted; audit event committed in the same transaction |
| The user-visible journey | **E2E** | e2e-automation | admin revokes from the members page and sees it disappear |
| Authorization and tenancy | **integration** (always) + E2E (once) | qa-engineer | 403 for members, 404 across tenants |
| Accessibility | **E2E** | e2e-automation | axe scan, keyboard path, 3 viewports |
| Performance criterion | **load test** | qa-engineer | p95 under 300ms at 100 rps |

**One E2E per journey, not per criterion.** E2E is the slowest and flakiest level; a criterion that a unit test can prove does not get an E2E. If you have 12 E2E specs for one story, the story is being tested at the wrong level.

## 5. Naming and traceability

Test IDs carry the criterion ID, so a failure names the broken promise:

```python
# tests/unit/test_revocation.py
def test_ac_014_4_revoke_is_idempotent() -> None:
    """AC-014-4: revoking an already-revoked member returns 200 and logs once."""
```

```typescript
// tests/e2e/revoke-member.spec.ts
test('AC-014-1: admin revokes a member and the list updates', async ({ page }) => { ... });
```

```
US-014
├── AC-014-1 → test_ac_014_1_revoke_removes_member (unit)
│            → test_ac_014_1_session_invalidated (integration)
│            → AC-014-1 admin revokes a member (e2e)
├── AC-014-2 → test_ac_014_2_member_cannot_revoke (integration)
├── AC-014-3 → test_ac_014_3_cross_tenant_returns_404 (integration)
└── AC-014-4 → test_ac_014_4_revoke_is_idempotent (unit)
```

`docs/prd/traceability.md` is updated in the same PR as the tests. A story whose row is empty does not pass the stage-7 gate.

## 6. Definition of Ready (before coding starts)

- [ ] Story has *as a / I want / so that*, and the *so that* is a real outcome
- [ ] Acceptance criteria written in Given/When/Then, each atomic and observable
- [ ] At least one negative scenario
- [ ] Data classes declared (none / PII / PHI / cardholder)
- [ ] Test level assigned per criterion
- [ ] Test hooks named — what must be injectable, seedable, or freezable
- [ ] Sized ≤5 points
- [ ] Feature flag named

## 7. Definition of Done (before the card moves)

- [ ] Every AC has at least one passing test at its assigned level
- [ ] Each test fails when the implementation is reverted — verified, not assumed
- [ ] Negative scenarios pass
- [ ] Changed-line coverage ≥85%
- [ ] E2E journey green at 375 / 768 / 1280, zero axe violations, keyboard path passes
- [ ] Traceability matrix updated
- [ ] `Changelog.md` entry references the story
- [ ] `devcrew verify` green

## 8. Test data

Each scenario seeds what it needs and cleans up after itself.

```python
# tests/fixtures/stories.py — one builder per story, not one giant fixture
def workspace_with_member(email: str = "bob@acme.test") -> Workspace: ...
```

- **Never** copy production data into a test environment. Synthetic only — this is a hard rule when PII, PHI, or cardholder data is in scope.
- Fixtures use obviously fake values (`@acme.test`, `4242 4242 4242 4242`) so nobody mistakes them for real records.
- Freeze the clock for anything time-dependent. A test that fails at midnight is a flaky test with extra steps.

## 9. Anti-patterns

| Anti-pattern | Why it hurts | Instead |
|---|---|---|
| Tests written after the code | They encode what the code does, not what the story promised | Write criteria first, then tests, then code |
| One E2E per acceptance criterion | Slow, flaky suite nobody trusts | Push down; one E2E per journey |
| Asserting internal calls | Breaks on every refactor, proves nothing | Assert observable outcomes |
| Shared mutable fixtures | Order-dependent failures | Per-test seeding |
| `test.skip` on a flaky spec | The gap is now invisible | Quarantine lane, 5-day fix SLA |
| Criteria written by the implementer alone | The implementer's blind spots become the test suite's blind spots | Product writes them, QA reviews them |
| "It works on my machine" as evidence | Not reproducible | Paste the command and its output |

## 10. Bug reports are stories too

A bug becomes a story with a reproducing scenario, and **the test comes first**:

```gherkin
# BUG-231 → AC-231-1
Scenario: Revoking a member with a pending invite
  Given "erin@acme.test" has been invited but has not accepted
  When the admin revokes "erin@acme.test"
  Then the response is 200
  And the pending invite is cancelled     # currently: invite stays live, access on accept
```

Write it, watch it fail, fix it, watch it pass. A fix without a reproducing test is a guess.
