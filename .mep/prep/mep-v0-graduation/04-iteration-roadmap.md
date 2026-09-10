---
mepSlug: mep-v0-graduation
mepPhase: 5
mepPrepDocsBootstrapped: true
mepHandoffApproved: false
mepInitiativeStatus: graduated
mepAuthorshipMode: default
mepCurrentIteration: 17
mepOwnedPaths: ["tools/mep/**",".cursor/skills/mise-en-place/**",".cursor/commands/mep.md",".cursor/commands/prep.md",".cursor/commands/prep-cleanup.md",".cursor/commands/prep-curate.md",".cursor/commands/prep-pr-description.md",".cursor/commands/prep-stage.md",".mep/prep/mep-v0-graduation/**",".mep/plans/mep-curate-outline.md"]
mepMasterPlanPath: .mep/prep/mep-v0-graduation/04-iteration-roadmap.md
---

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

### Ledger after v0.1.0

**15 tagged at `66373b3` (`v0.1.0`, signed).** **15b** landed post-tag (`2aa8a7c`). **16** committed (`8a738e4`). **17** committed (`09f8e54`). **program closed** — A2+ lives on `.mep/plans/mep-v0.2-outline.md` as a new epic, not this slug.

Git-proven or checkpoint-closed `committed` on this initiative: **0–14** (14's promised `pilot-default-mode-report.md` **absent** — deviation, do not backfill here). **11** and **12** landed (`8408fda`, `8af941f`).

| iter | git vs promise |
|------|----------------|
| 0 | closed at checkpoint — extract lives on `tvanmaren/mep` (`8ae1f24`); stranger CI green; no post-brief implementation SHA (founding commit bundled brief + tree) |
| 1 | committed — `b0886e5`; envelope + exit map; `run-unix-contract.sh` |
| 2 | committed — `210c716`; row-derived `executionRequest` |
| 3 | committed — `cafdc858`; `exec dispatch` + stub + workflow verbs; command presets fail closed |
| 4 | committed — `051df03`; `scripts/litmus/slice-boundary.sh --executor stub` on stranger CI |
| 5 | committed — `8e4d880` named context + goldens; checkpoint session `a0cecb8` (`--fix` blocked on I11; triplet uses impl SHA) |
| 5b | committed — `f749db1` comment grammar; brief `a0cecb8`; close `46895d9` (manifest number 5.1) |
| 6 | committed — `bb41b68` fail-closed manual `commit scope`; trap hygiene `2f937b7` (`--fix` SHA) |
| 7 | committed — `092ade7` autopilot `commit scope` fail-closed (mode parity, not a proxy runtime) |
| 8 | committed — `84aa6e8` deterministic `mep mark` writer (whole-file `@mise` + monotonic finish `--state`) |
| 9 | committed — `2f6a514` README Start here (repo-bin + stub loop); brief `6cc901b` |
| 9b | committed — `52bb530` mode-agnostic finish readiness; brief `1f4ed1e` (impl preceded brief) |
| 10 | committed — `50d76f6` unblocked `where` packet identity; brief `1f4ed1e`; docs sentence waived |
| 11 | committed — `8408fda` emit+tail suite; writers already existed |
| 12 | committed — `8af941f` CONTRIBUTING + examples; brief `1e8df26` |
| 13 | committed — curate preview/execute on fixture (`954828bdd`) |
| 14 | committed by owned-path history (`64802ec14` curate docs); **pilot report never created** — debt closed by **15b** (post-tag; 14's own "14b" was curate dogfood, a different fragment) |
| 15 | tagged `v0.1.0` at `66373b3`; brief `43fff44`; checkpoint `1d6bb8f`; 01 success #3 **not** claimed |
| 15b | committed — `2aa8a7c` public report + README citation; brief `4b3b893`; `--fix` checkpointRevision was pre-amend product `5b37dd8` — stripped pending docs-delta |
| 16 | committed — `8a738e4`; document-native authority + `mep migrate`; live sidecar retirement is docs-delta |
| 17 | committed — `09f8e54`; persistence primitives in `document.sh`; resolver is rows only |

**Next implement:** none on this slug. graduate. v0.2 A2/B/C/D wait for a new initiative.

**Skin order (operator 2026-09-09):** grok TUI first, then Cursor marketplace, then Claude. Skins are generated adapters over PATH `mep`; they do not own the resolver.

**Why no live driver yet (asked 2026-09-09):** manual and default are already agent-usable — a harness drives the CLI from outside via `portable-routing.md`, which is how every slice here was built. Only **autopilot** structurally needs `mep` to spawn an executor. That is v0.2 **D0**, sequenced after 16 so the evidence loop reads document-native state once.

### Coverage (C\* / I\* → iteration)

| id | home |
|----|------|
| C1–C5 | 13 (locked); 15 must not regress |
| C6 | 0 (core lock) |
| C7 | 1 (core lock) |
| C8 | 2 (core lock) |
| C9 | 3 (core lock) |
| I1–I3 | 13 skeleton; hydration skip-unless-gated |
| I4 | 5 (golden matrix) — do not treat as slice-14 proof |
| I5–I6 | 0 skeleton (finishes, not identity) |
| I7 | 1 (seed paths / scaffolding flag tactic) |
| I8 | 5 (resolver arity) — **done** in `8e4d880` |
| I11 | 5b — **done** in `f749db1` |
| I12 | 8 (`mep mark` comment-style map) |
| I13 | 9 (README stranger start) |
| I9 | 3 (spellings / overlay labels) |
| C10 | 4 (core lock) |
| C11 | 9b (core lock) |
| I10 | 4 (CI/fixture tactics) |
| I14 | 9b (open-marker helper spellings) |
| I15 | 10 (unblocked `where` mode-loop suite) |
| I16 | 11 (emit+tail suite path) |
| I17 | 12 (CONTRIBUTING + examples) |
| I18 | 15b (`tools/mep/docs/pilot-default-mode.md`) |
| C12 | 16 (core lock) |
| I19 | 17 — **done** in `09f8e54` (`document.sh`) |

---

## Executor & adapter model (cross-cutting)

MEP is **maximally platform-agnostic** at the runtime layer and **minimally configured** at the
executor layer:

| layer | owns | does not own |
|-------|------|--------------|
| **runtime** | `executionRequest`, evidence validation, routing | API keys, prompts, vendor SDKs |
| **executor adapter** | dispatch to cursor / claude / codex / … | manifest semantics, resolver rows |
| **stub executor** | CI / FOSS test double — accept/block on a valid `executionRequest` | product operator path; canned LLM replay |

**User setup (v0.1 target):** pick a preset in `.mep/config`, optional bare-minimum overrides (binary
path, env profile name) — not a framework config dump. Iteration 3 shipped the **adapter audit**
(canonical presets, override schema, getting-started sentence).

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

**Status:** committed — `210c716`

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

**Status:** committed — `cafdc858`

---

## Iteration 4 — Shell litmus & pipe harness

**Goal:** Prove Unix compliance in CI by **composing public `mep` verbs** against `--executor stub`.
Not a claim that humans replace LLM work; not a canned classifier inside the harness.

**Brief:** `iterations/04-shell-litmus-pipe-harness.md`

**Slice type:** architectural  
**Epistemic transition:** unix compliance moves from doctrine to executable gate.  
**Irreversible decision:** `scripts/litmus/slice-boundary.sh --executor stub` is required CI for v0.1.0.

**Approach:**
- Pipe recipes: `mep where … | jq -c .executionRequest | mep exec dispatch --json --executor stub`.
- Litmus walk (temp workspace, not the committed fixture tree): where → dispatch stub → evidence write → commit scope → checkpoint → where.
- Litmus **only composes** `mep` verbs shipped in iter 3. if a packet is still missing, this slice extracts it as CLI — it must not hide product functions in `scripts/litmus/`.
- Optional local smoke (non-CI): `--executor cursor` or other preset when the operator has credentials.
- Docs: one getting-started sentence that the runtime loop is `where` → `exec dispatch`.

**Litmus test (v0.1 CI gate):**

```bash
# proves plumbing — stub accept/block; NOT a no-LLM product path
scripts/litmus/slice-boundary.sh --executor stub
```

**Avoid:** inventing commit-scope / evidence-write as harness internals; live-vendor CI; I8 arity collapse.

**Checkpoint:** litmus passes in standalone repo CI; epic unix DoD satisfied.

**Status:** committed — `051df03`

---

## Iteration 5 — Resolver totality & golden matrix

**Goal:** Strip the resolver of bugginess — total routing, documented evaluation order, revision-triplet
landed detection, golden coverage for every row + recovery path.

**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/05-resolver-totality-golden-matrix.md`

**Slice type:** architectural  
**Epistemic transition:** resolver moves from dogfooding-discovered misroutes to contract-tested totality.  
**Irreversible decision:** evaluation-order table in glossary is the spec; `resolver.sh` must match.  
**Maturity target:** provisional → stable

**Approach:**
- Golden suite in FOSS: `tools/mep/test/run-golden-matrix.sh` (this remote has no `tools/mep/test/run.sh`).
- Cover rows 1–11 + row-10 precedence + row-11 recovery + row-5 docs-delta interstitial.
- Eliminate fragile heuristics that send landed slices back to `/implement-plan`.
- Keep `glossary.md` evaluation order and `resolver.sh` twins; glossary is the spec.
- Collapse `mep_where_resolver_json` / `mep_resolver_json` positional fanout (incl. implement `execution_target`) behind a named context; golden matrix is the safety net.

**Avoid:** new lifecycle features; adapter rewrites; expanding litmus into a second resolver; net-new inline git fallbacks beyond fixing proven misroutes (golden matrix locks **v0.1 transitional** routing — v0.2 demotes git from the default path; see `.mep/plans/mep-v0.2-outline.md`).

**Checkpoint:** `mep where` on fixture slugs never disagrees with golden expectations; dogfood notes empty.

**Status:** committed — `iterations/05-resolver-totality-golden-matrix.md` (`8e4d880`; checkpoint session `a0cecb8`)

---

## Iteration 5b — Finish-scan marker heuristic

**Goal:** `@finish` grep counts language comments, not bash `--flag` lines. a landed slice whose resolver *mentions* the token must not look unfinished.

**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/05b-finish-scan-marker-heuristic.md`

**Slice type:** architectural  
**Epistemic transition:** finish-scan stops impersonating an open decision on CLI-flag lines.  
**Irreversible decision:** comment prefixes are `-- ` (SQL), `#`, `//`, `/*`, `<!--` — not `--identifier`.  
**Maturity target:** provisional → stable

**Approach:** tighten `mep_finish_marker_lines_json` in `finish.sh`; prove with a fixture that `--reason "...@finish:open"` is not open, while `# @finish:open` still is. do not rewrite resolver row meaning or hide the token by copy-edit as the category.

**Avoid:** authorship-mode policy (6–8); string-only workaround in `resolver.sh` as the fix; expanding litmus.

**Checkpoint:** `mep finish scan mep-v0-graduation` has zero open markers; `mep where mep-v0-graduation` is not row 8 from this false positive.

**Status:** committed — `iterations/05b-finish-scan-marker-heuristic.md` (`f749db1`; brief `a0cecb8`; docs-delta `46895d9`)

---

## Iteration 6 — Manual mode workflow closure

**Goal:** Manual mode stops at finishes, prompts the human to fill the remainder, and **never** claims
the slice is done while `@finish:open` remains.

**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/06-manual-mode-workflow-closure.md`

**Slice type:** behavioral  
**Epistemic transition:** manual execution becomes honest about incompleteness.  
**Irreversible decision:** incompleteness is gated by marker grep + status packet, not LLM self-report.  
**Maturity target:** experimental → provisional

**Approach:** reuse 5b's finish-scan + row 8. make `commit scope` (and keep `lifecycle status --mode manual`) fail closed on `finish_open`. hermetic fixture: plant `# @finish:open` → blocked packets; flip to `done` → unblock. do not emit `@mise` (8); do not ship autopilot proxy (7).

**Checkpoint:** manual fixture completes the fill loop; status blocks commit with open finishes.

**Status:** committed — `iterations/06-manual-mode-workflow-closure.md` (`bb41b68`; `--fix` implementationRevision `2f937b7`)

---

## Iteration 7 — Autopilot ratification path

**Goal:** Autopilot uses the same fail-closed `commit scope` as manual when finishes stay open. lifecycle already mapped `finish_open` → proxy; this slice does **not** ship a running proxy.

**Slice type:** behavioral  
**Epistemic transition:** autopilot is not default on the commit packet.

**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/07-autopilot-ratification-path.md`

**Irreversible decision:** `authorshipMode=autopilot` joins the `finish_open` arm; runtime does not call a model.  
**Maturity target:** experimental → provisional

**Approach:** one disjunct in `mep_commit_scope_json`; hermetic fill-loop; do not emit `@mise` (8); do not spawn Task from `tools/mep/lib`.

**Avoid:** `@mise` emitter; in-tree LLM dispatch; resolver; litmus product; changing 6's manual/default arms.

**Checkpoint:** autopilot + `# @finish:open` ⇒ `commit scope` `blocked`; default still `ok`.

**Status:** committed — `iterations/07-autopilot-ratification-path.md` (`092ade7`)

---

## Iteration 8 — Mechanical authorship markers

**Goal:** `@mise` / `@finish:<state>` written by a deterministic `mep` verb — not prompt memory, not a file-watcher.

**Slice type:** behavioral  
**Epistemic transition:** authorship markers move from planned to mechanically emitted.

**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/08-mechanical-authorship-markers.md`

**Irreversible decision:** emission is a FOSS CLI using I11 comment grammar; never infers finish state from green tests; never calls a model (C9).

**Approach:** `mep mark mise` / `mep mark finish --state …` (spellings may match house `finish <subcmd>`). whole-file wrap for v0.1; range and on-save deferred. hermetic write+scan round-trip.

**Avoid:** file-watcher; in-tree LLM/Task; auto-infer `:done`; resolver rows; litmus growth; SKILL.md; retitling a packet tweak as the emitter.

**Checkpoint:** a temp `.sh` gains `@mise` wrappers via CLI; an existing `# @finish:open` can be set to `:done` without tests going green.

**Status:** committed — `iterations/08-mechanical-authorship-markers.md` (`84aa6e8`)

---

## Iteration 9 — Install path & stranger smoke test

**Goal:** A stranger clones this repo, puts `mep` on PATH (or follows an equivalent ≤5-step recipe), picks **one** executor preset, and runs the stub loop — no MEP-hosted keys. `run-stranger.sh` already proves engine defaults; this slice is the **operator install contract**, not a second CI harness.

**Slice type:** behavioral  
**Epistemic transition:** getting started is preset + optional override, not vision-doc archaeology.  
**Irreversible decision:** root README is the stranger entry; command presets stay fail-closed (`grok` stays named; no live driver).  
**Maturity target:** provisional → stable  
**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/09-install-stranger-smoke-test.md`

**Approach:** rewrite Start here to ≤5 copy-pasteable steps (clone → invoke `tools/mep/bin/mep` or PATH → `where`/`exec dispatch --executor stub`). document one command preset (cursor **or** grok TUI) as “your binary, no in-tree driver.” kill the stale README claim that slice-boundary litmus is unshipped. keep `run-stranger.sh` green; do not grow litmus product.

**Avoid:** v0.1.0 tag/packaging (15); CONTRIBUTING taste dump (12); live vendor SDK; dropping `grok`; I5 host pointer; SKILL.md rewrite; watcher/`mark` expansion.

**Checkpoint:** a stranger can follow README without opening the vision table; stub smoke still CI; grok still a named contract.

**Status:** committed — `iterations/09-install-stranger-smoke-test.md` (`2f6a514`; brief `6cc901b`)

---

## Iteration 9b — Mode-agnostic finish readiness

**Goal:** One open-finish fact gates every emitter. absent/default/manual/autopilot may project different actors/actions, but none may call `@finish:open` committable or checkpointable.

**Slice type:** architectural  
**Epistemic transition:** open-finish readiness becomes mode-agnostic across `where`, lifecycle, commit scope, and checkpoint.  
**Irreversible decision:** mode changes gate action/provenance, never readiness.  
**Maturity target:** provisional → stable  
**Delivery track:** mixed  
**Fanout:** sequential  
**Brief:** `iterations/09b-mode-agnostic-finish-readiness.md`

**Approach:** move open-marker selection to `finish.sh`; remove resolver’s duplicate helper; remove commit scope’s manual/autopilot condition; matrix absent/default/manual/autopilot across all four emitters.

**Avoid:** resolver rows; events (11); live proxy; README; packaging.

**Checkpoint:** absent/default `commit scope` exits 2 on `@finish:open`; all emitters derive openness from `finish.sh`; action remains human vs proxy by policy.

**Status:** committed — `iterations/09b-mode-agnostic-finish-readiness.md` (`52bb530`; brief `1f4ed1e`)

---

## Iteration 10 — Runtime ≠ policy hardening

**Goal:** Guard `where` packet identity on a **non-open-finish** row. 9b already locked row 8 and C11. 10 proves the same slug+facts still yield identical `proof.row` + `executionRequest` when the fixture is *not* finish-blocked.

**Slice type:** architectural  
**Epistemic transition:** remaining routing invariance (unblocked `where` row) is test-guarded.  
**Irreversible decision:** for one slug and one set of workflow facts **without** `@finish:open`, `mep where --json` `proof.row` and `executionRequest` `{kind,target,argv}` are identical under absent / `default` / `manual` / `autopilot`.  
**Maturity target:** provisional → stable  
**Delivery track:** mixed  
**Fanout:** sequential (11 may parallel after this brief if files stay disjoint)  
**Brief:** `iterations/10-runtime-policy-hardening.md`

**Approach:** hermetic equality on a clean `brief_ready` fixture; commit fixture manifest after each `mode set`. do not re-prove C11. do not add a `commit scope` mode arm. operator docs already name the boundary — no new taxonomy sentence.

**Avoid:** re-running 9b’s open-finish matrix as this slice’s RED; live proxy; `mep mark`; CONTRIBUTING (12); packaging (15); event ledger (11); `workflow.sh` rewrite; README/glossary restatement.

**Checkpoint:** unblocked `where` row+packet identical across modes; C11 untouched; docs sentence waived.

**Status:** committed — `iterations/10-runtime-policy-hardening.md` (`50d76f6`; brief `1f4ed1e`)

---

## Iteration 11 — Lifecycle observability completion

**Goal:** Close the observability gap: documented event classes (`resolver_routed`, `checkpoint_evaluated`, `lifecycle_evaluated`, `review_body_validated`) actually append, and `events tail --json` filters are proven — history stays off the resolver.

**Slice type:** behavioral  
**Epistemic transition:** observability matches the runtime spine (Milestone C remaining vs Milestone A routing).  
**Irreversible decision:** the four documented emit sites are the v0.1 ledger surface; tail is inspectable JSON; events never participate in `where` derivation.  
**Maturity target:** provisional → stable  
**Delivery track:** mixed  
**Fanout:** sequential (disjoint from 12’s CONTRIBUTING)  
**Brief:** `iterations/11-lifecycle-observability-completion.md`

**Approach:** hermetic `MEP_HISTORY_ROOT_OVERRIDE`; drive `where` / `checkpoint` / `lifecycle status` / `pr scaffold`; assert envelope + `events tail` `--slug` / `--event` / `--limit`. fill silent documented classes only. do not add analytics.

**Avoid:** resolver input from the ledger; new event classes for mark/commit-scope/mode unless a listed class is missing; dashboards; 12 CONTRIBUTING; packaging (15).

**Checkpoint:** four classes round-trip through tail; `rg` shows resolver still does not read the ledger.

**Status:** committed — `iterations/11-lifecycle-observability-completion.md` (`8408fda`; brief `8f61a98`)

---

## Iteration 12 — Curation externalized (authoring taste)

**Goal:** Taste lives in CONTRIBUTING, examples, and profile seeds — stranger can follow without author context.

**Slice type:** consolidation  
**Epistemic transition:** framework **authoring** curation moves from author memory to repo artifacts.  
**Irreversible decision:** CONTRIBUTING is the stranger authoring surface; glossary/resolver table stays the routing contract (no second table). 15 may only verify the file exists at tag time — it does not rewrite taste.  
**Maturity target:** absent → provisional  
**Delivery track:** mixed  
**Fanout:** sequential (15 packaging; 13 leftover CONTRIBUTING AC)  
**Brief:** `iterations/12-curation-externalized.md`

**Approach:** root `CONTRIBUTING.md` pointing at existing examples (`fixture-demo`, `example-stub`, curate fixture) plus any missing worked sample. grep-lock that the file exists and names curate + profile retarget. do not add a fourth “already true” CLI suite.

**Avoid:** 01 success #3 live-executor dogfood; v0.1.0 tag / Sator (15); rewriting 10/11 suites; live vendor driver (C9); forking the glossary into CONTRIBUTING.

**Checkpoint:** CONTRIBUTING + 2–3 canonical examples; glossary/resolver table is still the routing contract; 13’s leftover “CONTRIBUTING documents curate” can close.

**Status:** committed — `iterations/12-curation-externalized.md` (`8af941f`; brief `1e8df26`)

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

**Status:** committed — git owned-path landing `64802ec14`; promised `pilot-default-mode-report.md` **absent**. Not backfilled on the host branch. The debt is paid by **15b** in this repo (post-tag). Iter 14's "14b" remains the curate-instance probe in that brief — a different fragment.

---

## Iteration 15 — v0.1.0 release package (incl. Sator Square)

**Goal:** Honest public release — README (ownership model, one canonical workflow, open roadmap), LICENSE,
CONTRIBUTING (**created in 12** — 15 verifies, does not rewrite taste), tag **v0.1.0**. **Hard gate:** README footer contains exact Sator Square block.

**Brief:** `iterations/15-v010-release-package.md`

**Slice type:** cleanup  
**Epistemic transition:** MEP graduates from private thesis to FOSS v0.1.0 with honest scope table.  
**Irreversible decision:** the tag tells the truth about what runs (`stub` only) and what does not (live drivers, PATH package, success #3). Sator Square is a README footer gate, not an easter egg.  
**Maturity target:** thesis → public v0.1.0  
**Delivery track:** mixed  
**Fanout:** sequential (16 is post-tag)

**Approach:** bump `MEP_VERSION`; README scope table + Sator footer; verify LICENSE and CONTRIBUTING exist without rewriting taste; human `git tag v0.1.0`. do not ship a vendor driver.

**Avoid:** live executor SDK (C9); claiming 01 success #3; AUR/PATH install; I5 host consume; 16 manifest retirement; rewriting 12 CONTRIBUTING.

**Status:** committed — product `66373b3`; brief `43fff44`; checkpoint `1d6bb8f`; signed annotated tag `v0.1.0` on `66373b3`. 16 unblocked.

**Sator Square (required footer):**

```text
S A T O R
A R E P O
T E N E T
O P E R A
R O T A S
```

**Checkpoint:** Sator Square in README footer; scope section matches shipped surface; annotated tag `v0.1.0` on `66373b3`.

---

## Iteration 15b — Default-mode evidence report

**Goal:** A public record that default mode ran a real initiative — what was built, over how many slices, and **what went wrong**. Closes 14's unpaid artifact without pretending the host-branch pilot happened here. Numbered **15b** because it is post-tag work, not a rewind of 14 (whose "14b" was curate dogfood).

**Brief:** `iterations/15b-default-mode-evidence-report.md`

**Slice type:** consolidation
**Epistemic transition:** default mode is proven by a citable record, not by maintainer assertion.
**Irreversible decision:** the artifact is a **public repo doc** (`tools/mep/docs/pilot-default-mode.md`), not a prep-tree retrospective — a stranger evaluating `mep` reads it without opening `.mep/prep/`.
**Maturity target:** provisional → stable (default mode only)

**Approach:** chronology from the `04` ledger + `git log` + `manifest.deviations[]`; failure list first; state that the executor was an **agent harness driving the CLI**, not `mep exec dispatch`; leave 01 #3 open.

**Avoid:** piloting manual/autopilot; the D0 driver; install path; 16; upgrading README past the report.

**Status:** committed — `2aa8a7c`; brief `4b3b893`. `--fix` also wrote `checkpointRevision=5b37dd8` (pre-amend impl); stripped (impl ≠ checkpoint).

**Checkpoint:** report exists; this-remote SHAs resolve; host 13/14 SHAs named as unresolved; README default-mode wording matches the report; #3 still deferred.

---

## Iteration 16 — Document-native state authority & legacy migration (post-v0.1)

**Goal:** Make the plan documents the only state authority, and give everything that isn't one a
named exit. Readers compose from initiative + brief frontmatter + git; **every** writer follows
(`checkpoint`, `doctor`, `mode set`, `implement`, `pr scaffold`); an unmigrated initiative imports
its `manifest.json` read-only, refuses writes out loud, and converts via `mep migrate`. Same routing
semantics as iteration 5 golden matrix.

**Shortcut:** sc-101  
**Brief:** `iterations/16-document-colocated-workflow-state.md`

**Slice type:** architectural  
**Epistemic transition:** transitional manifest retires to import-only; plan documents are the workflow ledger, read *and* written.
**Blocked by:** golden matrix (5) — already committed. v0.1.0 tag (15) landed.

**Not a v0.1 gate.** v0.1 shipped the authoring contract (0, 12) and transitional manifest.

**Status:** committed — `iterations/16-document-colocated-workflow-state.md` (`8a738e4`)

---

## Iteration 17 — Document-state module (post-16 consolidation)

**Goal:** Give the frontmatter persistence grammar one home. Iteration 16 froze the contract inside
`resolver.sh`; this slice moves the primitives so routing and persistence are not the same reason
to change a file.

**Brief:** `iterations/17-document-state-module.md`

**Slice type:** consolidation
**Epistemic transition:** C12's grammar is interchangeable as a module path (I19), not as a second
authority.
**Blocked by:** 16 (`8a738e4`).

**Approach:** extract `mep_frontmatter_*`, `mep_document_state_present`, and compose helpers into
`tools/mep/lib/document.sh` (name is instance); `resolver.sh` keeps rows. no key-spelling changes.
no packet-shape changes. no A2 ladder. no live driver.

**Avoid:** A2 phases; B1 infer; D0 driver; rewriting twins for taste; changing `mep migrate` semantics.

**Status:** committed — `iterations/17-document-state-module.md` (`09f8e54`)

---

## Dependency order

```
0 (extract + document authoring contract)
  → 1 → 2 → 3 → 4   # unix foundation — v0.1 substrate; blocks all product work
  → 5                 # resolver totality (semantic; storage-agnostic tests)
  → 5b                # finish-scan comment heuristic (unblocks dogfood where)
  → 6,7,8             # workflow closure (identity work; 8 last of B)
  → 9 → 9b → 10,11 (parallel) → 12 → 13 → 14 → 15
  → 16 (post-v0.1)    # manifest → import-only; document-native state authority → v0.2.0 A1
  → 17                # persistence module; last slice on this slug
```

Iterations 1–15 execute in the **standalone repo**. Litmus (4) has passed. **v0.1.0 is tagged.** 16
closed A1. 17 closed I19. this initiative **graduates** here. A2/B/C/D wait for a new v0.2 epic
from `.mep/plans/mep-v0.2-outline.md`.

## Fanout eligibility

| Iterations | Parallel? | Reason |
|------------|-----------|--------|
| 5b then 6, 7, 8 | sequential now | 6–7 landed as commit-scope mode arms; 8 is the writer — last B identity |
| 9b before 10 | no | 10's mode-invariant routing proof assumes readiness is already mode-agnostic |
| 10, 11 | yes after 9b | docs/tests vs events.sh |

## Re-plan triggers

- Litmus reveals missing primitive → return to iteration 3 before resolver/workflow work.
- Exit-code contract churn → freeze iteration 1 before iteration 2+.
- Resolver golden matrix reveals table redesign → iteration 5 only; do not patch adapter-shaped routes.
- Finish-scan false-positive on CLI flags → iteration 5b; do not copy-edit resolver strings as the category.
