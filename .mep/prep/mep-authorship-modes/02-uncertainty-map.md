# Uncertainty map — mep-authorship-modes

**Phase:** 2
**Status:** draft
**Builds on:** [01-invariant-goal.md](./01-invariant-goal.md)

**Delivery track (initiative):** n/a — framework tooling (`.cursor/**` + `wiki/**`), not app code.
The profile's `frontend-only | full-stack` fork does not apply; the "track" is framework-internal.

## Summary

The risk is concentrated in one bet: that a single planning substrate (slices + fragment
classification + problem-frames) can drive three execution policies — manual, default, autopilot —
without their distinctions leaking, and that the classification feeding it is reliable enough to make
manual *useful* rather than busywork. Everything else (markers, resolver rows, ratchet, mode-switch
UX) is downstream of that bet and lower-risk. The active `example` profile is app-bound and does
not serve this effort; framework-native reducers/zones are recorded below.

## Uncertainty register

| ID | Description | Type | Confidence | Reducer (framework-native) | Defer? |
|----|-------------|------|------------|----------------------------|--------|
| U1 | **Shared-substrate fidelity (keystone):** can one analysis artifact drive all 3 policies without distinctions leaking? | domain / architectural | low | dogfood: define the artifact, dry-run all 3 policies against one real example slice | no — attack first |
| U2 | **Classification reliability (keystone):** does "AI can cite a named pattern → mechanical, else hole" flag holes where decisions actually are, despite AI miscalibration? | domain / operational | low–med | back-test the rule over a real past slice (a melt PR); compare flagged holes vs where decisions really were | no |
| U3 | **Non-anchoring frame:** does the 3-slot frame (contract / ≥2 precedents / fork), as contract-tier criteria, preserve felt ownership + pass the transcriptionist test? | UX | low | author a real frame for a real hole; operator fills it; check anchoring/ownership | partial — trial early |
| U4 | manifest + resolver representation of mode + per-hole status, keeping the resolver a total function of state | data / integration | med | extend schema on paper; add resolver row; re-derive states by hand | yes — after U1 shape fixed |
| U5 | marker vocabulary + lifecycle: `@hole`/`@human` vs extending maturity-tags; graduation "zero unfilled holes" gate | domain / integration | med | extend `maturity-tags.md` ladder on paper; check grep + cleanup protocol | yes |
| U6 | **anti-fighting fence:** can a `@human` no-touch contract actually stop the agent re-asserting human-edited lines mid-chat? | operational / UX | low–med | empirical spike: fence a region, edit it, observe whether the loop respects it | separable — candidate early standalone slice |
| U7 | autopilot non-blocking path: reuse gates auto-approved vs distinct path; how it still emits the hole-map | integration | med | trace existing phase/gate flow; design auto-approve hook | yes — far end |
| U8 | hardening ratchet + temporal test rule operationalized in the implement/commit flow (AI proposes, human ratifies) | domain / integration | med | prototype the ratchet against one real post-fill hole | yes |
| U9 | mode selection / switching UX (manifest default, `/mep` verb, per-slice override) | UX | med–high | small design; reuse `sessionMode` patterns | yes |

### Reducers (framework-native — profile does not apply)

| Uncertainty kind here | Reducer |
|-----------------------|---------|
| conceptual model (mode-space, hole/frame semantics) | sandboxed worked example + dogfood the framework on itself |
| state representation (manifest, resolver, markers) | extend schema/table on paper, hand-re-derive states (resolver is a pure function — checkable offline) |
| operator experience (anchoring, anti-fighting, pleasantness) | author a real frame / fence and trial it on a real fragment |
| integration into existing commands/skills | trace the current `prep → implement → commit → checkpoint` flow; design the seam |

### zones (framework-native)

| Zone | Home |
|------|------|
| engine | `.cursor/skills/mise-en-place/SKILL.md`, `glossary.md` (resolver), `maturity-tags.md` |
| templates | `.cursor/skills/mise-en-place/templates/**` (manifest, slice-brief, phase docs) |
| driver / commands | `.cursor/commands/mep.md`, `prep.md`, `implement-plan.md`, `prep-cleanup.md` |
| gates / hooks | `hooks/**` (scaffolding-free, archaeology, future hole-gate) |

### Keystone + foundation strategy

- **Keystone uncertainty:** U1 + U2 — the shared substrate and the classification that feeds it.
  If either fails, manual is busywork and autopilot is the blob; the whole axis collapses.
- **Foundation strategy (fork, resolve at phase 4):** the keystone is a *multiple-consumers-of-one-
  contract* problem (three policies consume one artifact), which points at **contract-first** (define
  the shared analysis-artifact schema first). But the hole/frame/classification concepts are still
  fluid, and contract-first risks calcifying a fluid schema — so **domain-core-first** (build the
  classification rule + hole model as sandboxed pure logic first, de-risking U2 before fixing the
  contract) is the live alternative. Do not resolve here.

## What must be prototyped

- the classification rule, back-tested on a real past slice (U2)
- one example slice carried through all three policies from a single artifact (U1)
- one real frame, trialed for anchoring/ownership (U3)
- the anti-fighting fence, as an empirical harness spike (U6)

## What can remain abstract

- exact marker spelling, manifest field names, resolver row wording (U4/U5) — downstream of U1
- autopilot's auto-approve mechanism (U7) — far end
- mode-switch UX surface (U9)

## What should not be decided yet

- contract-first vs domain-core-first (phase 4 fork)
- whether the analysis layer ships as its own standalone slice before manual/autopilot

## Misclassification risks

- **profile gap (process):** the active profile is app-bound; running meta-work through it invites
  mis-applied reducers/zones. Mitigated by the framework-native tables above. A `framework-self`
  profile may be warranted only if this kind of meta-work recurs — defer.
- **U2 confidence illusion:** "AI can cite a pattern" may *feel* reliable while AI confidently cites
  a spurious pattern. The back-test (not introspection) is the guard; if it fails, the whole
  human-default-subtraction mechanism (path 2) is in question, not just a parameter.
- treating U6 (anti-fighting) as cosmetic — it is arguably the load-bearing UX invariant for whether
  manual is *pleasant*; under-weighting it risks a correct-but-hated mode.
