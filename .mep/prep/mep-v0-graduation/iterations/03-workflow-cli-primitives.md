# Iteration 3 — Workflow CLI primitives & executor adapters

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/03-workflow-cli-primitives.md`  
**Status:** brief_ready  
**Slice type:** behavioral  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential  

## Epistemic transition

**What became more certain:** a shell driver can take `executionRequest` to a configured executor without reading Cursor slash strings; LLM work enters only through that adapter.

**Irreversible decision (one):** `mep exec dispatch` is the only runtime invoke of executors; the engine never calls a model.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** every current resolver kind is reachable as a CLI primitive or evidence write; `exec dispatch` consumes `{kind,target,argv}` as-is (C8).

**Instance certainty (this slice only):** `--executor stub` plus documented presets (cursor, claude-code, codex) as config rows — not working vendor SDKs. first primitive set listed below.

**Acceptance order:** dispatch + stub before extra verbs. do not invent a second packet shape. do not put vendor logic in `resolver.sh`.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | new registry verbs for this slice; `mep exec dispatch --json`; executor config keys under `.mep/config`; `adapters/README.md` (or `tools/mep/docs/` equivalent); FOSS tests that dispatch stub from a `where` packet; mode-set json if not already a verb |
| **May know** | C7/C8; iter-2 `executionRequest`; existing `lifecycle status`, `checkpoint`, `curate`, `finish scan` |
| **Must not know** | pipe litmus / `scripts/litmus/` (iter 4); golden-matrix totality / resolver positional collapse (iter 5); host `run.sh`; API keys in MEP config; `events.sh` / `pr.sh` payload redesign |
| **Invariants** | C4, C6, C7, C8; runtime never calls a model; stdout `--json` still matches process exit |
| **Still provisional** | dual skill/docs copies; vendor invoke mapping beyond stub; event-ledger still slash-shaped |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `exec dispatch` producer | `@stable` | add — public invoke seam |
| executor preset table / stub | `@provisional` | add — stub is the test double; live vendors overlay later |
| `tools/mep/test/run-unix-contract.sh` | `@provisional` | keep; extend for new verbs |

## Stabilizes

Milestone U late. Iter 4 may pipe `where` → `exec dispatch --executor stub`. it must not assume resolver arity cleanup.

## Macro constraints (read-only)

- C4: deterministic CLI; LLM only via executor
- C6: work stays on this remote
- C7: exit map
- C8: dispatch reads `executionRequest`, not `nextCommand`

## Acceptance criteria (this iteration ONLY)

- [ ] `mep exec dispatch --json` accepts an `executionRequest` object (stdin or flag); does not parse `nextCommand`
- [ ] `--executor stub` returns a deterministic json packet (`ok` / documented stub result) without network or model calls
- [ ] `.mep/config` documents `executors.default` and `executors.presets.<name>` (`kind`, `command`, env hints — no secrets)
- [ ] adapter audit doc lands: cursor, claude-code, codex, stub as preset rows; extensible registry; overrides = binary path / profile / timeout only
- [ ] `mep mode set <slug> <manual|default|autopilot> --json` writes authorship mode (initiative default)
- [ ] `mep implement --json <briefPath>` is **read-only** constitution/scope packet — does not fulfill the brief
- [ ] each current `executionRequest.kind` maps to ≥1 CLI primitive or evidence write (`prep` / `implement` / `commit_prep` / `checkpoint` / `cleanup` / `none`)
- [ ] `mep commit scope <slug> --json` and `mep evidence write --json` exist as packets (even if thin)
- [ ] `--dry-run` on effectful new verbs
- [ ] unix-contract + stranger still `status=ok`; no keys in config; no vendor code in `resolver.sh`
- [ ] no `scripts/litmus/`; no golden-matrix rewrite

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| `exec dispatch` consumes C8 packet | `mechanical` | iter-2 `executionRequest`; C4 no model in runtime |
| stub executor as test double | `mechanical` | roadmap iter 3 checkpoint; iter 4 will pipe it |
| wrap existing checkpoint/lifecycle/curate as primitives | `mechanical` | registry already has those json verbs |
| executor config key names + preset list | `finish` | public config API — chef owns the names |
| how wide “adapter audit” is (doc vs working drivers) | `finish` | blast radius |

**Frame — executor config schema:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| executor config schema | a stranger can set `executors.default=stub` and run dispatch without secrets in tree | `.mep/config` overlay keys; iter-1 registry as the other public table | `executors.default`, `executors.presets.<name>.{kind,command}` — no secrets | `ratified` |
| adapter-audit width | audit names presets and override surface; does not ship four vendor integrations | stranger CI uses stub/no overlay; cursor overlay already in-repo as commands | doc + working stub only; cursor/claude-code/codex are named preset contracts, not live SDK drivers | `ratified` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/registry.sh` | modify | domain | new verbs |
| `tools/mep/bin/mep` | modify | domain | dispatch / mode set / implement packet / commit scope / evidence |
| `tools/mep/lib/*` (new exec/config helpers as needed) | new/modify | domain | not `resolver.sh` vendor logic |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | new verb envelopes + stub dispatch |
| `tools/mep/test/run-stranger.sh` | modify | integration | stub path stays `status=ok` |
| `tools/mep/docs/README.md` | modify | integration | one getting-started sentence: pick preset |
| `tools/mep/docs/adapters.md` or `adapters/README.md` | new | integration | adapter audit; one canonical home |
| `.mep/config` schema comments / engine defaults in config reader | modify | domain | keys only; no secrets |

**Conflicts:** sequential — registry + bin + exec helper share the dispatch seam.

**Explicitly not this slice:** `tools/mep/lib/resolver.sh` internals (I8); `scripts/litmus/`; glossary evaluation-order rewrite; `events.sh` / `pr.sh` shape.

## RED-phase gates (before GREEN)

- [ ] no `mep exec` in the registry yet
- [ ] `where --json` already has `executionRequest` (C8) — consume it, do not re-derive from slash
- [ ] no executor keys in `.mep/config` yet (or only if engine defaults are absent — prove before adding)

## Approach

1. Registry + `exec dispatch` reading JSON `executionRequest`; unknown kind → `usage`/`blocked`, not a model call.
2. Stub preset: in-process or `command` that echoes kind/target/argv; unix-contract drives it from a fixture `where` packet.
3. Thin packets for `implement` (readonly), `mode set`, `commit scope`, `evidence write`; map kinds onto these plus existing checkpoint/cleanup/prep presentation.
4. Config overlay + audit doc. live vendor binaries are optional overlays, not FOSS CI.

## Avoid (out of scope this iteration)

- `scripts/litmus/` / pipe harness (iter 4)
- golden matrix; `mep_resolver_json` arity collapse (iter 5 / I8)
- API keys, prompt bodies in config
- vendor logic in `resolver.sh`
- `kind: evidence` as a routing kind (still not a resolver row)
- rewriting SKILL.md end-to-end
- host `run.sh`

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — dispatch surface + stub instance; extra verbs are the same seam
- [x] **Ownership minimal** — CLI/config/docs; resolver internals deferred
- [x] **Category before instance** — consume C8 before preset zoo
- [x] **One place to edit** — dispatch helper owns invoke; presets are data
- [x] **No planned shotgun surgery** — Avoid lists litmus/golden/I8
- [x] **Consolidation routing** — positional arity is I8/iter 5, not this slice

**Preflight note:** pass — 3 stays fat (roadmap-owned extraction). finishes ratified: config schema + stub-only drivers. iter 4 composes `mep` verbs; it must not hide product in `scripts/litmus/`.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| behavioral | workflow is invokable from shell via dispatch | rewrite resolver evaluation order; add litmus CI |

## Testing

- **FOSS:** `tools/mep/test/run-unix-contract.sh` + `run-stranger.sh`
- **host `run.sh`:** not this remote’s gate
- **Manual:** `mep where fixture-demo --json | jq .executionRequest | mep exec dispatch --json --executor stub`

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category = dispatch from `executionRequest`. fail if only a new slash alias lands.

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code scope
- [ ] `git commit` → optional `/prep-pr-description mep-v0-graduation 3`
- [ ] `/prep mep-v0-graduation checkpoint` → iter 4 brief
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
