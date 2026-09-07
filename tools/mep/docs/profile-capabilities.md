# Profile Capabilities

`mep profile dump --json` is the runtime read surface for the active structured profile seed.

The active profile is resolved from `.mep/config`:

- `profile.active` names the profile.
- `profile.dir` names the directory.
- The seed path is `<profile.dir>/<profile.active>.json`.

The command returns a shell-friendly packet:

```json
{
  "status": "ok",
  "profile": {
    "active": "example",
    "dir": {
      "relative": ".mep/profiles",
      "absolute": "/repo/.mep/profiles"
    },
    "seed": {
      "relative": ".mep/profiles/host.json",
      "absolute": "/repo/.mep/profiles/host.json"
    }
  },
  "schemaVersion": 1,
  "capabilities": {},
  "referenceOnly": []
}
```

The initial seed is intentionally narrow:

- `capabilities.classify.zones[]` describes repo-local semantic zones and path hints.
- `capabilities.review.inputs[]` names review inputs an adapter may load before auditing code.
- `capabilities.publication` (optional) binds review-stack serialization to a repo-local substrate.
- `referenceOnly[]` names prose surfaces runtime and adapters must not scrape as config.

## Optional: `capabilities.publication`

Omit when the repo has no preferred stack tool. Curate's epistemic model (merge courses + review
shards) stays portable either way; only `/mep stage` and adapter prose change when this object is
present.

| field | meaning | examples |
|-------|---------|----------|
| `stackBackend` | remote review surface | `github-native`, `graphite`, `branch-chain`, `none` |
| `tool` | local cli that owns branch/stack ops | `gh-stack`, `gt`, `jj`, `sapling`, `git-town`, `none` |
| `defaultSerialization` | how courses/shards become PRs | see below |

### Units (unchanged from curate)

| unit | ~size | role | independently runnable? |
|------|-------|------|-------------------------|
| **merge course** | ~2k | develop gate — next shippable trunk truth (course tip) | **yes** |
| **review shard** | ~300 (≤500) | stack/PR layer — attention budget; may be progressive inside its course | **no** |
| **discovery slice** | n/a | lab-branch learning unit — never the publication unit | n/a |

**Stability invariant (course-scoped):** no progressive unfinished **courses**. Tip N must leave trunk
coherent without tip N+1. Within a course, shard PRs may be progressive / not product-runnable. If
shard n+1 must rewrite n’s reviewed surface to become true **and** that rewrite crosses a course
boundary, the course cut was wrong. Lab commit chronology is evidence, not stack shape.

### `defaultSerialization` values

| value | meaning |
|-------|---------|
| `stack-of-shards` | **preferred for native stacks** — layers = review shards (not whole merge courses); merge courses mark which tip is the develop gate; stack may be one course’s shards or a linear run of several |
| `stack-of-merge-courses` | layers = whole merge courses; shards are nested commits inside each course PR |
| `course-branches-nested-commits` | one branch/PR per merge course; shards as nested commits (no native stack UX) |

Stacks are typically linear — do not plan DAG publication. Pick **one** remote authority
(`stackBackend`); do not dual-submit to github-native and graphite for the same work.

Adapters (`/prep-curate`, `/prep-stage`) read this via `mep profile dump --json`. Portable CLI
(`mep curate execute`) stays substrate-agnostic: it materializes integration branches; stage binds
them to the declared tool.

Markdown profile prose remains human reference. Runtime reads structured JSON only. Smoke/check
execution, reducers, house patterns, authorship policy, templates, review-rubric schema, and broad
Unix-hardening contracts stay out of this seed until a later slice proves they need structure.

If the active seed is missing or malformed, `profile dump --json` exits nonzero and returns a JSON
error packet. Commands that do not explicitly consume structured profile policy, including `where`,
must continue to work without the seed.
