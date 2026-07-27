#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
HELPER="$SCRIPT_DIR/project_data_env.sh"
TEST_ROOT="$REPO_ROOT/.linkedspec-data/test-project-data-env-$$"

trap 'rm -rf -- "$TEST_ROOT"' EXIT

fail() {
 printf '[project-data-test] ERROR: %s\n' "$*" >&2
 exit 1
}

assert_equal() {
 local actual=$1
 local expected=$2
 local label=$3
 [[ "$actual" == "$expected" ]] || fail "$label: expected '$expected', got '$actual'"
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

mkdir -p -- "$TEST_ROOT"
git -C "$REPO_ROOT" check-ignore -q .linkedspec-data/probe || \
 fail 'repository-local project-data root is not ignored'

(
 unset TMPDIR TMP TEMP CARGO_HOME CARGO_TARGET_DIR PUB_CACHE LINKEDSPEC_DART_HOME
 unset JULIA_DEPOT_PATH LINKEDSPEC_JULIA_DEPOT_PATH
 unset LINKEDSPEC_REPO_ROOT LINKEDSPEC_PROJECT_DATA_ROOT LINKEDSPEC_SCRATCH_ROOT LINKEDSPEC_CACHE_ROOT
 unset LINKEDSPEC_RUNS_ROOT
 unset LINKEDSPEC_HOST_TMPDIR LINKEDSPEC_HOST_TMPDIR_CAPTURED
 cd -- "$TEST_ROOT"
 # shellcheck source=project_data_env.sh
 source "$HELPER"

 assert_equal "$LINKEDSPEC_REPO_ROOT" "$REPO_ROOT" 'repository root'
 assert_equal "$LINKEDSPEC_PROJECT_DATA_ROOT" "$REPO_ROOT/.linkedspec-data" 'project-data root'
 assert_equal "$LINKEDSPEC_SCRATCH_ROOT" "$REPO_ROOT/.linkedspec-data/scratch" 'scratch root'
 assert_equal "$LINKEDSPEC_CACHE_ROOT" "$REPO_ROOT/.linkedspec-data/cache" 'cache root'
 assert_equal "$LINKEDSPEC_RUNS_ROOT" "$LINKEDSPEC_SCRATCH_ROOT/runs" 'managed-runs root'
 assert_equal "$LINKEDSPEC_HOST_TMPDIR_CAPTURED" 1 'host temporary capture marker'
 assert_equal "$LINKEDSPEC_HOST_TMPDIR" '' 'unset pre-routing host temporary root'
 assert_equal "$TMPDIR" "$LINKEDSPEC_SCRATCH_ROOT/tmp" 'TMPDIR default'
 assert_equal "$TMP" "$TMPDIR" 'TMP default'
 assert_equal "$TEMP" "$TMPDIR" 'TEMP default'
 assert_equal "$CARGO_HOME" "$LINKEDSPEC_CACHE_ROOT/cargo-home" 'Cargo cache default'
 assert_equal "$CARGO_TARGET_DIR" "$REPO_ROOT/rust/target" 'Cargo target default'
 assert_equal "$PUB_CACHE" "$LINKEDSPEC_CACHE_ROOT/dart-pub" 'Dart package-cache default'
 assert_equal "$LINKEDSPEC_DART_HOME" "$LINKEDSPEC_CACHE_ROOT/dart-home" 'Dart home default'
 assert_equal "$JULIA_DEPOT_PATH" "$LINKEDSPEC_CACHE_ROOT/julia-depot:" 'Julia depot default'
 assert_equal "$LINKEDSPEC_JULIA_DEPOT_PATH" "$JULIA_DEPOT_PATH" 'LinkedSpec Julia depot mirror'

 repo_device=$(device_id "$REPO_ROOT")
 for path in "$LINKEDSPEC_PROJECT_DATA_ROOT" "$LINKEDSPEC_SCRATCH_ROOT" "$LINKEDSPEC_CACHE_ROOT" \
  "$LINKEDSPEC_RUNS_ROOT" \
  "$TMPDIR" "$CARGO_HOME" "$CARGO_TARGET_DIR" "$PUB_CACHE" "$LINKEDSPEC_DART_HOME" \
  "${JULIA_DEPOT_PATH%:}"; do
  [[ -d "$path" ]] || fail "initializer did not create $path"
  assert_equal "$(device_id "$path")" "$repo_device" "filesystem for $path"
 done
)

same_volume_root="$TEST_ROOT/same-volume"
mkdir -p -- "$same_volume_root"/{tmp,cargo-home,cargo-target,dart-pub,julia-one,julia-two}
(
 export LINKEDSPEC_PROJECT_DATA_ROOT="$same_volume_root/custom-data"
 unset LINKEDSPEC_SCRATCH_ROOT LINKEDSPEC_CACHE_ROOT LINKEDSPEC_RUNS_ROOT
 unset LINKEDSPEC_HOST_TMPDIR LINKEDSPEC_HOST_TMPDIR_CAPTURED
 unset TMPDIR TMP TEMP CARGO_HOME CARGO_TARGET_DIR PUB_CACHE LINKEDSPEC_DART_HOME
 unset JULIA_DEPOT_PATH LINKEDSPEC_JULIA_DEPOT_PATH
 # shellcheck source=project_data_env.sh
 source "$HELPER"

 assert_equal "$LINKEDSPEC_PROJECT_DATA_ROOT" "$same_volume_root/custom-data" \
  'same-volume project-data root override'
 assert_equal "$LINKEDSPEC_SCRATCH_ROOT" "$same_volume_root/custom-data/scratch" \
  'scratch below custom project-data root'
 assert_equal "$LINKEDSPEC_CACHE_ROOT" "$same_volume_root/custom-data/cache" \
  'cache below custom project-data root'
)

(
 export TMPDIR="$same_volume_root/tmp"
 export TMP="$same_volume_root/tmp"
 export TEMP="$same_volume_root/tmp"
 export CARGO_HOME="$same_volume_root/cargo-home"
 export CARGO_TARGET_DIR="$same_volume_root/cargo-target"
 export PUB_CACHE="$same_volume_root/dart-pub"
 export LINKEDSPEC_DART_HOME="$same_volume_root/dart-home"
 export JULIA_DEPOT_PATH="$same_volume_root/julia-one:$same_volume_root/julia-two:"
 unset LINKEDSPEC_JULIA_DEPOT_PATH
 unset LINKEDSPEC_HOST_TMPDIR LINKEDSPEC_HOST_TMPDIR_CAPTURED
 # shellcheck source=project_data_env.sh
 source "$HELPER"

 assert_equal "$TMPDIR" "$same_volume_root/tmp" 'same-volume TMPDIR override'
 assert_equal "$LINKEDSPEC_HOST_TMPDIR" "$same_volume_root/tmp" 'pre-routing same-volume TMPDIR capture'
 captured_host_tmp=$LINKEDSPEC_HOST_TMPDIR
 source "$HELPER"
 assert_equal "$LINKEDSPEC_HOST_TMPDIR" "$captured_host_tmp" 'nested source preserves host TMPDIR capture'
 assert_equal "$CARGO_HOME" "$same_volume_root/cargo-home" 'same-volume Cargo override'
 assert_equal "$CARGO_TARGET_DIR" "$same_volume_root/cargo-target" 'same-volume target override'
 assert_equal "$PUB_CACHE" "$same_volume_root/dart-pub" 'same-volume Dart override'
 assert_equal "$LINKEDSPEC_DART_HOME" "$same_volume_root/dart-home" 'same-volume Dart-home override'
 assert_equal "$JULIA_DEPOT_PATH" \
  "$same_volume_root/julia-one:$same_volume_root/julia-two:" 'same-volume Julia override'
)

repo_device=$(device_id "$REPO_ROOT")
external_root=''
for candidate in /private/tmp /tmp "${HOME:-}"; do
 [[ -n "$candidate" && -d "$candidate" ]] || continue
 if [[ "$(device_id "$candidate")" != "$repo_device" ]]; then
  external_root=$candidate
  break
 fi
done

if [[ -n "$external_root" ]]; then
 (
  cd -- "$external_root"
  export TMPDIR="$external_root"
  export TMP="$external_root"
  export TEMP="$external_root"
  export CARGO_HOME="$external_root"
  export CARGO_TARGET_DIR="$external_root"
  export PUB_CACHE="$external_root"
  export LINKEDSPEC_DART_HOME="$external_root"
  export JULIA_DEPOT_PATH="$external_root:"
  export LINKEDSPEC_PROJECT_DATA_ROOT="$external_root"
  export LINKEDSPEC_SCRATCH_ROOT="$external_root"
  export LINKEDSPEC_CACHE_ROOT="$external_root"
  unset LINKEDSPEC_JULIA_DEPOT_PATH
  unset LINKEDSPEC_HOST_TMPDIR LINKEDSPEC_HOST_TMPDIR_CAPTURED
  # shellcheck source=project_data_env.sh
  source "$HELPER"

  assert_equal "$LINKEDSPEC_REPO_ROOT" "$REPO_ROOT" 'outside-cwd repository discovery'
  assert_equal "$LINKEDSPEC_PROJECT_DATA_ROOT" "$REPO_ROOT/.linkedspec-data" \
   'cross-volume project-data override replacement'
  assert_equal "$LINKEDSPEC_HOST_TMPDIR" "$external_root" \
   'cross-volume pre-routing host temporary capture'
  for path in "$TMPDIR" "$TMP" "$TEMP" "$CARGO_HOME" "$CARGO_TARGET_DIR" "$PUB_CACHE" \
   "$LINKEDSPEC_DART_HOME" \
   "${JULIA_DEPOT_PATH%:}"; do
   assert_equal "$(device_id "$path")" "$repo_device" "cross-volume replacement for $path"
  done
 )
else
 printf '%s\n' '[project-data-test] SKIP: no readable cross-filesystem directory found for hostile override test'
fi

if bash "$HELPER" >/dev/null 2>&1; then
 fail 'helper unexpectedly succeeded when executed instead of sourced'
fi

if rg -n '/Volumes/|/private/var/|/Users/' "$HELPER"; then
 fail 'helper persists a machine-specific checkout or storage root'
fi

printf '%s\n' '[project-data-test] PASS: repo-derived defaults and same-filesystem override policy'
