# Authorship modes for the mise-en-place framework

**Architecture doc:** the prep tree — [`.mep/prep/mep-authorship-modes/`](../prep/mep-authorship-modes/) (`01-invariant-goal`, `03-core-vs-volatile` + the ADs folded in `04-iteration-roadmap`). No separate `wiki/architecture/` doc; this is a framework-internal initiative whose decisions live in prep.

**Consolidation point:** drafted after I5 (manual) landed and the shape stabilized — substrate (I3) is a shut one-way door, the directive (I4) is foundational, manual (I5) runs end-to-end. One assessable document of the design before the back-half slices (autopilot, mode-switch wiring, cleanup).

## Problem & goal

The framework runs one implicit operating model — "implement owns code; humans audit" — and treats it as the whole truth. It is one corner of a larger space. **Goal:** make authorship a deliberate, coherent **mode-axis** — `manual | default | autopilot` — over **one shared analysis substrate**, such that every mode preserves the framework's invariants and the modes' distinctions never silently leak into one another.

Two faces, built together: the **ownership face** (zero-authorship hollows out the audit competence the framework leans on) and the **autonomy face** (full delegation must not recreate the undifferentiated "melt blob" — it needs a shared artifact that concentrates review).

## The design (consolidated)

**Mode-space model — the governance×authorship grid (AD1, AD3).** *Semantic* governance (who owns meaning/ontology/invariants) is the always-human invariant sitting *above* the grid. The grid's two axes are **who authors** the decision-bearing code × **who holds approval governance** at the merge gate:

|  | human authors | AI authors |
|---|---|---|
| **human approves** (blocking) | **manual** | **default** (today's model, now named) |
| **AI approves** (non-blocking) | **code-monkey — deliberately empty** | **autopilot** (up to graduation; human-gated cleanup) |

Switching mode changes **who acts**, never **what gets planned**.

**Shared substrate — the finish-map (AD3, I3).** The mode-invariant analysis artifact every policy consumes: each fragment is classified `mechanical` (AI-absorbable) or `finish` (decision-bearing), and each `finish` carries a **frame** (contract · ≥2 precedents · fork-as-question). Classification follows **path-2 (AD2)** — AI absorbs a fragment only if it can ground it in a named pattern, else the fragment is a `finish` — and the classifier **fails open to `finish`** (the I1 refinement) when a citable mechanism clothes an undictated tradeoff. Two orthogonal in-code markers express it: **`@mise`** (AI-authored code; unmarked = human's, no-touch) and **`@finish:<state>`** (the decision trail, mode-invariant — the seam that lets one mode hand off to another mid-flight).

**Finish lifecycle (I5, manual).** `@finish:open → done → ratified`: the AI frames a finish + writes red contract-level acceptance tests; the human authors the decision to green them (claims the edge); the ratchet adds blackbox validation + a code-speaks-for-itself check, and the human ratifies. The **temporal test rule (AD4)** governs: no test asserts a *mechanism* before it exists (contract-level red precedes code; only mechanism-level characterization waits). Inline guidance is transient — stripped when the finish is filled, verified gone at `ratified`. Autopilot (I6) reuses this exact state-machine with a different approver.

## Acceptance criteria (initiative-level)

- [ ] Three coherent modes — `manual`, `default`, `autopilot` — plan identically off one substrate and differ only in who acts (same input → same slice/finish sets across modes).
- [ ] `default` stays behavior-compatible with today's model (named, not changed).
- [ ] In `manual`, the operator's contribution is load-bearing (a transcriptionist could not complete a finish from its guidance alone).
- [ ] AI authorship is justified, never assumed — AI absorbs a fragment only if it can cite a named pattern; else it's a `finish`.
- [ ] `autopilot` is non-blocking but not blind: it self-approves slice-to-slice *up to* graduation and **always emits the finish-map**; graduation stays a human gate. It never recreates the melt blob.
- [ ] Nothing becomes a hardened invariant without human ratification (manual).
- [ ] The resolver stays a pure function of persisted state (`manifest.json` + git); mode is selectable/switchable and the driver routes correctly.
- [ ] The scaffolding-free convention holds for every node; graduation leaves zero stray `@` markers and zero unfilled finishes in `ownedPaths`.

## Technical approach

- **Affected areas:** the mise-en-place skill (`.cursor/skills/mise-en-place/**`), the driver commands (`.cursor/commands/{mep,prep,prep-cleanup,implement-plan}.md`), and `hooks/**`.
- **Substrate:** `maturity-tags.md` (the markers, mode-invariant) + `templates/slice-brief.md` (the finish-map schema). **Fixed (I3) — do not reopen.**
- **Execution policies:** `execution-policies/manual.md` (done, I5); `execution-policies/autopilot.md` (I6); the per-mode verbs live here, never in the mode-invariant substrate.
- **Wiring:** `manifest.authorshipMode` (orthogonal to `sessionMode`) + per-finish status + the resolver "scaffolded, finishes open" row (I7), keeping the resolver a pure function of state.
- **Validation discipline:** the `scaffolding-free-check.sh` archaeology gate over evergreen nodes; the readiness grep (`@finish:open`) at slice-commit; paper dry-runs of the lifecycle.

## Vertical slices (status + forward order)

> This master plan is the **assessable overview** of the initiative, not a slice contract. The per-iteration briefs under [`iterations/`](../prep/mep-authorship-modes/iterations/) are the `/implement-plan` inputs; this document is for assessing the whole shape, not for building a single slice.

1. **I1 — classification back-test (spike).** ✅ committed — ratified AD2 (path-2) + the fail-open-to-finish refinement.
2. **I2 — anti-line-fighting boundary.** ✅ committed — the polarity-agnostic no-touch fence mechanism.
3. **I3 — shared-substrate contract (the finish-map).** ✅ committed — the schema + two-axis `@mise`/`@finish` markers (AD3). One-way door, shut.
4. **I4 — amend the prime directive (AD1).** ✅ committed — the governance×authorship space; the two senses of "govern" clarified; autopilot in its own corner.
5. **I5 — manual execution policy (the finish lifecycle + AD4).** ✅ committed — manual runs end-to-end; the lifecycle, two-moment tests, ratchet, readiness gate.
6. **I6 — autopilot execution policy.** ⏳ next — non-blocking self-approval *up to* graduation that still emits the finish-map (reuses I5's state-machine + graduation gate, different approver). Risk: the auto-approve path must preserve the audit trail; far-end, unproven.
7. **I7 — mode-switch UX + resolver rows.** ⏳ — wire `authorshipMode` into the manifest, `/mep`, and the resolver; keep it a pure function of state.
8. **I8 — graduation cleanup.** ⏳ — strip scaffolding/markers, write `06-graduation.md`, set `initiativeStatus: graduated`.

## Out of scope

- Reopening the substrate schema or marker nouns (I3 is committed, one-way).
- Changing `default`'s behavior — it is named, not modified.
- The **code-monkey corner** (AI approves / human authors) — deliberately never built; it's the inversion that wastes the human.
- Using the modes to build product features — this initiative is framework-internal; the modes ship, the demos don't.

(Autopilot's auto-approve path, the mode selector, and resolver rows are **in** scope — they are I6/I7. They are *sequenced*, not excluded; build in dependency order, never ahead of their slice.)

## Risks & dependencies

- **U1 (substrate serves 3 policies):** validated for manual + default; **autopilot (I6) is the remaining proof** that one artifact drives all three without leak.
- **U3 (frame is non-anchoring):** settles after a real anchoring trial; manual's fill ergonomics are `@provisional` until then.
- **Autopilot trust surface:** full automation through-to-graduation is trust-heavy; the finish-map audit trail is the mitigation — its preservation is the I6 make-or-break.
- **Re-plan trigger:** if I6 reveals the substrate can't carry autopilot without schema changes, the substrate reopens (low probability — I6 reuses I5's proven machine).
