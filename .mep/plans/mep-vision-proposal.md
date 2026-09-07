# MEP — mise-en-place for uncertain software work

**A proposal for a portable workflow runtime that tells humans and agents what to do next, who owns the decision, and what evidence justifies moving on.**

---

## The problem

Large features fail in predictable ways:

- **Over-planning** — weeks of architecture before the first merge, then the plan is wrong anyway.
- **Branch sprawl** — one long-lived diff that nobody can review, with planning notes that lag reality by thousands of lines.
- **Agent chaos** — AI assistants implement eagerly but leave no durable record of *what was decided*, *what was uncertain*, or *what gate was supposed to block the next step*.

The industry default is either "just ship" or "write a 40-page design doc." Neither scales when uncertainty is real and the team wants small, reviewable PRs with human authority over meaning.

---

## The idea

**MEP (mise-en-place)** treats software work like a kitchen prep line:

- The **human is the chef** — owns semantics and ratifies decisions that no pattern dictates; holds the final sign-off in every mode.
- The **agent is the sous** — mechanical prep, scoped implementation, staging, and audit fanout; in autopilot, a cross-model **proxy** occupies the chef seat slice-to-slice under policy, not the parent grading its own work.
- **Prep happens just-in-time** — plan only the next mergeable slice, ship it, checkpoint what you learned, plan the next slice.

The framework is not another task tracker or JIRA workflow. It is a **state machine plus artifact contract** that makes "where are we?" and "what's next?" answerable from persisted state — not from conversation memory, not from reconstructing history every time someone asks.

---

## Three outcomes (north star)

Every feature of MEP should serve at least one of these. If it serves none, defer it.

| Outcome | Question answered |
|---------|-------------------|
| **Next action** | What should happen now, and why? |
| **Responsibility** | Who is accountable — human, agent, or proxy? |
| **Trust** | What evidence shows the last step actually completed? |

Shell completions, rich ontologies, and analytics dashboards are enablers at best; they are not the product.

---

## Operator surface

Humans and agents should not memorize phases, slice statuses, or pipeline vocabulary. Plain verbs cover the lifecycle:

| Verb | Purpose |
|------|---------|
| `start` | Begin a new effort — greenfield prep, or recovery if the branch already has work |
| `next` | Do whatever comes next |
| `where` | Same as `next`, but read-only — see the step without running it |
| `mode` | Choose who authors — manual, default, or autopilot |
| `style` | Choose prep ceremony depth — `hash` or `house` (see below) |
| `stage` | Verify promised work and prepare the review stack |
| `done` | Graduate the effort when every slice has landed |

Under the hood, a portable command-line tool **composes workflow state** from the effort's prep artifacts, the repo, and in-code markers — then returns the **literal next step** (implement this brief, run a checkpoint, stage for commit, and so on). Cursor (or any IDE agent) is one way to execute those steps; the runtime itself is editor-agnostic.

---

## The forward loop (happy path)

```text
plan a slice → build it → land it (commit) → checkpoint → plan the next slice → … → graduate
```

Concretely:

1. **Macro prep** — classify core vs interchangeable, sequence mergeable iterations, produce the first slice brief (thickness depends on **prep style** — see below).
2. **Implement** — scoped to *one* brief; file ownership in the brief is exhaustive.
3. **Land the slice** — staged audit, then commit under the active **delegation policy** (see authorship modes). Manual and default block on a human at this gate; autopilot advances when proxy ratification and required **evidence** satisfy policy — non-blocking, not blind.
4. **Checkpoint** — sync planning artifacts to what shipped, update the roadmap, draft the next brief.
5. **Repeat** until all iterations are done.
6. **Graduate** — human sign-off on the retained audit trail (risk-tiered re-review for autopilot), strip process markers, final PR.

Planning artifacts live in a dedicated prep folder per effort. Product code never mixes with prep scaffolding in the same undifferentiated diff.

---

## Recovery path

When someone started coding before planning — or the branch outran its docs — MEP does not pretend everything is still in sync.

```text
recover (tidy) → checkpoint → forward loop
```

**Tidy** is forensic recovery: reckon WIP against reality, backfill missing prep artifacts, produce a commit plan. Docs only; no autonomous commits. After tidy, the effort rejoins the normal forward loop at checkpoint.

This is where **dynamic inference** earns its keep — but as an explicit tool you invoke when needed, not as the default way "what's next?" gets answered (see below).

---

## Authorship modes — delegation, not automation levels

Semantic governance (who owns meaning, invariants, ontology) is **always human**, fixed in prep, invariant across modes. What varies is **who authors decision-bearing code**, **who ratifies per slice**, and **what authority is required to land commits**.

| Mode | Who authors | Per-slice gate | Commit authority |
|------|-------------|----------------|------------------|
| **manual** | Human | Human (blocking) | Human only |
| **default** | Agent | Human (blocking) | Human only — today's common pattern, now named |
| **autopilot** | Agent (parent sous) + proxy (chef seat) | Cross-model proxy ratification (non-blocking) | Policy + evidence — proxy may land the slice when tests, finish-map, and provenance requirements pass; parent never self-ratifies |

All three modes read the **same plan** — same slice briefs, same finish-map, same acceptance criteria. Switching mode changes *who acts next* and *what authority is required to advance*, not *what gets planned*.

Decision-bearing fragments are tagged in code (`@finish:open → done → ratified`). Mechanical fragments follow cited patterns and may be marked `@mise`. The **finish-map** classifies every fragment as mechanical or decision-bearing; it is the audit trail that survives mode switches and interrupted autopilot runs. In autopilot, provenance records that ratification was rendered by a proxy, not a human — enough to advance the slice, **not** enough to graduate.

---

## Prep style — ceremony depth, not a second railway

Orthogonal to authorship **mode** (who authors / who gates). Prep **style** only changes how thick the ceremony is — never which stations exist, never the resolver sequence.

Kitchen read: **house** = cook the proper house plate by the full method; **hash** = compose from mise already on the board. Both are disciplined cooking. Hash is not freestyle, not "au pif," not a parallel framework.

| Style | Ceremony |
|-------|----------|
| **house** (default when unset) | Full MEP prep — belief inventory, roadmap as needed, normal checkpoint depth |
| **hash** | Thin ceremony — short core vs interchangeable inventory; as few iterations as merge-safety requires (often one); same verbs and `where` rows |

**Surface:** `start --hash` sets `style: hash`. `/mep style <slug> hash|house` switches. Prefer the enum in the manifest (`style`), not a lone boolean — `--hash` is sugar.

**Hash still does the belief split** (core certainties vs interchangeable elements). It strips banquet theater (long roadmaps, checkpoint-as-saga, curate-by-default), not the forward loop.

**Promote hash → house mid-flight:** flip `style`, then replan under the house bar.

- Prep still matches git → **`/prep checkpoint`** thickens existing artifacts (flesh out `03`, expand/split briefs).
- Branch outran docs → **`/tidy` → checkpoint** (recovery first, then house-grade forward plan).

Never: hash-only verbs, a second next-command table, or "style switch always means tidy."

---

## State machine architecture

The core design bet: **"what's next?" should read explicit workflow state**, not re-derive it from git history every time someone asks.

### Where state lives — org-mode-shaped

State lives **on the nodes** of the prep tree, not in a separate summary file that duplicates them.

- Each **slice brief** carries its own status, ownership, and acceptance contract.
- The **roadmap** sequences slices and records what became trustworthy at each checkpoint.
- **In-code markers** record open decisions and authorship at the point of work.
- **Git** records what actually landed; the **event log** records what the runtime decided.

The runtime **walks these artifacts and composes** a routing view. That avoids the chronic failure mode where a central index disagrees with the brief files on disk. **Infer** and **doctor** reconcile the tree when composed views disagree.

### Layer 1 — Composed explicit state (default for routing)

Each slice progresses through recorded phases, for example:

```text
not planned yet → plan ready → code landed → planning synced → committed → merged
```

Those transitions are written only by trusted steps — checkpoint sync after a commit lands, finish ratification, or a repair tool applying changes git can prove. The runtime does not let agents self-report "done" without evidence.

The **`where`** command reads this composed layer first and folds in mode-specific steps (human authorship, proxy dispatch, commit approval) into **one** answer — not a separate report the operator has to merge manually.

### Layer 2 — Operational reads (cheap, always on)

Uncommitted changes (planning docs vs product code), open decision markers, the active delegation mode, and prep style (`hash` | `house`). These distinguish "stage and commit" from "run checkpoint" without digging through commit history. Style changes ceremony expectations, not which resolver stations exist.

### Layer 3 — Forensic inference (explicit invoke only)

When composed state and the branch disagree — or when recovery needs a seed — a dedicated **infer** command reconstructs what probably happened and attaches evidence:

- Was this slice actually built after its plan was written?
- Do brief files on disk agree with the roadmap on what is next?
- Is the recorded checkpoint stale relative to current commits?
- Has work merged to main even though planning artifacts still say "committed"?

Inference is **read-only**. It never picks the next step. It never silently rewrites planning artifacts.

**Doctor** runs infer, compares the result to the composed view, and reports mismatches. With an explicit repair flag, it may apply only **low-ambiguity fixes** git can prove (for example, promoting a slice to "merged" when main already contains the branch). Wrong claims are surfaced for human judgment, never auto-cleared.

When **`where`** sees planning state is inconsistent, it sends you to **doctor first** — it does not guess "you must be ready for checkpoint" by scanning commit logs on the fly.

```text
                    ┌─────────────┐
  happy path ──────►│    where    │──────► next step
                    └──────▲──────┘
                           │ composes
                    ┌──────┴──────────────────┐
                    │ briefs + roadmap +      │◄── checkpoint / ratification / doctor repair
                    │ markers + git           │
                    └──────▲──────────────────┘
                           │ compares
                    ┌──────┴──────┐
  recovery/tidy ───►│   infer     │
  doctor ──────────►│ (forensic)  │
                    └─────────────┘
```

Keeping inference out of the default path is what keeps routing stable: drift detection is a separate concern from "what should I do next on a healthy branch."

---

## Artifacts

| Artifact | Role |
|----------|------|
| Prep tree (briefs + roadmap) | Primary state — each node carries its own status, scope, and checkpoint learnings |
| Slice briefs | Scoped implement contract — acceptance criteria, file ownership, what is still uncertain |
| Finish-map | Per-slice list of mechanical vs decision-bearing work |
| In-code markers (`@finish`, `@mise`) | Decision and authorship state at the point of work; stripped at graduation |
| Git | Ground truth for what landed; reconciled against planning artifacts |
| Local event log | Observability — what the runtime decided and when; history, not routing input |
| Execution request | Neutral packet describing work to perform, required authority, and required evidence |
| Evidence packet | Proof returned after work — diff, tests, finish-map, provenance — validated before advance |
| PR bodies / review stack | Presentation for reviewers; separate from the critical next-step path |

---

## Gates

### Universal (every mode)

- **Semantic governance is human** — meaning, ontology, and irreversible product decisions are owned by the operator; the framework never cedes them to automation.
- **Human graduation** — stripping process markers, exporting the effort, and merging the final PR are explicit human gates. Autopilot runs slice-to-slice without blocking on a human, but **never through graduation** — the driver gets out of the car.
- **Evidence before trust** — advancing state requires an evidence packet (tests, diff scope, finish-map completeness, provenance) that policy can validate. "Non-blocking" is not "no proof."
- **No self-ratification** — the parent agent never approves its own autopilot work; proxy ratification is cross-model and recorded.
- **No planning leakage in product code** — automated checks block prep scaffolding, iteration handles, and framework vocabulary from landing in shipped code paths.
- **Docs lead code on the happy path** — when planning notes fall behind the branch, drift is flagged explicitly rather than ignored.

### Delegation-dependent (varies by mode)

- **Per-slice commit** — manual and default require a human at the merge gate. Autopilot delegates commit authority to the policy runtime when evidence satisfies the active authorization bundle; the runtime emits an execution request, an executor performs the commit, and history records the outcome.
- **Per-slice finish ratification** — manual: human authors and ratifies. Default: human ratifies before advance. Autopilot: proxy ratifies with recorded provenance; human re-ratifies semantic/foundational finishes at graduation, spot-audits the remainder.

---

## Portability

MEP is a **product**, not a single-editor plugin. Six composable layers:

```text
Policy → Runtime → Execution request → Executor → Evidence → History
```

| Layer | Role |
|-------|------|
| **Policy** | Authority and evidence rules — manual, default, and autopilot are policy bundles, not executor choices |
| **Runtime** | Composes explicit state from prep artifacts + git + markers; emits deterministic transitions — where, checkpoint, doctor, infer, lifecycle, events |
| **Execution request** | Neutral work packet the runtime emits when policy allows an effect |
| **Executor** | Human, IDE agent, shell, CI, or future agent that performs the request |
| **Evidence** | Proof the executor returns; policy validates before the runtime advances phase |
| **History** | Event log and git — auditable record of what happened |

Editor integrations translate runtime output into steps the operator can run. A single human-readable routing contract defines how state maps to next steps — so the logic is not duplicated across skill files. Any environment can invoke the same JSON API and follow equivalent procedure prose.

---

## Deliberately out of scope

- Inferring which effort you're working on from free text alone
- **Ungoverned** autonomy — commit, push, or merge without policy authority, evidence validation, and recorded provenance (autopilot's governed commit path is in scope; rubber-stamping is not)
- Analytics dashboards or query languages over the event log
- Rich epistemic tag taxonomies beyond what slice briefs need
- The "human types, AI approves" corner of the governance grid — intentionally empty
- Treating **hash** as ungoverned improvisation — thin ceremony on the same rail is in scope; a second lifecycle is not

---

## Why build this

**For humans:** One question — "what now?" — with an answer that survives digressions, context resets, and handoffs between sessions.

**For agents:** A bounded implement surface (one brief, exhaustive ownership) and explicit gates so eager automation does not skip decisions or pollute the branch.

**For teams:** Reviewable PR rhythm on uncertain work, with an audit trail that distinguishes mechanical code from human-owned choices — across manual, default, and autopilot delegation policies.

**For maintainers:** Routing rules stay small and stable because git reconstruction lives in infer and doctor, not in ever-growing special cases inside "what's next?"

---

## Success looks like

- `where` returns one concrete next step that reflects the active mode — human authorship in manual, human blocking gates in default, proxy dispatch and evidence-gathering in autopilot.
- Composed planning state and branch reality disagree → a clear repair report, not a wrong next step.
- Recovery seeds from structured inference, not ad-hoc archaeology every time a branch is messy.
- Routing rules change rarely; inference heuristics can evolve independently.
- An operator who has never read internal docs can drive an effort with the plain verbs (including `mode` and `style`) and trust the gates.

---

## Summary

MEP is **mise-en-place for software**: plan the next plate, cook it, plate it, learn, prep the next plate. The chef owns meaning and graduation; the sous (and, in autopilot, a cross-model proxy) stays in scope slice-to-slice.

The implementation is a **portable state machine** that composes workflow state from distributed prep artifacts, routes mode-aware next steps, runs forensic inference on demand, validates policy-driven authority and evidence, and holds a human graduation backstop — so "what's next?" is always answerable, always justified, and always someone's job.
