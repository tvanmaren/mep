# Autopilot execution policy

Autopilot is one **authorship mode** (see the [prime directive](../SKILL.md#authorship-modes--the-governanceauthorship-space)).
It introduces **no new lifecycle**: it is the [manual policy](manual.md) run by a **dispatched
cross-model sub-agent in the chef's seat**. Everything below is a **delta** from `manual.md` — the
state machine, the two test moments, the codeless fenced region, the no-prose-invariants rule, and the
ratchet are all inherited **verbatim**. The proxy moves `@finish:open → done → ratified` exactly as the
manual operator would; read `manual.md` for *what* those edges mean.

**The thesis autopilot proves:** full autonomy is reachable by **delegating the human role to a proxy**,
not by the parent rubber-stamping its own work — and it still leaves a recoverable finish-map (no blob).

## Delta 1 — the chef seat is a dispatched cross-model proxy

Where manual waits on the real operator, autopilot **dispatches a sub-agent** to occupy the chef seat
and run manual's lifecycle. The dispatch is **cross-model** — a different model family than the parent —
so the proxy is a genuinely **independent head**, not the authoring context grading itself. This reuses
the in-framework dispatch precedent: `commit-prep`'s `staged-audit-scout` second opinion and
`/execute-plan`'s `best-of-n-runner` fanout.

**The dispatch contract:**

- **Persona.** The proxy is prompted as *a coder who understands this codebase, acting as the MEP chef*:
  it authors the `finish`es and runs the ratchet, fulfilling every aspect of "human" the manual policy
  names (claims edges, ratifies, strips guidance).
- **Hand-off in.** The proxy receives the slice's **finish-map** (frames + red acceptance tests) and
  `manual.md` as its operating policy, plus the code context it needs to author the decisions.
- **Granularity.** **One proxy per slice** — it runs *all* of that slice's finishes as the chef, holding
  the cross-finish context a human operator would. (Not one proxy per finish; that fragments the context.)
- **Hand-off out.** The proxy **edits the working tree in place** — no isolated git worktree. (Unlike
  `best-of-n-runner`, there is no parallel competition to sandbox, and the parent blocks on the slice;
  isolating the proxy's edits would only strand an interrupted run away from where the human resumes,
  breaking the seam.) The parent does **not** advance until it gates on **tests green + the slice's
  finish-map complete** (no `@finish:open` remaining). Only then does the non-blocking advance fire.
- **Late mechanical work.** The bulk mechanical remainder is pre-authored by the sous (the parent) before
  dispatch. If authoring a finish then surfaces *adjacent* mechanical (pattern-citable) code, the
  chef-proxy writes it inline and marks it `@mise` — exactly as the manual operator may — rather than
  bouncing back to the sous. The hand-off stays **one-directional** (sous → chef), not a live loop.

## Delta 2 — the per-slice gate is non-blocking

This is the **only** behavioral difference from manual. Manual blocks each slice on the real operator;
autopilot proceeds slice-to-slice without waiting on a human, once the parent's tests-green +
finish-map-complete check passes. **Non-blocking, but not blind** — see delta 3.

## Delta 3 — the finish-map is retained, with proxy-provenance

Autopilot **always emits the finish-map and never strips it** before graduation. A run that graduates a
slice with *no recorded finish classification* is a failure, not a fast path. Each in-flight `ratified`
carries **proxy-provenance**: the record states the mode was `autopilot` and the ratification was rendered
by a **proxy, not a human**. This is what keeps the corner *governed* — drop the map and it degrades into
the ungoverned blob the framework rejects.

## Delta 4 — graduation is the true human ratification

The proxy's in-flight `ratified` is real for the lifecycle (it gates slice advance) but is **not** the
human ratification the framework requires. That comes at the **human graduation gate** — the same gate
manual graduates through. The driver gets out of the car: a human signs off on the retained,
proxy-provenanced finish-map before the `@mise` / `@finish` trail is stripped.

That sign-off is **risk-tiered**, reusing the maturity ladder's existing review gradient rather than
inventing a new one: the human **re-ratifies every proxy finish in a semantic/foundational zone** —
ontology, invariants, one-way decisions, anything the prime directive holds always-human — re-walking
the frame and the decision as themselves; and **spot-audits a sample of the remainder**, trusting the
retained map + proxy-provenance for the rest. Re-ratify-*all* would negate the gate-speedup autopilot
exists to win; trusting the *whole* map would under-guard the irreversible finishes. A spot-audit that
surfaces a bad proxy ratification escalates to a full re-ratification of that slice.

## The seam — an interrupt drops a real human into manual

Because the proxy runs manual's lifecycle unchanged, an interrupted autopilot run and a manual run differ
**only in who occupies the chef seat**. The `@finish` states on disk are identical, so a real operator
resumes in `manual` with **no translation** — picking up open finishes, finishing done ones, ratifying as
themselves. The paper trail is mode-invariant by construction — it lives in the shared substrate, not
the policy — so autopilot adds the **verbs**, not the nouns.

## Boundaries (what autopilot does NOT do here)

- **no mode selector** — *how* autopilot is chosen or switched is not this policy's concern; selection
  lives in the roadmap's `mepAuthorshipMode` frontmatter + the `/mep mode` verb. This policy defines only what
  autopilot *does* once selected.
- **graduation mechanics live in `/prep-cleanup`** — autopilot specifies the **depth** of the human's
  review over its map (delta 4); the strip itself (removing the `@mise`/`@finish` trail) is
  `/prep-cleanup`'s, shared with every mode.
- **the grid corner is unchanged** — autopilot is the AI-authors / AI-approves corner; this policy is its
  *mechanism*, not a new position on the grid.
- **`manual` + `default` are untouched** — autopilot is a third policy over the same substrate; it changes
  neither of the other two.
