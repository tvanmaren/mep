# MEP — one-pager

**Mise-en-place for uncertain software work:** a portable workflow runtime that answers three questions on every step — what's next, who's responsible, and what evidence justifies moving on.

---

## The problem

Big features die from over-planning, branch sprawl, or agent chaos — eager automation with no durable record of decisions, uncertainty, or gates. Teams need small reviewable PRs *and* human authority over meaning. Neither "just ship" nor "40-page design doc" scales.

---

## Three outcomes (north star)

Everything in MEP serves at least one of these. If it serves none, defer it.

| Outcome | Question |
|---------|----------|
| **Next action** | What now, and why? |
| **Responsibility** | Human, agent, or proxy? |
| **Trust** | What evidence proves the last step? |

---

## The idea

**Teleology → mechanics.** The north star is not decoration; it is the filter. MEP exists so those three questions always have a grounded answer — from persisted artifacts, not conversation memory.

Plan only the **next mergeable slice**, ship it, **checkpoint** what you learned, repeat. The human is the chef (semantics, graduation); the agent is the sous (scoped implementation, staging). Autopilot adds a cross-model **proxy** in the chef seat slice-to-slice — never self-grading, never through graduation.

```text
plan → build → land → checkpoint → … → graduate
```

Plain verbs operationalize the loop: **`start` · `next` · `where` · `mode` · `style` · `stage` · `done`**. A CLI composes state from prep artifacts + git + in-code markers and returns the literal next step. Editor-agnostic.

Recovery when the branch outran its docs: **tidy → checkpoint → forward loop**.

---

## Authorship modes

Same plan in every mode — only **delegation** changes.

| Mode | Who authors | Per-slice gate | Commit |
|------|-------------|----------------|--------|
| **manual** | Human | Human (blocking) | Human |
| **default** | Agent | Human (blocking) | Human |
| **autopilot** | Agent + cross-model proxy | Proxy ratification (non-blocking, evidence-backed) | Policy when evidence passes |

Semantic governance is **always human**. Graduation is **always human**. Autopilot retains a finish-map audit trail; proxy provenance advances slices, not final sign-off.

---

## Prep style

Orthogonal to mode: **ceremony depth**, same rail.

| Style | Meaning |
|-------|---------|
| **house** (default) | Full MEP ceremony |
| **hash** | Thin ceremony — short core/interchangeable inventory; few iterations (often one); same verbs/`where` |

`start --hash` or `/mep style … hash|house`. Promote hash→house: flip style, then **checkpoint** to thicken docs (or **tidy→checkpoint** only if the branch outran them). Hash ≠ freestyle.

---

## Architecture (three layers)

1. **Composed state (default)** — org-mode-shaped prep tree: status on each brief and roadmap node, markers in code, git as ground truth. Runtime walks and composes; `where` returns one mode-aware answer.
2. **Operational reads** — dirty planning vs product code, open decisions, active mode + style. Cheap, no archaeology.
3. **Forensic inference (on demand)** — `infer` reconstructs + evidences; `doctor` compares and repairs. Not the default routing path.

**Policy bundles** decouple *what* from *who*: Policy → Runtime → Execution request → Executor → Evidence → History. Manual, default, and autopilot are authorization/evidence policies — not executor choices. Any future agent framework plugs in if it satisfies the evidence contract; the runtime stays open for extension, closed for modification.

---

## Non-negotiable gates

- Evidence before trust — non-blocking ≠ no proof  
- No self-ratification in autopilot  
- No planning leakage into shipped code  
- Drift flagged explicitly, not ignored  

---

## Success

One concrete next step from `where`, surviving context resets. Messy branches seed from structured inference, not ad-hoc archaeology. Routing rules stable; inference evolves separately. Operators drive efforts with the plain verbs (including `mode` and `style`) and trust the gates.

---

**MEP** = plan the next plate, cook it, plate it, learn, prep the next plate — with accountability built in.
