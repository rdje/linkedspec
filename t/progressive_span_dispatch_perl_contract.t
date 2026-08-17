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
 'neutral_complete_backends_pending',
 'loads the neutral-complete and backend-pending rollout state',
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
  availability => 'neutral authority only; no backend admits the spelling until its independent rollout row completes',
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
  backend_guard_groups => 5,
  backend_guard_paths => 17,
  outward_guard_paths => 10,
  diagnostics => 26,
  rollout_legs => 9,
  mutations => 86,
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
 ['complete', ('pending') x 8],
 'keeps only the neutral rollout leg complete',
);
is_deeply(
 $contract->{rollout}[1]{paths},
 [],
 'keeps the Perl rollout path list empty before admission',
);

my $probe = 'return(dispatch_span("expr-v1", "Expr", span));';
my $lowered = LinkedSpec::call_spec_handler_subst('Top', $probe);
is(
 occurrences($lowered, 'dispatch_span'),
 1,
 'current lowering retains one logical dispatch marker',
);
is(
 occurrences($lowered, 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER'),
 1,
 'current lowering emits exactly one unsupported-helper sentinel',
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
 'generated-v2 retains one logical dispatch marker before integration',
);
is(
 occurrences($generated_source, 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER'),
 1,
 'generated-v2 retains one unsupported-helper sentinel before integration',
);
my $generated_package = 'LinkedSpec::ProgressiveSpanDispatchPerlRedGenerated';
my $generated_loaded = eval "package $generated_package; $generated_source; 1";
ok($generated_loaded, 'the current unsupported generated-v2 source loads') or diag($@);
my ($generated_value, $generated_execute_ok);
if ($generated_loaded) {
 no strict 'refs';
 my $generated_input = 'abc';
 $generated_execute_ok = eval {
  $generated_value = &{"${generated_package}::Execute"}(\$generated_input);
  1
 };
}
ok($generated_execute_ok, 'the current unsupported generated-v2 source executes') or diag($@);
ok(!defined($generated_value), 'the unsupported generated-v2 dispatch result remains null');

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
 'Perl lowers dispatch_span to dedicated language-agnostic progressive ActionIR',
);
diag(
 'expected RED: missing node=[PROGRESSIVE_DISPATCH_SPAN]'
 . '; unresolved helpers=[' . join(',', @unresolved_helpers) . ']'
 . "; raw dependencies=$raw_dependency_count",
) unless $descriptor_ready;

done_testing();
