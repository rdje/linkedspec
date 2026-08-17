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
use LinkedSpec::SourceLocation ();
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
   observation_scopes => [],
  };
  $CONTEXT_BY_KEY{$key} = $context;
 }

 my $cursor = _cursor($string_ref);
 if (@{$context->{observation_scopes}}) {
  my @cycle = grep {
   ($_->{rule} // '') eq $rule && ($_->{entry_cursor} // -1) == $cursor
  } @{$context->{guards}};
  reject_recursive_observation($descr, $string_ref, $rule) if @cycle;
 }
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
 my $identity = $context->{authority}->recursive_observation_identity(frame => $frame);
 my $guard = bless {
  context => $context,
  context_key => $key,
  authority => $context->{authority},
  frame => $frame,
  identity => $identity,
  string_ref => $string_ref,
  info => $info,
  boundary_ref => $boundary_ref,
  rule => $rule,
  entry_cursor => $cursor,
  accepted => 0,
  selected_match_start => undef,
  selected_match_end => undef,
  gap_phase => 'I',
  gap_state => undef,
  gap_snapshots => {},
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
 my $token = $guard->{authority}->checkpoint(
  frame => $guard->{frame},
  origin => $rule.':'.$token_slot,
 );
 if (ref($guard->{gap_state}) eq 'HASH') {
  $guard->{gap_snapshots}{refaddr($token)} = {
   committed_gap_cursor => $guard->{gap_state}{committed_gap_cursor},
   accepted_edge_count => $guard->{gap_state}{accepted_edge_count},
   current_gap => ref($guard->{gap_state}{current_gap}) eq 'HASH'
    ? {%{$guard->{gap_state}{current_gap}}}
    : undef,
  };
 }
 return $token
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

sub observe_static {
 my (
  $descr,
  $string_ref,
  $info,
  $boundary_ref,
  $target_ref,
  $callee,
  $rule,
  $entry_match_info,
 ) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 _internal_error('recursive observation target must be a scalar reference')
  unless ref($target_ref) eq 'SCALAR' || ref($target_ref) eq 'REF';
 _required_name($callee, 'recursive observation callee');
 my $entry = $descr->{spec}{$callee};
 my $handler = ref($entry) eq 'CODE' ? $entry
  : ref($entry) eq 'HASH' ? $entry->{handler}
  : undef;
 _internal_error("recursive observation callee '$callee' has no handler")
  unless ref($handler) eq 'CODE';

 my $child_info;
 if (ref($entry_match_info) eq 'HASH') {
  $child_info = $entry_match_info;
  $child_info->{source_location} = $info->{source_location}
   if !exists($child_info->{source_location}) && exists($info->{source_location});
  $child_info->{source_location_source_id} = $info->{source_location_source_id}
   if !exists($child_info->{source_location_source_id})
    && exists($info->{source_location_source_id});
  $child_info->{marks} = $info->{marks}
   if !exists($child_info->{marks}) && exists($info->{marks});
 } else {
  $child_info = {
   (exists($info->{source_location})
    ? (source_location => $info->{source_location}) : ()),
   (exists($info->{source_location_source_id})
    ? (source_location_source_id => $info->{source_location_source_id}) : ()),
   (exists($info->{marks}) ? (marks => $info->{marks}) : ()),
  };
 }

 my $context = $guard->{context};
 my $completion_count = scalar @{$context->{completions}};
 my $scope = {
  rule => $rule,
  callee => $callee,
  origin => $rule.':observe_recognition',
  target_ref => $target_ref,
  terminal_record => undef,
 };
 push @{$context->{observation_scopes}}, $scope;
 my ($payload, $ok, $error);
 $ok = eval {
  $payload = $handler->($descr, $string_ref, $child_info);
  1
 };
 $error = $@;
 pop @{$context->{observation_scopes}};

 if (ref($scope->{terminal_record}) eq 'HASH') {
  splice @{$context->{completions}}, $completion_count
   if @{$context->{completions}} > $completion_count;
  die $error unless $ok;
  _internal_error('rejected recursive observation returned without its typed failure')
 }

 my $completion = @{$context->{completions}} > $completion_count
  ? pop @{$context->{completions}}
  : undef;
 _internal_error('recursive observation child did not publish one invocation completion')
  unless ref($completion) eq 'HASH' && ($completion->{rule} // '') eq $callee;
 splice @{$context->{completions}}, $completion_count
  if @{$context->{completions}} > $completion_count;

 my $has_recognition_structure = @{_local_regexes($descr, $callee)}
  || _has_dependency_slots($descr, $callee);
 my $accepted = $ok
  ? ($has_recognition_structure ? ($completion->{accepted} ? 1 : 0) : 1)
  : 0;
 my $outcome = $ok ? ($accepted ? 'accepted' : 'failed') : 'aborted';
 my $record = _observation_record(
  info => $child_info,
  string_ref => $string_ref,
  identity => $completion->{identity},
  entry_offset => $completion->{start_offset},
  selected_match_start => $completion->{selected_match_start},
  selected_match_end => $completion->{selected_match_end},
  accepted_exit_offset => $accepted ? $completion->{end_offset} : undef,
  outcome => $outcome,
  diagnostic => undef,
 );
 $$target_ref = $record;
 die $error unless $ok;
 return $payload
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
 delete $guard->{gap_snapshots}{refaddr($token)};
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
 my $snapshot = delete $guard->{gap_snapshots}{refaddr($token)};
 if (ref($snapshot) eq 'HASH' && ref($guard->{gap_state}) eq 'HASH') {
  $guard->{gap_state} = {
   committed_gap_cursor => $snapshot->{committed_gap_cursor},
   accepted_edge_count => $snapshot->{accepted_edge_count},
   current_gap => ref($snapshot->{current_gap}) eq 'HASH'
    ? {%{$snapshot->{current_gap}}}
    : undef,
  };
 }
 return undef
}

sub note_match {
 my ($descr, $string_ref, $rule, $handler_kind, $start, $end) = @_;
 my $guard = _current_guard($descr, $string_ref, $rule);
 $guard->{accepted} = 1;
 $guard->{selected_match_start} = $start;
 $guard->{selected_match_end} = $end;
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

sub recursive_observation_active {
 my ($descr, $string_ref) = @_;
 my $context = _context($descr, $string_ref);
 return ref($context) eq 'HASH' && @{$context->{observation_scopes}} ? 1 : 0
}

sub reject_recursive_observation {
 my ($descr, $string_ref, $rule) = @_;
 my $context = _context($descr, $string_ref);
 _internal_error('recursive observation rejection has no active context')
  unless ref($context) eq 'HASH' && @{$context->{observation_scopes}};
 my $scope = $context->{observation_scopes}[-1];
 _internal_error("recursive observation rejection expected '$scope->{callee}', not '$rule'")
  unless ($scope->{callee} // '') eq ($rule // '');
 my $guard = $context->{guards}[-1];
 _internal_error('recursive observation rejection has no active parent invocation')
  unless ref($guard) eq 'LinkedSpec::RecognitionTransactionRuntime::InvocationGuard';

 my $diagnostic = ($scope->{rule} // '') eq ($rule // '')
  ? 'source_location_nonprogress_direct_recursion'
  : 'source_location_nonprogress_mutual_recursion';
 my $identity = $guard->{authority}->reserve_rejected_invocation(
  rule => $rule,
  origin => $scope->{origin},
 );
 my $offset = _cursor($string_ref);
 my $record = _observation_record(
  info => $guard->{info},
  string_ref => $string_ref,
  identity => $identity,
  entry_offset => $offset,
  selected_match_start => undef,
  selected_match_end => undef,
  accepted_exit_offset => undef,
  outcome => 'rejected',
  diagnostic => $diagnostic,
 );
 ${$scope->{target_ref}} = $record;
 $scope->{terminal_record} = $record;
 my $source_id = $record->{source_id};
 die LinkedSpec::SourceLocation::Error->new(
  code => $diagnostic,
  phase => 'progress',
  rule_role => $rule,
  invocation_role => 'rejected_child',
  source_id => $source_id,
  start_offset => $offset,
  end_offset => $offset,
  originating_edge_or_job => $scope->{origin},
 )
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

sub is_recursive_observation_error {
 my ($error) = @_;
 return 0 unless blessed($error) && $error->isa('LinkedSpec::SourceLocation::Error');
 my $code = $error->{code} // '';
 return (
  $code eq 'source_location_nonprogress_direct_recursion'
  || $code eq 'source_location_nonprogress_mutual_recursion'
 ) ? 1 : 0
}

sub _observation_record {
 my (%args) = @_;
 my $identity = $args{identity};
 _internal_error('recursive observation identity must be a hash reference')
  unless ref($identity) eq 'HASH';
 my $entry_position = LinkedSpec::SourceLocation::Runtime::detached_position_record(
  $args{info},
  $args{string_ref},
  $args{entry_offset},
  'recursive_observation_entry',
 );
 my $selected_match = LinkedSpec::SourceLocation::Runtime::detached_span_record(
  $args{info},
  $args{string_ref},
  $args{selected_match_start},
  $args{selected_match_end},
  'match',
 );
 my $accepted_exit = LinkedSpec::SourceLocation::Runtime::detached_position_record(
  $args{info},
  $args{string_ref},
  $args{accepted_exit_offset},
  'recursive_observation_exit',
 );
 return {
  source_id => $entry_position->{source_id},
  rule_label => $identity->{rule_label},
  invocation_id => $identity->{invocation_id},
  parent_invocation_id => $identity->{parent_invocation_id},
  entry_position => $entry_position,
  selected_match => $selected_match,
  accepted_exit => $accepted_exit,
  outcome => $args{outcome},
  diagnostic => $args{diagnostic},
 }
}

sub _context {
 my ($descr, $string_ref) = @_;
 return undef unless ref($descr) eq 'HASH' && ref($string_ref);
 return $CONTEXT_BY_KEY{refaddr($descr).':'.refaddr($string_ref)}
}

sub transaction_active {
 my ($descr, $string_ref) = @_;
 my $context = _context($descr, $string_ref);
 return 0 unless ref($context) eq 'HASH'
  && blessed($context->{authority})
  && $context->{authority}->isa('LinkedSpec::RecognitionTransaction');
 return $context->{authority}->has_active_transaction() ? 1 : 0
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
 if ($leave_ok && (
  @{$context->{recognition_scopes}}
  || @{$context->{observation_scopes}}
 )) {
  push @{$context->{completions}}, {
   rule => $guard->{rule},
   identity => {%{$guard->{identity}}},
   accepted => $guard->{accepted} ? 1 : 0,
   start_offset => $guard->{entry_cursor},
   end_offset => _cursor($guard->{string_ref}),
   selected_match_start => $guard->{selected_match_start},
   selected_match_end => $guard->{selected_match_end},
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
