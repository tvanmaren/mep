# Slice integrity self-check

**Sibling (plan layer):** `brief-preflight-check.md` — same **scoped** vocabulary at checkpoint on the
**draft brief** before implement. This file judges the **staged diff** after implement.

**What this is:** the check an agent runs at `/commit-prep` — before handing a staged slice to the
human's `git commit` trigger — to verify the agent **actually delivered what its slice brief
contracted**. It targets agent self-deception, not human error.

**Why it isn't redundant with the human commit gate.** That gate is a *trigger-pull over an
LLM-produced handoff*: the agent resolves scope, stages, runs the audit, and writes the message;
the human approves cleanup and commits, trusting the handoff. So the integrity of what the human
signs off is set by the agent. This check hardens that step — and frees the human to judge what
only a human can (*is this the right thing to build*) instead of bookkeeping (*did the agent skip
tests*).

**Unit:** one slice — its staged **diff**, judged against its **slice brief** (the contract) and
the **manifest**. Never the commit message; that's one line and holds none of this.

## Inputs (how an agent gets them)

Resolve from the active initiative's `wiki/prep/<slug>/manifest.json`, the same way `/commit-prep`
resolves its scope:

- **slice brief** — `wiki/prep/<slug>/iterations/<n>-*.md` for the slice being committed; its
  file-ownership table and acceptance criteria *are* the contract.
- **staged diff** — `git diff --cached`, scoped to that brief's file ownership.
- **manifest** — `wiki/prep/<slug>/manifest.json`, for stack / iteration state.

## Core checks — does the diff honor the brief? (run these)

Run them as a dimension of the cross-model second opinion `/commit-prep` already dispatches
(`staged-audit-scout`, opposite-family model). A reviewer that did **not** write the code is the
only one that reliably catches the author's self-deception. Feed it the slice brief as the
contract:

- **faithful** — the diff delivers the brief's claimed file-ownership and acceptance criteria;
  in-code intent markers stay consistent.
  *fails when:* the diff does things the brief never claimed, or omits what it promised.
- **scoped** — one nameable purpose matching the brief; no "while I was in here" sprawl.
  *fails when:* unrelated concerns ride along.
- **honestly-tested** — the tests the brief claimed exist *and actually exercise the claimed
  behavior*.
  *fails when:* "covered by branch tests"; assertions that never touch the behavior.

## Delegated — already `staged-audit`'s job (do not reimplement)

- **clean** — no generated / vendored / build output committed alongside logic.
- test *presence*, generic code-quality, secrets.

Point at `staged-audit` for these. The integrity check adds only the brief-contract judgment
above, which `staged-audit` does not do — it reads the diff in isolation.

## Human-reviewer rendering (built — see reviewer-checklist.md)

- **situated** (what the slice provides / builds on) and **mapped** (its place in the stack) are
  rendered for a human reviewer at `/prep-pr-description`, **translated to plain developer
  language** — the reviewer never sees these names. The standard lives in
  `.cursor/skills/mise-en-place/reviewer-checklist.md`.

## Principles (stable)

- Judge **structure / presence / honesty, never magnitude** — no LOC / file / commit thresholds.
- The check names (`faithful`, `scoped`, `honestly-tested`, `clean`, `situated`, `mapped`) are the
  stable interface that later consumers reference; rename only before anything embeds them.
- These checks were derived empirically, not invented; provenance lives in
  `wiki/prep/mep-framework-maturation/`.

## When

At `/commit-prep`, on the staged index, before the human commits — core checks via the cross-model
scout, delegated checks via `staged-audit`. The human-reviewer projection (`situated`/`mapped`) is
rendered separately at `/prep-pr-description`, in plain language (see `reviewer-checklist.md`).
