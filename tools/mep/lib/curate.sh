#!/usr/bin/env bash

mep_curation_json_rel() {
  printf '%s/%s/integration-curation.json' "$MEP_STORAGE_PREP_ROOT" "$1"
}

mep_curation_md_rel() {
  printf '%s/%s/integration-curation.md' "$MEP_STORAGE_PREP_ROOT" "$1"
}

mep_curate_script() {
  printf '%s/scripts/curate.py' "$MEP_HOME"
}

mep_curate_python() {
  local slug=$1
  shift
  mep_require python3 || return 3
  python3 "$(mep_curate_script)" \
    --repo-root "$MEP_REPO_ROOT" \
    --prep-root "$MEP_STORAGE_PREP_ROOT" \
    --trunk "$MEP_VCS_DEFAULT_TRUNK" \
    "$slug" \
    "$@"
}

mep_curate_json() {
  local slug=$1 mode=$2
  shift 2
  case "$mode" in
    preview)
      mep_curate_python "$slug" status
      ;;
    measure)
      mep_curate_python "$slug" measure
      ;;
    validate)
      mep_curate_python "$slug" validate
      ;;
    template)
      mep_curate_python "$slug" template "$@"
      ;;
    execute)
      mep_curate_python "$slug" execute "$@"
      ;;
    *)
      return 2
      ;;
  esac
}
