---
description: "stage prepared MEP work into a reviewable PR stack; preview-first, gated local/remote effects"
alwaysApply: false
---

# prep-stage — review-stack preparation

`/prep-stage <slug> [mode]` prepares a MEP effort for review. It verifies that promised slice work is
ready to present, maps iterations to branches/PRs, and, only behind explicit gates, uses `gh stack`
to create or update the review stack.

This is the mechanical command behind `/mep stage`. `/mep stage <slug>` is the normal operator surface
for review presentation; use `/prep-stage` only as a lower-level escape hatch during implementation or
recovery.

## Hard rules

1. **Default to `preview`.** No writes, pushes, PR creation, or PR-body updates unless the mode says so.
2. **Never** run `git commit`, `git push`, `gh pr create`, `gh pr merge`, or `gh stack submit`
   without an explicit `AskQuestion` gate.
3. **Remote effects are always separate from local effects.** Creating/adopting branches is not the
   same as submitting PRs.
4. PR body generation is part of the `/mep stage` review-prep pipeline. `prep-stage` may require,
   verify, scaffold, or apply those files; `/prep-pr-description` remains the lower-level semantic body
   contract.
5. Validate promised work before arranging it: each staged slice must be complete, scoped, and free of
   quarantined work before it is presented as review-ready.

## Modes

| mode | effects | use when |
|------|---------|----------|
| `preview` (default) | read-only | inspect planned branches, PRs, body files, and side effects |
| `create-local` | local branches / `gh stack init` only | committed slices exist locally but no stack is initialized |
| `update-local` | local branch adoption/repair only | a partial local stack exists and needs reconciliation |
| `greenfield` | local branch skeleton only | planned slices exist before code/PRs |
| `submit-draft` | remote submit + PR body updates | local stack is ready; create/update draft PRs |
| `submit-open` | remote submit + PR body updates + open browser | same as draft, but open the created/updated stack |

Every mode except `preview` asks before acting. Every remote mode shows the exact PR/body/base updates
before running `gh stack submit` or `gh pr edit`.

## Inputs

- `wiki/prep/<slug>/manifest.json`
- `manifest.iterations[]`
- `wiki/prep/<slug>/iterations/<n>-*.md`
- generated `wiki/pr-descriptions/<slug>-<n>-<short>.md` files
- `wiki/prep/<slug>/integration-curation.md` + `.json` when present (preferred over 1:1 iteration map); use **Execute record** integration branches when `execute` completed
- `wiki/prep/<slug>/merge-playbook.md` or `publication.mergePlaybook` when present — **required input** for curated stack-of-shards PR bodies
- git branch, commit log, working tree, and existing `gh stack` / PR state

## Preflight

1. Verify `manifest.json` exists and parses.
2. Verify `gh stack` is installed before any non-preview mode.
3. Resolve trunk, defaulting to `develop` unless the user provides another base.
4. Verify working tree state:
   - preview may run with unrelated dirt, but reports it.
   - local/remote modes stop unless scoped changes are intentionally part of staging.
5. Read existing stack state via `gh stack view --json` when available, and PR state via `gh pr list`
   by branch naming convention when needed.
6. List selected iterations and their status:
   - `committed` / `merged` slices are candidates for review-stack presentation.
   - `brief_ready` / `pending` slices are only eligible for `greenfield` skeletons.

## Promised-slice check

For each slice being presented as review-ready:

| check | question |
|-------|----------|
| complete | does the diff/commit satisfy the slice brief's acceptance criteria? |
| scoped | does it stay inside the brief's file ownership and one named purpose? |
| quarantined-work leakage | did it pull in pending/future iteration work? |
| PR body | does a matching reviewer-facing body exist, or should stage generate a scaffold and request semantic prose? |
| merge playbook | if curation has `publication.mergePlaybook` / `merge-playbook.md`, does **every** stacked PR body include a **Merge** section (role, base, fold vs trunk, sync)? |

If any check fails, stop and route to `/prep <slug> checkpoint` or `/commit-prep <slug>` as
appropriate. Do not paper over drift by creating a larger stack.

### Curated stack-of-shards (when `integration-curation` exists)

Prefer merge courses + `reviewShardsPlan` over 1:1 iteration mapping. For each shard PR body:

1. Stamp **Merge** from `merge-playbook.md` / `publication.mergePlaybook` (Pattern A unless artifact says otherwise).
2. Include `stackRole` (`course-bottom` | `intermediate` | `course-tip`), parent/base, and sync commands.
3. Course-tip bodies also carry that course's `trunkStateAfterMerge` + `watchFor` (truth after the **course** lands on trunk — not after the tip fold alone).
4. Never instruct a solo shard → trunk merge except the post-fold `course-bottom` → trunk landing.

## Required states

### no PRs yet, committed MEP work exists

Use `preview` to map committed iterations to branch names, titles, PR body files, and `gh stack`
commands. Use `create-local` to create/adopt local branches and run `gh stack init`. Use
`submit-draft` only after preview and local stack state are approved.

### partial stack already exists

Produce a reconciliation table:

| item | show |
|------|------|
| matched branch/PR | existing PR and matching iteration |
| missing branch/PR | iteration that needs branch/PR creation |
| stale/missing body | PR body file to regenerate or reapply |
| base mismatch | base branch change `gh stack submit` would apply |

Prefer update-in-place. Do not overwrite PR bodies without showing the exact PRs and body files first.

### greenfield stack

Use `greenfield` when the team wants ordered branch placeholders before slice code exists. Initialize
the local stack from planned iterations, then print the next steps:

```text
checkout bottom branch
implement the next slice
/commit-prep <slug>
/mep stage <slug>
/prep <slug> checkpoint
```

Do not submit empty PRs by default.

## Output

`preview` prints:

- selected iterations and statuses
- promised-slice check result per review-ready slice
- planned branch names and base
- matching PR body files, missing body scaffolds, and semantic-prose gaps
- existing PR/branch reconciliation
- exact commands that would run in the selected mode

Non-preview modes print the same plan, ask for approval, run only the approved operations, then report:

- stack state after the operation
- PR URLs when remote submit ran
- PR bodies applied or skipped
- next human step
