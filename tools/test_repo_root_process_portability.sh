#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_repo_root_process_portability.sh" "$@"

fail() {
 printf '[repo-root-process-test] ERROR: %s\n' "$*" >&2
 exit 1
}

device_id() {
 local path=$1
 local device
 if device=$(stat -c '%d' -- "$path" 2>/dev/null); then
  printf '%s\n' "$device"
 elif device=$(stat -f '%d' "$path" 2>/dev/null); then
  printf '%s\n' "$device"
 else
  fail "cannot determine filesystem device for $path"
 fi
}

run_named_smoke() {
 local label=$1
 shift
 local output

 if ! output=$(cd -- "$outside_cwd" && "$@"); then
  fail "$label named-spec command failed from outside the checkout"
 fi
 [[ "$output" == '["hello",["world"]]' ]] ||
  fail "$label named-spec command returned unexpected output: $output"
 printf '[repo-root-process-test] %s outside-cwd anchor passed\n' "$label"
}

(( $# == 0 )) || fail "unexpected argument: $1"
[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'process proof is not inside a managed run'

CARGO_CMD=${LINKEDSPEC_CARGO_CMD:-cargo}
PERL_CMD=${LINKEDSPEC_PERL_CMD:-perl}
JULIA_CMD=${LINKEDSPEC_JULIA_CMD:-julia}
LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
for command_name in "$CARGO_CMD" "$PERL_CMD" "$JULIA_CMD" "$LUA_CMD"; do
 command -v "$command_name" >/dev/null 2>&1 || fail "required command not found: $command_name"
done

outside_cwd=$(cd -P -- "$REPO_ROOT/.." && pwd -P)
[[ "$outside_cwd" != "$REPO_ROOT" && "$outside_cwd" != "$REPO_ROOT/"* ]] ||
 fail 'outside cwd unexpectedly resolves inside the checkout'
[[ "$(device_id "$outside_cwd")" == "$(device_id "$REPO_ROOT")" ]] ||
 fail 'outside cwd must stay on the repository filesystem'

cd "$REPO_ROOT"
bash scripts/check_repo_root_path_portability.sh
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
 --test repository_root_relocation \
 copied_primary_uses_its_moved_repository_and_requires_its_marker -- --exact

run_named_smoke perl env PERL5LIB= "$PERL_CMD" "$REPO_ROOT/bin/linkedspec" \
 --spec Lispish --input '(hello world)'

dart_config="$REPO_ROOT/dart/.dart_tool/package_config.json"
[[ -f "$dart_config" ]] || fail 'Dart package configuration is missing'
run_named_smoke dart bash "$REPO_ROOT/tools/run_dart_project_data.sh" \
 --packages="$dart_config" "$REPO_ROOT/dart/bin/linkedspec_dart.dart" \
 --spec Lispish --input '(hello world)'

run_named_smoke julia env JULIA_PKG_OFFLINE=true "$JULIA_CMD" \
 --project="$REPO_ROOT/julia" --startup-file=no --history-file=no \
 "$REPO_ROOT/julia/bin/linkedspec_julia.jl" \
 --spec Lispish --input '(hello world)'

lua_native="$LINKEDSPEC_RUN_DIR/repository-root-lua-native"
bash "$REPO_ROOT/tools/build_lua_native.sh" puc "$lua_native"
run_named_smoke lua env \
 LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
 LUA_CPATH="$lua_native/?.so;;" \
 LINKEDSPEC_LUA_TEST_RUNTIME="$LUA_CMD" \
 "$LUA_CMD" "$REPO_ROOT/lua/bin/linkedspec-lua" \
 --spec Lispish --input '(hello world)'

printf '%s\n' \
 '[repo-root-process-test] PASS: Rust moved-root selection and four outside-cwd runtime anchors are exact'
