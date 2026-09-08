#!/usr/bin/env bash
# @provisional — manual + @finish:open cannot look committable.
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
  "authorshipMode": "default",
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

rc=0
run_mep commit scope manual-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 0 ]] || fail "default commit scope exit 0 (got $rc)"
jq -e '.status == "ok"' "$tmp" >/dev/null || fail "default commit scope stays ok with open finish"
pass "default commit scope ignores open finish"

run_mep mode set manual-fx manual --json >"$tmp" 2>"$err"
jq -e '.status == "ok" and .authorshipMode == "manual"' "$tmp" >/dev/null || fail "mode set manual"

rc=0
run_mep lifecycle status manual-fx --mode manual --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "manual lifecycle exit 2 (got $rc)"
jq -e '
  .status == "blocked"
  and .asksUserMidSlice == true
  and ([.gates[] | select(.kind == "finish_open" and .action == "author_open_finish")] | length) == 1
' "$tmp" >/dev/null || {
  printf 'lifecycle=%s\n' "$(cat "$tmp")" >&2
  fail "manual lifecycle finish_open gate"
}
pass "manual lifecycle blocks on finish_open"

rc=0
run_mep commit scope manual-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "manual commit scope exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "finish_open"' "$tmp" >/dev/null || {
  printf 'commit-scope=%s\n' "$(cat "$tmp")" >&2
  fail "manual commit scope blocked on finish_open"
}
pass "manual commit scope blocks on finish_open"

rc=0
run_mep checkpoint manual-fx --json >"$tmp" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "checkpoint exit 2 with open finish (got $rc)"
jq -e '
  .status == "blocked"
  and ([.findings[] | select(.kind == "finish_writebacks_block_checkpoint")] | length) == 1
  and ([.findings[] | select(.kind == "finish_writebacks_block_checkpoint") | .blockers[]? | select(.kind == "finish_open")] | length) == 1
' "$tmp" >/dev/null || {
  printf 'checkpoint=%s\n' "$(cat "$tmp")" >&2
  fail "checkpoint still blocked on finish_open"
}
pass "checkpoint still blocked on finish_open"

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

pass "run-manual-workflow"
