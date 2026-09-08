# Iteration 4 — Shell litmus & pipe harness

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/04-shell-litmus-pipe-harness.md`  
**Status:** committed  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** unix compliance is an executable CI gate that pipes public `mep` verbs through `--executor stub`, not a doctrine paragraph.

**Irreversible decision (one):** `scripts/litmus/slice-boundary.sh --executor stub` is required CI for v0.1.0.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** slice-boundary proof is **composition of registry verbs** (C7/C8/C9). the harness must not grow a parallel product.

**Instance certainty (this slice only):** one script + FOSS CI step; temp workspace clone of a fixture slug; stub accept/block only.

**Acceptance order:** composition gate before extra verbs. extract a missing packet into `mep` if the walk cannot be spoken in registry usage lines. do not collapse I8.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `scripts/litmus/`; FOSS CI step that runs the litmus; unix-contract/stranger (or sibling) hook so the gate is not docs-only; one getting-started sentence in `tools/mep/docs/` |
| **May know** | C7–C9; iter-3 verbs (`where`, `exec dispatch`, `evidence write`, `commit scope`, `checkpoint`); stranger temp-root pattern |
| **Must not know** | golden-matrix totality / resolver positional collapse (I8 / iter 5); vendor SDKs; API keys; host `run.sh`; rewriting `resolver.sh` row meaning |
| **Invariants** | C4, C6, C7, C8, C9; litmus never shell-evals preset `command`; stdout `--json` still matches process exit |
| **Still provisional** | dual skill/docs copies; live vendor drivers; event-ledger still slash-shaped |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `scripts/litmus/slice-boundary.sh` | `@stable` | add — public unix-compliance gate |
| stub / command presets | `@provisional` | keep — stub remains the in-tree driver |
| `.github/workflows/stranger.yml` | `@provisional` | keep or retarget — CI still proving extract **and** litmus |

## Stabilizes

Milestone U complete (unix foundation). v0.1.0 (15) stays forbidden until this gate is green. iter 5 may then freeze resolver totality without hiding plumbing debt in tests.

## Macro constraints (read-only)

- C4: deterministic CLI; LLM only via executor
- C6: work stays on this remote
- C7: exit map
- C8: pipe `.executionRequest`, not `nextCommand`
- C9: dispatch + stub; no `eval` of command presets

## Acceptance criteria (this iteration ONLY)

- [x] `scripts/litmus/slice-boundary.sh --executor stub` exits 0 in a **temp** workspace (does not mutate committed `.mep/prep/fixture-demo` or this initiative’s manifest)
- [x] walk is only public verbs: `where` → `jq -c .executionRequest` → `exec dispatch --json --executor stub` → `evidence write` → `commit scope` → `checkpoint` → `where` (exact order may skip a no-op kind; must not call private `lib/*.sh` functions)
- [x] if a step cannot be expressed as a registry usage line, extract that verb into `tools/mep` **this slice** — do not hide it under `scripts/litmus/`
- [x] FOSS CI runs the litmus (stranger workflow job/step, not a live-vendor job)
- [x] unix-contract + stranger still `status=ok`; no API keys; no I8 arity refactor
- [x] docs: one sentence that the runtime loop is `where` → `exec dispatch` (preset optional)

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| temp-root / copy-fixture so CI is hermetic | `mechanical` | `tools/mep/test/run-stranger.sh` temp root |
| pipe `where` packet into dispatch | `mechanical` | iter-3 adapters.md recipe; C8/C9 |
| extract missing CLI if walk is inexpressible | `mechanical` | chef ratification on iter-3 brief: 4 composes verbs |
| CI attachment (extend stranger.yml vs new workflow) | `finish` | public gate location |

**Frame — CI attachment:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| CI attachment | a stranger PR that breaks the pipe fails required CI; no vendor credentials | `.github/workflows/stranger.yml`; `run-unix-contract.sh` as the other FOSS gate | recommend: add a **step/job on the existing stranger workflow**, not a second required workflow | `ratified` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `scripts/litmus/slice-boundary.sh` | new | integration | composition only |
| `scripts/litmus/**` (helpers if unavoidable) | new | integration | no product logic; prefer inline in the one script |
| `.github/workflows/stranger.yml` | modify | integration | required CI hook (unless chef picks a different attachment) |
| `tools/mep/test/run-unix-contract.sh` and/or `run-stranger.sh` | modify | integration | optional local invocation of the script |
| `tools/mep/docs/README.md` | modify | integration | runtime-loop sentence |
| `tools/mep/lib/registry.sh` + `tools/mep/bin/mep` + thin `lib/*.sh` | modify | domain | **only if** a packet is missing from the walk |
| `tools/mep/docs/adapters.md` | modify | integration | only if the pipe recipe needs a CI pointer |

**Conflicts:** sequential if a missing verb forces registry/bin edits alongside the script.

**Explicitly not this slice:** `tools/mep/lib/resolver.sh` internals (I8); golden matrix; live cursor/claude/codex drivers; SKILL.md rewrite; host `run.sh`.

## RED-phase gates (before GREEN)

- [x] `scripts/litmus/` does not exist (or is empty of a passing slice-boundary)
- [x] `.github/workflows/stranger.yml` does not invoke slice-boundary
- [x] unix-contract does not claim a litmus gate

## Approach

1. Prove RED: no litmus script/CI.
2. Write `slice-boundary.sh` as a stranger-style temp root: copy or seed a tiny slug, run the verb walk, assert each step’s json `status` and process exit (C7).
3. Dispatch **only** `--executor stub`. `--dry-run` allowed for effectful verbs when the walk must not persist into git.
4. Wire FOSS CI. if the walk is missing a verb, add the registry primitive **first**, then the script.
5. One docs sentence. do not expand adapter audit.

## Avoid (out of scope this iteration)

- canned classification / fake diffs / marker replay inside the harness (that is not what stub is)
- live-vendor CI; API keys; prompt bodies
- I8 / `mep_resolver_json` arity collapse / golden matrix (iter 5)
- vendor logic in `resolver.sh`
- mutating committed fixture-demo or `mep-v0-graduation` as the CI workspace
- rewriting SKILL.md; host `run.sh`
- install-path / stranger getting-started beyond one loop sentence (iter 9)

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — unix compliance becomes a composition CI gate
- [x] **Ownership minimal** — litmus + CI + docs sentence; product code only if a verb is missing
- [x] **Category before instance** — composition rule before extra presets
- [x] **One place to edit** — the script owns the walk; verbs stay in `mep`
- [x] **No planned shotgun surgery** — Avoid lists I8 / vendors / SKILL
- [x] **Consolidation routing** — iter 3 dispatch duplication is not debt this slice inherits

**Preflight note:** pass — 4 is the unix-foundation closer. stub remains accept/block (C9). CI attachment ratified: extend existing stranger workflow.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | pipe + CI gate; no parallel product in `scripts/litmus/` | change resolver row meaning; ship vendor drivers |

## Testing

- **FOSS:** `scripts/litmus/slice-boundary.sh --executor stub`; `tools/mep/test/run-unix-contract.sh`; `tools/mep/test/run-stranger.sh`
- **host `run.sh`:** not this remote’s gate
- **Manual:** local run of the script; optional non-CI `--executor cursor` is **not** required green

## Architectural diff (fill at checkpoint)

- Assumptions hardened: unix compliance is a composition CI gate (`slice-boundary.sh --executor stub`); the harness does not reimplement dispatch/evidence/commit-scope; fixture-demo checkpoint in that temp tree is `desync`/1 (brief_ready, not landed).
- Coupling increased: stranger workflow now installs `jq` and fails if the pipe walk breaks; docs name the same script as proof.
- Harder to change: removing the CI step or teaching the harness to `eval` preset `command` falsifies C9/C10.
- Easier to change: iter 5 can freeze resolver totality without hiding plumbing in tests — the walk is already public verbs.
- **Promote to core:** FOSS CI must run `scripts/litmus/slice-boundary.sh --executor stub` (C10).
- **Newly interchangeable:** unix-contract optionally invoking the script; stranger job still named `run-stranger`; fixture-demo as the litmus seed slug.
- **Falsified:** none of C1–C9. canned-classifier stub stayed out.

## Checkpoint

**Seam smell test:** category closed — composition of registry verbs in a temp workspace. not a parallel product.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code scope
- [x] `git commit` → optional `/prep-pr-description mep-v0-graduation 4`
- [x] `/prep mep-v0-graduation checkpoint` → iter 5 brief
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
