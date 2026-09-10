# Tidy handoff — {{SLUG}}

**Tidy phase:** 5  
**Status:** approved  
**Board cleared:** yes

## What tidy produced

| artifact | purpose |
|----------|---------|
| `00-reckoning.md` | how we got here |
| `03-core-vs-volatile.md` | code-truth sift |
| `01`–`05`, `iterations/*` | same-resolution backfill |
| `07-commit-plan.md` | human **code-only** commit sequence |

## Docs bootstrap (before code groups)

- [ ] AskQuestion: approve recovered prep tree?
- [ ] Set roadmap `mepPrepDocsBootstrapped: true` (before committing, so the bootstrap commit captures its own state)
- [ ] `/commit-prep {{SLUG}} docs-bootstrap` → human `git commit`

Prep docs ship **once** in docs-bootstrap (prep tree + master plan when set) — not in code groups.

## Retroactive slices (implicit-merged)

| # | brief | status |
|---|-------|--------|
| 1 | `iterations/01-….md` | implicit-merged |

## Commit plan status (code only)

- [ ] Human executed `07-commit-plan.md` via `/commit-prep` per group (or waived — explain)
- [ ] Working tree matches post-commit intent

## Forward path

### Work remains

```
/prep {{SLUG}} checkpoint
```

Prep drafts **next** forward `iterations/N.md` only. Checkpoint uses `docs-delta` when prep files change.

### Initiative complete

```
/prep-cleanup {{SLUG}}
/pr-description
```

## state updates

- This artifact records `boardCleared: true`.
- This artifact records `tidyCompletedAt: {{ISO}}`.
- Roadmap frontmatter sets `mepPrepDocsBootstrapped: true`.
- `sessionMode: tidy` was invocation-scoped; prep resumes with `checkpoint` without persisting it.
