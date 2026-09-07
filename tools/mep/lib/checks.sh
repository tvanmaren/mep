#!/usr/bin/env bash

mep_check_scaffolding() {
  local precise broad allowlist archaeology hits
  precise='\biter[ -]?[0-9]|\bU-[A-Z][0-9]|\bPath-[A-Z]\b'
  broad='\biter(ation)?[ -]?[0-9]|\bU-[A-Z][0-9]|\bPath-[A-Z]\b|\bI[0-9]|\bU[0-9]|\bAD[0-9]'
  allowlist='provenance:|@(experimental|provisional|stable|foundational|reference-only)'
  archaeology=$precise

  case "${1:-}" in
    --broad)
      archaeology=$broad
      shift
      ;;
    --product-code)
      archaeology=$precise
      shift
      ;;
  esac

  [[ $# -gt 0 ]] || return 0
  mep_require rg >/dev/null || return $?

  hits=$(rg -n -i "$archaeology" "$@" 2>/dev/null | rg -v "$allowlist" || true)
  if [[ -n "$hits" ]]; then
    printf '%s\n' "$hits"
    return 1
  fi
  return 0
}

mep_check_prep_active_json() {
  local session_rel=$MEP_RUNTIME_SESSION_ACTIVE_FILE
  local session_abs slug="" active=false
  session_abs=$(mep_abs_path "$session_rel")
  if [[ -n "$session_rel" && -f "$session_abs" ]]; then
    active=true
    slug=$(tr -d '[:space:]' < "$session_abs")
  fi

  printf '{'
  printf '"status":"ok",'
  printf '"active":%s,' "$active"
  printf '"slug":'
  if [[ -n "$slug" ]]; then mep_json_string "$slug"; else printf 'null'; fi
  printf ',"sessionActiveFile":{'
  printf '"relative":%s,' "$(mep_json_string "$session_rel")"
  printf '"absolute":%s' "$(mep_json_string "$session_abs")"
  printf '}}'
  printf '\n'
}
