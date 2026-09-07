# mise-en-place

Big features are uncertain. You learn as you ship. The usual failure mode is either
over-planning upfront or letting the branch sprawl into an unreviewable mess.

Mise-en-place is the middle path: **plan only what you need for the next mergeable slice**,
ship it, checkpoint what you learned, then plan the next slice. Repeat until done.

You stay the chef. The agent is the sous — prep work, mechanical code, staging — but **you
own the decisions that matter**. The framework keeps that line visible and reviewable.

## When to reach for it

Good fit: a new feature with unknown edges, work that wants several small PRs, or a branch
that needs deliberate pacing instead of one giant diff.

Already coding without prep notes? **`/tidy <slug>`** backfills the planning notes from what's
on the branch, then hands off to the normal forward loop. `/mep start` routes there when it
detects existing work — after you confirm it belongs to this effort.

Skip it: an obvious bug fix, a slice brief you already approved, or stable scope that just
needs an architecture doc.

## Getting started

Pick a short slug for the effort (e.g. `sample-payable-precision`).

```text
/mep start <slug>    # kick off — greenfield or recover a messy branch
/mep next <slug>     # do whatever comes next
/mep where <slug>    # same, but read-only — see the step without running it
/mep done <slug>     # wrap up when every slice has landed
/mep stage <slug>    # verify work and preview the review stack
```

That's the main operator surface (`mode` below). `/mep` reads `wiki/prep/<slug>/manifest.json`
and git, figures out where you are, and routes to the right slash command. You don't memorize
phases, slice statuses, or the pipeline.

Typical rhythm (happy path):

```text
plan a slice → build it → commit → checkpoint → plan the next slice → … → graduate
```

Already started coding? Catch up first:

```text
/tidy → checkpoint → build → commit → … → graduate
```

`/tidy` reads what's on the branch and writes the missing planning notes — no product code,
no autonomous commits. After that, you rejoin the forward loop at checkpoint.

## What you get

- **Right-sized PRs** — each slice is about one reviewable unit of work.
- **Explicit uncertainty** — core vs interchangeable belief state is written down and amended at checkpoints, not implied.
- **Checkpoints** — after each slice, replan from what actually shipped; **brief preflight** on the next plan before implement.
- **Scoped at two layers** — plan audit at checkpoint (`brief-preflight-check.md`); diff audit at commit (`slice-integrity-check.md`).
- **Human gates** — the agent stages and audits; you commit and graduate. In default (and
  manual), you also approve each slice before moving on; autopilot defers that to graduation.

Planning artifacts live under `wiki/prep/<slug>/`. The skill itself is docs and gates only;
product code goes through `/implement-plan`, scoped to one slice brief at a time.

## How hands-on do you want to be?

The plan stays the same across modes — switching only changes **who writes the tricky parts**
and **who signs off on each slice**. Meaning and invariants stay yours in every mode.

**Default** (no setup) — the agent builds each slice; you review and commit before moving on.
This is how the framework already works; `default` just names it.

**Manual** — you hand-write the parts that need a real judgment call; the agent handles the
mechanical rest. Good when the hard choices are yours and you want the agent to scaffold
around your decisions, not substitute for them.

**Autopilot** — the agent keeps running slice-to-slice; a cross-model proxy stands in as chef
for the decision-bearing parts (same lifecycle as manual, full audit trail). Faster throughput
— you still sign off at graduation, not ungoverned autonomy.

```text
/mep mode <slug> manual       # you author the decisions
/mep mode <slug> autopilot    # agent runs, proxy chef per slice
/mep mode <slug> default      # back to review-before-merge
```

## Go deeper

- [SKILL.md](SKILL.md) — full workflow, rules, authorship modes
- [execution-policies/](execution-policies/) — manual and autopilot in detail
- [profile-capabilities.md](profile-capabilities.md) — structured profile seed contract
- [`/tidy` skill](../tidy/SKILL.md) — catch up when you started coding before planning
- [glossary.md](glossary.md) — plain language + the "what's next" resolver
- [`/mep` command](../../commands/mep.md) — all six verbs (`stage`, `mode`, …)
