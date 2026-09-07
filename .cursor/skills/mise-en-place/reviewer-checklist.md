# Reviewer checklist

Governs the PR description `/prep-pr-description` renders for one PR in a multi-PR series, so a
reviewer who knows the codebase — but nothing about how the work was planned — can judge that PR
fast, without reading the rest of the series.

## What a good PR description lets a reviewer do (the reviewer-facing target — keep it plain)

- [ ] **Review this PR on its own** — you don't need the other PRs in the series open to judge it.
- [ ] **See what it adds** — the new behavior or structure is stated, not reverse-engineered from the diff.
- [ ] **See what it relies on** — existing code or already-merged PRs it builds on are named.
- [ ] **Place it in the series** — you know it's PR N of M and what it follows.
- [ ] **Trust the tests** — the change says how it's tested; tests exercise the behavior, not just "it exists".
- [ ] **Read it cold** — every term is plain English; nothing assumes how the work was planned.

If any box fails, the **description** is at fault, not the reviewer — fix the render.

## Internal mapping (for the generating agent — NOT part of any reviewer-facing output)

The reviewer-facing items above are the plain-language projection of the internal integrity checks.
These names are framework-internal — they must never appear in a rendered description:

| reviewer-facing item | internal check |
|----------------------|----------------|
| "See what it adds" / "See what it relies on" | `situated` |
| "Place it in the series" | `mapped` |
| "Review this PR on its own" | the merge-early property |

Defined in `slice-integrity-check.md`; this file is their **human** rendering.
