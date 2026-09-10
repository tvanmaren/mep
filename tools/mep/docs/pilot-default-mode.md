<!--
Evidence record for default authorship on this repo. Not a routing contract.
Runtime and adapters must not parse this file.
-->

# Default-mode record (v0.1)

This is what default mode actually did on **this** repository (`tvanmaren/mep`), initiative
`mep-v0-graduation`, through the **v0.1.0** tag. It is a failure list with a chronology attached,
not a claim that the mode "just works."

**Executor.** An agent harness *could* drive the public CLI (`mep where`, implement against a brief,
`/commit-prep`, `mep checkpoint`). `mep exec dispatch` was **not** the builder. `stub` still writes
nothing. Named presets (`grok`, `cursor`, `claude-code`, `codex`) still return
`executor_driver_unavailable`. If you pipe `where` at `exec dispatch --executor stub` and expect
product code, you will get a ticket printer. That is still true after this document.

The contract is: **ask `where`, then do that.** This pilot did not always. Some sessions presumed
the next slice from chat memory or a stale `04` header. That is item 5, not a footnote.

**What this is not.** [Success condition #3](../../../.mep/prep/mep-v0-graduation/01-invariant-goal.md)
(a stranger, **their** credentials, manual / default / autopilot) remains **open**. A maintainer
running default mode in this checkout is not that stranger. Manual and autopilot have suites; they
have not been driven through real work on this remote.

**Second repo.** The maintainer reports default-mode use on another product repo. This file does
not cite SHAs from that repo. Treat that report as unverified here.

## What broke

These are the parts with evidentiary value. Each has a deviation or a commit on this remote, except
where noted.

1. **`checkpoint --fix` wrote the wrong `briefRevision` (iteration 5b).** It pointed the 5b triplet
   at `ab9fc9b` (a later docs tick) so post-brief implementation looked empty. Corrected to
   brief `a0cecb8`, implementation/checkpoint `f749db1`. The mechanical closer is not a historian; a
   human had to repair the triplet.

2. **Implementation landed before the brief was in git (iteration 9b).** Code `52bb530` preceded the
   brief commit. `--fix` could not prove post-brief work. Human-closed: `status=committed` and
   `implementationRevision=52bb530`. Same shape as the founding extract (`8ae1f24` bundled brief +
   tree).

3. **Same ordering at the release slice (iteration 15).** Product `66373b3` landed before brief
   `43fff44`. `--fix` wrote `briefRevision` only. Human-closed with `implementationRevision=66373b3`.
   The annotated tag `v0.1.0` (signed) points at `66373b3`, not at the later ledger commits.

4. **Iteration 14 promised a report and did not write one.** `--fix` marked 14 committed from
   owned-path git recorded as `64802ec14`. That SHA **does not resolve on this remote**. The promised
   `pilot-default-mode-report.md` was never created. This file is the FOSS stand-in; it does not
   pretend the host-branch artifact exists. Iteration 14's curate-instance probe is a different
   fragment; it is not this document.

5. **The public ledger lagged the tag — because checkpoint was skipped and `where` was not asked.**
   After `v0.1.0`, the roadmap header still said **11 is next** and **15 packaging still open**. A
   stranger reading the file the README points at would have been lied to. The freeze was not
   mysterious: slices landed without `/prep checkpoint`, so `04` never rewrote the destination, and
   later harness turns **presumed** the next action instead of running `mep where`. `where` is the
   thing that would have said "checkpoint" or "you are not on 11." Rewritten to "15 tagged at
   `66373b3`; 16 is post-v0.1." The lesson is mechanical: if the harness does not invoke the
   resolver, the CLI cannot save it from a stale story.

6. **Iteration 7's title overclaimed.** Landed `092ade7` is autopilot join on the `finish_open` commit
   arm, not a proxy runtime. The loop kept the code and recorded the title as overclaim — it did not
   silently promote a ratification C*.

## Chronology (this remote)

Slices **0–12** and **15** have implementation commits that resolve here. **13** and **14** are in
the ledger with host SHAs (`954828bdd`, `64802ec14`) that **do not** resolve on `tvanmaren/mep`; do
not treat those as FOSS proofs.

| slice | what landed here | commit |
|-------|------------------|--------|
| 0 | extract + stranger CI | `8ae1f24` |
| 1 | unix envelope + exit map | `b0886e5` |
| 2 | `executionRequest` on `where` | `210c716` |
| 3 | `exec dispatch` + stub; presets fail closed | `cafdc858` |
| 4 | slice-boundary litmus on stranger CI | `051df03` |
| 5 | named resolver context + golden matrix | `8e4d880` |
| 5b | finish-scan comment grammar | `f749db1` |
| 6 | manual commit-scope fail-closed | `bb41b68` |
| 7 | autopilot on the same `finish_open` arm | `092ade7` |
| 8 | `mep mark` writer | `84aa6e8` |
| 9 | README Start here | `2f6a514` |
| 9b | mode-agnostic open-finish readiness | `52bb530` |
| 10 | unblocked `where` across modes | `50d76f6` |
| 11 | emit+tail suite | `8408fda` |
| 12 | CONTRIBUTING + examples | `8af941f` |
| 15 | `MEP_VERSION=0.1.0`, honest README, Sator footer | `66373b3` |
| tag | signed annotated `v0.1.0` | target commit `66373b3` |

Default mode, in this record, means: human-governed semantics, AI-authored finishes, blocking human
audit at commit (`/commit-prep`). That is how the rows above were produced. It does not mean
unattended `exec dispatch`.

## Claim ceiling

**Willing to claim:** default mode ran this initiative through a tagged v0.1.0, via a harness
that *sometimes* drove the CLI, and the loop's own closer (`checkpoint --fix`) was wrong often
enough that humans had to close slices. Skipping `where` is how a stale "next is 11" header survived
into the tagged tree. The failures above are the proof, not the embarrassment.

**Not willing to claim:** default mode works for a stranger; three-mode success (#3); UCG or any
repo other than this one; that `stub` builds software; that manual or autopilot are proven.

The README's default-mode sentence must not exceed this ceiling.
