---
mepIteration: 12
mepTitle: Curation externalized
mepStatus: committed
mepSliceType: consolidation
mepDeliveryTrack: mixed
mepFanout: sequential
mepBriefRevision: 1e8df2673bdfc58a39327857e9e8c153bf5c03c4
mepImplementationRevision: 8af941fad7ed474346b8526ecc1d0e884a15c37c
mepCheckpointRevision: 8af941fad7ed474346b8526ecc1d0e884a15c37c
---

# Iteration 12 — Curation externalized (authoring taste)

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/12-curation-externalized.md`  
**Status:** committed  
**Slice type:** consolidation  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential (15 packaging; 13 leftover CONTRIBUTING AC)

## Epistemic transition

**What became more certain:** a stranger can author against this repo from **CONTRIBUTING + in-tree examples**, not from the author's head. routing still lives in the glossary table (C8).

**Irreversible decision (one):** CONTRIBUTING is the authoring surface. 15 may only check the file exists at tag time. do not fork the resolver table into CONTRIBUTING.

**Maturity target:** `absent → provisional`

## Category vs instance

**Category certainty (close this slice):** authoring taste is a repo artifact. 0 deferred this as improvement-after-extract. 13's leftover “CONTRIBUTING documents curate” is this slice, not a reopen of 13.

**Instance certainty (this slice only):** root `CONTRIBUTING.md` plus 2–3 canonical pointers: `fixture-demo` (worked `where` loop), `tools/mep/examples/profiles/example-stub.md` (profile retarget), curate fixture / outline (preview → execute). fill only what is missing; do not duplicate README Start here.

**Acceptance order:** truthful CONTRIBUTING before tag (15). not a live-executor dogfood (01 success #3). not another already-true CLI proof suite.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `CONTRIBUTING.md` (new); `tools/mep/examples/**` only to add/point at the 2–3 samples; skill/docs profile twins **only** if CONTRIBUTING would send a stranger to a stale path; optional `run-stranger.sh` grep that CONTRIBUTING exists and names curate + profile retarget |
| **May know** | C1–C5, C6, C8, C9; README Start here (9, read-only); `event-ledger.md` / `events tail` (11, mention only); `.mep/plans/mep-curate-outline.md`; 13 product already shipped |
| **Must not know** | v0.1.0 tag / Sator / LICENSE rewrite (15); live vendor SDK / credentials (C9, success #3); resolver/event/mode suites (5/10/11); `manifest.json` retirement (16); I5 host pointer |
| **Invariants** | C6, C8, C9, C10; glossary remains the routing contract; stub stays CI/fixture; no second Start-here |
| **Still provisional** | dual skill/docs copies; PATH package (15); live command-preset drivers |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| n/a | n/a | docs/examples slice — no product `@` tags unless a grep helper lands (`@provisional`) |

## Stabilizes

v0.1 authoring contract that 0 left as follow-up. 13 leftover CONTRIBUTING AC. 15 packaging may assume the file exists.

## Macro constraints (read-only)

- C1–C5: curate is communication; preview then execute; lab sacred
- C6: standalone repo is already the home
- C8: do not invent a second resolver table in CONTRIBUTING
- C9: no in-tree live driver
- C10: do not grow litmus to re-prove docs

## Acceptance criteria (this iteration ONLY)

- [x] `CONTRIBUTING.md` at repo root: how to retarget a profile, how to author a brief/checkpoint, how `/mep curate` preview → execute works (closes 13 leftover)
- [x] 2–3 canonical examples exist **or** are linked without author context: `fixture-demo`, `example-stub`, curate fixture/outline
- [x] glossary / resolver table is **not** copied into CONTRIBUTING (pointer only)
- [x] README Start here (9) gains at most a one-line link to CONTRIBUTING — no recipe rewrite
- [x] 15 still owns tag / Sator / honest scope table; this slice does not tag
- [x] FOSS: `run-stranger.sh` and litmus still green; optional grep-lock that CONTRIBUTING exists. **no** new `run-*.sh` that only restates already-green CLI
- [x] no live executor, no credentials, no 10/11 suite rewrite

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| CONTRIBUTING sections | `finish` | what a stranger must do without asking the author |
| example pointers / missing sample | `mechanical` | `tools/mep/examples/profiles/example-stub.md`; `fixture-demo`; curate tests/outline |
| optional stranger grep | `mechanical` | `run-stranger.sh` README token lock (9) |
| leave glossary as routing SSOT | `mechanical` | C8 / iter 5 golden |

**Frame — CONTRIBUTING authoring surface:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| stranger can author | CONTRIBUTING + examples replace author memory for profile, brief, curate | README Start here; `example-stub.md`; `mep-curate-outline.md` | one CONTRIBUTING vs burying taste in 15 README | `done` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `CONTRIBUTING.md` | new | integration | authoring surface |
| `tools/mep/examples/profiles/README.md` | modify | integration | point at stub; no host private profile |
| `tools/mep/examples/profiles/example-stub.md` | modify | integration | only if the skeleton lies |
| `.cursor/skills/mise-en-place/profiles/example-stub.md` | modify | integration | twin **only** if path would rot |
| `README.md` | modify | integration | one-line CONTRIBUTING link max |
| `tools/mep/test/run-stranger.sh` | modify | integration | optional existence/token grep |
| `.mep/prep/mep-v0-graduation/iterations/13-integration-curation.md` | modify | integration | tick CONTRIBUTING AC only at close |

**Conflicts:** sequential vs 15 (tag). do not take `resolver.sh` / `events.sh` / `workflow.sh`.

**Explicitly not this slice:** live executor in three modes (01 #3); v0.1.0 tag; Sator; LICENSE; another observability/routing suite; SKILL.md prime directive; I5.

## RED-phase gates (before GREEN)

- [x] no root `CONTRIBUTING.md`
- [x] 13 still has an open “CONTRIBUTING documents curate” checkbox

## Approach

1. Inventory existing examples. do not invent a fourth copy of README Start here.
2. Write CONTRIBUTING: profile retarget, brief/checkpoint loop, curate preview→execute, pointer to glossary for `where`.
3. Add only the missing canonical sample (likely a curate walkthrough pointer).
4. Optional stranger grep. do not add `run-contributing.sh`.
5. One-line README link if the Start here would otherwise dead-end.

## Avoid (out of scope this iteration)

- 01 success #3 (stranger + real executor + three modes)
- v0.1.0 tag / Sator / scope table (15)
- live vendor SDK / API keys
- copying the resolver table into CONTRIBUTING
- rewriting 10/11 suites or `event-ledger.md`
- PATH install / packaging
- reopening 13 product

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — authoring taste leaves the author's head
- [x] **Ownership minimal** — CONTRIBUTING + example pointers + optional grep
- [x] **Category before instance** — authoring contract before tag (15)
- [x] **One place to edit** — CONTRIBUTING is the surface; examples are cited
- [x] **No planned shotgun surgery** — Avoid lists tag, live executor, suite locks
- [x] **Consolidation routing** — 10/11 were test locks; this is the deferred 0/13 docs dump, not a fourth lock

**Preflight note:** pass — 12 is real missing artifacts (`CONTRIBUTING.md` absent). recommended over skipping to success #3 (that's a different category and punches C9 if it ships a driver). human gate 2026-09-09: keep drafted contract.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| consolidation | stranger can follow profile + brief + curate without asking | tag v0.1.0; ship a live driver; fork routing into CONTRIBUTING |

## Testing

- **FOSS:** `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`; optional CONTRIBUTING grep
- **Manual:** clone-and-read CONTRIBUTING; follow profile copy recipe; find curate preview/execute without opening this prep tree

## Architectural diff (fill at checkpoint)

- Assumptions hardened: a stranger can retarget a profile, write a slice, and curate without asking the maintainer; glossary remains the routing table; `mep curate --preview` is status, not plan synthesis (C4).
- Coupling increased: `run-stranger.sh` greps CONTRIBUTING for `curate` / `example-stub` / `profile`.
- Harder to change: burying authoring taste in README Start here or the 15 tag notes.
- Easier to change: 15 may assume CONTRIBUTING exists and only verify it.
- **Promote to core:** none — confirmed C1–C5, C4, C8; no C12.
- **Newly interchangeable:** **I17** — CONTRIBUTING + example paths.
- **Falsified:** that `--preview` on the CLI proposes the curation plan. it reports artifact/manifest/git status; synthesis is `/mep curate <slug>` (agent).

## Checkpoint

**Seam smell test:** category closed as repo artifacts, not a fourth green suite. Sator/tag stayed out. C4 lie in the first draft was caught at commit-prep and rewritten before `8af941f`.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code/docs scope
- [x] `git commit` → `8af941f`
- [x] `/prep mep-v0-graduation checkpoint` → iter 15 brief
- [x] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Do not read future iterations.
