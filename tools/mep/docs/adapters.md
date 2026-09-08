# Executor Adapter Contract

`mep where <slug> --json` decides the next action. `mep exec dispatch --json` invokes the configured
executor with that action. Dispatch consumes only the `executionRequest` object; it never parses
`nextCommand`.

```bash
tools/mep/bin/mep where fixture-demo --json \
  | jq -c .executionRequest \
  | tools/mep/bin/mep exec dispatch --json --executor stub
```

The same object can be supplied with `--request-json '<json>'`. `--dry-run` preserves the request and
executor selection while suppressing executor effects.

## Configuration

Configuration remains newline-delimited `key=value` in `.mep/config`:

```text
executors.default=stub
executors.presets.stub.kind=stub
executors.presets.stub.command=internal:stub
executors.presets.cursor.kind=command
executors.presets.cursor.command=cursor
executors.presets.cursor.env.EXAMPLE_HINT=value
executors.presets.grok.kind=command
executors.presets.grok.command=grok
```

Preset names are extensible. Each preset has `kind` and `command`; optional
`executors.presets.<name>.env.<NAME>` entries are non-secret environment hints. API keys, access
tokens, prompt bodies, and credentials do not belong in MEP config.

Host adapter overrides are limited to binary path (`command`), profile name, and timeout. Profile
and timeout are documented adapter inputs, not runtime config keys; adding those keys
requires a working live driver. Prompt bodies and API keys are never adapter overrides.

## Audited Presets

| preset | contract | ships a live driver |
|--------|----------|---------------------|
| `stub` | in-process deterministic acceptance of every valid execution kind | yes |
| `cursor` | command contract for a Cursor host adapter | no |
| `claude-code` | command contract for a Claude Code host adapter | no |
| `codex` | command contract for a Codex host adapter | no |
| `grok` | command contract for the Grok TUI / standalone harness (not Cursor-hosted Grok) | no |

Only `stub` executes in-tree. Selecting a documented command preset returns
`blocked` / `executor_driver_unavailable` until an external host adapter is supplied.
The runtime never shell-evaluates preset `command` strings.

## Workflow Primitives

| execution kind | CLI primitive |
|----------------|---------------|
| `implement` | `mep implement --json <briefPath>` (read-only scope packet) |
| `checkpoint` | `mep checkpoint <slug> --json [--fix]` |
| `commit_prep` | `mep commit scope <slug> --json` (read-only path packet) |
| `prep` | `mep evidence write <slug> prep <state> --json [--dry-run]` |
| `cleanup` | `mep evidence write <slug> cleanup <state> --json [--dry-run]` |
| `none` | no-op |

`mep mode set <slug> <mode> --json [--dry-run]` is the deterministic writer for initiative-level
authorship mode. `mep evidence write` appends local evidence to `.mep/history/evidence.jsonl`; the
ledger is observability, not routing state. External composition scripts call these verbs;
they do not reimplement product behavior.
