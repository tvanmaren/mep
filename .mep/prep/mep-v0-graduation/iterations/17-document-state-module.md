---
mepIteration: 17
mepTitle: Document-state module
mepStatus: committed
mepSliceType: consolidation
mepDeliveryTrack: mixed
mepFanout: sequential
mepBriefRevision: b02b97e97a8161ecbc68c147c84aa0b49f307994
mepImplementationRevision: 09f8e548023f94d6d7db10d82558c2ecedcee823
mepCheckpointRevision: 09f8e548023f94d6d7db10d82558c2ecedcee823
mepImplementationPaths: []
---

# Iteration 17 — Document-state module (post-16 consolidation)

**Prep slug:** mep-v0-graduation
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/17-document-state-module.md`
**Slice type:** consolidation
**Mode:** hardening
**Delivery track:** mixed
**Fanout:** sequential

## Epistemic transition

**What became more certain:** C12's persistence grammar has one module. routing rows and frontmatter
I/O are no longer the same reason to edit `resolver.sh`.

**Irreversible decision (one):** document-state primitives (`mep_frontmatter_*`,
`mep_document_state_present`, compose helpers that are not row selection) live in
`tools/mep/lib/document.sh`. `resolver.sh` owns evaluation-order rows only.

**Maturity target:** `transitional → document-native` (module path only; grammar already C12)

## Category vs instance

**Category certainty (close this slice):** persistence I/O is a module, not a pile of helpers at the
top of the router.

**Instance certainty (this slice only):** the filename `document.sh`; which exact functions move.

**Acceptance order:** extract with identical packets, then delete the copies from `resolver.sh`. do
not restyle keys, packets, or migrate semantics.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/document.sh` (new); `tools/mep/lib/resolver.sh` (move primitives out); `tools/mep/bin/mep` source order; any test that sources resolver solely for frontmatter helpers |
| **May know** | C12, I19, C7, C8; iter 16 frontmatter grammar |
| **Must not know** | A2 phase ladder; `mep infer`; D0 live driver; changing key spellings; changing `where` / migrate packet shapes; README taste |
| **Invariants** | C7, C8, C10, C12; golden rows 1–11 unchanged; unix-contract + stranger + litmus still green |
| **Still provisional** | git heuristics for “built” (I4); dual skill/docs copies |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `tools/mep/lib/document.sh` | `@stable` | add — public persistence primitives |
| frontmatter key spellings | `@provisional` | keep — still instance (I*) |

## Stabilizes

I19. leaves A2/B/C/D unblocked rather than stacked on a 900-line router.

## Macro constraints (read-only)

- C12: documents remain the only mutable ledger
- C8: `executionRequest` still row-derived
- C7: envelope and exit still agree
- C10: litmus still composes public `mep` verbs only

## Acceptance criteria (this iteration ONLY)

- [x] `tools/mep/lib/document.sh` exists and is sourced before `resolver.sh`
- [x] `resolver.sh` no longer defines frontmatter read/write or `mep_document_state_present`
- [x] `mep_state_summary_json` still composes the same document-native packet (move it only if it is
      not row selection — prefer it lives with the documents)
- [x] `bash tools/mep/test/run-unix-contract.sh` green
- [x] `bash tools/mep/test/run-golden-matrix.sh` green with iter-5 row parity
- [x] `bash tools/mep/test/run-stranger.sh` and `scripts/litmus/slice-boundary.sh --executor stub` green
- [x] no key-spelling change; no new resolver row; no `mep infer`; no live vendor driver

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| extract persistence helpers into one lib file | `mechanical` | 16 close I19; cleaner-code one-reason-to-change; `paths.sh` already split from resolver |
| filename / exact function list | `finish` | — |

**Frame — filename:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| module name | one file; sourced by `bin/mep`; tests that unit-call primitives still work | `paths.sh`; `manifest.sh` as the dying importer | `document.sh` vs `frontmatter.sh` | `done` |

**Draft destination (operator ratifies by marking `done`):** `tools/mep/lib/document.sh`.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/document.sh` | add | domain | persistence primitives |
| `tools/mep/lib/resolver.sh` | modify | domain | rows only |
| `tools/mep/bin/mep` | modify | domain | source `document.sh` before `resolver.sh` |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | source `document.sh` if it currently sources resolver for primitives |

**Conflicts:** sequential vs resolver/bin. do not take `migrate.sh` semantics, `exec.sh`, events, docs twins except a one-line source comment if required.

**Explicitly not this slice:** A2; infer; D0; key renames; packet renames; twin hygiene.

## RED-phase gates (before GREEN)

- [x] `resolver.sh` still defines `mep_frontmatter_value` / `mep_frontmatter_set`
- [x] no `tools/mep/lib/document.sh`

## Approach

1. Prove RED: primitives live in `resolver.sh`.
2. Add `document.sh`; move functions without behavior change; source it from `bin/mep`.
3. Point unit-test sourcing at the new file.
4. Prove goldens + unix-contract unchanged.
5. Stop.

## Avoid (out of scope this iteration)

- A2 explicit slice phase ladder
- B1 `mep infer`
- D0 generic live driver
- changing `mepIteration` / `mepOwnedPaths` spellings
- making twins byte-identical

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — persistence gets one module
- [x] **Ownership minimal** — document.sh + resolver + bin + the one test that sources primitives
- [x] **Category before instance** — module seam before filename bikeshed (filename is the finish, marked `done`)
- [x] **One place to edit** — `document.sh` is the persistence home
- [x] **No planned shotgun surgery** — Avoid lists A2/B1/D0 and key/packet churn
- [x] **Consolidation routing** — 16 froze the grammar inside the router; this pays the extract

**Preflight note:** pass. queued at 16 close (`8a738e4`). operator `/mep next` is the approval.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| consolidation | behavior identical; one fewer reason to edit `resolver.sh` | change routing semantics; add infer; claim A2/D0 |

## Testing

- **FOSS:** `run-golden-matrix.sh`; `run-unix-contract.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** `mep where mep-v0-graduation --json` still composes from documents after the move

## Architectural diff (fill at checkpoint)

- Assumptions hardened: persistence I/O is a sourced module; `resolver.sh` is evaluation-order rows.
- Coupling increased: `bin/mep` and unit-test harnesses must source `document.sh` before `resolver.sh`.
- Harder to change: that source order is now a public persistence contract.
- Easier to change: A2/B1 can edit rows without touching awk frontmatter; migrate can keep its importer.
- **Promote to core:** none — the grammar was already C12; this only closed the module slot.
- **Newly interchangeable:** I19 collapsed to `tools/mep/lib/document.sh`.
- **Falsified:** frontmatter helpers living in the router as the persistence home.

## Checkpoint

**Seam smell test:** category is “one reason to change the router,” not “rename keys.” fail if packets or migrate behavior moved.

**Close (`09f8e54`):** packets and migrate untouched; I19 closed as `document.sh`. A2/B/C/D still not this slice. operator 2026-09-10: last slice; graduate rather than queue A2 here.

## After commit

- [x] `/commit-prep mep-v0-graduation`
- [x] `git commit`
- [x] `/prep mep-v0-graduation checkpoint`
- [ ] `/commit-prep mep-v0-graduation docs-delta` — close 17 + `06-graduation.md` (no iter 18)

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Do not read future iterations.
> Do not add `mep infer` or a live driver. Module-name finish is `done` (`document.sh`).
