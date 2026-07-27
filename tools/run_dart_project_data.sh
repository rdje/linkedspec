#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_dart_project_data.sh" "$@"

DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
command -v "$DART_CMD" >/dev/null 2>&1 || {
 printf 'dart-project-data: required command not found: %s\n' "$DART_CMD" >&2
 exit 1
}

[[ -n "${LINKEDSPEC_DART_HOME:-}" && -d "$LINKEDSPEC_DART_HOME" ]] || {
 printf '%s\n' 'dart-project-data: initialized Dart home is unavailable' >&2
 exit 1
}

# Dartdev reads/writes telemetry configuration beneath HOME before several
# subcommands honor PUB_CACHE. Isolate only the Dart child from developer HOME.
HOME="$LINKEDSPEC_DART_HOME" exec "$DART_CMD" "$@"
