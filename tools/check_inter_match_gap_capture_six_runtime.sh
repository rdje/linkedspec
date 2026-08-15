#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)

source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_inter_match_gap_capture_six_runtime.sh" "$@"

log() {
 printf '[inter-match-gap-matrix] %s\n' "$*"
}

cd -- "$REPO_ROOT"

log "checking the complete backend-neutral contract"
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py

log "checking complete runtime route perl_runtime: t/inter_match_gap_capture_perl_contract.t"
PERL5LIB= prove -Iperl t/inter_match_gap_capture_perl_contract.t
log "checking complete runtime route rust_runtime: rust/linkedspec-runtime/tests/inter_match_gap_capture_contract.rs"
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test inter_match_gap_capture_contract
log "checking complete runtime route dart_runtime: dart/test/inter_match_gap_capture_contract_test.dart"
( cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/inter_match_gap_capture_contract_test.dart )
log "skipping pending runtime route julia_runtime: julia/test/inter_match_gap_capture_contract_test.jl"
log "skipping pending runtime route puc_lua_runtime: lua/test/inter_match_gap_capture_contract_test.lua"
log "skipping pending runtime route luajit_runtime: lua/test/inter_match_gap_capture_contract_test.lua"

log "PASS: neutral, Perl, Rust, and Dart runtime routes complete; three later runtime routes remain pending"
