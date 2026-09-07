# Iteration 6 — autopilot execution policy

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/06-autopilot-execution-policy.md`
**Status:** committed
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** framework-internal
**Fanout:** sequential

## Epistemic transition

**What became more certain:** with manual proven end-to-end (I5), autopilot needs **no new lifecycle** —
it is the *manual* policy with a **dispatched sub-agent in the chef's seat**. We learn whether full
autonomy can be had by *delegating the human role to a proxy* rather than by the parent rubber-stamping
its own work — and whether that still leaves a recoverable finish-map (the U1 / no-blob proof).

**Irreversible decision (one):** **autopilot = the manual execution policy executed by a dispatched
cross-model sub-agent acting as the chef** — it authors the `finish`es and runs the ratchet to
`@finish:ratified`, **non-blocking** slice-to-slice; the finish-map is **retained** (proxy-provenance),
and the **human graduation gate is the true human ratification**. One-way: second binding to the I3
substrate; refines I4's autopilot *mechanism* prose ("self-approves" → "dispatches a proxy operator").

**Maturity target:** `experimental → provisional`

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `execution-policies/autopilot.md` (the autopilot verbs); a one-line refinement to `SKILL.md`'s autopilot cell ("self-approves" → "dispatches a cross-model proxy operator") + the closing default-vs-autopilot line |
| **May know** | `execution-policies/manual.md` (the lifecycle the proxy runs **verbatim**), the finish-map substrate (`maturity-tags.md`, I3), the grid (`SKILL.md`, I4), the autopilot invariants/rejection-criteria (`01-invariant-goal`), the sub-agent-dispatch precedent (`commit-prep`'s `staged-audit-scout`; `/execute-plan`'s `best-of-n-runner`) |
| **Must not know** | the mode selector, `manifest.authorshipMode`, resolver rows, mode-switch UX (I7); graduation cleanup mechanics (I8) |
| **Invariants** | the proxy runs manual's lifecycle **unchanged** (the seam); non-blocking **but not blind** (finish-map always emitted + retained, never stripped pre-graduation); the proxy is **cross-model + a separate context** (an independent head, not self-grading); **graduation stays the human gate** — the true human ratification; `manual` + `default` behavior unchanged; the grid corner (AI authors / AI approves) is **unchanged** |
| **Still provisional** | the dispatch contract (proxy persona prompt; how the finish-map + manual policy are handed over; parent↔proxy handoff) — fork 1; whether graduation **re-ratifies** every proxy-`ratified` finish or **spot-audits** the map — fork 2 (may defer to I8) |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `.cursor/skills/mise-en-place/execution-policies/autopilot.md` | `@provisional` | add (whole doc — auto-approve path unproven) |

## Stabilizes

The autopilot corner (AI authors / AI approves), the last live corner to bind. After this, only the
wiring (I7) and cleanup (I8) remain.

## Macro constraints (read-only)

From `03-core-vs-volatile.md` + the prior nodes:

- mode = execution policy over the **mode-invariant** substrate (the seam: same finish-map across modes).
- classifier **fails open to `finish`** — the proxy uses the *same* classifier; it does **not** judge its
  own correctness to decide what's a finish.
- **`ratified` is human-only is scoped to `manual`** (`01-invariant-goal` L63 reads "(manual)"). In
  autopilot the **proxy** ratifies in-flight; the **human graduation gate** is the true human
  ratification. This is reconciliation, not violation — the RED gate must confirm it.
- `default` stays behavior-compatible; this slice adds a third policy, changes neither of the other two.

## Acceptance criteria (this iteration ONLY)

- [ ] `execution-policies/autopilot.md` defines autopilot as: **dispatch a sub-agent** (coder persona that
  understands the codebase + fulfills the chef's role) and have it run **`manual.md`'s lifecycle verbatim**
  — author the `finish`es, run the ratchet, reach `@finish:ratified`.
- [ ] the dispatch is **cross-model** (a different model family than the parent), so the proxy is a
  genuinely independent head — citing the `commit-prep` / `execute-plan` dispatch precedent.
- [ ] the per-slice gate is **non-blocking**: the parent proceeds slice-to-slice without waiting on a human;
  this is the *only* thing that differs from `manual` (which waits on the real operator).
- [ ] autopilot **always emits the finish-map** and **never strips it** pre-graduation — a run that
  graduates a slice with no recorded finish classification is a failure (`01` invariant).
- [ ] proxy ratifications are **proxy-provenance**: the mode (`autopilot`) records that the in-flight
  `ratified` was rendered by a proxy, not a human — the human graduation gate is the true human sign-off.
- [ ] **seam property:** an interrupted autopilot run and a manual run differ only in *who occupies the
  chef seat* — the `@finish` states are identical, so the real human resumes in `manual` with no
  translation.
- [ ] `SKILL.md`'s autopilot prose is refined ("self-approves" → "dispatches a cross-model proxy
  operator"); the grid corner is unchanged; a `manifest.deviations[]` entry records the lineage.
- [ ] **no** mode selector, **no** `manifest.authorshipMode`, **no** resolver row; `manual` + `default`
  behavior unchanged.

## Finish-map (fragment classification)

Policy/protocol slice; "fragments" are the policy definitions. Mostly decision-bearing.

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| the sub-agent **dispatch contract** (proxy persona; runs manual's lifecycle as the chef) | `finish` | — |
| "the proxy runs `manual.md` verbatim" (reuse, not a new lifecycle) | `mechanical` | transcribes I5's manual policy as the shared lifecycle |
| **cross-model** dispatch (independent head) | `mechanical` | `commit-prep` second-opinion / `execute-plan` fanout precedent |
| non-blocking per-slice gate (the only delta vs manual) | `mechanical` | transcribes I4's per-slice-gate distinction |
| finish-map **retention** + proxy-provenance | `mechanical` | transcribes the `01` non-blocking-but-not-blind invariant |
| graduation re-ratify vs spot-audit of the proxy's map | `finish` (fails open) | — |

**Frame — the lifecycle finish (`open`):**

| finish | contract | ≥2 precedents | fork (the question) | state |
|--------|----------|---------------|---------------------|-------|
| the autopilot dispatch contract + graduation reconciliation | a dispatched cross-model proxy runs manual's lifecycle as chef (authors + ratifies), non-blocking; finish-map retained w/ proxy-provenance; human graduation is the true ratification; interruptible into manual | (1) `execution-policies/manual.md` (the lifecycle, run by a proxy); (2) `01-invariant-goal` autopilot success + rejection criteria; (3) `commit-prep` `staged-audit-scout` + `/execute-plan` `best-of-n-runner` (in-framework sub-agent dispatch) | **fork 1:** the dispatch contract — persona prompt, how the finish-map + policy are handed to the proxy, parent↔proxy handoff · **fork 2:** at graduation, does the human **re-ratify** every proxy-`ratified` finish, or **spot-audit** the map? (may belong to I8) | `open` |

**In-code markers:** per I3 — `@mise` (AI's code; unmarked = human's) and `@finish:<state>`. The proxy,
being the (AI) chef, marks its code `@mise` and drives finishes `open → done → ratified` exactly as the
manual operator would. This slice adds the autopilot **verbs**, not the nouns.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.cursor/skills/mise-en-place/execution-policies/autopilot.md` | new | facade | the autopilot policy — dispatch contract, cross-model proxy chef, non-blocking gate, finish-map retention + proxy-provenance, human-graduation backstop, the seam. States only the **deltas** from `manual.md` |
| `.cursor/skills/mise-en-place/SKILL.md` | modify | facade | refine the autopilot cell + closing line ("self-approves" → "dispatches a cross-model proxy operator"); extend the execution-policies pointer to list `autopilot`. Grid corner unchanged |

**Conflicts:** none → but sequential (binds to I5's policy + I3 substrate + refines I4 prose).

## RED-phase gates (before GREEN)

- [ ] **no-contradiction check:** the policy must not violate any `03-core-vs-volatile` core row or any
  `01-invariant-goal` invariant. **Critical reconciliations:** (a) `ratified`-by-proxy is allowed because
  the human-only rule is `manual`-scoped + graduation is the human backstop — RED if autopilot lets a
  finish reach `ratified` with **no** retained proxy-provenance **or no** human graduation gate; (b) the
  proxy must not **self-grade** — RED if it is the same context/model as the authoring parent; (c) RED if
  the SKILL.md refinement changes the grid **corner** rather than the mechanism prose.
- [ ] **worked-example dry-run (paper):** take the I5 worked finish and run it autopilot —
  `dispatch cross-model proxy → proxy authors → ratchet → proxy-ratifies → non-blocking next slice … →
  human graduation review → human ratifies/strips`. RED = a finish reaches `ratified` without retained
  proxy-provenance, the finish-map is absent/stripped at graduation, the proxy self-grades, or an
  interrupted run can't be resumed in manual from the `@finish` states alone.

## Approach

- write `autopilot.md` against the frame; cite `manual.md` for the lifecycle and state only the **deltas**:
  the dispatch contract, the cross-model proxy chef, the non-blocking per-slice gate, retention +
  proxy-provenance, and the human-graduation backstop. Do **not** restate the lifecycle.
- refine the one `SKILL.md` autopilot line + record the deviation.
- run the no-contradiction check (RED) — especially the three reconciliations — then the paper dry-run,
  then write.
- keep it to **verbs + dispatch contract**; change nothing about `manual`/`default`; build no selector.

## Avoid (out of scope this iteration)

- the mode selector, `manifest.authorshipMode`, resolver rows, mode-switch UX (I7)
- graduation cleanup mechanics (I8) — fork 2 may land here
- reopening the substrate schema or marker nouns (I3), the manual lifecycle (I5), or the I4 grid **corner**
  (only the mechanism prose is refined)

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | the dispatch contract's coherence + the no-contradiction reconciliations + the dry-run + the seam | build the selector, wire the manifest field, change `manual`/`default`, or move the grid corner |

## Testing

- **Unit/spec:** n/a if pure protocol docs; if a retention check lands as a hook, a shell test asserting
  the finish-map is present (not stripped) at the graduation boundary.
- **Manual:** the worked-example dry-run; confirm the seam (interrupt → resume in manual) on paper.

## Architectural diff (at checkpoint — committed `385f55e35`)

- **Assumptions hardened:** autopilot needs *no new lifecycle* — it is manual run by a proxy; the
  no-self-grading guard is satisfied structurally (cross-model + separate context), never by AI
  self-assessment; the finish-map is now the governing artifact in a *second* execution policy.
- **Coupling increased:** `autopilot.md` depends on `manual.md`'s lifecycle **verbatim** — a change to
  manual's state machine now ripples into autopilot; the `SKILL.md` grid prose is bound to the
  proxy-dispatch mechanism (mechanism only — the corner is untouched).
- **Harder to change:** the I3 substrate gains its second consumer (manual + autopilot), so reshaping
  the finish-map now breaks two policies; "autopilot = manual-by-proxy" is a one-way conceptual commit.
- **Easier to change:** the dispatch contract (granularity, model pick, in-place edit) is isolated in one
  doc; graduation-review depth is *deferred*, not coupled, leaving I8 room; mode **selection** stays
  unbuilt, so I7's wiring is unconstrained by this slice.

## Checkpoint

A dispatched cross-model proxy drives a slice's finishes to `ratified` non-blocking, leaving a retained
proxy-provenance finish-map; the human graduation gate is the true ratification; a finish never reaches
`ratified` without retained provenance or a human graduation backstop; an interrupted run resumes in
manual from the `@finish` states; `manual` + `default` untouched; the I4 grid corner unchanged.

## After commit

- [ ] `/commit-prep mep-authorship-modes` — **code** scope (this brief's file ownership)
- [ ] `git commit` → `/prep-pr-description mep-authorship-modes 06`
- [ ] `/prep mep-authorship-modes checkpoint` → draft I7 (mode-switch UX + resolver rows)
- [ ] `/commit-prep mep-authorship-modes docs-delta` → `git commit` if checkpoint changed prep tree

## implement-plan instruction

> Implement **only** this file's ownership. Constitution + slice-type rules are binding. Treat
> `03-core-vs-volatile` and `01-invariant-goal` as constraints, not scope. Reuse `manual.md`'s lifecycle —
> the proxy runs it verbatim; state only the autopilot **deltas**. Run the no-contradiction check **and**
> the worked-example dry-run (RED) before writing — especially the three reconciliations. Refine only the
> `SKILL.md` autopilot **mechanism prose**, never the grid corner; record the deviation. The dispatch
> contract + graduation reconciliation are the open forks — author/ratify them with the operator. Do
> **not** build the selector or touch the manifest mode field. Do not read future iterations.
