#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_typed_source_location_six_runtime.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[typed-source-location-six] %s\n' "$*"
}

fail() {
 printf '[typed-source-location-six] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"

log "checking the neutral algebra, recurring topology, rollout, and mutations"
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py

log "checking the Perl immutable values, exact helper projections, and recursive observation"
PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t t/recursive_observation_perl_contract.t

log "checking the Rust immutable values and exact helper projections"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract

log "checking the Dart immutable values and exact helper projections"
( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart )

log "checking the Julia immutable values and exact helper projections"
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/typed_source_location_contract_test.jl")'

log "checking the shared Lua immutable values and exact helper projections on PUC Lua"
bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua

log "checking the shared Lua immutable values and exact helper projections on LuaJIT"
bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua

log "checking generated-source, capability, and language-coverage ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all six typed source-location runtime routes and support ledgers pass"
