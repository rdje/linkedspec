#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_recognition_transaction_six_runtime.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[recognition-transaction-six] %s\n' "$*"
}

fail() {
 printf '[recognition-transaction-six] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"

log "checking the neutral contract, recurring topology, rollout, and mutations"
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py

log "checking the exact Perl recognition-transaction consumer"
PERL5LIB= prove -Iperl t/recognition_transaction_perl_contract.t

log "checking the exact Rust recognition-transaction consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract

log "checking the exact Dart recognition-transaction consumer"
( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/recognition_transaction_contract_test.dart )

log "checking the exact Julia recognition-transaction consumer"
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/recognition_transaction_contract_test.jl")'

log "checking the shared recognition-transaction consumer on PUC Lua"
bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua

log "checking the shared recognition-transaction consumer on LuaJIT"
bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua

log "checking generated-source, capability, and language-coverage ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all six recognition-transaction runtime routes and support ledgers pass"
