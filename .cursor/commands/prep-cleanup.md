---
description: >-
  final graduation pass — remove @ maturity tags and other in-code process
  artifacts from a completed prep initiative. leaves durable intent comments only.
alwaysApply: false
---
# prep-cleanup — epistemic graduation (final pass)

## objective

When an initiative is **done**, strip in-code process tracking (`@experimental`,
`@provisional`, etc.) so the merge-ready codebase is just good code. Planning
history stays in `wiki/prep/<slug>/` and optional `wiki/plans/`.

Read `.cursor/skills/mise-en-place/maturity-tags.md` for tag vocabulary and
cleanup rules.

## when to use

- All prep iterations merged; stakeholder signoff received
- Before the **final PR** of an initiative (or dedicated cleanup slice brief)
- User says "graduate", "cleanup tags", "prep cleanup", `/prep-cleanup`

## when not to use

- Mid-iteration exploration — tags should remain
- Single slice merge with more iterations pending

## inputs

1. **Prep slug** — `wiki/prep/<slug>/04-iteration-roadmap.md`
2. **mepOwnedPaths** — from roadmap frontmatter (glob list for ripgrep scope)
3. **Slice brief** (optional) — `iterations/N-cleanup.md` if cleanup was planned

Set roadmap frontmatter `mepInitiativeStatus: graduating` at start.

## process

### step 1 — inventory

```bash
rg '@(experimental|provisional|stable|foundational|reference-only|maturity:)' \
  -g '*.js' -g '*.vue' [mepOwnedPaths…]
rg 'PROVISIONAL:|TODO\\(stabilize-' -g '*.js' -g '*.vue' [mepOwnedPaths…]
```

Report hit count and locations. **AskQuestion:** proceed with cleanup?

### step 2 — transform

For each hit:

| was | action |
|-----|--------|
| `@experimental` / `@provisional` | remove line; fold non-obvious intent into durable comment if needed |
| `@stable` / `@foundational` | remove tag; keep underlying invariant explanation in plain prose |
| `@reference-only` | remove tag; keep "never read by compute" as business comment if true permanently |
| `PROVISIONAL:` / `TODO(stabilize-…)` | remove or resolve |

**Do not** remove comments that explain permanent business rules unrelated to
the dev cycle (e.g. USD compute invariant on fee fields).

### step 3 — verify & commit code

Re-run ripgrep — **zero** maturity-tag matches in `mepOwnedPaths`.

Run tests for touched areas.

`/commit-prep <slug>` — code scope (`mepOwnedPaths` cleanup diff) → human commits.

### step 4 — document & commit docs

Write `wiki/prep/<slug>/06-graduation.md`:

- tags removed (count + files)
- durable comments kept (with rationale)
- final epistemic state: all subsystems → shipped

Set roadmap frontmatter `mepInitiativeStatus: graduated`.

Then — now that the graduation doc + roadmap update exist — ship the docs commit:
`/commit-prep <slug> docs-delta` — includes `06-graduation.md` + roadmap → human commits; then `/pr-description`.

### step 5 — pr description

Recommend `/pr-description` with `--graduation` context (see pr-description command).

## hard rules

- No new features in cleanup pass
- No behavior changes — tag removal and comment hygiene only
- If cleanup reveals unresolved `@provisional` semantics, **stop** and `/prep checkpoint`

## deliverable

1. Clean diff (no `@` maturity tags in owned paths)
2. `wiki/prep/<slug>/06-graduation.md`
3. Suggested: `/pr-description` → final PR
