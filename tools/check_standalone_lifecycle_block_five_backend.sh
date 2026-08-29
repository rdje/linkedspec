#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_standalone_lifecycle_block_five_backend.sh" "$@"

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
DART_RUN=(bash "$REPO_ROOT/tools/run_dart_project_data.sh")
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
JULIA_READ_DEPOTS=${LINKEDSPEC_JULIA_DEPOT_PATH:?project-data initializer did not set the Julia depot}

log() {
 printf '[standalone-lifecycle-five] %s\n' "$*"
}

fail() {
 printf '[standalone-lifecycle-five] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

for command in python3 perl prove "$CARGO_CMD" dart "$JULIA_CMD" "$LUA_CMD" "$LUAJIT_CMD"; do
 require_command "$command"
done

cd "$REPO_ROOT"
TASK_ARTIFACT_ROOT=$(mktemp -d "${TMPDIR:?project-data initializer did not set TMPDIR}/linkedspec-standalone-lifecycle.XXXXXX")
RUST_TARGET_ROOT="$TASK_ARTIFACT_ROOT/rust-target"
LUA_NATIVE_ROOT="$TASK_ARTIFACT_ROOT/lua-native"
JULIA_WRITE_DEPOT="$TASK_ARTIFACT_ROOT/julia-depot"
mkdir -p "$RUST_TARGET_ROOT" "$LUA_NATIVE_ROOT" "$JULIA_WRITE_DEPOT"
cleanup() {
 rm -rf "$TASK_ARTIFACT_ROOT"
}
trap cleanup EXIT
export CARGO_TARGET_DIR="$RUST_TARGET_ROOT"
export JULIA_DEPOT_PATH="$JULIA_WRITE_DEPOT:$JULIA_READ_DEPOTS"

log "checking neutral schema, closed rollout, public markers, and drift mutations"
bash tools/run_python_project_data.sh tools/check_standalone_lifecycle_block_contract.py

log "checking Perl bootstrap, native, malformed, and emitted-source roles"
PERL5LIB= prove -Iperl t/standalone_lifecycle_block_perl_contract.t

log "checking permanent self-hosted grammar precedence and semantic twins"
PERL5LIB= prove -Iperl t/standalone_lifecycle_block_self_hosted_contract.t

log "checking Rust native, reconstructed, generated, and legacy roles"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test standalone_lifecycle_block_contract

log "checking Dart native, reconstructed, generated, and legacy roles"
(
 cd dart
 "${DART_RUN[@]}" test test/standalone_lifecycle_block_contract_test.dart
)

log "checking Julia native, reconstructed, generated, and legacy roles"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no --compiled-modules=no \
 -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT = pwd(); include("julia/test/standalone_lifecycle_block_contract_test.jl")'

log "building and checking the shared Lua source on PUC Lua"
bash tools/build_lua_native.sh puc "$LUA_NATIVE_ROOT/puc"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/puc/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" \
 "$LUA_CMD" lua/test/standalone_lifecycle_block_contract_test.lua

log "building and checking the shared Lua source on LuaJIT"
bash tools/build_lua_native.sh luajit "$LUA_NATIVE_ROOT/luajit"
LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
LUA_CPATH="$LUA_NATIVE_ROOT/luajit/?.so;;" \
LINKEDSPEC_LUA_TEST_RUNTIME="$LUAJIT_CMD" \
 "$LUAJIT_CMD" lua/test/standalone_lifecycle_block_contract_test.lua

log "checking generated-source, capability, and language-coverage ledgers"
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "all five backends, six runtime routes, self-hosted grammar, and public no-drift pass"
