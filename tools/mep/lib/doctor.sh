#!/usr/bin/env bash

mep_doctor_iteration_findings_json() {
  local manifest=$1 merged_truth=$2
  jq -c --argjson mergedTruth "$merged_truth" '
    [
      (.iterations // [])[]
      | select((.status == "merged" and ($mergedTruth | not)) or (.status == "committed" and $mergedTruth))
      | {
          n,
          title: (.title // null),
          status,
          finding: (if .status == "merged" then "false_merged" else "promote_to_merged" end)
        }
    ]
  ' "$manifest"
}

mep_doctor_phase_findings_json() {
  local manifest=$1
  jq -c '
    (.phase // 0) as $phase
    | (
        ((.phaseApproved["5"] // false) == true)
        or ((.handoffApproved // false) == true)
        or ((.prepDocsBootstrapped // false) == true)
        or ((.currentIteration // null) != null)
        or (((.sessionMode // "") == "checkpoint") and (((.iterations // []) | length) > 0))
      ) as $pastPlanning
    | if ($phase < 5 and $pastPlanning) then
        [{
          finding: "normalize_phase_to_5",
          currentPhase: $phase,
          targetPhase: 5,
          reason: "manifest contains handoff/bootstrap/checkpoint iteration evidence past upfront planning"
        }]
      else [] end
  ' "$manifest"
}

mep_doctor_manifest_report_json() {
  local manifest=$1 merged_truth=$2 iteration_findings phase_findings
  iteration_findings=$(mep_doctor_iteration_findings_json "$manifest" "$merged_truth")
  phase_findings=$(mep_doctor_phase_findings_json "$manifest")
  jq -cn --argjson iterationFindings "$iteration_findings" --argjson phaseFindings "$phase_findings" '
    $iterationFindings + $phaseFindings
  '
}

mep_doctor_apply_promotions() {
  local manifest=$1 tmp
  tmp=$(mktemp)
  jq '
    .iterations = ((.iterations // []) | map(if .status == "committed" then .status = "merged" else . end))
  ' "$manifest" > "$tmp"
  mv "$tmp" "$manifest"
}

mep_doctor_apply_phase_normalization() {
  local manifest=$1 tmp
  tmp=$(mktemp)
  jq '
    .phase = 5
    | .phaseApproved = (.phaseApproved // {})
    | .phaseApproved["1"] = true
    | .phaseApproved["2"] = true
    | .phaseApproved["3"] = true
    | .phaseApproved["4"] = true
    | .phaseApproved["5"] = true
  ' "$manifest" > "$tmp"
  mv "$tmp" "$manifest"
}

mep_doctor_json() {
  local slug=$1 fix=${2:-0} trunk=${3:-$MEP_VCS_DEFAULT_TRUNK}
  local manifest merged_truth=false findings applied=0 applied_phase=0 false_count promote_count phase_count

  mep_require jq "$MEP_VCS_KIND" >/dev/null || return $?

  manifest=$(mep_manifest_path "$slug")
  if [[ ! -f "$manifest" ]]; then
    printf '{"status":"not_found","slug":%s,"manifest":%s}\n' "$(mep_json_string "$slug")" "$(mep_json_string "$manifest")"
    return 2
  fi

  if ! git rev-parse --verify --quiet "$trunk^{commit}" >/dev/null; then
    printf '{"status":"error","slug":%s,"error":"trunk_not_found","trunk":%s}\n' "$(mep_json_string "$slug")" "$(mep_json_string "$trunk")"
    return 2
  fi

  if mep_vcs_is_current_change_in_trunk "$trunk"; then
    merged_truth=true
  fi

  findings=$(mep_doctor_manifest_report_json "$manifest" "$merged_truth")
  false_count=$(printf '%s' "$findings" | jq '[.[] | select(.finding == "false_merged")] | length')
  promote_count=$(printf '%s' "$findings" | jq '[.[] | select(.finding == "promote_to_merged")] | length')
  phase_count=$(printf '%s' "$findings" | jq '[.[] | select(.finding == "normalize_phase_to_5")] | length')

  if (( fix && promote_count > 0 )); then
    mep_doctor_apply_promotions "$manifest"
    applied=$promote_count
  fi
  if (( fix && phase_count > 0 )); then
    mep_doctor_apply_phase_normalization "$manifest"
    applied_phase=$phase_count
  fi
  if (( fix && (promote_count > 0 || phase_count > 0) )); then
    findings=$(mep_doctor_manifest_report_json "$manifest" "$merged_truth")
  fi

  jq -cn \
    --arg slug "$slug" \
    --arg manifest "$manifest" \
    --arg trunk "$trunk" \
    --argjson mergedTruth "$merged_truth" \
    --argjson findings "$findings" \
    --argjson applied "$applied" \
    --argjson appliedPhase "$applied_phase" \
    --argjson falseCount "$false_count" \
    --argjson promoteCount "$promote_count" \
    --argjson phaseCount "$phase_count" '
      {
        status: (if (($findings | length) == 0 and $applied == 0 and $appliedPhase == 0) then "clean" else "desync" end),
        slug: $slug,
        manifest: $manifest,
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
