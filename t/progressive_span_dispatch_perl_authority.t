#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Test::More;

use LinkedSpec::ProgressiveSpanDispatch ();

my $JSON = JSON::PP->new->canonical(1)->allow_nonref(1);

sub slurp_json {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $document = <$fh>;
 close $fh or die "cannot close $path: $!";
 return JSON::PP->new->decode($document)
}

sub clone_plain {
 my ($value) = @_;
 return JSON::PP->new->decode($JSON->encode($value))
}

my $contract = slurp_json(File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'progressive_span_dispatch_contract.json',
));
my %source = map { ($_->{id} => $_->{text}) } @{$contract->{sources}};
my %observed_error;

sub capture_error {
 my ($code, $callback, $label) = @_;
 my $ok = eval { $callback->(); 1 };
 my $error = $@;
 ok(!$ok, "$label rejects");
 ok(
  LinkedSpec::ProgressiveSpanDispatch::is_error($error),
  "$label returns the private typed error",
 );
 is($error->{code}, $code, "$label keeps diagnostic $code")
  if LinkedSpec::ProgressiveSpanDispatch::is_error($error);
 $observed_error{$error->{code}} = $error
  if LinkedSpec::ProgressiveSpanDispatch::is_error($error);
 return $error
}

sub build_harness {
 my (%args) = @_;
 my $executor = $args{executor} // sub {
  my ($request) = @_;
  return {
   text => $request->{source_view}->text,
   effective => $request->{effective},
  }
 };
 my @entries = map {
  my $entry = clone_plain($_);
  $entry->{compiled_authority} = sub { return $executor->(@_) };
  $entry
 } @{$contract->{registry_entries}};
 my $registry = LinkedSpec::ProgressiveSpanDispatch->new(entries => \@entries);
 my $cancelled = $args{cancelled} ? 1 : 0;
 my $now_tick = defined($args{now_tick}) ? $args{now_tick} : 1;
 my $invocation = $registry->start_invocation(
  sources => clone_plain($args{sources} // \%source),
  source_id => $args{source_id} // 'unicode',
  cancellation_token => $args{token} // 'cancel',
  cancelled => sub { return $cancelled },
  clock => sub { return $now_tick },
  deadline_tick => defined($args{deadline_tick}) ? $args{deadline_tick} : 100,
  remaining_steps => defined($args{remaining_steps}) ? $args{remaining_steps} : 100,
  max_depth => defined($args{max_depth}) ? $args{max_depth} : 4,
  max_calls => defined($args{max_calls}) ? $args{max_calls} : 8,
  active_chain => clone_plain($args{active_chain} // []),
  total_calls => defined($args{total_calls}) ? $args{total_calls} : 0,
 );
 return ($registry, $invocation, \@entries)
}

sub dispatch_args {
 return (
  origin => 'Top:dispatch_span',
  parser_id => 'expr-v1',
  top_rule => 'Expr',
  span => {source_id => 'unicode', start => 0, end => 1, provenance => 'test'},
  caller_capabilities => [qw(actionir-v1 caller-only structured-result-v1 typed-source-location-v1)],
  required_capabilities => [],
  caller_ceilings => {
   source_detail => 'text',
   policy_modes => [qw(deterministic fail-only strict-json trace)],
   max_steps => 100,
   max_result_nodes => 128,
   max_diagnostic_bytes => 4096,
  },
  required_source_detail => 'none',
  child_token => 'cancel',
  cost => 1,
 )
}

sub dispatch {
 my ($invocation, %overrides) = @_;
 return $invocation->dispatch(dispatch_args(), %overrides)
}

is(
 $contract->{contract_id},
 'linkedspec-progressive-span-dispatch-v1',
 'authority consumer loads the exact neutral contract',
);

subtest 'immutable registry and zero implicit loading' => sub {
 my ($registry, $invocation, $entries) = build_harness();
 push @{$entries->[0]{allowed_top_rules}}, 'Mutated';
 capture_error(
  'progressive_top_rule_forbidden',
  sub { dispatch($invocation, top_rule => 'Mutated') },
  'caller mutation of the seed entry',
 );
 capture_error(
  'progressive_registry_mutation_forbidden',
  sub { $registry->register(parser_id => 'later-v1') },
  'runtime registry mutation',
 );
 capture_error(
  'progressive_implicit_load_forbidden',
  sub { $registry->load(parser_id => 'expr-v1') },
  'runtime path/provider loading',
 );
};

subtest 'bounded Unicode-scalar source views and global rebasing' => sub {
 for my $case (@{$contract->{view_cases}}) {
  my ($registry, $invocation) = build_harness(
   source_id => $case->{authority_source_id},
   executor => sub {
    my ($request) = @_;
    my $view = $request->{source_view};
    return {
     text => $view->text,
     local_to_global => [map { $view->local_to_global($_) } 0 .. length($view->text)],
     rebased => $view->rebase_span({
      source_id => $case->{authority_source_id},
      start => 0,
      end => length($view->text),
      provenance => 'child',
     }),
    }
   },
  );
  if ($case->{accepted}) {
   my $result = dispatch(
    $invocation,
    span => clone_plain($case->{span}),
    parser_id => 'expr-v1',
    top_rule => 'Expr',
   );
   is($result->{text}, $case->{view_text}, "$case->{id} exposes only bounded decoded text");
   is_deeply(
    $result->{local_to_global},
    $case->{local_to_global},
    "$case->{id} rebases every local boundary globally",
   );
   is_deeply(
    $result->{rebased},
    {
     source_id => $case->{span}{source_id},
     start => $case->{span}{start},
     end => $case->{span}{end},
     provenance => 'child',
    },
    "$case->{id} rebases child spans without copied source text",
   );
  } else {
   capture_error(
    $case->{diagnostic},
    sub { dispatch($invocation, span => clone_plain($case->{span})) },
    $case->{id},
   );
  }
 }
};

subtest 'capabilities, policy, and ceilings only narrow' => sub {
 for my $case (@{$contract->{authority_cases}}) {
  my ($registry, $invocation) = build_harness(
   executor => sub { return clone_plain($_[0]{effective}) },
  );
  my %args = (
   parser_id => $case->{entry_id},
   top_rule => $case->{entry_id} eq 'json-v1' ? 'Document' : 'Expr',
   caller_capabilities => clone_plain($case->{caller_capabilities}),
   required_capabilities => clone_plain($case->{required_capabilities}),
   caller_ceilings => clone_plain($case->{caller_ceilings}),
   required_source_detail => $case->{required_source_detail},
  );
  if ($case->{accepted}) {
   is_deeply(
    dispatch($invocation, %args),
    $case->{effective},
    "$case->{id} computes exact intersections and minima",
   );
  } else {
   capture_error(
    $case->{diagnostic},
    sub { dispatch($invocation, %args) },
    $case->{id},
   );
  }
 }
};

subtest 'shared cancellation, deadline, and remaining budget never reset' => sub {
 for my $case (@{$contract->{cancellation_cases}}) {
  my ($registry, $invocation) = build_harness(
   token => $case->{token},
   cancelled => $case->{cancelled},
   now_tick => $case->{now_tick},
   deadline_tick => $case->{deadline_tick},
   remaining_steps => $case->{remaining_steps},
   executor => sub { return 0 },
  );
  my %args = (
   child_token => $case->{child_token},
   cost => $case->{cost},
  );
  if ($case->{accepted}) {
   is(dispatch($invocation, %args), 0, "$case->{id} preserves a false payload");
  } else {
   capture_error(
    $case->{diagnostic},
    sub { dispatch($invocation, %args) },
    $case->{id},
   );
  }
  is(
   $invocation->remaining_steps,
   $case->{remaining_after},
   "$case->{id} keeps the shared remaining budget exact",
  );
 }
};

subtest 'dispatch chains are bounded and same-identity repeats strictly shrink' => sub {
 for my $case (@{$contract->{chain_cases}}) {
  my ($parser_id, $top_rule, $source_id, $start, $end) = @{$case->{candidate}};
  my ($registry, $invocation) = build_harness(
   source_id => $source_id,
   active_chain => $case->{active},
   total_calls => $case->{total_calls},
   max_depth => $case->{max_depth},
   max_calls => $case->{max_calls},
   executor => sub { return 0 },
  );
  my %args = (
   parser_id => $parser_id,
   top_rule => $top_rule,
   span => {source_id => $source_id, start => $start, end => $end, provenance => 'chain'},
  );
  if ($case->{accepted}) {
   is(dispatch($invocation, %args), 0, "$case->{id} accepts the bounded chain candidate");
  } else {
   capture_error(
    $case->{diagnostic},
    sub { dispatch($invocation, %args) },
    $case->{id},
   );
  }
 }
};

subtest 'child execution is isolated, fail-only, falsey-safe, and deeply detached' => sub {
 for my $case (@{$contract->{execution_cases}}) {
  my $parent = clone_plain($case->{parent_before});
  my $parent_before = $JSON->encode($parent);
  my $child_result = clone_plain($case->{child_result});
  my ($registry, $invocation) = build_harness(
   remaining_steps => $case->{budget_before},
   executor => sub { return $child_result },
  );
  if ($case->{accepted}) {
   my $result = dispatch($invocation, cost => $case->{child_cost});
   is_deeply($result, $case->{child_result}, "$case->{id} returns the exact detached payload");
   if (ref($child_result) eq 'HASH') {
    $child_result->{kind} = 'mutated';
    isnt($result->{kind}, 'mutated', "$case->{id} does not retain the child aggregate");
   }
  } else {
   capture_error(
    $case->{diagnostic},
    sub { dispatch($invocation, cost => $case->{child_cost}) },
    $case->{id},
   );
  }
  is($JSON->encode($parent), $parent_before, "$case->{id} cannot mutate parent parser state");
  is(
   $invocation->remaining_steps,
   $case->{budget_after},
   "$case->{id} spends only the shared child cost",
  );
 }
};

subtest 'nested execution shares authority and invalidates transient views' => sub {
 my $retained_view;
 my ($registry, $invocation) = build_harness(
  remaining_steps => 20,
  executor => sub {
   my ($request, $authority) = @_;
   $retained_view = $request->{source_view};
   return {leaf => $request->{source_view}->text}
    if length($request->{source_view}->text) < length($source{unicode});
   return $authority->dispatch(
    dispatch_args(),
    span => {source_id => 'unicode', start => 1, end => 4, provenance => 'nested'},
    cost => 3,
   );
  },
 );
 is_deeply(
  dispatch(
   $invocation,
   span => {source_id => 'unicode', start => 0, end => 5, provenance => 'outer'},
   cost => 2,
  ),
  {leaf => 'é🙂B'},
  'a same-identity nested dispatch succeeds only over a strictly smaller span',
 );
 is($invocation->remaining_steps, 15, 'outer and nested calls spend one shared budget');
 is($invocation->total_calls, 2, 'outer and nested calls spend one shared call limit');
 my $view_ok = eval { $retained_view->text; 1 };
 ok(!$view_ok, 'a source view cannot outlive its child callback');
 like($@, qr/outside its child execution/, 'expired source-view access fails explicitly');

 my ($rebase_registry, $rebase_invocation) = build_harness(
  executor => sub {
   my ($request) = @_;
   my $view = $request->{source_view};
   return {
    position => $view->rebase_position(1),
    diagnostic => $view->rebase_diagnostic({
     code => 'child_syntax',
     offset => 1,
     span => {
      source_id => 'unicode',
      start => 0,
      end => length($view->text),
      provenance => 'child-diagnostic',
     },
    }),
   };
  },
 );
 my $rebased = dispatch(
  $rebase_invocation,
  span => {source_id => 'unicode', start => 1, end => 4, provenance => 'parent'},
 );
 is_deeply(
  $rebased->{position},
  {source_id => 'unicode', offset => 2},
  'child positions rebase to the caller-authorized source identity',
 );
 is_deeply(
  $rebased->{diagnostic},
  {
   code => 'child_syntax',
   source_id => 'unicode',
   offset => 2,
   span => {
    source_id => 'unicode',
    start => 1,
    end => 4,
    provenance => 'child-diagnostic',
   },
  },
  'child diagnostics rebase spans and scalar offsets globally',
 );

 my $cycle = {};
 $cycle->{self} = $cycle;
 my ($cycle_registry, $cycle_invocation) = build_harness(
  executor => sub { return $cycle },
 );
 capture_error(
  'progressive_result_not_detached',
  sub { dispatch($cycle_invocation) },
  'cyclic child result',
 );
};

subtest 'all private diagnostic seams carry the neutral context fields' => sub {
 my ($registry, $invocation) = build_harness();
 my @cases = (
  ['progressive_parser_identity_literal_required', sub { dispatch($invocation, parser_id => undef) }],
  ['progressive_parser_identity_invalid', sub { dispatch($invocation, parser_id => '../expr') }],
  ['progressive_top_rule_literal_required', sub { dispatch($invocation, top_rule => undef) }],
  ['progressive_top_rule_invalid', sub { dispatch($invocation, top_rule => 'Expr/Path') }],
  ['progressive_span_binding_required', sub { dispatch($invocation, span => 'copied text') }],
  ['progressive_registry_missing', sub { dispatch($invocation, parser_id => 'missing-v1') }],
  ['progressive_top_rule_forbidden', sub { dispatch($invocation, top_rule => 'Other') }],
  ['progressive_transaction_forbidden', sub { dispatch($invocation, transaction_active => 1) }],
 );
 for my $row (@cases) {
  capture_error($row->[0], $row->[1], $row->[0]);
 }

 my @expected_codes = map { $_->{code} } @{$contract->{diagnostics}};
 is_deeply(
  [sort keys %observed_error],
  [sort @expected_codes],
  'focused cases reach every neutral diagnostic code',
 );
 for my $diagnostic (@{$contract->{diagnostics}}) {
  my $error = $observed_error{$diagnostic->{code}};
  ok(defined($error), "$diagnostic->{code} was observed");
  next unless defined $error;
  for my $field (@{$diagnostic->{required_context}}) {
   ok(exists($error->{$field}), "$diagnostic->{code} carries required context $field");
  }
 }
};

done_testing();
