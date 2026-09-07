---
description: "/mep — plain-verb driver for the mise-en-place framework: next | where | start | done | stage | curate | mode"
alwaysApply: false
---

# mep — the plain-verb driver

`/mep <verb> <slug>` operates the framework with seven plain verbs — no need to know phases, slices,
or modes. It is a **thin façade**: it infers where you are from state and routes to the existing
commands (the lone exceptions are `mode`, which sets one manifest field, and `curate`, which
synthesizes merge narrative). It reimplements nothing.

**The deterministic reader is now the portable tool.** Prefer
`tools/mep/bin/mep where <slug> --json` and `tools/mep/bin/mep status <slug> --compact --json` for
state resolution. The glossary in
[`.cursor/skills/mise-en-place/glossary.md`](../skills/mise-en-place/glossary.md) remains the
human-readable resolver contract/reference; do not copy its rows into this command.

## Invocation

`/mep <verb> <slug>` — verb first (like `git <subcommand>`), `<slug>` **required** (no inference in
v1).

## State you read (infer it — don't make the user name a phase or mode)

- First run `tools/mep/bin/mep status <slug> --compact --json` for resolved paths, manifest summary,
  dependency state, dirty scopes, vcs summary, warnings, and routing proof.
- Treat non-empty `requiredWritebacks` as mode-governance work, not ignorable metadata. `blocker`
  writebacks stop slice advance until the marker/provenance issue is resolved.
- For the next literal command, run `tools/mep/bin/mep where <slug> --json`. Treat its `nextCommand` as
  the concrete route, then apply the verb behavior below.
- When `where` resolves to `/prep <slug> checkpoint`, run the **whole session** — sync is step 0
  inside that session (`tools/mep/bin/mep checkpoint <slug> --json`, then `--fix` only when the report
  has no blockers and no `commit_required_before_checkpoint`), not a standalone `/mep next` gate.
- For authorship modes, prefer `tools/mep/bin/mep lifecycle status <slug> --mode <mode> --json`.
  The lifecycle is finish → `/prep checkpoint` → advance; mode only selects the actor policy. Gate kinds are
  `human`, `proxy`, `commit`, `forbidden`, or `checkpoint`.
- For local runtime history inspection, use `tools/mep/bin/mep events tail --json`. This is an
  observability read, not a routing input.
- If the tool is missing or reports `missing_dependency`, fall back to the glossary resolver reference
  and say which dependency blocked scripted resolution.

**One exception to "don't ask":** when no manifest exists *and* the branch carries tracked work,
you **must** ask the user whether that work belongs to this effort before routing to `/tidy` —
relevance is the one thing only the human can classify (state/mode you still infer yourself).

Resolve the next literal command via the tool output, then act per verb. The glossary is the
readable contract for checking the answer, not a second implementation to paste here.

## Verbs

| verb | does | shows |
|------|------|-------|
| `next` | **executes** | states the step in plain language, then runs the resolved command |
| `where` | **nothing** (read-only) | prints state + the concrete next command |
| `start` | **executes** | bootstraps a new effort (greenfield, or `/tidy` if the branch outran its docs) |
| `done` | **executes after confirm** | graduates the effort |
| `stage` | **previews by default; executes after confirm in effectful modes** | verifies promised work and prepares a review stack |
| `curate` | **previews by default; executes after confirm** | lossy-compresses discovery into review narrative; publishes integration history on new branch(es) |
| `mode` | **executes** (writes the manifest field) | sets/switches who authors — `manual` / `default` / `autopilot` |

The **do-vs-show split is the mode** — `next` does, `where` shows.

### `next <slug>` — do the next thing

1. Resolve the next literal command from state.
2. **State it transparently, in plain language:** `you're at <plain where-you-are> → running
   <command>`. No framework vocabulary in this line — translate via the glossary.
3. Run that command.
4. **The gate stays put:** if the resolved command is `/commit-prep`, it stages and stops at the
   human commit gate as always. `/mep` never runs `git commit`.
5. **Mode gate:** if `requiredWritebacks` contains `finish_open`, missing provenance, or
   `finish_map_missing`, resolve that state before continuing. Manual routes open/missing human
   provenance to explicit human authorship/ratification. Autopilot dispatches a cross-model proxy for
   finish authorship/ratification; the parent agent never self-ratifies autopilot work.
6. **`/prep checkpoint` is atomic:** when the resolved command is `/prep <slug> checkpoint`, complete
   sync (step 0 inside the session when eligible) → replan → draft next brief → docs-delta before
   re-running `where`. Do not treat `mep checkpoint` as a separate next step.

### `where <slug>` — look before you leap

1. Resolve the next literal command from state. **No side effect.**
2. Print three plain lines: a one-line "you are here", the **concrete** next command — the real
   resolved path, e.g. `/implement-plan wiki/prep/<slug>/iterations/<n>-<name>.md`, not a
   placeholder — and a one-line description of what it will do.
3. **Never** answer with `/mep next` — always the real routed command. The answer is correct even
   after intervening questions/answers/digressions, because it is re-derived from `manifest.json` +
   git, not from memory.

### `start <slug>` — begin a new effort

No scaffolding yet (`wiki/prep/<slug>/manifest.json` absent)? Resolve per the glossary
**precondition**:

- no relevant tracked work (after checking commits + staged/unstaged; untracked unrelated files
  don't count) → `/prep <slug>` (greenfield macro prep).
- branch already carries **relevant** work (commits or staged/unstaged tracked changes —
  **confirm with the user**; untracked unrelated files don't count) → `/tidy <slug>` (recovery; it
  backfills the prep tree, then `/prep checkpoint` resumes).

If a manifest already exists, `start` is a no-op — use `next` / `where`.

### `done <slug>` — finish the effort

1. Check every iteration's `status`. **If any is not `committed`/`merged`, warn** and list them.
2. **Ask for explicit confirmation** ("graduate `<slug>` now? this strips scaffolding and writes
   the graduation notes").
3. Only on confirm, run `/prep-cleanup <slug>`.

### `stage <slug> [mode]` — prepare review

Route directly to:

```text
/prep-stage <slug> [mode]
```

`stage` is the normal review-presentation surface. It owns the full review-prep pipeline:

1. discover committed work ready for review,
2. verify promised-work checks: complete, scoped, leakage-free, and body-ready,
3. verify PR scaffold/body readiness and generate deterministic scaffolds when body files are missing,
4. route semantic reviewer prose through the PR-body contract,
5. preview branch/PR stack mapping,
6. apply local or remote stack effects only after the selected mode's explicit gates.

`preview` is the default. Local branch changes and remote `gh stack` / PR-body updates remain gated
inside `/prep-stage`.

`mep pr scaffold`, `/prep-pr-description`, and `/prep-stage` are plumbing under this review surface.
They may be useful escape hatches during implementation or recovery, but `/mep where` should not route
ordinary users to them directly. Do not use `stage` for commit staging, implementation, cleanup, or
product-code archaeology checks.

### `curate <slug> [mode]` — compress discovery into review narrative

Route directly to:

```text
/prep-curate <slug> [mode]
```

**Communication phase** — after execution, before merge. Curate is **lossy compression** of development
history: lossy on chronology, lossless on concept. The human approves the **communication strategy** in
preview; code already exists on the lab branch.

1. **`preview`:** distill **evidence** (R / AD / D) → **merge courses** → **review shards** (stable
   ~300 LOC completions) → **reviewer learning path** → **confidence report**. Propose first; ask
   only at level 3 or product decisions. No git writes. No wip-history stacking.
2. **`execute`:** **publication history** on integration branches (curated, not fabricated). Lab branch
   untouched.

Optional: `--optimize reviewer-comprehension|merge-speed|earliest-value` (executor + manifest; CLI passthrough post-v0.1).

Then **`/mep stage`** maps shards → PR stack (profile `capabilities.publication`).

Budget: merge course **~2k**; review shard **300** / **500** max. Outline: `wiki/plans/mep-curate-outline.md`

### `mode <slug> <mode> [iteration N]` — choose who authors

Sets `manifest.authorshipMode` — the one verb that **writes state** rather than routing. `<mode>` is
`manual | default | autopilot`.

1. No `iteration N` → set the **initiative** default. With `N` → set that iteration's override
   (`iterations[N].authorshipMode`); an iteration with no override **inherits** the initiative value.
2. **State the change in plain language:** `<slug> now authors by <mode> (was <prior>)`. Translate via
   the glossary — don't expose the field name unless asked.
3. Writes **only** the field; never the finish-map, never code. Switching mid-flight changes only *who
   acts next* — the planned slices and finishes are identical across modes (the seam).
4. `default` is the standing behavior; `mode` is opt-in. The initial pick can also be made at `/prep`
   bootstrap, alongside `sessionMode`.

### Mode governance (manual/autopilot)

Manual and autopilot share the same marker substrate and deterministic gates:

```text
tools/mep/bin/mep lifecycle status <slug> --mode <mode> --json
tools/mep/bin/mep finish scan <slug> --json
tools/mep/bin/mep status <slug> --compact --json
```

The lifecycle is shared. Mode is an actor policy. Deterministic manifest sync (`mep checkpoint --fix`)
runs as step 0 **inside** `/prep checkpoint`, not as a standalone operator step before it.

- `manual`: human implements, authors finishes, and ratifies with human/manual provenance.
- `default`: agent may implement/propose; human owns finish authorship and ratification.
- `autopilot`: parent agent implements; proxy authors/ratifies finishes with proxy/autopilot
  provenance; parent must not self-ratify.

Autopilot should not ask the operator mid-slice unless the lifecycle report returns a `human` gate.

## Plain-language rule (operator surface)

Everything `/mep` prints to the user avoids framework vocabulary (`phase`, `slice`, `brief`,
`docs-delta`, maturity tags). Translate via the glossary. The deep terms stay one lookup away for
anyone who wants them — they are not in your face by default.

## Out of scope (v1)

No slug/context inference, no free-text parsing — a verb is a verb. Verbs route to existing commands;
the sole exception is `mode`, which writes one manifest field (`authorshipMode`) and routes nowhere.
No verb edits a skill's internals.
