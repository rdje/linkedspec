#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_sexpr_document_v1.sh" "$@"
cd "$REPO_ROOT"

log() {
 printf '[sexpr-document-v1] %s\n' "$*"
}

log 'Perl authored values, failures, reuse, descriptor readiness and catch-all mutation'
PERL5LIB= prove -Iperl t/sexpr_document_v1.t

log 'Rust authored values, failures, round trips and same-engine reuse'
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline \
 -p linkedspec-runtime --test sexpr_document_v1

log 'Dart authored values, failures, round trips and same-engine reuse'
(
 cd dart
 bash ../tools/run_dart_project_data.sh test test/sexpr_document_v1_test.dart
)

log 'Julia authored values, failures, round trips and same-engine reuse'
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no \
 -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/sexpr_document_v1_test.jl")'

log 'PUC Lua authored values, failures, round trips and same-engine reuse'
bash tools/run_lua_project_data.sh puc lua/test/sexpr_document_v1_test.lua

log 'LuaJIT authored values, failures, round trips and same-engine reuse'
bash tools/run_lua_project_data.sh luajit lua/test/sexpr_document_v1_test.lua

log 'all six runtimes pass the versioned document contract'
