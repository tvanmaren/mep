# Graduation — mep-authorship-modes

**Status:** graduated
**Slice:** I8 (graduation cleanup)

## What the initiative delivered

The **authorship-mode axis** for the mise-en-place framework: the standing human-governs-semantics
invariant, below which *who authors the decision-bearing code* and *who holds approval governance* now
vary by an explicit, named mode.

| | shipped in |
|---|---|
| classification back-test (mechanical-vs-finish, fail-open-to-finish) | I1 |
| anti-line-fighting boundary mechanism | I2 |
| shared substrate — the `finish-map`, two markers (`@mise` authorship / `@finish` decision) | I3 |
| prime directive reframed as the governance×authorship space (3 corners) | I4 |
| manual execution policy — finish lifecycle, two test moments, hardening ratchet | I5 |
| autopilot execution policy — manual's lifecycle run by a dispatched cross-model proxy | I6 |
| mode wiring — `authorshipMode` field, resolver open-finish row, `/mep mode` verb | I7 |
| graduation cleanup | I8 (this slice) |

## What graduation did

**1 — stripped the 7 live initiative markers** (the scaffolding the framework planted on itself), keeping
all surrounding prose. Strip-predicate (finish 1) = **curated inventory as the action, provenance-grep as
the verification gate** (engine-level `.md`-aware cleanup rule considered and deferred):

| node | marker shed | content kept |
|------|-------------|--------------|
| `SKILL.md` | `@foundational` (operating model) | the operating-model invariant prose |
| `SKILL.md` | `@provisional` (mode wiring) | the `authorshipMode` bootstrap table |
| `glossary.md` | `@provisional` (open-finish row) | resolver row 8 |
| `execution-policies/manual.md` | `@provisional` (lifecycle UX) | the policy |
| `execution-policies/autopilot.md` | `@provisional` (auto-approve path) | the policy |
| `maturity-tags.md` | `@provisional` (`@finish:` grammar) | the grammar |
| `templates/slice-brief.md` | `@provisional` (substrate schema) | the Finish-map section |

The framework's *documentation* of the marker/tag vocabulary (the `maturity-tags.md` table + examples,
the `/prep-cleanup` strip table, `code-integrity-check.md`, the profile examples, the `slice-brief`
template's marker row) was **spared** — it is evergreen content, not initiative scaffolding. Verified:
`rg '(mep-authorship-modes I…)'` over `ownedPaths` returns zero; a broad marker scan returns only the
vocabulary documentation.

**2 — resolved the autopilot proxy-map review depth** (finish 2, deferred from I6): the graduation
sign-off over an autopilot proxy's finish-map is **risk-tiered** — the human re-ratifies every proxy
finish in a semantic/foundational zone (ontology, invariants, one-way decisions) and spot-audits a sample
of the remainder, reusing the maturity ladder's existing review gradient. Landed in `autopilot.md` Delta 4.

**3 — reconciled stale forward-references** that I7 had outdated. `manual.md` and `autopilot.md` (authored
at I5/I6, before the mode engine) still claimed "nothing in the resolver routes on the marker yet" and
"no mode selector — arrives with the mode engine (a later slice)." I7's resolver row 8 + `/mep mode` made
those false; graduation rewrote them to the shipped present (the resolver *does* route on `@finish:open`;
selection lives in the field + verb). Discovered by a forward-ref sweep beyond the marker inventory — the
"reads evergreen" half of the scaffolding-free convention.

## Final state

- zero live `@` markers in `manifest.ownedPaths`; the vocabulary documentation intact.
- the resolver, the prime directive, and all three policies read exactly as before, minus their
  scaffolding and minus two now-true (formerly stale) sentences.
- maturity: the mode axis graduates `provisional → stable`; the operating model stands as evergreen prose.
- `initiativeStatus: graduated`.

## Deferred (not regressions — explicit non-goals)

- an `.md`-aware rule in `/prep-cleanup` so a future framework-internal initiative's self-graduation is
  mechanical rather than curated (finish-1 path C).
- the per-operator foundation-strategy default (the tiebreak seam — one operator, no second yet).
