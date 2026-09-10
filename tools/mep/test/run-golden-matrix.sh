#!/usr/bin/env bash
# Golden proof for resolver rows, first-match precedence, and executionRequest parity.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
MEP="$SRC/tools/mep/bin/mep"
[[ -x "$MEP" ]] || { printf 'not ok - missing %s\n' "$MEP" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

set_frontmatter() {
  local file=$1 key=$2 value=$3 tmp
  tmp="${file}.tmp"
  awk -v key="$key" -v value="$value" '
    index($0, key ":") == 1 { print key ": " value; next }
    { print }
  ' "$file" >"$tmp"
  mv "$tmp" "$file"
}

new_case() {
  local slug=$1 phase=$2 bootstrapped=$3 status=$4 slice_type=$5 initiative_status=$6
  local root="$TMP/$slug"
  mkdir -p "$root/.mep/prep/$slug/iterations" "$root/src"
  cat >"$root/.mep/prep/$slug/04-iteration-roadmap.md" <<EOF
---
mepSlug: $slug
mepPhase: $phase
mepPrepDocsBootstrapped: $bootstrapped
mepHandoffApproved: false
mepInitiativeStatus: $initiative_status
mepAuthorshipMode: default
mepCurrentIteration: 1
mepOwnedPaths: ["src/**",".mep/prep/$slug/**"]
mepMasterPlanPath: .mep/prep/$slug/04-iteration-roadmap.md
---

# $slug roadmap
EOF
  cat >"$root/.mep/prep/$slug/iterations/01.md" <<EOF
---
mepIteration: 1
mepTitle: Golden fixture
mepStatus: $status
mepSliceType: $slice_type
mepDeliveryTrack: full-stack
mepFanout: sequential
---

# $slug brief
EOF
  printf '# fixture\n' >"$root/src/app.sh"
  git -C "$root" init -q -b main
  git -C "$root" config user.email mep@test
  git -C "$root" config user.name mep
  git -C "$root" config commit.gpgsign false
  git -C "$root" add -A
  git -C "$root" commit -q -m "golden $slug baseline"
  printf '%s' "$root"
}

assert_where() {
  local label=$1 root=$2 slug=$3 expected_row=$4 expected_next=$5 expected_request=$6
  local out err rc=0
  err=$(mktemp "$TMP/err.XXXXXX")
  out=$(cd "$root" && MEP_REPO_ROOT_OVERRIDE="$root" "$MEP" where "$slug" --json 2>"$err") || rc=$?
  [[ "$rc" == 0 ]] || fail "$label exit 0 (got $rc)"
  [[ ! -s "$err" ]] || fail "$label stderr empty"
  jq -en \
    --argjson packet "$out" \
    --argjson row "$expected_row" \
    --arg next "$expected_next" \
    --argjson request "$expected_request" '
      $packet.status == "ok"
      and $packet.row == $row
      and $packet.proof.row == $row
      and $packet.nextCommand == (if $next == "" then null else $next end)
      and $packet.executionRequest == $request
      and $packet.proof.executionRequest == $request
      and ($packet.executionRequest | keys | sort) == ["argv", "kind", "target"]
    ' >/dev/null || {
      printf 'expected row=%s next=%s request=%s\nactual=%s\n' \
        "$expected_row" "$expected_next" "$expected_request" "$out" >&2
      fail "$label packet"
    }
  pass "$label"
}

request_for() {
  local kind=$1 target=$2 arg=${3:-}
  if [[ "$kind" == none ]]; then
    jq -cn '{kind:"none",target:null,argv:[]}'
  elif [[ -n "$arg" ]]; then
    jq -cn --arg kind "$kind" --arg target "$target" --arg arg "$arg" \
      '{kind:$kind,target:$target,argv:[$arg]}'
  else
    jq -cn --arg kind "$kind" --arg target "$target" \
      '{kind:$kind,target:$target,argv:[]}'
  fi
}

root=$(new_case row1 5 true pending behavioral graduated)
assert_where "row 1 graduated" "$root" row1 1 "" "$(request_for none "")"

root=$(new_case row2 5 true brief_ready cleanup active)
assert_where "row 2 cleanup" "$root" row2 2 "/prep-cleanup row2" "$(request_for cleanup row2)"

root=$(new_case row3 4 false pending behavioral active)
set_frontmatter "$root/.mep/prep/row3/04-iteration-roadmap.md" mepCurrentIteration null
rm "$root/.mep/prep/row3/iterations/01.md"
git -C "$root" add -A
git -C "$root" commit -q -m "row 3 no current iteration"
assert_where "row 3 planning" "$root" row3 3 "/prep row3" "$(request_for prep row3)"

root=$(new_case row4 5 false pending behavioral active)
assert_where "row 4 docs bootstrap" "$root" row4 4 "/commit-prep row4 docs-bootstrap" \
  "$(request_for commit_prep row4 docs-bootstrap)"

root=$(new_case row5 5 true brief_ready behavioral active)
printf '\ncheckpoint note\n' >>"$root/.mep/prep/row5/iterations/01.md"
assert_where "row 5 docs-delta interstitial" "$root" row5 5 "/commit-prep row5 docs-delta" \
  "$(request_for commit_prep row5 docs-delta)"

root=$(new_case row6 5 true pending behavioral active)
assert_where "row 6 pending" "$root" row6 6 "/prep row6 checkpoint" "$(request_for checkpoint row6)"

root=$(new_case row6-dirty-planning 5 true pending behavioral active)
printf '\nunsaved planning note\n' >>"$root/.mep/prep/row6-dirty-planning/iterations/01.md"
assert_where "row 6 pending despite dirty planning" "$root" row6-dirty-planning 6 \
  "/prep row6-dirty-planning checkpoint" "$(request_for checkpoint row6-dirty-planning)"

root=$(new_case row7 5 true brief_ready behavioral active)
assert_where "row 7 implement" "$root" row7 7 \
  "/implement-plan .mep/prep/row7/iterations/01.md" \
  "$(request_for implement .mep/prep/row7/iterations/01.md .mep/prep/row7/iterations/01.md)"

root=$(new_case row8 5 true brief_ready behavioral active)
printf '# @finish:open — golden decision\n' >>"$root/src/app.sh"
git -C "$root" add -A
git -C "$root" commit -q -m "row 8 open finish"
assert_where "row 8 open finish" "$root" row8 8 \
  "/implement-plan .mep/prep/row8/iterations/01.md" \
  "$(request_for implement .mep/prep/row8/iterations/01.md .mep/prep/row8/iterations/01.md)"

root=$(new_case row9 5 true brief_ready behavioral active)
printf '# dirty implementation\n' >>"$root/src/app.sh"
assert_where "row 9 dirty implementation" "$root" row9 9 "/commit-prep row9" \
  "$(request_for commit_prep row9)"

root=$(new_case row10 5 true implemented behavioral active)
assert_where "row 10 landed fallback" "$root" row10 10 "/prep row10 checkpoint" \
  "$(request_for checkpoint row10)"

root=$(new_case row10-precedence 5 true brief_ready behavioral active)
printf '# landed implementation\n' >>"$root/src/app.sh"
git -C "$root" add -A
git -C "$root" commit -q -m "row 10 implementation"
printf '\nunsaved checkpoint note\n' >>"$root/.mep/prep/row10-precedence/iterations/01.md"
assert_where "row 10 beats dirty planning" "$root" row10-precedence 10 \
  "/prep row10-precedence checkpoint" "$(request_for checkpoint row10-precedence)"

root=$(new_case row11 5 true committed behavioral active)
cat >"$root/.mep/prep/row11/iterations/02.md" <<'EOF'
---
mepIteration: 2
mepTitle: Later work
mepStatus: pending
mepSliceType: behavioral
mepDeliveryTrack: full-stack
mepFanout: sequential
---

# Later work
EOF
git -C "$root" add -A
git -C "$root" commit -q -m "row 11 later work"
assert_where "row 11 recovery" "$root" row11 11 "/prep row11 checkpoint" \
  "$(request_for checkpoint row11)"

root=$(new_case checkpoint-docs 5 true brief_ready behavioral active)
printf '# landed implementation\n' >>"$root/src/app.sh"
git -C "$root" add -A
git -C "$root" commit -q -m "checkpoint implementation"
out=$(cd "$root" && MEP_REPO_ROOT_OVERRIDE="$root" "$MEP" checkpoint checkpoint-docs --fix --json) || true
[[ "$(printf '%s' "$out" | jq -r '.appliedWritebacks')" == 4 ]] || fail "checkpoint document writeback count"
out=$(MEP_REPO_ROOT_OVERRIDE="$root" "$MEP" status checkpoint-docs --compact --json)
jq -e '
  .initiative.currentIteration == 1
  and .initiative.currentIterationRecord.status == "committed"
  and (.initiative.currentIterationRecord.briefRevision | length) > 0
  and (.initiative.currentIterationRecord.implementationRevision | length) > 0
  and (.initiative.currentIterationRecord.checkpointRevision | length) > 0
' <<<"$out" >/dev/null || fail "checkpoint writebacks are not observable through composed state"
[[ ! -e "$root/.mep/prep/checkpoint-docs/manifest.json" ]] || fail "checkpoint created routing manifest"
pass "checkpoint writes document frontmatter"

pass "run-golden-matrix"
