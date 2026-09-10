---
name: prep
description: >-
  Iterative mise en place — classify known vs volatile, sequence mergeable
  iterations, produce slice briefs for scoped /implement-plan, graduate via
  /prep-cleanup. Docs and gates only; no application code.
disable-model-invocation: true
---

# Prep (`/prep`)

Mise en place for uncertain software work: prepare only the decisions needed for
the next reviewable slice, keep uncertainty explicit, and checkpoint what became
trustworthy before moving on.

**Prep owns macro uncertainty reduction. Slice briefs own the implement
interface — one merge unit at a time.**

This skill is **docs and gates only**. It does not write application code.
Implementation belongs in `/implement-plan` or `/execute-plan`, scoped to a
single `wiki/prep/<slug>/iterations/<n>-*.md` brief.

Cursor slash commands are adapters. The command-free routing contract lives in
[portable-routing.md](portable-routing.md); use it when a harness cannot execute `/mep`,
`/implement-plan`, `/commit-prep`, or `/prep-pr-description` directly.

## Pipeline (not linear)

**Happy path** (no tidy if prep discipline holds):

```
/prep → implement → commit → /prep checkpoint → … → /prep-cleanup
```

**Recovery path** (branch outran docs — see `/tidy`):

```
/tidy → /prep checkpoint → implement → …
```

Forward prep detail:

```
/prep (macro: phases 1–4, optional 5)
  → iterations/01-slice-brief.md
  → /implement-plan (scoped to that brief ONLY)
  → /commit-prep (code) → human git commit → /prep-pr-description → PR/stack
  → optional: /mep stage <slug> (verify promised work + prepare review stack)
  → /prep checkpoint (replan or draft iterations/02-…)
  → /commit-prep docs-delta → human commit (if prep tree changed)
  → …
  → optional late: /create-plan consolidates into wiki/plans/
  → /prep-cleanup (final) → /commit-prep → /pr-description (graduation PR)
```

Run in the main agent session. Readonly scouts (`explore`, `architecture-scout`,
`backend-scout`, `frontend-scout`, `test-scout`) for recon only.

## When to use / skip

| Use `/prep` | Skip |
|-------------|------|
| New volatile feature (greenfield prototyping) | Clear bug fix → implement directly |
| Need right-sized merge units before coding | Slice brief already approved → `/implement-plan` on that file |
| Iteration checkpoint after a slice committed | Stable scope needing AD doc → `/architect` |
| Replan next PR from existing plan + diff | Messy branch, stale prep → **`/tidy` first** |
| **After `/tidy`** — forward handoff (`checkpoint` mode) | |

## Prime directive

Build according to the rate at which truths become trustworthy.

**Operating model:** AI-accelerated evolution under **human-governed semantics**.
**Semantic governance — who owns meaning, ontology, invariants — is always human**,
fixed in prep, and holds in *every* mode; the framework never cedes it to the AI. What
*varies* by mode is the **authorship modes** below. See [maturity-tags.md](maturity-tags.md)
for the shared substrate (the `finish-map`: `@mise` marks AI-authored code, `@finish`
the decision-bearing fragments) and the in-code `@` markers during the cycle;
`/prep-cleanup` strips them when done.

### Authorship modes — the governance×authorship space

Below the standing human-governs-meaning invariant, two axes move: **who authors** the
decision-bearing code, and **who holds approval governance** — who signs off at the merge
gate at runtime. (So "govern" has two senses: *semantic* governance is always human;
*approval* governance is the axis.) Modes share one substrate; switching mode changes
*who acts*, never *what gets planned*.

|  | human authors | AI authors |
|---|---|---|
| **human approves** (blocking gate) | **manual** — operator authors the `finish`es; AI absorbs the mechanical remainder | **default** — AI authors, human audits *before* merge (today's model); the `finish-map` concentrates the audit |
| **AI approves** (non-blocking) | **code-monkey — deliberately empty** (human types while the AI signs off — the inversion that wastes the human) | **autopilot** — AI authors, and **dispatches a cross-model proxy operator** that approves slice-to-slice *up to* graduation, non-blocking *but not blind*: it emits the `finish-map` and never strips it. Graduation — cleaning the `@mise`/`@finish` trail — stays a **human** gate (the driver gets out of the car), so the audit survives. Drop the substrate and the corner degrades into ungoverned autonomy — rejected |

`default` is the model the framework runs today, now merely **named** — its behavior is
unchanged. **default and autopilot differ only at the per-slice gate**: default's human
audit *blocks* each slice; autopilot's dispatched proxy approves slice-to-slice,
non-blocking. Both still **graduate through a human** — autopilot leaves the `finish-map`
(with proxy-provenance) as the audit trail for that final sign-off.

Each mode's execution policy — *who acts, behind what gate* — lives in
[execution-policies/](execution-policies/): [manual](execution-policies/manual.md) (the operator
authors the `finish`es) and [autopilot](execution-policies/autopilot.md) (a dispatched cross-model
proxy runs manual's lifecycle, non-blocking). `default`'s policy follows.

## Hard rules

1. **Never** `git commit`, `git push`, `gh pr create`, or `gh pr merge`.
2. **Never** write application code — prep produces markdown artifacts only.
3. **Never** advance a phase without **AskQuestion** gate approval.
4. Every **core certainty** needs a **falsification criterion**. If nothing would
   change your mind, label it constraint/politics — not a certainty.
5. Each iteration in phase 4 must have: goal, approach, avoid-list, checkpoint,
   file-ownership sketch, fanout eligibility (`sequential` | `parallel`).
6. Phase 5 must emit **iteration 1 slice brief** — not only a summary doc.
7. `/implement-plan` receives **one slice brief**, not the whole roadmap.

## Session modes

Pick the session mode at bootstrap (from user message or AskQuestion). It scopes the current `/prep`
invocation and is not persisted — nothing routes off it after the session ends:

| Mode | Phases | `.cursor/prep-active` | Use when |
|------|--------|----------------------|----------|
| `greenfield` | 1→5 | yes | New volatile work, no plan yet |
| `checkpoint` | 4 (+ brief) | no | Mid-flight; replan next merge unit |
| `consolidation` | 4 (+ brief) | no | Semantic checkpoint; refactor only slice |
| `docs-only` | any subset | no | Post-hoc documentation from existing plan |

Graduation is **not** a `/prep` mode — it edits application code (strips `@` tags), which
hard rule #2 forbids here. It lives in the separate `/prep-cleanup` command.

Set roadmap frontmatter `mepAuthorshipMode` — **who authors the decision-bearing code** (orthogonal to session mode;
**absent ⇒ `default`**, today's behavior):

| Mode | Who authors the finishes | Approval gate |
|------|--------------------------|---------------|
| `default` | AI authors, human audits before merge (today's model) | blocking human audit |
| `manual` | the operator authors the finishes; AI absorbs the mechanical remainder | blocking human |
| `autopilot` | a dispatched cross-model proxy authors **and** ratifies, slice-to-slice | proxy in-flight; human at graduation |

Initiative-level; every iteration inherits it. Switch mid-flight with
`mep mode set <slug> <mode>`, which rewrites the roadmap's `mepAuthorshipMode`. On an initiative
that still carries a `manifest.json` it refuses with `legacy_state_read_only`; run `mep migrate`
first.
Each mode's execution policy lives in [execution-policies/](execution-policies/).

**Invocation examples** (detect from user message or AskQuestion):

- `/prep sample-feature foo` → `greenfield`
- `/prep upstream-contract-advanced-extensions checkpoint: next merge` → `checkpoint`
- `/prep foo docs-only from wiki/plans/foo.md` → `docs-only`

`checkpoint` seeds from `wiki/plans/<slug>.md`, `wiki/prep/<slug>/`, tidy
output (`08-tidy-handoff.md`), and/or git diff. Skip phases 1–3 unless knowledge
shifted. **After `/tidy`:** always enter checkpoint — do not rerun greenfield.

## Session bootstrap

1. Derive `slug` (kebab-case; JIRA key if given).
2. Create `wiki/prep/<slug>/` and `wiki/prep/<slug>/iterations/` if missing.
3. If `sessionMode` is `greenfield`: write `.cursor/prep-active` (slug only).
4. Read or init `04-iteration-roadmap.md` from
   [templates/04-iteration-roadmap.md](templates/04-iteration-roadmap.md); its frontmatter is the
   initiative's workflow state.
5. Execute only the current phase (roadmap `mepPhase`).

Delete `.cursor/prep-active` when user ends prep or starts implement in another
session.

## Three doc layers

| Layer | Path | Purpose |
|-------|------|---------|
| Macro prep | `wiki/prep/<slug>/0*.md` | Invariants, uncertainty, iteration order |
| Slice brief | `wiki/prep/<slug>/iterations/<n>-*.md` | One mergeable implement unit |
| Master plan (optional, late) | `wiki/plans/<slug>.md` | Consolidation after iterations stabilize |

## Scaffolding-free nodes (convention)

Every node — a skill, command, or agent in `.cursor/**`; a slice brief or macro-prep doc; a code
comment — states **what it is and why it is right, as if it had always been so**. The journey is
scrubbed: rejected paths, "changed from X", edit-narration, and rotted comments do not belong in the
node. Lineage lives in git history and in **terse, transient** entries under the **Amendments**
section of `03-core-vs-volatile.md` — never in the node itself.

This is the authoring twin of the `clean` integrity check, and it unifies three rules the framework
states piecemeal: `/update-plan`'s "write as if definitive", graduation's `@`-tag stripping
([maturity-tags.md](maturity-tags.md)), and `clean`. One principle — **the node is the destination.**

**Backstop + blind spot.** A commit gate (`hooks/deny-archaeology-commit.sh`, sharing its detector
with `staged-audit` via `hooks/scaffolding-free-check.sh`) mechanically blocks plan-archaeology from
the evergreen spine it scopes — `.cursor/skills`, `.cursor/commands`, `.cursor/agents`. Everything
else is uncovered by design: the gate's own `hooks/`, and deliberately `wiki/prep/**` — the prep
tree is process memory where deviations live. So for briefs and macro-prep docs **this convention is
the only governance**: state the destination there too; keep the lineage in `deviations[]`.

## Doc register — lite, not lossy

Terse always; lossy never. Register by content type:

- **enumerable** (ownership tables, acceptance criteria, status, deviations) → telegraphic —
  tables/bullets, no prose.
- **judgment-bearing** (uncertainty, tradeoffs, rejected alternatives) → tight prose: cut filler,
  keep the connective tissue. Review reads these for holes; lossy here hides the argument review
  exists to test.

`lite` (terse + structure, grammar intact) everywhere; `ultra` (glyph-sub, dropped
subjects/articles) nowhere — in any node a human reviews or an agent executes. Spine instructions:
terse-structured, lossless. No mechanical gate (terse-vs-lossy isn't regex-detectable); the
[staged-audit](../../skills/staged-audit/SKILL.md) docs tier carries it as a soft, waivable dimension.

## Profiles — retargeting the engine to a repo

The engine — phases, gates, the `faithful/scoped/honestly-tested/clean` vocabulary, the driver, the
enforce hooks — is repo-independent. The repo-specific facts it consults during Phase 2 and brief
authoring live in a **profile** under [`profiles/`](profiles/):

| Profile section | Binds |
|-----------------|-------|
| **reducers** | uncertainty type → how to reduce it in this repo |
| **house patterns** *(optional)* | recurring domain area → the established approach |
| **zones** | semantic zone → where code lives |
| **unit/spec** | default focused test command |
| **smoke** | full-stack smoke-test path |
| **comment syntax** | host-language examples for maturity tags |

The **active** profile is named in [`profiles/active`](profiles/active). Retarget the framework to
another repo by adding `profiles/<repo>.md` with the same sections and pointing `profiles/active` at
it — **no engine edits** (see [`profiles/example-stub.md`](profiles/example-stub.md)). Concrete
repo paths, commands, and syntax examples belong in profiles; engine docs use placeholders or
profile references for those facts.

## Foundation strategy — the shape of the first slices

A third axis, alongside the [profile](#profiles--retargeting-the-engine-to-a-repo) (repo: *where* code
lives) and the keystone (initiative: *which* uncertainty to attack first). **Foundation strategy** is
the **operator axis** — the preferred *shape* of the first slice(s), repo- and initiative-independent.
The engine already holds this position implicitly; here it is stated: **the foundation strategy is the
reducer matched to the keystone (highest-risk) uncertainty.** Don't pick a favorite — **match the shape
to the keystone**; the riskiest unknown dictates what you stabilize first. The menu is a palette.

| shape | stabilizes first | fits keystone | characteristic risk |
|-------|------------------|---------------|---------------------|
| **experience-first** (UI-mock) | the UI/product feel, against mock data + stubbed fns | **UX** — "is this the right product?" | mocked boundary ≠ real domain/data → rework when logic lands |
| **data-first** (representative corpus) | a real-ish corpus — inputs, outputs, edge cases, invariants | **data shape/quality** — "do we understand reality's shape?" | fixtures look representative but aren't → logic fails on first real contact |
| **domain-core-first** (sandboxed pure fns) | the business logic as pure, placement-deferred functions | **domain/correctness** — "does the calc hold?" | a correct engine for an unvalidated product |
| **headless-first** (engine before interface) | an *operable* path minus presentation (CLI, worker, REPL — incl. frontend logic driven from the devtools console) | **functional/pipeline** — "does the capability work, runnably?" | headless ergonomics ≠ UI ergonomics; UX an afterthought |
| **contract-first** (schema/interface) | the API or data contract both sides build against | **integration/boundary** — multiple consumers, full-stack handoff | premature calcification if the domain is still fluid |
| **walking-skeleton** (thin vertical slice) | one thin path through every layer (UI→API→domain→DB) | **architectural** — "do the layers wire up?" | shallow everywhere; **false confidence** — green plumbing masks missing depth in the hard layer |

Two adjacencies to keep straight:

- **data-first vs domain-core-first** — data uncertainty ≠ domain correctness; you can know the formula
  and still not know the data. data-first stabilizes the *corpus*, domain-core the *calc*.
- **headless-first vs walking-skeleton** — both run early, but split on *is presentation in scope for
  slice 1?* skeleton wires *through* every layer including UI (proves wiring); headless proves
  *capability*, presentation deferred (proves the engine).

**Tiebreak.** When the keystone genuinely suits more than one shape, the operator's standing preference
breaks the tie. (That slot is the seam a per-operator default would fill — deliberately not built yet:
one operator, no second.)

**Off the menu — different axes:**

- **spike / throwaway-prototype** is *non-retained* (converts ignorance to knowledge, lays no
  foundation) → it's the `exploration` half of
  [Exploration vs hardening](#exploration-vs-hardening-per-iteration), not a shape.
- **production-path / delivery-first** (deploy, observability, rollback) is largely the profile's
  concern → deferred there.

**Deliberate it, don't default it.** When sequencing the first slices (Phase 4), treat the foundation
strategy for the keystone as an architectural fork: surface 2–3 candidate shapes, weigh trade-offs,
record the pick — **reuse** the [architect](../architect/SKILL.md) skill's fork → `AskQuestion` → AD
pattern, not a bespoke one. Record as an AD (arch-doc work) or an **Amendments** line in
`03-core-vs-volatile.md` (prep work); the chosen shape + the tiebreak are enough.

## Five phases + gates

| Phase | Artifact | Gate |
|-------|----------|------|
| 1 | `01-invariant-goal.md` | Invariant goal, not disguised solution? |
| 2 | `02-uncertainty-map.md` | Uncertainties classified with right reducers? |
| 3 | `03-core-vs-volatile.md` | Core/volatile split approved? |
| 4 | `04-iteration-roadmap.md` | Iteration order + fanout rules approved? |
| 5 | `05-handoff.md` + `iterations/01-*.md` | Ready to implement iteration 1 only? |

Templates: [templates/](templates/)

**Phase writeback.** When a phase gate is approved, immediately update the frontmatter of
`04-iteration-roadmap.md`:

- Set `mepPhase` to the approved phase number.
- When phase 5 handoff is approved, set `mepPhase: 5` and `mepHandoffApproved: true`.

The roadmap frontmatter is the routing source of truth. Do not leave phase advancement as chat
memory or as prose in the body; a stale `mepPhase` misroutes later `/mep next` calls.

### Phase 1 — goal extraction

Extract ontology, not implementation:

- What outcome must exist when this succeeds?
- What would make stakeholders reject it?
- What must remain true regardless of UI, schema, or stack?
- What cannot regress?

Optional JIRA:

```bash
mcp run Atlassian jira_get '{"path":"/rest/api/3/issue/{TICKET_KEY}","jq":"{key, summary: .fields.summary, description: .fields.description, status: .fields.status.name}"}'
```

### Phase 2 — uncertainty mapping

Classify each uncertainty, then pick a reducer from the **active profile**'s `reducers` map and a
code home from its `zones` map (default [`profiles/example-stub.md`](profiles/example-stub.md); see
[Profiles](#profiles--retargeting-the-engine-to-a-repo)). When the work touches a recurring domain
area, check the profile's `house patterns`. The classification step is profile-independent; the
repo-specific reducers, patterns, and zones live in the profile, not here.

The reducer you pick for the **keystone** (highest-risk) uncertainty *is* your foundation strategy —
the shape of the first slice(s). See [Foundation strategy](#foundation-strategy--the-shape-of-the-first-slices).

**Fork early:** `deliveryTrack: frontend-only | full-stack`

### Phase 3 — core vs interchangeable (belief state)

Author `03-core-vs-volatile.md` — filename is legacy; prose uses **core certainties vs
interchangeable elements** (deprecated alias: *volatile*). See template **Guidance** section.

This is the initiative **belief state**, amended every checkpoint — not a one-time split.

Include **maturity ladder** per subsystem: experimental → provisional → stable → foundational.
Record AD candidates. Set roadmap `mepOwnedPaths` (globs for cleanup ripgrep scope).

### Phase 4 — iteration roadmap

Uncertainty reduction **sequence**, not a monolith plan. Per iteration index:

- **title**, **goal**, **sliceType** — `behavioral | architectural | consolidation | cleanup`
- **epistemicTransition** — what becomes more certain (PR title seed)
- **irreversibleDecision** — singular; if unnamed, split the iteration
- **maturityTarget** — e.g. `provisional → stable`
- **approach**, **avoid**, **checkpoint**
- **deliveryTrack** — `frontend-only` | `full-stack`
- **fanout** — `sequential` (default) | `parallel` (only if file ownership disjoint)
- **fileOwnership** — sketch; exhaustive list lands in slice brief
- **status** — `pending | brief_ready | committed | merged`
  - `committed` — slice code is on the working branch; **sync-owned** when git proves a landing
    (`/prep checkpoint` step 0 via `mep checkpoint --fix`), not hand attestation mid-session.
  - `merged` — slice landed in **trunk** via PR. Set only when confirmed (human, or detected
    via `git branch --contains <sha>`) — **never** inferred from a commit. `committed ≠ merged`.

Both shipping styles are supported: PR-per-slice (slices reach `merged` as you go) or one
stack merged at the end (slices stay `committed` until the stack lands).

Merge philosophy: **merge knowledge stabilized in this iteration**, not feature
complete.

Do **not** use generic LOC budgets as the primary sizing tool. Size iterations
for **reviewable merges** and **checkpoint proof**.

**Foundation strategy (first slices).** Before sequencing, pick the foundation strategy for the
keystone — the *shape* of the first slice(s) — by matching shape to keystone, and **deliberate** it
as an architectural fork (record the pick). This sets the shape of the first slice. See
[Foundation strategy](#foundation-strategy--the-shape-of-the-first-slices).

**Sequencing doctrine — core before interchangeable.** Phase 3 classifies identity; phase 4
**orders** it. Do not treat interchangeable rows as out of scope.

| Band | When | Owns | Policy |
|------|------|------|--------|
| **Core lock** | early | every slice-relevant C\* | Lock identity. Ship **skeleton** I\* only so the category is exercisable — not as finishes. |
| **I\* hydration** | late | I\* by **concern cluster** (one cluster per slice) | Flesh realizations after the core spine is checkpoint-vetted. Optional fidelity/polish = **evidence-gated** (skip if skeletons suffice). |

**Defer ≠ ignore.** Every I\* row needs a home: skeleton-in-core-slice, dedicated hydration slice,
`skip-unless-gated`, or explicit sunset. **Reject at the phase-4 gate:** (1) **parked core** — C\*
only in a late catch-up while early work chases I\*; (2) **catch-all hydration** — one dump for
unrelated I\* clusters; (3) **ignore-as-defer** — I\* with no planned home; (4) **skeleton-as-decision**
— locking an I\* instance inside a core-lock slice.

Roadmap must include a **coverage table** (C\*/I\* → iteration). Template:
[templates/04-iteration-roadmap.md](templates/04-iteration-roadmap.md).

### Phase 5 — handoff (slice-first)

Produce:

1. `05-handoff.md` — macro summary, iteration index, consolidation trigger
2. **`iterations/01-<short-title>.md`** — full slice brief from
   [templates/slice-brief.md](templates/slice-brief.md)

Set the brief's own frontmatter `mepIteration: 1` and `mepStatus: brief_ready`, and point the roadmap's
`mepCurrentIteration` at it. The brief's path is its identity — there is no separate `briefPath` field.

**Do not** default to `/create-plan`. Master plan is optional when:

- Multiple iterations committed and shape is stable
- Backend API handoff needed (`upstream_refining_contracts.metadata` promotion)
- Stakeholders need one assessable document

Then: `/create-plan` consolidates prep artifacts → `wiki/plans/<slug>.md`.
Set roadmap `mepMasterPlanPath` and commit via `docs-delta` (or include in next checkpoint docs commit).

### Phase 5 — docs bootstrap (before implement)

Prep artifacts must be in git before the first implement pass.

1. **AskQuestion:** approve prep tree for bootstrap commit?
2. Delete `.cursor/prep-active` (unblocks commit hook).
3. Record in the roadmap frontmatter: `mepPrepDocsBootstrapped: true` — set this *before* committing so the bootstrap commit captures its own state instead of leaving an uncommitted state delta.
4. `/commit-prep <slug> docs-bootstrap` → human `git commit`.

Then recommend `/implement-plan` scoped to iteration 1 brief only.

## Prep artifact commits

Process memory lives in `wiki/prep/` and `wiki/plans/<slug>.md`. Product code and
prep/plan docs use **separate** commit-prep scopes — never bundle by default.

Set roadmap `mepMasterPlanPath` when a master plan exists or is created (`/create-plan`,
pre-existing `wiki/plans/<slug>.md`, or tidy seed). Commit-prep docs modes always
include that path when set.

| When | Mode | Scope |
|------|------|-------|
| Forward prep phase 5 handoff | `docs-bootstrap` | `wiki/prep/<slug>/` + `masterPlanPath` |
| Tidy phase 5 handoff (before code groups) | `docs-bootstrap` | prep tree + plan doc for initiative |
| After each slice commit + checkpoint | `docs-delta` | changed prep tree + plan doc |
| After `/create-plan`, `/update-plan`, `/improve-plan` | `docs-delta` | plan doc (+ prep tree if also changed) |
| After implement (slice code) | code (default) | slice brief file ownership |
| Tidy `07-commit-plan` groups | code (default) | group paths — **exclude** prep docs scope |
| `/prep-cleanup` graduation | code + `docs-delta` | ownedPaths + `06-graduation.md` |

**Forward rhythm:**

```
phase 5 → docs-bootstrap → implement slice N
  → commit-prep (code) → commit
  → /prep checkpoint → docs-delta → commit (if changes)
  → repeat …
```

**Tidy rhythm:**

```
tidy phase 5 → docs-bootstrap → commit
  → commit-prep group 1..N (code only) → commits
  → /prep checkpoint
```

## Checkpoint loop (after iteration commits)

User runs `/prep` in `checkpoint` mode. **One atomic session** — do not re-run `/mep where` until
sync (when eligible), replan, and draft-next are complete.

0. **Sync (harness plumbing):** `tools/mep/bin/mep checkpoint <slug> --json`, then `--fix` only
   when the report has no blockers and no `commit_required_before_checkpoint`. Applies deterministic
   frontmatter writebacks (`mepBriefRevision`, `mepImplementationRevision`, `mepStatus→committed`)
   from git — not hand attestation.
1. Re-read git diff + sync outcome. Optional **landed-slice retrospective:** was last commit scoped
   to its brief? Feed gaps into next **Avoid** or schedule consolidation (`brief-preflight-check.md`).
2. **Revisit belief state (`03-core-vs-volatile.md`):** read landed slice **architectural diff** +
   **category vs instance**. Amend tables — promote category certainties to **core**, register
   **interchangeable** instances/UX, **falsify** disproved core rows. Append **Amendments** row
   (evidence + replaces); rewrite affected tables clean. If category was story-only, note rework or
   schedule follow-up. Record *no changes — iter N confirmed Ck* when appropriate.
3. Update `04-iteration-roadmap.md` if order/volatility shifted.
4. Draft **next** `iterations/<n>-*.md` only.
5. **Brief preflight** on the draft — plan-level scoped/blast-radius (`brief-preflight-check.md`); not
   clean-code on nonexistent code. Revise or split slice if preflight fails.
6. Gate: human approves brief → `brief_ready` → `/implement-plan` scoped to that file.
7. `/commit-prep <slug> docs-delta` → human commit if prep files changed.

Stopping after step 0 and re-resolving routes to checkpoint again — that is an interrupted session,
not the happy path. After a complete close+replan session, `where` should resolve to
`/implement-plan`, not another `/prep checkpoint`.

**Amend ritual (scaffolding-free).** When a checkpoint *changes a prior decision* — re-scopes a
slice, renumbers iterations, reverses an approach — do **both**: (a) append a **terse** entry to the
**Amendments** section of `03-core-vs-volatile.md` capturing the lineage, and (b) **rewrite the affected node(s) clean**,
as if the new decision had always held. The deviation carries the journey; the node carries only the
destination. This is what stops a palimpsest from forming as the plan evolves — the live half of the
scaffolding-free convention.

## After commit (checkpoint loop)

1. `/commit-prep <slug>` — **code** scope (committed slice brief file ownership)
2. Human `git commit` → `/prep-pr-description <slice brief>`
3. `/prep <slug> checkpoint` — update roadmap, draft next brief
4. `/commit-prep <slug> docs-delta` — human commit if checkpoint touched prep tree
5. When all iterations done: `/prep-cleanup` → code + `docs-delta` → `/pr-description`

## Reconciling status — doctor (`committed` vs `merged`)

Iteration `status` is self-attested, but the two rungs differ in *where their evidence lives*.
`committed` on a landed slice is sync-owned — `/prep checkpoint` step 0 applies it from git when
eligible, not hand attestation mid-session. `merged` (trunk landing) happens later, elsewhere, by a
human, so whoever writes it asserts a state they didn't witness; it can only be confirmed out-of-band,
and that gap is where the recorded state drifts from git. The **doctor** supplies that check:

```bash
tools/mep/bin/mep doctor <slug> --json [--trunk main] [--fix]
```

- **Reports** any iteration claiming `merged` that trunk does **not** contain (a false-merged
  desync), and any `committed` iteration trunk **now** contains (a promotion candidate).
- **`--fix`** applies only the git-proven `committed`→`merged` promotions; a false `merged` is
  **never** auto-cleared — it needs human judgment.
- Granularity is branch-level: the branch counts as merged iff trunk contains HEAD (fits a
  stack/massive-PR flow; per-slice would need a recorded commit sha per iteration).

## implement-plan contract

When handing off a slice brief, state explicitly. Cursor users may receive this as `/implement-plan
<briefPath>`; other harnesses receive the same contract as prose:

> Implement **only** `wiki/prep/<slug>/iterations/<n>-*.md`.
> Treat `03-core-vs-volatile.md` as **constraints**, not scope — and as **living belief state**:
> checkpoint amends it from each slice's architectural diff. Classify **core certainties** (identity)
> vs **interchangeable elements** (realizations), not churn rate.
> Do not read future iterations. File ownership in the brief is exhaustive.

Slice brief should include where applicable:

- **Epistemic transition** + **irreversible decision** + **category vs instance** + **constitution** block
- **Epistemic markers** — which `@` tags to add/remove ([maturity-tags.md](maturity-tags.md))
- Acceptance criteria (this iteration only)
- File ownership table with **zone** column
- RED-phase gates
- **Slice-type rules** (behavioral vs architectural — no cross-contamination)
- Test commands + manual steps
- **Architectural diff** (fill at checkpoint)
- **Brief preflight** (complete at checkpoint before `brief_ready`) — see `brief-preflight-check.md`
- `fanout: sequential | parallel`

During implement: add commented `@` tags on new boundaries. Tags are **process
artifacts** — removed in `/prep-cleanup` before final merge. Keep durable intent
comments that explain permanent business rules.

## Exploration vs hardening (per iteration)

| Mode | When | Implement bar |
|------|------|---------------|
| `exploration` | confidence low/medium | working prototype; mock-api OK |
| `hardening` | checkpoint passed | clean-code; `/commit-prep`; extract util layers |

Set on each slice brief, not only on the roadmap.

## Graduation cleanup (final pass)

When every iteration is done — committed on the branch, or already merged if shipped
PR-per-slice — and the initiative is complete:

1. User runs `/prep-cleanup <slug>` (or `sliceType: cleanup` brief + implement).
2. Remove all `@experimental|@provisional|@stable|@foundational|@reference-only`
   tags and `PROVISIONAL:` markers from the roadmap's `mepOwnedPaths`.
3. Rewrite tag-only comments into **durable intent** prose where still needed.
4. Write `06-graduation.md`; set `initiativeStatus: graduated`.
5. `/commit-prep` (cleanup mode) → `/pr-description` (graduation PR) → human merge.

**Final code:** good code only. Process memory lives in `wiki/prep/`, not `@` tags.

## Relationship to other commands

| Command | When |
|---------|------|
| `/prep` | Macro + slice briefs; uncertainty still moving |
| `/tidy` | **Recovery** — messy branch; backfill prep; then `/prep checkpoint` |
| `/implement-plan` | **One approved slice brief**; add `@` tags per brief |
| `/execute-plan` | Slice brief says `fanout: parallel` + disjoint file ownership |
| `/prep-cleanup` | **Final** — strip in-code epistemic markers |
| `/prep-pr-description` | Per-slice PR; reviewer-facing summary from a prep slice brief |
| `/mep stage` / `/prep-stage` | Verify promised slices and prepare a gated PR stack |
| `/pr-description` | Architecture-doc, master-plan, or graduation PR |
| `/architect` | Stable requirements; AD doc before consolidation |
| `/create-plan` | **Late** consolidation or greenfield without prep |
| `/assess-plan` | Master plan or large slice brief before implement |
| `/commit-prep` | After implement or tidy group: gated audit rounds, staged handoff + message |
| `/staged-audit` | Human-in-loop audit; spot checks |
| `/feature-flag` | Rollout gating per phase 2 |

Portable equivalents for the routing/handoff commands live in
[portable-routing.md](portable-routing.md). Do not duplicate the resolver logic in command files or
skills; re-read the plan documents + git state and translate the selected resolver row.

**Recommend after phase 5:**

```
1. AskQuestion: approve prep tree?
2. Delete .cursor/prep-active
3. /commit-prep <slug> docs-bootstrap → git commit
4. /implement-plan — scope to wiki/prep/<slug>/iterations/01-*.md only
   Constraints: wiki/prep/<slug>/03-core-vs-volatile.md
   After implement: /commit-prep (code) → git commit → /prep-pr-description
   Optional review prep: /mep stage <slug>
   After checkpoint: /commit-prep docs-delta → git commit (if changed)
```

When all iterations done: `/prep-cleanup <slug>` before final PR.

## Reply format

After each phase: artifact path, one-line summary, gate question.

After phase 5: docs-bootstrap instruction + slice brief path + `/implement-plan` scoping.

## Resuming

If `.cursor/prep-active` exists, read slug + `04-iteration-roadmap.md`; continue from its
`mepPhase` or draft next iteration brief in checkpoint mode.

## Examples

- Macro + slices done well (consolidated): `wiki/plans/upstream-contract-advanced-extensions.md`
- `@` tag reference: [maturity-tags.md](maturity-tags.md)
