---
name: staged-audit
description: >-
  Audit staged git changes against mep review kernels and the active profile.
  Use when the user says "audit staged", "review staged", or `/commit-prep`
  invokes this skill.
---

# Audit Staged Changes

Review staged changes against portable review surfaces. Read full files for context; scope
recommendations to the diff.

## Procedure

1. `git diff --cached --stat` and `git diff --cached`.
2. Read the full contents of every staged file.
3. Load applicable review surfaces:
   - `.cursor/skills/mise-en-place/review-kernels/clean-code.md` (code)
   - `.cursor/skills/mise-en-place/review-kernels/cleaner-code.md` (code)
   - active profile `capabilities.review.inputs` when `mep profile dump --json` names any
   - slice integrity: `.cursor/skills/mise-en-place/slice-integrity-check.md` when a brief path is in context
4. Report findings in two tiers.

## Reporting

### Actionable (fix before commit)

Issues in or adjacent to the diff. Group: **must-fix**, **should-fix**, **nit**.

### Deferred (log, don't fix now)

Pre-existing issues elsewhere in the file, unrelated to the diff.

## Output Format

```
**[severity]** `file/path:L42-L50` — [finding]. Fix: [suggestion].
```

No preamble. Group by file, then by tier.

## Modes

Default (bare `/staged-audit`) is **full tier + report-and-wait**.

### Tier

| Tier | Trigger | Checks |
|------|---------|--------|
| **full** | code paths staged | review kernels + profile inputs |
| **docs-only** | caller says `docs-only`; only `.mep/prep/**` or `.mep/plans/**` staged | structure + hygiene below |

**docs-only checks:**

- Valid markdown; no broken internal `.mep/prep/` or `.mep/plans/` cross-links
- `manifest.json` parses; slug matches directory; `masterPlanPath` valid when set
- No secrets / `.env`
- Epistemic claims in briefs match staged code intent when both land the same session
- Register (`lite`, not lossy)
- Typos / formatting are nits

### Framework-node hygiene

When staged paths include `.cursor/skills/**`, `.cursor/commands/**`, `.cursor/agents/**`
(not `.mep/prep/**`, which is process memory):

```bash
.cursor/hooks/scaffolding-free-check.sh --broad <staged spine paths>
```

Genuine offenders are **must-fix**. Lineage lives in `manifest.deviations` + briefs, never in the
evergreen node. `provenance:` / `@`-tag lines are the sanctioned exception.

### Disposition

| Disposition | Trigger | Behavior |
|-------------|---------|----------|
| **report-and-wait** | standalone `/staged-audit`; `staged-audit-scout` | emit findings, stop. Never edit, stage, or commit. |
| **findings-only** | `/commit-prep` | same findings, no human framing. Do not apply fixes. |
