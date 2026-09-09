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
