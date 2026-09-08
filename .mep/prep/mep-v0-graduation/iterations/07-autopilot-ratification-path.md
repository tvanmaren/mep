# Iteration 7 — Autopilot ratification path

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/07-autopilot-ratification-path.md`  
**Status:** committed  
**Slice type:** behavioral  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** open finishes in **autopilot** bounce to a **proxy** gate, not the human conversant — and the commit-shaped packet is `blocked`, same C7 pair as manual.

**Irreversible decision (one):** autopilot reuses the `finish_open` writeback with `gate=proxy`; runtime still does not call a model (C9). the host/executor occupies the chef seat.

**Maturity target:** `experimental → provisional`

## Category vs instance

**Category certainty (close this slice):** `authorshipMode=autopilot` + `finish_open` ⇒ `mep commit scope` `blocked`/exit 2; `lifecycle status --mode autopilot` has a `finish_open` gate with `gate=proxy` / `dispatch_proxy_finish_author`, `asksUserMidSlice=false` (no human gate on that path). default and manual packets from 6 do not change.

**Instance certainty (this slice only):** hermetic temp slug in autopilot with `# @finish:open`; flip to `:done` (and a `:ratified` line with proxy provenance if the writeback requires it). not live dispatch of a Cursor Task.

**Acceptance order:** fail-closed packets before shipping a runtime LLM proxy. do not emit `@mise` (8). do not retune resolver rows.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/workflow.sh` (`commit scope` for autopilot); `tools/mep/lib/lifecycle.sh` only if the proxy `finish_open` gate/action/exit is incomplete; FOSS fixture under `tools/mep/test/`; docs twins of `execution-policies/autopilot.md` **only** if they already specify these packets |
| **May know** | C7, C9; I11 / `finish.sh` (`finish_missing_proxy_provenance`); iter-6 manual `commit scope` branch; `mep mode set` |
| **Must not know** | `@mise` wrappers (8); resolver evaluation-order / named context; litmus product growth; vendor SDKs in `tools/mep/lib` |
| **Invariants** | C7, C8, C9, C10; manual + default `commit scope` behavior from 6 stays; stdout `--json` still matches process exit; runtime never `eval`s a model |
| **Still provisional** | actual host Task/scout dispatch of the chef-proxy; dual skill/docs copies except any autopilot-policy twins this slice must keep in sync |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| commit-scope autopilot fail-closed branch | `@provisional` | add — first honest autopilot stop |
| lifecycle `finish_open` → proxy | `@provisional` | add or keep if touched |
| finish-scan helper | `@stable` | keep — 5b |

## Stabilizes

Milestone B continues. 8 may assume proxy vs human is a gate actor, not a second scanner.

## Macro constraints (read-only)

- C7: `blocked` exit 2
- C8: do not invent a new `executionRequest` kind
- C9: no vendor SDK / no runtime model call; proxy dispatch is host/executor, not `mep exec` evaluating a prompt
- C10: do not weaken litmus
- I11: do not reopen `--flag` vs `-- ` (5b)

## Acceptance criteria (this iteration ONLY)

- [x] temp slug, `authorshipMode=autopilot`, owned `# @finish:open`: `mep lifecycle status --mode autopilot --json` has `status=blocked`, a `finish_open` gate with `gate=proxy` and `action=dispatch_proxy_finish_author`; `asksUserMidSlice=false`; process exit 2
- [x] same tree: `mep commit scope <slug> --json` is `status=blocked` / `reason=finish_open`; exit 2
- [x] same tree: `mep checkpoint --json` still blocked on `finish_open` (do not regress)
- [x] flipping to `# @finish:done` clears `finish_open` on those packets (other findings may remain, including proxy-provenance on `:ratified` without `proxy`/`autopilot` in the line)
- [x] **manual** fixture from 6 still: open finish ⇒ commit scope blocked; **default** still: open finish ⇒ commit scope `ok`
- [x] unix-contract + golden matrix + stranger + slice-boundary litmus still green; no resolver row-table edits; no `@mise` emitter; no in-tree LLM/Task dispatch

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| lifecycle `finish_open` → `gate=proxy` | `mechanical` | `lifecycle.sh` already maps that for `--mode autopilot` |
| reuse `finish_open` writeback in commit scope | `mechanical` | iter 6 `mep_commit_scope_json` manual arm |
| hermetic temp slug | `mechanical` | `run-manual-workflow.sh` |
| autopilot commit-scope fail-closed | `finish` | public commit-shaped packet for a third mode |
| in-process Task/LLM proxy dispatch | out of scope | C9 — host occupies the chef seat |

**Frame — commit scope vs open finishes (autopilot):**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| autopilot commit scope fail-closed | autopilot + `finish_open` ⇒ `blocked`/exit 2; 6's manual/default arms unchanged; C7; C9 | `commit scope` manual arm; lifecycle proxy `finish_open` | recommend: same writeback, treat `autopilot` like `manual` for the commit packet (not default); do not parse `nextCommand`; do not spawn a model from `tools/mep/lib` | `done` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/workflow.sh` | modify | domain | `mep_commit_scope_json` autopilot arm |
| `tools/mep/lib/lifecycle.sh` | modify | domain | only if proxy gate/action/`asksUserMidSlice` is incomplete |
| `tools/mep/bin/mep` | modify | domain | only if dispatch cannot pass mode/scan |
| `tools/mep/test/run-manual-workflow.sh` or `tools/mep/test/run-autopilot-workflow.sh` | modify / new | integration | fill-loop; keep 6's default/manual cases |
| `tools/mep/docs/execution-policies/autopilot.md` | modify | integration | only if the packets are already specified |
| `.cursor/skills/mise-en-place/execution-policies/autopilot.md` | modify | integration | keep twin if touched |

**Conflicts:** sequential — commit scope + lifecycle share `finish_open`. 8 is still parallel-eligible (markers vs this policy surface).

**Explicitly not this slice:** `resolver.sh` rows; `@mise` emission; spawning Cursor Task / vendor SDK; litmus product; SKILL.md rewrite; host `run.sh`.

## RED-phase gates (before GREEN)

- [x] `mep commit scope` on an autopilot fixture with `# @finish:open` still returns `status=ok`
- [x] no FOSS suite asserts autopilot fill-loop (open → proxy-blocked → done → not finish_open)

## Approach

1. Prove RED: autopilot + open finish, commit scope `ok` (6 only gated `manual`).
2. Thread `finish_open` into `mep_commit_scope_json` when `authorshipMode==autopilot` (same writeback as manual).
3. Confirm `lifecycle status --mode autopilot` already `blocked` + proxy action + `asksUserMidSlice=false`; patch only if C7/gate disagrees.
4. Hermetic fixture: mode set autopilot, plant `# @finish:open`, assert packets; flip to `done`; re-assert; keep 6's default/manual cases green.
5. Do not add a runtime model call. do not change default `commit scope`.

## Avoid (out of scope this iteration)

- mechanical `@mise` wrappers (8)
- in-tree LLM / Task / scout dispatch of the chef-proxy (C9 — host overlay)
- resolver evaluation order / named context / glossary twins
- expanding litmus; vendor drivers; SKILL.md
- changing manual/default commit-scope behavior from 6
- file-watcher runtime

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — autopilot incompleteness is a proxy gate + blocked commit packet
- [x] **Ownership minimal** — commit scope + fixture; lifecycle only if incomplete
- [x] **Category before instance** — fail-closed packets before live proxy dispatch
- [x] **One place to edit** — `finish_open` writeback consumed by commit scope
- [x] **No planned shotgun surgery** — Avoid lists 8 / runtime LLM / resolver / litmus
- [x] **Consolidation routing** — 6's trap-hygiene commit is not this slice's debt

**Preflight note:** pass — 7 is the autopilot actor on the same substrate. one finish: commit-scope fail-closed for autopilot (recommend: same writeback as manual).

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| behavioral | operator-visible: autopilot does not ask the human mid-slice for `finish_open`; commit packet blocked | emit `@mise`; ship a vendor driver |

## Testing

- **FOSS:** extend `run-manual-workflow.sh` or add `run-autopilot-workflow.sh`; `run-finish-scan.sh`; `run-golden-matrix.sh`; `run-unix-contract.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **Manual:** `mep mode set <fixture> autopilot`; plant `# @finish:open`; `lifecycle status --mode autopilot` + `commit scope` blocked; flip to `done`; `finish_open` drops

## Architectural diff (fill at checkpoint)

- Assumptions hardened: `authorshipMode=autopilot` + `finish_open` ⇒ `commit scope` `blocked`/`finish_open`/exit 2 (same writeback as manual). default still `ok`. lifecycle proxy `finish_open` was already true; this slice did not invent it.
- Coupling increased: one more disjunct on `mep_commit_scope_json` (`manual || autopilot`).
- Harder to change: calling autopilot “default-like” on the commit packet would let open finishes through.
- Easier to change: `@mise` emission (8) stays a writer, not another packet arm.
- **Promote to core:** none — C7 on the commit packet for a third mode; **not** a ratification engine.
- **Newly interchangeable:** none.
- **Falsified:** the brief title/category overclaimed a running proxy. landed product is mode parity on C7. `lifecycle.sh` / `autopilot.md` / Task dispatch were not this commit (`092ade7`).

## Checkpoint

**Seam smell test:** category closed as **mode parity on C7**, not a proxy runtime. fail the story if someone reads “ratification path” as Task dispatch.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code scope (`092ade7`)
- [x] `git commit` → optional `/prep-pr-description mep-v0-graduation 7`
- [x] `/prep mep-v0-graduation checkpoint` → iter 8 brief
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
