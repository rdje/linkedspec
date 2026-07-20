#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
DEFAULT_JULIA_WRITE_DEPOT="${TMPDIR:-/tmp}/linkedspec-julia-depot"

log() {
 printf '[rule-local-cursor-five] %s\n' "$*"
}

fail() {
 printf '[rule-local-cursor-five] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

if [[ -n ${LINKEDSPEC_JULIA_DEPOT_PATH:-} ]]; then
 JULIA_DEPOT=$LINKEDSPEC_JULIA_DEPOT_PATH
elif [[ -n ${JULIA_DEPOT_PATH:-} ]]; then
 JULIA_DEPOT=$JULIA_DEPOT_PATH
else
 JULIA_BASE_DEPOT=$(
  "$JULIA_CMD" --startup-file=no --history-file=no \
   -e 'print(join(Base.DEPOT_PATH, ":"))'
 )
 JULIA_DEPOT="$DEFAULT_JULIA_WRITE_DEPOT:$JULIA_BASE_DEPOT"
fi

cd "$REPO_ROOT"
export JULIA_DEPOT_PATH="$JULIA_DEPOT"
JULIA_WRITE_DEPOT=${JULIA_DEPOT_PATH%%:*}
mkdir -p "$JULIA_WRITE_DEPOT"
LUA_NATIVE_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/linkedspec-rule-local-cursor.XXXXXX")
trap 'rm -rf "$LUA_NATIVE_ROOT"' EXIT

log "checking the neutral schema, policy, admission topology, inventory, rollout, and drift mutations"
python3 tools/check_rule_local_cursor_contract.py

log "checking the Perl exact 14-role admission consumer"
PERL5LIB= prove -Iperl t/rule_local_cursor_perl_contract.t

log "checking the Rust exact 15-role admission consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test rule_local_cursor_contract

log "checking the Dart exact 15-role admission consumer"
(
 cd dart
 "$DART_CMD" test test/rule_local_cursor_contract_test.dart
)

log "checking the Julia exact 15-role admission consumer"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no --compiled-modules=no \
 -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/rule_local_cursor_contract_test.jl")'

log "building and checking the PUC Lua exact 15-role admission consumer"
bash tools/build_lua_native.sh puc "$LUA_NATIVE_ROOT/puc"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/puc/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" \
 "$LUA_CMD" lua/test/rule_local_cursor_contract_test.lua

log "building and checking the LuaJIT exact 15-role admission consumer"
bash tools/build_lua_native.sh luajit "$LUA_NATIVE_ROOT/luajit"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/luajit/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
 "$LUAJIT_CMD" lua/test/rule_local_cursor_contract_test.lua

log "checking help, retired-option, default-OR, default-AND, and trace cases across five commands and two environments"
bash tools/run_primary_cli_matrix.sh \
 --case help \
 --case usage_removed_parse_mode \
 --case success_default_rule_seeks \
 --case success_and_rule_consumes \
 --case trace_stdout_medium

log "checking generated-source, capability, and corpus-proof ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all rule-local cursor native, generated, descriptor, removal, primary, capability, and corpus boundaries pass"
