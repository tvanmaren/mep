# Iteration 0 — Repo extract & self-host bootstrap

**Prep slug:** mep-v0-graduation  
**Brief path:** `.mep/prep/mep-v0-graduation/iterations/00-repo-extract-self-host-bootstrap.md`  
**Status:** brief_ready  
**Slice type:** architectural  
**Mode:** hardening  
**Delivery track:** mixed  
**Fanout:** sequential  
**Shortcut:** sc-96

## Epistemic transition

**What became more certain:** MEP's canonical git home is a **new remote** whose tree is MEP-only. Stranger CI proves **storage/profile engine defaults**. Cursor dogfood in that repo uses a **spine/adapter overlay only** — never host's `wiki/prep` + `example` config.

**Irreversible decision (one):** canonical home = new FOSS remote from a MEP path set; host history is not rewritten and host is not wired as a consumer in this slice.

**Maturity target:** embedded → provisional

## Category vs instance

**Category certainty (close this slice):** `paths.sh` / `mep_config_defaults` are the layout: `storage.prepRoot=.mep/prep`. A temp clone **without** `.mep/config` runs `mep where fixture-demo --json`. The engine proves its own default via `config dump`; **doc prose is not a gate of this slice**.

**Relocation vs improvement (the slice boundary).** *Relocation* = move an artifact that already exists, unchanged — plus whatever a directory needs in order to **be** a repo (`LICENSE`, `README`, CI workflow, `.mep/config`, the fixture that proves the move). *Improvement* = change what MEP says or does; authored **in FOSS**, after the move. Every MEP doc under `.mep/plans/mep-*.md` is relocation. The prepRoot authoring-contract rewrite is improvement and is **out of this slice**.

**Instance certainty (this slice only):** repo `mise-en-place`, CLI `mep`; this initiative continues at `.mep/prep/mep-v0-graduation/`; checked-in FOSS `.mep/config` sets Cursor runtime (adapter + spine + session file) **and** `vcs.defaultTrunk=master` so `/mep` works after clone on this repo's actual trunk. Engine default trunk stays `main`; stranger CI with no config must still see that.

**Acceptance order:** defaults storage + stranger fixture CI, then relocate this slug, then Cursor overlay. Never “green CI by copying host `.mep/config`.”

## Constitution (binding for implement)

| | |
|---|---|
| **Owns** | FOSS remote (export path set); `tools/mep/test/run-stranger.sh`; FOSS `.github/workflows/stranger.yml`; `LICENSE` (MIT), `README.md`; FOSS `.mep/config` (Cursor overlay + `vcs.defaultTrunk=master`); `.mep/prep/mep-v0-graduation/**` (copy + path/`ownedPaths` rewrite); relocation of `.mep/plans/mep-*.md` → `.mep/plans/` and `.mep/prep/mep-authorship-modes/**` → `.mep/prep/` (verbatim copy, link fixups only); host pointer that FOSS is live |
| **May know** | `tools/mep/lib/config.sh` defaults; `tools/mep/lib/paths.sh`; `.cursor/commands/{mep,prep,prep-cleanup,prep-curate,prep-pr-description,prep-stage}.md`; `tools/mep/adapters/cursor/README.md`; `tools/mep/examples/profiles/example-stub.md` |
| **Must not know** | `host-api/**`, `host-client/**`, other host product trees; `.cursor/commands/implement-plan.md`; unix foundation (1–4); v0.1.0 / Sator Square (15); manifest retirement (16); host submodule / path-dep / package (I5); **any edit to MEP doc or skill prose** — improvements are authored in FOSS after the move, not here |
| **Invariants** | C1–C6; runtime never calls a model; `manifest.json` transitional; FOSS CI must not require `a host profile.active` or `storage.prepRoot=wiki/prep`; FOSS `.mep/config` must not set those keys; engine `vcs.defaultTrunk` stays `main` |
| **Still provisional** | dual skill/docs copies until a later canon cutover; `tools/mep/test/run.sh` = host compatibility only |

## Epistemic markers (`@` tags)

| location | tag | action |
|----------|-----|--------|
| `tools/mep/test/run-stranger.sh` | `@provisional` | add — defaults suite is the self-host boundary |
| `.github/workflows/stranger.yml` | `@provisional` | add — `# @provisional` on the workflow |

Tag **code/comment** boundaries only. Do not tag README as `@provisional`.

## Stabilizes

Milestone 0. Unix 1–4 runs **in the FOSS remote**. v0.1.0 stays forbidden until litmus (4).

## Macro constraints (read-only)

- C6: v0.1 ships from the standalone remote
- C1–C5: curate communication/execute split
- Engine storage defaults: `.mep/prep`, `.mep/plans`, … — host `wiki/*` is one host overlay

## Acceptance criteria (this iteration ONLY)

- [ ] New git remote `mise-en-place`; tree is the **export path set** only
- [ ] `LICENSE` MIT; `README.md`: chef/sous, CLI `mep`, repo `mise-en-place`, **open** roadmap (no present-tense unix / `executionRequest` / litmus)
- [ ] README: stranger path = no config + `.mep/prep`; Cursor path = committed overlay below
- [ ] FOSS `.mep/config` contains **only**:
  ```ini
  runtime.adapter=cursor
  runtime.sessionActiveFile=.cursor/prep-active
  runtime.spine=.cursor/skills
  runtime.spine=.cursor/commands
  vcs.defaultTrunk=master
  ```
  No `storage.*`, no `a host profile.active`. `vcs.defaultTrunk` is instance (this repo's branch), not a storage overlay.
- [ ] Stranger fixture `.mep/prep/fixture-demo/` (minimal `brief_ready` manifest)
- [ ] `tools/mep/test/run-stranger.sh` uses a **temp git root and no FOSS `.mep/config`**; asserts engine defaults (`prepRoot=.mep/prep`, `adapter=plain`, `profile.active=default`); `mep where fixture-demo --json` `status=ok`; **must not** assert `wiki/prep`, `example`, or `host-api`
- [ ] `.github/workflows/stranger.yml` runs `run-stranger.sh` only; CI green
- [ ] Graduation ledger at `.mep/prep/mep-v0-graduation/` (not `wiki/prep/`). Rewrite `briefPath`, `masterPlanPath`, in-doc links, and **narrow** `ownedPaths` (see table). Do **not** keep `.mep/**` or `wiki/**`. Do **not** invent missing iter 1–12 brief files.
- [ ] All five `.mep/plans/mep-*.md` relocated to `.mep/plans/` (engine `storage.plansRoot` default): `mep-vision-proposal`, `mep-vision-one-pager`, `mep-curate-outline`, `mep-v0.2-outline`, `mep-authorship-modes`. **Verbatim** — link fixups only, no prose rewrites. Their relative cross-links resolve inside the set
- [ ] `.mep/prep/mep-authorship-modes/**` relocated to `.mep/prep/` so `mep-authorship-modes.md`'s architecture-doc link resolves. It is **graduated**: copy the ledger verbatim, do **not** rewrite its `ownedPaths` (a historical record of what it touched in host, including paths FOSS does not carry)
- [ ] No `.mep/plans` hole: the engine defaults `storage.plansRoot=.mep/plans` and the FOSS tree populates it
- [ ] On a FOSS clone **with** the Cursor overlay, `mep where mep-v0-graduation --json` runs (`status=ok`). At `currentIteration` 0 `pending` this may be checkpoint/plan-only — smoke that routing **works**, not that iter 0 is `committed`
- [ ] Further MEP work (iter 1+) is in the FOSS remote on that slug. host `.mep/prep/mep-v0-graduation/` is a **pointer** (remote URL + live path). No dual-edit
- [ ] host diff is the **pointer only**. No edits to host `tools/mep/**` or `.cursor/skills/mise-en-place/**` — host's docs saying `wiki/prep` are locally true, because host's `.mep/config` sets `storage.prepRoot=wiki/prep`
- [ ] host **keeps** tracked MEP artifacts that already live there (`.mep/plans/mep-curate-outline.md`, `.mep/plans/mep-authorship-modes.md`, `.mep/prep/mep-authorship-modes/**`, `tools/mep/**`). Relocate into FOSS by **copy**, not by deleting the host originals. Improvements that happened inside host stay in host until I5
- [ ] `pack-foss.sh`, `run-stranger.sh`, and `fixture-demo/` are **not** committed to host. They ship in the FOSS tree; host's `tools/mep/**` becomes a stale fork until I5 and gains nothing from carrying them
- [ ] host `main` not rewritten; no host consumer pointer
- [ ] Two publishes: FOSS remote (tree) **and** host docs-delta (pointer). `commit-prep` on host cannot stage the FOSS remote
- [ ] No unix-foundation implementation in the export diff

### FOSS `ownedPaths` after rewrite

```text
tools/mep/**
.cursor/skills/mise-en-place/**
.cursor/commands/mep.md
.cursor/commands/prep.md
.cursor/commands/prep-cleanup.md
.cursor/commands/prep-curate.md
.cursor/commands/prep-pr-description.md
.cursor/commands/prep-stage.md
.mep/prep/mep-v0-graduation/**
.mep/plans/mep-curate-outline.md
```

Drop: `.mep/**`, `wiki/prep/**`, `wiki/plans/**`.

`mep-curate-outline.md` is iteration 13's own artifact, so this slug owns it. The vision docs, `mep-v0.2-outline.md`, and the `mep-authorship-modes` ledger are **relocated but not owned** — they ship in the tree without this initiative claiming the right to rewrite them.

### Export path set (FOSS tree)

| path | role |
|------|------|
| `tools/mep/**` | runtime, docs bundle, templates, examples, adapters, tests |
| `.cursor/skills/mise-en-place/**` | Cursor skill (adapter until cutover) |
| `.cursor/commands/mep.md` `prep.md` `prep-cleanup.md` `prep-curate.md` `prep-pr-description.md` `prep-stage.md` | Cursor handles |
| `LICENSE` `README.md` `.github/workflows/stranger.yml` | product home |
| `.mep/config` | Cursor overlay + `vcs.defaultTrunk=master` |
| `.mep/prep/fixture-demo/**` | stranger CI fixture |
| `.mep/prep/mep-v0-graduation/**` | live ledger (copy + rewrite; **created then published**, not a pre-existing filter path) |
| `.mep/plans/mep-*.md` | five relocated MEP docs — vision proposal, one-pager, curate outline, v0.2 outline, authorship modes |
| `.mep/prep/mep-authorship-modes/**` | graduated ledger, moved verbatim so the authorship doc's architecture link resolves |
| `.mep/profiles/default.md` | optional copy of `tools/mep/examples/profiles/example-stub.md` |

Do **not** export: host product plans in `wiki/plans/` (everything not `mep-*`), the rest of `wiki/prep/**`, host `.mep/config`, `.mep/profiles/host.*`, `.cursor/commands/implement-plan.md`, product packages.

**Known dangling, accepted:** the `mep-authorship-modes` ledger cites `.cursor/commands/implement-plan.md` and `hooks/**`, which FOSS does not carry. It is a graduated historical record — rewriting it to look self-consistent would falsify what the initiative actually touched.

## Finish-map (fragment classification)

| fragment | class | cited pattern (if `mechanical`) |
|----------|-------|----------------------------------|
| copy + rewrite ledger into `.mep/prep/`; publish new remote | `mechanical` | `paths.sh` uses `MEP_STORAGE_PREP_ROOT`; approach below |
| FOSS `.mep/config` Cursor overlay | `mechanical` | host `.mep/config` runtime.* keys, **minus** storage/profile, **plus** `vcs.defaultTrunk=master` |
| `run-stranger.sh` in temp root without config | `mechanical` | `run.sh` `MEP_REPO_ROOT_OVERRIDE` + `fresh_workspace` |
| relocate `.mep/plans/mep-*.md` + `mep-authorship-modes` ledger | `mechanical` | verbatim copy; rewrite map in approach below |
| MIT LICENSE + honest README | `mechanical` | this brief |
| host pointer + FOSS push as two remotes | `mechanical` | this brief |
| host consumption path | — | **out of slice** (I5) |

No open finishes.

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| FOSS remote (export path set) | new | domain | canonical home |
| FOSS `tools/mep/test/run-stranger.sh` | new | domain | authored into the FOSS tree, not committed to host |
| FOSS `.mep/prep/fixture-demo/**` | new | domain | ships in FOSS only |
| FOSS `.mep/config` | new | facade | Cursor overlay + trunk=master |
| FOSS `.github/workflows/stranger.yml` | new | integration | `run-stranger.sh` only |
| FOSS `LICENSE` `README.md` | new | integration | |
| FOSS `.mep/plans/mep-*.md` | move | prep | verbatim; link fixups only |
| FOSS `.mep/prep/mep-authorship-modes/**` | move | prep | graduated; `ownedPaths` untouched |
| `.mep/prep/mep-v0-graduation/iterations/00-repo-extract-self-host-bootstrap.md` | modify | prep | host pointer + checkboxes |
| `.mep/prep/mep-v0-graduation/04-iteration-roadmap.md` | modify | prep | FOSS remote URL |

**Conflicts:** sequential. Two remotes.

## RED-phase gates (before GREEN)

- [ ] Temp git root, export-shaped tree, **no** `.mep/config`: `run-stranger.sh` red until fixture-demo + default assertions exist
- [ ] Same temp root: do **not** run host `run.sh` as the FOSS gate
- [ ] Temp root that **copies host `.mep/config`** must **not** be how CI goes green

## Approach

1. Author `run-stranger.sh` + `fixture-demo` into the FOSS tree (temp root, no config).
2. Relocate the doc set **into the tree you will publish**. Rewrite **structured paths only, never prose**:

   | from | to |
   |------|-----|
   | `.mep/prep/mep-v0-graduation` | `.mep/prep/mep-v0-graduation` |
   | `.mep/prep/mep-authorship-modes` | `.mep/prep/mep-authorship-modes` |
   | `.mep/plans/mep-` | `.mep/plans/mep-` |

   Then **audit** it: `rg 'wiki/(prep|plans)' .mep/` and hand-check every hit. Blanket replacement corrupts sentences that legitimately name host paths; the control is a verification loop, not a cleverer pattern.
3. Apply FOSS `ownedPaths` to the graduation manifest. Leave missing 1–12 briefs missing. Leave the graduated authorship manifest untouched.
4. Add FOSS `.mep/config` (Cursor overlay + `vcs.defaultTrunk=master`). Add `LICENSE`, `README`, `stranger.yml`.
5. **Publish A:** push that tree to new remote `mise-en-place`. Do not force-push host. Do not delete PG packages from this branch.
6. **Publish B:** host docs-delta — pointer (FOSS URL + `.mep/prep/mep-v0-graduation/` is live). `commit-prep` here does not include the FOSS remote.
7. Dogfood smoke on FOSS clone with overlay: `mep where mep-v0-graduation --json`. Iter 1+ happens there.

## Avoid (out of scope this iteration)

- Pasting host `.mep/config` (`wiki/prep`, `example`, three-spine product layout) into FOSS
- Using `run.sh` as FOSS CI or asserting `wiki/prep` in `run-stranger.sh`
- Changing engine defaults to `wiki/prep` or engine `vcs.defaultTrunk` to `master`
- Deleting host copies of relocated MEP docs (`mep-curate-outline.md`, `mep-authorship-modes`)
- Exporting `implement-plan.md` or running the host product TDD
- Committing `pack-foss.sh`, `run-stranger.sh`, or `fixture-demo/` to host
- Rewriting the graduated `mep-authorship-modes` ledger to make its dangling refs look tidy
- Unix 1–4, v0.1.0 tag, golden-matrix (5), I5 consume
- Rewriting host `main` / deleting product packages
- Inventing iter 1–12 brief files to “complete” the copy
- Treating foss `where mep-v0-graduation` as proof iter 0 is `committed`
- Editing MEP doc or skill prose **at all** — that is improvement, and it happens in FOSS after the move
- Backfilling iter-14 pilot report

## Brief preflight (checkpoint gate — plan only)

- [x] **Single purpose** — FOSS home + defaults CI + Cursor overlay that does not touch storage
- [x] **Ownership minimal** — export set; no `.mep/**` glob; relocated-but-not-owned docs stay unowned
- [x] **Category before instance** — temp-root defaults before Cursor overlay and before wiki
- [x] **One place to edit** — live ledger FOSS `.mep/prep/mep-v0-graduation/`
- [x] **No planned shotgun surgery** — Avoid lists unix, consume, `run.sh`-as-FOSS
- [x] **Consolidation routing** — does not dump 1–12 briefs into the export

**Preflight note:** pass

## Slice-type rules

| type | validate | must NOT |
|------|----------|----------|
| architectural | home, defaults vs overlay, export boundary, stranger CI | change curate/default-mode product behavior; rewrite host history |

## Testing

- **FOSS CI:** `tools/mep/test/run-stranger.sh` (no host `.mep/config`)
- **host:** `tools/mep/test/run.sh` — compatibility; not this slice's green bar
- **Smoke:** temp/no-config `mep where fixture-demo --json`; FOSS clone **with overlay** `mep where mep-v0-graduation --json` (`status=ok`)
- **Manual:** clone without host paths; CLI works; Cursor `/mep` resolves with overlay

## Architectural diff (fill at checkpoint)

- Assumptions hardened:
- Coupling increased:
- Harder to change:
- Easier to change:
- **Promote to core:**
- **Newly interchangeable:**
- **Falsified:**

## Checkpoint

**Seam smell test:** category = configured prep root + stranger CI without host overlay. Instance = `mise-en-place` + this slug + Cursor overlay. Fail if CI is green only via `wiki/prep` + `example`.

## After commit

- [ ] FOSS remote has the tree + stranger suite + relocated docs
- [ ] FOSS initial commit names the host source SHA — the tree was copied, not `filter-repo`'d, so provenance lives in that message rather than in shared history
- [ ] host: `/commit-prep mep-v0-graduation docs-delta` — **pointer only**
- [ ] `/prep-pr-description mep-v0-graduation 0` optional
- [ ] next slices (unix 1+) in the FOSS remote on `.mep/prep/mep-v0-graduation/`
- [ ] **FOSS follow-up (unnumbered):** the prepRoot authoring-contract rewrite this slice deliberately dropped — `glossary.md` manifest row, `portable-routing.md` state-input line, `SKILL.md` prep-path sentences → configured `storage.prepRoot` (default `.mep/prep`). Still two files per concern in FOSS (`tools/mep/docs/` + `.cursor/skills/mise-en-place/`) until the canon cutover
- [ ] I5 later, on host

## implement instruction

> Implement **only** this file. Constitution + slice-type rules are binding.
> Portable implement (`tools/mep/docs/portable-routing.md`). Do **not** run `.cursor/commands/implement-plan.md`.
> Add `@` tags per epistemic markers.
> Do not read future iterations.
