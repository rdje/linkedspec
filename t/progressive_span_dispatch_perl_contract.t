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
use LinkedSpec::ProgressiveSpanDispatch ();
use LinkedSpec::ProgressiveSpanDispatchRuntime ();
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

sub clone_plain {
 my ($value) = @_;
 return JSON::PP->new->decode(JSON::PP->new->canonical(1)->encode($value))
}

sub progressive_options {
 my ($contract) = @_;
 my @entries = map {
  my $entry = clone_plain($_);
  $entry->{compiled_authority} = sub {
   my ($request) = @_;
   my $view = $request->{source_view};
   return {
    kind => 'expr',
    text => $view->text,
    span => $view->rebase_span({
     source_id => $view->source_id,
     start => 0,
     end => length($view->text),
     provenance => 'child-match',
    }),
   };
  };
  $entry
 } @{$contract->{registry_entries}};
 my $registry = LinkedSpec::ProgressiveSpanDispatch->new(entries => \@entries);
 return {
  progressive_span_dispatch => {
   registry => $registry,
   source_id => 'input',
   cancellation_token => 'contract-token',
   cancelled => sub { return 0 },
   clock => sub { return 1 },
   deadline_tick => 100,
   remaining_steps => 100,
   max_depth => 4,
   max_calls => 8,
   caller_capabilities => [qw(actionir-v1 structured-result-v1 typed-source-location-v1)],
   required_capabilities => [qw(actionir-v1 typed-source-location-v1)],
   caller_ceilings => {
    source_detail => 'text',
    policy_modes => [qw(deterministic fail-only strict-json)],
    max_steps => 100,
    max_result_nodes => 64,
    max_diagnostic_bytes => 4096,
   },
   required_source_detail => 'span',
   dispatch_cost => 1,
  },
 }
}

sub expected_child_result {
 return {
  kind => 'expr',
  text => 'a',
  span => {
   source_id => 'input',
   start => 0,
   end => 1,
   provenance => 'child-match',
  },
 }
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'progressive_span_dispatch_contract.json',
);
my $contract = slurp_json($contract_path);

is(
 $contract->{contract_id},
 'linkedspec-progressive-span-dispatch-v1',
 'loads the frozen progressive span-dispatch contract',
);
is($contract->{format}, 1, 'loads contract format 1');
is(
 $contract->{status},
 'all_private_backends_complete_recurring_and_public_pending',
 'loads the all-private-backends-complete and recurring/public-pending state',
);
is(
 $contract->{task_owner},
 'FUTURE-PARITY-BACKLOG.14.6.1',
 'loads the backend-neutral owner',
);

is_deeply(
 $contract->{authored_surface},
 {
  example => 'value = dispatch_span("expr-v1", "Expr", span)',
  callee => 'dispatch_span',
  node_kind => 'PROGRESSIVE_DISPATCH_SPAN',
  effect => 'parser_registry_or_staged_dispatch',
  operands => [
   'one nonempty normalized logical parser identity string literal',
   'one nonempty allowed top-rule string literal',
   'one bare rule-local harray binding with exact source_id/start/end/provenance fields',
  ],
  result => 'one detached child payload returned as the expression value',
  failure_policy => 'fail_only; every dispatch or child failure propagates unchanged and no null, fallback, retry, or alternate parser is implied',
  availability => 'private Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT runtimes admitted; recurring and public no-drift rows remain pending',
 },
 'freezes the dedicated authored expression, operands, result, and fail-only boundary',
);

is_deeply(
 [map { $_->{id} } @{$contract->{sources}}],
 [qw(unicode ascii)],
 'freezes both decoded source authorities',
);
is_deeply(
 ids($contract->{view_cases}),
 [qw(
  unicode_middle empty_direct_span ascii_full source_mismatch reversed outside_source
  copied_text_smuggling noninteger_offset
 )],
 'freezes the eight bounded source-view cases',
);
is_deeply(
 ids($contract->{authority_cases}),
 [qw(
  intersection_and_minima entry_cannot_elevate_caller required_capability_missing
  policy_intersection_empty source_detail_cannot_elevate caller_numeric_minimum
 )],
 'freezes the six capability, policy, and ceiling cases',
);
is_deeply(
 ids($contract->{cancellation_cases}),
 [qw(
  fresh_budget already_cancelled deadline_reached budget_empty cost_exceeds_remaining
  token_replacement
 )],
 'freezes the six cancellation, deadline, and budget cases',
);
is_deeply(
 ids($contract->{chain_cases}),
 [qw(
  root strictly_smaller exact_repeat shifted_equal_length larger_repeat different_identity
  depth_limit call_limit
 )],
 'freezes the eight cycle, depth, and call-bound cases',
);
is_deeply(
 ids($contract->{execution_cases}),
 [qw(detached_success false_payload child_failure_propagates live_handle_rejected)],
 'freezes the four detached success/failure cases',
);

is_deeply(
 $contract->{registry_schema}{fields},
 [qw(parser_id compiled_authority fingerprint allowed_top_rules capabilities ceilings)],
 'freezes the immutable pre-registered entry shape',
);
ok(
 $contract->{registry_schema}{immutable_during_execution},
 'registry entries are immutable during execution',
);
is_deeply(
 $contract->{registry_schema}{forbidden_fields},
 [qw(path spec_path search_roots provider_query source_text compile_request)],
 'registry entries grant no implicit loading or compilation authority',
);
is_deeply(
 [map { $_->{parser_id} } @{$contract->{registry_entries}}],
 [qw(expr-v1 json-v1)],
 'freezes both logical registry identities',
);

my @diagnostic_codes = map { $_->{code} } @{$contract->{diagnostics}};
is_deeply(
 \@diagnostic_codes,
 [qw(
  progressive_parser_identity_literal_required progressive_parser_identity_invalid
  progressive_top_rule_literal_required progressive_top_rule_invalid
  progressive_span_binding_required progressive_span_shape_invalid
  progressive_span_source_mismatch progressive_span_out_of_bounds progressive_span_reversed
  progressive_registry_missing progressive_registry_mutation_forbidden
  progressive_implicit_load_forbidden progressive_top_rule_forbidden
  progressive_capability_denied progressive_policy_denied progressive_source_detail_denied
  progressive_cancelled progressive_deadline_exceeded progressive_budget_exhausted
  progressive_cancellation_authority_mismatch progressive_cycle_non_decreasing
  progressive_depth_exceeded progressive_call_limit_exceeded progressive_child_failed
  progressive_transaction_forbidden progressive_result_not_detached
 )],
 'freezes all twenty-six portable structured diagnostic codes in order',
);
for my $diagnostic (@{$contract->{diagnostics}}) {
 is(
  $diagnostic->{required_context}[0],
  'code',
  "$diagnostic->{code} starts with its portable code field",
 );
 ok(
  !grep({ !defined($_) || $_ !~ /\A[a-z][a-z0-9_]*\z/ } @{$diagnostic->{required_context}}),
  "$diagnostic->{code} freezes only portable scalar context names",
 );
}

is_deeply(
 $contract->{expected_counts},
 {
  registry_entries => 2,
  sources => 2,
  view_cases => 8,
  authority_cases => 6,
  cancellation_cases => 6,
  chain_cases => 8,
  execution_cases => 4,
  rust_carrier_paths => 9,
  dart_carrier_paths => 8,
  julia_carrier_paths => 9,
  lua_carrier_paths => 9,
  backend_guard_groups => 0,
  backend_guard_paths => 0,
  outward_guard_paths => 10,
  diagnostics => 26,
  rollout_legs => 9,
  mutations => 112,
 },
 'freezes every neutral inventory count',
);
is_deeply(
 [map { $_->{leg} } @{$contract->{rollout}}],
 [qw(neutral perl rust dart julia puc_lua luajit recurring public_no_drift)],
 'freezes rollout order across five source backends and six runtimes',
);
is_deeply(
 [map { $_->{status} } @{$contract->{rollout}}],
 [('complete') x 7, ('pending') x 2],
 'keeps all private runtime legs complete while recurring and public remain pending',
);
is_deeply(
 $contract->{rollout}[1]{paths},
 ['t/progressive_span_dispatch_perl_contract.t'],
 'binds the Perl rollout leg to this exact admission consumer',
);
is_deeply(
 $contract->{rollout}[2]{paths},
 ['rust/linkedspec-runtime/tests/progressive_span_dispatch_contract.rs'],
 'binds the Rust rollout leg to its exact cfg-enabled admission consumer',
);
is_deeply(
 $contract->{rollout}[3]{paths},
 ['dart/test/progressive_span_dispatch_contract_test.dart'],
 'binds the Dart rollout leg to its ordinary and exact canonical consumer',
);
is_deeply(
 $contract->{rollout}[4]{paths},
 ['julia/test/progressive_span_dispatch_contract_test.jl'],
 'binds the Julia rollout leg to its ordinary and exact canonical consumer',
);
is_deeply(
 [$contract->{rollout}[5]{paths}, $contract->{rollout}[6]{paths}],
 [
  ['lua/test/progressive_span_dispatch_contract_test.lua'],
  ['lua/test/progressive_span_dispatch_contract_test.lua'],
 ],
 'binds both Lua runtime legs to the shared ordinary and exact canonical consumer',
);

my $probe = 'return(dispatch_span("expr-v1", "Expr", span));';
my $lowered = LinkedSpec::call_spec_handler_subst('Top', $probe);
is(
 occurrences($lowered, 'dispatch_span'),
 1,
 'a non-assignment dispatch form retains one logical marker for rejection',
);
is(
 occurrences($lowered, 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER'),
 1,
 'a non-assignment dispatch form remains outside the admitted exact assignment',
);

my $staged_job = {
 kind => 'parse_job',
 job_id => 'progressive-red',
 node_kind => 'progressive_span_dispatch',
 payload_kind => 'source_span',
 text => 'abc',
 parser_spec_id => 'expr-v1',
 top_rule => 'Expr',
 result_policy => 'replace',
 result_field => 'value',
 failure_policy => 'fail_only',
 parent_ast_path => ['Top'],
 source_span => {start => 0, end => 3, line_start => 1, line_end => 1},
};
my $staged_ok = eval {
 LinkedSpec::StagedParserRegistry::execute_parse_job($staged_job);
 1
};
my $staged_error = $@;
ok(!$staged_ok, 'the staged function-body adapter rejects progressive parser identity');
like(
 $staged_error,
 qr/phase=resolve;.*parser_spec_id=expr-v1;.*unsupported parser spec id 'expr-v1'/,
 'the separate staged registry fails at logical resolution without loading a path',
);

my $authored_source = <<'SPEC';
Top::
 I {
  span = hash("source_id", "input", "start", 0, "end", 1, "provenance", "authored")
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
SPEC

my %descriptor_ctx;
my $descriptor = LinkedSpec::Get(
 \$authored_source,
 return_descriptor => 1,
 generated_source_identity => 'progressive-span-dispatch-perl-red.spec',
 runtime_ctx_ref => \%descriptor_ctx,
);
ok(ref($descriptor) eq 'HASH', 'the exact future authored surface reaches descriptor construction')
 or diag(JSON::PP->new->canonical(1)->encode($descriptor_ctx{last_error} // {}));

my $rewriter = ref($descriptor) eq 'HASH'
 ? $descriptor->{spec}{Top}{meta}{action_rewriter}
 : {};
my @progressive_events = grep {
 ($_->{kind} // '') eq 'PROGRESSIVE_DISPATCH_SPAN'
} @{$rewriter->{canonical_action_ir_events} // []};
is(scalar(@progressive_events), 1, 'the exact assignment produces one dedicated progressive node');
is_deeply(
 $progressive_events[0]{args},
 {
  result => 'value',
  argument_count => 3,
  parser_operand => '"expr-v1"',
  top_rule_operand => '"Expr"',
  span_operand => 'span',
  parser_id => 'expr-v1',
  top_rule => 'Expr',
  span_binding => 'span',
 },
 'the dedicated node preserves only static logical operands and the result binding',
);
ok(
 !grep({
  ($_->{kind} // '') eq 'ASSIGN'
   && (($_->{args}{target} // '') eq 'value')
 } @{$rewriter->{canonical_action_ir_events} // []}),
 'the exclusive progressive statement is not duplicated as a generic assignment',
);

my %live_ctx;
my $live_parser = LinkedSpec::Get(
 \$authored_source,
 generated_source_identity => 'progressive-span-dispatch-perl-live.spec',
 runtime_ctx_ref => \%live_ctx,
);
ok(ref($live_parser) eq 'CODE', 'the live carrier compiles the private progressive node')
 or diag(JSON::PP->new->canonical(1)->encode($live_ctx{last_error} // {}));
my $live_input = 'abc';
my $live_value = ref($live_parser) eq 'CODE'
 ? $live_parser->(\$live_input, progressive_options($contract))
 : undef;
is_deeply($live_value, expected_child_result(), 'the live carrier returns the detached child payload');

my $reconstructed_input = 'abc';
my $reconstructed_value = LinkedSpec::ProgressiveSpanDispatchRuntime::with_invocation(
 $descriptor,
 \$reconstructed_input,
 progressive_options($contract),
 sub {
  return $descriptor->{spec}{Top}{handler}->($descriptor, \$reconstructed_input, {})
 },
);
is_deeply(
 $reconstructed_value,
 expected_child_result(),
 'the reconstructed descriptor carrier returns the same detached child payload',
);

my $generated_source = LinkedSpec::emit_generated_source(
 \$authored_source,
 source_identity => 'progressive-span-dispatch-perl-red.spec',
);
ok(
 defined($generated_source) && length($generated_source),
 'the future authored surface emits independently loadable generated-v2 source',
);
is(
 occurrences($generated_source, 'dispatch_span'),
 1,
 'generated-v2 serializes one logical dispatch origin marker',
);
is(
 occurrences($generated_source, 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER'),
 0,
 'generated-v2 contains no unsupported-helper sentinel after private lowering',
);
unlike(
 $generated_source,
 qr/(?:compiled_authority|contract-token|opaque:compiled|cancellation_token\s*=>)/,
 'generated-v2 serializes no registry callback, fingerprint authority, or cancellation token',
);

my $load_generated = sub {
 my ($package) = @_;
 my $loaded = eval "package $package; $generated_source; 1";
 my $error = $@;
 ok($loaded, "$package loads the emitted source in an isolated namespace") or diag($error);
 no strict 'refs';
 return {
  execute => *{"${package}::Execute"}{CODE},
  plan => *{"${package}::LinkedSpecGeneratedPlan"}{CODE},
  validate_plan => *{"${package}::ValidateGeneratedPlan"}{CODE},
 }
};

my $plan_carrier = $load_generated->('LinkedSpec::ProgressiveSpanDispatchPerlPlanGenerated');
my $generated_plan = $plan_carrier->{plan}->();
ok($plan_carrier->{validate_plan}->($generated_plan), 'the generated-plan carrier validates its logical plan');
ok(
 !grep({ exists($_->{registry}) || exists($_->{compiled_authority}) } @$generated_plan),
 'the generated plan contains no registry or compiled authority',
);
my $plan_input = 'abc';
is_deeply(
 $plan_carrier->{execute}->(\$plan_input, progressive_options($contract)),
 expected_child_result(),
 'the generated-plan carrier receives fresh authority only through invocation options',
);

my $emitted_carrier = $load_generated->('LinkedSpec::ProgressiveSpanDispatchPerlFreshGenerated');
my $emitted_input = 'abc';
is_deeply(
 $emitted_carrier->{execute}->(\$emitted_input, progressive_options($contract)),
 expected_child_result(),
 'an independently compiled emitted-source carrier returns the same child payload',
);

for my $missing_case (
 ['live', sub {
  my $input = 'abc';
  return $live_parser->(\$input)
 }],
 ['generated', sub {
  my $input = 'abc';
  return $emitted_carrier->{execute}->(\$input)
 }],
) {
 my ($label, $callback) = @$missing_case;
 my $ok = eval {
  $callback->();
  1
 };
 my $error = $@;
 ok(!$ok, "$label carrier rejects a missing host registry authority");
 ok(
  LinkedSpec::ProgressiveSpanDispatchRuntime::is_error($error)
   && ($error->{code} // '') eq 'progressive_registry_missing',
  "$label carrier preserves the typed missing-registry diagnostic unchanged",
 );
}

my @static_rejections = (
 {
  id => 'dynamic parser identity',
  call => 'dispatch_span(parser_id, "Expr", span)',
  code => 'progressive_parser_identity_literal_required',
  field => 'operand',
  value => 'parser_id',
 },
 {
  id => 'invalid parser identity',
  call => 'dispatch_span("../expr", "Expr", span)',
  code => 'progressive_parser_identity_invalid',
  field => 'parser_id',
  value => '../expr',
 },
 {
  id => 'dynamic top rule',
  call => 'dispatch_span("expr-v1", top_rule, span)',
  code => 'progressive_top_rule_literal_required',
  field => 'operand',
  value => 'top_rule',
 },
 {
  id => 'invalid top rule',
  call => 'dispatch_span("expr-v1", "Expr/Bad", span)',
  code => 'progressive_top_rule_invalid',
  field => 'top_rule',
  value => 'Expr/Bad',
 },
 {
  id => 'non-bare span',
  call => 'dispatch_span("expr-v1", "Expr", hash("source_id", "input"))',
  code => 'progressive_span_binding_required',
  field => 'operand',
  value => 'hash("source_id", "input")',
 },
);
for my $case (@static_rejections) {
 my $source = $authored_source;
 $source =~ s/dispatch_span\("expr-v1", "Expr", span\)/$case->{call}/;
 my %ctx;
 my $bad_descriptor = LinkedSpec::Get(\$source, return_descriptor => 1, runtime_ctx_ref => \%ctx);
 ok(!defined($bad_descriptor), "$case->{id} rejects before a parser carrier exists");
 is($ctx{last_error}{stage}, 'progressive_span_dispatch_policy', "$case->{id} uses the static progressive policy stage");
 is($ctx{last_error}{code}, $case->{code}, "$case->{id} uses the portable diagnostic code");
 is($ctx{last_error}{$case->{field}}, $case->{value}, "$case->{id} preserves its portable diagnostic operand");
}

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
 I {
  value = dispatch_span("expr-v1", "Expr", span)
  return(value)
 }
 /never/
SPEC
my %transaction_ctx;
my $transaction_descriptor = LinkedSpec::Get(
 \$transaction_source,
 return_descriptor => 1,
 runtime_ctx_ref => \%transaction_ctx,
);
ok(!defined($transaction_descriptor), 'an uncommitted recognition effect graph rejects progressive dispatch statically');
is($transaction_ctx{last_error}{stage}, 'recognition_transaction_policy', 'transaction rejection uses the recognition policy stage');
is($transaction_ctx{last_error}{code}, 'recognition_effect_forbidden', 'transaction rejection uses the portable forbidden-effect code');
is($transaction_ctx{last_error}{effect}, 'parser_registry_or_staged_dispatch', 'transaction rejection preserves the progressive effect class');

{
 my $runtime_descriptor = {spec => {}};
 my $runtime_input = 'abc';
 pos($runtime_input) = 0;
 my $runtime_info = {marks => {}};
 my $runtime_boundary = 0;
 my $guard = LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
  $runtime_descriptor,
  \$runtime_input,
  $runtime_info,
  \$runtime_boundary,
  'Top',
 );
 ok(
  !LinkedSpec::RecognitionTransactionRuntime::transaction_active($runtime_descriptor, \$runtime_input),
  'runtime transaction visibility starts inactive',
 );
 my $token = LinkedSpec::RecognitionTransactionRuntime::begin(
  $runtime_descriptor,
  \$runtime_input,
  $runtime_info,
  \$runtime_boundary,
  'Top',
  'token',
 );
 ok(
  LinkedSpec::RecognitionTransactionRuntime::transaction_active($runtime_descriptor, \$runtime_input),
  'runtime transaction visibility detects an active uncommitted token',
 );
 $guard->{authority}->attempt(
  frame => $guard->{frame},
  token => $token,
  matched => 0,
  state => {cursor => 0, boundary => 0, marks => {}},
 );
 LinkedSpec::RecognitionTransactionRuntime::finish_rollback(
  $runtime_descriptor,
  \$runtime_input,
  $runtime_info,
  \$runtime_boundary,
  $token,
  'Top',
 );
 ok(
  !LinkedSpec::RecognitionTransactionRuntime::transaction_active($runtime_descriptor, \$runtime_input),
  'runtime transaction visibility clears after rollback',
 );
 undef $guard;
}

my %observed_node = map { ($_ => 1) } @{$rewriter->{canonical_action_ir_nodes} // []};
my @unresolved_helpers = @{$rewriter->{unresolved_helpers} // []};
my $raw_dependency_count = $rewriter->{raw_perl_dependency_count} // 0;
my $descriptor_ready =
 $observed_node{PROGRESSIVE_DISPATCH_SPAN}
 && !@unresolved_helpers
 && !$raw_dependency_count
 && ($rewriter->{language_agnostic_action_ir_ready} // 0);

ok(
 $descriptor_ready,
 'Perl privately lowers the assignment to dedicated language-agnostic progressive ActionIR',
);
diag(
 'missing node=[PROGRESSIVE_DISPATCH_SPAN]'
 . '; unresolved helpers=[' . join(',', @unresolved_helpers) . ']'
 . "; raw dependencies=$raw_dependency_count",
) unless $descriptor_ready;

done_testing();
