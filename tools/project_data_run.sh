#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$SCRIPT_DIR/project_data_env.sh"

fail() {
 printf 'project-data-run: ERROR: %s\n' "$*" >&2
 exit 1
}

usage() {
 cat <<'EOF'
usage: tools/project_data_run.sh COMMAND [ARG ...]
       tools/project_data_run.sh --list
       tools/project_data_run.sh --recover
       tools/project_data_run.sh --purge-failed

Run COMMAND inside collision-safe repository-filesystem scratch. Successful runs and failed runs under the
default delete policy are removed. Set LINKEDSPEC_FAILED_RUN_POLICY=retain to keep a failed run for diagnosis.
--list reports owned leftovers, --recover removes abandoned interrupted runs after liveness checks, and
--purge-failed explicitly removes retained failed runs after the same checks.
EOF
}

relative_display() {
 local path=$1
 case "$path" in
  "$REPO_ROOT"/*) printf '%s\n' "${path#"$REPO_ROOT"/}" ;;
  *) printf '%s\n' "$path" ;;
 esac
}

pid_is_live() {
 local pid=${1:-0}
 [[ "$pid" =~ ^[1-9][0-9]*$ ]] && kill -0 "$pid" 2>/dev/null
}

checkout_id_dir="$REPO_ROOT/.linkedspec-data"
checkout_id_file="$checkout_id_dir/checkout-id"
[[ ! -L "$checkout_id_dir" ]] || fail 'checkout identity directory must not be a symbolic link'
mkdir -p -- "$checkout_id_dir"
[[ ! -L "$checkout_id_file" ]] || fail 'checkout identity must not be a symbolic link'

if [[ ! -s "$checkout_id_file" ]]; then
 checkout_id_candidate=$(mktemp "$checkout_id_dir/.checkout-id.XXXXXX")
 checkout_id_value="checkout-$(date +%s)-$$-${RANDOM}${RANDOM}"
 chmod 600 "$checkout_id_candidate"
 printf '%s\n' "$checkout_id_value" >"$checkout_id_candidate"
 if ! ln "$checkout_id_candidate" "$checkout_id_file" 2>/dev/null; then
  [[ -s "$checkout_id_file" && ! -L "$checkout_id_file" ]] || {
   rm -f -- "$checkout_id_candidate"
   fail 'cannot establish checkout identity'
  }
 fi
 rm -f -- "$checkout_id_candidate"
fi

IFS= read -r checkout_id <"$checkout_id_file" || fail 'cannot read checkout identity'
[[ "$checkout_id" =~ ^checkout-[A-Za-z0-9._-]+$ ]] || fail 'checkout identity is malformed'

runs_root=$LINKEDSPEC_RUNS_ROOT
checkout_runs="$runs_root/$checkout_id"
[[ ! -L "$checkout_runs" ]] || fail 'checkout run namespace must not be a symbolic link'
mkdir -p -- "$checkout_runs"
chmod 700 "$runs_root" "$checkout_runs"

marker_read() {
 local marker=$1
 marker_version=''
 marker_checkout_id=''
 marker_run_name=''
 marker_run_token=''
 marker_state=''
 marker_failure_policy=''
 marker_wrapper_pid='0'
 marker_child_pid='0'
 marker_exit_status=''

 [[ -f "$marker" && ! -L "$marker" ]] || return 1
 while IFS='=' read -r key value; do
  case "$key" in
   version) marker_version=$value ;;
   checkout_id) marker_checkout_id=$value ;;
   run_name) marker_run_name=$value ;;
   run_token) marker_run_token=$value ;;
   state) marker_state=$value ;;
   failure_policy) marker_failure_policy=$value ;;
   wrapper_pid) marker_wrapper_pid=$value ;;
   child_pid) marker_child_pid=$value ;;
   exit_status) marker_exit_status=$value ;;
  esac
 done <"$marker"

 [[ "$marker_version" == 1 && "$marker_checkout_id" == "$checkout_id" &&
    "$marker_run_name" =~ ^[A-Za-z0-9._-]+$ && "$marker_run_token" =~ ^[A-Za-z0-9._-]+$ &&
    "$marker_run_token" == "${marker_run_name##*.}" &&
    "$marker_state" =~ ^(starting|active|failed|succeeded)$ &&
    "$marker_failure_policy" =~ ^(delete|retain)$ &&
    "$marker_wrapper_pid" =~ ^[0-9]+$ && "$marker_child_pid" =~ ^[0-9]+$ ]]
}

safe_remove_owned_run() {
 local run_dir=$1
 local expected_name
 expected_name=$(basename -- "$run_dir")

 [[ -d "$run_dir" && ! -L "$run_dir" ]] || return 1
 [[ "$(dirname -- "$run_dir")" == "$checkout_runs" ]] || return 1
 marker_read "$run_dir/.linkedspec-run" || return 1
 [[ "$marker_run_name" == "$expected_name" && "$marker_run_token" == "${expected_name##*.}" ]] || return 1
 rm -rf -- "$run_dir"
}

scan_runs() {
 local action=$1
 local run_dir
 local run_name
 local classification
 local found=0
 local removed=0
 local skipped=0
 local -a run_dirs=()

 shopt -s nullglob
 run_dirs=("$checkout_runs"/*)
 shopt -u nullglob

 for run_dir in "${run_dirs[@]}"; do
  found=$((found + 1))
  run_name=$(basename -- "$run_dir")
  if ! marker_read "$run_dir/.linkedspec-run" || [[ "$marker_run_name" != "$run_name" ]]; then
   printf 'project-data-run: SKIP invalid owned-run candidate: %s\n' "$(relative_display "$run_dir")" >&2
   skipped=$((skipped + 1))
   continue
  fi

  if pid_is_live "$marker_wrapper_pid" || pid_is_live "$marker_child_pid"; then
   classification=live
  elif [[ "$marker_state" == failed && "$marker_failure_policy" == retain ]]; then
   classification=failed
  else
   classification=abandoned
  fi

  case "$action:$classification" in
   list:*)
    printf 'project-data-run: %s state=%s wrapper_pid=%s child_pid=%s path=%s\n' \
     "$classification" "$marker_state" "$marker_wrapper_pid" "$marker_child_pid" \
     "$(relative_display "$run_dir")"
    ;;
   recover:abandoned|purge-failed:failed)
    if safe_remove_owned_run "$run_dir"; then
     printf 'project-data-run: removed %s run: %s\n' "$classification" "$(relative_display "$run_dir")"
     removed=$((removed + 1))
    else
     printf 'project-data-run: SKIP removal validation failed: %s\n' "$(relative_display "$run_dir")" >&2
     skipped=$((skipped + 1))
    fi
    ;;
   recover:failed|purge-failed:abandoned|recover:live|purge-failed:live)
    printf 'project-data-run: retained %s run: %s\n' "$classification" "$(relative_display "$run_dir")"
    ;;
  esac
 done

 printf 'project-data-run: %s summary found=%d removed=%d skipped=%d\n' "$action" "$found" "$removed" "$skipped"
}

case "${1:-}" in
 --list)
  [[ $# -eq 1 ]] || { usage >&2; exit 64; }
  scan_runs list
  exit 0
  ;;
 --recover)
  [[ $# -eq 1 ]] || { usage >&2; exit 64; }
  scan_runs recover
  exit 0
  ;;
 --purge-failed)
  [[ $# -eq 1 ]] || { usage >&2; exit 64; }
  scan_runs purge-failed
  exit 0
  ;;
 -h|--help)
  usage
  exit 0
  ;;
 '')
  usage >&2
  exit 64
  ;;
esac

failed_policy=${LINKEDSPEC_FAILED_RUN_POLICY:-delete}
case "$failed_policy" in
 delete|retain) ;;
 *) fail "LINKEDSPEC_FAILED_RUN_POLICY must be delete or retain, got: $failed_policy" ;;
esac

command_path=$1
shift
command_label=${LINKEDSPEC_RUN_LABEL:-$(basename -- "$command_path")}
command_label=$(printf '%s' "$command_label" | tr -c 'A-Za-z0-9._-' '_')
command_label=${command_label:0:48}
[[ -n "$command_label" ]] || command_label=run
unset LINKEDSPEC_RUN_LABEL

run_dir=$(mktemp -d "$checkout_runs/$command_label.XXXXXX")
run_name=$(basename -- "$run_dir")
run_token=${run_name##*.}
run_tmp="$run_dir/tmp"
marker="$run_dir/.linkedspec-run"
mkdir -p -- "$run_tmp"
chmod 700 "$run_dir" "$run_tmp"

write_marker() {
 local state=$1
 local child_pid=$2
 local exit_status=${3:-}
 local marker_tmp="$run_dir/.linkedspec-run.tmp.$$"

 {
  printf 'version=1\n'
  printf 'checkout_id=%s\n' "$checkout_id"
  printf 'run_name=%s\n' "$run_name"
  printf 'run_token=%s\n' "$run_token"
  printf 'state=%s\n' "$state"
  printf 'failure_policy=%s\n' "$failed_policy"
  printf 'wrapper_pid=%s\n' "$$"
  printf 'child_pid=%s\n' "$child_pid"
  printf 'exit_status=%s\n' "$exit_status"
 } >"$marker_tmp"
 chmod 600 "$marker_tmp"
 mv -f -- "$marker_tmp" "$marker"
}

write_marker starting 0

LINKEDSPEC_RUN_ACTIVE=1
LINKEDSPEC_RUN_DIR=$run_dir
LINKEDSPEC_RUN_TOKEN=$run_token
LINKEDSPEC_CHECKOUT_ID=$checkout_id
TMPDIR=$run_tmp
TMP=$run_tmp
TEMP=$run_tmp
export LINKEDSPEC_RUN_ACTIVE LINKEDSPEC_RUN_DIR LINKEDSPEC_RUN_TOKEN LINKEDSPEC_CHECKOUT_ID TMPDIR TMP TEMP

child_pid=0
received_status=0
forward_signal() {
 local signal=$1
 local status=$2
 received_status=$status
 if [[ "$child_pid" =~ ^[1-9][0-9]*$ ]] && pid_is_live "$child_pid"; then
  kill -"$signal" "$child_pid" 2>/dev/null || true
 fi
}
trap 'forward_signal HUP 129' HUP
trap 'forward_signal INT 130' INT
trap 'forward_signal TERM 143' TERM

set +e
"$command_path" "$@" &
child_pid=$!
write_marker active "$child_pid"
wait "$child_pid"
status=$?
if (( received_status != 0 )); then
 while pid_is_live "$child_pid"; do
  wait "$child_pid"
  status=$?
 done
 status=$received_status
fi
set -e
trap - HUP INT TERM

if (( status == 0 )); then
 write_marker succeeded "$child_pid" 0
 if ! safe_remove_owned_run "$run_dir"; then
  printf 'project-data-run: ERROR: successful scratch cleanup failed: %s\n' "$(relative_display "$run_dir")" >&2
  exit 74
 fi
elif [[ "$failed_policy" == retain ]]; then
 write_marker failed "$child_pid" "$status"
 printf 'project-data-run: retained failed run (explicit policy): %s\n' "$(relative_display "$run_dir")" >&2
else
 write_marker failed "$child_pid" "$status"
 if ! safe_remove_owned_run "$run_dir"; then
  printf 'project-data-run: ERROR: failed-run scratch cleanup failed: %s\n' "$(relative_display "$run_dir")" >&2
  exit 74
 fi
fi

exit "$status"
