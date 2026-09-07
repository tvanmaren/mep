# MEP integration curation — outline (v0.1)

**Status:** approved for v0.1 (iteration 13 in `mep-v0-graduation`)  
**Canonical program:** `.mep/prep/mep-v0-graduation/04-iteration-roadmap.md` · epic #85 · sc-102  
**Vision context:** [mep-vision-proposal.md](./mep-vision-proposal.md)

## Mission

Curate answers:

> **What is the shortest truthful explanation of this initiative?**

Merge courses and PRs are the **serialization format** — not the objective.

**Curate is lossy compression of development history** — lossy on chronology, lossless on concept.
The preview is the **introduction chapter** to a PR series — not a project-management document.

**MEP symmetry:** roadmap → *what are we trying to learn?* · iterations → *what did we learn while
building?* · curate → *how should we teach what we learned to the next engineer?*

**Two peer outputs from execution:** operational history (iterations, lab branch) and publication
history (curation, integration branches). One optimizes **building**; one optimizes **teaching**.

Preview is the strategy gate. **`--execute`** writes publication history on disposable integration
branches — curated for comprehension, **not fabricated**. Lab branch untouched (**discovery fidelity**).

---

## Problem

| history kind | contents | consumer | git artifact |
|--------------|----------|----------|--------------|
| **Discovery** | iter 1–N, prep tree, lab-branch commits | future-you, MEP | **lab branch** (notebook — never rebase) |
| **Conceptual** | discoveries, curation plan, ADs, gating | approve before execute | `integration-curation.md` + `.json` |
| **Publication** | curated commits on fresh branch(es) | reviewers, merge | **integration branch(es)** |

Git and `/mep stage` optimize for **slice boundaries** (one iteration ≈ one review unit). That breaks
down at 35 slices / 16k+ LOC: 35 PRs is worse than one blob — one blob is worse than a **structured,
truthful narrative**.

**Curation** projects discovery for human comprehension. Semantic rebasing as **documentation**, not
history rewrite of the lab notebook.

---

## The epistemic leap

**Iterations optimize discovery. Courses optimize comprehension.** Different axes.

| axis | unit | optimizes |
|------|------|-----------|
| Discovery | iterations (slices) | what we learned next |
| Comprehension | merge courses | what a reviewer should understand |

**Courses ≠ iterations.** Never 1:1. **Iteration briefs are evidence** — witnesses, not commands.

**Reject chronological bias.** Do not preserve implementation order unless it also minimizes reviewer
cognition. Commit chronology on the lab branch is evidence, not publication order.

---

## Publication stack

> **Publication order follows comprehension + merge safety — not iteration numbers.**

State that line prominently in every preview. It is the philosophical justification for curate.

Synthesize top-down — **not** directly from iteration numbers:

```text
Evidence                requirements + ADs + discoveries (exploration learnings)
    ↓
Merge courses           sequential develop gates
    ↓
Review shards           stable ~300 LOC completions (stack layers; attention budgets)
    ↓
Reviewer learning path  cumulative understanding after each course
    ↓
Confidence report       curate self-assessment + alternatives considered
    ↓
Publication commits     curated integration history on disposable branches
```

### Evidence (three kinds)

Curate isn't inventing — it's synthesizing from prep. Evidence collectively justifies the plan:

| kind | id prefix | question | source |
|------|-----------|----------|--------|
| **Requirements** | R | what must the system guarantee? | invariant goal, success conditions |
| **Architectural decisions** | AD | what did we choose? | architecture doc |
| **Discoveries** | D | what did exploration teach? | **`03-core-vs-volatile` amendments** + interchangeable rows; cite C*/I* ids |

Iteration briefs are **citations** — witnesses, not primary sources for D rows after checkpoints ran.

| layer | kind | LOC target | lands on develop? | independently runnable? |
|-------|------|------------|-------------------|-------------------------|
| **merge course** | `merge-course` | **~2,000** (soft max ~3k) — **display last** | **yes** — ordered gate (course tip) | **yes** — tip must build/smoke |
| **review shard** | `review-shard` | **~300** (max **500**) — attention budget | **no** — stack-only | **no** — may be progressive inside its course |

---

## Optimize (in order)

When tradeoffs conflict:

1. **Reviewer understanding** — right mental model after reading the narrative
2. **Merge safety** — flag-off legacy; flag-on coherent through course N; **smokes at course tip**
   (not every intermediate shard)
3. **Narrative honesty** — never invent deps or hide why the system evolved
4. **Conceptual cohesion** — one conceptual move per merge course; reject leftover/hygiene courses
5. **Minimal dependency depth**
6. **Discovery record** — lab + prep preserved; curation cites evidence
7. **LOC targets** — shard and merge-course budgets (constraints, not the goal)

### `--optimize` preset

Optional goal override — executor reads invocation flag, then `manifest.curationOptimize`, then
default `reviewer-comprehension`. CLI passthrough post-v0.1; executor honors preset today.

| preset | when tradeoffs conflict, prefer… |
|--------|----------------------------------|
| **`reviewer-comprehension`** | teaching order → merge safety → honesty → cohesion → depth → discovery → LOC |
| **`merge-speed`** | merge safety → minimal depth → LOC → cohesion → teaching order → honesty → discovery |
| **`earliest-value`** | operator-visible courses earlier (when gating allows) → merge safety → teaching → honesty → depth → discovery → LOC |

Post-v0.1 presets (document only): `parallelism`, `release-risk`, `minimal-backport`.

Path globs + LOC alone do **not** prove merge safety. Preview includes **mergeability pass**
(architecture ship order, flags/stubs, smoke closure).

Each merge course must answer **in this order** (trunk state leads; LOC is last):

1. **Trunk after merge** — what new truth exists after this lands?
2. **Why now?** — conceptual justification citing R/AD/D (*exists because D3 and AD-4 become
   independently reviewable once the registry seam exists* — not merely `dependsOn`)
3. **Why not merged with previous?** — intentional boundary
4. **~product LOC** — budget constraint

Also: **concern** (`platform` | `domain` | `ui` | `certification`); optional **reviewerCognition**
(`low` | `medium` | `high` + reason). After the dependency DAG, emit **reviewer learning path**.

**Narrative honesty (v0.1 manual, v2 automate):** per course, **watch for:** — what wrong conclusion
might a reader draw if they stop at this PR alone?

**Brevity:** preview must stay readable before reviewing N PRs. Expand shard tables in artifact only.

### Confidence report (curate self-assessment)

End every preview with synthesis confidence and an honest self-check:

| bucket | examples |
|--------|----------|
| **High** | course boundaries, dependency graph, learning path |
| **Medium** | sizing on open iterations, retrofit scope |
| **Low** | underdetermined intent (should trigger level 3 or level 2 alternative) |

Include **alternatives considered** with rejection reasons (builds operator trust without asking).

---

## Interaction policy

**Maximize recommendations, minimize interrogations.** Preview is **one** high-value interruption:
the human ratifies an architectural editor's draft — not a questionnaire.

### Staff-engineer heuristic

> Could a highly respected staff engineer answer this without talking to the author?

| answer | action |
|--------|--------|
| Yes | decide; state confidence in prose |
| Ambiguous | preferred + alternative; human **chooses** |
| No — org/product | ask (product-decision list below) |

### Confidence ladder (prose — not scored)

| level | output |
|-------|--------|
| **Autonomous** | full proposal → *approve preview?* |
| **Ambiguous** | preferred strategy + alternative + reason |
| **Underdetermined** | one intent question — never *how many PRs?* |

### Always ask (product decisions)

Flag vs single merge · compat vs simplification · partial value vs cohesion · demo/urgency reordering.

### Authorship mode (curate)

| mode | behavior |
|------|----------|
| **default** | propose → level 2 if needed → level 3 for product only → approve preview |
| **manual** | co-design; more questions OK |
| **autopilot** | autonomous synthesis — **still** approve preview; execute never skips ratification silently |

Preference learning from preview edits → post-v0.1.

---

## Invariants

- **Narrative honesty.** Never separate concepts in a way that obscures evolution. Never invent
  dependencies. A clean PR that mis-teaches the reviewer is failure.
- **Lab branch sacred.** Never rebase discovery.
- **Publication ≠ fabrication.** Integration history is curated for comprehension; discovery fidelity
  lives in the lab branch.
- **Preview approves communication strategy** — grouping, order, deps, gating — not code (code is on
  the lab branch already).

---

## Judgment vs CLI (who does what)

| step | actor | tool |
|------|-------|------|
| synthesis, mergeability pass, gating plan | **executor (LLM) + human approve** | `/prep-curate`, skill |
| measure LOC, validate schema, git execute | **CLI** | `mep curate --json measure \| validate \| execute` |

`mep curate --json --preview` = **preflight + measure** (deterministic). Operator **`/mep curate
--preview`** = full synthesis in chat + optional CLI measure for LOC truth.

Runtime **never** calls an LLM. Executor adapter fulfills synthesis — same seam as `mep implement`.

---

## v0.1 scope

### In scope

| deliverable | notes |
|-------------|-------|
| **`/mep curate <slug> --preview`** | merge courses + review shard plan + mergeability pass + gating contracts — no git writes |
| **`/mep curate <slug> --execute`** | after approve: integration branch(es), **publication history** at merge-course granularity |
| **Artifact** | `integration-curation.md` + **`integration-curation.json`** (execute consumes JSON) |
| **Safety** | backup ref; lab branch never mutated |
| **Handoff** | `/mep stage` maps integration branches → PR stack |
| **Dogfood** | txn-adjustment-revamp: preview → execute → stage |

### Out of scope (v0.1)

- Rebasing or rewriting the discovery branch
- Replay of iteration SHAs as the integration story
- Claiming **parallel independent** develop merges without gating evidence
- Automatic feature-flag retrofit on monolith lab branches (plan may **require** retrofit; implementation is a separate slice)
- Slug inference
- CLI passthrough for `--optimize` (executor + manifest field only in v0.1)
- Learning publication preferences from preview edits

### Post-v0.1

- Import/call-graph hints for mergeability
- `mep curate --json` validate gating flags exist in repo
- Opt-in fully automated synthesis (never default)
- **Automated watch-for pass:** per-course easy-misunderstanding check (*what wrong conclusion might a reader draw?*)
- Dependency graph concern coloring in rendered output

---

## Operator model

```text
Discovery                 Curate preview                    Curate execute              Stage
────────────────          ──────────────                    ──────────────              ─────
lab branch + prep    →    discoveries + merge courses  →  integration branch(es)  →   PR stack
many slice commits        review shards (~300)            publication commits       shard layers +
                          mergeability + gating           (curated history)         develop-gate tips
```

**Plain language:** curate turns the lab notebook into a **reviewable publication** and a **sequential
merge playbook** — not 35 develop merges, not one blob, not 55 falsely-independent PRs.

---

## Command contract (v0.1)

### `/mep curate <slug> --preview`

**Purpose:** operator approves **communication strategy** (discoveries, grouping, order, gating) — not code.

1. **Preflight:** manifest, git, trunk, dirty scopes (`mep curate --json --preview` / `status`).
2. **Read corpus:** iterations, invariant goal, architecture ADs, reckoning, commit-plan groups.
3. **Distill evidence** — requirements, ADs, discoveries — from invariant goal, architecture, and
   **belief state** (`03-core-vs-volatile`); iteration briefs cite, not replay.
4. **Measure:** product LOC per path group (`mep curate --json --measure`) — constraint, not headline.
5. **Synthesize merge courses** from evidence + architecture ship order.
6. **Mergeability pass** (mandatory): sequential order, flags/stubs, **course-tip** smokes,
   shared-file ledger, no leftover courses, `retrofitRequired`.
7. **Plan review shards** as attention budgets inside each course (~300, ≤500 max); shards may be
   progressive within the course.
8. Per course: **trunk state**, **why now**, **why not merged with previous** (both tips runnable),
   concern, cognition.
9. Reject progressive unfinished **courses** (tip N must not need tip N+1). Within-course progressive
   shards are allowed. Reject leftover/hygiene courses.
10. **Reviewer learning path** after dependency DAG.
11. **Confidence report** — high/medium/low + alternatives considered.
12. Show plan; write artifacts only after operator confirms.

**No branches, commits, or rebases in preview.**

### `/mep curate <slug> --execute`

**Requires:** approved artifact (`status: approved`) + explicit operator gate.

1. Backup ref; record lab SHA.
2. **For each merge course** (dependency order):
   - Create integration branch from trunk or prior merge-course branch.
   - Apply lab tree state for course paths.
   - Write **publication commits**: merge-course message + optional nested shard commits per plan.
3. Never commit on the lab branch.
4. Record branches/SHAs in artifact `execute` section.
5. Hand off to `/mep stage`.

**Execute materializes publication history.** It does not merge to `develop`. Human merges **merge
courses** (or squash a course stack) per the gating plan.

Implementation v0.1: agent + [split-to-prs](~/.cursor/skills-cursor/split-to-prs/SKILL.md) discipline;
`tools/mep/scripts/curate.py` for measure/validate/execute mechanics.

---

## Budgets

### Merge course budget (develop gates)

Counts **product code only** (same exclusions as review).

| tier | LOC added (product) | action |
|------|---------------------|--------|
| **target** | **~2,000** | ideal merge-course size (~8 courses for ~16k LOC) |
| **soft max** | **~3,000** | warn; prefer split unless `cannot-separate` |
| **oversize** | **>3,000** | split into another merge course or flag `cannot-separate` + human approval |

Initiative override via `manifest.mergeBudget` or operator preview caps. Architecture AD per-PR budgets
(e.g. AD-11 ≤7k preview PR) may **supersede** 2k default for a single merge course when documented.

### Review shard budget (stack-only)

| tier | LOC added (product) | action |
|------|---------------------|--------|
| **target** | **≤300** | ideal shard |
| **max** | **≤500** | acceptable |
| **oversize** | **>500** | more shards inside the same merge course — **not** a new develop merge |

When a merge course exceeds ~2k product LOC, add merge courses — do not promote shards to develop
merges. Do **not** require each shard tip to be product-runnable — that re-inflates shards into
mini-courses. Require runnable **course tips** only.

---

## Mergeability & gating

### Runnable grain (two levels)

| unit | independently runnable? | notes |
|------|-------------------------|-------|
| **course tip** | **yes** | build + targeted tests + flag-off smoke; develop gate |
| **review shard** (incl. shard PRs) | **no** | attention/diff budget; may be progressive **inside** its course |

> A merge course is a trunk state you can run, not a chapter heading with a LOC budget.

**Across courses:** tip N must not depend on unmerged tip N+1 hunks.  
**Within a course:** progressive shards are allowed.  
**Leftover courses:** reject MCs whose only justification is residual wiring / demo harness / crumbs.

**Shared-file ledger (preview):** every path touched by ≥2 courses names an owning course tip and
allowed earlier stubs. Muddy ownership → merge courses or invent an explicit stub seam before execute.

**CI:** require full checks on **course-tip** PRs (and trunk). Do not require product smokes on every
intermediate shard PR.

### Mergeability kinds (artifact field)

| value | meaning |
|-------|---------|
| **`sequential-to-develop`** | default; merge course N after N−1; each **course tip** shippable on trunk |
| **`independent`** | may merge without prior courses — **requires evidence** (correctness-only fix, already on trunk, etc.) |
| **`stacked-only`** | review/publication only; **never** merge individually to develop; not required to be runnable alone |
| **`cannot-separate`** | oversize but conceptually atomic; human approves single merge |

**Independently mergeable ≠ mergeable in any order.** It means **each ordered course tip leaves main
shippable** — usually via flags + stubs + sequential merge.

### Gating contract (per merge course)

Each merge course with behavioral change should declare:

```json
"gating": {
  "flag": "refinery.adjustmentV2",
  "default": false,
  "activatesThrough": "course-3",
  "stubInventory": ["StatusTransitionPlanner noop until course-6"],
  "legacyPath": "unchanged when flag off"
}
```

| check | requirement |
|-------|-------------|
| **flag off** | zero behavior change vs legacy; new code unreachable or no-op |
| **flag on (partial)** | only surfaces registered through course N are active |
| **flag on (full)** | after final course or explicit flip course |
| **smoke at course tip** | named scripts pass flag-off; scoped flag-on where applicable — **not** required on every intermediate shard |

### Stub / seam pattern (sequential merge discipline)

For overhaul branches, course 1 (or early course) often owns **registry seams** — hook registry,
route table, planner dispatch — with **stubs/no-ops**; later courses **register real modules** without
rewriting the seam file structure. Conflicts at merge time (stub → real) are expected and small when
order is respected.

**Monolith lab branches:** if discovery did not build stub-first, preview must flag **`retrofitRequired`**
— curate plans the merge story; code may need a forward slice (master flag + registry) before execute
is honest.

---

## Relationship to `/mep stage`

| command | question |
|---------|----------|
| **stage** | Map integration branches → PR stack; merge-course tips → develop PRs |
| **curate** | What is the merge story + review publication for the whole initiative? |

Stage **prefers** curated review shards over 1:1 iteration mapping. Shards appear as stacked PRs
(or nested commits when no native stack); merge-course tips are the develop gates — not dozens of
develop merges, and not lab-WIP chronology.

### Publication substrate (profile-owned — not portable core)

Curate's courses/elements model is substrate-agnostic. Repos that have a preferred stack tool declare
it on the structured profile seed (`capabilities.publication` — see
`tools/mep/docs/profile-capabilities.md`):

| field | role |
|-------|------|
| `stackBackend` | remote review surface (`github-native`, `graphite`, `branch-chain`, …) |
| `tool` | local cli (`gh-stack`, `gt`, …) |
| `defaultSerialization` | how courses/elements become PRs |

**Vocabulary:** **merge course** = develop gate (~2k) — **must be tip-runnable**. **Review shard** =
stack/PR layer (~300) — attention budget; may be progressive inside its course. **Discovery slice** ≠
publication unit.

**Stability invariant (course-scoped):** no progressive unfinished **courses**. Tip N must leave trunk
coherent without tip N+1. Within a course, shard PRs may be progressive / not product-runnable. If
shard n+1 must rewrite n’s already-reviewed surface to become true **and** that rewrite crosses a
course boundary, the course cut was wrong. Lab commit chronology is evidence, not stack shape.

**When `defaultSerialization: stack-of-shards`** (host today): stack layers = review
shards (`stacked-only`); merge courses mark develop-gate tips (the runnable gates); a stack may be
one course’s shards or a linear run of several. Execute remains course-grained; **stage** binds shards
to the declared tool. Omit the capability → nested-commit / branch-chain fallback. Never dual-submit
to two remote stack UIs.

---

## Artifact schema

### Markdown (`integration-curation.md`)

Human-readable plan: **evidence** (R / AD / D), merge courses (**trunk state first**, why now, why not
merged, concern, cognition, **watch for:**), shard attention budgets, dependency graph, **reviewer
learning path**, **confidence report**, gating tables, execute notes.

### JSON (`integration-curation.json`) — execute input

```json
{
  "schemaVersion": 2,
  "status": "draft",
  "slug": "txn-adjustment-revamp",
  "sourceBranch": "feat/TICKET-2235/…",
  "sourceSha": null,
  "trunk": "develop",
  "retrofitRequired": true,
  "curationOptimize": "reviewer-comprehension",
  "mergeBudget": { "targetLocAdded": 2000, "softMaxLocAdded": 3000 },
  "reviewBudget": { "targetLocAdded": 300, "maxLocAdded": 500 },
  "requirements": [{ "id": "r1", "statement": "…", "evidence": ["…"] }],
  "architecturalDecisions": [{ "id": "ad4", "statement": "…", "evidence": ["…"] }],
  "discoveries": [{ "id": "d1", "statement": "…", "evidence": ["…"] }],
  "reviewerLearningPath": [{ "afterCourse": "1", "understand": ["…"] }],
  "confidenceReport": {
    "synthesis": "autonomous",
    "high": ["Course boundaries", "Dependency graph"],
    "medium": ["MC-7 sizing — open iteration"],
    "low": [],
    "alternativesConsidered": [
      { "proposal": "Merge MC-6 and MC-7", "rejectedBecause": "Independently reviewable concerns" }
    ]
  },
  "courses": [
    {
      "id": "1",
      "kind": "merge-course",
      "title": "Uncancel correctness",
      "dependsOn": [],
      "whyNow": "D7 — sample correctness fix is independently shippable before preview work",
      "whyNotMergedWithPrevious": "First course (or skip if already on develop)",
      "concern": "domain",
      "reviewerCognition": { "level": "low", "reason": "Pure correctness" },
      "mergeability": "independent",
      "productLocAdded": 800,
      "paths": ["host-api/utils/domain/HostJournaler/**"],
      "gating": null,
      "reviewShards": 3,
      "commitMessage": "refinery: uncancel restores spot-lock + journal seams",
      "suggestedPrTitle": "TICKET-2235 sample correctness fix",
      "smokeClosure": ["uncancel_correctness_smoke_test.sh"],
      "trunkStateAfterMerge": "Uncancel restores spot-lock correctly; legacy adjust path unchanged"
    },
    {
      "id": "2",
      "kind": "merge-course",
      "title": "Platform seam + master flag",
      "dependsOn": ["1"],
      "whyNow": "AD-4 and R1 become independently reviewable once registry seam exists (MC-1)",
      "whyNotMergedWithPrevious": "Registry + flag are platform concerns separable from sample correctness fix",
      "concern": "platform",
      "reviewerCognition": { "level": "low", "reason": "Seams and stubs; no operator behavior change" },
      "mergeability": "sequential-to-develop",
      "productLocAdded": 400,
      "paths": ["host-api/…/hooks/**"],
      "gating": {
        "flag": "refinery.adjustmentV2",
        "default": false,
        "activatesThrough": "2",
        "stubInventory": ["planner dispatch registry", "lifecycle route 501"]
      },
      "reviewShards": 2,
      "commitMessage": "refinery: adjustment v2 master flag + registry seams (default off)"
    }
  ],
  "execute": null
}
```

Review shards may be nested under a parent course:

```json
"reviewShardsPlan": [
  { "shard": "2a", "parentCourse": "2", "productLocTarget": 300, "paths": ["…"], "mergeability": "stacked-only" }
]
```

`mep curate --json validate` checks: acyclic deps, shard LOC ≤500, merge courses ≤ soft max unless
`cannot-separate`, every behavioral course has gating or explicit waiver.

---

## Preview checklist (executor)

- [ ] **Evidence** (R / AD / D) distilled before courses — not raw iteration replay
- [ ] **Publication order = comprehension + merge safety** stated prominently
- [ ] **Communication strategy** clear — operator knows what they are approving
- [ ] Architecture AD ship order cited
- [ ] **Narrative honesty** — no invented deps; evolution not obscured
- [ ] **Chronological bias rejected** — publication order serves comprehension
- [ ] Merge courses: **trunk state first**, **why now**, **why not merged with previous**
- [ ] Review shards as **attention budgets** (~300); none promoted to develop without evidence
- [ ] Shards may be progressive **inside** a course; **course tips** must be independently runnable
- [ ] **No progressive unfinished courses** (tip N coherent without tip N+1)
- [ ] **Shared-file ledger** for paths touched by ≥2 courses
- [ ] **No leftover/hygiene courses** (fold crumbs into last doctrine course)
- [ ] **Reviewer learning path** after dependency DAG
- [ ] **Confidence report** + alternatives considered
- [ ] **Watch for:** per behavioral course (not "misconception risk")
- [ ] Preview brevity — readable before N PRs; shard detail in artifact
- [ ] Gating contract per behavioral merge course (or waiver)
- [ ] `retrofitRequired` honest for monolith branches
- [ ] **Interaction policy** — propose first; level 3 / product decisions / thin prep only
- [ ] **`curationOptimize`** preset resolved (default `reviewer-comprehension`)
- [ ] Smoke closure named **per course tip** (CI grain matches: tips, not every shard)

---

## v0.1 implementation slices

| slice | owner | deliverable |
|-------|-------|-------------|
| **13a** | skill + command | two-layer model in skill + prep-curate; routes in `mep.md` |
| **13b** | prep-stage | read curation artifact; merge-course → PR mapping |
| **13c** | CLI | `mep curate measure \| validate \| execute`; schema v2 |
| **13d** | execute | merge-course integration branches + nested shard commits |
| **13e** | dogfood | txn-adjustment-revamp: ~8 merge courses + shard plan |

---

## Success criteria (v0.1 curate done)

- Preview produces **merge courses** (~2k, tip-runnable) **and** **review shards** (~300 attention),
  with mergeability pass (shared-file ledger, no leftover courses).
- Execute builds integration publication at merge-course granularity; lab branch unchanged.
- Stage maps to PR stack; operator understands which PRs are **develop gates (course tips)** vs
  **review-only shards** (not required to be runnable alone).
- txn-adjustment dogfood documents gating/retrofit honestly (e.g. no flags today → `retrofitRequired: true`).

---

## Example: txn-adjustment-revamp (sketch)

~16k product LOC → **~8 merge courses** (not 55 develop merges):

| # | merge course | ~product LOC | gating | notes |
|---|--------------|--------------|--------|-------|
| 1 | sample correctness fix | ~800 | none / independent | skip if already on develop |
| 2 | platform seam + master flag | ~400 | `adjustmentV2` default off | **retrofit keystone** |
| 3 | adjustment engines + read service | ~2k | flag off = legacy | backend only |
| 4 | apply path + metal-txn invariants | ~2k | partial flag-on | no UI yet |
| 5 | adjustment UI preview→commit | ~2k | UI behind flag | AD-11 preview PR core |
| 6 | lifecycle planner + event contract | ~2k | sub-flag or master | iters 14–25 |
| 7 | lifecycle journal materialization | ~2k | sequential | iters 16–18, 37–38 |
| 8 | lifecycle admin UI + certification + flip | ~2k | flip default | smokes |

Each row: **~7 review shards** (`stacked-only` attention budgets; may be progressive inside the
course) for publication; **one** develop-merge tip that must be independently runnable. With
`capabilities.publication.defaultSerialization: stack-of-shards`, those shards are github stack
layers (not lab-WIP chronology, not nested-commit-only inside one PR).

---

## Links

| Artifact | Role |
|----------|------|
| `.mep/prep/mep-v0-graduation/iterations/13-integration-curation.md` | v0.1 iteration brief |
| `.cursor/commands/prep-curate.md` | operator command |
| `.cursor/skills/mise-en-place/curate/SKILL.md` | executor workflow |
| `wiki/architecture/TICKET-2235-sample-architecture.md` | AD-11 ship order (dogfood) |
| `.mep/plans/mep-v0.2-outline.md` | routing architecture (separate from curate) |
