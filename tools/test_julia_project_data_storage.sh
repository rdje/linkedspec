#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_julia_project_data_storage.sh" "$@"

fail() {
 printf '[julia-project-data-test] ERROR: %s\n' "$*" >&2
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

file_size() {
 local path=$1
 local size

 if size=$(stat -c '%s' -- "$path" 2>/dev/null); then
  printf '%s\n' "$size"
 elif size=$(stat -f '%z' "$path" 2>/dev/null); then
  printf '%s\n' "$size"
 else
  fail "cannot determine file size for $path"
 fi
}

require_repo_device() {
 local label=$1
 local path=$2

 [[ -d "$path" ]] || fail "$label directory is missing: $path"
 [[ "$(device_id "$path")" == "$repo_device" ]] ||
  fail "$label crossed the repository filesystem: $path"
}

reuse_complete_gate=0
if [[ "${1:-}" == '--reuse-complete-julia-gate' ]]; then
 reuse_complete_gate=1
 shift
fi
(( $# == 0 )) || fail "unexpected argument: $1"

JULIA_CMD="${LINKEDSPEC_JULIA_CMD:-julia}"
command -v "$JULIA_CMD" >/dev/null 2>&1 || fail "required command not found: $JULIA_CMD"
command -v shasum >/dev/null 2>&1 || fail 'required command not found: shasum'

[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'focused proof is not inside a managed run'
[[ -n "${LINKEDSPEC_RUN_DIR:-}" && -d "$LINKEDSPEC_RUN_DIR" ]] ||
 fail 'managed run directory is missing'
[[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]] || fail 'managed temporary directory is missing'
[[ "$JULIA_DEPOT_PATH" == "$LINKEDSPEC_JULIA_DEPOT_PATH" ]] ||
 fail 'Julia depot aliases disagree'

case "$(uname -s)" in
 MINGW*|MSYS*|CYGWIN*)
  writable_depot=${JULIA_DEPOT_PATH%%;*}
  [[ "$JULIA_DEPOT_PATH" == *';' ]] || fail 'Julia depot stack omits runtime system depots'
  [[ "${JULIA_DEPOT_PATH%;}" != *';'* ]] || fail 'Julia depot stack contains an explicit external entry'
  ;;
 *)
  writable_depot=${JULIA_DEPOT_PATH%%:*}
  [[ "$JULIA_DEPOT_PATH" == *':' ]] || fail 'Julia depot stack omits runtime system depots'
  [[ "${JULIA_DEPOT_PATH%:}" != *':'* ]] || fail 'Julia depot stack contains an explicit external entry'
  ;;
esac

repo_device=$(device_id "$REPO_ROOT")
require_repo_device 'managed run' "$LINKEDSPEC_RUN_DIR"
require_repo_device 'Julia temporary root' "$TMPDIR"
require_repo_device 'Julia writable depot' "$writable_depot"
case "$(cd -P -- "$TMPDIR" && pwd -P)/" in
 "$LINKEDSPEC_RUN_DIR/tmp/") ;;
 *) fail 'Julia temporary root is not the active managed-run tmp directory' ;;
esac

expected_temp_owners=(
 julia/test/callable_codeblock_literal_contract_test.jl
 julia/test/duplicate_regex_slot_identity_contract_test.jl
 julia/test/inter_match_gap_capture_contract_test.jl
 julia/test/logical_helper_contract_test.jl
 julia/test/repeated_action_result_contract_test.jl
 julia/test/root_rule_selection_admission_test.jl
 julia/test/root_rule_selection_routes_test.jl
 julia/test/rule_local_cursor_contract_test.jl
 julia/test/rule_local_cursor_descriptor_test.jl
 julia/test/rule_local_cursor_execution_test.jl
 julia/test/rule_local_cursor_option_removal_test.jl
 julia/test/runtests.jl
 julia/test/semantic_index_runtime_observation_routes_test.jl
 julia/test/semantic_index_runtime_observation_test.jl
 julia/test/semantic_introspection_julia_admission_test.jl
 julia/test/source_boundary_compatibility_aliases_test.jl
 julia/test/source_emitter_test.jl
 julia/test/spec_loader_test.jl
 julia/test/unicode_rule_label_identity_routes_test.jl
 julia/test/unicode_rule_label_negative_isolation_test.jl
 julia/test/write_vivification_contract_test.jl
)
mapfile -t actual_temp_owners < <(
 rg -l 'mktempdir\(|tempdir\(' "$REPO_ROOT/julia" --glob '*.jl' |
  sed "s|^$REPO_ROOT/||" | sort
)
(( ${#actual_temp_owners[@]} == ${#expected_temp_owners[@]} )) ||
 fail "tracked Julia temporary-owner inventory drifted from ${#expected_temp_owners[@]} to ${#actual_temp_owners[@]}"
for index in "${!expected_temp_owners[@]}"; do
 [[ "${actual_temp_owners[$index]}" == "${expected_temp_owners[$index]}" ]] ||
  fail "Julia temporary-owner inventory drifted at entry $index"
done

expected_packages=(
 JSON3/rT1w2
 Parsers/05lwR
 PrecompileTools/QUxvR
 Preferences/kUJxq
 StructTypes/PaLwj
)
package_root="$writable_depot/packages"
for package in "${expected_packages[@]}"; do
 [[ -d "$package_root/$package" ]] || fail "Julia depot is missing locked package tree: $package"
done
mapfile -t actual_packages < <(
 find "$package_root" -mindepth 2 -maxdepth 2 -type d -print |
  sed "s|^$package_root/||" | sort
)
(( ${#actual_packages[@]} == ${#expected_packages[@]} )) ||
 fail "Julia package inventory drifted from ${#expected_packages[@]} to ${#actual_packages[@]}"
for index in "${!expected_packages[@]}"; do
 [[ "${actual_packages[$index]}" == "${expected_packages[$index]}" ]] ||
  fail "Julia package inventory drifted at entry $index"
done

package_file_count=0
package_byte_count=0
while IFS= read -r -d '' file; do
 [[ "$(device_id "$file")" == "$repo_device" ]] ||
  fail "Julia package file crossed the repository filesystem: $file"
 (( package_file_count += 1 ))
 (( package_byte_count += $(file_size "$file") ))
done < <(find "$package_root" -type f -print0)
if find "$package_root" -type l -print -quit | grep -q .; then
 fail 'Julia package payload contains a symlink'
fi
[[ "$package_file_count" == 146 ]] || fail "Julia package file count drifted: $package_file_count"
[[ "$package_byte_count" == 710665 ]] || fail "Julia package byte count drifted: $package_byte_count"

package_hash=$(
 cd "$package_root"
 for package in "${expected_packages[@]}"; do
  find "$package" -type f -print0
 done | sort -z | while IFS= read -r -d '' file; do
  digest=$(shasum -a 256 "$file" | awk '{print $1}')
  printf '%s  %s\n' "$digest" "$file"
 done | shasum -a 256 | awk '{print $1}'
)
[[ "$package_hash" == '6840ce825c96acd208d308fc58baac1306dcfd64afe1dc4b365f1eccfe906af1' ]] ||
 fail "Julia package payload hash drifted: $package_hash"
[[ -f "$writable_depot/registries/General.tar.gz" ]] || fail 'Julia General registry archive is missing'
[[ -f "$writable_depot/registries/General.toml" ]] || fail 'Julia General registry metadata is missing'

export JULIA_PKG_OFFLINE=true
cd "$REPO_ROOT"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no -e '
using JSON3
using LinkedSpecJulia

@assert realpath(tempdir()) == realpath(ENV["TMPDIR"])
separator = Sys.iswindows() ? ";" : ":"
depot = split(ENV["JULIA_DEPOT_PATH"], separator; keepempty = true)[1]
json_source = Base.find_package("JSON3")
@assert json_source !== nothing
@assert dirname(dirname(dirname(dirname(dirname(realpath(json_source)))))) == realpath(depot)

mktempdir() do scratch
    @assert startswith(realpath(scratch), string(realpath(ENV["TMPDIR"]), Base.Filesystem.path_separator))
    compiled = compile_spec(parse_spec("Top::\n /x/\n E { return(\"ssd\") }\n"))
    generated = joinpath(scratch, "generated_parser.jl")
    write(generated, emit_julia_source_v2(compiled, "generated/storage.spec"))
    @assert isfile(generated)
    trace_path = joinpath(scratch, "storage.trace")
    config = with_trace_reset_file(with_trace_file(trace_config_enabled(LinkedSpecTraceDebug), trace_path))
    emitter = LinkedSpecTraceEmitter(config; stdout_io = IOBuffer())
    emit_trace_line!(emitter, LinkedSpecTraceLow, "ssd-storage")
    @assert read(trace_path, String) == "ssd-storage\n"
end
'

if (( ! reuse_complete_gate )); then
 bash tools/run_julia_project_data.sh --project=julia -e 'import Pkg; Pkg.instantiate(; verbose = false)'
fi

canonical_depot=$(cd -P -- "$LINKEDSPEC_CACHE_ROOT/julia-depot" && pwd -P)
if [[ "$(cd -P -- "$writable_depot" && pwd -P)" == "$canonical_depot" ]]; then
 [[ ! -e "$writable_depot/logs/manifest_usage.toml" ]] ||
  fail 'canonical Julia depot retained machine-specific manifest usage metadata'
fi

if find "$TMPDIR" -mindepth 1 -type d -name 'jl_*' -print -quit | grep -q .; then
 fail 'a completed focused Julia workspace remained in managed temporary storage'
fi

printf '[julia-project-data-test] PASS: 21 Julia owners, 5 locked package trees, generated output, and traces stay on repository storage\n'
