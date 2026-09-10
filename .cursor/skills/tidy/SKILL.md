---
name: tidy
description: >-
  Mid-flight branch recovery — reckon WIP against reality, sift core from
  volatile, backfill prep artifacts, and produce a commit plan. Hands off to
  /prep checkpoint. Recovery path when prep discipline was skipped; unnecessary
  if /prep loop was followed. Docs only; no code commits.
disable-model-invocation: true
---

# Tidy (`/tidy`)

**Recovery path, not the happy path.** If you `/prep` → implement → merge →
`/prep checkpoint` each slice, you never need `/tidy`.

Use when a branch outran its docs: uncommitted chaos, missing prep artifacts,
diverged plan, or pre-process WIP. **Tidy clears the board; prep continues.**

Framework pairing: **tidy → prep** (same `.mep/prep/<slug>/` tree). Tidy writes the same
document-native state as prep; it does not create or maintain `manifest.json`.

## Pipeline

```
messy branch
  → /tidy (backward: reckon → sift → set → commit plan)
  → /prep checkpoint (forward: next slice brief)
  → /implement-plan → merge → …
  → /prep-cleanup
```

Happy path (no tidy):

```
/prep → implement → merge → /prep checkpoint → … → /prep-cleanup
```

Docs and gates only — **no application code**, **no autonomous commits**.
Human executes `07-commit-plan.md`. Readonly scouts for recon.

Shares templates with mise-en-place:
`.cursor/skills/mise-en-place/templates/` + [templates/](templates/)

## Hard rules

1. **Never** `git commit`, `git push`, `gh pr create`, or `gh pr merge`.
2. **Never** write application code.
3. **Never** advance a tidy phase without **AskQuestion** gate approval.
4. **Never** draft the *next forward* slice brief — that is `/prep checkpoint`.
5. Retroactive slice briefs use `mepStatus: committed | merged` only when git proves that state;
   their bodies say reconstruction occurred and gates were not rerun.
6. **Do not** create `.cursor/prep-active` — tidy clears toward commits, not away from them.
7. One initiative per slug; mixed branches → stop and AskQuestion.

## When to use / skip

| Use `/tidy` | Skip (use `/prep checkpoint`) |
|-------------|-------------------------------|
| No `.mep/prep/<slug>/` or stale vs branch | Prep artifacts match git state |
| Large uncommitted + committed mix | Clean slice just merged |
| `.mep/plans/*.md` but no prep tree | Checkpoint only needs next brief |
| "Account for how we got here" | Clean prep artifacts + fresh merge |
| | Greenfield → `/prep` |
| | Initiative done, only tags → `/prep-cleanup` |

## Bootstrap

1. Derive `slug` from branch, plan, ticket, or user input.
2. Git context (required):
   - `git branch --show-current`
   - `git log --oneline -20`
   - `git diff --stat` (uncommitted)
   - `git diff main...HEAD --stat` (or user base branch)
   - Optional: `rg '@(experimental|provisional|stable|foundational|reference-only)'` on diff paths
3. Seed from `.mep/plans/<slug>.md`, existing `.mep/prep/<slug>/`, JIRA if keyed.
4. Create/update `.mep/prep/<slug>/` and `iterations/`. Create
   `04-iteration-roadmap.md` from the shared roadmap template when absent, and write initiative
   frontmatter directly: `mepAuthorshipMode`, `mepInitiativeStatus`, `mepOwnedPaths`,
   `mepMasterPlanPath`, and `mepCurrentIteration`.
5. Treat `sessionMode: tidy` as invocation-scoped. Record tidy phase/progress in tidy artifacts
   (`00-reckoning.md` through `08-tidy-handoff.md`), never in roadmap or brief workflow state.

Do not extend or synthesize a manifest. A legacy `manifest.json` may be read only as migration input;
new recovery state is document-native.

## Five phases + gates

| Phase | Name | Primary artifact | Gate |
|-------|------|------------------|------|
| 1 | reckon | `00-reckoning.md` | Branch state accounted for? |
| 2 | sift | `03-core-vs-volatile.md` | Core/volatile from **code truth**? |
| 3 | set | backfill `01`–`05`, retro `iterations/*` | Same-resolution as if prep'd from start? |
| 4 | commit plan | `07-commit-plan.md` | Commit sequence approved? |
| 5 | handoff | `08-tidy-handoff.md` | Board clear → `/prep checkpoint`? |

### Phase 1 — reckon

Account for how we got here — not how we wish we had:

- Branch, base, committed vs uncommitted split
- Implicit decisions visible in diff/commits
- Existing prep/plan alignment or drift
- `@` tags found; test status if cheap to note
- Open risks / mixed-initiative smell

Template: [templates/00-reckoning.md](templates/00-reckoning.md)

### Phase 2 — sift

From **code + reckon**, not intent alone:

- Update `03-core-vs-volatile.md` (falsification on each core item)
- Set roadmap frontmatter `mepOwnedPaths` for later `/prep-cleanup`
- Note what is still volatile vs accidentally hardened

Granular separation lives here — **sift** is a phase inside tidy, not the command.

Optional: backfill `01-invariant-goal.md`, `02-uncertainty-map.md` if missing or wrong.

### Phase 3 — set

Same-resolution vision — prep artifacts as if the process ran from the start:

- Backfill or correct `01`–`05`, `04-iteration-roadmap.md`
- Forensic slice briefs in `iterations/` for work **already on branch**:
  - frontmatter `mepStatus: committed | merged`, according to git evidence
  - frontmatter `mepBriefRevision` and `mepImplementationRevision` from the reconstructed git evidence
  - note in brief: *reconstructed at tidy; gates not rerun*
- Mark pending work in roadmap; set `mepCurrentIteration` only when a reconstructed current brief
  exists; do **not** write next forward brief

Reuse [slice-brief.md](../mise-en-place/templates/slice-brief.md) with retro header from
[templates/retro-slice-brief.md](templates/retro-slice-brief.md).

### Phase 4 — commit plan

Epistemic commit groups — **what became more certain per commit**, not file-type batches.

Template: [templates/07-commit-plan.md](templates/07-commit-plan.md)

Slice-level groups (paths + epistemic transition + **one-line** message seed).
Human runs git; tidy advises only. Multi-line notes in commit plan are for
`/prep-pr-description` when a group maps to a retro slice brief (or `/pr-description`
for non-slice groups) — not literal commit bodies.

Each group includes a **commit-prep block** (paths, epistemic seed, optional
`iterations/NN` cite). Human or agent runs `/commit-prep` per group — gated audit
rounds, staged handoff + message. Tidy does not execute commit-prep itself.

**Prep docs are not in code groups.** Ship prep docs scope via
`/commit-prep <slug> docs-bootstrap` after phase 5, before group 1.
Includes `.mep/prep/<slug>/` and roadmap `mepMasterPlanPath` when set.

Terminal case: if branch is **fully complete**, commit plan may be "one graduation
group" → `/prep-cleanup` → `/pr-description`; skip prep checkpoint in handoff.

### Phase 5 — handoff

Write [templates/08-tidy-handoff.md](templates/08-tidy-handoff.md). Record `boardCleared: true` and
the tidy completion time in that handoff artifact. These are tidy-only process facts, not roadmap
frontmatter or iteration state.

**Commit sequence after phase 5 approval:**

```
1. /commit-prep <slug> docs-bootstrap → human git commit
2. /commit-prep <slug> group 1..N (code only, per 07-commit-plan.md)
3. /prep <slug> checkpoint   (if work remains)
   OR /prep-cleanup + /pr-description   (if initiative complete)
```

Prep checkpoint seeds from tidy output; prep drafts **next** forward `iterations/N.md` only.

## Post–phase 5 — commit execution

Tidy phases 1–5 never run git. A separate `/commit-prep` invocation (run by human
or agent) handles docs-bootstrap; a human commits — then the code groups from
`07-commit-plan.md`.

## Reply format

After each phase: artifact path, summary, gate question.

After phase 5: docs-bootstrap → code groups → `/prep checkpoint` or `/prep-cleanup`.

## Relationship to other commands

| Command | Role |
|---------|------|
| `/tidy` (this) | Backward recovery on messy branch |
| `/prep` | Forward; checkpoint after tidy |
| `/implement-plan` | One prep slice brief (not tidy output) |
| `/prep-cleanup` | Final `@` tag strip |
| `/prep-pr-description` | Reviewer-facing PR for a reconstructed or forward prep slice |
| `/pr-description` | Architecture/master-plan, non-slice commit-plan group, or graduation PR |
| `/commit-prep` | Per commit-plan group: gated audit rounds → staged handoff + message |
| `/staged-audit` | Human-in-loop spot check (optional after commit-prep) |

## Split-to-PRs

If commit plan implies multiple PRs, user may run split-to-prs skill after tidy.
Tidy produces the epistemic grouping; split tooling executes mechanically.

## Examples

- Recovery target: `.mep/plans/upstream-contract-advanced-extensions.md`
- Forward skill: [../mise-en-place/SKILL.md](../mise-en-place/SKILL.md) (`/prep`)
- `@` tags: [../mise-en-place/maturity-tags.md](../mise-en-place/maturity-tags.md)
