#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use JSON::PP ();
use Scalar::Util qw(blessed refaddr);
use Test::More;

use LinkedSpec ();
use LinkedSpec::RecognitionTransactionRuntime ();

sub slurp_json {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $document = <$fh>;
 close $fh or die "cannot close $path: $!";
 return JSON::PP->new->decode($document)
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

sub compile_rejection {
 my ($source) = @_;
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
 return ($parser, $runtime_ctx{last_error} // {})
}

sub build_parser {
 my ($source, $label) = @_;
 my %runtime_ctx;
 my $parser = LinkedSpec::Get(\$source, runtime_ctx_ref => \%runtime_ctx);
 ok(ref($parser) eq 'CODE', "$label compiles") or diag explain $runtime_ctx{last_error};
 return ($parser, \%runtime_ctx)
}

sub run_parser {
 my ($parser, $input) = @_;
 my $runtime_input = $input;
 my ($value, $error);
 my $ok = eval {
  $value = $parser->(\$runtime_input);
  1
 };
 $error = $@;
 return ($value, $error, $runtime_input, pos($runtime_input))
}

sub observation_event {
 my ($rewriter) = @_;
 my @events = grep {
  ref($_) eq 'HASH' && ($_->{kind} // '') eq 'OBSERVE_RECOGNITION'
 } @{$rewriter->{canonical_action_ir_events} // []};
 return $events[0]
}

sub expected_position {
 my ($offset) = @_;
 return {source_id => 'input', offset => $offset}
}

sub expected_span {
 my ($start, $end) = @_;
 return {
  source_id => 'input',
  start => $start,
  end => $end,
  provenance => 'match',
 }
}

sub assert_observation {
 my ($actual, $expected, $label) = @_;
 is_deeply(
  $actual,
  {
   source_id => 'input',
   rule_label => $expected->{rule_label},
   invocation_id => $expected->{invocation_id},
   parent_invocation_id => $expected->{parent_invocation_id},
   entry_position => expected_position($expected->{entry_offset}),
   selected_match => defined($expected->{match_start})
    ? expected_span($expected->{match_start}, $expected->{match_end})
    : undef,
   accepted_exit => defined($expected->{exit_offset})
    ? expected_position($expected->{exit_offset})
    : undef,
   outcome => $expected->{outcome},
   diagnostic => $expected->{diagnostic},
  },
  $label,
 )
}

sub private_observation_attempt {
 my (%args) = @_;
 my $input = 'x';
 my $descriptor = {spec => {}};
 my $info = {};
 my $boundary = 0;
 my $ancestor;
 if (defined($args{ancestor_rule})) {
  $ancestor = LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
   $descriptor,
   \$input,
   $info,
   \$boundary,
   $args{ancestor_rule},
  );
 }
 my $parent = LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
  $descriptor,
  \$input,
  $info,
  \$boundary,
  $args{parent_rule},
 );
 $descriptor->{spec}{$args{callee}} = sub {
  my ($descr, $string_ref, $child_info) = @_;
  my $child_boundary = pos($$string_ref) // 0;
  my $child = LinkedSpec::RecognitionTransactionRuntime::enter_invocation(
   $descr,
   $string_ref,
   $child_info,
   \$child_boundary,
   $args{callee},
  );
  die $args{error};
 };

 my $observation;
 my ($value, $caught);
 my $ok = eval {
  $value = LinkedSpec::RecognitionTransactionRuntime::observe_static(
   $descriptor,
   \$input,
   $info,
   \$boundary,
   \$observation,
   $args{callee},
   $args{parent_rule},
   undef,
  );
  1
 };
 $caught = $@;
 undef $parent;
 undef $ancestor;
 return ($ok, $value, $caught, $observation)
}

my $contract_path = File::Spec->catfile(
 $Bin,
 '..',
 'capability_conformance',
 'typed_source_location_contract.json',
);
my $contract = slurp_json($contract_path);
my $recursive = $contract->{recursive_observation_state_machine};

is(
 $recursive->{authored_surface}{request},
 'value = observe_recognition(observation, call(Child))',
 'loads the exact neutral recursive-observation spelling',
);
is_deeply(
 $recursive->{carrier_projection}{fields},
 [qw(
  source_id rule_label invocation_id parent_invocation_id entry_position
  selected_match accepted_exit outcome diagnostic
 )],
 'loads the exact ordered nine-field detached carrier',
);

subtest 'dedicated authored lowering and static policy' => sub {
 my $source = <<'SPEC';
Top::
 I {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation["outcome"]))
 }
Child::AND
 /x/ -> Child { return(0) }
SPEC
 my ($descriptor, $runtime_ctx) = compile_descriptor($source);
 ok(ref($descriptor) eq 'HASH', 'valid recursive observation compiles to a descriptor')
  or diag explain $runtime_ctx->{last_error};
 my $rewriter = ref($descriptor) eq 'HASH'
  ? $descriptor->{spec}{Top}{meta}{action_rewriter}
  : {};
 my $event = observation_event($rewriter);
 is_deeply(
  $event->{args},
  {
   result => 'value',
   target => 'observation',
   operand => 'call(Child)',
   callee => 'Child',
  },
  'dedicated ActionIR preserves result, harray target, unevaluated operand, and static callee',
 );
 is_deeply(
  [grep { $_ eq 'CALL' || $_ eq 'ASSIGN' }
   @{$rewriter->{canonical_action_ir_nodes} // []}],
  [],
  'the special form is not duplicated as an ordinary call or assignment',
 );
 is($rewriter->{unresolved_helper_count}, 0, 'valid recursive observation leaves no unresolved helper');

 my $lowered = LinkedSpec::call_spec_handler_subst(
  'Top',
  'value = observe_recognition(observation, call(Child))',
 );
 like(
  $lowered,
  qr/RecognitionTransactionRuntime::observe_static/,
  'authored form lowers through the private recursive-observation runtime seam',
 );
 unlike($lowered, qr/UNSUPPORTED_ACTIONIR_HELPER/, 'lowering has no unsupported-helper fallback');
 unlike($lowered, qr/&\{\$\$descr\{spec\}\{Child\}/, 'lowering does not eagerly lower the child call');

 my ($bad_target_parser, $bad_target) = compile_rejection(<<'SPEC');
Top::
 I { value = observe_recognition(observation["nested"], call(Child)); return(value) }
Child::AND
 /x/
SPEC
 ok(!defined($bad_target_parser), 'non-bare observation target rejects before execution');
 is($bad_target->{code}, 'source_location_recursive_observation_target', 'target rejection has the exact portable code');
 is($bad_target->{stage}, 'recursive_observation_policy', 'target rejection is owned by recursive-observation policy');
 is($bad_target->{rule_role}, 'Top', 'target diagnostic carries the owning rule');
 is($bad_target->{source_id}, 'input', 'target diagnostic carries source identity without source text');
 is($bad_target->{binding_name}, 'observation["nested"]', 'target diagnostic carries the rejected binding expression');

 my ($bad_operand_parser, $bad_operand) = compile_rejection(<<'SPEC');
Top::
 I { value = observe_recognition(observation, dynamic_child); return(value) }
Child::AND
 /x/
SPEC
 ok(!defined($bad_operand_parser), 'non-static-call observation operand rejects before execution');
 is($bad_operand->{code}, 'source_location_recursive_observation_operand', 'operand rejection has the exact portable code');
 is($bad_operand->{operand_kind}, 'bare_value', 'operand diagnostic classifies the rejected shape');

 my ($bad_arity_parser, $bad_arity) = compile_rejection(<<'SPEC');
Top::
 I { value = observe_recognition(); return(value) }
Child::AND
 /x/ -> Child { return(1) }
SPEC
 ok(!defined($bad_arity_parser), 'missing observation operands reject before execution');
 is($bad_arity->{code}, 'source_location_recursive_observation_target', 'missing target uses the exact target diagnostic');
 is($bad_arity->{binding_name}, '', 'missing target preserves an empty rejected binding name');

 my ($transaction_parser, $transaction_error) = compile_rejection(<<'SPEC');
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Observer))
  recognition_rollback(tx)
  return(matched)
 }
Observer:
 I { value = observe_recognition(observation, call(Child)); return(value) }
Child::AND
 /x/ -> Child { return(1) }
SPEC
 ok(!defined($transaction_parser), 'recursive observation is rejected inside bounded recognition');
 is($transaction_error->{code}, 'recognition_effect_forbidden', 'transaction rejection uses the closed effect diagnostic');
 is($transaction_error->{effect}, 'binding_write', 'recursive observation is classified as a binding write');
};

subtest 'accepted falsey payloads and failed selection' => sub {
 for my $case (
  ['zero', '0', 0],
  ['empty', '""', ''],
  ['undef', 'undef', undef],
 ) {
  my ($label, $payload_source, $expected_payload) = @$case;
  my $source = <<"SPEC";
Top::
 I {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }
Child::AND
 /x/ -> Child { return($payload_source) }
SPEC
  my ($parser) = build_parser($source, "$label payload program");
  next unless ref($parser) eq 'CODE';
  my ($value, $error) = run_parser($parser, 'x');
  is($error, '', "$label payload returns normally");
  is_deeply($value->[0], $expected_payload, "$label child payload is unchanged");
  assert_observation(
   $value->[1],
   {
    rule_label => 'Child', invocation_id => 2, parent_invocation_id => 1,
    entry_offset => 0, match_start => 0, match_end => 1, exit_offset => 1,
    outcome => 'accepted', diagnostic => undef,
   },
   "$label accepted observation is exact",
  );
 }

 my $failure_source = <<'SPEC';
Top::
 I {
  value = observe_recognition(observation, call(Missing))
  return(array(value, observation))
 }
Missing::AND
 /z/ -> Missing { return(1) }
SPEC
 my ($failure_parser) = build_parser($failure_source, 'failed-selection program');
 if (ref($failure_parser) eq 'CODE') {
  my ($value, $error) = run_parser($failure_parser, 'x');
  is($error, '', 'failed selection returns normally');
  is($value->[0], undef, 'failed child payload remains undef');
  assert_observation(
   $value->[1],
   {
    rule_label => 'Missing', invocation_id => 2, parent_invocation_id => 1,
    entry_offset => 0, exit_offset => undef,
    outcome => 'failed', diagnostic => undef,
   },
   'failed selection binds before returning',
  );
 }
};

subtest 'entry state, terminal match, cursor ownership, and detachment' => sub {
 my $edge_source = <<'SPEC';
Top::
 /a/ -> Top {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }
Child::AND
 /b/
 /c/
 -> Child[0] { first = match_text() }
 -> Child[1] { return(array(entry_text(), entry_start_pos())) }
SPEC
 my ($edge_parser) = build_parser($edge_source, 'action-edge program');
 if (ref($edge_parser) eq 'CODE') {
  my ($value, $error) = run_parser($edge_parser, 'abc');
  is($error, '', 'action-edge observation returns normally');
  is_deeply($value->[0], ['a', 0], 'action edge carries the selected parent match into child entry state');
  assert_observation(
   $value->[1],
   {
    rule_label => 'Child', invocation_id => 2, parent_invocation_id => 1,
    entry_offset => 1, match_start => 2, match_end => 3, exit_offset => 3,
    outcome => 'accepted', diagnostic => undef,
   },
   'AND child owns consume policy and terminal local match replaces the initial selection',
  );

  $value->[1]{entry_position}{offset} = 99;
  $value->[1]{selected_match}{start} = 99;
  my ($again, $again_error) = run_parser($edge_parser, 'abc');
  is($again_error, '', 'same parser executes again after detached-record mutation');
  is($again->[1]{invocation_id}, 2, 'a fresh parse restarts its parse-local invocation authority');
  is($again->[1]{entry_position}{offset}, 1, 'entry position is recursively detached');
  is($again->[1]{selected_match}{start}, 2, 'selected span is recursively detached');
 }

 my $zero_source = <<'SPEC';
Top::
 I {
  value = observe_recognition(observation, call(Coordinator))
  return(array(value, observation))
 }
Coordinator:
 I { return("coordinated") }
SPEC
 my ($zero_parser) = build_parser($zero_source, 'zero-regex coordinator program');
 if (ref($zero_parser) eq 'CODE') {
  my ($value, $error) = run_parser($zero_parser, '');
  is($error, '', 'zero-regex coordinator returns normally');
  is($value->[0], 'coordinated', 'zero-regex coordinator payload is unchanged');
  assert_observation(
   $value->[1],
   {
    rule_label => 'Coordinator', invocation_id => 2, parent_invocation_id => 1,
    entry_offset => 0, exit_offset => 0,
    outcome => 'accepted', diagnostic => undef,
   },
   'zero-regex coordinator has no invented selected match',
  );
 }

 my $seek_source = <<'SPEC';
Top::
 I {
  value = observe_recognition(observation, call(SeekChild))
  return(array(value, observation))
 }
SeekChild:
 /a/ -> SeekChild { return("seek") }
SPEC
 my ($seek_parser) = build_parser($seek_source, 'seek-family program');
 if (ref($seek_parser) eq 'CODE') {
  my ($value, $error) = run_parser($seek_parser, 'xxa');
  is($error, '', 'seek-family child returns normally');
  is($value->[0], 'seek', 'OR/default child finds its own later match');
  is($value->[1]{entry_position}{offset}, 0, 'entry remains the caller cursor before child seek');
  is($value->[1]{selected_match}{start}, 2, 'selected match records the child-owned seek result');
  is($value->[1]{accepted_exit}{offset}, 3, 'accepted exit records the resumed caller cursor');
 }
};

subtest 'aborted and rejected boundaries bind before unchanged failure propagation' => sub {
 my $sentinel = bless {}, 'Local::RecursiveObservationAbort';
 my ($abort_ok, undef, $abort_error, $abort_observation) = private_observation_attempt(
  parent_rule => 'AbortParent',
  callee => 'AbortChild',
  error => $sentinel,
 );
 ok(!$abort_ok, 'aborted child propagates failure');
 is(refaddr($abort_error), refaddr($sentinel), 'aborted child propagates the identical typed failure object');
 assert_observation(
  $abort_observation,
  {
   rule_label => 'AbortChild', invocation_id => 2, parent_invocation_id => 1,
   entry_offset => 0, exit_offset => undef,
   outcome => 'aborted', diagnostic => undef,
  },
  'aborted child binds a detached record before propagation',
 );

 for my $case (
  ['direct', 'DirectRecur', 'DirectRecur', 'source_location_nonprogress_direct_recursion'],
  ['mutual', 'MutualB', 'MutualA', 'source_location_nonprogress_mutual_recursion'],
 ) {
  my ($label, $parent_rule, $callee, $diagnostic) = @$case;
  my ($ok, undef, $error, $observation) = private_observation_attempt(
   ($label eq 'mutual' ? (ancestor_rule => 'MutualA') : ()),
   parent_rule => $parent_rule,
   callee => $callee,
   error => $sentinel,
  );
  ok(!$ok, "$label non-progress rejection propagates failure");
  isa_ok($error, 'LinkedSpec::SourceLocation::Error');
  is(
   blessed($error) ? $error->{code} : undef,
   $diagnostic,
   "$label rejection preserves the exact typed diagnostic",
  );
  assert_observation(
   $observation,
   {
    rule_label => $callee,
    invocation_id => $label eq 'direct' ? 2 : 3,
    parent_invocation_id => $label eq 'direct' ? 1 : 2,
    entry_offset => 0, exit_offset => undef,
    outcome => 'rejected', diagnostic => $diagnostic,
   },
   "$label rejection reserves a fresh attempted-child identity without a frame",
  );
 }
};

subtest 'actual recursion guards and independently loaded generated source' => sub {
 my $direct_source = <<'SPEC';
Top::
 I { value = observe_recognition(top_observation, call(DirectRecur)); return(value) }
DirectRecur:
 I { value = observe_recognition(observation, call(DirectRecur)); return(value) }
SPEC
 my ($direct_parser) = build_parser($direct_source, 'direct-recursion program');
 if (ref($direct_parser) eq 'CODE') {
  my (undef, $error) = run_parser($direct_parser, 'x');
  isa_ok($error, 'LinkedSpec::SourceLocation::Error');
  is(
   blessed($error) ? $error->{code} : undef,
   'source_location_nonprogress_direct_recursion',
   'actual direct recursion guard keeps the portable code',
  );
 }

 my $mutual_source = <<'SPEC';
Top::
 I { value = observe_recognition(top_observation, call(MutualA)); return(value) }
MutualA:
 I { value = observe_recognition(observation_a, call(MutualB)); return(value) }
MutualB:
 I { value = observe_recognition(observation_b, call(MutualA)); return(value) }
SPEC
 my ($mutual_parser) = build_parser($mutual_source, 'mutual-recursion program');
 if (ref($mutual_parser) eq 'CODE') {
  my (undef, $error) = run_parser($mutual_parser, 'x');
  isa_ok($error, 'LinkedSpec::SourceLocation::Error');
  is(
   blessed($error) ? $error->{code} : undef,
   'source_location_nonprogress_mutual_recursion',
   'actual mutual recursion guard keeps the portable code',
  );
 }

 my $generated_source = <<'SPEC';
Top::
 I {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }
Child::AND
 /x/ -> Child { return(0) }
SPEC
 my $emitted = LinkedSpec::emit_generated_source(
  \$generated_source,
  source_identity => 'recursive-observation.spec',
 );
 like($emitted, qr/RecognitionTransactionRuntime::observe_static/, 'emitted source carries the private observation route');
 unlike($emitted, qr/UNSUPPORTED_ACTIONIR_HELPER:observe_recognition/, 'emitted source has no dormant fallback');
 my $loaded = eval "package Local::RecursiveObservationGenerated; $emitted; 1";
 ok($loaded, 'recursive-observation generated source loads independently') or diag($@);
 if ($loaded) {
  my $input = 'x';
  my $value = Local::RecursiveObservationGenerated::Execute(\$input);
  is($value->[0], 0, 'independently loaded source preserves falsey child payload');
  assert_observation(
   $value->[1],
   {
    rule_label => 'Child', invocation_id => 2, parent_invocation_id => 1,
    entry_offset => 0, match_start => 0, match_end => 1, exit_offset => 1,
    outcome => 'accepted', diagnostic => undef,
   },
   'independently loaded source returns the exact detached observation',
  );
 }
};

done_testing;
