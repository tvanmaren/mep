#!/usr/bin/env bash
# Reconcile a prep manifest's self-attested iteration status against git ground
# truth (the `committed` vs `merged` distinction). Detective, not preventive: it
# REPORTS desync and only writes corrections with --fix. It never *infers* merged
# from a bare commit — merged means trunk contains the work. Granularity is
# branch-level: the whole branch counts as merged iff trunk contains HEAD (fits a
# stack/massive-PR flow; per-slice granularity would need a recorded commit sha).
#
# Pure bash + sed (no jq), matching the hook scripts; relies on the manifest's
# one-iteration-per-line layout (which the surgical write-back also assumes).
#
# Usage: doctor.sh <slug> [--trunk <branch>] [--fix]
# Exit:  0 = clean · 1 = desync (report-only or unresolved FLAGs) · 2 = usage/IO error.
set -uo pipefail

usage() { echo "usage: doctor.sh <slug> [--trunk <branch>] [--fix]" >&2; exit 2; }

slug=""; trunk="main"; fix=0
while (( $# )); do
  case "$1" in
    --fix)   fix=1 ;;
    --trunk) shift; trunk="${1:-}"; [[ -n "$trunk" ]] || usage ;;
    -*)      usage ;;
    *)       if [[ -z "$slug" ]]; then slug="$1"; else usage; fi ;;
  esac
  shift
done
[[ -n "$slug" ]] || usage

manifest="wiki/prep/$slug/manifest.json"
[[ -f "$manifest" ]] || { echo "doctor: no manifest at $manifest" >&2; exit 2; }

# A bad/stale trunk ref must be a config error, not a silent "not merged" that
# false-FLAGs genuinely merged iterations.
git rev-parse --verify --quiet "$trunk^{commit}" >/dev/null \
  || { echo "doctor: trunk ref '$trunk' does not resolve" >&2; exit 2; }

# Branch-granularity merged truth: does trunk contain HEAD?
if git merge-base --is-ancestor HEAD "$trunk" 2>/dev/null; then
  echo "doctor[$slug]: does $trunk contain HEAD? yes — branch is in trunk"
  merged_truth=1
else
  echo "doctor[$slug]: does $trunk contain HEAD? no — branch not yet merged"
  merged_truth=0
fi

flags=(); promos=()
while IFS= read -r line; do
  case "$line" in *'"number":'*'"status":'*|*'"n":'*'"status":'*) ;; *) continue ;; esac
  n=$(printf '%s' "$line" | sed -n 's/.*"number":[[:space:]]*\([0-9]\{1,\}\).*/\1/p')
  [[ -n "$n" ]] || n=$(printf '%s' "$line" | sed -n 's/.*"n":[[:space:]]*\([0-9]\{1,\}\).*/\1/p')
  status=$(printf '%s' "$line" | sed -n 's/.*"status":[[:space:]]*"\([a-z_]\{1,\}\)".*/\1/p')
  [[ -n "$n" && -n "$status" ]] || continue
  if [[ "$status" == merged ]] && (( ! merged_truth )); then
    flags+=("$n")
  elif [[ "$status" == committed ]] && (( merged_truth )); then
    promos+=("$n")
  fi
done < "$manifest"

if (( ${#flags[@]} == 0 && ${#promos[@]} == 0 )); then
  echo "doctor: clean — every iteration's status agrees with git."
  exit 0
fi

for n in "${flags[@]:-}";  do [[ -n "$n" ]] && echo "  FLAG  iter $n: claims \`merged\` but trunk does not contain this branch"; done
for n in "${promos[@]:-}"; do [[ -n "$n" ]] && echo "  PROMOTE iter $n: committed -> merged (trunk now contains it)"; done

if (( ! fix )); then
  echo "doctor: report-only. Re-run with --fix to apply promotions; FLAGs need human judgment (never auto-cleared)."
  exit 1
fi

applied=0
for n in "${promos[@]:-}"; do
  [[ -n "$n" ]] || continue
  # Surgical: on iteration n's line only, flip committed->merged (formatting preserved).
  before=$(sed -n "/\"number\":[[:space:]]*$n,/p; /\"n\":[[:space:]]*$n,/p" "$manifest")
  sed -i "/\"number\":[[:space:]]*$n,/ s/\"status\":[[:space:]]*\"committed\"/\"status\": \"merged\"/" "$manifest"
  sed -i "/\"n\":[[:space:]]*$n,/ s/\"status\":[[:space:]]*\"committed\"/\"status\": \"merged\"/" "$manifest"
  after=$(sed -n "/\"number\":[[:space:]]*$n,/p; /\"n\":[[:space:]]*$n,/p" "$manifest")
  [[ "$before" != "$after" ]] && applied=$((applied + 1))
done
echo "doctor: applied $applied promotion(s) to $manifest."

if (( ${#flags[@]} > 0 )); then
  echo "doctor: ${#flags[@]} FLAG(s) left for you — \`merged\` is never auto-corrected."
  exit 1
fi
exit 0
