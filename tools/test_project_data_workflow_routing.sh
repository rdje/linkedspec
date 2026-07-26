#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
TEST_ROOT="$REPO_ROOT/.linkedspec-data/test-project-data-routing-$$"

trap 'rm -rf -- "$TEST_ROOT"' EXIT

fail() {
 printf '[project-data-routing-test] ERROR: %s\n' "$*" >&2
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

routed_entrypoints=(
 .githooks/pre-commit
 scripts/check_doctrines.sh
 scripts/check_memory_architecture.sh
 scripts/check_task_tree_metadata.sh
 scripts/check_diagnosis_evidence.sh
 scripts/check_repo_root_path_portability.sh
 knowledge-map/scripts/gen_knowledge_map.sh
 knowledge-map/scripts/check_knowledge_map.sh
 tools/run_ci_local.sh
 tools/run_rust_local.sh
 tools/run_dart_local.sh
 tools/run_julia_local.sh
 tools/run_lua_local.sh
 tools/run_mdbook_local.sh
)

for relative in "${routed_entrypoints[@]}"; do
 path="$REPO_ROOT/$relative"
 [[ -f "$path" ]] || fail "routed entrypoint is missing: $relative"
 source_line=$(rg -n -m1 '^[[:space:]]*(source|\.) .*(_km_env_initializer|project_data_env\.sh)' "$path" |
  cut -d: -f1)
 [[ -n "$source_line" ]] || fail "entrypoint does not route the project-data initializer: $relative"
 run_line=$(rg -n -m1 '^[[:space:]]*(linkedspec_project_data_enter_run|"\$KM_RUN_INITIALIZER")' "$path" |
  cut -d: -f1)
 [[ -n "$run_line" ]] || fail "entrypoint does not enter managed run scratch: $relative"
 (( run_line > source_line )) || fail "entrypoint enters managed run scratch before environment routing: $relative"

 if awk -v last="$source_line" '
   NR >= last { exit }
   /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
   /mktemp|tempfile|tempdir|Directory\.systemTemp|(^|[[:space:]"\047])(cargo|dart|julia|lua|mdbook|perl|prove|python[0-9]*)([[:space:]"\047]|$)/ {
    print NR ":" $0
   }
  ' "$path" | rg -q .; then
  fail "entrypoint can allocate or start a runtime before storage initialization: $relative"
 fi
done

mkdir -p -- "$TEST_ROOT/cases"
repo_device=$(device_id "$REPO_ROOT")
external_root=''
for candidate in /private/tmp /tmp "${HOME:-}"; do
 [[ -n "$candidate" && -d "$candidate" ]] || continue
 if [[ "$(device_id "$candidate")" != "$repo_device" ]]; then
  external_root=$candidate
  break
 fi
done
[[ -n "$external_root" ]] || fail 'no readable other-filesystem directory is available for outside-cwd proof'

run_routed_case() {
 local name=$1
 local expectation=$2
 local script=$3
 shift 3
 local case_root="$TEST_ROOT/cases/$name"
 local output="$TEST_ROOT/$name.out"
 local status

 set +e
 (
  cd -- "$external_root"
  env \
   LINKEDSPEC_PROJECT_DATA_ROOT="$case_root" \
   LINKEDSPEC_SCRATCH_ROOT="$external_root" \
   LINKEDSPEC_CACHE_ROOT="$external_root" \
   TMPDIR="$external_root" TMP="$external_root" TEMP="$external_root" \
   CARGO_HOME="$external_root" CARGO_TARGET_DIR="$external_root" \
   PUB_CACHE="$external_root" \
   JULIA_DEPOT_PATH="$external_root:" LINKEDSPEC_JULIA_DEPOT_PATH="$external_root:" \
   "$@" bash "$script"
 ) >"$output" 2>&1
 status=$?
 set -e

 case "$expectation" in
  success)
   if [[ "$status" -ne 0 ]]; then
    sed -n '1,200p' "$output" >&2
    fail "$name failed unexpectedly; captured output shown above"
   fi
   ;;
  failure)
   [[ "$status" -ne 0 ]] || fail "$name unexpectedly reached its full workflow"
   if ! rg -q 'linkedspec-routing-test-missing-' "$output"; then
    sed -n '1,200p' "$output" >&2
    fail "$name did not reach its configured missing-runtime preflight; captured output shown above"
   fi
   ;;
  *) fail "unknown expectation for $name: $expectation" ;;
 esac

 for path in \
  "$case_root" \
  "$case_root/scratch" \
  "$case_root/scratch/tmp" \
  "$case_root/scratch/runs" \
  "$case_root/cache" \
  "$case_root/cache/cargo-home" \
  "$case_root/cache/dart-pub" \
  "$case_root/cache/julia-depot"; do
  [[ -d "$path" ]] || fail "$name did not create routed directory: $path"
  [[ "$(device_id "$path")" == "$repo_device" ]] || fail "$name routed outside repository filesystem: $path"
 done

 shopt -s nullglob
 remaining_runs=("$case_root/scratch/runs"/*/*)
 shopt -u nullglob
 (( ${#remaining_runs[@]} == 0 )) || fail "$name left managed run scratch after completion"
}

run_routed_case memory success "$REPO_ROOT/scripts/check_memory_architecture.sh"
run_routed_case doctrines success "$REPO_ROOT/scripts/check_doctrines.sh"
run_routed_case knowledge-map success "$REPO_ROOT/knowledge-map/scripts/check_knowledge_map.sh"
run_routed_case mdbook success "$REPO_ROOT/tools/run_mdbook_local.sh"
run_routed_case rust failure "$REPO_ROOT/tools/run_rust_local.sh" \
 LINKEDSPEC_CARGO_CMD=linkedspec-routing-test-missing-cargo
run_routed_case dart failure "$REPO_ROOT/tools/run_dart_local.sh" \
 LINKEDSPEC_DART_CMD=linkedspec-routing-test-missing-dart
run_routed_case julia failure "$REPO_ROOT/tools/run_julia_local.sh" \
 LINKEDSPEC_JULIA_CMD=linkedspec-routing-test-missing-julia
run_routed_case lua failure "$REPO_ROOT/tools/run_lua_local.sh" \
 LINKEDSPEC_LUA_CMD=linkedspec-routing-test-missing-lua

printf '%s\n' '[project-data-routing-test] PASS: standard workflows initialize repo-filesystem storage from outside cwd'
