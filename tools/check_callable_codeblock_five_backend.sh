#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_callable_codeblock_five_backend.sh" "$@"
PYTHON_CMD=${LINKEDSPEC_PYTHON_CMD:-python3}
CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}

log() {
 printf '[callable-codeblock-five] %s\n' "$*"
}

fail() {
 printf '[callable-codeblock-five] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in prove "$PYTHON_CMD" "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"

log "checking the neutral schema, semantics, recurring topology, status, and governance mutations"
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py

log "checking the Perl construction, invocation, contextual, and route consumer"
PERL5LIB= prove -Iperl t/callable_codeblock_literal_contract.t

log "checking the Rust construction, invocation, contextual, and route consumer"
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml \
 -p linkedspec-runtime --test callable_codeblock_literal_contract

log "checking the Dart construction, invocation, contextual, and route consumer"
(
 cd dart
 bash ../tools/run_dart_project_data.sh test test/callable_codeblock_literal_contract_test.dart
)

log "checking the Julia construction, invocation, contextual, and route consumer"
bash tools/run_julia_project_data.sh --project=julia \
 -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/callable_codeblock_literal_contract_test.jl")'

log "checking the PUC Lua construction, invocation, contextual, and route consumer"
bash tools/run_lua_project_data.sh \
 puc lua/test/callable_codeblock_literal_contract_test.lua

log "checking the LuaJIT construction, invocation, contextual, and route consumer"
bash tools/run_lua_project_data.sh \
 luajit lua/test/callable_codeblock_literal_contract_test.lua

log "all five-backend callable-codeblock contract and authority routes pass"
