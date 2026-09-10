#!/usr/bin/env bash

# Evaluation-order rows. persistence primitives live in document.sh.
mep_execution_request_json() {
  local row=$1 slug=$2 brief_path=${3:-}

  # Resolver rows, not adapter command strings, define the public execution request.
  case "$row" in
    '"precondition"'|3)
      jq -cn --arg target "$slug" '{kind:"prep",target:$target,argv:[]}'
      ;;
    '"migration"')
      jq -cn --arg target "$slug" '{kind:"migrate",target:$target,argv:[]}'
      ;;
    '"invalid_document_state"')
      jq -cn '{kind:"none",target:null,argv:[]}'
      ;;
    1)
      jq -cn '{kind:"none",target:null,argv:[]}'
      ;;
    2)
      jq -cn --arg target "$slug" '{kind:"cleanup",target:$target,argv:[]}'
      ;;
    4)
      jq -cn --arg target "$slug" '{kind:"commit_prep",target:$target,argv:["docs-bootstrap"]}'
      ;;
    5)
      jq -cn --arg target "$slug" '{kind:"commit_prep",target:$target,argv:["docs-delta"]}'
      ;;
    6|10|11)
      jq -cn --arg target "$slug" '{kind:"checkpoint",target:$target,argv:[]}'
      ;;
    7|8)
      [[ -n "$brief_path" ]] || return 70
      jq -cn --arg target "$brief_path" '{kind:"implement",target:$target,argv:[$target]}'
      ;;
    9)
      jq -cn --arg target "$slug" '{kind:"commit_prep",target:$target,argv:[]}'
      ;;
    *)
      return 70
      ;;
  esac
}

mep_resolver_context_json() {
  local status=ok row='' state='' next='' description='' reason='' warnings_json='[]' findings_json='[]'
  local proof_facts_json='{}' optional_steps_json='[]' slug='' execution_target=''
  while (( $# )); do
    case "$1" in
      --status) status=$2 ;;
      --row) row=$2 ;;
      --state) state=$2 ;;
      --next) next=$2 ;;
      --description) description=$2 ;;
      --reason) reason=$2 ;;
      --warnings-json) warnings_json=$2 ;;
      --findings-json) findings_json=$2 ;;
      --proof-facts-json) proof_facts_json=$2 ;;
      --optional-steps-json) optional_steps_json=$2 ;;
      --slug) slug=$2 ;;
      --execution-target) execution_target=$2 ;;
      *) return 2 ;;
    esac
    shift 2
  done
  [[ -n "$row" && -n "$state" && -n "$description" && -n "$reason" ]] || return 2
  jq -cn \
    --argjson row "$row" \
    --arg state "$state" \
    --arg next "$next" \
    --arg description "$description" \
    --arg reason "$reason" \
    --argjson warnings "$warnings_json" \
    --argjson findings "$findings_json" \
    --argjson proofFacts "$proof_facts_json" \
    --argjson optionalSteps "$optional_steps_json" \
    --arg status "$status" \
    --arg slug "$slug" \
    --arg executionTarget "$execution_target" \
    '{
      status: $status,
      row: $row,
      state: $state,
      next: $next,
      description: $description,
      reason: $reason,
      warnings: $warnings,
      findings: $findings,
      proofFacts: $proofFacts,
      optionalSteps: $optionalSteps,
      slug: $slug,
      executionTarget: $executionTarget
    }'
}

mep_resolver_json() {
  local context_json=$1
  local status row state next description reason warnings_json findings_json proof_facts_json optional_steps_json event_slug execution_target
  status=$(printf '%s' "$context_json" | jq -r '.status')
  row=$(printf '%s' "$context_json" | jq -c '.row')
  state=$(printf '%s' "$context_json" | jq -r '.state')
  next=$(printf '%s' "$context_json" | jq -r '.next')
  description=$(printf '%s' "$context_json" | jq -r '.description')
  reason=$(printf '%s' "$context_json" | jq -r '.reason')
  warnings_json=$(printf '%s' "$context_json" | jq -c '.warnings')
  findings_json=$(printf '%s' "$context_json" | jq -c '.findings')
  proof_facts_json=$(printf '%s' "$context_json" | jq -c '.proofFacts')
  optional_steps_json=$(printf '%s' "$context_json" | jq -c '.optionalSteps')
  event_slug=$(printf '%s' "$context_json" | jq -r '.slug')
  execution_target=$(printf '%s' "$context_json" | jq -r '.executionTarget')
  local execution_request packet
  execution_request=$(mep_execution_request_json "$row" "$event_slug" "$execution_target") || return $?
  # The resolver emits history after deriving the packet; event writes are best-effort and do not feed routing.
  packet=$(jq -cn \
    --argjson row "$row" \
    --arg state "$state" \
    --arg next "$next" \
    --arg description "$description" \
    --arg reason "$reason" \
    --argjson warnings "$warnings_json" \
    --argjson findings "$findings_json" \
    --argjson facts "$proof_facts_json" \
    --argjson optionalSteps "$optional_steps_json" \
    --argjson executionRequest "$execution_request" \
    --arg status "$status" \
    '
      ({
        status: $status,
        row: $row,
        state: $state,
        nextCommand: (if $next == "" then null else $next end),
        executionRequest: $executionRequest,
        description: $description,
        reason: $reason,
        warnings: $warnings,
        optionalSteps: $optionalSteps,
        proof: {
          version: 1,
          api: "where",
          source: "resolver",
          row: $row,
          nextCommand: (if $next == "" then null else $next end),
          executionRequest: $executionRequest,
          facts: $facts
        }
      } + if ($findings | length) == 0 then {} else {findings: $findings} end)
    ')
  printf '%s\n' "$packet"
  mep_event_emit_resolver_routed "$packet" "$event_slug" where
}

mep_where_resolver_json() {
  (( $# == 1 )) || return 2
  mep_resolver_json "$1"
}

mep_where_proof_facts_with_presentation_json() {
  local slug=$1 current_json=$2 proof_facts_json=$3
  local presentation_json
  presentation_json=$(mep_pr_body_ready_json "$slug" "$current_json")
  jq -cn \
    --argjson proof "$proof_facts_json" \
    --argjson presentation "$presentation_json" \
    '$proof + {presentation: $presentation}'
}

mep_where_row10_json() {
  local slug=$1 current_json=$2 dirty_owned_json=$3 dirty_planning_json=$4 dirty_implementation_json=$5 evidence_json=$6 predicates_json=$7 reason=$8 warnings_json=$9
  local proof_facts optional_steps
  proof_facts=$(mep_where_proof_facts_json \
    "$current_json" \
    "$dirty_owned_json" \
    "$dirty_planning_json" \
    "$dirty_implementation_json" \
    "$evidence_json" \
    "$predicates_json")
  proof_facts=$(mep_where_proof_facts_with_presentation_json "$slug" "$current_json" "$proof_facts")
  optional_steps=$(mep_pr_optional_steps_json "$slug" "$current_json")
  mep_where_resolver_json "$(mep_resolver_context_json \
    --row 10 \
    --state "slice on the branch -> review and plan next" \
    --next "/prep $slug checkpoint" \
    --description "checkpoint this slice" \
    --reason "$reason" \
    --warnings-json "$warnings_json" \
    --proof-facts-json "$proof_facts" \
    --optional-steps-json "$optional_steps" \
    --slug "$slug")"
}

mep_where_proof_facts_json() {
  local current_json=$1 dirty_owned_json=$2 dirty_planning_json=$3 dirty_implementation_json=$4 evidence_json=$5 predicates_json=$6
  jq -cn \
    --argjson current "$current_json" \
    --argjson dirtyOwned "$dirty_owned_json" \
    --argjson dirtyPlanning "$dirty_planning_json" \
    --argjson dirtyImplementation "$dirty_implementation_json" \
    --argjson evidence "$evidence_json" \
    --argjson predicates "$predicates_json" '
      {
        documents: {
          currentIterationNumber: ($current.number // null),
          currentIterationStatus: ($current.status // null),
          currentSliceType: ($current.sliceType // null),
          briefPath: ($current.briefPath // null),
          briefRevision: ($current.briefRevision // null),
          implementationRevision: ($current.implementationRevision // null),
          checkpointRevision: ($current.checkpointRevision // null)
        },
        dirty: {
          ownedCount: ($dirtyOwned | length),
          planningCount: ($dirtyPlanning | length),
          implementationCount: ($dirtyImplementation | length)
        },
        evidence: $evidence,
        predicates: $predicates
      }
    '
}

mep_has_any_implementation_commit() {
  local manifest_json=$1
  local paths=() prefix
  while IFS= read -r prefix; do
    [[ -n "$prefix" ]] && paths+=("$prefix")
  done < <(mep_implementation_path_prefixes "$manifest_json")
  (( ${#paths[@]} > 0 )) || return 1
  [[ -n "$(git log --max-count=1 --format=%H -- "${paths[@]}" 2>/dev/null)" ]]
}

mep_latest_implementation_change_since_revision() {
  local manifest_json=$1 revision=$2
  local paths=() prefix
  [[ -n "$revision" ]] || return 0
  while IFS= read -r prefix; do
    [[ -n "$prefix" ]] && paths+=("$prefix")
  done < <(mep_implementation_path_prefixes "$manifest_json")
  (( ${#paths[@]} > 0 )) || return 0
  git log --max-count=1 --format=%H "${revision}..HEAD" -- "${paths[@]}" 2>/dev/null
}

mep_current_brief_history_revision() {
  local manifest_json=$1
  local brief_path
  brief_path=$(printf '%s' "$manifest_json" | jq -r '.currentIterationRecord.briefPath // ""')
  [[ -n "$brief_path" ]] || return 0
  mep_vcs_latest_change_for_path "$brief_path"
}

mep_effective_brief_revision() {
  local manifest_json=$1
  local brief_revision
  brief_revision=$(printf '%s' "$manifest_json" | jq -r '.currentIterationRecord.briefRevision // ""')
  if [[ -n "$brief_revision" ]]; then
    printf '%s' "$brief_revision"
    return 0
  fi
  mep_current_brief_history_revision "$manifest_json"
}

mep_has_implementation_commit_since_revision() {
  local manifest_json=$1 brief_revision=$2
  [[ -n "$brief_revision" ]] || return 1
  [[ -n "$(mep_latest_implementation_change_since_revision "$manifest_json" "$brief_revision")" ]]
}

mep_has_implementation_commit_since_brief() {
  local manifest_json=$1
  local brief_revision
  brief_revision=$(mep_effective_brief_revision "$manifest_json")
  mep_has_implementation_commit_since_revision "$manifest_json" "$brief_revision"
}

mep_where_slice_implementation_landed_evidence_json() {
  local manifest_json=$1 current_json=$2 effective_brief_revision=$3 effective_brief_revision_source=$4
  local status impl_revision checkpoint_revision change_id landed=false landed_source=none post_brief=false

  status=$(printf '%s' "$current_json" | jq -r '.status // ""')
  impl_revision=$(printf '%s' "$current_json" | jq -r '.implementationRevision // ""')
  checkpoint_revision=$(printf '%s' "$current_json" | jq -r '.checkpointRevision // ""')
  change_id=$(mep_vcs_current_change_id)

  if [[ "$status" == "committed" || "$status" == "merged" ]]; then
    landed=false
    landed_source=already_committed
  elif [[ -n "$impl_revision" && "$status" == brief_ready ]]; then
    landed=true
    landed_source=triplet_brief_ready
  elif [[ -n "$impl_revision" && -n "$checkpoint_revision" && "$checkpoint_revision" != "$change_id" ]]; then
    landed=true
    landed_source=triplet_checkpoint_stale
  elif mep_has_implementation_commit_since_revision "$manifest_json" "$effective_brief_revision"; then
    landed=true
    landed_source=git_post_brief
  fi

  if [[ "$landed" == true ]]; then
    post_brief=true
  fi

  jq -cn \
    --argjson landed "$landed" \
    --arg landedSource "$landed_source" \
    --argjson hasPostBriefImplementationChange "$post_brief" \
    --arg revision "$effective_brief_revision" \
    --arg source "$effective_brief_revision_source" \
    --arg implementationRevision "$impl_revision" \
    --arg checkpointRevision "$checkpoint_revision" \
    --arg currentChangeId "$change_id" '
      {
        implementationChangeScope: "post_brief",
        hasPostBriefImplementationChange: $hasPostBriefImplementationChange,
        sliceImplementationLanded: $landed,
        landedSource: $landedSource,
        effectiveBriefRevision: (if $revision == "" then null else $revision end),
        effectiveBriefRevisionSource: $source,
        implementationRevision: (if $implementationRevision == "" then null else $implementationRevision end),
        checkpointRevision: (if $checkpointRevision == "" then null else $checkpointRevision end),
        currentChangeId: (if $currentChangeId == "" then null else $currentChangeId end)
      }
    '
}

mep_where_slice_implementation_landed() {
  local manifest_json=$1 current_json=$2 effective_brief_revision=$3
  local evidence_json landed
  evidence_json=$(mep_where_slice_implementation_landed_evidence_json "$manifest_json" "$current_json" "$effective_brief_revision" missing)
  landed=$(printf '%s' "$evidence_json" | jq -r '.sliceImplementationLanded')
  [[ "$landed" == true ]]
}

# Row 5 is a post-processor on implement routes (rows 7–8): unsaved planning docs must not
# be skipped when the lifecycle resolver would next build the slice.
mep_where_dirty_planning_blocks_implement() {
  local manifest_json=$1 current_status=$2 effective_brief_revision=$3
  [[ "$current_status" == brief_ready ]] || return 1
  if mep_where_slice_implementation_landed "$manifest_json" "$(printf '%s' "$manifest_json" | jq -c '.currentIterationRecord')" "$effective_brief_revision"; then
    return 1
  fi
  return 0
}

mep_where_emit_or_docs_delta() {
  local slug=$1 row=$2 state=$3 next=$4 description=$5 reason=$6 warnings_json=$7 proof_facts=$8
  local manifest_json=$9 current_status=${10} effective_brief_revision=${11}
  local dirty_planning_json=${12} dirty_implementation_json=${13}
  local current_json=${14} dirty_owned_json=${15}
  local brief_path=${16}

  if [[ "$row" == 7 || "$row" == 8 ]] \
    && [[ "$(printf '%s' "$dirty_planning_json" | jq 'length')" != 0 ]] \
    && [[ "$(printf '%s' "$dirty_implementation_json" | jq 'length')" == 0 ]] \
    && mep_where_dirty_planning_blocks_implement "$manifest_json" "$current_status" "$effective_brief_revision"; then
    proof_facts=$(mep_where_proof_facts_json \
      "$current_json" \
      "$dirty_owned_json" \
      "$dirty_planning_json" \
      "$dirty_implementation_json" \
      '{"dirtyScope":"planning","docsDeltaGate":"implement"}' \
      '["dirty_planning_paths","owned_implementation_paths_clean","docs_delta_gates_implement"]')
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 5 \
      --state "planning notes changed -> save them before moving on" \
      --next "/commit-prep $slug docs-delta" \
      --description "save checkpoint docs" \
      --reason "resolved implement route blocked by uncommitted planning docs for a slice that is not yet built" \
      --warnings-json "$warnings_json" \
      --proof-facts-json "$proof_facts" \
      --slug "$slug")"
    return 0
  fi

  mep_where_resolver_json "$(mep_resolver_context_json \
    --row "$row" \
    --state "$state" \
    --next "$next" \
    --description "$description" \
    --reason "$reason" \
    --warnings-json "$warnings_json" \
    --proof-facts-json "$proof_facts" \
    --slug "$slug" \
    --execution-target "$brief_path")"
}

mep_where_json() {
  local slug=$1
  local manifest_json current_json dirty_owned_json dirty_planning_json dirty_implementation_json warnings_json
  local phase initiative_status prep_bootstrapped handoff_approved current_status current_slice_type brief_path all_terminal
  local next reason proof_facts effective_brief_revision effective_brief_revision_source landed_evidence

  mep_require jq rg "$MEP_VCS_KIND" >/dev/null || return $?

  manifest_json=$(mep_state_summary_json "$slug")
  warnings_json='[]'

  if [[ "$(printf '%s' "$manifest_json" | jq -r '.exists')" != true ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row '"precondition"' \
      --state "no prep docs yet" \
      --next "/prep $slug" \
      --description "start planning this effort" \
      --reason "initiative state is absent; treating branch relevance as clean for script parity. human classification is still required when tracked work is relevant." \
      --warnings-json "$warnings_json" \
      --slug "$slug")"
    return 0
  fi

  if [[ "$(printf '%s' "$manifest_json" | jq '(.documentErrors // []) | length')" != 0 ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --status blocked \
      --row '"invalid_document_state"' \
      --state "document state is invalid" \
      --next "" \
      --description "repair roadmap or iteration frontmatter" \
      --reason "invalid_document_state" \
      --warnings-json "$warnings_json" \
      --findings-json "$(printf '%s' "$manifest_json" | jq -c '.documentErrors')" \
      --proof-facts-json '{"authority":"documents"}' \
      --slug "$slug")"
    return 0
  fi

  if [[ "$(printf '%s' "$manifest_json" | jq -r '.authority')" == legacy_import ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row '"migration"' \
      --state "legacy manifest imported read-only" \
      --next "mep migrate $slug --json" \
      --description "migrate initiative state into roadmap and brief frontmatter" \
      --reason "the one-release compatibility bridge is read-only; migrate before any state-writing workflow" \
      --warnings-json "$warnings_json" \
      --proof-facts-json '{"authority":"legacy_import"}' \
      --slug "$slug")"
    return 0
  fi

  phase=$(printf '%s' "$manifest_json" | jq -r '.phase // 0')
  initiative_status=$(printf '%s' "$manifest_json" | jq -r '.initiativeStatus // ""')
  prep_bootstrapped=$(printf '%s' "$manifest_json" | jq -r '.prepDocsBootstrapped // false')
  handoff_approved=$(printf '%s' "$manifest_json" | jq -r '.handoffApproved // false')
  current_json=$(printf '%s' "$manifest_json" | jq -c '.currentIterationRecord')
  current_status=$(printf '%s' "$current_json" | jq -r '.status // ""')
  current_slice_type=$(printf '%s' "$current_json" | jq -r '.sliceType // ""')
  brief_path=$(printf '%s' "$current_json" | jq -r '.briefPath // ""')
  effective_brief_revision=$(mep_effective_brief_revision "$manifest_json")
  if [[ -n "$(printf '%s' "$current_json" | jq -r '.briefRevision // ""')" ]]; then
    effective_brief_revision_source=document_state
  elif [[ -n "$effective_brief_revision" ]]; then
    effective_brief_revision_source=brief_history
  else
    effective_brief_revision_source=missing
  fi
  all_terminal=$(printf '%s' "$manifest_json" | jq -r '(.iterations | length > 0) and all(.iterations[]; (.status == "committed" or .status == "merged" or .status == "skipped"))')

  if [[ "$initiative_status" == graduated ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 1 \
      --state "finished" \
      --next "" \
      --description "nothing to do; the effort is done" \
      --reason "initiativeStatus is graduated" \
      --warnings-json "$warnings_json" \
      --slug "$slug")"
    return 0
  fi

  if (( phase < 5 )) && [[ "$prep_bootstrapped" != true && "$handoff_approved" != true && "$current_json" == "null" ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 3 \
      --state "still planning the effort up front" \
      --next "/prep $slug" \
      --description "continue planning" \
      --reason "document phase is less than 5" \
      --warnings-json "$warnings_json" \
      --slug "$slug")"
    return 0
  fi

  if [[ "$prep_bootstrapped" != true ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 4 \
      --state "planning done -> first save the notes" \
      --next "/commit-prep $slug docs-bootstrap" \
      --description "save the prep docs before implementation" \
      --reason "phase is 5 and prepDocsBootstrapped is false" \
      --warnings-json '["deferred by local no-commit-until-graduation policy when initiative amendments say so"]' \
      --slug "$slug")"
    return 0
  fi

  dirty_owned_json=$(mep_dirty_owned_paths_json "$manifest_json")
  dirty_planning_json=$(mep_dirty_planning_paths_json "$slug" "$dirty_owned_json" "$manifest_json")
  dirty_implementation_json=$(mep_dirty_implementation_paths_json "$slug" "$dirty_owned_json" "$manifest_json")

  if [[ "$current_status" == brief_ready && "$(printf '%s' "$dirty_implementation_json" | jq 'length')" == 0 ]]; then
    if ! mep_finish_has_open "$manifest_json"; then
      landed_evidence=$(mep_where_slice_implementation_landed_evidence_json \
        "$manifest_json" \
        "$current_json" \
        "$effective_brief_revision" \
        "$effective_brief_revision_source")
      if [[ "$(printf '%s' "$landed_evidence" | jq -r '.sliceImplementationLanded')" == true ]]; then
        mep_where_row10_json "$slug" \
          "$current_json" \
          "$dirty_owned_json" \
          "$dirty_planning_json" \
          "$dirty_implementation_json" \
          "$landed_evidence" \
          '["current_iteration_brief_ready","no_open_finish","owned_implementation_paths_clean","slice_implementation_landed"]' \
          "owned implementation paths are clean and the slice is built (revision triplet or post-brief git history)" \
          "$warnings_json"
        return 0
      fi
    fi
  fi

  if [[ "$(printf '%s' "$dirty_implementation_json" | jq 'length')" != 0 ]]; then
    proof_facts=$(mep_where_proof_facts_json \
      "$current_json" \
      "$dirty_owned_json" \
      "$dirty_planning_json" \
      "$dirty_implementation_json" \
      '{"dirtyScope":"implementation"}' \
      '["dirty_implementation_paths"]')
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 9 \
      --state "slice built -> stage and commit it" \
      --next "/commit-prep $slug" \
      --description "prepare the slice for commit" \
      --reason "owned implementation paths have uncommitted changes" \
      --warnings-json "$warnings_json" \
      --proof-facts-json "$proof_facts" \
      --slug "$slug")"
    return 0
  fi

  if [[ "$current_slice_type" == cleanup || "$all_terminal" == true ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 2 \
      --state "all slices done -> final cleanup" \
      --next "/prep-cleanup $slug" \
      --description "finish the effort" \
      --reason "current iteration is cleanup or every iteration is committed/merged and no scoped dirty state remains" \
      --warnings-json "$warnings_json" \
      --slug "$slug")"
    return 0
  fi

  if [[ "$current_status" == pending || "$current_status" == "" ]]; then
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 6 \
      --state "the next slice has no plan yet -> draft it" \
      --next "/prep $slug checkpoint" \
      --description "draft the next slice plan" \
      --reason "current iteration status is pending or missing" \
      --warnings-json "$warnings_json" \
      --slug "$slug")"
    return 0
  fi

  if [[ "$current_status" == brief_ready ]]; then
    if mep_finish_has_open "$manifest_json"; then
      proof_facts=$(mep_where_proof_facts_json \
        "$current_json" \
        "$dirty_owned_json" \
        "$dirty_planning_json" \
        "$dirty_implementation_json" \
        '{"finishState":"open"}' \
        '["current_iteration_brief_ready","open_finish_markers"]')
      mep_where_emit_or_docs_delta "$slug" 8 \
        "the slice has an unmade decision -> author the open finish(es) before it can be committed" \
        "/implement-plan $brief_path" \
        "finish the open decision work" \
        "owned paths contain @finish:open" \
        "$warnings_json" \
        "$proof_facts" \
        "$manifest_json" \
        "$current_status" \
        "$effective_brief_revision" \
        "$dirty_planning_json" \
        "$dirty_implementation_json" \
        "$current_json" \
        "$dirty_owned_json" \
        "$brief_path"
      return 0
    fi
    landed_evidence=$(mep_where_slice_implementation_landed_evidence_json \
      "$manifest_json" \
      "$current_json" \
      "$effective_brief_revision" \
      "$effective_brief_revision_source")
    if [[ "$(printf '%s' "$landed_evidence" | jq -r '.sliceImplementationLanded')" == true ]]; then
      mep_where_row10_json "$slug" \
        "$current_json" \
        "$dirty_owned_json" \
        "$dirty_planning_json" \
        "$dirty_implementation_json" \
        "$landed_evidence" \
        '["current_iteration_brief_ready","no_open_finish","owned_paths_clean","slice_implementation_landed"]' \
        "owned implementation paths are clean and the slice is built (revision triplet or post-brief git history)" \
        "$warnings_json"
      return 0
    fi
    proof_facts=$(mep_where_proof_facts_json \
      "$current_json" \
      "$dirty_owned_json" \
      "$dirty_planning_json" \
      "$dirty_implementation_json" \
      "$(jq -cn --arg revision "$effective_brief_revision" --arg source "$effective_brief_revision_source" '{implementationChangeScope:"post_brief",hasPostBriefImplementationChange:false,sliceImplementationLanded:false,landedSource:"not_landed",effectiveBriefRevision:(if $revision == "" then null else $revision end),effectiveBriefRevisionSource:$source}')" \
      '["current_iteration_brief_ready","no_open_finish","owned_paths_clean","slice_not_yet_built"]')
    mep_where_emit_or_docs_delta "$slug" 7 \
      "plan is ready -> build the slice" \
      "/implement-plan $brief_path" \
      "build the planned slice" \
      "current iteration is brief_ready, owned paths are clean, and the slice is not yet built" \
      "$warnings_json" \
      "$proof_facts" \
      "$manifest_json" \
      "$current_status" \
      "$effective_brief_revision" \
      "$dirty_planning_json" \
      "$dirty_implementation_json" \
      "$current_json" \
      "$dirty_owned_json" \
      "$brief_path"
    return 0
  fi

  if [[ "$current_status" != committed && "$current_status" != merged ]]; then
    if mep_finish_has_open "$manifest_json"; then
      mep_where_resolver_json "$(mep_resolver_context_json \
        --row 8 \
        --state "the slice has an unmade decision -> author the open finish(es) before it can be committed" \
        --next "/implement-plan $brief_path" \
        --description "finish the open decision work" \
        --reason "owned paths contain @finish:open" \
        --warnings-json "$warnings_json" \
        --slug "$slug" \
        --execution-target "$brief_path")"
      return 0
    fi
    mep_where_resolver_json "$(mep_resolver_context_json \
      --row 10 \
      --state "slice on the branch -> review and plan next" \
      --next "/prep $slug checkpoint" \
      --description "checkpoint this slice" \
      --reason "owned paths are clean after implementation-status rows" \
      --warnings-json "$warnings_json" \
      --slug "$slug")"
    return 0
  fi

  mep_where_resolver_json "$(mep_resolver_context_json \
    --row 11 \
    --state "this slice is done -> review and plan the next" \
    --next "/prep $slug checkpoint" \
    --description "checkpoint and plan the next slice" \
    --reason "current iteration status is committed or merged while later work remains" \
    --warnings-json "$warnings_json" \
    --slug "$slug")"
}
