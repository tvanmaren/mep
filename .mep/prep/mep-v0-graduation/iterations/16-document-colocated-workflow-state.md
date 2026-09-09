# Iteration 16 — Document-colocated workflow state (post-v0.1)

**Prep slug:** mep-v0-graduation
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/16-document-colocated-workflow-state.md`
**Status:** brief_ready
**Slice type:** architectural
**Mode:** hardening
**Delivery track:** mixed
**Fanout:** sequential
**Shortcut:** sc-101

## Epistemic transition

**What became more certain:** workflow routing reads plan documents + git. `manifest.json` is not a routing authority.

**Irreversible decision (one):** the initiative cursor lives in YAML frontmatter on `04-iteration-roadmap.md`; each iteration's status and revision triplet live in that brief's YAML frontmatter. checkpoint writes those nodes. resolver composes them. `manifest.json` is removed once goldens pass on the composed view.

**Maturity target:** `transitional → document-native`

## Category vs instance

**Category certainty (close this slice):** routing *authority* is the prep tree + git, not a sidecar index. evaluation-order rows stay the iter-5 glossary table; only the *inputs* change.

**Instance certainty (this slice only):** frontmatter key names; YAML vs JSON; how fixtures seed a temp slug without a `manifest.json`.

**Acceptance order:** compose reader + checkpoint writer + golden parity, then delete `manifest.json` from the live path. do not staff infer (B1), doctor expansion (B2), or explicit phase ladder (A2).

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/resolver.sh` (read compose); `tools/mep/lib/checkpoint.sh` / `doctor.sh` writebacks that today mutate `manifest.json`; `tools/mep/lib/paths.sh`; `tools/mep/lib/status.sh` if it reads the index; `tools/mep/test/run-golden-matrix.sh`; glossary twins (`manifest` definition + inputs); this initiative's live `manifest.json` *retirement* |
| **May know** | C7, C8, C10, I4; iter 5 golden oracle; `workflow.sh` / `mode` only as consumers of the compose helper; curate.py if it currently loads the index for status |
| **Must not know** | `mep infer` (v0.2 B1); desync-first `where` (B3); `where` ⊕ lifecycle merge (C1); live vendor drivers; PATH/AUR; rewriting 15 README taste; I5 host consume |
| **Invariants** | C4, C7, C8, C9, C10, C11; golden rows 1–11 + documented recoveries still match; stdout `status` agrees with exit; no in-tree live driver |
| **Still provisional** | git heuristics for “built” (I4) — still transitional; dual skill/docs copies; event ledger |

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

- [ ] resolver + `where --json` compose initiative cursor + current brief from documents + git — they do **not** read `manifest.json` as authority
- [ ] `tools/mep/test/run-golden-matrix.sh` still green with **row parity** to iter 5 (same rows, same `executionRequest` / `proof` assertions); fixtures seed documents, not a routing manifest
- [ ] checkpoint `--fix` writes brief/roadmap frontmatter (status, revision triplet, current iteration) — not `manifest.json` fields
- [ ] live `.mep/prep/mep-v0-graduation/manifest.json` is gone or is a one-release import stub that `where` ignores
- [ ] glossary twins: `manifest.json` is no longer described as the resolver input; composed documents + git are
- [ ] unix-contract, stranger, slice-boundary `--executor stub` still green
- [ ] no `mep infer`; no A2 phase enum; no live vendor driver

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
| `tools/mep/lib/checkpoint.sh` | modify | domain | write frontmatter |
| `tools/mep/lib/doctor.sh` | modify | domain | git-proven writebacks to documents, not JSON index |
| `tools/mep/lib/paths.sh` | modify | domain | drop or demote `manifest.json` path helper |
| `tools/mep/lib/status.sh` | modify | domain | if it reads the index |
| `tools/mep/test/run-golden-matrix.sh` | modify | integration | seed documents |
| `.cursor/skills/mise-en-place/glossary.md` + `tools/mep/docs/glossary.md` | modify | integration | twins |
| `.mep/prep/mep-v0-graduation/manifest.json` | delete | integration | after compose works |
| `.mep/prep/mep-v0-graduation/04-iteration-roadmap.md` | modify | integration | cursor frontmatter |
| `.mep/prep/mep-v0-graduation/iterations/*.md` | modify | integration | per-iter frontmatter as needed for *this* slug to keep routing |

**Conflicts:** sequential vs all other lib owners. do not take `events.sh`, `exec` dispatch, README taste, curate execute semantics.

**Explicitly not this slice:** infer; doctor as forensic orchestrator; A2 phases; C1 unified `where`; live drivers; 15 README rewrite.

## RED-phase gates (before GREEN)

- [ ] `mep where mep-v0-graduation --json` still depends on `manifest.json` (authority)
- [ ] golden matrix fixtures still write `manifest.json`
- [ ] `manifest.json` still present under `.mep/prep/mep-v0-graduation/`

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

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category is “who is the ledger,” not “prettier YAML.” fail if goldens were rewritten to hide a row, or if infer shipped to “finish” compose.

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code/docs scope
- [ ] `git commit`
- [ ] `/prep mep-v0-graduation checkpoint`
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Do not read future iterations.
> Do not add `mep infer`. Schema finish is `done` (cursor on 04, triplet on briefs, deviations in 03).
