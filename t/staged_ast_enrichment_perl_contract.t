#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec ();
use LinkedSpec::StagedParserRegistry ();

sub slurp_json {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $document = <$fh>;
 close $fh or die "cannot close $path: $!";
 return JSON::PP->new->decode($document)
}

sub ids {
 my ($rows) = @_;
 return [map { $_->{id} } @$rows]
}

sub occurrences {
 my ($text, $needle) = @_;
 my $count = 0;
 my $offset = 0;
 while (($offset = index($text, $needle, $offset)) >= 0) {
  ++$count;
  $offset += length($needle);
 }
 return $count
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'staged_ast_enrichment_contract.json',
);
my $contract = slurp_json($contract_path);

is(
 $contract->{contract_id},
 'linkedspec-staged-ast-enrichment-v1',
 'loads the frozen general staged-AST enrichment contract',
);
is($contract->{format}, 1, 'loads contract format 1');
is(
 $contract->{status},
 'neutral_complete_backends_pending',
 'keeps backend behavior pending behind complete neutral authority',
);
is(
 $contract->{task_owner},
 'FUTURE-PARITY-BACKLOG.14.7.2',
 'keeps the backend-neutral contract under its ratification owner',
);

is_deeply(
 {
  callee => $contract->{authored_surface}{callee},
  node_kind => $contract->{authored_surface}{node_kind},
  sidecar_kind => $contract->{authored_surface}{sidecar_kind},
  effect => $contract->{authored_surface}{effect},
  required_options => $contract->{authored_surface}{required_options},
  optional_options => $contract->{authored_surface}{optional_options},
 },
 {
  callee => 'parse_job',
  node_kind => 'STAGED_PARSE_JOB_MARKER',
  sidecar_kind => 'staged_parse_job_v2',
  effect => 'staged_parse_job_declaration',
  required_options => [qw(node_kind payload_kind spec result_policy on_error)],
  optional_options => [qw(top into required_capabilities)],
 },
 'freezes the dedicated inert marker, sidecar, effect, and authored options',
);
is_deeply(
 [map { $_->{resolved_spec_id} } @{$contract->{resolution_snapshot}{entries}}],
 [qw(registry:expr-v2 registry:json-v1 registry:xml-v1 registry:yaml-v1)],
 'freezes all four pre-resolved and already-compiled registry identities',
);
is_deeply(
 [map { $_->{source_id} } @{$contract->{sources}}],
 [qw(unicode ascii)],
 'freezes both decoded source authorities',
);

my @case_groups = (
 [provenance_cases => [qw(
  direct_unicode direct_empty derived_ordered direct_reversed direct_out_of_bounds
  derived_empty derived_segment_invalid copied_text_smuggling
 )]],
 [job_id_cases => [qw(direct_identity derived_identity default_top_normalized_before_identity)]],
 [resolution_cases => [qw(
  alias_first declaring_relative_second search_root_order provider_order missing
  same_priority_ambiguous alias_relative_collision path_traversal_rejected
 )]],
 [authority_cases => [qw(
  intersection_and_minima entry_cannot_elevate_caller required_capability_missing
  policy_denied source_detail_denied helper_version_mismatch
 )]],
 [cache_cases => [qw(
  base identical content_changed graph_changed top_changed spec_version_changed
  helper_version_changed staged_version_changed capability_order_normalized capability_set_changed
 )]],
 [queue_cases => [qw(
  parent_then_provenance job_id_tie_break derived_order_key breadth_first_recursive_enqueue
 )]],
 [isolation_cases => [qw(
  siblings_receive_fresh_runtime_contexts falsey_child_state_does_not_escape shared_budget_spans_next_depth
 )]],
 [stitch_cases => [qw(replace_marker replace_field sibling_field append_child)]],
 [failure_cases => [qw(fail_aborts_composed_parse keep_text_continues diagnostic_node_uses_result_target)]],
 [chain_cases => [qw(
  direct_strictly_smaller derived_strictly_smaller exact_tuple_cycle same_extent_non_decreasing
  derived_not_contained depth_exceeded call_limit_exceeded cancelled deadline_exceeded budget_exhausted
 )]],
 [detachment_cases => [qw(plain_nested falsey_scalar live_parser_handle reference_cycle_marker node_limit)]],
);
for my $group (@case_groups) {
 my ($field, $expected) = @$group;
 is_deeply(ids($contract->{$field}), $expected, "freezes the complete $field inventory");
}

is_deeply(
 $contract->{result_policies},
 [qw(replace_marker replace_field sibling_field append_child)],
 'freezes all four result policies',
);
is_deeply(
 $contract->{failure_policies},
 [qw(fail keep_text diagnostic_node)],
 'freezes all three failure policies',
);
is_deeply(
 $contract->{compatibility_v1},
 {
  status => 'current_unchanged',
  record_version => 1,
  parser_spec_id => 'actionir-body.spec',
  resolved_spec_id => 'builtin:actionir-body.spec',
  top_rule => 'action_block',
  result_policy => 'replace_field',
  result_field => 'body_ast',
  failure_policy => 'fail',
  source_provenance => 'legacy copied exact text plus numeric offset and line span',
  general_authoring => JSON::PP::false,
  upgrade_to_v2 => 'explicit_only',
 },
 'freezes the explicit unchanged function-body v1 compatibility adapter',
);
is_deeply(
 $contract->{expected_counts},
 {
  registry_entries => 4,
  sources => 2,
  provenance_cases => 8,
  job_id_cases => 3,
  resolution_cases => 8,
  authority_cases => 6,
  cache_cases => 10,
  queue_cases => 4,
  isolation_cases => 3,
  stitch_cases => 4,
  failure_cases => 3,
  chain_cases => 10,
  detachment_cases => 5,
  carrier_requirements => 4,
  backend_consumers => 5,
  runtime_routes => 6,
  outward_guard_paths => 10,
  diagnostics => 37,
  rollout_legs => 9,
  ownership_rows => 35,
  mutations => 72,
 },
 'freezes every neutral inventory count',
);
is(scalar(@{$contract->{diagnostics}}), 37, 'freezes all thirty-seven diagnostic contracts');
is_deeply(
 [map { $_->{status} } @{$contract->{backend_consumers}}],
 ['dormant_red', ('pending_absent') x 4],
 'activates only the exact Perl consumer as a dormant RED',
);
is_deeply(
 $contract->{backend_consumers}[0],
 {
  backend => 'perl',
  owner => 'FUTURE-PARITY-BACKLOG.14.7.3.0',
  path => 't/staged_ast_enrichment_perl_contract.t',
  status => 'dormant_red',
 },
 'binds the dormant Perl consumer to its exact path and leaf owner',
);
is_deeply(
 [map { $_->{status} } @{$contract->{rollout}}],
 ['complete', ('pending') x 8],
 'keeps only neutral rollout complete',
);
is_deeply(
 [map { $_->{responsibility} } grep {
  $_->{owner} =~ /\AFUTURE-PARITY-BACKLOG[.]14[.]7[.]3(?:\z|[.])/
 } @{$contract->{ownership}}],
 [qw(
  perl_parent perl_dormant_red perl_annotation_and_provenance
  perl_resolution_cache_and_policies perl_recursive_queue_bounds_diagnostics
  perl_carriers_and_admission
 )],
 'freezes the disjoint Perl parent and child ownership sequence',
);

my $v1_job = {
 kind => 'parse_job',
 version => 1,
 job_id => 'parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:10-26',
 parent_ast_path => ['functions', '0', 'body_source'],
 node_kind => 'function_definition',
 payload_kind => 'function_body',
 text => 'return(trim(value))',
 source_span => {start => 10, end => 26, line_start => 1, line_end => 1},
 parser_spec_id => 'actionir-body.spec',
 top_rule => 'action_block',
 result_policy => 'replace_field',
 result_field => 'body_ast',
 failure_policy => 'fail',
 diagnostic_owner => 'function_body',
};
my $v1_results = eval { LinkedSpec::StagedParserRegistry::execute_parse_jobs([$v1_job]) };
my $v1_error = $@;
ok(!$v1_error && ref($v1_results) eq 'ARRAY', 'the committed v1 registry still executes one function-body job')
 or diag($v1_error);
my $v1_result = ref($v1_results) eq 'ARRAY' && @$v1_results ? $v1_results->[0] : {};
is_deeply($v1_result->{phases}, [qw(resolve load compile execute)], 'v1 preserves its four deterministic phases');
is($v1_result->{resolved_spec_id}, 'builtin:actionir-body.spec', 'v1 preserves its built-in resolved identity');
is($v1_result->{payload_kind}, 'function_body', 'v1 preserves its payload kind');
is_deeply($v1_result->{source_span}, $v1_job->{source_span}, 'v1 preserves its legacy numeric source span');
is($v1_result->{result_policy}, 'replace_field', 'v1 preserves replace_field');
is($v1_result->{result_field}, 'body_ast', 'v1 preserves the body_ast target');
is($v1_result->{failure_policy}, 'fail', 'v1 preserves fail-fast behavior');
is($v1_result->{result}{kind}, 'action_block', 'v1 executes the action-block adapter');
is($v1_result->{result}{statements}[0]{expr}{name}, 'return', 'v1 parses the body return expression');

my $wrong_top_job = {%$v1_job, top_rule => 'missing_top'};
my $wrong_top_ok = eval { LinkedSpec::StagedParserRegistry::execute_parse_jobs([$wrong_top_job]); 1 };
my $wrong_top_error = $@;
ok(!$wrong_top_ok, 'v1 still rejects an unsupported top rule during compile');
for my $field (
 [phase => 'compile'],
 [job_id => $v1_job->{job_id}],
 [parent_ast_path => 'functions.0.body_source'],
 [parser_spec_id => 'actionir-body.spec'],
 [resolved_spec_id => 'builtin:actionir-body.spec'],
 [top_rule => 'missing_top'],
 [payload_kind => 'function_body'],
 [source_span => '10-26'],
 [failure_policy => 'fail'],
) {
 my ($name, $value) = @$field;
 like($wrong_top_error, qr/\Q$name=$value\E/, "v1 compile diagnostic preserves $name");
}

my $function_source = <<'SPEC';
fn normalize(value) { return(trim(value)) }
Top::
 /x/
 I { return(normalize(" x ")) }
SPEC
my %function_ctx;
my $function_descriptor = LinkedSpec::Get(
 \$function_source,
 return_descriptor => 1,
 runtime_ctx_ref => \%function_ctx,
);
ok(ref($function_descriptor) eq 'HASH', 'the committed function-body path still builds a descriptor')
 or diag(JSON::PP->new->canonical(1)->encode($function_ctx{last_error} // {}));
my $function = ref($function_descriptor) eq 'HASH'
 ? $function_descriptor->{functions}{normalize}
 : {};
is($function->{body_parse_job}{version}, 1, 'the function-body sidecar remains version 1');
is($function->{body_parse_job}{parser_spec_id}, 'actionir-body.spec', 'the function sidecar keeps v1 parser identity');
is($function->{body_parse_job}{result_policy}, 'replace_field', 'the function sidecar keeps v1 stitch policy');
is($function->{body_parse_job}{result_field}, 'body_ast', 'the function sidecar keeps the v1 target');
is($function->{body_parse_job}{failure_policy}, 'fail', 'the function sidecar keeps v1 failure policy');
is($function->{body_ast}{kind}, 'action_block', 'the function registry still stitches the parsed body AST');
ok(!exists($function->{staged_parse_job_v2}), 'v1 is not silently upgraded to a v2 sidecar');

my $annotation_options = 'hash("node_kind", "expression", "payload_kind", "embedded_expression", '
 .'"spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", '
 .'"into", "expression_ast", "on_error", "fail")';
my $annotation_call = 'parse_job(entry_group(0), ' . $annotation_options . ')';
my $annotation_statement = 'job_marker = ' . $annotation_call;
my $lowered = LinkedSpec::call_spec_handler_subst('Top', $annotation_statement);
is(occurrences($lowered, 'parse_job'), 1, 'current lowering retains one logical parse_job marker');
is(
 occurrences($lowered, 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:parse_job'),
 1,
 'current lowering emits exactly one parse_job unsupported-helper sentinel',
);

my $general_job = {
 %$v1_job,
 version => 2,
 job_id => 'parse_job:v2:sha256:dormant-red',
 node_kind => 'expression',
 payload_kind => 'embedded_expression',
 text => '1+2',
 parser_spec_id => 'expr-v1',
 top_rule => 'Expr',
 result_policy => 'sibling_field',
 result_field => 'expression_ast',
};
my $general_registry_ok = eval {
 LinkedSpec::StagedParserRegistry::execute_parse_job($general_job);
 1
};
my $general_registry_error = $@;
ok(!$general_registry_ok, 'the v1 function-body adapter grants no accidental general parser authority');
like(
 $general_registry_error,
 qr/phase=resolve;.*parser_spec_id=expr-v1;.*unsupported parser spec id 'expr-v1'/,
 'the v1 adapter rejects general identity at resolve without loading a path',
);

my $authored_source = <<"SPEC";
Top::
 /([^;]+);/
 I {
  $annotation_statement
  return(job_marker)
 }
SPEC
my %descriptor_ctx;
my $descriptor = LinkedSpec::Get(
 \$authored_source,
 return_descriptor => 1,
 generated_source_identity => 'staged-ast-enrichment-perl-red.spec',
 runtime_ctx_ref => \%descriptor_ctx,
);
ok(ref($descriptor) eq 'HASH', 'the exact future annotation reaches descriptor construction')
 or diag(JSON::PP->new->canonical(1)->encode($descriptor_ctx{last_error} // {}));

my $rewriter = ref($descriptor) eq 'HASH'
 ? $descriptor->{spec}{Top}{meta}{action_rewriter}
 : {};
my @marker_events = grep {
 ($_->{kind} // '') eq 'STAGED_PARSE_JOB_MARKER'
} @{$rewriter->{canonical_action_ir_events} // []};
my @unresolved_helpers = @{$rewriter->{unresolved_helpers} // []};
my $raw_dependency_count = $rewriter->{raw_perl_dependency_count} // 0;
my $annotation_ready =
 @marker_events == 1
 && !@unresolved_helpers
 && !$raw_dependency_count
 && ($rewriter->{language_agnostic_action_ir_ready} // 0);

ok(
 $annotation_ready,
 'Perl lowers parse_job to one dedicated inert marker with no unresolved or raw dependency',
);
diag(
 'expected RED: missing node=[STAGED_PARSE_JOB_MARKER]'
 . '; unresolved helpers=[' . join(',', @unresolved_helpers) . ']'
 . "; raw dependencies=$raw_dependency_count",
) unless $annotation_ready;

done_testing();
