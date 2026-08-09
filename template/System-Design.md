# System-Design.md

End-to-end system design principles for this project. `Project-Context.md` says which standards bind us; this file says how to actually design a system against them. Read the section you need — this is a reference, not a session document.

Owned by `architect` and `tech-lead`. Every decision made using it becomes an ADR.

---

## 0. The design sequence

Design in this order. Skipping ahead is how systems get rebuilt.

```
Requirements → Constraints → Capacity → Data model → API contract →
Component boundaries → Consistency model → Failure model → Scaling plan →
Security model → Observability → Cost model → Trade-off record (ADR)
```

Two rules that override everything below:

1. **Design for the load you have plus one order of magnitude — not three.** Building for 100× traffic you don't have costs real money and real complexity today against a benefit that may never arrive.
2. **Prefer the boring, reversible option.** Novelty needs written justification. The cost of a wrong reversible decision is a week; the cost of a wrong irreversible one is a rewrite.

---

## 1. Requirements and constraints

Before any box is drawn, write down:

| | |
|---|---|
| **Functional** | What the system does, as `REQ-###` (IEEE 29148) |
| **Quality attributes** | Latency, availability, durability, consistency, security, cost — with numbers (`Project-Context.md` §5) |
| **Constraints** | Budget, team size, deadline, existing systems, data residency, compliance regime |
| **Assumptions** | Anything you believe but haven't verified. Mark them; they are the risk register |

**Architecture is the sum of quality-attribute trade-offs.** If you cannot name which attributes are driving a decision, you are not designing — you are picking technologies.

## 2. Capacity estimation

Do the arithmetic before choosing anything. Order of magnitude is enough; precision is theatre.

```
DAU × actions/user/day        = requests/day
requests/day ÷ 86,400         = average RPS
average RPS × peak factor 3-5 = peak RPS
records/day × bytes/record    = daily write volume
daily write × retention days  = storage at horizon
read:write ratio              → caching and replica strategy
```

Anchors worth memorizing: an SSD random read ≈ 100µs, a same-region network round trip ≈ 0.5ms, cross-region ≈ 50–150ms, a well-indexed Postgres point read ≈ 1ms, a single Postgres instance handles thousands of simple queries per second. **Most systems are far smaller than their designers assume** — 100 RPS is a real business.

Record the numbers in the ADR. A capacity estimate nobody wrote down gets re-argued every quarter.

## 3. Data model first

The data model outlives every service, framework, and language choice around it. Get it right before writing an endpoint.

- **Model the domain, not the screens.** UI changes quarterly; entities and their relationships do not.
- **Normalize until it hurts, denormalize until it works** — in that order, and only with a measurement in between.
- **Pick the key deliberately.** Natural keys leak business meaning into every foreign key. Prefer opaque IDs (UUIDv7 or ULID — time-ordered, so they index well).
- **Index for your actual queries.** Every index costs write throughput. An unused index is pure loss.
- **Classify every field** — none / PII / PHI / cardholder — and annotate it in code. This drives encryption, logging redaction, and retention (`Project-Context.md` §4.1).
- **Migrations are expand/contract, always.** Add the new column, backfill, dual-write, switch reads, then drop. Never drop-then-add: a rollback must never need a data restore.
- **Soft-delete only where the domain requires it.** Otherwise it's a leak that every future query must remember to filter.

### Choosing a store

| Need | Use |
|---|---|
| Relational data, transactions, most things | **PostgreSQL** — start here, and stay unless measurement says otherwise |
| Cache, rate limits, ephemeral state | Redis |
| Full-text and faceted search | Postgres FTS first; OpenSearch when it genuinely stops being enough |
| Append-only events, replay | Postgres table, then Kafka only at real volume |
| Blobs, uploads, exports | Object storage (S3-compatible) |
| Time-series metrics | Prometheus / TimescaleDB |

Polyglot persistence is a cost — every store is another thing to back up, monitor, secure, and reason about consistency across. Justify each one in an ADR.

## 4. API contract

Contract-first. The contract is the boundary, and boundaries are what make change survivable.

- REST + OpenAPI 3.1 by default. GraphQL when clients genuinely need arbitrary shapes; gRPC for internal high-throughput paths.
- Version in the path (`/v1/`). Never break a published contract — add, deprecate, then remove on a stated timeline.
- **Every list endpoint paginates** from day one. Retrofitting pagination is a breaking change.
- Errors follow RFC 9457 problem+json with a stable `type` URI. Clients branch on `type`, never on message text.
- **Idempotency keys on every non-GET that creates or moves money or state.** Networks retry; your API must tolerate it.
- Validate at the boundary and reject unknown fields. Be strict in what you accept — Postel's law aged badly for security.
- Return the resource state the client needs; don't force an immediate follow-up GET.

## 5. Component boundaries

- **Start as a modular monolith.** One deployable, hard internal module boundaries, one database with per-module schemas. It is faster, cheaper, and easier to split later than to merge back.
- Extract a service only for a real reason: independent scaling, independent deploy cadence, team ownership, or a hard isolation requirement. "Microservices" is not a reason.
- A boundary is defined by **what crosses it and in what format** — not by folder layout.
- Each module owns its data. No other module reads its tables directly; that shared table is the coupling you'll pay for.
- Draw it in C4: Context and Container are mandatory, Component only where non-obvious.

## 6. Consistency and coordination

- **Default to strong consistency inside a single database transaction.** It is the cheapest correctness you will ever get. Reach for eventual consistency only when a boundary forces it.
- Across boundaries, pick deliberately: synchronous call (simple, couples availability) vs. event (decoupled, eventually consistent, harder to debug).
- **The dual-write problem is real:** writing to your DB and publishing an event are not atomic. Use the transactional outbox pattern — write the event to a table in the same transaction, relay it asynchronously.
- Consumers must be idempotent. At-least-once delivery is what you actually get.
- Sagas for multi-step workflows that need compensation. Write the compensating action *before* the happy path.
- Distributed locks are a smell. Prefer a single writer, an optimistic-concurrency version column, or a queue partitioned by key.

## 7. Failure model

Assume every dependency fails. Design what happens when it does — and write it down.

| Pattern | Use |
|---|---|
| **Timeouts** | On every network call. No timeout means unbounded latency and thread exhaustion |
| **Retries with exponential backoff + jitter** | Only for idempotent operations. Bounded attempts — retries amplify outages |
| **Circuit breaker** | Stop hammering a dependency that's already down |
| **Bulkhead** | Separate pools so one slow dependency can't consume every worker |
| **Graceful degradation** | Serve stale cache, hide the feature, queue for later — decide per feature which |
| **Backpressure** | Shed load deliberately (429) rather than collapsing |
| **Dead-letter queue** | Failed messages go somewhere a human can see, never silently dropped |

**Fail closed on authorization and authentication. Fail open on non-critical enrichment.** Getting these backwards is either an outage or a breach.

Single points of failure are acceptable when written down and accepted. Undocumented ones are how a Tuesday becomes an incident.

## 8. Scaling

Scale in this order, and only when a measurement demands it:

1. **Fix the query.** Most "scaling problems" are a missing index or an N+1.
2. **Cache** — with an explicit invalidation strategy. A cache without one is a correctness bug on a delay.
3. **Scale vertically.** Modern hardware is enormous and a bigger instance is far cheaper than a distributed system.
4. **Scale horizontally**, which requires statelessness: no session in memory, no local disk state.
5. **Read replicas** for read-heavy loads — accept the replication lag explicitly, and never read your own write from a replica.
6. **Shard** last. Sharding is a one-way door: pick the key extremely carefully; a bad shard key is a rewrite.

Caching layers, nearest first: client → CDN → application cache → database. Cache the expensive and stable; never cache authorization decisions.

Async everything that the user does not need to wait for: email, thumbnails, exports, webhooks, analytics.

## 9. Security by design

Threat-model at every trust boundary **before** coding (`/threat-model`). The full control set is in `Project-Context.md` §4.

- **Least privilege everywhere** — service identities, database roles, cloud IAM, API scopes.
- **Deny by default.** Authorization is checked server-side on every request at the object level, never only at the route.
- **Defense in depth.** No single control is load-bearing.
- Encrypt in transit (TLS 1.3) and at rest (AES-256). Secrets from a manager, rotated ≤90 days, never in code, logs, or prompts.
- Validate input at every boundary; encode output for its specific sink.
- **Treat every model output and retrieved document as untrusted input.** Parse into a strict schema before use; never eval, never pass to a shell or SQL.
- Rate-limit by identity and by IP. Every expensive endpoint gets a ceiling.
- Audit-log every privileged action with actor, target, and timestamp — in the same transaction as the action itself.

## 10. Observability

Not optional, and not added after launch. Nothing reaches production without all four.

1. **SLIs and SLOs** on user-visible symptoms: availability, latency p95/p99, correctness. Error budget derived from them.
2. **RED** per service (rate, errors, duration) and **USE** per resource (utilization, saturation, errors).
3. **Structured JSON logs**, one event per line, correlation ID propagated end to end. **Zero PII, PHI, or cardholder data in any log field, span attribute, or metric label** — telemetry is the most common leak path.
4. **Distributed tracing** (OpenTelemetry) across every service boundary.

Alert on symptoms users feel, never on causes machines feel. Burn-rate alerts (fast 2%/1h, slow 5%/6h). **Every alert links to a runbook; an alert with no action is deleted, not tuned.**

## 11. Cost model

Cost is a design constraint like latency. Estimate it before building, not after the invoice.

- Estimate monthly spend per component at your capacity numbers. Compute, storage, egress, managed services, and model tokens if there's an LLM.
- **Egress and cross-AZ traffic are the classic surprises.** Check them explicitly.
- Tag every resource by service and environment, and set a budget alarm from day one.
- Prefer managed services when the team is small — the cheapest infrastructure is the kind nobody operates.
- Autoscale down. Idle non-production environments are pure loss; shut them off outside working hours.
- **For LLM features:** cost per request × requests, per-user token ceilings, cheaper models for simple steps, cache what repeats.

### Zero-cost baseline

A complete, production-capable stack on free tiers — the default when the project's budget is zero:

| Need | Free option | Ceiling to watch |
|---|---|---|
| Source, CI/CD, registry | GitHub + Actions + GHCR | 2,000 Actions minutes/month on free |
| Issues, boards | GitHub Issues + Projects, or the in-repo `trackers/` | — |
| App hosting | Cloudflare Workers/Pages · Fly.io · Render · Railway | cold starts, hours/month |
| Postgres | Neon · Supabase · Railway | storage cap, compute suspend |
| Redis / KV | Upstash · Cloudflare KV | commands/day |
| Object storage | Cloudflare R2 (no egress fee) · Backblaze B2 | GB stored |
| Auth | Supabase Auth · Auth0 free · your own OIDC | MAU cap |
| Email | Resend · Brevo free tier | sends/day |
| Errors | Sentry free | events/month |
| Metrics + dashboards | Grafana Cloud free · Prometheus self-hosted | series/retention |
| Uptime | UptimeRobot · GitHub Actions cron | check interval |
| Status page | GitHub Pages | — |
| Secrets | GitHub Actions secrets + the platform's env store | — |
| Security scanning | gitleaks, semgrep, bandit, pip-audit, Dependabot, CodeQL | all free for public repos |
| Docs | GitHub Pages / the repo itself | — |

**Record the ceilings in the ADR alongside the choice.** A free tier you outgrow without noticing becomes an outage, and every one of these has a migration path — the point is to know which wall you hit first and what it costs to cross it.

## 12. Trade-off record

Every significant decision becomes an ADR (`/adr`) with real alternatives, honest consequences, and what would change your mind. The purpose is not process — it is so that in eighteen months, when the constraint has changed, someone can tell whether the decision is still right.

---

## Design review checklist

Run before an architecture is accepted:

- [ ] Quality attributes named with numbers, and the trade-offs between them stated
- [ ] Capacity estimated and written down
- [ ] Data model reviewed; every field classified; migrations expand/contract
- [ ] API contract defined, versioned, paginated, idempotent where it matters
- [ ] Component boundaries drawn in C4; each module owns its data
- [ ] Consistency model explicit at every boundary; no dual writes
- [ ] Every dependency has a timeout, a retry policy, and a defined degraded mode
- [ ] Single points of failure identified and accepted in writing
- [ ] Scaling path known, with the trigger that starts it
- [ ] Threat model complete; authorization object-level and deny-by-default
- [ ] SLOs, dashboards, alerts, and a runbook exist **before** traffic
- [ ] Monthly cost estimated; budget alarm set; free-tier ceilings recorded
- [ ] ADRs written for every irreversible choice
