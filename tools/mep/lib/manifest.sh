#!/usr/bin/env bash

mep_manifest_path() {
  mep_abs_path "$(mep_manifest_rel "$1")"
}

# One-release importer; document-native callers consume its normalized state shape.
mep_legacy_manifest_summary_json() {
  local manifest=$1
  jq -c --arg path "$manifest" '
    . as $m
    | ($m.currentIteration // null) as $n
    | [
        ($m.iterations // [])[]
        | {
            number: ((.number // .n) // null),
            briefPath: (.briefPath // null)
          }
          + (if (.title // null) == null then {} else {title} end)
          + (if (.status // null) == null then {} else {status} end)
          + (if (.sliceType // null) == null then {} else {sliceType} end)
          + (if (.deliveryTrack // null) == null then {} else {deliveryTrack} end)
          + (if (.fanout // null) == null then {} else {fanout} end)
          + (if (.briefRevision // null) == null then {} else {briefRevision} end)
          + (if (.implementationRevision // null) == null then {} else {implementationRevision} end)
          + (if (.checkpointRevision // null) == null then {} else {checkpointRevision} end)
          + (if ((.implementationPaths // []) | length) == 0 then {} else {implementationPaths} end)
      ] as $iterations
    | {
        exists: true,
        authority: "legacy_import",
        path: $path,
        slug: ($m.slug // null),
        schemaVersion: ($m.schemaVersion // null),
        phase: ($m.phase // null),
        authorshipMode: ($m.authorshipMode // "default"),
        initiativeStatus: ($m.initiativeStatus // null),
        prepDocsBootstrapped: ($m.prepDocsBootstrapped // false),
        handoffApproved: ($m.handoffApproved // false),
        currentIteration: $n,
        currentIterationRecord: (
          if $n == null then null
          else ($iterations | map(select(.number == $n)) | .[0] // null)
          end
        ),
        ownedPaths: ($m.ownedPaths // []),
        masterPlanPath: ($m.masterPlanPath // null),
        iterations: $iterations
      }
  ' "$manifest"
}
