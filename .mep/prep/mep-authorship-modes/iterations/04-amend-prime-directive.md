# Iteration 4 — amend the prime directive (AD1)

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/04-amend-prime-directive.md`
**Status:** brief_ready
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** framework-internal
**Fanout:** sequential

## Epistemic transition

**What became more certain:** with the shared substrate fixed (I3), the framework's operating model
can finally be **named accurately** — "implement owns code; humans audit" is revealed as *one corner*
of a **governance × authorship** space, and the amended directive can reference a substrate that
already exists rather than one it promises.

**Irreversible decision (one):** the **constitution amendment** — the new wording of the prime
directive + operating model. One-way and politically sensitive (it is the framework's self-description;
every downstream doc inherits its frame).

**Maturity target:** `stable → foundational`

## The space being named (source of truth: `01-invariant-goal`)

**Governance × authorship.** **Semantic governance is invariant** — the framework never cedes
ontology/semantics to the AI; that sits *above* the grid. The grid's two axes are **who authors** ×
**who holds approval governance** (who signs off at the merge gate):

| | human authors | AI authors |
|---|---|---|
| **human approves** (blocking) | **manual** — operator authors the `finish`es; AI absorbs the mechanical | **default** — AI authors, human audits *before* merge; the `finish-map` concentrates the audit |
| **AI approves** (non-blocking) | **code-monkey — deliberately empty** (human types while the AI signs off: never) | **autopilot** — AI authors + self-approves, non-blocking *but not blind*; the `finish-map` is recorded. Strip the substrate and it degrades into the ungoverned **melt blob** — rejected |

The three live modes share one substrate and differ only in *who acts* (default vs autopilot: only at
the gate); the amendment must make that the headline, not a footnote.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | the **wording** of `SKILL.md`'s *Prime directive* + *Operating model* (§ "Prime directive") — reframed as the governance×authorship space; a one-line cross-reference to the now-fixed substrate (`finish-map`, `@mise`/`@finish`) |
| **May know** | `01-invariant-goal` (the space, the invariants, the rejection criteria), I3's committed substrate (`maturity-tags.md`, the slice-brief `finish-map`), the existing prime directive text |
| **Must not know** | *who moves a finish's state* / *what gate* (execution policy — I5/I6); the manifest `authorshipMode` **field** + resolver rows + mode-switch wiring (I7) |
| **Invariants** | human governance is constant across all three modes; `default` is **named, not changed** (behavior-compatible); the code-monkey corner stays empty; the amendment contradicts **no** existing gate or hard rule |
| **Still provisional** | the exact prose + whether the 2×2 ships as a table or sentence in `SKILL.md`; the glossary phrasing of "authorship mode" *as a concept* (the field wiring is I7) |

## Finish-map (fragment classification)

This slice is **almost entirely `finish`** — amending a constitution is decision-bearing by nature;
there is no mechanical remainder to cite a pattern for.

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| the new *Prime directive / Operating model* wording | `finish` | — |
| the cross-reference line to the substrate (`finish-map`, `@mise`/`@finish`) | `finish` (fails open) | a mechanism (a link) clothing a framing choice — *which* artifacts to name is a decision |
| optional glossary row for "authorship mode" *as concept* | `finish` | — |

**Frame — the directive-amendment finish:**

| finish | contract | ≥2 precedents | fork | state |
|--------|----------|---------------|------|-------|
| the amended directive | names the governance×authorship space; places all 3 live modes; marks the 4th corner empty; keeps human-governance invariant; breaks no existing gate | (1) current `SKILL.md` *Prime directive* §69–76; (2) `01-invariant-goal` "Problem (invariant)" + the invariants table | table vs prose in `SKILL.md`? · how much of the 2×2 lives in the directive vs a cross-referenced section? | `done` (operator-ratified: short directive + cross-ref subsection carrying the 2×2 as a table) |

Because this is the politically-sensitive corner, the `finish` was held **`open`** through an
operator ratification gate (AI proposed from the frame, operator ratified) — the constitution was
not pre-drafted and shipped without sign-off.

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| the amended *Operating model* paragraph | `@foundational` | add — the directive is the framework's bedrock once ratified (target `stable → foundational`) |

## Stabilizes

AD1 (the prime-directive amendment) and the conceptual frame the remaining execution-policy slices
(I5 manual, I6 autopilot) build against. Independently valuable: the named space makes `default`-mode
review legible without any behavior change.

## Macro constraints (read-only)

From `03-core-vs-volatile.md`: the prime directive is **stable core / foundational** — a one-way
door; amend it only to the extent I3's substrate justifies, and never in a way that re-litigates a
ratified gate. From `01-invariant-goal` "Non-negotiable constraints": `default` stays
behavior-compatible; the resolver stays a pure function of state; minimalism — name the space, don't
build past real pull.

## Acceptance criteria (this iteration ONLY)

- [ ] `SKILL.md`'s *Prime directive* / *Operating model* reframes "implement owns code; humans audit"
  as **one corner** of the governance×authorship space, naming **manual / default / autopilot** and
  marking the **code-monkey** corner deliberately empty
- [ ] human governance is stated as **invariant** across all three modes
- [ ] a one-line cross-reference points to the committed substrate (`finish-map`, `@mise`/`@finish`)
  without re-specifying it
- [ ] the amendment **contradicts no** existing hard rule or gate (verified against `SKILL.md` hard
  rules + the five-phase gates)
- [ ] **no mode behavior changes** — this is the conceptual frame only; no execution policy, no
  manifest field, no resolver row
- [ ] `default`'s description stays behavior-compatible with today's model (named, not changed)

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.cursor/skills/mise-en-place/SKILL.md` | modify | facade | reframe the *Prime directive* + *Operating model* section only |
| `.cursor/skills/mise-en-place/glossary.md` | modify | facade | *optional* — add "authorship mode" / "governance×authorship space" as **concepts** (not the manifest field) |

**Conflicts:** touches the engine spine (`SKILL.md`) — **must stay sequential** (I3..I8 non-parallel).

## RED-phase gates (before GREEN)

- [ ] the **no-contradiction check is run first**: enumerate `SKILL.md`'s hard rules + the five gate
  questions, and confirm the proposed reframing leaves each intact **before** writing the new wording.
  A contradiction surfaced here **fails the slice** and reopens the amendment (`04` re-plan trigger).

## Approach

- the directive-amendment is a **`finish`** — the operator authors or ratifies the wording; do not
  ship a constitution the human did not sign off on.
- draft against the frame's contract; run the no-contradiction check (RED) before committing prose.
- add the `@foundational` tag; add the optional glossary concept rows.
- keep it to the *frame* — name the space, cross-reference the substrate, change nothing's behavior.

## Avoid (out of scope this iteration)

- any execution policy — *who* fills a finish, *what* gate applies (I5 manual, I6 autopilot)
- the manifest `authorshipMode` field, resolver rows, mode-switch UX (I7)
- the finish **lifecycle** / temporal-test rule AD4 (I5)
- re-opening the substrate schema (I3, committed)

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | the amended frame's coherence + the no-contradiction check | change any mode's *behavior* or build an execution policy |

## Testing

- **Unit/spec:** n/a (constitution prose)
- **Manual:** read the amended directive against (a) the three modes from `01-invariant-goal` — each
  is placed, none collapses; (b) every `SKILL.md` hard rule + gate — none contradicted. Pass = both
  hold; fail = any mode unplaced or any gate broken.

## Architectural diff (fill at checkpoint)

- Assumptions hardened: the operating model is a **governance×authorship space**, not a single
  model; human governance is constant across modes; `default` is one corner (named, unchanged).
- Coupling increased: the directive now references the I3 substrate (`finish-map`, `@mise`/`@finish`)
  — the constitution depends on the substrate existing.
- Harder to change: the three-mode framing + empty code-monkey corner is now `@foundational`
  bedrock; downstream docs inherit it.
- Easier to change: I5/I6 execution policies now have a named slot to fill — *who acts* per mode —
  without re-litigating *what gets planned*.

## Checkpoint

The prime directive names the governance×authorship space, places all three live modes over the one
substrate, marks the code-monkey corner empty, and breaks no gate; `@foundational` recorded; no mode
behavior changed.

## After commit

- [ ] `/commit-prep mep-authorship-modes` — **code** scope (this brief's file ownership)
- [ ] `git commit` → `/prep-pr-description mep-authorship-modes 04`
- [ ] `/prep mep-authorship-modes checkpoint` → draft I5 (manual execution policy)
- [ ] `/commit-prep mep-authorship-modes docs-delta` → `git commit` if checkpoint changed prep tree

## implement-plan instruction

> Implement **only** this file's ownership (`SKILL.md` directive + optional glossary concept rows).
> Constitution + slice-type rules are binding. Treat `03-core-vs-volatile.md` and `01-invariant-goal`
> as constraints, not scope. The directive-amendment is a `finish` — author/ratify with the operator;
> do not ship un-ratified constitution prose. Run the no-contradiction check (RED) first. Do **not**
> build any execution policy or touch the manifest mode field. Do not read future iterations.
