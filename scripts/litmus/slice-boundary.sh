#!/usr/bin/env bash
# @stable — public unix-compliance gate: compose registry verbs through --executor stub.
set -euo pipefail

usage() {
  printf 'usage: scripts/litmus/slice-boundary.sh --executor stub\n' >&2
  exit 64
}

executor=
while [[ $# -gt 0 ]]; do
  case "$1" in
    --executor)
      [[ $# -ge 2 ]] || usage
      executor=$2
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      usage
      ;;
  esac
done

[[ -n "$executor" ]] || usage
[[ "$executor" == stub ]] || {
  printf 'slice-boundary: only --executor stub is allowed in this gate\n' >&2
  exit 2
}

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
SRC_MEP="$ROOT/tools/mep"
FIXTURE="$ROOT/.mep/prep/fixture-demo"
[[ -x "$SRC_MEP/bin/mep" ]] || { printf 'not ok - missing %s\n' "$SRC_MEP/bin/mep" >&2; exit 1; }
[[ -d "$FIXTURE" ]] || { printf 'not ok - missing %s\n' "$FIXTURE" >&2; exit 1; }

command -v jq >/dev/null || { printf 'not ok - jq required\n' >&2; exit 1; }
command -v git >/dev/null || { printf 'not ok - git required\n' >&2; exit 1; }

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/tools" "$TMP/.mep/prep"
cp -a "$SRC_MEP" "$TMP/tools/mep"
cp -a "$FIXTURE" "$TMP/.mep/prep/fixture-demo"

cd "$TMP"
git init -q -b main
git config user.email "mep@test"
git config user.name "mep"
git config commit.gpgsign false
git add -A
git commit -q -m "litmus fixture"

export MEP_REPO_ROOT_OVERRIDE="$TMP"
unset MEP_HISTORY_ROOT_OVERRIDE || true
MEP="$TMP/tools/mep/bin/mep"
SLUG=fixture-demo

run_mep() {
  local label=$1 expected_status=$2 expected_rc=$3
  shift 3
  local out err rc=0 st
  err=$(mktemp "$TMP/err.XXXXXX")
  out=$("$MEP" "$@" 2>"$err") || rc=$?
  printf '%s' "$out" | jq -e 'type == "object" and (.status | type == "string")' >/dev/null \
    || fail "$label stdout json"
  st=$(printf '%s' "$out" | jq -r '.status')
  [[ "$st" == "$expected_status" ]] || fail "$label status=$st expected=$expected_status"
  [[ "$rc" == "$expected_rc" ]] || fail "$label C7 status=$st exit=$rc expected=$expected_rc"
  [[ ! -s "$err" ]] || fail "$label stderr empty on envelope"
  printf '%s' "$out"
}

migration=$(run_mep "migrate" ok 0 migrate "$SLUG" --json)
printf '%s' "$migration" | jq -e '.written == true and .legacyRemoved == true' >/dev/null \
  || fail "migrate legacy fixture"
git add -A
git commit -q -m "migrate litmus fixture"
pass "migrate"

where=$(run_mep "where" ok 0 where "$SLUG" --json)
printf '%s' "$where" | jq -e '
  .status == "ok"
  and (.executionRequest | type == "object")
  and (.executionRequest | keys | sort) == ["argv", "kind", "target"]
' >/dev/null || fail "where executionRequest shape"
pass "where"

request=$(printf '%s' "$where" | jq -c '.executionRequest')
dispatch=$(printf '%s\n' "$request" | run_mep "exec dispatch" ok 0 exec dispatch --json --executor stub)
printf '%s' "$dispatch" | jq -e --argjson request "$request" '
  .status == "ok"
  and .executor == "stub"
  and .executionRequest == $request
  and .result.kind == "stub"
' >/dev/null || fail "dispatch stub packet"
pass "exec dispatch --executor stub"

evidence=$(run_mep "evidence write" ok 0 evidence write "$SLUG" prep "done" --json --detail litmus --dry-run)
printf '%s' "$evidence" | jq -e '.status == "ok" and .dryRun == true' >/dev/null \
  || fail "evidence write dry-run"
pass "evidence write"

scope=$(run_mep "commit scope" ok 0 commit scope "$SLUG" --json)
printf '%s' "$scope" | jq -e '.status == "ok"' >/dev/null || fail "commit scope packet"
pass "commit scope"

# fixture-demo stays brief_ready / not landed in this temp tree, so checkpoint reports desync/1.
checkpoint=$(run_mep "checkpoint" desync 1 checkpoint "$SLUG" --json)
printf '%s' "$checkpoint" | jq -e '.status == "desync" and .blockerCount == 0' >/dev/null \
  || fail "checkpoint desync without blockers"
pass "checkpoint"

where2=$(run_mep "where again" ok 0 where "$SLUG" --json)
printf '%s' "$where2" | jq -e '.status == "ok" and (.executionRequest | type == "object")' >/dev/null \
  || fail "where again"
pass "where again"

pass "slice-boundary --executor stub"
