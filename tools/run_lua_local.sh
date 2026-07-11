#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
export LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;"

log() {
 printf '[lua-ci] %s\n' "$*"
}

fail() {
 printf '[lua-ci] ERROR: %s\n' "$*" >&2
 exit 1
}

command -v "$LUA_CMD" >/dev/null 2>&1 || fail "required primary runtime not found: $LUA_CMD"

cd "$REPO_ROOT"
log "syntax-checking Lua source"
find lua -type f \( -name '*.lua' -o -name 'linkedspec-lua' \) -print0 |
 while IFS= read -r -d '' file; do
  LINKEDSPEC_LUA_CHECK_FILE="$file" \
   "$LUA_CMD" -e 'assert(loadfile(os.getenv("LINKEDSPEC_LUA_CHECK_FILE")))'
 done

log "running primary PUC Lua tests"
"$LUA_CMD" lua/test/run.lua

log "checking explicit scaffold command failures"
set +e
cli_stderr=$("$LUA_CMD" lua/bin/linkedspec-lua 2>&1 >/dev/null)
cli_status=$?
corpus_stderr=$("$LUA_CMD" lua/bin/corpus_runner.lua 2>&1 >/dev/null)
corpus_status=$?
set -e
[ "$cli_status" -eq 2 ] || fail "CLI scaffold exit was $cli_status, expected 2"
[ "$cli_stderr" = 'linkedspec-lua: backend scaffold; parser CLI is not implemented' ] ||
 fail "CLI scaffold stderr drifted"
[ "$corpus_status" -eq 2 ] || fail "corpus scaffold exit was $corpus_status, expected 2"
[ "$corpus_stderr" = 'linkedspec-lua corpus runner: backend scaffold; corpus IO is not implemented' ] ||
 fail "corpus scaffold stderr drifted"

if command -v "$LUAJIT_CMD" >/dev/null 2>&1; then
 log "running secondary LuaJIT compatibility tests"
 "$LUAJIT_CMD" lua/test/run.lua
else
 log "LuaJIT compatibility runtime not installed; secondary leg skipped"
fi

log "Lua local gate passed"
