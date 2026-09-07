# Iteration roadmap — {{SLUG}}

**Phase:** 4  
**Status:** draft | approved  
**Builds on:** [03-core-vs-volatile.md](./03-core-vs-volatile.md)

Merge philosophy: **merge uncertainty reduction, not production readiness.**

Size each iteration for a **reviewable merge** and a **checkpoint** — not a
monolith plan. Each iteration gets its own slice brief in `iterations/`.

---

## Sequencing doctrine (core before interchangeable)

**Defer ≠ ignore.** Early slices **lock core** (C\* identity). Late slices **hydrate
interchangeable** (I\* realizations). Core slices may ship a **skeleton** instance so the
category is exercisable — that is not I\* hydration.

| Band | Owns | I\* policy |
|------|------|-----------|
| **Core lock** (early) | every C\* row that is a slice decision (doctrine-only rows may stay initiative-level) | skeleton only — do not treat palette/chrome/column/field-name choices as finishes |
| **I\* hydration** (late) | I\* concern clusters, **one cluster per slice** | flesh instances after the core spine is checkpoint-vetted; evidence-gate optional polish |

**Anti-patterns (reject at phase-4 gate):**

1. **Parked core** — a C\* row only appears in a late “catch-up / audit” slice while early slices chase I\*.
2. **Catch-all hydration** — one dump iteration that hydrates unrelated I\* clusters (export + identity + adapter fidelity + …).
3. **Ignore-as-defer** — I\* rows with no planned skeleton *or* hydration home (and no explicit skip/sunset).
4. **Skeleton-as-decision** — locking an I\* instance (colors, column sets, panel placement) inside a core-lock slice.

**Required artifacts in this doc:**

- Band table (which iters are core lock vs hydration).
- **Coverage table** mapping every C\* / I\* id → iteration (or `initiative` / `skip-unless-gated`).
- Hydration slices **layered by concern**; optional fidelity/polish slices are **evidence-gated** (skip if skeletons suffice).

---

## Foundation strategy (keystone match)

<!-- Deliberate 2–3 shapes; record the pick. See SKILL.md Foundation strategy. -->

**Keystone:**

| Candidate | Fit | Tradeoff |
|-----------|-----|----------|
| | | |

**Pick:**

---

## Iteration 1 — {{TITLE}}

**Goal:**

**sliceType:** behavioral | architectural | consolidation | cleanup  
**epistemicTransition:**  
**irreversibleDecision:** (C\* id(s) — singular decision; split if unnamed)  
**maturityTarget:**  
**Delivery track:** frontend-only | full-stack  
**Fanout:** sequential | parallel  
**Brief:** `iterations/01-{{SHORT_TITLE}}.md` (draft at phase 5)

**Approach:**
- <!-- Core lock: name C\*. Skeleton I\* only if needed to exercise the category. -->

**Avoid:**
- <!-- I\* hydration, parked-core work belonging later, out-of-track productization -->

**Checkpoint:**

**File ownership (sketch):**
-

**Status:** pending

---

## Iteration 2 — {{TITLE}}

<!-- Copy block; increment brief filename. Separate core-lock iters from I\* hydration iters. -->

---

## Dependency order

```
<!-- core lock band → layered I* hydration band -->
iteration 1 → iteration 2 → …
```

Notes:
- <!-- e.g. 1–N = core lock; N+1… = hydration by concern; last = evidence-gated stub refinement -->

## Core / interchangeable coverage

| ID | Band | Iteration |
|----|------|-----------|
| C… | core lock | |
| I… | skeleton in … / hydration in … / skip-unless-gated | |

## Fanout eligibility

| Iterations | Parallel? | Reason |
|------------|-----------|--------|
| | no — file conflict on … | |

## Re-plan triggers

<!-- Return to phase 2 or 4 when… Include: evidence that opens a gated hydration slice; core gap found before hydration band. -->

## Consolidation trigger (optional master plan)

<!-- When to run /create-plan → wiki/plans/{{SLUG}}.md -->

- After core-lock band passes checkpoint AND backend handoff needed
- OR stakeholder request for single assessable document
