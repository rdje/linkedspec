#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_duplicate_regex_slot_identity_five_backend.sh" "$@"
CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
DART_RUN=(bash "$REPO_ROOT/tools/run_dart_project_data.sh")
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
JULIA_READ_DEPOTS=${LINKEDSPEC_JULIA_DEPOT_PATH:?project-data initializer did not set the Julia depot}

log() {
 printf '[duplicate-regex-slot-five] %s\n' "$*"
}

fail() {
 printf '[duplicate-regex-slot-five] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"
TASK_ARTIFACT_ROOT=$(mktemp -d "${TMPDIR:?project-data initializer did not set TMPDIR}/linkedspec-duplicate-slot.XXXXXX")
RUST_TARGET_ROOT="$TASK_ARTIFACT_ROOT/rust-target"
LUA_NATIVE_ROOT="$TASK_ARTIFACT_ROOT/lua-native"
JULIA_WRITE_DEPOT="$TASK_ARTIFACT_ROOT/julia-depot"
mkdir -p "$RUST_TARGET_ROOT" "$LUA_NATIVE_ROOT" "$JULIA_WRITE_DEPOT"
cleanup() {
 rm -rf "$TASK_ARTIFACT_ROOT"
}
trap cleanup EXIT
export JULIA_DEPOT_PATH="$JULIA_WRITE_DEPOT:$JULIA_READ_DEPOTS"
export CARGO_TARGET_DIR="$RUST_TARGET_ROOT"

log "checking the neutral schema, model, topology, public state, closure, and drift mutations"
bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py

log "checking the Perl exact 12-role admission consumer"
PERL5LIB= prove -Iperl t/duplicate_regex_slot_identity_perl_contract.t

log "checking the Rust exact 15-role admission consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test duplicate_regex_slot_identity_contract

log "checking the Dart exact 15-role admission consumer"
(
 cd dart
 "${DART_RUN[@]}" test test/duplicate_regex_slot_identity_contract_test.dart
)

log "checking the Julia exact 15-role admission consumer"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no --compiled-modules=no \
 -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/duplicate_regex_slot_identity_contract_test.jl")'

log "building and checking the PUC Lua exact 15-role admission consumer"
bash tools/build_lua_native.sh puc "$LUA_NATIVE_ROOT/puc"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/puc/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" \
 "$LUA_CMD" lua/test/duplicate_regex_slot_identity_contract_test.lua

log "building and checking the LuaJIT exact 15-role admission consumer"
bash tools/build_lua_native.sh luajit "$LUA_NATIVE_ROOT/luajit"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/luajit/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
 "$LUAJIT_CMD" lua/test/duplicate_regex_slot_identity_contract_test.lua

log "checking exact AND consumption across five commands and two environments"
bash tools/run_primary_cli_matrix.sh --case success_and_rule_consumes

log "checking generated-source, capability, and corpus-proof ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all duplicate-slot native, generated, descriptor, trace, primary, and support boundaries pass"
