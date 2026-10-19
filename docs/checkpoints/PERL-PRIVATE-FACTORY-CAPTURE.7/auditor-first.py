"""Reconcile historical objective evidence without claiming fresh runtime execution.

Run with tools/run_python_project_data.sh. Current runtime/test inputs must match
the latest audited milestone. Exact owner-bound CI insertions must reconstruct
the historical bytes; documentation remains revision-bound.
"""

import hashlib
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[2]
PREFIX = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3."
MILESTONES = ("1.2.3", "2.7", "3.5")
RUNTIMES = ("perl", "rust", "dart", "julia", "puc", "luajit")
GOVERNANCE_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2"
COMPOSED_GOVERNANCE_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2"
PUSH_REPAIR_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.1"
NORMALIZATION_CORRECTION_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1"
SIGNATURE_REPAIR_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1"
SIGNATURE_BEFORE = "67af62f7aa6dff39b6c3fd64b15fb5139f691a0a"
SIGNATURE_AFTER = "446fb65fadca2e1bd31fec93bb9de779eb2134d1"
OCCURRENCE_REPAIR_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1"
BOUNDARY_REPAIR_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1"
BOUNDARY_BEFORE = "da5c8d1f66732f0989cecca745557005fe44e7c1"
BOUNDARY_AFTER = "b2156813fffed53622e640583a46a4ca94186a08"
BOUNDARY_RECURRENCE_OWNER = BOUNDARY_REPAIR_OWNER + ".1"
BOUNDARY_RECURRENCE_AFTER = "d52add3e5e070b243eb3a2a532d061b51994a36a"
COMPILER_MEMBERSHIP_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1"
COMPILER_MEMBERSHIP_RECONCILIATION_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.0"
COMPILER_MEMBERSHIP_BEFORE = "31395e440a38acec7a6712d470a90a90a6567863"
COMPILER_MEMBERSHIP_AFTER = "af5d19971a1682f6895901fb769ff41b69842672"
CONTRACT_CAPTURE_BEFORE = "2d878478028fc417ac5b7790c016543c18c1f48b"
CONTRACT_CAPTURE_DEPENDENCIES = "be7d70719856e76b7cb5a427ad6061a7109028ea"
CONTRACT_CAPTURE_AFTER = "33e57deee73e27b97e9c21116bc70942f3f33772"
CONTRACT_CAPTURE_OWNERS = ("PERL-PRIVATE-FACTORY-CAPTURE.2.1.0", "PERL-PRIVATE-FACTORY-CAPTURE.2.1.1")
COMPILER_SCAN_BEFORE = b"    local *LinkedSpec::ActionIR::Scanner::scan_contract_ir_events = sub {\n"
COMPILER_SCAN_AFTER = b"    local *LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events = sub {\n"
BOUNDARY_IMPORT = b"use LinkedSpec::ActionIR::BoundaryLabels ();\n"
BOUNDARY_LOOP_BEFORE = br'''     for my $boundary (split(/\s*,\s*/, $+{boundaries})) {
      if ($boundary =~ /\A(["'])(.*)\1\z/s) {
       $boundary = $2;
       $boundary =~ s/\\(["'\\])/$1/g;
      }
'''
BOUNDARY_LOOP_AFTER = b"     for my $boundary (@{LinkedSpec::ActionIR::BoundaryLabels::_decode_recognized_labels($+{boundaries})}) {\n"
OCCURRENCE_ANCHOR = b"subtest 'actionir_canonical_events_require_avoids_core_load_until_build' => sub {\n"
OCCURRENCE_INSERTION = (
    b"subtest 'actionir_residual_occurrence_order_regression' => sub {\n"
    b"    plan tests => 2;\n"
    b"    my ($exit_code, $out, $err) = run_perl_snippet_in_subprocess(<<'PERL');\n"
    b"my $result = do './t/canonical_event_occurrence_order.t';\n"
    b"die $@ if $@;\n"
    b'die "queue regression did not load: $!" unless defined $result;\n'
    b"PERL\n"
    b"    is($exit_code, 0, 'permanent queue occurrence/ownership regression passes') or diag($err || $out);\n"
    b"    like($out, qr/^1\\.\\.[1-9][0-9]*$/m, 'the complete standalone assertion plan actually ran');\n"
    b"};\n"
)
# Only these reviewed CI insertions and Perl inventory replacements may evolve
# historical executable inputs. Normalization must recover every original byte.
CI_INSERTIONS = (
    (b"require_tracked_file tools/check_typed_source_location_contract.py\n",
     b"require_tracked_file tools/check_language_closure_contract.py\n"
     b"require_tracked_file capability_conformance/language_closure_contract.json\n"),
    (b"perl tools/check_capability_conformance.pl\n\n",
     b'log "checking language closure operation/scope/reference structure"\n'
     b"bash tools/run_python_project_data.sh tools/check_language_closure_contract.py\n\n"),
)
COMPOSED_CI_INSERTIONS = (
    (b"require_tracked_file capability_conformance/language_closure_contract.json\n",
     b"require_tracked_file tools/check_composed_objective_contract.py\n"
     b"require_tracked_file capability_conformance/composed_objective_contract.json\n"
     b"require_tracked_file tests/language-readiness/composed/diagnostic.spec\n"
     b"require_tracked_file tests/language-readiness/composed/normalization.spec\n"
     b"require_tracked_file tests/language-readiness/composed/diagnostic-invalid-arity.spec\n"),
    (b"bash tools/run_python_project_data.sh tools/check_language_closure_contract.py\n\n",
     b'log "checking neutral composed objective fixtures and independent observations"\n'
     b"bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py\n\n"),
)
PUSH_CI_INSERTIONS = (
    (b"require_tracked_file t/phase0_regression.t\n",
     b"require_tracked_file t/codeblock_push_composition_perl.t\n"),
    (b"PERL5LIB= prove -Iperl t/callable_codeblock_literal_contract.t\n",
     b'\nlog "running Perl deferred push composition and caller-identity fixture"\n'
     b"PERL5LIB= prove -Iperl t/codeblock_push_composition_perl.t\n"),
)
NORMALIZATION_CI_INSERTIONS = (
    (b"require_tracked_file tests/language-readiness/composed/normalization.spec\n",
     b"require_tracked_file tests/language-readiness/composed/normalization-calls.spec\n"
     b"require_tracked_file t/composed_normalization_perl.t\n"
     b"require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl\n"),
    (b"PERL5LIB= prove -Iperl t/codeblock_push_composition_perl.t\n",
     b'\nlog "running Perl call-form normalization source and native/fresh object controls"\n'
     b"PERL5LIB= prove -Iperl t/composed_normalization_perl.t\n"),
)
ARTIFACT_RECOVERY_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1"
ARTIFACT_CI_INSERTIONS = (
    (b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl\n',
     b'require_tracked_file tests/language-readiness/recover_objective_audit_inputs.py\n'
     b'require_tracked_file tests/language-readiness/artifacts/objective-audit-inputs.zip\n'
     b'require_tracked_file tests/language-readiness/artifacts/objective-audit-inputs.json\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-census.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-verification.json\n'
     b'require_tracked_file tests/language-readiness/verify_objectives.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-verification.json\n'
     b'require_tracked_file docs/language-readiness/objective-reconciliation.md\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3-verification.json\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7-verification.json\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5-verification.json\n'
    ),
    (b'bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py\n\n',
     b'log "checking isolated historical artifact recovery and read-denied audit"\n'
     b'bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py\n'
     b'\n'
    ),
)

RAW_READINESS_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
RAW_READINESS_CI_INSERTIONS = (
    (b"require_tracked_file t/phase0_regression.t\n",
     b"require_tracked_file perl/LinkedSpec/ActionIR/RawDependencies.pm\n"
     b"require_tracked_file t/actionir_raw_dependency_metadata.t\n"
     b"require_tracked_file t/actionir_raw_dependency_provenance.t\n"
     b"require_tracked_file t/actionir_nested_block_source_spans.t\n"
     b"require_tracked_file t/actionir_raw_dependency_compatibility.t\n"),
    (b"perl -c -Iperl t/actionir_ast_parser.t\n",
     b"perl -c -Iperl perl/LinkedSpec/ActionIR/RawDependencies.pm\n"
     b"perl -c -Iperl t/actionir_raw_dependency_metadata.t\n"
     b"perl -c -Iperl t/actionir_raw_dependency_provenance.t\n"
     b"perl -c -Iperl t/actionir_nested_block_source_spans.t\n"
     b"perl -c -Iperl t/actionir_raw_dependency_compatibility.t\n"),
    (b"prove -Iperl t/actionir_ast_parser.t\n",
     b'\nlog "running source-bound raw dependency readiness and provenance suites"\n'
     b"PERL5LIB= prove -Iperl t/actionir_raw_dependency_metadata.t t/actionir_raw_dependency_provenance.t t/actionir_nested_block_source_spans.t t/actionir_raw_dependency_compatibility.t\n"),
)

SCALAR_RECEIVER_COPY_OWNER = "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0"
SCALAR_RECEIVER_COPY_CI_INSERTIONS = (
    (b"require_tracked_file t/uniform_binding_contract.t\n",
     b"require_tracked_file t/actionir_receiver_scalar_copy.t\n"
     b"require_tracked_file t/actionir_receiver_scalar_copy_probe.pl\n"),
    (b"perl -c -Iperl t/actionir_ast_parser.t\n",
     b"perl -c -Iperl t/actionir_receiver_scalar_copy.t\n"
     b"perl -c -Iperl t/actionir_receiver_scalar_copy_probe.pl\n"),
    (b"prove -Iperl t/actionir_ast_parser.t\n",
     b'\nlog "running scalar receiver-copy regression suite"\n'
     b"prove -Iperl t/actionir_receiver_scalar_copy.t\n"),
)

KNOWLEDGE_HEADER_GATE_OWNER = "PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11"
KNOWLEDGE_HEADER_GATE_CI_INSERTIONS = (
    (b'bash "$REPO_ROOT/scripts/check_doctrines.sh"\n\n',
     b'log "checking Knowledge header list association through the public generator/checker"\n'
     b'require_tracked_file t/knowledge_map_header_lists.t\n'
     b'PERL5LIB= prove t/knowledge_map_header_lists.t\n\n'),
)

PRIVATE_FACTORY_FIXTURE_OWNER = "PERL-PRIVATE-FACTORY-CAPTURE.7"
PRIVATE_FACTORY_FIXTURE_PATHS = (
    't/actionir_method_input_captures.t',
    't/actionir_method_argument_source_frames.t',
    't/actionir_empty_expression_spans.t',
    't/actionir_ast_input_frames.t',
    't/actionir_ast_constructions.t',
    't/actionir_ast_parser.t',
    't/actionir_source_emissions.t',
    't/canonical_event_occurrence_order.t',
    't/actionir_nested_block_source_spans.t',
    't/actionir_compiler_source_membership.t',
    't/actionir_executable_source_membership.t',
    't/trace_actionir_method_lowering.t',
    't/trace_emit_context_bridge.t',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t',
    't/actionir_event_input_grants.t',
    't/actionir_input_composition_acceptance.t',
    't/actionir_factory_capture.t',
    't/actionir_emit_context_capture.t',
    't/actionir_emit_context_capture_cold.t',
    't/actionir_contract_dependency_capture.t',
    't/actionir_contract_dependency_capture_cold.t',
    't/actionir_contract_factory_capture.t',
    't/actionir_contract_factory_capture_cold.t',
    't/actionir_method_default_capture.t',
    't/actionir_method_default_capture_cold.t',
    't/actionir_method_trim_capture.t',
    't/actionir_method_trim_capture_cold.t',
    't/actionir_method_inference_capture.t',
    't/actionir_method_inference_capture_cold.t',
    't/actionir_method_inline_capture.t',
    't/actionir_method_inline_capture_cold.t',
    't/actionir_method_block_component_capture.t',
    't/actionir_method_block_component_capture_cold.t',
    't/actionir_method_local_return_capture.t',
    't/actionir_method_local_return_capture_cold.t',
    't/actionir_method_block_value_capture.t',
    't/actionir_method_block_value_capture_cold.t',
    't/actionir_method_ast_hash_key_capture.t',
    't/actionir_method_ast_hash_key_capture_cold.t',
    't/actionir_method_ast_call_capture.t',
    't/actionir_method_ast_call_capture_cold.t',
    't/actionir_method_ast_array_end_capture.t',
    't/actionir_method_ast_array_end_capture_cold.t',
    't/uniform_binding_contract.t',
    't/actionir_method_ast_assignment_capture.t',
    't/actionir_method_ast_assignment_capture_cold.t',
    't/actionir_method_value_capture.t',
    't/actionir_method_value_capture_cold.t',
    't/actionir_method_slot_capture.t',
    't/actionir_method_slot_capture_cold.t',
    't/actionir_method_general_return_capture.t',
    't/actionir_method_general_return_capture_cold.t',
    't/actionir_method_assignment_required_capture.t',
    't/actionir_method_assignment_required_capture_cold.t',
    't/actionir_method_set_key_required_capture.t',
    't/actionir_method_set_key_required_capture_cold.t',
    't/actionir_method_push_required_capture.t',
    't/actionir_method_push_required_capture_cold.t',
    't/actionir_method_regex_undef_required_capture.t',
    't/actionir_method_regex_undef_required_capture_cold.t',
    't/actionir_receiver_scalar_copy.t',
    't/actionir_array_receiver_required_capture.t',
    't/actionir_scalar_receiver_required_capture.t',
    't/actionir_hash_receiver_required_capture.t',
    't/actionir_array_end_required_capture.t',
    't/actionir_hash_index_required_capture.t',
    't/actionir_package_flow_capture.t',
    't/actionir_dropped_trim_capture.t',
    't/actionir_small_kind_capture.t',
    't/actionir_uniform_target.t',
    't/actionir_method_kind_capture.t',
    't/actionir_source_assignment_kind_capture.t',
    't/actionir_ast_optional_capture.t',
    't/actionir_tracking_predicate_capture.t',
    't/actionir_formal_trim_capture.t',
    't/actionir_named_dispatch_capture.t',
    't/actionir_flow_required_capture.t',
    't/actionir_flow_kind_capture.t',
    't/actionir_flow_default_capture.t',
    't/actionir_control_foundation_capture.t',
    't/actionir_control_expansion_capture.t',
    't/actionir_control_attached_capture.t',
    't/actionir_control_single_capture.t',
    't/actionir_control_ifwhile_capture.t',
    't/actionir_control_switch_capture.t',
    't/diagnostic_output_perl_contract.t',
    't/actionir_control_output_capture.t',
    't/actionir_control_kind_capture.t',
    't/actionir_control_calls_capture.t',
    't/actionir_control_default_capture.t',
    't/actionir_default_object_capture.t',
    't/actionir_array_end_required_cold_probe.pl',
    't/actionir_array_end_required_probe.pl',
    't/actionir_array_receiver_required_cold_probe.pl',
    't/actionir_array_receiver_required_probe.pl',
    't/actionir_ast_optional_probe.pl',
    't/actionir_ast_optional_stable_probe.pl',
    't/actionir_control_attached_native_fixed.pl',
    't/actionir_control_calls_native_complete.pl',
    't/actionir_control_default_native.pl',
    't/actionir_control_expansion_native.pl',
    't/actionir_control_foundation_native.pl',
    't/actionir_control_ifwhile_native.pl',
    't/actionir_control_ifwhile_native_complete.pl',
    't/actionir_control_kind_native_complete.pl',
    't/actionir_control_output_native.pl',
    't/actionir_control_output_native_complete.pl',
    't/actionir_control_single_native.pl',
    't/actionir_control_switch_native.pl',
    't/actionir_default_object_native.pl',
    't/actionir_dropped_trim_cold_probe.pl',
    't/actionir_dropped_trim_probe.pl',
    't/actionir_flow_default_native.pl',
    't/actionir_flow_kind_native.pl',
    't/actionir_flow_required_native.pl',
    't/actionir_formal_trim_probe.pl',
    't/actionir_hash_index_required_cold_probe.pl',
    't/actionir_hash_index_required_probe.pl',
    't/actionir_hash_receiver_required_cold_probe.pl',
    't/actionir_hash_receiver_required_probe.pl',
    't/actionir_legacy_hash_kind_cold_probe.pl',
    't/actionir_legacy_hash_kind_probe.pl',
    't/actionir_method_kind_authority_probe.pl',
    't/actionir_method_kind_probe.pl',
    't/actionir_method_regex_undef_required_probe.pl',
    't/actionir_named_dispatch_probe.pl',
    't/actionir_package_flow_cold_probe.pl',
    't/actionir_package_flow_probe.pl',
    't/actionir_receiver_scalar_copy_probe.pl',
    't/actionir_scalar_receiver_required_cold_probe.pl',
    't/actionir_scalar_receiver_required_probe.pl',
    't/actionir_small_kind_probe.pl',
    't/actionir_small_kind_reference_probe.pl',
    't/actionir_small_kind_symbolic_probe.pl',
    't/actionir_source_assignment_kind_probe.pl',
    't/actionir_tracking_predicate_probe.pl',
    't/actionir_uniform_target_probe.pl',
)
PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS = ((
    b'PERL5LIB= prove -Iperl t/actionir_raw_dependency_metadata.t t/actionir_raw_dependency_provenance.t t/actionir_nested_block_source_spans.t t/actionir_raw_dependency_compatibility.t\n',
    (
        b'\n'
        b'# PERL-PRIVATE-FACTORY-CAPTURE.7: exact supplied fixture admission.\n'
        b'private_factory_suites=(\n'
        b' t/actionir_method_input_captures.t\n'
        b' t/actionir_method_argument_source_frames.t\n'
        b' t/actionir_empty_expression_spans.t\n'
        b' t/actionir_ast_input_frames.t\n'
        b' t/actionir_ast_constructions.t\n'
        b' t/actionir_ast_parser.t\n'
        b' t/actionir_source_emissions.t\n'
        b' t/canonical_event_occurrence_order.t\n'
        b' t/actionir_nested_block_source_spans.t\n'
        b' t/actionir_compiler_source_membership.t\n'
        b' t/actionir_executable_source_membership.t\n'
        b' t/trace_actionir_method_lowering.t\n'
        b' t/trace_emit_context_bridge.t\n'
        b' docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0-origin-fixture.t\n'
        b' t/actionir_event_input_grants.t\n'
        b' t/actionir_input_composition_acceptance.t\n'
        b' t/actionir_factory_capture.t\n'
        b' t/actionir_emit_context_capture.t\n'
        b' t/actionir_emit_context_capture_cold.t\n'
        b' t/actionir_contract_dependency_capture.t\n'
        b' t/actionir_contract_dependency_capture_cold.t\n'
        b' t/actionir_contract_factory_capture.t\n'
        b' t/actionir_contract_factory_capture_cold.t\n'
        b' t/actionir_method_default_capture.t\n'
        b' t/actionir_method_default_capture_cold.t\n'
        b' t/actionir_method_trim_capture.t\n'
        b' t/actionir_method_trim_capture_cold.t\n'
        b' t/actionir_method_inference_capture.t\n'
        b' t/actionir_method_inference_capture_cold.t\n'
        b' t/actionir_method_inline_capture.t\n'
        b' t/actionir_method_inline_capture_cold.t\n'
        b' t/actionir_method_block_component_capture.t\n'
        b' t/actionir_method_block_component_capture_cold.t\n'
        b' t/actionir_method_local_return_capture.t\n'
        b' t/actionir_method_local_return_capture_cold.t\n'
        b' t/actionir_method_block_value_capture.t\n'
        b' t/actionir_method_block_value_capture_cold.t\n'
        b' t/actionir_method_ast_hash_key_capture.t\n'
        b' t/actionir_method_ast_hash_key_capture_cold.t\n'
        b' t/actionir_method_ast_call_capture.t\n'
        b' t/actionir_method_ast_call_capture_cold.t\n'
        b' t/actionir_method_ast_array_end_capture.t\n'
        b' t/actionir_method_ast_array_end_capture_cold.t\n'
        b' t/uniform_binding_contract.t\n'
        b' t/actionir_method_ast_assignment_capture.t\n'
        b' t/actionir_method_ast_assignment_capture_cold.t\n'
        b' t/actionir_method_value_capture.t\n'
        b' t/actionir_method_value_capture_cold.t\n'
        b' t/actionir_method_slot_capture.t\n'
        b' t/actionir_method_slot_capture_cold.t\n'
        b' t/actionir_method_general_return_capture.t\n'
        b' t/actionir_method_general_return_capture_cold.t\n'
        b' t/actionir_method_assignment_required_capture.t\n'
        b' t/actionir_method_assignment_required_capture_cold.t\n'
        b' t/actionir_method_set_key_required_capture.t\n'
        b' t/actionir_method_set_key_required_capture_cold.t\n'
        b' t/actionir_method_push_required_capture.t\n'
        b' t/actionir_method_push_required_capture_cold.t\n'
        b' t/actionir_method_regex_undef_required_capture.t\n'
        b' t/actionir_method_regex_undef_required_capture_cold.t\n'
        b' t/actionir_receiver_scalar_copy.t\n'
        b' t/actionir_array_receiver_required_capture.t\n'
        b' t/actionir_scalar_receiver_required_capture.t\n'
        b' t/actionir_hash_receiver_required_capture.t\n'
        b' t/actionir_array_end_required_capture.t\n'
        b' t/actionir_hash_index_required_capture.t\n'
        b' t/actionir_package_flow_capture.t\n'
        b' t/actionir_dropped_trim_capture.t\n'
        b' t/actionir_small_kind_capture.t\n'
        b' t/actionir_uniform_target.t\n'
        b' t/actionir_method_kind_capture.t\n'
        b' t/actionir_source_assignment_kind_capture.t\n'
        b' t/actionir_ast_optional_capture.t\n'
        b' t/actionir_tracking_predicate_capture.t\n'
        b' t/actionir_formal_trim_capture.t\n'
        b' t/actionir_named_dispatch_capture.t\n'
        b' t/actionir_flow_required_capture.t\n'
        b' t/actionir_flow_kind_capture.t\n'
        b' t/actionir_flow_default_capture.t\n'
        b' t/actionir_control_foundation_capture.t\n'
        b' t/actionir_control_expansion_capture.t\n'
        b' t/actionir_control_attached_capture.t\n'
        b' t/actionir_control_single_capture.t\n'
        b' t/actionir_control_ifwhile_capture.t\n'
        b' t/actionir_control_switch_capture.t\n'
        b' t/diagnostic_output_perl_contract.t\n'
        b' t/actionir_control_output_capture.t\n'
        b' t/actionir_control_kind_capture.t\n'
        b' t/actionir_control_calls_capture.t\n'
        b' t/actionir_control_default_capture.t\n'
        b' t/actionir_default_object_capture.t\n'
        b')\n'
        b'private_factory_helpers=(\n'
        b' t/actionir_array_end_required_cold_probe.pl\n'
        b' t/actionir_array_end_required_probe.pl\n'
        b' t/actionir_array_receiver_required_cold_probe.pl\n'
        b' t/actionir_array_receiver_required_probe.pl\n'
        b' t/actionir_ast_optional_probe.pl\n'
        b' t/actionir_ast_optional_stable_probe.pl\n'
        b' t/actionir_control_attached_native_fixed.pl\n'
        b' t/actionir_control_calls_native_complete.pl\n'
        b' t/actionir_control_default_native.pl\n'
        b' t/actionir_control_expansion_native.pl\n'
        b' t/actionir_control_foundation_native.pl\n'
        b' t/actionir_control_ifwhile_native.pl\n'
        b' t/actionir_control_ifwhile_native_complete.pl\n'
        b' t/actionir_control_kind_native_complete.pl\n'
        b' t/actionir_control_output_native.pl\n'
        b' t/actionir_control_output_native_complete.pl\n'
        b' t/actionir_control_single_native.pl\n'
        b' t/actionir_control_switch_native.pl\n'
        b' t/actionir_default_object_native.pl\n'
        b' t/actionir_dropped_trim_cold_probe.pl\n'
        b' t/actionir_dropped_trim_probe.pl\n'
        b' t/actionir_flow_default_native.pl\n'
        b' t/actionir_flow_kind_native.pl\n'
        b' t/actionir_flow_required_native.pl\n'
        b' t/actionir_formal_trim_probe.pl\n'
        b' t/actionir_hash_index_required_cold_probe.pl\n'
        b' t/actionir_hash_index_required_probe.pl\n'
        b' t/actionir_hash_receiver_required_cold_probe.pl\n'
        b' t/actionir_hash_receiver_required_probe.pl\n'
        b' t/actionir_legacy_hash_kind_cold_probe.pl\n'
        b' t/actionir_legacy_hash_kind_probe.pl\n'
        b' t/actionir_method_kind_authority_probe.pl\n'
        b' t/actionir_method_kind_probe.pl\n'
        b' t/actionir_method_regex_undef_required_probe.pl\n'
        b' t/actionir_named_dispatch_probe.pl\n'
        b' t/actionir_package_flow_cold_probe.pl\n'
        b' t/actionir_package_flow_probe.pl\n'
        b' t/actionir_receiver_scalar_copy_probe.pl\n'
        b' t/actionir_scalar_receiver_required_cold_probe.pl\n'
        b' t/actionir_scalar_receiver_required_probe.pl\n'
        b' t/actionir_small_kind_probe.pl\n'
        b' t/actionir_small_kind_reference_probe.pl\n'
        b' t/actionir_small_kind_symbolic_probe.pl\n'
        b' t/actionir_source_assignment_kind_probe.pl\n'
        b' t/actionir_tracking_predicate_probe.pl\n'
        b' t/actionir_uniform_target_probe.pl\n'
        b')\n'
        b'log "checking complete private factory fixture inputs and syntax"\n'
        b'for private_factory_input in "${private_factory_suites[@]}" "${private_factory_helpers[@]}"; do\n'
        b' require_tracked_file "$private_factory_input"\n'
        b' perl -c -Iperl "$private_factory_input"\n'
        b'done\n'
        b'log "running complete supplied private factory regression population"\n'
        b'LINKEDSPEC_EVENT_ORDER_BASELINE=0 LINKEDSPEC_MEMBERSHIP_BASELINE=0 PERL5LIB= PERL5OPT= prove -Iperl "${private_factory_suites[@]}"\n'
    ),
),)

PERL_STORAGE_REPLACEMENTS = (
    (b"(( ${#perl_temp_owners[@]} == 27 )) ||\n",
     b"(( ${#perl_temp_owners[@]} == 29 )) ||\n"),
    (b' fail "tracked Perl temporary-allocation inventory drifted from 27 to ${#perl_temp_owners[@]}"\n',
     b' fail "tracked Perl temporary-allocation inventory drifted from 29 to ${#perl_temp_owners[@]}"\n'),
    (b"for owner in t/legacy_pathsearch_fallback.t t/nested_tree_readiness.t t/lua_legacy_temp_residue.t; do\n",
     b"for owner in t/legacy_pathsearch_fallback.t t/nested_tree_readiness.t t/lua_legacy_temp_residue.t t/codeblock_push_composition_perl.t t/knowledge_map_header_lists.t; do\n"),
    (b" '[perl-project-data-test] PASS: 27 Perl allocators, traces, and CLI workspaces stay on repository storage'\n",
     b" '[perl-project-data-test] PASS: 29 Perl allocators, traces, and CLI workspaces stay on repository storage'\n"),
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def read_relative(path):
    candidate = Path(path)
    require(not candidate.is_absolute() and ".." not in candidate.parts,
            f"non-repository evidence path: {path}")
    resolved = (ROOT / candidate).resolve()
    resolved.relative_to(ROOT)
    return resolved.read_bytes()


def producing_commit(path):
    commit = git("log", "--diff-filter=A", "-1", "--format=%H", "--", path).decode().strip()
    require(len(commit) == 40, f"missing producing commit: {path}")
    return commit


def verify_governance_evolution(source, contents, historical_hash):
    require(source == "tools/run_ci_local.sh", f"unapproved governance source: {source}")
    normalized = contents
    # Strip the later insertions first: their anchors are earlier owned additions.
    for anchor, insertion in (PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS + KNOWLEDGE_HEADER_GATE_CI_INSERTIONS + SCALAR_RECEIVER_COPY_CI_INSERTIONS + RAW_READINESS_CI_INSERTIONS + ARTIFACT_CI_INSERTIONS + NORMALIZATION_CI_INSERTIONS + PUSH_CI_INSERTIONS
                              + COMPOSED_CI_INSERTIONS + CI_INSERTIONS):
        require(normalized.count(anchor + insertion) == 1,
                f"governance registration mismatch: {source}")
        normalized = normalized.replace(anchor + insertion, anchor, 1)
    require(digest(normalized) == historical_hash,
            f"unreviewed governance drift: {source}")
    return {"path": source, "historical": historical_hash,
            "current": digest(contents), "owner": GOVERNANCE_OWNER,
            "additional_owner": COMPOSED_GOVERNANCE_OWNER,
            "runtime_repair_owner": PUSH_REPAIR_OWNER,
            "source_correction_owner": NORMALIZATION_CORRECTION_OWNER,
            "artifact_recovery_owner": ARTIFACT_RECOVERY_OWNER,
            "raw_readiness_owner": RAW_READINESS_OWNER,
            "scalar_receiver_copy_owner": SCALAR_RECEIVER_COPY_OWNER,
            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,
            "private_factory_fixture_owner": PRIVATE_FACTORY_FIXTURE_OWNER,
            "scope": "exact anchored checker/input registration; original CI bytes preserved"}


def verify_selector_governance_evolution(source, contents, historical_hash):
    require(source == "tools/check_public_aggregate_selector_surface.py",
            f"unapproved selector governance source: {source}")
    before = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 36\n"
    after = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 40\n"
    require(contents.count(after) == 1,
            f"selector governance registration mismatch: {source}")
    normalized = contents.replace(after, before, 1)
    require(digest(normalized) == historical_hash,
            f"unreviewed selector governance drift: {source}")
    return {"path": source, "historical": historical_hash,
            "current": digest(contents), "owner": SCALAR_RECEIVER_COPY_OWNER,
            "scope": "exact public census inverse; every original checker byte preserved"}


def signature_subtest(contents):
    start = b"subtest 'actionir_statement_split_core_requires_newline_or_semicolon_boundaries' => sub {\n"
    following = b"subtest 'actionir_canonical_events_require_avoids_core_load_until_build' => sub {\n"
    require(contents.count(start) == contents.count(following) == 1,
            "signature regression marker mismatch: t/phase0_regression.t")
    first = contents.index(start)
    end = contents.index(following, first)
    return contents[first:end]


def restore_raw_readiness_oracles(contents):
    path = "docs/checkpoints/" + RAW_READINESS_OWNER + "-compatibility-oracles.json"
    table = json.loads(read_relative(path))
    expected = ("emit_context_meta_exposes_language_agnostic_readiness",
                "emit_context_meta_exposes_language_agnostic_blocker_statements",
                "return_descriptor_exposes_action_rewriter_migration_summary",
                "return_descriptor_exposes_action_rewriter_migration_blocker_type_breakdown",
                "method_empty_action_return_with_leading_space_args_stays_balanced")
    require(tuple(row["subtest"] for row in table["subtests"]) == expected
            and sum(len(row["assertions"]) for row in table["subtests"]) == 14,
            "raw-readiness oracle table mismatch: t/phase0_regression.t")
    for row in table["subtests"]:
        marker = ("subtest '" + row["subtest"] + "' => sub {\n").encode()
        require(contents.count(marker) == 1,
                "raw-readiness oracle marker mismatch: t/phase0_regression.t")
        start = contents.index(marker)
        end = contents.find(b"\nsubtest ", start + len(marker))
        require(end >= 0, "raw-readiness oracle boundary mismatch: t/phase0_regression.t")
        block = contents[start:end]
        for pair in row["assertions"]:
            old, new = pair["before"].encode(), pair["after"].encode()
            require(old != new and block.count(new) == 1,
                    "raw-readiness oracle assertion mismatch: t/phase0_regression.t")
            block = block.replace(new, old, 1)
        contents = contents[:start] + block + contents[end:]
    return contents


def boundary_recurrence(contents):
    marker = b"subtest 'quoted_boundary_atoms_survive_nested_value_serialization' => sub {\n"
    anchor = b"subtest 'anonymous_capture_take_until_cursor_helper_reads_and_advances_through_current_parser_position' => sub {\n"
    require(contents.count(marker) == contents.count(anchor) == 1,
            "boundary recurrence marker mismatch: t/phase0_regression.t")
    start = contents.index(marker)
    end = contents.index(anchor, start)
    return contents[start:end]


def restore_boundary_recurrence(source, contents):
    before = git("show", f"{BOUNDARY_AFTER}:{source}")
    after = git("show", f"{BOUNDARY_RECURRENCE_AFTER}:{source}")
    insertion = boundary_recurrence(after)
    require(after.replace(insertion, b"", 1) == before,
            f"unreviewed boundary recurrence history: {source}")
    require(contents.count(insertion) == 1,
            f"boundary recurrence registration mismatch: {source}")
    return contents.replace(insertion, b"", 1)


def restore_compiler_scanner_mock(source, contents):
    before = git("show", f"{COMPILER_MEMBERSHIP_BEFORE}:{source}")
    after = git("show", f"{COMPILER_MEMBERSHIP_AFTER}:{source}")
    require(after.count(COMPILER_SCAN_AFTER) == 1 and
            after.replace(COMPILER_SCAN_AFTER, COMPILER_SCAN_BEFORE, 1) == before,
            f"unreviewed compiler scanner mock history: {source}")
    require(contents.count(COMPILER_SCAN_AFTER) == 1,
            f"compiler scanner mock registration mismatch: {source}")
    return contents.replace(COMPILER_SCAN_AFTER, COMPILER_SCAN_BEFORE, 1)


def verify_signature_regression_evolution(source, contents, historical_hash):
    require(source == "t/phase0_regression.t", f"unapproved signature regression source: {source}")
    before = git("show", f"{SIGNATURE_BEFORE}:{source}")
    after = git("show", f"{SIGNATURE_AFTER}:{source}")
    current_hash = digest(contents)
    contents = restore_compiler_scanner_mock(source, contents)
    contents = restore_boundary_recurrence(source, contents)
    require(contents.count(OCCURRENCE_INSERTION + OCCURRENCE_ANCHOR) == 1,
            f"occurrence regression registration mismatch: {source}")
    prior = restore_raw_readiness_oracles(contents).replace(OCCURRENCE_INSERTION + OCCURRENCE_ANCHOR,
                             OCCURRENCE_ANCHOR, 1)
    require(prior == after, f"unreviewed signature-regression drift: {source}")
    # Replace only the exact owned subtest, including its fixed/dynamic plan change.
    normalized = prior.replace(signature_subtest(after), signature_subtest(before), 1)
    require(normalized == before and digest(normalized) == historical_hash,
            f"unreviewed signature-regression history: {source}")
    return {"path": source, "historical": historical_hash, "current": current_hash,
            "owner": SIGNATURE_REPAIR_OWNER, "reconciliation_owner": NORMALIZATION_CORRECTION_OWNER,
            "occurrence_repair_owner": OCCURRENCE_REPAIR_OWNER,
            "raw_readiness_owner": RAW_READINESS_OWNER,
            "boundary_recurrence_owner": BOUNDARY_RECURRENCE_OWNER,
            "boundary_recurrence_before_revision": BOUNDARY_AFTER,
            "boundary_recurrence_after_revision": BOUNDARY_RECURRENCE_AFTER,
            "compiler_membership_owner": COMPILER_MEMBERSHIP_OWNER,
            "compiler_membership_reconciliation_owner": COMPILER_MEMBERSHIP_RECONCILIATION_OWNER,
            "compiler_membership_before_revision": COMPILER_MEMBERSHIP_BEFORE,
            "compiler_membership_after_revision": COMPILER_MEMBERSHIP_AFTER,
            "before_revision": SIGNATURE_BEFORE, "after_revision": SIGNATURE_AFTER,
            "scope": "exact committed compiler-scanner mock-entry replacement, nested-boundary insertion, fourteen metadata assertion replacements, occurrence regression insertion and committed signature subtest/plan replacement; original Phase0 bytes recovered"}


def verify_perl_storage_evolution(source, contents, historical_hash):
    require(source == "tools/test_perl_project_data_storage.sh",
            f"unapproved Perl storage source: {source}")
    normalized = contents
    for historical, current in PERL_STORAGE_REPLACEMENTS:
        require(normalized.count(current) == 1,
                f"Perl storage registration mismatch: {source}")
        normalized = normalized.replace(current, historical, 1)
    require(digest(normalized) == historical_hash,
            f"unreviewed Perl storage drift: {source}")
    return {"path": source, "historical": historical_hash,
            "current": digest(contents), "owner": PUSH_REPAIR_OWNER,
            "knowledge_header_gate_owner": KNOWLEDGE_HEADER_GATE_OWNER,
            "scope": "exact 27-to-29 census and two allocator memberships; original bytes preserved"}


def restore_contract_factory_capture(source, contents):
    """Admit only the two named committed whole-file factory changes.

    This is historical byte reconciliation, never a fresh runtime assertion.
    Any later or foreign source edit requires its own reviewed inverse.
    """
    before = git("show", f"{CONTRACT_CAPTURE_BEFORE}:{source}")
    dependencies = git("show", f"{CONTRACT_CAPTURE_DEPENDENCIES}:{source}")
    after = git("show", f"{CONTRACT_CAPTURE_AFTER}:{source}")
    require(before == git("show", f"{BOUNDARY_AFTER}:{source}") and
            before == git("show", f"{CONTRACT_CAPTURE_DEPENDENCIES}^1:{source}") and
            dependencies == git("show", f"{CONTRACT_CAPTURE_AFTER}^1:{source}") and
            before != dependencies and dependencies != after,
            f"unreviewed Contracts factory capture history: {source}")
    require(contents == after,
            f"unreviewed Contracts factory capture drift: {source}")
    return before


def verify_boundary_contract_evolution(source, contents, historical_hash):
    require(source == "perl/LinkedSpec/ActionIR/Contracts.pm",
            f"unapproved boundary contract source: {source}")
    current_hash = digest(contents)
    contents = restore_contract_factory_capture(source, contents)
    before = git("show", f"{BOUNDARY_BEFORE}:{source}")
    after = git("show", f"{BOUNDARY_AFTER}:{source}")
    require(digest(before) == historical_hash,
            f"unreviewed boundary contract history: {source}")
    require(contents.count(BOUNDARY_IMPORT) == 1 and
            contents.count(BOUNDARY_LOOP_AFTER) == 1,
            f"boundary contract registration mismatch: {source}")
    normalized = contents.replace(BOUNDARY_IMPORT, b"", 1).replace(
        BOUNDARY_LOOP_AFTER, BOUNDARY_LOOP_BEFORE, 1)
    require(normalized == before and contents == after,
            f"unreviewed boundary contract drift: {source}")
    return {"path": source, "historical": historical_hash, "current": current_hash,
            "owner": BOUNDARY_REPAIR_OWNER,
            "before_revision": BOUNDARY_BEFORE, "after_revision": BOUNDARY_AFTER,
            "factory_capture_owners": list(CONTRACT_CAPTURE_OWNERS),
            "factory_capture_before_revision": CONTRACT_CAPTURE_BEFORE,
            "factory_capture_dependencies_revision": CONTRACT_CAPTURE_DEPENDENCIES,
            "factory_capture_after_revision": CONTRACT_CAPTURE_AFTER,
            "scope": "exact two committed whole-file factory/dependency changes, then decoder import and quoted-boundary loop inverse; original historical bytes recovered; no fresh objective execution"}


def audit_evidence(read=read_relative):
    checkpoints, sources, logs, milestones = {}, {}, {}, {}
    references = 0

    def checkpoint(path, expected=None):
        contents = read(path)
        if expected is not None:
            require(digest(contents) == expected, f"checkpoint digest mismatch: {path}")
        commit = producing_commit(path)
        require(git("show", f"{commit}:{path}") == contents,
                f"checkpoint changed since production: {path}")
        record = json.loads(contents)
        require(record["owner"] + "-verification.json" == Path(path).name,
                f"checkpoint owner mismatch: {path}")
        checkpoints[path] = {"sha256": digest(contents), "producing_commit": commit}
        return record, commit

    for suffix in MILESTONES:
        path = f"docs/checkpoints/{PREFIX}{suffix}-verification.json"
        record, milestone_commit = checkpoint(path)
        milestones[suffix] = record
        if "audit" in record:
            audit = record["audit"]
            children = [(p, row["sha256"]) for p, row in audit["checkpoints"].items()]
            comparisons = []
            for child_path, expected in children:
                child, child_commit = checkpoint(child_path, expected)
                for source, source_hash in child["source_hashes"].items():
                    comparisons.append((source, source_hash, child_commit))
            current_hashes = audit["current_source_hashes"]
            log_hashes = audit["log_hashes"]
        else:
            for row in record["checkpoint_hashes"]:
                checkpoint(row["path"], row["sha256"])
            comparisons = [(row["path"], row["recorded"],
                            checkpoints[row["checkpoint"]]["producing_commit"])
                           for row in record["source_hash_comparisons"]]
            current_hashes = {row["path"]: row["current"]
                              for row in record["source_hash_comparisons"]}
            log_hashes = {row["path"]: row.get("sha256", row.get("recorded"))
                          for row in record["log_hashes"]}
        for source, expected, commit in comparisons:
            require(digest(git("show", f"{commit}:{source}")) == expected,
                    f"historical source mismatch: {source} at {commit}")
            references += 1
        for source, expected in current_hashes.items():
            require(digest(git("show", f"{milestone_commit}:{source}")) == expected,
                    f"milestone source mismatch: {source}")
            sources[source] = {"sha256": expected, "milestone": suffix}
        for log, expected in log_hashes.items():
            require(digest(read(log)) == expected, f"retained log mismatch: {log}")
            if log in logs:
                require(logs[log] == expected, f"conflicting log digest: {log}")
            logs[log] = expected

    documentation_updates, governance_updates = [], []
    for source, row in sources.items():
        current = digest(read(source))
        if current != row["sha256"]:
            if source == "tools/run_ci_local.sh":
                governance_updates.append(verify_governance_evolution(
                    source, read(source), row["sha256"]))
                continue
            if source == "tools/test_perl_project_data_storage.sh":
                governance_updates.append(verify_perl_storage_evolution(
                    source, read(source), row["sha256"]))
                continue
            if source == "t/phase0_regression.t":
                governance_updates.append(verify_signature_regression_evolution(
                    source, read(source), row["sha256"]))
                continue
            if source == "perl/LinkedSpec/ActionIR/Contracts.pm":
                governance_updates.append(verify_boundary_contract_evolution(
                    source, read(source), row["sha256"]))
                continue
            if source == "tools/check_public_aggregate_selector_surface.py":
                governance_updates.append(verify_selector_governance_evolution(
                    source, read(source), row["sha256"]))
                continue
            require(source.startswith("docs/") and source.endswith(".md"),
                    f"current executable evidence drift: {source}")
            documentation_updates.append({"path": source, "historical": row["sha256"],
                                          "current": current, "milestone": row["milestone"]})

    # Read the original independent oracle, rather than deriving expected case
    # counts or coordinates from a runtime checker or this summary's prose.
    corpora = {}
    for stem in ("nested-tree", "context-names", "lossless-segments", "lossless-child"):
        path = f"tests/language-readiness/{stem}/cases.json"
        cases = json.loads(read(path))
        accepts, rejects = cases["accept"], cases.get("reject", [])
        names = [row if isinstance(row, str) else row.get("id", row["input"])
                 for row in accepts + rejects]
        require(len(names) == len(set(names)), f"duplicate authored case: {stem}")
        spans = 0

        def walk(value, text):
            nonlocal spans
            if isinstance(value, list):
                for child in value:
                    walk(child, text)
            elif isinstance(value, dict):
                if "span" in value:
                    span = value["span"]
                    first, last = span if isinstance(span, list) else (span["start"], span["end"])
                    require(type(first) is int and type(last) is int and
                            0 <= first <= last <= len(text), f"invalid scalar span: {stem}")
                    if "text" in value:
                        require(text[first:last] == value["text"], f"wrong scalar slice: {stem}")
                    spans += 1
                for key, child in value.items():
                    if key != "span":
                        walk(child, text)

        for case in accepts:
            walk(case["expected"], case["input"])
            if stem == "lossless-segments":
                cursor = 0
                for segment in case["expected"]:
                    span = segment["span"]
                    first, last = span if isinstance(span, list) else (span["start"], span["end"])
                    require(first == cursor, "lossless segments are not adjacent")
                    cursor = last
                require(cursor == len(case["input"]), "lossless segments omit input")
        corpora[stem] = {"accept": len(accepts), "reject": len(rejects),
                         "authored_spans": spans, "case_names": names,
                         "sha256": digest(read(path))}

    matrices = {}
    for suffix, key in (("1.2.3", "routes"), ("2.7", "typed_routes"), ("3.5", "carrier_pairs")):
        rows = {("puc" if name == "puc_lua" else name): row
                for name, row in milestones[suffix][key].items()}
        require(set(rows) == set(RUNTIMES), f"runtime membership mismatch: {suffix}")
        for row in rows.values():
            routes = row.get("routes", row.get("matched"))
            require(0 < row["retained"] <= routes, f"invalid retained routes: {suffix}")
            if suffix != "3.5":
                rejected = corpora["nested-tree" if suffix == "1.2.3" else "context-names"]["reject"]
                require(row["recoveries"] == row["retained"] * 2 * rejected,
                        f"recovery inflation: {suffix}")
            else:
                require(row["per_call"] == routes - row["retained"], "per-call pair mismatch")
        matrices[suffix] = rows

    return {"checkpoints": checkpoints, "historical_source_references": references,
            "latest_source_inputs": sources, "retained_log_hashes": logs,
            "documentation_updates": documentation_updates,
            "governance_updates": governance_updates, "corpora": corpora,
            "matrices": matrices,
            "limits": "Evidence integrity and independent scalar slicing; runtime execution is historical per-leaf proof. No new capability or objective promotion."}


def falsify(report):
    targets = (next(iter(report["checkpoints"])), next(iter(report["latest_source_inputs"])),
               next(iter(report["retained_log_hashes"])),
               "tests/language-readiness/context-names/cases.json")
    for target in targets:
        def corrupt(path):
            data = read_relative(path)
            return data + b" " if path == target else data
        try:
            audit_evidence(corrupt)
        except ValueError:
            continue
        raise ValueError(f"corruption control did not reject: {target}")
    for target in ("../outside", "/outside"):
        try:
            read_relative(target)
        except ValueError:
            continue
        raise ValueError(f"outside-path control did not reject: {target}")
    governance_controls = 0
    controls_by_source = {}
    for row in report["governance_updates"]:
        source = row["path"]
        current = read_relative(source)
        if source == "tools/run_ci_local.sh":
            altered = (
                current + b"# unreviewed edit\n",
                current.replace(CI_INSERTIONS[0][1], b"", 1),
                current.replace(b"bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py\n", b"", 1),
                current.replace(b"require_tracked_file capability_conformance/composed_objective_contract.json\n",
                                b"", 1),
                current.replace(COMPOSED_CI_INSERTIONS[1][1], b"", 1),
                current.replace(COMPOSED_CI_INSERTIONS[1][1],
                                COMPOSED_CI_INSERTIONS[1][1] * 2, 1),
                current.replace(PUSH_CI_INSERTIONS[0][1], b"", 1),
                current.replace(PUSH_CI_INSERTIONS[1][1], b"", 1),
                current.replace(PUSH_CI_INSERTIONS[1][1], PUSH_CI_INSERTIONS[1][1] * 2, 1),
                current.replace(NORMALIZATION_CI_INSERTIONS[0][1], b"", 1),
                current.replace(NORMALIZATION_CI_INSERTIONS[1][1], b"", 1),
                current.replace(NORMALIZATION_CI_INSERTIONS[1][1],
                                NORMALIZATION_CI_INSERTIONS[1][1] * 2, 1),
                current.replace(ARTIFACT_CI_INSERTIONS[0][1], b"", 1),
                current.replace(ARTIFACT_CI_INSERTIONS[1][1], b"", 1),
                current.replace(ARTIFACT_CI_INSERTIONS[1][1],
                                ARTIFACT_CI_INSERTIONS[1][1] * 2, 1),
                current.replace(RAW_READINESS_CI_INSERTIONS[0][1], b"", 1),
                current.replace(RAW_READINESS_CI_INSERTIONS[1][1], b"", 1),
                current.replace(RAW_READINESS_CI_INSERTIONS[2][1], b"", 1),
                current.replace(RAW_READINESS_CI_INSERTIONS[2][1],
                                RAW_READINESS_CI_INSERTIONS[2][1] * 2, 1),
                current.replace(RAW_READINESS_CI_INSERTIONS[2][1],
                                RAW_READINESS_CI_INSERTIONS[2][1].replace(b"PERL5LIB= prove", b"PERL5LIB= true"), 1),
                current.replace(RAW_READINESS_CI_INSERTIONS[0][1],
                                RAW_READINESS_CI_INSERTIONS[0][1].replace(b"metadata.t", b"missing.t"), 1),
                current.replace(b"require_tracked_file t/actionir_nested_block_source_spans.t\n", b"", 1),
                current.replace(b"perl -c -Iperl t/actionir_nested_block_source_spans.t\n", b"", 1),
                current.replace(b" t/actionir_nested_block_source_spans.t t/actionir_raw_dependency_compatibility.t\n",
                                b" t/actionir_raw_dependency_compatibility.t\n", 1),
                current.replace(b"require_tracked_file t/actionir_raw_dependency_compatibility.t\n", b"", 1),
                current.replace(b"perl -c -Iperl t/actionir_raw_dependency_compatibility.t\n", b"", 1),
                current.replace(b" t/actionir_raw_dependency_compatibility.t\n", b"\n", 1),
            )
            altered += tuple(current.replace(insertion, b"", 1)
                             for _, insertion in SCALAR_RECEIVER_COPY_CI_INSERTIONS)
            altered += tuple(current.replace(insertion, insertion * 2, 1)
                             for _, insertion in SCALAR_RECEIVER_COPY_CI_INSERTIONS)
            altered += (
                current.replace(b"prove -Iperl t/actionir_receiver_scalar_copy.t\n",
                                b"true t/actionir_receiver_scalar_copy.t\n", 1),
                current.replace(b"perl -c -Iperl t/actionir_receiver_scalar_copy.t\n",
                                b"perl -c -Iperl t/other_copy.t\n", 1),
                current.replace(b"require_tracked_file t/actionir_receiver_scalar_copy_probe.pl\n", b"", 1),
                current.replace(b"perl -c -Iperl t/actionir_receiver_scalar_copy_probe.pl\n", b"", 1),
            )
            altered += tuple(current.replace(insertion, b"", 1)
                             for _, insertion in KNOWLEDGE_HEADER_GATE_CI_INSERTIONS)
            altered += tuple(current.replace(insertion, insertion * 2, 1)
                             for _, insertion in KNOWLEDGE_HEADER_GATE_CI_INSERTIONS)
            altered += (
                current.replace(b"PERL5LIB= prove t/knowledge_map_header_lists.t\n",
                                b"PERL5LIB= true t/knowledge_map_header_lists.t\n", 1),
                current.replace(b"require_tracked_file t/knowledge_map_header_lists.t\n",
                                b"require_tracked_file t/other_header_lists.t\n", 1),
                current.replace(b"require_tracked_file t/knowledge_map_header_lists.t\n", b"", 1),
            )
            altered += tuple(current.replace(insertion, b"", 1)
                             for _, insertion in PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS)
            altered += tuple(current.replace(insertion, insertion * 2, 1)
                             for _, insertion in PRIVATE_FACTORY_FIXTURE_CI_INSERTIONS)
            for path in PRIVATE_FACTORY_FIXTURE_PATHS:
                line = b" " + path.encode() + b"\n"
                require(current.count(line) == 1, "private fixture path is not unique")
                altered += (current.replace(line, b"", 1),
                            current.replace(line, line * 2, 1))
            altered += (
                current.replace(b'PERL5OPT= prove -Iperl "${private_factory_suites[@]}"',
                                b'PERL5OPT= true "${private_factory_suites[@]}"', 1),
                current.replace(b' perl -c -Iperl "$private_factory_input"',
                                b' true "$private_factory_input"', 1),
                current.replace(b' require_tracked_file "$private_factory_input"',
                                b' true "$private_factory_input"', 1),
                current.replace(b" t/actionir_default_object_capture.t\n",
                                b" t/other_private_fixture.t\n", 1),
            )
            verify = verify_governance_evolution
            reasons = ("governance registration mismatch:", "unreviewed governance drift:")
        elif source == "tools/test_perl_project_data_storage.sh":
            altered = (current + b"# unreviewed edit\n",) + tuple(
                current.replace(replacement, historical, 1)
                for historical, replacement in PERL_STORAGE_REPLACEMENTS
            ) + (current.replace(PERL_STORAGE_REPLACEMENTS[2][1],
                                 PERL_STORAGE_REPLACEMENTS[2][1] * 2, 1),
                 current.replace(b" t/knowledge_map_header_lists.t; do\n", b"; do\n", 1),
                 current.replace(b" t/knowledge_map_header_lists.t; do\n",
                                 b" t/other_header_lists.t; do\n", 1),
                 current.replace(b"== 29 ))", b"== 28 ))", 1))
            verify = verify_perl_storage_evolution
            reasons = ("Perl storage registration mismatch:", "unreviewed Perl storage drift:")
        elif source == "t/phase0_regression.t":
            before = git("show", f"{SIGNATURE_BEFORE}:{source}")
            # Isolate the original signature controls from the new recurrence.
            owned = signature_subtest(current.replace(OCCURRENCE_INSERTION + OCCURRENCE_ANCHOR,
                                                       OCCURRENCE_ANCHOR, 1))
            altered = (
                current.replace(owned, signature_subtest(before), 1),
                current.replace(owned, owned.replace(b"    done_testing();\n",
                                                    b"    plan tests => 8;\n", 1), 1),
                current + b"# unreviewed edit outside the owned subtest\n",
                current.replace(OCCURRENCE_INSERTION, b"", 1),
                current.replace(OCCURRENCE_INSERTION, OCCURRENCE_INSERTION * 2, 1),
                current.replace(OCCURRENCE_INSERTION,
                                OCCURRENCE_INSERTION.replace(b"    plan tests => 2;\n",
                                                             b"    plan tests => 1;\n"), 1),
            )
            table = json.loads(read_relative("docs/checkpoints/" + RAW_READINESS_OWNER + "-compatibility-oracles.json"))
            altered += tuple(current.replace(row["assertions"][0]["after"].encode(),
                                             row["assertions"][0]["before"].encode(), 1)
                             for row in table["subtests"])
            insertion = boundary_recurrence(current)
            altered += (
                current.replace(insertion, b"", 1),
                current.replace(insertion, insertion * 2, 1),
                current.replace(insertion, insertion.replace(b"my @cases", b"my @other_cases", 1), 1),
                current.replace(insertion, insertion.replace(b"is_deeply", b"ok", 1), 1),
                current.replace(insertion, insertion.replace(b'"a,b,c"', b'"a"', 1), 1),
                current.replace(insertion, insertion.replace(b"runtime_ctx_ref =>", b"other_ctx_ref =>", 1), 1),
                current.replace(COMPILER_SCAN_AFTER, COMPILER_SCAN_BEFORE, 1),
                current.replace(COMPILER_SCAN_AFTER, COMPILER_SCAN_AFTER * 2, 1),
                current.replace(COMPILER_SCAN_AFTER, COMPILER_SCAN_AFTER.replace(b"sub {", b"sub { return;"), 1),
                current.replace(COMPILER_SCAN_AFTER, COMPILER_SCAN_AFTER.replace(b"_scan_executable_contract_ir_events", b"_other_scan"), 1),
            )
            verify = verify_signature_regression_evolution
            reasons = ("raw-readiness oracle assertion mismatch:", "occurrence regression registration mismatch:", "unreviewed signature-regression drift:",
                       "unreviewed signature-regression history:", "signature regression marker mismatch:",
                       "boundary recurrence registration mismatch:", "compiler scanner mock registration mismatch:")
        elif source == "perl/LinkedSpec/ActionIR/Contracts.pm":
            altered = (
                current + b"# unreviewed boundary contract edit\n",
                current.replace(BOUNDARY_IMPORT, b"", 1),
                current.replace(BOUNDARY_IMPORT, BOUNDARY_IMPORT * 2, 1),
                current.replace(BOUNDARY_LOOP_AFTER, BOUNDARY_LOOP_BEFORE, 1),
                current.replace(BOUNDARY_LOOP_AFTER, BOUNDARY_LOOP_AFTER * 2, 1),
                current.replace(BOUNDARY_LOOP_AFTER,
                                BOUNDARY_LOOP_AFTER.replace(b"_decode_recognized_labels", b"_other_decoder"), 1),
            )
            altered += (
                current.replace(b"return _bind_emission_dependency($cb)", b"return $cb", 1),
                current.replace(b"return _register_native_contracts([", b"return [", 1),
                current.replace(b"sub _register_native_contracts {", b"sub _other_native_contracts {", 1),
                current.replace(b"SourceEmissions::_invoke_emission_dependency($callback", b"SourceEmissions::_invoke_other_dependency($callback", 1),
            )
            verify = verify_boundary_contract_evolution
            reasons = ("boundary contract registration mismatch:", "unreviewed boundary contract drift:",
                       "unreviewed Contracts factory capture drift:")
        elif source == "tools/check_public_aggregate_selector_surface.py":
            line = b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 40\n"
            altered = (
                current + b"# unreviewed edit\n",
                current.replace(line, b"", 1),
                current.replace(line, line * 2, 1),
                current.replace(line, b"EXPECTED_CLASSIFIED_REFERENCE_COUNT = 39\n", 1),
                current.replace(b"reference_count = check_exact_references(paths)", b"reference_count = 0", 1),
                current.replace(b"EXPECTED_PUBLIC_FILE_COUNT = 70", b"EXPECTED_PUBLIC_FILE_COUNT = 69", 1),
            )
            verify = verify_selector_governance_evolution
            reasons = ("selector governance registration mismatch:", "unreviewed selector governance drift:")
        else:
            raise ValueError(f"unapproved governance control source: {source}")
        require(all(candidate != current for candidate in altered),
                f"governance controls must change actual bytes: {source}")
        controls_by_source[source] = 0
        for contents in altered:
            try:
                verify(source, contents, row["historical"])
            except ValueError as error:
                require(str(error).startswith(reasons),
                        "unrelated error substituted for governance rejection")
                governance_controls += 1
                controls_by_source[source] += 1
            else:
                raise ValueError("governance corruption control did not reject")
    return {"corrupted_inputs_rejected": list(targets), "outside_paths_rejected": 2,
            "governance_mutations_rejected": governance_controls,
            "governance_mutations_by_source": controls_by_source}


def verify_summary(report, text):
    labels = dict(zip(RUNTIMES, ("Perl", "Rust", "Dart", "Julia", "PUC Lua", "LuaJIT")))
    for runtime in RUNTIMES:
        nesting = report["matrices"]["1.2.3"][runtime]
        context = report["matrices"]["2.7"][runtime]
        child = report["matrices"]["3.5"][runtime]
        require(nesting["routes"] == context["routes"] and
                nesting["retained"] == context["retained"], "combined route table loses a distinction")
        row = (f"| {labels[runtime]} | {nesting['routes']} | {nesting['retained']} | "
               f"{nesting['recoveries']} / {context['recoveries']} | {child['matched']} | "
               f"{child['retained']} | {child['per_call']} |")
        require(text.splitlines().count(row) == 1, f"summary route mismatch: {runtime}")


if __name__ == "__main__":
    result = audit_evidence()
    result["controls"] = falsify(result)
    summary = read_relative("docs/language-readiness/objective-reconciliation.md").decode()
    verify_summary(result, summary)
    try:
        verify_summary(result, summary.replace("| 28 / 68 |", "| 29 / 68 |", 1))
    except ValueError:
        result["controls"]["summary_recovery_inflation_rejected"] = True
    else:
        raise ValueError("summary recovery inflation control did not reject")
    print(json.dumps(result, indent=2, sort_keys=True))
