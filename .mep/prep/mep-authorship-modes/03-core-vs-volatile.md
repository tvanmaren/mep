# Core vs volatile — mep-authorship-modes

**Phase:** 3
**Status:** draft
**Builds on:** [02-uncertainty-map.md](./02-uncertainty-map.md)

## Stable core

Harden early. Each needs falsification.

| Item | Layer | Falsification |
|------|-------|---------------|
| Mode = execution policy over a **shared, mode-invariant substrate** (the spine) | contract | a mode requires its own planning artifacts to function |
| Governance×authorship space; 3 occupied corners, the AI-governs/human-types corner stays empty | domain | a mode puts the operator in the code-monkey corner |
| **Path 2:** human-default authorship; AI absorbs a fragment only if it can ground it in a named pattern | domain | a useful mode is built that routes by AI-detected *uncertainty* instead |
| Classifier **fails open to `finish`** on decision-clothed-in-a-known-mechanism (ratified by I1) | domain | a fragment with a citable mechanism but an undictated tradeoff is classified `mechanical` |
| The transcriptionist line is the frame's acceptance test | experience | a frame ships that a transcriptionist could complete unaided |
| Temporal test rule (mechanism-level): no test asserts a **mechanism** before it exists — contract-level acceptance tests precede code (normal TDD red); only *mechanism-level* characterization waits for the code | contract | a mechanism-level assertion is authored before the mechanism |
| Hardening is human-ratified | domain | a characterization assertion is auto-committed unratified |
| `default` stays behavior-compatible with today's model | integration | naming the mode changes current behavior |

## Volatile surface

Keep flexible. Sunset = when it earns permanence.

| Item | Why volatile | Sunset criteria |
|------|--------------|-----------------|
| Marker spelling (`@finish`/`@mise` vs maturity-tag extension) | naming, not semantics | grep + cleanup protocol proven on a real slice |
| manifest field names + resolver row wording | representation detail | resolver re-derivation checks out by hand |
| Frame rendering (criteria format, slot layout) | UX surface | after U3 anchoring trial |
| Autopilot auto-approve mechanism | far-end, unproven | manual substrate proven first |
| Mode-switch surface (manifest default / `/mep` verb / per-slice override) | UX | modes otherwise stable |
| Whether the analysis layer ships standalone first | sequencing | phase 4 |

## Reversible vs irreversible decisions

| Decision | Reversible? | Notes |
|----------|-------------|-------|
| Amend the prime directive → governance×authorship space | one-way | constitution; external mental models will anchor to it |
| The shared-substrate schema, once consumers depend on it | one-way | three policies + other harnesses bind to it |
| Resolver state model (must stay a pure function of state) | one-way | portable-routing + non-Cursor harnesses depend on it |
| Path-2 (human-default) vs path-1 (uncertainty-detect) | one-way-ish | reversing it re-architects manual mode |
| Marker names, frame rendering, mode-switch surface | two-way | cosmetic / swappable |

## Risk / confidence notes

| Area | confidence | falsification |
|------|------------|---------------|
| Shared substrate serves 3 policies (U1) | low | one example slice cannot be driven through all 3 from one artifact |
| Classification reliability (U2) | **ratified (I1)** | residual: granularity — a mechanism-clothed decision read as `mechanical` |
| Frame is non-anchoring (U3) | low | operator reports the fill felt like transcription |
| Anti-fighting fence holds in the real loop (U6) | low–med | agent re-asserts into a fenced region during a spike |

## Layer map

| Layer | Core certainties | Interchangeable |
|-------|------------------|-----------------|
| Experience | non-anchoring frame; fenced regions respected (ownership + pleasantness) | exact prompts, mode-switch surface |
| Domain | mode-space model; mechanical/finish distinction; finish lifecycle | vocabulary, marker names |
| Contract | the shared analysis artifact (slices + classification + frames) | serialization format, marker spelling |
| Persistence | resolver stays a pure fn of state; per-finish status persisted | manifest field names/layout |
| Integration | `default` behavior-compatible; existing `prep→implement→commit→checkpoint` flow unbroken | which command hosts the mode flag |

## Maturity ladder (per subsystem)

| Subsystem | Target this initiative |
|-----------|------------------------|
| mode-space spine (2×2, mode=policy) | `foundational` early — everything depends on it |
| shared-substrate schema | `stable` — hardened contract for this initiative |
| classification rule | `provisional → stable` (proven via U2 back-test) |
| problem-frame form | `provisional` (settles after U3) |
| markers / manifest / resolver wording | `experimental → provisional` |
| anti-fighting fence | `provisional` (separable spike) |
| autopilot path | `experimental` (far end) |

## AD candidates (architectural decisions to record)

- **AD1 — amend the prime directive** to the governance×authorship space (the constitution change).
  *Politically sensitive; one-way.*
- **AD2 — path 2 over path 1:** human-default authorship + justified AI subtraction, not
  uncertainty-detection. (keystone mechanism)
- **AD3 — analysis/execution split** as the architectural spine: one shared substrate, three
  execution policies.
- **AD4 — temporal test rule**: no test asserts a *mechanism* before it exists — contract-level
  acceptance tests precede code (normal TDD red); only *mechanism-level* characterization follows it.
  A framework-wide TDD discipline, not just a manual-mode rule.

`ownedPaths` set in manifest (cleanup ripgrep scope): the mise-en-place engine, the affected driver
commands, and `hooks/**`.
