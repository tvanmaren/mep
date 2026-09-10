#!/usr/bin/env bash

# @stable — public persistence primitives. the mutable ledger is plan documents, not a sidecar.
mep_roadmap_path() {
  mep_abs_path "$(mep_roadmap_rel "$1")"
}

mep_frontmatter_value() {
  local file=$1 key=$2 value
  # A literal `null` is the templates' way of showing an unset key; it reads as absent, never as a
  # value. Without this, `mepBriefRevision: null` would be recorded as the revision string "null".
  value=$(awk -v key="$key" '
    NR == 1 && $0 == "---" { frontmatter = 1; next }
    frontmatter && $0 == "---" { exit }
    frontmatter && index($0, key ":") == 1 {
      value = substr($0, length(key) + 2)
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      if (value == "null" || value == "~") { exit }
      print value
      exit
    }
  ' "$file")
  [[ -n "$value" ]] || return 0
  if [[ "$value" == \"* ]] && printf '%s' "$value" | jq -e 'type == "string"' >/dev/null 2>&1; then
    printf '%s' "$value" | jq -r '.'
  else
    printf '%s\n' "$value"
  fi
}

mep_frontmatter_key_has_empty_value() {
  local file=$1 key=$2
  awk -v key="$key" '
    NR == 1 && $0 == "---" { frontmatter = 1; next }
    frontmatter && $0 == "---" { exit }
    frontmatter && $0 ~ ("^" key ":[[:space:]]*$") { found = 1; exit }
    END { exit (found ? 0 : 1) }
  ' "$file"
}

mep_frontmatter_key_present() {
  local file=$1 key=$2
  mep_document_state_present "$file" || return 1
  awk -v key="$key" '
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm && $0 == "---" { exit(found ? 0 : 1) }
    in_fm && index($0, key ":") == 1 { found=1 }
    END { if (!found) exit 1 }
  ' "$file"
}

mep_frontmatter_set() {
  local file=$1 key=$2 value=$3 tmp
  # Fail loudly rather than succeed as a no-op: a document with no frontmatter block has nowhere to
  # put the key, and every caller treats a zero exit as "the state is now on disk".
  mep_document_state_present "$file" || return 1
  tmp=$(mktemp "${file}.tmp.XXXXXX") || return 1
  cp -p "$file" "$tmp" || { rm -f "$tmp"; return 1; }
  if ! awk -v key="$key" -v value="$value" '
    NR == 1 && $0 == "---" { frontmatter = 1 }
    frontmatter && index($0, key ":") == 1 {
      print key ": " value
      found = 1
      next
    }
    frontmatter && $0 == "---" && NR > 1 && !found {
      print key ": " value
      found = 1
    }
    frontmatter && $0 == "---" && NR > 1 { frontmatter = 0 }
    { print }
  ' "$file" >"$tmp" || ! mv "$tmp" "$file"; then
    rm -f "$tmp"
    return 1
  fi
}

# @stable — document authority requires an actual frontmatter block, not merely a roadmap file.
# Every pre-migration initiative has an `04-iteration-roadmap.md` with no frontmatter; those must
# fall through to the legacy importer instead of resolving to an empty cursor.
mep_document_state_present() {
  local file=$1
  [[ -f "$file" ]] || return 1
  awk '
    NR == 1 && $0 != "---" { exit }
    NR == 1 { frontmatter = 1; next }
    frontmatter && $0 == "---" { closed = 1; exit }
    frontmatter && /^mep[A-Z]/ { found = 1 }
    END { exit (found && closed ? 0 : 1) }
  ' "$file"
}

mep_frontmatter_block_invalid() {
  local file=$1 first_line
  [[ -f "$file" ]] || return 1
  IFS= read -r first_line <"$file"
  [[ "$first_line" == "---" ]] && ! mep_document_state_present "$file"
}

mep_document_iteration_json() {
  local brief=$1 number title status slice_type delivery_track fanout brief_revision implementation_revision checkpoint_revision implementation_paths
  if mep_frontmatter_block_invalid "$brief"; then
    jq -cn --arg path "$(mep_rel_path "$brief")" '{
      documentError: {kind:"invalid_frontmatter_block",path:$path}
    }'
    return 0
  fi
  number=$(mep_frontmatter_value "$brief" mepIteration)
  if [[ ! "$number" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    jq -cn --arg path "$(mep_rel_path "$brief")" --arg value "$number" '{
      documentError: {
        kind: (if $value == "" then "missing_mep_iteration" else "invalid_mep_iteration" end),
        path: $path,
        value: (if $value == "" then null else $value end)
      }
    }'
    return 0
  fi
  title=$(mep_frontmatter_value "$brief" mepTitle)
  status=$(mep_frontmatter_value "$brief" mepStatus)
  slice_type=$(mep_frontmatter_value "$brief" mepSliceType)
  delivery_track=$(mep_frontmatter_value "$brief" mepDeliveryTrack)
  fanout=$(mep_frontmatter_value "$brief" mepFanout)
  brief_revision=$(mep_frontmatter_value "$brief" mepBriefRevision)
  implementation_revision=$(mep_frontmatter_value "$brief" mepImplementationRevision)
  checkpoint_revision=$(mep_frontmatter_value "$brief" mepCheckpointRevision)
  implementation_paths=$(mep_frontmatter_value "$brief" mepImplementationPaths)
  if mep_frontmatter_key_has_empty_value "$brief" mepImplementationPaths; then
    jq -cn --arg path "$(mep_rel_path "$brief")" '{
      documentError: {kind:"unsupported_block_mep_implementation_paths",path:$path}
    }'
    return 0
  fi
  [[ -n "$implementation_paths" ]] || implementation_paths='[]'
  if ! printf '%s' "$implementation_paths" | jq -e 'type == "array"' >/dev/null 2>&1; then
    jq -cn --arg path "$(mep_rel_path "$brief")" '{
      documentError: {kind:"invalid_mep_implementation_paths",path:$path}
    }'
    return 0
  fi

  jq -cn \
    --argjson number "$number" \
    --arg title "$title" \
    --arg briefPath "$(mep_rel_path "$brief")" \
    --arg status "$status" \
    --arg sliceType "$slice_type" \
    --arg deliveryTrack "$delivery_track" \
    --arg fanout "$fanout" \
    --arg briefRevision "$brief_revision" \
    --arg implementationRevision "$implementation_revision" \
    --arg checkpointRevision "$checkpoint_revision" \
    --argjson implementationPaths "$implementation_paths" '
      {number: $number, briefPath: $briefPath}
      + (if $title == "" then {} else {title: $title} end)
      + (if $status == "" then {} else {status: $status} end)
      + (if $sliceType == "" then {} else {sliceType: $sliceType} end)
      + (if $deliveryTrack == "" then {} else {deliveryTrack: $deliveryTrack} end)
      + (if $fanout == "" then {} else {fanout: $fanout} end)
      + (if $briefRevision == "" then {} else {briefRevision: $briefRevision} end)
      + (if $implementationRevision == "" then {} else {implementationRevision: $implementationRevision} end)
      + (if $checkpointRevision == "" then {} else {checkpointRevision: $checkpointRevision} end)
      + (if ($implementationPaths | length) == 0 then {} else {implementationPaths: $implementationPaths} end)
    '
}

mep_state_summary_json() {
  local slug=$1 roadmap roadmap_rel legacy_manifest iteration_dir current_iteration records_json iterations_json document_errors owned_paths
  local phase prep_bootstrapped handoff_approved initiative_status authorship_mode master_plan_path
  roadmap=$(mep_roadmap_path "$slug")
  roadmap_rel=$(mep_rel_path "$roadmap")
  if ! mep_document_state_present "$roadmap"; then
    if mep_frontmatter_block_invalid "$roadmap"; then
      jq -cn --arg path "$roadmap" --arg errorPath "$roadmap_rel" --arg slug "$slug" '{
        exists: true,
        authority: "documents",
        path: $path,
        slug: $slug,
        schemaVersion: 2,
        documentErrors: [{kind:"invalid_frontmatter_block",path:$errorPath}]
      }'
      return 0
    fi
    # One-release importer for existing v1 initiatives. New and migrated initiatives never consult it.
    legacy_manifest=$(mep_manifest_path "$slug")
    if [[ -f "$legacy_manifest" ]]; then
      mep_legacy_manifest_summary_json "$legacy_manifest"
      return 0
    fi
    printf '{"exists":false,"path":%s,"authority":"documents"}\n' "$(mep_json_string "$roadmap")"
    return 0
  fi

  current_iteration=$(mep_frontmatter_value "$roadmap" mepCurrentIteration)
  phase=$(mep_frontmatter_value "$roadmap" mepPhase)
  prep_bootstrapped=$(mep_frontmatter_value "$roadmap" mepPrepDocsBootstrapped)
  handoff_approved=$(mep_frontmatter_value "$roadmap" mepHandoffApproved)
  initiative_status=$(mep_frontmatter_value "$roadmap" mepInitiativeStatus)
  authorship_mode=$(mep_frontmatter_value "$roadmap" mepAuthorshipMode)
  master_plan_path=$(mep_frontmatter_value "$roadmap" mepMasterPlanPath)
  owned_paths=$(mep_frontmatter_value "$roadmap" mepOwnedPaths)
  if ! mep_frontmatter_key_present "$roadmap" mepOwnedPaths \
    || mep_frontmatter_key_has_empty_value "$roadmap" mepOwnedPaths; then
    owned_paths=__unsupported_block_value__
  fi
  [[ -n "$phase" ]] || phase=null
  [[ -n "$prep_bootstrapped" ]] || prep_bootstrapped=false
  [[ -n "$handoff_approved" ]] || handoff_approved=false
  [[ -n "$initiative_status" ]] || initiative_status=active
  [[ -n "$authorship_mode" ]] || authorship_mode=default
  [[ -n "$owned_paths" ]] || owned_paths='[]'
  [[ -n "$current_iteration" ]] || current_iteration=null

  iteration_dir=$(mep_abs_path "$(mep_iteration_dir_rel "$slug")")
  records_json=$(
    shopt -s nullglob
    for brief in "$iteration_dir"/*.md; do
      mep_document_iteration_json "$brief"
    done | jq -sc 'sort_by(.number)'
  )
  iterations_json=$(printf '%s' "$records_json" | jq -c '[.[] | select(has("documentError") | not)]')
  document_errors=$(printf '%s' "$records_json" | jq -c '[.[].documentError? | select(. != null)]')

  jq -cn \
    --arg path "$roadmap" \
    --arg errorPath "$roadmap_rel" \
    --arg slug "$slug" \
    --arg phase "$phase" \
    --arg prepDocsBootstrapped "$prep_bootstrapped" \
    --arg handoffApproved "$handoff_approved" \
    --arg initiativeStatus "$initiative_status" \
    --arg authorshipMode "$authorship_mode" \
    --arg currentIteration "$current_iteration" \
    --arg ownedPaths "$owned_paths" \
    --arg masterPlanPath "$master_plan_path" \
    --argjson iterations "$iterations_json" \
    --argjson documentErrors "$document_errors" '
      ($phase | if . == "null" then null else (try tonumber catch null) end) as $parsedPhase
      | ($currentIteration | if . == "null" then null else (try tonumber catch null) end) as $parsedCurrentIteration
      | ($ownedPaths | try fromjson catch null) as $parsedOwnedPaths
      | (
          $documentErrors
          + (if $phase != "null" and $parsedPhase == null then [{kind:"invalid_mep_phase",path:$errorPath,value:$phase}] else [] end)
          + (if ($prepDocsBootstrapped != "true" and $prepDocsBootstrapped != "false") then [{kind:"invalid_mep_prep_docs_bootstrapped",path:$errorPath,value:$prepDocsBootstrapped}] else [] end)
          + (if ($handoffApproved != "true" and $handoffApproved != "false") then [{kind:"invalid_mep_handoff_approved",path:$errorPath,value:$handoffApproved}] else [] end)
          + (if $currentIteration != "null" and $parsedCurrentIteration == null then [{kind:"invalid_mep_current_iteration",path:$errorPath,value:$currentIteration}] else [] end)
          + (if $parsedOwnedPaths == null or ($parsedOwnedPaths | type) != "array" then [{kind:"invalid_mep_owned_paths",path:$errorPath}] else [] end)
        ) as $errors
      | ($prepDocsBootstrapped == "true") as $parsedPrepDocsBootstrapped
      | ($handoffApproved == "true") as $parsedHandoffApproved
      | {
        exists: true,
        authority: "documents",
        path: $path,
        slug: $slug,
        schemaVersion: 2,
        phase: $parsedPhase,
        authorshipMode: $authorshipMode,
        initiativeStatus: $initiativeStatus,
        prepDocsBootstrapped: $parsedPrepDocsBootstrapped,
        handoffApproved: $parsedHandoffApproved,
        currentIteration: $parsedCurrentIteration,
        currentIterationRecord: ($iterations | map(select(.number == $parsedCurrentIteration)) | .[0] // null),
        ownedPaths: ($parsedOwnedPaths // []),
        masterPlanPath: (if $masterPlanPath == "" then null else $masterPlanPath end),
        iterations: $iterations,
        documentErrors: $errors
      }
    '
}
