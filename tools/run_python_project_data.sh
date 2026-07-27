#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_python_project_data.sh" "$@"

fail() {
 printf '[python-project-data] ERROR: %s\n' "$*" >&2
 exit 64
}

[[ $# -ge 1 ]] || fail 'usage: tools/run_python_project_data.sh <repo-relative-script.py> [args...]'
PYTHON_SCRIPT=$1
shift

[[ "$PYTHON_SCRIPT" != /* ]] || fail 'the Python script path must be repository-root-relative'
case "/$PYTHON_SCRIPT/" in
 */../*|*/./*) fail 'the Python script path must not contain dot traversal components' ;;
 *//*) fail 'the Python script path must not contain empty components' ;;
esac
[[ "$PYTHON_SCRIPT" == *.py ]] || fail 'the Python script path must end in .py'
[[ -f "$REPO_ROOT/$PYTHON_SCRIPT" && ! -L "$REPO_ROOT/$PYTHON_SCRIPT" ]] || \
 fail "Python script is missing or is a symlink: $PYTHON_SCRIPT"
PYTHON_SCRIPT_PARENT=$(cd -P -- "$(dirname -- "$REPO_ROOT/$PYTHON_SCRIPT")" && pwd -P) ||
 fail "cannot resolve Python script parent: $PYTHON_SCRIPT"
case "$PYTHON_SCRIPT_PARENT/" in
 "$REPO_ROOT/"*) ;;
 *) fail "Python script resolves outside the repository: $PYTHON_SCRIPT" ;;
esac

PYTHON_CMD=${LINKEDSPEC_PYTHON_CMD:-python3}
command -v "$PYTHON_CMD" >/dev/null 2>&1 || fail "required command not found: $PYTHON_CMD"

cd "$REPO_ROOT"
exec "$PYTHON_CMD" "$REPO_ROOT/$PYTHON_SCRIPT" "$@"
