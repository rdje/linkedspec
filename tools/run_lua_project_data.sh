#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_lua_project_data.sh" "$@"

fail() {
 printf '[lua-project-data] ERROR: %s\n' "$*" >&2
 exit 1
}

runtime=${1:-puc}
case "$runtime" in
 puc)
  LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
  ;;
 luajit)
  LUA_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
  ;;
 *) fail "runtime must be puc or luajit: $runtime" ;;
esac
command -v "$LUA_CMD" >/dev/null 2>&1 || fail "required runtime not found: $LUA_CMD"
(( $# > 0 )) && shift
(( $# > 0 )) || fail 'Lua arguments are required'

native_root=$(mktemp -d "${TMPDIR:?project-data initializer did not set TMPDIR}/linkedspec-lua-targeted-$runtime.XXXXXX")
cleanup() {
 rm -rf -- "$native_root"
}
trap cleanup EXIT

bash "$REPO_ROOT/tools/build_lua_native.sh" "$runtime" "$native_root"
export LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;"
export LUA_CPATH="$native_root/?.so;;"
export LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD"
cd "$REPO_ROOT"
"$LUA_CMD" "$@"
