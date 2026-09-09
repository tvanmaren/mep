#!/usr/bin/env bash
# @provisional — @finish:open cannot look committable in any authorship mode.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
MEP="$SRC/tools/mep/bin/mep"
[[ -x "$MEP" ]] || { printf 'not ok - missing %s\n' "$MEP" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

root="$TMP/manual-fx"
mkdir -p "$root/.mep/prep/manual-fx/iterations" "$root/src"
cat >"$root/.mep/prep/manual-fx/manifest.json" <<'EOF'
{
  "slug": "manual-fx",
  "schemaVersion": 1,
  "framework": "mise-en-place",
  "phase": 5,
  "prepDocsBootstrapped": true,
  "initiativeStatus": "active",
  "currentIteration": 1,
  "ownedPaths": ["src/**", ".mep/prep/manual-fx/**"],
  "iterations": [{
    "number": 1,
    "title": "Manual fixture",
    "briefPath": ".mep/prep/manual-fx/iterations/01.md",
    "status": "brief_ready",
    "sliceType": "behavioral"
  }]
}
EOF
cat >"$root/.mep/prep/manual-fx/iterations/01.md" <<'MD'
# Iteration 1 — Manual fixture

**Status:** brief_ready

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `src/app.sh` | modify | domain | fixture |
MD
cat >"$root/src/app.sh" <<'EOF'
# @finish:open — fixture decision
printf 'ok\n'
EOF

git -C "$root" init -q -b main
git -C "$root" config user.email mep@test
git -C "$root" config user.name mep
git -C "$root" config commit.gpgsign false
git -C "$root" add -A
git -C "$root" commit -q -m "manual workflow fixture"

history="$TMP/history"
mkdir -p "$history"
run_mep() {
  MEP_REPO_ROOT_OVERRIDE="$root" MEP_HISTORY_ROOT_OVERRIDE="$history" "$MEP" "$@"
}

tmp="$TMP/out"
err="$TMP/err"

assert_where_blocks_open_finish() {
  local label=$1
  run_mep where manual-fx --json >"$tmp" 2>"$err"
  jq -e '
    .status == "ok"
    and .row == 8
    and .executionRequest.kind == "implement"
    and .proof.facts.evidence.finishState == "open"
  ' "$tmp" >/dev/null || {
    printf 'where=%s\n' "$(cat "$tmp")" >&2
    fail "$label where must route to open finish"
  }
  pass "$label where routes to open finish"
}

assert_lifecycle_blocks_open_finish() {
  local label=$1 mode=$2 asks=$3 gate=$4 action=$5 rc=0
  run_mep lifecycle status manual-fx --mode "$mode" --json >"$tmp" 2>"$err" || rc=$?
  [[ "$rc" == 2 ]] || fail "$label lifecycle exit 2 (got $rc)"
  jq -e \
    --argjson asks "$asks" \
    --arg gate "$gate" \
    --arg action "$action" '
      .status == "blocked"
      and .asksUserMidSlice == $asks
      and ([.gates[] | select(.kind == "finish_open" and .gate == $gate and .action == $action)] | length) == 1
    ' "$tmp" >/dev/null || {
    printf 'lifecycle=%s\n' "$(cat "$tmp")" >&2
    fail "$label lifecycle blocks on open finish"
  }
  pass "$label lifecycle blocks on open finish"
}

assert_checkpoint_blocks_open_finish() {
  local label=$1 rc=0
  run_mep checkpoint manual-fx --json >"$tmp" 2>"$err" || rc=$?
  [[ "$rc" == 2 ]] || fail "$label checkpoint exit 2 (got $rc)"
  jq -e '
    .status == "blocked"
    and ([.findings[] | select(.kind == "finish_writebacks_block_checkpoint") | .blockers[]? | select(.kind == "finish_open")] | length) == 1
  ' "$tmp" >/dev/null || fail "$label checkpoint blocks on open finish"
  pass "$label checkpoint blocks on open finish"
}

assert_commit_scope_blocks_open_finish() {
  local label=$1 rc=0
  run_mep commit scope manual-fx --json >"$tmp" 2>"$err" || rc=$?
  [[ "$rc" == 2 ]] || fail "$label commit scope exit 2 (got $rc)"
  jq -e '.status == "blocked" and .reason == "finish_open"' "$tmp" >/dev/null || {
    printf 'commit-scope=%s\n' "$(cat "$tmp")" >&2
    fail "$label commit scope blocks on open finish"
  }
  pass "$label commit scope blocks on open finish"
}

assert_where_blocks_open_finish "absent-mode"
assert_lifecycle_blocks_open_finish "absent-mode/default-policy" default true human author_open_finish
assert_commit_scope_blocks_open_finish "absent-mode"
assert_checkpoint_blocks_open_finish "absent-mode"

run_mep mode set manual-fx default --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .authorshipMode == "default"' "$tmp" >/dev/null || fail "mode set default"
git -C "$root" add .mep/prep/manual-fx/manifest.json
git -C "$root" commit -q -m "set default mode"

assert_where_blocks_open_finish "default"
assert_lifecycle_blocks_open_finish "default" default true human author_open_finish
assert_commit_scope_blocks_open_finish "default"
assert_checkpoint_blocks_open_finish "default"

run_mep mode set manual-fx manual --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .authorshipMode == "manual"' "$tmp" >/dev/null || fail "mode set manual"
git -C "$root" add .mep/prep/manual-fx/manifest.json
git -C "$root" commit -q -m "set manual mode"

assert_where_blocks_open_finish "manual"
assert_lifecycle_blocks_open_finish "manual" manual true human author_open_finish
assert_commit_scope_blocks_open_finish "manual"
assert_checkpoint_blocks_open_finish "manual"

printf '# @finish:done — fixture decision\nprintf '"'"'ok\\n'"'"'\n' >"$root/src/app.sh"

rc=0
run_mep commit scope manual-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "manual commit scope after done exit 0 (got $rc)"
jq -e '.status == "ok" and ((.reason // "") != "finish_open")' "$tmp" >/dev/null || fail "manual commit scope clears finish_open"
pass "manual commit scope clears after done"

rc=0
run_mep lifecycle status manual-fx --mode manual --json >"$tmp" 2>"$err" || rc=$?
jq -e '[.gates[]? | select(.kind == "finish_open")] | length == 0' "$tmp" >/dev/null || {
  printf 'lifecycle-done=%s\n' "$(cat "$tmp")" >&2
  fail "lifecycle drops finish_open after done"
}
pass "lifecycle drops finish_open after done"

rc=0
run_mep checkpoint manual-fx --json >"$tmp" 2>"$err" || rc=$?
jq -e '[.findings[]? | .blockers[]? | select(.kind == "finish_open")] | length == 0' "$tmp" >/dev/null || {
  printf 'checkpoint-done=%s\n' "$(cat "$tmp")" >&2
  fail "checkpoint drops finish_open after done"
}
pass "checkpoint drops finish_open after done"

cat >"$root/src/app.sh" <<'EOF'
# @finish:open — fixture decision
printf 'ok\n'
EOF

run_mep mode set manual-fx autopilot --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .authorshipMode == "autopilot"' "$tmp" >/dev/null || fail "mode set autopilot"
git -C "$root" add .mep/prep/manual-fx/manifest.json
git -C "$root" commit -q -m "set autopilot mode"

assert_where_blocks_open_finish "autopilot"
assert_lifecycle_blocks_open_finish "autopilot" autopilot false proxy dispatch_proxy_finish_author
assert_commit_scope_blocks_open_finish "autopilot"
assert_checkpoint_blocks_open_finish "autopilot"

cat >"$root/src/app.sh" <<'EOF'
# @finish:done — fixture decision
printf 'ok\n'
EOF

rc=0
run_mep commit scope manual-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "autopilot commit scope after done exit 0 (got $rc)"
jq -e '.status == "ok" and ((.reason // "") != "finish_open")' "$tmp" >/dev/null || fail "autopilot commit scope clears finish_open"
pass "autopilot commit scope clears after done"

rc=0
run_mep lifecycle status manual-fx --mode autopilot --json >"$tmp" 2>"$err" || rc=$?
jq -e '[.gates[]? | select(.kind == "finish_open")] | length == 0' "$tmp" >/dev/null || {
  printf 'autopilot-lifecycle-done=%s\n' "$(cat "$tmp")" >&2
  fail "autopilot lifecycle drops finish_open after done"
}
pass "autopilot lifecycle drops finish_open after done"

rc=0
run_mep checkpoint manual-fx --json >"$tmp" 2>"$err" || rc=$?
jq -e '[.findings[]? | .blockers[]? | select(.kind == "finish_open")] | length == 0' "$tmp" >/dev/null || {
  printf 'autopilot-checkpoint-done=%s\n' "$(cat "$tmp")" >&2
  fail "checkpoint drops finish_open after done in autopilot"
}
pass "checkpoint drops finish_open after done in autopilot"

pass "run-manual-workflow"
