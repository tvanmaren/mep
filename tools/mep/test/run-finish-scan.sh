#!/usr/bin/env bash
# Finish-scan counts language comments, not bash --flags.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
MEP="$SRC/tools/mep/bin/mep"
[[ -x "$MEP" ]] || { printf 'not ok - missing %s\n' "$MEP" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

if rg -n --glob '*.sh' 'rg[^\n]*@finish:' "$SRC/tools/mep/lib/resolver.sh" >/dev/null; then
  fail "resolver must not grow a second @finish grep"
fi
pass "row 8 uses finish helper"

root="$TMP/finish-scan-fixture"
mkdir -p "$root/.mep/prep/finish-scan-fixture/iterations" "$root/src"
cat >"$root/.mep/prep/finish-scan-fixture/04-iteration-roadmap.md" <<'MD'
---
mepSlug: finish-scan-fixture
mepPhase: 5
mepPrepDocsBootstrapped: true
mepAuthorshipMode: default
mepCurrentIteration: 1
mepOwnedPaths: ["src/**"]
---

# Iteration roadmap — finish-scan-fixture
MD
cat >"$root/.mep/prep/finish-scan-fixture/iterations/01.md" <<'MD'
---
mepIteration: 1
mepStatus: brief_ready
mepSliceType: behavioral
---

# Iteration 1 — finish scan
MD
cat >"$root/src/flags.sh" <<'EOF'
        --reason "owned paths contain @finish:open" \
EOF
cat >"$root/src/hash.sh" <<'EOF'
# @finish:open — golden decision
EOF
cat >"$root/src/sql.sh" <<'EOF'
-- @finish:done — sql comment
EOF
git -C "$root" init -q -b main
git -C "$root" config user.email mep@test
git -C "$root" config user.name mep
git -C "$root" config commit.gpgsign false
git -C "$root" add -A
git -C "$root" commit -q -m "finish-scan fixture"

err="$TMP/err"
rc=0
out=$(cd "$root" && MEP_REPO_ROOT_OVERRIDE="$root" "$MEP" finish scan finish-scan-fixture --json 2>"$err") || rc=$?
[[ "$rc" == 0 ]] || fail "finish scan exit 0 (got $rc)"
[[ ! -s "$err" ]] || fail "finish scan stderr empty"
jq -en --argjson packet "$out" '
  $packet.status == "ok"
  and $packet.counts.open == 1
  and $packet.counts.done == 1
  and $packet.counts.total == 2
  and ([ $packet.markers[] | select(.state == "open") | .path ] | unique) == ["src/hash.sh"]
  and ([ $packet.markers[] | select(.state == "done") | .path ] | unique) == ["src/sql.sh"]
  and ([ $packet.markers[] | .path ] | index("src/flags.sh")) == null
' >/dev/null || {
  printf 'actual=%s\n' "$out" >&2
  fail "flag line ignored; # open and -- comment counted"
}
pass "flag line ignored; # open and -- comment counted"

pass "run-finish-scan"
