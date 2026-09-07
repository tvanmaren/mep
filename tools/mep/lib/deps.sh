#!/usr/bin/env bash

mep_have() {
  command -v "$1" >/dev/null 2>&1
}

mep_dependency_json() {
  local name=$1 status=$2 required=$3 detail=${4:-}
  printf '{"name":'
  mep_json_string "$name"
  printf ',"status":'
  mep_json_string "$status"
  printf ',"required":%s,"detail":' "$required"
  mep_json_string "$detail"
  printf '}'
}

mep_dependency_report_json() {
  local vcs_kind=${1:-git}
  local first=1 dep status required detail
  printf '['
  for dep in bash jq rg "$vcs_kind"; do
    required=true
    detail=""
    if mep_have "$dep"; then
      status=ok
    else
      status=missing_dependency
      detail="$dep not found on PATH"
    fi
    if (( first )); then first=0; else printf ','; fi
    mep_dependency_json "$dep" "$status" "$required" "$detail"
  done
  printf ']'
}

mep_optional_dependency_report_json() {
  local first=1 dep status detail
  printf '['
  for dep in "$@"; do
    if mep_have "$dep"; then
      status=ok
      detail=""
    else
      status=degraded
      detail="$dep not found on PATH"
    fi
    if (( first )); then first=0; else printf ','; fi
    mep_dependency_json "$dep" "$status" false "$detail"
  done
  printf ']'
}

mep_require() {
  local missing=() dep
  for dep in "$@"; do
    mep_have "$dep" || missing+=("$dep")
  done
  if (( ${#missing[@]} == 0 )); then
    return 0
  fi
  printf '{"status":"missing_dependency","missing":'
  printf '%s\n' "${missing[@]}" | mep_json_string_array_from_lines
  printf '}\n'
  return 2
}
