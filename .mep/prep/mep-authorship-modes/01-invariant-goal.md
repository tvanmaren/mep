# Invariant goal — mep-authorship-modes

**Phase:** 1
**Status:** draft
**JIRA:** none

## Problem (invariant)

The framework runs one implicit operating model — "implement owns code; humans audit" — and treats
it as the whole truth. It is really one corner of a space. AI-accelerated development needs that
space made deliberate: a small set of **authorship modes** that share one planning substrate yet
place the human/AI authorship line in different, principled positions, while preserving the
framework's invariants across all of them.

Two faces of the same problem, built together:

- **ownership face** — when authorship is fully delegated, the human is left to *govern and audit*,
  but audit competence is itself fed by authorship; zero-authorship hollows out the very review the
  framework leans on. The upstream-melt prototype falsifies "govern+audit is sufficient": ~21 PRs
  approved in ~3 hours, eyeballed, owned only where the human had personally driven direction.
- **autonomy face** — that same prototype is, in hindsight, *unprincipled autopilot*: full
  delegation with no shared artifact to concentrate review, so output arrives as an undifferentiated
  blob. Full autonomy is wanted, but it must not recreate the blob.

Invariant problem: **make authorship a deliberate, coherent mode-axis — manual, default,
autopilot — over one shared analysis substrate, such that each mode preserves the framework's
invariants and the modes' distinctions never silently leak into one another.**

## Success condition

The framework supports three coherent authorship modes over a shared planning substrate:

- **manual** — the operator personally authors the non-deterministic, decision-bearing fragments and
  feels responsible for them; AI absorbs the provably-mechanical remainder. Pleasanter than
  wing-it-then-review, not less.
- **default** — AI authors, human audits (today's model) — now with a finish-map that concentrates
  audit on the fragments that carried decisions.
- **autopilot** — AI authors and self-approves slice-to-slice *up to* graduation (never *through* it:
  graduation stays a human gate, so the audit trail can't be stripped before review), *non-blocking
  but not blind*: it still emits the finish-map, so ownership/audit is recoverable after the fact.

Switching mode changes **who acts**, never **what gets planned**.

## Rejection criteria

- manual hands the human busywork instead of the consequential/rewarding code
- guidance anchors the human to an AI-authored vision, robbing felt responsibility
- manual is less smooth than "let AI wing it + review"
- any mode relies on AI self-assessing where it will be wrong (AI is confidently wrong)
- autopilot recreates the melt blob — undifferentiated output, no finish-map
- the modes diverge in their planning artifacts, or their distinctions collapse into one another

## Invariants (must survive any implementation)

| Invariant | Falsification (what would change our mind) |
|-----------|---------------------------------------------|
| Authorship mode is execution policy over a shared substrate — modes plan identically, differ only in who acts | the same input yields different slice/finish sets across modes |
| Each mode is a distinct corner of the governance×authorship space; the fourth corner (AI governs, human types) stays empty | a mode lands operators in the code-monkey corner |
| Autopilot is non-blocking but not blind | autopilot graduates a slice with no recorded finish classification |
| In manual, the operator's contribution is load-bearing | a transcriptionist could complete a human-reserved fragment from its guidance alone |
| AI authorship is justified, never assumed: AI absorbs a fragment only if it can ground it in a named pattern | AI authors a fragment for which it can cite no house-pattern / precedent |
| No test asserts a *mechanism* before it exists (contract-level acceptance tests precede code — normal TDD red) | a mechanism-level assertion is written before the mechanism exists |
| Nothing becomes a hardened invariant without human ratification (manual) | a characterization assertion is committed the operator did not ratify |

## Entities and operations (believed real)

- **authorship mode** — `manual | default | autopilot`; orthogonal to the existing `sessionMode`
- **governance×authorship space** — 2×2; three occupied corners, the code-monkey corner deliberately empty
- **analysis layer (shared)** — slices + fragment classification + problem-frames; mode-invariant
- **execution policy (mode-bound)** — who fills finishes, and what gate applies
- **fragment classification** — `mechanical` (AI-absorbable) | `finish` (decision-bearing)
- **problem-frame** — non-anchoring guidance for a finish: contract + ≥2 precedents + fork-as-question
- **no-touch fence** — a region AI is contractually forbidden to re-assert into
- **finish lifecycle** — frame → author → hardening ratchet → ratify

## Non-negotiable constraints

- `default` stays behavior-compatible with today's model (it is named, not changed)
- the resolver stays a pure function of persisted state (`manifest.json` + git)
- profiles retarget with no engine edits; the scaffolding-free convention holds for every node
- honor the framework's minimalism: deliberate, don't default; don't build past real pull

## Politically sensitive areas

- amends the **prime directive** ("implement owns code; humans audit") — the framework's
  constitution — reframing it as the governance×authorship space. High-stakes; gate carefully.
- autopilot is a trust-heavy capability (full automation through graduation); its own risk surface.

## Open questions (defer to phase 2)

- **keystone** (highest risk): can one shared analysis substrate faithfully serve three execution
  policies without the modes' distinctions leaking? this likely sets the foundation strategy.
- keystone fork already deliberated, ratify at phase 2/3: route by **provable mechanical-certainty**
  (human-default + justified AI subtraction), *not* by AI-detected uncertainty
- manifest representation of authorship mode + per-finish status; resolver row(s) for "scaffolded, finishes open"
- autopilot: gates auto-approved in place, or a distinct non-blocking path? how is mode selected/switched?
- marker vocabulary (`@finish`, `@mise`) vs. extending the existing maturity-tags
- whether the **analysis layer** ships first, standalone — it improves `default` review on its own
