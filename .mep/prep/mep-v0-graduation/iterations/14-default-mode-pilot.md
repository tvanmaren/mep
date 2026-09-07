# Iteration 14 — Default mode end-to-end pilot

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/14-default-mode-pilot.md`  
**Status:** committed  
**Slice type:** behavioral  
**Mode:** exploration  
**Delivery track:** mixed  
**Fanout:** sequential  
**Shortcut:** sc-95

## Epistemic transition

**What became more certain:** default authorship on the graduation initiative produces auditable
lifecycle evidence (gates, resolver routes, interruption correctness) without greenwashing; curate
instance dogfood on `txn-adjustment-revamp` is **blocked or deferred by default** when prep is absent.

**Irreversible decision:** pilot outcomes live only in `pilot-default-mode-report.md` with attached
command JSON — pass, partial, or blocked — never implied by completing the slice.

**Maturity target:** provisional → stable

## Category vs instance

**Category certainty:** default-mode lifecycle (implement → commit-prep → human commit → checkpoint →
docs-delta) is **observable and recorded** on a real slug with raw tool output.

**Instance certainty:** curate preview (and execute when prep + lab branch exist) on `txn-adjustment-revamp`.

**Acceptance order:** category lifecycle proof (14a) may pass independently; instance curate dogfood
(14b) is a separate verdict — default **blocked** when prep tree is missing.

**Pilot shape:** **self-dogfood** on `mep-v0-graduation` (prep-only deliverable). This is not product-code
exercise and not a substitute for txn-adjustment merge-course synthesis.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `pilot-default-mode-report.md`; checkbox updates on this brief |
| **May know** | `tools/mep/**` read-only; prior art `wiki/prep/mep-portability/iterations/14-default-adapter-over-manual.md` |
| **Must not know** | product application code; standalone repo extract (iter 0); unix foundation (1–4) |
| **Invariants** | C1–C5 from `03-core-vs-volatile.md`; default authorshipMode; portability iter 14 default-over-manual gates |
| **Still provisional** | txn-adjustment merge courses; CONTRIBUTING curate section; foundation ledger reconciliation (0–12) |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| n/a | n/a | docs-only behavioral slice — no product tags |

## Stabilizes

Default-mode operator trust before v0.1.0 release packaging (iter 15). Builds on **mep-portability
iter 14** (default as adapter over manual finish/checkpoint gates — already landed in portability
graduation); this slice proves the same gates under **graduation initiative** dogfood with evidence,
not adapter prose alone.

## Macro constraints (read-only)

- `03-core-vs-volatile.md` — curate communication/execute split (C1–C5)
- `wiki/prep/mep-portability/iterations/14-default-adapter-over-manual.md` — default actor model and
  gate substrate (do not re-derive)

## Prerequisites (before implement)

0. **Checkpoint docs-delta committed** — iter 13 ledger reconciliation + this brief must be on
   `HEAD` before `/implement-plan`. Resolver row 5 blocks implement while planning docs are dirty
   only in the index.

## Acceptance criteria (this iteration ONLY)

### 14a — Default-mode lifecycle (category)

- [ ] `pilot-default-mode-report.md` exists with all **Report template** sections filled
- [ ] Raw JSON attached for: `lifecycle status`, `where`, `status --compact`, `finish scan`, `checkpoint`
- [ ] **14a verdict** recorded: `pass` | `partial` | `blocked` with one-line justification
- [ ] At least one gate / finish-map decision rated for **interruption correctness** (include false
      positives — e.g. `finish_map_missing` on dirty prep under `ownedPaths`)
- [ ] Report distinguishes **framework observations** from **slice completion** (observations ≠ pass)

### 14b — Curate instance dogfood (separate verdict)

- [ ] `mep curate txn-adjustment-revamp --preview` attempted **or** **blocked** documented (default when
      `wiki/prep/txn-adjustment-revamp/manifest.json` absent)
- [ ] **14b verdict** recorded: `pass` | `blocked` | `deferred` — independent of 14a
- [ ] Recovery path documented: txn-adjustment prep bootstrap is a **separate initiative decision**, not
      in-scope unless human explicitly overrides the default defer

### Scope guards

- [ ] No silent expansion into iter 0 extract or unix foundation (1–4)
- [ ] No `wiki/prep/txn-adjustment-revamp/**` files created unless human finish explicitly selects
      bootstrap (default: defer)

## Pilot report template

Create `.mep/prep/mep-v0-graduation/pilot-default-mode-report.md` with these sections:

| section | content |
|---------|---------|
| **Summary** | 14a verdict + 14b verdict (two lines) |
| **Prerequisites** | docs-delta SHA; iter 13 implementation SHA |
| **Commands run** | exact CLI invocations with timestamps |
| **Lifecycle** | paste `lifecycle status --mode default --json`; note `canAdvance`, gates |
| **Resolver** | paste `where --json` before and after slice work |
| **Finish / checkpoint** | paste `finish scan`, `checkpoint --json` findings |
| **Surprises** | resolver or lifecycle behavior that contradicts docs-only expectations |
| **Interruption rating** | gate table: gate kind, correct interrupt?, notes |
| **14b txn-adjustment** | curate preview output or blocker evidence |
| **Fix-only patches** | if any `tools/mep/**` change — path + line + report citation |
| **Follow-on** | foundation reconciliation (iters 0–12) — out of scope for iter 14 |

## Finish-map (fragment classification)

| fragment | class | actor | notes |
|----------|-------|-------|-------|
| pilot report template sections | mechanical | agent | fill all rows; attach JSON |
| 14a vs 14b verdict | mechanical | agent | independent pass/blocked |
| txn-adjustment when prep absent | mechanical | agent | **default defer** — document blocker |
| txn-adjustment bootstrap | finish | human | **only** if overriding default defer; new initiative scope |
| curate preview approval (if run) | finish | human | communication strategy ratification |

## File ownership

| path | zone | purpose |
|------|------|---------|
| `.mep/prep/mep-v0-graduation/pilot-default-mode-report.md` | prep | pilot evidence (primary deliverable) |
| `.mep/prep/mep-v0-graduation/iterations/14-default-mode-pilot.md` | prep | brief checkbox updates |
| `tools/mep/**` | runtime | **fix-only** — patches for reproducible pilot blockers; cite in report |

## Approach

### Step 0 — Unblock resolver

Confirm checkpoint docs-delta is committed (`git log -1 -- .mep/prep/mep-v0-graduation/`).

### 14a — Default-mode lifecycle proof (self-dogfood)

1. Capture baseline JSON (lifecycle, where, status, finish scan, checkpoint).
2. Produce `pilot-default-mode-report.md` from template — **this is the slice implementation**.
3. Run `/commit-prep mep-v0-graduation` (code scope: report + brief only) → human commit.
4. Re-capture post-commit JSON; record whether resolver routes expected next step.
5. Assign **14a verdict** from evidence, not from having written the report.

### 14b — Curate instance dogfood (deferred from iter 13)

1. If `wiki/prep/txn-adjustment-revamp/manifest.json` **missing** (expected in this repo): run
   `mep curate txn-adjustment-revamp --json --preview`; paste missing-artifact JSON; assign **14b:
   blocked**; document recovery as separate initiative.
2. If prep exists: `/prep-curate txn-adjustment-revamp --preview` (human ratifies communication
   strategy); assign **14b: pass** or **partial**.
3. **`mep curate mep-v0-graduation --preview`** is CLI smoke only — does **not** satisfy 14b.

## Avoid

- Treating slice completion as 14a pass without gate JSON evidence
- Bootstrapping `wiki/prep/txn-adjustment-revamp/**` without explicit human finish override
- Implementing iter 0 extract or unix foundation (1–4)
- Rebasing any lab branch during curate execute
- False-marking roadmap iterations 0–12 committed without git evidence
- Product code changes outside fix-only pilot blockers
- Re-proving portability iter 14 adapter semantics in prose

## Test commands

```bash
# baseline + evidence capture (paste into report)
tools/mep/bin/mep lifecycle status mep-v0-graduation --mode default --json
tools/mep/bin/mep where mep-v0-graduation --json
tools/mep/bin/mep status mep-v0-graduation --compact --json
tools/mep/bin/mep finish scan mep-v0-graduation --json
tools/mep/bin/mep checkpoint mep-v0-graduation --json

# 14b instance probe
tools/mep/bin/mep curate txn-adjustment-revamp --json --preview

# CLI smoke (not 14b)
tools/mep/bin/mep curate mep-v0-graduation --json --preview

# after any fix-only runtime patch
tools/mep/test/run.sh
```

## Brief preflight

- [x] **single purpose** — auditable default-mode evidence + honest 14b blocker default
- [x] **ownership minimal** — report + brief only; txn-adjustment out unless human override
- [x] **category before instance** — 14a verdict independent of 14b
- [x] **one place to edit** — pilot report is sole evidence surface
- [x] **no planned shotgun surgery** — foundation reconciliation deferred to follow-on slice
- [x] **consolidation routing** — iter 13 out-of-order delivery recorded in manifest deviations

**Preflight:** pass (revised 2026-06-30)

## Architectural diff

- Assumptions hardened: resolver marks `brief_ready` committed from post-brief **owned-path** git, including docs that are not the brief's primary deliverable
- Coupling increased: `ownedPaths` mixes runtime and this prep tree — curate-doc commits count as landing
- Harder to change: `committed` is sync-owned; a promise-gap cannot be quietly unmarked
- Easier to change: missing evidence can be declined as follow-on without denying the git landing
- **Promote to core:** none — default-mode observability not evidenced
- **Newly interchangeable:** I4 — owned-path / revision-triplet heuristic as one realization of "built"
- **Falsified:** none of C1–C5; the pilot-as-proof story is unproven, not disproved

## Checkpoint

**Seam smell test:** story-only. What landed was curate publication-contract docs (`64802ec14`), not 14a/14b. `pilot-default-mode-report.md` never existed.

**Follow-on:** iteration 0 extract (C6). Not 15. Do not false-mark 0–12 committed.
