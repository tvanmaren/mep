#!/usr/bin/env bash

mep_checkpoint_findings_json() {
  local manifest_json=$1 finish_scan_json=$2 phase_findings_json=$3 change_id=$4 has_post_brief_commit=${5:-false} has_any_owned_commit=${6:-false} brief_revision_candidate=${7:-} implementation_revision_candidate=${8:-}
  jq -cn \
    --argjson manifest "$manifest_json" \
    --argjson finishScan "$finish_scan_json" \
    --argjson phaseFindings "$phase_findings_json" \
    --arg changeId "$change_id" \
    --argjson hasPostBriefCommit "$has_post_brief_commit" \
    --argjson hasAnyOwnedCommit "$has_any_owned_commit" \
    --arg briefRevisionCandidate "$brief_revision_candidate" \
    --arg implementationRevisionCandidate "$implementation_revision_candidate" '
      ($manifest.currentIterationRecord // null) as $iter
      | ($finishScan.requiredWritebacks // []) as $writebacks
      | ([ $writebacks[] | select(.severity == "blocker") ]) as $blockers
      | (($finishScan.dirtyImplementationFiles // []) | length) as $dirtyImplementationCount
      | ($iter != null and (($iter.status // "") == "brief_ready") and (($iter.briefRevision // null) == null)) as $missingBriefRevision
      | ($dirtyImplementationCount == 0 and $missingBriefRevision and ($briefRevisionCandidate != "")) as $writeBriefRevision
      | ($dirtyImplementationCount == 0 and $missingBriefRevision and ($briefRevisionCandidate == "") and $hasAnyOwnedCommit) as $missingBriefRevisionCandidate
      | ($dirtyImplementationCount == 0 and $iter != null and (($iter.status // "") == "brief_ready") and $hasPostBriefCommit) as $committedCandidate
      | ($iter != null and ((($iter.status // "") == "committed") or (($iter.status // "") == "merged") or $committedCandidate)) as $hasCommittedState
      | [
          (if $iter == null then
            {
              kind: "no_current_iteration",
              severity: "blocker",
              fixable: false,
              detail: "composed documents have no current iteration record"
            }
          else empty end),
          (if ($blockers | length) > 0 then
            {
              kind: "finish_writebacks_block_checkpoint",
              severity: "blocker",
              fixable: false,
              detail: "finish-map required writebacks must be resolved before checkpoint mutation",
              blockers: $blockers
            }
          else empty end),
          (if $dirtyImplementationCount > 0 then
            {
              kind: "commit_required_before_checkpoint",
              severity: "warning",
              fixable: false,
              detail: "implementation paths are dirty; checkpoint cannot record committed revision facts yet",
              count: $dirtyImplementationCount
            }
          else empty end),
          (if $writeBriefRevision then
            {
              kind: "write_brief_revision",
              severity: "info",
              fixable: true,
              field: "briefRevision",
              value: $briefRevisionCandidate,
              detail: "brief-ready slices need a recorded brief revision before clean history can prove implementation"
            }
          else empty end),
          (if $missingBriefRevisionCandidate then
            {
              kind: "brief_revision_missing",
              severity: "warning",
              fixable: false,
              detail: "current brief has no recorded revision and no committed brief-path history could be found"
            }
          else empty end),
          (if $committedCandidate then
            {
              kind: "mark_current_iteration_committed",
              severity: "info",
              fixable: true,
              field: "status",
              value: "committed",
              detail: "owned paths are clean and branch history contains post-brief implementation work"
            }
          else empty end),
          (if ($dirtyImplementationCount == 0 and $hasCommittedState and (($iter.implementationRevision // null) == null)) then
            {
              kind: "write_implementation_revision",
              severity: "info",
              fixable: true,
              field: "implementationRevision",
              value: (if $implementationRevisionCandidate != "" then $implementationRevisionCandidate else $changeId end)
            }
          else empty end),
          (if ($dirtyImplementationCount == 0 and $hasCommittedState and (($iter.checkpointRevision // null) == null)) then
            {
              kind: "write_checkpoint_revision",
              severity: "info",
              fixable: true,
              field: "checkpointRevision",
              value: $changeId
            }
          else empty end)
        ] + $phaseFindings
    '
}

# Checkpoint writes are limited to observable revision/phase facts;
# dirty work produces a warning, never a fake committed state.
mep_checkpoint_apply_fix() {
  local slug=$1 findings_json=$2 change_id=$3 summary=$4 brief roadmap value applied=0
  brief=$(printf '%s' "$summary" | jq -r '.currentIterationRecord.briefPath')
  brief=$(mep_abs_path "$brief")
  roadmap=$(mep_roadmap_path "$slug")

  # @provisional — frontmatter key spellings are the document-state instance.
  if printf '%s' "$findings_json" | jq -e 'any(.kind == "write_brief_revision")' >/dev/null; then
    value=$(printf '%s' "$findings_json" | jq -r '[.[] | select(.kind == "write_brief_revision") | .value][0]')
    mep_frontmatter_set "$brief" mepBriefRevision "$value" || { printf '%s\n' "$applied"; return 1; }
    applied=$((applied + 1))
  fi
  if printf '%s' "$findings_json" | jq -e 'any(.kind == "mark_current_iteration_committed")' >/dev/null; then
    mep_frontmatter_set "$brief" mepStatus committed || { printf '%s\n' "$applied"; return 1; }
    applied=$((applied + 1))
  fi
  if printf '%s' "$findings_json" | jq -e 'any(.kind == "write_implementation_revision")' >/dev/null; then
    value=$(printf '%s' "$findings_json" | jq -r '[.[] | select(.kind == "write_implementation_revision") | .value][0]')
    mep_frontmatter_set "$brief" mepImplementationRevision "$value" || { printf '%s\n' "$applied"; return 1; }
    applied=$((applied + 1))
  fi
  if printf '%s' "$findings_json" | jq -e 'any(.kind == "write_checkpoint_revision")' >/dev/null; then
    value=$(printf '%s' "$findings_json" | jq -r '[.[] | select(.kind == "write_checkpoint_revision") | .value][0] // empty')
    [[ -n "$value" ]] || value=$change_id
    mep_frontmatter_set "$brief" mepCheckpointRevision "$value" || { printf '%s\n' "$applied"; return 1; }
    applied=$((applied + 1))
  fi
  if printf '%s' "$findings_json" | jq -e 'any((.kind // .finding) == "normalize_phase_to_5")' >/dev/null; then
    mep_frontmatter_set "$roadmap" mepPhase 5 || { printf '%s\n' "$applied"; return 1; }
    applied=$((applied + 1))
  fi
  printf '%s\n' "$applied"
}

mep_checkpoint_json() {
  local slug=$1 fix=${2:-0}
  local emit_event=${3:-1}
  local state_path manifest_json finish_scan_json phase_findings_json change_id findings_json blocker_count fixable_count applied=0 legacy_state=0 has_post_brief_commit=false has_any_owned_commit=false packet event_payload brief_revision_candidate effective_brief_revision implementation_revision_candidate
  mep_require jq rg "$MEP_VCS_KIND" || return $?

  manifest_json=$(mep_state_summary_json "$slug")
  state_path=$(printf '%s' "$manifest_json" | jq -r '.path')
  if [[ "$(printf '%s' "$manifest_json" | jq -r '.exists')" != true ]]; then
    printf '{"status":"not_found","slug":%s,"statePath":%s}\n' "$(mep_json_string "$slug")" "$(mep_json_string "$state_path")"
    return 0
  fi
  if [[ "$(printf '%s' "$manifest_json" | jq '(.documentErrors // []) | length')" != 0 ]]; then
    jq -cn \
      --arg slug "$slug" \
      --arg statePath "$state_path" \
      --argjson findings "$(printf '%s' "$manifest_json" | jq -c '[.documentErrors[] | . + {severity:"blocker",fixable:false}]')" \
      '{status:"blocked",reason:"invalid_document_state",slug:$slug,statePath:$statePath,findings:$findings,blockerCount:($findings|length),appliedWritebacks:0}'
    return 0
  fi

  finish_scan_json=$(mep_finish_scan_json "$slug")
  phase_findings_json=$(mep_doctor_phase_findings_json "$manifest_json")
  change_id=$(mep_vcs_current_change_id)
  brief_revision_candidate=$(mep_current_brief_history_revision "$manifest_json")
  effective_brief_revision=$(mep_effective_brief_revision "$manifest_json")
  implementation_revision_candidate=$(mep_latest_implementation_change_since_revision "$manifest_json" "$effective_brief_revision")
  if [[ -n "$implementation_revision_candidate" ]]; then
    has_post_brief_commit=true
  fi
  if mep_has_any_implementation_commit "$manifest_json"; then
    has_any_owned_commit=true
  fi
  findings_json=$(mep_checkpoint_findings_json "$manifest_json" "$finish_scan_json" "$phase_findings_json" "$change_id" "$has_post_brief_commit" "$has_any_owned_commit" "$brief_revision_candidate" "$implementation_revision_candidate")

  # An unmigrated initiative is import-only: say so instead of advertising fixes that will not run.
  if [[ "$(printf '%s' "$manifest_json" | jq -r '.authority')" != documents ]]; then
    legacy_state=1
    findings_json=$(printf '%s' "$findings_json" | jq -c --arg path "$state_path" '
      [{
        kind: "legacy_state_read_only",
        severity: "blocker",
        fixable: false,
        detail: ("initiative state is an import-only manifest at " + $path + "; run `mep migrate` to write document frontmatter before checkpointing"),
        count: 1
      }] + [.[] | .fixable = false]
    ')
  fi

  blocker_count=$(printf '%s' "$findings_json" | jq '[.[] | select(.severity == "blocker")] | length')
  if (( legacy_state )); then
    fixable_count=0
  else
    fixable_count=$(printf '%s' "$findings_json" | jq '[.[] | select(.fixable == true or .finding == "normalize_phase_to_5")] | length')
  fi

  if (( fix && blocker_count == 0 && fixable_count > 0 && ! legacy_state )); then
    if ! applied=$(mep_checkpoint_apply_fix "$slug" "$findings_json" "$change_id" "$manifest_json"); then
      findings_json=$(printf '%s' "$findings_json" | jq -c '
        [{
          kind: "state_write_failed",
          severity: "blocker",
          fixable: false,
          detail: "checkpoint could not persist every requested document writeback"
        }] + .
      ')
      blocker_count=1
    else
      manifest_json=$(mep_state_summary_json "$slug")
      finish_scan_json=$(mep_finish_scan_json "$slug")
      phase_findings_json=$(mep_doctor_phase_findings_json "$manifest_json")
      brief_revision_candidate=$(mep_current_brief_history_revision "$manifest_json")
      effective_brief_revision=$(mep_effective_brief_revision "$manifest_json")
      implementation_revision_candidate=$(mep_latest_implementation_change_since_revision "$manifest_json" "$effective_brief_revision")
      if [[ -n "$implementation_revision_candidate" ]]; then
        has_post_brief_commit=true
      else
        has_post_brief_commit=false
      fi
      if mep_has_any_implementation_commit "$manifest_json"; then
        has_any_owned_commit=true
      else
        has_any_owned_commit=false
      fi
      findings_json=$(mep_checkpoint_findings_json "$manifest_json" "$finish_scan_json" "$phase_findings_json" "$change_id" "$has_post_brief_commit" "$has_any_owned_commit" "$brief_revision_candidate" "$implementation_revision_candidate")
      blocker_count=$(printf '%s' "$findings_json" | jq '[.[] | select(.severity == "blocker")] | length')
    fi
  fi

  packet=$(jq -cn \
    --arg slug "$slug" \
    --arg statePath "$state_path" \
    --arg changeId "$change_id" \
    --argjson findings "$findings_json" \
    --argjson blockers "$blocker_count" \
    --argjson applied "$applied" '
      {
        status: (if $blockers > 0 then "blocked" elif (($findings | length) == 0 and $applied == 0) then "clean" else "desync" end),
        slug: $slug,
        statePath: $statePath,
        currentChangeId: $changeId,
        findings: $findings,
        blockerCount: $blockers,
        appliedWritebacks: $applied
      }
    ') || return $?
  printf '%s\n' "$packet"
  if (( emit_event )); then
    event_payload=$(printf '%s' "$packet" | jq -c '{
      status,
      currentChangeId,
      blockerCount,
      appliedWritebacks,
      findingKinds: [(.findings // [])[] | (.kind // .finding)]
    }' 2>/dev/null) || event_payload=
    [[ -n "$event_payload" ]] && mep_event_append "checkpoint_evaluated" "$slug" "checkpoint" "$event_payload"
  fi
}
