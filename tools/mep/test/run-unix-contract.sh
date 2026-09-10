#!/usr/bin/env bash
# Unix command-contract suite: exit map + stderr discipline. FOSS only.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
export MEP_REPO_ROOT=$SRC
MEP="$SRC/tools/mep/bin/mep"
REG="$SRC/tools/mep/lib/registry.sh"
JSON="$SRC/tools/mep/lib/json.sh"

[[ -x "$MEP" ]] || { echo "not ok - missing $MEP" >&2; exit 1; }

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

# --- unit: taxonomy ---
# shellcheck source=/dev/null
. "$JSON"
# shellcheck source=/dev/null
. "$REG"
# shellcheck source=/dev/null
. "$SRC/tools/mep/lib/deps.sh"
# shellcheck source=/dev/null
. "$SRC/tools/mep/lib/paths.sh"
# shellcheck source=/dev/null
. "$SRC/tools/mep/lib/document.sh"
# shellcheck source=/dev/null
. "$SRC/tools/mep/lib/resolver.sh"

# @provisional — lock the row-derived request while routing adapters are still being built.
assert_execution_request() {
  local row=$1 slug=$2 brief_path=$3 expected=$4 actual
  actual=$(mep_execution_request_json "$row" "$slug" "$brief_path") || fail "request row $row emitted"
  jq -en \
    --argjson actual "$actual" \
    --argjson expected "$expected" \
    '$actual == $expected and ($actual | keys | sort) == ["argv", "kind", "target"]' \
    >/dev/null || fail "request row $row shape"
}

assert_execution_request '"precondition"' demo "" '{"kind":"prep","target":"demo","argv":[]}'
assert_execution_request '"migration"' demo "" '{"kind":"migrate","target":"demo","argv":[]}'
assert_execution_request '"invalid_document_state"' demo "" '{"kind":"none","target":null,"argv":[]}'
assert_execution_request 1 demo "" '{"kind":"none","target":null,"argv":[]}'
assert_execution_request 2 demo "" '{"kind":"cleanup","target":"demo","argv":[]}'
assert_execution_request 3 demo "" '{"kind":"prep","target":"demo","argv":[]}'
assert_execution_request 4 demo "" '{"kind":"commit_prep","target":"demo","argv":["docs-bootstrap"]}'
assert_execution_request 5 demo "" '{"kind":"commit_prep","target":"demo","argv":["docs-delta"]}'
assert_execution_request 6 demo "" '{"kind":"checkpoint","target":"demo","argv":[]}'
assert_execution_request 7 demo brief.md '{"kind":"implement","target":"brief.md","argv":["brief.md"]}'
assert_execution_request 8 demo brief.md '{"kind":"implement","target":"brief.md","argv":["brief.md"]}'
assert_execution_request 9 demo "" '{"kind":"commit_prep","target":"demo","argv":[]}'
assert_execution_request 10 demo "" '{"kind":"checkpoint","target":"demo","argv":[]}'
assert_execution_request 11 demo "" '{"kind":"checkpoint","target":"demo","argv":[]}'
rc=0
mep_execution_request_json 12 demo "" >/dev/null || rc=$?
[[ "$rc" == 70 ]] || fail "unknown request row fails internal (got $rc)"
pass "execution request row map"

# subshell: mep_exit_for_status always exits
assert_map() {
  local st=$1 want=$2
  local rc=0
  ( mep_exit_for_status "$st" ) || rc=$?
  [[ "$rc" == "$want" ]] || fail "map $st -> $want (got $rc)"
  pass "map $st -> $want"
}

assert_map ok 0
assert_map clean 0
assert_map desync 1
assert_map gated 1
assert_map warning 1
assert_map blocked 2
assert_map missing_dependency 2
assert_map not_found 3
assert_map usage 64
assert_map internal 70

assert_print() {
  local packet=$1 want_st=$2 want_rc=$3
  local rc=0 out
  out=$(mep_print_json_exit "$packet") || rc=$?
  [[ "$rc" == "$want_rc" ]] || fail "print $want_st exit $want_rc (got $rc)"
  jq -e --arg st "$want_st" '.status == $st' <<<"$out" >/dev/null || fail "print $want_st packet"
  pass "print $want_st -> $want_rc"
}

assert_print '{"status":"ok"}' ok 0
assert_print '{"status":"desync"}' desync 1
assert_print '{"status":"gated"}' gated 1
assert_print '{"status":"warning"}' warning 1
assert_print '{"status":"blocked"}' blocked 2
assert_print '{"status":"not_found"}' not_found 3
assert_print '{"status":"error"}' internal 70
assert_print '{"status":"ready"}' internal 70

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
tmp="$TMP/out"
err="$TMP/err"
: >"$tmp"
: >"$err"

frontmatterless="$TMP/frontmatterless.md"
printf '# body\n' >"$frontmatterless"
rc=0
mep_frontmatter_set "$frontmatterless" mepPhase 5 || rc=$?
[[ "$rc" == 1 ]] || fail "frontmatter setter must fail closed without a block"
grep -qx '# body' "$frontmatterless" || fail "frontmatter setter changed a document without state"
pass "frontmatter setter fails closed"

spaced_frontmatter="$TMP/spaced-frontmatter.md"
printf '%s\n' '---' 'mepIteration: 1 ' 'mepStatus: brief_ready ' '---' >"$spaced_frontmatter"
[[ "$(mep_frontmatter_value "$spaced_frontmatter" mepStatus)" == brief_ready ]] \
  || fail "frontmatter reader retained trailing whitespace"
printf '%s\n' '---' 'mepIteration: 1' >"$spaced_frontmatter"
jq -e '.documentError.kind == "invalid_frontmatter_block"' \
  <<<"$(mep_document_iteration_json "$spaced_frontmatter")" >/dev/null \
  || fail "iteration reader accepted unterminated frontmatter"
pass "frontmatter reader normalizes and validates boundaries"

rc=0
mep_require __mep_no_such_dep__ >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "mep_require missing_dependency return 2 (got $rc)"
jq -e '.status == "missing_dependency"' "$tmp" >/dev/null || fail "missing_dependency packet"
pass "missing_dependency packet exit 2"

# registry feeds help
mep_registry_print | grep -q $'^where\t' || fail "registry has where"
pass "registry lists where"
mep_registry_print | grep -q $'^mark mise\t' || fail "registry has mark mise"
mep_registry_print | grep -q $'^mark finish\t' || fail "registry has mark finish"
pass "registry lists marker writers"

# --- CLI packets ---

rc=0
"$MEP" >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 64 ]] || fail "bare mep usage exit 64 (got $rc)"
[[ ! -s "$tmp" ]] || fail "bare mep stdout empty"
[[ -s "$err" ]] || fail "bare mep stderr nonempty"
pass "usage exit 64 stderr-only"

rc=0
"$MEP" pr scaffold fixture-demo 1 >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 64 ]] || fail "pr scaffold missing --json exit 64 (got $rc)"
[[ ! -s "$tmp" ]] || fail "pr scaffold usage stdout empty"
pass "pr scaffold usage exit 64"

rc=0
"$MEP" migrate --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 64 ]] || fail "migrate missing slug exit 64 (got $rc)"
[[ ! -s "$tmp" && -s "$err" ]] || fail "migrate usage must be stderr-only"
pass "migrate rejects flag-shaped slug"

rc=0
"$MEP" lifecycle status fixture-demo --mode nope --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 64 ]] || fail "lifecycle bad --mode exit 64 (got $rc)"
[[ ! -s "$tmp" ]] || fail "lifecycle usage stdout empty"
[[ -s "$err" ]] || fail "lifecycle usage stderr nonempty"
pass "lifecycle bad mode usage exit 64"

rc=0
"$MEP" help >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "help exit 0 (got $rc)"
[[ ! -s "$tmp" ]] || fail "help stdout empty"
[[ -s "$err" ]] || fail "help stderr nonempty"
grep -q 'mep where' "$err" || fail "help lists where from registry"
while IFS=$'\t' read -r _ usage _; do
  [[ -n "$usage" ]] || continue
  grep -F "  $usage" "$err" >/dev/null || fail "help missing $usage"
done < <(mep_registry_print)
pass "help lists every registry usage"

rc=0
"$MEP" version --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "version exit 0 (got $rc)"
[[ ! -s "$err" ]] || fail "version stderr empty"
jq -e '.status == "ok" and (.version | type == "string")' "$tmp" >/dev/null || fail "version envelope"
pass "version --json"

rc=0
"$MEP" config dump --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "config dump exit 0 (got $rc)"
[[ ! -s "$err" ]] || fail "config dump stderr empty"
jq -e '.status == "ok"' "$tmp" >/dev/null || fail "config dump status ok"
jq -e '
  .executors.default == "stub"
  and .executors.presets.stub == {kind:"stub",command:"internal:stub"}
  and .executors.presets.cursor == {kind:"command",command:"cursor"}
  and .executors.presets["claude-code"] == {kind:"command",command:"claude"}
  and .executors.presets.codex == {kind:"command",command:"codex"}
  and .executors.presets.grok == {kind:"command",command:"grok"}
' "$tmp" >/dev/null || fail "config dump executor presets"
pass "config dump envelope exit 0"

rc=0
"$MEP" where fixture-demo --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "where fixture-demo exit 0 (got $rc)"
[[ ! -s "$err" ]] || fail "where success stderr empty"
jq -e '.status == "ok"' "$tmp" >/dev/null || fail "where status ok"
jq -e '
  .executionRequest == .proof.executionRequest
  and (.executionRequest | keys | sort) == ["argv", "kind", "target"]
  and .executionRequest == {
    kind: "migrate",
    target: "fixture-demo",
    argv: []
  }
  and .nextCommand == "mep migrate fixture-demo --json"
' "$tmp" >/dev/null || fail "where fixture-demo execution request"
pass "where fixture-demo durable execution request"

request=$(jq -c '.executionRequest' "$tmp")
rc=0
printf '%s\n' "$request" | "$MEP" exec dispatch --json --executor stub >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "stub dispatch exit 0 (got $rc)"
[[ ! -s "$err" ]] || fail "stub dispatch stderr empty"
jq -e --argjson request "$request" '
  .status == "ok"
  and .executor == "stub"
  and .dryRun == false
  and .executionRequest == $request
  and .result == {kind:"stub",accepted:true,primitive:"mep migrate"}
' "$tmp" >/dev/null || fail "stub dispatch preserves execution request"
pass "stub dispatch from where request"

while IFS=$'\t' read -r kind target primitive; do
  if [[ "$kind" == none ]]; then
    request=$(jq -cn --arg kind "$kind" '{kind:$kind,target:null,argv:[]}')
  else
    request=$(jq -cn --arg kind "$kind" --arg target "$target" '{kind:$kind,target:$target,argv:[]}')
  fi
  "$MEP" exec dispatch --json --executor stub --request-json "$request" >"$tmp" 2>"$err"
  jq -e --arg kind "$kind" --arg primitive "$primitive" '
    .status == "ok"
    and .executionRequest.kind == $kind
    and .result.primitive == $primitive
  ' "$tmp" >/dev/null || fail "stub maps $kind primitive"
done <<'CASES'
implement	brief.md	mep implement
checkpoint	demo	mep checkpoint
commit_prep	demo	mep commit scope
prep	demo	mep evidence write <slug> prep <state>
migrate	demo	mep migrate
cleanup	demo	mep evidence write <slug> cleanup <state>
none	-	none
CASES
pass "stub maps every execution kind"

rc=0
"$MEP" exec dispatch --json --executor stub \
  --request-json '{"kind":"bogus","target":"x","argv":[]}' >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "invalid dispatch request exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_execution_request"' "$tmp" >/dev/null || fail "invalid dispatch packet"
pass "invalid dispatch request blocked"

rc=0
"$MEP" exec dispatch --json --executor cursor \
  --request-json '{"kind":"none","target":null,"argv":[]}' >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "documented command preset exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "executor_driver_unavailable"' "$tmp" >/dev/null || fail "command preset unavailable packet"
pass "documented command preset has no live driver"

rc=0
"$MEP" exec dispatch --json --executor cursor --dry-run \
  --request-json '{"kind":"none","target":null,"argv":[]}' >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "command preset dry-run exit 0 (got $rc)"
jq -e '
  .status == "ok"
  and .executor == "cursor"
  and .dryRun == true
  and .result == {kind:"dry_run",accepted:true,presetKind:"command",command:"cursor"}
' "$tmp" >/dev/null || fail "command preset dry-run packet"
pass "command preset dry-run suppresses driver"

route_fx="$TMP/route_fx"
mkdir -p "$route_fx/.mep/prep/commit-prep-fx/iterations"
cat >"$route_fx/.mep/prep/commit-prep-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: commit-prep-fx
mepPhase: 5
mepPrepDocsBootstrapped: false
mepInitiativeStatus: active
mepCurrentIteration: 1
mepOwnedPaths: [".mep/prep/commit-prep-fx/**"]
---

# Iteration roadmap — commit-prep-fx
MD
cat >"$route_fx/.mep/prep/commit-prep-fx/iterations/01.md" <<'MD'
---
mepIteration: 1
mepTitle: Bootstrap fixture
mepStatus: pending
mepSliceType: behavioral
---

# Iteration 1 — bootstrap fixture
MD
git -C "$route_fx" init -q -b main
git -C "$route_fx" config user.email "mep@test"
git -C "$route_fx" config user.name "mep"
git -C "$route_fx" config commit.gpgsign false
git -C "$route_fx" add -A
git -C "$route_fx" commit -q -m "commit-prep routing fixture"
rc=0
MEP_REPO_ROOT_OVERRIDE="$route_fx" "$MEP" where commit-prep-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "where commit-prep fixture exit 0 (got $rc)"
[[ ! -s "$err" ]] || fail "where commit-prep fixture stderr empty"
jq -e '
  .status == "ok"
  and .row == 4
  and .executionRequest == .proof.executionRequest
  and .executionRequest == {kind: "commit_prep", target: "commit-prep-fx", argv: ["docs-bootstrap"]}
  and (.executionRequest | keys | sort) == ["argv", "kind", "target"]
  and ([.executionRequest.kind] - ["implement", "checkpoint", "commit_prep", "prep", "cleanup", "none"] | length) == 0
  and (.nextCommand | startswith("/commit-prep "))
' "$tmp" >/dev/null || fail "where commit-prep execution request"
pass "where commit-prep row-derived execution request"

rc=0
"$MEP" checkpoint __no-such-slug__ --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 3 ]] || fail "checkpoint missing slug exit 3 (got $rc)"
jq -e '.status == "not_found"' "$tmp" >/dev/null || fail "checkpoint not_found status"
pass "not_found exit 3"

rc=0
"$MEP" doctor mep-v0-graduation --json --trunk __no_such_trunk__ >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 3 ]] || fail "doctor missing trunk exit 3 (got $rc)"
jq -e '.status == "not_found" and .reason == "trunk_not_found"' "$tmp" >/dev/null || fail "doctor trunk not_found packet"
pass "doctor trunk not_found exit 3"

hist="$TMP/hist-not-file"
mkdir -p "$hist/events.jsonl"
rc=0
MEP_HISTORY_ROOT_OVERRIDE=$hist "$MEP" events tail --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 3 ]] || fail "events ledger not a file exit 3 (got $rc)"
jq -e '.status == "not_found" and .reason == "invalid_ledger"' "$tmp" >/dev/null || fail "events ledger-not-file packet"
pass "events ledger not a file not_found exit 3"

hist="$TMP/hist-malformed"
mkdir -p "$hist"
printf 'not-json\n' >"$hist/events.jsonl"
rc=0
MEP_HISTORY_ROOT_OVERRIDE=$hist "$MEP" events tail --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "events malformed ledger exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_ledger"' "$tmp" >/dev/null || fail "events invalid_ledger blocked packet"
pass "events malformed ledger blocked exit 2"

prof="$TMP/prof"
mkdir -p "$prof/.mep"
printf 'profile.active=default\nprofile.dir=.mep/profiles\n' >"$prof/.mep/config"
rc=0
MEP_REPO_ROOT_OVERRIDE=$prof "$MEP" profile dump --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 3 ]] || fail "profile missing seed exit 3 (got $rc)"
jq -e '.status == "not_found" and .reason == "missing_profile_seed"' "$tmp" >/dev/null || fail "profile missing seed packet"
mkdir -p "$prof/.mep/profiles"
printf '{not json' >"$prof/.mep/profiles/default.json"
rc=0
MEP_REPO_ROOT_OVERRIDE=$prof "$MEP" profile dump --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "profile invalid seed exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_profile_seed"' "$tmp" >/dev/null || fail "profile invalid seed packet"
pass "profile seed not_found / blocked"

rc=0
"$MEP" profile dump --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "repo profile dump exit 0 (got $rc)"
jq -e '.status == "ok" and .profile.active == "default"' "$tmp" >/dev/null || fail "repo profile seed ok"
pass "repo profile dump ok"

fx="$TMP/desync-fx"
mkdir -p "$fx/.mep/prep/desync-fx/iterations"
cat >"$fx/.mep/prep/desync-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: desync-fx
mepPhase: 5
mepPrepDocsBootstrapped: true
mepInitiativeStatus: active
mepCurrentIteration: 1
mepOwnedPaths: [".mep/prep/desync-fx/**"]
---

# Iteration roadmap — desync-fx
MD
cat >"$fx/.mep/prep/desync-fx/iterations/01.md" <<'MD'
---
mepIteration: 1
mepTitle: Desync fixture
mepStatus: committed
mepSliceType: behavioral
---

# Iteration 1 — Desync fixture
MD
git -C "$fx" init -q -b main
git -C "$fx" config user.email "mep@test"
git -C "$fx" config user.name "mep"
git -C "$fx" config commit.gpgsign false
git -C "$fx" add -A
git -C "$fx" commit -q -m "desync fixture"
rc=0
out=$(
  cd "$fx" && MEP_REPO_ROOT_OVERRIDE="$fx" "$MEP" doctor desync-fx --json
) || rc=$?
printf '%s\n' "$out" >"$tmp"
[[ "$rc" == 1 ]] || fail "doctor desync fixture exit 1 (got $rc)"
jq -e '.status == "desync"' "$tmp" >/dev/null || fail "doctor desync fixture packet"
pass "doctor desync fixture exit 1"

workflow_fx="$TMP/workflow_fx"
mkdir -p "$workflow_fx/.mep/prep/workflow-fx/iterations"
cat >"$workflow_fx/.mep/prep/workflow-fx/manifest.json" <<'JSON'
{
  "slug": "workflow-fx",
  "schemaVersion": 1,
  "framework": "mise-en-place",
  "authorshipMode": "default",
  "phase": 5,
  "prepDocsBootstrapped": true,
  "initiativeStatus": "active",
  "currentIteration": 1,
  "ownedPaths": ["src/**", ".mep/prep/workflow-fx/**"],
  "iterations": [{"number": 1, "title": "Workflow fixture", "briefPath": ".mep/prep/workflow-fx/iterations/01.md", "status": "brief_ready", "sliceType": "behavioral"}]
}
JSON
cat >"$workflow_fx/.mep/prep/workflow-fx/iterations/01.md" <<'MD'
# Iteration 1 — Workflow fixture

**Status:** brief_ready

## Constitution

| | |
|---|---|
| **Owns** | `src/workflow.sh`; fixture tests |
| **May know** | fixture inputs |
| **Must not know** | network |
| **Invariants** | read-only |
| **Still provisional** | fixture adapter |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `src/workflow.sh` | modify | domain | fixture |
| `test/workflow.sh` | modify | integration | fixture |
MD
git -C "$workflow_fx" init -q -b main
git -C "$workflow_fx" config user.email "mep@test"
git -C "$workflow_fx" config user.name "mep"
git -C "$workflow_fx" config commit.gpgsign false
git -C "$workflow_fx" add -A
git -C "$workflow_fx" commit -q -m "workflow fixture"

brief_hash=$(git -C "$workflow_fx" hash-object .mep/prep/workflow-fx/iterations/01.md)
MEP_REPO_ROOT_OVERRIDE="$workflow_fx" "$MEP" implement --json \
  .mep/prep/workflow-fx/iterations/01.md >"$tmp" 2>"$err"
[[ "$(git -C "$workflow_fx" hash-object .mep/prep/workflow-fx/iterations/01.md)" == "$brief_hash" ]] || fail "implement packet mutated brief"
jq -e '
  .status == "ok"
  and .readOnly == true
  and .executionRequest.kind == "implement"
  and .brief.status == "brief_ready"
  and .brief.constitution == {
    owns:"`src/workflow.sh`; fixture tests",
    mayKnow:"fixture inputs",
    mustNotKnow:"network",
    invariants:"read-only",
    stillProvisional:"fixture adapter"
  }
  and .brief.ownedPaths == ["src/workflow.sh","test/workflow.sh"]
' "$tmp" >/dev/null || fail "implement scope packet"
pass "implement packet is read-only"

rc=0
MEP_REPO_ROOT_OVERRIDE="$workflow_fx" "$MEP" implement --json ../../etc/passwd >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "unsafe implement path exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_brief_path"' "$tmp" >/dev/null || fail "unsafe implement path packet"
pass "implement rejects path traversal"

MEP_REPO_ROOT_OVERRIDE="$workflow_fx" "$MEP" commit scope workflow-fx --json >"$tmp" 2>"$err"
jq -e '
  .status == "ok"
  and .readOnly == true
  and .iteration == 1
  and .paths == ["src/workflow.sh","test/workflow.sh"]
' "$tmp" >/dev/null || fail "commit scope packet"
pass "commit scope follows brief ownership"

manifest_hash=$(git -C "$workflow_fx" hash-object .mep/prep/workflow-fx/manifest.json)
rc=0
MEP_REPO_ROOT_OVERRIDE="$workflow_fx" "$MEP" mode set workflow-fx manual --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "legacy mode set exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "legacy_state_read_only"' "$tmp" >/dev/null || fail "legacy mode set packet"
[[ "$(git -C "$workflow_fx" hash-object .mep/prep/workflow-fx/manifest.json)" == "$manifest_hash" ]] || fail "legacy mode set wrote the import file"
pass "mode set refuses import-only state"

rc=0
MEP_REPO_ROOT_OVERRIDE="$workflow_fx" "$MEP" mode set absent-fx manual --json --dry-run >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 3 ]] || fail "absent mode set exit 3 (got $rc)"
jq -e '.status == "not_found" and .reason == "state_not_found" and (.statePath | endswith("/04-iteration-roadmap.md"))' "$tmp" >/dev/null \
  || fail "absent mode set packet"
pass "mode set rejects absent initiative"

# Document-native twin of workflow_fx: the same verbs against roadmap/brief frontmatter
# rather than the legacy import file.
doc_fx="$TMP/doc_fx"
doc_roadmap="$doc_fx/.mep/prep/doc-fx/04-iteration-roadmap.md"
doc_brief="$doc_fx/.mep/prep/doc-fx/iterations/01.md"
mkdir -p "$doc_fx/.mep/prep/doc-fx/iterations"
cat >"$doc_roadmap" <<'MD'
---
mepSlug: doc-fx
mepPhase: 5
mepPrepDocsBootstrapped: true
mepHandoffApproved: true
mepInitiativeStatus: active
mepAuthorshipMode: default
mepCurrentIteration: 1
mepOwnedPaths: ["src/**", ".mep/prep/doc-fx/**"]
---

# Iteration roadmap — doc-fx
MD
cat >"$doc_brief" <<'MD'
---
mepIteration: 1
mepTitle: Workflow fixture
mepStatus: brief_ready
mepSliceType: behavioral
mepFanout: sequential
---

# Iteration 1 — Workflow fixture

## Constitution

| | |
|---|---|
| **Owns** | `src/workflow.sh`; fixture tests |
| **May know** | fixture inputs |
| **Must not know** | network |
| **Invariants** | read-only |
| **Still provisional** | fixture adapter |

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `src/workflow.sh` | modify | domain | fixture |
| `test/workflow.sh` | modify | integration | fixture |
MD
git -C "$doc_fx" init -q -b main
git -C "$doc_fx" config user.email "mep@test"
git -C "$doc_fx" config user.name "mep"
git -C "$doc_fx" config commit.gpgsign false
git -C "$doc_fx" add -A
git -C "$doc_fx" commit -q -m "doc fixture"

MEP_REPO_ROOT_OVERRIDE="$doc_fx" "$MEP" implement --json \
  .mep/prep/doc-fx/iterations/01.md >"$tmp" 2>"$err"
jq -e '
  .status == "ok"
  and .brief.status == "brief_ready"
  and .brief.ownedPaths == ["src/workflow.sh","test/workflow.sh"]
' "$tmp" >/dev/null || fail "implement reads brief status from frontmatter"
pass "implement scope reads document frontmatter"

MEP_REPO_ROOT_OVERRIDE="$doc_fx" "$MEP" mode set doc-fx manual --json --dry-run >"$tmp" 2>"$err"
jq -e '.status == "ok" and .authorshipMode == "manual" and .dryRun == true and .written == false' "$tmp" >/dev/null || fail "mode dry-run packet on documents"
grep -q '^mepAuthorshipMode: default$' "$doc_roadmap" || fail "mode dry-run mutated roadmap"
roadmap_mode=$(stat -c '%a' "$doc_roadmap")
MEP_REPO_ROOT_OVERRIDE="$doc_fx" "$MEP" mode set doc-fx manual --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .dryRun == false and .written == true' "$tmp" >/dev/null || fail "mode write packet on documents"
grep -q '^mepAuthorshipMode: manual$' "$doc_roadmap" || fail "mode write missed roadmap frontmatter"
[[ "$(stat -c '%a' "$doc_roadmap")" == "$roadmap_mode" ]] || fail "mode write changed roadmap permissions"
[[ ! -e "$doc_fx/.mep/prep/doc-fx/manifest.json" ]] || fail "mode write created a legacy manifest"
MEP_REPO_ROOT_OVERRIDE="$doc_fx" "$MEP" finish scan doc-fx --json >"$tmp" 2>"$err"
jq -e '.authorshipMode == "manual"' "$tmp" >/dev/null || fail "resolver did not observe mode write"
pass "mode set writes roadmap frontmatter"

mep_frontmatter_set "$doc_roadmap" mepPhase 4
chmod 500 "$(dirname "$doc_brief")" "$(dirname "$doc_roadmap")"
rc=0
MEP_REPO_ROOT_OVERRIDE="$doc_fx" "$MEP" checkpoint doc-fx --json --fix >"$tmp" 2>"$err" || rc=$?
chmod 700 "$(dirname "$doc_brief")" "$(dirname "$doc_roadmap")"
[[ "$rc" == 2 ]] || fail "checkpoint write failure exit 2 (got $rc)"
jq -e '
  .status == "blocked"
  and .appliedWritebacks == 0
  and ([.findings[] | select(.kind == "state_write_failed")] | length) == 1
' "$tmp" >/dev/null || fail "checkpoint write failure packet"
pass "checkpoint reports failed document writes"

# A literal `null` in frontmatter means "unset", not the revision string "null".
grep -q '^mepBriefRevision: null$' "$SRC/tools/mep/templates/slice-brief.md" \
  || fail "slice-brief template no longer exercises the null-revision case"
MEP_REPO_ROOT_OVERRIDE="$doc_fx" "$MEP" where doc-fx --json >"$tmp" 2>"$err"
jq -e '.proof.facts.documents.briefRevision == null' "$tmp" >/dev/null || fail "null frontmatter read as a revision value"
pass "null frontmatter reads as absent"

# Pre-migration initiative: a roadmap exists but carries no frontmatter, so the manifest is authority.
legacy_fx="$TMP/legacy_fx"
mkdir -p "$legacy_fx/.mep/prep/legacy-fx/iterations" "$legacy_fx/src"
cat >"$legacy_fx/.mep/prep/legacy-fx/manifest.json" <<'JSON'
{
  "slug": "legacy-fx",
  "schemaVersion": 1,
  "authorshipMode": "default",
  "phase": 4,
  "phaseApproved": {"1": true, "2": true, "3": true, "4": false, "5": false},
  "sessionMode": "checkpoint",
  "prepDocsBootstrapped": true,
  "handoffApproved": true,
  "initiativeStatus": "active",
  "currentIteration": 1,
  "ownedPaths": ["src/**", ".mep/prep/legacy-fx/**"],
  "deviations": [{"kind":"fixture-history"}],
  "unknownLegacy": true,
  "iterations": [{
    "number": 1,
    "title": "Legacy fixture",
    "briefPath": ".mep/prep/legacy-fx/iterations/01.md",
    "status": "brief_ready",
    "sliceType": "behavioral",
    "implementationPaths": ["src/app.sh"],
    "unknownSlice": true
  }]
}
JSON
cat >"$legacy_fx/.mep/prep/legacy-fx/04-iteration-roadmap.md" <<'MD'
# Iteration roadmap — legacy-fx

**Status:** approved
MD
cat >"$legacy_fx/.mep/prep/legacy-fx/iterations/01.md" <<'MD'
# Iteration 1 — Legacy fixture

**Status:** brief_ready

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `src/app.sh` | modify | domain | fixture |
MD
echo 'echo hi' >"$legacy_fx/src/app.sh"
git -C "$legacy_fx" init -q -b main
git -C "$legacy_fx" config user.email "mep@test"
git -C "$legacy_fx" config user.name "mep"
git -C "$legacy_fx" config commit.gpgsign false
git -C "$legacy_fx" add -A
git -C "$legacy_fx" commit -q -m "legacy fixture"

MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" status legacy-fx --compact --json >"$tmp" 2>"$err"
[[ ! -s "$err" ]] || fail "legacy read wrote to stderr: $(head -1 "$err")"
jq -e '.initiative.authority == "legacy_import" and .initiative.currentIteration == 1' "$tmp" >/dev/null \
  || fail "frontmatter-less roadmap must not claim document authority"
MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" where legacy-fx --json >"$tmp" 2>"$err"
jq -e '
  .row == "migration"
  and .nextCommand == "mep migrate legacy-fx --json"
  and .executionRequest == {kind:"migrate",target:"legacy-fx",argv:[]}
' "$tmp" >/dev/null || fail "legacy import must route to migration (got row $(jq -c '.row' "$tmp"))"
pass "legacy import routes to migration"

rc=0
MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" checkpoint legacy-fx --json --fix >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "legacy checkpoint --fix exit 2 (got $rc)"
jq -e '
  .status == "blocked"
  and .appliedWritebacks == 0
  and ([.findings[] | select(.kind == "legacy_state_read_only")] | length) == 1
  and ([.findings[] | select(.fixable == true)] | length) == 0
' "$tmp" >/dev/null || fail "legacy checkpoint must refuse out loud, not silently"
pass "checkpoint names the legacy refusal"

rc=0
out=$(
  cd "$legacy_fx" && MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" doctor legacy-fx --json --fix
) || rc=$?
printf '%s\n' "$out" >"$tmp"
[[ "$rc" == 2 ]] || fail "legacy doctor --fix exit 2 (got $rc)"
jq -e '
  .status == "blocked"
  and .appliedPromotions == 0
  and .appliedPhaseNormalizations == 0
  and ([.findings[] | select(.finding == "legacy_state_read_only")] | length) == 1
' "$tmp" >/dev/null || fail "legacy doctor must refuse out loud, not silently"
pass "doctor names the legacy refusal"

MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" migrate legacy-fx --json --dry-run >"$tmp" 2>"$err"
jq -e '
  .status == "ok"
  and .written == false
  and .briefsWritten == 1
  and (.droppedKeys | sort) == ["deviations","iterations[].unknownSlice","phaseApproved","schemaVersion","sessionMode","unknownLegacy"]
' "$tmp" >/dev/null || fail "migrate dry-run packet"
git -C "$legacy_fx" diff --quiet || fail "migrate dry-run mutated the tree"
MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" migrate legacy-fx --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .written == true and .legacyRemoved == true and .briefsWritten == 1' "$tmp" >/dev/null || fail "migrate write packet"
[[ ! -e "$legacy_fx/.mep/prep/legacy-fx/manifest.json" ]] || fail "migrate left a stale sidecar behind"
MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" status legacy-fx --compact --json >"$tmp" 2>"$err"
jq -e '
  .initiative.authority == "documents"
  and .initiative.phase == 4
  and .initiative.masterPlanPath == null
  and .initiative.currentIteration == 1
  and .initiative.ownedPaths == ["src/**",".mep/prep/legacy-fx/**"]
  and .initiative.iterations[0].status == "brief_ready"
  and .initiative.iterations[0].implementationPaths == ["src/app.sh"]
  and (.initiative.iterations[0] | has("deliveryTrack") | not)
  and (.initiative.iterations[0] | has("fanout") | not)
  and (.initiative.iterations[0] | has("briefRevision") | not)
' "$tmp" >/dev/null || fail "migrated state must match the manifest it replaced"
MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" where legacy-fx --json >"$tmp" 2>"$err"
jq -e '.row == 7' "$tmp" >/dev/null || fail "migration changed the resolved row"
MEP_REPO_ROOT_OVERRIDE="$legacy_fx" "$MEP" migrate legacy-fx --json >"$tmp" 2>"$err"
jq -e '
  .alreadyMigrated == true
  and .written == false
  and .legacyRemoved == true
  and .dryRun == false
  and .briefsWritten == 0
  and .droppedKeys == []
' "$tmp" >/dev/null || fail "migrate must be idempotent with one packet shape"
pass "migrate preserves modeled state and names dropped legacy keys"

# Fresh document state must not inherit synthetic checkpoint/phase approvals.
fresh_fx="$TMP/fresh_fx"
mkdir -p "$fresh_fx/.mep/prep/fresh-fx/iterations"
cat >"$fresh_fx/.mep/prep/fresh-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: fresh-fx
mepPhase: 4
mepPrepDocsBootstrapped: false
mepHandoffApproved: false
mepInitiativeStatus: active
mepAuthorshipMode: default
mepCurrentIteration: null
mepOwnedPaths: []
mepMasterPlanPath: null
---

# Iteration roadmap — fresh-fx
MD
git -C "$fresh_fx" init -q -b main
git -C "$fresh_fx" config user.email "mep@test"
git -C "$fresh_fx" config user.name "mep"
git -C "$fresh_fx" config commit.gpgsign false
git -C "$fresh_fx" add -A
git -C "$fresh_fx" commit -q -m "fresh document fixture"
out=$(
  cd "$fresh_fx" && MEP_REPO_ROOT_OVERRIDE="$fresh_fx" "$MEP" doctor fresh-fx --json
)
jq -e '.status == "clean" and .phaseNormalizationCandidateCount == 0' <<<"$out" >/dev/null \
  || fail "fresh phase-4 documents must not look checkpoint-approved"
grep -q '^mepPhase: 4$' "$fresh_fx/.mep/prep/fresh-fx/04-iteration-roadmap.md" \
  || fail "doctor advanced fresh planning state"
pass "doctor does not synthesize phase approval"

# Invalid document nodes block routing instead of disappearing from the composed roster.
cat >"$fresh_fx/.mep/prep/fresh-fx/iterations/01.md" <<'MD'
# Iteration 1 — missing frontmatter
MD
rc=0
out=$(
  cd "$fresh_fx" && MEP_REPO_ROOT_OVERRIDE="$fresh_fx" "$MEP" where fresh-fx --json
) || rc=$?
[[ "$rc" == 2 ]] || fail "invalid document state exit 2 (got $rc)"
jq -e '
  .status == "blocked"
  and .reason == "invalid_document_state"
  and any(.findings[]; .kind == "missing_mep_iteration")
' <<<"$out" >/dev/null || fail "missing brief frontmatter must block routing"
pass "invalid brief state blocks rather than vanishing"

rm "$fresh_fx/.mep/prep/fresh-fx/iterations/01.md"
cat >"$fresh_fx/.mep/prep/fresh-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: fresh-fx
mepPhase: 4
mepPrepDocsBootstrapped: false
mepHandoffApproved: false
mepInitiativeStatus: active
mepCurrentIteration: null
mepOwnedPaths:
  - "src/**"
---

# Iteration roadmap — unsupported block-list fixture
MD
rc=0
out=$(
  cd "$fresh_fx" && MEP_REPO_ROOT_OVERRIDE="$fresh_fx" "$MEP" where fresh-fx --json
) || rc=$?
[[ "$rc" == 2 ]] || fail "unsupported block frontmatter exit 2 (got $rc)"
jq -e 'any(.findings[]; .kind == "invalid_mep_owned_paths")' <<<"$out" >/dev/null \
  || fail "unsupported block-list frontmatter must not become an empty scope"
pass "unsupported frontmatter shape blocks routing"

cat >"$fresh_fx/.mep/prep/fresh-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: fresh-fx
mepPhase: 4
mepPrepDocsBootstrapped: false
mepHandoffApproved: false
mepInitiativeStatus: active
mepCurrentIteration: null
---

# Iteration roadmap — missing owned paths fixture
MD
rc=0
MEP_REPO_ROOT_OVERRIDE="$fresh_fx" "$MEP" where fresh-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "missing owned paths exit 2 (got $rc)"
jq -e 'any(.findings[]; .kind == "invalid_mep_owned_paths")' "$tmp" >/dev/null \
  || fail "missing mepOwnedPaths must not become an empty scope"
pass "missing owned paths blocks routing"

cat >"$fresh_fx/.mep/prep/fresh-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: fresh-fx
mepPhase: 4
# missing closing delimiter
MD
rc=0
out=$(
  cd "$fresh_fx" && MEP_REPO_ROOT_OVERRIDE="$fresh_fx" "$MEP" where fresh-fx --json
) || rc=$?
[[ "$rc" == 2 ]] || fail "unterminated frontmatter exit 2 (got $rc)"
jq -e 'any(.findings[]; .kind == "invalid_frontmatter_block")' <<<"$out" >/dev/null \
  || fail "unterminated frontmatter must not claim document authority"
rc=0
MEP_REPO_ROOT_OVERRIDE="$fresh_fx" "$MEP" mode set fresh-fx manual --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "mode set invalid frontmatter exit 2 (got $rc)"
jq -e '
  .status == "blocked"
  and .reason == "invalid_document_state"
  and (.statePath | endswith("/04-iteration-roadmap.md"))
' "$tmp" >/dev/null \
  || fail "mode set must use composed document validity"
pass "unterminated frontmatter blocks routing"

# A failed brief write leaves the roadmap non-authoritative; rerunning completes the migration.
resume_fx="$TMP/resume_fx"
mkdir -p "$resume_fx/.mep/prep/resume-fx/iterations"
cat >"$resume_fx/.mep/prep/resume-fx/manifest.json" <<'JSON'
{
  "slug": "resume-fx",
  "phase": 5,
  "prepDocsBootstrapped": true,
  "currentIteration": 1,
  "iterations": [
    {"number":1,"title":"first","briefPath":".mep/prep/resume-fx/iterations/01.md","status":"committed"},
    {"number":2,"title":"second","briefPath":".mep/prep/resume-fx/iterations/02.md","status":"pending"}
  ]
}
JSON
printf '# roadmap\n' >"$resume_fx/.mep/prep/resume-fx/04-iteration-roadmap.md"
cat >"$resume_fx/.mep/prep/resume-fx/iterations/01.md" <<'MD'
---
mepIteration: 1
mepTitle: first
mepStatus: committed
---

# first
MD
cp "$resume_fx/.mep/prep/resume-fx/manifest.json" "$resume_fx/manifest.valid.json"
jq '.iterations[1].number = "oops"' "$resume_fx/manifest.valid.json" \
  >"$resume_fx/.mep/prep/resume-fx/manifest.json"
rc=0
MEP_REPO_ROOT_OVERRIDE="$resume_fx" "$MEP" migrate resume-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "invalid iteration migration exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_iteration_number" and .value == "oops"' "$tmp" >/dev/null \
  || fail "migration accepted an invalid iteration number"
mv "$resume_fx/manifest.valid.json" "$resume_fx/.mep/prep/resume-fx/manifest.json"
cat >"$resume_fx/.mep/prep/resume-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: resume-fx
---

# partial roadmap
MD
rc=0
MEP_REPO_ROOT_OVERRIDE="$resume_fx" "$MEP" migrate resume-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "incomplete roadmap migration exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "incomplete_roadmap_frontmatter"' "$tmp" >/dev/null \
  || fail "migration accepted incomplete roadmap authority"
[[ -f "$resume_fx/.mep/prep/resume-fx/manifest.json" ]] || fail "incomplete roadmap migration removed authority"
printf '# roadmap\n' >"$resume_fx/.mep/prep/resume-fx/04-iteration-roadmap.md"
printf '%s\n' '---' 'mepIteration: 2' >"$resume_fx/.mep/prep/resume-fx/iterations/02.md"
rc=0
MEP_REPO_ROOT_OVERRIDE="$resume_fx" "$MEP" migrate resume-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "malformed migration exit 2 (got $rc)"
jq -e '
  .status == "blocked"
  and .reason == "invalid_frontmatter_block"
  and .briefPath == ".mep/prep/resume-fx/iterations/02.md"
' "$tmp" >/dev/null || fail "migration must reject malformed brief frontmatter"
[[ -f "$resume_fx/.mep/prep/resume-fx/manifest.json" ]] || fail "malformed migration removed authority"
printf '# second\n' >"$resume_fx/.mep/prep/resume-fx/iterations/02.md"
git -C "$resume_fx" init -q -b main
git -C "$resume_fx" config user.email "mep@test"
git -C "$resume_fx" config user.name mep
git -C "$resume_fx" config commit.gpgsign false
git -C "$resume_fx" add -A
git -C "$resume_fx" commit -q -m "resumable migration fixture"
chmod 500 "$resume_fx/.mep/prep/resume-fx/iterations"
rc=0
MEP_REPO_ROOT_OVERRIDE="$resume_fx" "$MEP" migrate resume-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "partial migration exit 2 (got $rc)"
grep -q '^mepIteration: 1$' "$resume_fx/.mep/prep/resume-fx/iterations/01.md" \
  || fail "partial migration did not retain completed brief"
! grep -q '^---$' "$resume_fx/.mep/prep/resume-fx/04-iteration-roadmap.md" \
  || fail "partial migration claimed document authority"
chmod 700 "$resume_fx/.mep/prep/resume-fx/iterations"
MEP_REPO_ROOT_OVERRIDE="$resume_fx" "$MEP" migrate resume-fx --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .written == true and .briefsWritten == 1' "$tmp" >/dev/null \
  || fail "migration did not resume remaining briefs"
MEP_REPO_ROOT_OVERRIDE="$resume_fx" "$MEP" status resume-fx --compact --json >"$tmp" 2>"$err"
jq -e '.initiative.authority == "documents" and (.initiative.iterations | length) == 2' "$tmp" >/dev/null \
  || fail "resumed migration did not commit document authority"
pass "migration is resumable and flips authority last"

evidence_root="$TMP/evidence"
MEP_REPO_ROOT_OVERRIDE="$workflow_fx" MEP_HISTORY_ROOT_OVERRIDE="$evidence_root" \
  "$MEP" evidence write workflow-fx implement "done" --json --detail "fixture" --dry-run >"$tmp" 2>"$err"
jq -e '.status == "ok" and .dryRun == true and .written == false' "$tmp" >/dev/null || fail "evidence dry-run packet"
[[ ! -e "$evidence_root/evidence.jsonl" ]] || fail "evidence dry-run wrote ledger"
MEP_REPO_ROOT_OVERRIDE="$workflow_fx" MEP_HISTORY_ROOT_OVERRIDE="$evidence_root" \
  "$MEP" evidence write workflow-fx implement "done" --json --detail "fixture" >"$tmp" 2>"$err"
jq -e '.status == "ok" and .dryRun == false and .written == true' "$tmp" >/dev/null || fail "evidence write packet"
jq -e '.slug == "workflow-fx" and .kind == "implement" and .state == "done" and .detail == "fixture"' "$evidence_root/evidence.jsonl" >/dev/null || fail "evidence ledger row"
pass "evidence write dry-run and append"

rc=0
"$MEP" check scaffolding --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "check scaffolding --json no paths exit 0 (got $rc)"
jq -e '.status == "ok"' "$tmp" >/dev/null || fail "check scaffolding ok envelope"
pass "check scaffolding --json envelope"

rc=0
"$MEP" check scaffolding --product-code tools/mep/lib/registry.sh >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "check scaffolding implied json exit 0 (got $rc)"
jq -e '.status == "ok" and (.hits | length) == 0' "$tmp" >/dev/null || fail "check scaffolding implied json envelope"
pass "check scaffolding implied json envelope"

bash "$SRC/tools/mep/test/run-finish-scan.sh"
pass "finish-scan suite"

bash "$SRC/tools/mep/test/run-mark.sh"
pass "mark suite"

bash "$SRC/tools/mep/test/run-manual-workflow.sh"
pass "manual-workflow suite"

bash "$SRC/tools/mep/test/run-mode-resolver.sh"
pass "mode-resolver suite"

bash "$SRC/tools/mep/test/run-events.sh"
pass "events suite"

bash "$SRC/scripts/litmus/slice-boundary.sh" --executor stub
pass "slice-boundary litmus"

pass "run-unix-contract"
