# Iteration roadmap — mep-v0-graduation

**Phase:** 4  
**Status:** approved  
**Builds on:** Epic #85 definition of done; archive synthesis (2026-06-19)

Merge philosophy: **merge uncertainty reduction toward v0.1.0**, not feature sprawl.

Foundation strategy: **extract → unix foundation → everything else → v0.1.0**. Full Unix compliance
is not post-release polish; it is the **substrate** resolver, workflow closure, and adapters build on.
Building features on cursor-shaped `nextCommand` strings compounds migration cost.

v0.1.0 ships from the **standalone repo** only after the **shell litmus** passes.

Milestones:

- **Milestone 0 — self-host bootstrap:** iteration 0 (new repo skeleton; CI; neutral layout).
- **Milestone U — unix foundation (v0.1 blocker):** iterations 1–4 (command contract, executor-neutral
  routing, workflow CLI primitives, pipe litmus).
- **Milestone A — boring resolver:** iteration 5 (golden matrix + totality).
- **Milestone B — closed workflow:** iterations 6–8 (manual, autopilot, markers).
- **Milestone C — product hardening:** iterations 9–14 (install, policy, observability, curation, integration curation, pilot).
- **Milestone R — release:** iteration 15 (v0.1.0 + Sator Square).

Shortcut epic: **#85**. Each iteration maps to one backlog story.

### Ledger after iteration 0 (this remote)

Git-proven or checkpoint-closed `committed` on this initiative: **0, 1, 13, 14**. **2–12, 15, 16** remain pending.

| iter | git vs promise |
|------|----------------|
| 0 | closed at checkpoint — extract lives on `tvanmaren/mep` (`8ae1f24`); stranger CI green; no post-brief implementation SHA (founding commit bundled brief + tree) |
| 1 | committed — `b0886e5`; envelope + exit map; `run-unix-contract.sh` |
| 2–12 | not satisfied — no `executionRequest`; no slice-boundary litmus |
| 13 | committed — curate preview/execute on fixture (`954828bdd`) |
| 14 | committed by owned-path history (`64802ec14` curate docs); **pilot report never created** |
| 15 | forbidden until iter 4 litmus in the **standalone** repo |
| 16 | post-v0.1 |

**Next implement:** iteration **2** (executor-neutral routing). Not 15.

### Coverage (C\* / I\* → iteration)

| id | home |
|----|------|
| C1–C5 | 13 (locked); 15 must not regress |
| C6 | 0 (core lock) |
| C7 | 1 (core lock) |
| I1–I3 | 13 skeleton; hydration skip-unless-gated |
| I4 | 5 (golden matrix) — do not treat as slice-14 proof |
| I5–I6 | 0 skeleton (finishes, not identity) |
| I7 | 1 (seed paths / scaffolding flag tactic) |

---

## Executor & adapter model (cross-cutting)

MEP is **maximally platform-agnostic** at the runtime layer and **minimally configured** at the
executor layer:

| layer | owns | does not own |
|-------|------|--------------|
| **runtime** | `executionRequest`, evidence validation, routing | API keys, prompts, vendor SDKs |
| **executor adapter** | dispatch to cursor / claude / codex / … | manifest semantics, resolver rows |
| **stub executor** | CI litmus — replays canned classification + diff | product operator path |

**User setup (v0.1 target):** pick a preset in `.mep/config`, optional bare-minimum overrides (binary
path, env profile name) — not a framework config dump. Iteration 3 includes an **adapter audit**
(canonical presets, override schema, getting-started doc).

**Authorship modes (unchanged):** `manual` | `default` | `autopilot` — all assume an LLM-capable
executor for classification, `@mise` boilerplate, audit, and (in autopilot) sub-agents. **Manual is
the human-facing floor**, not "no LLM."

---

## Iteration 0 — Repo extract & self-host bootstrap (GATE)

**Goal:** Move MEP to its own FOSS repo and prove it can dogfood itself there — without depending on
host's `.cursor/commands/implement-plan.md` (the host product TDD, smoke tests, frontend cycles).

**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/00-repo-extract-self-host-bootstrap.md`

**Slice type:** architectural  
**Epistemic transition:** MEP moves from embedded host concern to standalone product that eats its own cooking.  
**Irreversible decision:** the new repo is the canonical home; host retains only a consumer adapter/profile.  
**Maturity target:** embedded → provisional (standalone)

**Why this gates everything else:** resolver fixes, workflow closure, and v0.1.0 release all assume a
repo whose skills are **MEP-native**, not host-coupled. Dogfooding `mep-v0-graduation` in-place in host
would keep lying about portability.

**Approach — extract shell:**
- Publish a **new remote** (`https://github.com/tvanmaren/mep`) from the MEP path set. Second publish: host pointer only. No consumer wiring. No host history rewrite. Copied from host `ucg@31cf767ca5131c9559f2d33a09926da091e2af2c`.
- Stranger CI: temp root, no config, `run-stranger.sh` + `.mep/prep/fixture-demo` (engine storage defaults).
- FOSS `.mep/config`: Cursor `runtime.*` plus `vcs.defaultTrunk=master` (this repo's trunk). Never copy host `storage.prepRoot=wiki/prep` or `a host profile.active`. Engine default trunk stays `main`.
- Relocate this initiative to `.mep/prep/mep-v0-graduation/` (narrow `ownedPaths`). Further slices run there.
- LICENSE MIT; CLI `mep`. Docs: prep paths = configured `storage.prepRoot` (default `.mep/prep`).

**Avoid:** copying host orchestration wholesale; implementing unix foundation here (that's iterations 1–4).

**Checkpoint:** standalone repo exists; CI green on current test suite; `mep where` runs headlessly.

**Status:** committed — `iterations/00-repo-extract-self-host-bootstrap.md` (`8ae1f24`; human-closed at checkpoint)

---

## Iteration 1 — Unix command contract (GATE)

**Goal:** Every machine-facing command shares one shell contract: `--json` stdout envelope, stderr for
usage/diagnostics, **exit codes aligned with JSON status**, help/version, command registry as source of truth.

**Brief:** `iterations/01-unix-command-contract.md`

**Slice type:** architectural  
**Epistemic transition:** MEP becomes scriptable with `set -e`, not jq-only branching.  
**Irreversible decision:** exit-code taxonomy is public API; breaking it is semver-major.

**Approach:**
- Command registry (help, tests, docs derive from one table).
- `mep help`, `mep version`; usage on stderr; success silent on stderr.
- Map JSON `status` → exit: `ok/clean` 0; `desync/gated/warning` 1; `blocked/missing_dependency` 2;
  `not_found` 3; usage 64; internal 70 (exact table in brief).
- Convert `check scaffolding` to `--json` or subcommand with same envelope.
- Conformance tests: stderr empty on success; exit codes on fixture packets.

**Checkpoint:** `tools/mep/test/` includes an exit-code + stderr discipline suite (FOSS; not host `run.sh`).

**Status:** committed — `iterations/01-unix-command-contract.md` (`b0886e5`)

---

## Iteration 2 — Executor-neutral routing

**Goal:** `where --json` emits **shell-invokable** `executionRequest` packets — not cursor slash commands.
`nextCommand` becomes adapter convenience or aliases the primary request.

**Brief:** `iterations/02-executor-neutral-routing.md`

**Slice type:** architectural  
**Epistemic transition:** runtime stops leaking adapter vocabulary into the public API.  
**Irreversible decision:** durable field is `executionRequest`; slash commands are optional presentation.

**Approach:**
- `executionRequest`: `{ kind, target, argv }` only. kinds from resolver **row**: `implement` | `checkpoint` | `commit_prep` | `prep` | `cleanup` | `none`.
- Rows 7–8: `kind: implement`, `target` = brief path, `argv` = `[briefPath]`.
- `commit_prep` argv distinguishes `docs-bootstrap` / `docs-delta` / bare commit-prep. no `kind: evidence`.
- FOSS tests lock packet shape. vendor invoke mapping is iteration 3.

**Avoid:** embedding cursor slash commands as the durable contract; executor classes / authority fields.

**Checkpoint:** `mep where <slug> --json | jq .executionRequest` is sufficient for a shell driver.

**Status:** brief_ready — `iterations/02-executor-neutral-routing.md`

---

## Iteration 3 — Workflow CLI primitives & executor adapters

**Goal:** Close the workflow loop at the CLI boundary and ship a **minimal executor adapter config**
— platform-agnostic runtime, user picks a preset, done.

**Brief:** `iterations/03-workflow-cli-primitives.md`

**Slice type:** behavioral  
**Epistemic transition:** lifecycle is representable in shell; LLM work flows through configured executors, not runtime internals.

**Approach — runtime primitives:**
- `mep mode set <slug> <mode> --json` (`manual` | `default` | `autopilot` only).
- `mep implement --json <briefPath>` — read-only scope/constitution packet (runtime); fulfillment is executor job.
- `mep exec dispatch --json [--executor auto|<preset>]` — hand `executionRequest` to configured adapter.
- `mep commit scope <slug> --json`, `mep evidence write --json`, cleanup/graduation packets.
- Uniform `--dry-run` on effectful commands where applicable.

**Approach — adapter surface (minimal setup):**
- `.mep/config` → `executors.default`, `executors.presets.<name>` (kind, command, env hints — no secrets).
- Ship documented presets after **adapter audit** (cursor, claude-code, codex, stub; extensible registry).
- Overrides: binary path, profile name, timeout — not prompt bodies or API keys in MEP config.
- `adapters/README.md`: "pick preset → optional one-line override → run."

**Avoid:** MEP storing API keys; vendor logic in `tools/mep/lib/resolver.sh`; a human-as-classifier "solo" mode.

**Checkpoint:** each resolver row maps to ≥1 CLI primitive or evidence write; `mep exec dispatch --executor stub` works; adapter audit doc lands.

**Status:** pending

---

## Iteration 4 — Shell litmus & pipe harness

**Goal:** Prove Unix compliance in CI using **`--executor stub`** — a test double that replays canned
classification, diffs, and markers. **Not** a claim that humans replace LLM work.

**Brief:** `iterations/04-shell-litmus-pipe-harness.md`

**Slice type:** architectural  
**Epistemic transition:** unix compliance moves from doctrine to executable gate.  
**Irreversible decision:** `scripts/litmus/slice-boundary.sh --executor stub` is required CI for v0.1.0.

**Approach:**
- Pipe recipes in test suite: `mep where … | jq … | xargs mep exec dispatch …`.
- Litmus: where → executionRequest → **stub executor** → evidence → commit scope → checkpoint → where.
- Optional local smoke (non-CI): `--executor cursor` or other preset when user has credentials.
- README: runtime-first loop; executor preset as step 2 of getting started.

**Litmus test (v0.1 CI gate):**

```bash
# proves plumbing — stub replays LLM outcomes; NOT a no-LLM product path
scripts/litmus/slice-boundary.sh --executor stub prep/fixture-demo
```

**Checkpoint:** litmus passes in standalone repo CI; epic unix DoD satisfied.

**Status:** pending

---

## Iteration 5 — Resolver totality & golden matrix

**Goal:** Strip the resolver of bugginess — total routing, documented evaluation order, revision-triplet
landed detection, golden coverage for every row + recovery path.

**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/05-resolver-totality-golden-matrix.md` (draft at slice start)

**Slice type:** architectural  
**Epistemic transition:** resolver moves from dogfooding-discovered misroutes to contract-tested totality.  
**Irreversible decision:** evaluation-order table in glossary is the spec; `resolver.sh` must match.  
**Maturity target:** provisional → stable

**Approach:**
- Extend `tools/mep/test/run.sh` to cover rows 1–11 + row-10 precedence + row-11 recovery + row-5 docs-delta interstitial.
- Eliminate fragile heuristics that send landed slices back to `/implement-plan`.
- Align `glossary.md` evaluation order with `resolver.sh` or fix the code.

**Avoid:** new lifecycle features; adapter rewrites; net-new inline git fallbacks beyond fixing proven misroutes (golden matrix locks **v0.1 transitional** routing — v0.2 demotes git from the default path; see `.mep/plans/mep-v0.2-outline.md`).

**Checkpoint:** `/mep where` on fixture slugs never disagrees with golden expectations; dogfood notes empty.

**Status:** pending

---

## Iteration 6 — Manual mode workflow closure

**Goal:** Manual mode stops at finishes, prompts the human to fill the remainder, and **never** claims
the slice is done while `@finish:open` remains.

**Slice type:** behavioral  
**Epistemic transition:** manual execution becomes honest about incompleteness.  
**Irreversible decision:** incompleteness is gated by marker grep + status packet, not LLM self-report.

**Checkpoint:** manual fixture initiative completes human-fill loop; status blocks commit with open finishes.

**Status:** pending

---

## Iteration 7 — Autopilot ratification path

**Goal:** Autopilot proxy ratification + commit path runs without bouncing every gate to the human
conversant (within configured policy).

**Slice type:** behavioral  
**Epistemic transition:** autopilot moves from prototype to alpha-capable for trusted slices.

**Checkpoint:** autopilot fixture runs slice boundary without manual commit/review prompts where policy allows.

**Status:** pending

---

## Iteration 8 — Mechanical authorship markers

**Goal:** `@mise` / `@finish:<state>` emitted by tooling or execution policy — not optional LLM discipline.

**Slice type:** behavioral  
**Epistemic transition:** authorship markers move from planned to mechanically enforced.

**Checkpoint:** agent-generated diffs receive `@mise` wrappers; finish states advance on save or explicit ratification.

**Status:** pending

---

## Iteration 9 — Install path & stranger smoke test

**Goal:** A stranger clones, installs `mep`, picks **one executor preset**, and completes one small
initiative — minimal config, no MEP-hosted keys.

**Slice type:** behavioral  
**Epistemic transition:** getting started is preset + optional override, not dotfile archaeology.

**Checkpoint:** documented install; smoke script passes with `--executor stub` (CI) and documented path
for at least one real preset (e.g. cursor); stranger guide ≤5 setup steps.

**Status:** pending

---

## Iteration 10 — Runtime ≠ policy hardening

**Goal:** One lifecycle in code and docs; manual/default/autopilot differ only in who acts and who ratifies.

**Slice type:** architectural  
**Epistemic transition:** policy/runtime boundary becomes test-guarded, not prose-only.

**Checkpoint:** regression tests prove mode changes do not alter resolver rows; docs state the three-layer model.

**Status:** pending

---

## Iteration 11 — Lifecycle observability completion

**Goal:** Close event-coverage gaps — meaningful transitions emit machine-readable events; `--json` proof
separate from human reason across where/status/checkpoint/finish scan.

**Slice type:** behavioral  
**Epistemic transition:** observability matches the runtime spine (Milestone A from runtime-evolution).

**Checkpoint:** event ledger covers resolver, checkpoint, lifecycle, review validation; reads filter correctly.

**Status:** pending

---

## Iteration 12 — Curation externalized (authoring taste)

**Goal:** Taste lives in CONTRIBUTING, examples, and profile seeds — stranger can follow without author context.

**Slice type:** consolidation  
**Epistemic transition:** framework **authoring** curation moves from author memory to repo artifacts.

**Checkpoint:** CONTRIBUTING + 2–3 canonical examples; glossary/resolver table is the routing contract.

**Status:** pending

---

## Iteration 13 — Integration curation (`/mep curate`)

**Goal:** Lossy-compress discovery into **review narrative** on **integration branch(es)** with **publication commits** — without rebasing the lab branch.

**Brief:** `iterations/13-integration-curation.md`  
**Outline:** `.mep/plans/mep-curate-outline.md`  
**Shortcut:** sc-102

**Slice type:** behavioral  
**Epistemic transition:** MEP gains an integration phase between execution and merge.  
**Irreversible decision:** v0.1 ships **`preview` + `execute`** — plan then publication branches.

**Approach:**
- `/mep curate <slug> --preview` → `wiki/prep/<slug>/integration-curation.md`
- `/mep curate <slug> --execute` → integration branch(es) + publication history
- `/mep stage` reads approved curation plan + integration branches

**Blocked by:** iteration 3 (stage/workflow CLI), iteration 12 (CONTRIBUTING).

**Checkpoint:** curate preview + execute on fixture landed (`954828bdd`). txn-adjustment dogfood → iter 14.

**Status:** committed

---

## Iteration 14 — Default mode end-to-end pilot

**Goal:** Exercise default authorship on a real pilot initiative: brief → implement → commit-prep → checkpoint → next slice. **Includes txn-adjustment-revamp curate (preview → execute) → stage** when initiative reaches merge boundary.

**Brief:** `iterations/14-default-mode-pilot.md` (draft at slice start)

**Slice type:** behavioral  
**Epistemic transition:** default mode proven on non-fixture slug; long-initiative merge path dogfooded.

**Status:** committed — git owned-path landing `64802ec14`; promised `pilot-default-mode-report.md` **absent**. Do not backfill on this host branch; extract (0) is the next certainty move.

---

## Iteration 15 — v0.1.0 release package (incl. Sator Square)

**Goal:** Honest public release — README (ownership model, one canonical workflow, open roadmap), LICENSE,
CONTRIBUTING, tag **v0.1.0**. **Hard gate:** README footer contains exact Sator Square block.

**Brief:** `iterations/15-v010-release-package.md` (draft at slice start)

**Slice type:** cleanup  
**Epistemic transition:** MEP graduates from private thesis to FOSS v0.1.0 with honest scope table.

**Sator Square (required footer):**

```text
S A T O R
A R E P O
T E N E T
O P E R A
R O T A S
```

**Checkpoint:** v0.1.0 tagged; epic #85 DoD checkboxes satisfied; Sator Square present in README.

**Status:** pending

---

## Iteration 16 — Document-colocated workflow state (post-v0.1)

**Goal:** Eliminate `manifest.json`. Checkpoint writes brief frontmatter; resolver reads initiative +
brief documents + git. Same routing semantics as iteration 5 golden matrix.

**Shortcut:** sc-101  
**Brief:** `iterations/16-document-colocated-workflow-state.md` (draft at slice start)

**Slice type:** architectural  
**Epistemic transition:** transitional manifest retires; plan documents are the workflow ledger.  
**Blocked by:** v0.1.0 tag (15) + golden matrix (5).

**Not a v0.1 gate.** v0.1 ships the authoring contract (0, 12) and transitional manifest.

**Status:** pending

---

## Dependency order

```
0 (extract + document authoring contract)
  → 1 → 2 → 3 → 4   # unix foundation — v0.1 substrate; blocks all product work
  → 5                 # resolver totality (semantic; storage-agnostic tests)
  → 6,7,8 (parallel)  # workflow closure
  → 9 → 10,11 (parallel) → 12 → 13 → 14 → 15
  → 16 (post-v0.1)    # eliminate manifest; document-colocated state → v0.2.0 program (`.mep/plans/mep-v0.2-outline.md`)
```

Iterations 1–15 execute in the **standalone repo**. **v0.1.0 (15) is forbidden until litmus (4) passes.**

## Fanout eligibility

| Iterations | Parallel? | Reason |
|------------|-----------|--------|
| 6, 7, 8 | yes after 5 | disjoint policy surfaces; unix+routing frozen |
| 10, 11 | yes after 9 | docs/tests vs events.sh |

## Re-plan triggers

- Litmus reveals missing primitive → return to iteration 3 before resolver/workflow work.
- Exit-code contract churn → freeze iteration 1 before iteration 2+.
- Resolver golden matrix reveals table redesign → iteration 5 only; do not patch adapter-shaped routes.
