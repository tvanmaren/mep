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

tmp=$(mktemp)
err=$(mktemp)
trap 'rm -f "$tmp" "$err"' EXIT

rc=0
mep_require __mep_no_such_dep__ >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "mep_require missing_dependency return 2 (got $rc)"
jq -e '.status == "missing_dependency"' "$tmp" >/dev/null || fail "missing_dependency packet"
pass "missing_dependency packet exit 2"

# registry feeds help
mep_registry_print | grep -q $'^where\t' || fail "registry has where"
pass "registry lists where"

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
pass "config dump envelope exit 0"

rc=0
"$MEP" where fixture-demo --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "where fixture-demo exit 0 (got $rc)"
[[ ! -s "$err" ]] || fail "where success stderr empty"
jq -e '.status == "ok"' "$tmp" >/dev/null || fail "where status ok"
jq -e 'has("executionRequest") | not' "$tmp" >/dev/null || fail "no executionRequest"
pass "where fixture-demo envelope exit 0"

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

hist=$(mktemp -d)
mkdir -p "$hist/events.jsonl"
rc=0
MEP_HISTORY_ROOT_OVERRIDE=$hist "$MEP" events tail --json >"$tmp" 2>"$err" || rc=$?
rm -rf "$hist"
[[ "$rc" == 3 ]] || fail "events ledger not a file exit 3 (got $rc)"
jq -e '.status == "not_found" and .reason == "invalid_ledger"' "$tmp" >/dev/null || fail "events ledger-not-file packet"
pass "events ledger not a file not_found exit 3"

hist=$(mktemp -d)
printf 'not-json\n' >"$hist/events.jsonl"
rc=0
MEP_HISTORY_ROOT_OVERRIDE=$hist "$MEP" events tail --json >"$tmp" 2>"$err" || rc=$?
rm -rf "$hist"
[[ "$rc" == 2 ]] || fail "events malformed ledger exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_ledger"' "$tmp" >/dev/null || fail "events invalid_ledger blocked packet"
pass "events malformed ledger blocked exit 2"

prof=$(mktemp -d)
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
rm -rf "$prof"
[[ "$rc" == 2 ]] || fail "profile invalid seed exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_profile_seed"' "$tmp" >/dev/null || fail "profile invalid seed packet"
pass "profile seed not_found / blocked"

rc=0
"$MEP" profile dump --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "repo profile dump exit 0 (got $rc)"
jq -e '.status == "ok" and .profile.active == "default"' "$tmp" >/dev/null || fail "repo profile seed ok"
pass "repo profile dump ok"

fx=$(mktemp -d)
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
rm -rf "$fx"
printf '%s\n' "$out" >"$tmp"
[[ "$rc" == 1 ]] || fail "doctor desync fixture exit 1 (got $rc)"
jq -e '.status == "desync"' "$tmp" >/dev/null || fail "doctor desync fixture packet"
pass "doctor desync fixture exit 1"

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

pass "run-unix-contract"
