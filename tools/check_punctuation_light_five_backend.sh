#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_punctuation_light_five_backend.sh" "$@"
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
DART_RUN=(bash "$REPO_ROOT/tools/run_dart_project_data.sh")
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[punctuation-light-five] %s\n' "$*"
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || {
  printf '[punctuation-light-five] ERROR: required command not found: %s\n' "$1" >&2
  exit 1
 }
}

require_command python3
require_command perl
require_command prove
require_command cargo
require_command "$DART_CMD"
require_command "$JULIA_CMD"
require_command "$LUA_CMD"
require_command "$LUAJIT_CMD"

cd "$REPO_ROOT"

log "checking the neutral syntax and exclusion contract"
bash tools/run_python_project_data.sh tools/check_punctuation_light_zero_arg_contract.py

log "checking Perl typed, native, and generated behavior"
PERL5LIB= prove -Iperl t/punctuation_light_zero_arg_contract.t

log "checking Rust typed, serialized, native, and generated behavior"
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test punctuation_light_zero_arg_contract

log "checking Dart typed, emitted-state, native, and generated behavior"
(
 cd dart
 "${DART_RUN[@]}" test test/punctuation_light_zero_arg_contract_test.dart
)

log "checking Julia typed, emitted-state, native, and generated behavior"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no -e '
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT = pwd()
include("julia/test/punctuation_light_zero_arg_contract_test.jl")
'

log "checking Lua typed, serialized, and native behavior on both ABIs"
LINKEDSPEC_LUA_CMD="$LUA_CMD" LINKEDSPEC_LUAJIT_CMD="$LUAJIT_CMD" \
 bash tools/run_lua_local.sh

log "all five backends and both Lua ABIs preserve the admitted boundary"
