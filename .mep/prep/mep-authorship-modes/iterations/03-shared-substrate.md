# Iteration 3 — shared-substrate contract (the finish-map)

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/03-shared-substrate.md`
**Status:** brief_ready
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** framework-internal
**Fanout:** sequential

## Epistemic transition

**What became more certain:** the single, **mode-invariant** artifact all three policies read — the
**finish-map**: every fragment classified `mechanical | finish`; each `finish` carries a frame
(contract + ≥2 precedents + fork) **and a state** (`open | done | ratified`). One worked example
drives manual, default, and autopilot from this *one* artifact with their distinctions intact (U1,
the keystone). And the realisation that **two orthogonal markers**, not one, carry it.

**Irreversible decision (one):** the substrate schema — the `mechanical | finish` classification +
frame/state slots, and the two-marker vocabulary the policies bind to. One-way once consumers bind
(per `03-core-vs-volatile`).

**Maturity target:** `provisional → stable`

## The vocabulary (load-bearing — locked here)

The framework is *mise-en-place*: **AI is the sous, the human is the chef.** Two **orthogonal** axes,
two markers — the war between them was a category error (they do different jobs):

### Axis 1 — authorship / ownership: `@mise` (resolves I2's lifted polarity = the inversion)

| | |
|---|---|
| **marks** | code the **agent generated** (the sous's prep) |
| **unmarked means** | the **human's** — no-touch; the agent never generates into, overwrites, or re-asserts it |
| **claim** | the human takes ownership of *any* region, anytime, by **deleting its `@mise`** (subtractive — no new convention to *write* code) |
| **failure mode** | forget to mark AI code → reads as human → **over-protect** (safe) |
| **coverage** | the bulk in manual; ~all of the file in default/autopilot (*true*, not noise — stripped at graduation) |

This is the I2 anti-line-fighting boundary, polarity now resolved: **mark the agent's code; the
human's is the unmarked default.** Zero ceremony to write code the ordinary way.

### Axis 2 — direction / decision: `@finish` (the substrate's contribution)

| | |
|---|---|
| **marks** | a **decision-bearing** fragment — the agent *directs* the chef to author it |
| **carries** | a frame (contract + ≥2 precedents + fork) + a state `@finish:open → :done → :ratified` |
| **mode-invariance** | the `@finish` **set** is identical across modes (the seamless trail); only the *state* differs by who has acted |
| **failure mode** | miss a decision → not flagged → silent AI call (**dangerous**) — mitigated by I1's **fail-open-to-`finish`** classifier |
| **coverage** | the informative **minority** in every mode |

`@finish` is **prescriptive** ("your judgment goes here"); deleting `@mise` is **discretionary**
("I chose to own this"). Keeping them distinct means **claiming code never masquerades as an AI
directive** — the social meanings stay separate.

### How they overlay (the 2×2)

| | `@finish` (a decision) | not a decision |
|---|---|---|
| **`@mise`** (AI authored) | AI made a call → **audit this** (default / autopilot) | AI prep — the bulk |
| **unmarked** (human) | a decision the human authored / was directed to | human-claimed plumbing |

System sentence: **"the sous lays the `@mise`; the chef `@finish`es the rest — and owns anything
they un-`@mise`."**

### Per mode

- **manual:** mechanical prep → `@mise`; directed decisions → `@finish:open` (unmarked by mise — the
  AI didn't author them); chef fills → `@finish:done`, then ratifies. Chef may un-`@mise` any prep to
  claim it.
- **default:** ~all code → `@mise`; the decisions additionally → `@finish:done` — the map flags
  exactly what to audit.
- **autopilot:** ~all code → `@mise`; decisions → `@finish:done`→`:ratified`, **recorded**, then
  auto-committed (non-blocking *but not blind*).

Cleanup strips **both** markers at graduation; shipped code is just code.

### Nouns here (I3) / verbs there (I5)

I3 fixes the **nouns** — `mechanical | finish`, `@mise`, `@finish`, the `open|done|ratified` states.
I5/I6 own the **verbs** — *who moves a finish through its states* (chef in manual; sous-drives-all
non-blocking in autopilot; sous-cooks/chef-ratifies in default). Same nouns, different driver — that
is the seam, and keeping the verbs out of I3 keeps the substrate mode-invariant.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | the substrate **schema** — the `mechanical | finish` classification table + per-`finish` frame slots + `open|done|ratified` states; the **two-marker vocabulary** (`@mise` authorship/no-touch; `@finish` decision/direction) and their orthogonality; the classifier's fail-open-to-`finish` granularity (I1) |
| **May know** | `01`/`02`/`03`, I1 findings (granularity), I2 boundary mechanism (`maturity-tags.md`), the slice-brief template |
| **Must not know** | *who* moves a finish's state or *what gate* applies (execution policy — I5/I6); mode-switch wiring + manifest mode fields (I7) |
| **Invariants** | same input → same `finish`-set across modes; unmarked code is no-touch (the agent marks its own `@mise`); a frame passes the **transcriptionist test**; classifier **fails open to `finish`**; the state trail is **recorded**, never blank (autopilot non-blocking *but not blind*) |
| **Still provisional** | the exact state-tag **grammar** (`@finish:open` working); frame field names; whether the classification table lives in the brief vs a sidecar |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| the substrate-schema section of the slice-brief template | `@provisional` | add — schema settles when a real manual slice (I5) exercises it |
| `maturity-tags.md` boundary section | `@provisional` | keep — resolve its polarity to the **`@mise` inversion** (mark AI code), and cross-reference `@finish` as the orthogonal decision axis; state-tag grammar still settling |

## Stabilizes

U1 (the keystone: one substrate, three policies, no leak) and AD3 (the analysis/execution split made
concrete). Independently valuable: the finish-map concentrates **default**-mode audit on its own.

## Macro constraints (read-only)

From `03-core-vs-volatile.md`: the substrate schema is **stable core** and a one-way door — do not
calcify beyond what the dry-run justifies. Frame field names + state-tag grammar are **volatile
surface**; the `@mise`/`@finish` nouns *are* fixed (operator-ruled load-bearing). Carry the
I1-ratified certainty: the classifier **fails open to `finish`**.

## Acceptance criteria (this iteration ONLY)

- [ ] the slice-brief template gains a **fragment-classification table** — per fragment: `mechanical
  | finish`, where a `mechanical` call must **cite a named house-pattern/precedent**; absent one it
  **fails open to `finish`** (the I1 rule, made schema)
- [ ] each `finish` row carries a **frame** (contract + ≥2 precedents + fork-as-question) passing the
  transcriptionist test, **and a state** `open | done | ratified`
- [ ] the **two-marker vocabulary** is specified as orthogonal axes: `@mise` (agent-authored,
  no-touch default, claim-by-un-marking — resolving I2's polarity to the inversion) and `@finish`
  (decision/direction, mode-invariant, carries state); plus the 2×2 of how they overlay
- [ ] the **seam property** is recorded: an interrupted-autopilot file and a manual file differ
  **only** in `@finish` *states*, never in *which* fragments are `finish`es
- [ ] **one worked example slice** carried through the schema and **dry-run against all three
  policies**, showing the same `finish`-set drives manual (`open`s to cook) · default (cooked to
  `done` + audit-flagged) · autopilot (cooked + states recorded) — **distinctions intact, no leak**
- [ ] *who moves the states* + the final state-tag **grammar** explicitly **deferred** to I5/I6; the
  `@mise`/`@finish`/`mechanical|finish` **nouns** are locked here

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.cursor/skills/mise-en-place/templates/slice-brief.md` | modify | facade | add the `mechanical | finish` classification table + frame/state slots |
| `.cursor/skills/mise-en-place/maturity-tags.md` | modify | facade | resolve the boundary section to the `@mise` inversion (mark AI code; unmarked = human/no-touch; claim by un-marking); cross-reference `@finish` as the orthogonal decision axis |
| `.cursor/skills/mise-en-place/glossary.md` | modify | facade | add `mechanical` / `finish` / `@mise` / `@finish` / frame / finish-map / state-trail terms (+ plain-language column) |
| `.mep/prep/mep-authorship-modes/iterations/03-shared-substrate.md` | modify | — | embed the worked-example three-policy dry-run (the keystone evidence) |

**Conflicts:** touches engine facade docs — **must stay sequential** (I3..I8 are non-parallel).

## RED-phase gates (before GREEN)

- [ ] the **leak-test is written first**: the one worked example + the three-policy dry-run table
  drafted *before* the schema, so the schema is shaped to make the distinctions hold. A "distinction
  leaks" outcome — two modes produce different `finish`-sets, or a mode needs a field the others
  don't — **fails the slice** and reopens the schema (`04` re-plan trigger).

## Approach

- pick **one** small, real, decision-bearing example (reuse the I1 melt-PR fragment if it fits).
- draft the three-policy dry-run **first** (RED): same `finish`-set across modes; verify `@mise`
  coverage differs by mode while the `@finish` set does not.
- then write the schema into the slice-brief template; add the glossary terms; resolve the
  `maturity-tags.md` boundary to the `@mise` inversion + cross-reference `@finish`.
- keep the classifier's **fail-open-to-`finish`** rule explicit and load-bearing.

## Avoid (out of scope this iteration)

- *who* moves a state / *what gate* — execution policy (I5 manual, I6 autopilot)
- the finish **lifecycle transitions** + the "zero `open` finishes" graduation gate (I5)
- the final state-tag **grammar**, manifest `authorshipMode` fields, resolver rows (I7)
- the prime-directive amendment (I4)

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | the schema's invariants + the no-leak dry-run | change any mode's *behavior* or build an execution policy |

## Testing

- **Unit/spec:** n/a (schema + instruction artifact)
- **Manual:** the three-policy dry-run on the one worked example — pass = identical `finish`-set
  across modes, each policy reading only the shared finish-map; fail = any divergence in the planned
  artifact.

## Demonstration (worked example — the leak-test, RED→GREEN)

Built on I1's real classified fragment (TICKET-2210's `listSourceLots` read) so the schema is
proven on real shape, not a toy.

**The slice (illustrative):** a paginated read microservice listing upstream source lots.

**Classification (the finish-map):**

| fragment | class | why | cited pattern (mechanical) / fork (finish) |
|---|---|---|---|
| route + handler wiring, param parse/clamp, `DECIMAL`→number convert, response serialization | `mechanical` | instantiates house patterns | read-microservice scaffold; param-coercion helper; serializer precedent |
| **auth lock** on the endpoint | `finish` | *who may read this* is an undictated policy call | fork: session-scoped vs service-token vs role-gated? |
| **`paidMetals` filter pushed into a `Sequelize.literal` subselect** | `finish` (**fails open**) | the *mechanism* (subselect) is citable, but the *choice* to filter in SQL "to keep pagination honest" is an undictated tradeoff (I1's D2) | fork: filter in SQL (pagination-correct, harder to read) vs in app (simpler, page-count drift)? |

mechanical → `@mise` when the sous writes it; the two `finish`es carry a frame (contract + ≥2
precedents + fork) + a state.

**The leak-test — the same finish-set `{auth, sql-pushdown}` against all three policies:**

| | mechanical (the bulk) | the two `finish`es | who acts |
|---|---|---|---|
| **manual** | `@mise` (sous writes) | `@finish:open` + frame — gaps the chef cooks → `:done` → `:ratified` | chef moves the states |
| **default** | `@mise` (sous writes) | sous writes them → `@mise`+`@finish:done` — the map flags *these two* as the audit targets | chef ratifies at audit |
| **autopilot** | `@mise` | sous writes → `@mise`+`@finish:done`→`:ratified`, recorded, auto-committed | sous moves all states, non-blocking |

**Pass (no leak):** the **finish-set is identical** in every row — `{auth, sql-pushdown}` — and each
policy reads the *same* finish-map. Only two things vary, and both are *who-acts*, never
*what's-planned*: (a) `@mise` coverage (sparse in manual, ~all in default/autopilot), (b) the
`@finish` *state* each policy drives to. **Interrupt autopilot mid-run → the same two `@finish` marks
are already there** (at `:done`), so a chef takes over in manual seamlessly: reviews/ratifies exactly
those two decisions, nothing hidden.

**Fail (would reopen the schema):** any policy needing a *different* finish-set, a field the others
don't carry, or the decision/mechanical line moving by mode. None do.

**Granularity (I1 carried):** at function granularity the SQL-pushdown reads "mechanical" (a query
helper); at **decision granularity** it fails open to `finish` because the subselect *clothes* an
undictated tradeoff. The schema's classification rule encodes this: a `mechanical` label needs a
cited pattern that dictates *the choice*, not merely the *mechanism*.

## Architectural diff (fill at checkpoint)

- **Assumptions hardened:** one enumerative finish-map drives all three policies with no leak (U1);
  the two authorship/decision axes are genuinely orthogonal (the worked example carries `@mise`-only,
  `@finish`-only, and `@mise`+`@finish` fragments).
- **Coupling increased:** the slice-brief template, `maturity-tags.md`, and the glossary now share
  one vocabulary; the classifier's decision-granularity rule (I1) is baked into the schema.
- **Harder to change:** the `mechanical | finish` classification shape + the two-marker vocabulary,
  once policies bind (I5/I6).
- **Easier to change:** the `@finish:` state-tag grammar and frame field names stay `@provisional`.

## Checkpoint

One worked example drives all three policies from a single finish-map, distinctions intact; schema
recorded `@provisional`; the **two-marker vocabulary** is fixed — `@mise` (authorship/no-touch,
resolving I2's polarity to the inversion) and `@finish` (decision/direction, mode-invariant, stateful)
— with the verbs deferred to I5.

## After commit

- [ ] `/commit-prep mep-authorship-modes` — **code** scope (this brief's file ownership)
- [ ] `git commit -m "…"` → `/prep-pr-description mep-authorship-modes 03`
- [ ] `/prep mep-authorship-modes checkpoint` → draft I4 (prime-directive amendment)
- [ ] `/commit-prep mep-authorship-modes docs-delta` → `git commit` if checkpoint changed prep tree

## implement-plan instruction

> Implement **only** this file's ownership. Constitution + slice-type rules are binding. Treat
> `03-core-vs-volatile.md` as constraints, not scope. Add the `@provisional` tags per the markers
> table. Lock the `@mise`/`@finish`/`mechanical|finish` nouns; do **not** decide the state-tag
> grammar or build any execution policy. Do not read future iterations.
