#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
CARGO_CMD="${LINKEDSPEC_CARGO_CMD:-cargo}"
DART_CMD="${LINKEDSPEC_DART_CMD:-dart}"
JULIA_CMD="${LINKEDSPEC_JULIA_CMD:-julia}"
LUA_CMD="${LINKEDSPEC_LUA_CMD:-lua}"
DEFAULT_JULIA_DEPOT="${TMPDIR:-/tmp}/linkedspec-julia-depot"
JULIA_DEPOT="${LINKEDSPEC_JULIA_DEPOT_PATH:-${JULIA_DEPOT_PATH:-$DEFAULT_JULIA_DEPOT}}"

log() {
 printf '[cli-matrix] %s\n' "$*"
}

fail() {
 printf '[cli-matrix] ERROR: %s\n' "$*" >&2
 exit 1
}

CASE_ARGS=()
CASE_IDS=()
MANIFEST_ARGS=()
MANIFEST_PATH=
while (( $# > 0 )); do
 case "$1" in
  --manifest)
   (( $# >= 2 )) || fail "--manifest requires a path"
   [[ -n "$2" ]] || fail "--manifest path must not be empty"
   (( ${#MANIFEST_ARGS[@]} == 0 )) || fail "--manifest may be supplied only once"
   MANIFEST_ARGS=(--manifest "$2")
   MANIFEST_PATH=$2
   shift 2
   ;;
  --case)
   (( $# >= 2 )) || fail "--case requires an ID"
   [[ -n "$2" ]] || fail "--case ID must not be empty"
   CASE_ARGS+=(--case "$2")
   CASE_IDS+=("$2")
   shift 2
   ;;
  --help|-h)
   printf 'Usage: %s [--manifest PATH] [--case ID ...]\n' "$0"
   printf 'Run one manifest through five backends, optionally selecting cases by ID.\n'
   exit 0
   ;;
  *)
   fail "unknown argument: $1"
   ;;
 esac
done

for command in perl "$CARGO_CMD" "$DART_CMD" "$JULIA_CMD" "$LUA_CMD"; do
 command -v "$command" >/dev/null 2>&1 || fail "required command not found: $command"
done

cd "$REPO_ROOT"
export JULIA_DEPOT_PATH="$JULIA_DEPOT"
JULIA_WRITE_DEPOT=${JULIA_DEPOT_PATH%%:*}
mkdir -p "$JULIA_WRITE_DEPOT"
LUA_NATIVE_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/linkedspec-cli-matrix-lua.XXXXXX")
trap 'rm -rf "$LUA_NATIVE_ROOT"' EXIT

log "building Rust primary command"
"$CARGO_CMD" build --manifest-path rust/Cargo.toml -p linkedspec-runtime --bin linkedspec-rust
RUST_TARGET_DIR="${CARGO_TARGET_DIR:-$REPO_ROOT/rust/target}"
if [[ "$RUST_TARGET_DIR" != /* ]]; then
 RUST_TARGET_DIR="$REPO_ROOT/$RUST_TARGET_DIR"
fi
RUST_COMMAND="$RUST_TARGET_DIR/debug/linkedspec-rust"
[[ -x "$RUST_COMMAND" ]] || fail "built Rust command is not executable: $RUST_COMMAND"

DART_PACKAGE_CONFIG="$REPO_ROOT/dart/.dart_tool/package_config.json"
if [[ ! -f "$DART_PACKAGE_CONFIG" ]]; then
 log "resolving Dart packages"
 (
  cd "$REPO_ROOT/dart"
  "$DART_CMD" pub get
 )
fi
[[ -f "$DART_PACKAGE_CONFIG" ]] || fail "Dart package configuration was not created"

log "warming Dart primary command"
"$DART_CMD" --packages="$DART_PACKAGE_CONFIG" \
 "$REPO_ROOT/dart/bin/linkedspec_dart.dart" --help >/dev/null

log "warming Julia project in $JULIA_DEPOT_PATH"
"$JULIA_CMD" --project="$REPO_ROOT/julia" --startup-file=no --history-file=no \
 -e 'using LinkedSpecJulia' >/dev/null

log "building disposable PUC Lua native adapters"
bash "$REPO_ROOT/tools/build_lua_native.sh" puc "$LUA_NATIVE_ROOT"

run_contract() {
 local backend=$1
 local display_command=$2
 shift 2

 log "running $backend contract (default environment)"
 env -u POSIXLY_CORRECT PERL5LIB= perl tools/run_cli_conformance.pl \
  "${MANIFEST_ARGS[@]}" "${CASE_ARGS[@]}" --display-command "$display_command" -- "$@"

 log "running $backend contract (POSIX environment)"
 env POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl \
  "${MANIFEST_ARGS[@]}" "${CASE_ARGS[@]}" --display-command "$display_command" -- "$@"
}

run_contract Perl 'perl bin/linkedspec' \
 perl -I'{{REPO_ROOT}}/perl' '{{REPO_ROOT}}/bin/linkedspec'
run_contract Rust linkedspec-rust "$RUST_COMMAND"
run_contract Dart 'dart run bin/linkedspec_dart.dart' \
 "$DART_CMD" --packages='{{REPO_ROOT}}/dart/.dart_tool/package_config.json' \
 '{{REPO_ROOT}}/dart/bin/linkedspec_dart.dart'
run_contract Julia linkedspec_julia \
 "$JULIA_CMD" --project='{{REPO_ROOT}}/julia' --startup-file=no --history-file=no \
 '{{REPO_ROOT}}/julia/bin/linkedspec_julia.jl'
run_contract Lua 'lua/bin/linkedspec-lua' \
 env "LUA_CPATH=$LUA_NATIVE_ROOT/?.so;;" "$LUA_CMD" \
 '{{REPO_ROOT}}/lua/bin/linkedspec-lua'

if (( ${#CASE_IDS[@]} == 0 && ${#MANIFEST_ARGS[@]} == 0 )); then
 log "primary CLI matrix passed: 5 backends x 2 environments x 66 cases"
elif (( ${#CASE_IDS[@]} == 0 )); then
 log "primary CLI matrix passed: 5 backends x 2 environments x manifest $MANIFEST_PATH"
else
 log "primary CLI matrix passed: 5 backends x 2 environments x ${#CASE_IDS[@]} selected case(s): ${CASE_IDS[*]}"
fi
