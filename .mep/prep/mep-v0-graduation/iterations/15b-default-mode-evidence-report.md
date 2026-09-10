---
mepIteration: 15.1
mepTitle: Default-mode evidence report
mepStatus: committed
mepSliceType: consolidation
mepDeliveryTrack: mixed
mepFanout: sequential
mepBriefRevision: 4b3b893bb6a4c36d2cc60875dd92f27175992c28
mepImplementationRevision: 2aa8a7c657d290cc5b27db4cbf291ba172e9d387
---

# Iteration 15b — Default-mode evidence report

**Prep slug:** mep-v0-graduation
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/15b-default-mode-evidence-report.md`
**Status:** committed
**Slice type:** consolidation
**Mode:** hardening
**Delivery track:** mixed
**Fanout:** sequential (may run alongside 16 — disjoint ownership)

## Epistemic transition

**What became more certain:** default mode is proven on real work by a written record, not by the maintainer's word. The README's "in daily use on a real repo" has a citation.

**Irreversible decision (one):** the evidence artifact is a **public repo document** describing the loop as run, not a prep-tree retrospective — a stranger evaluating `mep` reads it without opening `.mep/prep/`.

**Maturity target:** `provisional → stable` (default mode only)

## Category vs instance

**Category certainty (close this slice):** a mode is "proven" when a non-fixture initiative ran the full loop and the record says what broke. 14's missing report is why default mode has no citation and autopilot/manual have no template for theirs.

**Instance certainty (this slice only):** the report covers **default mode** on the initiatives actually run (this repo's v0-graduation, plus UCG usage the operator can describe). manual and autopilot stay beta — this slice does not pilot them.

**Acceptance order:** report the loop that ran, including where it failed. do not upgrade README language beyond what the report supports.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | new `tools/mep/docs/pilot-default-mode.md`; the README "Project status" sentence about default mode **only if** the report changes what is true; `.mep/prep/mep-v0-graduation/03-core-vs-volatile.md` amendment row |
| **May know** | 14's brief and its missing-artifact deviation; this initiative's commit history as the primary evidence; `01-invariant-goal.md` success #3 |
| **Must not know** | live driver work (v0.2); 16 internals; manual/autopilot pilots; install path; curate execute semantics |
| **Invariants** | C6, C9, C11; 01 success #3 stays **deferred** — a maintainer running default mode is not a stranger with their own credentials |
| **Still provisional** | manual and autopilot remain beta; 14's host-branch `pilot-default-mode-report.md` stays absent by deviation |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `tools/mep/docs/pilot-default-mode.md` | `@reference-only` | add — evidence record, not a contract |

## Stabilizes

The README's default-mode claim. Gives manual/autopilot pilots a shape to copy when they happen.

## Macro constraints (read-only)

- C9: no live driver appears in this slice; the executor during the pilot was the **harness**, not `mep exec dispatch`
- 01 #3: not satisfied by this report — say so in the report
- I4: git history is the evidence; do not claim steps no commit supports

## Acceptance criteria (this iteration ONLY)

- [x] `tools/mep/docs/pilot-default-mode.md` exists: what was built, over how many slices, with which commits
- [x] it names **at least three** things that went wrong (e.g. `--fix` mispointing `briefRevision` at 5.1; impl-before-brief ordering at 9b/15; 14's own missing artifact) and what the loop did about each
- [x] it states plainly that the executor was an **agent harness driving the CLI**, not `mep exec dispatch` — and that autopilot/manual are unproven
- [x] it states that 01 success #3 remains open (a stranger, their credentials, three modes)
- [x] README default-mode wording matches the report; no claim is upgraded past its evidence
- [x] `run-stranger.sh`, litmus, golden matrix still green
- [x] no live driver, no install path, no 16 work

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| commit-by-commit chronology | `mechanical` | `04-iteration-roadmap.md` ledger table; `git log` |
| deviation list as the "what broke" section | `mechanical` | `manifest.deviations[]` is already that record |
| what the report is willing to claim | `finish` | — |

**Frame — claim ceiling:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| claim ceiling | a skeptic reading it cannot accuse the README of overclaiming | README "What doesn't yet"; 15's honest scope section; 01 success vs rejection | "default mode works" vs "default mode worked here, N times, and here is the failure list" | `done` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/docs/pilot-default-mode.md` | new | integration | the report |
| `README.md` | modify | integration | default-mode sentence + link **only** if the report changes what is true; do not touch Start here or Sator |
| `.mep/prep/mep-v0-graduation/03-core-vs-volatile.md` | modify | integration | amendment row |

**Conflicts:** none with 16 (`resolver.sh` / `checkpoint.sh` / `paths.sh`) — may run alongside.

**Explicitly not this slice:** live `command` driver; manual or autopilot pilot; install path; 16; backfilling 14's host-branch artifact.

## RED-phase gates (before GREEN)

- [x] no default-mode evidence document exists in the repo
- [x] README's default-mode claim rests on maintainer assertion with nothing to cite

## Approach

1. Prove RED: no such document; README claim uncited.
2. Reconstruct the chronology from `04`'s ledger + `git log` + `manifest.deviations[]`.
3. Write the failure list first — it is the part with evidentiary value.
4. State the executor honestly (harness, not dispatch) and leave #3 open.
5. Adjust the README sentence only if the report contradicts it.

## Avoid (out of scope this iteration)

- piloting manual or autopilot to "complete the set"
- building or stubbing the live `command` driver
- retiring `manifest.json` (16)
- upgrading README language past the report
- backfilling 14's original host-branch artifact

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — evidence for one mode
- [x] **Ownership minimal** — one new doc, one conditional README sentence, one amendment row
- [x] **Category before instance** — "what makes a mode proven" before piloting further modes
- [x] **One place to edit** — the report is the record; README cites it
- [x] **No planned shotgun surgery** — Avoid lists driver, 16, other modes
- [x] **Consolidation routing** — this is 14's unpaid report, closed as **15b** (after the tag) rather than smuggled into 16 or colliding with 14's existing 14b (curate dogfood)

**Preflight note:** pass. operator 2026-09-09 chose this as the next slice; may run alongside 16 (disjoint ownership). claim-ceiling finish stays `open` until the report is drafted and the operator ratifies what it asserts.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| consolidation | a skeptic can check every claim against git | pilot another mode; claim #3; ship a driver |

## Testing

- **FOSS:** `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`; `run-golden-matrix.sh`
- **Manual:** every SHA in the report resolves; every failure named has a deviation or commit behind it

## Architectural diff (fill at checkpoint)

- Assumptions hardened: "proven default mode" means a public failure list + chronology on this remote (`2aa8a7c`); the executor was the harness, not `mep exec dispatch`; 01 #3 stays open; host SHAs `954828bdd` / `64802ec14` do not resolve here.
- Coupling increased: README default-mode bullet cites `tools/mep/docs/pilot-default-mode.md`; the file is `@reference-only` (must not become a routing input).
- Harder to change: uncited "daily use" language; claiming #3 or a live driver from this record.
- Easier to change: manual/autopilot pilots copy the report shape; 16 does not own the citation.
- **Promote to core:** none — confirmed C6/C9; default-mode-as-identity stays unpromoted.
- **Newly interchangeable:** I18 (`pilot-default-mode.md` path and claim ceiling).
- **Falsified:** none of C*. the uncited README vibe claim.

## Checkpoint

**Seam smell test:** category closed as citation, not as "the mode works." failure list first. #3 not claimed. `--fix` wrote `checkpointRevision=5b37dd8` (product); stripped until docs-delta.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code/docs scope
- [x] `git commit` → product `2aa8a7c` (amended from `5b37dd8`); brief `4b3b893`
- [x] `/prep mep-v0-graduation checkpoint`
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Do not read future iterations.
> Do not ship a driver. Do not claim 01 success #3.
