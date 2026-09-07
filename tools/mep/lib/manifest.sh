#!/usr/bin/env bash

mep_manifest_path() {
  mep_abs_path "$(mep_manifest_rel "$1")"
}

mep_manifest_exists() {
  [[ -f "$(mep_manifest_path "$1")" ]]
}

mep_manifest_current_iteration_json() {
  local manifest=$1
  jq -c '
    . as $m
    | ($m.currentIteration // null) as $n
    | if $n == null then null
      else ($m.iterations // [] | map(select((.number // .n) == $n)) | .[0] // null)
      end
  ' "$manifest"
}

mep_manifest_summary_json() {
  local slug=$1 manifest
  manifest=$(mep_manifest_path "$slug")
  if [[ ! -f "$manifest" ]]; then
    printf '{"exists":false,"path":%s}\n' "$(mep_json_string "$manifest")"
    return 0
  fi

  jq -c --arg path "$manifest" '
    . as $m
    | ($m.currentIteration // null) as $n
    | {
        exists: true,
        path: $path,
        slug: ($m.slug // null),
        schemaVersion: ($m.schemaVersion // null),
        phase: ($m.phase // null),
        phaseApproved: ($m.phaseApproved // {}),
        sessionMode: ($m.sessionMode // null),
        authorshipMode: ($m.authorshipMode // "default"),
        initiativeStatus: ($m.initiativeStatus // null),
        prepDocsBootstrapped: ($m.prepDocsBootstrapped // false),
        handoffApproved: ($m.handoffApproved // false),
        currentIteration: $n,
        currentIterationRecord: (
          if $n == null then null
          else ($m.iterations // [] | map(select((.number // .n) == $n)) | .[0] // null)
          end
        ),
        ownedPaths: ($m.ownedPaths // []),
        masterPlanPath: ($m.masterPlanPath // null),
        iterations: ($m.iterations // [])
      }
  ' "$manifest"
}
