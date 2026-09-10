#!/usr/bin/env bash
# @provisional — deterministic marker emission is new in the v0.1 workflow.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
MEP="$SRC/tools/mep/bin/mep"
[[ -x "$MEP" ]] || { printf 'not ok - missing %s\n' "$MEP" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

root="$TMP/mark-fx"
mkdir -p "$root/.mep/prep/mark-fx/iterations" "$root/src"
cat >"$root/.mep/prep/mark-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: mark-fx
mepPhase: 5
mepPrepDocsBootstrapped: true
mepInitiativeStatus: active
mepAuthorshipMode: default
mepCurrentIteration: 1
mepOwnedPaths: ["src/**", ".mep/prep/mark-fx/**"]
---

# Iteration roadmap — mark-fx
MD
cat >"$root/.mep/prep/mark-fx/iterations/01.md" <<'MD'
---
mepIteration: 1
mepTitle: Mark fixture
mepStatus: brief_ready
mepSliceType: behavioral
---

# Iteration 1 — Mark fixture

## File ownership

| file | slice op | zone | notes |
|------|----------|------|-------|
| `src/app.sh` | modify | domain | fixture |
| `src/decision.sh` | modify | domain | fixture |
MD
cat >"$root/src/app.sh" <<'SH'
#!/usr/bin/env bash
printf 'ok\n'
SH
cat >"$root/src/decision.sh" <<'SH'
# @finish:open — fixture decision
        --reason "mention @finish:open without a comment" \
SH
printf '{}\n' >"$root/src/data.json"

git -C "$root" init -q -b main
git -C "$root" config user.email mep@test
git -C "$root" config user.name mep
git -C "$root" config commit.gpgsign false
git -C "$root" add -A
git -C "$root" commit -q -m "mark fixture"

run_mep() {
  MEP_REPO_ROOT_OVERRIDE="$root" "$MEP" "$@"
}

out="$TMP/out"
err="$TMP/err"
before=$(git -C "$root" hash-object src/app.sh)
mode_before=$(stat -c '%a' "$root/src/app.sh")

run_mep mark mise src/app.sh --json --dry-run >"$out" 2>"$err"
jq -e '
  .status == "ok"
  and .operation == "mise"
  and .dryRun == true
  and .written == false
  and .commentStyle == "hash"
' "$out" >/dev/null || fail "mise dry-run packet"
[[ "$(git -C "$root" hash-object src/app.sh)" == "$before" ]] || fail "mise dry-run mutated file"
pass "mise dry-run is non-mutating"

run_mep mark mise src/app.sh --json >"$out" 2>"$err"
jq -e '
  .status == "ok"
  and .operation == "mise"
  and .dryRun == false
  and .written == true
  and .commentStyle == "hash"
' "$out" >/dev/null || fail "mise write packet"
[[ "$(head -n 1 "$root/src/app.sh")" == "#!/usr/bin/env bash" ]] || fail "mise preserves shebang"
[[ "$(sed -n '2p' "$root/src/app.sh")" == "# @mise" ]] || fail "mise opens after shebang"
[[ "$(tail -n 1 "$root/src/app.sh")" == "# @mise:end" ]] || fail "mise closes file"
[[ "$(stat -c '%a' "$root/src/app.sh")" == "$mode_before" ]] || fail "mise preserves file mode"
pass "mise wraps whole shell file"

wrapped=$(git -C "$root" hash-object src/app.sh)
run_mep mark mise src/app.sh --json >"$out" 2>"$err"
jq -e '.status == "ok" and .written == false' "$out" >/dev/null || fail "mise retry packet"
[[ "$(git -C "$root" hash-object src/app.sh)" == "$wrapped" ]] || fail "mise retry changed file"
pass "mise retry is idempotent"

run_mep finish scan mark-fx --json >"$out" 2>"$err"
jq -e '
  .counts == {total:1,open:1,done:0,ratified:0}
  and .markers[0].path == "src/decision.sh"
' "$out" >/dev/null || fail "finish scan ignores mise and flag mention"
pass "finish scan keeps marker axes separate"

rc=0
run_mep commit scope mark-fx --json >"$out" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "default commit scope exit 2 with open finish (got $rc)"
jq -e '.status == "blocked" and .reason == "finish_open"' "$out" >/dev/null || fail "default commit scope blocks open finish"
pass "default commit scope blocks open finish"

decision_before=$(git -C "$root" hash-object src/decision.sh)
run_mep mark finish src/decision.sh --state "done" --json --dry-run >"$out" 2>"$err"
jq -e '
  .status == "ok"
  and .operation == "finish"
  and .from == "open"
  and .to == "done"
  and .dryRun == true
  and .written == false
' "$out" >/dev/null || fail "finish dry-run packet"
[[ "$(git -C "$root" hash-object src/decision.sh)" == "$decision_before" ]] || fail "finish dry-run mutated file"
pass "finish dry-run is non-mutating"

run_mep mark finish src/decision.sh --state "done" --json >"$out" 2>"$err"
jq -e '.status == "ok" and .from == "open" and .to == "done" and .written == true' "$out" >/dev/null \
  || fail "finish open to done packet"
run_mep finish scan mark-fx --json >"$out" 2>"$err"
jq -e '.counts == {total:1,open:0,done:1,ratified:0}' "$out" >/dev/null \
  || fail "finish scan follows done write"
pass "finish advances open to done"

done_hash=$(git -C "$root" hash-object src/decision.sh)
run_mep mark finish src/decision.sh --state "done" --json >"$out" 2>"$err"
jq -e '.status == "ok" and .from == "done" and .to == "done" and .written == false' "$out" >/dev/null \
  || fail "finish retry packet"
[[ "$(git -C "$root" hash-object src/decision.sh)" == "$done_hash" ]] || fail "finish retry changed file"
pass "finish retry is idempotent"

run_mep mark finish src/decision.sh --state ratified --json >"$out" 2>"$err"
jq -e '.status == "ok" and .from == "done" and .to == "ratified" and .written == true' "$out" >/dev/null \
  || fail "finish done to ratified packet"
run_mep finish scan mark-fx --json >"$out" 2>"$err"
jq -e '.counts == {total:1,open:0,done:0,ratified:1}' "$out" >/dev/null \
  || fail "finish scan follows ratified write"
pass "finish advances done to ratified"

rc=0
run_mep mark finish src/decision.sh --state "done" --json >"$out" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "finish state regression exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "finish_state_regression"' "$out" >/dev/null \
  || fail "finish state regression packet"
pass "finish state cannot regress"

rc=0
run_mep mark finish src/decision.sh --state guessed --json >"$out" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "invalid finish state exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_finish_state"' "$out" >/dev/null \
  || fail "invalid finish state packet"
pass "invalid finish state fails closed"

rc=0
run_mep mark mise src/data.json --json >"$out" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "unsupported comment syntax exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "unsupported_comment_syntax"' "$out" >/dev/null \
  || fail "unsupported comment syntax packet"
pass "unsupported comment syntax fails closed"

outside="$TMP/outside"
mkdir -p "$outside"
printf '# external\n' >"$outside/external.sh"
ln -s "$outside" "$root/escape"
rc=0
run_mep mark mise escape/external.sh --json >"$out" 2>"$err" || rc=$?
[[ "$rc" == 2 ]] || fail "symlink escape exit 2 (got $rc)"
jq -e '.status == "blocked" and .reason == "invalid_mark_path"' "$out" >/dev/null \
  || fail "symlink escape packet"
[[ "$(cat "$outside/external.sh")" == "# external" ]] || fail "symlink escape mutated external file"
pass "mark path cannot escape repository"

pass "run-mark"
