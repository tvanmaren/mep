#!/usr/bin/env bash
# @stable — public shell contract: JSON status → process exit; this registry feeds help, usage, and tests.

MEP_VERSION=0.1.0

# TSV: name<TAB>usage<TAB>blurb
mep_registry_print() {
  cat <<'EOF'
help	mep help	print command list to stderr
version	mep version --json	print tool version envelope
config dump	mep config dump --json	print resolved config
profile dump	mep profile dump --json	print active profile seed
paths	mep paths <slug> --json	print resolved paths for a slug
status	mep status <slug> --compact --json	print compact initiative status
check scaffolding	mep check scaffolding [--json] [--broad|--product-code] [paths...]	scan paths for process archaeology
check prep-active	mep check prep-active --json	print prep-active session file state
doctor	mep doctor <slug> --json [--fix] [--trunk <ref>]	report or apply committed/merged desync
where	mep where <slug> --json	print next-command resolver packet
exec dispatch	mep exec dispatch --json [--executor <preset>] [--request-json <json>] [--dry-run]	dispatch an executionRequest
implement	mep implement --json <briefPath>	print read-only brief scope packet
mode set	mep mode set <slug> <manual|default|autopilot> --json [--dry-run]	set initiative authorship mode
commit scope	mep commit scope <slug> --json	print current slice commit paths
evidence write	mep evidence write <slug> <kind> <state> --json [--detail <text>] [--dry-run]	append workflow evidence
events tail	mep events tail --json [--slug <slug>] [--event <name>] [--version <n>] [--limit <n>]	read local event ledger
pr scaffold	mep pr scaffold <slug> <n> --json	write deterministic PR scaffold
finish scan	mep finish scan <slug> --json	scan finish-map markers
mark mise	mep mark mise <path> --json [--dry-run]	wrap a source file in authorship markers
mark finish	mep mark finish <path> --state <open|done|ratified> --json [--dry-run]	set one existing finish marker state
checkpoint	mep checkpoint <slug> --json [--fix]	report or apply checkpoint writebacks
lifecycle status	mep lifecycle status <slug> --mode <manual|default|autopilot> --json	print authorship-mode lifecycle
curate	mep curate <slug> --json [--preview|--measure|--validate|--execute] [--confirm] [--dry-run]	curate preview/execute
curate template	mep curate <slug> --json --template [--force]	write curation template
EOF
}

mep_exit_code_for_status() {
  case "${1:-}" in
    ok|clean) printf '0' ;;
    desync|gated|warning) printf '1' ;;
    blocked|missing_dependency) printf '2' ;;
    not_found) printf '3' ;;
    usage) printf '64' ;;
    *) printf '70' ;;
  esac
}

mep_canonicalize_packet_status() {
  case "${1:-}" in
    ok|clean|desync|gated|warning|blocked|missing_dependency|not_found) printf '%s' "$1" ;;
    *) printf 'internal' ;;
  esac
}

mep_exit_for_status() {
  case "${1:-}" in
    usage) exit 64 ;;
  esac
  exit "$(mep_exit_code_for_status "$(mep_canonicalize_packet_status "${1:-}")")"
}

mep_print_json_exit() {
  local json=${1:-}
  local st canon
  if [[ -z "$json" ]]; then
    printf '{"status":"internal","detail":"empty command output"}\n'
    mep_exit_for_status internal
  fi
  if ! printf '%s' "$json" | jq -e 'type == "object"' >/dev/null 2>&1; then
    printf '{"status":"internal","detail":"command output was not a JSON object"}\n'
    mep_exit_for_status internal
  fi
  if printf '%s' "$json" | jq -e '.status | not' >/dev/null 2>&1; then
    json=$(printf '%s' "$json" | jq -c '. + {status:"ok"}')
  fi
  st=$(printf '%s' "$json" | jq -r '.status // empty' 2>/dev/null) || mep_exit_for_status internal
  canon=$(mep_canonicalize_packet_status "$st")
  if [[ "$canon" != "$st" ]]; then
    json=$(printf '%s' "$json" | jq -c --arg st "$canon" '.status = $st')
  fi
  printf '%s\n' "$json"
  mep_exit_for_status "$canon"
}

mep_dispatch_json() {
  local fn=$1 json rc=0
  shift
  json=$("$fn" "$@") || rc=$?
  if (( rc == 64 )); then
    mep_exit_for_status usage
  fi
  mep_print_json_exit "$json"
}

mep_usage_from_registry() {
  local usage
  printf 'usage:\n' >&2
  while IFS=$'\t' read -r _ usage _; do
    [[ -n "$usage" ]] || continue
    printf '  %s\n' "$usage" >&2
  done < <(mep_registry_print)
}

mep_help() {
  mep_usage_from_registry
  exit 0
}

mep_version_json() {
  printf '{"status":"ok","version":%s}\n' "$(mep_json_string "$MEP_VERSION")"
}
