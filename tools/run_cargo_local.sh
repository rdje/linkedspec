#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_cargo_local.sh" "$@"

CARGO_CMD="${LINKEDSPEC_CARGO_CMD:-cargo}"
command -v "$CARGO_CMD" >/dev/null 2>&1 || {
 printf '[cargo-local] ERROR: required command not found: %s\n' "$CARGO_CMD" >&2
 exit 1
}

cd "$REPO_ROOT"
exec "$CARGO_CMD" "$@"
