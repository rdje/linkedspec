#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_mcp_six_runtime.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
JULIA_READ_DEPOTS=${LINKEDSPEC_JULIA_DEPOT_PATH:?project-data initializer did not set the Julia depot}

log() {
 printf '[mcp-six-runtime] %s\n' "$*"
}

fail() {
 printf '[mcp-six-runtime] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"
TASK_ARTIFACT_ROOT=$(mktemp -d "${TMPDIR:?project-data initializer did not set TMPDIR}/linkedspec-mcp-six.XXXXXX")
RUST_TARGET_ROOT="$TASK_ARTIFACT_ROOT/rust-target"
JULIA_WRITE_DEPOT="$TASK_ARTIFACT_ROOT/julia-depot"
mkdir -p "$RUST_TARGET_ROOT" "$JULIA_WRITE_DEPOT"
cleanup() {
 rm -rf -- "$TASK_ARTIFACT_ROOT"
}
trap cleanup EXIT
export CARGO_TARGET_DIR="$RUST_TARGET_ROOT"
export JULIA_DEPOT_PATH="$JULIA_WRITE_DEPOT:$JULIA_READ_DEPOTS"

log "checking the neutral semantic contract before composing transports"
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py

log "materializing and independently validating the neutral MCP transport contract"
bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py

log "checking all five generated MCP bindings in contract order"
bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py
bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py

log "checking the Perl all-twenty direct/MCP identity consumer"
PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t

log "checking the Rust all-twenty direct/MCP identity consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test mcp_server_rust_admission

log "checking the Dart all-twenty direct/MCP identity consumer"
(
 cd dart
 bash ../tools/run_dart_project_data.sh test test/mcp_server_dart_admission_test.dart
)

log "checking the Julia all-twenty direct/MCP identity consumer"
bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include("julia/test/mcp_server_julia_admission_test.jl")'

log "building and checking the PUC Lua all-twenty direct/MCP identity consumer"
TMPDIR="$TASK_ARTIFACT_ROOT" bash tools/run_lua_project_data.sh \
 puc lua/test/mcp_server_lua_admission_test.lua

log "building and checking the LuaJIT all-twenty direct/MCP identity consumer"
TMPDIR="$TASK_ARTIFACT_ROOT" bash tools/run_lua_project_data.sh \
 luajit lua/test/mcp_server_lua_admission_test.lua

log "checking the five-implementation/six-runtime admission ledger"
bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py

log "checking exact no-new-CLI behavior across five commands and two environments"
bash tools/run_primary_cli_matrix.sh \
 --case success_named_source_literal_input \
 --case failure_compile_precedes_input_load \
 --case trace_failure_invoke_route_low

log "all six MCP consumers, governance ledgers, and primary no-drift cases pass"
