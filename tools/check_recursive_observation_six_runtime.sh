#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_recursive_observation_six_runtime.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[recursive-observation-six] %s\n' "$*"
}

fail() {
 printf '[recursive-observation-six] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"

log "checking the neutral recursive-observation contract, recurring topology, rollout, and mutations"
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py

log "checking the exact Perl recursive-observation consumer"
PERL5LIB= prove -Iperl t/recursive_observation_perl_contract.t

log "checking the exact Rust recursive-observation consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recursive_observation_contract

log "checking the exact Dart recursive-observation consumer"
( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/recursive_observation_contract_test.dart )

log "checking the exact Julia recursive-observation consumer"
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/recursive_observation_contract_test.jl")'

log "checking the shared recursive-observation consumer on PUC Lua"
bash tools/run_lua_project_data.sh puc lua/test/recursive_observation_contract_test.lua

log "checking the shared recursive-observation consumer on LuaJIT"
bash tools/run_lua_project_data.sh luajit lua/test/recursive_observation_contract_test.lua

log "checking generated-source, capability, and language-coverage ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all six recursive-observation runtime routes and support ledgers pass"
