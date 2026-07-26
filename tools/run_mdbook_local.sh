#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"

MDBOOK_CMD=${LINKEDSPEC_MDBOOK_CMD:-mdbook}
command -v "$MDBOOK_CMD" >/dev/null 2>&1 || {
 printf '[mdbook] ERROR: required command not found: %s\n' "$MDBOOK_CMD" >&2
 exit 1
}

cd "$REPO_ROOT"
printf '%s\n' '[mdbook] building LinkedSpec book with repo-local project data'
"$MDBOOK_CMD" build docs/linkedspec-book "$@"
