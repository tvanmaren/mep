#!/usr/bin/env bash

mep_repo_relative_path_is_safe() {
  case "$1" in
    ""|/*|..|../*|*/../*|*/..) return 1 ;;
    *) return 0 ;;
  esac
}

mep_brief_owned_paths_json() {
  local brief_path=$1
  awk '
    /^## File ownership/ { in_ownership = 1; next }
    in_ownership && /^## / { exit }
    in_ownership && /^\| `/ {
      line = $0
      sub(/^\| `/, "", line)
      sub(/`.*/, "", line)
      print line
    }
  ' "$brief_path" | mep_json_string_array_from_lines
}

mep_brief_constitution_text() {
  local brief_path=$1 key=$2
  awk -v key="$key" '
    {
      prefix = "| **" key "** | "
    }
    index($0, prefix) == 1 {
      line = $0
      line = substr(line, length(prefix) + 1)
      sub(/ \|$/, "", line)
      print line
      exit
    }
  ' "$brief_path"
}

mep_implement_scope_json() {
  local brief_rel=$1 brief_abs status owns may_know must_not_know invariants still_provisional owned_paths
  if ! mep_repo_relative_path_is_safe "$brief_rel"; then
    jq -cn \
      --arg briefPath "$brief_rel" \
      '{status:"blocked",reason:"invalid_brief_path",briefPath:$briefPath}'
    return 0
  fi
  brief_abs=$(mep_abs_path "$brief_rel")
  if [[ ! -f "$brief_abs" ]]; then
    jq -cn \
      --arg briefPath "$brief_rel" \
      '{status:"not_found",reason:"brief_not_found",briefPath:$briefPath}'
    return 0
  fi

  status=$(mep_frontmatter_value "$brief_abs" mepStatus)
  # Briefs authored before document-colocated state carry the status in the prose header only.
  if [[ -z "$status" ]]; then
    status=$(awk -F'[*:]+' '/^\*\*Status:\*\*/ { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3); print $3; exit }' "$brief_abs")
  fi
  owns=$(mep_brief_constitution_text "$brief_abs" "Owns")
  may_know=$(mep_brief_constitution_text "$brief_abs" "May know")
  must_not_know=$(mep_brief_constitution_text "$brief_abs" "Must not know")
  invariants=$(mep_brief_constitution_text "$brief_abs" "Invariants")
  still_provisional=$(mep_brief_constitution_text "$brief_abs" "Still provisional")
  owned_paths=$(mep_brief_owned_paths_json "$brief_abs")

  jq -cn \
    --arg briefPath "$brief_rel" \
    --arg briefStatus "$status" \
    --arg owns "$owns" \
    --arg mayKnow "$may_know" \
    --arg mustNotKnow "$must_not_know" \
    --arg invariants "$invariants" \
    --arg stillProvisional "$still_provisional" \
    --argjson ownedPaths "$owned_paths" \
    '{
      status: "ok",
      readOnly: true,
      executionRequest: {kind:"implement",target:$briefPath,argv:[$briefPath]},
      brief: {
        path: $briefPath,
        status: $briefStatus,
        constitution: {
          owns: $owns,
          mayKnow: $mayKnow,
          mustNotKnow: $mustNotKnow,
          invariants: $invariants,
          stillProvisional: $stillProvisional
        },
        ownedPaths: $ownedPaths
      }
    }'
}

mep_commit_scope_json() {
  local slug=$1 manifest_json current_json brief_rel brief_abs owned_paths
  local markers_json dirty_owned_json dirty_implementation_json writebacks_json
  local finish_open_json
  manifest_json=$(mep_state_summary_json "$slug")
  if [[ "$(printf '%s' "$manifest_json" | jq -r '.exists')" != true ]]; then
    jq -cn --arg slug "$slug" '{status:"not_found",reason:"state_not_found",slug:$slug}'
    return 0
  fi

  current_json=$(printf '%s' "$manifest_json" | jq -c '.currentIterationRecord')
  brief_rel=$(printf '%s' "$current_json" | jq -r '.briefPath // ""')
  brief_abs=$(mep_abs_path "$brief_rel")
  if [[ -z "$brief_rel" || ! -f "$brief_abs" ]]; then
    jq -cn --arg slug "$slug" --arg briefPath "$brief_rel" \
      '{status:"not_found",reason:"brief_not_found",slug:$slug,briefPath:(if $briefPath == "" then null else $briefPath end)}'
    return 0
  fi

  owned_paths=$(mep_brief_owned_paths_json "$brief_abs")
  markers_json=$(mep_finish_marker_lines_json "$manifest_json")
  dirty_owned_json=$(mep_dirty_owned_paths_json "$manifest_json")
  dirty_implementation_json=$(mep_dirty_implementation_paths_json "$slug" "$dirty_owned_json" "$manifest_json")
  writebacks_json=$(mep_finish_required_writebacks_json "$manifest_json" "$markers_json" "$dirty_implementation_json")
  finish_open_json=$(printf '%s' "$writebacks_json" | jq -c '[.[] | select(.kind == "finish_open")]')

  # Open finishes cannot look committable in any authorship mode.
  if [[ "$(printf '%s' "$finish_open_json" | jq 'length')" -gt 0 ]]; then
    jq -cn \
      --arg slug "$slug" \
      --arg briefPath "$brief_rel" \
      --argjson iteration "$(printf '%s' "$current_json" | jq '.number // null')" \
      --argjson paths "$owned_paths" \
      --argjson finishOpen "$finish_open_json" \
      '{
        status: "blocked",
        reason: "finish_open",
        readOnly: true,
        slug: $slug,
        iteration: $iteration,
        briefPath: $briefPath,
        paths: $paths,
        requiredWritebacks: $finishOpen
      }'
    return 0
  fi

  jq -cn \
    --arg slug "$slug" \
    --arg briefPath "$brief_rel" \
    --argjson iteration "$(printf '%s' "$current_json" | jq '.number // null')" \
    --argjson paths "$owned_paths" \
    '{
      status: "ok",
      readOnly: true,
      slug: $slug,
      iteration: $iteration,
      briefPath: $briefPath,
      paths: $paths
    }'
}

mep_mode_set_json() {
  local slug=$1 mode=$2 dry_run=${3:-0} roadmap state_json authority state_path
  local dry_run_json=false
  (( dry_run )) && dry_run_json=true

  roadmap=$(mep_roadmap_path "$slug")
  state_json=$(mep_state_summary_json "$slug")
  authority=$(printf '%s' "$state_json" | jq -r '.authority')
  state_path=$(printf '%s' "$state_json" | jq -r '.path')

  if [[ "$(printf '%s' "$state_json" | jq -r '.exists')" != true ]]; then
    jq -cn --arg slug "$slug" --arg path "$state_path" \
      '{status:"not_found",reason:"state_not_found",slug:$slug,statePath:$path}'
    return 0
  fi

  if [[ "$(printf '%s' "$state_json" | jq '(.documentErrors // []) | length')" != 0 ]]; then
    printf '%s' "$state_json" | jq -c --arg statePath "$state_path" '{
      status: "blocked",
      reason: "invalid_document_state",
      slug,
      statePath: $statePath,
      findings: .documentErrors
    }'
    return 0
  fi

  if [[ "$authority" != documents ]]; then
    if [[ "$authority" == legacy_import ]]; then
      jq -cn --arg slug "$slug" --arg path "$state_path" '{
        status: "blocked",
        reason: "legacy_state_read_only",
        slug: $slug,
        statePath: $path,
        detail: "initiative state is an import-only manifest at \($path); run `mep migrate` to write document frontmatter before setting a mode"
      }'
      return 0
    fi
    jq -cn --arg slug "$slug" --arg statePath "$state_path" --arg authority "$authority" \
      '{status:"blocked",reason:"unsupported_state_authority",slug:$slug,statePath:$statePath,authority:$authority}'
    return 0
  fi

  if (( ! dry_run )) && ! mep_frontmatter_set "$roadmap" mepAuthorshipMode "$mode"; then
    jq -cn --arg slug "$slug" --arg statePath "$state_path" \
      '{status:"blocked",reason:"state_write_failed",slug:$slug,statePath:$statePath}'
    return 0
  fi

  jq -cn \
    --arg slug "$slug" \
    --arg mode "$mode" \
    --argjson dryRun "$dry_run_json" \
    '{status:"ok",slug:$slug,authorshipMode:$mode,dryRun:$dryRun,written:($dryRun | not)}'
}

mep_evidence_write_json() {
  local slug=$1 kind=$2 state=$3 detail=$4 dry_run=${5:-0}
  local root path ts evidence dry_run_json=false
  (( dry_run )) && dry_run_json=true
  root=$(mep_history_root_abs)
  path=$root/evidence.jsonl
  ts=$(mep_event_now)
  evidence=$(jq -cn \
    --arg slug "$slug" \
    --arg kind "$kind" \
    --arg state "$state" \
    --arg detail "$detail" \
    --arg ts "$ts" \
    '{version:1,ts:$ts,slug:$slug,kind:$kind,state:$state,detail:(if $detail == "" then null else $detail end)}')

  if (( ! dry_run )); then
    mkdir -p "$root" || {
      jq -cn '{status:"blocked",reason:"evidence_write_failed"}'
      return 0
    }
    printf '%s\n' "$evidence" >>"$path" || {
      jq -cn '{status:"blocked",reason:"evidence_write_failed"}'
      return 0
    }
  fi

  jq -cn \
    --arg path "$path" \
    --argjson dryRun "$dry_run_json" \
    --argjson evidence "$evidence" \
    '{status:"ok",path:$path,dryRun:$dryRun,written:($dryRun | not),evidence:$evidence}'
}
