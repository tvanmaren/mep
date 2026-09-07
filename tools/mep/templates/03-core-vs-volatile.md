# Core vs interchangeable — {{SLUG}}

<!-- Filename stays `03-core-vs-volatile.md` for path stability. "Volatile" is deprecated in
prose — use **interchangeable** (see Guidance below). -->

**Phase:** 3  
**Status:** draft | approved  
**Role:** initiative **belief state** — living model amended every checkpoint, not a one-time plan doc.  
**Builds on:** [02-uncertainty-map.md](./02-uncertainty-map.md)

## Guidance — core certainties vs interchangeable elements

This document classifies **architectural identity**, not churn rate.

| wrong question | right question |
|----------------|----------------|
| *Will this change soon?* | *Could system identity survive substituting this?* |
| *Is this stable in git history?* | *Is this essential, or one realization of an essential category?* |

**Core certainty** — removing or swapping it falsifies the architecture. Needs a **falsification**
criterion. Promoted at checkpoint when slices prove the category, not merely the instance.

**Interchangeable element** — another implementation could occupy this slot without changing what
the system *is*. Includes: first-instance kinds, specific UX, vendors, smoke scripts, tactical
vocabulary. **Interchangeable ≠ plugin** — deeply embedded code can still be interchangeable;
a clean interface does not make something core.

**Defer ≠ ignore (phase 4 will sequence this).** Listing a row as interchangeable means it is
**not identity** — not that it is out of scope. Phase 4 puts C\* in an early **core-lock** band and
I\* in later **hydration** slices (layered by concern; skeleton-only during core). If an I\* row
has no planned home, that is a phase-4 defect, not a successful deferral.

### Generative dialectic (attack from either end)

**From a concrete thing (code, kind, vendor):**

> Could another realization occupy this position?

Yes → interchangeable. No → ask *why* — you may have found core, or accidental coupling to core.

**From a claimed invariant:**

> Is this actually essential to identity?

Yes → core (with falsification). No → interchangeable — you may have overfit a instance to identity.

**Pair with slice briefs:** brief **category vs instance** asks *what abstraction did this reveal?*
Checkpoint **core vs interchangeable** asks *what belongs to identity vs this path through design
space?* Same meta-question; opposite directions.

### Compression rules

- **~10–20 core rows** with one-line falsification each. Readable in ~10 minutes.
- **Interchangeable** holds instances, UX polish, first-of-kind handlers — not proof.
- **Amendments** carry story (evidence, replaces); rewrite tables clean on promote/falsify.
- **No changes** at checkpoint is valid: *iter N confirmed C6* — epistemic maintenance, not failure.

## Stable core

| # | core item | layer | falsification |
|---|-----------|-------|---------------|
| | | goal / domain / contract / persistence | |

## Interchangeable surface

<!-- Realizations, instances, UX, tactics — not identity. "Why interchangeable" not "why volatile". -->

| # | interchangeable item | why interchangeable | sunset (when it earns a core row) |
|---|----------------------|---------------------|-----------------------------------|
| | | | |

## Reversible vs irreversible decisions

| Decision | Reversible? | Notes |
|----------|-------------|-------|
| | two-way / one-way | |

## Risk / confidence notes

| Area | confidence | falsification |
|------|------------|---------------|
| | low/med/high | |

## Layer map

| Layer | Core certainties | Interchangeable |
|-------|------------------|-----------------|
| Experience | | |
| Domain | | |
| Contract | | |
| Persistence | | |
| Integration | | |

## Amendments (checkpoint-maintained)

<!-- Updated every `/prep checkpoint` after a landed slice. Rewrite stable core / interchangeable
tables clean when promoting or falsifying; log lineage here. -->

| iter | change | kind | evidence | replaces |
|------|--------|------|----------|----------|
| | promoted / newly interchangeable / falsified / demoted / confirmed | category \| instance | slice architectural diff, commit | prior belief or row removed |

**Kinds:** **promoted** → core row · **newly interchangeable** → instance/UX row · **falsified** →
remove from core (record what disproved it) · **confirmed** → no table change · **demoted** → core →
interchangeable when overfit corrected.
