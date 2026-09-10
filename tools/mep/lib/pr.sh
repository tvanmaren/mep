#!/usr/bin/env bash

# These take the composed state summary, not a file, so document and legacy initiatives read alike.
mep_pr_iteration_json() {
  local summary_json=$1 n=$2
  printf '%s' "$summary_json" | jq -c --argjson n "$n" '
    (.iterations // [] | map(select(.number == $n)) | .[0]) // null
  '
}

mep_pr_owned_pathspecs() {
  local summary_json=$1 output_rel=${2:-} path
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    [[ "$path" == "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT/**" ]] && continue
    path=${path%%\*}
    path=${path%/}
    [[ -z "$path" ]] && continue
    printf '%s\n' "$path"
  done < <(printf '%s' "$summary_json" | jq -r '.ownedPaths[]? // empty' | sort -u)
  [[ -n "$output_rel" ]] && printf '%s\n' "$output_rel"
}

mep_pr_status_lines() {
  local summary_json=$1 output_rel=${2:-}
  mapfile -t pathspecs < <(mep_pr_owned_pathspecs "$summary_json" "$output_rel")
  if (( ${#pathspecs[@]} == 0 )); then
    return 0
  fi
  git status --porcelain -- "${pathspecs[@]}" 2>/dev/null || true
}

mep_pr_diff_stat_lines() {
  local summary_json=$1 output_rel=${2:-}
  mapfile -t pathspecs < <(mep_pr_owned_pathspecs "$summary_json" "$output_rel")
  if (( ${#pathspecs[@]} == 0 )); then
    return 0
  fi
  {
    git diff --no-color --stat -- "${pathspecs[@]}" 2>/dev/null || true
    git diff --cached --no-color --stat -- "${pathspecs[@]}" 2>/dev/null || true
  } | sed '/^$/d'
}

mep_pr_scaffold_path_rel() {
  local slug=$1 n=$2 title=$3
  local safe_title
  safe_title=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-//; s/-$//')
  printf '%s/%s-%02d-%s.md' "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT" "$slug" "$n" "$safe_title"
}

mep_pr_iteration_number() {
  local current_json=$1
  printf '%s' "$current_json" | jq -r '(.number // "") | tostring'
}

mep_pr_body_find_rel() {
  local slug=$1 n=$2
  local root prefix name path_rel
  [[ "$n" =~ ^[0-9]+$ ]] || return 0
  root=$(mep_abs_path "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT")
  [[ -d "$root" ]] || return 0
  prefix=$(printf '%s-%02d-' "$slug" "$n")
  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    path_rel="${MEP_STORAGE_PR_DESCRIPTIONS_ROOT}/${name}"
    printf '%s' "$path_rel"
    return 0
  done < <(find "$root" -maxdepth 1 -type f -name "${prefix}*.md" -printf '%f\n' 2>/dev/null | sort | head -n 1)
}

mep_pr_body_ready_json() {
  local slug=$1 current_json=$2
  local n path_rel
  n=$(mep_pr_iteration_number "$current_json")
  path_rel=$(mep_pr_body_find_rel "$slug" "$n")
  jq -cn \
    --arg root "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT" \
    --arg n "$n" \
    --arg path "$path_rel" \
    '{
      prBodyRoot: $root,
      iterationNumber: (if ($n | length) == 0 then null else ($n | tonumber) end),
      prBodyReady: ($path != ""),
      prBodyPath: (if $path == "" then null else $path end)
    }'
}

mep_pr_optional_steps_json() {
  local slug=$1 current_json=$2
  local pr_body_json n command
  pr_body_json=$(mep_pr_body_ready_json "$slug" "$current_json")
  if [[ "$(printf '%s' "$pr_body_json" | jq -r '.prBodyReady')" == true ]]; then
    printf '[]'
    return 0
  fi
  n=$(printf '%s' "$pr_body_json" | jq -r '.iterationNumber // empty')
  [[ -n "$n" ]] || {
    printf '[]'
    return 0
  }
  command="/prep-pr-description $slug $n"
  jq -cn \
    --arg command "$command" \
    --arg slug "$slug" \
    --argjson n "$n" \
    --arg root "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT" \
    '[
      {
        kind: "presentation",
        blocking: false,
        command: $command,
        description: "render reviewer-facing PR body for the slice just committed",
        reason: "post-brief implementation is on the branch and no PR description file exists for the current iteration under the configured prDescriptionsRoot",
        facts: {
          slug: $slug,
          iterationNumber: $n,
          prBodyRoot: $root
        }
      }
    ]'
}

mep_pr_scaffold() {
  local slug=$1 n=$2 json_flag=${3:-}
  [[ "$json_flag" == "--json" ]] || return 2
  mep_require jq git || return 3

  local summary_json state_path iteration title status brief_path output_rel output_abs now status_lines diff_stat packet event_payload
  summary_json=$(mep_state_summary_json "$slug")
  state_path=$(printf '%s' "$summary_json" | jq -r '.path')
  if [[ "$(printf '%s' "$summary_json" | jq -r '.exists')" != true ]]; then
    printf '{"status":"not_found","path":%s}\n' "$(mep_json_string "$state_path")"
    return 0
  fi

  iteration=$(mep_pr_iteration_json "$summary_json" "$n")
  if [[ "$iteration" == "null" ]]; then
    printf '{"status":"not_found","iteration":%s}\n' "$(mep_json_string "$n")"
    return 0
  fi

  title=$(jq -r '.title // "untitled"' <<<"$iteration")
  status=$(jq -r '.status // "unknown"' <<<"$iteration")
  brief_path=$(jq -r '.briefPath // ""' <<<"$iteration")
  output_rel=$(mep_pr_scaffold_path_rel "$slug" "$n" "$title")
  output_abs=$(mep_abs_path "$output_rel")
  mkdir -p "$(dirname "$output_abs")"
  now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  status_lines=$(mep_pr_status_lines "$summary_json" "$output_rel")
  diff_stat=$(mep_pr_diff_stat_lines "$summary_json" "$output_rel")

  {
    printf '# %s - %02d %s\n\n' "$slug" "$n" "$title"
    printf '<!-- generated by tools/mep/bin/mep pr scaffold; fill semantic sections before publishing -->\n\n'
    printf '## Summary\n\n'
    printf '%s\n' '- TODO: state the user-facing outcome.'
    printf '%s\n\n' '- TODO: state the implementation boundary and why it is safe.'
    printf '## Deterministic facts\n\n'
    printf '%s\n' "- Slug: \`$slug\`"
    printf '%s\n' "- Iteration: \`$n\`"
    printf '%s\n' "- Title: \`$title\`"
    printf '%s\n' "- Local status: \`$status\`"
    printf '%s\n' "- Brief: \`$brief_path\`"
    printf '%s\n' "- Generated: \`$now\`"
    printf '%s\n\n' "- Continuation command: \`/implement-plan $brief_path\`"
    printf '## Changed paths snapshot\n\n'
    if [[ -n "$status_lines" ]]; then
      printf '```text\n%s\n```\n\n' "$status_lines"
    else
      printf '_No initiative-owned dirty paths detected._\n\n'
    fi
    printf '## Diff stat snapshot\n\n'
    if [[ -n "$diff_stat" ]]; then
      printf '```text\n%s\n```\n\n' "$diff_stat"
    else
      printf '_No tracked diff stat detected for initiative-owned paths._\n\n'
    fi
    printf '## Test plan\n\n'
    printf '%s\n' '- [ ] TODO: list manual checks.'
    printf '%s\n\n' '- [ ] `bash tools/mep/test/run-unix-contract.sh`'
    printf '## Reviewer notes\n\n'
    printf '%s\n' '- TODO: call out any deferred local commit/graduation policy.'
  } > "$output_abs"

  packet=$(jq -cn \
    --arg outputRel "$output_rel" \
    --arg outputAbs "$output_abs" \
    --argjson iteration "$iteration" '
      {
        status: "ok",
        path: {
          relative: $outputRel,
          absolute: $outputAbs
        },
        iteration: $iteration
      }
    ') || return $?
  printf '%s\n' "$packet"
  event_payload=$(printf '%s' "$packet" | jq -c '{
    status: "ready",
    iteration: .iteration.number,
    localStatus: .iteration.status,
    title: .iteration.title,
    briefPath: .iteration.briefPath,
    bodyStatus: "scaffolded",
    bodyPath: .path.relative,
    checkKinds: ["iteration_found", "body_scaffolded"]
  }' 2>/dev/null) || event_payload=
  [[ -n "$event_payload" ]] && mep_event_append "review_body_validated" "$slug" "pr_scaffold" "$event_payload"
}
