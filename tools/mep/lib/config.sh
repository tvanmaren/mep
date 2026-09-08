#!/usr/bin/env bash

mep_repo_root() {
  if [[ -n "${MEP_REPO_ROOT_OVERRIDE:-}" ]]; then
    printf '%s\n' "$MEP_REPO_ROOT_OVERRIDE"
    return 0
  fi
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

mep_trim() {
  local s=$1
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

mep_config_defaults() {
  MEP_CONFIG_VERSION=1
  MEP_STORAGE_PREP_ROOT=.mep/prep
  MEP_STORAGE_PLANS_ROOT=.mep/plans
  MEP_STORAGE_PR_DESCRIPTIONS_ROOT=.mep/pr-descriptions
  MEP_STORAGE_ARCHITECTURE_ROOT=.mep/architecture
  MEP_STORAGE_HISTORY_ROOT=.mep/history
  MEP_RUNTIME_ADAPTER=plain
  MEP_RUNTIME_SESSION_ACTIVE_FILE=
  MEP_RUNTIME_SPINES=(.mep)
  MEP_VCS_KIND=git
  MEP_VCS_DEFAULT_TRUNK=main
  MEP_PROFILE_ACTIVE=default
  MEP_PROFILE_DIR=.mep/profiles
  MEP_EXECUTORS_DEFAULT=stub
  MEP_EXECUTOR_CONFIG_KEYS=(
    "executors.presets.stub.kind"
    "executors.presets.stub.command"
  )
  MEP_EXECUTOR_CONFIG_VALUES=(
    "stub"
    "internal:stub"
  )
  MEP_CONFIG_FILE=
  MEP_CONFIG_ERRORS=()
}

mep_config_known_key() {
  case "$1" in
    version|storage.prepRoot|storage.plansRoot|storage.prDescriptionsRoot|storage.architectureRoot|storage.historyRoot|runtime.adapter|runtime.sessionActiveFile|runtime.spine|vcs.kind|vcs.defaultTrunk|profile.active|profile.dir|executors.default)
      return 0 ;;
    executors.presets.*.kind|executors.presets.*.command|executors.presets.*.env.*)
      [[ "$1" =~ ^executors\.presets\.[A-Za-z0-9_-]+\.(kind|command|env\.[A-Za-z_][A-Za-z0-9_]*)$ ]]
      ;;
    *)
      return 1 ;;
  esac
}

mep_config_set() {
  local key=$1 value=$2
  case "$key" in
    version) MEP_CONFIG_VERSION=$value ;;
    storage.prepRoot) MEP_STORAGE_PREP_ROOT=$value ;;
    storage.plansRoot) MEP_STORAGE_PLANS_ROOT=$value ;;
    storage.prDescriptionsRoot) MEP_STORAGE_PR_DESCRIPTIONS_ROOT=$value ;;
    storage.architectureRoot) MEP_STORAGE_ARCHITECTURE_ROOT=$value ;;
    storage.historyRoot) MEP_STORAGE_HISTORY_ROOT=$value ;;
    runtime.adapter) MEP_RUNTIME_ADAPTER=$value ;;
    runtime.sessionActiveFile) MEP_RUNTIME_SESSION_ACTIVE_FILE=$value ;;
    runtime.spine) MEP_RUNTIME_SPINES+=("$value") ;;
    vcs.kind) MEP_VCS_KIND=$value ;;
    vcs.defaultTrunk) MEP_VCS_DEFAULT_TRUNK=$value ;;
    profile.active) MEP_PROFILE_ACTIVE=$value ;;
    profile.dir) MEP_PROFILE_DIR=$value ;;
    executors.default) MEP_EXECUTORS_DEFAULT=$value ;;
    executors.presets.*)
      MEP_EXECUTOR_CONFIG_KEYS+=("$key")
      MEP_EXECUTOR_CONFIG_VALUES+=("$value")
      ;;
  esac
}

mep_load_config() {
  local root=${1:-$(mep_repo_root)}
  local file=${2:-$root/.mep/config}
  local line trimmed key value line_no=0 saw_runtime_spine=0

  mep_config_defaults
  MEP_REPO_ROOT=$root
  MEP_CONFIG_FILE=$file

  [[ -f "$file" ]] || return 0

  MEP_RUNTIME_SPINES=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))
    trimmed=$(mep_trim "$line")
    [[ -z "$trimmed" || "${trimmed:0:1}" == "#" ]] && continue
    if [[ "$trimmed" != *"="* ]]; then
      MEP_CONFIG_ERRORS+=("line $line_no: expected key=value")
      continue
    fi
    key=$(mep_trim "${trimmed%%=*}")
    value=$(mep_trim "${trimmed#*=}")
    if [[ -z "$key" ]]; then
      MEP_CONFIG_ERRORS+=("line $line_no: empty key")
      continue
    fi
    if ! mep_config_known_key "$key"; then
      MEP_CONFIG_ERRORS+=("line $line_no: unknown key '$key'")
      continue
    fi
    [[ "$key" == runtime.spine ]] && saw_runtime_spine=1
    mep_config_set "$key" "$value"
  done < "$file"

  if (( ! saw_runtime_spine && ${#MEP_RUNTIME_SPINES[@]} == 0 )); then
    MEP_RUNTIME_SPINES=(.mep)
  fi
}

mep_abs_path() {
  local path=${1:-}
  [[ -z "$path" ]] && { printf ''; return 0; }
  case "$path" in
    /*) printf '%s' "$path" ;;
    *) printf '%s/%s' "$MEP_REPO_ROOT" "$path" ;;
  esac
}

mep_config_errors_json() {
  printf '%s\n' "${MEP_CONFIG_ERRORS[@]}" | mep_json_string_array_from_lines
}

mep_spines_json() {
  printf '%s\n' "${MEP_RUNTIME_SPINES[@]}" | mep_json_string_array_from_lines
}

mep_executors_json() {
  local result key value remainder preset field env_name i
  result=$(jq -cn --arg defaultExecutor "$MEP_EXECUTORS_DEFAULT" '{default:$defaultExecutor,presets:{}}')

  for (( i=0; i<${#MEP_EXECUTOR_CONFIG_KEYS[@]}; i++ )); do
    key=${MEP_EXECUTOR_CONFIG_KEYS[$i]}
    value=${MEP_EXECUTOR_CONFIG_VALUES[$i]}
    remainder=${key#executors.presets.}
    preset=${remainder%%.*}
    field=${remainder#*.}
    if [[ "$field" == env.* ]]; then
      env_name=${field#env.}
      result=$(jq -cn \
        --argjson current "$result" \
        --arg preset "$preset" \
        --arg envName "$env_name" \
        --arg value "$value" \
        '$current | setpath(["presets",$preset,"env",$envName];$value)')
    else
      result=$(jq -cn \
        --argjson current "$result" \
        --arg preset "$preset" \
        --arg field "$field" \
        --arg value "$value" \
        '$current | setpath(["presets",$preset,$field];$value)')
    fi
  done

  printf '%s\n' "$result"
}

mep_executor_preset_json() {
  local preset=$1
  mep_executors_json | jq -c --arg preset "$preset" '.presets[$preset] // null'
}

mep_config_dump_json() {
  printf '{'
  printf '"version":%s,' "$(mep_json_string "$MEP_CONFIG_VERSION")"
  printf '"source":'
  if [[ -f "$MEP_CONFIG_FILE" ]]; then mep_json_string "$MEP_CONFIG_FILE"; else printf 'null'; fi
  printf ',"errors":'
  mep_config_errors_json
  printf ',"storage":{'
  printf '"prepRoot":%s,' "$(mep_json_string "$MEP_STORAGE_PREP_ROOT")"
  printf '"plansRoot":%s,' "$(mep_json_string "$MEP_STORAGE_PLANS_ROOT")"
  printf '"prDescriptionsRoot":%s,' "$(mep_json_string "$MEP_STORAGE_PR_DESCRIPTIONS_ROOT")"
  printf '"architectureRoot":%s,' "$(mep_json_string "$MEP_STORAGE_ARCHITECTURE_ROOT")"
  printf '"historyRoot":%s' "$(mep_json_string "$MEP_STORAGE_HISTORY_ROOT")"
  printf '},"runtime":{'
  printf '"adapter":%s,' "$(mep_json_string "$MEP_RUNTIME_ADAPTER")"
  printf '"sessionActiveFile":%s,' "$(mep_json_string "$MEP_RUNTIME_SESSION_ACTIVE_FILE")"
  printf '"spine":'
  mep_spines_json
  printf '},"vcs":{'
  printf '"kind":%s,' "$(mep_json_string "$MEP_VCS_KIND")"
  printf '"defaultTrunk":%s' "$(mep_json_string "$MEP_VCS_DEFAULT_TRUNK")"
  printf '},"profile":{'
  printf '"active":%s,' "$(mep_json_string "$MEP_PROFILE_ACTIVE")"
  printf '"dir":%s' "$(mep_json_string "$MEP_PROFILE_DIR")"
  printf '},"executors":'
  mep_executors_json
  printf '}'
  printf '\n'
}
