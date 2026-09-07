# Iteration 7 — mode-switch UX + resolver rows

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/07-mode-switch-resolver.md`
**Status:** committed
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** framework-internal
**Fanout:** sequential

## Epistemic transition

**What became more certain:** with all three execution policies defined (manual I5, autopilot I6, default
named), the mode is a real axis but it is **inert** — nothing reads it. This slice makes it *operational*:
the manifest carries the mode, the resolver becomes aware of open finishes, and the operator can select
and switch mode. We learn whether mode can be wired in as **pure state** — no new engine, the resolver
still a function of `manifest.json` + git — without the modes' distinctions leaking into routing.

**Irreversible decision (one):** **the manifest representation of authorship mode + the resolver's read
of per-finish status** (the U4 question). One-way: once `/mep` and the resolver bind to a field shape and
a "finishes open" row, changing them is a routing migration. Bounded by the non-negotiable: with the
field **absent or `default`**, routing is byte-for-byte today's behavior.

**Maturity target:** `provisional → stable`

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `templates/manifest.json` (the `authorshipMode` field); `glossary.md` (the resolver row(s) for "scaffolded, finishes open" + any mode-glossary tightening); `.cursor/commands/mep.md` (the mode-select/switch surface); `SKILL.md` (an `authorshipMode` bootstrap-table entry parallel to `sessionMode`) |
| **May know** | the three policies the modes route to (`execution-policies/manual.md`, `autopilot.md`; `default` is named); the finish-map substrate + in-code `@finish:<state>` markers (`maturity-tags.md`, I3) as persisted state the resolver may grep; the current resolver table + `sessionMode` precedent (`glossary.md`, `SKILL.md`); `portable-routing.md` (non-Cursor harnesses resolve the same rows) |
| **Must not know** | graduation cleanup mechanics + the human-review depth over a proxy's map (I8); reopening the substrate schema/markers (I3), the manual lifecycle (I5), or the autopilot dispatch contract (I6) |
| **Invariants** | the resolver stays a **pure function of persisted state** (`manifest.json` + git, incl. in-code markers) — no conversation memory (`01` L79); the table stays **total + first-match-wins unambiguous**; **`default`/absent ⇒ today's routing unchanged** (`01` L78); mode changes *who acts*, never *what gets planned* (`01` L57); `/mep`'s operator surface stays **plain-language** (no framework vocabulary leaked to the user) |
| **Still provisional** | finish 1 — the field shape (initiative-level vs per-iteration override) + whether per-finish status is **grepped from in-code markers** or mirrored in the manifest · finish 2 — the resolver row(s): predicate, placement, and whether routing is **mode-sensitive** · finish 3 — the mode-switch UX (new `/mep` verb vs flag-on-`start` vs direct field edit) |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `glossary.md` (the new resolver row block) | `@provisional` | add (HTML comment — wiring unproven until a real mode-switched run) |
| `SKILL.md` (the `authorshipMode` bootstrap entry) | `@provisional` | add |

(JSON can't carry a marker; the `templates/manifest.json` field is covered by this brief, not an inline tag.)

## Stabilizes

The operator-facing mode selection and the resolver's awareness of unfilled finishes — the last wiring
before cleanup. After this, only graduation (I8) remains.

## Macro constraints (read-only)

From `03-core-vs-volatile.md` + `01-invariant-goal.md`:

- mode = execution policy over the **mode-invariant** substrate; the resolver routes on *state*, not mode-baked logic.
- **resolver is a pure function of persisted state** (non-negotiable) — every new row reads only `manifest.json` + git.
- **`default` stays behavior-compatible** (non-negotiable) — it is named, not changed; absent field ⇒ default.
- honor minimalism: **no new engine**, no resolver-logic smeared into skill bodies (one home — the glossary table).

## Acceptance criteria (this iteration ONLY)

- [ ] `templates/manifest.json` carries an `authorshipMode` field, orthogonal to `sessionMode`, whose
  **absent-or-`default`** value yields **today's exact routing** (a back-test of the resolver against a
  no-field manifest produces identical results).
- [ ] `SKILL.md` documents `authorshipMode` with a short table parallel to the `sessionMode` one (values
  `manual | default | autopilot`, what each selects, default = `default`).
- [ ] `glossary.md`'s resolver gains the **"scaffolded, finishes open"** row(s): a current-iteration slice
  with unfilled finishes (`@finish:open` present in owned paths) resolves to the **fill** step, placed so
  it is reached **before** the commit row (an open decision must not be committable) and keeps the table
  **total + unambiguous**.
- [ ] the resolver row(s) read **only** persisted state (manifest + git/markers) — `/mep where` re-derives
  the right next command for a finishes-open slice **cold**, after any digression.
- [ ] `.cursor/commands/mep.md` gains a **mode select/switch** surface, stated in plain language, that sets
  the manifest field; switching mode mid-flight changes only *who acts next*, never the finish-map.
- [ ] **no new engine**, no resolver logic copied out of the glossary table; `manual`/`default`/`autopilot`
  policies unchanged; the substrate (I3) untouched.

## Finish-map (fragment classification)

Wiring slice; "fragments" are the field, the rows, and the UX. Mostly decision-bearing.

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| add `authorshipMode` key to `templates/manifest.json` (once shape decided) | `mechanical` | transcribes the `sessionMode` field precedent — same template, sibling enum |
| `SKILL.md` `authorshipMode` doc table | `mechanical` | mirrors the existing `sessionMode` bootstrap table |
| the `authorshipMode` **field shape** + per-finish status source | `finish` | — |
| the **resolver row(s)** for finishes-open (predicate, placement, mode-sensitivity) | `finish` | — |
| the **mode-switch UX** in `/mep` | `finish` | — |
| glossary `authorshipMode` term entry | `mechanical` | already present (added with the I4 grid) — keep |

**Frames — the three finishes (`open`):**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| **mode representation (U4)** | `authorshipMode ∈ {manual,default,autopilot}`, orthogonal to `sessionMode`, **defaults to `default`** (absent ⇒ today's behavior); the resolver can read per-finish status as **pure persisted state** | (1) `sessionMode` field — `templates/manifest.json` + `SKILL.md` bootstrap table; (2) the in-code `@finish:<state>` markers (I3) as greppable persisted state, like resolver rows 5/8 grep tree-dirtiness | initiative-level field only, or per-iteration override too? · per-finish status = **grep `@finish:open` from the code** (no manifest mirror) or a manifest field? | `open` |
| **resolver row(s)** | a built slice with `@finish:open` in owned paths resolves to the **fill** step, *before* the commit row; table stays total + first-match-wins; pure function of state | (1) resolver row 5 (uncommitted prep-docs, grep-based, placed ahead of status rows); (2) resolver row 8 (owned-files-dirty, git-sensitive); (3) `manual.md` readiness gate (`rg @finish:open` → NOT READY) | one **mode-agnostic** row keyed on the marker grep, or **per-mode** rows (manual → human-fill; autopilot → transient/in-flight; default → no finishes-open)? where exactly, relative to rows 7/8? | `open` |
| **mode-switch UX** | the operator selects/switches mode in plain language; the action sets the manifest field and nothing else; mid-flight switch changes only who-acts-next | (1) `/mep` verbs (next/where/start/done/stage) — verb-first façade routing via the resolver; (2) `sessionMode` set at bootstrap from message/AskQuestion | a **new `/mep` verb** (e.g. `mode <slug> <mode>`), a **flag on `start`**, or a **direct manifest field edit** the operator makes? | `open` |

**In-code markers:** per I3 — `@mise` (AI's code; unmarked = human's) and `@finish:<state>`. This slice adds
the mode **wiring**, not new nouns.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.cursor/skills/mise-en-place/templates/manifest.json` | modify | integration | add the `authorshipMode` field per the representation finish |
| `.cursor/skills/mise-en-place/SKILL.md` | modify | facade | `authorshipMode` bootstrap-table entry parallel to `sessionMode`; no prime-directive edits |
| `.cursor/skills/mise-en-place/glossary.md` | modify | facade | the finishes-open resolver row(s) + the row-totality note; the term entry already exists |
| `.cursor/commands/mep.md` | modify | facade | the mode select/switch surface (plain-language) |

**Conflicts:** none → but **sequential** (binds to I3 substrate + I5/I6 policies; refines the shared resolver).

## RED-phase gates (before GREEN)

- [ ] **resolver-purity + totality check:** every proposed row is a function of `manifest.json` + git/markers
  alone (no memory); after insertion the table is still **total** (every state matches exactly one row) and
  **first-match-wins unambiguous**. RED if a row needs non-persisted state or two rows can both match a state.
- [ ] **behavior-compat back-test:** run the resolver (on paper) against a manifest with **no** `authorshipMode`
  field and against `authorshipMode: "default"` — both must produce **identical** next-commands to today for
  every current row. RED if a missing/`default` field changes any routing.
- [ ] **finishes-open dry-run:** a manual slice mid-fill (`@finish:open` in owned paths) resolves to the fill
  step cold; an autopilot slice resolves correctly (its finishes are driven to `ratified` in-flight, so the
  open state is transient); a `default` slice is unaffected (no finishes-open concept). RED if any case
  mis-routes or the manual case is committable with an open finish.

## Approach

- resolve the three finishes with the operator (representation → rows → UX), in that order — each constrains
  the next.
- add the field to the template + the `SKILL.md` table (mechanical, once shape is set); add the resolver
  row(s) to the **glossary table only** (no logic in skill bodies); add the `/mep` surface.
- run the purity+totality check and the behavior-compat back-test **before** writing the rows; then the dry-run.
- keep it to **wiring**: no engine, no policy changes, no substrate edits.

## Avoid (out of scope this iteration)

- graduation cleanup + proxy-map review depth (I8)
- reopening the substrate/markers (I3), the manual lifecycle (I5), or the autopilot dispatch contract (I6)
- any change to `default`'s behavior, or to the prime-directive grid (I4)
- building a mode *engine* — the resolver is a table, not a state machine

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | resolver purity + table totality + behavior-compat + the finishes-open dry-run | change `default` routing, smear resolver logic into skill bodies, edit the substrate, or touch policy behavior |

## Testing

- **Unit/spec:** n/a for pure protocol/table docs; if a marker-readiness helper lands as a hook, a shell test
  asserting `@finish:open` detection on a fixture.
- **Manual:** the behavior-compat back-test + the finishes-open dry-run (resolve `/mep where` cold for each mode).

## Architectural diff (fill at checkpoint)

- **Assumptions hardened:** the resolver is a pure function of *persisted* state even with a mode axis
  — per-finish status is **grepped from in-code `@finish:open`**, so no manifest mirror, no second
  source to drift; `authorshipMode` absent-or-`default` ⇒ routing is byte-for-byte today's (back-test
  held); mode is **pure data**, not an engine (a field value + a policy doc).
- **Coupling increased:** the resolver now reads a **third** state source — in-code markers — alongside
  `manifest.json` and git tree/log; `/mep` gained its first **state-writing** verb (`mode`), widening the
  façade's "routes only" charter by one documented exception; four nodes (`templates/manifest.json`,
  `SKILL.md`, `glossary.md`, `mep.md`) now co-reference `authorshipMode` + the per-iteration override and
  must stay consistent.
- **Harder to change:** the `authorshipMode` field shape and row 8's predicate/placement are now a
  routing **contract** — moving them is a routing migration; resolver **row numbers** are referenced from
  prose in `mep.md` + `glossary.md`, so any future insert re-triggers the renumber sweep this slice ran.
- **Easier to change:** adding a future mode is pure data (a sibling enum value + an `execution-policies/`
  doc) with **no engine edit**; marker-as-source-of-truth means per-finish status needs no manifest schema
  bump; the seam (modes share the plan, differ only in who-acts) means a mid-flight switch is a one-field
  write, never a re-plan.

## Checkpoint

The manifest carries `authorshipMode` (absent/`default` ⇒ unchanged routing); the resolver routes a
finishes-open slice to the fill step cold; the operator can select/switch mode in plain language; the table
is still total + pure; `default`/policies/substrate untouched.

## After commit

- [ ] `/commit-prep mep-authorship-modes` — **code** scope (this brief's file ownership)
- [ ] `git commit` → `/prep-pr-description mep-authorship-modes 07`
- [ ] `/prep mep-authorship-modes checkpoint` → draft I8 (graduation cleanup)
- [ ] `/commit-prep mep-authorship-modes docs-delta` → `git commit` if checkpoint changed prep tree

## implement-plan instruction

> Implement **only** this file's ownership. Constitution + slice-type rules are binding. Treat
> `03-core-vs-volatile` and `01-invariant-goal` as constraints, not scope. Resolve the three open finishes
> with the operator in order (representation → rows → UX). Run the resolver-purity+totality check **and** the
> behavior-compat back-test before writing rows, then the finishes-open dry-run. Keep resolver logic in the
> glossary table only — no engine, no skill-body logic. Do **not** change `default`, the policies, the
> substrate, or the prime-directive grid. Do not read future iterations.
