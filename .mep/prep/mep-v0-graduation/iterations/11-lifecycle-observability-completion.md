# Iteration 11 — Lifecycle observability completion

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/11-lifecycle-observability-completion.md`  
**Status:** committed  
**Slice type:** behavioral  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential (12 is CONTRIBUTING; files stay disjoint)

## Epistemic transition

**What became more certain:** the event ledger is inspectable history for the four documented classes, not prose in `event-ledger.md`. `where` still does not read it (C8).

**Irreversible decision (one):** v0.1 observability is those four emit sites + `mep events tail --json` filters (`--slug`, `--event`, `--version`, `--limit`). no fifth class, no analytics.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** history ≠ state. append-only JSONL observes already-derived packets; routing/lifecycle/checkpoint remain authoritative without the ledger.

**Instance certainty (this slice only):** hermetic `MEP_HISTORY_ROOT_OVERRIDE` proving emit + tail for `resolver_routed`, `checkpoint_evaluated`, `lifecycle_evaluated`, `review_body_validated`. unix-contract already covers missing/malformed ledger; do not re-own that.

**Acceptance order:** RED (no emit+tail suite for the four classes) before GREEN. do not make the resolver consult the ledger to “fix” a missing event.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/events.sh`; emit call sites already in `resolver.sh` / `checkpoint.sh` / `lifecycle.sh` / `pr.sh` **only if a documented class is silent**; FOSS suite hooked from `run-unix-contract.sh`; `tools/mep/docs/event-ledger.md` **only** to match proven behavior (no new product claims) |
| **May know** | C7, C8, C11; `event-ledger.md` envelope; unix-contract tail not_found/blocked; `MEP_HISTORY_ROOT_OVERRIDE` |
| **Must not know** | new resolver rows; `mep mark` / commit-scope / `mode set` as new event classes; CONTRIBUTING (12); packaging (15); dashboards; vendor telemetry |
| **Invariants** | C7, C8, C9, C10, C11; events never feed `where`; append is best-effort (must not fail the observed command) |
| **Still provisional** | compaction/rotation/repair; remote telemetry |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| emit+tail suite | `@provisional` | add |
| `events.sh` | `@provisional` | keep unless already tagged |

## Stabilizes

Milestone C observability. 12 may assume a stranger can `events tail` a local ledger. 7’s leftover (running proxy) stays out.

## Macro constraints (read-only)

- C8: ledger is not a routing input
- C7: `events tail` envelope/exit already fail-closed on bad ledgers — keep it
- C9: no vendor SDK as the history store
- C10: do not grow litmus to re-prove events
- C11: do not re-prove open-finish readiness

## Acceptance criteria (this iteration ONLY)

- [x] RED: unix-contract covers tail missing/malformed only — no FOSS test asserts the four documented classes append and round-trip through `events tail`
- [x] GREEN: hermetic suite fails if any of the four classes is missing after the matching `--json` verb, or if `--slug` / `--event` / `--limit` filters lie
- [x] envelope fields (`version`, `event`, `id`, `ts`, `slug`, `source`, `payload`) match `event-ledger.md` for those rows
- [x] `rg` of `tools/mep/lib/resolver.sh` shows emit-after-packet only — no ledger read on the `where` path
- [x] `bash tools/mep/test/run-unix-contract.sh` green; golden + stranger + litmus unchanged
- [x] no analytics; no new event class; no 10 suite rewrite

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| hermetic history root + tail filters | `mechanical` | unix-contract events tail packets |
| drive where / checkpoint / lifecycle / pr scaffold | `mechanical` | existing emit call sites |
| hook suite from unix-contract | `mechanical` | `run-mode-resolver.sh` hook |
| whether silent verbs (mark, commit scope, mode) need events | out of scope | documented four classes only |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/test/run-events.sh` | new | integration | emit+tail; name may match house `run-*.sh` |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | hook after existing events tail tests or sibling pass |
| `tools/mep/lib/events.sh` | modify | domain | only if envelope/filter bug |
| `tools/mep/lib/resolver.sh` | modify | domain | **only** if `resolver_routed` is silent |
| `tools/mep/lib/checkpoint.sh` | modify | domain | **only** if `checkpoint_evaluated` is silent |
| `tools/mep/lib/lifecycle.sh` | modify | domain | **only** if `lifecycle_evaluated` is silent |
| `tools/mep/lib/pr.sh` | modify | domain | **only** if `review_body_validated` is silent |
| `tools/mep/docs/event-ledger.md` | modify | integration | match proven behavior; no new claims |

**Conflicts:** sequential vs 12 (CONTRIBUTING). do not take `workflow.sh` / `finish.sh` / `mark.sh`. 10’s `run-mode-resolver.sh` is read-only.

**Explicitly not this slice:** new event classes; dashboards; `where` reading history; README Start here; packaging; live proxy.

## RED-phase gates (before GREEN)

- [x] no suite asserts append of `resolver_routed` / `checkpoint_evaluated` / `lifecycle_evaluated` / `review_body_validated`
- [x] resolver does not read `events.jsonl` (emit-only)

## Approach

1. Prove RED: tail tests exist; emit tests do not.
2. Hermetic history dir; run the four `--json` verbs; `events tail` round-trip with filters.
3. If a documented class is silent: emit after the existing packet (best-effort, same as current `mep_event_append`).
4. Hook unix-contract. do not duplicate golden matrix.
5. Touch `event-ledger.md` only if the suite falsifies a sentence.

## Avoid (out of scope this iteration)

- events as resolver/lifecycle input
- new classes for mark / commit-scope / mode / exec dispatch
- analytics, compaction, repair, remote telemetry
- CONTRIBUTING (12)
- PATH/package (15)
- rewriting 10’s mode-loop
- punching C11

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — documented classes emit and tail filters tell the truth
- [x] **Ownership minimal** — events.sh + one suite + silent-class emit sites only
- [x] **Category before instance** — history ≠ state before a fifth class
- [x] **One place to edit** — `events.sh` is the writer; tests guard it
- [x] **No planned shotgun surgery** — Avoid lists new classes, 12, 15, dashboards
- [x] **Consolidation routing** — 10 was a clean test lock; this is leftover observability, not 10 debt

**Preflight note:** pass — writers already exist; this slice is FOSS proof (and silent-class repair only). four classes already named in `event-ledger.md`. human gate 2026-09-09: keep drafted contract.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| behavioral | four classes round-trip; `where` still ignores the ledger | invent telemetry product; add resolver rows |

## Testing

- **FOSS:** new emit+tail suite; `run-unix-contract.sh`; `run-golden-matrix.sh`; `run-mode-resolver.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** `mep where <slug> --json` then `mep events tail --json --event resolver_routed --limit 1` against a temp history root

## Architectural diff (fill at checkpoint)

- Assumptions hardened: the four documented classes append and round-trip through `events tail` filters; writers were already in `resolver` / `checkpoint` / `lifecycle` / `pr`.
- Coupling increased: `run-unix-contract.sh` now runs `run-events.sh`.
- Harder to change: silently dropping a documented emit site.
- Easier to change: 12 may assume a stranger can `events tail` a local ledger.
- **Promote to core:** none — confirmed C8; no observability C*.
- **Newly interchangeable:** **I16** — `run-events.sh` / `MEP_HISTORY_ROOT_OVERRIDE`.
- **Falsified:** none. the slice was a test lock of already-true emitters (same pattern as 10).

## Checkpoint

**Seam smell test:** category closed as proof, not as new product. `event-ledger.md` was not rewritten. 12 is authoring artifacts, not a fifth event class.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code scope
- [x] `git commit` → `8408fda`
- [x] `/prep mep-v0-graduation checkpoint` → iter 12 brief
- [x] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
