# mise-en-place glossary & next-command resolver

Two jobs, one file:

1. **Glossary** — translate the framework's vocabulary to plain developer language (and back), so
   an operator can drive without learning the ontology.
2. **Resolver** — the single, authoritative table mapping initiative state (`manifest.json` + git)
   to the **literal next command**. `/mep` and any "what's next?" prose read *this* table; the
   logic is **not** copied into skill bodies (one home — don't smear next-command logic across skills).
   Non-Cursor harnesses use the same table, then translate the resolved command through
   [portable-routing.md](portable-routing.md).

## Glossary (framework term ↔ plain language)

Read either column first; the map works both ways.

| framework term | plain language |
|----------------|----------------|
| initiative | the whole effort — many pieces of work, one branch / feature |
| prep / mise-en-place | planning the next piece of work before coding |
| phase (1–5) | a step in the up-front planning |
| slice / iteration | one small, self-contained piece of work — about one PR's worth |
| brief | the written plan for a single piece of work |
| checkpoint | `/prep <slug> checkpoint` — review what we learned, **amend belief state** (`03-core-vs-volatile`: core vs interchangeable), and plan the next piece of work; **one command per slice boundary** (manifest sync is step 0 inside the session, not a separate operator step) |
| belief state / core vs interchangeable | `03-core-vs-volatile.md` — what defines architectural **identity** (core) vs what is merely a **realization** (interchangeable); amended every checkpoint. Filename says *volatile*; use *interchangeable* in prose |
| core certainty | an invariant of identity — substituting it falsifies the architecture; needs falsification criterion |
| interchangeable element | another realization could occupy this slot without changing system identity; not the same as *plugin* or *will change soon*; **defer ≠ ignore** — still needs a roadmap home |
| core-lock band | early roadmap iterations that lock C\* identity; may ship skeleton I\* only so the category is exercisable |
| I\* hydration | late roadmap iterations that flesh interchangeable realizations — **layered by concern**, not one catch-all dump |
| skeleton (I\*) | minimal instance shipped inside a core-lock slice so the category can be demoed; not a finish / not hydration |
| evidence-gated slice | optional hydration/polish opened only when external evidence or a blocking demo gap appears; otherwise skip |
| brief preflight | checkpoint plan audit on the **draft** next brief before `brief_ready` — scoped ownership, blast radius; not clean-code on code (`brief-preflight-check.md`) |
| slice integrity check | `/commit-prep` audit of **staged diff** vs brief — faithful, scoped, honestly-tested (`slice-integrity-check.md`) |
| commit-prep | stage changes and sanity-check them for a commit |
| staged-audit | review staged changes against the code-review bar |
| docs-bootstrap | the first commit of the planning notes |
| docs-delta | commit the updated planning notes |
| graduation / prep-cleanup | the final cleanup pass before the effort is done |
| stage / prep-stage | verify promised work and prepare it for review as a PR stack |
| manifest | the initiative's state file (`wiki/prep/<slug>/manifest.json`) |
| maturity tag (`@experimental` …) | a marker of how settled a piece of code is |
| mise-en-place metaphor | AI is the **sous** (does the prep); the human is the **chef** (makes the calls) |
| authorship mode | who writes the decision-bearing code and who signs off — `manual` (you write + own), `default` (AI writes, you audit before merge), `autopilot` (AI writes + self-approves, non-blocking, recorded) — over one shared plan |
| governance×authorship space | the grid the framework lives in: **who authors** × **who approves at the merge gate**; *semantic* governance (who owns meaning) sits above the grid and is always human. three live corners — manual, default, autopilot — and the human-types / AI-approves ("code-monkey") corner left empty on purpose |
| `mechanical` | a fragment the AI may absorb — it instantiates a cited, named pattern |
| `finish` | a decision-bearing fragment the human owns — no cited pattern dictates the *choice* |
| finish-map | the per-slice classification of every fragment as `mechanical` or `finish` (+ frames); the one artifact all three authorship modes read |
| frame | non-anchoring guidance for a `finish`: contract + ≥2 precedents + the fork (a question, not an answer) |
| `@mise` (marker) | tags the agent's own generated code; **unmarked code is the human's, no-touch**; claim any region by deleting its `@mise` |
| `@finish:<state>` (marker) | tags a decision the agent directs the human to author; `open → done → ratified` |
| state-trail | a `finish`'s recorded `open → done → ratified` history; mode-invariant, so one mode can hand off to another mid-flight |

The seven operator verbs (`next` / `where` / `start` / `done` / `stage` / `curate` / `mode`) are
defined in [`.cursor/commands/mep.md`](../../commands/mep.md). **`curate`** — lossy-compress
discovery into review narrative, materialize integration branches, then hand off to **`stage`**.
The rest are already plain and need no translation.

## Checkpoint — one operator command

**Operator surface:** only `/prep <slug> checkpoint`. `/mep` macros and the resolver never route to
`tools/mep/bin/mep checkpoint` as a separate next step.

When git proves a slice landed but the manifest lags, the prep session opens with harness plumbing:
`tools/mep/bin/mep checkpoint <slug> --json`, then `--fix` only when the report has no blockers and
no `commit_required_before_checkpoint` finding. That sync is **step 0 inside the session** — not a
second checkpoint, not a standalone `/mep next` gate.

**Atomic session.** Finish the whole session before re-running `/mep where`: sync (when eligible) →
replan → draft the **next** brief → advance `currentIteration` to `brief_ready` when closing a
landed slice → `/commit-prep docs-delta` → human commit when prep docs changed. Normal slice
boundary = **one** checkpoint invocation. Stopping after step 0 and re-resolving routes to checkpoint
again — that is an interrupted session, not the happy path.

| entry state | session work |
|-------------|--------------|
| `brief_ready` + code landed (row 10) | close + replan: sync → mark slice committed → draft **next** brief |
| `pending` (row 6) | plan-only: draft the slice brief |
| current `committed`/`merged`, next still unplanned (row 11) | **recovery only** — plan-only after interrupted close or out-of-band sync |

Row 11 is not the normal successor to row 10. After a complete close+replan session, `where` should
resolve to `/implement-plan`, not another `/prep checkpoint`.

## Resolver — state → next literal command

Inputs: the initiative `manifest.json` and `git` (working-tree state **and commit log**). Resolve
**top-down; first match wins**. `<slug>` comes from the invocation; `<briefPath>` comes from the
manifest (when present). In Cursor, every result is a **concrete, resolvable command** — never the
self-referential `/mep next`. Outside Cursor, resolve the same row and perform the command-free
procedure in [portable-routing.md](portable-routing.md).

**Precondition — no scaffolding yet.** If `wiki/prep/<slug>/manifest.json` does **not** exist, the
table below has no state to read; resolve from the branch instead:

- branch carries **no relevant tracked work** (no commits ahead, nothing staged/unstaged that
  belongs to this effort — untracked unrelated files don't count) → `/prep <slug>` (greenfield start).
- branch **already carries relevant work** (commits, or staged/unstaged tracked changes) → `/tidy
  <slug>` (recovery: the branch outran its docs; tidy backfills the prep tree, then `/prep
  checkpoint` resumes). **Confirm relevance with the user first** — the driver detects *that* work
  exists, but only the human classifies it as this effort's vs. unrelated cruft.

Mid-flight drift — a manifest that *exists* but lags the branch — is **not** detected here; this
resolver trusts the forward invariant (docs lead code) and does not reconcile manifest claims
against git history.

| # | state (manifest + git) | next literal command | plain "you are here" |
|---|------------------------|----------------------|----------------------|
| 1 | `initiativeStatus == graduated` | — (nothing; the effort is done) | finished |
| 2 | current iteration `sliceType == cleanup`, **or** every iteration `status` ∈ {`committed`, `merged`, `skipped`} | `/prep-cleanup <slug>` | all slices done → final cleanup |
| 3 | `phase < 5`, prep is not bootstrapped/handed off, and no current iteration record exists | `/prep <slug>` | still planning the effort up front |
| 4 | `phase == 5` and `prepDocsBootstrapped == false` | `/commit-prep <slug> docs-bootstrap` | planning done → first save the notes |
| 5 | implement would be next (unbuilt `brief_ready` or open finish) **and** `wiki/prep/<slug>/**` (or `masterPlanPath`) has **uncommitted** changes **and** owned implementation is clean **and** the slice is not yet built | `/commit-prep <slug> docs-delta` | planning notes changed on an implement route → save them before building |
| 6 | current iteration `status == pending` | `/prep <slug> checkpoint` | the next slice has no plan yet → draft it |
| 7 | current iteration `status == brief_ready` **and the slice isn't built yet** (no implementation change after the recorded or derivable brief revision; owned files clean) | `/implement-plan <briefPath>` | plan is ready → build the slice |
| 8 | current iteration's **`status`** isn't `committed`/`merged` yet **and** owned paths contain an **open finish** (`@finish:open` present) | `/implement-plan <briefPath>` | the slice has an unmade decision → author the open finish(es) before it can be committed |
| 9 | current iteration's **`status`** isn't `committed`/`merged` yet **and** owned files have **uncommitted** changes (work sits in the tree, not on the branch) | `/commit-prep <slug>` | slice built → stage and commit it |
| 10 | current iteration's **`status`** isn't `committed`/`merged` yet **and** owned files are **clean** (the code already landed on the branch — the manifest just hasn't caught up) | `/prep <slug> checkpoint` | slice on the branch → review and plan next |
| 11 | current iteration `status` ∈ {`committed`, `merged`} **and** the next slice still needs a brief (recovery — interrupted session or sync without replan) | `/prep <slug> checkpoint` | recovery: plan the next slice (not the normal tail of row 10) |

"current iteration" = the `iterations[]` entry whose `number == currentIteration` (`n` is legacy-readable). The build-state rows
key on **git, not on a self-attested in-progress status** — the manifest has no `implementing` rung,
so a slice sits at `brief_ready` straight through its code commit until the checkpoint marks it
`committed`. Four git-sensitive points, all because the manifest alone is blind to the working tree
and the commit log: **row 5** is an **implement interstitial**, not a first-match dirty-prep row —
unsaved prep-tree docs divert rows 7–8 to docs-delta so a drafted checkpoint cannot skip straight
into implement. pending, cleanup, and other non-implement routes keep their own rows even when prep
docs are dirty. **row 10 precedence** still wins when implementation already landed on a
`brief_ready` slice (`/prep checkpoint` over docs-delta); **row 7's build-guard**
tells a brief that hasn't been built (no implementation change after the persisted `briefRevision`,
or after the latest committed change to the brief file when that field is missing → implement) from
one already built (→ fall through to the commit/checkpoint rows), so a committed-but-not-yet-
checkpointed slice is never sent back into implement; **row 8** greps the owned paths for an **open
finish** (`@finish:open`) and, finding one, routes back to authoring before commit — an unmade
decision is not committable — and is **mode-agnostic** (the marker fires it, not the mode: `default`
never leaves one open, and an interrupted `autopilot` resuming as `manual` is exactly this case);
**rows 9 vs 10** split "code written (uncommitted)" from "code committed" for the current slice —
reached **only after** rows 7–8 have peeled off the not-yet-built brief and the open-finish slice, so
a *clean* slice arriving at row 10 is necessarily past implement and `checkpoint` is the safe move
(row 10's predicate stays clean-and-built to keep the table total). Detect "built" from current
iteration `implementationPaths` when present, otherwise from non-planning initiative `ownedPaths`,
after the effective brief baseline: the recorded `briefRevision` when present, otherwise the latest
committed change to the current brief file. This lets architectural/doc-only slice artifacts under
`wiki/prep/<slug>/**` count as implementation only when the active iteration names them. Broad history
before that baseline is not enough to mark a `brief_ready` slice committed. If no persisted baseline
exists, checkpoint writes the brief-file revision, never `HEAD`; if no brief-file history exists,
checkpoint must not invent implementation. Row 5 scopes to `wiki/prep/<slug>/**` (+ `masterPlanPath`)
only — a dirty *owned code* file is rows 9/10's job. **Row 11** is recovery when a slice is already
`committed`/`merged` but the next brief was never drafted (interrupted session) — not the normal
successor to a **complete** row-10 close+replan (the table is **total**: every state matches exactly
one row).

## Resolver evaluation order

Row numbers are stable IDs for proof and tests. `tools/mep/lib/resolver.sh` uses **first match** in
this order (not numeric row order):

1. row 1 — graduated
2. row 3 — `phase < 5` when no current iteration record yet
3. row 4 — docs-bootstrap needed
4. row 10 precedence — `brief_ready`, post-brief implementation landed, owned code clean → `/prep checkpoint`
5. row 9 — dirty owned implementation → commit-prep
6. row 2 — cleanup / all terminal
7. row 6 — pending → `/prep checkpoint` (plan-only), even if prep docs are dirty
8. rows 7–8 — brief_ready not built / open finish → implement-plan, **or** row 5 docs-delta when those routes would fire and only prep docs are dirty
9. row 10 — landed fallback → `/prep checkpoint`
10. row 11 — committed current, recovery plan-only → `/prep checkpoint`

**Optional presentation interstitial (non-blocking):** when row 10 fires and no PR description
file exists for the current iteration under configured `storage.prDescriptionsRoot`, `where --json`
includes a single `optionalSteps[]` entry for `/prep-pr-description <slug> <n>`. `nextCommand`
remains `/prep <slug> checkpoint` — the presentation step is offered, not forced. After a body file
matching `<slug>-<nn>-*.md` exists, `optionalSteps` is empty. Batch review presentation still
belongs to `/mep stage`; this interstitial is the per-slice post-commit nudge.

**Review-stack aside (off the next-command path):** when committed slices are ready for review, the
operator may run `/mep stage <slug>` to route to `/prep-stage <slug>`. Staging is presentation work:
it verifies promised slices, previews branch/PR/body changes, and gates local or remote stack effects.

## Re-derivability (the durable navigation requirement)

This table is a **pure function of persisted state** — it uses no conversation memory. "Where were
we?" after any digression is answered by re-reading `manifest.json` + `git` and re-resolving. That
is exactly what `/mep where <slug>` does, and why the answer survives intervening
questions/answers/digressions.
