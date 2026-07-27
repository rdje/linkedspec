#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_root_rule_selection_five_backend.sh" "$@"
CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_CMD=${LINKEDSPEC_DART_CMD:-dart}
DART_RUN=(bash "$REPO_ROOT/tools/run_dart_project_data.sh")
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
JULIA_DEPOT=${LINKEDSPEC_JULIA_DEPOT_PATH:?project-data initializer did not set the Julia depot}

log() {
 printf '[root-rule-selection-five] %s\n' "$*"
}

fail() {
 printf '[root-rule-selection-five] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"
export JULIA_DEPOT_PATH="$JULIA_DEPOT"
JULIA_WRITE_DEPOT=${JULIA_DEPOT_PATH%%:*}
mkdir -p "$JULIA_WRITE_DEPOT"
LUA_NATIVE_ROOT=$(mktemp -d "${TMPDIR:?project-data initializer did not set TMPDIR}/linkedspec-root-rule-selection.XXXXXX")
trap 'rm -rf "$LUA_NATIVE_ROOT"' EXIT

log "checking the neutral schema, precedence model, topology, public state, and drift mutations"
bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py

log "checking Perl core and composed route consumers"
PERL5LIB= prove -Iperl t/root_rule_selection_perl_core.t t/root_rule_selection_perl_routes.t

log "checking the Rust exact 15-role admission consumer"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test root_rule_selection_admission

log "checking the Dart exact 15-role admission consumer"
(
 cd dart
 "${DART_RUN[@]}" test test/root_rule_selection_admission_test.dart
)

log "checking the Julia exact 15-role admission consumer"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no --compiled-modules=no \
 -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/root_rule_selection_admission_test.jl")'

log "building and checking the PUC Lua exact 15-role admission consumer"
bash tools/build_lua_native.sh puc "$LUA_NATIVE_ROOT/puc"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/puc/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" \
 "$LUA_CMD" lua/test/root_rule_selection_admission_test.lua

log "building and checking the LuaJIT exact 15-role admission consumer"
bash tools/build_lua_native.sh luajit "$LUA_NATIVE_ROOT/luajit"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/luajit/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
 "$LUAJIT_CMD" lua/test/root_rule_selection_admission_test.lua

log "checking six exact root-selection cases across five commands and two environments"
bash tools/run_primary_cli_matrix.sh \
 --case success_default_first_authored_marker \
 --case success_markerless_first_authored_rule \
 --case success_explicit_top_rule \
 --case failure_invocation_missing_top_rule \
 --case trace_stdout_medium \
 --case trace_failure_invoke_escaped_field

log "checking generated-source, capability, and corpus-proof ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all root-selection native, composed, primary, capability, and corpus-proof boundaries pass"
