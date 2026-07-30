#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_project_data_process_locality.sh" "$@"

fail() {
 printf '[project-data-process-test] ERROR: %s\n' "$*" >&2
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

real_dir() {
 (cd -P -- "$1" && pwd -P)
}

resolve_host_user_tmp() {
 local candidate=${LINKEDSPEC_HOST_TMPDIR:-}
 local resolved

 [[ "${LINKEDSPEC_HOST_TMPDIR_CAPTURED:-}" == 1 ]] ||
  fail 'pre-routing host temporary authority was not captured'
 [[ -n "$candidate" && -d "$candidate" && ! -L "$candidate" ]] ||
  fail 'pre-routing host temporary root is missing or symbolic'
 resolved=$(real_dir "$candidate")
 [[ "$(device_id "$resolved")" != "$(device_id "$REPO_ROOT")" ]] ||
  fail 'pre-routing host temporary root unexpectedly shares the repository filesystem'
 printf '%s\n' "$resolved"
}

require_repo_path() {
 local label=$1
 local path=$2
 local resolved

 [[ -e "$path" && ! -L "$path" ]] || fail "$label is missing or symbolic: $path"
 if [[ -d "$path" ]]; then
  resolved=$(real_dir "$path")
 else
  resolved=$(real_dir "$(dirname -- "$path")")/$(basename -- "$path")
 fi
 case "$resolved" in
  "$REPO_ROOT"|"$REPO_ROOT"/*) ;;
  *) fail "$label escaped the active repository: $resolved" ;;
 esac
 [[ "$(device_id "$path")" == "$(device_id "$REPO_ROOT")" ]] ||
  fail "$label crossed the repository filesystem: $resolved"
}

require_external_executable() {
 local command_name=$1
 local executable
 local resolved

 executable=$(command -v "$command_name" 2>/dev/null) ||
  fail "required external command is unavailable: $command_name"
 resolved=$(realpath "$executable") || fail "cannot resolve external command: $executable"
 case "$resolved" in
  "$REPO_ROOT"/*) fail "external command unexpectedly resolves inside the repository: $resolved" ;;
 esac
 case "$resolved" in
  /System/*|/usr/*|/bin/*|/sbin/*|/opt/homebrew/*) ;;
  *) fail "external command is outside the frozen system/tool roots: $resolved" ;;
 esac
 printf '%s\n' "$resolved"
}

assert_probe_set() {
 local expected='caller-input dart julia lua perl rust tool'
 local actual
 shift 0
 actual=$(printf '%s\n' "$@" | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')
 [[ "$actual" == "$expected" ]] || fail "representative probe set drifted: $actual"
}

run_primary_probe() {
 local label=$1
 shift
 local trace_path="$TMPDIR/$label.trace"
 local output
 local expected='"inline"'
 local spec=$'Top::\n /x/ -> Done { return("inline") }\n\nDone::\n /x/\n'

 output=$("$@" --inline-spec "$spec" --input x --trace low --trace-file "$trace_path" --trace-reset)
 [[ "$output" == "$expected" ]] || fail "$label primary probe returned unexpected output: $output"
 require_repo_path "$label trace" "$trace_path"
 [[ -s "$trace_path" ]] || fail "$label trace is empty"
}

run_relocated_driver() {
 local caller_input=$1
 local outside_cwd=$2
 local -a passed=()
 local dart_config="$REPO_ROOT/dart/.dart_tool/package_config.json"
 local lua_native="$TMPDIR/lua-native"
 local writable_julia_depot=${JULIA_DEPOT_PATH%%:*}

 [[ "$PWD" == "$outside_cwd" ]] || fail 'driver did not start from the requested outside cwd'
 [[ "$(device_id "$PWD")" != "$(device_id "$REPO_ROOT")" ]] ||
  fail 'driver cwd unexpectedly shares the repository filesystem'

 for path in "$LINKEDSPEC_PROJECT_DATA_ROOT" "$LINKEDSPEC_SCRATCH_ROOT" "$LINKEDSPEC_CACHE_ROOT" \
  "$LINKEDSPEC_RUN_DIR" "$TMPDIR" "$CARGO_HOME" "$CARGO_TARGET_DIR" "$PUB_CACHE" \
  "$LINKEDSPEC_DART_HOME" \
  "$writable_julia_depot" "$PYTHONPYCACHEPREFIX"; do
  require_repo_path 'initialized project-data path' "$path"
 done

 # The caller input is the sole exact exception beneath the otherwise denied developer home.
 dd if="$caller_input" of=/dev/null bs=1 count=1 2>/dev/null ||
  fail 'explicit caller input was not readable through its exact sandbox exception'
 passed+=(caller-input)

 run_primary_probe perl env PERL5LIB= perl -I"$REPO_ROOT/perl" "$REPO_ROOT/bin/linkedspec"
 passed+=(perl)

 require_repo_path 'relocated Rust primary' "$REPO_ROOT/rust/target/debug/linkedspec-rust"
 run_primary_probe rust "$REPO_ROOT/rust/target/debug/linkedspec-rust"
 passed+=(rust)

 (
  cd "$REPO_ROOT/dart"
  bash "$REPO_ROOT/tools/run_dart_project_data.sh" pub get --offline >/dev/null
 )
 require_repo_path 'relocated Dart package configuration' "$dart_config"
 run_primary_probe dart bash "$REPO_ROOT/tools/run_dart_project_data.sh" \
  --packages="$dart_config" "$REPO_ROOT/dart/bin/linkedspec_dart.dart"
 passed+=(dart)

 JULIA_PKG_OFFLINE=true run_primary_probe julia julia --project="$REPO_ROOT/julia" \
  --startup-file=no --history-file=no "$REPO_ROOT/julia/bin/linkedspec_julia.jl"
 passed+=(julia)

 bash "$REPO_ROOT/tools/build_lua_native.sh" puc "$lua_native"
 require_repo_path 'relocated Lua native directory' "$lua_native"
 LUA_CPATH="$lua_native/?.so;;" run_primary_probe lua lua "$REPO_ROOT/lua/bin/linkedspec-lua"
 passed+=(lua)

 PYTHONNOUSERSITE=1 bash "$REPO_ROOT/tools/run_python_project_data.sh" \
  tools/check_callable_codeblock_contract.py >/dev/null
 find "$PYTHONPYCACHEPREFIX" -type f -name '*.pyc' -print -quit | rg -q . ||
  fail 'tool probe did not create bytecode in the relocated cache'
 passed+=(tool)

 assert_probe_set "${passed[@]}"
 printf '%s\n' '[project-data-process-test] relocated six-family driver passed'
}

if [[ "${1:-}" == '--relocated-driver' ]]; then
 (( $# == 3 )) || fail 'relocated driver requires caller-input and outside-cwd paths'
 shift
 run_relocated_driver "$@"
 exit 0
fi

(( $# == 0 )) || fail "unexpected argument: $1"
[[ "$(uname -s)" == Darwin ]] || fail 'process-locality containment currently requires macOS sandbox-exec'
[[ -x /usr/bin/sandbox-exec ]] || fail 'macOS sandbox-exec is unavailable'
[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'process proof is not inside a managed run'
require_repo_path 'managed run' "$LINKEDSPEC_RUN_DIR"

for command_name in bash perl dart julia lua python3; do
 require_external_executable "$command_name" >/dev/null
done

slash=/
system_tmp=$(real_dir "${slash}tmp")
home_root=$(real_dir "${HOME:?HOME is required to classify developer-owned data}")
repo_device=$(device_id "$REPO_ROOT")
[[ "$(device_id "$system_tmp")" != "$repo_device" ]] ||
 fail 'system temporary root is not an available other-filesystem cwd'

if (LINKEDSPEC_HOST_TMPDIR_CAPTURED=1 LINKEDSPEC_HOST_TMPDIR= resolve_host_user_tmp) >/dev/null 2>&1; then
 fail 'host temporary resolver accepted missing pre-routing authority'
fi
if (LINKEDSPEC_HOST_TMPDIR_CAPTURED=1 LINKEDSPEC_HOST_TMPDIR="$REPO_ROOT" \
 resolve_host_user_tmp) >/dev/null 2>&1; then
 fail 'host temporary resolver accepted repository-filesystem authority'
fi
user_tmp=$(resolve_host_user_tmp)

caller_input=''
for candidate in "$home_root/.gitconfig" "$home_root/.zshrc" "$home_root/.bash_profile"; do
 if [[ -f "$candidate" && ! -L "$candidate" ]]; then
  caller_input=$candidate
  break
 fi
done
[[ -n "$caller_input" ]] || fail 'no bounded existing caller-owned input is available'

relocated_root="$TMPDIR/relocated checkout"
mkdir -p -- "$relocated_root"
git -C "$REPO_ROOT" archive HEAD | tar -xf - -C "$relocated_root"
for relative in lua/native/mcp_system.c tools/build_lua_native.sh tools/project_data_env.sh \
 tools/run_dart_project_data.sh tools/test_project_data_process_locality.sh; do
 cp -- "$REPO_ROOT/$relative" "$relocated_root/$relative"
done
chmod +x "$relocated_root/tools/test_project_data_process_locality.sh"
chmod +x "$relocated_root/tools/run_dart_project_data.sh"

clone_tree() {
 local source=$1
 local destination=$2
 mkdir -p -- "$(dirname -- "$destination")"
 if ! cp -cR -- "$source" "$destination" 2>/dev/null; then
  [[ ! -e "$destination" ]] || fail "clone copy partially created destination: $destination"
  cp -R -- "$source" "$destination"
 fi
}

mkdir -p -- "$relocated_root/rust/target/debug"
cp -c -- "$REPO_ROOT/rust/target/debug/linkedspec-rust" \
 "$relocated_root/rust/target/debug/linkedspec-rust" 2>/dev/null ||
 cp -- "$REPO_ROOT/rust/target/debug/linkedspec-rust" \
  "$relocated_root/rust/target/debug/linkedspec-rust"
clone_tree "$REPO_ROOT/.linkedspec-data/cache/dart-pub" \
 "$relocated_root/.linkedspec-data/cache/dart-pub"
clone_tree "$REPO_ROOT/.linkedspec-data/cache/julia-depot" \
 "$relocated_root/.linkedspec-data/cache/julia-depot"
require_repo_path 'relocated checkout' "$relocated_root"

profile_path="$relocated_root/project-data-process.sb"
cat >"$profile_path" <<'PROFILE'
(version 1)
(allow default)

; Only the dynamic relocated checkout and the null device accept writes.
(deny file-write*
 (require-not (subpath (param "REPO_ROOT"))))
(allow file-write* (literal "/dev/null"))

; Developer-home and both inherited OS-temporary roots are forbidden data inputs.
(deny file-read-data
 (subpath (param "HOME_ROOT"))
 (subpath (param "SYSTEM_TMP"))
 (subpath (param "USER_TMP")))

; One explicit, read-only caller input is narrower than the home denial.
(allow file-read-data (literal (param "CALLER_INPUT")))
PROFILE

run_sandbox() {
 /usr/bin/sandbox-exec \
  -D "REPO_ROOT=$relocated_root" \
  -D "HOME_ROOT=$home_root" \
  -D "SYSTEM_TMP=$system_tmp" \
  -D "USER_TMP=$user_tmp" \
  -D "CALLER_INPUT=$caller_input" \
  -f "$profile_path" "$@"
}

# Deterministic REDs: the profile must block old-volume output, implicit home/cache reads, and symlink escapes.
hostile_write="$system_tmp/linkedspec-process-write-$$"
[[ ! -e "$hostile_write" && ! -L "$hostile_write" ]] || fail 'hostile write path already exists'
set +e
run_sandbox /bin/sh -c 'printf forbidden >"$1"' sh "$hostile_write" >/dev/null 2>&1
hostile_status=$?
set -e
[[ "$hostile_status" -ne 0 && ! -e "$hostile_write" && ! -L "$hostile_write" ]] ||
 fail 'sandbox profile accepted or created an old-volume project write'

set +e
run_sandbox /bin/sh -c 'dd if="$1" of=/dev/null bs=1 count=1 2>/dev/null' sh \
 "$home_root/.cargo/.package-cache" >/dev/null 2>&1
cache_status=$?
set -e
[[ "$cache_status" -ne 0 ]] || fail 'sandbox profile accepted an implicit shared Cargo-cache read'

escape_link="$relocated_root/escape-link"
ln -s -- "$system_tmp" "$escape_link"
set +e
run_sandbox /bin/sh -c 'printf forbidden >"$1/escaped"' sh "$escape_link" >/dev/null 2>&1
escape_status=$?
set -e
[[ "$escape_status" -ne 0 && ! -e "$system_tmp/escaped" ]] ||
 fail 'sandbox profile accepted a symlinked old-volume write'
rm -- "$escape_link"

if (assert_probe_set caller-input dart julia lua perl rust) >/dev/null 2>&1; then
 fail 'probe-set guard accepted a missing tool-family leg'
fi

hostile_path="$system_tmp/linkedspec-hostile-$$"
path_value="/opt/homebrew/bin:/usr/bin:/bin"
driver_stdout="$TMPDIR/relocated-driver.out"
driver_stderr="$TMPDIR/relocated-driver.err"
set +e
(
 cd "$system_tmp"
 run_sandbox env -i \
  PATH="$path_value" HOME="$home_root" LANG=C LC_ALL=C \
  TMPDIR="$hostile_path/tmp" TMP="$hostile_path/tmp" TEMP="$hostile_path/tmp" \
  CARGO_HOME="$home_root/.cargo" CARGO_TARGET_DIR="$hostile_path/rust-target" \
  PUB_CACHE="$home_root/.pub-cache" JULIA_DEPOT_PATH="$home_root/.julia:" \
  LINKEDSPEC_DART_HOME="$home_root/.dart-tool" \
  LINKEDSPEC_JULIA_DEPOT_PATH="$home_root/.julia:" \
  PYTHONPYCACHEPREFIX="$user_tmp/linkedspec-hostile-pycache" \
  "$relocated_root/tools/test_project_data_process_locality.sh" \
  --relocated-driver "$caller_input" "$system_tmp"
) >"$driver_stdout" 2>"$driver_stderr"
driver_status=$?
set -e
cat "$driver_stdout"
if [[ "$driver_status" -ne 0 ]]; then
 sed -n '1,200p' "$driver_stderr" >&2
 fail "representative relocated driver failed with status $driver_status"
fi
if rg -n 'Operation not permitted|Permission denied|xcrun_db-' "$driver_stderr"; then
 fail 'representative driver attempted an access denied by the containment policy'
fi
[[ ! -e "$hostile_path" && ! -L "$hostile_path" ]] ||
 fail 'hostile inherited roots received project data'

printf '%s\n' \
 '[project-data-process-test] PASS: relocated Perl/Rust/Dart/Julia/Lua/tool IO is repository-contained'
