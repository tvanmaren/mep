---
mepIteration: 16
mepTitle: Document-native state authority & legacy migration
mepStatus: committed
mepSliceType: architectural
mepDeliveryTrack: mixed
mepFanout: sequential
mepBriefRevision: acf06b0a9b36e065415689fe59e46cfc692b680b
mepImplementationRevision: 8a738e42c8d7592cd65d79583c9c12aa0f2fb130
mepCheckpointRevision: 8a738e42c8d7592cd65d79583c9c12aa0f2fb130
---

# Iteration 16 — Document-native state authority & legacy migration (post-v0.1)

**Prep slug:** mep-v0-graduation
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/16-document-colocated-workflow-state.md`
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** mixed
**Fanout:** sequential
**Shortcut:** sc-101

## Epistemic transition

**What became more certain:** workflow routing reads plan documents + git, and *writes* them too — a sidecar is retired only when every writer follows the reader. `manifest.json` is not an authority; it is an import format with a named refusal and a conversion verb.

**Irreversible decision (one):** the initiative cursor lives in YAML frontmatter on `04-iteration-roadmap.md`; each iteration's status and revision triplet live in that brief's YAML frontmatter. checkpoint writes those nodes. resolver composes them. `manifest.json` is removed once goldens pass on the composed view.

**Maturity target:** `transitional → document-native`

## Category vs instance

**Category certainty (close this slice):** routing *authority* is the prep tree + git, not a sidecar index. evaluation-order rows stay the iter-5 glossary table; only the *inputs* change.

**Instance certainty (this slice only):** frontmatter key names; YAML vs JSON; how fixtures seed a temp slug without a `manifest.json`.

**Acceptance order:** compose reader + checkpoint writer + golden parity, then delete `manifest.json` from the live path. do not staff infer (B1), doctor expansion (B2), or explicit phase ladder (A2).

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | document-state runtime (`resolver`, `manifest`, `checkpoint`, `doctor`, `paths`, `status`, `workflow`, `lifecycle`, `finish`, `pr`, `migrate`, CLI registry); all state-sensitive fixtures; `.mep/prep/fixture-demo/` migration; every shipped operator surface that instructs sidecar reads/writes (`SKILL`, command adapters, tidy, curate, bundled reference, glossary, portable routing, policies, templates, READMEs); the v0.2 A1 outline/invariant reconciliation; this initiative's live `manifest.json` *retirement* |
| **May know** | C7, C8, C10, I4; iter 5 golden oracle; curate.py if it currently loads the index for status |
| **Must not know** | `mep infer` (v0.2 B1); desync-first `where` (B3); `where` ⊕ lifecycle merge (C1); live vendor drivers; PATH/AUR; rewriting 15 README taste; I5 host consume |
| **Invariants** | C4, C7, C8, C9, C10, C11; **C12 promoted at close** (`8a738e4`); golden rows 1–11 + documented recoveries still match; stdout `status` agrees with exit; no in-tree live driver |
| **Still provisional** | git heuristics for “built” (I4) — still transitional; dual skill/docs copies; event ledger; frontmatter primitives still live in `resolver.sh` (I19 → iter 17) |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| compose reader | `@stable` | add — public routing inputs |
| frontmatter schema | `@provisional` | add — key spellings are instance (I*) |
| git-heuristic “built” | `@provisional` | keep — v0.2 B1 demotes |

## Stabilizes

v0.2.0 headline (outline A1). B1 infer may assume the hot path no longer *requires* `manifest.json`.

## Macro constraints (read-only)

- C8: `executionRequest` still row-derived; do not make slash strings the durable API
- C7: envelope and exit still agree
- C10: litmus still composes public `mep` verbs only
- C4: checkpoint `--fix` stays deterministic; no model in the write path
- I4: post-brief history remains how “built” is proven until B1

## Acceptance criteria (this iteration ONLY)

- [x] resolver + `where --json` compose initiative cursor + current brief from documents + git — they do **not** read `manifest.json` as authority
- [x] `tools/mep/test/run-golden-matrix.sh` still green with **row parity** to iter 5 (same rows, same `executionRequest` / `proof` assertions); fixtures seed documents, not a routing manifest
- [x] checkpoint `--fix` writes brief/roadmap frontmatter (status, revision triplet, current iteration) — not `manifest.json` fields
- [x] live `.mep/prep/mep-v0-graduation/manifest.json` is gone or is a one-release import stub that `where` ignores
- [x] glossary twins: `manifest.json` is no longer described as the resolver input; composed documents + git are
- [x] every state *writer* follows the reader: `mode set` rewrites roadmap `mepAuthorshipMode`, `implement` reads brief `mepStatus`, `pr scaffold` reads the composed summary, and `run-unix-contract.sh` covers both authority arms (document-native fixture + legacy import fixture)
- [x] document authority requires a frontmatter block, not a roadmap *file* — a pre-migration roadmap with no frontmatter imports its manifest instead of resolving to an empty cursor
- [x] a literal `null` in frontmatter reads as absent, never as the revision string `"null"`
- [x] legacy initiatives get a named refusal (`legacy_state_read_only`) and a supported exit (`mep migrate`), not a silent no-op under `--fix` — `checkpoint`, `doctor`, and `mode set` all refuse at `blocked`/exit 2, and `mep_frontmatter_set` fails closed rather than succeeding as a no-op
- [x] no writer decides authority for itself: `mep_document_state_present` is the single test, and every mode-set fixture no longer shares one authority arm
- [x] no doc instructs an agent to read or write `manifest.json` as authority; `templates/manifest.json` and the superseded `mise-en-place/doctor.sh` sed writer are gone
- [x] document state never fabricates retired `phaseApproved` / `sessionMode` fields; malformed roadmap or brief frontmatter blocks routing instead of disappearing or defaulting optimistically
- [x] checkpoint and doctor report only writebacks that reached disk; any failed frontmatter mutation is `blocked/state_write_failed`
- [x] migration is resumable: every referenced brief validates first, briefs write before the roadmap authority flip, modeled fields survive, and intentionally dropped legacy keys are named in the packet
- [x] every live adapter and recovery/publication surface reads the composed state or document nodes; tidy no longer creates a manifest-native initiative
- [x] vision documents say exactly where reality is: A1 implemented here; A2/B/C/D remain future work
- [x] unix-contract, stranger, slice-boundary `--executor stub` still green
- [x] no `mep infer`; no A2 phase enum; no live vendor driver

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| golden matrix keeps iter-5 rows | `mechanical` | iter 5 irreversible decision; `run-golden-matrix.sh` |
| checkpoint `--fix` stays git-proven / deterministic | `mechanical` | C4; existing `checkpoint.sh` |
| retire sidecar as routing authority | `mechanical` | this brief's category; v0.2 outline A1 |
| document schema (which file holds the cursor vs per-iter triplet) | `finish` | — |

**Frame — document schema:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| schema | one cursor, one triplet per slice, checkpoint can write it, resolver can read it, goldens can seed it | brief YAML-ish headers; `04-iteration-roadmap.md` as master plan; I4 triplet | cursor on 04 vs a new `initiative.md`; deviations stay in 03 vs a jsonl | `done` |

**Draft destination (operator ratifies by marking `done`):** cursor = YAML frontmatter on `04-iteration-roadmap.md`; triplet + `status` = YAML frontmatter on `iterations/<n>-*.md`; `deviations[]` migrate into `03` amendments (already the human table) — do not keep a second JSON ledger.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/resolver.sh` | modify | domain | compose from documents + git |
| `tools/mep/lib/manifest.sh` | modify | domain | retain only the explicitly named legacy path; no shadow reader |
| `tools/mep/lib/checkpoint.sh` | modify | domain | write frontmatter |
| `tools/mep/lib/doctor.sh` | modify | domain | git-proven writebacks to documents, not JSON index |
| `tools/mep/lib/paths.sh` | modify | domain | drop or demote `manifest.json` path helper |
| `tools/mep/lib/status.sh` | modify | domain | if it reads the index |
| `tools/mep/lib/workflow.sh` | modify | domain | `mode set` writes frontmatter; `implement` reads `mepStatus` |
| `tools/mep/lib/pr.sh` | modify | domain | read the composed summary, not the manifest file |
| `tools/mep/lib/lifecycle.sh` | modify | domain | packet key `manifest` → `documents` |
| `tools/mep/lib/migrate.sh` | add | domain | manifest → frontmatter conversion |
| `tools/mep/bin/mep` + `tools/mep/lib/registry.sh` | modify | domain | `mep migrate` verb + usage |
| `tools/mep/lib/exec.sh` | modify | domain | `kind: migrate` on the dispatch allowlist (row-derived; not a second resolver) |
| `tools/mep/lib/events.sh` | modify | domain | `resolver_routed` payload carries `status` so blocked routes are distinguishable |
| `tools/mep/test/run-golden-matrix.sh` | modify | integration | seed documents |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | both authority arms; legacy refusal; migrate round trip |
| `tools/mep/test/run-events.sh` | modify | integration | fixture off the legacy path |
| `tools/mep/test/run-stranger.sh` + `scripts/litmus/slice-boundary.sh` | modify | integration | migrate the copied `fixture-demo` at runtime; do not require a committed tree migration |
| `tools/mep/test/run-finish-scan.sh` + `tools/mep/test/run-mark.sh` + `tools/mep/test/run-mode-resolver.sh` + `tools/mep/test/run-manual-workflow.sh` | modify | integration | document-authority coverage for state-sensitive verbs |
| `tools/mep/templates/{04-iteration-roadmap,slice-brief,05-handoff}.md` + skill twins | modify | integration | ship the frontmatter new initiatives need |
| `tools/mep/templates/manifest.json` + skill twin | delete | integration | no template for a retired format |
| `.cursor/skills/mise-en-place/doctor.sh` | delete | integration | sed-based manifest writer, superseded by `mep doctor` |
| glossary / `portable-routing` / `SKILL` / `slice-integrity-check` / `maturity-tags` / `event-ledger` / `execution-policies` / README twins | modify | integration | no doc may instruct a sidecar read or write |
| `README.md` | modify | integration | the v0.1 scope bullet this slice falsifies |
| `.cursor/commands/{mep,prep-stage,prep-cleanup,prep-pr-description,prep-curate}.md` | modify | integration | remove live manifest-authority instructions |
| `.cursor/skills/tidy/SKILL.md` + `.cursor/skills/mise-en-place/curate/SKILL.md` | modify | integration | recovery/publication operate on document state |
| `tools/mep/scripts/{bundle-reference.py,curate.py}` | modify | integration | generated/runtime status surfaces name document state |
| `.mep/plans/mep-v0.2-outline.md` + `01-invariant-goal.md` | modify | integration | reconcile A1 reality and persisted cursor decision |
| `.mep/prep/fixture-demo/**` | leave | integration | **not** in `8a738e4` — stranger/litmus migrate a copy; working tree may still be legacy |
| `.mep/prep/mep-v0-graduation/manifest.json` | delete | integration | after compose works |
| `.mep/prep/mep-v0-graduation/04-iteration-roadmap.md` | modify | integration | cursor frontmatter |
| `.mep/prep/mep-v0-graduation/iterations/*.md` | modify | integration | per-iter frontmatter as needed for *this* slug to keep routing |
| `.mep/prep/mep-v0-graduation/03-core-vs-volatile.md` | modify | integration | amendments 16 through 16e + **16 close** (C12 / I19) |

**Conflicts:** sequential vs all other lib owners. README taste and curate execute semantics stayed out. `exec.sh` / `events.sh` *did* move — only the `migrate` kind and blocked-route `status` on the ledger, not dispatch rewrite.

**Explicitly not this slice:** infer; doctor as forensic orchestrator; A2 phases; C1 unified `where`; live drivers; 15 README rewrite.

## RED-phase gates (before GREEN)

- [x] `mep where mep-v0-graduation --json` still depends on `manifest.json` (authority)
- [x] golden matrix fixtures still write `manifest.json`
- [x] `manifest.json` still present under `.mep/prep/mep-v0-graduation/`

## Approach

1. Prove RED: where/checkpoint/goldens on the sidecar.
2. Land compose helper; point resolver at it; keep a throwaway importer if a fixture still speaks JSON.
3. Retarget checkpoint/doctor `--fix` writebacks to 04 + brief frontmatter.
4. Convert golden fixtures to document seeds; prove parity.
5. Delete live `manifest.json`; update glossary twins.
6. Stop. do not build infer.

## Avoid (out of scope this iteration)

- `mep infer` / forensic reconstruction as the default `where` path
- explicit slice phase ladder (A2)
- merging lifecycle status into `where` (C1)
- live vendor drivers; PATH package; I5
- rewriting v0.1 README scope / Sator
- growing litmus into a second resolver

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — routing authority moves to documents
- [x] **Ownership minimal** — lib compose/write + golden + glossary + this slug's ledger files
- [x] **Category before instance** — authority seam before key-spelling bikeshed (schema is the finish)
- [x] **One place to edit** — compose helper is the reader; checkpoint is the writer
- [x] **No planned shotgun surgery** — Avoid lists B1–C1, events, README
- [x] **Consolidation routing** — 15 closed packaging; this is the structural v0.2.0 slice, not a tidy

**Preflight note:** pass. operator 2026-09-09 ratified schema: cursor on 04, triplet on briefs, deviations in 03. brief_ready.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | goldens match iter-5 semantics on new inputs; sidecar is not authority | change row meanings; add infer; claim v0.2.0 while `manifest.json` still routes |

## Testing

- **FOSS:** `run-golden-matrix.sh`; `run-unix-contract.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** `mep where mep-v0-graduation --json` with `manifest.json` absent; checkpoint `--fix` edits frontmatter

## Architectural diff (fill at checkpoint)

- Assumptions hardened: document authority is a validated frontmatter block, not file existence;
  readers and writers share that seam; roadmap is the final migration commit point.
- Coupling increased: roadmap/brief key spellings are now a public persistence contract for v0.2.
- Harder to change: cursor placement and the legacy import window require explicit migration logic.
- Easier to change: routing no longer depends on a sidecar mirror; forensic B1/B2 can compare one
  authoritative tree against git without deciding which persisted copy wins.
- **Promote to core:** C12 — plan documents are the only mutable ledger; malformed state blocks;
  writes report disk truth; compatibility imports never accept mutations.
- **Newly interchangeable:** legacy manifest parsing and `mep migrate` are one-release adapters,
  deletable without changing document-native callers. I19 (which file owns the primitives) stayed
  interchangeable — queued as iter 17, not promoted.
- **Falsified:** a green legacy-only fixture proves document-native behavior; a document's existence
  proves state exists; migration can safely flip authority before every child node lands;
  compatibility fields may be synthesized harmlessly.

## Checkpoint

**Seam smell test:** category is “who is the ledger,” not “prettier YAML.” fail if goldens were rewritten to hide a row, or if infer shipped to “finish” compose.

**Close (`8a738e4` + this docs-delta):** C12 promoted; I19 registered and *not* extracted here; live `mep-v0-graduation/manifest.json` retires in the docs-delta. `fixture-demo` remains a legacy seed that the harness migrates.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code/docs scope
- [x] `git commit`
- [x] `/prep mep-v0-graduation checkpoint`
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Do not read future iterations.
> Do not add `mep infer`. Schema finish is `done` (cursor on 04, triplet on briefs, deviations in 03).
