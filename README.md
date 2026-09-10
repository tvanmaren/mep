# mise-en-place (`mep`)

A planning tool for building software with an AI agent, one reviewable piece at a time.

**CLI:** `mep` · **Repo:** [`tvanmaren/mep`](https://github.com/tvanmaren/mep) · **License:** MIT

## What problem this solves

When you build something genuinely new with an AI agent, two things tend to go wrong. Either you
try to design the whole feature upfront and half your decisions turn out to be guesses, or you let
the agent run and end up with a 4,000-line branch nobody can review.

`mep` takes the middle path. You plan **only the next mergeable piece** of work, build it, write
down what you actually learned, and then plan the next piece using that knowledge. Each piece is
small enough to review honestly.

The other half of the tool is about **who decides what**. The agent can do a lot — scaffolding,
mechanical edits, tests, staging commits — but some choices are genuinely yours. `mep` makes that
line explicit in the code and refuses to call a piece "done" while a decision you own is still
unanswered. In the project's own shorthand: you're the chef, the agent is the sous.

## Vocabulary (four words, then you're fluent)

| word | means |
|------|-------|
| **initiative** | one body of work you're pushing toward, named by a short **slug** like `payment-retries`. |
| **slice** | one mergeable piece of an initiative. Roughly one PR. Each slice gets a written brief before code. |
| **brief** | the plan for one slice: what it owns, what "done" means, what's explicitly out of scope. |
| **checkpoint** | after a slice lands, you record what became certain and re-plan the next slice from reality. |

Everything else in the tool is in service of that loop:

```text
plan a slice → build it → commit → checkpoint → plan the next slice → … → done
```

## Start here: try it in two minutes

You'll need `bash`, `git`, `jq`, and `ripgrep`. There's no install step yet and no API keys
involved — you run the script straight out of the checkout.

**1. Clone the repo and go in.**

```bash
git clone https://github.com/tvanmaren/mep.git
cd mep
```

**2. Check the CLI runs.** It lives at `tools/mep/bin/mep`.

```bash
tools/mep/bin/mep version --json
```

```json
{"status":"ok","version":"0.1.0"}
```

**3. Ask the tool what to do next.** The repo ships a tiny example initiative called
`fixture-demo` so you have something to point at:

```bash
tools/mep/bin/mep where fixture-demo --json | jq '{state, nextCommand, executionRequest}'
```

```json
{
  "state": "plan is ready -> build the slice",
  "nextCommand": "/implement-plan .mep/prep/fixture-demo/iterations/01-ready.md",
  "executionRequest": {
    "kind": "implement",
    "target": ".mep/prep/fixture-demo/iterations/01-ready.md",
    "argv": [".mep/prep/fixture-demo/iterations/01-ready.md"]
  }
}
```

That's the core move. `mep where` reads your plan files and git, works out which step of the loop
you're actually on, and hands back the next action. You never have to remember what phase you're
in.

**4. Hand that action to an agent.** `mep` doesn't call a model itself — it emits the request and
something else runs it. The built-in `stub` executor stands in for a real agent so you can watch
the plumbing work:

```bash
tools/mep/bin/mep where fixture-demo --json \
  | jq -c .executionRequest \
  | tools/mep/bin/mep exec dispatch --json --executor stub
```

```json
{"status":"ok","executor":"stub","result":{"kind":"stub","accepted":true,"primitive":"mep implement"}}
```

`accepted: true` means the request was well-formed and routed. Nothing was written — `stub` is a
test double, not an agent.

**5. Confirm the whole thing on your machine.**

```bash
bash tools/mep/test/run-stranger.sh
bash scripts/litmus/slice-boundary.sh --executor stub
```

The first proves `mep` works in a bare checkout with no configuration. The second walks a full
slice boundary using only public commands. Both run in CI on every push.

## Two ways to drive it

**Shell.** Steps 3–4 are the loop: `mep where` names the next action, `mep exec dispatch --executor stub` pretends to run it. Keep using that from this checkout. You don't need Cursor, and you don't need a config file for stub.

**Cursor, in this checkout.** The committed `.mep/config` turns on slash commands (`/mep next`, `/prep`, `/implement-plan`, `/commit-prep`) over the same engine — see [the framework guide](.cursor/skills/mise-en-place/README.md). That overlay does **not** change where plans live.

The no-config proof is step 5 (`run-stranger.sh`): a throwaway clone with no `.mep/config` at all. That's CI, not a second onboarding path.

Ready to point it at your own project? [CONTRIBUTING.md](CONTRIBUTING.md) covers profiles, writing a slice, and curating a long branch for review.

## Connecting your own agent

Two commands matter: `mep where` tells you the next action, and `mep exec dispatch` hands that
action to an executor. Which executor runs is one line in `.mep/config`:

```text
executors.default=stub
```

Besides `stub`, the tool ships **named contracts** for the agents people actually use — `grok`
(the standalone TUI, not the Cursor model), `cursor`, `claude-code`, and `codex`. A contract is a
documented name and command shape, not a working integration. Ask for one today and you get a
clear refusal rather than a surprise:

```json
{"status":"blocked","reason":"executor_driver_unavailable",
 "detail":"executor preset 'grok' is a documented command contract; no live driver ships in-tree"}
```

That's deliberate. `mep` never stores your API keys and never ships a vendor SDK; when live drivers
land, they'll invoke **your** binary with **your** credentials. Until then `stub` is the only
executor that actually runs.

## Scripting against it

Every machine-facing command follows one contract, so you can use `set -e` instead of parsing
prose:

- JSON on stdout, human diagnostics on stderr — the two never mix.
- The exit code always agrees with the JSON `status`: `0` when you're fine (`ok`, `clean`), `1`
  when something needs attention but isn't fatal (`desync`, `gated`, `warning`), `2` when the tool
  refused (`blocked`, `missing_dependency`), `3` for `not_found`, `64` for bad usage, `70` for an
  internal bug. Full table in [the tool docs](tools/mep/docs/README.md).
- `tools/mep/bin/mep help` lists every command.

## Where things live

| path | what's there |
|------|--------------|
| `.mep/prep/<slug>/` | one folder per initiative — its briefs, belief state, and roadmap |
| `.mep/plans/` | longer-lived design documents |
| `tools/mep/bin/mep` | the CLI |
| `tools/mep/test/` | the test suites, all runnable by hand |

Both roots are configurable in `.mep/config`, so a project that already keeps docs in `wiki/` can
point `mep` there instead.

## Project status

The latest tag is **v0.1.0**; main is building **v0.2.0**. The short version: the planning half works
end to end, document-native state has landed after the tag, and the half where a real agent does the
building is still ahead of us.

**What works today**

- The whole loop, from this checkout. `mep where` tells you the next step, and each checkpoint
  re-plans from what actually shipped rather than from the original guess.
- The shell contract. JSON on stdout, diagnostics on stderr, and an exit code that always agrees
  with the reported status — so scripts can branch on it.
- The `stub` executor, which proves the plumbing in CI and fixtures. It is not a way to build
  software; it accepts or refuses a request and writes nothing.
- Decision markers. A choice the tool considers yours blocks the commit until you answer it,
  in every authorship mode.
- The plan documents *are* the state. Routing reads frontmatter on the roadmap and the iteration
  briefs, so there is no sidecar that can disagree with the prose next to it. This landed after the
  v0.1.0 tag; an initiative written under the tag still carries a `manifest.json`, which the resolver
  imports read-only. It can be read and routed, but not checkpointed — `mep migrate <slug> --json`
  writes the modeled facts into frontmatter, reports intentionally retired keys, and is what
  unblocks it.
- Curating a long branch into reviewable ones with `mep curate --execute`, without touching the
  branch you developed on. Stacking those for review is `/mep stage`, on the Cursor overlay
  rather than the CLI.
- [CONTRIBUTING.md](CONTRIBUTING.md), so you can point `mep` at your own project without asking us.

**What doesn't yet**

- **No live agent driver.** `grok`, `cursor`, `claude-code`, and `codex` are documented contracts
  that politely refuse; `stub` is the only executor that runs. Your credentials, your binary — when
  the drivers land.
- **No install path.** Clone it and run it from the checkout. No PATH shim, no package manager.
- **Two of the three authorship modes are beta.** Default mode ran **this** repo through the
  v0.1.0 tag via an agent harness driving the CLI — the failure list is
  [the default-mode record](tools/mep/docs/pilot-default-mode.md). Manual and autopilot pass
  their suites but have not been driven through real work on this remote.

What v0.1 leaves unfinished on purpose is in
[mep-v0.2-outline.md](.mep/plans/mep-v0.2-outline.md); the slice-by-slice ledger is
[the roadmap](.mep/prep/mep-v0-graduation/04-iteration-roadmap.md).

## Going deeper

| doc | what it is |
|-----|------------|
| [the framework guide](.cursor/skills/mise-en-place/README.md) | how the workflow actually feels to use |
| [mep-vision-one-pager.md](.mep/plans/mep-vision-one-pager.md) | the thesis, briefly |
| [mep-vision-proposal.md](.mep/plans/mep-vision-proposal.md) | the thesis, at length |
| [mep-authorship-modes.md](.mep/plans/mep-authorship-modes.md) | how much the agent decides, and why one combination is left deliberately empty |
| [mep-curate-outline.md](.mep/plans/mep-curate-outline.md) | turning messy development history into a reviewable story |
| [mep-v0.2-outline.md](.mep/plans/mep-v0.2-outline.md) | what v0.1 leaves unfinished on purpose |

---

```text
S A T O R
A R E P O
T E N E T
O P E R A
R O T A S
```

*With tools, the coder keeps the cycles moving carefully.*
