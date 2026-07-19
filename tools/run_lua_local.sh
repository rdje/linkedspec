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
command -v perl >/dev/null 2>&1 || fail "required command not found: perl"

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
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/diagnostic_output_contract_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/logical_helper_contract_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/root_rule_selection_core_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/root_rule_selection_routes_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/rule_local_cursor_normalization_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/rule_local_cursor_execution_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/rule_local_cursor_descriptor_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/rule_local_cursor_generated_source_test.lua
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" "$LUA_CMD" lua/test/run.lua

log "running shared primary CLI contract (default environment)"
env -u POSIXLY_CORRECT PERL5LIB= perl tools/run_cli_conformance.pl \
 --display-command 'lua/bin/linkedspec-lua' -- \
 "$LUA_CMD" '{{REPO_ROOT}}/lua/bin/linkedspec-lua'

log "running shared primary CLI contract (POSIX environment)"
env POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl \
 --display-command 'lua/bin/linkedspec-lua' -- \
 "$LUA_CMD" '{{REPO_ROOT}}/lua/bin/linkedspec-lua'

log "validating the exact checked-in corpus through the developer command"
corpus_output=$("$LUA_CMD" lua/bin/corpus_runner.lua --corpus rust/linkedspec-runtime/tests/corpus)
printf '%s\n' "$corpus_output" | grep -F 'fixtures: 105' >/dev/null ||
 fail "corpus runner fixture count drifted"
printf '%s\n' "$corpus_output" | grep -F 'status: manifest validated; execution not requested' >/dev/null ||
 fail "corpus runner validation boundary drifted"

log "executing the complete checked-in corpus through the developer command"
corpus_output=$("$LUA_CMD" lua/bin/corpus_runner.lua \
 --corpus rust/linkedspec-runtime/tests/corpus --execute)
printf '%s\n' "$corpus_output" | grep -F 'PASS proof_edge_array_literal' >/dev/null ||
 fail "corpus runner first result drifted"
printf '%s\n' "$corpus_output" | grep -F 'PASS capability_capture_named_surface' >/dev/null ||
 fail "corpus runner last result drifted"
printf '%s\n' "$corpus_output" | grep -F 'summary: 105 passed, 0 failed' >/dev/null ||
 fail "corpus runner complete execution drifted"

if command -v "$LUAJIT_CMD" >/dev/null 2>&1; then
 log "building disposable LuaJIT PCRE2 adapter"
 bash "$REPO_ROOT/tools/build_lua_native.sh" luajit "$secondary_native"
 log "running secondary LuaJIT compatibility tests"
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
 "$LUAJIT_CMD" lua/test/diagnostic_output_contract_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/logical_helper_contract_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/root_rule_selection_core_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/root_rule_selection_routes_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/rule_local_cursor_normalization_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/rule_local_cursor_execution_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/rule_local_cursor_descriptor_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/rule_local_cursor_generated_source_test.lua
 LUA_CPATH="$secondary_native/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
  "$LUAJIT_CMD" lua/test/run.lua
else
 log "LuaJIT compatibility runtime not installed; secondary leg skipped"
fi

log "Lua local gate passed"
