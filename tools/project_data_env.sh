#!/usr/bin/env bash

# Source this file before a LinkedSpec workflow creates temporary or cached data.
# It deliberately derives every default from this file's current checkout.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
 printf '%s\n' 'project_data_env.sh must be sourced, not executed' >&2
 exit 64
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

_linkedspec_storage_select_dir TMPDIR "$LINKEDSPEC_SCRATCH_ROOT/tmp" || return 1
_linkedspec_storage_select_dir TMP "$TMPDIR" || return 1
_linkedspec_storage_select_dir TEMP "$TMPDIR" || return 1
_linkedspec_storage_select_dir CARGO_HOME "$LINKEDSPEC_CACHE_ROOT/cargo-home" || return 1
_linkedspec_storage_select_dir CARGO_TARGET_DIR "$_linkedspec_storage_repo_root/rust/target" || return 1
_linkedspec_storage_select_dir PUB_CACHE "$LINKEDSPEC_CACHE_ROOT/dart-pub" || return 1
_linkedspec_storage_select_julia_depots "$LINKEDSPEC_CACHE_ROOT/julia-depot" || return 1

unset _linkedspec_storage_script_dir _linkedspec_storage_repo_root _linkedspec_storage_repo_device
unset -f _linkedspec_storage_device _linkedspec_storage_absolute
unset -f _linkedspec_storage_existing_ancestor _linkedspec_storage_prepare_dir
unset -f _linkedspec_storage_select_dir _linkedspec_storage_select_julia_depots
