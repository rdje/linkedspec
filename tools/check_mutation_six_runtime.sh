#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_mutation_six_runtime.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[mutation-six] %s\n' "$*"
}

fail() {
 printf '[mutation-six] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd -- "$REPO_ROOT"

log "checking the frozen nested write-vivification authority"
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py

log "checking the frozen map_leaves mutation and composed transaction authorities"
bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py

log "checking the exact Perl write and map_leaves mutation consumers"
PERL5OPT=-Mwarnings=FATAL PERL5LIB= prove -Iperl t/write_vivification_perl_contract.t t/map_leaves_mutation_perl_contract.t

log "checking the exact Rust write, map_leaves mutation, and composition consumers"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test write_vivification_contract --test map_leaves_mutation_contract

log "refreshing locked project-local Dart metadata from the offline cache"
( cd dart && bash ../tools/run_dart_project_data.sh pub get --offline )

log "checking the exact Dart write-vivification consumer"
( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/write_vivification_contract_test.dart )

log "checking the exact Dart map_leaves mutation and composition consumer"
( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/map_leaves_mutation_contract_test.dart )

log "checking the exact Julia write, map_leaves mutation, and composition consumers"
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --compiled-modules=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/write_vivification_contract_test.jl"); include("julia/test/map_leaves_mutation_contract_test.jl")'

log "checking the shared write and map_leaves mutation consumers on PUC Lua"
bash tools/run_lua_project_data.sh puc lua/test/write_vivification_contract_test.lua
bash tools/run_lua_project_data.sh puc lua/test/map_leaves_mutation_contract_test.lua

log "checking the shared write and map_leaves mutation consumers on LuaJIT"
bash tools/run_lua_project_data.sh luajit lua/test/write_vivification_contract_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/map_leaves_mutation_contract_test.lua

log "checking generated-source, capability, and language-coverage support ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all six mutation runtime routes, composed transaction boundaries, and support ledgers pass"
