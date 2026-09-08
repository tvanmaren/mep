#!/usr/bin/env bash

mep_execution_request_is_valid() {
  local request_json=$1
  printf '%s' "$request_json" | jq -e '
    type == "object"
    and (keys | sort) == ["argv", "kind", "target"]
    and (.kind | IN("implement", "checkpoint", "commit_prep", "prep", "cleanup", "none"))
    and (.argv | type == "array" and all(.[]; type == "string"))
    and (
      if .kind == "none"
      then .target == null
      else (.target | type == "string" and length > 0)
      end
    )
  ' >/dev/null 2>&1
}

mep_exec_error_json() {
  local status=$1 reason=$2 detail=$3
  jq -cn \
    --arg status "$status" \
    --arg reason "$reason" \
    --arg detail "$detail" \
    '{status:$status,reason:$reason,detail:$detail}'
}

mep_execution_primitive_for_kind() {
  case "$1" in
    implement) printf 'mep implement' ;;
    checkpoint) printf 'mep checkpoint' ;;
    commit_prep) printf 'mep commit scope' ;;
    prep) printf 'mep evidence write <slug> prep <state>' ;;
    cleanup) printf 'mep evidence write <slug> cleanup <state>' ;;
    none) printf 'none' ;;
    *) return 70 ;;
  esac
}

# @stable — dispatch consumes the public executionRequest object without translating adapter strings.
mep_exec_dispatch_json() {
  local request_json=$1 executor=${2:-$MEP_EXECUTORS_DEFAULT} dry_run=${3:-0}
  local preset_json preset_kind preset_command primitive dry_run_json=false
  (( dry_run )) && dry_run_json=true

  if ! mep_execution_request_is_valid "$request_json"; then
    mep_exec_error_json blocked invalid_execution_request \
      'executionRequest must contain exactly kind, target, argv with a supported kind'
    return 0
  fi

  preset_json=$(mep_executor_preset_json "$executor")
  if [[ "$preset_json" == null ]]; then
    mep_exec_error_json not_found executor_not_found "executor preset '$executor' is not configured"
    return 0
  fi

  preset_kind=$(printf '%s' "$preset_json" | jq -r '.kind // ""')
  preset_command=$(printf '%s' "$preset_json" | jq -r '.command // ""')

  if (( dry_run )); then
    jq -cn \
      --arg executor "$executor" \
      --arg presetKind "$preset_kind" \
      --arg command "$preset_command" \
      --argjson request "$request_json" \
      '{
        status: "ok",
        executor: $executor,
        dryRun: true,
        executionRequest: $request,
        result: {
          kind: "dry_run",
          accepted: true,
          presetKind: $presetKind,
          command: $command
        }
      }'
    return 0
  fi

  case "$preset_kind:$preset_command" in
    stub:internal:stub)
      # @provisional — deterministic test double; live vendor drivers remain external contracts.
      primitive=$(mep_execution_primitive_for_kind "$(printf '%s' "$request_json" | jq -r '.kind')")
      jq -cn \
        --arg executor "$executor" \
        --arg primitive "$primitive" \
        --argjson request "$request_json" \
        --argjson dryRun "$dry_run_json" \
        '{
          status: "ok",
          executor: $executor,
          dryRun: $dryRun,
          executionRequest: $request,
          result: {
            kind: "stub",
            accepted: true,
            primitive: $primitive
          }
        }'
      ;;
    command:*)
      mep_exec_error_json blocked executor_driver_unavailable \
        "executor preset '$executor' is a documented command contract; no live driver ships in-tree"
      ;;
    *)
      mep_exec_error_json blocked invalid_executor_preset \
        "executor preset '$executor' must declare a supported kind and command"
      ;;
  esac
}
