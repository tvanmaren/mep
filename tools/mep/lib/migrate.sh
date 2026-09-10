#!/usr/bin/env bash
# @provisional — one-release bridge: retires an import-only manifest by writing the same facts
# into roadmap and brief frontmatter. Deletable once no unmigrated initiative remains.

mep_migrate_roadmap_complete() {
  local roadmap=$1 slug=$2 key
  for key in \
    mepSlug mepPhase mepPrepDocsBootstrapped mepHandoffApproved \
    mepInitiativeStatus mepAuthorshipMode mepCurrentIteration mepOwnedPaths; do
    mep_frontmatter_key_present "$roadmap" "$key" || return 1
  done
  [[ "$(mep_frontmatter_value "$roadmap" mepSlug)" == "$slug" ]]
}

# Prepend a frontmatter block to a document that has none.
mep_migrate_prepend_frontmatter() {
  local file=$1 block=$2 tmp
  tmp=$(mktemp "${file}.tmp.XXXXXX") || return 1
  if [[ -f "$file" ]]; then
    cp -p "$file" "$tmp" || { rm -f "$tmp"; return 1; }
  fi
  if ! {
    printf -- '---\n'
    printf '%s\n' "$block"
    printf -- '---\n\n'
    if [[ -f "$file" ]]; then
      cat "$file"
    fi
  } >"$tmp" || ! mv "$tmp" "$file"; then
    rm -f "$tmp"
    return 1
  fi
}

mep_migrate_roadmap_frontmatter() {
  local summary_json=$1 slug=$2
  printf '%s' "$summary_json" | jq -r --arg slug "$slug" '
    [
      "mepSlug: " + ($slug | @json),
      "mepPhase: " + ((.phase // null) | tostring),
      "mepPrepDocsBootstrapped: " + ((.prepDocsBootstrapped // false) | tostring),
      "mepHandoffApproved: " + ((.handoffApproved // false) | tostring),
      "mepInitiativeStatus: " + (.initiativeStatus // "active"),
      "mepAuthorshipMode: " + (.authorshipMode // "default"),
      "mepCurrentIteration: " + ((.currentIteration // null) | tostring),
      "mepOwnedPaths: " + ((.ownedPaths // []) | tojson),
      "mepMasterPlanPath: " + ((.masterPlanPath // null) | if . == null then "null" else @json end)
    ] | join("\n")
  '
}

mep_migrate_brief_frontmatter() {
  local iteration_json=$1
  printf '%s' "$iteration_json" | jq -r '
    [
      "mepIteration: " + (.number | tostring),
      "mepTitle: " + ((.title // "") | @json),
      "mepStatus: " + (.status // "draft"),
      "mepSliceType: " + ((.sliceType // null) | tostring),
      "mepDeliveryTrack: " + ((.deliveryTrack // null) | tostring),
      "mepFanout: " + ((.fanout // null) | tostring),
      "mepBriefRevision: " + ((.briefRevision // null) | tostring),
      "mepImplementationRevision: " + ((.implementationRevision // null) | tostring),
      "mepCheckpointRevision: " + ((.checkpointRevision // null) | tostring),
      "mepImplementationPaths: " + ((.implementationPaths // []) | tojson)
    ] | join("\n")
  '
}

mep_migrate_dropped_keys_json() {
  local manifest=$1
  jq -c '
    . as $manifest
    | (
        ($manifest | keys)
        - ["slug", "phase", "prepDocsBootstrapped", "handoffApproved", "initiativeStatus",
           "authorshipMode", "currentIteration", "ownedPaths", "masterPlanPath", "iterations"]
      ) as $rootDropped
    | (
        [($manifest.iterations // [])[] | keys[]]
        | unique
        | . - ["number", "n", "title", "briefPath", "status", "sliceType", "deliveryTrack",
               "fanout", "briefRevision", "implementationRevision", "checkpointRevision",
               "implementationPaths"]
        | map("iterations[]." + .)
      ) as $iterationDropped
    | $rootDropped + $iterationDropped
  ' "$manifest"
}

mep_migrate_json() {
  local slug=$1 dry_run=${2:-0}
  local manifest roadmap summary block brief_rel brief_abs iteration_json number iteration_dir_rel written_briefs=0
  local dry_run_json=false roadmap_already=0 roadmap_already_json=false dropped_keys_json
  (( dry_run )) && dry_run_json=true

  roadmap=$(mep_roadmap_path "$slug")
  manifest=$(mep_manifest_path "$slug")
  iteration_dir_rel=$(mep_iteration_dir_rel "$slug")

  if mep_document_state_present "$roadmap"; then
    if ! mep_migrate_roadmap_complete "$roadmap" "$slug"; then
      jq -cn --arg slug "$slug" --arg path "$(mep_rel_path "$roadmap")" \
        '{status:"blocked",reason:"incomplete_roadmap_frontmatter",slug:$slug,statePath:$path}'
      return 0
    fi
    roadmap_already=1
    roadmap_already_json=true
  elif mep_frontmatter_block_invalid "$roadmap"; then
    jq -cn --arg slug "$slug" --arg path "$(mep_rel_path "$roadmap")" \
      '{status:"blocked",reason:"invalid_frontmatter_block",slug:$slug,statePath:$path}'
    return 0
  fi
  if [[ ! -f "$manifest" ]]; then
    if (( roadmap_already )); then
      jq -cn \
        --arg slug "$slug" \
        --arg path "$(mep_rel_path "$roadmap")" \
        --arg legacyPath "$(mep_rel_path "$manifest")" \
        --argjson dryRun "$dry_run_json" '{
          status:"ok",
          slug:$slug,
          statePath:$path,
          legacyStatePath:$legacyPath,
          alreadyMigrated:true,
          dryRun:$dryRun,
          written:false,
          legacyRemoved:true,
          briefsWritten:0,
          droppedKeys:[],
          detail:"document state is already authoritative; no legacy manifest remains"
        }'
      return 0
    fi
    jq -cn --arg slug "$slug" --arg path "$(mep_rel_path "$manifest")" \
      '{status:"not_found",reason:"no_legacy_manifest",slug:$slug,statePath:$path}'
    return 0
  fi

  summary=$(mep_legacy_manifest_summary_json "$manifest") || {
    jq -cn --arg slug "$slug" '{status:"blocked",reason:"invalid_manifest",slug:$slug}'
    return 0
  }

  dropped_keys_json=$(mep_migrate_dropped_keys_json "$manifest")

  # Validate every referenced brief before writing. Briefs land first; the roadmap is the authority
  # flip and therefore the final commit point. A failed run remains legacy-readable and resumable.
  while IFS= read -r iteration_json; do
    [[ -n "$iteration_json" ]] || continue
    brief_rel=$(printf '%s' "$iteration_json" | jq -r '.briefPath // ""')
    if [[ -z "$brief_rel" ]]; then
      number=$(printf '%s' "$iteration_json" | jq -r '.number // null')
      jq -cn --arg slug "$slug" --argjson n "$number" \
        '{status:"blocked",reason:"missing_brief_path",slug:$slug,iteration:$n}'
      return 0
    fi
    number=$(printf '%s' "$iteration_json" | jq -r '.number // ""')
    if [[ ! "$number" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      jq -cn --arg slug "$slug" --arg path "$brief_rel" --arg value "$number" \
        '{status:"blocked",reason:"invalid_iteration_number",slug:$slug,briefPath:$path,value:$value}'
      return 0
    fi
    brief_abs=$(mep_abs_path "$brief_rel")
    if [[ "$(dirname "$brief_rel")" != "$iteration_dir_rel" ]]; then
      jq -cn --arg slug "$slug" --arg path "$brief_rel" --arg expected "$iteration_dir_rel" \
        '{status:"blocked",reason:"brief_outside_iteration_directory",slug:$slug,briefPath:$path,expectedDirectory:$expected}'
      return 0
    fi
    if [[ ! -f "$brief_abs" ]]; then
      jq -cn --arg slug "$slug" --arg path "$brief_rel" \
        '{status:"blocked",reason:"brief_not_found",slug:$slug,briefPath:$path}'
      return 0
    fi
    if mep_frontmatter_block_invalid "$brief_abs"; then
      jq -cn --arg slug "$slug" --arg path "$brief_rel" \
        '{status:"blocked",reason:"invalid_frontmatter_block",slug:$slug,briefPath:$path}'
      return 0
    fi
    if mep_document_state_present "$brief_abs" \
      && [[ ! "$(mep_frontmatter_value "$brief_abs" mepIteration)" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      jq -cn --arg slug "$slug" --arg path "$brief_rel" \
        '{status:"blocked",reason:"invalid_brief_frontmatter",slug:$slug,briefPath:$path}'
      return 0
    fi
  done < <(printf '%s' "$summary" | jq -c '.iterations[]?')

  while IFS= read -r iteration_json; do
    [[ -n "$iteration_json" ]] || continue
    brief_rel=$(printf '%s' "$iteration_json" | jq -r '.briefPath')
    brief_abs=$(mep_abs_path "$brief_rel")
    mep_document_state_present "$brief_abs" && continue
    number=$(printf '%s' "$iteration_json" | jq -r '.number')
    written_briefs=$((written_briefs + 1))
    (( dry_run )) && continue
    mep_migrate_prepend_frontmatter "$brief_abs" "$(mep_migrate_brief_frontmatter "$iteration_json")" || {
      jq -cn --arg slug "$slug" --argjson n "$number" \
        '{status:"blocked",reason:"brief_write_failed",slug:$slug,iteration:$n}'
      return 0
    }
  done < <(printf '%s' "$summary" | jq -c '.iterations[]?')

  if (( ! dry_run && ! roadmap_already )); then
    [[ -f "$roadmap" ]] || printf '# Iteration roadmap — %s\n' "$slug" >"$roadmap"
    block=$(mep_migrate_roadmap_frontmatter "$summary" "$slug")
    mep_migrate_prepend_frontmatter "$roadmap" "$block" || {
      jq -cn --arg slug "$slug" --arg path "$(mep_rel_path "$roadmap")" \
        '{status:"blocked",reason:"state_write_failed",slug:$slug,statePath:$path}'
      return 0
    }
  fi
  if (( ! dry_run )) && ! rm -f "$manifest"; then
    jq -cn --arg slug "$slug" --arg path "$(mep_rel_path "$manifest")" \
      '{status:"blocked",reason:"legacy_retirement_failed",slug:$slug,legacyStatePath:$path}'
    return 0
  fi

  jq -cn \
    --arg slug "$slug" \
    --arg path "$(mep_rel_path "$roadmap")" \
    --arg legacyPath "$(mep_rel_path "$manifest")" \
    --argjson dryRun "$dry_run_json" \
    --argjson briefs "$written_briefs" \
    --argjson roadmapAlready "$roadmap_already_json" \
    --argjson droppedKeys "$dropped_keys_json" '
      {
        status: "ok",
        slug: $slug,
        statePath: $path,
        legacyStatePath: $legacyPath,
        alreadyMigrated: ($roadmapAlready and $briefs == 0),
        dryRun: $dryRun,
        written: (($dryRun | not) and (($briefs > 0) or ($roadmapAlready | not))),
        legacyRemoved: ($dryRun | not),
        briefsWritten: $briefs,
        droppedKeys: $droppedKeys,
        detail: "document frontmatter written; intentionally unmodeled legacy keys are listed in droppedKeys"
      }
    '
}
