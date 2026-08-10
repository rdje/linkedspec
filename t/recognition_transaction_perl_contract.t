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

sub slurp_json {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $document = <$fh>;
 close $fh or die "cannot close $path: $!";
 return JSON::PP->new->decode($document)
}

sub fixture_ids {
 my ($rows) = @_;
 return [map { $_->{id} } @$rows]
}

sub compile_descriptor {
 my ($source) = @_;
 my %runtime_ctx;
 my $descriptor = LinkedSpec::Get(
  \$source,
  return_descriptor => 1,
  runtime_ctx_ref   => \%runtime_ctx,
 );
 return ($descriptor, \%runtime_ctx)
}

sub run_spec {
 my ($source, $input, $label) = @_;
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
 ok(ref($parser) eq 'CODE', "$label compiles");
 return (undef, \%runtime_ctx) unless ref($parser) eq 'CODE';
 my $runtime_input = $input;
 return ($parser->(\$runtime_input), \%runtime_ctx)
}

sub compile_rejection {
 my ($source) = @_;
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
 return ($parser, $runtime_ctx{last_error} // {})
}

sub transaction_event_by_kind {
 my ($rewriter, $kind) = @_;
 my @events = grep {
  ref($_) eq 'HASH' && ($_->{kind} // '') eq $kind
 } @{$rewriter->{canonical_action_ir_events} // []};
 return $events[0]
}

sub transaction_spec {
 my (%args) = @_;
 my $terminal = $args{terminal};
 my $payload = $args{payload};
 my $terminal_source = $terminal eq 'commit'
  ? <<'COMMIT'
  payload = recognition_commit(tx)
  return(array(matched, payload, cursor_pos(), mark_pos(origin)))
COMMIT
  : <<'ROLLBACK';
  recognition_rollback(tx)
  return(array(matched, cursor_pos(), mark_pos(origin)))
ROLLBACK

 return <<"SPEC";
Top::
 I {
  mark_here(origin)
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
$terminal_source }
 /never/
Child::AND
 /c/ -> Payload { return($payload) }
Payload::AND
 /d/
SPEC
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'recognition_transaction_contract.json',
);
my $contract = slurp_json($contract_path);

is(
 $contract->{contract_id},
 'linkedspec-recognition-transaction-v1',
 'loads the frozen recognition-transaction contract',
);
is($contract->{format}, 1, 'loads contract format 1');
is(
 $contract->{status},
 'neutral_complete_backends_red',
 'loads the neutral-complete and backend-RED rollout state',
);

is_deeply(
 $contract->{authored_surface},
 {
  checkpoint        => 'tx = recognition_checkpoint()',
  attempt           => 'matched = recognize_once(tx, call(Child))',
  commit            => 'payload = recognition_commit(tx)',
  rollback          => 'recognition_rollback(tx)',
  operand           => 'recognize_once accepts exactly one unevaluated static call(Rule) operand',
  result_separation => 'recognize_once returns a strict match boolean; the recognized payload remains staged until commit',
  availability      => 'future and unavailable in every backend until its rollout leg is admitted',
 },
 'freezes all four authored forms and their static operand/result boundary',
);

is_deeply(
 fixture_ids($contract->{fixtures}{token_positive}),
 [qw(
  commit_false commit_zero commit_empty commit_undef commit_value commit_miss
  rollback_match rollback_miss
 )],
 'freezes all eight falsey-safe, miss, commit, and rollback cases',
);
is_deeply(
 fixture_ids($contract->{fixtures}{token_negative}),
 [qw(
  copied_token compared_token aggregate_token function_token codeblock_token returned_token
  captured_token serialized_token retry nested missing_attempt missing_terminal double_terminal
  cross_invocation cross_source dynamic_rule_operand payload_truthiness
 )],
 'freezes all seventeen linear-token, attempt, terminal, and authority violations',
);
is_deeply(
 fixture_ids($contract->{fixtures}{effect_graphs}),
 [qw(
  acyclic_allowed direct_recursive_allowed mutual_recursive_allowed transitive_forbidden
  recursive_forbidden unknown_effect
 )],
 'freezes all six direct, transitive, recursive, and fail-closed effect graphs',
);
is_deeply(
 fixture_ids($contract->{fixtures}{marks}),
 [qw(
  rollback_restores commit_retains recursive_same_label_isolated stale_generation
  mark_cross_invocation mark_cross_source
 )],
 'freezes all six snapshot, generation, recursive-mark, and authority cases',
);
is_deeply(
 fixture_ids($contract->{fixtures}{progress}),
 [qw(
  repetition_advances direct_recursion_advances mutual_recursion_advances one_shot_zero_width
  repetition_zero direct_recursion_zero mutual_recursion_zero state_change_only
 )],
 'freezes all eight cursor-only repetition and recursive-progress cases',
);

is_deeply(
 $contract->{effect_model}{allowed},
 [qw(
  pure_value source_read structured_control rule_recognition transaction_state cursor_advance
  capture_boundary_write invocation_mark_write staged_return
 )],
 'freezes the exact nine admitted recognition effects',
);
is_deeply(
 $contract->{effect_model}{rejected},
 [qw(
  binding_write aggregate_write ast_or_object_write compatibility_cursor_control output
  authored_diagnostic exit_or_unbounded_control dynamic_callable
  parser_registry_or_staged_dispatch external_or_host unknown_or_raw
 )],
 'freezes the exact eleven rejected recognition effects',
);

my @diagnostic_codes = map { $_->{code} } @{$contract->{diagnostics}};
is_deeply(
 \@diagnostic_codes,
 [qw(
  recognition_token_expected recognition_token_escape recognition_token_reused
  recognition_nesting_forbidden recognition_cross_invocation recognition_cross_source
  recognition_attempt_count recognition_terminal_required recognition_effect_forbidden
  recognition_unknown_effect recognition_zero_progress_repetition
  recognition_zero_progress_recursive_cycle recognition_static_rule_required
  recognition_match_boolean_required recognition_mark_generation_invalid
 )],
 'freezes all fifteen portable structured diagnostic codes in order',
);
for my $diagnostic (@{$contract->{diagnostics}}) {
 is($diagnostic->{fields}[0], 'code', "$diagnostic->{code} starts with its portable code field");
 ok(
  !grep({ !defined($_) || $_ !~ /\A[a-z][a-z0-9_]*\z/ } @{$diagnostic->{fields}}),
  "$diagnostic->{code} freezes only portable scalar field names",
 );
}

is($contract->{expected_counts}{token_positive_cases}, 8, 'neutral count locks eight positive token cases');
is($contract->{expected_counts}{token_negative_cases}, 17, 'neutral count locks seventeen negative token cases');
is($contract->{expected_counts}{effect_graph_cases}, 6, 'neutral count locks six effect graphs');
is($contract->{expected_counts}{mark_cases}, 6, 'neutral count locks six mark cases');
is($contract->{expected_counts}{progress_cases}, 8, 'neutral count locks eight progress cases');
is($contract->{expected_counts}{diagnostics}, 15, 'neutral count locks fifteen diagnostics');

my $authored_source = <<'SPEC';
Top::
 /t/ -> Child {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  if(matched)
   payload = recognition_commit(tx)
   return(payload)
  else
   recognition_rollback(tx)
  endif
 }
Child::
 /c/
 I { return(0) }
SPEC

my ($descriptor, $descriptor_ctx) = compile_descriptor($authored_source);
ok(ref($descriptor) eq 'HASH', 'the exact future authored surface reaches descriptor construction')
 or diag(JSON::PP->new->canonical(1)->encode($descriptor_ctx->{last_error} // {}));

my $rewriter = ref($descriptor) eq 'HASH'
 ? $descriptor->{spec}{Top}{meta}{action_rewriter}
 : {};
my @required_nodes = qw(
 RECOGNITION_CHECKPOINT RECOGNIZE_ONCE RECOGNITION_COMMIT RECOGNITION_ROLLBACK
);
my %observed_node = map { ($_ => 1) } @{$rewriter->{canonical_action_ir_nodes} // []};
my @missing_nodes = grep { !$observed_node{$_} } @required_nodes;
my @unresolved_helpers = @{$rewriter->{unresolved_helpers} // []};
my $raw_dependency_count = $rewriter->{raw_perl_dependency_count} // 0;
my $descriptor_ready =
 !@missing_nodes
 && !@unresolved_helpers
 && !$raw_dependency_count
 && ($rewriter->{language_agnostic_action_ir_ready} // 0);

ok(
 $descriptor_ready,
 'Perl lowers the four transaction forms to dedicated language-agnostic ActionIR',
);
diag(
 'expected RED: missing nodes=[' . join(',', @missing_nodes)
 . ']; unresolved helpers=[' . join(',', @unresolved_helpers)
 . "]; raw dependencies=$raw_dependency_count",
) unless $descriptor_ready;

SKIP: {
 skip 'future Perl recognition-transaction ActionIR is unavailable', 1
  unless $descriptor_ready;

 subtest 'neutral transaction behavior executes live and from standalone generated source' => sub {
  is_deeply(
   transaction_event_by_kind($rewriter, 'RECOGNITION_CHECKPOINT')->{args},
   {token => 'tx'},
   'checkpoint ActionIR owns the direct local token slot',
  );
  is_deeply(
   transaction_event_by_kind($rewriter, 'RECOGNIZE_ONCE')->{args},
   {matched => 'matched', token => 'tx', callee => 'Child', operand => 'call(Child)'},
   'attempt ActionIR preserves one unevaluated static child operand and strict-boolean slot',
  );
  is_deeply(
   transaction_event_by_kind($rewriter, 'RECOGNITION_COMMIT')->{args},
   {payload => 'payload', token => 'tx'},
   'commit ActionIR owns the staged-payload binding exception',
  );
  is_deeply(
   transaction_event_by_kind($rewriter, 'RECOGNITION_ROLLBACK')->{args},
   {token => 'tx'},
   'rollback ActionIR is statement-only and owns no authored value',
  );

  subtest 'static operand and transitive effect barriers fail before recognition' => sub {
   my @cases = (
    {
     id => 'dynamic operand',
     code => 'recognition_static_rule_required',
     source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, Child)
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 /c/
SPEC
    },
    {
     id => 'copied token',
     code => 'recognition_token_escape',
     source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  copy = tx
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 /c/
SPEC
    },
    {
     id => 'missing terminal',
     code => 'recognition_terminal_required',
     source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  return(matched)
 }
 /never/
Child::
 /c/
SPEC
    },
    {
     id => 'attempt before checkpoint',
     code => 'recognition_token_expected',
     source => <<'SPEC',
Top::
 I {
  matched = recognize_once(tx, call(Child))
  tx = recognition_checkpoint()
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 /c/
SPEC
    },
    {
     id => 'terminal before attempt',
     code => 'recognition_terminal_required',
     source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  recognition_rollback(tx)
  matched = recognize_once(tx, call(Child))
  return(matched)
 }
 /never/
Child::
 /c/
SPEC
    },
    {
     id => 'direct forbidden output effect',
     code => 'recognition_effect_forbidden',
     effect => 'output',
     source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 I { say("forbidden") }
 /c/
SPEC
    },
    {
     id => 'transitive forbidden binding effect',
     code => 'recognition_effect_forbidden',
     effect => 'binding_write',
     source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 I { return(call(Grandchild)) }
 /c/
Grandchild::
 I { value = 1 }
 /d/
SPEC
    },
    {
     id => 'unknown raw effect',
     code => 'recognition_unknown_effect',
     effect => 'unknown_or_raw',
     source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 I { future_unclassified_helper() }
 /c/
SPEC
    },
   );
   for my $case (@cases) {
    my ($parser, $error) = compile_rejection($case->{source});
    ok(!defined($parser), "$case->{id} rejects during parser construction");
    is($error->{code}, $case->{code}, "$case->{id} reports the portable code");
    is($error->{effect}, $case->{effect}, "$case->{id} reports the classified effect")
     if exists $case->{effect};
    ok(defined($error->{rule}) && length($error->{rule}), "$case->{id} reports the owning rule");
    ok(defined($error->{origin}) && length($error->{origin}), "$case->{id} reports the authored origin");
   }
  };

  my %payload_source = (
   commit_false => 'false',
   commit_zero  => '0',
   commit_empty => '""',
   commit_undef => 'undef',
   commit_value => '"value"',
   commit_miss  => '"unreached"',
  );
  my %expected_payload = (
   commit_false => 0,
   commit_zero  => 0,
   commit_empty => '',
   commit_undef => undef,
   commit_value => 'value',
   commit_miss  => undef,
  );

  for my $fixture (@{$contract->{fixtures}{token_positive}}) {
   my $id = $fixture->{id};
   my $terminal = $id =~ /\Acommit_/ ? 'commit' : 'rollback';
   my $matched = $id !~ /_miss\z/;
   my $payload = $payload_source{$id} // '"value"';
   my $source = transaction_spec(terminal => $terminal, payload => $payload);
   my $input = $matched ? 'cd' : 'z';
   my ($result, $ctx) = run_spec($source, $input, $id);
   my $expected = $terminal eq 'commit'
    ? [$matched ? 1 : 0, $expected_payload{$id}, $matched ? 2 : 0, 0]
    : [$matched ? 1 : 0, 0, 0];
   is_deeply($result, $expected, "$id preserves the neutral match/payload/cursor result");
   ok(!exists($ctx->{last_error}), "$id leaves structured runtime diagnostics clear");
  }

  my $compatibility_source = <<'SPEC';
Top::
 I {
  saved = save_cursor()
  restored = restore_cursor()
  return(array(saved, restored, cursor_pos()))
 }
 /never/
SPEC
  my ($compatibility_result, $compatibility_ctx) = run_spec(
   $compatibility_source,
   'input',
   'compatibility cursor-stack control',
  );
  is_deeply(
   $compatibility_result,
   [undef, undef, 0],
   'save/restore remains an independent compatibility stack rather than a transaction token',
  );
  ok(!exists($compatibility_ctx->{last_error}), 'compatibility cursor-stack diagnostics remain clear');

  my $zero_width_repetition_source = <<'SPEC';
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child:+
 /(?=c)/ -> Child { return("zero") }
SPEC
  my ($zero_width_parser, $zero_width_ctx) = compile_rejection($zero_width_repetition_source);
  ok(ref($zero_width_parser) eq 'CODE', 'zero-width repetition transaction compiles before runtime progress validation');
  if (ref($zero_width_parser) eq 'CODE') {
   my $input = 'c';
   my $run_ok = eval { $zero_width_parser->(\$input); 1 };
   ok(!$run_ok, 'accepted zero-width repetition rejects at runtime');
   my $error = $@;
   is(ref($error), 'LinkedSpec::RecognitionTransaction::Error', 'progress rejection remains a typed transaction error');
   is($error->{code}, 'recognition_zero_progress_repetition', 'repetition rejection reports its portable code');
   is($error->{start_offset}, 0, 'repetition rejection reports its start offset');
   is($error->{end_offset}, 0, 'repetition rejection reports its end offset');
  }

  my $one_shot_zero_width_source = <<'SPEC';
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(array(matched, cursor_pos()))
 }
 /never/
Child::AND
 /(?=c)/
SPEC
  my ($one_shot_result, $one_shot_ctx) = run_spec(
   $one_shot_zero_width_source,
   'c',
   'one-shot zero-width recognition',
  );
  is_deeply($one_shot_result, [1, 0], 'one-shot zero-width recognition remains legal');
  ok(!exists($one_shot_ctx->{last_error}), 'one-shot zero-width recognition leaves diagnostics clear');

  my @recursive_progress_cases = (
   {
    id => 'direct recursive zero progress',
    cycle => 'Top->Child->Child',
    source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 I { return(call(Child)) }
 /(?=c)/
SPEC
   },
   {
    id => 'mutual recursive zero progress',
    cycle => 'Top->Child->Other->Child',
    source => <<'SPEC',
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  recognition_rollback(tx)
  return(matched)
 }
 /never/
Child::
 I { return(call(Other)) }
 /(?=c)/
Other::
 I { return(call(Child)) }
 /(?=c)/
SPEC
   },
  );
  for my $case (@recursive_progress_cases) {
   my ($parser, $ctx) = compile_rejection($case->{source});
   ok(ref($parser) eq 'CODE', "$case->{id} compiles before runtime progress validation");
   next unless ref($parser) eq 'CODE';
   my $input = 'c';
   my $ok = eval { $parser->(\$input); 1 };
   my $error = $@;
   ok(!$ok, "$case->{id} rejects at runtime");
   is(ref($error), 'LinkedSpec::RecognitionTransaction::Error', "$case->{id} remains typed");
   if (ref($error) eq 'LinkedSpec::RecognitionTransaction::Error') {
    is($error->{code}, 'recognition_zero_progress_recursive_cycle', "$case->{id} reports its portable code");
    is($error->{cycle}, $case->{cycle}, "$case->{id} reports the exact active cycle");
    is($error->{start_offset}, 0, "$case->{id} reports its start offset");
    is($error->{end_offset}, 0, "$case->{id} reports its end offset");
   }
  }

  my $generated_recursive_source = LinkedSpec::emit_generated_source(
   \$recursive_progress_cases[1]{source},
   source_identity => 'recognition-transaction-mutual-recursion.spec',
  );
  my $recursive_package = 'LinkedSpec::RecognitionTransactionRecursiveGenerated';
  my $recursive_loaded = eval "package $recursive_package; $generated_recursive_source; 1";
  ok($recursive_loaded, 'mutual-recursion transaction source loads independently') or diag($@);
  if ($recursive_loaded) {
   no strict 'refs';
   my $input = 'c';
   my $ok = eval { &{$recursive_package . '::Execute'}(\$input); 1 };
   my $error = $@;
   ok(!$ok, 'independent mutual-recursion execution rejects zero progress');
   is(ref($error), 'LinkedSpec::RecognitionTransaction::Error', 'independent recursive progress stays typed');
   is($error->{code}, 'recognition_zero_progress_recursive_cycle', 'independent recursive progress keeps its code')
    if ref($error) eq 'LinkedSpec::RecognitionTransaction::Error';
  }

  my $emitted_fixture = transaction_spec(terminal => 'commit', payload => 'false');
  my $generated_source = LinkedSpec::emit_generated_source(
   \$emitted_fixture,
   source_identity => 'recognition-transaction-perl-contract.spec',
  );
  ok(defined($generated_source) && length($generated_source), 'transaction fixture emits standalone source');
  unlike(
   $generated_source,
   qr/LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER/,
   'standalone transaction source contains no unsupported-helper residue',
  );
  my $package = 'LinkedSpec::RecognitionTransactionPerlContractGenerated';
  my $loaded = eval "package $package; $generated_source; 1";
  ok($loaded, 'standalone transaction source loads') or diag($@);
  if ($loaded) {
   no strict 'refs';
   my $input = 'cd';
   my $generated_result;
   my $execute_ok = eval {
    $generated_result = &{$package . '::Execute'}(\$input);
    1
   };
   ok($execute_ok, 'standalone transaction execution completes') or diag($@);
   is_deeply(
    $generated_result,
    [1, 0, 2, 0],
    'standalone transaction execution preserves falsey payload and committed cursor',
   ) if $execute_ok;
  }
 };
}

done_testing();
