#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
RUNNER="$SCRIPT_DIR/project_data_run.sh"
TEST_ROOT="$REPO_ROOT/.linkedspec-data/test-project-data-lifecycle-$$"
DATA_ROOT="$TEST_ROOT/data"
background_pids=()
background_process_groups=()

cleanup() {
 local process_group_id
 local pid
 for process_group_id in "${background_process_groups[@]}"; do
  kill -TERM -- "-$process_group_id" 2>/dev/null || true
 done
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

wait_for_pid_exit() {
 local pid=$1
 local attempt
 for ((attempt = 0; attempt < 500; attempt += 1)); do
  kill -0 "$pid" 2>/dev/null || return 0
  sleep 0.02
 done
 fail "timed out waiting for pid $pid to exit"
}

wait_for_pid_live() {
 local pid=$1
 local attempt
 for ((attempt = 0; attempt < 500; attempt += 1)); do
  kill -0 "$pid" 2>/dev/null && return 0
  sleep 0.02
 done
 fail "timed out waiting for pid $pid to become live"
}

wait_for_process_group_exit() {
 local process_group_id=$1
 local attempt
 for ((attempt = 0; attempt < 500; attempt += 1)); do
  kill -0 -- "-$process_group_id" 2>/dev/null || return 0
  sleep 0.02
 done
 fail "timed out waiting for process group $process_group_id to exit"
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

descendant_release="$TEST_ROOT/release-background-descendant"
descendant_record="$TEST_ROOT/background-descendant.record"
project_run bash -c '
 (cd "$LINKEDSPEC_RUN_DIR/tmp" && while [[ ! -e "$2" ]]; do sleep 0.02; done) >/dev/null 2>&1 &
 printf "%s\n%s\n" "$LINKEDSPEC_RUN_DIR" "$!" >"$1"
' _ "$descendant_record" "$descendant_release" &
descendant_wrapper=$!
background_pids+=("$descendant_wrapper")
wait_for_file "$descendant_record"
mapfile -t descendant_fields <"$descendant_record"
[[ ${#descendant_fields[@]} -eq 2 ]] || fail 'background-descendant probe record is incomplete'
descendant_run=${descendant_fields[0]}
descendant_pid=${descendant_fields[1]}
wait_for_pid_exit "$(sed -n 's/^child_pid=//p' "$descendant_run/.linkedspec-run")"
descendant_process_group=$(sed -n 's/^process_group_id=//p' "$descendant_run/.linkedspec-run")
[[ "$descendant_process_group" =~ ^[1-9][0-9]*$ ]] || fail 'marker lacks process-group identity'
rg -q '^version=2$' "$descendant_run/.linkedspec-run" || fail 'managed run did not write marker version 2'
kill -0 "$descendant_wrapper" 2>/dev/null || fail 'wrapper returned while its descendant was still live'
kill -0 "$descendant_pid" 2>/dev/null || fail 'background-descendant probe exited before release'
[[ -d "$descendant_run" ]] || fail 'normal cleanup deleted scratch while a descendant was live'
touch "$descendant_release"
wait "$descendant_wrapper"
background_pids=()
wait_for_pid_exit "$descendant_pid"
[[ ! -e "$descendant_run" ]] || fail 'descendant-drained successful scratch was not removed'

signal_record="$TEST_ROOT/signal.record"
signal_child_record="$TEST_ROOT/signal-child.record"
signal_descendant_record="$TEST_ROOT/signal-descendant.record"
env \
 LINKEDSPEC_PROJECT_DATA_ROOT="$DATA_ROOT" \
 LINKEDSPEC_SCRATCH_ROOT= LINKEDSPEC_CACHE_ROOT= \
 TMPDIR= TMP= TEMP= \
 "$RUNNER" bash -c \
 '
  trap "printf \"%s\\n\" child >\"$2\"; exit 143" TERM
  (
   trap "printf \"%s\\n\" descendant >\"$3\"; exit 143" TERM
   while :; do sleep 0.02; done
  ) >/dev/null 2>&1 &
  printf "%s\n%s\n" "$LINKEDSPEC_RUN_DIR" "$!" >"$1"
  while :; do sleep 0.02; done
 ' _ "$signal_record" "$signal_child_record" "$signal_descendant_record" >/dev/null 2>&1 &
signal_wrapper=$!
background_pids+=("$signal_wrapper")
wait_for_file "$signal_record"
mapfile -t signal_fields <"$signal_record"
[[ ${#signal_fields[@]} -eq 2 ]] || fail 'signal probe record is incomplete'
signal_run=${signal_fields[0]}
signal_descendant=${signal_fields[1]}
kill -TERM "$signal_wrapper"
set +e
wait "$signal_wrapper"
signal_status=$?
set -e
background_pids=()
[[ "$signal_status" -eq 143 ]] || fail "TERM status changed across the wrapper: $signal_status"
[[ "$(<"$signal_child_record")" == child ]] || fail 'TERM did not reach the managed direct child'
[[ "$(<"$signal_descendant_record")" == descendant ]] || fail 'TERM did not reach the managed descendant'
wait_for_pid_exit "$signal_descendant"
[[ ! -e "$signal_run" ]] || fail 'trappable interrupted run did not follow default cleanup policy'

orphan_release="$TEST_ROOT/release-orphan-descendant"
orphan_record="$TEST_ROOT/orphan-descendant.record"
project_run bash -c '
 trap "" HUP
 (
  trap "" HUP
  cd "$LINKEDSPEC_RUN_DIR/tmp"
  while [[ ! -e "$2" ]]; do sleep 0.02; done
 ) >/dev/null 2>&1 &
 printf "%s\n%s\n" "$LINKEDSPEC_RUN_DIR" "$!" >"$1"
 while :; do sleep 0.02; done
' _ "$orphan_record" "$orphan_release" >/dev/null 2>&1 &
orphan_wrapper=$!
background_pids+=("$orphan_wrapper")
wait_for_file "$orphan_record"
mapfile -t orphan_fields <"$orphan_record"
[[ ${#orphan_fields[@]} -eq 2 ]] || fail 'orphan-descendant probe record is incomplete'
orphan_run=${orphan_fields[0]}
orphan_descendant=${orphan_fields[1]}
orphan_child=$(sed -n 's/^child_pid=//p' "$orphan_run/.linkedspec-run")
orphan_process_group=$(sed -n 's/^process_group_id=//p' "$orphan_run/.linkedspec-run")
[[ "$orphan_process_group" == "$orphan_child" ]] || fail 'orphan probe marker group does not match its leader'
background_process_groups+=("$orphan_process_group")
wait_for_pid_live "$orphan_child"
wait_for_pid_live "$orphan_descendant"
kill -KILL "$orphan_wrapper"
set +e
wait "$orphan_wrapper" 2>/dev/null
orphan_wrapper_status=$?
set -e
background_pids=()
[[ "$orphan_wrapper_status" -eq 137 ]] || fail "abrupt wrapper status changed: $orphan_wrapper_status"
kill -KILL "$orphan_child"
wait_for_pid_exit "$orphan_child"
kill -0 "$orphan_descendant" 2>/dev/null || fail 'orphan descendant did not survive wrapper/direct-child loss'
kill -0 -- "-$orphan_process_group" 2>/dev/null || fail 'owned process group disappeared while its descendant was live'
project_run --recover >/dev/null
[[ -d "$orphan_run" ]] || fail 'recovery deleted scratch owned by a live orphan process group'
touch "$orphan_release"
wait_for_pid_exit "$orphan_descendant"
wait_for_process_group_exit "$orphan_process_group"
background_process_groups=()
project_run --recover >/dev/null
[[ ! -e "$orphan_run" ]] || fail 'recovery did not remove scratch after its orphan process group drained'

checkout_id=$(<"$REPO_ROOT/.linkedspec-data/checkout-id")
owned_namespace="$DATA_ROOT/scratch/runs/$checkout_id"
live_leftover="$owned_namespace/interrupted-live.ABC123"
mkdir -p -- "$live_leftover"
bash -c 'while [[ ! -e "$1" ]]; do sleep 0.02; done' _ "$TEST_ROOT/stop-live-child" &
live_child=$!
background_pids+=("$live_child")
{
 printf 'version=2\n'
 printf 'checkout_id=%s\n' "$checkout_id"
 printf 'run_name=%s\n' "${live_leftover##*/}"
 printf 'run_token=ABC123\n'
 printf 'state=active\n'
 printf 'failure_policy=delete\n'
 printf 'wrapper_pid=99999999\n'
 printf 'child_pid=%s\n' "$live_child"
 printf 'process_group_id=%s\n' "$live_child"
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
 'version=2' \
 "checkout_id=$checkout_id" \
 'run_name=interrupted-default-failure.DEF456' \
 'run_token=DEF456' \
 'state=failed' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'process_group_id=99999998' \
 'exit_status=7' >"$default_failure_leftover/.linkedspec-run"
project_run --recover >/dev/null
[[ ! -e "$default_failure_leftover" ]] || fail 'recovery retained a dead default-delete failure'

invalid_owned_run="$owned_namespace/invalid-owned.BAD123"
mkdir -p -- "$invalid_owned_run"
printf '%s\n' \
 'version=2' \
 "checkout_id=$checkout_id" \
 'run_name=invalid-owned.BAD123' \
 'run_token=WRONG' \
 'state=active' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'process_group_id=99999998' \
 'exit_status=' >"$invalid_owned_run/.linkedspec-run"
project_run --recover >/dev/null 2>&1
[[ -d "$invalid_owned_run" ]] || fail 'recovery removed an owned candidate with an invalid token marker'
rm -rf -- "$invalid_owned_run"

legacy_marker_run="$owned_namespace/legacy-marker.LEG123"
mkdir -p -- "$legacy_marker_run"
printf '%s\n' \
 'version=1' \
 "checkout_id=$checkout_id" \
 'run_name=legacy-marker.LEG123' \
 'run_token=LEG123' \
 'state=active' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'process_group_id=99999998' \
 'exit_status=' >"$legacy_marker_run/.linkedspec-run"
project_run --recover >/dev/null 2>&1
[[ -d "$legacy_marker_run" ]] || fail 'recovery trusted a legacy marker without process-group authority'
rm -rf -- "$legacy_marker_run"

mismatched_group_run="$owned_namespace/mismatched-group.MIS123"
mkdir -p -- "$mismatched_group_run"
printf '%s\n' \
 'version=2' \
 "checkout_id=$checkout_id" \
 'run_name=mismatched-group.MIS123' \
 'run_token=MIS123' \
 'state=active' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'process_group_id=99999997' \
 'exit_status=' >"$mismatched_group_run/.linkedspec-run"
project_run --recover >/dev/null 2>&1
[[ -d "$mismatched_group_run" ]] || fail 'recovery trusted a marker whose process group did not match its leader'
rm -rf -- "$mismatched_group_run"

indeterminate_starting_run="$owned_namespace/indeterminate-starting.STA123"
mkdir -p -- "$indeterminate_starting_run"
printf '%s\n' \
 'version=2' \
 "checkout_id=$checkout_id" \
 'run_name=indeterminate-starting.STA123' \
 'run_token=STA123' \
 'state=starting' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=0' \
 'process_group_id=0' \
 'exit_status=' >"$indeterminate_starting_run/.linkedspec-run"
starting_list_output=$(project_run --list)
[[ "$starting_list_output" == *"indeterminate"* && \
   "$starting_list_output" == *"${indeterminate_starting_run##*/}"* ]] || \
 fail 'listing did not identify an interrupted starting marker as indeterminate'
project_run --recover >/dev/null
project_run --purge-failed >/dev/null
[[ -d "$indeterminate_starting_run" ]] || fail 'automated cleanup trusted an indeterminate starting marker'
rm -rf -- "$indeterminate_starting_run"

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
 'version=2' \
 'checkout_id=checkout-foreign' \
 'run_name=foreign.ABC123' \
 'run_token=ABC123' \
 'state=active' \
 'failure_policy=delete' \
 'wrapper_pid=99999999' \
 'child_pid=99999998' \
 'process_group_id=99999998' \
 'exit_status=' >"$foreign_run/.linkedspec-run"
project_run --recover >/dev/null
[[ -d "$foreign_run" ]] || fail 'one checkout recovery removed another checkout namespace'

printf '%s\n' \
 '[project-data-lifecycle-test] PASS: cleanup, retention, concurrency, descendant groups, signals, and interrupted-run recovery'
