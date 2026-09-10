# Event Ledger

The runtime records what it resolves and evaluates. Event classes cover resolver routes,
checkpoint outcomes, lifecycle gates, and review-body readiness. Events are **runtime history, not
current state** — they observe already-derived results and never participate in route derivation.
Current state stays in the plan documents' frontmatter, `.mep/config`, git, and profiles; the ledger is a separate,
append-only log.

## Storage

- **Format:** newline-delimited JSON (JSONL), one event object per line, append-only.
- **Default root:** `.mep/history`, with the ledger at `.mep/history/events.jsonl`.
- **Configurable:** set `storage.historyRoot` in `.mep/config` to relocate the ledger (it follows
  the same convention as `storage.prepRoot` and friends, so a retargeted repo keeps its history
  local and portable). `MEP_HISTORY_ROOT_OVERRIDE` redirects writes for ephemeral/CI/test runs
  without touching config, mirroring `MEP_REPO_ROOT_OVERRIDE`.
- The history root is local runtime data, not tracked state; `.mep/.gitignore` keeps it out of
  commits.

The writer creates the history directory on demand and is non-disruptive when it already exists.

## Envelope

Every event row shares one envelope so future event classes can reuse it without forcing
route-specific fields into every row:

| field | meaning |
|-------|---------|
| `version` | event ledger schema version (currently `1`) |
| `event` | event class name, e.g. `resolver_routed` |
| `id` | reserved, currently `null` — no read/export surface needs it yet |
| `ts` | event time, ISO-8601 UTC |
| `slug` | initiative slug the event was emitted for (nullable) |
| `source` | command/source that emitted the event, e.g. `where` (nullable) |
| `payload` | event-class-specific body |

`version` is the ledger envelope version and is intentionally distinct from `proof.version`, the
resolver proof contract version.

## `resolver_routed` payload

The payload embeds the resolver result rather than recomputing it, so the event can explain the
decision without becoming a second resolver. It carries the resolved `status`, `row`, `state`,
`nextCommand`, and the full machine-facing `proof` object from the resolver contract
(`tools/mep/docs/portable-routing.md`):

```json
{
  "version": 1,
  "event": "resolver_routed",
  "id": null,
  "ts": "2026-06-14T22:00:00Z",
  "slug": "mep-runtime-evolution",
  "source": "where",
  "payload": {
    "status": "ok",
    "row": 7,
    "state": "plan is ready -> build the slice",
    "nextCommand": "/implement-plan wiki/prep/mep-runtime-evolution/iterations/02-resolver-event-primitive.md",
    "proof": {
      "version": 1,
      "api": "where",
      "source": "resolver",
      "row": 7,
      "nextCommand": "/implement-plan wiki/prep/mep-runtime-evolution/iterations/02-resolver-event-primitive.md",
      "facts": { "...": "resolver facts" }
    }
  }
}
```

Embedding the already-derived `proof` keeps the event a faithful, deterministic record of the route
and avoids drift between the resolver decision and its history.

## `checkpoint_evaluated` payload

`tools/mep/bin/mep checkpoint <slug> --json [--fix]` emits one checkpoint event after it has produced
the normal checkpoint JSON packet. The payload records the deterministic result, not a replay of
stdout:

```json
{
  "status": "desync",
  "currentChangeId": "abc123",
  "blockerCount": 0,
  "appliedWritebacks": 0,
  "findingKinds": ["write_implementation_revision", "write_checkpoint_revision"]
}
```

`appliedWritebacks` records how many deterministic writebacks the command applied in that invocation;
`findingKinds` is a compact index of the findings already present in the command output.
Checkpoint events include `currentChangeId` because checkpoint already derives revision context.

## `lifecycle_evaluated` payload

`tools/mep/bin/mep lifecycle status <slug> --mode <mode> --json` emits one lifecycle event after it
has produced the normal lifecycle packet. The payload records existing lifecycle state and gates:

```json
{
  "status": "blocked",
  "mode": "autopilot",
  "canAdvance": false,
  "asksUserMidSlice": false,
  "currentIteration": 3,
  "currentIterationStatus": "brief_ready",
  "currentSliceType": "behavioral",
  "gateCount": 1,
  "gateKinds": ["finish_open"]
}
```

The event mirrors document-backed lifecycle status; it does not create lifecycle concepts or gates.
Lifecycle events omit revision context until the lifecycle packet itself derives one.

## `review_body_validated` payload

`tools/mep/bin/mep pr scaffold <slug> <n> --json` emits one review-body validation event after it
verifies the iteration exists, writes the deterministic PR-body scaffold, and prints the normal JSON
packet:

```json
{
  "status": "ready",
  "iteration": 3,
  "localStatus": "brief_ready",
  "title": "runtime event coverage",
  "briefPath": "wiki/prep/mep-runtime-evolution/iterations/03-runtime-event-coverage.md",
  "bodyStatus": "scaffolded",
  "bodyPath": "wiki/pr-descriptions/mep-runtime-evolution-03-runtime-event-coverage.md",
  "checkKinds": ["iteration_found", "body_scaffolded"]
}
```

The event records the deterministic PR-body readiness result at the scaffold plumbing boundary.
Reviewer-facing prose still lives in the PR description file and is not embedded in the event.
Review-body events omit revision context until the scaffold packet itself derives one.

## Read Surface

`tools/mep/bin/mep events tail --json` reads the local ledger without mutating it. The command returns
a JSON packet with the ledger path, applied filters, match counts, and the latest matching rows:

```bash
tools/mep/bin/mep events tail --json --slug mep-runtime-evolution --event resolver_routed --limit 5 \
  | jq '.events[].payload.nextCommand'
```

Supported filters are deliberately envelope-shaped: `--slug <slug>`, `--event <name>`,
`--version <n>`, and `--limit <n>`. Missing history is an empty `ok` packet with a
`history_missing` warning and does not create the ledger. A ledger path that is not a file
returns `not_found` (exit 3). Malformed JSONL returns `blocked` (exit 2) with
`reason: invalid_ledger` so corruption is visible instead of silently becoming state.

## Scope (this tranche)

The read surface is local and inspectable only. It does not provide analytics, dashboards, reports,
query languages, repair, compaction, rotation, external telemetry, policy schema migration, or
workflow-state inference.
