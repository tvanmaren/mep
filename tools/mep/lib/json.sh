#!/usr/bin/env bash

mep_json_escape() {
  local s=${1:-}
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

mep_json_string() {
  printf '"%s"' "$(mep_json_escape "${1:-}")"
}

mep_json_string_array_from_lines() {
  local first=1 line
  printf '['
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if (( first )); then
      first=0
    else
      printf ','
    fi
    mep_json_string "$line"
  done
  printf ']'
}
