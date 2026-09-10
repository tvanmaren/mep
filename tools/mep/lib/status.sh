#!/usr/bin/env bash

mep_path_prefix_for_git() {
  local p=$1
  case "$p" in
    *"*"*)
      p=${p%%\**}
      p=${p%/}
      [[ -n "$p" ]] && printf '%s' "$p"
      ;;
    *)
      printf '%s' "$p"
      ;;
  esac
}

mep_dirty_owned_paths_json() {
  local manifest_json=$1
  local dirty_paths=() owned_paths=() matches=() dirty owned
  mapfile -t dirty_paths < <(mep_vcs_dirty_paths)
  mapfile -t owned_paths < <(printf '%s' "$manifest_json" | jq -r '.ownedPaths[]?')

  for dirty in "${dirty_paths[@]}"; do
    [[ -n "$dirty" ]] || continue
    for owned in "${owned_paths[@]}"; do
      [[ -n "$owned" ]] || continue
      if mep_owned_path_matches_dirty "$owned" "$dirty"; then
        matches+=("$dirty")
        break
      fi
    done
  done

  printf '%s\n' "${matches[@]}" | mep_json_string_array_from_lines
}

mep_path_is_under_root() {
  local path=$1 root=$2
  path=${path#./}
  root=${root#./}
  root=${root%/}

  [[ -n "$root" ]] || return 1
  [[ "$path" == "$root" || "$path" == "$root/"* ]]
}

mep_configured_planning_path() {
  local path=$1 slug=${2:-}
  local roots=(
    "$MEP_STORAGE_PLANS_ROOT"
    "$MEP_STORAGE_ARCHITECTURE_ROOT"
    "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT"
  )
  local root

  if [[ -n "$slug" ]]; then
    roots+=("$MEP_STORAGE_PREP_ROOT/$slug")
  else
    roots+=("$MEP_STORAGE_PREP_ROOT")
  fi

  for root in "${roots[@]}"; do
    if mep_path_is_under_root "$path" "$root"; then
      return 0
    fi
  done
  return 1
}

mep_effective_implementation_paths_json() {
  local manifest_json=$1
  printf '%s' "$manifest_json" | jq -c '
    (.currentIterationRecord.implementationPaths // []) as $iterationPaths
    | if ($iterationPaths | length) > 0 then $iterationPaths else (.ownedPaths // []) end
  '
}

mep_has_current_iteration_implementation_paths() {
  local manifest_json=$1
  [[ "$(printf '%s' "$manifest_json" | jq '(.currentIterationRecord.implementationPaths // []) | length')" != 0 ]]
}

mep_path_is_current_implementation() {
  local manifest_json=$1 path=$2 implementation_paths_json
  if mep_has_current_iteration_implementation_paths "$manifest_json"; then
    implementation_paths_json=$(mep_effective_implementation_paths_json "$manifest_json")
    mep_path_matches_any_pathspec_json "$path" "$implementation_paths_json"
    return
  fi
  ! mep_configured_planning_path "$path"
}

mep_implementation_path_prefixes() {
  local manifest_json=$1
  local implementation_paths_json owned prefix

  implementation_paths_json=$(mep_effective_implementation_paths_json "$manifest_json")
  while IFS= read -r owned; do
    [[ -n "$owned" ]] || continue
    prefix=$(mep_path_prefix_for_git "$owned")
    if ! mep_has_current_iteration_implementation_paths "$manifest_json" && ! mep_path_is_current_implementation "$manifest_json" "$prefix"; then
      continue
    fi
    [[ -n "$prefix" ]] && printf '%s\n' "$prefix"
  done < <(printf '%s' "$implementation_paths_json" | jq -r '.[]?')
}

mep_path_matches_any_pathspec_json() {
  local path=$1 paths_json=$2 owned
  while IFS= read -r owned; do
    [[ -n "$owned" ]] || continue
    if mep_owned_path_matches_dirty "$owned" "$path"; then
      return 0
    fi
  done < <(printf '%s' "$paths_json" | jq -r '.[]?')
  return 1
}

mep_dirty_implementation_paths_json() {
  local slug=$1 dirty_owned_json=$2 manifest_json=${3:-} dirty
  while IFS= read -r dirty; do
    [[ -n "$dirty" ]] || continue
    if [[ -n "$manifest_json" ]] && mep_path_is_current_implementation "$manifest_json" "$dirty"; then
      printf '%s\n' "$dirty"
    elif [[ -z "$manifest_json" ]] && ! mep_configured_planning_path "$dirty" "$slug"; then
      printf '%s\n' "$dirty"
    fi
  done < <(printf '%s' "$dirty_owned_json" | jq -r '.[]?') | mep_json_string_array_from_lines
}

mep_dirty_planning_paths_json() {
  local slug=$1 dirty_owned_json=$2 manifest_json=${3:-} dirty
  {
    mep_vcs_dirty_paths "$MEP_STORAGE_PREP_ROOT/$slug"
    while IFS= read -r dirty; do
      [[ -n "$dirty" ]] || continue
      if mep_configured_planning_path "$dirty" "$slug"; then
        printf '%s\n' "$dirty"
      fi
    done < <(printf '%s' "$dirty_owned_json" | jq -r '.[]?')
  } | while IFS= read -r dirty; do
    [[ -n "$dirty" ]] || continue
    if [[ -n "$manifest_json" ]] && ! mep_path_is_current_implementation "$manifest_json" "$dirty"; then
      printf '%s\n' "$dirty"
    elif [[ -z "$manifest_json" ]]; then
      printf '%s\n' "$dirty"
    fi
  done | sort -u | mep_json_string_array_from_lines
}

mep_owned_path_matches_dirty() {
  local owned=$1 dirty=$2 prefix
  owned=${owned#./}
  dirty=${dirty#./}

  case "$owned" in
    *"*"*|*"?"*|*"["*)
      # shellcheck disable=SC2053 # owned is intentionally a configured glob.
      if [[ "$dirty" == $owned ]]; then
        return 0
      fi
      prefix=${owned%%[\*\?\[]*}
      [[ "$dirty" == */ && -n "$prefix" && "$prefix" == "$dirty"* ]]
      return
      ;;
    */)
      [[ "$dirty" == "$owned"* || ( "$dirty" == */ && "$owned" == "$dirty"* ) ]]
      return
      ;;
    *)
      [[ "$dirty" == "$owned" ]]
      return
      ;;
  esac
}

mep_dirty_prep_paths_json() {
  local slug=$1
  local prep_path
  prep_path="$MEP_STORAGE_PREP_ROOT/$slug"
  mep_vcs_dirty_paths "$prep_path" | mep_json_string_array_from_lines
}

mep_status_warnings_json() {
  local config_errors_json=$1 manifest_json=$2
  jq -cn \
    --argjson configErrors "$config_errors_json" \
    --argjson manifest "$manifest_json" '
      [
        (if ($configErrors | length) > 0 then "config has errors" else empty end),
        (if ($manifest.exists | not) then "initiative documents not found" else empty end),
        (if (($manifest.prepDocsBootstrapped // false) == false) then "prep docs not bootstrapped" else empty end)
      ]
    '
}

mep_routing_proof_json() {
  local manifest_json=$1 dirty_prep_json=$2 dirty_owned_json=$3 dirty_planning_json=${4:-[]} dirty_implementation_json=${5:-[]}
  jq -cn \
    --argjson manifest "$manifest_json" \
    --argjson dirtyPrep "$dirty_prep_json" \
    --argjson dirtyOwned "$dirty_owned_json" \
    --argjson dirtyPlanning "$dirty_planning_json" \
    --argjson dirtyImplementation "$dirty_implementation_json" '
      ($manifest.currentIterationRecord // {}) as $iter
      | {
          briefRevision: ($iter.briefRevision // null),
          implementationRevision: ($iter.implementationRevision // null),
          checkpointRevision: ($iter.checkpointRevision // null)
        } as $provenance
      | if ($manifest.exists | not) then
        {
          source: "heuristic",
          row: "precondition",
          reason: "initiative state is absent; relevance classification remains human-owned"
        }
      elif (($provenance.briefRevision != null) or ($provenance.implementationRevision != null) or ($provenance.checkpointRevision != null)) then
        {
          source: "document_revision_provenance",
          row: null,
          reason: "current iteration carries revision-neutral route provenance",
          provenance: $provenance
        }
      elif (($manifest.prepDocsBootstrapped // false) == false) then
        {
          source: "heuristic",
          row: 4,
          reason: "phase is complete enough for handoff but prep docs are not bootstrapped",
          deferredByPolicy: true
        }
      else
        {
          source: "heuristic",
          row: null,
          reason: "gate-1 compact status does not implement full resolver parity"
        }
      end
      + {
        provenance: $provenance,
        dirtyPrepCount: ($dirtyPrep | length),
        dirtyOwnedCount: ($dirtyOwned | length),
        dirtyPlanningCount: ($dirtyPlanning | length),
        dirtyImplementationCount: ($dirtyImplementation | length)
      }
    '
}

mep_status_compact_json() {
  local slug=$1
  local deps_json optional_deps_json manifest_json paths_json vcs_json dirty_prep_json dirty_owned_json dirty_planning_json dirty_implementation_json warnings_json routing_json config_errors_json finish_markers_json required_writebacks_json

  mep_require jq rg "$MEP_VCS_KIND" || return $?

  deps_json=$(mep_dependency_report_json "$MEP_VCS_KIND")
  optional_deps_json=$(mep_optional_dependency_report_json gh jj)
  manifest_json=$(mep_state_summary_json "$slug")
  paths_json=$(mep_paths_json "$slug")
  vcs_json=$(mep_vcs_summary_json "$MEP_VCS_DEFAULT_TRUNK")
  dirty_prep_json=$(mep_dirty_prep_paths_json "$slug")
  dirty_owned_json=$(mep_dirty_owned_paths_json "$manifest_json")
  dirty_planning_json=$(mep_dirty_planning_paths_json "$slug" "$dirty_owned_json" "$manifest_json")
  dirty_implementation_json=$(mep_dirty_implementation_paths_json "$slug" "$dirty_owned_json" "$manifest_json")
  finish_markers_json=$(mep_finish_marker_lines_json "$manifest_json")
  required_writebacks_json=$(mep_finish_required_writebacks_json "$manifest_json" "$finish_markers_json" "$dirty_implementation_json")
  config_errors_json=$(mep_config_errors_json)
  warnings_json=$(mep_status_warnings_json "$config_errors_json" "$manifest_json")
  routing_json=$(mep_routing_proof_json "$manifest_json" "$dirty_prep_json" "$dirty_owned_json" "$dirty_planning_json" "$dirty_implementation_json")

  jq -cn \
    --arg slug "$slug" \
    --argjson config "$(mep_config_dump_json)" \
    --argjson paths "$paths_json" \
    --argjson dependencies "$deps_json" \
    --argjson optionalDependencies "$optional_deps_json" \
    --argjson manifest "$manifest_json" \
    --argjson vcs "$vcs_json" \
    --argjson dirtyPrepFiles "$dirty_prep_json" \
    --argjson dirtyOwnedFiles "$dirty_owned_json" \
    --argjson dirtyPlanningFiles "$dirty_planning_json" \
    --argjson dirtyImplementationFiles "$dirty_implementation_json" \
    --argjson warnings "$warnings_json" \
    --argjson routingProof "$routing_json" \
    --argjson requiredWritebacks "$required_writebacks_json" '
      {
        status: "ok",
        slug: $slug,
        config: $config,
        paths: $paths,
        dependencies: $dependencies,
        optionalDependencies: $optionalDependencies,
        initiative: $manifest,
        vcs: $vcs,
        dirtyPrepFiles: $dirtyPrepFiles,
        dirtyOwnedFiles: $dirtyOwnedFiles,
        dirtyPlanningFiles: $dirtyPlanningFiles,
        dirtyImplementationFiles: $dirtyImplementationFiles,
        warnings: $warnings,
        routingProof: $routingProof,
        requiredWritebacks: $requiredWritebacks
      }
    '
}
