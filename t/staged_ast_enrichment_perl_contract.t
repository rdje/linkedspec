#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Scalar::Util qw(refaddr);
use Test::More;

use LinkedSpec ();
use LinkedSpec::ActionIR::StagedParseJob ();
use LinkedSpec::SourceLocation ();
use LinkedSpec::StagedASTEnrichment ();
use LinkedSpec::StagedParseJob ();
use LinkedSpec::StagedParserRegistry ();

my $JSON = JSON::PP->new->canonical(1)->allow_nonref(1);

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

sub forbidden_key_hits {
 my ($value, $forbidden, $path) = @_;
 $path = '$' unless defined($path);
 my @hits;
 if (ref($value) eq 'HASH') {
  for my $key (sort keys %$value) {
   push @hits, "$path.$key" if $forbidden->{$key};
   push @hits, forbidden_key_hits($value->{$key}, $forbidden, "$path.$key");
  }
 } elsif (ref($value) eq 'ARRAY') {
  for my $index (0 .. $#$value) {
   push @hits, forbidden_key_hits($value->[$index], $forbidden, "$path\[$index\]");
  }
 }
 return @hits
}

sub clone_plain {
 my ($value) = @_;
 return JSON::PP->new->decode($JSON->encode($value))
}

sub capture_enrichment_error {
 my ($code, $callback, $label) = @_;
 my $ok = eval { $callback->(); 1 };
 my $error = $@;
 ok(!$ok, "$label rejects");
 ok(
  LinkedSpec::StagedASTEnrichment::is_error($error),
  "$label returns the private staged-enrichment error",
 );
 is($error->{code}, $code, "$label uses $code")
  if LinkedSpec::StagedASTEnrichment::is_error($error);
 return $error
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'staged_ast_enrichment_contract.json',
);
my $contract = slurp_json($contract_path);

sub build_enrichment_authority {
 my (%args) = @_;
 my $snapshot = clone_plain($contract->{resolution_snapshot});
 my $executor = $args{executor} // sub {
  my ($request) = @_;
  return {
   kind => 'parsed',
   text => $request->{text},
  }
 };
 for my $entry (@{$snapshot->{entries}}) {
  my $resolved_spec_id = $entry->{resolved_spec_id};
  $entry->{compiled_authority} = sub {
   return $executor->($_[0], $resolved_spec_id)
  };
 }
 my $authority = LinkedSpec::StagedASTEnrichment->new(snapshot => $snapshot);
 return wantarray ? ($authority, $snapshot) : $authority
}

sub make_inert_marker {
 my (%args) = @_;
 my $text = defined($args{text}) ? "$args{text}" : 'abc';
 my %options = (
  node_kind => $args{node_kind} // 'expression',
  payload_kind => $args{payload_kind} // 'embedded_expression',
  spec => $args{spec} // 'expr',
  result_policy => $args{result_policy} // 'replace_marker',
  on_error => $args{on_error} // 'fail',
  required_capabilities => clone_plain(
   $args{required_capabilities} // [qw(staged-parse-job-v2 typed-source-location-v1)],
  ),
 );
 $options{top} = $args{top} if exists $args{top};
 $options{into} = $args{into} if exists $args{into};
 my $input = $text;
 my $entry_info = {
  match_span => {start => 0, end => length($text)},
  match_spans => [{start => 0, end => length($text)}],
 };
 return LinkedSpec::StagedParseJob::construct_marker(
  \$input,
  $entry_info,
  undef,
  $args{origin} // 'contract:parse_job',
  $JSON->encode({
   text_plan => {kind => 'direct_span', source => 'entry_text'},
   options => \%options,
  }),
 )
}

sub enrichment_args {
 return (
  declaring_spec_id => 'grammar/main.spec',
  caller_capabilities => [qw(
   caller-only staged-parse-job-v2 structured-result-v1
   typed-source-location-v1 xml-v1 yaml-v1
  )],
  caller_policy_modes => [qw(
   append_child diagnostic_node fail keep_text replace_field replace_marker
   sibling_field trace
  )],
  caller_ceilings => {
   source_detail => 'text',
   max_steps => 500,
   max_result_nodes => 256,
   max_diagnostic_bytes => 8192,
  },
  required_source_detail => 'span',
  required_versions => {
   spec_language_version => 2,
   helper_contract_version => 'actionir-v3',
   staged_contract_version => 2,
  },
 )
}

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
is(
 occurrences($lowered, 'LinkedSpec::StagedParseJob::construct_marker'),
 1,
 'private lowering constructs exactly one inert staged marker',
);
is(
 occurrences($lowered, 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:parse_job'),
 0,
 'the exact annotation no longer emits an unsupported-helper sentinel',
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

is_deeply(
 {
  target => $marker_events[0]{args}{target},
  text_plan => $marker_events[0]{args}{text_plan},
  options => $marker_events[0]{args}{options},
 },
 {
  target => 'job_marker',
  text_plan => {
   kind => 'direct_span',
   source => 'entry_group',
   index => 0,
  },
  options => {
   node_kind => 'expression',
   payload_kind => 'embedded_expression',
   spec => 'expr-v1',
   top => 'Expr',
   result_policy => 'sibling_field',
   into => 'expression_ast',
   on_error => 'fail',
   required_capabilities => [],
  },
 },
 'the dedicated node preserves only one typed text plan and normalized literal options',
);
ok(
 !grep({
  ($_->{kind} // '') eq 'ASSIGN'
   && (($_->{args}{target} // '') eq 'job_marker')
 } @{$rewriter->{canonical_action_ir_events} // []}),
 'the exclusive parse-job annotation is not duplicated as a generic assignment',
);

my %decoded_sources = map {
 ($_->{source_id} => $_->{text})
} @{$contract->{sources}};
my $source_authority = LinkedSpec::SourceLocation->new(
 sources => \%decoded_sources,
);
subtest 'all neutral provenance cases use the existing typed source algebra' => sub {
 for my $case (@{$contract->{provenance_cases}}) {
  my $result;
  my $ok = eval {
   $result = LinkedSpec::StagedParseJob::validate_and_materialize_provenance(
    $source_authority,
    $case->{provenance},
    origin => 'contract:parse_job',
   );
   1
  };
  if ($case->{accepted}) {
   ok($ok, "$case->{id} accepts typed provenance") or diag($@);
   is($result->{text}, $case->{materialized_text}, "$case->{id} materializes exact text");
   is_deeply($result->{provenance}, $case->{provenance}, "$case->{id} preserves exact provenance");
  } else {
   ok(!$ok, "$case->{id} rejects invalid provenance");
   ok(
    LinkedSpec::StagedParseJob::is_error($@),
    "$case->{id} returns the private typed staged error",
   );
   is($@->{code}, $case->{diagnostic}, "$case->{id} uses the neutral diagnostic code");
   is($@->{phase}, 'declare', "$case->{id} fails during inert declaration");
  }
 }
};

my $direct_source = <<'SPEC';
Top::
 /(é🙂)(B);/ -> Top { job_marker = parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr", "result_policy", "sibling_field", "into", "expression_ast", "on_error", "fail")); return(job_marker) }
SPEC
my %direct_ctx;
my $direct_parser = LinkedSpec::Get(
 \$direct_source,
 generated_source_identity => 'staged-ast-enrichment-perl-direct.spec',
 runtime_ctx_ref => \%direct_ctx,
);
ok(ref($direct_parser) eq 'CODE', 'the private direct-provenance carrier compiles')
 or diag(JSON::PP->new->canonical(1)->encode($direct_ctx{last_error} // {}));
my $direct_input = 'Aé🙂B;C';
my $direct_marker = ref($direct_parser) eq 'CODE'
 ? $direct_parser->(\$direct_input)
 : undef;
ok(LinkedSpec::StagedParseJob::is_marker($direct_marker), 'direct authored text returns one opaque marker');
is_deeply(
 LinkedSpec::StagedParseJob::marker_record($direct_marker),
 {
  kind => 'STAGED_PARSE_JOB_MARKER',
  version => 2,
  sidecar_kind => 'staged_parse_job_v2',
  effect => 'staged_parse_job_declaration',
 },
 'the marker exposes only its neutral logical identity',
);
my $direct_sidecar = LinkedSpec::StagedParseJob::sidecar_record($direct_marker);
is_deeply(
 $direct_sidecar,
 {
  kind => 'staged_parse_job_v2',
  version => 2,
  state => 'declared',
  effect => 'staged_parse_job_declaration',
  node_kind => 'expression',
  payload_kind => 'embedded_expression',
  parser_spec_id => 'expr-v1',
  top_rule => 'Expr',
  result_policy => 'sibling_field',
  into => 'expression_ast',
  failure_policy => 'fail',
  required_capabilities => [],
  text => 'é🙂',
  provenance => {
   kind => 'direct_span',
   source_id => 'input',
   start => 1,
   end => 3,
   provenance => 'match_group',
  },
  origin => 'Top:parse_job',
 },
 'the private sidecar carries exact materialized text and one Unicode-scalar direct span',
);
$direct_sidecar->{provenance}{start} = 99;
is(
 LinkedSpec::StagedParseJob::sidecar_record($direct_marker)->{provenance}{start},
 1,
 'sidecar snapshots cannot mutate opaque marker state',
);

my $derived_options = 'hash("node_kind", "expression", "payload_kind", "embedded_expression", '
 .'"spec", "expr-v1", "result_policy", "replace_marker", "on_error", "keep_text", '
 .'"required_capabilities", array("typed-source-location-v1", "actionir-v1"))';
my $derived_source = 'Top::' . "\n"
 .' /(a)(a);/ -> Top { job_marker = parse_job(cat(match_group(0), match_group(1)), '
 .$derived_options . '); return(job_marker) }' . "\n";
my %derived_ctx;
my $derived_parser = LinkedSpec::Get(
 \$derived_source,
 generated_source_identity => 'staged-ast-enrichment-perl-derived.spec',
 runtime_ctx_ref => \%derived_ctx,
);
ok(ref($derived_parser) eq 'CODE', 'the private ordered-derived carrier compiles')
 or diag(JSON::PP->new->canonical(1)->encode($derived_ctx{last_error} // {}));
my $derived_input = 'aa;';
my $derived_marker = ref($derived_parser) eq 'CODE'
 ? $derived_parser->(\$derived_input)
 : undef;
ok(LinkedSpec::StagedParseJob::is_marker($derived_marker), 'composed authored text returns one opaque marker');
my $derived_sidecar = LinkedSpec::StagedParseJob::sidecar_record($derived_marker);
is($derived_sidecar->{text}, 'aa', 'ordered-derived text materializes in authored order');
is_deeply(
 $derived_sidecar->{provenance},
 {
  kind => 'derived_text',
  policy => 'concatenate_in_order',
  segments => [
   {kind => 'direct_span', source_id => 'input', start => 0, end => 1, provenance => 'match_group'},
   {kind => 'direct_span', source_id => 'input', start => 1, end => 2, provenance => 'match_group'},
  ],
 },
 'identical copied capture text retains two distinct ordered source spans',
);
is_deeply(
 $derived_sidecar->{required_capabilities},
 [qw(actionir-v1 typed-source-location-v1)],
 'literal capability options normalize deterministically before scheduling',
);
my %forbidden_sidecar_key = map { ($_ => 1) } qw(
 path spec_path source_authority match match_object parser registry compiled_authority
 callback host_handle cancellation_token deadline mutable_queue
);
is_deeply(
 [forbidden_key_hits($derived_sidecar, \%forbidden_sidecar_key)],
 [],
 'marker and sidecar serialize no source, parser, path, callback, or scheduler authority',
);

my @static_rejections = (
 {
  id => 'dynamic options',
  call => 'parse_job(match_group(0), options)',
  code => 'staged_parse_job_options_required',
 },
 {
  id => 'unknown option',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail", "loader", "ambient"))',
  code => 'staged_parse_job_option_unknown',
 },
 {
  id => 'missing required option',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker"))',
  code => 'staged_parse_job_options_required',
 },
 {
  id => 'dynamic node kind',
  call => 'parse_job(match_group(0), hash("node_kind", node_kind, "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail"))',
  code => 'staged_parse_job_options_required',
 },
 {
  id => 'path-like parser identity',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "../expr", "result_policy", "replace_marker", "on_error", "fail"))',
  code => 'staged_parser_identity_invalid',
 },
 {
  id => 'invalid top rule',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "top", "Expr/Bad", "result_policy", "replace_marker", "on_error", "fail"))',
  code => 'staged_top_rule_invalid',
 },
 {
  id => 'invalid result policy',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace", "on_error", "fail"))',
  code => 'staged_result_policy_invalid',
 },
 {
  id => 'invalid failure policy',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "retry"))',
  code => 'staged_failure_policy_invalid',
 },
 {
  id => 'replace marker with target',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "into", "wrong", "on_error", "fail"))',
  code => 'staged_result_target_invalid',
 },
 {
  id => 'sibling without target',
  call => 'parse_job(match_group(0), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "sibling_field", "on_error", "fail"))',
  code => 'staged_result_target_invalid',
 },
 {
  id => 'transformed copied text',
  call => 'parse_job(trim(match_group(0)), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail"))',
  code => 'staged_source_provenance_invalid',
 },
 {
  id => 'literal copied text',
  call => 'parse_job("copied", hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail"))',
  code => 'staged_source_provenance_invalid',
 },
 {
  id => 'dynamic capture index',
  call => 'parse_job(match_group(index), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail"))',
  code => 'staged_source_provenance_invalid',
 },
);
for my $case (@static_rejections) {
 my $source = "Top::\n /(x);/ -> Top { job_marker = $case->{call}; return(job_marker) }\n";
 my %ctx;
 my $bad_descriptor = LinkedSpec::Get(
  \$source,
  return_descriptor => 1,
  runtime_ctx_ref => \%ctx,
 );
 ok(!defined($bad_descriptor), "$case->{id} rejects before authored execution");
 is($ctx{last_error}{stage}, 'staged_parse_job_policy', "$case->{id} uses the static annotation policy");
 is($ctx{last_error}{code}, $case->{code}, "$case->{id} uses its neutral diagnostic code");
}

my $generic_return_source = "Top::\n /(x);/ -> Top { return($annotation_call) }\n";
my $generic_return_descriptor = LinkedSpec::Get(
 \$generic_return_source,
 return_descriptor => 1,
);
my $generic_return_rewriter = $generic_return_descriptor->{spec}{Top}{meta}{action_rewriter};
ok(
 !grep({ ($_->{kind} // '') eq 'STAGED_PARSE_JOB_MARKER' }
  @{$generic_return_rewriter->{canonical_action_ir_events} // []}),
 'a non-annotation parse_job call cannot acquire the dedicated node',
);
is_deeply(
 $generic_return_rewriter->{unresolved_helpers},
 ['parse_job'],
 'a residual generic parse_job call remains fail-closed as an unresolved helper',
);

my $transaction_source = <<'SPEC';
Top::
 I {
  token = recognition_checkpoint()
  matched = recognize_once(token, call(Child))
  if(matched)
   value = recognition_commit(token)
  else()
   recognition_rollback(token)
  endif()
  return(value)
 }
 /never/
Child:
 I { marker = parse_job(entry_text(), hash("node_kind", "expression", "payload_kind", "embedded_expression", "spec", "expr-v1", "result_policy", "replace_marker", "on_error", "fail")); return(marker) }
 /never/
SPEC
my %transaction_ctx;
my $transaction_descriptor = LinkedSpec::Get(
 \$transaction_source,
 return_descriptor => 1,
 runtime_ctx_ref => \%transaction_ctx,
);
ok(!defined($transaction_descriptor), 'uncommitted recognition rejects inert staged declaration statically');
is($transaction_ctx{last_error}{stage}, 'recognition_transaction_policy', 'transaction rejection uses the recognition policy');
is($transaction_ctx{last_error}{code}, 'recognition_effect_forbidden', 'transaction rejection stays fail-closed');
is($transaction_ctx{last_error}{effect}, 'parser_registry_or_staged_dispatch', 'the dedicated marker has the staged-dispatch effect');

ok(
 LinkedSpec::StagedASTEnrichment->can('enrich_ast'),
 'Perl exposes one private post-AST current-depth enrichment seam',
);

subtest 'pre-registered resolution is pure, prioritized, and diagnostic-exact' => sub {
 my $authority = build_enrichment_authority();
 for my $case (@{$contract->{resolution_cases}}) {
  my ($resolved, $error);
  my $ok = eval {
   $resolved = $authority->resolve_pre_registered(
    declaring_spec_id => $case->{declaring_spec_id},
    parser_spec_id => $case->{parser_spec_id},
    job_id => 'parse_job:v2:resolution-contract',
   );
   1
  };
  if (defined($case->{diagnostic})) {
   ok(!$ok, "$case->{id} rejects during pure frozen selection");
   ok(
    LinkedSpec::StagedASTEnrichment::is_error($@),
    "$case->{id} returns a typed resolution diagnostic",
   );
   is($@->{code}, $case->{diagnostic}, "$case->{id} preserves the neutral diagnostic code")
    if LinkedSpec::StagedASTEnrichment::is_error($@);
   is($@->{phase}, 'resolve', "$case->{id} stays in the pure resolve phase")
    if LinkedSpec::StagedASTEnrichment::is_error($@);
  } else {
   ok($ok, "$case->{id} resolves from the frozen snapshot") or diag($@);
   is($resolved, $case->{resolved_spec_id}, "$case->{id} selects the exact normalized identity");
  }
 }
};

subtest 'caller and entry authority intersect and every ceiling narrows' => sub {
 my $authority = build_enrichment_authority();
 for my $case (@{$contract->{authority_cases}}) {
  my ($effective, $error);
  my $ok = eval {
   $effective = $authority->effective_authority(
    entry_id => $case->{entry_id},
    job_id => 'parse_job:v2:authority-contract',
    top_rule => $case->{top_rule},
    caller_capabilities => clone_plain($case->{caller_capabilities}),
    required_capabilities => clone_plain($case->{required_capabilities}),
    caller_policy_modes => clone_plain($case->{caller_policy_modes}),
    required_policy_modes => clone_plain($case->{required_policy_modes}),
    caller_ceilings => clone_plain($case->{caller_ceilings}),
    required_source_detail => $case->{required_source_detail},
    required_versions => clone_plain($case->{required_versions}),
   );
   1
  };
  if ($case->{accepted}) {
   ok($ok, "$case->{id} accepts strictly narrowed authority") or diag($@);
   is_deeply($effective, $case->{effective}, "$case->{id} computes exact intersections and minima");
  } else {
   ok(!$ok, "$case->{id} rejects authority elevation");
   ok(
    LinkedSpec::StagedASTEnrichment::is_error($@),
    "$case->{id} returns a typed authority diagnostic",
   );
   is($@->{code}, $case->{diagnostic}, "$case->{id} preserves the neutral diagnostic code")
   if LinkedSpec::StagedASTEnrichment::is_error($@);
  }
 }
 capture_enrichment_error(
  'staged_top_rule_forbidden',
  sub {
   $authority->effective_authority(
    entry_id => 'registry:expr-v2',
    job_id => 'parse_job:v2:wrong-top',
    top_rule => 'MissingTop',
    caller_capabilities => [qw(staged-parse-job-v2 typed-source-location-v1)],
    required_capabilities => [qw(typed-source-location-v1)],
    caller_policy_modes => [qw(fail replace_marker)],
    required_policy_modes => [qw(fail)],
    caller_ceilings => {
     source_detail => 'span',
     max_steps => 100,
     max_result_nodes => 64,
     max_diagnostic_bytes => 4096,
    },
    required_source_detail => 'identity',
    required_versions => {
     spec_language_version => 2,
     helper_contract_version => 'actionir-v3',
     staged_contract_version => 2,
    },
   )
  },
  'entry-forbidden top rule',
 );
};

subtest 'v2 job identity and immutable cache identity are exact' => sub {
 for my $case (@{$contract->{job_id_cases}}) {
  my $fields = clone_plain($case);
  delete @{$fields}{qw(id expected_job_id)};
  is(
   LinkedSpec::StagedASTEnrichment->job_identity($fields),
   $case->{expected_job_id},
   "$case->{id} matches the cross-backend canonical job digest",
  );
 }
 my $base;
 for my $case (@{$contract->{cache_cases}}) {
  my $identity = LinkedSpec::StagedASTEnrichment->cache_identity(
   clone_plain($case->{fields}),
  );
  $base = $identity if $case->{id} eq 'base';
  is(
   $identity eq $base ? 1 : 0,
   $case->{same_as_base} ? 1 : 0,
   "$case->{id} preserves exact cache hit/invalidation identity",
  );
 }
 my $invalid_cache = clone_plain($contract->{cache_cases}[0]{fields});
 $invalid_cache->{content_digest} = 'sha256:not-a-digest';
 my $cache_error = capture_enrichment_error(
  'staged_cache_identity_invalid',
  sub { LinkedSpec::StagedASTEnrichment->cache_identity($invalid_cache) },
  'malformed cache content digest',
 );
 is($cache_error->{cache_component}, 'content_digest', 'cache diagnostics name the exact invalid component');
};

subtest 'registry seeds freeze callbacks and grant no mutation or implicit load' => sub {
 my @observed_requests;
 my ($authority, $seed) = build_enrichment_authority(
  executor => sub {
   my ($request) = @_;
   push @observed_requests, $request;
   return {kind => 'frozen_callback'};
  },
 );
 $seed->{aliases}[0]{resolved_spec_id} = 'registry:yaml-v1';
 $seed->{entries}[0]{compiled_authority} = sub { return {kind => 'mutated_callback'} };
 is(
  $authority->resolve_pre_registered(
   declaring_spec_id => 'grammar/main.spec',
   parser_spec_id => 'expr',
   job_id => 'parse_job:v2:frozen-seed',
  ),
  'registry:expr-v2',
  'caller mutation of candidate seed rows cannot alter frozen resolution',
 );
 capture_enrichment_error(
  'staged_registry_mutation_forbidden',
  sub { $authority->register(parser_spec_id => 'later-v1') },
  'post-construction registry mutation',
 );
 capture_enrichment_error(
  'staged_implicit_load_forbidden',
  sub { $authority->load(parser_spec_id => 'expr') },
  'dispatch-time path/provider loading',
 );

 my $marker = make_inert_marker(result_policy => 'replace_marker');
 my $output = $authority->enrich_ast(
  {payload => $marker},
  enrichment_args(),
 );
 is($output->{ast}{payload}{kind}, 'frozen_callback', 'execution retains the already-compiled frozen callback');
 is(scalar(@observed_requests), 1, 'exactly one callback executes for one current-depth marker');
 my %forbidden_request_key = map { ($_ => 1) } qw(
  path spec_path source_authority match match_object parser registry
  compiled_authority provider filesystem environment network loader compiler
  cancellation deadline mutable_queue
 );
 is_deeply(
  [forbidden_key_hits($observed_requests[0], \%forbidden_request_key)],
  [],
  'the child request carries no registry, callback, loader, path, or ambient authority',
 );
 is_deeply(
  $observed_requests[0]{runtime_context},
  {cursor => 0, marks => {}, captures => {}, variables => {}},
  'the child begins with a fresh isolated parser runtime context',
 );

 my $invalid_snapshot = clone_plain($contract->{resolution_snapshot});
 my $invalid_ok = eval {
  LinkedSpec::StagedASTEnrichment->new(snapshot => $invalid_snapshot);
  1
 };
 ok(!$invalid_ok, 'opaque strings cannot impersonate already-compiled callback authority');
 like($@, qr/already-compiled callback/, 'invalid registry construction fails at the caller-preparation boundary');
};

subtest 'all four result policies stitch detached child data' => sub {
 for my $case (@{$contract->{stitch_cases}}) {
  my $child_result = clone_plain($case->{result});
  my $authority = build_enrichment_authority(
   executor => sub { return $child_result },
  );
  my %marker_args = (
   text => $case->{text},
   result_policy => $case->{result_policy},
   on_error => 'fail',
  );
  $marker_args{into} = $case->{into} if defined($case->{into});
  my $marker = make_inert_marker(%marker_args);
  my $input = clone_plain($case->{parent});
  $input->{$case->{marker_field}} = $marker;
  my $output = $authority->enrich_ast($input, enrichment_args());
  is_deeply(
   $output->{ast},
   $case->{expected_parent},
   "$case->{id} applies the exact neutral stitch operation",
  );
  ok(
   LinkedSpec::StagedParseJob::is_marker($input->{$case->{marker_field}}),
   "$case->{id} does not mutate the caller's parent AST",
  );
  is($output->{sidecars}[0]{state}, 'succeeded', "$case->{id} settles its scheduler sidecar");
  like(
   $output->{sidecars}[0]{job_id},
   qr/\Aparse_job:v2:sha256:[0-9a-f]{64}\z/,
   "$case->{id} receives a deterministic v2 job id",
  );
  is($output->{sidecars}[0]{top_rule}, 'Expr', "$case->{id} normalizes the default top before identity");
  $child_result->{kind} = 'mutated_after_return';
  my $stitched_result = $case->{result_policy} eq 'replace_marker'
   ? $output->{ast}{$case->{marker_field}}
   : $case->{result_policy} eq 'append_child'
    ? $output->{ast}{$case->{into}}[0]
    : $output->{ast}{$case->{into}};
  isnt(
   $stitched_result->{kind},
   'mutated_after_return',
   "$case->{id} retains no mutable child aggregate",
  );
 }
};

subtest 'all three failure policies are atomic and retain portable diagnostics' => sub {
 for my $case (@{$contract->{failure_cases}}) {
  my $authority = build_enrichment_authority(
   executor => sub { die {code => 'child_syntax'} },
  );
  my %marker_args = (
   text => $case->{text},
   result_policy => $case->{result_policy},
   on_error => $case->{failure_policy},
  );
  $marker_args{into} = $case->{into} if defined($case->{into});
  my $marker = make_inert_marker(%marker_args);
  my $input = clone_plain($case->{parent});
  $input->{$case->{marker_field}} = $marker;
  if ($case->{failure_policy} eq 'fail') {
   my $error = capture_enrichment_error(
    'staged_child_failed',
    sub { $authority->enrich_ast($input, enrichment_args()) },
    $case->{id},
   );
   is($error->{phase}, 'execute', "$case->{id} aborts in execute");
   is($error->{child_diagnostic}{code}, 'child_syntax', "$case->{id} preserves the child diagnostic");
   ok(
    LinkedSpec::StagedParseJob::is_marker($input->{$case->{marker_field}}),
    "$case->{id} publishes no partial parent AST",
   );
   next
  }
  my $output = $authority->enrich_ast($input, enrichment_args());
  is($output->{ast}{$case->{marker_field}}, $case->{text}, "$case->{id} materializes original exact text");
  is(scalar(@{$output->{diagnostics}}), 1, "$case->{id} retains one scheduler diagnostic");
  is($output->{diagnostics}[0]{code}, 'staged_child_failed', "$case->{id} keeps the portable failure code");
  is_deeply(
   $output->{sidecars}[0]{diagnostic},
   $output->{diagnostics}[0],
   "$case->{id} retains the same detached sidecar diagnostic",
  );
  if ($case->{failure_policy} eq 'keep_text') {
   is_deeply($output->{ast}{$case->{into}}, [], "$case->{id} leaves the result target unchanged");
   is($output->{sidecars}[0]{state}, 'failed_keep_text', "$case->{id} records continued text state");
  } else {
   is($output->{ast}{$case->{into}}{kind}, 'staged_parse_diagnostic', "$case->{id} stitches one diagnostic node");
   is(
    $output->{ast}{$case->{into}}{diagnostic}{code},
    'staged_child_failed',
    "$case->{id} uses the selected result target for its diagnostic",
   );
   is($output->{sidecars}[0]{state}, 'failed_diagnostic_node', "$case->{id} records continued diagnostic state");
  }
 }
};

subtest 'current-depth order, sibling isolation, and cache hit behavior are deterministic' => sub {
 my @requests;
 my $authority = build_enrichment_authority(
  executor => sub {
   my ($request) = @_;
   push @requests, {
    path => clone_plain($request->{parent_ast_path}),
    context_address => refaddr($request->{runtime_context}),
    initial_context => clone_plain($request->{runtime_context}),
   };
   $request->{runtime_context}{cursor} = 99;
   return {kind => 'parsed', text => $request->{text}};
  },
 );
 my @nodes = map { ({kind => 'plain', index => $_}) } 0 .. 10;
 $nodes[10] = make_inert_marker(text => 'ten', result_policy => 'replace_marker');
 $nodes[2] = make_inert_marker(text => 'two', result_policy => 'replace_marker');
 my $output = $authority->enrich_ast({nodes => \@nodes}, enrichment_args());
 is_deeply(
  [map { $_->{path} } @requests],
  [['nodes', 2], ['nodes', 10]],
  'numeric typed path order places index 2 before index 10',
 );
 isnt($requests[0]{context_address}, $requests[1]{context_address}, 'siblings receive distinct runtime contexts');
 is_deeply(
  [map { $_->{initial_context} } @requests],
  [map { +{cursor => 0, marks => {}, captures => {}, variables => {}} } 1 .. 2],
  'one sibling cannot leak cursor, mark, capture, or variable state to another',
 );
 is($output->{ast}{nodes}[2]{text}, 'two', 'first ordered child result stitches at its exact path');
 is($output->{ast}{nodes}[10]{text}, 'ten', 'second ordered child result stitches at its exact path');
 is_deeply(
  {map { ($_ => $output->{cache}{$_}) } qw(entries hits misses)},
  {entries => 1, hits => 1, misses => 1},
  'two jobs with one immutable execution identity produce one miss then one hit',
 );

 my $third = make_inert_marker(text => 'again', result_policy => 'replace_marker');
 my $third_output = $authority->enrich_ast({payload => $third}, enrichment_args());
 is($third_output->{ast}{payload}{text}, 'again', 'a cache hit still executes the callback on fresh text');
 is(scalar(@requests), 3, 'the cache stores no child result');
 is($third_output->{cache}{hits}, 2, 'the later invocation records a second plan hit');

 my $isolated = build_enrichment_authority();
 is_deeply(
  {map { ($_ => $isolated->cache_stats->{$_}) } qw(entries hits misses)},
  {entries => 0, hits => 0, misses => 0},
  'a separately prepared registry owns an isolated empty cache',
 );
};

subtest 'failed child executions never poison cache results' => sub {
 my $calls = 0;
 my $authority = build_enrichment_authority(
  executor => sub {
   ++$calls;
   die {code => 'transient_child_failure'} if $calls == 1;
   return {kind => 'retry_success'};
  },
 );
 my $failed = make_inert_marker(
  text => 'same-cache-key',
  result_policy => 'replace_marker',
  on_error => 'keep_text',
 );
 my $failed_output = $authority->enrich_ast({payload => $failed}, enrichment_args());
 is($failed_output->{ast}{payload}, 'same-cache-key', 'the first failed execution keeps exact text');
 my $retry = make_inert_marker(
  text => 'same-cache-key',
  result_policy => 'replace_marker',
  on_error => 'keep_text',
 );
 my $retry_output = $authority->enrich_ast({payload => $retry}, enrichment_args());
 is($retry_output->{ast}{payload}{kind}, 'retry_success', 'a cache hit retries rather than replaying failure state');
 is($calls, 2, 'failed and successful jobs both invoke fresh child execution');
 is_deeply(
  {map { ($_ => $retry_output->{cache}{$_}) } qw(entries hits misses)},
  {entries => 1, hits => 1, misses => 1},
  'only the immutable execution plan is cached across failure and retry',
 );
};

subtest 'detachment contract rejects live, cyclic, and over-limit results' => sub {
 for my $case (@{$contract->{detachment_cases}}) {
  my $returned = clone_plain($case->{value});
  my $authority = build_enrichment_authority(
   executor => sub { return $returned },
  );
  my $marker = make_inert_marker(result_policy => 'replace_marker', on_error => 'fail');
  my %args = enrichment_args();
  $args{caller_ceilings}{max_result_nodes} = $case->{max_nodes};
  if ($case->{accepted}) {
   my $output = $authority->enrich_ast({payload => $marker}, %args);
   is_deeply($output->{ast}{payload}, $case->{value}, "$case->{id} accepts exact detached plain data");
   if (ref($returned) eq 'HASH') {
    $returned->{kind} = 'mutated';
    isnt($output->{ast}{payload}{kind}, 'mutated', "$case->{id} does not retain a child aggregate");
   }
  } else {
   capture_enrichment_error(
    $case->{diagnostic},
    sub { $authority->enrich_ast({payload => $marker}, %args) },
    $case->{id},
   );
  }
 }

 my $cycle = {};
 $cycle->{self} = $cycle;
 my $cycle_authority = build_enrichment_authority(executor => sub { return $cycle });
 capture_enrichment_error(
  'staged_result_not_detached',
  sub {
   $cycle_authority->enrich_ast(
    {payload => make_inert_marker(result_policy => 'replace_marker')},
    enrichment_args(),
   )
  },
  'actual cyclic child aggregate',
 );

 my $live_token = bless {}, 'StagedASTEnrichmentTest::LiveToken';
 my $live_authority = build_enrichment_authority(executor => sub { return $live_token });
 capture_enrichment_error(
  'staged_result_not_detached',
  sub {
   $live_authority->enrich_ast(
    {payload => make_inert_marker(result_policy => 'replace_marker')},
    enrichment_args(),
   )
  },
  'blessed live child token',
 );
};

subtest 'marker and result-target diagnostics fail before unsafe publication' => sub {
 my @cases = (
  {
   id => 'missing replace target',
   code => 'staged_stitch_target_missing',
   marker => {result_policy => 'replace_field', into => 'ast'},
   parent => sub { return {payload => $_[0]} },
  },
  {
   id => 'sibling collision',
   code => 'staged_stitch_target_collision',
   marker => {result_policy => 'sibling_field', into => 'ast'},
   parent => sub { return {payload => $_[0], ast => {kind => 'existing'}} },
  },
  {
   id => 'append target wrong kind',
   code => 'staged_append_target_invalid',
   marker => {result_policy => 'append_child', into => 'children'},
   parent => sub { return {payload => $_[0], children => {}} },
  },
 );
 for my $case (@cases) {
  my $calls = 0;
  my $authority = build_enrichment_authority(executor => sub { ++$calls; return {kind => 'parsed'} });
  my $marker = make_inert_marker(%{$case->{marker}});
  my $parent = $case->{parent}->($marker);
  capture_enrichment_error(
   $case->{code},
   sub { $authority->enrich_ast($parent, enrichment_args()) },
   $case->{id},
  );
  is($calls, 0, "$case->{id} is rejected while validating the complete depth");
  ok(LinkedSpec::StagedParseJob::is_marker($parent->{payload}), "$case->{id} leaves the caller AST untouched");
 }

 my $calls = 0;
 my $stale_authority = build_enrichment_authority(
  executor => sub { ++$calls; return {kind => 'parsed'} },
 );
 my $first = make_inert_marker(result_policy => 'replace_field', into => 'second');
 my $second = make_inert_marker(result_policy => 'replace_marker');
 my $stale_error = capture_enrichment_error(
  'staged_marker_mismatch',
  sub {
   $stale_authority->enrich_ast(
    {first => $first, second => $second},
    enrichment_args(),
   )
  },
  'stale marker after an earlier ordered stitch',
 );
 is($stale_error->{phase}, 'stitch', 'stale marker identity fails in the stitch phase');
 is($calls, 1, 'the stale later marker is rejected before its child callback executes');
};

my $nested_callback_calls = 0;
my $nested_marker = make_inert_marker(text => 'inner', result_policy => 'replace_marker');
my $current_depth_authority = build_enrichment_authority(
 executor => sub {
  ++$nested_callback_calls;
  return {kind => 'outer_result', child => $nested_marker};
 },
);
my $outer_marker = make_inert_marker(text => 'outer', result_policy => 'replace_marker');
my $current_depth_output = $current_depth_authority->enrich_ast(
 {payload => $outer_marker},
 enrichment_args(),
);
is($nested_callback_calls, 1, 'current-depth execution does not rescan a newly stitched result');
ok(
 LinkedSpec::StagedParseJob::is_marker($current_depth_output->{ast}{payload}{child}),
 'a newly stitched inert marker remains intact for the future next depth',
);

my $recursive_interface = LinkedSpec::StagedASTEnrichment->can('enrich_recursively');
ok(
 $recursive_interface,
 'Perl schedules newly stitched markers breadth-first with bounded decreasing chains and rebased diagnostics',
);
diag(
 'expected RED: missing authority=[breadth_first_recursive_scheduling,decreasing_chain_bounds,'
 .'cancellation_resource_limits,source_rebased_diagnostics]'
 .'; current_depth=complete; marker=STAGED_PARSE_JOB_MARKER; sidecar=staged_parse_job_v2',
) unless $recursive_interface;

done_testing();
