#!/usr/bin/env bash

mep_manifest_rel() {
  printf '%s/%s/manifest.json' "$MEP_STORAGE_PREP_ROOT" "$1"
}

mep_iteration_dir_rel() {
  printf '%s/%s/iterations' "$MEP_STORAGE_PREP_ROOT" "$1"
}

mep_plan_rel() {
  printf '%s/%s.md' "$MEP_STORAGE_PLANS_ROOT" "$1"
}

mep_pr_description_root_rel() {
  printf '%s' "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT"
}

mep_paths_json() {
  local slug=$1
  local manifest_rel iteration_dir_rel plan_rel pr_root_rel profile_dir_rel session_rel
  manifest_rel=$(mep_manifest_rel "$slug")
  iteration_dir_rel=$(mep_iteration_dir_rel "$slug")
  plan_rel=$(mep_plan_rel "$slug")
  pr_root_rel=$(mep_pr_description_root_rel)
  profile_dir_rel=$MEP_PROFILE_DIR
  session_rel=$MEP_RUNTIME_SESSION_ACTIVE_FILE

  printf '{'
  printf '"slug":%s,' "$(mep_json_string "$slug")"
  printf '"repoRoot":%s,' "$(mep_json_string "$MEP_REPO_ROOT")"
  printf '"manifest":{'
  printf '"relative":%s,' "$(mep_json_string "$manifest_rel")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$manifest_rel")")"
  printf '},"prepRoot":{'
  printf '"relative":%s,' "$(mep_json_string "$MEP_STORAGE_PREP_ROOT")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$MEP_STORAGE_PREP_ROOT")")"
  printf '},"iterationDir":{'
  printf '"relative":%s,' "$(mep_json_string "$iteration_dir_rel")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$iteration_dir_rel")")"
  printf '},"plan":{'
  printf '"relative":%s,' "$(mep_json_string "$plan_rel")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$plan_rel")")"
  printf '},"prDescriptionsRoot":{'
  printf '"relative":%s,' "$(mep_json_string "$pr_root_rel")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$pr_root_rel")")"
  printf '},"sessionActiveFile":{'
  printf '"relative":%s,' "$(mep_json_string "$session_rel")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$session_rel")")"
  printf '},"profile":{'
  printf '"active":%s,' "$(mep_json_string "$MEP_PROFILE_ACTIVE")"
  printf '"dir":{'
  printf '"relative":%s,' "$(mep_json_string "$profile_dir_rel")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$profile_dir_rel")")"
  printf '}}}'
  printf '\n'
}
