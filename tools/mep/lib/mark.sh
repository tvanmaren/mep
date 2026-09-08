#!/usr/bin/env bash

mep_mark_path_is_safe() {
  case "$1" in
    ""|/*|..|../*|*/../*|*/..) return 1 ;;
    *) return 0 ;;
  esac
}

mep_mark_comment_style() {
  local path=$1 absolute=${2:-} first_line=""
  case "$path" in
    *.sh|*.bash|*.zsh|*.py|*.rb|*.pl|*.yml|*.yaml|*.toml|*.conf|*.env)
      printf 'hash'
      ;;
    *.js|*.jsx|*.ts|*.tsx|*.c|*.h|*.cc|*.cpp|*.cxx|*.hpp|*.go|*.rs|*.java|*.kt|*.kts|*.swift)
      printf 'slash'
      ;;
    *.sql)
      printf 'sql'
      ;;
    *.html|*.htm|*.xml|*.svg)
      printf 'html'
      ;;
    *.css|*.scss|*.sass|*.less)
      printf 'block'
      ;;
    *)
      [[ -n "$absolute" ]] && IFS= read -r first_line <"$absolute"
      if [[ "$first_line" == '#!'* ]]; then
        printf 'hash'
      else
        return 1
      fi
      ;;
  esac
}

mep_mark_comment_line() {
  local style=$1 marker=$2
  case "$style" in
    hash) printf '# %s' "$marker" ;;
    slash) printf '// %s' "$marker" ;;
    sql) printf '%s %s' '--' "$marker" ;;
    html) printf '<!-- %s -->' "$marker" ;;
    block) printf '/* %s */' "$marker" ;;
    *) return 1 ;;
  esac
}

mep_mark_target_json() {
  local path=$1 abs parent root_physical parent_physical
  if ! mep_mark_path_is_safe "$path"; then
    jq -cn --arg path "$path" '{status:"blocked",reason:"invalid_mark_path",path:$path}'
    return 1
  fi

  abs=$(mep_abs_path "$path")
  parent=$(dirname "$abs")
  root_physical=$(cd "$MEP_REPO_ROOT" && pwd -P) || {
    jq -cn --arg path "$path" '{status:"blocked",reason:"invalid_mark_path",path:$path}'
    return 1
  }
  parent_physical=$(cd "$parent" 2>/dev/null && pwd -P) || {
    jq -cn --arg path "$path" '{status:"not_found",reason:"mark_path_not_found",path:$path}'
    return 1
  }
  case "$parent_physical/" in
    "$root_physical/"*) ;;
    *)
      jq -cn --arg path "$path" '{status:"blocked",reason:"invalid_mark_path",path:$path}'
      return 1
      ;;
  esac
  abs=$parent_physical/$(basename "$path")
  if [[ ! -e "$abs" ]]; then
    jq -cn --arg path "$path" '{status:"not_found",reason:"mark_path_not_found",path:$path}'
    return 1
  fi
  if [[ ! -f "$abs" || -L "$abs" ]]; then
    jq -cn --arg path "$path" '{status:"blocked",reason:"mark_path_not_regular_file",path:$path}'
    return 1
  fi

  jq -cn --arg path "$path" --arg absolute "$abs" '{status:"ok",path:$path,absolute:$absolute}'
}

mep_mark_atomic_mise_write() {
  local path=$1 opening=$2 closing=$3 tmp
  tmp=$(mktemp "${path}.tmp.XXXXXX") || return 1
  if ! cp -p "$path" "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  if ! awk -v opening="$opening" -v closing="$closing" '
    BEGIN { opened = 0 }
    NR == 1 && /^#!/ {
      print
      print opening
      opened = 1
      next
    }
    NR == 1 {
      print opening
      opened = 1
    }
    { print }
    END {
      if (!opened) print opening
      print closing
    }
  ' "$path" >"$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  if ! mv "$tmp" "$path"; then
    rm -f "$tmp"
    return 1
  fi
}

mep_mark_atomic_finish_write() {
  local path=$1 line=$2 state=$3 tmp
  tmp=$(mktemp "${path}.tmp.XXXXXX") || return 1
  if ! cp -p "$path" "$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  if ! awk -v target="$line" -v state="$state" '
    NR == target { sub(/@finish:(open|done|ratified)/, "@finish:" state) }
    { print }
  ' "$path" >"$tmp"; then
    rm -f "$tmp"
    return 1
  fi
  if ! mv "$tmp" "$path"; then
    rm -f "$tmp"
    return 1
  fi
}

# @provisional — first deterministic writer for authorship and finish markers.
mep_mark_mise_json() {
  local path=$1 dry_run=${2:-0} target style open close marker_count=0 open_count=0 close_count=0
  local line text trimmed line_number=0 open_line=0 close_line=0 expected_open_line=1 first_line=""
  local dry_run_json=false
  (( dry_run )) && dry_run_json=true

  target=$(mep_mark_target_json "$path") || {
    printf '%s\n' "$target"
    return 0
  }
  if ! style=$(mep_mark_comment_style "$path" "$(printf '%s' "$target" | jq -r '.absolute')"); then
    jq -cn --arg path "$path" '{status:"blocked",reason:"unsupported_comment_syntax",path:$path}'
    return 0
  fi
  open=$(mep_mark_comment_line "$style" "@mise")
  close=$(mep_mark_comment_line "$style" "@mise:end")
  mep_finish_line_is_language_comment "$open" || {
    jq -cn --arg path "$path" '{status:"blocked",reason:"unsupported_comment_syntax",path:$path}'
    return 0
  }

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))
    (( line_number == 1 )) && first_line=$line
    text=$(mep_trim "$line")
    mep_finish_line_is_language_comment "$text" || continue
    [[ "$text" == *"@mise"* ]] || continue
    marker_count=$((marker_count + 1))
    if [[ "$text" == "$open" ]]; then
      open_count=$((open_count + 1))
      open_line=$line_number
    fi
    if [[ "$text" == "$close" ]]; then
      close_count=$((close_count + 1))
      close_line=$line_number
    fi
  done <"$(printf '%s' "$target" | jq -r '.absolute')"

  [[ "$first_line" == '#!'* ]] && expected_open_line=2
  if (( marker_count == 2
      && open_count == 1
      && close_count == 1
      && open_line == expected_open_line
      && close_line == line_number )); then
    jq -cn \
      --arg path "$path" \
      --arg style "$style" \
      --argjson dryRun "$dry_run_json" \
      '{status:"ok",operation:"mise",path:$path,commentStyle:$style,dryRun:$dryRun,written:false}'
    return 0
  fi
  if (( marker_count > 0 )); then
    jq -cn --arg path "$path" '{status:"blocked",reason:"mise_markers_present",path:$path}'
    return 0
  fi

  if (( ! dry_run )) && ! mep_mark_atomic_mise_write "$(printf '%s' "$target" | jq -r '.absolute')" "$open" "$close"; then
    jq -cn --arg path "$path" '{status:"blocked",reason:"mark_write_failed",path:$path}'
    return 0
  fi

  jq -cn \
    --arg path "$path" \
    --arg style "$style" \
    --argjson dryRun "$dry_run_json" \
    '{status:"ok",operation:"mise",path:$path,commentStyle:$style,dryRun:$dryRun,written:($dryRun | not)}'
}

mep_mark_finish_json() {
  local path=$1 state=$2 dry_run=${3:-0} target line text trimmed
  local marker_count=0 marker_line=0 prior_state="" prior_rank target_rank dry_run_json=false
  (( dry_run )) && dry_run_json=true

  case "$state" in
    open|done|ratified) ;;
    *)
      jq -cn --arg path "$path" --arg state "$state" \
        '{status:"blocked",reason:"invalid_finish_state",path:$path,state:$state}'
      return 0
      ;;
  esac

  target=$(mep_mark_target_json "$path") || {
    printf '%s\n' "$target"
    return 0
  }

  line=0
  while IFS= read -r text || [[ -n "$text" ]]; do
    line=$((line + 1))
    trimmed=$(mep_trim "$text")
    mep_finish_line_is_language_comment "$trimmed" || continue
    [[ "$trimmed" =~ @finish:(open|done|ratified) ]] || continue
    marker_count=$((marker_count + 1))
    marker_line=$line
    prior_state=${BASH_REMATCH[1]}
  done <"$(printf '%s' "$target" | jq -r '.absolute')"

  if (( marker_count == 0 )); then
    jq -cn --arg path "$path" '{status:"blocked",reason:"finish_marker_not_found",path:$path}'
    return 0
  fi
  if (( marker_count > 1 )); then
    jq -cn --arg path "$path" --argjson count "$marker_count" \
      '{status:"blocked",reason:"ambiguous_finish_markers",path:$path,count:$count}'
    return 0
  fi
  if [[ "$prior_state" == "$state" ]]; then
    jq -cn \
      --arg path "$path" \
      --arg state "$state" \
      --argjson line "$marker_line" \
      --argjson dryRun "$dry_run_json" \
      '{status:"ok",operation:"finish",path:$path,line:$line,from:$state,to:$state,dryRun:$dryRun,written:false}'
    return 0
  fi

  case "$prior_state" in
    open) prior_rank=0 ;;
    done) prior_rank=1 ;;
    ratified) prior_rank=2 ;;
  esac
  case "$state" in
    open) target_rank=0 ;;
    done) target_rank=1 ;;
    ratified) target_rank=2 ;;
  esac
  if (( target_rank < prior_rank )); then
    jq -cn \
      --arg path "$path" \
      --arg from "$prior_state" \
      --arg to "$state" \
      '{status:"blocked",reason:"finish_state_regression",path:$path,from:$from,to:$to}'
    return 0
  fi

  if (( ! dry_run )) && ! mep_mark_atomic_finish_write \
    "$(printf '%s' "$target" | jq -r '.absolute')" "$marker_line" "$state"; then
    jq -cn --arg path "$path" '{status:"blocked",reason:"mark_write_failed",path:$path}'
    return 0
  fi

  jq -cn \
    --arg path "$path" \
    --arg from "$prior_state" \
    --arg to "$state" \
    --argjson line "$marker_line" \
    --argjson dryRun "$dry_run_json" \
    '{status:"ok",operation:"finish",path:$path,line:$line,from:$from,to:$to,dryRun:$dryRun,written:($dryRun | not)}'
}
