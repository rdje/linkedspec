#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_scalar_numeric_six_runtime.sh" "$@"
CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[scalar-numeric-six] %s\n' "$*"
}

fail() {
 printf '[scalar-numeric-six] ERROR: %s\n' "$*" >&2
 exit 1
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 command -v "$command" >/dev/null 2>&1 || fail "required command not found: $command"
done

cd "$REPO_ROOT"

log "checking neutral contract"
python3 tools/check_scalar_numeric_contract.py

log "checking Perl reference"
PERL5LIB= prove -Iperl t/scalar_numeric_contract.t

log "checking Rust"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test scalar_numeric_contract

log "checking Dart"
(
 cd dart
 "$DART_CMD" test test/runtime_interpreter_test.dart --name 'matches the neutral scalar numeric contract exactly'
)

log "checking Julia"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no -e '
using LinkedSpecJulia, JSON3, Test
contract = JSON3.read(read("capability_conformance/scalar_numeric_contract.json", String), Dict{String,Any})
@test contract["format"] == 1
@test contract["contract_id"] == "linkedspec-scalar-numeric-v1"
@test length(contract["cases"]) == 55
engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(contract["spec_source"])))
@test runtime_execute(engine, "xx").value == contract["expected"]
'

log "checking PUC Lua and LuaJIT"
LINKEDSPEC_LUA_CMD="$LUA_CMD" LINKEDSPEC_LUAJIT_CMD="$LUAJIT_CMD" bash tools/run_lua_local.sh

log "all six runtimes match all 55 cases"
