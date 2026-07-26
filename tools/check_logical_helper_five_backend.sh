#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_logical_helper_five_backend.sh" "$@"
CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
JULIA_DEPOT=${LINKEDSPEC_JULIA_DEPOT_PATH:?project-data initializer did not set the Julia depot}

log() {
 printf '[logical-helper-five] %s\n' "$*"
}

fail() {
 printf '[logical-helper-five] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"
export JULIA_DEPOT_PATH="$JULIA_DEPOT"
JULIA_WRITE_DEPOT=${JULIA_DEPOT_PATH%%:*}
mkdir -p "$JULIA_WRITE_DEPOT"
LUA_NATIVE_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/linkedspec-logical-helper.XXXXXX")
trap 'rm -rf "$LUA_NATIVE_ROOT"' EXIT

log "checking the neutral schema, semantic model, topology, and drift mutations"
python3 tools/check_logical_helper_contract.py

log "checking Perl native, primary, and generated consumers"
PERL5LIB= prove -Iperl t/logical_helper_perl_contract.t

log "checking Rust native, serialized, and generated consumers"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test logical_helper_contract

log "checking Dart native, reconstructed, primary, and generated consumers"
(
 cd dart
 "$DART_CMD" test test/logical_helper_contract_test.dart
)

log "checking Julia native, reconstructed, primary, and generated consumers"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no --compiled-modules=no \
 julia/test/logical_helper_contract_test.jl

log "building and checking PUC Lua native, reconstructed, primary, and generated consumers"
bash tools/build_lua_native.sh puc "$LUA_NATIVE_ROOT/puc"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/puc/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" \
 "$LUA_CMD" lua/test/logical_helper_contract_test.lua

log "building and checking LuaJIT native, reconstructed, primary, and generated consumers"
bash tools/build_lua_native.sh luajit "$LUA_NATIVE_ROOT/luajit"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/luajit/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
 "$LUAJIT_CMD" lua/test/logical_helper_contract_test.lua

log "checking the exact logical primary projection across five commands and two environments"
bash tools/run_primary_cli_matrix.sh --case success_logical_helpers_eager

log "checking generated-source, capability, and corpus-proof ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all native, generated, primary, capability, and corpus logical boundaries pass"
