---
name: commit-prep
description: >-
  Stage scoped paths (code, docs-bootstrap, or docs-delta), run gated audit-fix
  rounds, recommend commit message. Use after implement, prep/tidy handoff, or
  checkpoint. Does not commit.
disable-model-invocation: true
---

# Commit Prep (`/commit-prep`)

**Stage → audit → fix (unstaged) → approve → stage cleanup → next round** (≤3),
then **commit-msg** on the final staged index.

Orchestrates [staged-audit](../staged-audit/SKILL.md) (findings-only disposition), optional
**cross-model second opinion** via [staged-audit-scout](../../agents/staged-audit-scout.md),
and [commit-msg](../commit-msg/SKILL.md) (staged-only mode).

Audit fixes are applied autonomously, but each round's **cleanup stays unstaged**
until human approval — catches bad audit advice before it enters the index.

## Hard rules

1. **Never** `git commit`, `git push`, `gh pr create`, or `gh pr merge`.
2. Stage **only** paths in resolved scope — no opportunistic adds outside scope.
3. **Do not** ask whether unstaged files outside scope should be included.
4. Fix only **actionable** findings in scoped diff; log **deferred** (pre-existing outside diff).
5. Max **3** audit rounds; then stop with blockers — no commit message if must-fix remains.
6. After applying audit fixes in a round: **do not stage cleanup** until AskQuestion approval.
7. **Leave index staged** at handoff when audit is clean — scope + approved cleanups ready to commit.
8. **AskQuestion** gate **per round** when cleanup was applied — before staging for next round.
9. **Second opinion** (default on **code** scope): dispatch staged-audit-scout on an
   alternate model each audit round; parent triages with grain of salt — never blind-merge.

Skip second opinion when user says `single-audit` or docs-only scope with no code paths.

## Scope modes

Resolve mode from user message first, then fall through default priority.

| Mode | Trigger | Scope paths | Audit tier |
|------|---------|-------------|------------|
| **`docs-bootstrap`** | `docs-bootstrap`, tidy phase 5 handoff, prep phase 5 handoff | prep docs scope (below) | docs-only |
| **`docs-delta`** | `docs-delta`, after checkpoint / slice merge / plan update | changed prep docs scope paths since `HEAD` | docs-only |
| **code** (default) | `group N`, slice brief, explicit product paths | group / file-ownership table | full staged-audit |

### Prep docs scope

Always resolve from `.mep/prep/<slug>/manifest.json`:

1. `.mep/prep/<slug>/` — entire tree (bootstrap) or changed files (delta)
2. **Master plan** — `manifest.masterPlanPath` when set; else `.mep/plans/<slug>.md` if the file exists or was touched this initiative

Include the master plan in **every** docs-bootstrap and docs-delta when it belongs to this
initiative. Plan creation (`/create-plan`), updates (`/update-plan`, `/improve-plan`,
`/assess-plan` → `/update-plan`) are prep-side documentation — **never** code commits.

**Never** include `.mep/prep/` or `.mep/plans/` in code scope.

**Docs-only audit:** run staged-audit **docs-only tier** (its Modes section owns the
checklist — markdown structure, manifest parse, secrets, brief/code epistemic match).
Disposition is still findings-only; commit-prep applies typo/formatting fixes in step 4.

## Scope resolution (code — default priority)

| Priority | Source |
|----------|--------|
| 1 | User path list or `group N` |
| 2 | `.mep/prep/<slug>/07-commit-plan.md` — group **Files / paths** |
| 3 | `.mep/prep/<slug>/iterations/<n>-*.md` — file ownership table |
| 4 | `git diff --cached --name-only` if user says `staged only` |

**Never** include prep docs scope in code mode unless user explicitly overrides.

### Product-code archaeology gate

When code scope resolves from a slice brief (priority 3) or explicit product paths (priority 1), run
the product-code integrity check from
[code-integrity-check.md](../mise-en-place/code-integrity-check.md) on the scoped non-prep paths.

Use the shared detector; do not invent a second pattern set:

```bash
.cursor/hooks/scaffolding-free-check.sh --product-code <scoped product paths>
```

- Empty product path set → skip with `product-code archaeology: n/a`.
- Mechanical hits → **must-fix** unless clearly outside the staged diff.
- Judgment-tier archaeology (future-slice promises, implementation diary prose, plan labels rewritten
  in ordinary English) → **must-fix** when it lives in or adjacent to the staged code.
- Sanctioned maturity markers (`@experimental`, `@provisional`, `@stable`, `@foundational`,
  `@reference-only`) are allowed; they are stripped by `/prep-cleanup`, not this gate.
- Broad-mode false positives are waivable audit findings; precise/product-code hits should be rare
  enough to treat as blocking by default.

## Scope resolution (docs)

Resolve `PLAN_PATH` from `manifest.masterPlanPath` or `.mep/plans/<slug>.md`.

### docs-bootstrap

```bash
git add -- .mep/prep/<slug>/
# when PLAN_PATH exists or was created/updated this initiative:
git add -- <PLAN_PATH>
git diff --cached --stat
```

Use after:

- **Forward `/prep` phase 5** — initial tree before first implement
- **`/tidy` phase 5** — recovery backfill before code commit-plan groups

Epistemic seed (wording hint only — commit-prep compresses to one line via commit-msg):

- `docs(prep): bootstrap <slug> prep tree 📝` or tidy recovery variant

### docs-delta

```bash
# include <PLAN_PATH> only when manifest.masterPlanPath resolves; else prep tree only:
git diff --name-only HEAD -- .mep/prep/<slug>/ <PLAN_PATH>   # master plan set
git diff --name-only HEAD -- .mep/prep/<slug>/               # no master plan
# if empty → report "no prep/plan doc changes"; skip commit message
git add -- <changed paths>
```

Use after:

- **`/prep checkpoint`** — roadmap / brief / manifest updates
- **Slice merge** — architectural diff or iteration status in prep tree
- **`/create-plan`**, **`/update-plan`**, **`/improve-plan`** — plan doc changes for this initiative
- **`/prep-cleanup`** — include `06-graduation.md` when written

Epistemic seed: cite iteration index or checkpoint action from manifest.

Load epistemic seed when available (code modes — **hints only, not literal `-m` text**):

- Commit plan group → **What becomes more certain** (ignore multi-line message blocks in plan)
- Slice brief → **epistemicTransition**, **irreversibleDecision**

## Procedure

### 1. Resolve scope

Produce explicit path list. Stage scope if not already staged:

```bash
git add -- <paths>
git diff --cached --stat
```

Verify staged set matches scope — no extras, no missing owned paths from brief/group.

#### Review surfaces and lenses

For MEP-scoped code audits, load the active profile's review surfaces before invoking
staged-audit. For the default the host product profile, that means the review kernels and hydration
examples listed in [example-stub.md](../mise-en-place/profiles/example-stub.md). Pass those paths to
staged-audit-scout as parent-provided review surfaces when dispatching the second opinion.

Initial lens set:

| Lens | Applies when | Review surfaces |
|------|--------------|-----------------|
| `stack-conventions` | full tier and staged code touches stack-specific paths | active profile stack rules and repo code-review rules |
| `clean-code` | full tier and staged code exists | clean-code kernel plus profile examples |
| `cleaner-code` | full tier and staged code exists | cleaner-code kernel plus profile examples |

Docs-only tier skips code lenses. Its markdown structure, manifest, secrets, and register checks stay
inside staged-audit's docs-only pass.

### 2. Audit-fix rounds (≤3)

Each **round**:

1. **Primary audit** — staged content per staged-audit **findings-only disposition**
   (parent agent). Audit emits findings; it does **not** fix. Fixes are applied in step 4.
2. **Lens second opinions** (code scope, unless `single-audit`):
   - Build the applicable lens list from the table above. Empty list → record `lens-fanout: n/a`.
   - Dispatch one **staged-audit-scout** readonly task per applicable lens on the alternate model
     family (see table below). Do **not** build a lens × model matrix; the lens changes the prompt,
     not the model policy.
   - Prompt each scout with: current `git diff --cached`; tier full; one lens assignment; review
     surfaces for that lens; report only.
   - Use `Task` with `readonly: true` and explicit `model`. Prefer `subagent_type:
     staged-audit-scout` when available; else `generalPurpose` with scout prompt + skill path.
   - **Slice integrity dimension** (when scope resolved from a slice brief — priority 3): also
     pass the **brief path** to the scout as the *contract*, and instruct the **core** checks from
     [slice-integrity-check.md](../mise-en-place/slice-integrity-check.md) — `faithful` /
     `scoped` / `honestly-tested` (does the diff deliver the brief's claimed file-ownership +
     acceptance criteria, with one nameable purpose, and tests that exercise the claimed
     behavior?). Also instruct the product-code archaeology check from
     [code-integrity-check.md](../mise-en-place/code-integrity-check.md) for scoped product paths.
     Hygiene (`clean`, presence, secrets) stays the scout's normal staged-audit pass — **not**
     re-graded here. Catches the drift a diff-in-isolation audit can't: a silently omitted
     acceptance criterion or process archaeology leaking into code.
   - **Aggregation and triage** (parent, grain of salt):
     - Deduplicate by `(file, line range, principle)` before applying cleanup.
     - Keep the strongest severity when two lenses report the same issue.
     - Surface cross-lens conflicts instead of resolving them silently, e.g. clean-code says
       "extract" while cleaner-code says "inline until stable".

     | Second opinion | Primary agrees? | Action |
     |----------------|-----------------|--------|
     | must-fix | yes | fix in primary pass |
     | must-fix | no | note conflict; default **primary** unless scout cites clear rule violation |
     | must-fix | primary missed | adopt if concrete; else should-fix |
     | should-fix | either | fix if cheap; else log for handoff |
     | nit / deferred | — | log only; do not expand scope |
     | conflicts with primary cleanup | — | prefer **minimal diff**; mention in AskQuestion gate |

   - Record one line: `lens-fanout: clean | adopted N | noted M conflicts | skipped <reason>`
   - If a lens dispatch fails (timeout, unavailable model): continue primary + other lenses. When a slice brief
     resolved, the parent runs the core integrity checks itself but **labels them `degraded
     (author self-review)`** — a non-author scout is the real seam for catching self-deception;
     note both in handoff.
3. If clean (zero must-fix after triage; should-fix resolved or waived): exit loop → step 3.
4. **Apply fixes** to working tree — triaged must-fix and adopted should-fix only.
5. **Do not stage fixes yet.** Show cleanup delta:
   ```bash
   git diff --stat -- <fixed-paths>
   git diff -- <fixed-paths>
   ```
6. **AskQuestion:** approve staging this cleanup before next audit round?
   - **Approve** → `git add -- <fixed-paths>` → next round (or exit if now clean)
   - **Reject** → stop loop; human reverts/edits manually; report state
7. Repeat until clean or 3 rounds exhausted.

**Cross-model pairing** (second-opinion dispatch):

Infer the parent family, then dispatch the **best non-max available opposite-family
thinking model**. "Non-max" = strong thinking tier, not the absolute top/most-expensive
SKU. Resolve concrete slugs against the dispatchable list at runtime; pick the closest
match if a named example is gone.

| Parent family | Dispatch (opposite family, best non-max thinking) | Current concrete pick |
|---------------|---------------------------------------------------|------------------------|
| Claude (`claude-*`, Composer thinking) | best GPT thinking | `gpt-5.5-medium` |
| GPT / Codex (`gpt-*`, `composer-*` non-Claude) | best Opus/Claude thinking | `claude-opus-4-8-thinking-high` |
| Unknown | default to GPT thinking | `gpt-5.5-medium` |

If no opposite-family thinking model is dispatchable, fall back to the other family or skip
with a handoff note — **do not block commit-prep on scout failure.**

If round 3 ends with **must-fix** remaining: report blockers; skip commit message.

#### Lens fanout validation fixture

To validate lens wiring without touching product code, use a staged documentation fixture or pasted
diff snippet with one planted violation per lens:

| Lens | Planted violation | Expected scout finding |
|------|-------------------|------------------------|
| `stack-conventions` | backend/client path ignores active profile stack rules | reports a stack-conventions finding only |
| `clean-code` | changed function uses vague names and mixed responsibilities | reports naming/function responsibility only |
| `cleaner-code` | duplicated stable rule or premature helper creates future change cost | reports structural blast-radius risk only |

The proof passes when each assigned lens reports its planted violation and ignores the other two.
Docs-only diffs pass by spawning no code lenses and relying on staged-audit's docs-only checks.

### 3. Commit message (staged index)

When audit is clean and index reflects scope + all approved cleanups:

**Read and follow** [commit-msg](../commit-msg/SKILL.md) **`staged-only` mode in full.**

Hard rules for commit-prep output:

1. **Exactly one line** — `<type>(<scope>): <imperative summary> <gitmoji>`
2. Epistemic seed (slice brief, commit-plan group, docs mode) informs *wording* — **never paste**
   multi-line blocks from `07-commit-plan.md` or plan prose into the commit message.
3. **No** body paragraphs, bullet lists, `Refs:`, or PR-description content in the message.
4. Match `git log --oneline -10` style; trailing gitmoji required.
5. Long epistemic context → cite in handoff for the appropriate PR-description command, not in `-m`.

Docs mode examples (one line each):

```
docs(prep): bootstrap upstream-contract-advanced-extensions prep tree 📝
docs(prep): checkpoint roadmap and slice brief 📝
docs(plan): consolidate upstream advanced extensions master plan 📝
```

Code mode examples:

```
feat(refinery): additive contract schema for advanced upstream fields ✨
refactor(refinery): extract settlement validation to settlementDraft ♻️
```

### 4. Handoff

Handoff shape:

```text
Scope: <paths or group label>
Rounds: N/3 — audit clean | N blockers (list)
Second opinion: <per-round summary | skipped (single-audit)>
Staged: <git diff --cached --stat>
```

Commit message:

```text
<type>(<scope>): <summary> <gitmoji>
```

Commit command:

```bash
git commit -m "<type>(<scope>): <summary> <gitmoji>"
```

Then:
- after a **slice code** commit, run `tools/mep/bin/mep where <slug> --json`; if
  `optionalSteps[0]` is present, surface that optional `/prep-pr-description` step before the
  resolver `nextCommand`; otherwise no per-slice PR-body nudge applies
- non-slice / architecture / master-plan / graduation → `/pr-description`
- resolver `nextCommand` is always the required local continuation (usually `/prep <slug> checkpoint`
  after a landed slice); derive it from `where`, not from memory
- other local continuation → derive it from the Continuation Contract in
  `.cursor/skills/mise-en-place/portable-routing.md`; do not keep a local state-routing table here.

Always include **both** forms in this order:

1. `Commit message:` followed by a standalone `text` code block containing only the one-line message.
2. `Commit command:` followed by a standalone `bash` code block.
3. `Then:` continuation outside the command block, resolved through the portable routing contract.

Use the simplest valid command for one-line messages: `git commit -m "<message>"`. Do **not** use a
heredoc unless the message is intentionally multiline or shell quoting would otherwise be ambiguous.
Do not collapse the handoff to only one form; the message is for review, the command is for execution.

If loop stopped on rejection or blockers: index may be partially staged; human resolves
before commit. Optional `/staged-audit` spot check.

## When to use / skip

| Use `/commit-prep` | Skip |
|--------------------|------|
| After `/implement-plan` — code scope (slice brief ownership) | Ad-hoc human review only → `/staged-audit` |
| `docs-bootstrap` after prep phase 5 or tidy phase 5 | Message only → `/commit-msg` |
| `docs-delta` after checkpoint / slice merge / plan update | Prep/tidy macro phases (never stage product code) |
| One **code** group from `07-commit-plan.md` (tidy) | |
| `/prep-cleanup` graduation — code scope + `docs-delta` for `06-graduation.md` | |

## Examples

```
/commit-prep upstream-contract-advanced-extensions group 1
/commit-prep upstream-contract-advanced-extensions group 1 single-audit
/commit-prep upstream-contract-advanced-extensions docs-bootstrap
```

## Relationship

| Slash | Role |
|-------|------|
| `/commit-prep` (this) | Gated audit-fix rounds → staged handoff + message |
| `/staged-audit` | Human-in-loop audit; spot checks |
| `/commit-msg` | Message only; default mode prompts on unstaged |
| `/tidy` | Produces groups; run commit-prep per group |
| `/prep` | Slice handoff → implement → commit-prep → human commit |
