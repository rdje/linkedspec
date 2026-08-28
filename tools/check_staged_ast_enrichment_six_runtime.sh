#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_staged_ast_enrichment_six_runtime.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[staged-ast-enrichment-six] %s\n' "$*"
}

fail() {
 printf '[staged-ast-enrichment-six] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"

log "checking the neutral staged-AST enrichment contract, function-body-v1 compatibility, rollout, and mutations"
bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py

log "checking the exact Perl staged-AST enrichment consumer"
PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t

log "checking the exact Rust staged-AST enrichment consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract

log "checking the exact Dart staged-AST enrichment consumer"
( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart )

log "checking the exact Julia staged-AST enrichment consumer"
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl

log "checking the shared staged-AST enrichment consumer on PUC Lua"
bash tools/run_lua_project_data.sh puc lua/test/staged_ast_enrichment_contract_test.lua

log "checking the shared staged-AST enrichment consumer on LuaJIT"
bash tools/run_lua_project_data.sh luajit lua/test/staged_ast_enrichment_contract_test.lua

log "checking typed-source, generated-source, capability, and language-coverage ledgers"
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all six staged-AST enrichment runtime routes, function-body-v1 compatibility, and support ledgers pass"
