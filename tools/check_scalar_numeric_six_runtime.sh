#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[scalar-numeric-six] %s\n' "$*"
}

if ! command -v "$LUAJIT_CMD" >/dev/null 2>&1; then
 printf '[scalar-numeric-six] ERROR: required LuaJIT runtime not found: %s\n' "$LUAJIT_CMD" >&2
 exit 1
fi

cd "$REPO_ROOT"

log "checking neutral contract"
python3 tools/check_scalar_numeric_contract.py

log "checking Perl reference"
PERL5LIB= prove -Iperl t/scalar_numeric_contract.t

log "checking Rust"
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test scalar_numeric_contract

log "checking Dart"
(
 cd dart
 dart test test/runtime_interpreter_test.dart --name 'matches the neutral scalar numeric contract exactly'
)

log "checking Julia"
JULIA_DEPOT_PATH=${JULIA_DEPOT_PATH:-/private/tmp/linkedspec-julia-depot} \
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
bash tools/run_lua_local.sh

log "all six runtimes match all 55 cases"
