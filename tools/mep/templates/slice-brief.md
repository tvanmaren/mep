---
mepIteration: {{N}}
mepTitle: {{TITLE}}
# status: draft | pending | brief_ready | committed | merged | skipped
mepStatus: draft
# slice type: behavioral | architectural | consolidation | cleanup
mepSliceType: behavioral
# delivery track: frontend-only | full-stack
mepDeliveryTrack: full-stack
# fanout: sequential | parallel
mepFanout: sequential
mepBriefRevision: null
mepImplementationRevision: null
mepCheckpointRevision: null
mepImplementationPaths: []
---

# Iteration {{N}} — {{TITLE}}

**Prep slug:** {{SLUG}}
**Mode:** exploration | hardening

## Epistemic transition

<!-- PR title seed: what became MORE CERTAIN if this merges? Not "what feature." -->

**What became more certain:**

**Irreversible decision (one):** <!-- singular; if you can't name one, slice is too big -->

**Maturity target:** `experimental → provisional` | `provisional → stable` | `stable → foundational` | `n/a (cleanup)`

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | |
| **May know** | |
| **Must not know** | |
| **Invariants** | |
| **Still provisional** | |

## Epistemic markers (`@` tags)

<!-- Required additions/removals this slice. See maturity-tags.md -->

| location | tag | action |
|----------|-----|--------|
| `path/to/file` | `@provisional` | add / remove / keep |

Exploration/architectural slices: **add** tags on new boundaries.
Cleanup slice: **remove all** initiative tags in ownedPaths.

## Stabilizes

## Macro constraints (read-only)

From `wiki/prep/{{SLUG}}/03-core-vs-volatile.md`:

-

## Acceptance criteria (this iteration ONLY)

- [ ]

## Finish-map (fragment classification)

Classify every fragment on two **orthogonal** axes. This map is **mode-invariant**: manual, default,
and autopilot read the *same* table and differ only in *who* acts and *what state* a finish reaches —
never in *which* fragments are finishes (the seam that makes interrupting one mode for another
seamless).

**Decision-ness — `mechanical | finish`:**

- `mechanical` — the sous (AI) may absorb it. Requires a **cited** house-pattern/precedent that
  dictates *the choice*, not merely the mechanism. **Absent a citation it fails open to `finish`**
  (classify at decision granularity: a known mechanism clothing an undictated tradeoff is a `finish`).
- `finish` — a decision the chef (human) owns; carries a **frame** + a **state**.

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| | `mechanical` / `finish` | |

**Frame — one per `finish` (must pass the transcriptionist test: guidance alone cannot author it):**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| | | | | `open` / `done` / `ratified` |

**In-code markers (two orthogonal axes; both stripped at graduation — see
[maturity-tags.md](../maturity-tags.md)):**

- `@mise` — the sous's own generated code; **unmarked = the chef's, no-touch.** The chef claims any
  region by *deleting* its `@mise` (subtractive — no convention to write code the ordinary way).
- `@finish:<state>` — a decision fragment, `open → done → ratified`; the mode-invariant trail.

> *Who* moves a finish's state, and *what gate* applies, is **execution policy** (set per authorship
> mode) — not specified in this map.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| | modify / new | experience / facade / domain / integration | |

**Conflicts:** none → fanout eligible | list → must stay sequential

## RED-phase gates (before GREEN)

- [ ]

## Approach

-

## Avoid (out of scope this iteration)

-

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| behavioral | UX, workflow, stakeholder reaction | refactor domain layer unless brief says so |
| architectural | invariants, boundaries, extraction | change user-visible behavior |
| consolidation | remove accidental complexity | add features |
| cleanup | zero `@` maturity tags in ownedPaths | any behavior change |

## Testing

- **Unit/spec:** active profile's unit/spec command, if defined
- **Smoke (if full-stack):** active profile's `smoke` path
- **Manual:**

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:

## Checkpoint

## After commit

- [ ] `/commit-prep {{SLUG}}` — **code** scope (this brief's file ownership)
- [ ] `git commit -m "…"` → `/prep-pr-description {{SLUG}} {{NN}}` — reviewer-facing slice PR
- [ ] `/prep {{SLUG}} checkpoint` → next brief OR `/prep-cleanup` if done
- [ ] `/commit-prep {{SLUG}} docs-delta` → `git commit` if checkpoint changed prep tree
- [ ] Optional: `/create-plan` consolidation

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Add required `@` tags per epistemic markers table.
> Do not read future iterations.
