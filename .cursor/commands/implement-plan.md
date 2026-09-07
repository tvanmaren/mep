---
description: "implement one approved mep slice brief — portable, host-TDD-free"
alwaysApply: false
---

# implement-plan — one slice brief

`/implement-plan <briefPath>` is the Cursor handle for **building the current approved slice**.
It is **not** a product-stack TDD ritual. Hosts may overlay a stricter implement command; this file
is the engine default.

**Follow the implement-plan contract in**
[`.cursor/skills/mise-en-place/SKILL.md`](../skills/mise-en-place/SKILL.md)
**(section "implement-plan contract")** and the portable procedure in
[portable-routing.md](../skills/mise-en-place/portable-routing.md).

## Invocation

`/implement-plan <briefPath>` — `<briefPath>` required. Typical source: `mep where <slug> --json`
→ `nextCommand`.

If the user omitted the path, run `mep where <slug> --json` only when the slug is already in
context; otherwise ask for the brief path. Do not invent a brief.

## Binding constraints

1. Implement **only** that brief. File ownership in the brief is exhaustive.
2. Treat `03-core-vs-volatile.md` (and the rest of the initiative prep tree) as **constraints**,
   not extra scope. Do not read **future** iteration briefs unless this brief explicitly allows it.
3. Constitution, slice-type rules, RED-phase gates, and Avoid in the brief are binding.
4. Add `@` tags only where the brief's epistemic markers say to.
5. Do **not** run a host-specific implement overlay (smoke-test scripts, product TDD rulepacks,
   `wiki/plans/` master-plan execution) unless *this repo's* `.mep/config` / profile names one.
6. Do **not** `git commit`. After the slice is built, routing's next command is `/commit-prep`.
7. Tests: run **what the brief's Testing section names**. If it names nothing, run the repo's
   existing check for the owned paths — do not invent a stack.

## Procedure

1. Read the brief in full. If status is not `brief_ready` / implement-ready, stop and say so.
2. Read only the constraint docs the brief points at (usually `01`, `03`, current roadmap row).
3. Execute the brief's Approach / RED → GREEN against owned paths.
4. Fill in-brief checkboxes only when the evidence exists; do not tick from hope.
5. Stop when acceptance criteria for **this iteration only** are met, or when a named human
   finish / constitution collision requires a question.

## Relationship

| this is | this is not |
|---------|-------------|
| one slice, one brief | `/execute-plan` (parallel fanout) |
| implement | `/prep` (planning) or `/commit-prep` (stage/audit) |
| portable default | a host's vertical-slice TDD command |
