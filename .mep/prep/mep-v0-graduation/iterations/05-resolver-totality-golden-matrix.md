# Iteration 5 — Resolver totality & golden matrix

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/05-resolver-totality-golden-matrix.md`  
**Status:** committed  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** `mep where` is total against a documented evaluation order; every row and the named recovery/precedence paths have a golden expectation.

**Irreversible decision (one):** the glossary evaluation-order table is the spec; `resolver.sh` must match it.

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** first-match evaluation order is one function; emit sites share one named request context (I8 collapse); golden matrix is the proof, not a second resolver.

**Instance certainty (this slice only):** FOSS suite `tools/mep/test/run-golden-matrix.sh` with temp manifests per row (not this initiative’s live ledger).

**Acceptance order:** spec + emit helper before extra rows. do not grow `scripts/litmus/` into routing. do not invent v0.2 composed-state routing.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `tools/mep/lib/resolver.sh`; both `glossary.md` copies; golden suite under `tools/mep/test/`; unix-contract/stranger only if they must call the golden script; portable-routing only if evaluation-order facts live there |
| **May know** | C7–C10; I4 (revision-triplet as “built”); I8; fixture-demo; glossary rows 1–11 |
| **Must not know** | live vendor drivers; expanding litmus product; authorship-mode policy changes (6–8); install path (9); v0.2 git-demotion |
| **Invariants** | C4, C6, C7, C8, C9, C10; `executionRequest` still row-derived; stdout `--json` still matches process exit |
| **Still provisional** | dual skill/docs copies except glossary twins this slice keeps in sync; event-ledger still slash-shaped; git heuristics remain v0.1 transitional |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `resolver.sh` evaluation / packet emit | `@stable` | keep or add — public routing engine |
| golden matrix suite | `@stable` | add — totality proof |
| git-heuristic “built” detection | `@provisional` | keep — v0.1 transitional (v0.2 demotes) |

## Stabilizes

Milestone A. workflow closure (6–8) may assume `where` does not bounce a landed slice back to implement.

## Macro constraints (read-only)

- C7: exit map
- C8: `executionRequest` from row
- C9: dispatch is not this slice
- C10: do not weaken the litmus CI gate
- I4: triplet / post-brief history is how “built” is proven — lock it in goldens, do not treat slice-14 as proof
- I8: collapse positional arity **this slice**

## Acceptance criteria (this iteration ONLY)

- [x] `tools/mep/test/run-golden-matrix.sh` exits 0 and covers glossary rows **1–11** plus **row-10 precedence**, **row-11 recovery**, and **row-5 docs-delta interstitial**
- [x] each case asserts `executionRequest` (and `proof.executionRequest`) plus `row`; `nextCommand` is presentation only
- [x] a landed `brief_ready` slice with clean owned implementation routes to checkpoint (row 10), **never** back to implement
- [x] `mep_where_resolver_json` / `mep_resolver_json` call sites pass a **named context** (no 6–11 positional arities, including implement `execution_target`)
- [x] `.cursor/skills/mise-en-place/glossary.md` and `tools/mep/docs/glossary.md` stay twins on evaluation order
- [x] unix-contract + stranger + slice-boundary litmus still green; no I8 leftover fanout; no vendor drivers; no litmus product logic
- [x] fixtures are temp / dedicated slugs — do not mutate committed `mep-v0-graduation` or `fixture-demo` as the golden workspace

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| glossary evaluation order is the spec | `mechanical` | roadmap iter 5 irreversible decision |
| golden suite as a FOSS file, not host `run.sh` | `mechanical` | this remote only has `run-unix-contract.sh` / `run-stranger.sh` |
| temp manifests per row | `mechanical` | stranger/litmus temp-root |
| named resolver context shape | `finish` | public calling convention |

**Frame — named resolver context:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| named resolver context | one obvious place to add a field; goldens still pass; no silent arity overloads | `mep_execution_request_json` named helper; C8 exact `{kind,target,argv}` object | recommend: one jq/object (or nameref) context consumed by `mep_resolver_json`; call sites stop packing positionals | `ratified` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `tools/mep/lib/resolver.sh` | modify | domain | evaluation + named context; not vendor invoke |
| `.cursor/skills/mise-en-place/glossary.md` | modify | integration | spec twin |
| `tools/mep/docs/glossary.md` | modify | integration | spec twin |
| `tools/mep/test/run-golden-matrix.sh` | new | integration | totality suite |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | optional: invoke golden, or leave to CI |
| `tools/mep/test/run-stranger.sh` | modify | integration | only if stranger must prove a golden row |
| `tools/mep/docs/portable-routing.md` | modify | integration | only if eval-order facts already live there |
| `.cursor/skills/mise-en-place/portable-routing.md` | modify | integration | keep twin if portable-routing is touched |
| `.github/workflows/stranger.yml` | modify | integration | optional: run golden in CI |

**Conflicts:** sequential — resolver + glossary + goldens share the evaluation seam.

**Explicitly not this slice:** `scripts/litmus/` product growth; `exec.sh` vendor drivers; mode policies; SKILL.md rewrite; host `run.sh`; v0.2 composed-state default path.

## RED-phase gates (before GREEN)

- [x] no `run-golden-matrix.sh` (or it does not cover rows 1–11)
- [x] `mep_where_resolver_json` still has 6/7/8/9-arg overloads
- [x] a fixture that is `brief_ready` + landed + clean can still be shown routing to implement without a golden failure

## Approach

1. Prove RED: missing golden file; arity overloads present; document one known implement-bounce if still true.
2. Introduce named context; rewrite emit sites; keep `executionRequest` derivation on `row`.
3. Align `resolver.sh` first-match order with glossary **evaluation order** (glossary wins).
4. Table-driven goldens: temp git root + seeded manifest/tree per case.
5. Wire FOSS proof (unix-contract and/or stranger CI). do not hide routing inside litmus.

## Avoid (out of scope this iteration)

- new authorship modes / finish-scan policy (6–8)
- live vendor adapters; API keys
- expanding `scripts/litmus/` beyond composition
- v0.2: composed prep-tree as default routing input; demoting git heuristics
- mutating this initiative’s manifest as a golden workspace
- SKILL.md / host `run.sh`

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — routing totality (order + goldens + named emit context)
- [x] **Ownership minimal** — resolver + glossary twins + golden suite; CI optional
- [x] **Category before instance** — named context + spec before extra row folklore
- [x] **One place to edit** — evaluation lives in resolver; glossary is the spec twin; goldens are proof
- [x] **No planned shotgun surgery** — Avoid lists litmus/vendors/v0.2/modes
- [x] **Consolidation routing** — I8 wait is this slice; not leftover from 4

**Preflight note:** pass — 5 stays fat (roadmap-owned). named context ratified (jq/object or nameref). golden file is FOSS-native (no host `run.sh`).

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | evaluation order, emit context, goldens | change user-visible workflow *meaning*; add vendor drivers |

## Testing

- **FOSS:** `tools/mep/test/run-golden-matrix.sh`; `run-unix-contract.sh`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`
- **host `run.sh`:** not this remote’s gate
- **Manual:** `mep where` on a temp landed-`brief_ready` fixture → row 10, not implement

## Architectural diff (fill at checkpoint)

- Assumptions hardened: evaluation order is glossary + resolver twins; row 5 is an implement interstitial on 7/8, not first-match dirty-prep; I8 named context is one jq object; goldens prove rows 1–11 + precedence + recovery + interstitial + pending+dirty stays 6.
- Coupling increased: stranger CI runs `run-golden-matrix.sh`; glossary table is the spec the matrix asserts.
- Harder to change: changing a row without a golden (or without both glossary twins) is now a red suite.
- Easier to change: adding a packet field is one named context helper, not 6–11 positional arities.
- **Promote to core:** none new — C8 already says row→`executionRequest`; this slice locked the *table* and the *emit shape*.
- **Newly interchangeable:** finish-scan comment prefixes (`--` matching bash flags) — **I11 / iter 5b**, not a resolver-row problem.
- **Falsified:** none of C7–C10. **dogfood hole:** `8e4d880` still bounces *this* slug to row 8 because `--reason "owned paths contain @finish:open"` is grepped as a marker. goldens did not cover self-scan of `resolver.sh`. **5b owns the heuristic.** `--fix` on 5 was blocked; 5 is human-closed from git (`8e4d880`) like iter 0.

## Checkpoint

**Seam smell test:** category closed in goldens (total eval + named emit). live dogfood bounce is **5b**, not a 6+ start.

## After commit

- [x] `/commit-prep mep-v0-graduation` — code scope (`8e4d880`)
- [x] `git commit` → optional `/prep-pr-description mep-v0-graduation 5`
- [x] `/prep mep-v0-graduation checkpoint` → **5b** (not 6)
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
