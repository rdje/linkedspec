#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_rust_project_data_storage.sh" "$@"

fail() {
 printf '[rust-project-data-test] ERROR: %s\n' "$*" >&2
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

 [[ -d "$path" ]] || fail "$label directory is missing: $path"
 [[ "$(device_id "$path")" == "$repo_device" ]] ||
  fail "$label crossed the repository filesystem: $path"
}

reuse_complete_gate=0
if [[ "${1:-}" == '--reuse-complete-rust-gate' ]]; then
 reuse_complete_gate=1
 shift
fi
(( $# == 0 )) || fail "unexpected argument: $1"

CARGO_CMD="${LINKEDSPEC_CARGO_CMD:-cargo}"
command -v "$CARGO_CMD" >/dev/null 2>&1 || fail "required command not found: $CARGO_CMD"

[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'focused proof is not inside a managed run'
[[ -n "${LINKEDSPEC_RUN_DIR:-}" && -d "$LINKEDSPEC_RUN_DIR" ]] ||
 fail 'managed run directory is missing'
[[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]] || fail 'managed temporary directory is missing'

repo_device=$(device_id "$REPO_ROOT")
require_repo_device 'managed run' "$LINKEDSPEC_RUN_DIR"
require_repo_device 'Rust temporary root' "$TMPDIR"
require_repo_device 'Cargo home' "$CARGO_HOME"
require_repo_device 'Cargo target' "$CARGO_TARGET_DIR"
case "$(cd -P -- "$TMPDIR" && pwd -P)/" in
 "$LINKEDSPEC_RUN_DIR/tmp/") ;;
 *) fail 'Rust temporary root is not the active managed-run tmp directory' ;;
esac

expected_temp_owners=(
 rust/linkedspec-core/src/trace.rs
 rust/linkedspec-runtime/src/primary_cli.rs
 rust/linkedspec-runtime/tests/diagnostic_output_contract.rs
 rust/linkedspec-runtime/tests/duplicate_regex_slot_identity_contract.rs
 rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs
 rust/linkedspec-runtime/tests/logical_helper_contract.rs
 rust/linkedspec-runtime/tests/repeated_action_result_contract.rs
 rust/linkedspec-runtime/tests/root_rule_selection_admission.rs
 rust/linkedspec-runtime/tests/root_rule_selection_routes.rs
 rust/linkedspec-runtime/tests/rule_local_cursor_contract.rs
 rust/linkedspec-runtime/tests/rule_local_cursor_execution.rs
 rust/linkedspec-runtime/tests/semantic_index_runtime_observation.rs
 rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs
 rust/linkedspec-runtime/tests/source_emitter.rs
 rust/linkedspec-runtime/tests/spec_loader.rs
 rust/linkedspec-runtime/tests/trace_controls.rs
 rust/linkedspec-runtime/tests/unicode_rule_label_routes.rs
)
mapfile -t actual_temp_owners < <(
 while IFS= read -r relative; do
  if rg -q '(^|[^[:alnum:]_])((std::)?env::temp_dir|tempfile::tempdir)[[:space:]]*\(' \
   "$REPO_ROOT/$relative"; then
   printf '%s\n' "$relative"
  fi
 done < <(git -C "$REPO_ROOT" ls-files 'rust/**/*.rs')
)
(( ${#actual_temp_owners[@]} == ${#expected_temp_owners[@]} )) ||
 fail "tracked Rust temporary-owner inventory drifted from ${#expected_temp_owners[@]} to ${#actual_temp_owners[@]}"
for index in "${!expected_temp_owners[@]}"; do
 [[ "${actual_temp_owners[$index]}" == "${expected_temp_owners[$index]}" ]] ||
  fail "Rust temporary-owner inventory drifted at entry $index"
done

cd "$REPO_ROOT"
"$CARGO_CMD" fetch --manifest-path rust/Cargo.toml --locked --offline
registry_lock_count=$(awk '
 /^source = "registry\+/ { count++ }
 END { print count + 0 }
' rust/Cargo.lock)
registry_cache_count=$(find "$CARGO_HOME/registry/cache" -type f 2>/dev/null | wc -l | tr -d ' ')
(( registry_lock_count > 0 )) || fail 'Cargo.lock has no registry packages to verify'
[[ "$registry_cache_count" == "$registry_lock_count" ]] ||
 fail "SSD Cargo cache covers $registry_cache_count/$registry_lock_count locked registry packages"
printf '[rust-project-data-test] offline Cargo cache covers %s locked registry packages\n' \
 "$registry_lock_count"

if (( ! reuse_complete_gate )); then
 "$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-core \
  trace_file_defaults_to_route_and_reset_truncates -- --exact
 "$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
  primary_cli::tests::repository_root_discovery_prefers_executable_then_cwd_then_fallback -- --exact
 "$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls \
  traced_entrypoint_validates_route_sink_setup_without_changing_output -- --exact
 "$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter \
  emitted_source_option_roles_compile_and_select_an_ordinary_rule -- --exact
 "$CARGO_CMD" build --manifest-path rust/Cargo.toml -p linkedspec-runtime \
  --bin linkedspec-rust --offline
fi

primary_command="$CARGO_TARGET_DIR/debug/linkedspec-rust"
[[ -x "$primary_command" ]] || fail "built primary command is not executable: $primary_command"
relocated_root="$LINKEDSPEC_RUN_DIR/relocated-rust"
relocated_bin="$relocated_root/bin/linkedspec-rust"
relocated_cwd="$relocated_root/work"
mkdir -p -- "$(dirname -- "$relocated_bin")" "$relocated_cwd"
cp -- "$primary_command" "$relocated_bin"
chmod +x "$relocated_bin"
require_repo_device 'relocated Rust binary' "$(dirname -- "$relocated_bin")"

relocated_stdout=$(
 cd "$relocated_cwd"
 "$relocated_bin" \
  --inline-spec $'Top::\n /x/\n E { return("ssd-local") }\n' \
  --input x \
  --trace low \
  --trace-file rust-storage.trace \
  --trace-reset
)
[[ "$relocated_stdout" == '"ssd-local"' ]] ||
 fail "relocated Rust primary returned unexpected output: $relocated_stdout"
[[ -s "$relocated_cwd/rust-storage.trace" ]] || fail 'relocated Rust trace was not created'
[[ "$(device_id "$relocated_cwd/rust-storage.trace")" == "$repo_device" ]] ||
 fail 'relocated Rust trace crossed the repository filesystem'

printf '%s\n' \
 '[rust-project-data-test] PASS: 17 Rust owners, Cargo cache, generated workspaces, traces, and relocation stay on repository storage'
