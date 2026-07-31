#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_tool_project_data_storage.sh" "$@"

fail() {
 printf '[tool-project-data-test] ERROR: %s\n' "$*" >&2
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

assert_local_real_path() {
 local path=$1
 [[ -e "$path" && ! -L "$path" ]] || fail "expected a real generated path: $path"
 [[ "$(device_id "$path")" == "$repo_device" ]] || fail "generated path crossed the repository filesystem: $path"
}

mcp_ci_topology_matches() {
 local ci_path=$1
 local -a actual_commands
 local -a expected_commands=(
  'bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py'
  'bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py'
  'bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py'
  'bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py'
  'bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py'
  'bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py'
  'bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py'
  'bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py'
 )
 mapfile -t actual_commands < <(
  rg '^bash tools/run_python_project_data[.]sh tools/(materialize_mcp_semantic_transport_contract|check_mcp_semantic_transport_contract|generate_perl_mcp_contract|generate_rust_mcp_contract|generate_dart_mcp_contract|generate_julia_mcp_contract|generate_lua_mcp_contract|check_mcp_implementation_admission)[.]py$' \
   "$ci_path"
 )
 [[ "${actual_commands[*]}" == "${expected_commands[*]}" ]]
}

[[ "${LINKEDSPEC_RUN_ACTIVE:-}" == 1 ]] || fail 'focused proof is not inside a managed run'
[[ -n "${LINKEDSPEC_RUN_DIR:-}" && -d "$LINKEDSPEC_RUN_DIR" ]] || fail 'managed run directory is missing'
repo_device=$(device_id "$REPO_ROOT")
assert_local_real_path "$LINKEDSPEC_RUN_DIR"
assert_local_real_path "$TMPDIR"
assert_local_real_path "$PYTHONPYCACHEPREFIX"

mapfile -t python_temp_owners < <(
 rg -l 'tempfile[.](NamedTemporaryFile|TemporaryDirectory)' "$REPO_ROOT"/tools/*.py |
  sed "s|^$REPO_ROOT/||" | sort
)
expected_python_temp_owners=(
 tools/check_executable_aggregate_selector_sources.py
 tools/check_unicode_case_contract.py
 tools/check_unicode_rule_label_contract.py
)
[[ "${python_temp_owners[*]}" == "${expected_python_temp_owners[*]}" ]] ||
 fail "Python temporary-owner inventory drifted: ${python_temp_owners[*]}"

mapfile -t python_tool_entrypoints < <(
 rg -l '^#!/usr/bin/env python3$' "$REPO_ROOT"/tools/*.py | sed "s|^$REPO_ROOT/||" | sort
)
(( ${#python_tool_entrypoints[@]} == 27 )) ||
 fail "Python tool entrypoint inventory drifted from 27 to ${#python_tool_entrypoints[@]}"

allocator_name='mk''temp'
mapfile -t shell_temp_owners < <(
 rg -l "\\$\\($allocator_name\\b" "$REPO_ROOT"/tools/*.sh "$REPO_ROOT"/knowledge-map/scripts/*.sh |
  sed "s|^$REPO_ROOT/||" | sort
)
expected_shell_temp_owners=(
 knowledge-map/scripts/check_knowledge_map.sh
 tools/check_diagnostic_output_five_backend.sh
 tools/check_duplicate_regex_slot_identity_five_backend.sh
 tools/check_julia_primary_cli.sh
 tools/check_logical_helper_five_backend.sh
 tools/check_mcp_six_runtime.sh
 tools/check_repeated_action_result_five_backend.sh
 tools/check_root_rule_selection_five_backend.sh
 tools/check_rule_local_cursor_five_backend.sh
 tools/check_semantic_introspection_six_runtime.sh
 tools/project_data_run.sh
 tools/run_lua_local.sh
 tools/run_lua_project_data.sh
 tools/run_primary_cli_matrix.sh
)
[[ "${shell_temp_owners[*]}" == "${expected_shell_temp_owners[*]}" ]] ||
 fail "shell temporary-owner inventory drifted: ${shell_temp_owners[*]}"

rg -q 'dir=managed_temp_root[(][)]' "$REPO_ROOT/tools/check_unicode_case_contract.py" ||
 fail 'Unicode case regeneration no longer selects verified managed scratch'
rg -q 'dir=managed_temp_root[(][)]' "$REPO_ROOT/tools/check_unicode_rule_label_contract.py" ||
 fail 'Unicode rule-label regeneration no longer selects verified managed scratch'
[[ "$(rg -c 'TMPDIR[[:space:]]*=>[[:space:]]*1' "$REPO_ROOT/tools/gen_oracle_corpus.pl")" == 2 ]] ||
 fail 'oracle stdout/stderr writers no longer select initialized temporary storage twice'
rg -q 'tools/test_perl_project_data_storage[.]sh' "$REPO_ROOT/tools/run_ci_local.sh" ||
 fail 'the recurring conformance/TAP/oracle storage proof is absent from local CI'

mcp_ci_topology_matches "$REPO_ROOT/tools/run_ci_local.sh" ||
 fail 'MCP materializer/validator canonical topology drifted'

# Cross-filesystem reads below are deliberate and bounded: they prove hostile output roots are rejected without
# creating them. No project data is written to the selected external parent.
external_root=''
for candidate in /private/tmp /tmp "${HOME:-}"; do
 [[ -n "$candidate" && -d "$candidate" ]] || continue
 if [[ "$(device_id "$candidate")" != "$repo_device" ]]; then
  external_root=$candidate
  break
 fi
done
[[ -n "$external_root" ]] || fail 'no readable other-filesystem directory is available for rejection proof'
external_probe="$external_root/linkedspec-tool-storage-rejection-$$"
[[ ! -e "$external_probe" && ! -L "$external_probe" ]] || fail "external rejection probe already exists: $external_probe"

case_root="$LINKEDSPEC_RUN_DIR/tool-project-data"
python_root="$case_root/python"
mkdir -p -- "$case_root"
mcp_omission_mutant="$case_root/mcp-ci-omission.sh"
mcp_generator_omission_mutant="$case_root/mcp-ci-generator-omission.sh"
mcp_rust_generator_omission_mutant="$case_root/mcp-ci-rust-generator-omission.sh"
mcp_dart_generator_omission_mutant="$case_root/mcp-ci-dart-generator-omission.sh"
mcp_julia_generator_omission_mutant="$case_root/mcp-ci-julia-generator-omission.sh"
mcp_lua_generator_omission_mutant="$case_root/mcp-ci-lua-generator-omission.sh"
mcp_admission_omission_mutant="$case_root/mcp-ci-admission-omission.sh"
mcp_order_mutant="$case_root/mcp-ci-order.sh"
awk '$0 != "bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py"' \
 "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_omission_mutant"
if mcp_ci_topology_matches "$mcp_omission_mutant"; then
 fail 'MCP canonical topology accepted a missing materializer'
fi
awk '$0 != "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py"' \
 "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_generator_omission_mutant"
if mcp_ci_topology_matches "$mcp_generator_omission_mutant"; then
 fail 'MCP canonical topology accepted a missing generated Perl binding check'
fi
awk '$0 != "bash tools/run_python_project_data.sh tools/generate_rust_mcp_contract.py"' \
 "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_rust_generator_omission_mutant"
if mcp_ci_topology_matches "$mcp_rust_generator_omission_mutant"; then
 fail 'MCP canonical topology accepted a missing generated Rust binding check'
fi
awk '$0 != "bash tools/run_python_project_data.sh tools/generate_dart_mcp_contract.py"' \
 "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_dart_generator_omission_mutant"
if mcp_ci_topology_matches "$mcp_dart_generator_omission_mutant"; then
 fail 'MCP canonical topology accepted a missing generated Dart binding check'
fi
awk '$0 != "bash tools/run_python_project_data.sh tools/generate_julia_mcp_contract.py"' \
 "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_julia_generator_omission_mutant"
if mcp_ci_topology_matches "$mcp_julia_generator_omission_mutant"; then
 fail 'MCP canonical topology accepted a missing generated Julia binding check'
fi
awk '$0 != "bash tools/run_python_project_data.sh tools/generate_lua_mcp_contract.py"' \
 "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_lua_generator_omission_mutant"
if mcp_ci_topology_matches "$mcp_lua_generator_omission_mutant"; then
 fail 'MCP canonical topology accepted a missing generated Lua binding check'
fi
awk '$0 != "bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py"' \
 "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_admission_omission_mutant"
if mcp_ci_topology_matches "$mcp_admission_omission_mutant"; then
 fail 'MCP canonical topology accepted a missing implementation/admission checker'
fi
awk '
 $0 == "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py" {
  print "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py"
  next
 }
 $0 == "bash tools/run_python_project_data.sh tools/generate_perl_mcp_contract.py" {
  print "bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py"
  next
 }
 { print }
' "$REPO_ROOT/tools/run_ci_local.sh" >"$mcp_order_mutant"
if mcp_ci_topology_matches "$mcp_order_mutant"; then
 fail 'MCP canonical topology accepted binding-check-before-validator order'
fi
env \
 LINKEDSPEC_PROJECT_DATA_ROOT="$python_root" \
 LINKEDSPEC_SCRATCH_ROOT="$external_probe/scratch" \
 LINKEDSPEC_CACHE_ROOT="$external_probe/cache" \
 TMPDIR="$external_probe/tmp" TMP="$external_probe/tmp" TEMP="$external_probe/tmp" \
 PYTHONPYCACHEPREFIX="$external_probe/pycache" \
 bash "$REPO_ROOT/tools/run_python_project_data.sh" tools/check_callable_codeblock_contract.py
assert_local_real_path "$python_root/cache/python-pycache"
find "$python_root/cache/python-pycache" -type f -name '*.pyc' -print -quit | rg -q . ||
 fail 'targeted Python boundary did not retain imported bytecode in repository cache'
[[ ! -e "$external_probe" && ! -L "$external_probe" ]] || fail 'Python boundary created the rejected external root'

for checker in tools/check_unicode_case_contract.py tools/check_unicode_rule_label_contract.py; do
 set +e
 hostile_output=$(env PYTHONDONTWRITEBYTECODE=1 LINKEDSPEC_REPO_ROOT="$REPO_ROOT" \
  TMPDIR="$external_probe/python-temp" python3 "$REPO_ROOT/$checker" 2>&1)
 hostile_status=$?
 set -e
 [[ "$hostile_status" -ne 0 ]] || fail "$checker accepted external temporary storage"
printf '%s\n' "$hostile_output" | rg -q 'outside the repository filesystem' ||
  fail "$checker did not explain its external temporary-storage rejection"
done
[[ ! -e "$external_probe" && ! -L "$external_probe" ]] || fail 'Python checker rejection created external data'

mkdir -p -- "$case_root/symlink-target"
ln -s -- "$case_root/symlink-target" "$case_root/output-link"
for checker in tools/check_unicode_case_contract.py tools/check_unicode_rule_label_contract.py; do
 set +e
 symlink_output=$(env PYTHONDONTWRITEBYTECODE=1 LINKEDSPEC_REPO_ROOT="$REPO_ROOT" \
  TMPDIR="$case_root/output-link/python-temp" python3 "$REPO_ROOT/$checker" 2>&1)
 symlink_status=$?
 set -e
 [[ "$symlink_status" -ne 0 ]] || fail "$checker accepted a symlinked temporary root"
 printf '%s\n' "$symlink_output" | rg -q 'contains a symlink' ||
  fail "$checker did not explain its symlinked temporary-root rejection"
done

valid_map="$case_root/knowledge/KNOWLEDGE_MAP.md"
KM_OUTPUT="$valid_map" bash "$REPO_ROOT/knowledge-map/scripts/gen_knowledge_map.sh" >/dev/null
assert_local_real_path "$valid_map"
set +e
KM_OUTPUT="$case_root/output-link/KNOWLEDGE_MAP.md" \
 bash "$REPO_ROOT/knowledge-map/scripts/gen_knowledge_map.sh" >/dev/null 2>"$case_root/knowledge-symlink.err"
symlink_status=$?
set -e
[[ "$symlink_status" -ne 0 ]] || fail 'Knowledge Map accepted a symlinked output path'
rg -q 'must not contain a symlink' "$case_root/knowledge-symlink.err" ||
 fail 'Knowledge Map did not explain its symlinked output rejection'
set +e
KM_OUTPUT="$external_probe/KNOWLEDGE_MAP.md" \
 bash "$REPO_ROOT/knowledge-map/scripts/gen_knowledge_map.sh" >/dev/null 2>"$case_root/knowledge-hostile.err"
hostile_status=$?
set -e
[[ "$hostile_status" -ne 0 ]] || fail 'Knowledge Map accepted an external output path'
rg -q 'outside the repository filesystem' "$case_root/knowledge-hostile.err" ||
 fail 'Knowledge Map did not explain its external output rejection'
[[ ! -e "$external_probe" && ! -L "$external_probe" ]] || fail 'Knowledge Map rejection created external data'

fake_mdbook="$case_root/bin/mdbook"
mkdir -p -- "$(dirname -- "$fake_mdbook")"
{
 printf '%s\n' '#!/bin/sh'
 printf '%s\n' 'mkdir -p -- "$LINKEDSPEC_MDBOOK_TEST_OUTPUT"'
 printf '%s\n' 'printf "%s\n" rendered >"$LINKEDSPEC_MDBOOK_TEST_OUTPUT/index.html"'
} >"$fake_mdbook"
chmod +x "$fake_mdbook"

valid_book="$case_root/book"
LINKEDSPEC_MDBOOK_CMD="$fake_mdbook" LINKEDSPEC_MDBOOK_TEST_OUTPUT="$valid_book" \
 bash "$REPO_ROOT/tools/run_mdbook_local.sh" --dest-dir "$valid_book" >/dev/null
assert_local_real_path "$valid_book"
assert_local_real_path "$valid_book/index.html"

set +e
LINKEDSPEC_MDBOOK_CMD="$fake_mdbook" LINKEDSPEC_MDBOOK_TEST_OUTPUT="$case_root/should-not-run" \
 bash "$REPO_ROOT/tools/run_mdbook_local.sh" --dest-dir "$case_root/output-link/book" \
 >/dev/null 2>"$case_root/mdbook-symlink.err"
symlink_status=$?
set -e
[[ "$symlink_status" -ne 0 ]] || fail 'mdBook accepted a symlinked destination'
rg -q 'must not contain a symlink' "$case_root/mdbook-symlink.err" ||
 fail 'mdBook did not explain its symlinked destination rejection'
[[ ! -e "$case_root/should-not-run" ]] || fail 'mdBook ran after rejecting the symlinked destination'

set +e
MDBOOK_BUILD__BUILD_DIR="$external_probe/book" LINKEDSPEC_MDBOOK_CMD="$fake_mdbook" \
 LINKEDSPEC_MDBOOK_TEST_OUTPUT="$case_root/should-not-run" \
 bash "$REPO_ROOT/tools/run_mdbook_local.sh" >/dev/null 2>"$case_root/mdbook-hostile.err"
hostile_status=$?
set -e
[[ "$hostile_status" -ne 0 ]] || fail 'mdBook accepted an external configured destination'
rg -q 'outside the repository filesystem' "$case_root/mdbook-hostile.err" ||
 fail 'mdBook did not explain its external destination rejection'
[[ ! -e "$case_root/should-not-run" ]] || fail 'mdBook ran after rejecting the external destination'
[[ ! -e "$external_probe" && ! -L "$external_probe" ]] || fail 'mdBook rejection created external data'

bash "$REPO_ROOT/tools/test_perl_project_data_storage.sh" >/dev/null

tap_test="$case_root/writers/storage.t"
tap_output="$case_root/writers/storage.tap"
mkdir -p -- "$(dirname -- "$tap_test")"
printf '%s\n' 'use Test::More tests => 1; ok(1, "repository-filesystem TAP");' >"$tap_test"
linkedspec_project_data_validate_output_path "$tap_output" 'TAP output'
PERL5LIB= prove "$tap_test" >"$tap_output"
linkedspec_project_data_validate_output_path "$tap_output" 'TAP output'
assert_local_real_path "$tap_output"

[[ ! -e "$external_probe" && ! -L "$external_probe" ]] || fail 'focused proof left external project data'
printf '%s\n' \
 '[tool-project-data-test] PASS: Python, shell, Knowledge Map, mdBook, conformance, TAP, and oracle writers stay on repository storage'
