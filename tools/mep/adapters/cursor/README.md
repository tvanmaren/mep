# Cursor Adapter

Cursor remains an operator-facing adapter over the standalone `mep` tool.

Current adapter behavior:

- `/mep` keeps the six plain verbs: `next`, `where`, `start`, `done`, `stage`, and `mode`.
- Deterministic state reads should prefer `tools/mep/bin/mep status <slug> --compact --json`.
- Concrete next-command routing should prefer `tools/mep/bin/mep where <slug> --json`.
- Mode governance should read `tools/mep/bin/mep finish scan <slug> --json` and the compact status
  `requiredWritebacks` array before advancing a slice.
- Mode governance should prefer `tools/mep/bin/mep lifecycle status <slug> --mode <mode> --json`.
  The lifecycle is shared; mode selects only the actor policy. The report classifies gates as `human`,
  `proxy`, `commit`, `forbidden`, or `checkpoint`.
- Checkpoint writebacks run as step 0 **inside** `/prep <slug> checkpoint` via
  `tools/mep/bin/mep checkpoint <slug> --json`; `--fix` is allowed only when there are no blockers
  and no `commit_required_before_checkpoint` finding — not as a standalone operator step before the
  prep session.
- The glossary remains the human-readable resolver reference until generated/reference cutover is
  completed.

The lifecycle is finish → `/prep checkpoint` → advance. Manual uses human implementation and human/manual
ratification provenance. Default allows the agent to implement/propose while human approval boundaries
remain human-owned. Autopilot swaps a proxy into the finish author/ratifier seat and requires
proxy/autopilot provenance; the parent agent must not self-ratify its own autopilot finish.
Only broker-reported `human` gates should ask the operator mid-slice. `commit` gates require explicit
operator approval before any commit, push, PR creation, or merge.

This directory records the adapter contract. The live Cursor command still lives at
`.cursor/commands/mep.md` until a later generated-mirror or adapter cutover makes this directory the
only home for Cursor-specific instructions.
