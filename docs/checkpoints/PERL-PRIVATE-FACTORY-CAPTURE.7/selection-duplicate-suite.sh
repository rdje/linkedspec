set -euo pipefail
log() {
 printf '[ci] %s\n' "$*"
}

fail() {
 printf '[ci] ERROR: %s\n' "$*" >&2
 exit 1
}

require_tracked_file() {
 local path="$1"
 [[ -f "$path" ]] || fail "required file missing: $path"
 git ls-files --error-unmatch -- "$path" >/dev/null 2>&1 || fail "required file is not git-tracked: $path"
}

# PERL-PRIVATE-FACTORY-CAPTURE.7: exact supplied fixture admission.
private_factory_suites=(
 t/actionir_method_input_captures.t
 t/actionir_method_argument_source_frames.t
 t/actionir_empty_expression_spans.t
 t/actionir_ast_input_frames.t
 t/actionir_ast_constructions.t
 t/actionir_ast_parser.t
 t/actionir_source_emissions.t
 t/canonical_event_occurrence_order.t
 t/actionir_nested_block_source_spans.t
 t/actionir_compiler_source_membership.t
 t/actionir_executable_source_membership.t
 t/trace_actionir_method_lowering.t
 t/trace_emit_context_bridge.t
 docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t
 t/actionir_event_input_grants.t
 t/actionir_input_composition_acceptance.t
 t/actionir_factory_capture.t
 t/actionir_emit_context_capture.t
 t/actionir_emit_context_capture_cold.t
 t/actionir_contract_dependency_capture.t
 t/actionir_contract_dependency_capture_cold.t
 t/actionir_contract_factory_capture.t
 t/actionir_contract_factory_capture_cold.t
 t/actionir_method_default_capture.t
 t/actionir_method_default_capture_cold.t
 t/actionir_method_trim_capture.t
 t/actionir_method_trim_capture_cold.t
 t/actionir_method_inference_capture.t
 t/actionir_method_inference_capture_cold.t
 t/actionir_method_inline_capture.t
 t/actionir_method_inline_capture_cold.t
 t/actionir_method_block_component_capture.t
 t/actionir_method_block_component_capture_cold.t
 t/actionir_method_local_return_capture.t
 t/actionir_method_local_return_capture_cold.t
 t/actionir_method_block_value_capture.t
 t/actionir_method_block_value_capture_cold.t
 t/actionir_method_ast_hash_key_capture.t
 t/actionir_method_ast_hash_key_capture_cold.t
 t/actionir_method_ast_call_capture.t
 t/actionir_method_ast_call_capture_cold.t
 t/actionir_method_ast_array_end_capture.t
 t/actionir_method_ast_array_end_capture_cold.t
 t/uniform_binding_contract.t
 t/actionir_method_ast_assignment_capture.t
 t/actionir_method_ast_assignment_capture_cold.t
 t/actionir_method_value_capture.t
 t/actionir_method_value_capture_cold.t
 t/actionir_method_slot_capture.t
 t/actionir_method_slot_capture_cold.t
 t/actionir_method_general_return_capture.t
 t/actionir_method_general_return_capture_cold.t
 t/actionir_method_assignment_required_capture.t
 t/actionir_method_assignment_required_capture_cold.t
 t/actionir_method_set_key_required_capture.t
 t/actionir_method_set_key_required_capture_cold.t
 t/actionir_method_push_required_capture.t
 t/actionir_method_push_required_capture_cold.t
 t/actionir_method_regex_undef_required_capture.t
 t/actionir_method_regex_undef_required_capture_cold.t
 t/actionir_receiver_scalar_copy.t
 t/actionir_array_receiver_required_capture.t
 t/actionir_array_receiver_required_capture.t
 t/actionir_scalar_receiver_required_capture.t
 t/actionir_hash_receiver_required_capture.t
 t/actionir_array_end_required_capture.t
 t/actionir_hash_index_required_capture.t
 t/actionir_package_flow_capture.t
 t/actionir_dropped_trim_capture.t
 t/actionir_small_kind_capture.t
 t/actionir_uniform_target.t
 t/actionir_method_kind_capture.t
 t/actionir_source_assignment_kind_capture.t
 t/actionir_ast_optional_capture.t
 t/actionir_tracking_predicate_capture.t
 t/actionir_formal_trim_capture.t
 t/actionir_named_dispatch_capture.t
 t/actionir_flow_required_capture.t
 t/actionir_flow_kind_capture.t
 t/actionir_flow_default_capture.t
 t/actionir_control_foundation_capture.t
 t/actionir_control_expansion_capture.t
 t/actionir_control_attached_capture.t
 t/actionir_control_single_capture.t
 t/actionir_control_ifwhile_capture.t
 t/actionir_control_switch_capture.t
 t/diagnostic_output_perl_contract.t
 t/actionir_control_output_capture.t
 t/actionir_control_kind_capture.t
 t/actionir_control_calls_capture.t
 t/actionir_control_default_capture.t
 t/actionir_default_object_capture.t
)
private_factory_helpers=(
 t/actionir_array_end_required_cold_probe.pl
 t/actionir_array_end_required_probe.pl
 t/actionir_array_receiver_required_cold_probe.pl
 t/actionir_array_receiver_required_probe.pl
 t/actionir_ast_optional_probe.pl
 t/actionir_ast_optional_stable_probe.pl
 t/actionir_control_attached_native_fixed.pl
 t/actionir_control_calls_native_complete.pl
 t/actionir_control_default_native.pl
 t/actionir_control_expansion_native.pl
 t/actionir_control_foundation_native.pl
 t/actionir_control_ifwhile_native.pl
 t/actionir_control_ifwhile_native_complete.pl
 t/actionir_control_kind_native_complete.pl
 t/actionir_control_output_native.pl
 t/actionir_control_output_native_complete.pl
 t/actionir_control_single_native.pl
 t/actionir_control_switch_native.pl
 t/actionir_default_object_native.pl
 t/actionir_dropped_trim_cold_probe.pl
 t/actionir_dropped_trim_probe.pl
 t/actionir_flow_default_native.pl
 t/actionir_flow_kind_native.pl
 t/actionir_flow_required_native.pl
 t/actionir_formal_trim_probe.pl
 t/actionir_hash_index_required_cold_probe.pl
 t/actionir_hash_index_required_probe.pl
 t/actionir_hash_receiver_required_cold_probe.pl
 t/actionir_hash_receiver_required_probe.pl
 t/actionir_legacy_hash_kind_cold_probe.pl
 t/actionir_legacy_hash_kind_probe.pl
 t/actionir_method_kind_authority_probe.pl
 t/actionir_method_kind_probe.pl
 t/actionir_method_regex_undef_required_probe.pl
 t/actionir_named_dispatch_probe.pl
 t/actionir_package_flow_cold_probe.pl
 t/actionir_package_flow_probe.pl
 t/actionir_receiver_scalar_copy_probe.pl
 t/actionir_scalar_receiver_required_cold_probe.pl
 t/actionir_scalar_receiver_required_probe.pl
 t/actionir_small_kind_probe.pl
 t/actionir_small_kind_reference_probe.pl
 t/actionir_small_kind_symbolic_probe.pl
 t/actionir_source_assignment_kind_probe.pl
 t/actionir_tracking_predicate_probe.pl
 t/actionir_uniform_target_probe.pl
)
log "checking complete private factory fixture inputs and syntax"
for private_factory_input in "${private_factory_suites[@]}" "${private_factory_helpers[@]}"; do
 require_tracked_file "$private_factory_input"
 perl -c -Iperl "$private_factory_input"
done
log "running complete supplied private factory regression population"
LINKEDSPEC_EVENT_ORDER_BASELINE=0 LINKEDSPEC_MEMBERSHIP_BASELINE=0 PERL5LIB= PERL5OPT= prove -Iperl "${private_factory_suites[@]}"
