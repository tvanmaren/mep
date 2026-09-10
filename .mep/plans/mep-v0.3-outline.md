# MEP v0.3 — outline

**Status:** active outline — A1 implemented by mep-v0-graduation iteration 16; persistence module by
iteration 17; **v0.2.0** is the document-native cutover. remainder needs a **new** v0.3 initiative.
**Canonical vision:** [mep-vision-proposal.md](./mep-vision-proposal.md) · [mep-vision-one-pager.md](./mep-vision-one-pager.md)  
**Predecessor program:** epic #85 · `.mep/prep/mep-v0-graduation/`

v0.1 shipped a **credible FOSS product** (unix substrate, executor plugs, workflow closure, transitional routing). **v0.2.0** shipped composed explicit state as the default routing input. v0.3 closes the **remaining architecture gap**: forensic inference as an opt-in layer, and a single mode-aware answer from `where`.

**Staffing rule:** keep this outline; open a v0.3 epic and shortcut stories only after v0.2.0 is **tagged** (see gates below). Slice titles and order may change once v0.2 contracts land.

---

## Why v0.3 exists

v0.1 intentionally left routing on a **transitional model** (central index + git heuristics in `resolver.sh`). v0.2.0 retired the sidecar as authority. what remains is recurring resolver churn on **git reconstruction** and split-brain between `where` and `lifecycle status`.

v0.3 is not feature sprawl. It is the **structural fix** the vision proposal still describes after A1:

```text
default path:  where → composed prep-tree state (+ operational reads)
desync path:   where → doctor → (optional infer) → human or repair
recovery:      tidy → infer seed → checkpoint
```

---

## Entry gates (before v0.3 epic is staffed)

All required (v0.1 substrate + v0.2.0 document state):

| Gate | milestone | Why v0.3 waits |
|------|-----------|----------------|
| Unix litmus green | v0.1 iter 4 | infer/doctor must speak the same JSON + exit contract |
| `executionRequest` on `where --json` | v0.1 iter 2 | evidence-gated autopilot commit needs the packet |
| Golden matrix (transitional, then document inputs) | v0.1 iter 5 + v0.2.0 A1 | v0.3 **replaces** remaining hot-path git heuristics; needs a baseline to regress against |
| At least one mode workflow closed | v0.1 iter 6 **or** 7 | unified router must route real manual/autopilot steps |
| v0.1.0 tagged | v0.1 iter 14 | semver + standalone repo home |
| v0.2.0 tagged | post-v0.1 iters 16–17 | document-native state is the default reader |

Recommended before **v0.2.0** (document state) shipped — already true:

| Gate | v0.1 milestone |
|------|----------------|
| Frontmatter authoring contract | iter 0 |
| Runtime ≠ policy boundary tested | iter 10 |

---

## Guardrail on v0.1 (historical)

**Iteration 5 (resolver totality)** locked routing for the **v0.1 transitional model** only.

While building iter 5:

- Close **known misroutes** and document evaluation order in the glossary.
- Do **not** add net-new inline git fallbacks beyond fixing proven bugs.
- Treat golden fixtures as **oracle for v0.1**, not as the permanent architecture.

v0.3 **demotes** git reconstruction from the default `where` path and moves it to `infer`. Iter 5 must not make that migration harder.

---

## Release shape

| Tag | Theme |
|-----|--------|
| **v0.1.0** | FOSS extract, unix foundation, workflow CLI, transitional resolver, manifest OK |
| **v0.2.0** | Document-colocated workflow state; runtime **composes** from prep-tree nodes (A1) |
| **v0.3.x** | `infer`, doctor expansion, desync routing, unified mode-aware `where`, tidy seeding, classification feedback, generic live driver |
| **v0.4.0** | Auto mode assignment — MEP classifies work into manual / default / autopilot (see below) |

Post-v0.1 iteration 16 (*document-native state authority & legacy migration*) is the **v0.2.0**
headline and implements A1. It does not complete v0.3: infer, desync routing, unified mode-aware
`where`, tidy seeding, and the generic live driver remain B–D work. **v0.4** opens only after the
v0.3 program success criteria pass.

---

## Candidate slices (titles only — order TBD)

### Milestone A — composed state reader (v0.2.0)

**A1. Document-colocated state — implemented by iteration 16; tagged v0.2.0**
Retire central index as routing authority. Checkpoint writes brief/roadmap frontmatter; runtime walks prep tree + git + markers. Same routing *semantics* as v0.1 golden matrix, new *inputs*.  
*Likely inherits v0.1 iter 15 scope.*

**A2. Explicit slice phase transitions**
Phase ladder on nodes: not planned → plan ready → code landed → planning synced → committed → merged. Trusted writers only (checkpoint, ratification, doctor `--fix` for git-proven fixes).
*Not staffed on mep-v0-graduation. Open a v0.3 epic.*

### Milestone B — forensic layer (v0.3.1)

**B1. `mep infer`**  
Read-only reconstruction + evidence packet. Scenarios: post-brief build proof, roadmap/brief agreement, checkpoint staleness, merged truth.

**B2. Doctor ← infer**  
Orchestrate infer → compare(composed view, branch) → findings. Expand beyond committed→merged. `--fix` applies only low-ambiguity, git-proven writebacks.

**B3. Desync routing**  
When composed state is inconsistent, `where` routes to doctor first — no inline `git log` guessing.

**B0. Classification feedback ledger** *(v0.3.x, observability only)*  
Log finish-map / gate decisions with human verdict (`correct` | `should_have_been_X`). History surface only — does **not** write `authorshipMode`. Seeds the v0.4 classifier; pilot metric starts in v0.1 iter 13.

### Milestone C — total router (v0.3.2)

**C1. `where` ⊕ lifecycle merge**  
Single next step includes mode-specific work: human authorship/ratification (manual), blocking gates (default), proxy dispatch + evidence (autopilot). Eliminate parallel lifecycle report the operator must stitch.

**C2. Tidy ← infer**  
Recovery skill/tooling seeds from `mep infer --json` instead of ad-hoc agent archaeology.

### Milestone D — delegation depth (v0.3.x, policy-dependent)

**D0. One generic live driver**
`exec dispatch` gains a single `kind: command` arm: exec the preset's argv with the `executionRequest` on stdin. No vendor SDK, no shell `eval` (C9). `cursor` / `claude-code` / `codex` / `grok` stay **config examples**, not four maintained drivers.

This is the only slice that makes **autopilot** real — manual and default are already served by an agent harness driving the CLI from outside (`portable-routing.md`), which is how every closed slice in v0.1 was built. Sequenced **after A1** so the evidence loop reads document-native state once.

**Skin emit order (operator 2026-09-09):** generated adapters over PATH `mep`, not second resolvers. **grok TUI first**, then Cursor marketplace, then Claude. VS Code is a Cursor-adjacent emit, not a fourth architecture. Marketplace packages declare a CLI compatibility range and fail closed if `mep` is missing.

**D1. Evidence-gated autopilot commit**  
Policy validates evidence packet; runtime emits execution request; executor performs commit. Requires frozen request/evidence schema from v0.1 and **D0**.

**D2. Autopilot graduation re-ratification**  
Risk-tiered human re-review of semantic/foundational proxy finishes; spot-audit remainder; finish-map retained at graduation.

---

## Dependency sketch

```text
v0.1 tag + litmus + executionRequest + golden matrix (transitional)
  → A1 document-colocated state (v0.2.0)
  → A2 explicit phases
  → B1 infer
  → B2 doctor ← infer
  → B3 desync routing row
  → C1 where ⊕ lifecycle
  → C2 tidy ← infer
  → D0 generic command driver (after A1; unblocks autopilot)
  → D1 autopilot evidence commit (after D0; parallel ok after B2 + v0.1 iter 2 frozen)
  → D2 graduation re-ratification
  → B0 classification feedback (parallel ok after iter 13 pilot; no mode writes)
  → v0.4 program (E1 → E2 → E3) after v0.3 success criteria
```

B milestones can start fixture work **in parallel** with late A1 once prep-tree walk API is sketched — but **C1 must not ship** until B3 proves desync does not fall through to guess routing. **E milestones do not start** until v0.3 is done.

---

## Explicit non-goals for v0.3

- Full runtime rewrite / substrate migration (see `mep-runtime-productization` — separate program)
- Analytics, dashboards, or query language over the event log
- Slug inference from free text
- Ungoverned autonomous commit/push/merge
- Rich epistemic tag taxonomy beyond slice-brief needs
- Replacing Cursor adapter with a new executor framework
- **Per-vendor drivers.** One generic `command` arm (D0), not four vendor integrations tracking four flag surfaces.
- **Auto mode assignment** — runtime or CLI selecting manual / default / autopilot from classification (v0.4; see below). v0.3 routes for the **operator-chosen** mode only.
- **Prep style runtime (`hash` | `house`)** — vision principle in [mep-vision-proposal.md](./mep-vision-proposal.md) (ceremony depth orthogonal to authorship mode; same rail). Do **not** staff `style` / `--hash` as v0.3 slices; keep A–D focused on composed state / infer / unified `where`.

---

## v0.4 — outline stub (not staffed)

**Status:** deferred until v0.3 success criteria pass. Staff a v0.4 epic after v0.3.0+ is shippable.

v0.4 closes the **policy classifier** gap: today the operator sets `authorshipMode`; finish-map classifies mechanical vs decision-bearing at slice planning (executor/LLM). v0.4 adds MEP **assigning or recommending** delegation policy from "does this need human judgment?" — a new operator contract, semver **0.4.0** minimum if it writes mode without explicit `/mep mode`.

**Not the same as:**

| layer | v0.1–v0.3 | v0.4 |
|-------|-----------|------|
| finish-map (mechanical / finish) | slice brief + markers | input to mode classifier |
| authorship mode | operator via `/mep mode` | MEP suggests or assigns (opt-in → default) |
| unified `where` (C1) | steps for **active** mode | surfaces mode recommendation + reason |

### Milestone E — mode classifier (v0.4.0)

**E1. Mode recommendation (read-only)**  
`where` / lifecycle report includes suggested mode + plain-language reason ("human judgment needed because …"). No write to `authorshipMode`; operator confirms via existing `/mep mode`.

**E2. Per-slice mode override**  
Classifier may set `iterations[N].authorshipMode` when policy allows; initiative default unchanged. Requires B0 verdict dataset showing acceptable accuracy.

**E3. Auto-assignment (opt-in config)**  
`.mep/config` flag to apply E1/E2 without manual confirm. Graduation and semantic/foundational finishes remain human gates regardless.

**Prerequisites (v0.3):** C1 unified router · enforced finish-map (v0.1 iter 8) · B0 classification feedback · at least one closed manual/default/autopilot workflow.

**Explicit non-goals for v0.4 (initial):** ownership lifecycle promotion (manual→autopilot over time without human ratification); deterministic non-LLM classifier as sole authority; fourth authorship mode.

---

## Success criteria (v0.3 program done)

- `where` on a healthy branch reads **composed state only** — no git-archaeology predicates on the hot path.
- Desync → doctor finding, not wrong next step.
- Manual and autopilot steps appear in **one** routed answer, not a second lifecycle channel.
- Tidy recovery can bootstrap from `infer` output.
- Golden matrix from v0.1 still passes under the new input layer (semantic parity).
- Resolver row table changes rarely; infer heuristics can evolve independently.

---

## Open decisions (resolve at v0.2.0 tag)

1. **v0.3 epic** — extend epic #85 post-v0.1 section vs new epic #N?
2. **Manifest retirement — resolved:** document state is authoritative; manifests are import-only
   for one compatibility release and convert explicitly via `mep migrate`.
3. **Infer API stability** — semver-minor for heuristic improvements inside v0.3.x?
4. **Productization rewrite** — does v0.3 land in bash reference runtime only, or block on substrate choice?

---

## Links

| Artifact | Role |
|----------|------|
| [mep-curate-outline.md](./mep-curate-outline.md) | v0.1 integration curation (`/mep curate`) |
| [mep-vision-proposal.md](./mep-vision-proposal.md) | North star / full vision |
| [mep-vision-one-pager.md](./mep-vision-one-pager.md) | Exec summary |
| `.mep/prep/mep-v0-graduation/04-iteration-roadmap.md` | v0.1 slice program |
| `wiki/prep/mep-runtime-productization/` | Parallel rewrite / contract freeze (not v0.3 scope) |
