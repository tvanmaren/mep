---
mepIteration: 8
mepTitle: Mechanical authorship markers
mepStatus: committed
mepSliceType: behavioral
mepDeliveryTrack: mixed
mepFanout: sequential
mepBriefRevision: 2e38627cd340d2c2f44726066d9e8a9dba845caf
mepImplementationRevision: 84aa6e8597d3aa770c611da54b541ccfc718a5b0
mepCheckpointRevision: 84aa6e8597d3aa770c611da54b541ccfc718a5b0
---

# Iteration 8 — Mechanical authorship markers

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/08-mechanical-authorship-markers.md`  
**Status:** committed  
**Slice type:** behavioral  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** `@mise` / `@finish:<state>` can be **written by a deterministic `mep` verb**, not hoped from the model or a file-watcher.

**Irreversible decision (one):** emission is a FOSS CLI that uses the same language-comment grammar as I11; it never infers finish state from tests going green, and it never calls a model (C9).

**Maturity target:** `absent → provisional`

## Category vs instance

**Category certainty (close this slice):** one writer: wrap a path with `@mise` / `@mise:end` (host comment syntax), and set `@finish:` suffix on an existing marker line. scan/commit-scope/lifecycle **consume** markers; they do not grow a second grepping writer.

**Instance certainty (this slice only):** hermetic temp file(s) under a fixture slug. not this initiative’s live tree. not “on save.” not Cursor Task wrapping diffs.

**Acceptance order:** CLI writer before host overlay, before watcher, before SKILL.md telling the LLM to remember tags.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/finish.sh` (or a sibling `mark.sh` sourced by `bin/mep`); `tools/mep/bin/mep` + `registry.sh` for the new verb(s); FOSS fixture under `tools/mep/test/`; docs twins of `maturity-tags.md` **only** if they already specify *how* markers are written (format/grep is not enough — skip if they only describe meaning) |
| **May know** | I11 comment prefixes; C7; `finish scan`; 6/7 `commit scope` consumers; registry TSV |
| **Must not know** | in-tree LLM/Task; file-watcher runtime; resolver row table; litmus product growth; vendor drivers; `/prep-cleanup` strip logic rewrite |
| **Invariants** | C7, C8, C9, C10; I11 prefixes unchanged; `# @finish:open` still detects after a CLI write; unmarked files stay unmarked; stdout `--json` matches exit |
| **Still provisional** | host calling the verb after generate; dual skill/docs copies except any emission-spec twins this slice must keep in sync |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| new mark/write helper | `@provisional` | add — first mechanical emitter |
| `mep_finish_line_is_language_comment` | `@stable` | keep — 5b |

## Stabilizes

Milestone B close. 9+ may assume agents *can* mark without relying on prompt memory. graduation strip (15/`prep-cleanup`) still owns removal.

## Macro constraints (read-only)

- C7: envelope/exit
- C8: no new `executionRequest` kind unless a verb is not dispatchable that way — prefer a read/write packet like `finish scan`, not a new resolver kind
- C9: no vendor; no `eval` of model output as the writer
- C10: do not weaken litmus
- I11: `--flag` is still not a comment

## Acceptance criteria (this iteration ONLY)

- [x] a hermetic source file with no markers: `mep mark mise <path> --json` (exact verb spelling in registry) writes language-comment `@mise` / `@mise:end` around the file (or a documented range); packet `status=ok`; `finish scan` still counts finishes separately (mise ≠ finish)
- [x] same tree: an existing `# @finish:open` line can be set to `:done` then `:ratified` via the CLI; `finish scan` counts follow; **no** auto-flip because tests are green
- [x] writer uses I11 prefixes (`#` on a `.sh` fixture); a `--reason` flag line still is not a marker
- [x] unix-contract lists the new verb(s); golden + stranger + slice-boundary litmus still green; no resolver row-table edits; no in-tree LLM; no inotify/watcher
- [x] 6/7 commit-scope behavior unchanged on an unmarked default-mode fixture

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| comment-prefix pick for `.sh` | `mechanical` | I11 `mep_finish_line_is_language_comment` |
| registry + `bin/mep` dispatch | `mechanical` | `finish scan` / `commit scope` verbs |
| wrap file vs wrap range | `finish` | whole-file vs region — first instance may be whole-file if range is deferred in Avoid |
| auto-infer `:done` from tests | out of scope | manual policy: tooling may offer, never auto-infers |

**Frame — whole-file wrap vs range (if this slice ships whole-file only, state `done` with range deferred):**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| mechanical emitter | deterministic JSON verb writes `@mise` and can advance `@finish:` suffix; never infers from tests; I11 grammar | `finish scan` consumer; maturity-tags wrap example `@mise` / `@mise:end` | whole-file wrap for v0.1 + explicit monotonic `--state` on one existing finish line; byte-range wrap and watchers deferred | `done` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/finish.sh` | modify | domain | writer next to scanner, or extract `mark.sh` if finish.sh would mix two reasons to change |
| `tools/mep/lib/mark.sh` | new | domain | only if extracted |
| `tools/mep/lib/registry.sh` | modify | domain | new verb TSV |
| `tools/mep/bin/mep` | modify | domain | dispatch |
| `tools/mep/test/run-mark.sh` | new | integration | write + scan round-trip |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | registry + fixture invocation |
| `tools/mep/docs/maturity-tags.md` | modify | integration | **only** if emission how-to is already specified |
| `.cursor/skills/mise-en-place/maturity-tags.md` | modify | integration | twin if touched |

**Conflicts:** sequential — writer + scan share comment grammar.

**Explicitly not this slice:** `resolver.sh` rows; litmus product; SKILL.md; host `run.sh`; file-watcher; spawning Task; `prep-cleanup` strip rewrite.

## RED-phase gates (before GREEN)

- [x] no public `mep` verb writes `@mise` or flips `@finish:` (scan-only)
- [x] unix-contract registry list has no mark/set-finish writer

## Approach

1. Prove RED: registry + `mep help` have no writer; planting markers is still `cat >>` in tests.
2. Add JSON verb(s) — recommend `mep mark mise --json <path>` and `mep mark finish --json <path> --state done` (spellings may match house `finish <subcmd>` if that reads cleaner in registry; pick one family and stick).
3. Reuse I11 to choose/validate comment syntax; refuse to treat `--flags` as write targets.
4. Hermetic fixture: write mise → file contains wrappers; set finish state → scan counts; default commit-scope still `ok` without open finishes.
5. Do not watch the filesystem. do not call a model.

## Avoid (out of scope this iteration)

- file-watcher / editor on-save (invariant goal: post-v0.1)
- in-tree LLM / Task wrapping diffs (C9)
- auto-inferring `:done` from green tests
- resolver evaluation order / glossary row table
- expanding litmus; vendor drivers; SKILL.md rewrite
- retitling a one-line packet tweak as “the emitter” (7’s lesson)
- changing 6/7 fail-closed commit-scope rules

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — deterministic CLI writes authorship markers
- [x] **Ownership minimal** — finish/mark + registry + bin + fixture
- [x] **Category before instance** — writer before host overlay / watcher
- [x] **One place to edit** — comment grammar stays I11; writer is the new home for *emission*
- [x] **No planned shotgun surgery** — Avoid lists watcher / LLM / resolver / litmus / 6–7 packets
- [x] **Consolidation routing** — 7 was mode-parity on commit scope; this is a new verb, not leftover 7

**Preflight note:** pass — 8 is the remaining Milestone B identity. one finish: CLI emitter (recommend whole-file `@mise` + explicit finish `--state`; range/watcher deferred).

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| behavioral | operator can mark a file without asking the model to remember tags | invent a watcher; ship a vendor wrapper |

## Testing

- **FOSS:** new or extended mark/finish-write suite; `run-finish-scan.sh`; `run-golden-matrix.sh`; `run-unix-contract.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** write `@mise` on a temp `.sh`; `finish scan` still coherent; flip `@finish:open` → `:done` with the verb; no watcher required

## Architectural diff (fill at checkpoint)

- Assumptions hardened: `@mise` / `@finish:<state>` are emitted by `mep mark … --json`; scan/commit-scope still consume. whole-file wrap; finish `--state` is monotonic; I11 prefixes; no test-green auto-flip; no model (C9).
- Coupling increased: writer comment-style map must stay compatible with `mep_finish_line_is_language_comment`; unix-contract lists the verbs.
- Harder to change: treating `--reason` as a write target, or letting finish regress `:ratified` → `:done`.
- Easier to change: host/on-save can call the verb later; range wrap still deferred.
- **Promote to core:** none — emission is a CLI realization of C9 (no in-tree model), not a new identity row.
- **Newly interchangeable:** extension/shebang → comment style (`hash`/`slash`/`sql`/`html`/`block`) — **I12**.
- **Falsified:** none of C7–C10. title matched the product (unlike 7).

## Checkpoint

**Seam smell test:** category closed — public JSON verbs write markers. not prompt memory.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code scope (`84aa6e8`)
- [x] `git commit` → optional `/prep-pr-description mep-v0-graduation 8`
- [x] `/prep mep-v0-graduation checkpoint` → iter 9 brief
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
