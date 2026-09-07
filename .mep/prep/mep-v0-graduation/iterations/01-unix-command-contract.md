# Iteration 1 — Unix command contract

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/01-unix-command-contract.md`  
**Status:** brief_ready  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential  

## Epistemic transition

**What became more certain:** every machine-facing `mep` command shares one shell contract — `--json` on stdout, diagnostics on stderr, **exit codes aligned with JSON `status`** — so `set -e` scripts can branch without `jq`.

**Irreversible decision (one):** the exit-code taxonomy is public API; breaking it is semver-major.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** one envelope + one exit map for all machine-facing commands. Registry is the source of truth for help/tests/docs.

**Instance certainty (this slice only):** the current `mep` subcommands (`config dump`, `where`, `status`, `checkpoint`, `finish scan`, `lifecycle status`, `curate`, `doctor`, `events tail`, `pr scaffold`, `check scaffolding`, `paths`, `profile dump`). No new product verbs.

**Acceptance order:** taxonomy + envelope first; then convert each existing command onto it. Do not invent `executionRequest` here.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/bin/mep`; command registry (one table the CLI, help, and tests read); `tools/mep/lib/deps.sh` exit mapping for `missing_dependency`; FOSS tests that prove exit + stderr discipline; CLI usage/help text |
| **May know** | current JSON `status` strings; `mep_require` / `mep_usage`; `tools/mep/test/run-stranger.sh` as the other FOSS gate |
| **Must not know** | `executionRequest` (iter 2); executor presets / adapters (iter 3); pipe litmus / `--executor stub` (iter 4); host `tools/mep/test/run.sh`; host `wiki/prep` |
| **Invariants** | C6 (work stays on this remote); runtime never calls a model; JSON `status` and process exit must not disagree |
| **Still provisional** | dual skill/docs copies; resolver totality (iter 5) |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| command registry / exit-map module | `@stable` | add — public shell contract |
| `tools/mep/test/run-stranger.sh` | `@provisional` | keep — still the extract gate, not this suite |

## Stabilizes

Milestone U start. Iter 2+ may assume `mep where --json` exit matches `.status`.

## Macro constraints (read-only)

- C6: ship from standalone remote
- Rejection: commands must not return exit 0 for `blocked` / `desync` / `gated`

## Acceptance criteria (this iteration ONLY)

- [ ] Documented taxonomy (exact table in this brief) is implemented; JSON `status` → process exit never disagrees
- [ ] `--json` is stdout-only; usage/diagnostics on stderr; success leaves stderr empty
- [ ] `mep help` and `mep version` exist; usage on stderr; help/version derive from the registry
- [ ] Every current machine-facing command is on the envelope (including `check scaffolding` — `--json` or a subcommand with the same envelope)
- [ ] Conformance tests in FOSS `tools/mep/test/` (not host `run.sh`): stderr empty on success; fixture packets for 0 / 1 / 2 / 3 / 64
- [ ] `run-stranger.sh` still green; this slice does not weaken the no-config defaults proof
- [ ] No `executionRequest` field; no executor preset work

### Exit taxonomy (public API)

| JSON `status` (or condition) | exit |
|------------------------------|------|
| `ok` / `clean` | 0 |
| `desync` / `gated` / `warning` | 1 |
| `blocked` / `missing_dependency` | 2 |
| `not_found` | 3 |
| usage / bad argv | 64 |
| internal error | 70 |

Today: `mep_usage` exits **2**; `mep_require` returns **3**. This slice **changes** those to the table above.

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| exit-code taxonomy (table above) | `finish` | public API — chef owns the numbers |
| registry as single table feeding help/tests | `mechanical` | this brief; one table, three readers |
| wrap each existing command in the envelope | `mechanical` | taxonomy + registry once ratified |
| `check scaffolding` → json envelope | `mechanical` | same envelope; no new semantics |
| FOSS conformance tests | `mechanical` | this brief’s Testing section |

**Frame — exit taxonomy:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| exit taxonomy | `set -e` scripts branch on exit without `jq`; JSON `status` never lies about the exit | sysexits 64/70; current `mep_usage`=2 vs `mep_require`=3 (conflict to resolve) | which statuses share an exit vs get their own (esp. `desync` vs `blocked` vs `not_found`)? | `open` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/bin/mep` | modify | domain | dispatch + help/version + exit |
| `tools/mep/lib/deps.sh` | modify | domain | `missing_dependency` exit 2 |
| new registry module under `tools/mep/lib/` | new | domain | one table |
| `tools/mep/test/*` unix-contract suite | new | integration | FOSS only |
| `tools/mep/test/run-stranger.sh` | modify | integration | only if envelope change breaks it |
| `tools/mep/docs/README.md` | modify | integration | document the contract; no skill-prose rewrite beyond CLI |

**Conflicts:** sequential — bin + deps + tests share the taxonomy.

## RED-phase gates (before GREEN)

- [ ] A command that prints `"status":"desync"` (or `gated`) currently exits 0 — prove RED
- [ ] `mep_usage` currently exits 2, not 64 — prove RED
- [ ] No `executionRequest` in `where --json` yet (iter 2 owns that) — keep RED for that field

## Approach

1. Ratify the taxonomy table (finish). Implement a single `mep_exit_for_status` (or equivalent) used by every command.
2. Registry table: name, argv shape, help blurb. `mep help` / `mep version` read it.
3. Convert each existing command onto `--json` stdout + mapped exit. `check scaffolding` gets the envelope (flag or subcommand — pick the smaller diff).
4. FOSS tests: success stderr empty; explicit packets for the exit map. Keep `run-stranger.sh` as a separate gate.
5. Do not add `executionRequest`; do not touch resolver row meanings.

## Avoid (out of scope this iteration)

- `executionRequest` / adapter vocabulary (iter 2)
- executor presets, `mep exec dispatch` (iter 3)
- pipe litmus / `--executor stub` (iter 4)
- host `run.sh` as the green bar
- golden-matrix totality (iter 5)
- drive-by resolver row rewrites
- renaming github remote or `.mep/config` overlay
- inventing iter 2–12 product behavior to “complete” unix

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — shell contract (envelope + exit map) only
- [x] **Ownership minimal** — bin + deps + registry + FOSS tests; no `.cursor/skills` prose rewrite
- [x] **Category before instance** — taxonomy/envelope before wrapping each verb
- [x] **One place to edit** — registry + `mep_exit_for_status`
- [x] **No planned shotgun surgery** — Avoid lists 2–4 and host `run.sh`
- [x] **Consolidation routing** — extract debt (host pointer, dual docs) stays out

**Preflight note:** pass — roadmap’s `run.sh` checkpoint rewritten to FOSS tests (host suite is not in this tree)

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | envelope, exit map, registry | change user-visible workflow meaning; add `executionRequest` |

## Testing

- **FOSS:** new unix-contract suite under `tools/mep/test/` + existing `run-stranger.sh`
- **host `run.sh`:** not this remote’s gate
- **Manual:** `mep where fixture-demo --json`; echo `$?`; stderr empty on success; `mep help` on stderr

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category = one exit map + stdout/stderr split. Instance = wrapping today’s subcommands. Fail if only `where` is honest and the rest still exit 0 on `desync`.

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code scope
- [ ] `git commit` → optional `/prep-pr-description mep-v0-graduation 1`
- [ ] `/prep mep-v0-graduation checkpoint` → iter 2 brief
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
