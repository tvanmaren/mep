# Handoff — {{SLUG}}

**Phase:** 5
**Status:** draft | approved
**Session mode:** greenfield | checkpoint | docs-only

## 1. Stable core (macro constraints)

| ID | Decision / invariant | Falsification |
|----|---------------------|---------------|
| | | |

## 2. Volatile surface (explicitly provisional)

| Area | Sunset criteria |
|------|-----------------|
| | |

## 3. Owned paths (for cleanup ripgrep)

```
<profile-owned path/glob>
<additional owned path/glob>
```

## 4. Iteration index

| # | Title | Type | Brief | Status |
|---|-------|------|-------|--------|
| 1 | | behavioral / architectural / … | `iterations/01-….md` | brief_ready |
| N | cleanup | cleanup | `iterations/N-cleanup.md` | pending |

## 5. Docs bootstrap (before implement)

- [ ] AskQuestion: approve prep tree?
- [ ] Delete `.cursor/prep-active`
- [ ] `/commit-prep {{SLUG}} docs-bootstrap` → human `git commit` (prep tree + `masterPlanPath` when set)
- [ ] Set roadmap frontmatter `mepPhase: 5` and `mepHandoffApproved: true`
- [ ] Set roadmap `mepPrepDocsBootstrapped: true`; set `mepMasterPlanPath` if plan exists

## 6. Next action — iteration 1 only

**Slice brief:** `wiki/prep/{{SLUG}}/iterations/01-{{SHORT_TITLE}}.md`

```
/implement-plan — this brief only. Add @ tags per epistemic markers.
After implement: /commit-prep (code) → git commit → /prep-pr-description {{SLUG}} 01
After checkpoint: /commit-prep docs-delta → git commit (if prep files changed)
```

## 7. Graduation (when every iteration is committed or merged)

```
/prep-cleanup {{SLUG}} → strip @ tags → 06-graduation.md
/commit-prep (code) + docs-delta → /pr-description — graduation PR
```

Final code: no `@` maturity tags; wiki retains history.

## 8. Master plan (deferred)

`wiki/plans/{{SUGGESTED_SLUG}}.md` — optional late consolidation.
