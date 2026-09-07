---
description: "synthesize integration curation plan from MEP discovery history; preview-first"
alwaysApply: false
---

# prep-curate — integration curation

Transform **discovery history** into the **smallest truthful review narrative** for reviewers —
then materialize **publication history** on disposable integration branches. The lab branch is never
rebased or mutated.

**Preview approves the communication strategy** (evidence, grouping, order, gating) — not the code.
Code already lives on the lab branch.

This is the mechanical command behind **`/mep curate`**. Outline: `wiki/plans/mep-curate-outline.md`

## The epistemic leap

**Iterations optimize discovery. Courses optimize comprehension.**

**Courses ≠ iterations.** Iteration briefs are **evidence** — witnesses, not commands.

> **Publication order follows comprehension + merge safety — not iteration numbers.**

## Publication stack

```text
Evidence (R / AD / D) → merge courses → review shards (attention budgets) → learning path → confidence report → publication commits
```

## Hard rules

1. **Default to `preview`.** No artifact write or git effects unless mode says so.
2. **Never** mutate the discovery branch.
3. **Narrative honesty.** Never invent dependencies or obscure why the system evolved.
4. **Distill evidence** (requirements, ADs, discoveries) before grouping merge courses.
5. **Review shards** are **attention budgets:** target ≤300 / max 500 product LOC — **stack-only**.
6. **Merge courses:** target ~2k / soft max ~3k — **sequential develop gates**.
7. Each merge course: **trunk state first**, **why now**, **why not merged with previous**.
8. **`execute`** writes **publication history** on integration branches (curated, not fabricated).
   Requires a clean tree **except** `wiki/prep/<slug>/integration-curation.{json,md}` and
   `wiki/prep/<slug>/merge-playbook.md` — uncommitted approved artifacts are allowed; any other
   dirty path blocks execute. Commit messages must satisfy repo hooks (e.g. gitmoji).
9. Write artifacts only after operator approves preview.
10. **Propose first** — questions only at confidence level 3 or product decisions (see skill).

## Interaction policy

**Maximize recommendations, minimize interrogations.** One interruption: *approve preview?*

Staff-engineer heuristic · confidence ladder (prose) · always-ask product decisions · authorship mode
interpretation — see skill.

## Optimize preset

`/mep curate <slug> --preview --optimize reviewer-comprehension|merge-speed|earliest-value`

Default: `reviewer-comprehension`. Persist as `manifest.curationOptimize` or artifact field on approve.
CLI passthrough post-v0.1; executor honors preset from invocation or manifest today.

## Optimize (default order)

1. Reviewer understanding · 2. Merge safety · 3. Narrative honesty · 4. Cohesion · 5. Min depth · 6. Discovery record · 7. LOC targets

## Modes

| mode | effects |
|------|---------|
| `preview` (default) | evidence + merge courses + shards + learning path + confidence report — read-only |
| `write` | writes artifact (`draft`) |
| `approve` | `approved` — unblocks execute |
| `execute` | integration branches + publication commits; records execute table |

## Synthesis steps (preview)

1. Merge + review budgets; resolve **`curationOptimize`** preset (see outline).
2. **Distill evidence** — requirements, ADs, discoveries (exploration only).
3. **Merge courses** from evidence + architecture ship order.
4. **Mergeability pass:** sequential order, gating/stubs, **course-tip** smokes, shared-file
   ledger, no leftover courses, `retrofitRequired`.
5. **Review shards** as attention budgets inside each course (`stacked-only`); may be progressive
   within the course — **not** required to be independently runnable.
6. Per course: trunk state, **why now**, **why not merged with previous** (both tips runnable),
   concern, cognition.
7. Dependency graph (concern tags); **reviewer learning path**; **confidence report**; **watch for:** per course.
8. Apply **interaction policy** — propose; level 2 alternatives if ambiguous; level 3 for product only.

## CLI (mechanics only — no LLM)

```bash
tools/mep/bin/mep curate <slug> --json --preview
tools/mep/bin/mep curate <slug> --json --measure
tools/mep/bin/mep curate <slug> --json --validate
tools/mep/bin/mep curate <slug> --json --execute --dry-run
tools/mep/bin/mep curate <slug> --json --execute --confirm
```

## Handoff

```text
/mep stage <slug> preview
/mep stage <slug> submit-draft
```

## Skill

`.cursor/skills/mise-en-place/curate/SKILL.md`
