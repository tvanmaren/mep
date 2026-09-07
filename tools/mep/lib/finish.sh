#!/usr/bin/env bash

mep_finish_path_prefix_for_git() {
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

mep_finish_owned_pathspecs() {
  local manifest_json=$1 owned prefix
  while IFS= read -r owned; do
    [[ -n "$owned" ]] || continue
    prefix=$(mep_finish_path_prefix_for_git "$owned")
    [[ -n "$prefix" ]] && printf '%s\n' "$prefix"
  done < <(printf '%s' "$manifest_json" | jq -r '.ownedPaths[]?')
}

mep_finish_marker_lines_json() {
  local manifest_json=$1
  local paths=() path line text marker_text state first=1
  mapfile -t paths < <(mep_finish_owned_pathspecs "$manifest_json")
  if (( ${#paths[@]} == 0 )); then
    printf '[]'
    return 0
  fi

  printf '['
  while IFS=: read -r path line text; do
    [[ -n "$path" && -n "$line" && -n "$text" ]] || continue
    case "$path" in
      *.md|*.json|*.txt|*/test/*|*".test."*|*".spec."*) continue ;;
    esac
    marker_text=$(mep_trim "$text")
    case "$marker_text" in
      "//"*|"#"*|"--"*|"/*"*|"<!--"*) ;;
      *) continue ;;
    esac
    [[ "$marker_text" =~ @finish:(open|done|ratified) ]] || continue
    state=${BASH_REMATCH[1]}
    if (( first )); then first=0; else printf ','; fi
    jq -cn \
      --arg path "$path" \
      --argjson line "$line" \
      --arg state "$state" \
      --arg text "$text" \
      '{path:$path,line:$line,state:$state,text:$text}'
  done < <(
    cd "$MEP_REPO_ROOT" || exit 1
    rg -n --with-filename --no-heading '@finish:(open|done|ratified)' "${paths[@]}" 2>/dev/null || true
  )
  printf ']'
}

# Required-writeback rules are intentionally conservative:
# validate observable marker/provenance state without inferring semantic finish classifications.
mep_finish_required_writebacks_json() {
  local manifest_json=$1 markers_json=$2 dirty_implementation_json=$3
  jq -cn \
    --argjson manifest "$manifest_json" \
    --argjson markers "$markers_json" \
    --argjson dirtyImplementation "$dirty_implementation_json" '
      ($manifest.authorshipMode // "default") as $mode
      | ($manifest.currentIterationRecord.status // "") as $currentStatus
      | [
          (if ([ $markers[] | select(.state == "open") ] | length) > 0 then
            {
              kind: "finish_open",
              severity: "blocker",
              detail: "one or more @finish:open markers remain",
              count: ([ $markers[] | select(.state == "open") ] | length)
            }
          else empty end),
          (if $mode == "autopilot" then
            ([ $markers[]
              | select(.state == "ratified")
              | select((.text | test("autopilot|proxy"; "i")) | not)
            ] | length) as $missing
            | if $missing > 0 then
              {
                kind: "finish_missing_proxy_provenance",
                severity: "blocker",
                detail: "autopilot ratified finishes must include proxy/autopilot provenance",
                count: $missing
              }
            else empty end
          else empty end),
          (if $mode == "manual" then
            ([ $markers[]
              | select(.state == "ratified")
              | select((.text | test("manual|human"; "i")) | not)
            ] | length) as $missing
            | if $missing > 0 then
              {
                kind: "finish_missing_human_provenance",
                severity: "blocker",
                detail: "manual ratified finishes must include human/manual provenance",
                count: $missing
              }
            else empty end
          else empty end),
          (if (($mode == "manual" or $mode == "autopilot")
              and ($currentStatus != "pending")
              and (($dirtyImplementation | length) > 0)
              and (($markers | length) == 0)) then
            {
              kind: "finish_map_missing",
              severity: "warning",
              detail: "manual/autopilot dirty implementation work has no @finish markers; classify finishes or record that the slice is mechanical-only",
              count: ($dirtyImplementation | length)
            }
          else empty end)
        ]
    '
}

mep_finish_scan_json() {
  local slug=$1 manifest_json markers_json dirty_owned_json dirty_implementation_json writebacks_json
  mep_require jq rg "$MEP_VCS_KIND" || return $?

  manifest_json=$(mep_manifest_summary_json "$slug")
  if [[ "$(printf '%s' "$manifest_json" | jq -r '.exists')" != true ]]; then
    printf '{"status":"not_found","slug":%s,"manifest":%s}\n' "$(mep_json_string "$slug")" "$(printf '%s' "$manifest_json" | jq '.path')"
    return 0
  fi

  markers_json=$(mep_finish_marker_lines_json "$manifest_json")
  dirty_owned_json=$(mep_dirty_owned_paths_json "$manifest_json")
  dirty_implementation_json=$(mep_dirty_implementation_paths_json "$slug" "$dirty_owned_json" "$manifest_json")
  writebacks_json=$(mep_finish_required_writebacks_json "$manifest_json" "$markers_json" "$dirty_implementation_json")

  jq -cn \
    --arg slug "$slug" \
    --argjson manifest "$manifest_json" \
    --argjson markers "$markers_json" \
    --argjson dirtyOwned "$dirty_owned_json" \
    --argjson dirtyImplementation "$dirty_implementation_json" \
    --argjson requiredWritebacks "$writebacks_json" '
      {
        status: "ok",
        slug: $slug,
        authorshipMode: ($manifest.authorshipMode // "default"),
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
        dirtyImplementationFiles: $dirtyImplementation,
        requiredWritebacks: $requiredWritebacks
      }
    '
}
