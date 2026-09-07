# Commit plan — {{SLUG}}

**Tidy phase:** 4
**Status:** draft | approved
**Human executes** — tidy does not run git.

Merge philosophy: **one epistemic transition per commit/PR** where possible.

**Commit messages:** each group's **Suggested commit message** is a one-line seed only
(`type(scope): summary gitmoji`). `/commit-prep` generates the actual `-m` via commit-msg
from staged diff + epistemic title — never paste multi-line prose into `git commit`.
Long context → the appropriate PR-description command after commit (`/prep-pr-description` for reconstructed slice groups; `/pr-description` for non-slice groups).

**Prep docs:** `.mep/prep/{{SLUG}}/` and `.mep/plans/{{SLUG}}.md` (when part of this
initiative) ship via `/commit-prep {{SLUG}} docs-bootstrap` after tidy phase 5 —
**not** in code groups below.

---

## Group 1 — {{EPISTEMIC_TITLE}}

**What becomes more certain:**

**Suggested commit message** (one-line seed for commit-msg — not a commit body):

```
feat(refinery): {{epistemic one-liner}} ✨
```

**Epistemic notes** (optional — for PR description, not `git commit -m`):

```
<!-- bullets, refs, reviewer caveats — PR-description context only -->
```

**Files / paths:**

- {{PATH}}

**Uncommitted portion:**

- [ ] `/commit-prep {{SLUG}} group 1` — gated audit rounds (cleanup unstaged per round until approved)

**Commit-prep scope:** paths above only. **Exclude** prep docs scope (`.mep/prep/`, initiative plan doc).

**After commit-prep (index staged when audit clean):**

- [ ] Review any rejected rounds or partial state if loop stopped early
- [ ] `git commit -m "…"` (use `/commit-prep`'s suggested message)
- [ ] `/prep-pr-description {{SLUG}} NN` when this group maps to `iterations/NN-….md`; otherwise `/pr-description` for this group
- [ ] optional: `/staged-audit` human spot check before commit

---

## Group 2 — {{EPISTEMIC_TITLE}}

<!-- Copy block per commit/PR unit -->

---

## Order

```
group 1 → group 2 → …
```

## Leave unstaged (next prep slice)

<!-- Explicitly NOT in this commit batch -->

- {{DEFERRED_ITEM}}

## Terminal: initiative complete?

If all work is on branch and nothing remains:

- [ ] Single graduation commit optional
- [ ] `/prep-cleanup {{SLUG}}` → `/pr-description`
- [ ] Skip `/prep checkpoint`

## Notes

<!-- amend vs new commits; branch push strategy -->
