#------------------------------------------------------------------------------
# Package: LinkedSpec::RecognitionTransactionRuntime
# Purpose: Bind private recognition transactions to live/generated handlers,
#          real cursor/boundary/marks, falsey-safe acceptance, and progress.
#------------------------------------------------------------------------------
package LinkedSpec::RecognitionTransactionRuntime;

use 5.010;
use strict;
use warnings;

use Scalar::Util qw(blessed refaddr weaken);
use LinkedSpec::RecognitionTransaction ();
use LinkedRE ();

my %CONTEXT_BY_KEY;

sub enter_invocation {
 my ($descr, $string_ref, $info, $boundary_ref, $rule) = @_;
 _internal_error('descriptor must be a hash reference') unless ref($descr) eq 'HASH';
 _internal_error('input must be a scalar reference') unless ref($string_ref) eq 'SCALAR' || ref($string_ref) eq 'REF';
 _internal_error('match info must be a hash reference') unless ref($info) eq 'HASH';
 _internal_error('boundary must be a scalar reference') unless ref($boundary_ref) eq 'SCALAR';
 _required_name($rule, 'rule');

 my $key = refaddr($descr).':'.refaddr($string_ref);
 my $context = $CONTEXT_BY_KEY{$key};
 unless (ref($context) eq 'HASH') {
  my $source_identity = 'perl-input-'.refaddr($string_ref);
  $context = {
   key => $key,
   authority => LinkedSpec::RecognitionTransaction->new(
    source_authority => $string_ref,
    source_identity  => $source_identity,
   ),
   guards => [],
   completions => [],
   recognition_scopes => [],
  };
  $CONTEXT_BY_KEY{$key} = $context;
 }

 my $cursor = _cursor($string_ref);
 if (@{$context->{recognition_scopes}}) {
  my @cycle = map { $_->{rule} } grep {
   ($_->{rule} // '') eq $rule && ($_->{entry_cursor} // -1) == $cursor
  } @{$context->{guards}};
  reject_recursive_zero_progress($descr, $string_ref, $rule) if @cycle;
 }

 $info->{marks} = {} unless ref($info->{marks}) eq 'HASH';
 my $had_prior_marks = exists($info->{marks}{$rule}) ? 1 : 0;
 my $prior_marks = $had_prior_marks ? $info->{marks}{$rule} : undef;
 $info->{marks}{$rule} = {};

 my $boundary = defined($$boundary_ref) ? $$boundary_ref : $cursor;
 my $frame = $context->{authority}->enter_invocation(
  rule => $rule,
  origin => $rule.':handler_entry',
  cursor => $cursor,
  boundary => $boundary,
 );
 my $guard = bless {
  context => $context,
  context_key => $key,
  authority => $context->{authority},
  frame => $frame,
  string_ref => $string_ref,
  info => $info,
  boundary_ref => $boundary_ref,
  rule => $rule,
  entry_cursor => $cursor,
  accepted => 0,
  finished => 0,
  had_prior_marks => $had_prior_marks,
  prior_marks => $prior_marks,
 }, 'LinkedSpec::RecognitionTransactionRuntime::InvocationGuard';
 push @{$context->{guards}}, $guard;
 weaken($context->{guards}[-1]);
 _sync_to_authority($guard);
 return $guard
}

sub begin {
 my ($descr, $string_ref, $info, $boundary_ref, $rule, $token_slot) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 _sync_to_authority($guard);
 return $guard->{authority}->checkpoint(
  frame => $guard->{frame},
  origin => $rule.':'.$token_slot,
 )
}

sub attempt_static {
 my ($descr, $string_ref, $info, $boundary_ref, $token, $callee, $rule) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 unless (defined($callee) && !ref($callee) && $callee =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o) {
  _throw(
   code => 'recognition_static_rule_required',
   rule => $rule,
   origin => $rule.':recognize_once',
   operand => defined($callee) && !ref($callee) ? $callee : '<dynamic>',
  );
 }
 my $entry = $descr->{spec}{$callee};
 my $handler = ref($entry) eq 'CODE' ? $entry
  : ref($entry) eq 'HASH' ? $entry->{handler}
  : undef;
 unless (ref($handler) eq 'CODE') {
  _throw(
   code => 'recognition_static_rule_required',
   rule => $rule,
   origin => $rule.':recognize_once',
   operand => 'call('.$callee.')',
  );
 }

 my $context = $guard->{context};
 my $child_info = $info;
 my $has_dependency_slots = _has_dependency_slots($descr, $callee);
 my $local_regexes = _local_regexes($descr, $callee);
 my $local_match_present = 0;
 if (@$local_regexes) {
  my $local_match = LinkedRE::or(
   $string_ref,
   LinkedRE::oredRE(@$local_regexes),
   'consume',
   $info,
  );
  unless ($local_match) {
   _sync_to_authority($guard);
   return $guard->{authority}->attempt(
    frame => $guard->{frame},
    token => $token,
    matched => 0,
    state => _actual_state($guard),
   );
  }
  my $local_end = _cursor($string_ref);
  pos($$string_ref) = $local_end;
  $child_info = $local_match;
  $local_match_present = 1;
 }
 my $completion_count = scalar @{$context->{completions}};
 my $start = _cursor($string_ref);
 push @{$context->{recognition_scopes}}, {
  rule => $rule,
  callee => $callee,
  origin => $rule.':recognize_once',
  start_offset => $start,
 };
 my ($payload, $ok, $error);
 $ok = eval {
  $payload = $handler->($descr, $string_ref, $child_info);
  1
 };
 $error = $@;
 pop @{$context->{recognition_scopes}};
 die $error unless $ok;

 my $completion = @{$context->{completions}} > $completion_count
  ? pop @{$context->{completions}}
  : undef;
 _internal_error('static recognition child did not publish one invocation completion')
  unless ref($completion) eq 'HASH' && ($completion->{rule} // '') eq $callee;
 splice @{$context->{completions}}, $completion_count
  if @{$context->{completions}} > $completion_count;

 _sync_to_authority($guard);
 return $guard->{authority}->attempt(
  frame => $guard->{frame},
  token => $token,
  matched => $has_dependency_slots
   ? ($completion->{accepted} ? 1 : 0)
   : ($local_match_present ? 1 : ($completion->{accepted} ? 1 : 0)),
  state => _actual_state($guard),
  payload => $payload,
 )
}

sub _local_regexes {
 my ($descr, $callee) = @_;
 my $entry = $descr->{spec}{$callee};
 return [@{$entry->{re}}] if ref($entry) eq 'HASH' && ref($entry->{re}) eq 'ARRAY';
 my $map = $descr->{recognition_regex_map};
 return [@{$map->{$callee}}] if ref($map) eq 'HASH' && ref($map->{$callee}) eq 'ARRAY';
 return []
}

sub _has_dependency_slots {
 my ($descr, $callee) = @_;
 my $entry = $descr->{spec}{$callee};
 return 1 if ref($entry) eq 'HASH'
  && ref($entry->{dependency_refs}) eq 'ARRAY'
  && @{$entry->{dependency_refs}};
 my $slots = $descr->{dependency_slot_map};
 return 1 if ref($slots) eq 'HASH'
  && ref($slots->{$callee}) eq 'ARRAY'
  && @{$slots->{$callee}};
 return 0
}

sub finish_commit {
 my ($descr, $string_ref, $info, $boundary_ref, $token, $rule) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 _sync_to_authority($guard);
 my $payload = $guard->{authority}->commit(frame => $guard->{frame}, token => $token);
 _apply_authority_state($guard);
 if (blessed($payload) && $payload->isa('JSON::PP::Boolean')) {
  return $payload ? 1 : 0;
 }
 return $payload
}

sub finish_rollback {
 my ($descr, $string_ref, $info, $boundary_ref, $token, $rule) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 _sync_to_authority($guard);
 $guard->{authority}->rollback(frame => $guard->{frame}, token => $token);
 _apply_authority_state($guard);
 return undef
}

sub note_match {
 my ($descr, $string_ref, $rule, $handler_kind, $start, $end) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 $guard->{accepted} = 1;
 if (@{$guard->{context}{recognition_scopes}}
  && defined($handler_kind) && $handler_kind =~ /\Arep(?:_|\z)/o
  && defined($start) && defined($end) && $end <= $start) {
  my $scope = $guard->{context}{recognition_scopes}[-1];
  _throw(
   code => 'recognition_zero_progress_repetition',
   rule => $rule,
   origin => $scope->{origin},
   start_offset => $start,
   end_offset => $end,
  );
 }
 return 1
}

sub note_miss {
 my ($descr, $string_ref, $rule) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 $guard->{accepted} = 0;
 return 0
}

sub result_is_match {
 my ($descr, $string_ref, $value) = @_;
 my $context = _context($descr, $string_ref);
 return $value ? 1 : 0
  unless ref($context) eq 'HASH' && @{$context->{recognition_scopes}};
 my $completion = pop @{$context->{completions}};
 return ref($completion) eq 'HASH' ? ($completion->{accepted} ? 1 : 0) : ($value ? 1 : 0)
}

sub assert_repetition_progress {
 my ($descr, $string_ref, $rule, $start, $end) = @_;
 my $context = _context($descr, $string_ref);
 return 1 unless ref($context) eq 'HASH' && @{$context->{recognition_scopes}};
 return 1 unless defined($start) && defined($end) && $end <= $start;
 my $scope = $context->{recognition_scopes}[-1];
 _throw(
  code => 'recognition_zero_progress_repetition',
  rule => $rule,
  origin => $scope->{origin},
  start_offset => $start,
  end_offset => $end,
 )
}

sub recognition_active {
 my ($descr, $string_ref) = @_;
 my $context = _context($descr, $string_ref);
 return ref($context) eq 'HASH' && @{$context->{recognition_scopes}} ? 1 : 0
}

sub reject_recursive_zero_progress {
 my ($descr, $string_ref, $rule) = @_;
 my $context = _context($descr, $string_ref);
 return 0 unless ref($context) eq 'HASH' && @{$context->{recognition_scopes}};
 my $scope = $context->{recognition_scopes}[-1];
 my @cycle = map { $_->{rule} } @{$context->{guards}};
 push @cycle, $rule;
 my $offset = _cursor($string_ref);
 _throw(
  code => 'recognition_zero_progress_recursive_cycle',
  rule => $rule,
  origin => $scope->{origin},
  cycle => join('->', @cycle),
  start_offset => $offset,
  end_offset => $offset,
 )
}

sub is_error {
 my ($error) = @_;
 return blessed($error) && $error->isa('LinkedSpec::RecognitionTransaction::Error') ? 1 : 0
}

sub _context {
 my ($descr, $string_ref) = @_;
 return undef unless ref($descr) eq 'HASH' && ref($string_ref);
 return $CONTEXT_BY_KEY{refaddr($descr).':'.refaddr($string_ref)}
}

sub _current_guard {
 my ($descr, $string_ref, $rule) = @_;
 my $context = _context($descr, $string_ref);
 _internal_error('no active recognition invocation') unless ref($context) eq 'HASH';
 my $guard = $context->{guards}[-1];
 _internal_error('recognition invocation stack is empty') unless ref($guard) eq 'LinkedSpec::RecognitionTransactionRuntime::InvocationGuard';
 _internal_error("active recognition invocation belongs to '$guard->{rule}', not '$rule'")
  unless ($guard->{rule} // '') eq ($rule // '');
 return $guard
}

sub _cursor {
 my ($string_ref) = @_;
 my $cursor = pos($$string_ref);
 unless (defined $cursor) {
  pos($$string_ref) = 0;
  return 0;
 }
 return 0 + $cursor
}

sub _actual_state {
 my ($guard) = @_;
 my $marks = $guard->{info}{marks}{$guard->{rule}};
 $marks = {} unless ref($marks) eq 'HASH';
 return {
  cursor => _cursor($guard->{string_ref}),
  boundary => ${$guard->{boundary_ref}},
  marks => {%$marks},
 }
}

sub _sync_to_authority {
 my ($guard) = @_;
 $guard->{authority}->set_frame_state(
  frame => $guard->{frame},
  state => _actual_state($guard),
 );
 return
}

sub _apply_authority_state {
 my ($guard) = @_;
 my $state = $guard->{authority}->frame_snapshot(frame => $guard->{frame});
 pos(${$guard->{string_ref}}) = $state->{cursor};
 ${$guard->{boundary_ref}} = $state->{boundary};
 $guard->{info}{marks}{$guard->{rule}} = {%{$state->{marks}}};
 return
}

sub _finish_guard {
 my ($guard) = @_;
 return if $guard->{finished};
 $guard->{finished} = 1;
 my $context = $guard->{context};
 _internal_error('recognition invocation guards must leave in stack order')
  unless @{$context->{guards}}
   && ref($context->{guards}[-1])
   && refaddr($context->{guards}[-1]) == refaddr($guard);
 _sync_to_authority($guard);
 my $leave_ok = eval {
  $guard->{authority}->leave_invocation(frame => $guard->{frame});
  1
 };
 my $leave_error = $@;
 pop @{$context->{guards}};
 if ($leave_ok && @{$context->{recognition_scopes}}) {
  push @{$context->{completions}}, {
   rule => $guard->{rule},
   accepted => $guard->{accepted} ? 1 : 0,
   start_offset => $guard->{entry_cursor},
   end_offset => _cursor($guard->{string_ref}),
  };
 }
 if ($guard->{had_prior_marks}) {
  $guard->{info}{marks}{$guard->{rule}} = $guard->{prior_marks};
 } else {
  delete $guard->{info}{marks}{$guard->{rule}};
 }
 delete $CONTEXT_BY_KEY{$guard->{context_key}} unless @{$context->{guards}};
 die $leave_error unless $leave_ok;
 return
}

sub _required_name {
 my ($value, $label) = @_;
 _internal_error("$label must be a bare identifier")
  unless defined($value) && !ref($value) && $value =~ /\A[A-Za-z_][A-Za-z0-9_]*\z/o;
 return $value
}

sub _throw {
 die LinkedSpec::RecognitionTransaction::Error->new(@_)
}

sub _internal_error {
 my ($detail) = @_;
 die "(LinkedSpec::RecognitionTransactionRuntime) -E- $detail\n"
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::RecognitionTransactionRuntime::InvocationGuard
# Purpose: Balance source handler frames on every return and exception path.
#------------------------------------------------------------------------------
package LinkedSpec::RecognitionTransactionRuntime::InvocationGuard;

use 5.010;
use strict;
use warnings;

sub DESTROY {
 my ($self) = @_;
 return if $self->{finished};
 my $prior_error = $@;
 my $ok = eval {
  LinkedSpec::RecognitionTransactionRuntime::_finish_guard($self);
  1
 };
 my $finish_error = $@;
 die $finish_error unless $ok || $prior_error;
 return
}

1;
