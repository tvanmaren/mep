# Maturity tags (commented `@` markers)

Searchable epistemic markers **during** implementation. Removed by `/prep-cleanup`
when an initiative graduates — see [cleanup protocol](#cleanup-protocol).

Tags are always **comments** (never runtime decorators). Use the host language's normal comment
syntax; the active profile may show repo-specific examples. The `@` prefix makes them grep-friendly:

```bash
rg '@(experimental|provisional|stable|foundational|reference-only)' <owned paths>
```

## Ladder

| Tag | Meaning | AI freedom | Review bar |
|-----|---------|------------|------------|
| `@experimental` | Semantics still discovered | high | light |
| `@provisional` | Pattern emerging; may change next slice | medium | checkpoint |
| `@stable` | Contract hardened for this initiative | low | `/staged-audit` |
| `@foundational` | Org dependency; change is expensive | minimal | human + assess |
| `@reference-only` | Audit/doc path; must not enter compute | n/a | verify no compute reads |

## Placement

**File header** (preferred for new modules):

```text
<comment start>
<module purpose>
@provisional — boundary still settling; graduates in a later slice or cleanup.
<comment end>
```

**Function / block** (when maturity differs within a file):

```text
<comment> @experimental — behavior still being proven
<code boundary>
```

**File-format boundary** — use the nearest ordinary comment location for that host file:

```text
<host comment> @stable — invariant should now resist casual edits
```

Do **not** tag every function. Tag **boundaries** where provisionality or invariants
matter for review.

## Pair with slice brief

Each implement pass lists required tags in the slice brief `epistemicMarkers`
section. Exploration/architectural slices **add** tags. Cleanup slice **removes**
all initiative tags.

## Authorship & decision markers — two axes

The ladder above is the **certainty** axis. These markers are two **orthogonal** axes (a region can
be `@stable` *and* `@mise` *and* `@finish`). The metaphor: **AI is the sous, the human is the chef.**

### Axis 1 — authorship / no-touch: `@mise`

`@mise` marks **the agent's own generated code** (the sous's prep). **Unmarked code is the operator's
— no-touch.** Writing code the ordinary way *is* how you own it; the operator marks nothing. To take
over any region, the operator **deletes its `@mise`** (claiming is *subtractive*).

This is the anti-line-fighting boundary: within a `@mise` region the agent may
freely regenerate; into **unmarked** code it must never generate, overwrite, reformat, "restore", or
revert — and unmarked **outranks the agent's memory** (it does not re-assert a remembered version
over operator lines). Failure-safe: forget to mark agent code → it reads as the operator's →
over-protect, never clobber. (Coverage is naturally ~all of the file in default/autopilot — accurate,
not noise; it is stripped at graduation.)

### Axis 2 — decision / direction: `@finish`

`@finish` marks a **decision-bearing fragment** the agent *directs* the chef to author — *"your
judgment goes here."* It is **mode-invariant** (the same fragments are finishes in every mode; only
their *state* differs by who has acted), and carries a state: `@finish:open → :done → :ratified`.
Fragments are classified `mechanical | finish` in the slice brief's **finish-map** (see
[templates/slice-brief.md](templates/slice-brief.md)); a `mechanical` call needs a cited pattern that
dictates *the choice*, else it **fails open to `finish`**.

`@finish` is **prescriptive** (the agent asks); deleting `@mise` is **discretionary** (the operator
chooses) — kept distinct so claiming code never masquerades as an AI directive.

### How they overlay

| | `@finish` (a decision) | not a decision |
|---|---|---|
| **`@mise`** (agent wrote it) | agent made a call → **audit this** | agent prep — the bulk |
| **unmarked** (operator) | a decision the operator authored / was directed to | operator-claimed code |

### Grammar (provisional)

Comment-based, host-language-agnostic, grep-able. Each marker has **block** (open/`:end`), **inline**
(trailing a line), and **file** (header) forms.

```text
<comment> @mise
<agent-generated code — the agent may regenerate; delete this marker to claim it>
<comment> @mise:end

<comment> @finish:open    (a decision awaiting authorship; → :done → :ratified)
```

### Lifespan & removal

Both markers are **process scaffolding**, never permanent. `/prep-cleanup` strips every `@mise` and
`@finish` at graduation; shipped code is just code. Until then `@finish` doubles as the **audit map**
(concentrate review on the decisions), and the `@finish` state trail is the interruptible record that
lets one authorship mode hand off to another mid-flight.

Distinguish the **marker** from the **inline guidance prose** a `finish` may carry while `open` (the
frame's what/recommendations — never code): the guidance is transient and sheds **once the finish is
filled** (it does not wait for graduation), so the surviving code speaks for itself; the
`@finish:<state>` **marker** persists as the audit map until graduation. *Who moves a finish's state,
and when, is execution policy (per authorship mode) — see `execution-policies/` — not specified here.*

## What is NOT a maturity tag (survives cleanup)

Comments that explain **permanent** business rules or invariants — not cycle state:

```text
<comment> reference-only — review support only; runtime logic does not read it
```

After cleanup, rewrite as durable intent if still needed:

```text
<comment> This data supports operator review only; runtime logic ignores it.
```

The second form stays; `@reference-only` goes.

## Cleanup protocol

When `manifest.initiativeStatus === graduating`:

1. `rg '@(experimental|provisional|stable|foundational|reference-only)'` scoped to
   initiative `ownedPaths`
2. For each hit: remove tag line OR rewrite into durable intent comment
3. Remove `PROVISIONAL:`, `TODO(stabilize-…)`, `@maturity:` aliases
4. `rg '@(mise|finish)'` scoped to `ownedPaths`; **remove** every `@mise` / `@mise:end` and
   `@finish:<state>` marker — the code each wrapped simply stays
5. `.cursor/hooks/scaffolding-free-check.sh --broad <ownedPaths>`; **rewrite** any surviving
   prose archaeology — iteration/uncertainty/decision handles (`I<n>`, `U<n>`, `Path-<x>`,
   `AD<n>`) in headers or body text — into durable intent. The provenance lives in `wiki/prep/`,
   not the evergreen doc (steps 1–4 only catch `@`-markers; free prose slips them otherwise)
6. **Keep** falsifiable business-rule comments that a new dev needs without reading
   wiki/prep
7. Run `/staged-audit`; confirm zero initiative maturity tags, zero `@mise`/`@finish` markers,
   **and zero archaeology handles** remain in owned paths
8. Record cleanup in `wiki/prep/<slug>/06-graduation.md`

Final merged code: good code only. Process memory lives in `wiki/prep/` and
`wiki/plans/`, not in `@` tags.
