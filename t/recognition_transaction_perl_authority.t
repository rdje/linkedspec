#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../perl";
use File::Spec ();
use Hash::Util ();
use JSON::PP ();
use Scalar::Util qw(reftype);
use Test::More;

use LinkedSpec::RecognitionTransaction ();
use LinkedSpec::SourceLocation ();

sub slurp_json {
 my ($path) = @_;
 open my $fh, '<:encoding(UTF-8)', $path or die "cannot read $path: $!";
 local $/;
 my $document = <$fh>;
 close $fh or die "cannot close $path: $!";
 return JSON::PP->new->decode($document)
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
 'private authority consumes the frozen neutral transaction contract',
);

my %diagnostic_by_code = map {
 ($_->{code} => $_)
} @{$contract->{diagnostics}};

sub new_authority {
 my (%args) = @_;
 my $source_identity = $args{source_identity} // 'input.spec';
 my $source_authority = LinkedSpec::SourceLocation->new(
  sources => {input => 'abcdef'},
 );
 my $authority = LinkedSpec::RecognitionTransaction->new(
  source_authority => $source_authority,
  source_identity  => $source_identity,
 );
 return ($source_authority, $authority)
}

sub enter_frame {
 my ($authority, %args) = @_;
 return $authority->enter_invocation(
  rule     => $args{rule} // 'Top',
  origin   => $args{origin} // 'Top->Child',
  cursor   => defined($args{cursor}) ? $args{cursor} : 2,
  boundary => defined($args{boundary}) ? $args{boundary} : 1,
 )
}

sub seed_origin_mark {
 my ($authority, $frame) = @_;
 $authority->write_mark(
  frame  => $frame,
  name   => 'a',
  offset => 1,
 );
 return
}

sub initial_state {
 return {
  cursor   => 2,
  boundary => 1,
  marks    => {a => 1},
 }
}

sub staged_state {
 return {
  cursor   => 5,
  boundary => 4,
  marks    => {a => 3, b => 4},
 }
}

sub capture_error {
 my ($label, $operation) = @_;
 my $ok = eval {
  $operation->();
  1
 };
 ok(!$ok, "$label rejects");
 my $error = $@;
 isa_ok($error, 'LinkedSpec::RecognitionTransaction::Error', "$label error");
 return $error
}

sub verify_diagnostic {
 my ($label, $error, $code, $expected) = @_;
 my $contract_diagnostic = $diagnostic_by_code{$code};
 ok(ref($contract_diagnostic) eq 'HASH', "$label diagnostic exists in neutral contract");
 is($error->{code}, $code, "$label uses exact portable code");
 is_deeply(
  [sort keys %$error],
  [sort @{$contract_diagnostic->{fields}}],
  "$label exposes exactly the neutral diagnostic fields",
 );
 for my $field (keys %$expected) {
  is($error->{$field}, $expected->{$field}, "$label preserves $field");
 }
 is(
  "$error",
  "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:$code",
  "$label has deterministic stringification",
 );
 return
}

sub attempt_candidate {
 my ($authority, $frame, $token, %args) = @_;
 return $authority->attempt(
  token   => $token,
  frame   => $frame,
  matched => $args{matched},
  payload => $args{payload},
  state   => $args{matched} ? staged_state() : initial_state(),
 )
}

sub payload_from_operation {
 my ($operation) = @_;
 return 0 if $operation eq 'attempt_match:false';
 return 0 if $operation eq 'attempt_match:0';
 return '' if $operation eq 'attempt_match:';
 return undef if $operation eq 'attempt_match:null';
 return 'value' if $operation eq 'attempt_match:value';
 die "unknown neutral payload operation: $operation"
}

subtest 'authority, invocation frames, and transaction tokens are opaque scalars' => sub {
 my ($source_authority, $authority) = new_authority();
 is(reftype($authority), 'SCALAR', 'authority storage is opaque');
 my $frame = enter_frame($authority);
 is(reftype($frame), 'SCALAR', 'invocation frame storage is opaque');
 my $token = $authority->checkpoint(frame => $frame, origin => 'Top->Child');
 is(reftype($token), 'SCALAR', 'transaction token storage is opaque');
 ok(!$INC{'LinkedSpec.pm'}, 'private authority does not load the public facade');
 ok(!$INC{'LinkedSpec/Compiler.pm'}, 'private authority does not load the compiler');
 ok(!$INC{'LinkedSpec/SpecEntry.pm'}, 'private authority does not load rule execution');
 ok(!$INC{'LinkedSpec/GeneratedSource.pm'}, 'private authority does not load generated-source emission');
 my $missing_attempt = capture_error('opaque token without attempt', sub {
  $authority->rollback(token => $token, frame => $frame)
 });
 verify_diagnostic(
  'opaque token without attempt',
  $missing_attempt,
  'recognition_attempt_count',
  {rule => 'Top', origin => 'Top->Child', count => 0},
 );
 $authority->leave_invocation(frame => $frame);
};

subtest 'invocation ids and mark generations are monotonic and same-label recursive frames are isolated' => sub {
 my ($source_authority, $authority) = new_authority();
 my $parent = enter_frame($authority, rule => 'Top', origin => 'root', cursor => 0, boundary => 0);
 $authority->write_mark(frame => $parent, name => 'shared', offset => 1);
 my $parent_snapshot = $authority->frame_snapshot(frame => $parent);

 my $child = enter_frame($authority, rule => 'Top', origin => 'Top->Top', cursor => 1, boundary => 1);
 my $child_snapshot = $authority->frame_snapshot(frame => $child);
 cmp_ok($child_snapshot->{invocation}, '>', $parent_snapshot->{invocation}, 'recursive invocation id increases');
 cmp_ok($child_snapshot->{generation}, '>', $parent_snapshot->{generation}, 'recursive mark generation increases');
 is($authority->read_mark(frame => $child, name => 'shared'), undef, 'recursive child starts with fresh marks');
 $authority->write_mark(frame => $child, name => 'shared', offset => 2);
 is($authority->read_mark(frame => $child, name => 'shared'), 2, 'child writes only its invocation marks');
 is($authority->read_mark(frame => $parent, name => 'shared'), 1, 'child cannot overwrite parent same-label mark');
 $authority->leave_invocation(frame => $child);

 my $next = enter_frame($authority, rule => 'Top', origin => 'Top->Top:next', cursor => 1, boundary => 1);
 my $next_snapshot = $authority->frame_snapshot(frame => $next);
 cmp_ok($next_snapshot->{invocation}, '>', $child_snapshot->{invocation}, 'left invocation id is not reused');
 cmp_ok($next_snapshot->{generation}, '>', $child_snapshot->{generation}, 'left mark generation is not reused');
 $authority->leave_invocation(frame => $next);

 my $detached = $authority->frame_snapshot(frame => $parent);
 $detached->{marks}{shared} = 99;
 is($authority->read_mark(frame => $parent, name => 'shared'), 1, 'detached frame snapshots cannot mutate marks');
 $authority->leave_invocation(frame => $parent);

 my $stale = capture_error('left invocation generation', sub {
  $authority->frame_snapshot(frame => $parent)
 });
 verify_diagnostic(
  'left invocation generation',
  $stale,
  'recognition_mark_generation_invalid',
  {rule => 'Top', origin => 'root', generation => $parent_snapshot->{generation}},
 );
};

subtest 'all eight neutral positive token cases preserve match and staged payload separately' => sub {
 for my $fixture (@{$contract->{fixtures}{token_positive}}) {
  my ($source_authority, $authority) = new_authority();
  my $frame = enter_frame($authority);
  seed_origin_mark($authority, $frame);
  my $token = $authority->checkpoint(frame => $frame, origin => $fixture->{id});
  my ($attempt_operation) = grep { /\Aattempt_/ } @{$fixture->{ops}};
  my $matched = $attempt_operation ne 'attempt_miss';
  my $payload = $matched ? payload_from_operation($attempt_operation) : undef;
  my $observed_match = attempt_candidate(
   $authority,
   $frame,
   $token,
   matched => $matched ? 1 : 0,
   payload => $payload,
  );
  is($observed_match, $matched ? 1 : 0, "$fixture->{id} returns strict match presence");

  my $terminal = $fixture->{ops}[-1];
  my $result = $terminal eq 'commit'
   ? $authority->commit(token => $token, frame => $frame)
   : $authority->rollback(token => $token, frame => $frame);
  if ($terminal eq 'commit') {
   if ($matched) {
    is($result, $payload, "$fixture->{id} commits the separately staged payload");
   } else {
    is($result, undef, "$fixture->{id} commit after miss yields undef");
   }
   is_deeply(
    $authority->frame_snapshot(frame => $frame),
    {
     source     => 'input.spec',
     rule       => 'Top',
     invocation => 1,
     generation => 1,
     %{$matched ? staged_state() : initial_state()},
    },
    "$fixture->{id} commit retains candidate cursor, boundary, and marks",
   );
  } else {
   is($result, undef, "$fixture->{id} rollback has no authored value");
   is_deeply(
    $authority->frame_snapshot(frame => $frame),
    {
     source     => 'input.spec',
     rule       => 'Top',
     invocation => 1,
     generation => 1,
     %{initial_state()},
    },
    "$fixture->{id} rollback restores cursor, boundary, and marks",
   );
  }
  $authority->leave_invocation(frame => $frame);
 }
};

subtest 'all neutral token escape kinds restore and invalidate before diagnostics' => sub {
 my @escape_fixtures = grep {
  ($_->{diagnostic} // '') eq 'recognition_token_escape'
 } @{$contract->{fixtures}{token_negative}};
 is(scalar(@escape_fixtures), 8, 'neutral contract supplies eight explicit token escape kinds');
 for my $fixture (@escape_fixtures) {
  my ($source_authority, $authority) = new_authority();
  my $frame = enter_frame($authority);
  seed_origin_mark($authority, $frame);
  my $token = $authority->checkpoint(frame => $frame, origin => $fixture->{id});
  $authority->set_frame_state(frame => $frame, state => staged_state());
  my $error = capture_error($fixture->{id}, sub {
   $authority->reject_escape(
    token  => $token,
    frame  => $frame,
    escape => $fixture->{violation},
   )
  });
  verify_diagnostic(
   $fixture->{id},
   $error,
   'recognition_token_escape',
   {rule => 'Top', origin => $fixture->{id}, escape => $fixture->{violation}},
  );
  is_deeply(
   {map { ($_ => $authority->frame_snapshot(frame => $frame)->{$_}) } qw(cursor boundary marks)},
   initial_state(),
   "$fixture->{id} restores its complete snapshot before reporting",
  );
  my $reused = capture_error("$fixture->{id} invalidated token", sub {
   attempt_candidate($authority, $frame, $token, matched => 0, payload => undef)
  });
  verify_diagnostic(
   "$fixture->{id} invalidated token",
   $reused,
   'recognition_token_reused',
   {rule => 'Top', origin => $fixture->{id}, operation => 'attempt'},
  );
  $authority->leave_invocation(frame => $frame);
 }
};

subtest 'attempt, terminal, nesting, authority, and boolean misuse are fail-closed' => sub {
 my ($source_authority, $authority) = new_authority();

 my $missing_frame = enter_frame($authority, origin => 'missing-token');
 my $missing_token = capture_error('non-token operand', sub {
  attempt_candidate($authority, $missing_frame, {}, matched => 0, payload => undef)
 });
 verify_diagnostic(
  'non-token operand',
  $missing_token,
  'recognition_token_expected',
  {rule => 'Top', origin => 'missing-token'},
 );
 $authority->leave_invocation(frame => $missing_frame);

 my $retry_frame = enter_frame($authority, origin => 'retry');
 my $retry_token = $authority->checkpoint(frame => $retry_frame, origin => 'retry');
 attempt_candidate($authority, $retry_frame, $retry_token, matched => 0, payload => undef);
 my $retry = capture_error('second attempt', sub {
  attempt_candidate($authority, $retry_frame, $retry_token, matched => 1, payload => 'value')
 });
 verify_diagnostic(
  'second attempt',
  $retry,
  'recognition_attempt_count',
  {rule => 'Top', origin => 'retry', count => 2},
 );
 $authority->leave_invocation(frame => $retry_frame);

 my $boolean_frame = enter_frame($authority, origin => 'boolean');
 my $boolean_token = $authority->checkpoint(frame => $boolean_frame, origin => 'boolean');
 my $boolean = capture_error('truthy non-boolean match', sub {
  $authority->attempt(
   token   => $boolean_token,
   frame   => $boolean_frame,
   matched => 'value',
   payload => 'value',
   state   => staged_state(),
  )
 });
 verify_diagnostic(
  'truthy non-boolean match',
  $boolean,
  'recognition_match_boolean_required',
  {rule => 'Top', origin => 'boolean'},
 );
 $authority->leave_invocation(frame => $boolean_frame);

 my $double_frame = enter_frame($authority, origin => 'double');
 my $double_token = $authority->checkpoint(frame => $double_frame, origin => 'double');
 attempt_candidate($authority, $double_frame, $double_token, matched => 1, payload => 'value');
 is($authority->commit(token => $double_token, frame => $double_frame), 'value', 'first terminal succeeds');
 my $double = capture_error('second terminal', sub {
  $authority->rollback(token => $double_token, frame => $double_frame)
 });
 verify_diagnostic(
  'second terminal',
  $double,
  'recognition_token_reused',
  {rule => 'Top', origin => 'double', operation => 'rollback'},
 );
 $authority->leave_invocation(frame => $double_frame);

 my $unwind_frame = enter_frame($authority, origin => 'unwind');
 my $unwind_token = $authority->checkpoint(frame => $unwind_frame, origin => 'unwind');
 attempt_candidate($authority, $unwind_frame, $unwind_token, matched => 1, payload => 'value');
 my $unwind = capture_error('missing terminal on invocation exit', sub {
  $authority->leave_invocation(frame => $unwind_frame)
 });
 verify_diagnostic(
  'missing terminal on invocation exit',
  $unwind,
  'recognition_terminal_required',
  {rule => 'Top', origin => 'unwind'},
 );

 my $parent = enter_frame($authority, rule => 'Top', origin => 'parent', cursor => 0, boundary => 0);
 my $parent_token = $authority->checkpoint(frame => $parent, origin => 'parent');
 my $child = enter_frame($authority, rule => 'Child', origin => 'child', cursor => 0, boundary => 0);
 my $nested = capture_error('descendant transaction nesting', sub {
  $authority->checkpoint(frame => $child, origin => 'child')
 });
 verify_diagnostic(
  'descendant transaction nesting',
  $nested,
  'recognition_nesting_forbidden',
  {rule => 'Child', origin => 'child'},
 );
 $authority->leave_invocation(frame => $child);
 $authority->leave_invocation(frame => $parent);
};

subtest 'cross-invocation and cross-source token use invalidate the owning snapshot' => sub {
 my ($source_authority, $authority) = new_authority(source_identity => 'a.spec');
 my $parent = enter_frame($authority, rule => 'Top', origin => 'parent', cursor => 2, boundary => 1);
 seed_origin_mark($authority, $parent);
 my $token = $authority->checkpoint(frame => $parent, origin => 'parent');
 $authority->set_frame_state(frame => $parent, state => staged_state());
 my $child = enter_frame($authority, rule => 'Child', origin => 'child', cursor => 2, boundary => 1);
 my $child_snapshot = $authority->frame_snapshot(frame => $child);
 my $cross_invocation = capture_error('cross-invocation token', sub {
  attempt_candidate($authority, $child, $token, matched => 0, payload => undef)
 });
 verify_diagnostic(
  'cross-invocation token',
  $cross_invocation,
  'recognition_cross_invocation',
  {
   rule                => 'Child',
   origin              => 'child',
   expected_invocation => $child_snapshot->{invocation},
   actual_invocation   => 1,
  },
 );
 is_deeply(
  {map { ($_ => $authority->frame_snapshot(frame => $parent)->{$_}) } qw(cursor boundary marks)},
  initial_state(),
  'cross-invocation failure restores the owning parent snapshot',
 );
 $authority->leave_invocation(frame => $child);
 $authority->leave_invocation(frame => $parent);

 my ($source_a, $authority_a) = new_authority(source_identity => 'a.spec');
 my $frame_a = enter_frame($authority_a, origin => 'a');
 seed_origin_mark($authority_a, $frame_a);
 my $token_a = $authority_a->checkpoint(frame => $frame_a, origin => 'a');
 $authority_a->set_frame_state(frame => $frame_a, state => staged_state());
 my ($source_b, $authority_b) = new_authority(source_identity => 'b.spec');
 my $frame_b = enter_frame($authority_b, origin => 'b');
 my $cross_source = capture_error('cross-source token', sub {
  attempt_candidate($authority_b, $frame_b, $token_a, matched => 0, payload => undef)
 });
 verify_diagnostic(
  'cross-source token',
  $cross_source,
  'recognition_cross_source',
  {
   rule            => 'Top',
   origin          => 'b',
   expected_source => 'b.spec',
   actual_source   => 'a.spec',
  },
 );
 is_deeply(
  {map { ($_ => $authority_a->frame_snapshot(frame => $frame_a)->{$_}) } qw(cursor boundary marks)},
  initial_state(),
  'cross-source failure restores the token-owning source snapshot',
 );
 $authority_b->leave_invocation(frame => $frame_b);
 $authority_a->leave_invocation(frame => $frame_a);
};

subtest 'private state never aliases compatibility cursor-stack storage' => sub {
 my $compatibility = {
  cursor_stack => [3, 7],
  marks        => {Top => {legacy => 9}},
 };
 my ($source_authority, $authority) = new_authority();
 my $frame = enter_frame($authority);
 seed_origin_mark($authority, $frame);
 my $token = $authority->checkpoint(frame => $frame, origin => 'compatibility-isolation');
 attempt_candidate($authority, $frame, $token, matched => 1, payload => 0);
 is($authority->commit(token => $token, frame => $frame), 0, 'private commit preserves falsey payload');
 $authority->leave_invocation(frame => $frame);
 is_deeply(
  $compatibility,
  {
   cursor_stack => [3, 7],
   marks        => {Top => {legacy => 9}},
  },
  'private authority has no route to compatibility cursor stack or rule-label marks',
 );
};

done_testing();
