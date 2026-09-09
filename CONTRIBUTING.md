# Contributing to `mep`

The root README shows you the loop from the outside — run
[Start here](README.md#start-here-try-it-in-two-minutes) first if you haven't, so you know the CLI
works on your machine. This page picks up where that leaves off: how to point `mep` at your own
project, write your own plans, and get a long branch into a shape someone can review.

Nothing here needs an API key or a model subscription. The bundled `stub` executor stands in for a
real agent, and `mep` never stores credentials of any kind.

## Point the tool at your project

Everything specific to *your* repo — where code lives, which review notes to load, how to run the
tests — lives in a **profile**. The CLI itself stays generic, so retargeting it never means editing
`tools/mep/lib`.

A profile is two files: markdown you write for people, and JSON the tool actually reads.

1. Copy [`tools/mep/examples/profiles/example-stub.md`](tools/mep/examples/profiles/example-stub.md)
   to `.mep/profiles/<name>.md` and replace the placeholders with facts about your repo.
2. Add `.mep/profiles/<name>.json` next to it. This is the file the tool reads; the markdown is
   there for humans, so list it under `referenceOnly`. The available fields are documented in
   [`tools/mep/docs/profile-capabilities.md`](tools/mep/docs/profile-capabilities.md).
3. Tell `mep` about it in `.mep/config`:

   ```text
   profile.active=<name>
   profile.dir=.mep/profiles
   ```

4. Confirm the tool sees what you meant:

   ```bash
   tools/mep/bin/mep profile dump --json
   ```

This checkout's own profile is [`.mep/profiles/default.json`](.mep/profiles/default.json) — a
working example rather than a template. If you use the Cursor slash commands, you may also see a
prose copy under `.cursor/skills/mise-en-place/profiles/`; that's part of the editor overlay, not
something a new project needs.

## Write and land a slice

The README explains the shape of the loop. What it can't tell you is how *small* each piece should
be, so that's what this section is about: a slice is one mergeable piece of work, and a brief is the
short plan you write before touching code.

1. **Open an initiative.** `/mep start <slug>` on an empty tree sets up planning notes from scratch.
   If the branch already has work on it that belongs to this effort, `/tidy <slug>` writes the notes
   you skipped instead of pretending you started clean.
2. **Write one brief for the next piece.** Say what files it owns, what "done" means, and what is
   deliberately out of scope. A brief should move exactly one thing from uncertain to settled — if
   yours moves two, you have two slices.
3. **Build only what that brief describes.** The file list in the brief is the whole permission;
   anything else belongs to a later slice. In Cursor that's `/implement-plan <brief>`; from a shell,
   hand `mep where` output to `mep exec dispatch`.
4. **Let a human commit.** `/commit-prep <slug>` stages the work, audits it, and hands you a commit
   message — it never commits for you. Keep product code and planning notes in separate commits, or
   the router can no longer tell which change proved which plan.
5. **Checkpoint before planning the next piece.** Once the slice is on the branch,
   `/prep <slug> checkpoint` is a single sitting: it reconciles the notes with git, records what you
   actually learned, and drafts the next brief. It isn't a sequence of commands you drive by hand.

Whenever you lose your place, ask the tool instead of guessing:

```bash
tools/mep/bin/mep where <slug> --json
```

The field to act on is `executionRequest`. How the tool decides is one table, and it lives in the
[glossary](tools/mep/docs/glossary.md) — deliberately not repeated here, so if this page and that
table ever disagree, believe the table.

If you want to see what the tool has been doing, `mep events tail --json` prints a local history
log. It's there for reading; nothing routes off it. Details in
[`tools/mep/docs/event-ledger.md`](tools/mep/docs/event-ledger.md).

## Turn a long branch into something reviewable

Development order and reading order aren't the same thing. A branch that took twenty slices to
figure out makes a terrible twenty-PR series and an even worse single diff. **Curate** rewrites the
*explanation*, not the code: it groups what you built into an order that makes sense to someone
reading it for the first time, then puts that version of history on fresh branches. The branch you
developed on is never rebased or edited.

1. **Ask for a plan, and approve it.** Proposing the grouping is a writing job, so it's the agent's
   half: `/mep curate <slug>` drafts the plan and stops. Nothing reaches git until you accept it,
   and you're approving the explanation, not the code — the code already exists.
2. **Check the mechanical parts yourself.** The CLI half is deterministic and needs no model. It
   reports where curation stands, sizes the change, and checks the plan against its schema:

   ```bash
   tools/mep/bin/mep curate <slug> --json --preview
   tools/mep/bin/mep curate <slug> --json --measure
   tools/mep/bin/mep curate <slug> --json --validate
   ```

3. **Then execute.** Try it dry first, then confirm. This creates the reviewable branches
   (`integrate/<slug>/course-*`); your development branch stays exactly as it was:

   ```bash
   tools/mep/bin/mep curate <slug> --json --execute --dry-run
   tools/mep/bin/mep curate <slug> --json --execute --confirm
   ```

4. **Hand the result to `/mep stage <slug>`** to turn those branches into a review stack. Stage also
   previews before it changes anything.

Worked commands are in
[`tools/mep/examples/curate-walkthrough.md`](tools/mep/examples/curate-walkthrough.md); the
reasoning behind the grouping rules is in
[`.mep/plans/mep-curate-outline.md`](.mep/plans/mep-curate-outline.md).

## Examples worth copying

| example | what it shows |
|---------|---------------|
| [`.mep/prep/fixture-demo`](.mep/prep/fixture-demo) | the smallest initiative the router can point at — the one README steps 3–4 use |
| [`tools/mep/examples/profiles/example-stub.md`](tools/mep/examples/profiles/example-stub.md) | a profile you can copy and fill in |
| [`tools/mep/examples/curate-walkthrough.md`](tools/mep/examples/curate-walkthrough.md) | curating a branch end to end, without needing to ask the maintainer |

## What this page isn't

It isn't a second copy of Start here, it isn't the release checklist, and it doesn't describe a
shipping integration with any commercial agent — `stub` is still the only executor that runs.
