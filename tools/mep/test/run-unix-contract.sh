#!/usr/bin/env bash
# Unix command-contract suite: exit map + stderr discipline. FOSS only.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
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
    kind: "implement",
    target: ".mep/prep/fixture-demo/iterations/01-ready.md",
    argv: [".mep/prep/fixture-demo/iterations/01-ready.md"]
  }
  and (.nextCommand | startswith("/implement-plan "))
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
  and .result == {kind:"stub",accepted:true,primitive:"mep implement"}
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
mkdir -p "$route_fx/.mep/prep/commit-prep-fx"
cat >"$route_fx/.mep/prep/commit-prep-fx/manifest.json" <<'JSON'
{
  "slug": "commit-prep-fx",
  "schemaVersion": 1,
  "framework": "mise-en-place",
  "phase": 5,
  "phaseApproved": {"1": true, "2": true, "3": true, "4": true, "5": true},
  "initiativeStatus": "active",
  "prepDocsBootstrapped": false,
  "currentIteration": 1,
  "ownedPaths": [".mep/prep/commit-prep-fx/**"],
  "iterations": [{"number": 1, "title": "Bootstrap fixture", "briefPath": ".mep/prep/commit-prep-fx/iterations/01.md", "status": "pending", "sliceType": "behavioral"}]
}
JSON
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
mkdir -p "$fx/.mep/prep/desync-fx"
cat >"$fx/.mep/prep/desync-fx/manifest.json" <<'JSON'
{
  "slug": "desync-fx",
  "schemaVersion": 1,
  "framework": "mise-en-place",
  "phase": 5,
  "phaseApproved": {"1": true, "2": true, "3": true, "4": true, "5": true},
  "initiativeStatus": "active",
  "prepDocsBootstrapped": true,
  "currentIteration": 1,
  "ownedPaths": [".mep/prep/desync-fx/**"],
  "iterations": [{"number": 1, "title": "Desync fixture", "briefPath": ".mep/prep/desync-fx/iterations/01.md", "status": "committed", "sliceType": "behavioral"}]
}
JSON
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

MEP_REPO_ROOT_OVERRIDE="$workflow_fx" "$MEP" mode set workflow-fx manual --json --dry-run >"$tmp" 2>"$err"
jq -e '.status == "ok" and .authorshipMode == "manual" and .dryRun == true and .written == false' "$tmp" >/dev/null || fail "mode dry-run packet"
jq -e '.authorshipMode == "default"' "$workflow_fx/.mep/prep/workflow-fx/manifest.json" >/dev/null || fail "mode dry-run mutated manifest"
MEP_REPO_ROOT_OVERRIDE="$workflow_fx" "$MEP" mode set workflow-fx manual --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .dryRun == false and .written == true' "$tmp" >/dev/null || fail "mode write packet"
jq -e '.authorshipMode == "manual"' "$workflow_fx/.mep/prep/workflow-fx/manifest.json" >/dev/null || fail "mode write missed manifest"
if git -C "$workflow_fx" diff --summary | grep -q 'mode change'; then
  fail "mode write changed manifest permissions"
fi
pass "mode set dry-run and write"

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

bash "$SRC/scripts/litmus/slice-boundary.sh" --executor stub
pass "slice-boundary litmus"

pass "run-unix-contract"
