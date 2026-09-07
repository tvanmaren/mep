# Brief preflight check

**What this is:** the plan-level audit run at **`/prep checkpoint`**, after drafting the **next**
slice brief and **before** marking it `brief_ready` or routing to `/implement-plan`.

**What this is not:** clean/cleaner-code review on code that does not exist yet. Structural code
quality stays at **`/commit-prep`** via `slice-integrity-check.md` + `staged-audit` on the staged
diff.

**Unit:** one **draft brief** — its constitution, file ownership, category/instance, and approach —
judged for scoping and blast radius.

## When

End of checkpoint session, after belief-state amend and brief draft, before human approves
`brief_ready`.

## Landed-slice retrospective (start of checkpoint — optional input)

Before drafting the next brief, optionally ask of the **landed** slice:

- Was the commit **scoped** to what the brief promised? If not, feed gaps into the next brief's
  **Avoid** list or schedule a **consolidation** slice.
- **Seam smell test:** category closed or story-only? (see slice brief **Checkpoint** section.)

This is learning from what shipped — not a blocker on the new brief.

## Preflight checks (draft brief — run these)

Apply the **cleaner-code lens to the plan**, not the codebase:

| check | question | fails when |
|-------|----------|------------|
| **single purpose** | Does epistemic transition name one certainty move? | brief tries to do two unrelated things |
| **ownership minimal** | Is file ownership exhaustive *and* as small as honest? | unrelated zones / shotgun paths pre-authorized |
| **category before instance** | Is category certainty closed (or waived with reason)? | instance-only plan when a seam exists elsewhere |
| **one place to edit** | If this rule changes next slice, is there one obvious module? | blast radius spread across distant unrelated files |
| **no planned shotgun surgery** | Does **Avoid** explicitly exclude "while we're here" work? | approach/ownership smuggles drive-by refactors |
| **consolidation routing** | Did last slice land messy? Should this be consolidation/cleanup instead? | feature slice carries structural debt forward |

Reference: `.cursor/skills/mise-en-place/review-kernels/cleaner-code.md` (**One Change One Place**,
**Proportionality**) — applied to the **contract**, not implementation.

## Gate

- **Pass** → human approves brief → `brief_ready` → `/implement-plan`.
- **Fail** → revise brief (split slice, narrow ownership, add consolidation iteration, close category
  first). Do not implement until preflight passes.

Record pass in the brief's **Brief preflight** section (checkboxes + one-line note if waived).

## Sibling checks

| phase | artifact | check |
|-------|----------|-------|
| **checkpoint (plan)** | draft brief | **this file** — scoped plan, blast radius |
| **commit-prep (code)** | staged diff | `slice-integrity-check.md` — faithful, scoped, honestly-tested |
| **commit-prep (code)** | staged diff | `staged-audit` + clean/cleaner kernels — hygiene and structure |

Same vocabulary (**scoped**) at two layers: plan scoping prevents code scoping failures; code scoping
catches plan failures that slipped through.
