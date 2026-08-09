#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_ci_local.sh" "$@"

cd "$REPO_ROOT"

log() {
 printf '[ci] %s\n' "$*"
}

fail() {
 printf '[ci] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

require_tracked_file() {
 local path="$1"
 [[ -f "$path" ]] || fail "required file missing: $path"
 git ls-files --error-unmatch -- "$path" >/dev/null 2>&1 || fail "required file is not git-tracked: $path"
}

require_tracked_tree() {
 local path="$1"
 [[ -d "$path" ]] || fail "required directory missing: $path"
 if ! git ls-files -- "$path" | grep -q .; then
  fail "required directory has no git-tracked files: $path"
 fi
}

check_no_untracked_ci_inputs() {
 local status_line
 local found=0

 while IFS= read -r status_line; do
  [[ "$status_line" == '?? '* ]] || continue
  printf '[ci] ERROR: untracked CI input: %s\n' "${status_line#?? }" >&2
  found=1
 done < <(git status --short --untracked-files=all -- .github/workflows bin/linkedspec capability_conformance cli_conformance unicode_case lua/src/linkedspec/semantic_index.lua lua/src/linkedspec/semantic_compilation_outcome.lua lua/src/linkedspec/semantic_static_projection.lua lua/src/linkedspec/semantic_query.lua lua/test/project_data_storage_test.lua lua/test/semantic_index_source_foundation_test.lua lua/test/semantic_index_compilation_foundation_test.lua lua/test/semantic_index_static_graph_test.lua lua/test/semantic_index_static_remaining_test.lua lua/test/semantic_index_call_core_test.lua lua/test/semantic_index_call_staged_generated_test.lua lua/test/semantic_index_query_kernel_test.lua tools/build_lua_native.sh tools/check_callable_codeblock_contract.py tools/check_callable_codeblock_five_backend.sh tools/check_callable_signature_contract.py tools/check_complete_named_mark_contract.py tools/check_diagnostic_output_contract.py tools/check_diagnostic_output_five_backend.sh tools/check_duplicate_regex_slot_identity_contract.py tools/check_duplicate_regex_slot_identity_five_backend.sh tools/check_logical_helper_contract.py tools/check_logical_helper_five_backend.sh tools/check_mcp_implementation_admission.py tools/check_mcp_semantic_transport_contract.py tools/materialize_mcp_semantic_transport_contract.py tools/mcp_contract_binding.py tools/generate_perl_mcp_contract.py tools/generate_rust_mcp_contract.py tools/generate_julia_mcp_contract.py tools/check_punctuation_light_zero_arg_contract.py tools/check_punctuation_light_five_backend.sh tools/check_repeated_action_result_contract.py tools/check_repeated_action_result_five_backend.sh tools/check_root_rule_selection_contract.py tools/check_root_rule_selection_five_backend.sh tools/check_semantic_introspection_contract.py tools/check_uniform_binding_contract.py tools/check_uniform_binding_mutation_result_surface.py tools/check_capability_conformance.pl tools/check_generated_source_contract.pl tools/check_language_capability_coverage.pl tools/check_native_spec_resolution_contract.pl tools/check_scalar_numeric_contract.py tools/check_unicode_case_contract.py tools/check_unicode_rule_label_contract.py tools/run_ci_local.sh tools/run_rust_local.sh tools/run_dart_local.sh tools/run_dart_project_data.sh tools/run_julia_local.sh tools/run_lua_project_data.sh tools/run_primary_cli_matrix.sh tools/run_python_project_data.sh tools/run_cli_conformance.pl tools/test_lua_project_data_storage.sh tools/test_perl_project_data_storage.sh tools/test_project_data_process_locality.sh tools/test_repo_root_process_portability.sh tools/test_tool_project_data_storage.sh rust/linkedspec-runtime/src/mcp_contract.rs rust/linkedspec-runtime/src/mcp_contract_runtime.rs rust/linkedspec-runtime/src/mcp_server.rs rust/linkedspec-runtime/src/mcp_wire.rs rust/linkedspec-runtime/tests/mcp_server_rust_dispatch.rs rust/linkedspec-runtime/tests/mcp_server_rust_stdio.rs rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs rust/linkedspec-runtime/tests/repository_root_relocation.rs dart/lib/src/mcp/mcp_wire.dart dart/test/mcp_server_dart_stdio_test.dart dart/test/mcp_server_dart_admission_test.dart specs conf tablescript ebnf perl t)

 while IFS= read -r status_line; do
  [[ "$status_line" == '?? '* ]] || continue
  printf '[ci] ERROR: untracked CI input: %s\n' "${status_line#?? }" >&2
  found=1
 done < <(git status --short --untracked-files=all -- \
  tools/generate_dart_mcp_contract.py \
  dart/lib/src/mcp/mcp_contract.dart \
  dart/lib/src/mcp/mcp_contract_runtime.dart \
  dart/lib/src/mcp/mcp_server.dart \
  dart/lib/src/mcp/mcp_wire.dart \
  dart/test/mcp_contract_dart_binding_test.dart \
  dart/test/mcp_server_dart_dispatch_test.dart \
  dart/test/mcp_server_dart_stdio_test.dart \
  dart/test/mcp_server_dart_admission_test.dart \
  julia/src/mcp/McpContract.jl \
  julia/src/mcp/McpContractRuntime.jl \
  julia/src/mcp/McpServer.jl \
  julia/src/mcp/McpWire.jl \
  julia/test/mcp_contract_julia_binding_test.jl \
  julia/test/mcp_server_julia_dispatch_test.jl \
  julia/test/mcp_server_julia_stdio_test.jl \
  julia/test/mcp_server_julia_admission_test.jl \
  tools/generate_lua_mcp_contract.py \
  lua/native/mcp_system.c \
  lua/src/linkedspec/mcp_contract.lua \
  lua/src/linkedspec/mcp_contract_runtime.lua \
  lua/src/linkedspec/mcp_server.lua \
  lua/src/linkedspec/mcp_wire.lua \
  lua/test/mcp_contract_lua_binding_test.lua \
  lua/test/mcp_server_lua_dispatch_test.lua \
  lua/test/mcp_server_lua_stdio_test.lua \
  lua/test/mcp_server_lua_admission_test.lua)

 status_line=$(git status --short --untracked-files=all -- lua/test/semantic_introspection_lua_admission_test.lua)
 if [[ "$status_line" == '?? '* ]]; then
  printf '[ci] ERROR: untracked CI input: %s\n' "${status_line#?? }" >&2
  found=1
 fi

 status_line=$(git status --short --untracked-files=all -- tools/check_semantic_introspection_six_runtime.sh)
 if [[ "$status_line" == '?? '* ]]; then
  printf '[ci] ERROR: untracked CI input: %s\n' "${status_line#?? }" >&2
  found=1
 fi

 status_line=$(git status --short --untracked-files=all -- tools/check_mcp_six_runtime.sh)
 if [[ "$status_line" == '?? '* ]]; then
  printf '[ci] ERROR: untracked CI input: %s\n' "${status_line#?? }" >&2
  found=1
 fi

 status_line=$(git status --short --untracked-files=all -- tools/check_typed_source_location_contract.py)
 if [[ "$status_line" == '?? '* ]]; then
  printf '[ci] ERROR: untracked CI input: %s\n' "${status_line#?? }" >&2
  found=1
 fi

 (( found == 0 )) || exit 1
}

audit_no_machine_specific_absolute_paths() {
 local path
 local matches
 local found=0

 while IFS= read -r path; do
  [[ -f "$path" ]] || continue
  matches=$(grep -nE '/(Users|home)/[^[:space:]]*|[[:alpha:]]:\\\\' "$path" || true)
  if [[ -n "$matches" ]]; then
   printf '[ci] ERROR: machine-specific absolute path(s) in %s:\n%s\n' "$path" "$matches" >&2
   found=1
  fi
 done < <(git ls-files -- .github/workflows/ci.yml bin/linkedspec capability_conformance cli_conformance unicode_case lua/src/linkedspec/semantic_index.lua lua/src/linkedspec/semantic_compilation_outcome.lua lua/src/linkedspec/semantic_static_projection.lua lua/src/linkedspec/semantic_query.lua lua/test/project_data_storage_test.lua lua/test/semantic_index_source_foundation_test.lua lua/test/semantic_index_compilation_foundation_test.lua lua/test/semantic_index_static_graph_test.lua lua/test/semantic_index_static_remaining_test.lua lua/test/semantic_index_call_core_test.lua lua/test/semantic_index_call_staged_generated_test.lua lua/test/semantic_index_query_kernel_test.lua tools/build_lua_native.sh tools/check_callable_codeblock_contract.py tools/check_callable_codeblock_five_backend.sh tools/check_callable_signature_contract.py tools/check_complete_named_mark_contract.py tools/check_diagnostic_output_contract.py tools/check_diagnostic_output_five_backend.sh tools/check_duplicate_regex_slot_identity_contract.py tools/check_duplicate_regex_slot_identity_five_backend.sh tools/check_logical_helper_contract.py tools/check_logical_helper_five_backend.sh tools/check_mcp_implementation_admission.py tools/check_mcp_semantic_transport_contract.py tools/materialize_mcp_semantic_transport_contract.py tools/mcp_contract_binding.py tools/generate_perl_mcp_contract.py tools/generate_rust_mcp_contract.py tools/check_punctuation_light_zero_arg_contract.py tools/check_punctuation_light_five_backend.sh tools/check_repeated_action_result_contract.py tools/check_repeated_action_result_five_backend.sh tools/check_root_rule_selection_contract.py tools/check_root_rule_selection_five_backend.sh tools/check_rule_local_cursor_contract.py tools/check_rule_local_cursor_five_backend.sh tools/check_semantic_introspection_contract.py tools/check_uniform_binding_contract.py tools/check_uniform_binding_mutation_result_surface.py tools/check_capability_conformance.pl tools/check_generated_source_contract.pl tools/check_language_capability_coverage.pl tools/check_native_spec_resolution_contract.pl tools/check_scalar_numeric_contract.py tools/check_unicode_case_contract.py tools/check_unicode_rule_label_contract.py tools/run_ci_local.sh tools/run_rust_local.sh tools/run_dart_local.sh tools/run_dart_project_data.sh tools/run_julia_local.sh tools/run_lua_project_data.sh tools/run_primary_cli_matrix.sh tools/run_python_project_data.sh tools/run_cli_conformance.pl tools/test_lua_project_data_storage.sh tools/test_project_data_process_locality.sh tools/test_repo_root_process_portability.sh tools/test_tool_project_data_storage.sh rust/linkedspec-runtime/src/mcp_contract.rs rust/linkedspec-runtime/src/mcp_contract_runtime.rs rust/linkedspec-runtime/src/mcp_server.rs rust/linkedspec-runtime/src/mcp_wire.rs rust/linkedspec-runtime/tests/mcp_server_rust_dispatch.rs rust/linkedspec-runtime/tests/mcp_server_rust_stdio.rs rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs rust/linkedspec-runtime/tests/repository_root_relocation.rs dart/test/mcp_server_dart_admission_test.dart t/phase0_regression.t t/trace_cli.t t/cli_conformance_runner.t t/repeated_action_result_perl_contract.t t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t t/mcp_server_perl_admission.t lua/test/repeated_action_result_contract_test.lua perl/LinkedSpec.pm perl/LinkedSpec)

 while IFS= read -r path; do
  [[ -f "$path" ]] || continue
  matches=$(grep -nE '/(Users|home)/[^[:space:]]*|[[:alpha:]]:\\\\' "$path" || true)
  if [[ -n "$matches" ]]; then
   printf '[ci] ERROR: machine-specific absolute path(s) in %s:\n%s\n' "$path" "$matches" >&2
   found=1
  fi
 done < <(git ls-files -- \
  tools/generate_dart_mcp_contract.py \
  tools/generate_julia_mcp_contract.py \
  dart/lib/src/mcp/mcp_contract.dart \
  dart/lib/src/mcp/mcp_contract_runtime.dart \
  dart/lib/src/mcp/mcp_server.dart \
  dart/lib/src/mcp/mcp_wire.dart \
  dart/test/mcp_contract_dart_binding_test.dart \
  dart/test/mcp_server_dart_dispatch_test.dart \
  dart/test/mcp_server_dart_stdio_test.dart \
  dart/test/mcp_server_dart_admission_test.dart \
  julia/src/mcp/McpContract.jl \
  julia/src/mcp/McpContractRuntime.jl \
  julia/src/mcp/McpServer.jl \
  julia/src/mcp/McpWire.jl \
  julia/test/mcp_contract_julia_binding_test.jl \
  julia/test/mcp_server_julia_dispatch_test.jl \
  julia/test/mcp_server_julia_stdio_test.jl \
  julia/test/mcp_server_julia_admission_test.jl \
  tools/generate_lua_mcp_contract.py \
  lua/native/mcp_system.c \
  lua/src/linkedspec/mcp_contract.lua \
  lua/src/linkedspec/mcp_contract_runtime.lua \
  lua/src/linkedspec/mcp_server.lua \
  lua/src/linkedspec/mcp_wire.lua \
  lua/test/mcp_contract_lua_binding_test.lua \
  lua/test/mcp_server_lua_dispatch_test.lua \
  lua/test/mcp_server_lua_stdio_test.lua \
  lua/test/mcp_server_lua_admission_test.lua)

 (( found == 0 )) || exit 1
}

log "repo root: $REPO_ROOT"
log "checking required commands"
require_command git
require_command perl
require_command prove
require_command python3
require_command dart
require_command julia

log "running the general doctrine enforcer (DOCTRINE_ENFORCEMENT.md §5/§7 — E4 backstop): the registry driver runs every registered check (memory-architecture, Knowledge Map, ...)"
bash "$REPO_ROOT/scripts/check_doctrines.sh"

log "auditing git-tracked CI inputs"
require_tracked_file .github/workflows/ci.yml
require_tracked_file tools/run_ci_local.sh
require_tracked_file tools/run_rust_local.sh
require_tracked_file tools/run_dart_local.sh
require_tracked_file tools/run_dart_project_data.sh
require_tracked_file tools/run_julia_local.sh
require_tracked_file tools/run_julia_project_data.sh
require_tracked_file tools/run_lua_local.sh
require_tracked_file tools/run_lua_project_data.sh
require_tracked_file tools/run_python_project_data.sh
require_tracked_file tools/run_primary_cli_matrix.sh
require_tracked_file tools/run_cargo_local.sh
require_tracked_file tools/build_lua_native.sh
require_tracked_file tools/test_perl_project_data_storage.sh
require_tracked_file tools/test_rust_project_data_storage.sh
require_tracked_file tools/test_dart_project_data_storage.sh
require_tracked_file tools/test_julia_project_data_storage.sh
require_tracked_file tools/test_lua_project_data_storage.sh
require_tracked_file tools/test_tool_project_data_storage.sh
require_tracked_file tools/test_project_data_process_locality.sh
require_tracked_file tools/test_repo_root_process_portability.sh
require_tracked_file rust/linkedspec-runtime/tests/repository_root_relocation.rs
require_tracked_file lua/test/project_data_storage_test.lua
require_tracked_file tools/check_julia_primary_cli.sh
require_tracked_file tools/run_cli_conformance.pl
require_tracked_file tools/check_callable_codeblock_contract.py
require_tracked_file tools/check_callable_codeblock_five_backend.sh
require_tracked_file tools/check_callable_signature_contract.py
require_tracked_file tools/check_complete_named_mark_contract.py
require_tracked_file tools/check_diagnostic_output_contract.py
require_tracked_file tools/check_diagnostic_output_five_backend.sh
require_tracked_file tools/check_duplicate_regex_slot_identity_contract.py
require_tracked_file tools/check_duplicate_regex_slot_identity_five_backend.sh
require_tracked_file tools/check_logical_helper_contract.py
require_tracked_file tools/check_logical_helper_five_backend.sh
require_tracked_file tools/materialize_mcp_semantic_transport_contract.py
require_tracked_file tools/check_mcp_semantic_transport_contract.py
require_tracked_file tools/mcp_contract_binding.py
require_tracked_file tools/generate_perl_mcp_contract.py
require_tracked_file tools/generate_rust_mcp_contract.py
require_tracked_file tools/generate_dart_mcp_contract.py
require_tracked_file tools/generate_julia_mcp_contract.py
require_tracked_file tools/generate_lua_mcp_contract.py
require_tracked_file tools/check_mcp_implementation_admission.py
require_tracked_file tools/check_punctuation_light_zero_arg_contract.py
require_tracked_file tools/check_punctuation_light_five_backend.sh
require_tracked_file tools/check_repeated_action_result_contract.py
require_tracked_file tools/check_repeated_action_result_five_backend.sh
require_tracked_file tools/check_root_rule_selection_contract.py
require_tracked_file tools/check_root_rule_selection_five_backend.sh
require_tracked_file tools/check_rule_local_cursor_contract.py
require_tracked_file tools/check_rule_local_cursor_five_backend.sh
require_tracked_file tools/check_typed_source_location_contract.py
require_tracked_file tools/check_semantic_introspection_contract.py
require_tracked_file tools/check_semantic_introspection_six_runtime.sh
require_tracked_file tools/check_mcp_six_runtime.sh
require_tracked_file tools/check_uniform_binding_contract.py
require_tracked_file tools/check_uniform_binding_mutation_result_surface.py
require_tracked_file tools/check_capability_conformance.pl
require_tracked_file tools/check_generated_source_contract.pl
require_tracked_file tools/check_language_capability_coverage.pl
require_tracked_file tools/check_native_spec_resolution_contract.pl
require_tracked_file tools/check_scalar_numeric_contract.py
require_tracked_file tools/check_unicode_case_contract.py
require_tracked_file tools/check_unicode_rule_label_contract.py
require_tracked_file capability_conformance/mcp_semantic_transport_contract.json
require_tracked_file capability_conformance/mcp_semantic_transport/schema.json
require_tracked_file capability_conformance/mcp_semantic_transport/semantic_payloads.json
require_tracked_file capability_conformance/mcp_semantic_transport/corpus.json
require_tracked_file capability_conformance/mcp_semantic_transport/canonical_frames.jsonl
require_tracked_file capability_conformance/mcp_semantic_transport/validator_cases.json
require_tracked_file capability_conformance/mcp_implementation_admission.json
require_tracked_file unicode_case/self_hosted_cli/manifest.json
require_tracked_file t/semantic_introspection_perl_admission.t
require_tracked_file rust/linkedspec-runtime/tests/semantic_introspection_rust_admission.rs
require_tracked_file rust/linkedspec-runtime/src/mcp_contract.rs
require_tracked_file rust/linkedspec-runtime/src/mcp_contract_runtime.rs
require_tracked_file rust/linkedspec-runtime/src/mcp_server.rs
require_tracked_file rust/linkedspec-runtime/src/mcp_wire.rs
require_tracked_file rust/linkedspec-runtime/tests/mcp_server_rust_dispatch.rs
require_tracked_file rust/linkedspec-runtime/tests/mcp_server_rust_stdio.rs
require_tracked_file rust/linkedspec-runtime/tests/mcp_server_rust_admission.rs
require_tracked_file dart/lib/src/mcp/mcp_contract.dart
require_tracked_file dart/lib/src/mcp/mcp_contract_runtime.dart
require_tracked_file dart/lib/src/mcp/mcp_server.dart
require_tracked_file dart/lib/src/mcp/mcp_wire.dart
require_tracked_file dart/test/mcp_contract_dart_binding_test.dart
require_tracked_file dart/test/mcp_server_dart_dispatch_test.dart
require_tracked_file dart/test/mcp_server_dart_stdio_test.dart
require_tracked_file dart/test/mcp_server_dart_admission_test.dart
require_tracked_file julia/src/mcp/McpContract.jl
require_tracked_file julia/src/mcp/McpContractRuntime.jl
require_tracked_file julia/src/mcp/McpServer.jl
require_tracked_file julia/src/mcp/McpWire.jl
require_tracked_file julia/test/mcp_contract_julia_binding_test.jl
require_tracked_file julia/test/mcp_server_julia_dispatch_test.jl
require_tracked_file julia/test/mcp_server_julia_stdio_test.jl
require_tracked_file julia/test/mcp_server_julia_admission_test.jl
require_tracked_file lua/native/mcp_system.c
require_tracked_file lua/src/linkedspec/mcp_contract.lua
require_tracked_file lua/src/linkedspec/mcp_contract_runtime.lua
require_tracked_file lua/src/linkedspec/mcp_server.lua
require_tracked_file lua/src/linkedspec/mcp_wire.lua
require_tracked_file lua/test/mcp_contract_lua_binding_test.lua
require_tracked_file lua/test/mcp_server_lua_dispatch_test.lua
require_tracked_file lua/test/mcp_server_lua_stdio_test.lua
require_tracked_file lua/test/mcp_server_lua_admission_test.lua
require_tracked_file dart/test/semantic_introspection_dart_admission_test.dart
require_tracked_file julia/test/semantic_introspection_julia_admission_test.jl
require_tracked_file lua/test/semantic_introspection_lua_admission_test.lua
require_tracked_file t/rule_local_cursor_perl_contract.t
require_tracked_file t/duplicate_regex_slot_identity_perl_contract.t
require_tracked_file t/sparse_and_action_slots_perl_regression.t
require_tracked_file t/repeated_action_result_perl_contract.t
require_tracked_file rust/linkedspec-runtime/tests/duplicate_regex_slot_identity_contract.rs
require_tracked_file rust/linkedspec-runtime/tests/repeated_action_result_contract.rs
require_tracked_file rust/linkedspec-core/tests/unicode_rule_label_contract.rs
require_tracked_file rust/linkedspec-runtime/tests/unicode_rule_label_routes.rs
require_tracked_file dart/test/repeated_action_result_contract_test.dart
require_tracked_file dart/test/self_hosted_unicode_rule_label_test.dart
require_tracked_file dart/lib/src/parser/unicode_rule_label.dart
require_tracked_file dart/test/unicode_rule_label_classifier_test.dart
require_tracked_file dart/test/unicode_rule_label_routes_test.dart
require_tracked_file dart/test/unicode_rule_label_identity_routes_test.dart
require_tracked_file dart/test/unicode_rule_label_negative_isolation_test.dart
require_tracked_file julia/src/spec/UnicodeRuleLabel.jl
require_tracked_file julia/test/unicode_rule_label_classifier_test.jl
require_tracked_file julia/test/unicode_rule_label_routes_test.jl
require_tracked_file julia/test/unicode_rule_label_identity_routes_test.jl
require_tracked_file julia/test/unicode_rule_label_negative_isolation_test.jl
require_tracked_file julia/test/repeated_action_result_contract_test.jl
require_tracked_file lua/src/linkedspec/unicode_rule_label.lua
require_tracked_file lua/src/linkedspec/semantic_index.lua
require_tracked_file lua/src/linkedspec/semantic_compilation_outcome.lua
require_tracked_file lua/src/linkedspec/semantic_static_projection.lua
require_tracked_file lua/src/linkedspec/semantic_query.lua
require_tracked_file lua/test/semantic_index_source_foundation_test.lua
require_tracked_file lua/test/semantic_index_compilation_foundation_test.lua
require_tracked_file lua/test/semantic_index_static_graph_test.lua
require_tracked_file lua/test/semantic_index_static_remaining_test.lua
require_tracked_file lua/test/semantic_index_call_core_test.lua
require_tracked_file lua/test/semantic_index_call_staged_generated_test.lua
require_tracked_file lua/test/semantic_index_query_kernel_test.lua
require_tracked_file lua/test/unicode_rule_label_classifier_test.lua
require_tracked_file lua/test/unicode_rule_label_routes_test.lua
require_tracked_file lua/test/unicode_rule_label_identity_routes_test.lua
require_tracked_file lua/test/body_fluent_whole_token_test.lua
require_tracked_file lua/test/unicode_rule_label_negative_isolation_test.lua
require_tracked_file lua/test/repeated_action_result_contract_test.lua
require_tracked_file dart/test/duplicate_regex_slot_identity_contract_test.dart
require_tracked_file julia/test/duplicate_regex_slot_identity_contract_test.jl
require_tracked_file lua/test/duplicate_regex_slot_identity_contract_test.lua
require_tracked_file t/root_rule_selection_perl_core.t
require_tracked_file t/root_rule_selection_perl_routes.t
require_tracked_file rust/linkedspec-runtime/tests/rule_local_cursor_contract.rs
require_tracked_file dart/test/rule_local_cursor_contract_test.dart
require_tracked_file julia/test/rule_local_cursor_contract_test.jl
require_tracked_file lua/test/rule_local_cursor_contract_test.lua
require_tracked_file rust/linkedspec-runtime/tests/root_rule_selection_admission.rs
require_tracked_file dart/test/root_rule_selection_admission_test.dart
require_tracked_file julia/test/root_rule_selection_admission_test.jl
require_tracked_file lua/test/root_rule_selection_admission_test.lua
require_tracked_file bin/linkedspec
require_tracked_file capability_conformance/manifest.json
require_tracked_file capability_conformance/callable_codeblock_contract.json
require_tracked_file capability_conformance/callable_signature_contract.json
require_tracked_file capability_conformance/complete_named_mark_contract.json
require_tracked_file capability_conformance/diagnostic_output_contract.json
require_tracked_file capability_conformance/duplicate_regex_slot_identity_contract.json
require_tracked_file capability_conformance/logical_helper_contract.json
require_tracked_file capability_conformance/punctuation_light_zero_arg_contract.json
require_tracked_file capability_conformance/repeated_action_result_contract.json
require_tracked_file capability_conformance/repeated_action_result/explicit_or_distinct.spec
require_tracked_file capability_conformance/repeated_action_result/explicit_or_distinct.input
require_tracked_file capability_conformance/repeated_action_result/explicit_or_distinct.expected.json
require_tracked_file capability_conformance/root_rule_selection_contract.json
require_tracked_file capability_conformance/rule_local_cursor_contract.json
require_tracked_file capability_conformance/typed_source_location_contract.json
require_tracked_file capability_conformance/semantic_introspection_contract.json
require_tracked_file capability_conformance/semantic_introspection_model.json
require_tracked_file capability_conformance/uniform_binding_contract.json
require_tracked_file capability_conformance/generated_source_contract.json
require_tracked_file capability_conformance/native_spec_resolution_contract.json
require_tracked_file capability_conformance/unicode_case_contract.json
require_tracked_file capability_conformance/unicode_rule_label_contract.json
require_tracked_file capability_conformance/scalar_text_contract.json
require_tracked_file capability_conformance/scalar_numeric_contract.json
require_tracked_file unicode_case/README.md
require_tracked_file unicode_case/generate_unicode_case_contract.py
require_tracked_file unicode_case/generate_unicode_rule_label_contract.py
require_tracked_file unicode_case/unicode_rule_label_regex_class.txt
require_tracked_file unicode_case/upstream/17.0.0/UnicodeData.txt.gz
require_tracked_file unicode_case/upstream/17.0.0/SpecialCasing.txt.gz
require_tracked_file unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz
require_tracked_file unicode_case/upstream/17.0.0/LICENSE.txt.gz
require_tracked_file perl/LinkedSpec/UnicodeCaseMapping.pm
require_tracked_file rust/linkedspec-runtime/src/unicode_case_mapping.rs
require_tracked_file rust/linkedspec-core/src/unicode_rule_label.rs
require_tracked_file rust/linkedspec-runtime/src/semantic_index.rs
require_tracked_file rust/linkedspec-runtime/tests/unicode_case_mapping.rs
require_tracked_file rust/linkedspec-runtime/tests/semantic_index_foundation.rs
require_tracked_file dart/lib/src/runtime/unicode_case_mapping.dart
require_tracked_file dart/test/unicode_case_mapping_test.dart
require_tracked_file julia/src/runtime/UnicodeCaseMapping.jl
require_tracked_file lua/src/linkedspec/unicode_case_mapping.lua
require_tracked_file cli_conformance/manifest.json
require_tracked_file t/cli_conformance_runner.t
require_tracked_file t/trace_cli.t
require_tracked_file t/native_spec_resolution.t
require_tracked_file t/generated_source_contract.t
require_tracked_file t/diagnostic_output_perl_contract.t
require_tracked_file t/scalar_numeric_contract.t
require_tracked_file t/punctuation_light_zero_arg_contract.t
require_tracked_file t/complete_named_mark_contract.t
require_tracked_file t/typed_source_location_values.t
require_tracked_file t/typed_source_location_perl_contract.t
require_tracked_file rust/linkedspec-runtime/tests/typed_source_location_contract.rs
require_tracked_file dart/test/typed_source_location_contract_test.dart
require_tracked_file julia/test/typed_source_location_contract_test.jl
require_tracked_file lua/test/source_boundary_compatibility_aliases_test.lua
require_tracked_file t/variadic_user_function_contract.t
require_tracked_file t/callable_codeblock_literal_contract.t
require_tracked_file t/uniform_binding_contract.t
require_tracked_file t/semantic_index_perl_foundation.t
require_tracked_file t/semantic_index_perl_static_projection.t
require_tracked_file t/semantic_index_perl_calls_projection.t
require_tracked_file t/semantic_index_perl_query.t
require_tracked_file t/semantic_index_perl_runtime_observation.t
require_tracked_file t/mcp_contract_perl_binding.t
require_tracked_file t/mcp_server_perl_dispatch.t
require_tracked_file t/mcp_server_perl_stdio.t
require_tracked_file t/mcp_server_perl_admission.t
require_tracked_file perl/LinkedSpec/SemanticCallProjection.pm
require_tracked_file perl/LinkedSpec/SemanticQuery.pm
require_tracked_file perl/LinkedSpec/SemanticRuntimeProjection.pm
require_tracked_file perl/LinkedSpec/SemanticStaticProjection.pm
require_tracked_file perl/LinkedSpec/RuntimeSemanticObservation.pm
require_tracked_file tools/check_aggregate_selector_retirement.py
require_tracked_file tools/check_public_aggregate_selector_surface.py
require_tracked_file tools/check_executable_aggregate_selector_sources.py
require_tracked_file perl/LinkedSpec.pm
require_tracked_file perl/LinkedSpec/BindingRuntime.pm
require_tracked_file perl/LinkedSpec/SpecLoader.pm
require_tracked_file perl/LinkedSpec/GeneratedSource.pm
require_tracked_file perl/LinkedSpec/SemanticIndex.pm
require_tracked_file perl/LinkedSpec/SemanticSourceMap.pm
require_tracked_file perl/LinkedSpec/MCPContract.pm
require_tracked_file perl/LinkedSpec/MCPContractRuntime.pm
require_tracked_file perl/LinkedSpec/MCPServer.pm
require_tracked_file perl/LinkedSpec/MCPWire.pm
require_tracked_file perl/LinkedSpec/Numeric.pm
require_tracked_file t/phase0_regression.t
require_tracked_file scripts/check_memory_architecture.sh
require_tracked_file scripts/check_memory_commit_pointer.sh
require_tracked_file tools/test_memory_commit_pointer.sh
require_tracked_file scripts/check_doctrines.sh
require_tracked_file scripts/check_diagnosis_evidence.sh
require_tracked_file scripts/check_readme_stability.sh
require_tracked_file README_POLICY.md
require_tracked_file DOCTRINE_ENFORCEMENT.md
require_tracked_file TOOLBOX.md
require_tracked_file MEMORY_ARCHITECTURE.md
require_tracked_file KNOWLEDGE_MAP.md
require_tracked_file knowledge-map/scripts/gen_knowledge_map.sh
require_tracked_file knowledge-map/scripts/check_knowledge_map.sh
# NOTE: 'plugin' is intentionally NOT required here — NONCORE-QUARANTINE.3 git mv'd the 13 .plg to
# noncore/plugin/ and removed the top-level plugin/ dir. The core gate stays core-only and does not reach
# into noncore/ (same core-only precedent as PHASE0-BACKHALF-TRIAGE.5.1/.5.4). (PHASE0-BACKHALF-TRIAGE.5.3.1)
for path in capability_conformance cli_conformance unicode_case specs conf tablescript ebnf perl t; do
 require_tracked_tree "$path"
done
check_no_untracked_ci_inputs

log "auditing CI-local path usage"
audit_no_machine_specific_absolute_paths
semantic_driver_matches=$(grep -nE '/(Users|home)/[^[:space:]]*|[[:alpha:]]:\\\\' tools/check_semantic_introspection_six_runtime.sh || true)
[[ -z "$semantic_driver_matches" ]] || fail "machine-specific absolute path(s) in semantic recurring driver:
$semantic_driver_matches"
mcp_driver_matches=$(grep -nE '/(Users|home)/[^[:space:]]*|[[:alpha:]]:\\\\' tools/check_mcp_six_runtime.sh || true)
[[ -z "$mcp_driver_matches" ]] || fail "machine-specific absolute path(s) in MCP recurring driver:
$mcp_driver_matches"

log "running syntax checks"
bash -n tools/run_ci_local.sh tools/run_rust_local.sh tools/run_dart_local.sh \
 tools/run_julia_local.sh tools/run_julia_project_data.sh tools/run_lua_local.sh tools/run_lua_project_data.sh \
 tools/run_python_project_data.sh tools/run_dart_project_data.sh \
 tools/run_primary_cli_matrix.sh \
 tools/build_lua_native.sh tools/check_julia_primary_cli.sh \
 tools/run_cargo_local.sh tools/test_perl_project_data_storage.sh tools/test_rust_project_data_storage.sh \
 tools/test_dart_project_data_storage.sh tools/test_julia_project_data_storage.sh \
 tools/test_lua_project_data_storage.sh tools/test_tool_project_data_storage.sh \
 tools/test_project_data_process_locality.sh tools/test_repo_root_process_portability.sh \
 tools/check_callable_codeblock_five_backend.sh \
 tools/check_diagnostic_output_five_backend.sh tools/check_logical_helper_five_backend.sh \
 tools/check_duplicate_regex_slot_identity_five_backend.sh tools/check_repeated_action_result_five_backend.sh \
 tools/check_root_rule_selection_five_backend.sh \
 tools/check_rule_local_cursor_five_backend.sh \
 tools/check_semantic_introspection_six_runtime.sh \
 tools/check_mcp_six_runtime.sh \
 scripts/check_memory_commit_pointer.sh scripts/check_readme_stability.sh \
 tools/test_memory_commit_pointer.sh \
 tools/check_punctuation_light_five_backend.sh tools/check_scalar_numeric_six_runtime.sh
perl -c perl/LinkedSpec.pm
perl -c bin/linkedspec
perl -c tools/run_cli_conformance.pl
perl -c tools/check_capability_conformance.pl
perl -c tools/check_generated_source_contract.pl
perl -c tools/check_language_capability_coverage.pl
perl -c tools/check_native_spec_resolution_contract.pl
perl -c -Iperl t/actionir_ast_parser.t
perl -c -Iperl t/cli_conformance_runner.t
perl -c -Iperl t/trace_cli.t
perl -c -Iperl t/native_spec_resolution.t
perl -c -Iperl t/generated_source_contract.t
perl -c -Iperl t/diagnostic_output_perl_contract.t
perl -c -Iperl t/scalar_text_contract.t
perl -c -Iperl t/scalar_numeric_contract.t
perl -c -Iperl t/punctuation_light_zero_arg_contract.t
perl -c -Iperl t/complete_named_mark_contract.t
perl -c -Iperl t/typed_source_location_values.t
perl -c -Iperl t/typed_source_location_perl_contract.t
perl -c -Iperl t/rule_local_cursor_perl_contract.t
perl -c -Iperl t/duplicate_regex_slot_identity_perl_contract.t
perl -c -Iperl t/sparse_and_action_slots_perl_regression.t
perl -c -Iperl t/repeated_action_result_perl_contract.t
perl -c -Iperl t/root_rule_selection_perl_core.t
perl -c -Iperl t/root_rule_selection_perl_routes.t
perl -c -Iperl t/variadic_user_function_contract.t
perl -c -Iperl t/callable_codeblock_literal_contract.t
perl -c -Iperl t/uniform_binding_contract.t
perl -c -Iperl t/semantic_index_perl_foundation.t
perl -c -Iperl t/semantic_index_perl_static_projection.t
perl -c -Iperl t/semantic_index_perl_calls_projection.t
perl -c -Iperl t/semantic_index_perl_query.t
perl -c -Iperl t/semantic_index_perl_runtime_observation.t
perl -c -Iperl t/semantic_introspection_perl_admission.t
perl -c -Iperl t/mcp_contract_perl_binding.t
perl -c -Iperl t/mcp_server_perl_dispatch.t
perl -c -Iperl t/mcp_server_perl_stdio.t
perl -c -Iperl t/mcp_server_perl_admission.t
perl -c -Iperl perl/LinkedSpec/BindingRuntime.pm
perl -c -Iperl perl/LinkedSpec/SemanticIndex.pm
perl -c -Iperl perl/LinkedSpec/SemanticSourceMap.pm
perl -c -Iperl perl/LinkedSpec/SemanticCallProjection.pm
perl -c -Iperl perl/LinkedSpec/SemanticQuery.pm
perl -c -Iperl perl/LinkedSpec/SemanticRuntimeProjection.pm
perl -c -Iperl perl/LinkedSpec/SemanticStaticProjection.pm
perl -c -Iperl perl/LinkedSpec/RuntimeSemanticObservation.pm
perl -c -Iperl perl/LinkedSpec/MCPContract.pm
perl -c -Iperl perl/LinkedSpec/MCPContractRuntime.pm
perl -c -Iperl perl/LinkedSpec/MCPServer.pm
perl -c -Iperl perl/LinkedSpec/MCPWire.pm
perl -c -Iperl t/phase0_regression.t

log "checking the phase-aware MEMORY activation-commit pointer"
bash tools/test_memory_commit_pointer.sh

log "checking machine-readable backend capability census"
perl tools/check_capability_conformance.pl

log "checking pinned Unicode casing contract"
bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py

log "checking pinned Unicode rule-label contract"
bash tools/run_python_project_data.sh tools/check_unicode_rule_label_contract.py

log "checking portable scalar numeric helper contract"
bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py

log "checking backend-neutral logical-helper and typed-truthiness contract"
bash tools/run_python_project_data.sh tools/check_logical_helper_contract.py

log "checking backend-neutral rule-local cursor and bare-edge contract"
bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py

log "checking backend-neutral typed source-location algebra contract"
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py

log "running exact Perl typed source-location value and projection admission consumers"
PERL5LIB= prove -Iperl t/typed_source_location_values.t t/typed_source_location_perl_contract.t

log "running exact Rust typed source-location value and projection admission consumer"
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test typed_source_location_contract

log "running exact Dart typed source-location value and projection admission consumer"
(cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/typed_source_location_contract_test.dart)

log "running exact Julia typed source-location value and projection admission consumer"
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/typed_source_location_contract_test.jl")'

log "checking backend-neutral root-rule selection contract"
bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py

log "checking backend-neutral semantic introspection model/query contract"
bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py

log "checking exact MCP transport materialization"
bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py

log "independently validating the MCP transport contract"
bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py

log "checking the generated filesystem-free Perl MCP contract binding"
bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py

log "checking the generated filesystem-free Rust MCP contract binding"
bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py

log "checking the generated filesystem-free Dart MCP contract binding"
bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py

log "checking the generated filesystem-free Julia MCP contract binding"
bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py

log "checking the generated filesystem-free Lua MCP contract binding"
bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py

log "running Perl MCP contract-binding, decoded-dispatch, and strict-stdio proof"
PERL5LIB= prove -Iperl t/mcp_contract_perl_binding.t t/mcp_server_perl_dispatch.t t/mcp_server_perl_stdio.t

log "running Rust MCP frozen-runtime, secure-registry, decoded-dispatch, strict-stdio, and exact-admission proof"
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib mcp_
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_dispatch
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_stdio
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test mcp_server_rust_admission

log "running Dart MCP generated-binding, frozen-runtime, secure-registry, decoded-dispatch, and strict-stdio proof"
(
 cd "$REPO_ROOT/dart"
 bash ../tools/run_dart_project_data.sh test test/mcp_contract_dart_binding_test.dart test/mcp_server_dart_dispatch_test.dart test/mcp_server_dart_stdio_test.dart
)

log "running exact Dart MCP admission consumer"
(
 cd "$REPO_ROOT/dart"
 bash ../tools/run_dart_project_data.sh test test/mcp_server_dart_admission_test.dart
)

log "running Julia MCP generated-binding, frozen-runtime, secure-registry, decoded-dispatch, and strict-stdio proof"
bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include("julia/test/mcp_contract_julia_binding_test.jl"); include("julia/test/mcp_server_julia_dispatch_test.jl"); include("julia/test/mcp_server_julia_stdio_test.jl")'

log "running exact Julia MCP admission consumer"
bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, Test; const REPO_ROOT=pwd(); include("julia/test/mcp_server_julia_admission_test.jl")'

log "running exact shared Lua MCP admission consumer on PUC Lua"
bash tools/run_lua_project_data.sh puc lua/test/mcp_server_lua_admission_test.lua

log "running exact shared Lua MCP admission consumer on LuaJIT"
bash tools/run_lua_project_data.sh luajit lua/test/mcp_server_lua_admission_test.lua

log "checking MCP implementation/runtime admission ledger"
bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py

log "running exact Perl MCP admission consumer"
PERL5LIB= prove -Iperl t/mcp_server_perl_admission.t

log "running Perl semantic-index source/map/outcome foundation"
PERL5LIB= prove -Iperl t/semantic_index_perl_foundation.t

log "running Perl semantic-index static graph/diagnostic projection"
PERL5LIB= prove -Iperl t/semantic_index_perl_static_projection.t

log "running Perl semantic-index call/staged/generated projection"
PERL5LIB= prove -Iperl t/semantic_index_perl_calls_projection.t

log "running Perl immutable semantic capabilities/query evaluator"
PERL5LIB= prove -Iperl t/semantic_index_perl_query.t

log "running Perl typed runtime semantic observation and route projection"
PERL5LIB= prove -Iperl t/semantic_index_perl_runtime_observation.t

log "running composed Perl semantic-introspection admission consumer"
PERL5LIB= prove -Iperl t/semantic_introspection_perl_admission.t

log "running composed Rust semantic-introspection admission consumer"
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_introspection_rust_admission

log "running composed Dart semantic-introspection admission consumer"
(
 cd "$REPO_ROOT/dart"
 bash ../tools/run_dart_project_data.sh test test/semantic_introspection_dart_admission_test.dart
)

log "running composed Julia semantic-introspection admission consumer"
julia --project=julia --startup-file=no --history-file=no --compiled-modules=no julia/test/semantic_introspection_julia_admission_test.jl

log "checking backend-neutral duplicate regex-slot identity contract"
bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py

log "running composed Perl duplicate regex-slot identity consumer"
PERL5LIB= prove -Iperl t/duplicate_regex_slot_identity_perl_contract.t

log "running Perl sparse-AND action-slot regression consumer"
PERL5LIB= prove -Iperl t/sparse_and_action_slots_perl_regression.t

log "checking backend-neutral explicit-repetition action-result contract"
bash tools/run_python_project_data.sh tools/check_repeated_action_result_contract.py

log "running composed Perl explicit-repetition action-result consumer"
PERL5LIB= prove -Iperl t/repeated_action_result_perl_contract.t

log "running focused Perl root-rule selection core consumer"
PERL5LIB= prove -Iperl t/root_rule_selection_perl_core.t

log "running focused Perl root-rule loaded/generated/trace consumer"
PERL5LIB= prove -Iperl t/root_rule_selection_perl_routes.t

log "running composed Perl rule-local cursor admission consumer"
PERL5LIB= prove -Iperl t/rule_local_cursor_perl_contract.t

log "checking portable callable-signature contract"
bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py

log "checking portable callable-codeblock contract"
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py

log "checking complete named-mark helper contract"
bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py

log "checking backend-neutral diagnostic-output event contract"
bash tools/run_python_project_data.sh tools/check_diagnostic_output_contract.py

printf '%s\n' '[ci-local] Perl diagnostic-output event contract'
PERL5LIB= prove -Iperl t/diagnostic_output_perl_contract.t

log "running Perl complete named-mark behavior contract fixture"
PERL5LIB= prove -Iperl t/complete_named_mark_contract.t

log "checking punctuation-light zero-argument syntax contract"
bash tools/run_python_project_data.sh tools/check_punctuation_light_zero_arg_contract.py

log "running Perl punctuation-light zero-argument behavior contract fixture"
PERL5LIB= prove -Iperl t/punctuation_light_zero_arg_contract.t

log "checking portable uniform-binding and aggregate-selector retirement contract"
bash tools/run_python_project_data.sh tools/check_uniform_binding_contract.py

log "checking uniform-binding mutation-result public surface"
bash tools/run_python_project_data.sh tools/check_uniform_binding_mutation_result_surface.py

log "checking final public aggregate-selector retirement admission"
bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py

log "running Perl uniform-binding behavior contract fixture"
PERL5LIB= prove -Iperl t/uniform_binding_contract.t

log "running Perl callable-codeblock literal contract fixture"
PERL5LIB= prove -Iperl t/callable_codeblock_literal_contract.t

log "running Perl variadic user-function contract fixture"
PERL5LIB= prove -Iperl t/variadic_user_function_contract.t

log "checking generated-source capability contract"
perl tools/check_generated_source_contract.pl

log "running Perl generated-source contract fixture"
PERL5LIB= prove -Iperl t/generated_source_contract.t

log "running neutral scalar-to-text contract fixture"
PERL5LIB= prove -Iperl t/scalar_text_contract.t

log "running Perl scalar numeric contract fixture"
PERL5LIB= prove -Iperl t/scalar_numeric_contract.t

log "checking native named/file resolution contract"
perl tools/check_native_spec_resolution_contract.pl

log "running Perl native named/file resolution fixture"
PERL5LIB= prove -Iperl t/native_spec_resolution.t

log "checking exhaustive current ActionIR documentation and neutral corpus coverage"
perl tools/check_language_capability_coverage.pl

log "running ActionIR AST parser focused suite"
prove -Iperl t/actionir_ast_parser.t

log "running primary CLI runner and focused trace suites"
PERL5LIB= prove -Iperl t/cli_conformance_runner.t t/trace_cli.t

log "proving Perl project data stays in managed repository storage"
bash "$REPO_ROOT/tools/test_perl_project_data_storage.sh"

log "proving Python and tool output stays in managed repository storage"
bash "$REPO_ROOT/tools/test_tool_project_data_storage.sh"

log "proving representative process IO stays within repository storage and necessary reads"
bash "$REPO_ROOT/tools/test_project_data_process_locality.sh"

log "proving relocated named-spec execution across all five primary runtime anchors"
bash "$REPO_ROOT/tools/test_repo_root_process_portability.sh"

log "running primary CLI conformance (default option environment)"
PERL5LIB= perl tools/run_cli_conformance.pl \
 --display-command 'perl bin/linkedspec' \
 -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec

log "running primary CLI conformance (POSIX option environment)"
POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl \
 --display-command 'perl bin/linkedspec' \
 -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec

# Memory guard — bail if system RAM is critically low before running the heavy suite
_ram_used_pct() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local page_size free_pages inactive_pages speculative_pages total_ram avail_pages
    page_size=$(pagesize 2>/dev/null || echo 16384)
    free_pages=$(vm_stat 2>/dev/null | awk '/Pages free/               {print $NF}' | tr -d '.')
    inactive_pages=$(vm_stat 2>/dev/null | awk '/Pages inactive/         {print $NF}' | tr -d '.')
    speculative_pages=$(vm_stat 2>/dev/null | awk '/Pages speculative/    {print $NF}' | tr -d '.')
    avail_pages=$(( ${free_pages:-0} + ${inactive_pages:-0} + ${speculative_pages:-0} ))
    total_ram=$(sysctl -n hw.memsize 2>/dev/null || echo 17179869184)
    echo $(( 100 - (avail_pages * page_size * 100 / total_ram) ))
  else
    awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", 100-(a*100/t)}' /proc/meminfo 2>/dev/null || echo 0
  fi
}
GUARD_PCT=$(_ram_used_pct)
DANGER_PCT="${LINKEDSPEC_TEST_DANGER_PCT:-88}"
if [[ "${GUARD_PCT}" -ge "${DANGER_PCT}" ]]; then
  fail "RAM ${GUARD_PCT}% used (danger threshold ${DANGER_PCT}%) — refusing to run heavy suite. Free RAM and retry, or set LINKEDSPEC_TEST_DANGER_PCT higher."
fi
log "RAM ${GUARD_PCT}% used — within threshold (${DANGER_PCT}%)"

log "running phase0 regression suite"
prove -v -Iperl t/phase0_regression.t

if [[ "${LINKEDSPEC_RUN_RUST:-0}" == "1" ]]; then
 log "running optional Rust local gate (LINKEDSPEC_RUN_RUST=1)"
 require_tracked_file tools/run_rust_local.sh
 bash "$REPO_ROOT/tools/run_rust_local.sh"
else
 log "skipping optional Rust local gate (set LINKEDSPEC_RUN_RUST=1 to include it when a Rust toolchain is available)"
fi

if [[ "${LINKEDSPEC_RUN_DART:-0}" == "1" ]]; then
 log "running optional Dart local gate (LINKEDSPEC_RUN_DART=1)"
 require_tracked_file tools/run_dart_local.sh
 bash "$REPO_ROOT/tools/run_dart_local.sh"
else
 log "skipping optional Dart local gate (set LINKEDSPEC_RUN_DART=1 to include it when a Dart SDK is available)"
fi

if [[ "${LINKEDSPEC_RUN_JULIA:-0}" == "1" ]]; then
 log "running optional Julia local gate (LINKEDSPEC_RUN_JULIA=1)"
 require_tracked_file tools/run_julia_local.sh
 bash "$REPO_ROOT/tools/run_julia_local.sh"
else
 log "skipping optional Julia local gate (set LINKEDSPEC_RUN_JULIA=1 to include it when a Julia SDK is available)"
fi

if [[ "${LINKEDSPEC_RUN_LUA:-0}" == "1" ]]; then
 log "running optional dual-ABI Lua local gate (LINKEDSPEC_RUN_LUA=1)"
 require_tracked_file tools/run_lua_local.sh
 bash "$REPO_ROOT/tools/run_lua_local.sh"
else
 log "skipping optional dual-ABI Lua local gate (set LINKEDSPEC_RUN_LUA=1 when PUC Lua and LuaJIT are available)"
fi

if [[ "${LINKEDSPEC_RUN_CLI_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend primary CLI matrix (LINKEDSPEC_RUN_CLI_MATRIX=1)"
 require_tracked_file tools/run_primary_cli_matrix.sh
 bash "$REPO_ROOT/tools/run_primary_cli_matrix.sh"
 bash "$REPO_ROOT/tools/run_primary_cli_matrix.sh" --manifest unicode_case/self_hosted_cli/manifest.json
else
 log "skipping optional five-backend primary CLI matrix (set LINKEDSPEC_RUN_CLI_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_SEMANTIC_MATRIX:-0}" == "1" ]]; then
 log "running optional six-runtime semantic-introspection matrix (LINKEDSPEC_RUN_SEMANTIC_MATRIX=1)"
 require_tracked_file tools/check_semantic_introspection_six_runtime.sh
 bash "$REPO_ROOT/tools/check_semantic_introspection_six_runtime.sh"
else
 log "skipping optional six-runtime semantic-introspection matrix (set LINKEDSPEC_RUN_SEMANTIC_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_MCP_MATRIX:-0}" == "1" ]]; then
 log "running optional six-runtime MCP composition matrix (LINKEDSPEC_RUN_MCP_MATRIX=1)"
 require_tracked_file tools/check_mcp_six_runtime.sh
 bash "$REPO_ROOT/tools/check_mcp_six_runtime.sh"
else
 log "skipping optional six-runtime MCP composition matrix (set LINKEDSPEC_RUN_MCP_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend callable-codeblock matrix (LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX=1)"
 require_tracked_file tools/check_callable_codeblock_five_backend.sh
 bash "$REPO_ROOT/tools/check_callable_codeblock_five_backend.sh"
else
 log "skipping optional five-backend callable-codeblock matrix (set LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX=1 when all five backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_DIAGNOSTIC_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend diagnostic-output matrix (LINKEDSPEC_RUN_DIAGNOSTIC_MATRIX=1)"
 require_tracked_file tools/check_diagnostic_output_five_backend.sh
 bash "$REPO_ROOT/tools/check_diagnostic_output_five_backend.sh"
else
 log "skipping optional five-backend diagnostic-output matrix (set LINKEDSPEC_RUN_DIAGNOSTIC_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_LOGICAL_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend logical-helper matrix (LINKEDSPEC_RUN_LOGICAL_MATRIX=1)"
 require_tracked_file tools/check_logical_helper_five_backend.sh
 bash "$REPO_ROOT/tools/check_logical_helper_five_backend.sh"
else
 log "skipping optional five-backend logical-helper matrix (set LINKEDSPEC_RUN_LOGICAL_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_ROOT_RULE_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend root-rule selection matrix (LINKEDSPEC_RUN_ROOT_RULE_MATRIX=1)"
 require_tracked_file tools/check_root_rule_selection_five_backend.sh
 bash "$REPO_ROOT/tools/check_root_rule_selection_five_backend.sh"
else
 log "skipping optional five-backend root-rule selection matrix (set LINKEDSPEC_RUN_ROOT_RULE_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_CURSOR_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend rule-local cursor matrix (LINKEDSPEC_RUN_CURSOR_MATRIX=1)"
 require_tracked_file tools/check_rule_local_cursor_five_backend.sh
 bash "$REPO_ROOT/tools/check_rule_local_cursor_five_backend.sh"
else
 log "skipping optional five-backend rule-local cursor matrix (set LINKEDSPEC_RUN_CURSOR_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_DUPLICATE_SLOT_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend duplicate regex-slot matrix (LINKEDSPEC_RUN_DUPLICATE_SLOT_MATRIX=1)"
 require_tracked_file tools/check_duplicate_regex_slot_identity_five_backend.sh
 bash "$REPO_ROOT/tools/check_duplicate_regex_slot_identity_five_backend.sh"
else
 log "skipping optional five-backend duplicate regex-slot matrix (set LINKEDSPEC_RUN_DUPLICATE_SLOT_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend repeated action-result matrix (LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX=1)"
 require_tracked_file tools/check_repeated_action_result_five_backend.sh
 bash "$REPO_ROOT/tools/check_repeated_action_result_five_backend.sh"
else
 log "skipping optional five-backend repeated action-result matrix (set LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX=1 when all backend toolchains are available)"
fi

if [[ "${LINKEDSPEC_RUN_PUNCTUATION_MATRIX:-0}" == "1" ]]; then
 log "running optional five-backend punctuation-light matrix (LINKEDSPEC_RUN_PUNCTUATION_MATRIX=1)"
 require_tracked_file tools/check_punctuation_light_five_backend.sh
 bash "$REPO_ROOT/tools/check_punctuation_light_five_backend.sh"
else
 log "skipping optional five-backend punctuation-light matrix (set LINKEDSPEC_RUN_PUNCTUATION_MATRIX=1 when all backend toolchains are available)"
fi

log "local CI gate passed"
