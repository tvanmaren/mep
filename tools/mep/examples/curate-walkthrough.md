# Curate walkthrough

Reach for this when a branch has grown past the point where anyone can review it in one sitting.
It's a worked example, so you shouldn't need to ask the maintainer anything to follow it. The
reasoning behind the rules is in
[`mep-curate-outline.md`](../../../.mep/plans/mep-curate-outline.md).

## What curate actually does

Curate changes how the work is *explained*, not what the work is. It keeps every concept you
landed and drops the wrong turns and the order you happened to discover things in, then writes that
cleaner version of the story onto new branches.

The branch you developed on is the record of what really happened. Curate never rebases it or
commits to it, so you can always go back and see how you got here.

One thing to expect: the reviewable groupings almost never line up one-to-one with the slices you
built. Grouping for a first-time reader is a different problem than sequencing your own discovery.

## Who does which half

Proposing the grouping means writing an explanation, so an agent does it: `/mep curate <slug>`
drafts a plan and waits for you to accept or redirect it. Everything below is the other half — the
deterministic commands that measure, check, and materialize what you approved. They need no model
and no credentials.

## The commands

Run these from a checkout that already has planning notes at `.mep/prep/<slug>/`.

See where curation stands — whether a plan exists, how many groupings it has, whether it's been
executed:

```bash
tools/mep/bin/mep curate <slug> --json --preview
```

Size the change and check the plan against its schema. Both need the plan file to exist already —
without it they report `not_found` rather than guessing:

```bash
tools/mep/bin/mep curate <slug> --json --measure
tools/mep/bin/mep curate <slug> --json --validate
```

Write an empty plan file to fill in by hand instead:

```bash
tools/mep/bin/mep curate <slug> --json --template
```

Create the reviewable branches — dry run first, then for real. Your development branch is left
alone. A dirty working tree blocks this, apart from the curation artifacts themselves:

```bash
tools/mep/bin/mep curate <slug> --json --execute --dry-run
tools/mep/bin/mep curate <slug> --json --execute --confirm
```

The plan is written to `.mep/prep/<slug>/integration-curation.json`, alongside an `.md` version when
you're running through an editor. The branches are named `integrate/<slug>/course-*`.

To turn those branches into an actual review stack, run `/mep stage <slug>` — it previews first too.
Curate stops at the branches; it doesn't open pull requests.

## Things that defeat the purpose

- Editing or rebasing the branch you developed on. That's the honest record; leave it alone.
- Adding code during curation. If it wasn't built, it doesn't belong in the story.
- Treating a `stub` run as review. `stub` proves the plumbing, not the work.
