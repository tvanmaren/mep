# Invariant goal — mep-v0-graduation

**Phase:** 1  
**Status:** approved  
**JIRA / Shortcut:** Epic #85 — MEP — mise-en-place framework

## Problem (invariant)

MEP is a coherent thesis with a partially closed implementation. The resolver misroutes under real
dogfooding; manual and autopilot modes leave workflow gaps the system does not surface; authorship
markers are optional in practice; and the tool is still Cursor-coupled. v0.1.0 must ship a
**stranger-can-succeed** portable runtime with a **total, boring resolver**, **no silent workflow
gaps**, and a **platform-agnostic executor boundary** — signed with the Sator Square.

The ceremony (finish-map, `@mise` / `@finish`, gates) is valuable **because** an LLM executor can
absorb classification, boilerplate, edits, and audit. A human performing that ceremony without an
executor is pointless — there is no "solo" product mode.

## Success condition

1. **Standalone repo** exists; CI is green.
2. **Unix foundation:** exit codes, `executionRequest`, workflow CLI primitives, pipe litmus with
   **`--executor stub`** (CI test double — not a human-as-classifier path).
3. **Product path:** a stranger configures **one executor preset** in `.mep/config` (minimal overrides)
   and completes real work in **manual / default / autopilot** using **their** credentials — MEP holds
   no API keys. Long initiatives can **`/mep curate`** (preview → execute on integration branches) and
   **`/mep stage`** a review stack.
4. Epic #85 DoD satisfied; **v0.1.0** tagged with Sator Square footer.

## Rejection criteria

- v0.1.0 tagged while `scripts/litmus/slice-boundary.sh --executor stub` fails.
- Runtime requires Cursor, a specific vendor, or MEP-hosted API keys to operate.
- `where --json` emits slash commands as the only durable action (no `executionRequest`).
- Commands return exit 0 for `blocked`/`desync`/`gated` — shell scripts cannot branch without jq.
- A fourth "no LLM" authorship mode ships as operator-facing product (stub is CI-only).

## Layer model (binding)

```text
policy        → authority + evidence rules (manual | default | autopilot)
runtime       → mep CLI: state, routing, requests, validation (keyless)
executionRequest → neutral packet: kind, target, argv, authority, evidence
executor      → user-configured adapter (cursor, claude-code, codex, stub, …)
evidence      → diff, tests, markers, review body, checkpoint result
history       → event ledger
```

**Runtime never calls a model.** Executors fulfill requests; users bring credentials via adapter
config, not MEP env vars.

## Document-native SSOT (binding identity; v0.1 contract layer)

**Steady-state target:** workflow state lives on the plan documents themselves — initiative policy in
`01-invariant-goal.md` frontmatter, slice workflow ledger in each brief's frontmatter, roster in
`04-iteration-roadmap.md`. No central index tracking things *about* markdown outside markdown.

**v0.1 ships:** the **authoring contract** (schema, templates, prep layout) plus `manifest.json` as
**transitional runtime storage** (machine-sync overlay). Strangers orient from documents under
configured `storage.prepRoot` (engine default **`.mep/prep`**). `manifest.json` is not the
specification layer. Hosts may overlay (`wiki/prep` is one overlay, not identity).

| Field class | v0.1 authority | steady-state home |
|-------------|----------------|-------------------|
| Initiative policy (phase, authorshipMode, ownedPaths, gates) | manifest (+ initiative doc mirrors) | initiative frontmatter |
| Slice intent (constitution, finish-map) | brief body | brief body |
| Slice metadata (sliceType, deliveryTrack, fanout) | brief header/frontmatter | brief frontmatter |
| Machine sync (status, revision triplets) | manifest (checkpoint writes) | brief frontmatter |
| Derived orchestration (currentIteration) | manifest | derived at resolve — not persisted |

**v0.1 rejects:** duplicated slice status in brief header *and* manifest without declared authority.

**Post-v0.1 (sc-101):** checkpoint/resolver
read/write document-colocated state; eliminate `manifest.json`.

## Invariants (must survive any implementation)

| Invariant | Falsification |
|-----------|---------------|
| Resolver is a pure function of **persisted workflow state** + git (+ markers) — v0.1: `manifest.json`; steady-state: initiative + brief frontmatter | Routing reads conversation memory or adapter-specific state |
| One lifecycle; authorship modes differ only in who acts/ratifies | Mode-specific lifecycle states or parallel workflows appear |
| LLM integration is executor-pluggable, maximally decoupled | Runtime imports vendor SDKs or embeds prompt bodies |
| Manual is the ownership floor for real use (sous + human finishes) | Product claims meaningful use with zero executor |
| Stub executor is CI/fixture only | Stub documented as normal operator path |
| `/mep where` re-derives after any digression | Operator must remember where they were |
| Sator Square is a hard v0.1.0 README gate | Square moved to optional easter egg or omitted |

## Open questions (defer to briefs)

- **Executor adapter audit (iteration 3):** which presets to ship v0.1 (`cursor`, `claude-code`,
  `codex`, `stub`, …) and what minimal override surface each exposes — audit in brief, not here.
- File-watcher runtime for manual finishes — post-v0.1.0 unless it falls out of marker work.
- AUR/packaging — explicitly out of v0.1.0 scope.
