#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_lua_project_data_storage.sh" "$@"

fail() {
 printf '[lua-project-data-test] ERROR: %s\n' "$*" >&2
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

require_repo_device() {
 local label=$1
 local path=$2

 [[ -e "$path" ]] || fail "$label is missing: $path"
 [[ "$(device_id "$path")" == "$repo_device" ]] ||
  fail "$label crossed the repository filesystem: $path"
}

reuse_complete_gate=0
if [[ "${1:-}" == '--reuse-complete-lua-gate' ]]; then
 reuse_complete_gate=1
 shift
fi
(( $# == 0 )) || fail "unexpected argument: $1"

LUA_CMD=${LINKEDSPEC_LUA_CMD:-lua}
LUAJIT_CMD=${LINKEDSPEC_LUAJIT_CMD:-luajit}
command -v "$LUA_CMD" >/dev/null 2>&1 || fail "required PUC Lua runtime not found: $LUA_CMD"
command -v rg >/dev/null 2>&1 || fail 'required command not found: rg'

[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'focused proof is not inside a managed run'
[[ -n "${LINKEDSPEC_RUN_DIR:-}" && -d "$LINKEDSPEC_RUN_DIR" ]] ||
 fail 'managed run directory is missing'
[[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]] || fail 'managed temporary directory is missing'

repo_device=$(device_id "$REPO_ROOT")
require_repo_device 'managed run' "$LINKEDSPEC_RUN_DIR"
require_repo_device 'Lua temporary root' "$TMPDIR"
case "$(cd -P -- "$TMPDIR" && pwd -P)/" in
 "$LINKEDSPEC_RUN_DIR/tmp/") ;;
 *) fail 'Lua temporary root is not the active managed-run tmp directory' ;;
esac

expected_temp_owners=(
 lua/test/duplicate_regex_slot_identity_contract_test.lua
 lua/test/repeated_action_result_contract_test.lua
 lua/test/root_rule_selection_admission_test.lua
 lua/test/root_rule_selection_routes_test.lua
 lua/test/rule_local_cursor_contract_test.lua
 lua/test/rule_local_cursor_descriptor_test.lua
 lua/test/rule_local_cursor_execution_test.lua
 lua/test/rule_local_cursor_generated_source_test.lua
 lua/test/rule_local_cursor_option_removal_test.lua
 lua/test/run.lua
 lua/test/semantic_index_runtime_observation_generated_routes_test.lua
 lua/test/semantic_index_runtime_observation_native_test.lua
 lua/test/semantic_introspection_lua_admission_test.lua
 lua/test/unicode_rule_label_identity_routes_test.lua
 lua/test/unicode_rule_label_negative_isolation_test.lua
 tools/run_lua_local.sh
)
mapfile -t actual_temp_owners < <(
 {
  rg -l 'mktemp[[:space:]]+-d|io[.]tmpfile' "$REPO_ROOT/lua" --glob '*.lua'
  rg -l 'mktemp[[:space:]]+-d|io[.]tmpfile' "$REPO_ROOT/tools/run_lua_local.sh"
 } | sed "s|^$REPO_ROOT/||" | sort
)
(( ${#actual_temp_owners[@]} == ${#expected_temp_owners[@]} )) ||
 fail "Lua temporary-owner inventory drifted from ${#expected_temp_owners[@]} to ${#actual_temp_owners[@]}"
for index in "${!expected_temp_owners[@]}"; do
 [[ "${actual_temp_owners[$index]}" == "${expected_temp_owners[$index]}" ]] ||
  fail "Lua temporary-owner inventory drifted at entry $index"
done

owner_paths=()
for relative in "${expected_temp_owners[@]}"; do owner_paths+=("$REPO_ROOT/$relative"); done
if rg -n '/private/tmp|io[.]tmpfile' "${owner_paths[@]}"; then
 fail 'a Lua temporary owner retains an unmanaged operating-system-temp path'
fi
for relative in "${expected_temp_owners[@]}"; do
 if [[ "$relative" == *.lua ]]; then
  rg -q 'os[.]getenv[(]"TMPDIR"[)]' "$REPO_ROOT/$relative" ||
   fail "Lua temporary owner does not read routed TMPDIR: $relative"
 fi
done

owned_native_root=''
if (( reuse_complete_gate )); then
 puc_native=${LINKEDSPEC_LUA_NATIVE_PUC_DIR:-}
 [[ -n "$puc_native" ]] || fail 'complete Lua gate did not publish its PUC native directory'
 if command -v "$LUAJIT_CMD" >/dev/null 2>&1; then
  luajit_native=${LINKEDSPEC_LUA_NATIVE_LUAJIT_DIR:-}
  [[ -n "$luajit_native" ]] || fail 'complete Lua gate did not publish its LuaJIT native directory'
 else
  luajit_native=''
 fi
else
 owned_native_root="$TMPDIR/linkedspec-lua-storage native"
 puc_native="$owned_native_root/puc"
 luajit_native="$owned_native_root/luajit"
 mkdir -p -- "$owned_native_root"
 bash "$REPO_ROOT/tools/build_lua_native.sh" puc "$puc_native"
 if command -v "$LUAJIT_CMD" >/dev/null 2>&1; then
  bash "$REPO_ROOT/tools/build_lua_native.sh" luajit "$luajit_native"
 else
  luajit_native=''
 fi
fi

check_native_dir() {
 local label=$1
 local path=$2

 require_repo_device "$label native directory" "$path"
 for module in linkedspec_regex_pcre2.so linkedspec_filesystem_native.so; do
  [[ -f "$path/$module" && ! -L "$path/$module" ]] || fail "$label native module is missing: $module"
  require_repo_device "$label native module" "$path/$module"
 done
 [[ "$(find "$path" -maxdepth 1 -type f -name '*.so' | wc -l | tr -d ' ')" == 2 ]] ||
  fail "$label native module inventory drifted"
}

check_native_dir 'PUC Lua' "$puc_native"
if [[ -n "$luajit_native" ]]; then check_native_dir 'LuaJIT' "$luajit_native"; fi

probe_root="$TMPDIR/linkedspec-lua-storage-probe"
mkdir -p -- "$probe_root/puc"
run_probe() {
 local label=$1
 local runtime_command=$2
 local native_dir=$3
 local output_root="$probe_root/$label"

 mkdir -p -- "$output_root"
 LUA_PATH="$REPO_ROOT/lua/src/?.lua;$REPO_ROOT/lua/src/?/init.lua;;" \
 LUA_CPATH="$native_dir/?.so;;" \
 LINKEDSPEC_LUA_TEST_RUNTIME="$runtime_command" \
 LINKEDSPEC_LUA_STORAGE_PROBE_ROOT="$output_root" \
  "$runtime_command" "$REPO_ROOT/lua/test/project_data_storage_test.lua"
 require_repo_device "$label generated source" "$output_root/generated_parser.lua"
 require_repo_device "$label trace output" "$output_root/storage.trace"
}

run_probe puc "$LUA_CMD" "$puc_native"
if [[ -n "$luajit_native" ]]; then run_probe luajit "$LUAJIT_CMD" "$luajit_native"; fi

external_root=''
for candidate in /private/tmp /tmp "${HOME:-}"; do
 [[ -n "$candidate" && -d "$candidate" ]] || continue
 if [[ "$(device_id "$candidate")" != "$repo_device" ]]; then
  external_root=$candidate
  break
 fi
done
[[ -n "$external_root" ]] || fail 'no readable other-filesystem directory is available for build rejection proof'
hostile_output="$external_root/linkedspec-lua-build-reject-$$"
[[ ! -e "$hostile_output" ]] || fail "hostile output probe already exists: $hostile_output"
set +e
bash "$REPO_ROOT/tools/build_lua_native.sh" puc "$hostile_output" >"$probe_root/reject.out" 2>&1
reject_status=$?
set -e
[[ "$reject_status" -ne 0 ]] || fail 'native builder accepted a cross-volume output directory'
[[ ! -e "$hostile_output" ]] || fail 'native builder created its rejected cross-volume output directory'
rg -q 'native output must use the repository filesystem' "$probe_root/reject.out" ||
 fail 'native builder rejection did not identify the filesystem boundary'

if find "$external_root" -maxdepth 1 -type d -name 'linkedspec-lua-*' -print -quit | rg -q .; then
 fail 'an exact Lua-owned directory remains in the old temporary root'
fi

rm -rf -- "$probe_root"
if [[ -n "$owned_native_root" ]]; then rm -rf -- "$owned_native_root"; fi
[[ ! -e "$probe_root" ]] || fail 'Lua storage probe remained after cleanup'
[[ -z "$owned_native_root" || ! -e "$owned_native_root" ]] || fail 'Lua native build remained after cleanup'

printf '[lua-project-data-test] PASS: 16 owners, dual-ABI native modules, generated output, and traces stay on repository storage\n'
