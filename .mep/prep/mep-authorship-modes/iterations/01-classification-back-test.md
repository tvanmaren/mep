# Iteration 1 — classification back-test (spike)

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/01-classification-back-test.md`
**Status:** brief_ready
**Slice type:** architectural
**Mode:** exploration
**Delivery track:** framework-internal
**Fanout:** parallel (batch with I2)

## Epistemic transition

**What became more certain:** whether the mechanical-vs-hole classification rule is reliable enough
on real code to make manual mode *useful* rather than busywork.

**Irreversible decision (one):** ratify **AD2 (path-2)** — adopt human-default authorship + justified
AI subtraction — on back-test evidence, or pivot back to phase 2.

**Maturity target:** `experimental → provisional` (the classification rule)

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | the back-test method + findings doc for this slice |
| **May know** | a real merged host-prototype PR diff (candidate: **TICKET-2210** host-feature prototype, a merged host PR); the path-2 rule from `03-core-vs-volatile.md`; `02-uncertainty-map.md` U2 |
| **Must not know** | the substrate schema, marker spelling, any engine change (future iterations) |
| **Invariants** | the rule under test, stated exactly: *a fragment is `mechanical` iff AI can cite an existing named pattern (profile house-pattern, or a concrete in-repo precedent) it instantiates; otherwise it is a `hole`* |
| **Still provisional** | the rule itself — this slice may falsify it |

## Epistemic markers (`@` tags)

None — this slice retains no code; it produces a findings document only.

## Stabilizes

The keystone U2. Gates whether the rest of the initiative proceeds as designed.

## Macro constraints (read-only)

From `03-core-vs-volatile.md`: path-2 is core; routing by AI-detected *uncertainty* (path-1) is
explicitly rejected. The guard against U2's "confidence illusion" is **back-test evidence, not AI
introspection.**

## Acceptance criteria (this iteration ONLY)

- [x] a representative real melt PR is selected and its decision-points identified independently of the rule (where did a human actually have to decide something?)
- [x] the classification rule is applied across that PR's fragments, each labeled `mechanical` or `hole` with the cited pattern (or its absence) recorded
- [x] a confusion table is produced: holes-flagged vs decisions-actual (hits, false-mechanical, false-hole)
- [x] a verdict: does the rule flag holes at the real decisions with a tolerable false-mechanical rate? → **ratify or kill AD2**

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.mep/prep/mep-authorship-modes/iterations/01-classification-back-test.md` | modify | (findings) | append a "## Findings" section with the confusion table + verdict |

**Conflicts:** none → fanout eligible (disjoint from I2).

## RED-phase gates (before GREEN)

- [x] decision-points of the chosen PR are enumerated **before** running the rule (so the rule can't be fit to them post-hoc)

## Approach

- pick the PR; read its diff; list where a human had to make a call (auth, query shape, business rule, naming-that-encodes-a-decision)
- run the rule fragment-by-fragment; for each `mechanical` label, write down the pattern cited
- tabulate; compute false-mechanical rate (decisions the rule wrongly absorbed — the dangerous error)

## Avoid (out of scope this iteration)

- designing the substrate, markers, or any engine change
- writing retained code — this is a non-retained knowledge spike

## Slice-type rules

architectural: validate the rule's invariant; do **not** change any user-visible framework behavior.

## Testing

- **Unit/spec:** n/a (spike)
- **Manual:** the confusion table IS the test; false-mechanical is the failure signal

## Findings (implement — spike result)

**Corpus:** TICKET-2210 host-feature prototype (a merged host PR, ~60 files). Representative sample across
zones: backend domain read (`listSourceLots/index.js`), facade/mock
(`hostFeatureMockApi.js`), presentational control (`SampleBanner.vue`).
**Method:** decision-points enumerated independently *before* the rule (RED gate honored); rule then
applied fragment-by-fragment; compared.

### Decision-points (enumerated before the rule)

- backend read: bar-level metal derivation (not `lot.primaryMetal`); `paidMetals` pushed into a SQL
  subselect "to keep pagination honest"; purity emitted raw `DECIMAL(5,4)`, normalization deferred to
  FE; Pt/Pd omitted v0 → `'pt'` short-circuits empty; `settledAt = updatedAt` proxy;
  `allocatedHostEntityId` join + cancelled-release design; pins emitted only when `> 0`.
- mock: stateless principle (vuex owns persisted state); create-validation rules; `nextCode`
  caller-provided to avoid reload collisions; the v1-swap endpoint contract.
- presentational: ~none (slot-for-page-context is the only micro-composition choice).

### Classification vs reality (confusion)

| | rule said **mechanical** | rule said **hole** |
|---|---|---|
| **actually a decision** | **D2 — SQL pushdown, at coarse granularity** | D1, D3–D7, D9–D12 |
| **actually mechanical** | M1–M10 (parse/clamp/convert helpers, microservice wiring, clone/delay, v-alert chrome) | ~none |

- false-**hole** (safe — human glances at something trivial): ~0
- false-**mechanical** (dangerous — AI silently authors a decision): **one nameable class**, not random.

### The dangerous error is a single, nameable shape

Every false-mechanical risk is the same: a fragment where a *citable mechanism* (`Sequelize.literal`
subselect, a sequelize `include`, a clone-join) co-locates with a *design decision the mechanism does
not dictate* (filter-in-SQL-for-pagination-honesty; which associations, and why). At function/file
granularity the rule mis-reads these as mechanical ("looks like a query helper"). At **decision
granularity** (the *choice* vs the *typing*) it correctly flags the hole.

### Corroborating signal (bonus)

The author commented *exactly* the decision-fragments and left the mechanical helpers uncommented.
Comment-presence ≈ decision-presence in this corpus — a cheap corroborator, and independent validation
of the pre-enumerated decision list.

### Verdict — AD2 RATIFIED (with one refinement)

Path-2 survives. AI's subtraction is safe across the mechanical class (generic helpers, house-pattern
wiring, presentational chrome — genuinely decision-free), and the error profile is favorable: it errs
toward holes (safe), and its dangerous error is a single, predictable, guardable class. **Adopt
path-2.** Carry one refinement into I3 (substrate): the classifier's `mechanical` test must **fail open
to `hole` on decision-clothed-in-a-known-mechanism** — even when a pattern fits the mechanics, a
fragment that encodes an undictated tradeoff is a hole. **Granularity is the make-or-break, not the
rule's spirit.** No re-plan to phase 2.

## Architectural diff (fill at checkpoint)

- Assumptions hardened: path-2 is empirically viable; classification granularity is the decisive knob.
- Coupling increased: I3's substrate must encode decision-granularity + the decision-clothed-in-mechanism guard.
- Harder to change: the classifier's granularity contract, once the substrate binds to it.
- Easier to change: nothing newly.

## Checkpoint

Verdict = **ratify AD2 + granularity refinement.** Iteration 1 complete (findings retained in this
brief); ready to mark `committed` at checkpoint, then proceed to the substrate (carrying the
refinement) and the fence.

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Produce the findings + verdict. Do not read future iterations.
