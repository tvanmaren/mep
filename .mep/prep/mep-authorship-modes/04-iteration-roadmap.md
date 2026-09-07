# Iteration roadmap — mep-authorship-modes

**Phase:** 4
**Status:** draft
**Builds on:** [03-core-vs-volatile.md](./03-core-vs-volatile.md)

Merge philosophy: **merge uncertainty reduction, not feature completeness.**

## Foundation strategy (fork resolved)

Two candidates from phase 2: **contract-first** (fix the shared-substrate schema first — natural,
since three policies consume one artifact) vs **domain-core-first** (prove the classification core as
sandboxed logic first). 

**Resolved: domain-core-first → contract-first, sequenced.** The substrate schema is a one-way door
once consumers bind to it (per phase 3); we do not calcify it until the classification rule that
*justifies* its shape is proven. So iteration 1 proves the core (classification, U2) by back-test;
iteration 3 then fixes the contract on that evidence. The keystone's make-or-break (U2 reliability) +
the irreversibility of a premature schema dictate the order — no operator-preference tiebreak needed.

## Folded ADs (recorded here, not standalone)

- **AD2 (path-2)** is *earned, not asserted*: iteration 1's back-test ratifies or kills it. The
  framework's own "every certainty needs falsification" applied to our keystone decision.
- **AD3 (analysis/execution split)** crystallizes as iteration 3's substrate contract.
- **AD1 (prime-directive amendment)** lands in iteration 4, after the substrate it must describe is
  fixed — so the constitution edit is accurate and stable, not rewritten later.
- **AD4 (temporal test rule)** lands inside iteration 5's finish lifecycle.

---

## Iteration 1 — classification back-test (spike)

**Goal:** prove or kill the mechanical-vs-finish rule ("AI absorbs a fragment only if it can cite a
named pattern; else it's a finish") by applying it to a **real merged host-prototype PR** and checking
whether flagged finishes land where decisions actually were.
**Slice type:** architectural · **Mode:** exploration · **Delivery track:** framework-internal · **Fanout:** parallel (batch with I2)
**Epistemic transition:** we know whether path-2 classification is reliable enough to make manual *useful*.
**Irreversible decision:** ratify AD2 (adopt path-2) on back-test evidence, or pivot.
**Maturity target:** `experimental → provisional` (classification rule)
**Approach:** pick a representative melt PR; hand/agent-run the rule; tabulate flagged-mechanical vs flagged-finish against where real decisions lived; record hit/miss.
**Avoid:** building any schema, marker, or engine change — this is non-retained knowledge work.
**Checkpoint:** does the rule flag finishes at the decisions, with tolerable false-mechanical rate? (the U2 "confidence illusion" guard — evidence, not introspection)
**File ownership (sketch):** `.mep/prep/mep-authorship-modes/iterations/01-*.md` (findings only)

---

## Iteration 2 — anti-line-fighting boundary (mechanism; polarity → I3)

**Goal:** a region the agent is contractually forbidden to re-assert into; agent scaffolds around it, never inside.
**Slice type:** architectural · **Mode:** hardening · **Fanout:** parallel (batch with I1)
**Epistemic transition:** the boundary mechanism holds in the real agent loop (U6) — and it is **polarity-agnostic**.
**Irreversible decision:** the boundary *mechanism* + the engine contract that honors it. **Which side is marked, the spelling, and the cross-mode finish-map are deferred to I3** (a default/autopilot stress-test showed they only resolve at the substrate).
**Maturity target:** `experimental → provisional`
**Approach:** spike the marker mechanism + the loop-respect contract; declare a boundary, edit inside it, observe non-re-assertion.
**Avoid:** coupling to the full substrate, and **fixing the polarity** — the mechanism is independently valuable and ships alone.
**Checkpoint:** the agent leaves a boundaried region untouched across a multi-turn edit; polarity lifted to I3.

---

## Iteration 3 — shared-substrate contract

**Goal:** the mode-invariant analysis artifact — how a brief records fragment classification +
problem-frames — that all three policies consume.
**Slice type:** architectural · **Mode:** hardening · **Fanout:** sequential
**Epistemic transition:** the artifact all three modes read is fixed (AD3).
**Irreversible decision:** the substrate schema + the two-marker vocabulary (`@mise` authorship / `@finish` decision) — one-way once consumers bind.
**Maturity target:** `provisional → stable`
**Approach:** extend the slice-brief template with a classification table + frame slots (contract / ≥2 precedents / fork); dry-run all three policies against ONE example slice (U1). **Carry the I1 refinement:** the classifier's `mechanical` test must fail open to `finish` when a citable mechanism clothes an undictated tradeoff — classify at decision granularity, not mechanism-match.
**Avoid:** marker spelling, manifest field bikeshedding (volatile surface).
**Checkpoint:** one example slice drives manual, default, and autopilot from a single artifact, distinctions intact.

---

## Iteration 4 — amend the prime directive (AD1)

**Goal:** reframe "implement owns code; humans audit" → the governance×authorship space (3 corners; code-monkey corner empty).
**Slice type:** architectural · **Mode:** hardening · **Fanout:** sequential
**Epistemic transition:** the framework's operating model names the mode-axis.
**Irreversible decision:** the constitution amendment (one-way, politically sensitive).
**Maturity target:** `stable → foundational`
**Approach:** edit `SKILL.md` prime directive + operating model; reference the now-fixed substrate.
**Avoid:** changing any mode's behavior — this is the conceptual frame only.
**Checkpoint:** the amended directive describes all three modes without contradicting existing gates. **(Done — 8fb3db2c3.** Implement clarified the two senses of "govern": *semantic* governance = always-human invariant *above* the grid; the grid's vertical axis = *approval* governance (who signs off at the gate). That puts autopilot in its own AI-authors/AI-approves corner, distinct from default; the melt blob is that corner's failure-mode. Autopilot bounded to *up to* graduation — graduation stays human. See `manifest.deviations`.)

---

## Iteration 5 — manual execution policy (finishes + frames + ratchet)

**Goal:** the finish lifecycle in the implement flow: `@mise`/`@finish` markers, frame authoring, human-fill,
hardening ratchet (AI proposes / human ratifies), graduation "zero unfilled finishes" gate.
**Slice type:** architectural · **Mode:** hardening · **Fanout:** sequential · **(likely splits at brief time)**
**Epistemic transition:** manual mode actually runs end-to-end on a real slice.
**Irreversible decision:** the finish lifecycle + temporal test rule (AD4). *If this can't be one decision at brief time, split into 5a markers, 5b frame+fill, 5c ratchet+gate.*
**Maturity target:** `provisional → stable`
**Avoid:** autopilot concerns.
**Checkpoint:** a real finish goes frame → human-fill → ratchet → ratify → marker sheds; graduation blocks on an unfilled finish. **(Done — code `562e0f595`, docs `5f4534cd4`.** Shipped `execution-policies/manual.md`: the finish lifecycle, two-moment test model, hardening ratchet, codeless guidance stripped at the ratchet, readiness grep. Implement resolved the two open forks — ratchet emits *tests not prose-invariants*; fill is a *codeless guided region* — and tightened AD4 to its mechanism-level reading. Did **not** split. See `manifest.deviations`.)

---

## Iteration 6 — autopilot execution policy

**Goal:** non-blocking self-approval *up to* graduation (graduation stays a human gate) that **still emits the finish-map** (non-blocking, not blind).
**Slice type:** architectural · **Mode:** hardening · **Fanout:** sequential
**Epistemic transition:** full autonomy exists without recreating the melt blob.
**Irreversible decision:** the auto-approve path that preserves the finish-map audit trail.
**Maturity target:** `experimental → provisional`
**Checkpoint:** an autopilot run graduates a slice AND leaves a recorded finish classification. **(Done — code `385f55e35`.** Shipped `execution-policies/autopilot.md` as pure deltas over manual: autopilot = the manual lifecycle run by a **dispatched cross-model proxy** in the chef's seat (no new lifecycle → the seam holds). Resolved the two open forks with the operator — dispatch contract = **one proxy per slice, edits in place** (no isolated worktree; isolation would break the seam), parent gates on tests-green + finish-map-complete before the non-blocking advance; graduation-review **depth deferred to I8**. Refined `SKILL.md`'s autopilot *mechanism* prose ("self-approves" → "dispatches a cross-model proxy operator") — grid corner unchanged. Both RED gates + a cross-model commit-prep audit passed. See `manifest.deviations`.)

---

## Iteration 7 — mode-switch UX + resolver rows

**Goal:** wire `authorshipMode` into the manifest (orthogonal to `sessionMode`), `/mep`, and the resolver (the "scaffolded, finishes open" row), keeping the resolver a pure function of state.
**Slice type:** architectural · **Mode:** hardening · **Fanout:** sequential
**Epistemic transition:** an operator can select/switch mode and the driver routes correctly.
**Irreversible decision:** the manifest representation of mode + per-finish status (U4).
**Maturity target:** `provisional → stable`
**Checkpoint:** `/mep where` re-derives the right next command for a finishes-open slice, cold. **(Done — code `147c2c419`.** Wired `authorshipMode` as pure state across four nodes: an initiative-level manifest field (absent ⇒ `default` ⇒ today's routing) with optional `iterations[].authorshipMode` override; a `SKILL.md` bootstrap table parallel to `sessionMode`; a mode-agnostic resolver **row 8** keyed on a `@finish:open` grep → `/implement-plan` (before the commit row, so an unmade decision is uncommittable), renumbering old 8/9/10 → 9/10/11; and a `/mep mode <slug> <mode> [iteration N]` verb — `/mep`'s first state-writing verb. Three finishes resolved with the operator (representation → rows → UX): per-finish status is **grepped from the marker, not mirrored**; the row is **mode-agnostic** (default never leaves one open; an interrupted autopilot resuming as manual *is* the manual case — the seam); flag-on-`start` and raw field-edit both rejected for the verb. Both RED gates + a cross-model commit-prep audit passed (the audit caught a row-8 totality gap — added a `status` guard — and a stale verb count). See `manifest.deviations`.)

---

## Iteration 8 — graduation cleanup

**Goal:** shed the initiative's self-planted markers from `ownedPaths` (sparing the framework's vocabulary *documentation*), write `06-graduation.md`, set `initiativeStatus: graduated`; resolve the one policy finish I6 deferred here (autopilot's proxy-map review depth).
**Slice type:** cleanup · **Fanout:** sequential
**Irreversible decision:** graduation (strip + `graduated` — one-way). Two finishes ride inside: the **strip-predicate** (this initiative graduates the *framework itself*, whose docs define the very `@`-markers it planted — so a blind sweep would gut the vocabulary; judgment, not regex) and the **deferred review-depth** policy. If the latter outgrows a localized clause, split it out.
**Maturity target:** `n/a (cleanup)` (+ autopilot graduation clause `provisional → stable` if bundled)
**Checkpoint:** zero live `@` markers in `ownedPaths` (vocabulary docs intact), `06-graduation.md` written, `initiativeStatus: graduated`, resolver + every policy unchanged minus scaffolding.

---

## Dependency order

```
I1 (classification) ─┐
I2 (fence)          ─┴→ I3 (substrate) → I4 (prime directive) → I5 (manual) → I6 (autopilot) → I7 (mode-switch + resolver) → I8 (cleanup)
```

I1 and I2 are the two de-risking front-runners (lowest-confidence items U2, U6); everything retained
flows from the substrate (I3).

## Fanout eligibility

| Iterations | Parallel? | Reason |
|------------|-----------|--------|
| I1 + I2 | **yes — parallel batch** (operator-approved) | disjoint files: prep-findings doc vs engine fence |
| I3..I8 | no | each binds to the substrate / prior decision |

## Re-plan triggers

- I1 back-test **kills** path-2 → return to phase 2; the whole mechanism is in question (not a tweak).
- I2 fence fails in the loop → manual mode's *pleasantness* invariant is at risk; reassess before I5.
- I3 dry-run shows a mode's distinction leaks through the shared artifact → substrate schema reopens.

## Consolidation trigger (optional master plan)

- After I5 (manual) passes checkpoint AND the shape is stable → `/create-plan` into
  `.mep/plans/mep-authorship-modes.md` for one assessable document before I6/I7.
  **(Fired — `.mep/plans/mep-authorship-modes.md` written; `manifest.masterPlanPath` set. Next: `/assess-plan` → `/update-plan`, then resume I6.)**
