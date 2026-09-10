# Portable Routing Contract

Cursor slash commands are adapters. The durable behavior is the state contract below.

## State Inputs

- `wiki/prep/<slug>/04-iteration-roadmap.md` frontmatter — the initiative cursor (`mepCurrentIteration`,
  `mepPhase`, `mepInitiativeStatus`, `mepAuthorshipMode`, `mepOwnedPaths`)
- `git status --short`
- `git log --oneline`
- the active iteration brief — the one under `iterations/` whose frontmatter `mepIteration` equals the
  roadmap's `mepCurrentIteration`; its `mepStatus` and revision triplet are that slice's state

An initiative authored before document-colocated state has no roadmap frontmatter — a bare
`04-iteration-roadmap.md` with no frontmatter block counts as absent. The resolver then imports its
`manifest.json` read-only; `status --compact --json` reports `authority: "legacy_import"`. Reads and
routing work; every writer refuses rather than no-opping — `checkpoint` and `doctor` with a
`legacy_state_read_only` finding, `mode set` with a `legacy_state_read_only` reason, all of them
`blocked` at exit 2. `mep migrate <slug> --json` writes modeled facts into frontmatter, names retired
keys, and is the supported exit.

Use the resolver table in `glossary.md` as the single source of truth. A non-Cursor harness reads the
same inputs, resolves the same row, and performs the described procedure directly.

## Resolver API

`tools/mep/bin/mep where <slug> --json` is the public resolver API for now. Do not add a separate
`resolve` command until an adapter needs a distinct verb.

Every successful `where --json` packet includes:

```json
{
  "status": "ok",
  "row": 7,
  "executionRequest": {
    "kind": "implement",
    "target": "wiki/prep/demo/iterations/01-ready.md",
    "argv": ["wiki/prep/demo/iterations/01-ready.md"]
  },
  "nextCommand": "/implement-plan wiki/prep/demo/iterations/01-ready.md",
  "reason": "human-facing prose",
  "proof": {
    "version": 1,
    "api": "where",
    "source": "resolver",
    "row": 7,
    "executionRequest": {
      "kind": "implement",
      "target": "wiki/prep/demo/iterations/01-ready.md",
      "argv": ["wiki/prep/demo/iterations/01-ready.md"]
    },
    "nextCommand": "/implement-plan wiki/prep/demo/iterations/01-ready.md",
    "facts": {
      "...": "resolver facts"
    }
  }
}
```

`executionRequest` is the durable routing field. It has exactly `kind`, `target`, and `argv`;
`proof.executionRequest` is identical to the envelope field. The resolver derives it from the selected
row, never by parsing `nextCommand`. Kinds are `implement`, `checkpoint`, `commit_prep`, `prep`,
`migrate`, `cleanup`, and `none`; `target` is the brief path or slug, and is null only for `none`.

`nextCommand` remains optional adapter presentation for Cursor and may be null. Non-Cursor consumers
must dispatch from `executionRequest`, not parse the slash string. `reason` is for operators. `proof`
is for adapters, events, tests, and future replay; consumers should key on `proof.version`,
`proof.api`, `proof.row`, `proof.executionRequest`, and named `facts` fields.

## Continuation Contract

When a handoff needs "what next?", the agent resolves it in-turn:

1. Read the plan documents and git state.
2. Select the first matching resolver row in `glossary.md`.
3. Output the concrete next procedure or command.
4. Never ask the operator to run `/mep where` as the next step.

If the harness cannot execute slash commands, translate the resolved command into the underlying
procedure:

| resolved command | portable procedure |
|------------------|--------------------|
| `/prep <slug> checkpoint` | **atomic session:** step 0 `mep checkpoint --json [--fix]` when git proves a slice landed; amend belief state (`03-core-vs-volatile`); optional landed-slice retrospective; draft next brief; **brief preflight** on draft (`brief-preflight-check.md`); human approves → `brief_ready`; then `/commit-prep docs-delta` if prep changed. Do not re-resolve until the session completes. |
| `/implement-plan <briefPath>` | implement only that brief; treat prior prep docs as constraints, not extra scope |
| `/commit-prep <slug> [mode]` | stage the intended scope, run the commit-prep audit gates, then hand the human the raw message block followed by the simplest valid commit command block |
| `/prep-cleanup <slug>` | perform the final cleanup pass and write graduation notes after explicit confirmation |
| `/prep-pr-description <slug> <n>` | render the reviewer-facing PR body from the brief, roadmap, and branch diff |

## PR Rendering

When `where --json` returns `optionalSteps[]` for row 10, the first entry is the optional
`/prep-pr-description` interstitial. `nextCommand` remains checkpoint; presentation is not blocking.

PR creation is presentation, not a blocker. Render the body to `wiki/pr-descriptions/<slug>-<n>-<short>.md`,
then offer:

1. optional review presentation via `gh pr create --body-file <path>`
2. the resolved local continuation from the resolver (`nextCommand`, not an optional step)

Review-stack presentation is governed by the Review-stack aside in `glossary.md`; this section only
renders the body and the resolver-derived local continuation.

If `gh` is unavailable, the file is still the deliverable; the operator can paste it into the host
review system.

## Commit Handoff

Commit-prep handoff always presents:

1. `Commit message:` followed by a standalone `text` code block containing only the one-line message.
2. `Commit command:` followed by a standalone `bash` code block.
3. The continuation step outside the command block.

For checkpoint `docs-delta`, the normal continuation after the human commit is to re-read the plan
documents + git, resolve the next command, and print that concrete command. In Cursor, use
`tools/mep/bin/mep where <slug> --json` and hand off its `nextCommand`; do not hand off
`/mep next <slug>`.
Review-stack presentation remains the glossary's aside, not a commit handoff route.

For one-line messages, use the simple form:

```bash
git commit -m "<type>(<scope>): <summary> <gitmoji>"
```

Use a heredoc only for intentionally multiline messages or genuinely ambiguous shell quoting.

## Implementation Handoff

For a brief handoff outside Cursor, say:

> implement only `<briefPath>`. file ownership in that brief is exhaustive. treat earlier prep docs as
> constraints and do not read future iterations unless the brief explicitly allows it.

## Hook Substitute

Cursor hook wiring is optional. The portable checks are the shell scripts under `.cursor/hooks/`.

Before committing staged framework-spine files, run:

```bash
mapfile -t spine < <(git diff --cached --name-only --diff-filter=d -- .cursor/skills .cursor/commands .cursor/agents)
.cursor/hooks/scaffolding-free-check.sh "${spine[@]}"
```

For slice-owned product paths, run:

```bash
.cursor/hooks/scaffolding-free-check.sh --product-code <slice-owned product paths>
```

The `.cursor/prep-active` guard has no complete git-native equivalent because it blocks more than
`pre-commit`. Outside Cursor, agents must manually check for `.cursor/prep-active` before effectful
`git` or `gh` operations and stop unless the relevant handoff says the operation is allowed.

## Implementation History

For row 10 recovery, broad owned-path history is not enough proof. The resolver treats
`currentIterationRecord.implementationPaths` as the slice deliverable paths when present, including
prep-tree artifacts such as architectural inventory files. Without that field, it falls back to
initiative `ownedPaths` with configured planning roots excluded.

## Portable Bundle

The commit-prep bundle must include these peer docs:

- `.cursor/skills/mise-en-place/brief-preflight-check.md`
- `.cursor/skills/mise-en-place/slice-integrity-check.md`
- `.cursor/skills/mise-en-place/code-integrity-check.md`
- `.cursor/skills/mise-en-place/portable-routing.md`
