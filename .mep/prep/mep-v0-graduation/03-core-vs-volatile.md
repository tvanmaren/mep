# Core vs interchangeable — mep-v0-graduation

**Phase:** living belief state (amended at checkpoint)

## Stable core (identity — falsify to disprove architecture)

| id | certainty | falsification |
|----|-----------|---------------|
| C1 | Curate is **communication**, not implementation — preview ratifies narrative; execute materializes publication history | Curate mutates lab branch or invents code |
| C2 | Merge courses optimize **comprehension**; iterations optimize **discovery** — never 1:1 map | Publication order follows iteration numbers by default |
| C3 | Integration branches are **disposable**; lab branch is **sacred** | Execute rebases or rewrites discovery branch |
| C4 | Deterministic CLI owns git mechanics (`measure`, `validate`, `execute`); LLM owns synthesis only | Runtime calls a model for curate execute |
| C5 | v0.1 ships **`preview` + `execute`** for curate | Either mode removed without AD amendment |
| C6 | v0.1 ships from a **standalone repo**; host is a consumer | v0.1.0 tagged while canonical home is still this monorepo |
| C7 | Machine-facing `mep` JSON `status` and process exit **never disagree**; the iter-1 table is public API | a command exits 0 for `blocked` / `desync` / `gated`, or stdout `status` lies about `$?` |
| C8 | Durable next action from `where --json` is **`executionRequest` `{kind,target,argv}`**, derived from resolver **row**; `nextCommand` is adapter presentation | consumers must parse slash strings to know what to run; envelope and `proof` packets disagree |
| C9 | Runtime invoke of executors is **`mep exec dispatch`**; in-tree live driver is **stub** (accept/block); command presets are contracts and must not be shell-evaluated | dispatch parses `nextCommand`; runtime `eval`s `presets.*.command`; a vendor SDK ships as the FOSS driver |
| C10 | Unix-compliance proof is **`scripts/litmus/slice-boundary.sh --executor stub`** required in FOSS CI; the script only composes public `mep` verbs | v0.1.0 tagged without that CI step; the harness reimplements dispatch / evidence / commit-scope |
| C11 | `@finish:open` is a **mode-agnostic readiness blocker**; authorshipMode changes gate actor/action/provenance only | a mode, including absent/default, treats open finishes as committable or checkpointable |
| C12 | Plan documents are the **only mutable workflow ledger**; `manifest.json` is one-release import-only and converts via `mep migrate` | `where` / writers treat the sidecar as authority, or a writer mutates it in place |

## Interchangeable (realizations)

| id | slot | notes |
|----|------|-------|
| I1 | schema v2 field names beyond required execute input | v1 subset still validates for fixtures |
| I2 | `--optimize` CLI passthrough | manifest/executor preset sufficient v0.1 |
| I3 | partial execute rollback | deferred hardening; backup ref exists |
| I4 | git owned-path / revision-triplet as proof of "built" | realization of resolver landing; ≠ promised brief files |
| I5 | host consumption path (submodule / path dep / package) | later host slice — not extract |
| I6 | FOSS default profile name and repo public name | locked: `profile.active=default`; repo `tvanmaren/mep`; CLI `mep` |
| I7 | FOSS `default.json` review-input paths; `check scaffolding` implied `--json` | envelope is identity (C7); these are tactics |
| I8 | `mep_where_resolver_json` / `mep_resolver_json` positional arity (incl. implement `execution_target`) | **collapsed** in `8e4d880` — named `mep_resolver_context_json`; keep as history, not a live fanout |
| I11 | finish-scan comment prefixes (`-- ` SQL vs `--flag`) | **closed** in `f749db1` — `mep_finish_line_is_language_comment` |
| I12 | `mep mark` comment-style map (extension / shebang → hash/slash/sql/html/block) | writer is C9-shaped CLI; grammar still I11 |
| I9 | stub primitive template strings; `.mep/history/evidence.jsonl`; documented command-preset names | invoke seam is C9; spellings now include `grok` (TUI harness) alongside cursor / claude-code / codex; still no live driver |
| I10 | unix-contract optionally invoking litmus; stranger job name; fixture-demo as the litmus seed | the gate is C10; these are CI/fixture tactics |
| I13 | stranger start surface (README Start here; repo-bin vs later PATH; `run-stranger.sh` token lock) | invoke is C6; stub/fail-closed presets are C9; CI composition is C10 |
| I14 | open-marker helper names; consumers may call `mep_finish_has_open` or filter `finish_open` writebacks | the fact is C11; spellings are tactics |
| I15 | unblocked mode-loop suite path (`run-mode-resolver.sh`) and compare-key shape | the invariant is C8; the file/jq key are tactics |
| I16 | emit+tail suite path (`run-events.sh`) and hermetic `MEP_HISTORY_ROOT_OVERRIDE` | history ≠ state is C8; the file/override are tactics |
| I17 | root `CONTRIBUTING.md` + `tools/mep/examples/{profiles,curate-walkthrough.md}` | stranger authoring is C6; these files are the instance |
| I18 | `tools/mep/docs/pilot-default-mode.md` | default-mode evidence record; not a routing input |
| I19 | which lib file owns frontmatter primitives (`resolver.sh` vs a document-state module) | the grammar is C12; the file split is tactics |

## Amendments

| iter | evidence | action |
|------|----------|--------|
| 13 | `954828bdd` — curate CLI + adapter + v2 template + fixture execute | promoted C1–C5; I1–I3 registered |
| 14 | `64802ec14` on owned paths after brief `982655863`; `pilot-default-mode-report.md` absent | confirmed C1–C5; registered I4; **did not** promote default-mode pilot to core — promised evidence never landed |
| 14→0 | `01-invariant-goal.md` success #1 still false on this branch | promoted C6; I5–I6 home = iter 0; next brief is extract not release |
| 0 | github `tvanmaren/mep` — avoid jdx/mise name collision | I6 public name = `mep`; CLI stays `mep` |
| 0 close | `8ae1f24` extract + stranger CI green without host overlay | C6 confirmed; founding-commit seam (brief+tree same SHA) recorded on manifest; host pointer still open (I5 consume later) |
| 1 | `b0886e5` unix-contract + `run-unix-contract.sh` | promoted C7; registered I7; category = envelope+exit map, not `where`-only |
| 2 | `210c716` `executionRequest` on `where` + unix-contract/stranger locks | promoted C8; registered I8; category = row→packet on all emit sites, not fixture-demo-only |
| 3 | `cafdc858` dispatch + stub + workflow verbs; command presets `blocked` | promoted C9; registered I9; stub is accept/block, not a canned classifier |
| 4 | `051df03` slice-boundary litmus on stranger workflow | promoted C10; registered I10; category = composition gate, not canned LLM |
| 5 | `8e4d880` named context + golden matrix; glossary row 5 = implement interstitial | confirmed C8; I8 collapsed; live slug still row-8 until 5b; registered I11; checkpoint session `a0cecb8` (`--fix` blocked) |
| 5b | `f749db1` `-- ` vs `--flag` in finish-scan | I11 closed; brief birth `a0cecb8`; docs-delta `46895d9`; `--fix` had pointed briefRevision at `ab9fc9b` — corrected |
| oob | grok named as command preset (`command=grok`) | I9 hydration — TUI harness on the audit table; no live driver; iter 9 must not drop it |
| 6 | `bb41b68` commit scope fail-closed in manual; `2f937b7` suite `$TMP` trap | confirmed C7 on the commit packet; **default-ok-with-open-finish falsified by 9b** |
| 7 | `092ade7` autopilot join on the same `finish_open` arm | confirmed C7; **did not** promote a ratification/proxy C*; title overclaimed — product is enum expansion + fixture; lifecycle proxy mapping pre-existed |
| 8 | `84aa6e8` `mep mark mise` / `mark finish` | confirmed C9 (no in-tree model); registered I12; category = CLI writer, not watcher / SKILL.md |
| 9 | `2f6a514` README Start here + twins + stranger README lock | confirmed C6/C9/C10; registered I13; category = operator install contract, not a live driver / PATH package |
| 9b | `52bb530` shared open-marker predicate; brief `1f4ed1e` | promoted C11; registered I14; category = readiness fact, not another mode arm |
| 10 | `50d76f6` unblocked `where` mode-loop; brief `1f4ed1e` | confirmed C8; registered I15; **did not** promote a three-layer docs C*; sentence waived |
| 11 | `8408fda` emit+tail suite; writers already existed | confirmed C8 (ledger still not a `where` input); registered I16; **did not** promote an observability C*; product was FOSS proof |
| 12 | `8af941f` CONTRIBUTING + examples; brief `1e8df26` | confirmed C1–C5 and C4 (CLI `--preview` is status, not synthesis); confirmed C8 (no resolver table in CONTRIBUTING); registered I17; **did not** promote an authoring-docs C* |
| 15 | product `66373b3`; brief `43fff44`; checkpoint `1d6bb8f`; tag `v0.1.0` on `66373b3` | confirmed C6/C9/C10; **did not** promote a "scope table form" C*; 01 #3 stays deferred; `--fix` could not prove post-brief impl; tag unblocks 16 |
| 15b | `2aa8a7c` public report + README citation; brief `4b3b893` | **did not** promote default-mode-as-core; 01 #3 stays deferred; registered I18. 14's missing host report stays absent; `--fix` checkpointRevision stripped (impl SHA) |
| 16 | `mode set` returned `manifest_not_found` and `implement` returned an empty `brief.status` on the migrated initiative, while unix-contract stayed green on a legacy-only fixture | scope extended past the brief: readers alone do not retire a sidecar — **every writer must move in the same slice, and each authority arm needs its own fixture**. A green suite over a legacy fixture proves the old path, not the new one. Deviations' home ratified as 03 Amendments (not frontmatter: the parser is line-based); `sessionMode` demoted to invocation-scoped; `phaseApproved` dropped as redundant with `mepPhase`; `iterations[].authorshipMode` deleted from docs — never implemented in any reader |
| 16b | a pre-migration roadmap (file present, no frontmatter) resolved to document authority with an empty cursor, emitting `jq` errors on stderr and `where` "no prep docs yet" at exit 0 | **presence of a document is not presence of state** — authority now requires a frontmatter block. Falsified "reads are backwards compatible": the compatible case was only the unrealistic one (no roadmap at all). Every real legacy initiative has that file |
| 16c | `mepBriefRevision: null` was read as the revision string `"null"`, so checkpoint saw a recorded revision and never wrote the real one | the templates' own null spelling poisoned new initiatives, not just migrated ones. Normalization belongs at the reader (`mep_frontmatter_value`), so hand-authored `null` is inert and templates can keep the keys visible |
| 16d | 16b recurred one file over: `mode set` still tested `[[ -f roadmap ]]`, so a legacy initiative with a bare roadmap got `ok`/`written:true` after writing nothing. Every `mode set` fixture was manifest-only *and roadmap-less*, so the suite covered only the branch being deleted | an authority test written twice is written wrong once — `mep_document_state_present` is the only permitted test, and `mep_frontmatter_set` now fails closed so a writer cannot succeed as a no-op. Also settles the seam: import-only means **no** writer touches the manifest, so `mode set` refuses like `checkpoint`/`doctor` rather than keeping the import file current. Fixtures must vary the axis under test; three fixtures sharing one authority arm is one fixture |
| 16e | full staged audit against the north-star documents found the composed reader inventing all-true `phaseApproved` and `sessionMode: checkpoint`, missing briefs disappearing from the roster, write failures reported as applied, and roadmap-first migration able to strand a half-migrated initiative | A1 is an authority cutover, not permission to fabricate compatibility fields. Document state must fail closed when malformed; trusted writers must report actual persistence; migration writes briefs first and flips authority with the roadmap last. The audit also bounded the claim: iteration 16 implements **A1**, not infer, desync-first routing, unified `where`, tidy inference, or a live driver |
| 16 close | `8a738e4` document-native runtime; live `manifest.json` retired in the following docs-delta | promoted C12; registered I19; confirmed C7/C8/C10. **did not** promote a module-split C* — primitives still live in `resolver.sh`. A2/B/C/D remain future. `--fix` wrote status + implementation/checkpoint revisions to the brief |
