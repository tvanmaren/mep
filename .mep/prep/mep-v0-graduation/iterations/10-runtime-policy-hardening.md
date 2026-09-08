# Iteration 10 — Runtime ≠ policy hardening

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/10-runtime-policy-hardening.md`  
**Status:** brief_ready  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential (11 may start in parallel only if this slice does not take `events.sh`)

## Epistemic transition

**What became more certain:** `authorshipMode` is **policy**. it changes lifecycle/commit-scope actors, not `where` routing. the resolver remains a pure function of persisted workflow state + git.

**Irreversible decision (one):** for one slug and one set of workflow facts, `mep where --json` `proof.row` and `executionRequest` `{kind,target,argv}` are identical under `manual`, `default`, and `autopilot`.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** one invariant, test-guarded: mode is not a resolver input. C8 stays row→packet; C7 still pairs JSON status with exit; policy lives in lifecycle / commit-scope / execution-policies.

**Instance certainty (this slice only):** hermetic fixture(s) covering at least one `where` row that 6/7 already touch via finish-scan (so a leak would be visible), plus a docs sentence naming the three layers (runtime / executor / authorship policy).

**Acceptance order:** failing RED (no mode-loop on `where`) before GREEN. do not “fix” a green `where` by special-casing mode in `resolver.sh`.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | FOSS proof that `where` is mode-invariant (extend `tools/mep/test/run-golden-matrix.sh` **or** add a dedicated hermetic suite hooked from `run-unix-contract.sh`); docs that already claim the boundary (`tools/mep/docs/README.md` / glossary / execution-policies twins, `.cursor/skills/mise-en-place/**` copies) — **only** the sentence that states the three layers, not a SKILL rewrite |
| **May know** | C7, C8, C9; `mep mode set`; `authorshipMode` on lifecycle + `commit scope` (6/7); golden-matrix fixture helper; glossary evaluation order as **read-only spec** |
| **Must not know** | new resolver rows; `mep mark`; event ledger (`events.sh` — 11); CONTRIBUTING (12); packaging (15); live Task/LLM proxy; vendor SDKs |
| **Invariants** | C7, C8, C9, C10; 6/7 `commit scope` packets stay as landed; `resolver.sh` does not grow an `authorshipMode` branch unless a test proves a leak **and** the fix restores invariance (no new row) |
| **Still provisional** | actual autopilot host dispatch; dual skill/docs copies except the one three-layer sentence this slice must keep in sync |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| mode-invariant `where` suite | `@provisional` | add |
| `resolver.sh` | `@stable` | keep — do not retag as this slice’s invention |
| 6/7 commit-scope arms | `@provisional` | keep |

## Stabilizes

Milestone C continues. 11 may assume `where` is not a mode switch. 7’s leftover (running proxy) stays out.

## Macro constraints (read-only)

- C8: durable action is `executionRequest` from resolver **row**
- C7: JSON `status` and `$?` never disagree
- C9: no in-tree live driver; do not `eval` preset `command`
- C10: do not grow litmus product to re-prove routing

## Acceptance criteria (this iteration ONLY)

- [ ] RED: today no FOSS test asserts `where` packet equality across `manual`/`default`/`autopilot` on the same slug/state
- [ ] GREEN: hermetic suite fails if any of the three modes changes `proof.row` or `executionRequest` for that fixture
- [ ] fixture includes a state 6/7 already distinguish (owned `# @finish:open` is enough — `where` must still match; `commit scope` may still differ)
- [ ] docs name three layers: runtime (`where`/envelope/litmus), executor (`exec dispatch` / stub), authorship policy (lifecycle + execution-policies). no fourth “resolver mode” layer
- [ ] `resolver.sh` still has no `authorshipMode` branch (or a leak-fix that removes one — never a new evaluation-order row)
- [ ] `bash tools/mep/test/run-unix-contract.sh` green; `run-golden-matrix.sh` still green; stranger + litmus unchanged
- [ ] no vendor SDK; no `events.sh` product; no 6/7 packet rewrite

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| hermetic temp slug + `mep where --json` | `mechanical` | `run-golden-matrix.sh` / `run-manual-workflow.sh` fixture |
| loop three `mep mode set` values, compare packets | `mechanical` | unix-contract jq equality |
| hook suite from `run-unix-contract.sh` | `mechanical` | `run-mark.sh` hook |
| keep 6/7 commit-scope fail-closed | `mechanical` | landed `workflow.sh` arms |
| three-layer operator sentence | `finish` | where the boundary is named without inventing a fourth layer |

**Frame — three-layer sentence:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| layer names | a stranger reading getting-started/glossary can tell routing ≠ executor ≠ authorship gate | README “connecting your own agent”; `execution-policies/*.md` vs `resolver` glossary | one paragraph in foss docs + skill twin vs glossary-only | `open` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/test/run-golden-matrix.sh` | modify | integration | **or** leave and add a sibling suite |
| `tools/mep/test/run-mode-resolver.sh` | new | integration | only if golden matrix should stay row-coverage, not mode-coverage |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | hook the new/extended proof |
| `tools/mep/docs/README.md` | modify | integration | three-layer sentence if this is the foss getting-started twin |
| `tools/mep/docs/glossary.md` | modify | integration | **only** if the resolver intro is the one place that must deny mode-as-input |
| `.cursor/skills/mise-en-place/README.md` | modify | integration | twin of docs README if that copy is edited |
| `.cursor/skills/mise-en-place/glossary.md` | modify | integration | twin if glossary is edited |
| `tools/mep/lib/resolver.sh` | modify | domain | **only** to restore invariance if RED finds a leak — no new rows |

**Conflicts:** sequential vs 11 if this slice takes `events.sh` (it must not). glossary twins are this slice’s conflict, not 11’s.

**Explicitly not this slice:** `mark.sh`; `events.sh`; `workflow.sh` commit-scope rewrite; SKILL.md prime directive; CONTRIBUTING; README Start here (9); v0.1.0 tag.

## RED-phase gates (before GREEN)

- [ ] `rg authorshipMode tools/mep/lib/resolver.sh` is empty (or document the leak as the GREEN fix)
- [ ] no existing suite compares `where` across three modes on one fixture

## Approach

1. Prove RED: no mode-loop on `where`; `resolver.sh` has no `authorshipMode`.
2. Hermetic fixture: same owned paths / iteration status; `mep mode set` through the three values; assert `where` packets equal. include `# @finish:open` so a mistaken “mode belongs in where” would fire.
3. Hook into unix-contract. do not duplicate golden row tables unless extending that file is smaller.
4. One docs sentence for the three layers. keep twins in sync if you touch a copied node.
5. If a leak exists: restore invariance (mode is not a resolver input). do not add a row.

## Avoid (out of scope this iteration)

- another `commit scope` mode arm (6/7 landed)
- live proxy / Task dispatch
- `mep mark` / watcher
- event ledger / `events.sh` (11)
- CONTRIBUTING taste (12)
- PATH/package / Sator Square (15)
- rewriting README Start here (9 / I13)
- teaching `where` to read `authorshipMode` as a feature

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — `where` is mode-invariant; docs name the layers
- [x] **Ownership minimal** — test hook + the docs node that already states the boundary; resolver only on leak
- [x] **Category before instance** — invariant before a fourth-layer essay
- [x] **One place to edit** — the suite is the guard; docs are one sentence, not a second resolver
- [x] **No planned shotgun surgery** — Avoid lists 6/7 rewrite, 11, 12, 15, mark
- [x] **Consolidation routing** — 9 was install copy; this is the C8/C7 guard 6/7 left untested, not leftover 9

**Preflight note:** pass — 6/7 proved policy on commit-scope; this slice proves policy is **not** on `where`. one finish: where the three layers are named.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | mode does not change `where` row/packet; docs match | change user-visible stranger Start here; add resolver rows |

## Testing

- **FOSS:** new or extended mode-invariant `where` suite; `run-golden-matrix.sh`; `run-unix-contract.sh`; `run-manual-workflow.sh` (6/7 still green); `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** `mep mode set <slug> manual` then `where` on a known slug — packet matches `default`

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category = `where` ignores mode. fail if the slice only restates execution-policies or retunes 6/7 packets.

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code scope
- [ ] `git commit` → optional `/prep-pr-description mep-v0-graduation 10`
- [ ] `/prep mep-v0-graduation checkpoint` → iter 11 brief (or 11 if 10/11 parallel already briefed)
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
