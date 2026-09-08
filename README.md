# mise-en-place (`mep`)

Plan the next reviewable unit of work, ship it, checkpoint what you learned, repeat.

You stay the chef. The agent is the sous.

**CLI:** `mep`  
**Repo:** [`tvanmaren/mep`](https://github.com/tvanmaren/mep)

## Start here

| doc | what it is |
|-----|------------|
| [mep-vision-one-pager.md](.mep/plans/mep-vision-one-pager.md) | the short version |
| [mep-vision-proposal.md](.mep/plans/mep-vision-proposal.md) | the long version |
| [mep-authorship-modes.md](.mep/plans/mep-authorship-modes.md) | manual / default / autopilot, and why `code-monkey` is deliberately empty |
| [mep-curate-outline.md](.mep/plans/mep-curate-outline.md) | how curate compresses development history |
| [mep-v0.2-outline.md](.mep/plans/mep-v0.2-outline.md) | what v0.1 deliberately leaves unfinished |

## Layout

Design docs live under configured `storage.plansRoot` (engine default **`.mep/plans`**). Initiative ledgers live under `storage.prepRoot` (default **`.mep/prep`**). `manifest.json` is transitional runtime storage, not the spec.

A host may overlay those paths (for example `wiki/prep`) in `.mep/config`. That is a host choice, not identity.

## Two ways in

**Stranger / CI:** no `.mep/config`. Defaults: `.mep/prep`, adapter `plain`, profile `default`. Proof: `bash tools/mep/test/run-stranger.sh`.

**Cursor in this repo:** committed `.mep/config` sets `runtime.adapter=cursor`, `runtime.spine`, and `vcs.defaultTrunk=master` (this repo's trunk). It does **not** set `storage.prepRoot` or a host `profile.active`.

## Workflow

```text
mep where <slug> --json
mep exec dispatch --json --executor stub
```

`where` emits `executionRequest`. `exec dispatch` is the invoke seam; only the stub driver ships in-tree. Slice-boundary litmus and v0.1.0 packaging are **not** shipped yet. See `.mep/prep/mep-v0-graduation/04-iteration-roadmap.md`.

## License

MIT
