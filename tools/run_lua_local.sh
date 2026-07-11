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

native_root=$(mktemp -d /private/tmp/linkedspec-lua-native.XXXXXX)
trap 'rm -rf "$native_root"' EXIT
primary_native="$native_root/puc"
secondary_native="$native_root/luajit"

log "building disposable PUC Lua PCRE2 adapter"
bash "$REPO_ROOT/tools/build_lua_native.sh" puc "$primary_native"
export LUA_CPATH="$primary_native/?.so;;"

cd "$REPO_ROOT"
log "syntax-checking Lua source"
find lua -type f \( -name '*.lua' -o -name 'linkedspec-lua' \) -print0 |
 while IFS= read -r -d '' file; do
  LINKEDSPEC_LUA_CHECK_FILE="$file" \
   "$LUA_CMD" -e 'assert(loadfile(os.getenv("LINKEDSPEC_LUA_CHECK_FILE")))'
 done

log "running primary PUC Lua tests"
"$LUA_CMD" lua/test/run.lua

log "checking explicit parser CLI scaffold failure"
set +e
cli_stderr=$("$LUA_CMD" lua/bin/linkedspec-lua 2>&1 >/dev/null)
cli_status=$?
set -e
[ "$cli_status" -eq 2 ] || fail "CLI scaffold exit was $cli_status, expected 2"
[ "$cli_stderr" = 'linkedspec-lua: backend scaffold; parser CLI is not implemented' ] ||
 fail "CLI scaffold stderr drifted"

log "validating the exact checked-in corpus through the developer command"
corpus_output=$("$LUA_CMD" lua/bin/corpus_runner.lua --corpus rust/linkedspec-runtime/tests/corpus)
printf '%s\n' "$corpus_output" | grep -F 'fixtures: 105' >/dev/null ||
 fail "corpus runner fixture count drifted"
printf '%s\n' "$corpus_output" | grep -F 'status: manifest validated; parser execution is not implemented' >/dev/null ||
 fail "corpus runner execution boundary drifted"

if command -v "$LUAJIT_CMD" >/dev/null 2>&1; then
 log "building disposable LuaJIT PCRE2 adapter"
 bash "$REPO_ROOT/tools/build_lua_native.sh" luajit "$secondary_native"
 log "running secondary LuaJIT compatibility tests"
 LUA_CPATH="$secondary_native/?.so;;" "$LUAJIT_CMD" lua/test/run.lua
else
 log "LuaJIT compatibility runtime not installed; secondary leg skipped"
fi

log "Lua local gate passed"
