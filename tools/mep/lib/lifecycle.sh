#!/usr/bin/env bash

mep_lifecycle_validate_mode() {
  case "$1" in
    manual|default|autopilot) return 0 ;;
    *) return 1 ;;
  esac
}

mep_lifecycle_validation_mode() {
  case "$1" in
    autopilot) printf 'autopilot' ;;
    *) printf 'manual' ;;
  esac
}

mep_lifecycle_manifest_json() {
  local manifest_json=$1 mode=$2 validation_mode
  validation_mode=$(mep_lifecycle_validation_mode "$mode")
  printf '%s' "$manifest_json" | jq --arg mode "$mode" --arg validationMode "$validation_mode" '
    .authorshipMode = $mode
    | .lifecycleValidationMode = $validationMode
  '
}

mep_lifecycle_gates_json() {
  local finish_scan_json=$1 checkpoint_json=$2 manifest_json=$3 mode=$4
  jq -cn \
    --arg mode "$mode" \
    --argjson finishScan "$finish_scan_json" \
    --argjson checkpoint "$checkpoint_json" \
    --argjson manifest "$manifest_json" '
      ($finishScan.requiredWritebacks // []) as $writebacks
      | ($checkpoint.findings // []) as $findings
      | ($manifest.currentIterationRecord.sliceType // "") as $sliceType
      | ($mode == "autopilot") as $autopilot
      | [
          (if ($autopilot and $sliceType == "cleanup") then
            {
              kind: "graduation_export",
              gate: "human",
              severity: "blocker",
              action: "ask_operator_for_graduation_approval",
              detail: "graduation/export is an explicit human gate"
            }
          else empty end),
          ($writebacks[]?
            | if .kind == "finish_open" then
              {
                kind: .kind,
                gate: (if $autopilot then "proxy" else "human" end),
                severity: "blocker",
                action: (if $autopilot then "dispatch_proxy_finish_author" else "author_open_finish" end),
                detail: .detail,
                count: .count
              }
            elif .kind == "finish_missing_proxy_provenance" then
              {
                kind: .kind,
                gate: "proxy",
                severity: "blocker",
                action: "dispatch_proxy_ratification",
                detail: .detail,
                count: .count
              }
            elif .kind == "finish_missing_human_provenance" then
              {
                kind: .kind,
                gate: "human",
                severity: "blocker",
                action: "ratify_with_human_provenance",
                detail: .detail,
                count: .count
              }
            elif .kind == "finish_map_missing" then
              {
                kind: .kind,
                gate: (if $autopilot then "proxy" else "human" end),
                severity: "warning",
                action: (if $autopilot then "dispatch_proxy_finish_classification" else "classify_finish_map" end),
                detail: .detail,
                count: .count
              }
            else
              {
                kind: .kind,
                gate: (if $autopilot then "proxy" else "human" end),
                severity: (.severity // "warning"),
                action: (if $autopilot then "dispatch_proxy_finish_resolution" else "resolve_finish_writeback" end),
                detail: (.detail // ""),
                count: (.count // null)
              }
            end),
          ($findings[]?
            | if .kind == "commit_required_before_checkpoint" then
              {
                kind: .kind,
                gate: "commit",
                severity: (.severity // "warning"),
                action: (if $autopilot then "stop_for_explicit_commit_approval" else "commit_or_clean_owned_work_before_checkpoint" end),
                detail: .detail,
                count: (.count // null)
              }
            elif (.severity // "") == "blocker" then
              {
                kind: (.kind // .finding),
                gate: "forbidden",
                severity: "blocker",
                action: (if $autopilot then "stop_until_checkpoint_blocker_resolved" else "resolve_checkpoint_blocker" end),
                detail: (.detail // "")
              }
            elif (.fixable == true or .finding == "normalize_phase_to_5") then
              {
                kind: (.kind // .finding),
                gate: (if $autopilot then "proxy" else "checkpoint" end),
                severity: (.severity // "info"),
                action: (if $autopilot then "apply_deterministic_checkpoint_writeback_when_clean" else "run_mep_checkpoint_fix_when_clean" end),
                detail: (.detail // "deterministic checkpoint writeback is pending")
              }
            else
              {
                kind: (.kind // .finding),
                gate: (if $autopilot then "forbidden" else "checkpoint" end),
                severity: (.severity // "warning"),
                action: (if $autopilot then "stop_until_checkpoint_finding_resolved" else "resolve_checkpoint_finding" end),
                detail: (.detail // "")
              }
            end)
        ]
    '
}

mep_lifecycle_actor_json() {
  local mode=$1
  jq -cn --arg mode "$mode" '
    if $mode == "autopilot" then
      {
        implementer: "parent_agent",
        finishAuthor: "proxy",
        ratifier: "proxy",
        checkpointWriter: "tool"
      }
    elif $mode == "default" then
      {
        implementer: "agent",
        finishAuthor: "human",
        ratifier: "human",
        checkpointWriter: "tool"
      }
    else
      {
        implementer: "human",
        finishAuthor: "human",
        ratifier: "human",
        checkpointWriter: "tool"
      }
    end
  '
}

mep_lifecycle_status_json() {
  local slug=$1 mode=$2
  local emit_event=${3:-1}
  local manifest_json lifecycle_manifest_json validation_manifest_json markers_json dirty_owned_json required_writebacks_json finish_scan_json checkpoint_json gates_json actor_json blocker_count can_advance asks_user_mid_slice validation_mode packet event_payload
  mep_require jq rg "$MEP_VCS_KIND" || return $?
  mep_lifecycle_validate_mode "$mode" || mep_usage

  manifest_json=$(mep_manifest_summary_json "$slug")
  if [[ "$(printf '%s' "$manifest_json" | jq -r '.exists')" != true ]]; then
    printf '{"status":"not_found","slug":%s,"manifest":%s}\n' "$(mep_json_string "$slug")" "$(printf '%s' "$manifest_json" | jq '.path')"
    return 0
  fi

  validation_mode=$(mep_lifecycle_validation_mode "$mode")
  lifecycle_manifest_json=$(mep_lifecycle_manifest_json "$manifest_json" "$mode")
  validation_manifest_json=$(printf '%s' "$manifest_json" | jq --arg validationMode "$validation_mode" '.authorshipMode = $validationMode')
  markers_json=$(mep_finish_marker_lines_json "$validation_manifest_json")
  dirty_owned_json=$(mep_dirty_owned_paths_json "$validation_manifest_json")
  required_writebacks_json=$(mep_finish_required_writebacks_json "$validation_manifest_json" "$markers_json" "$dirty_owned_json")
  finish_scan_json=$(jq -cn \
    --arg slug "$slug" \
    --arg mode "$mode" \
    --arg validationMode "$validation_mode" \
    --argjson manifest "$lifecycle_manifest_json" \
    --argjson markers "$markers_json" \
    --argjson dirtyOwned "$dirty_owned_json" \
    --argjson requiredWritebacks "$required_writebacks_json" '
      {
        status: "ok",
        slug: $slug,
        authorshipMode: $mode,
        validationMode: $validationMode,
        currentIteration: $manifest.currentIteration,
        currentIterationStatus: ($manifest.currentIterationRecord.status // null),
        counts: {
          total: ($markers | length),
          open: ([ $markers[] | select(.state == "open") ] | length),
          done: ([ $markers[] | select(.state == "done") ] | length),
          ratified: ([ $markers[] | select(.state == "ratified") ] | length)
        },
        markers: $markers,
        dirtyOwnedFiles: $dirtyOwned,
        requiredWritebacks: $requiredWritebacks
      }
    ')
  checkpoint_json=$(mep_checkpoint_json "$slug" 0 0)
  gates_json=$(mep_lifecycle_gates_json "$finish_scan_json" "$checkpoint_json" "$lifecycle_manifest_json" "$mode")
  actor_json=$(mep_lifecycle_actor_json "$mode")
  blocker_count=$(printf '%s' "$gates_json" | jq '[.[] | select(.severity == "blocker")] | length')
  can_advance=$(printf '%s' "$gates_json" | jq 'length == 0')
  asks_user_mid_slice=$(printf '%s' "$gates_json" | jq '[.[] | select(.gate == "human")] | length > 0')

  packet=$(jq -cn \
    --arg slug "$slug" \
    --arg mode "$mode" \
    --arg validationMode "$validation_mode" \
    --argjson manifest "$lifecycle_manifest_json" \
    --argjson finish "$finish_scan_json" \
    --argjson checkpoint "$checkpoint_json" \
    --argjson gates "$gates_json" \
    --argjson actor "$actor_json" \
    --argjson blockerCount "$blocker_count" \
    --argjson canAdvance "$can_advance" \
    --argjson asksUserMidSlice "$asks_user_mid_slice" '
      {
        status: (if $canAdvance then "clean" elif $blockerCount > 0 then "blocked" else "gated" end),
        slug: $slug,
        mode: $mode,
        validationMode: $validationMode,
        actor: $actor,
        canAdvance: $canAdvance,
        asksUserMidSlice: $asksUserMidSlice,
        gateKinds: ["human", "proxy", "commit", "forbidden", "checkpoint"],
        humanGateAllowlist: [
          "graduation_export",
          "branch_relevance_classification",
          "commit_or_pr_approval"
        ],
        forbiddenActions: [
          "parent_self_ratification",
          "git_commit_without_operator_approval",
          "git_push_without_operator_approval",
          "gh_pr_create_without_operator_approval",
          "gh_pr_merge_without_operator_approval"
        ],
        manifest: {
          currentIteration: $manifest.currentIteration,
          currentIterationStatus: ($manifest.currentIterationRecord.status // null),
          currentSliceType: ($manifest.currentIterationRecord.sliceType // null)
        },
        finish: $finish,
        checkpoint: $checkpoint,
        gates: $gates
      }
    ') || return $?
  printf '%s\n' "$packet"
  if (( emit_event )); then
    event_payload=$(printf '%s' "$packet" | jq -c '{
      status,
      mode,
      canAdvance,
      asksUserMidSlice,
      currentIteration: .manifest.currentIteration,
      currentIterationStatus: .manifest.currentIterationStatus,
      currentSliceType: .manifest.currentSliceType,
      gateCount: ((.gates // []) | length),
      gateKinds: [(.gates // [])[] | .kind]
    }' 2>/dev/null) || event_payload=
    [[ -n "$event_payload" ]] && mep_event_append "lifecycle_evaluated" "$slug" "lifecycle" "$event_payload"
  fi
}
