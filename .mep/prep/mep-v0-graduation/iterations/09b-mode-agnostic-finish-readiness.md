# Iteration 9b — Mode-agnostic finish readiness

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/09b-mode-agnostic-finish-readiness.md`  
**Status:** committed  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** `@finish:open` is one mode-agnostic readiness fact. every emitter blocks on it; authorship mode changes the gate actor/action, not whether work is ready.

**Irreversible decision (one):** absent/default/manual/autopilot all treat an open finish as uncommittable and uncheckpointable.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** one predicate in `finish.sh` selects open markers. resolver, required writebacks, lifecycle, checkpoint, and commit scope consume that fact.

**Instance certainty (this slice only):** the existing workflow fixture becomes a four-mode matrix. absent mode is tested separately because it is the engine default seam.

**Acceptance order:** default/absent RED before helper extraction; all emitters green before iter 10.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/finish.sh`; `tools/mep/lib/resolver.sh`; `tools/mep/lib/workflow.sh`; `tools/mep/test/run-manual-workflow.sh`; stale default-mode assertions in `tools/mep/test/run-mark.sh`; `run-unix-contract.sh` only if its existing hook is absent |
| **May know** | C7, C8, C9; I11 grammar; 6/7 lifecycle action differences; checkpoint finish writebacks |
| **Must not know** | new resolver rows; live proxy dispatch; event ledger (11); README onboarding (9); packaging (15) |
| **Invariants** | mode may change `gate`, `action`, `asksUserMidSlice`, and ratification provenance; mode may not change open-finish readiness |
| **Still provisional** | live proxy execution; final helper name |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| open-finish predicate | `@provisional` | helper is first shared readiness seam |
| workflow stop | `@provisional` | rewrite durable meaning: any mode |
| workflow fixture | `@provisional` | keep; expand to absent/default |

## Stabilizes

Blocks iteration 10. mode-invariant `where` is credible only after all readiness emitters share the same fact.

## Macro constraints (read-only)

- C7: blocked JSON exits 2
- C8: `where` row/packet remains row-derived
- C9: no model call
- I11: only language-comment markers count

## Acceptance criteria (this iteration ONLY)

- [x] RED: absent `authorshipMode` + `@finish:open` made `mep commit scope` return `ok` / exit 0
- [x] `finish.sh` owns the open-marker predicate; resolver no longer owns a duplicate scanner
- [x] absent/default/manual/autopilot all route `where` to row 8 on the same open-finish state
- [x] absent/default/manual/autopilot all block `commit scope` with `reason=finish_open`, exit 2
- [x] lifecycle blocks open finishes in every mode; default/manual use human action, autopilot uses proxy action
- [x] checkpoint blocks open finishes in every mode
- [x] done removes the gate for covered manual/autopilot paths
- [x] marker suite no longer canonizes permissive default commit scope
- [x] no resolver row/evaluation-order change; no event or live-driver growth

## Finish-map

| fragment | class | cited pattern |
|----------|-------|---------------|
| filter marker list to `state=open` | `mechanical` | existing `mep_finish_required_writebacks_json` filter |
| make commit scope consume `finish_open` independent of mode | `mechanical` | checkpoint already treats the writeback as mode-agnostic |
| four-mode fixture matrix | `mechanical` | `run-manual-workflow.sh` manual/autopilot cases |

No new finish: feedback exposed an invariant violation, and existing checkpoint behavior supplies the precedent.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/finish.sh` | modify | domain | one open-marker predicate |
| `tools/mep/lib/resolver.sh` | modify | domain | consume shared predicate; remove duplicate |
| `tools/mep/lib/workflow.sh` | modify | integration | remove manual/autopilot condition |
| `tools/mep/test/run-manual-workflow.sh` | modify | integration | absent/default + all-emitter matrix |
| `tools/mep/test/run-mark.sh` | modify | integration | replace stale permissive-default assertion |

**Conflicts:** resolver/finish/workflow are one readiness seam; sequential.

## RED-phase gates

- [x] absent-mode commit scope exits 0 with `@finish:open`
- [x] explicit default has the same hole

## Approach

1. Change the absent/default fixture expectation and prove RED.
2. Extract open-marker selection into `finish.sh`.
3. Route resolver and required-writeback counting through it.
4. Remove the mode condition from commit scope.
5. Matrix `where`, lifecycle, scope, and checkpoint; preserve mode-specific action fields.

## Avoid

- changing resolver rows
- erasing mode-specific provenance checks
- merging iter 10 docs-layer work into this fix
- new suite when the existing workflow fixture is the natural home
- event ledger, live proxy, README, packaging

## Brief preflight

- [x] **Single purpose** — one readiness fact across emitters
- [x] **Ownership minimal** — three consumers + existing fixture
- [x] **Category before instance** — shared predicate before iter-10 invariance prose
- [x] **One place to edit** — `finish.sh`
- [x] **No planned shotgun surgery** — no rows/events/docs chrome
- [x] **Consolidation routing** — corrective architectural slice; iter 10 stays queued

**Preflight note:** pass — this is the prerequisite exposed by external review, not an expansion of iter 10.

## Testing

- **Focused:** `bash tools/mep/test/run-manual-workflow.sh`
- **FOSS:** `bash tools/mep/test/run-unix-contract.sh`; `bash tools/mep/test/run-golden-matrix.sh`
- **Static:** `shellcheck` on changed shell files

## Architectural diff (fill at checkpoint)

- Assumptions hardened: `@finish:open` is one readiness fact in `finish.sh` (`mep_finish_open_markers_json` / `mep_finish_has_open`). `where`, required writebacks, lifecycle, checkpoint, and commit scope consume it. authorshipMode may change `gate` / `action` / `asksUserMidSlice` / ratification provenance only.
- Coupling increased: every readiness emitter now depends on that helper; a second open-marker scanner is a bug.
- Harder to change: treating absent/default as exempt from `finish_open` (the 6/7 hole).
- Easier to change: 10 can prove `where` packet identity on a *non-open* row without re-gating commit scope.
- **Promote to core:** **C11** — `@finish:open` is a mode-agnostic readiness blocker.
- **Newly interchangeable:** **I14** — helper names / whether consumers call `mep_finish_has_open` vs filter `requiredWritebacks` for `kind=finish_open`.
- **Falsified:** iter 6 amendment that default `commit scope` stays `ok` with open finishes. no C7–C10 falsified.

## Checkpoint

**Seam smell test:** category closed — absent/default/manual/autopilot all block scope and checkpoint; `where` row 8 on the same open-finish fixture; lifecycle still human vs proxy.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code scope (`52bb530`)
- [x] `git commit`
- [x] `/prep mep-v0-graduation checkpoint` → restore iter 10 as current (triplet: impl preceded brief)
- [x] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Do not read future iterations.
