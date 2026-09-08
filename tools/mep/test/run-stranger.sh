#!/usr/bin/env bash
# @provisional — defaults suite is the self-host boundary. Stranger CI: temp git
# root, no host .mep/config, engine storage defaults, fixture-demo only.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
MEP="$SRC/tools/mep/bin/mep"
[[ -x "$MEP" ]] || { echo "not ok - missing $MEP" >&2; exit 1; }
[[ -d "$SRC/.mep/prep/fixture-demo" ]] || { echo "not ok - missing .mep/prep/fixture-demo" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/tools" "$TMP/.mep/prep"
cp -a "$SRC/tools/mep" "$TMP/tools/mep"
cp -a "$SRC/.mep/prep/fixture-demo" "$TMP/.mep/prep/fixture-demo"
# no .mep/config — engine defaults

cd "$TMP"
git init -q -b main
git config user.email "mep@test"
git config user.name "mep"
git config commit.gpgsign false
git add -A
git commit -q -m "stranger fixture"

export MEP_REPO_ROOT_OVERRIDE="$TMP"
unset MEP_HISTORY_ROOT_OVERRIDE || true

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

assert_jq() {
  local expr=$1 input=$2 label=$3
  printf '%s' "$input" | jq -e "$expr" >/dev/null || fail "$label"
  pass "$label"
}

dump=$("$MEP" config dump --json)
printf '%s' "$dump" | jq -e '.storage.prepRoot == "wiki/prep"' >/dev/null && fail "must not inherit wiki/prep overlay"
printf '%s' "$dump" | jq -e '.profile.active != "default"' >/dev/null && fail "must not inherit a host profile overlay"
assert_jq '.storage.prepRoot == ".mep/prep" and .runtime.adapter == "plain" and .profile.active == "default" and .vcs.defaultTrunk == "main"' "$dump" "engine defaults without overlay"

where=$("$MEP" where fixture-demo --json)
assert_jq '
  .status == "ok"
  and .executionRequest == .proof.executionRequest
  and .executionRequest == {
    kind: "implement",
    target: ".mep/prep/fixture-demo/iterations/01-ready.md",
    argv: [".mep/prep/fixture-demo/iterations/01-ready.md"]
  }
' "$where" "where fixture-demo durable execution request"

pass "run-stranger"
