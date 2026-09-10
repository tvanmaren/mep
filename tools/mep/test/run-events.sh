#!/usr/bin/env bash
# Documented event classes append and round-trip through events tail.
set -euo pipefail

SRC=${MEP_REPO_ROOT_OVERRIDE:-$(git rev-parse --show-toplevel)}
MEP="$SRC/tools/mep/bin/mep"
[[ -x "$MEP" ]] || { printf 'not ok - missing %s\n' "$MEP" >&2; exit 1; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

root="$TMP/events-fx"
mkdir -p "$root/.mep/prep/events-fx/iterations" "$root/src"
cat >"$root/.mep/prep/events-fx/iterations/01.md" <<'MD'
---
mepIteration: 1
mepTitle: Events fixture
mepStatus: brief_ready
mepSliceType: behavioral
mepFanout: sequential
---

# Iteration 1 — Events fixture
MD
printf '# fixture\n' >"$root/src/app.sh"
cat >"$root/.mep/prep/events-fx/04-iteration-roadmap.md" <<'MD'
---
mepSlug: events-fx
mepPhase: 5
mepPrepDocsBootstrapped: true
mepHandoffApproved: true
mepInitiativeStatus: active
mepAuthorshipMode: default
mepCurrentIteration: 1
mepOwnedPaths: ["src/**", ".mep/prep/events-fx/**"]
---

# Iteration roadmap — events-fx
MD

git -C "$root" init -q -b main
git -C "$root" config user.email mep@test
git -C "$root" config user.name mep
git -C "$root" config commit.gpgsign false
git -C "$root" add -A
git -C "$root" commit -q -m "events fixture"

history="$TMP/history"
mkdir -p "$history"
run_mep() {
  MEP_REPO_ROOT_OVERRIDE="$root" MEP_HISTORY_ROOT_OVERRIDE="$history" "$MEP" "$@"
}

tmp="$TMP/out"
err="$TMP/err"
ledger="$history/events.jsonl"

ledger_count() {
  if [[ -f "$ledger" ]]; then
    jq -s 'length' "$ledger"
  else
    printf '0'
  fi
}

assert_command_emits() {
  local label=$1 class=$2 source=$3
  local before after last
  before=$(ledger_count)
  shift 3
  LAST_MEP_RC=0
  "$@" >"$tmp" 2>"$err" || LAST_MEP_RC=$?
  after=$(ledger_count)
  [[ "$after" -eq $((before + 1)) ]] || {
    printf 'before=%s after=%s rc=%s out=%s\n' "$before" "$after" "$LAST_MEP_RC" "$(cat "$tmp")" >&2
    fail "$label appended one event"
  }
  last=$(tail -n 1 "$ledger")
  jq -en --argjson row "$last" --arg class "$class" --arg source "$source" '
    $row.event == $class
    and $row.source == $source
    and $row.slug == "events-fx"
    and $row.version == 1
    and $row.id == null
    and ($row.ts | type) == "string"
    and ($row.payload | type) == "object"
    and ($row | keys | sort) == ["event","id","payload","slug","source","ts","version"]
  ' >/dev/null || {
    printf 'last=%s\n' "$last" >&2
    fail "$label event class/source/envelope"
  }
  pass "$label emits $class"
}

assert_command_emits "where" resolver_routed where \
  run_mep where events-fx --json
[[ "$LAST_MEP_RC" == 0 ]] || fail "where exit 0 (got $LAST_MEP_RC)"

assert_command_emits "checkpoint" checkpoint_evaluated checkpoint \
  run_mep checkpoint events-fx --json
[[ "$LAST_MEP_RC" == 0 || "$LAST_MEP_RC" == 1 ]] || fail "checkpoint exit 0 or 1 (got $LAST_MEP_RC)"

assert_command_emits "lifecycle" lifecycle_evaluated lifecycle \
  run_mep lifecycle status events-fx --mode default --json
[[ "$LAST_MEP_RC" == 0 ]] || fail "lifecycle exit 0 (got $LAST_MEP_RC)"

assert_command_emits "pr scaffold" review_body_validated pr_scaffold \
  run_mep pr scaffold events-fx 1 --json
[[ "$LAST_MEP_RC" == 0 ]] || fail "pr scaffold exit 0 (got $LAST_MEP_RC)"

run_mep events tail --json --slug events-fx >"$tmp" 2>"$err" || fail "tail all exit 0"
jq -e '
  .status == "ok"
  and .totalMatched >= 4
  and (.events | length) >= 4
  and all(.events[];
    (.event == "resolver_routed"
     or .event == "checkpoint_evaluated"
     or .event == "lifecycle_evaluated"
     or .event == "review_body_validated")
    and .version == 1
    and .id == null
    and (.ts | type) == "string"
    and .slug == "events-fx"
    and (.source | type) == "string"
    and (.payload | type) == "object")
' "$tmp" >/dev/null || {
  printf 'tail=%s\n' "$(cat "$tmp")" >&2
  fail "four classes present with envelope"
}
pass "four documented classes append"

for class in resolver_routed checkpoint_evaluated lifecycle_evaluated review_body_validated; do
  run_mep events tail --json --slug events-fx --event "$class" >"$tmp" 2>"$err" || fail "tail $class exit 0"
  jq -e --arg class "$class" '
    .status == "ok"
    and .totalMatched >= 1
    and .count == (.events | length)
    and all(.events[]; .event == $class)
  ' "$tmp" >/dev/null || {
    printf 'tail-%s=%s\n' "$class" "$(cat "$tmp")" >&2
    fail "filter --event $class"
  }
  pass "tail --event $class"
done

run_mep events tail --json --slug events-fx --limit 1 >"$tmp" 2>"$err" || fail "tail limit exit 0"
jq -e '.status == "ok" and .count == 1 and (.events | length) == 1' "$tmp" >/dev/null || fail "filter --limit 1"
pass "tail --limit 1"

run_mep events tail --json --slug __no-such-slug__ >"$tmp" 2>"$err" || fail "tail other slug exit 0"
jq -e '.status == "ok" and .totalMatched == 0 and .count == 0' "$tmp" >/dev/null || fail "filter --slug miss"
pass "tail --slug miss"

run_mep events tail --json --slug events-fx --version 1 >"$tmp" 2>"$err" || fail "tail version 1 exit 0"
jq -e '.status == "ok" and .totalMatched >= 4' "$tmp" >/dev/null || fail "filter --version 1"
run_mep events tail --json --slug events-fx --version 9 >"$tmp" 2>"$err" || fail "tail version 9 exit 0"
jq -e '.status == "ok" and .totalMatched == 0' "$tmp" >/dev/null || fail "filter --version miss"
pass "tail --version filter"

pass "run-events"
