#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_semantic_introspection_six_runtime.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
JULIA_READ_DEPOTS=${LINKEDSPEC_JULIA_DEPOT_PATH:?project-data initializer did not set the Julia depot}

log() {
 printf '[semantic-introspection-six] %s\n' "$*"
}

fail() {
 printf '[semantic-introspection-six] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"
TASK_ARTIFACT_ROOT=$(mktemp -d "${TMPDIR:?project-data initializer did not set TMPDIR}/linkedspec-semantic-six.XXXXXX")
RUST_TARGET_ROOT="$TASK_ARTIFACT_ROOT/rust-target"
JULIA_WRITE_DEPOT="$TASK_ARTIFACT_ROOT/julia-depot"
mkdir -p "$RUST_TARGET_ROOT" "$JULIA_WRITE_DEPOT"
cleanup() {
 rm -rf -- "$TASK_ARTIFACT_ROOT"
}
trap cleanup EXIT
export CARGO_TARGET_DIR="$RUST_TARGET_ROOT"
export JULIA_DEPOT_PATH="$JULIA_WRITE_DEPOT:$JULIA_READ_DEPOTS"

log "checking the neutral model, query answers, recurring topology, rollout, and mutations"
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py

log "checking the Perl exact twelve-role admission consumer"
PERL5LIB= prove -Iperl t/semantic_introspection_perl_admission.t

log "checking the Rust exact twelve-role admission consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test semantic_introspection_rust_admission

log "checking the Dart exact twelve-role admission consumer"
(
 cd dart
 bash ../tools/run_dart_project_data.sh test test/semantic_introspection_dart_admission_test.dart
)

log "checking the Julia exact twelve-role admission consumer"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no --compiled-modules=no \
 julia/test/semantic_introspection_julia_admission_test.jl

log "building and checking the PUC Lua exact twelve-role admission consumer"
TMPDIR="$TASK_ARTIFACT_ROOT" bash tools/run_lua_project_data.sh \
 puc lua/test/semantic_introspection_lua_admission_test.lua

log "building and checking the LuaJIT exact twelve-role admission consumer"
TMPDIR="$TASK_ARTIFACT_ROOT" bash tools/run_lua_project_data.sh \
 luajit lua/test/semantic_introspection_lua_admission_test.lua

log "checking the exact no-new-CLI projection across five commands and two environments"
bash tools/run_primary_cli_matrix.sh \
 --case success_named_source_literal_input \
 --case failure_compile_precedes_input_load \
 --case trace_failure_invoke_route_low

log "checking generated-source, capability, and language-coverage ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all six semantic consumers, primary cases, and support ledgers pass"
