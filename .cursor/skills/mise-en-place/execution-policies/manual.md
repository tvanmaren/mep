# Manual execution policy

Manual is one **authorship mode** (see the [prime directive](../SKILL.md#authorship-modes--the-governanceauthorship-space)).
It binds the mode-invariant substrate — the `finish-map` and the `@mise` / `@finish` markers from
[maturity-tags.md](../maturity-tags.md) — to a concrete **execution policy**: *who* moves a finish's
state, *under what test discipline*, *behind what gate*. `default` and `autopilot` are separate
policies over the same substrate; switching mode changes who acts, never what gets planned.

**The thesis manual proves:** the operator authors the decision-bearing fragments and is *load-bearing*;
the sous (AI) absorbs only the provably-mechanical remainder. Pleasanter than wing-it-then-review,
because the human gets the consequential code, not busywork.

## The lifecycle — the marker is the source of truth

The in-code `@finish:<state>` trail is authoritative; the resolver routes on it — its *scaffolded,
finishes-open* row greps `@finish:open` and sends an unmade decision back to authoring before it can be
committed. That grep is the readiness check the lifecycle enforces (below).

| edge | triggering action | actor |
|------|-------------------|-------|
| → `@finish:open` | the sous classifies a fragment as `finish`, writes its **frame** (contract · ≥2 precedents · the fork-as-question), the **contract-level acceptance tests (red)**, and **codeless** inline guidance in the fenced region | AI |
| `open → done` | the operator writes code to **green the acceptance tests** — authoring the decision — and **claims** the edge (flips the suffix; tooling may offer to, never auto-infers); strips guidance as the code subsumes it | human |
| `done → ratified` | the **ratchet**: the sous proposes blackbox validation + a code-speaks-for-itself check; the operator **ratifies** (never inferred). All inline guidance is **verified stripped** here | human |
| marker sheds | graduation — backstop sweep (`@finish:ratified` lived on as the audit map until now) | `/prep-cleanup` |

The sous authors **all** `@mise` mechanical fragments in parallel; it authors **no** `finish` decision.

## Two test moments (the temporal test rule)

The temporal test rule is **mechanism-level**: *no test asserts a mechanism before that mechanism
exists.* It does **not** forbid TDD's red — contract-level acceptance tests precede code as normal.
Hence two moments:

1. **Acceptance tests (red, at `open`).** Assert the **contract** — observable behavior the fragment
   must satisfy — never the *mechanism*. The operator writes code to turn them green; that *is* the
   decision. A test that pins *how* before the operator chose it is the same anchoring failure as a
   pseudo-code stub — forbidden.
2. **Blackbox validation (at `ratified`).** Characterizes the **now-existing** solution to guard against
   regression; added as-needed, no over-testing of incidental edges.

## The fenced region is codeless

Inline guidance in an `open` finish may carry the **what**, **recommendations**, and **permitted
libraries** — but **no code**, commented or otherwise. A snippet of suggested implementation anchors the
operator to the sous's guess; the frame's job is to make the operator *able* to decide, not to pre-decide.

The guidance is **transient scaffolding**: the operator strips it as their code subsumes it, and the
ratchet **verifies it is gone at `ratified`** — it does not wait for graduation. What survives is clean
code that **speaks for itself**.

## No prose invariants

The ratchet emits **tests**, never invariant-comments. We do not clutter the codebase with
`// invariant: …` prose. Where a fragment genuinely cannot be tested, the bar is not a comment — it is
that **the code speaks for itself** (clean/cleaner-code: naming, single responsibility, structure). The
self-documentation check is part of the `ratified` gate, testable or not.

## The hardening ratchet (`done → ratified`)

1. The sous **proposes** blackbox validation of the existing solution + flags any spot where the code
   does not yet speak for itself.
2. The operator **ratifies** — confirms the validation captures intended behavior and the code reads
   clean. Ratification is **always** an explicit human act; it is **never inferred** from green tests
   alone (green proves behavior, not that the operator owns it).
3. On ratify: `@finish:done` → `@finish:ratified`; inline guidance verified stripped.

Nothing becomes a hardened invariant the operator did not ratify.

## Readiness gate

A finish left `open` means a decision is unmade — the slice is not done. The gate is a grep, in the
[`scaffolding-free-check.sh`](../../../hooks/scaffolding-free-check.sh) style — **no bespoke engine**;
the resolver encodes the same grep as its *scaffolded, finishes-open* row, routing such a slice back to
authoring before commit:

```bash
rg -n '@finish:open' <owned paths>   # any hit → NOT READY
```

Run it at the slice-commit boundary. `@finish:done` and `:ratified` do not block (the decision is made);
only `:open` does.

## Boundaries (what manual does NOT do here)

- **no mode selector** — *how* a mode is chosen or switched is not this policy's concern; selection lives
  in the roadmap's `mepAuthorshipMode` frontmatter + the `/mep mode` verb. This policy defines only what manual
  *does* once selected.
- **routing on finish-state lives in the resolver, not here** — the *scaffolded, finishes-open* row owns
  it; this policy defines the lifecycle the marker drives, not the route.
- **no autopilot** — the AI-approves gate is a separate mode that reuses this lifecycle with a different
  approver.
- **`default` is untouched** — manual is opt-in; today's AI-authors/human-audits behavior is unchanged.
