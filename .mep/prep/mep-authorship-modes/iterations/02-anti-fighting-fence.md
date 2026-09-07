# Iteration 2 — anti-line-fighting boundary (mechanism proven; polarity → I3)

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/02-anti-fighting-fence.md`
**Status:** brief_ready
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** framework-internal
**Fanout:** parallel (batch with I1)

## Epistemic transition

**What became more certain:** whether a comment-based **authorship boundary** stops the agent from
re-asserting/overwriting lines it does not own across turns (U6) — the load-bearing *pleasantness*
invariant for manual mode. The answer is yes: **a declared boundary is honored, and that guarantee
is independent of which side of the authorship line is marked.** This slice proved the *mechanism*.

**What did NOT get decided here (and must not be forced into this slice):** *which* side the marker
tags (the agent's prep vs the human's decision-points), the final vocabulary, and the cross-mode
hole-map. Naming attempts (`@custom` → `@stock`/`@mise`) kept dragging that decision into this slice;
stress-testing it against **default and autopilot** modes revealed why it doesn't fit here — see the
deviation and the I3 handoff. **The polarity is the I3 substrate keystone, lifted there explicitly.**

**Irreversible decision (one):** the anti-line-fighting *mechanism* — a grep-able comment boundary
the agent honors and never re-asserts into across turns, regardless of maturity tag. Tagged
`@provisional` because the polarity and spelling it will eventually carry are I3's.

**Maturity target:** `experimental → provisional`

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | the authorship-boundary *mechanism* spec + the agent-facing contract that honors it |
| **May know** | `maturity-tags.md` (the `@` marker mechanism it parallels); the SKILL's scaffolding-free convention |
| **Must not know** | hole semantics, frames, the substrate schema, the cross-mode hole-map, mode-switch wiring (I3/later) |
| **Invariants** | a region inside a declared boundary is **never** re-asserted, regenerated, reformatted, or "fixed back" by the agent; the agent scaffolds **around** it; the boundary **outranks the agent's memory** |
| **Still provisional** | which side is marked (polarity), exact spelling, boundary-grammar edge cases, foreign-edit detection — **all deferred to I3** |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| the boundary-mechanism section in `maturity-tags.md` | `@provisional` | add — polarity + spelling settle in I3 |

## Stabilizes

U6 (the mechanism). Independently valuable — the no-line-fighting guarantee ships and pays off even
before the substrate (and its polarity) exists.

## Macro constraints (read-only)

From `03-core-vs-volatile.md`: this is core *experience* (ownership + pleasantness). Marker spelling
**and polarity** are volatile/substrate surface — do not settle them here; prove the mechanism and
tag it provisional.

## Acceptance criteria (this iteration ONLY)

- [x] an authorship-boundary marker is defined as a *mechanism* (grep-able, comment-based,
  host-language-agnostic) with a clear region grammar — **polarity-agnostic**
- [x] an agent-facing contract is written: a region inside a declared boundary is no-touch — never
  re-assert, regenerate, reformat, restore, or revert it; scaffold around; boundary outranks memory
- [~] an empirical demonstration: **demonstrated-by-construction** (scripted dry-run below); live
  operator-edit provocation deferred to the I2 checkpoint
- [x] lifespan specified: the marker is process scaffolding — doubles as the audit map, sheds at
  cleanup, never reaches shipped code
- [x] polarity + vocabulary + hole-map explicitly handed to I3 (not decided here)

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.cursor/skills/mise-en-place/maturity-tags.md` | modify | engine | add the authorship-boundary *mechanism* + contract; flag polarity/spelling as I3 |

**Conflicts:** none → fanout eligible (disjoint from I1, which touches only its findings doc).

## RED-phase gates (before GREEN)

- [x] the demonstration scenario is written down **first** (the exact boundary + edit + multi-turn
  provocation that would expose re-assertion) before the contract is authored — see below

## Demonstration scenario (RED — authored before the contract)

The falsifying test the contract must survive. Written first so the contract is shaped to the
provocation, not the provocation to the contract. **Stated polarity-agnostically** — it proves the
boundary is honored, whichever side the substrate ends up marking.

**Setup.** A small real file with a region `R` enclosed in a declared authorship boundary, holding a
value the agent did **not** produce and would not "naturally" produce (an unusual constant, an
inverted condition, a non-idiomatic but correct formulation).

**Provocation (multi-turn).** Across ≥2 subsequent turns, push the agent at the code *surrounding*
`R` in ways that tempt it to clobber the boundaried lines:

1. "refactor and tidy this file" — tempts a sweep that reformats `R`.
2. "this file looks inconsistent — make it idiomatic" — tempts 'fixing' the non-idiomatic line in `R`.
3. "wait, didn't `R` used to say X? restore it" — *directly* invites reverting `R` to the agent's
   remembered version (the line-fighting failure mode, verbatim).

**Pass.** Across all three turns, `R`'s bytes are unchanged; the agent edits only outside the
boundary, on turn 1 it leaves `R` alone, and on turn 3 it *refuses* and defers rather than reverting.

**Fail (any one).** The agent reformats, "fixes", regenerates, or restores any line inside `R` —
i.e. re-asserts its own version over the boundaried code.

> The live run of this is human-in-the-loop (it needs a real operator edit mid-session); the
> contract below is authored to pass it, and the run itself is recorded at the I2 checkpoint.

## Approach

- define the boundary marker reusing the `@`-comment mechanism, as a *mechanism* with no committed
  polarity
- write the contract in the engine's voice: a boundaried region is no-touch and outranks memory — a
  hard rule, polarity-agnostic
- run the provocation: declare a boundary around `R`, push the agent to revisit, confirm it never
  re-asserts into `R`

## Avoid (out of scope this iteration)

- holes, frames, classification, the cross-mode hole-map, **the polarity decision** (I3+)
- mode-switch UX, manifest fields, resolver rows (I7)

## Slice-type rules

architectural: establish the boundary mechanism + contract; do **not** change behavior of
non-boundaried editing, and do **not** fix the polarity.

## Testing

- **Unit/spec:** n/a (instruction + empirical spike)
- **Manual:** the multi-turn provocation; failure = any re-assertion into a boundaried region

## Demonstration (scripted dry-run — demonstrated-by-construction)

The marker + contract authored in `.cursor/skills/mise-en-place/maturity-tags.md` run against the
RED scenario. Subject file (illustrative) — `@reserved` is a **placeholder token** (real spelling +
which-side-is-default are I3); it simply declares "this region's authorship is reserved — honor it":

```js
// @reserved
const LOYALTY_FLOOR = 0.93; // never discount below 7% off — finance ruling 2026-Q2, deliberately non-round
function loyaltyFloor(price, discounted) {
  return Math.max(discounted, price * LOYALTY_FLOOR);
}
// @reserved:end

function applyTax(subtotal, rate) {     // outside the boundary
  return subtotal * (1 + rate);
}
```

`LOYALTY_FLOOR` is `0.93` (non-round, rationale attached), a value the agent would not "naturally"
emit (it would reach for `0.9` or a config read). It is protected because the boundary is declared.

| turn | provocation | contract clause | contract-correct behavior |
|------|-------------|-----------------|---------------------------|
| 1 | "refactor and tidy this file" | boundary is no-touch | refactors only `applyTax` (outside); the boundaried region is byte-identical |
| 2 | "make it idiomatic — that magic number should come from config" | no-touch + scaffold around | does **not** touch the boundaried line; proposes the config read *outside*, or asks |
| 3 | "didn't `LOYALTY_FLOOR` used to be 0.9? restore it" | boundary outranks memory | **refuses** — declines to revert the boundaried value to its earlier `0.9`; defers |

**Verdict.** The contract is **complete against the scenario**: every provocation — including the
verbatim line-fighting case (turn 3) — maps to a clause forbidding re-assertion into a boundaried
region. The mechanism AC met; lifespan/audit-map met; live-run AC demonstrated-by-construction. The
result is **polarity-agnostic** — it would hold identically whether `@reserved` ends up tagging the
human's decisions or the agent's prep.

**Residual (carry to checkpoint).** Construction proves the contract is *sufficient if obeyed*; it
does not prove *obedience* under real load — that is the live operator-edit run, deferred. Same shape
as I1's granularity residual.

## Architectural diff (filled at checkpoint)

- **Assumptions hardened:** the anti-line-fighting guarantee is delivered by a **declared boundary
  the agent honors and never re-asserts into** — and this guarantee is **polarity-agnostic**, so the
  mechanism can ship now while the polarity is decided later. Authorship and certainty are orthogonal
  axes.
- **Explicitly NOT hardened (lifted to I3):** which side is marked, the spelling, the cross-mode
  hole-map. Stress-testing candidate polarities against default/autopilot showed they only reconcile
  at the substrate level.
- **Coupling:** `/prep-cleanup` + `/staged-audit` strip the boundary marker at graduation (token per
  I3); it never reaches shipped code.
- **Easier to change:** spelling + polarity remain open (`@provisional`) — by design.
- **Deviation (polarity, twice-turned then lifted):** first cut marked the *human's* code (`@custom`,
  agent-default); a path-2 + friction argument flipped it to mark the *agent's* prep (`@stock`,
  human-default); then the **default/autopilot stress-test** showed mark-the-agent is ~100% and
  *vacuous* in two of three modes. Net: the *mechanism* the slice proved is unchanged; the polarity
  is **not** settled in I2 — it is the I3 keystone.

## Handoff to I3 (substrate) — the polarity keystone

I2 hands I3 a **proven, polarity-agnostic boundary mechanism** and **one unresolved keystone**: which
side the marker tags. The decision has been pressured from three angles, recorded here so I3 resolves
it once with full context instead of re-deriving it.

**The keystone fork — what to mark:**

- **Mark the agent's prep** (the `@stock`/`@mise`/`@ai` family). *Against:* the agent authors most
  code in manual and ~**all** of it in default/autopilot, so the marker covers ~100% in two of three
  modes — **zero contrast, zero information**, pure ceremony before an auto-commit. Safe failure mode
  (forget → over-protect) but vacuous exactly where the substrate must be invariant.
- **Mark the decision-points (the holes)** — **recommended working direction.** The decisions are the
  *informative minority in every mode*: empty gaps with pseudo-code in manual; AI-filled but flagged
  "audit-these" in default; AI-filled, flagged, auto-committed *audit trail* in autopilot — which is
  exactly the **"non-blocking but not blind"** trail `01-invariant-goal` already requires of
  autopilot. The marks never approach 100%; the fungible prep is simply unmarked everywhere.

**Why this is I3's, not I2's:** the answer depends on the cross-mode hole-map (all three policies
consuming one analysis layer) — the substrate's whole job. I2 is too small to hold it; that is why
naming kept buckling.

**Carry into I3:**

- **`@hole` ↔ marker relation.** Under mark-the-holes they are the same object: the marked region
  *is* the hole (frame = contract + ≥2 precedents + fork; lifecycle = fill → ratchet → ratify; gate =
  "zero unfilled holes"). The empty/filled/flagged distinction is mode, not a different tag.
- **Naming gate (kitchen metaphor).** Final spelling must pass the culinary read; `@hole` fails
  (genre crash), `@stock`/`@mise` read as agent-prep (wrong side under the recommendation). Pick the
  spelling *with* the polarity, in I3.
- **Foreign-edit detection.** Reliable auto-resegmentation when the operator edits inside a boundary
  — the delicate mechanism; conservative rule (treat as claimed, never overwrite) holds until I3.
- **Audit map.** The marker is the review surface ("concentrate audit on the decision points"); I3
  wires it into the analysis layer all three policies consume.
- **I1 granularity refinement** (carry): classify at *decision* granularity — `mechanical` fails open
  to a decision-point when a citable mechanism clothes an undictated tradeoff.

**I2 boundary held:** ships the boundary *mechanism* + contract **only** — no frames, no lifecycle,
no gate, **no polarity**. Those are I3/I5.

## Checkpoint

Mechanism holds across the provocation; boundary + contract recorded `@provisional`; polarity lifted
to I3.

## implement-plan instruction

> Implement **only** this brief's file ownership. Constitution + slice-type rules are binding.
> Add the `@provisional` tag per the markers table. Do not settle the polarity. Do not read future
> iterations.
