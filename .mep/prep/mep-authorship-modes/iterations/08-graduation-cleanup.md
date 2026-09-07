# Iteration 8 — graduation cleanup

**Prep slug:** mep-authorship-modes
**Brief path:** `.mep/prep/mep-authorship-modes/iterations/08-graduation-cleanup.md`
**Status:** brief_ready
**Slice type:** cleanup
**Mode:** hardening
**Delivery track:** framework-internal
**Fanout:** sequential

## Epistemic transition

**What became more certain:** all three policies + the mode wiring shipped and were exercised (the
initiative dogfooded itself), so the mode-axis content is now **stable**. Nothing new is learned by
keeping it marked `@provisional`. This slice sheds the scaffolding the framework planted **on itself**
and settles the one policy question I6 deferred to graduation — after which the framework stands as
evergreen prose (no `@`-markers, no process-archaeology) and the initiative graduates.

**Irreversible decision (one):** **graduation** — strip the initiative's self-planted markers across
`ownedPaths` and flip `initiativeStatus: graduated`. One-way (reversing means re-littering the spine).
Two finishes ride inside it (below); if finish 2 proves larger than a localized clause, **split it out**
(see the gate fork) rather than widen this cleanup.

**Maturity target:** `n/a (cleanup)` — except the autopilot graduation clause (finish 2), which promotes
`provisional → stable` if it lands here.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | the in-code **marker strip** across `manifest.ownedPaths` (the live initiative markers inventoried below); `06-graduation.md` (new); `manifest.initiativeStatus` → `graduated`; **iff finish 2 lands here** — the autopilot **graduation-review-depth** clause in `execution-policies/autopilot.md` |
| **May know** | `/prep-cleanup`'s strip table + procedure (`.cursor/commands/prep-cleanup.md`); the graduation section of `maturity-tags.md`; the archaeology detector's evergreen-spine scope (`hooks/scaffolding-free-check.sh`, `hooks/deny-archaeology-commit.sh`); I6's deferred review-depth fork + its retained `finish-map`/proxy-provenance guarantee; `manual.md`'s human-only ratify bar + `commit-prep`'s cross-model-then-human gate (precedents for the depth finish) |
| **Must not know** | the *internals* of any shipped decision (I3 substrate, I4 directive, I5 manual lifecycle, I6 dispatch contract, I7 wiring) — graduation **strips markers, it does not re-litigate**; no new mode behavior |
| **Invariants** | cleanup changes **no behavior/semantics** — it sheds process artifacts only (the lone exception is finish 2, which *completes* an I6-declared hole, not a new feature); the framework's documented tag/marker **vocabulary survives** (strip the live markers, spare the docs that define them); **graduation stays a human gate** (I4 L93); the scaffolding-free convention holds — every graduated node reads as if always-evergreen, lineage lives only in `deviations[]` + git |
| **Still provisional** | finish 1 — the **strip-predicate** (how to remove only the live markers without touching the vocabulary documentation) · finish 2 — the autopilot **proxy-map review depth** (+ whether it splits into its own slice) |

## Epistemic markers (`@` tags)

Cleanup slice: **remove all** initiative markers in `ownedPaths`. Inventory of the **live** markers to
strip (each is an HTML-comment marker on the framework's own evergreen prose; the surrounding content
**stays** — only the marker line goes):

| location | tag | action |
|----------|-----|--------|
| `SKILL.md:73` | `@foundational` (operating-model bedrock) | remove tag; keep the operating-model prose (per `/prep-cleanup` rule: `@foundational` → drop tag, keep invariant in plain prose) |
| `SKILL.md` (mode-wiring block) | `@provisional` (mode wiring · I7) | remove; keep the `authorshipMode` table |
| `glossary.md` (row-8 block) | `@provisional` (open-finish row · I7) | remove; keep resolver row 8 |
| `execution-policies/autopilot.md` | `@provisional` (auto-approve path · I6) | remove; keep the policy |
| `execution-policies/manual.md` | `@provisional` (lifecycle UX · I5) | remove; keep the policy |
| `maturity-tags.md` (`@finish:` grammar note) | `@provisional` (state-tag grammar · I5) | remove; keep the grammar |
| `templates/slice-brief.md` (Finish-map block) | `@provisional` (substrate schema · I3) | remove; keep the Finish-map section |

**Spare (these are the vocabulary *documentation*, not live markers):** the tag table + examples in
`maturity-tags.md`; the strip table in `prep-cleanup.md`; the sanctioned-marker lists in
`code-integrity-check.md` and `commit-prep/SKILL.md`; the profile examples (`host.md`,
`example-stub.md`); the marker-table row in the `slice-brief.md` template. **This spare-list is finish 1.**

## Stabilizes

The framework itself — it stops carrying its own construction scaffolding. After this there is no next
slice; the initiative is graduated.

## Macro constraints (read-only)

From `03-core-vs-volatile.md` + `01-invariant-goal.md`:

- semantic governance is **always human** — graduation, the last gate, is therefore human-signed.
- the substrate/markers are **process artifacts**, stripped at graduation; the *documentation* of them is
  evergreen framework content and is **not** an artifact.
- scaffolding-free: a node states what it is "as if it had always been so"; lineage lives in
  `deviations[]`, never in the node.

## Acceptance criteria (this iteration ONLY)

- [ ] every **live** initiative marker in the inventory above is removed; the surrounding prose stands
  evergreen (no "was provisional", no dangling reference to the marker).
- [ ] every **spare-list** occurrence (the vocabulary documentation) is **untouched** — `rg` for the tag
  spellings over `ownedPaths` returns **only** spare-list hits, zero live markers.
- [ ] no shipped policy/directive/substrate text is reworded — the diff is marker-removal (+ `06-graduation.md`,
  + `initiativeStatus`, + finish 2's clause iff bundled), nothing else.
- [ ] `06-graduation.md` written; `manifest.initiativeStatus: graduated` set **only** after a human gate.
- [ ] **(iff finish 2 lands here)** the autopilot graduation-review-depth clause is consistent with the
  human-gate invariant (I4) + the retained-map guarantee (I6) + the human-only ratify bar (`manual.md`),
  and leaves no `@finish:open`.

## Finish-map (fragment classification)

Cleanup slice — most fragments are `mechanical` (marker removal cites `/prep-cleanup`'s strip table).
Two `finish`es: the strip-predicate and the deferred review-depth policy.

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| remove each inventoried marker line, keep surrounding prose | `mechanical` | `/prep-cleanup` strip table (`@experimental/@provisional` → remove line; `@foundational` → drop tag, keep prose) |
| write `06-graduation.md` | `mechanical` | the graduation-doc convention (`SKILL.md` graduation pass; prior initiatives' `06-graduation.md`) |
| set `initiativeStatus: graduated` | `mechanical` | manifest field precedent |
| the **strip-predicate** (live markers vs vocabulary docs) | `finish` | — |
| the autopilot **proxy-map review depth** (deferred I6) | `finish` | — |

**Frames — the two finishes (`open`):**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| **strip-predicate** | removes exactly the live initiative markers (the inventory) and **nothing** in the vocabulary documentation (the spare-list); result is `rg` over `ownedPaths` finding only documentation hits | (1) `/prep-cleanup` strip table + its **`.js`/`.vue`-scoped** ripgrep — the mechanism, but here the target is `.md` framework docs, so the file-type scope no longer separates live from documented; (2) `scaffolding-free-check.sh` / `deny-archaeology-commit.sh` already distinguish the evergreen spine from legitimate vocabulary | provenance-tag predicate (strip comments carrying `(mep-authorship-modes I…)` + the lone operating-model `@foundational`) · *or* the hand-curated inventory above · *or* extend `/prep-cleanup` with an `.md`-aware rule that excludes the vocabulary files? | `open` |
| **proxy-map review depth** (deferred I6) | specifies how a human discharges the **final** graduation sign-off over a proxy-authored, proxy-ratified `finish-map`; bounded by: graduation stays human (I4), the map + proxy-provenance are retained (I6), and `ratified` is never inferred (`manual.md`) | (1) `manual.md` ratify step — human-only, never inferred (the depth bar for a *human*-authored finish); (2) `commit-prep` cross-model second-opinion **+** human commit gate (a sign-off that *samples* rather than re-derives); (3) the doctor's git-proven promotion (trust-but-verify against ground truth) | re-ratify **every** proxy finish (full human re-walk — safe, costly, erases autopilot's gate-speedup) · *or* spot-audit a **sample** + trust the map (cheap, residual risk) · *or* **risk-tiered** (re-ratify finishes touching foundational/semantic zones, spot-audit the rest)? | `open` |

**In-code markers:** this slice **removes**, adds none. Per I3 the substrate markers (`@mise`/`@finish`)
and the maturity tags are process artifacts; graduation is where they shed.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `.cursor/skills/mise-en-place/SKILL.md` | modify | facade | strip 2 markers (operating-model `@foundational`; mode-wiring `@provisional`) |
| `.cursor/skills/mise-en-place/glossary.md` | modify | facade | strip the row-8 `@provisional` |
| `.cursor/skills/mise-en-place/execution-policies/autopilot.md` | modify | facade | strip `@provisional`; **iff bundled** add the review-depth clause |
| `.cursor/skills/mise-en-place/execution-policies/manual.md` | modify | facade | strip `@provisional` |
| `.cursor/skills/mise-en-place/maturity-tags.md` | modify | facade | strip the `@finish:`-grammar `@provisional` |
| `.cursor/skills/mise-en-place/templates/slice-brief.md` | modify | facade | strip the Finish-map `@provisional` |
| `.mep/prep/mep-authorship-modes/06-graduation.md` | new | — | graduation note (docs scope) |
| `.mep/prep/mep-authorship-modes/manifest.json` | modify | — | `initiativeStatus: graduated` (docs scope) |

**Conflicts:** none, but **sequential** (terminal slice; touches the same spine nodes the whole series built).

## RED-phase gates (before GREEN)

- [ ] **strip-completeness + vocabulary-preservation:** after cleanup, `rg '@experimental|@provisional|@stable|@foundational|@reference-only|PROVISIONAL:'`
  over `ownedPaths` returns **only** the spare-list (vocabulary docs) — zero live initiative markers, and
  zero spare-list entries removed. RED if a live marker survives **or** a documentation hit was stripped.
- [ ] **no-semantics-change:** the diff outside `06-graduation.md`/`initiativeStatus`/(finish 2's clause)
  is **marker-line removal only**. RED if any policy/directive/substrate sentence is reworded.
- [ ] **resolver intact:** removing `glossary.md`'s row-8 `@provisional` leaves the resolver table total +
  first-match-wins unchanged (the marker was a comment, not a row). RED if the table shifts.
- [ ] **scaffolding-free + archaeology:** graduated nodes carry no edit-narration or initiative references;
  `deny-archaeology-commit.sh` passes on the evergreen spine. RED on any "was/changed-from" residue.
- [ ] **human graduation gate:** `initiativeStatus: graduated` flips only after an explicit human confirm.

## Approach

- **resolve the two finishes with the operator first** (strip-predicate → review-depth), since the
  review-depth answer decides whether this slice stays whole or splits (the gate fork).
- run the **strip** via `/prep-cleanup` semantics (the one command licensed to edit code/strip tags) — by
  the resolved predicate, removing only the inventoried live markers, keeping surrounding prose.
- write `06-graduation.md`; set `initiativeStatus: graduated` behind the human gate.
- keep the lineage in `deviations[]`; add **none** to the graduated nodes.

## Avoid (out of scope this iteration)

- re-opening or rewording any shipped decision (I3–I7) — strip, don't re-litigate.
- stripping the framework's **documentation** of the tag/marker vocabulary (the spare-list).
- any behavior change beyond completing finish 2's declared hole.
- a generic `.md`-wide tag sweep (it would gut the vocabulary docs — the whole point of finish 1).

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| cleanup | zero **live** `@` markers in `ownedPaths` (spare the vocabulary docs); graduation doc written; human gate | change behavior (beyond finish 2's declared clause), reword shipped policy, or strip the documented vocabulary |

## Testing

- **Unit/spec:** n/a (protocol/docs).
- **Manual:** the strip-completeness grep (only spare-list hits remain); a read-through that each graduated
  node stands evergreen; `scaffolding-free-check.sh --broad` over `ownedPaths`; confirm resolver row 8 still
  resolves after its marker is gone.

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:

## Checkpoint

Zero live `@` markers in `ownedPaths` (vocabulary docs intact); `06-graduation.md` written;
`initiativeStatus: graduated`; the resolver + every policy/directive read exactly as before, minus their
scaffolding; the autopilot graduation-review depth is specified (here or in its split-out slice). No next
iteration — the initiative is done.

## After commit

- [ ] `/prep-cleanup mep-authorship-modes` (or `/implement-plan` on this brief) — **code** scope (the
  `ownedPaths` strip) **+** `docs-delta` (`06-graduation.md` + `initiativeStatus`)
- [ ] `git commit` → `/prep-pr-description mep-authorship-modes 08` (or `/pr-description` for the graduation PR)
- [ ] terminal — no further checkpoint; `initiativeStatus: graduated`

## implement-plan instruction

> Implement **only** this file's ownership, via `/prep-cleanup` semantics (this is the one slice licensed
> to edit code / strip tags). Constitution + slice-type rules are binding. Resolve the two finishes with the
> operator in order (strip-predicate → review-depth); if review-depth is chosen to split out, do the amend
> ritual (deviation + renumber) and implement only the cleanup here. Strip **only** the inventoried live
> markers — spare the vocabulary documentation. Do **not** re-litigate any shipped decision (I3–I7). Keep
> lineage in `deviations[]`. Flip `initiativeStatus: graduated` only behind a human gate. Do not read future
> iterations (there are none).
