---
name: mep-curate
description: >-
  Lossy compression of discovery history into the smallest truthful review narrative
  for reviewers — then materialize curated publication history on disposable integration
  branch(es). Use for /mep curate, /prep-curate, or merging a long initiative without
  rebasing the lab branch.
---

# MEP integration curation

## Mission

Curate answers one question:

> **What is the shortest truthful explanation of this initiative?**

Merge courses and PRs are the **serialization format** — not the objective. Transform discovery
history into that explanation while minimizing reviewer cognitive load.

Curate is **lossy compression of development history** — lossy on implementation order and
exploration noise, **lossless on conceptual information**. The code already exists on the lab branch;
curate produces a **review curriculum** — the **introduction chapter** to a PR series, not a
project-management document.

**MEP symmetry:** roadmap asks *what are we trying to learn?* · iterations ask *what did we learn
while building?* · curate asks *how should we teach what we learned to the next engineer?*

See `wiki/plans/mep-curate-outline.md` for full contract.

---

## The epistemic leap

**Iterations optimize discovery. Courses optimize comprehension.** Those are different axes.

| axis | unit | question |
|------|------|----------|
| **Discovery** | iterations (slices) | what did we learn next? |
| **Comprehension** | merge courses | what should a reviewer understand? |

**Courses ≠ iterations.** Never map 1:1. **Iteration briefs are evidence** — witnesses to discovery,
not commands for publication order.

**Reject chronological bias.** Do not preserve implementation order unless that order also minimizes
reviewer cognition. Lab-branch commit order is evidence, not scripture.

---

## Publication stack

> **Publication order follows comprehension + merge safety — not iteration numbers.**
>
> That line is the philosophical justification for curate. State it prominently in every preview.

Synthesize top-down — not directly from iteration numbers:

```text
Evidence             requirements + architectural decisions + discoveries (exploration learnings)
    ↓
Merge courses        (sequential develop gates — shape of the resulting system)
    ↓
Review shards        (attention budgets ~300 LOC → stack-only, inside a merge course)
    ↓
Reviewer learning path   what the reviewer understands after each course
    ↓
Confidence report    curate self-assessment + alternatives considered
    ↓
Publication commits  (curated integration history on disposable branches)
```

**Evidence** — three kinds synthesizing from prep; curate isn't inventing, it's citing. They
collectively justify the publication plan (like a paper's claims + methods):

| kind | question | primary source |
|------|----------|----------------|
| **Requirements (R)** | what must the system guarantee? | invariant goal, success conditions |
| **Architectural decisions (AD)** | what did we choose? | architecture doc + **stable core** rows (C*) |
| **Discoveries (D)** | what did exploration teach? | **`03-core-vs-volatile` amendments** + open interchangeable rows; iteration briefs cite, not replay |

**Belief state before replay:** by curate time, checkpoints have already promoted categories to core.
Curate **cites stable core rows (C*)**, not re-derives prior checkpoint promotions from chat.
Reckoning and iteration titles are secondary evidence only.

Iteration briefs are **citations** for all three — witnesses, not publication commands.

**Two layers in the artifact:** merge courses (develop) contain review shards (publication only).

| unit | job | independently runnable? |
|------|-----|-------------------------|
| **merge course tip** | trunk chapter / develop gate | **yes** — build + targeted tests + flag-off smoke |
| **review shard** | attention / diff budget (~300 LOC); may be its own stacked PR | **no** — may be progressive **inside** its course |

> Shards may be unfinished progressive states **inside** a course; only the **course tip** must be
> an independently runnable trunk state.

Nobody should need to understand more than ~300 product LOC to validate one conceptual step — that
is an **attention** budget, not a “each shard ships alone” budget.

**Cross-course vs within-course:** tip N must not depend on unmerged tip N+1 hunks. Progressive
shards inside MC-N are fine; progressive unfinished **courses** are not.

---

## Preview gate

**Preview exists so the human approves the communication strategy — not the code changes.**

The operator ratifies:

- **evidence** (requirements, ADs, discoveries) and how it justifies grouping
- **merge course** order, **why now**, and **why not merged with previous**
- **gating** story (flags, stubs, **trunk state after merge** per course)
- **review shard** attention budgets inside each course
- **reviewer learning path** (cumulative understanding after each course)
- **confidence report** — what curate is sure/unsure about; alternatives considered
- optional **reviewer cognition** estimates (low / medium / high) for lead scheduling

**Brevity:** target readable before reviewing N PRs. Full shard tables belong in the artifact, not
an inflated chat preview.

No artifact write, branch, commit, or rebase until preview is approved.

**One interruption, high value:** synthesis happens first; the human ratifies the draft at the end.
Do not turn preview into planning poker.

---

## Interaction policy

**Maximize recommendations, minimize interrogations.** The operator reviews an architectural
editor's work — not a questionnaire. Curate inherits MEP's attention rule: humans spend attention only
where it adds unique value.

### Staff-engineer heuristic

Before asking anything:

> Could a highly respected staff engineer answer this without talking to the author?

| answer | action |
|--------|--------|
| **Yes** | decide from prep tree + ADs; state confidence in prose; include in proposal |
| **Ambiguous** | level 2 — preferred + alternative; human **chooses**, does not co-design |
| **No — organizational/product** | level 3 — ask (see always-ask list) |

Thin prep tree → more level 3. Fix prep; do not compensate with more curate questions.

### Confidence ladder (prose — not scored telemetry)

| level | when | output |
|-------|------|--------|
| **1 — autonomous** | prep + ADs resolve grouping, order, gating | full proposal → *approve preview?* |
| **2 — ambiguous** | two plausible publication strategies | **preferred** + **alternative** + reason; human picks |
| **3 — underdetermined** | intent not in prep tree | one architectural-intent question; never "how many PRs?" |

**Bad question:** *how many PRs do you want?* (that's curate's job)

**Good question:** *should reviewers understand lifecycle planning before preview-then-confirm, or
vice versa?* (architectural intent)

### Always ask (product decisions)

Not deducible from code or prep — organizational choices:

- flag vs single merge
- backwards compatibility vs API simplification
- ship partial value early vs wait for cohesion
- stakeholder demo / urgency reordering UI ahead of backend depth

### Authorship mode (curate interpretation)

Uses initiative `authorshipMode` — no separate curation mode field in v0.1.

| mode | curate behavior |
|------|-----------------|
| **default** | full proposal → level 2 when ambiguous → level 3 only for product decisions → **approve preview** |
| **manual** | co-design publication strategy; more level 3 acceptable for high-stakes initiatives |
| **autopilot** | agent runs synthesis autonomously — **still stops at approve preview**; implementation autopilot ≠ skipping communication ratification. Execute without preview requires explicit `--execute --confirm`, never silent inheritance |

Learning publication preferences from preview edits → post-v0.1.

---

## Optimize (in order)

When tradeoffs conflict, prefer higher items:

1. **Reviewer understanding** — will the narrative teach the right mental model?
2. **Merge safety** — flag-off legacy intact; flag-on coherent through course N; **smokes at
   course tip** (not at every intermediate shard)
3. **Narrative honesty** — never invent dependencies or hide why the system evolved; per course
   **watch for:** what wrong conclusion might a reader draw? (manual in v0.1; automated in v2)
4. **Conceptual cohesion** — one conceptual move per merge course; **reject leftover/hygiene
   courses** whose only job is residual wiring
5. **Minimal dependency depth** — shallow graph when honesty allows
6. **Discovery record** — lab branch + prep tree preserved; curation cites evidence
7. **LOC targets** — shards ~300 (max 500); merge courses ~2k (soft max ~3k)

LOC is a **constraint**, not the objective function.

### `--optimize` preset (executor + optional manifest)

Override tradeoff order when the operator specifies a goal. Read from, in order:

1. `/mep curate <slug> --preview --optimize <preset>`
2. `manifest.curationOptimize` (optional; persisted on approve)
3. default: `reviewer-comprehension`

| preset | when tradeoffs conflict, prefer… |
|--------|----------------------------------|
| **`reviewer-comprehension`** (default) | teaching order → merge safety → honesty → cohesion → depth → discovery record → LOC |
| **`merge-speed`** | merge safety → minimal depth → LOC → cohesion → teaching order → honesty → discovery record |
| **`earliest-value`** | operator/stakeholder-visible courses earlier (when gating allows) → merge safety → teaching order → honesty → depth → discovery → LOC |

Post-v0.1 presets (document only): `parallelism`, `release-risk`, `minimal-backport`.

CLI wiring for `--optimize` is post-v0.1; executor honors the preset from invocation or manifest today.

---

## Invariants

- **Narrative honesty.** Never separate concepts in a way that obscures why the system evolved.
  Never invent dependencies that did not exist. A beautiful PR that teaches the wrong model is a
  failure.
- **Lab branch sacred.** Never rebase or mutate the discovery branch.
- **Publication ≠ fabrication.** Integration history is **curated and reconstructed** for
  comprehension — inspired by discovery, not a replay of iteration SHAs. Discovery fidelity lives in
  the lab branch forever; integration fidelity means not mis-teaching the reviewer.
- **Shards are not develop merges.** Review shards are `stacked-only` unless gating evidence proves
  independence. Shard PRs need not be product-runnable; **course tips must be**.
- **A merge course is a trunk state you can run**, not a chapter heading with a LOC budget.
- **Merge playbook in publication.** Curated stack-of-shards efforts must record a default landing
  pattern (prefer **A: fold course → one trunk landing**) plus sync commands under
  `publication.mergePlaybook` and a `merge-playbook.md` operators can paste into PR bodies. Stage
  must stamp every shard PR with a **Merge** section — role, base, fold vs trunk, `gh stack sync`.

---

## Hard rules

- **Mergeability pass (mandatory):** architecture ship order, gating/stub plan, smoke closure **at
  each course tip**; `retrofitRequired` on monolith lab branches.
- **Shared-file ledger (preview):** every path touched by ≥2 courses must name an owning course tip
  (and allowed earlier stubs). Muddy ownership → merge courses or invent an explicit stub seam
  before execute.
- **No leftover courses:** reject MCs justified only as residual wiring / demo harness / package
  crumbs — fold into the last doctrine course or keep off the publication stack.
- **CI matches grain:** require full checks on **course-tip** PRs (and trunk). Do not force every
  intermediate shard PR to pass product smokes — that re-inflates shards into mini-courses.
- **`execute` writes publication history** on disposable integration branch(es); lab branch untouched.
- CLI (`mep curate measure | validate | execute`) handles git mechanics; **never** calls an LLM.

---

## Workflow

1. Read `.cursor/commands/prep-curate.md`.
2. Resolve **`curationOptimize`** preset (flag → manifest → default `reviewer-comprehension`).
3. Preflight: `tools/mep/bin/mep curate <slug> --json --preview`.
4. Read prep tree: manifest, iterations, invariant goal, architecture, reckoning, handoff.
5. **Distill evidence** — requirements, architectural decisions, discoveries (exploration only).
6. Git measure: `mep curate --json --measure` — LOC truth per path group (constraint, not headline).
7. **Mergeability pass:** AD ship order, gating/stubs, **course-tip** smokes, shared-file ledger,
   no leftover courses, `retrofitRequired`.
8. Preview: evidence → merge courses (trunk state first) → shard outline (one example per course max)
   → dependency DAG → **reviewer learning path** → **confidence report** → mergeability pass.
9. Apply **interaction policy**: state synthesis confidence (*considered whether to ask; concluded …*);
   level 2 alternatives if ambiguous; level 3 only for product decisions or thin prep.
10. On approval: write `integration-curation.md` + `integration-curation.json` (`draft` → `approved`);
    persist `curationOptimize` if set.
11. On **execute** (explicit gate): `--dry-run` then `--confirm`; record branches in artifact.
12. Hand off to `/mep stage`.

---

## Quality bar

Each **merge course** must answer four questions **in this display order** (trunk state leads; LOC is
last):

1. **Trunk after merge** — what new truth exists after this lands? (the field reviewers remember)
2. **Why now?** — conceptual justification citing R/AD/D ids (*exists because D3 and AD-4 become
   independently shippable once …* — not merely `dependsOn: MC-2`)
3. **Why not merged with previous?** — intentional boundary that leaves **both** course tips
   runnable (*separated because tip N−1 is coherent without N’s hunks* — not merely “concepts are
   independently reviewable”)
4. **~product LOC** — budget constraint only

Also: **concern** tag; optional **reviewer cognition**; per course **watch for:** (easy misunderstanding
if the reader stops at this course tip alone).

Each **review shard** is an **attention budget** — one conceptual step, ≤500 product LOC (target ≤300).
Shards may be progressive inside the course; they are **not** required to be independently runnable.

After the dependency DAG, emit **reviewer learning path** and **confidence report**:

```text
Synthesis confidence: autonomous | ambiguous | underdetermined

High confidence
  ✓ course boundaries · ✓ dependency graph · …

Medium confidence
  ⚠ MC-N sizing (open iteration incomplete)

Low confidence
  (none)

Alternatives considered
  Merge MC-N + MC-(N+1) — rejected because the concepts are independently reviewable.
```

See `wiki/plans/mep-curate-outline.md` for the full confidence-report contract and dogfood examples
in initiative prep briefs.
