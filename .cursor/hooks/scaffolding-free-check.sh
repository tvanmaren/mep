#!/usr/bin/env bash
# Cursor adapter for the portable scaffolding-free check.
# The detector vocabulary lives in tools/mep/lib/checks.sh; this file preserves
# the old hook path and CLI shape for existing Cursor/staged-audit callers.
set -uo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "$root" ]]; then
  root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
fi

exec "$root/tools/mep/bin/mep" check scaffolding "$@"
