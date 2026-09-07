# Code Integrity Check

**What this is:** the `/commit-prep` check that keeps MEP process archaeology out of code paths a
slice is trying to ship.

Product code should read as destination state. It may contain durable intent comments and the
temporary maturity markers from `maturity-tags.md`; it should not contain the agent's planning trail.

## Allowed

- Durable comments that explain a business rule, invariant, workaround, or integration contract.
- Temporary maturity tags: `@experimental`, `@provisional`, `@stable`, `@foundational`, and
  `@reference-only`.
- Ticket keys, migration names, endpoint names, and domain identifiers when they are part of the
  shipped system's vocabulary.

## Forbidden

- Slice-plan residue: numbered iteration shorthand, uncertainty-code shorthand, decision-path labels,
  and similar planning tokens.
- Narrative edit history: "changed from X", "temporary until later slice", "will be replaced in the
  next iteration", or "from the plan".
- Rejected-path notes that belong in prep docs, not code.
- Comments whose only purpose is to tell a reviewer how the agent arrived here.

## Mechanical Check

Reuse `.cursor/hooks/scaffolding-free-check.sh`; do not create a second regex vocabulary.

```bash
.cursor/hooks/scaffolding-free-check.sh --product-code <slice-owned product paths>
```

`--product-code` uses the same precise pattern set as the blocking framework-spine gate. It catches
low-false-positive shorthand and exits non-zero on hits. The AI audit tier may run `--broad` on the
same paths for recall, but broad findings are judgment calls: waive false positives, fix real leaks.

## Judgment Check

Regex catches shape, not intent. During `/commit-prep`, the parent audit and staged-audit scout also
read nearby comments and flag archaeology that has no mechanical marker:

- future-slice promises
- implementation diary prose
- plan labels rewritten in ordinary English
- comments explaining agent uncertainty instead of durable code intent

Findings are scoped to the staged slice-owned paths. Do not search the whole repo.

## Relationship to slice integrity

`slice-integrity-check.md` asks whether the diff delivered the brief. This file asks whether shipped
code still carries the planning trail. The checks are siblings: run both when `/commit-prep` is
working from a slice brief.
