# Handoff — mep-authorship-modes

**Phase:** 5
**Status:** draft
**Session mode:** greenfield

## 1. Stable core (macro constraints)

| ID | Decision / invariant | Falsification |
|----|---------------------|---------------|
| C1 | Mode = execution policy over a shared, mode-invariant substrate | a mode needs its own planning artifacts |
| C2 | Governance×authorship space; code-monkey corner stays empty | a mode puts the operator in that corner |
| C3 | Path-2: human-default; AI absorbs only fragments it can ground in a named pattern | a useful mode routes by AI-detected uncertainty |
| C4 | Transcriptionist line is the frame's acceptance test | a frame ships a transcriptionist could complete unaided |
| C5 | A test asserts only what already exists | a mechanism-level assertion precedes the mechanism |
| C6 | Hardening is human-ratified | an unratified characterization assertion is committed |
| C7 | `default` stays behavior-compatible | naming the mode changes current behavior |

## 2. Volatile surface (explicitly provisional)

| Area | Sunset criteria |
|------|-----------------|
| marker spelling (`@hole`/`@human` vs maturity-tag extension) | grep + cleanup proven on a real slice |
| manifest field names + resolver row wording | resolver re-derivation checks out by hand |
| frame rendering | after I1/U3 anchoring trial |
| autopilot auto-approve mechanism | manual substrate proven first |

## 3. Owned paths (for cleanup ripgrep)

```
.cursor/skills/mise-en-place/**
.cursor/commands/mep.md
.cursor/commands/prep.md
.cursor/commands/prep-cleanup.md
.cursor/commands/implement-plan.md
hooks/**
```

## 4. Iteration index

| # | Title | Type | Brief | Status |
|---|-------|------|-------|--------|
| 1 | classification back-test (spike) | architectural | `iterations/01-classification-back-test.md` | committed |
| 2 | anti-line-fighting boundary (mechanism; polarity → I3) | architectural | `iterations/02-anti-fighting-fence.md` | committed |
| 3 | shared-substrate contract | architectural | (draft at checkpoint) | pending |
| 4 | amend prime directive (AD1) | architectural | (draft at checkpoint) | pending |
| 5 | manual execution policy | architectural | (draft at checkpoint; likely splits) | pending |
| 6 | autopilot execution policy | architectural | (draft at checkpoint) | pending |
| 7 | mode-switch UX + resolver rows | architectural | (draft at checkpoint) | pending |
| 8 | graduation cleanup | cleanup | (draft at checkpoint) | pending |

**Parallel batch:** I1 + I2 (disjoint files, operator-approved). Dispatch together via `/execute-plan`
or implement each via scoped `/implement-plan`.

## 5. Docs bootstrap (before implement)

- [ ] AskQuestion: approve prep tree?
- [ ] Set `manifest.prepDocsBootstrapped: true`
- [ ] Delete `.cursor/prep-active`
- [ ] `/commit-prep mep-authorship-modes docs-bootstrap` → human `git commit`

## 6. Next action — parallel batch (I1 + I2)

```
/execute-plan over the I1+I2 batch  (disjoint files → true parallel)
  — or —
/implement-plan iterations/01-classification-back-test.md   (this brief only)
/implement-plan iterations/02-anti-fighting-fence.md         (this brief only)
After each: /commit-prep (code) → git commit → /prep-pr-description mep-authorship-modes <n>
After batch: /prep mep-authorship-modes checkpoint → draft iteration 3 (substrate)
```

## 7. Graduation (when every iteration is committed or merged)

```
/prep-cleanup mep-authorship-modes → strip @ tags + assert zero unfilled holes → 06-graduation.md
/commit-prep (code) + docs-delta → /pr-description — graduation PR
```

## 8. Master plan (deferred)

`.mep/plans/mep-authorship-modes.md` — optional, after I5 (manual) stabilizes.
