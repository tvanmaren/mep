# Iteration 15 — v0.1.0 release package (incl. Sator Square)

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/15-v010-release-package.md`  
**Status:** brief_ready  
**Slice type:** cleanup  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential (16 is post-tag)  
**Shortcut:** sc-92

## Epistemic transition

**What became more certain:** v0.1.0 is a public, honest package of what already runs — not a promise that a stranger can finish real work through a live vendor driver.

**Irreversible decision (one):** the tag and the README footer tell the same truth. Sator Square is required, exact, and not optional. the scope table names what ships and what does not. `stub` remains the only in-tree executor that runs.

**Maturity target:** thesis → public v0.1.0

## Category vs instance

**Category certainty (close this slice):** a FOSS tag is a statement about the shipped surface. tagging while the README still says "v0.1.0 is still ahead", or while it implies live drivers work, is a lie.

**Instance certainty (this slice only):** `MEP_VERSION=0.1.0`; README ownership + one workflow + open roadmap + scope table + Sator footer; LICENSE and CONTRIBUTING already exist — verify, do not rewrite taste; human creates annotated tag `v0.1.0`.

**Acceptance order:** honest scope table before the tag. live drivers never land here (C9). 01 success #3 (stranger + their credentials + three modes) stays **deferred**, named in the table — not claimed.

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | `README.md` (status / scope table / Sator footer; Start here recipe stays 9's); `tools/mep/lib/registry.sh` (`MEP_VERSION`); optional `CHANGELOG.md` if one is the honest record; `.github/workflows/stranger.yml` **only** if a required proof is missing from CI (litmus + stranger + golden already run) |
| **May know** | C6–C11; LICENSE (MIT, already present); `CONTRIBUTING.md` (12 — verify exists); `01-invariant-goal.md` success/rejection; `04-iteration-roadmap.md` |
| **Must not know** | vendor SDKs / live drivers; I5 host consume; AUR/PATH packaging; 16 manifest retirement; rewriting 12 CONTRIBUTING sections; resolver/event/mode suite rewrites; `workflow.sh` |
| **Invariants** | C6, C7, C8, C9, C10; Sator Square exact block in README footer; stub is CI/fixture, not the "normal operator path" in the scope table |
| **Still provisional** | dual skill/docs copies; command-preset live drivers; 14's missing pilot report; 13 leftover `/mep stage` artifact dogfood |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| n/a | n/a | packaging slice — do not retag product `@` as this slice's invention |

## Stabilizes

Milestone R. 16 may assume a tagged v0.1.0 exists. strangers read README + CONTRIBUTING without this prep tree.

## Macro constraints (read-only)

- C6: this repo is already the home
- C9: no in-tree live driver; presets stay fail-closed
- C10: `scripts/litmus/slice-boundary.sh --executor stub` stays in FOSS CI
- C8: do not make slash commands the durable API
- 01 rejection: do not tag if litmus is red; do not require Cursor or MEP-hosted keys

## Acceptance criteria (this iteration ONLY)

- [ ] `MEP_VERSION` is `0.1.0` (`tools/mep/bin/mep version --json`)
- [ ] README has an honest **scope table**: ships (unix contract, `executionRequest`, stub dispatch, markers, curate CLI execute, CONTRIBUTING authoring) vs does **not** (live vendor drivers, PATH/AUR install, success #3 three-mode stranger path, document-native manifest)
- [ ] README footer contains the exact Sator Square block (five lines, spaces as in the roadmap)
- [ ] README no longer lists "the v0.1.0 release itself" under still-ahead
- [ ] LICENSE remains MIT; CONTRIBUTING.md remains the 12 authoring surface (no taste rewrite)
- [ ] `.github/workflows/stranger.yml` still runs stranger + golden + litmus `--executor stub`
- [ ] `bash tools/mep/test/run-stranger.sh` and `scripts/litmus/slice-boundary.sh --executor stub` green
- [ ] human annotated tag `v0.1.0` on the release commit — the agent does not `git tag` or `git push --tags` unless asked
- [ ] no vendor SDK; no I5; no 16; no claim that stub is how operators normally build product

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| Sator Square footer | `mechanical` | exact block already in `04-iteration-roadmap.md` |
| `MEP_VERSION` bump | `mechanical` | `registry.sh` `MEP_VERSION`; README `version --json` example |
| scope table | `finish` | what ships vs what does not — must match the tree |
| annotated tag | `finish` | human creates `v0.1.0` |

**Frame — honest scope table:**

| finish | contract (what it must satisfy) | ≥2 in-repo precedents | fork (the question, not the answer) | state |
|--------|---------------------------------|-----------------------|-------------------------------------|-------|
| scope table | a stranger can tell stub from a live driver, and v0.1 from v0.2 | README "Project status"; 01 success vs rejection; C9 | claim #3 vs defer #3 | `open` |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `README.md` | modify | integration | scope table + Sator + version example; do not rewrite Start here |
| `tools/mep/lib/registry.sh` | modify | domain | `MEP_VERSION=0.1.0` |
| `LICENSE` | read | integration | already MIT — rewrite only if the copyright line is false |
| `CONTRIBUTING.md` | read | integration | exist-check; no section rewrite |
| `.github/workflows/stranger.yml` | modify | integration | **only** if a C10 proof is missing |
| `CHANGELOG.md` | new | integration | optional; only if the tag needs a human-readable record |

**Conflicts:** sequential vs 16. do not take `resolver.sh` / `events.sh` / `curate.py`.

**Explicitly not this slice:** live `grok`/`cursor`/`claude-code`/`codex` drivers; AUR; I5; 16; 12 prose rewrite; 14 backfill of `pilot-default-mode-report.md`.

## RED-phase gates (before GREEN)

- [ ] `MEP_VERSION` is still `0.0.0-dev`
- [ ] README has no Sator Square footer
- [ ] README "Project status" still lists v0.1.0 as ahead

## Approach

1. Prove RED: version string, missing Sator, "still ahead" sentence.
2. Write the scope table from 01 + C6–C11 + what 12/13 actually shipped. defer #3 explicitly.
3. Append the Sator block. bump `MEP_VERSION`. update the README `version --json` example.
4. Confirm LICENSE + CONTRIBUTING + CI proofs. do not add a new suite.
5. Stop at commit-prep. the human tags.

## Avoid (out of scope this iteration)

- shipping or claiming a live vendor driver (C9, 01 #3)
- PATH / AUR / package managers
- host submodule (I5)
- eliminating `manifest.json` (16)
- rewriting CONTRIBUTING taste
- backfilling 14's missing pilot report
- growing litmus or golden matrix

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — honest public v0.1.0
- [x] **Ownership minimal** — README + version + verify LICENSE/CONTRIBUTING/CI
- [x] **Category before instance** — truth-in-labeling before the git tag
- [x] **One place to edit** — README is the public claim; `MEP_VERSION` is the machine claim
- [x] **No planned shotgun surgery** — Avoid lists drivers, 16, 12 rewrite, 14 backfill
- [x] **Consolidation routing** — 12 closed authoring artifacts; this is packaging, not another docs dump of taste

**Preflight note:** pass — LICENSE and CONTRIBUTING already exist; the missing work is version + Sator + honest table. 01 success #3 is **not** this slice. Shortcut epic #85 was 404 from this session; treat 01 rejection/success as the DoD stand-in unless the operator pastes the epic. human gate 2026-09-09: keep drafted contract.

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| cleanup | tagged 0.1.0 matches the tree; Sator present; table does not lie | ship a driver; claim three-mode stranger success; retire the manifest |

## Testing

- **FOSS:** `tools/mep/bin/mep version --json`; `run-stranger.sh`; `scripts/litmus/slice-boundary.sh --executor stub`; `run-golden-matrix.sh` if README tokens that suite greps still hold
- **Manual:** README footer is the five-line square; `git tag -l v0.1.0` after the human tags

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** the tag is a label on what exists. fail if the slice ships a driver to "complete" 01 #3, or omits the square.

## After commit

- [ ] `/commit-prep mep-v0-graduation` — code/docs scope
- [ ] `git commit`
- [ ] human `git tag -a v0.1.0`
- [ ] `/prep mep-v0-graduation checkpoint` → 16 is post-v0.1 (optional) or `/mep done`
- [ ] `/commit-prep mep-v0-graduation docs-delta`

## implement-plan instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`).
> Do not read future iterations.
> Do not `git tag` unless the operator asked in the same turn.
