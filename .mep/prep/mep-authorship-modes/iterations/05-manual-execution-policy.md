# Iteration 5 — manual execution policy (the finish lifecycle + AD4)

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/05-manual-execution-policy.md`
**Status:** committed
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** framework-internal
**Fanout:** sequential · **(may split — see "Split decision")**

## Epistemic transition

**What became more certain:** with the substrate fixed (I3) and the space named (I4), the framework can
finally make **manual mode actually run**. Manual is the first *execution policy* to bind to the
substrate — and the one that proves the whole ownership-face thesis (a human authors the
decision-bearing code, *pleasantly*, and is load-bearing). It supplies the **verbs** I3 deliberately
left out: *who* moves a `finish`'s state and *what gate* applies.

**Irreversible decision (one):** the **manual finish lifecycle** — `@finish:open → done → ratified`
driven by *human authors the decision / AI proposes characterization / human ratifies* — **plus the
temporal test rule (AD4)** that governs ratification. One-way: I6 (autopilot) reuses this exact
state-machine + graduation gate with a different approver, and I7 wires a selector to it. The
*nouns* are I3's (fixed); this slice fixes the *verbs* and the *gate*.

**Maturity target:** `provisional → stable`

## State-machine boundary (triggers here; engine-routing in I7)

Three layers, three slices. I3 fixed the **state vocabulary**; I5 fixes the **triggers + who acts**;
I7 makes the engine *route* on those states. I5 stays at the **marker layer** — the in-code
`@finish:<state>` trail is the **source of truth**, and the resolver stays blind to it until I7.

| layer | what | slice |
|-------|------|-------|
| state vocabulary (`open/done/ratified`) | marker suffixes exist | I3 — done |
| triggers + who acts (the manual verbs) | which action advances each edge | **I5 — this slice** |
| engine routes on finish-state (resolver "scaffolded, finishes open" row; per-finish status persisted) | the driver reads + routes | I7 — later |

**Triggers (locked — manual; marker is the source of truth):**

| edge | triggering action | actor | scaffolding |
|------|-------------------|-------|-------------|
| → `@finish:open` | implement classifies a fragment as `finish`, writes the frame **+ the contract-level AC tests (red)**, and leaves **codeless inline guidance** (what / recommendations / libraries — no code) in the fenced region | AI | guidance present |
| `open → done` | the human writes code to **green the AC tests** = authors the decision; **claims** the edge (flips the suffix; a tool may offer to, never auto-infers); strips guidance as they go | human | guidance shrinking |
| `done → ratified` | the ratchet — AI **proposes** blackbox validation (characterizing what now exists) + a **code-speaks-for-itself** check (clean/cleaner, no comment crutch); human **ratifies** (never inferred); **all inline guidance verified stripped** | human | guidance gone; `@finish:ratified` marker stays |
| marker sheds | graduation — backstop sweep | `/prep-cleanup` (I8) |

**Two test moments (the AD4-vs-TDD resolution).** AD4 is *mechanism-level*: a test must not assert a
*mechanism* before it exists. Contract-level acceptance tests are normal TDD red and **precede** code.
So: (1) **red AC tests** at `open` assert the *contract* (observable behavior), never the *how* — a test
that pins the mechanism pre-decision is the same anchoring failure as a stub; (2) **blackbox validation**
at `ratified` characterizes the now-existing solution, no over-testing of edges.

**No prose invariants.** The ratchet emits *tests*, never invariant-comments. Where a fragment genuinely
can't be tested, the bar is **"the code speaks for itself"** (clean/cleaner-code), not a comment.

The only **enforced** marker-layer check is a **readiness grep** (`@finish:open` present → not ready),
in the `scaffolding-free-check.sh` style — *not* a new engine or resolver row.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | the **manual execution policy** as a self-contained protocol: the `@finish` state transitions and *who* moves each in manual (human authors `open→done`; AI *proposes* a characterization, human *ratifies* `done→ratified`); the **hardening ratchet** (AI proposes / human ratifies — never auto-commit); the **temporal test rule (AD4)** as the governing test discipline; the **readiness gate** that blocks while any `@finish:open` remains. Likely a new policy doc + the `@finish` lifecycle/verbs in `maturity-tags.md` + a manual-mode hook in the implement flow |
| **May know** | I3 substrate (`maturity-tags.md`, the slice-brief `finish-map` schema, `@mise`/`@finish` nouns + states); I4's named modes (`SKILL.md` directive); `01-invariant-goal` (manual success condition + rejection criteria); `03-core-vs-volatile` (AD4, the transcriptionist line, hardening-is-human-ratified, path-2) |
| **Must not know** | autopilot's auto-approve path (I6); the manifest `authorshipMode` **field**, the resolver/driver **routing on** finish-state (the "scaffolded, finishes open" row), per-finish status **persisted** in the manifest, mode-switch UX (I7) — manual is a *marker-layer protocol*; the engine stays blind to finish-state until I7 |
| **Invariants** | manual hands the human the **consequential** code, never busywork; the frame stays **non-anchoring** (transcriptionist test); manual is **pleasanter** than wing-it-then-review; the human's contribution is **load-bearing**; **AD4** — a test asserts only what already exists; **hardening is human-ratified** (no auto-committed characterization); the readiness gate blocks on any `@finish:open`; `default` behavior unchanged |
| **Still provisional** | frame rendering / prompt format (settles after the U3 anchoring trial); the exact ratchet UX; whether this slice splits (5a/5b/5c) |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| the manual policy doc (new) | `@provisional` | add — lifecycle UX still settles after a real run + U3 |
| the `@finish` lifecycle/verbs section in `maturity-tags.md` | `@stable` | add — the state-machine is the hardened contract I6/I7 bind to |

## Stabilizes

The manual mode end-to-end; the `open→done→ratified` state-machine + readiness gate that **I6
(autopilot) reuses** (same lifecycle, AI-approves gate); **AD4** as a framework-wide TDD discipline.
Independently valuable: even before autopilot/wiring exists, an operator can run manual on a real slice.

## Macro constraints (read-only)

From `03-core-vs-volatile.md`: **AD4** (a test asserts only what already exists) is stable core;
the **transcriptionist line** is the frame's acceptance test; **hardening is human-ratified** (no
auto-committed characterization); **path-2** (human-default authorship, AI subtracts only what it can
cite). `default` stays behavior-compatible. Marker spelling + frame rendering are the **volatile**
surface — don't calcify them here. From `01-invariant-goal`: minimalism — define the policy, don't
build the selector (that's I7).

## Acceptance criteria (this iteration ONLY)

- [ ] on a **real slice**, manual mode drives a `finish` through **frame → human-fill (`open→done`) →
  blackbox validation at `ratified`, human ratifies)**
- [ ] at `open`, the AI writes **contract-level AC tests (red)** — asserting the *what*, never the
  *mechanism* — plus **codeless** inline guidance (what / recommendations / libraries, **no code**)
- [ ] the AI authors **all** `mechanical` fragments (`@mise`) and authors **no** `finish` decision
  (the human greens the AC tests = the human's code is load-bearing)
- [ ] the ratchet **never** commits a validation test the human did not ratify; emits **tests, not
  prose-invariant comments**
- [ ] **AD4 holds (mechanism-level)**: no test asserts a *mechanism* before it exists; contract-level
  red precedes code as normal TDD
- [ ] at `ratified`, the inline guidance is **verified stripped** (not deferred to graduation); where
  untestable, the **code-speaks-for-itself** bar (clean/cleaner) is met
- [ ] a **readiness gate** reports not-ready while any `@finish:open` remains in owned paths
- [ ] validated against the **transcriptionist line** and the **pleasantness** criterion
- [ ] **no** autopilot path, **no** manifest field / resolver row, `default` behavior unchanged

## Finish-map (fragment classification)

This is a policy/protocol slice; "fragments" are the policy definitions. Mostly decision-bearing.

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| the `@finish` state-machine semantics (who moves `open→done→ratified` in manual) | `finish` | — |
| the hardening-ratchet protocol (AI-proposes / human-ratifies shape) | `finish` | — |
| writing AD4 into the policy as the governing test rule | `mechanical` | a ratified decision transcribed — `03-core-vs-volatile.md` L18 + AD4 |
| the readiness-gate check ("zero `@finish:open`") | `finish` (fails open) | a grep mechanism (cf. `scaffolding-free-check.sh`) clothing a *what-blocks* decision |

**Frame — the lifecycle finish (`open`):**

| finish | contract | ≥2 precedents | fork | state |
|--------|----------|---------------|------|-------|
| the manual finish lifecycle + ratchet | human authors every decision (load-bearing); AI proposes but never ratifies; AD4 honored; readiness gate blocks on `open`; pleasanter than wing-it | (1) `03-core-vs-volatile` AD4 + hardening-ratified rows; (2) `01-invariant-goal` manual success-condition + rejection criteria; (3) I3 `maturity-tags.md` `@finish:<state>` markers | **(resolved — see below)** | `ratified` |

> **Resolved (authored/ratified in the I5 design session — the first manual-mode run, dogfooded):**
> - **source of truth** = the in-code `@finish` marker; `done` is **human-claimed**, `ratified` is **human-only / never inferred**.
> - **ratchet output** (was fork 1) = **tests, not prose invariants**: contract-level **AC tests red-first** (the human greens them) + **blackbox validation** at `ratified`; where a fragment can't be tested, the bar is **code-speaks-for-itself** (clean/cleaner), never an invariant-comment.
> - **fill ergonomics** (was fork 3) = **codeless guided region**: inline guidance (what / recommendations / libraries) but **no code**; the guidance is **transient** — stripped by the ratchet at `ratified` (not deferred to graduation), so the surviving code self-documents.
> - **AD4** clarified to its mechanism-level reading; the readiness gate is a **grep clause**, not a new hook/resolver row.

**In-code markers:** per I3 — `@mise` (AI's code; unmarked = human's, no-touch) and `@finish:<state>`
(the mode-invariant decision trail). This slice adds the **verbs**, not the nouns.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.cursor/skills/mise-en-place/execution-policies/manual.md` | new | facade | the manual policy doc — the **verbs**: two-moment test model, ratchet, codeless guidance, readiness gate. Owns who-moves-each-state (mode-bound) |
| `.cursor/skills/mise-en-place/maturity-tags.md` | modify | facade | **mode-invariant** clarification only: `@finish` inline guidance-prose is transient (sheds at `ratified`); the marker persists to graduation. The *verbs* live in the policy doc, not here (I3 keeps this mode-invariant) |
| `.cursor/skills/mise-en-place/SKILL.md` | modify | facade | one pointer from the implement flow to the manual policy (no behavior change to `default`) |
| `.mep/prep/mep-authorship-modes/03-core-vs-volatile.md` | modify | (prep) | **AD4 prose tightened** to its mechanism-level reading (rides docs-delta, not the code commit) — discovered during this slice; deviation recorded |

**Conflicts:** touches the engine spine (`SKILL.md`, `maturity-tags.md`) — **must stay sequential** (I3..I8 non-parallel).

## RED-phase gates (before GREEN)

- [ ] **no-contradiction first**: confirm the lifecycle leaves AD4, the transcriptionist line, and
  hardening-is-human-ratified (all `03-core-vs-volatile` core) intact — *before* writing the protocol.
- [ ] **worked-example dry-run (paper)**: take a real `finish` from the I1/I3 example and walk it
  `frame → open → human-fill → done → AI-proposes → human-ratifies → ratified`. RED = the lifecycle
  leaves a finish unaccounted, lets the AI author a decision, or lets a characterization land
  unratified.

## Approach

- write the manual policy doc against the frame's contract; cite I3's substrate (don't reopen the nouns).
- define the three transitions + the manual approver for each; the ratchet (AI proposes / human ratifies);
  the readiness gate; AD4 as the test discipline.
- run the no-contradiction check (RED), then the paper dry-run, then write.
- keep it to **verbs + gate** — name the policy, change nothing about `default`, build no selector.

## Avoid (out of scope this iteration)

- autopilot's auto-approve path (I6)
- the manifest `authorshipMode` field, resolver rows, mode-switch UX (I7)
- reopening the substrate schema or marker nouns (I3, committed)
- the "does the analysis layer ship standalone first" sequencing question

## Split decision (resolve at the approval gate)

The roadmap flagged this slice **likely splits**. The single irreversible decision is *the manual
finish lifecycle + AD4*. If that holds as one merge unit, ship as **I5**. If implement reveals it's
two decisions, split:

- **5a** — `@finish` lifecycle + markers wired into the implement flow (frame → open → human-fill → done)
- **5b** — the hardening ratchet (AI proposes / human ratifies → ratified) + AD4 + the readiness gate

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | the lifecycle's coherence + the no-contradiction check + the dry-run | build autopilot, wire a mode selector, or change `default`'s behavior |

## Testing

- **Unit/spec:** n/a if pure protocol docs; if the readiness gate lands as a hook/script, a shell test
  asserting it reports not-ready on a planted `@finish:open` and ready when none remain.
- **Manual:** the worked-example dry-run above; confirm the transcriptionist + pleasantness criteria
  on the human-filled finish.

## Architectural diff

- Assumptions hardened: manual mode is *real* — a human authors finishes by hand and is load-bearing,
  the AI absorbs only the mechanical remainder; the in-code `@finish:<state>` marker is the source of
  truth; ratification is human-only, never inferred from green tests.
- Coupling increased: the manual policy binds to I3's substrate (finish-map, `@mise`/`@finish`);
  autopilot (I6) must now reuse this exact three-state lifecycle + graduation gate, differing only in
  the approver.
- Harder to change: the `open → done → ratified` lifecycle and the human-authors / AI-proposes /
  human-ratifies shape are now a contract later modes build on; AD4's mechanism-level reading is fixed.
- Easier to change: the *verbs* live in `execution-policies/manual.md`, isolated from the
  mode-invariant substrate — a new mode is a new policy doc, not a substrate edit; `default` untouched.

## Checkpoint

A real `finish` goes `frame → human-fill → ratchet → ratify → marker sheds`; the readiness gate blocks
on an unfilled finish; AD4 held; `default` untouched; no autopilot, no selector.

## After commit

- [ ] `/commit-prep mep-authorship-modes` — **code** scope (this brief's file ownership)
- [ ] `git commit` → `/prep-pr-description mep-authorship-modes 05`
- [ ] `/prep mep-authorship-modes checkpoint` → draft I6 (autopilot execution policy)
- [ ] `/commit-prep mep-authorship-modes docs-delta` → `git commit` if checkpoint changed prep tree
- [ ] Optional: `/create-plan` consolidation (the roadmap's post-I5 trigger, once manual is stable)

## implement-plan instruction

> Implement **only** this file's ownership. Constitution + slice-type rules are binding. Treat
> `03-core-vs-volatile.md` and `01-invariant-goal` as constraints, not scope. Run the no-contradiction
> check **and** the worked-example dry-run (RED) before writing the protocol. The lifecycle is the
> decision — author/ratify the genuinely-open forks with the operator. Do **not** build autopilot or
> touch the manifest mode field. Do not read future iterations.
