#!/usr/bin/env bash

# @provisional — append-only runtime history; never a routing input.
# Events are runtime history, not current state: they observe already-derived
# runtime results without participating in route derivation, and never feed manifest/config.

MEP_EVENT_LEDGER_VERSION=1
MEP_EVENT_DEFAULT_SOURCE=resolver
MEP_EVENT_DEFAULT_TAIL_LIMIT=20

mep_history_root_abs() {
  if [[ -n "${MEP_HISTORY_ROOT_OVERRIDE:-}" ]]; then
    printf '%s' "$MEP_HISTORY_ROOT_OVERRIDE"
    return 0
  fi
  mep_abs_path "$MEP_STORAGE_HISTORY_ROOT"
}

mep_event_ledger_path() {
  printf '%s/events.jsonl' "$(mep_history_root_abs)"
}

mep_event_ledger_relative_path() {
  local ledger
  ledger=$(mep_event_ledger_path)
  if [[ -z "${MEP_HISTORY_ROOT_OVERRIDE:-}" && "$ledger" == "$MEP_REPO_ROOT/"* ]]; then
    printf '%s' "${ledger#"$MEP_REPO_ROOT/"}"
  fi
}

mep_event_now() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

mep_event_append() {
  local event=$1 slug=$2 emit_source=$3 payload_json=${4:-null}
  local ledger row
  ledger=$(mep_event_ledger_path)
  mkdir -p "$(dirname "$ledger")" 2>/dev/null || return 0 # best-effort: event writes never disrupt runtime commands
  row=$(jq -cn \
    --argjson version "$MEP_EVENT_LEDGER_VERSION" \
    --arg event "$event" \
    --arg ts "$(mep_event_now)" \
    --arg slug "$slug" \
    --arg source "$emit_source" \
    --argjson payload "$payload_json" '
      {
        version: $version,
        event: $event,
        id: null,
        ts: $ts,
        slug: (if $slug == "" then null else $slug end),
        source: (if $source == "" then null else $source end),
        payload: $payload
      }
    ' 2>/dev/null) || return 0 # best-effort: malformed event payloads never disrupt runtime commands
  { printf '%s\n' "$row" >> "$ledger"; } 2>/dev/null || return 0 # best-effort: ledger writes never disrupt runtime commands
}

mep_event_emit_resolver_routed() {
  local packet=$1 slug=$2 emit_source=${3:-$MEP_EVENT_DEFAULT_SOURCE}
  local payload
  payload=$(printf '%s' "$packet" | jq -c '{ status: .status, row: .row, state: .state, nextCommand: .nextCommand, proof: .proof }' 2>/dev/null) || return 0 # best-effort: event payload extraction never disrupts resolver routes
  mep_event_append "resolver_routed" "$slug" "$emit_source" "$payload"
}

mep_event_tail_ledger_ref_json() {
  local ledger=$1 relative=$2
  jq -cn \
    --arg path "$ledger" \
    --arg relative "$relative" '
      {
        path: $path,
        relative: (if $relative == "" then null else $relative end)
      }
    '
}

mep_event_tail_filters_json() {
  local filter_slug=$1 filter_event=$2 filter_version=$3
  jq -cn \
    --arg slug "$filter_slug" \
    --arg event "$filter_event" \
    --arg version "$filter_version" '
      {
        slug: (if $slug == "" then null else $slug end),
        event: (if $event == "" then null else $event end),
        version: (if $version == "" then null else ($version | tonumber) end)
      }
    '
}

mep_event_tail_ok_json() {
  local ledger_ref_json=$1 filters_json=$2 limit=$3 total_matched=$4 events_json=$5 warnings_json=$6
  jq -cn \
    --argjson ledger "$ledger_ref_json" \
    --argjson filters "$filters_json" \
    --argjson limit "$limit" \
    --argjson totalMatched "$total_matched" \
    --argjson events "$events_json" \
    --argjson warnings "$warnings_json" '
      {
        status: "ok",
        ledger: $ledger,
        filters: $filters,
        limit: $limit,
        totalMatched: $totalMatched,
        count: ($events | length),
        events: $events,
        warnings: $warnings
      }
    '
}

mep_event_tail_invalid_ledger_json() {
  local status=$1 ledger=$2 relative=$3 line_number=$4 detail=$5
  local ledger_ref_json
  ledger_ref_json=$(mep_event_tail_ledger_ref_json "$ledger" "$relative")
  jq -cn \
    --arg status "$status" \
    --argjson ledger "$ledger_ref_json" \
    --argjson lineNumber "$line_number" \
    --arg detail "$detail" '
      {
        status: $status,
        reason: "invalid_ledger",
        ledger: $ledger,
        lineNumber: $lineNumber,
        detail: $detail
      }
    '
}

mep_events_tail_json() {
  local limit=$1 filter_slug=$2 filter_event=$3 filter_version=$4
  local ledger relative ledger_ref_json filters_json rows=() line parsed line_number=0 matched_json events_json total_matched
  ledger=$(mep_event_ledger_path)
  relative=$(mep_event_ledger_relative_path)
  ledger_ref_json=$(mep_event_tail_ledger_ref_json "$ledger" "$relative")
  filters_json=$(mep_event_tail_filters_json "$filter_slug" "$filter_event" "$filter_version")

  if [[ ! -e "$ledger" ]]; then
    mep_event_tail_ok_json "$ledger_ref_json" "$filters_json" "$limit" 0 '[]' '[{"kind":"history_missing","detail":"event ledger does not exist"}]'
    return 0
  fi

  if [[ ! -f "$ledger" ]]; then
    mep_event_tail_invalid_ledger_json "not_found" "$ledger" "$relative" 0 "event ledger path is not a file"
    return 0
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))
    parsed=$(printf '%s' "$line" | jq -c . 2>/dev/null) || {
      mep_event_tail_invalid_ledger_json "blocked" "$ledger" "$relative" "$line_number" "malformed JSONL at line $line_number"
      return 0
    }
    rows+=("$parsed")
  done < "$ledger"

  matched_json=$({
    if (( ${#rows[@]} )); then
      printf '%s\n' "${rows[@]}"
    fi
  } | jq -c -s \
    --arg filterSlug "$filter_slug" \
    --arg filterEvent "$filter_event" \
    --arg filterVersion "$filter_version" '
      def matches:
        (($filterSlug == "") or (.slug == $filterSlug))
        and (($filterEvent == "") or (.event == $filterEvent))
        and (($filterVersion == "") or ((.version | tostring) == $filterVersion));

      [ .[] | select(matches) ]
    ')
  total_matched=$(printf '%s' "$matched_json" | jq 'length')
  events_json=$(printf '%s' "$matched_json" | jq -c --argjson limit "$limit" 'if $limit == 0 then [] else .[-$limit:] end')
  mep_event_tail_ok_json "$ledger_ref_json" "$filters_json" "$limit" "$total_matched" "$events_json" '[]'
}
