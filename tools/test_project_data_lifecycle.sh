#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
RUNNER="$SCRIPT_DIR/project_data_run.sh"
TEST_ROOT="$REPO_ROOT/.linkedspec-data/test-project-data-lifecycle-$$"
DATA_ROOT="$TEST_ROOT/data"
background_pids=()

cleanup() {
 local pid
 for pid in "${background_pids[@]}"; do
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
 done
 rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
 printf '[project-data-lifecycle-test] ERROR: %s\n' "$*" >&2
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

project_run() {
 env \
  LINKEDSPEC_PROJECT_DATA_ROOT="$DATA_ROOT" \
  LINKEDSPEC_SCRATCH_ROOT= LINKEDSPEC_CACHE_ROOT= \
  TMPDIR= TMP= TEMP= \
  LINKEDSPEC_FAILED_RUN_POLICY="${LINKEDSPEC_FAILED_RUN_POLICY:-delete}" \
  "$RUNNER" "$@"
}

wait_for_file() {
 local path=$1
 local attempt
 for ((attempt = 0; attempt < 500; attempt += 1)); do
  [[ -s "$path" ]] && return 0
  sleep 0.02
 done
 fail "timed out waiting for $path"
}

mkdir -p -- "$TEST_ROOT"
repo_device=$(device_id "$REPO_ROOT")

success_record="$TEST_ROOT/success.record"
project_run bash -c '
 printf "%s\n%s\n%s\n%s\n" "$LINKEDSPEC_RUN_DIR" "$LINKEDSPEC_RUN_TOKEN" "$TMPDIR" "$LINKEDSPEC_CACHE_ROOT" >"$1"
 [[ -d "$LINKEDSPEC_RUN_DIR" && "$TMPDIR" == "$LINKEDSPEC_RUN_DIR/tmp" ]]
 touch "$LINKEDSPEC_CACHE_ROOT/lifecycle-retained-cache"
' _ "$success_record"
mapfile -t success_fields <"$success_record"
[[ ${#success_fields[@]} -eq 4 ]] || fail 'successful run did not export the complete lifecycle contract'
success_run=${success_fields[0]}
[[ "${success_fields[1]}" == "${success_run##*.}" ]] || fail 'run token does not match collision-safe directory name'
[[ ! -e "$success_run" ]] || fail 'successful run scratch was not removed'
[[ -f "${success_fields[3]}/lifecycle-retained-cache" ]] || fail 'successful cleanup removed retained cache data'
[[ "$(device_id "$DATA_ROOT")" == "$repo_device" ]] || fail 'managed data root is not on the repository filesystem'

non_executable_script="$TEST_ROOT/non-executable.sh"
non_executable_record="$TEST_ROOT/non-executable.record"
{
 printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail'
 printf 'source %q\n' "$SCRIPT_DIR/project_data_env.sh"
 printf '%s\n' \
  'linkedspec_project_data_enter_run "$0" "$@"' \
  'printf "%s\n" "$LINKEDSPEC_RUN_DIR" >"$1"'
} >"$non_executable_script"
chmod 600 "$non_executable_script"
env \
 LINKEDSPEC_PROJECT_DATA_ROOT="$DATA_ROOT" \
 LINKEDSPEC_SCRATCH_ROOT= LINKEDSPEC_CACHE_ROOT= \
 TMPDIR= TMP= TEMP= \
 bash "$non_executable_script" "$non_executable_record"
non_executable_run=$(<"$non_executable_record")
[[ "${non_executable_run##*/}" == non-executable.sh.* ]] || fail 'routed run label lost the source script identity'
[[ ! -e "$non_executable_run" ]] || fail 'non-executable shell-script run was not cleaned'

failed_delete_record="$TEST_ROOT/failed-delete.record"
set +e
project_run bash -c 'printf "%s\n" "$LINKEDSPEC_RUN_DIR" >"$1"; exit 7' _ "$failed_delete_record"
failed_delete_status=$?
set -e
[[ "$failed_delete_status" -eq 7 ]] || fail "failed run status changed: $failed_delete_status"
failed_delete_run=$(<"$failed_delete_record")
[[ ! -e "$failed_delete_run" ]] || fail 'default failed-run policy retained scratch'

failed_retain_record="$TEST_ROOT/failed-retain.record"
set +e
LINKEDSPEC_FAILED_RUN_POLICY=retain project_run bash -c \
 'printf "%s\n" "$LINKEDSPEC_RUN_DIR" >"$1"; exit 9' _ "$failed_retain_record"
failed_retain_status=$?
set -e
[[ "$failed_retain_status" -eq 9 ]] || fail "retained failure status changed: $failed_retain_status"
failed_retain_run=$(<"$failed_retain_record")
[[ -d "$failed_retain_run" ]] || fail 'explicit failed-run retention did not preserve scratch'
rg -q '^state=failed$' "$failed_retain_run/.linkedspec-run" || fail 'retained failure marker lacks failed state'
rg -q '^failure_policy=retain$' "$failed_retain_run/.linkedspec-run" || \
 fail 'retained failure marker lacks explicit retention policy'
rg -q '^exit_status=9$' "$failed_retain_run/.linkedspec-run" || fail 'retained failure marker lacks exit status'

list_output=$(project_run --list)
[[ "$list_output" == *"failed"* && "$list_output" == *"${failed_retain_run##*/}"* ]] || \
 fail 'run listing does not identify the retained failure'
project_run --recover >/dev/null
[[ -d "$failed_retain_run" ]] || fail 'interrupted-run recovery deleted an explicitly retained failure'
project_run --purge-failed >/dev/null
[[ ! -e "$failed_retain_run" ]] || fail 'explicit failed-run purge did not remove the retained run'

release_one="$TEST_ROOT/release-one"
release_two="$TEST_ROOT/release-two"
concurrent_one="$TEST_ROOT/concurrent-one.record"
concurrent_two="$TEST_ROOT/concurrent-two.record"
project_run bash -c \
 'printf "%s\n" "$LINKEDSPEC_RUN_DIR" >"$1"; while [[ ! -e "$2" ]]; do sleep 0.02; done' \
 _ "$concurrent_one" "$release_one" &
pid_one=$!
background_pids+=("$pid_one")
project_run bash -c \
 'printf "%s\n" "$LINKEDSPEC_RUN_DIR" >"$1"; while [[ ! -e "$2" ]]; do sleep 0.02; done' \
 _ "$concurrent_two" "$release_two" &
pid_two=$!
background_pids+=("$pid_two")
wait_for_file "$concurrent_one"
wait_for_file "$concurrent_two"
run_one=$(<"$concurrent_one")
run_two=$(<"$concurrent_two")
[[ "$run_one" != "$run_two" ]] || fail 'concurrent invocations collided on one run directory'
[[ -d "$run_one" && -d "$run_two" ]] || fail 'concurrent run directory disappeared while its owner was live'
project_run --recover >/dev/null
[[ -d "$run_one" && -d "$run_two" ]] || fail 'recovery removed a live concurrent run'
touch "$release_one" "$release_two"
wait "$pid_one"
wait "$pid_two"
background_pids=()
[[ ! -e "$run_one" && ! -e "$run_two" ]] || fail 'concurrent successful scratch was not cleaned'

signal_record="$TEST_ROOT/signal.record"
env \
 LINKEDSPEC_PROJECT_DATA_ROOT="$DATA_ROOT" \
 LINKEDSPEC_SCRATCH_ROOT= LINKEDSPEC_CACHE_ROOT= \
 TMPDIR= TMP= TEMP= \
 "$RUNNER" bash -c \
 'trap "exit 143" TERM; printf "%s\n" "$LINKEDSPEC_RUN_DIR" >"$1"; while :; do sleep 0.02; done' \
 _ "$signal_record" &
signal_wrapper=$!
background_pids+=("$signal_wrapper")
wait_for_file "$signal_record"
signal_run=$(<"$signal_record")
kill -TERM "$signal_wrapper"
set +e
wait "$signal_wrapper"
signal_status=$?
set -e
background_pids=()
[[ "$signal_status" -eq 143 ]] || fail "TERM status changed across the wrapper: $signal_status"
[[ ! -e "$signal_run" ]] || fail 'trappable interrupted run did not follow default cleanup policy'

checkout_id=$(<"$REPO_ROOT/.linkedspec-data/checkout-id")
owned_namespace="$DATA_ROOT/scratch/runs/$checkout_id"
live_leftover="$owned_namespace/interrupted-live.ABC123"
mkdir -p -- "$live_leftover"
bash -c 'while [[ ! -e "$1" ]]; do sleep 0.02; done' _ "$TEST_ROOT/stop-live-child" &
live_child=$!
background_pids+=("$live_child")
{
 printf 'version=1\n'
 printf 'checkout_id=%s\n' "$checkout_id"
 printf 'run_name=%s\n' "${live_leftover##*/}"
 printf 'run_token=ABC123\n'
 printf 'state=active\n'
 printf 'failure_policy=delete\n'
 printf 'wrapper_pid=99999999\n'
 printf 'child_pid=%s\n' "$live_child"
 printf 'exit_status=\n'
} >"$live_leftover/.linkedspec-run"
project_run --recover >/dev/null
[[ -d "$live_leftover" ]] || fail 'recovery removed interrupted scratch while its child was still live'
touch "$TEST_ROOT/stop-live-child"
wait "$live_child"
background_pids=()
project_run --recover >/dev/null
[[ ! -e "$live_leftover" ]] || fail 'recovery did not remove an abandoned interrupted run'

default_failure_leftover="$owned_namespace/interrupted-default-failure.DEF456"
mkdir -p -- "$default_failure_leftover"
printf '%s\n' \
 'version=1' \
 "checkout_id=$checkout_id" \
 'run_name=interrupted-default-failure.DEF456' \
 'run_token=DEF456' \
 'state=failed' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'exit_status=7' >"$default_failure_leftover/.linkedspec-run"
project_run --recover >/dev/null
[[ ! -e "$default_failure_leftover" ]] || fail 'recovery retained a dead default-delete failure'

invalid_owned_run="$owned_namespace/invalid-owned.BAD123"
mkdir -p -- "$invalid_owned_run"
printf '%s\n' \
 'version=1' \
 "checkout_id=$checkout_id" \
 'run_name=invalid-owned.BAD123' \
 'run_token=WRONG' \
 'state=active' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'exit_status=' >"$invalid_owned_run/.linkedspec-run"
project_run --recover >/dev/null 2>&1
[[ -d "$invalid_owned_run" ]] || fail 'recovery removed an owned candidate with an invalid token marker'
rm -rf -- "$invalid_owned_run"

rmdir "$owned_namespace"
symlink_target="$TEST_ROOT/symlink-target"
mkdir -p -- "$symlink_target"
touch "$symlink_target/must-survive"
ln -s "$symlink_target" "$owned_namespace"
set +e
project_run --list >"$TEST_ROOT/symlink-list.out" 2>&1
symlink_status=$?
set -e
[[ "$symlink_status" -ne 0 ]] || fail 'runner accepted a symbolic-link checkout namespace'
[[ -f "$symlink_target/must-survive" ]] || fail 'symbolic-link namespace rejection mutated its target'
rm -f -- "$owned_namespace"

foreign_namespace="$DATA_ROOT/scratch/runs/checkout-foreign"
foreign_run="$foreign_namespace/foreign.ABC123"
mkdir -p -- "$foreign_run"
printf '%s\n' \
 'version=1' \
 'checkout_id=checkout-foreign' \
 'run_name=foreign.ABC123' \
 'run_token=ABC123' \
 'state=active' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'exit_status=' >"$foreign_run/.linkedspec-run"
project_run --recover >/dev/null
[[ -d "$foreign_run" ]] || fail 'one checkout recovery removed another checkout namespace'

printf '%s\n' '[project-data-lifecycle-test] PASS: cleanup, retention, concurrency, and interrupted-run recovery'
