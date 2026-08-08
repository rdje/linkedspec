#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_dart_project_data_storage.sh" "$@"

fail() {
 printf '[dart-project-data-test] ERROR: %s\n' "$*" >&2
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
if [[ "${1:-}" == '--reuse-complete-dart-gate' ]]; then
 reuse_complete_gate=1
 shift
fi
(( $# == 0 )) || fail "unexpected argument: $1"

DART_CMD="${LINKEDSPEC_DART_CMD:-dart}"
command -v "$DART_CMD" >/dev/null 2>&1 || fail "required command not found: $DART_CMD"
DART_RUN=(bash "$REPO_ROOT/tools/run_dart_project_data.sh")

[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'focused proof is not inside a managed run'
[[ -n "${LINKEDSPEC_RUN_DIR:-}" && -d "$LINKEDSPEC_RUN_DIR" ]] ||
 fail 'managed run directory is missing'
[[ -n "${TMPDIR:-}" && -d "$TMPDIR" ]] || fail 'managed temporary directory is missing'

repo_device=$(device_id "$REPO_ROOT")
require_repo_device 'managed run' "$LINKEDSPEC_RUN_DIR"
require_repo_device 'Dart temporary root' "$TMPDIR"
require_repo_device 'Dart package cache' "$PUB_CACHE"
case "$(cd -P -- "$TMPDIR" && pwd -P)/" in
 "$LINKEDSPEC_RUN_DIR/tmp/") ;;
 *) fail 'Dart temporary root is not the active managed-run tmp directory' ;;
esac

expected_temp_owners=(
 dart/test/callable_codeblock_literal_contract_test.dart
 dart/test/corpus_manifest_test.dart
 dart/test/duplicate_regex_slot_identity_contract_test.dart
 dart/test/logical_helper_contract_test.dart
 dart/test/native_pipeline_trace_test.dart
 dart/test/primary_cli_test.dart
 dart/test/repeated_action_result_contract_test.dart
 dart/test/root_rule_selection_admission_test.dart
 dart/test/root_rule_selection_routes_test.dart
 dart/test/rule_local_cursor_contract_test.dart
 dart/test/rule_local_cursor_descriptor_test.dart
 dart/test/rule_local_cursor_execution_test.dart
 dart/test/semantic_index_runtime_observation_routes_test.dart
 dart/test/semantic_index_runtime_observation_test.dart
 dart/test/semantic_introspection_dart_admission_test.dart
 dart/test/source_boundary_compatibility_aliases_test.dart
 dart/test/source_emitter_test.dart
 dart/test/spec_loader_test.dart
 dart/test/trace_test.dart
 dart/test/unicode_rule_label_identity_routes_test.dart
)
mapfile -t actual_temp_owners < <(
 while IFS= read -r relative; do
  if rg -q 'Directory[.]systemTemp' "$REPO_ROOT/$relative"; then
   printf '%s\n' "$relative"
  fi
 done < <(git -C "$REPO_ROOT" ls-files 'dart/**/*.dart')
)
(( ${#actual_temp_owners[@]} == ${#expected_temp_owners[@]} )) ||
 fail "tracked Dart temporary-owner inventory drifted from ${#expected_temp_owners[@]} to ${#actual_temp_owners[@]}"
for index in "${!expected_temp_owners[@]}"; do
 [[ "${actual_temp_owners[$index]}" == "${expected_temp_owners[$index]}" ]] ||
  fail "Dart temporary-owner inventory drifted at entry $index"
done

cd "$REPO_ROOT"
"${DART_RUN[@]}" pub get -C dart --offline
locked_hosted_count=$(awk '/^    source: hosted$/ { count++ } END { print count + 0 }' dart/pubspec.lock)
cached_package_count=$(find "$PUB_CACHE/hosted/pub.dev" -mindepth 1 -maxdepth 1 -type d \
 ! -name '.cache' | wc -l | tr -d ' ')
cached_hash_count=$(find "$PUB_CACHE/hosted-hashes/pub.dev" -type f | wc -l | tr -d ' ')
(( locked_hosted_count > 0 )) || fail 'Dart lockfile has no hosted packages to verify'
[[ "$cached_package_count" == "$locked_hosted_count" ]] ||
 fail "SSD Dart cache covers $cached_package_count/$locked_hosted_count locked package directories"
[[ "$cached_hash_count" == "$locked_hosted_count" ]] ||
 fail "SSD Dart cache covers $cached_hash_count/$locked_hosted_count locked package hashes"

package_config="$REPO_ROOT/dart/.dart_tool/package_config.json"
[[ -f "$package_config" ]] || fail 'Dart package configuration is missing after offline resolution'
expected_root_uri="file://$PUB_CACHE/hosted/pub.dev/"
configured_cache_count=$(rg -F -c "\"rootUri\": \"$expected_root_uri" "$package_config")
[[ "$configured_cache_count" == "$locked_hosted_count" ]] ||
 fail "Dart package configuration routes $configured_cache_count/$locked_hosted_count packages through the SSD cache"

if (( ! reuse_complete_gate )); then
 (
  cd "$REPO_ROOT/dart"
  "${DART_RUN[@]}" test test/native_pipeline_trace_test.dart test/source_emitter_test.dart test/trace_test.dart
 )
fi

if find "$TMPDIR" -mindepth 1 -type d -name 'linkedspec-dart-*' -print -quit | grep -q .; then
 fail 'a completed focused Dart workspace remained in managed temporary storage'
fi

printf '[dart-project-data-test] PASS: %s Dart owners, %s locked packages, generated workspaces, and traces stay on repository storage\n' \
 "${#expected_temp_owners[@]}" "$locked_hosted_count"
