#!/usr/bin/env bash

mep_doctor_iteration_findings_json() {
  local summary_json=$1 merged_truth=$2
  printf '%s' "$summary_json" | jq -c --argjson mergedTruth "$merged_truth" '
    [
      (.iterations // [])[]
      | select((.status == "merged" and ($mergedTruth | not)) or (.status == "committed" and $mergedTruth))
      | {
          number: (.number // null),
          title: (.title // null),
          status,
          finding: (if .status == "merged" then "false_merged" else "promote_to_merged" end)
        }
    ]
  '
}

mep_doctor_phase_findings_json() {
  local summary_json=$1
  printf '%s' "$summary_json" | jq -c '
    (.phase // 0) as $phase
    | (
        ((.handoffApproved // false) == true)
        or ((.prepDocsBootstrapped // false) == true)
        or ((.currentIteration // null) != null)
      ) as $pastPlanning
    | if ($phase < 5 and $pastPlanning) then
        [{
          finding: "normalize_phase_to_5",
          currentPhase: $phase,
          targetPhase: 5,
          reason: "initiative documents contain handoff/bootstrap/checkpoint evidence past upfront planning"
        }]
      else [] end
  '
}

mep_doctor_state_report_json() {
  local summary_json=$1 merged_truth=$2 iteration_findings phase_findings
  iteration_findings=$(mep_doctor_iteration_findings_json "$summary_json" "$merged_truth")
  phase_findings=$(mep_doctor_phase_findings_json "$summary_json")
  jq -cn --argjson iterationFindings "$iteration_findings" --argjson phaseFindings "$phase_findings" '
    $iterationFindings + $phaseFindings
  '
}

mep_doctor_apply_promotions() {
  local summary_json=$1 brief applied=0
  while IFS= read -r brief; do
    [[ -n "$brief" ]] || continue
    mep_frontmatter_set "$(mep_abs_path "$brief")" mepStatus merged || { printf '%s\n' "$applied"; return 1; }
    applied=$((applied + 1))
  done < <(printf '%s' "$summary_json" | jq -r '.iterations[] | select(.status == "committed") | .briefPath')
  printf '%s\n' "$applied"
}

mep_doctor_apply_phase_normalization() {
  local slug=$1
  mep_frontmatter_set "$(mep_roadmap_path "$slug")" mepPhase 5
}

mep_doctor_json() {
  local slug=$1 fix=${2:-0} trunk=${3:-$MEP_VCS_DEFAULT_TRUNK}
  local state_path summary_json merged_truth=false findings applied=0 applied_phase=0 false_count promote_count phase_count legacy_state=0 legacy_state_json=false

  mep_require jq "$MEP_VCS_KIND" >/dev/null || return $?

  summary_json=$(mep_state_summary_json "$slug")
  state_path=$(printf '%s' "$summary_json" | jq -r '.path')
  if [[ "$(printf '%s' "$summary_json" | jq -r '.exists')" != true ]]; then
    printf '{"status":"not_found","slug":%s,"statePath":%s}\n' "$(mep_json_string "$slug")" "$(mep_json_string "$state_path")"
    return 0
  fi
  if [[ "$(printf '%s' "$summary_json" | jq '(.documentErrors // []) | length')" != 0 ]]; then
    jq -cn \
      --arg slug "$slug" \
      --arg statePath "$state_path" \
      --argjson findings "$(printf '%s' "$summary_json" | jq -c '.documentErrors')" \
      '{status:"blocked",reason:"invalid_document_state",slug:$slug,statePath:$statePath,findings:$findings,appliedPromotions:0,appliedPhaseNormalizations:0}'
    return 0
  fi

  if ! git rev-parse --verify --quiet "$trunk^{commit}" >/dev/null; then
    printf '{"status":"not_found","slug":%s,"reason":"trunk_not_found","trunk":%s}\n' "$(mep_json_string "$slug")" "$(mep_json_string "$trunk")"
    return 0
  fi

  if mep_vcs_is_current_change_in_trunk "$trunk"; then
    merged_truth=true
  fi

  findings=$(mep_doctor_state_report_json "$summary_json" "$merged_truth")

  # Import-only state cannot be reconciled in place; name the reason rather than no-op under --fix.
  [[ "$(printf '%s' "$summary_json" | jq -r '.authority')" == documents ]] || legacy_state=1
  (( legacy_state )) && legacy_state_json=true
  if (( legacy_state )); then
    findings=$(printf '%s' "$findings" | jq -c --arg path "$state_path" '
      [{
        finding: "legacy_state_read_only",
        detail: ("initiative state is an import-only manifest at " + $path + "; run `mep migrate` to write document frontmatter before reconciling")
      }] + .
    ')
  fi

  false_count=$(printf '%s' "$findings" | jq '[.[] | select(.finding == "false_merged")] | length')
  promote_count=$(printf '%s' "$findings" | jq '[.[] | select(.finding == "promote_to_merged")] | length')
  phase_count=$(printf '%s' "$findings" | jq '[.[] | select(.finding == "normalize_phase_to_5")] | length')

  if (( fix && ! legacy_state && promote_count > 0 )); then
    if ! applied=$(mep_doctor_apply_promotions "$summary_json"); then
      jq -cn --arg slug "$slug" --arg statePath "$state_path" --argjson applied "$applied" \
        '{status:"blocked",reason:"state_write_failed",slug:$slug,statePath:$statePath,appliedPromotions:$applied,appliedPhaseNormalizations:0}'
      return 0
    fi
  fi
  if (( fix && ! legacy_state && phase_count > 0 )); then
    if ! mep_doctor_apply_phase_normalization "$slug"; then
      jq -cn --arg slug "$slug" --arg statePath "$state_path" --argjson applied "$applied" \
        '{status:"blocked",reason:"state_write_failed",slug:$slug,statePath:$statePath,appliedPromotions:$applied,appliedPhaseNormalizations:0}'
      return 0
    fi
    applied_phase=$phase_count
  fi
  # Only re-read after writes actually happened, or the refusal above would recompute itself away.
  if (( fix && ! legacy_state && (promote_count > 0 || phase_count > 0) )); then
    summary_json=$(mep_state_summary_json "$slug")
    findings=$(mep_doctor_state_report_json "$summary_json" "$merged_truth")
  fi

  jq -cn \
    --arg slug "$slug" \
    --arg statePath "$state_path" \
    --arg trunk "$trunk" \
    --argjson mergedTruth "$merged_truth" \
    --argjson findings "$findings" \
    --argjson applied "$applied" \
    --argjson appliedPhase "$applied_phase" \
    --argjson falseCount "$false_count" \
    --argjson promoteCount "$promote_count" \
    --argjson phaseCount "$phase_count" \
    --argjson legacyState "$legacy_state_json" '
      {
        status: (
          if $legacyState then "blocked"
          elif (($findings | length) == 0 and $applied == 0 and $appliedPhase == 0) then "clean"
          else "desync" end
        ),
        slug: $slug,
        statePath: $statePath,
        trunk: $trunk,
        branchInTrunk: $mergedTruth,
        findings: $findings,
        appliedPromotions: $applied,
        appliedPhaseNormalizations: $appliedPhase,
        falseMergedCount: $falseCount,
        promotionCandidateCount: $promoteCount,
        phaseNormalizationCandidateCount: $phaseCount
      }
    '
}
