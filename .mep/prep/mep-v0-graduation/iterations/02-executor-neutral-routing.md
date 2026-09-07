# Iteration 2 — Executor-neutral routing

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/02-executor-neutral-routing.md`  
**Status:** brief_ready  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential  

## Epistemic transition

**What became more certain:** the durable next action from `mep where --json` is an **`executionRequest` packet** keyed by resolver **row**, not a Cursor slash string.

**Irreversible decision (one):** `executionRequest` is the public routing contract; `nextCommand` is optional presentation for Cursor adapters.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** every `where` success path that today sets `nextCommand` (including null) also sets `executionRequest` with the field set below. slash strings are not the contract.

**Instance certainty (this slice only):** packet shape + emission from `where` (envelope **and** `proof`) on **today's rows**. both `portable-routing.md` copies. no new product verbs. no executor dispatch. events/pr scaffold stay slash-shaped.

**Acceptance order:** emit from `row` → kind/target/argv. do not parse `nextCommand` to build the packet. do not invent `mep exec dispatch`.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/resolver.sh` packet emission; `where --json` `executionRequest` on the envelope and inside `proof`; FOSS tests that lock shape and treat `nextCommand` as non-authoritative; `tools/mep/docs/portable-routing.md` **and** `.cursor/skills/mise-en-place/portable-routing.md` |
| **May know** | iter-1 envelope + exit map (C7); current resolver row ids and `nextCommand` strings (to keep presentation); `optionalSteps[]` |
| **Must not know** | executor presets / `mep exec dispatch` (iter 3); pipe litmus / `--executor stub` (iter 4); golden-matrix totality (iter 5); host `tools/mep/test/run.sh`; `events.sh` payload shape; `pr.sh` scaffold prose |
| **Invariants** | C6, C7; runtime never calls a model; stdout `--json` still matches process exit; packet is derived from **row**, never by splitting `nextCommand` |
| **Still provisional** | dual skill/docs copies except the portable-routing pair this slice keeps in sync; vendor invoke mapping (iter 3); event-ledger `nextCommand` |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `executionRequest` producer in `resolver.sh` | `@stable` | add — public routing contract |
| `tools/mep/test/run-unix-contract.sh` | `@provisional` | keep suite; **replace** the iter-1 `has("executionRequest") \| not` assertion |

## Stabilizes

Milestone U middle. Iter 3 may assume `jq .executionRequest` yields `kind` / `target` / `argv` without parsing slash strings. it must not assume executor classes or authority fields.

## Macro constraints (read-only)

- C6: work stays on this remote
- C7: `where` success/failure still uses the iter-1 exit map
- Runtime never calls a model

## Acceptance criteria (this iteration ONLY)

- [ ] `mep where <slug> --json` includes `executionRequest` with **exactly** `{ kind, target, argv }` (no `requiredAuthority`, `requiredEvidence`, `allowedExecutorClasses`; do not emit those keys)
- [ ] `proof.executionRequest` equals the envelope field (one object, two pointers — or identical copies; do not let them drift)
- [ ] `nextCommand` remains a Cursor-shaped string (or null); tests treat `executionRequest` as the durable field
- [ ] `kind` is one of: `implement` | `checkpoint` | `commit_prep` | `prep` | `cleanup` | `none`
- [ ] row → kind (exhaustive for today's emit sites):

| row | kind | target | argv |
|-----|------|--------|------|
| `"precondition"`, 3 | `prep` | slug | `[]` |
| 1 (graduated, empty next) | `none` | `null` | `[]` |
| 2 | `cleanup` | slug | `[]` |
| 4 | `commit_prep` | slug | `["docs-bootstrap"]` |
| 5 | `commit_prep` | slug | `["docs-delta"]` |
| 6, 10, 11 | `checkpoint` | slug | `[]` |
| 7, 8 | `implement` | brief path | `[briefPath]` |
| 9 | `commit_prep` | slug | `[]` |

- [ ] FOSS tests: `fixture-demo` → `kind=implement`, `target` = that brief path, argv one-element; **one** synthetic (or in-repo) non-implement row (`checkpoint` or `commit_prep`); `run-stranger.sh` still `status=ok`; no executor-preset keys on the packet
- [ ] both portable-routing copies say `executionRequest` is durable; `nextCommand` is adapter presentation
- [ ] no `mep exec dispatch`; no executor config schema; no litmus script; no `kind: evidence`

### Packet (public API)

```json
{
  "kind": "implement",
  "target": ".mep/prep/fixture-demo/iterations/01-ready.md",
  "argv": [".mep/prep/fixture-demo/iterations/01-ready.md"]
}
```

`target` is the primary path or slug (`null` iff `kind` is `none`). `argv` is the portable token list **already implied by the row** (not a split of `nextCommand`). `docs-bootstrap` vs `docs-delta` is argv, not a second kind.

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| emit `executionRequest` from existing `where` rows | `mechanical` | table above + iter-1 envelope wrap |
| keep `nextCommand` as presentation | `mechanical` | today's field; cursor adapters |
| replace unix-contract absence assertion | `mechanical` | iter-1 RED this slice closes |
| dual portable-routing copies | `mechanical` | iter-1 dual-copy precedent for contract strings |
| `executionRequest` field set + kind enum | `finish` | public API — chef owns the names |

**Frame — executionRequest schema:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| executionRequest schema | `jq .executionRequest` yields kind/target/argv without parsing slash; every current emit site covered | iter-1 exit taxonomy; resolver row ids as glossary stable ids | (ratified) three fields; six kinds from rows; no evidence/authority/executor classes | `done` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/resolver.sh` | modify | domain | one helper; row → packet; attach on every `mep_where_resolver_json` path |
| `tools/mep/bin/mep` | modify | domain | only if `where` cannot pass the field through (prefer resolver-only) |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | require packet; keep exit/stderr contract |
| `tools/mep/test/run-stranger.sh` | modify | integration | only if needed for `status=ok` with the new field |
| `tools/mep/docs/portable-routing.md` | modify | integration | durable field is `executionRequest` |
| `.cursor/skills/mise-en-place/portable-routing.md` | modify | integration | keep in sync |
| `tools/mep/docs/README.md` | modify | integration | one paragraph on the packet; no skill-prose rewrite beyond that |

**Conflicts:** sequential — resolver + tests + portable-routing pair share the schema.

**Explicitly not this slice:** `tools/mep/lib/events.sh`, `tools/mep/lib/pr.sh`, glossary row *meanings*.

## RED-phase gates (before GREEN)

- [ ] `mep where fixture-demo --json` currently has **no** `executionRequest` — prove before GREEN
- [ ] unix-contract still asserts `has("executionRequest") \| not` — that assertion is the tripwire
- [ ] no `mep exec` / executor preset verbs yet

## Approach

1. One helper: `row` + slug + briefPath → `{kind, target, argv}` per the table. unknown row → fail closed (`internal` / do not guess).
2. `mep_resolver_json` attaches the object to the envelope and to `proof`.
3. Tests: invert absence check on `fixture-demo`; add one non-implement fixture (temp slug missing manifest → `prep`, or dirty-prep docs-delta → `commit_prep`, or current `mep-v0-graduation` → `checkpoint` if still row 6/10/11 at test time — prefer a **deterministic temp fixture**, not live initiative state).
4. Rewrite both portable-routing copies as destination: harnesses read `executionRequest`; `nextCommand` is optional presentation.
5. README: one contract sentence. do not rewrite SKILL.md.

## Avoid (out of scope this iteration)

- `mep exec dispatch`, executor presets, adapter audit (iter 3)
- `scripts/litmus/` / `--executor stub` (iter 4)
- golden-matrix totality / evaluation-order rewrite (iter 5)
- host `run.sh`
- drive-by resolver *row meaning* changes
- `kind: evidence`; `requiredAuthority`; executor classes
- `events.sh` / `pr.sh` slash strings
- new authorship modes

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — durable action is `executionRequest`, not slash strings
- [x] **Ownership minimal** — resolver + tests + portable-routing pair; events/pr deferred in writing
- [x] **Category before instance** — packet schema before vendor mapping
- [x] **One place to edit** — one helper builds the packet; rows call it
- [x] **No planned shotgun surgery** — Avoid lists exec/litmus/events
- [x] **Consolidation routing** — iter 1 extra libs were envelope wrap, not debt this slice inherits

**Preflight note:** pass — kinds are today's emit sites; evidence/authority deferred with a reason

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | packet schema, `where` emission | change user-visible workflow *meaning*; add exec dispatch |

## Testing

- **FOSS:** `tools/mep/test/run-unix-contract.sh` + `run-stranger.sh`
- **host `run.sh`:** not this remote’s gate
- **Manual:** `mep where fixture-demo --json | jq .executionRequest`; `.nextCommand` still a slash string for adapters

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category = one durable request object on **all** current emit sites. fail if only `fixture-demo` grows the field.

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code scope
- [ ] `git commit` → optional `/prep-pr-description mep-v0-graduation 2`
- [ ] `/prep mep-v0-graduation checkpoint` → iter 3 brief
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
