#!/usr/bin/env bash

# Source this file before a LinkedSpec workflow creates temporary or cached data.
# It deliberately derives every default from this file's current checkout.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
 printf '%s\n' 'project_data_env.sh must be sourced, not executed' >&2
 exit 64
fi

# Preserve the caller's pre-routing temporary root as runtime-only host authority. Nested
# managed-run sources must not overwrite it after TMPDIR has moved beneath repository scratch.
if [[ "${LINKEDSPEC_HOST_TMPDIR_CAPTURED:-}" != 1 ]]; then
 LINKEDSPEC_HOST_TMPDIR=${TMPDIR-}
 LINKEDSPEC_HOST_TMPDIR_CAPTURED=1
 export LINKEDSPEC_HOST_TMPDIR LINKEDSPEC_HOST_TMPDIR_CAPTURED
fi

_linkedspec_storage_script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || return 1
_linkedspec_storage_repo_root=$(cd -- "$_linkedspec_storage_script_dir/.." && pwd -P) || return 1

_linkedspec_storage_device() {
 local path=$1
 local device

 if device=$(stat -c '%d' -- "$path" 2>/dev/null); then
  printf '%s\n' "$device"
  return 0
 fi
 if device=$(stat -f '%d' "$path" 2>/dev/null); then
  printf '%s\n' "$device"
  return 0
 fi

 printf 'project-data: cannot determine filesystem device for %s\n' "$path" >&2
 return 1
}

_linkedspec_storage_absolute() {
 local path=$1

 case "$path" in
  /*) printf '%s\n' "$path" ;;
  *) printf '%s/%s\n' "$PWD" "$path" ;;
 esac
}

_linkedspec_storage_existing_ancestor() {
 local path=$1
 local parent

 while [[ ! -d "$path" ]]; do
  [[ ! -e "$path" ]] || return 1
  parent=$(dirname -- "$path") || return 1
  [[ "$parent" != "$path" ]] || return 1
  path=$parent
 done

 (cd -P -- "$path" && pwd -P)
}

_linkedspec_storage_prepare_dir() {
 local candidate=$1
 local absolute
 local ancestor
 local resolved
 local ancestor_device
 local resolved_device

 [[ -n "$candidate" ]] || return 1
 absolute=$(_linkedspec_storage_absolute "$candidate") || return 1
 ancestor=$(_linkedspec_storage_existing_ancestor "$absolute") || return 1
 ancestor_device=$(_linkedspec_storage_device "$ancestor") || return 1
 [[ "$ancestor_device" == "$_linkedspec_storage_repo_device" ]] || return 1

 mkdir -p -- "$absolute" || return 1
 resolved=$(cd -P -- "$absolute" && pwd -P) || return 1
 resolved_device=$(_linkedspec_storage_device "$resolved") || return 1
 [[ "$resolved_device" == "$_linkedspec_storage_repo_device" ]] || return 1
 printf '%s\n' "$resolved"
}

_linkedspec_storage_select_dir() {
 local variable=$1
 local default_path=$2
 local candidate=${!variable-}
 local selected

 if [[ -n "$candidate" ]] && selected=$(_linkedspec_storage_prepare_dir "$candidate"); then
  :
 else
  selected=$(_linkedspec_storage_prepare_dir "$default_path") || return 1
 fi

 printf -v "$variable" '%s' "$selected"
 export "$variable"
}

_linkedspec_storage_select_julia_depots() {
 local separator=':'
 local requested=${LINKEDSPEC_JULIA_DEPOT_PATH:-${JULIA_DEPOT_PATH:-}}
 local default_depot=$1
 local entry
 local resolved
 local normalized=''
 local valid=1
 local trailing_system_depot=0
 local -a entries=()

 case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) separator=';' ;;
 esac

 if [[ -n "$requested" ]]; then
  [[ "$requested" == *"$separator" ]] && trailing_system_depot=1
  IFS="$separator" read -r -a entries <<< "$requested"
  [[ -n "${entries[0]:-}" ]] || valid=0
  if (( valid )); then
   for entry in "${entries[@]}"; do
    if [[ -z "$entry" ]]; then
     normalized+="$separator"
     continue
    fi
    if ! resolved=$(_linkedspec_storage_prepare_dir "$entry"); then
     valid=0
     break
    fi
    if [[ -n "$normalized" && "${normalized: -1}" != "$separator" ]]; then
     normalized+="$separator"
    fi
    normalized+="$resolved"
   done
   if (( valid && trailing_system_depot )) && [[ "${normalized: -1}" != "$separator" ]]; then
    normalized+="$separator"
   fi
  fi
 fi

 if [[ -z "$requested" ]] || (( ! valid )); then
  resolved=$(_linkedspec_storage_prepare_dir "$default_depot") || return 1
  normalized="$resolved$separator"
 fi

 JULIA_DEPOT_PATH=$normalized
 LINKEDSPEC_JULIA_DEPOT_PATH=$normalized
 export JULIA_DEPOT_PATH LINKEDSPEC_JULIA_DEPOT_PATH
}

_linkedspec_storage_repo_device=$(_linkedspec_storage_device "$_linkedspec_storage_repo_root") || return 1

LINKEDSPEC_REPO_ROOT=$_linkedspec_storage_repo_root
export LINKEDSPEC_REPO_ROOT

_linkedspec_storage_select_dir LINKEDSPEC_PROJECT_DATA_ROOT \
 "$_linkedspec_storage_repo_root/.linkedspec-data" || return 1
_linkedspec_storage_select_dir LINKEDSPEC_SCRATCH_ROOT \
 "$LINKEDSPEC_PROJECT_DATA_ROOT/scratch" || return 1
_linkedspec_storage_select_dir LINKEDSPEC_CACHE_ROOT \
 "$LINKEDSPEC_PROJECT_DATA_ROOT/cache" || return 1

LINKEDSPEC_RUNS_ROOT=$(_linkedspec_storage_prepare_dir "$LINKEDSPEC_SCRATCH_ROOT/runs") || return 1
export LINKEDSPEC_RUNS_ROOT

_linkedspec_storage_select_dir TMPDIR "$LINKEDSPEC_SCRATCH_ROOT/tmp" || return 1
_linkedspec_storage_select_dir TMP "$TMPDIR" || return 1
_linkedspec_storage_select_dir TEMP "$TMPDIR" || return 1
_linkedspec_storage_select_dir CARGO_HOME "$LINKEDSPEC_CACHE_ROOT/cargo-home" || return 1
_linkedspec_storage_select_dir CARGO_TARGET_DIR "$_linkedspec_storage_repo_root/rust/target" || return 1
_linkedspec_storage_select_dir PUB_CACHE "$LINKEDSPEC_CACHE_ROOT/dart-pub" || return 1
_linkedspec_storage_select_dir LINKEDSPEC_DART_HOME \
 "$LINKEDSPEC_CACHE_ROOT/dart-home" || return 1
_linkedspec_storage_select_julia_depots "$LINKEDSPEC_CACHE_ROOT/julia-depot" || return 1
_linkedspec_storage_select_dir PYTHONPYCACHEPREFIX \
 "$LINKEDSPEC_CACHE_ROOT/python-pycache" || return 1

linkedspec_project_data_validate_output_path() {
 local candidate=${1:-}
 local label=${2:-project output}
 local absolute
 local probe
 local resolved
 local device
 local repo_device

 [[ -n "$candidate" ]] || {
  printf 'project-data: %s path is empty\n' "$label" >&2
  return 64
 }

 case "$candidate" in
 /*) absolute=$candidate ;;
  *) absolute="$PWD/$candidate" ;;
 esac

 probe=$absolute
 while [[ "$probe" != / ]]; do
  [[ ! -L "$probe" ]] || {
   printf 'project-data: %s must not contain a symlink: %s\n' "$label" "$probe" >&2
   return 1
  }
  probe=$(dirname -- "$probe") || return 1
 done

 if [[ -e "$absolute" ]]; then
  if [[ -d "$absolute" ]]; then
   resolved=$(cd -P -- "$absolute" && pwd -P) || return 1
  else
   probe=$(cd -P -- "$(dirname -- "$absolute")" && pwd -P) || return 1
   resolved="$probe/$(basename -- "$absolute")"
  fi
 else
  probe=$(dirname -- "$absolute") || return 1
  while [[ ! -d "$probe" ]]; do
   [[ ! -e "$probe" && ! -L "$probe" ]] || {
    printf 'project-data: %s has a non-directory ancestor: %s\n' "$label" "$probe" >&2
    return 1
   }
   [[ "$(dirname -- "$probe")" != "$probe" ]] || return 1
   probe=$(dirname -- "$probe") || return 1
  done
  resolved=$(cd -P -- "$probe" && pwd -P) || return 1
 fi

 if ! device=$(stat -c '%d' -- "$resolved" 2>/dev/null); then
  device=$(stat -f '%d' "$resolved" 2>/dev/null) || {
   printf 'project-data: cannot determine filesystem device for %s\n' "$resolved" >&2
   return 1
  }
 fi
 if ! repo_device=$(stat -c '%d' -- "$LINKEDSPEC_REPO_ROOT" 2>/dev/null); then
  repo_device=$(stat -f '%d' "$LINKEDSPEC_REPO_ROOT" 2>/dev/null) || return 1
 fi
 [[ "$device" == "$repo_device" ]] || {
  printf 'project-data: %s is outside the repository filesystem: %s\n' "$label" "$candidate" >&2
  return 1
 }
}

linkedspec_project_data_enter_run() {
 local command=${1:-}
 local active_dir=''
 local marker_token=''
 local marker_checkout_id=''
 local marker_state=''
 local marker_wrapper_pid='0'
 local key
 local value

 [[ -n "$command" ]] || {
  printf '%s\n' 'project-data: a command is required to enter a managed run' >&2
  return 64
 }

 if [[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 && -n "${LINKEDSPEC_RUN_DIR:-}" &&
       -n "${LINKEDSPEC_RUN_TOKEN:-}" && -d "$LINKEDSPEC_RUN_DIR" &&
       ! -L "$LINKEDSPEC_RUN_DIR" ]]; then
  active_dir=$(cd -P -- "$LINKEDSPEC_RUN_DIR" && pwd -P) || active_dir=''
  case "$active_dir/" in
   "$LINKEDSPEC_RUNS_ROOT/"*)
    if [[ -f "$active_dir/.linkedspec-run" && ! -L "$active_dir/.linkedspec-run" ]]; then
     while IFS='=' read -r key value; do
      case "$key" in
       checkout_id) marker_checkout_id=$value ;;
       run_token) marker_token=$value ;;
       state) marker_state=$value ;;
       wrapper_pid) marker_wrapper_pid=$value ;;
      esac
     done <"$active_dir/.linkedspec-run"
     if [[ -n "${LINKEDSPEC_CHECKOUT_ID:-}" && "$marker_checkout_id" == "$LINKEDSPEC_CHECKOUT_ID" &&
           "$marker_token" == "$LINKEDSPEC_RUN_TOKEN" && "$marker_state" =~ ^(starting|active)$ &&
           "$marker_wrapper_pid" =~ ^[1-9][0-9]*$ ]] && kill -0 "$marker_wrapper_pid" 2>/dev/null; then
      return 0
     fi
    fi
    ;;
  esac
 fi

 unset LINKEDSPEC_RUN_ACTIVE LINKEDSPEC_RUN_DIR LINKEDSPEC_RUN_TOKEN LINKEDSPEC_CHECKOUT_ID
 LINKEDSPEC_RUN_LABEL=$(basename -- "$command")
 export LINKEDSPEC_RUN_LABEL
 exec "$LINKEDSPEC_REPO_ROOT/tools/project_data_run.sh" "${BASH:-bash}" "$@"
}

unset _linkedspec_storage_script_dir _linkedspec_storage_repo_root _linkedspec_storage_repo_device
unset -f _linkedspec_storage_device _linkedspec_storage_absolute
unset -f _linkedspec_storage_existing_ancestor _linkedspec_storage_prepare_dir
unset -f _linkedspec_storage_select_dir _linkedspec_storage_select_julia_depots
