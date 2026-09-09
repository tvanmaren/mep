# Example Profiles

A profile is where a repo's own semantics live: which uncertainties get reduced how, where code
belongs, how the tests run, and which review notes to load. Keeping those facts in a profile is what
lets the same engine drive different repos without edits.

The files in this directory are examples shipped with the tool, not the active profile for any
project. A real one belongs under the configured `profile.dir`, which is usually `.mep/profiles`.

`example-stub.md` is the markdown skeleton you copy and fill in. The tool itself only reads
`<profile.dir>/<profile.active>.json`, described in
[`profile-capabilities.md`](../../docs/profile-capabilities.md) — the markdown is for people. Setup
steps are in the repo-root [CONTRIBUTING.md](../../../../CONTRIBUTING.md).

A project can keep its profile private; nothing requires publishing it here.

## Where to look

| file | role |
|------|------|
| [`example-stub.md`](example-stub.md) | the copy-and-fill markdown; name it in the JSON `referenceOnly` list |
| [`.mep/profiles/default.json`](../../../../.mep/profiles/default.json) | this repo's live profile — a working example, not a second skeleton |
