# Graduation — mep-v0-graduation

**Status:** graduated  
**Date:** 2026-09-10

## Summary

Epic #85 / v0.1 program is closed. Last product slice is **17** (`09f8e54`, document-state
module). v0.1.0 remains tagged at `66373b3`; document-native state is **v0.2.0**. A2/B/C/D and 0.4 stay on
`.mep/plans/mep-v0.3-outline.md` as a **new** initiative — not more iterations here.

01 success **#3** (stranger + live preset + three modes) is still false. that is D0, not a
cleanup/evidence slice; 15 already named it deferred.

## Tags removed

Initiative `@experimental|@provisional|@stable|@foundational|@reference-only` **comment markers**
on runtime and test files were rewritten to durable intent (tag token stripped). vocabulary docs
that *define* the tagging system were left alone — they are the product.

| file | tag | action taken |
|------|-----|--------------|
| `tools/mep/lib/document.sh` | `@stable` ×2 | durable persistence / frontmatter-block comments |
| `tools/mep/lib/resolver.sh` | `@stable` ×2 | durable row / executionRequest comments |
| `tools/mep/lib/exec.sh` | `@stable`, `@provisional` | durable dispatch / stub comments |
| `tools/mep/lib/workflow.sh` | `@provisional` | durable open-finish commit gate |
| `tools/mep/lib/migrate.sh` | `@provisional` | durable one-release bridge |
| `tools/mep/lib/events.sh` | `@provisional` | durable history-is-not-routing |
| `tools/mep/lib/checkpoint.sh` | `@provisional` | durable key-spelling instance |
| `tools/mep/lib/manifest.sh` | `@provisional` | durable one-release importer |
| `tools/mep/lib/registry.sh` | `@stable` | durable shell-contract comment |
| `tools/mep/lib/finish.sh` | `@stable`, `@provisional` | durable comment-line / readiness-fact comments |
| `tools/mep/lib/mark.sh` | `@provisional` | durable writer comment |
| `tools/mep/docs/pilot-default-mode.md` | `@reference-only` | HTML comment already said not-a-routing-contract |
| `tools/mep/test/run-*.sh` (unix-contract, stranger, golden-matrix, mark, finish-scan, manual-workflow, mode-resolver, events) | file-header `@stable`/`@provisional` | durable suite purpose comments |

## Durable comments kept

| file | comment | why it stays |
|------|---------|--------------|
| `document.sh` / `resolver.sh` / `exec.sh` / `finish.sh` / `migrate.sh` / `manifest.sh` / `events.sh` | invariant prose after tag strip | C7/C8/C9/C12 and one-release adapters |
| `mark.sh` / `finish.sh` runtime | `@mise` / `@finish:*` **matchers and writers** | product: these implement the marker protocol for *consumer* trees |
| tests | planted `# @finish:open` / `# @mise` in fixtures | they exercise the product |
| `maturity-tags.md`, glossary, templates, example-stub, execution-policies, SKILL | documented `@` vocabulary | evergreen framework docs, not this initiative's in-code trail |
| `checks.sh` allowlist | sanctioned tag regex | future initiatives still need the gate |

Naive `rg '@(experimental|…)'` over all `mepOwnedPaths` still hits **docs that teach the
ladder**. that is expected. implementation comment markers in `tools/mep/lib/*.sh` and
`tools/mep/test/run-*.sh` headers are gone.

No `@mise` / `@finish` **wrappers** were sitting on this repo's own lib as process
scaffolding (the engine *emits* those into other trees). none to strip there.

## Verification

- [x] lib/test process `@` maturity comment markers stripped
- [x] FOSS suites (unix-contract, goldens, stranger, litmus stub) green at graduation
- [ ] `/commit-prep mep-v0-graduation` — code scope (tag strip)
- [ ] `/commit-prep mep-v0-graduation docs-delta` — this file + 17 close (no iter 18)

## Final PR

`/pr-description` — graduation PR; epistemic lead: v0.1 program complete through document-native
state; #3 and v0.3 remain explicit non-claims.
