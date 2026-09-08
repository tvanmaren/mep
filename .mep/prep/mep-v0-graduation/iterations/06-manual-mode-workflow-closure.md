# Iteration 6 — Manual mode workflow closure

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/06-manual-mode-workflow-closure.md`  
**Status:** brief_ready  
**Slice type:** behavioral  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** a slice with `@finish:open` cannot be reported as committable in **manual** — the packet is `blocked`, not an LLM saying “done.”

**Irreversible decision (one):** incompleteness is gated by the finish-scan writeback + a JSON `status`/`exit` pair (C7), not by self-report.

**Maturity target:** `experimental → provisional`

## Category vs instance

**Category certainty (close this slice):** one “not ready” rule: `finish_open` ⇒ `blocked` on the **commit-shaped** packet (`mep commit scope`) when `authorshipMode` is `manual`. `lifecycle status --mode manual` already emits the human gate; keep that and make commit scope agree.

**Instance certainty (this slice only):** hermetic temp slug with `# @finish:open` in owned code; flip to `:done` to unblock. not this initiative’s live ledger.

**Acceptance order:** fail-closed packets before UX chrome. do not emit `@mise` (8). do not ship autopilot proxy ratification (7). do not retune resolver rows.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/workflow.sh` (`commit scope`); `tools/mep/lib/lifecycle.sh` only if the manual `finish_open` gate is incomplete; FOSS fixture under `tools/mep/test/`; docs twins of `execution-policies/manual.md` **only** if they already specify the commit packet |
| **May know** | C7; I11 / `finish.sh` scan; row 8; `mep mode set`; `checkpoint --json` blocker |
| **Must not know** | autopilot proxy (7); `@mise` wrappers (8); resolver evaluation-order / named context; litmus product growth; vendor drivers |
| **Invariants** | C7, C8, C9, C10; `# @finish:open` still detects; default `commit scope` stays `ok` unless this brief explicitly changes it; stdout `--json` still matches process exit |
| **Still provisional** | dual skill/docs copies except any manual-policy twins this slice must keep in sync; ratchet UX |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| commit-scope / lifecycle fail-closed branch | `@provisional` | add — first honest manual stop |
| finish-scan helper | `@stable` | keep — 5b |

## Stabilizes

Milestone B start. autopilot (7) may reuse the same `finish_open` blocker with a different `gate` actor.

## Macro constraints (read-only)

- C7: `blocked` exit 2
- C8: do not invent a new `executionRequest` kind
- C9: no vendor in runtime
- C10: do not weaken litmus
- I11: do not reopen `--flag` vs `-- ` (5b)

## Acceptance criteria (this iteration ONLY)

- [ ] temp slug, `authorshipMode=manual`, owned `# @finish:open`: `mep lifecycle status --mode manual --json` has `status=blocked`, a `finish_open` gate, `asksUserMidSlice=true`, action `author_open_finish`; process exit 2
- [ ] same tree: `mep commit scope <slug> --json` is `status=blocked` (not `ok`) with a named reason tied to open finishes; exit 2
- [ ] same tree: `mep checkpoint --json` remains blocked on `finish_open` (already true — do not regress)
- [ ] flipping the marker to `# @finish:done` clears `finish_open` on those packets (other findings may remain)
- [ ] a **default**-mode fixture with an open finish: `commit scope` stays `ok` (manual is opt-in); do not silently change default commit-prep
- [ ] unix-contract + golden matrix + stranger + slice-boundary litmus still green; no resolver row-table edits; no `@mise` emitter; no autopilot proxy

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| reuse `mep_finish_required_writebacks_json` | `mechanical` | `finish.sh`; checkpoint already blocks `--fix` |
| lifecycle `finish_open` → human `author_open_finish` | `mechanical` | `lifecycle.sh` already maps that gate |
| hermetic temp slug + `#` marker | `mechanical` | `run-finish-scan.sh` / golden-matrix temp roots |
| `commit scope` fail-closed in manual | `finish` | public commit-shaped packet |

**Frame — commit scope vs open finishes:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| commit scope fail-closed | manual + `finish_open` ⇒ `blocked`/exit 2; default `commit scope` still `ok`; C7 | `checkpoint --json` blocker; `lifecycle status` `blocked` | recommend: `commit scope` reads the same `finish_open` writeback; do not parse `nextCommand`; do not change default | `open` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/workflow.sh` | modify | domain | `mep_commit_scope_json` fail-closed |
| `tools/mep/lib/lifecycle.sh` | modify | domain | only if manual gate/action/exit is incomplete |
| `tools/mep/bin/mep` | modify | domain | only if commit-scope dispatch cannot pass mode/scan |
| `tools/mep/test/run-manual-workflow.sh` or extend `run-unix-contract.sh` / `run-finish-scan.sh` | new / modify | integration | fill-loop fixture |
| `tools/mep/docs/execution-policies/manual.md` | modify | integration | only if the commit packet is already specified |
| `.cursor/skills/mise-en-place/execution-policies/manual.md` | modify | integration | keep twin if touched |

**Conflicts:** sequential — commit scope + lifecycle share `finish_open`.

**Explicitly not this slice:** `resolver.sh` rows; `@mise` emission; autopilot proxy; litmus product; SKILL.md rewrite; host `run.sh`.

## RED-phase gates (before GREEN)

- [ ] `mep commit scope` on a manual fixture with `# @finish:open` still returns `status=ok`
- [ ] no FOSS suite asserts the fill-loop (open → blocked → done → not finish_open)

## Approach

1. Prove RED: commit scope `ok` despite open finish.
2. Thread `finish_open` into `mep_commit_scope_json` when manifest `authorshipMode==manual`.
3. Confirm `lifecycle status --mode manual` already `blocked` + `author_open_finish`; patch only if exit/C7 disagrees.
4. Hermetic fixture: mode set manual (or fixture manifest field), plant `# @finish:open`, assert packets; flip to `done`; re-assert.
5. Do not change default `commit scope` unless a test proves it already claimed blocked (it does not).

## Avoid (out of scope this iteration)

- autopilot proxy / provenance (7)
- mechanical `@mise` wrappers (8)
- resolver evaluation order / named context / glossary twins
- expanding litmus; vendor drivers; SKILL.md
- file-watcher runtime (invariant goal: post-v0.1)

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — manual incompleteness is a `blocked` packet
- [x] **Ownership minimal** — commit scope + fixture; lifecycle only if incomplete
- [x] **Category before instance** — fail-closed rule before extra UX
- [x] **One place to edit** — `finish_open` writeback consumed by commit scope
- [x] **No planned shotgun surgery** — Avoid lists 7/8/resolver/litmus
- [x] **Consolidation routing** — 5b scanner is assumed, not rebuilt

**Preflight note:** pass — 6 is the first Milestone B slice. commit-scope fail-closed is the one finish (recommend: same writeback, manual only).

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| behavioral | operator-visible stop: cannot treat the slice as committable while open | refactor resolver rows; ship autopilot |

## Testing

- **FOSS:** new or extended manual-workflow suite; `run-finish-scan.sh`; `run-golden-matrix.sh`; `run-unix-contract.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** `mep mode set <fixture> manual`; plant `# @finish:open`; `lifecycle status` + `commit scope` blocked; flip to `done`; packets drop `finish_open`

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category = fail-closed commit packet. fail if only docs say “don’t commit.”

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code scope
- [ ] `git commit` → optional `/prep-pr-description mep-v0-graduation 6`
- [ ] `/prep mep-v0-graduation checkpoint` → iter 7 brief (7/8 still parallel-eligible)
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
