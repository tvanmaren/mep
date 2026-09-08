# Iteration 9 — Install path & stranger smoke test

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/09-install-stranger-smoke-test.md`  
**Status:** brief_ready  
**Slice type:** behavioral  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential

## Epistemic transition

**What became more certain:** a stranger can start from **root README** in ≤5 copy-pasteable steps — clone, invoke `mep`, pick one executor preset (stub in CI), run `where` → `exec dispatch`. not vision-doc archaeology.

**Irreversible decision (one):** README is the stranger entry; command presets stay **fail-closed**. `grok` stays a named TUI contract. no live vendor driver lands (C9).

**Maturity target:** `provisional → stable`

## Category vs instance

**Category certainty (close this slice):** one install contract: documented PATH-or-repo-bin invocation + stub smoke. `run-stranger.sh` already proves engine defaults without `.mep/config`. this slice does **not** invent a second CI harness.

**Instance certainty (this slice only):** README (and any getting-started twin that already specifies *how* to start) lists the steps; CI still runs existing stranger + litmus. a command-preset sentence names cursor **or** grok as “your binary; in-tree driver is stub.”

**Acceptance order:** truthful README before packaging (15), before CONTRIBUTING taste (12), before live drivers.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `README.md`; `tools/mep/docs/README.md` **only** if it already specifies getting-started (it does — Cursor `/mep` surface); `.cursor/skills/mise-en-place/README.md` twin if that copy is the Cursor start path; `tools/mep/test/run-stranger.sh` only if the documented invoke path would fail today’s suite; FOSS proof that the guide still mentions stub + at least one named command preset including `grok` |
| **May know** | C6, C9, C10, I9, I10; `executors.presets`; `run-stranger.sh`; slice-boundary litmus (already shipped) |
| **Must not know** | live vendor SDKs; `mep mark` expansion; resolver rows; CONTRIBUTING dump (12); v0.1.0 tag / Sator Square (15); I5 host pointer |
| **Invariants** | C7, C8, C9, C10; stranger CI still no host overlay; stub remains the in-tree driver; `grok` preset not dropped |
| **Still provisional** | dual skill/docs copies except twins this slice must keep in sync; how a host consumes the repo (I5) |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| stranger suite / install-guide proof | `@provisional` | keep or add if a new helper lands |
| `mep mark` writer | `@provisional` | keep — 8 |

## Stabilizes

Milestone C start. 10+ may assume a stranger can find stub dispatch without reading graduation prep. 15 still owns packaging/tag.

## Macro constraints (read-only)

- C6: standalone repo is already the home
- C9: no live driver; do not `eval` preset `command`
- C10: do not weaken or reimplement litmus inside README
- I9: `grok` stays on the audit table

## Acceptance criteria (this iteration ONLY)

- [ ] root README **Start here** is ≤5 numbered/copy-pasteable steps a stranger can run without opening `.mep/plans/*`; includes invoke of `tools/mep/bin/mep` (or an equivalent PATH recipe this slice documents)
- [ ] README no longer claims slice-boundary litmus / unix foundation is unshipped
- [ ] README (or the owned getting-started twin) documents: default/CI path `--executor stub`; one command preset (`cursor` **or** `grok`) as fail-closed / no in-tree driver; no API keys in MEP config
- [ ] `bash tools/mep/test/run-stranger.sh` still green; stranger.yml still runs it + golden + litmus; **no** litmus product growth
- [ ] `mep config dump --json` still lists `grok` as `{kind:command,command:grok}`; unix-contract preset assertions still green
- [ ] no vendor SDK under `tools/mep/lib`; no I5 host submodule; no v0.1.0 tag

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| keep `run-stranger.sh` engine-defaults assertions | `mechanical` | existing stranger suite |
| keep grok in executor dump | `mechanical` | I9 / unix-contract preset lock |
| README start-here shape (≤5 steps vs table of vision docs) | `finish` | operator-facing entry |
| PATH install vs repo-relative `tools/mep/bin/mep` | `finish` | v0.1 may document repo-bin only; packaging is 15 |

**Frame — install recipe:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| stranger start | ≤5 steps from README; stub smoke remains CI; grok named fail-closed | root README “Two ways in”; `run-stranger.sh` | recommend: document repo-bin invoke (no package) + stub loop; vision docs demoted below Start here | `open` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `README.md` | modify | integration | stranger entry; kill stale litmus sentence |
| `tools/mep/docs/README.md` | modify | integration | getting-started already specified — keep foss vs cursor honest |
| `.cursor/skills/mise-en-place/README.md` | modify | integration | twin if docs README is a copy |
| `tools/mep/test/run-stranger.sh` | modify | integration | only if documented invoke would fail |
| `tools/mep/test/run-unix-contract.sh` | modify | integration | only if a README/preset assertion must live here |
| `.github/workflows/stranger.yml` | modify | integration | **only** if a new required CI step is the category — default: leave |

**Conflicts:** sequential — README twins.

**Explicitly not this slice:** `resolver.sh`; `mark.sh`; litmus internals; SKILL.md; CONTRIBUTING; LICENSE/tag; host overlay.

## RED-phase gates (before GREEN)

- [ ] root README Start here is a vision-doc table, not ≤5 runnable steps
- [ ] README still says slice-boundary litmus is not shipped

## Approach

1. Prove RED: README Start here + stale litmus claim.
2. Rewrite Start here ≤5 steps; demote vision links; document stub loop; name one command preset fail-closed (`grok` must remain somewhere in that contract).
3. Align `tools/mep/docs/README.md` (and skill twin if it is a copy) so Cursor `/mep` start does not contradict the foss CLI recipe.
4. Keep stranger + litmus + unix-contract green. do not add a second harness unless README’s claimed command would fail today’s `run-stranger.sh`.
5. Do not ship a driver. do not drop grok.

## Avoid (out of scope this iteration)

- live cursor/grok/claude/codex driver (C9)
- dropping the `grok` preset
- expanding `scripts/litmus/` product
- v0.1.0 tag, Sator Square, package managers (15)
- CONTRIBUTING examples dump (12)
- I5 host pointer / submodule
- `mep mark` / watcher / SKILL.md
- retitling a README copy-edit as “stranger can complete a full initiative in three modes” (01 success #3 is still 10–14)

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — stranger install contract (README + keep stub/grok)
- [x] **Ownership minimal** — README twins + stranger only if invoke breaks
- [x] **Category before instance** — documented start before packaging / live driver
- [x] **One place to edit** — root README is the stranger entry; twins stay copies
- [x] **No planned shotgun surgery** — Avoid lists 12/15/C9/litmus/`mark`
- [x] **Consolidation routing** — 8 was the writer; this is Milestone C entry, not leftover 8

**Preflight note:** pass — `run-stranger.sh` already exists; do not rebuild it. one finish: README recipe (recommend repo-bin + stub; grok named).

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| behavioral | stranger can follow README to stub dispatch | ship a vendor driver; claim full three-mode product path |

## Testing

- **FOSS:** `tools/mep/test/run-stranger.sh`; `run-unix-contract.sh` (grok preset); `scripts/litmus/slice-boundary.sh --executor stub`; `run-golden-matrix.sh`
- **Manual:** clone-shaped read of README Start here; `mep help` lists mark + dispatch; no keys required for stub

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category = operator install contract. fail if the slice only restyles vision links or claims a live grok driver.

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code scope
- [ ] `git commit` → optional `/prep-pr-description mep-v0-graduation 9`
- [ ] `/prep mep-v0-graduation checkpoint` → iter 10 brief
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Add `@` tags per epistemic markers.
> Do not read future iterations.
