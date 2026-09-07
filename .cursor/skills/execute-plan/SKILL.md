---
name: execute-plan
description: >-
  Execute a mep slice brief via bounded agent fanout when fanout is parallel
  and file ownership is disjoint. Each agent implements one ownership slice
  under the portable implement-plan contract. Use when the user says
  "execute plan" or the brief sets fanout: parallel.
---

# Execute Plan — slice fanout

Orchestrate **one approved mep brief** by dispatching independent ownership slices to isolated
sub-agents. This is **not** a host TDD overlay and **not** `wiki/plans/` master-plan execution.

If the brief says `fanout: sequential` or ownership conflicts, do **not** fan out — run
`/implement-plan <briefPath>` instead.

## Binding constraints

1. The brief's file-ownership table is exhaustive. A file in two slices is a **hard conflict** → serialize or stop.
2. Each agent implements **only** its slice of that table, under the
   [implement-plan contract](../mise-en-place/SKILL.md).
3. Tests: whatever the brief's Testing section names. Do not invent a host smoke-test ritual.
4. Do **not** `git commit`. Foundation stays uncommitted; `/commit-prep` is the later route.
5. Do **not** read future iteration briefs.

## Process

### 1. Ingest

Read the brief. Extract acceptance criteria, ownership table + zones, RED gates, testing.

### 2. DAG

Assign every owned path to exactly one agent slice. Detect file conflicts, data dependencies,
test-fixture prerequisites. Schedule: serial chains vs parallel batches.

Present the schedule (ownership matrix, edges or "none", batches) and **wait for approval**
before dispatch.

### 3. Dispatch

Launch independent slices in one turn via `Task` / `best-of-n-runner` when available; otherwise
run slices sequentially in-process under the same contract.

Each agent: RED → GREEN → refactor against
`.cursor/skills/mise-en-place/review-kernels/` (and the active profile's review inputs if any).
Exit when that slice's acceptance criteria and tests pass.

### 4. Integrate

Merge worktrees or in-process results. Re-run the brief's tests. Constitution / Avoid collisions
→ stop and ask; do not "complete" by dropping a criterion.

## Relationship

| this is | this is not |
|---------|-------------|
| parallel `/implement-plan` | host smoke-test TDD command |
| one mep brief | a `wiki/plans/` product plan |
| orchestrator | `/commit-prep` |
