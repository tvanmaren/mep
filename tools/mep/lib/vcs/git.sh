#!/usr/bin/env bash

mep_vcs_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

mep_vcs_current_change_id() {
  git rev-parse HEAD 2>/dev/null || true
}

mep_vcs_latest_change_for_path() {
  local path=$1
  [[ -n "$path" ]] || return 0
  git log --max-count=1 --format=%H -- "$path" 2>/dev/null || true
}

mep_vcs_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || true
}

mep_vcs_dirty_paths() {
  git status --porcelain -- "$@" 2>/dev/null | sed 's/^...//' | sed '/^$/d'
}

mep_vcs_changed_paths_since_base() {
  local base=${1:-main}
  git diff --name-only "$base"...HEAD 2>/dev/null || true
}

mep_vcs_is_current_change_in_trunk() {
  local trunk=${1:-main}
  git merge-base --is-ancestor HEAD "$trunk" 2>/dev/null
}

mep_vcs_summary_json() {
  local trunk=${1:-main}
  local branch change_id in_trunk=false dirty changed
  branch=$(mep_vcs_branch)
  change_id=$(mep_vcs_current_change_id)
  if mep_vcs_is_current_change_in_trunk "$trunk"; then
    in_trunk=true
  fi
  dirty=$(mep_vcs_dirty_paths | mep_json_string_array_from_lines)
  changed=$(mep_vcs_changed_paths_since_base "$trunk" | mep_json_string_array_from_lines)

  printf '{'
  printf '"kind":"git",'
  printf '"branch":%s,' "$(mep_json_string "$branch")"
  printf '"currentChangeId":%s,' "$(mep_json_string "$change_id")"
  printf '"baseRef":%s,' "$(mep_json_string "$trunk")"
  printf '"isCurrentChangeInTrunk":%s,' "$in_trunk"
  printf '"dirtyPaths":%s,' "$dirty"
  printf '"changedPathsSinceBase":%s' "$changed"
  printf '}'
}
