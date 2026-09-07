#!/usr/bin/env bash

mep_profile_seed_rel() {
  printf '%s/%s.json' "$MEP_PROFILE_DIR" "$MEP_PROFILE_ACTIVE"
}

mep_profile_context_json() {
  local seed_rel=$1 seed_abs=$2
  printf '{'
  printf '"active":%s,' "$(mep_json_string "$MEP_PROFILE_ACTIVE")"
  printf '"dir":{'
  printf '"relative":%s,' "$(mep_json_string "$MEP_PROFILE_DIR")"
  printf '"absolute":%s' "$(mep_json_string "$(mep_abs_path "$MEP_PROFILE_DIR")")"
  printf '},"seed":{'
  printf '"relative":%s,' "$(mep_json_string "$seed_rel")"
  printf '"absolute":%s' "$(mep_json_string "$seed_abs")"
  printf '}}'
}

mep_profile_error_json() {
  local status=$1 reason=$2 detail=$3 seed_rel=$4 seed_abs=$5
  printf '{"status":%s,' "$(mep_json_string "$status")"
  printf '"reason":%s,' "$(mep_json_string "$reason")"
  printf '"profile":'
  mep_profile_context_json "$seed_rel" "$seed_abs"
  printf ',"detail":%s}\n' "$(mep_json_string "$detail")"
}

mep_profile_seed_is_valid() {
  local seed_abs=$1
  # publication is optional: omit for substrate-agnostic repos; when present, require shape.
  jq -e --arg active "$MEP_PROFILE_ACTIVE" '
    .schemaVersion == 1
    and .profile == $active
    and (.capabilities.classify.zones | type == "array")
    and (.capabilities.review.inputs | type == "array")
    and (.referenceOnly | type == "array")
    and (
      (.capabilities.publication | type == "null")
      or (
        (.capabilities.publication | type == "object")
        and (.capabilities.publication.stackBackend | type == "string" and length > 0)
        and (.capabilities.publication.tool | type == "string" and length > 0)
        and (.capabilities.publication.defaultSerialization | type == "string" and length > 0)
      )
    )
  ' "$seed_abs" >/dev/null 2>&1
}

mep_profile_dump_json() {
  local seed_rel seed_abs
  seed_rel=$(mep_profile_seed_rel)
  seed_abs=$(mep_abs_path "$seed_rel")

  mep_require jq || return $?

  if [[ ! -f "$seed_abs" ]]; then
    mep_profile_error_json "not_found" "missing_profile_seed" "active structured profile seed is missing" "$seed_rel" "$seed_abs"
    return 0
  fi

  # Keep the structured profile reader deliberately small; broader policy stays outside runtime.
  if ! mep_profile_seed_is_valid "$seed_abs"; then
    mep_profile_error_json "blocked" "invalid_profile_seed" "malformed JSON or unsupported profile seed shape" "$seed_rel" "$seed_abs"
    return 0
  fi

  jq -c \
    --argjson profile "$(mep_profile_context_json "$seed_rel" "$seed_abs")" \
    '{
      status: "ok",
      profile: $profile,
      schemaVersion,
      capabilities,
      referenceOnly
    }' "$seed_abs"
}
