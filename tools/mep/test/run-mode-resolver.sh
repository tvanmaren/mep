#!/usr/bin/env bash
# @provisional — unblocked where packets stay identical across authorship modes.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
MEP="$SRC/tools/mep/bin/mep"
[[ -x "$MEP" ]] || { printf 'not ok - missing %s\n' "$MEP" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

root="$TMP/mode-fx"
mkdir -p "$root/.mep/prep/mode-fx/iterations" "$root/src"
cat >"$root/.mep/prep/mode-fx/iterations/01.md" <<'MD'
# Iteration 1 — Unblocked fixture

**Status:** brief_ready
MD
printf '# fixture\n' >"$root/src/app.sh"
jq -n '{
  slug: "mode-fx",
  schemaVersion: 1,
  framework: "mise-en-place",
  phase: 5,
  phaseApproved: {"1":true,"2":true,"3":true,"4":true,"5":true},
  initiativeStatus: "active",
  prepDocsBootstrapped: true,
  currentIteration: 1,
  ownedPaths: ["src/**", ".mep/prep/mode-fx/**"],
  iterations: [{
    number: 1,
    title: "Unblocked fixture",
    briefPath: ".mep/prep/mode-fx/iterations/01.md",
    status: "brief_ready",
    sliceType: "behavioral"
  }]
}' >"$root/.mep/prep/mode-fx/manifest.json"

git -C "$root" init -q -b main
git -C "$root" config user.email mep@test
git -C "$root" config user.name mep
git -C "$root" config commit.gpgsign false
git -C "$root" add -A
git -C "$root" commit -q -m "unblocked where fixture"

history="$TMP/history"
mkdir -p "$history"
run_mep() {
  MEP_REPO_ROOT_OVERRIDE="$root" MEP_HISTORY_ROOT_OVERRIDE="$history" "$MEP" "$@"
}

packet_key() {
  jq -c '{row: .proof.row, executionRequest}'
}

where_key() {
  local label=$1 out
  out=$(run_mep where mode-fx --json) || fail "$label where exit 0"
  jq -en --argjson packet "$out" '
    $packet.status == "ok"
    and $packet.proof.row == 7
    and $packet.executionRequest.kind == "implement"
    and ($packet.executionRequest | keys | sort) == ["argv", "kind", "target"]
  ' >/dev/null || {
    printf 'where=%s\n' "$out" >&2
    fail "$label unblocked implement packet"
  }
  packet_key <<<"$out"
}

baseline=$(where_key "absent-mode")
pass "absent-mode unblocked where"

for mode in default manual autopilot; do
  run_mep mode set mode-fx "$mode" --json >/dev/null || fail "mode set $mode"
  git -C "$root" add .mep/prep/mode-fx/manifest.json
  git -C "$root" commit -q -m "set $mode mode"
  got=$(where_key "$mode")
  [[ "$got" == "$baseline" ]] || {
    printf 'baseline=%s\ngot=%s\n' "$baseline" "$got" >&2
    fail "$mode where packet differs from absent-mode"
  }
  pass "$mode where packet matches absent-mode"
done

pass "run-mode-resolver"
