---
description: "generate a plain-language, reviewer-facing PR description for a single prep slice (brief + manifest sourced)"
alwaysApply: false
---

# prep-pr-description - reviewer-facing slice summary

cursor command adapter for the portable PR-rendering contract in
[`portable-routing.md`](../skills/mise-en-place/portable-routing.md). keep the reusable behavior
there; this file is the slash-command shell.

Normal review preparation should start from `/mep stage <slug>`. This command is the lower-level semantic PR-body contract and escape hatch used by stage when a reviewer-facing body is missing or
needs repair.

## objective

render a PR description for **one prep slice**, for a developer who knows the codebase but **not**
the prep framework. the output is a lossy, **framework-free** projection of the slice's internal
artifacts — the reviewer never sees framework vocabulary.

## inputs

1. **slice brief** — `wiki/prep/<slug>/iterations/<n>-*.md` (user passes the slug or brief path).
2. **manifest** — `wiki/prep/<slug>/manifest.json` for series position, merged dependencies, and dependency order.
3. **diff** — `git diff <base>...HEAD --stat` and `git diff <base>...HEAD`, using the branch's actual base.

if no slice brief resolves, prompt: "no prep slice brief found. pass a slug/brief path, or use `/pr-description` for arch-doc work."

## the one rule

**framework-free output.** no "slice", "situated/mapped", "epistemic", "iteration brief", or
maturity tags in the reviewer-facing copy. extract the facts from the internal artifacts, then
**rewrite them in a reviewer's words**. validate the result against
`.cursor/skills/mise-en-place/reviewer-checklist.md`.

## process

### step 1: extract → translate

pull the raw facts from the internal artifacts, then translate each to plain developer language.
internal check names are sources only — they never appear in output.

| internal source | reviewer-facing section | plain content |
|-----------------|-------------------------|---------------|
| brief "what becomes more certain" + Stabilizes | **What this adds** | the behavior/structure this PR introduces |
| brief macro-constraints + already-merged dependencies | **What it relies on** | existing code / merged PRs it builds on |
| `manifest.iterations[]` position + merged deps + **what's pending after** | **Where it sits** | "PR N of M; builds on the merged PRs that [did X]; later PRs will [Y]" — cite `#refs` only when known |
| `integration-curation` `publication.mergePlaybook` + shard `stackRole` (when curated stack) | **Merge** | Pattern A/B playbook: parent vs trunk, when to fold, when to `gh stack sync` / `--prune` — required for stack-of-shards |
| brief testing section / test files in the diff | **How this is tested** | what the tests exercise, in plain terms — never just "tests added" |
| `git diff` | **Changes** | capability-grouped change list + file count |

### step 2: summarize the diff

run `git diff <base>...HEAD --stat` and inspect `git diff <base>...HEAD` only as much as needed
to summarize reviewer-visible behavior. use the branch's actual base (`develop`, `main`, or user
provided); do not assume `main` if the branch targets `develop`.

summarize changes by capability, not by file:

- good: "added a flag-gated deposit summary dialog to the SO cashflow"
- bad: "modified `SalesOrder.vue`, added `DepositSummaryDialog.vue`, added `depositSummary.js`"

include a total changed-file count. if the PR only includes part of a larger branch stack, summarize
the current PR diff/scope, not every prep artifact that exists on the branch.

### step 3: assemble

use this format:

```markdown
[one sentence: what this PR does, plain English]

## What this adds

- [behavior/structure this PR introduces]

## What it relies on

- [existing code / merged PRs it builds on — or "Nothing — standalone."]

## Where it sits

PR N of M in a series. Builds on the earlier merged PRs that [did X] (cite `#refs` when known).
Later PRs will [what's still coming], so this one is scoped to [its part].

## Merge

(Required when `wiki/prep/<slug>/merge-playbook.md` or `publication.mergePlaybook` exists.)

- **Stack role:** course-bottom | intermediate | course-tip
- **Base:** [parent branch or trunk]
- **After approval:** [merge into parent only / hold for course fold / land course-bottom → trunk]
- **Sync:** after fold → `gh stack sync`; after trunk landing → `gh stack sync --prune`
- **Do not:** solo-shard trunk merge; skip sync; merge tip to trunk first

## How this is tested

[what the tests exercise, plain — a reviewer should trust it without reading them]

## Changes

- [capability-grouped change 1]
- [capability-grouped change 2]

[N files changed]

**Details:** `wiki/prep/<slug>/iterations/<n>-*.md`
```

### step 4: write + apply

write the assembled PR description to:

`wiki/pr-descriptions/<slug>-<n>-<short>.md`

create `wiki/pr-descriptions/` if needed. do **not** output the full PR body inline in chat.
after writing, reply with:

1. the file path
2. a one-sentence summary of the PR description
3. suggested optional review step: `gh pr create --body-file wiki/pr-descriptions/<slug>-<n>-<short>.md`
4. local continuation: follow the PR Rendering section in
   `.cursor/skills/mise-en-place/portable-routing.md`.

PR creation is review presentation, not a blocker for continuing local MEP work. Do not re-encode
continuation policy here; keep it in `portable-routing.md`.

the bottom Details link is the **only** pointer to internal docs; the body stands alone for a
framework-naive dev.

## framework-free rule (re-check before write)

if any reviewer-facing line uses a framework term, rewrite it. a developer who has never seen this
framework must understand every word.
