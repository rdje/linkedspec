#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_julia_project_data.sh" "$@"

fail() {
 printf '[julia-project-data] ERROR: %s\n' "$*" >&2
 exit 1
}

JULIA_CMD="${LINKEDSPEC_JULIA_CMD:-julia}"
command -v "$JULIA_CMD" >/dev/null 2>&1 || fail "required command not found: $JULIA_CMD"
(( $# > 0 )) || fail 'Julia arguments are required'

case "$(uname -s)" in
 MINGW*|MSYS*|CYGWIN*) writable_depot=${JULIA_DEPOT_PATH%%;*} ;;
 *) writable_depot=${JULIA_DEPOT_PATH%%:*} ;;
esac
[[ -n "$writable_depot" && -d "$writable_depot" ]] || fail 'writable Julia depot is missing'

cleanup_usage_log() {
 local canonical_depot

 canonical_depot=$(cd -P -- "$LINKEDSPEC_CACHE_ROOT/julia-depot" && pwd -P)
 if [[ "$(cd -P -- "$writable_depot" && pwd -P)" == "$canonical_depot" ]]; then
  rm -f -- "$writable_depot/logs/manifest_usage.toml"
 fi
}
trap cleanup_usage_log EXIT

export JULIA_PKG_OFFLINE="${JULIA_PKG_OFFLINE:-true}"
cd "$REPO_ROOT"
"$JULIA_CMD" --startup-file=no --history-file=no "$@"
