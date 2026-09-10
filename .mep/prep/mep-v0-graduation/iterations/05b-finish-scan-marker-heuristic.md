---
mepIteration: 5.1
mepTitle: Finish-scan marker heuristic
mepStatus: committed
mepSliceType: architectural
mepDeliveryTrack: mixed
mepFanout: sequential
mepBriefRevision: a0cecb82c9a9dc1be7ad9b44960f61b68444d91d
mepImplementationRevision: f749db12c8dd0333b074439c6a506101a2e72d6b
mepCheckpointRevision: f749db12c8dd0333b074439c6a506101a2e72d6b
---

# Iteration 5b — Finish-scan marker heuristic

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/05b-finish-scan-marker-heuristic.md`  
**Status:** committed  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** `@finish` detection is a comment grammar, not a substring search that treats bash `--flags` as SQL comments.

**Irreversible decision (one):** a finish marker counts only on a language-comment line (`#`, `//`, `-- ` with a following space, `/*`, `<!--`). `--identifier` is a flag, never a comment.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** one comment-prefix rule in `mep_finish_marker_lines_json`. row 8 / checkpoint `--fix` consume that rule; they do not grow a second scanner.

**Instance certainty (this slice only):** the live false positive `tools/mep/lib/resolver.sh` `--reason "owned paths contain @finish:open"` (and any twin `--*` line) stops counting as `open`.

**Acceptance order:** heuristic first. do not “fix” dogfood by rewriting resolver copy. do not start manual-mode policy (6).

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/finish.sh`; a FOSS proof that flag-lines ≠ markers (new or extend `tools/mep/test/`); docs twins **only** if they already specify the grep |
| **May know** | `resolver.sh` as a victim of the current heuristic; C7; iter-5 goldens (must stay green) |
| **Must not know** | authorship-mode lifecycle (6–8); vendor drivers; litmus product growth; resolver evaluation-order edits |
| **Invariants** | C7, C8; `# @finish:open` (and `//` / `<!--` / `-- comment`) still detect; stdout `--json` still matches process exit |
| **Still provisional** | git “built” heuristics (I4); dual skill/docs copies except any grep-spec twins this slice must keep in sync |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `finish.sh` marker scan | `@stable` | add or keep — public readiness grep |
| test fixture planting `@finish:open` | `@stable` | keep — proof, not a decision |

## Stabilizes

Iter 5 dogfood: `mep where mep-v0-graduation` can reach checkpoint instead of a fake open finish. workflow closure (6–8) may assume the grep.

## Macro constraints (read-only)

- C7: exit map
- C8: do not change `executionRequest` derivation
- C10: do not weaken litmus
- I11: this slice *is* the home

## Acceptance criteria (this iteration ONLY)

- [x] `mep finish scan mep-v0-graduation --json` reports `counts.open == 0` on a clean tree after this slice (today: 1 hit at `resolver.sh` `--reason`)
- [x] a fixture file whose trimmed line is `--reason "…@finish:open"` is **not** a marker; `# @finish:open` **is**
- [x] `mep_has_open_finish` / row 8 use the same helper — no second grep
- [x] `tools/mep/test/run-golden-matrix.sh` still exits 0 (row 8 fixture is a `#` comment in the *temp* repo, not this heuristic)
- [x] unix-contract + stranger + slice-boundary litmus still green; no resolver row-table edits; no string-only workaround as the shipped category

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| skip `*.md` / `*/test/*` | `mechanical` | already in `mep_finish_marker_lines_json` |
| `#` `//` `/*` `<!--` as comments | `mechanical` | same helper; maturity-tags comment examples |
| `--` vs `--flag` | `finish` | SQL `-- ` vs bash `--reason` |

**Frame — `--` comment vs flag:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| `--` comment vs flag | SQL line comments still match; `--reason` / `--foo` never match | `finish.sh` existing `"--"*` arm; `resolver.sh` named `--reason` flags | recommend: require `--` + space (or end) for the SQL arm, not `--` + identifier | `done` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/finish.sh` | modify | domain | comment-prefix rule only |
| `tools/mep/test/run-*-finish*.sh` or extend an existing FOSS suite | new / modify | integration | flag-line vs `#` comment |
| `tools/mep/docs/maturity-tags.md` | modify | integration | only if the grep is already specified there |
| `.cursor/skills/mise-en-place/maturity-tags.md` | modify | integration | keep twin if maturity-tags is touched |

**Conflicts:** sequential — helper + test share the grep seam.

**Explicitly not this slice:** `resolver.sh` evaluation order / named context; `scripts/litmus/` product; mode policy docs; SKILL.md; goldens row meanings.

## RED-phase gates (before GREEN)

- [x] `mep finish scan mep-v0-graduation --json` still has `open >= 1` on `resolver.sh` `--reason`
- [x] `mep_finish_marker_lines_json` still matches `"--"*` (any `--` prefix)

## Approach

1. Prove RED: current scan packet (path + line + `--reason` text).
2. Narrow the `--` arm to SQL comments (`--` + space or end). keep other prefixes.
3. Add a hermetic fixture (temp file or suite case): flag line ignored; `# @finish:open` counted.
4. Re-scan this initiative: zero open. do not edit resolver copy unless a test still fails for a non-`--` reason.

## Avoid (out of scope this iteration)

- rewriting `resolver.sh` reason strings as the category (instance dodge)
- manual/autopilot execution policy (6–8)
- litmus / vendor / I8 / glossary row table
- treating `finish.sh` jq `detail:` strings as a second class of false positive unless the same prefix rule catches them

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — finish-scan comment grammar
- [x] **Ownership minimal** — `finish.sh` + proof; docs only if they already specify the grep
- [x] **Category before instance** — prefix rule before copy-editing resolver
- [x] **One place to edit** — `mep_finish_marker_lines_json`
- [x] **No planned shotgun surgery** — Avoid lists resolver totality / modes / litmus
- [x] **Consolidation routing** — this *is* the debt from iter 5, not a feature slice carrying it into 6

**Preflight note:** pass — 5b is the scanner seam. `--` vs `--flag` is the one finish (recommend `--` + space).

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | comment-prefix rule; row 8 uses it | change resolver rows; ship mode policy |

## Testing

- **FOSS:** new or extended finish-scan suite; `run-golden-matrix.sh`; `run-unix-contract.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** `mep finish scan mep-v0-graduation --json` → open 0; `mep where mep-v0-graduation --json` → not row 8 from this hit

## Architectural diff (fill at checkpoint)

- Assumptions hardened: finish markers are language comments (`#` `//` `-- ` `/*` `<!--`); `--reason` is a flag; one helper feeds scan, row 8, and checkpoint blockers.
- Coupling increased: unix-contract now runs `run-finish-scan.sh`.
- Harder to change: widening `"--"*` again re-breaks this slug and the hermetic flag fixture.
- Easier to change: comment grammar is one function; resolver copy stays mention-safe.
- **Promote to core:** none — grep honesty is still I11, not a new C*.
- **Newly interchangeable:** whether stranger CI must invoke `run-finish-scan.sh` directly (unix-contract already does).
- **Falsified:** none of C7–C10. the 5b dogfood bounce is gone (`finish scan` open 0). `--fix` later wrote `briefRevision=ab9fc9b` (acceptance tick); corrected to brief birth `a0cecb8`, impl/checkpoint `f749db1`.

## Checkpoint

**Seam smell test:** category closed — comment grammar in `mep_finish_line_is_language_comment`. not a resolver string edit.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code scope (`f749db1`)
- [x] `git commit` → optional `/prep-pr-description mep-v0-graduation 5b`
- [x] `/prep mep-v0-graduation checkpoint` → iter 6 brief
- [x] `/commit-prep mep-v0-graduation docs-delta` (`46895d9`)

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
