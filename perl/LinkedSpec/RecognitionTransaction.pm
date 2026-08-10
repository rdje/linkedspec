#------------------------------------------------------------------------------
# Package: LinkedSpec::RecognitionTransaction
# Purpose: Own private Perl recognition invocation frames, linear transaction
#          tokens, snapshots, staged results, and terminal invalidation.
#------------------------------------------------------------------------------
package LinkedSpec::RecognitionTransaction;

use 5.010;
use strict;
use warnings;

use Hash::Util ();
use Scalar::Util qw(blessed refaddr reftype);

my %AUTHORITY_STATE_BY_ADDRESS;
my %FRAME_STATE_BY_ADDRESS;
my %TOKEN_STATE_BY_ADDRESS;
my $NEXT_AUTHORITY_ID = 1;

sub new {
 my ($class, %args) = @_;
 my $source_authority = $args{source_authority};
 _internal_error('source_authority must be a reference') unless ref($source_authority);
 my $source_identity = _required_scalar($args{source_identity}, 'source_identity');

 my $token = 0;
 my $self = bless \$token, $class;
 $AUTHORITY_STATE_BY_ADDRESS{refaddr($self)} = {
  authority_id       => $NEXT_AUTHORITY_ID++,
  source_authority   => $source_authority,
  source_address     => refaddr($source_authority),
  source_identity    => $source_identity,
  next_invocation_id => 1,
  next_generation    => 1,
  next_transaction_id => 1,
  invocation_stack  => [],
  active_token_by_frame => {},
 };
 return $self
}

sub enter_invocation {
 my ($self, %args) = @_;
 my $authority = _authority_state($self);
 my $rule = _required_scalar($args{rule}, 'invocation rule');
 my $origin = _required_scalar($args{origin}, 'invocation origin');
 my $cursor = _nonnegative_integer($args{cursor}, 'invocation cursor');
 my $boundary = _optional_nonnegative_integer($args{boundary}, 'invocation boundary');

 my $invocation_id = $authority->{next_invocation_id}++;
 my $generation = $authority->{next_generation}++;
 my $token = 0;
 my $frame = bless \$token, 'LinkedSpec::RecognitionTransaction::Frame';
 my $frame_address = refaddr($frame);
 $FRAME_STATE_BY_ADDRESS{$frame_address} = {
  authority_address => refaddr($self),
  authority_id      => $authority->{authority_id},
  source_address    => $authority->{source_address},
  source_identity   => $authority->{source_identity},
  rule              => $rule,
  origin            => $origin,
  invocation_id     => $invocation_id,
  generation        => $generation,
  active            => 1,
  cursor            => $cursor,
  boundary          => $boundary,
  marks             => {},
 };
 push @{$authority->{invocation_stack}}, $frame_address;
 return $frame
}

sub leave_invocation {
 my ($self, %args) = @_;
 my $authority = _authority_state($self);
 my $frame = $args{frame};
 my $frame_state = _frame_for_authority($self, $frame, require_active => 1);
 my $frame_address = refaddr($frame);
 my $stack = $authority->{invocation_stack};
 _internal_error('invocation frames must leave in stack order')
  unless @$stack && $stack->[-1] == $frame_address;

 my $active_token_address = $authority->{active_token_by_frame}{$frame_address};
 if (defined $active_token_address) {
  my $token_state = $TOKEN_STATE_BY_ADDRESS{$active_token_address};
  if (ref($token_state) eq 'HASH' && $token_state->{state} ne 'invalidated') {
   _restore_and_invalidate($token_state, terminal => 'unwind');
   pop @$stack;
   $frame_state->{active} = 0;
   _throw_diagnostic(
    code   => 'recognition_terminal_required',
    rule   => $token_state->{rule},
    origin => $token_state->{origin},
   );
  }
 }

 pop @$stack;
 $frame_state->{active} = 0;
 return undef
}

sub frame_snapshot {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 return _detached_frame_snapshot($frame_state)
}

sub set_frame_state {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 my $state = _validated_state_record($args{state}, 'frame state');
 _assign_frame_state($frame_state, $state);
 return _detached_frame_snapshot($frame_state)
}

sub write_mark {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 my $name = _required_scalar($args{name}, 'mark name');
 my $offset = _nonnegative_integer($args{offset}, 'mark offset');
 $frame_state->{marks}{$name} = $offset;
 return $offset
}

sub read_mark {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 my $name = _required_scalar($args{name}, 'mark name');
 return $frame_state->{marks}{$name}
}

sub clear_mark {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 my $name = _required_scalar($args{name}, 'mark name');
 delete $frame_state->{marks}{$name};
 return undef
}

sub checkpoint {
 my ($self, %args) = @_;
 my $authority = _authority_state($self);
 my $frame = $args{frame};
 my $frame_state = _frame_for_authority($self, $frame, require_active => 1);
 my $origin = defined($args{origin})
  ? _required_scalar($args{origin}, 'transaction origin')
  : $frame_state->{origin};

 for my $stack_frame_address (@{$authority->{invocation_stack}}) {
  my $active_token_address = $authority->{active_token_by_frame}{$stack_frame_address};
  next unless defined $active_token_address;
  my $active_token = $TOKEN_STATE_BY_ADDRESS{$active_token_address};
  next unless ref($active_token) eq 'HASH' && $active_token->{state} ne 'invalidated';
  _restore_and_invalidate($active_token, terminal => 'nesting_rejected');
  _throw_diagnostic(
   code   => 'recognition_nesting_forbidden',
   rule   => $frame_state->{rule},
   origin => $origin,
  );
 }

 my $token = 0;
 my $transaction = bless \$token, 'LinkedSpec::RecognitionTransaction::Token';
 my $token_address = refaddr($transaction);
 my $frame_address = refaddr($frame);
 $TOKEN_STATE_BY_ADDRESS{$token_address} = {
  token_address     => $token_address,
  authority_address => refaddr($self),
  authority_id      => $authority->{authority_id},
  source_address    => $authority->{source_address},
  source_identity   => $authority->{source_identity},
  rule              => $frame_state->{rule},
  origin            => $origin,
  invocation_id     => $frame_state->{invocation_id},
  generation        => $frame_state->{generation},
  transaction_id    => $authority->{next_transaction_id}++,
  frame_address     => $frame_address,
  state             => 'active_unattempted',
  attempt_count     => 0,
  matched           => 0,
  payload_present   => 0,
  payload           => undef,
  snapshot          => _state_record($frame_state),
 };
 $authority->{active_token_by_frame}{$frame_address} = $token_address;
 return $transaction
}

sub attempt {
 my ($self, %args) = @_;
 my $frame = $args{frame};
 my $frame_state = _frame_for_authority($self, $frame, require_active => 1);
 my $token_state = _token_for_operation(
  $self,
  $args{token},
  $frame_state,
  operation => 'attempt',
 );

 if ($token_state->{state} ne 'active_unattempted') {
  my $count = $token_state->{attempt_count} + 1;
  _restore_and_invalidate($token_state, terminal => 'attempt_count_rejected');
  _throw_diagnostic(
   code   => 'recognition_attempt_count',
   rule   => $token_state->{rule},
   origin => $token_state->{origin},
   count  => $count,
  );
 }

 my $matched = $args{matched};
 unless (defined($matched) && !ref($matched) && ($matched eq '0' || $matched eq '1')) {
  _restore_and_invalidate($token_state, terminal => 'match_boolean_rejected');
  _throw_diagnostic(
   code   => 'recognition_match_boolean_required',
   rule   => $token_state->{rule},
   origin => $token_state->{origin},
  );
 }

 my $candidate = _validated_state_record($args{state}, 'attempt state');
 _assign_frame_state($frame_state, $candidate);
 $token_state->{attempt_count} = 1;
 $token_state->{matched} = $matched ? 1 : 0;
 $token_state->{payload_present} = $matched ? 1 : 0;
 $token_state->{payload} = $matched && exists($args{payload}) ? $args{payload} : undef;
 $token_state->{state} = $matched ? 'active_staged_match' : 'active_staged_miss';
 return $token_state->{matched}
}

sub commit {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 my $token_state = _token_for_operation(
  $self,
  $args{token},
  $frame_state,
  operation => 'commit',
 );
 _require_attempted($token_state);
 my $matched = $token_state->{matched};
 my $payload = $token_state->{payload};
 _invalidate($token_state, terminal => 'commit');
 return $matched ? $payload : undef
}

sub rollback {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 my $token_state = _token_for_operation(
  $self,
  $args{token},
  $frame_state,
  operation => 'rollback',
 );
 _require_attempted($token_state);
 _restore_and_invalidate($token_state, terminal => 'rollback');
 return undef
}

sub reject_escape {
 my ($self, %args) = @_;
 my $frame_state = _frame_for_authority($self, $args{frame}, require_active => 1);
 my $token_state = _token_for_operation(
  $self,
  $args{token},
  $frame_state,
  operation => 'escape',
 );
 my $escape = _required_scalar($args{escape}, 'token escape kind');
 _restore_and_invalidate($token_state, terminal => 'escape_rejected');
 _throw_diagnostic(
  code   => 'recognition_token_escape',
  rule   => $token_state->{rule},
  origin => $token_state->{origin},
  escape => $escape,
 );
}

sub _require_attempted {
 my ($token_state) = @_;
 return if $token_state->{state} eq 'active_staged_match'
  || $token_state->{state} eq 'active_staged_miss';
 _restore_and_invalidate($token_state, terminal => 'attempt_required');
 _throw_diagnostic(
  code   => 'recognition_attempt_count',
  rule   => $token_state->{rule},
  origin => $token_state->{origin},
  count  => $token_state->{attempt_count},
 );
}

sub _token_for_operation {
 my ($self, $token, $frame_state, %args) = @_;
 my $operation = $args{operation};
 unless (blessed($token) && $token->isa('LinkedSpec::RecognitionTransaction::Token')) {
  _throw_diagnostic(
   code   => 'recognition_token_expected',
   rule   => $frame_state->{rule},
   origin => $frame_state->{origin},
  );
 }
 my $token_state = $TOKEN_STATE_BY_ADDRESS{refaddr($token)};
 unless (ref($token_state) eq 'HASH') {
  _throw_diagnostic(
   code   => 'recognition_token_expected',
   rule   => $frame_state->{rule},
   origin => $frame_state->{origin},
  );
 }

 if ($token_state->{source_address} != $frame_state->{source_address}) {
  _restore_and_invalidate($token_state, terminal => 'cross_source_rejected');
  _throw_diagnostic(
   code            => 'recognition_cross_source',
   rule            => $frame_state->{rule},
   origin          => $frame_state->{origin},
   expected_source => $frame_state->{source_identity},
   actual_source   => $token_state->{source_identity},
  );
 }

 if (
  $token_state->{authority_id} != $frame_state->{authority_id}
  || $token_state->{invocation_id} != $frame_state->{invocation_id}
 ) {
  _restore_and_invalidate($token_state, terminal => 'cross_invocation_rejected');
  _throw_diagnostic(
   code                => 'recognition_cross_invocation',
   rule                => $frame_state->{rule},
   origin              => $frame_state->{origin},
   expected_invocation => $frame_state->{invocation_id},
   actual_invocation   => $token_state->{invocation_id},
  );
 }

 if (
  !$frame_state->{active}
  || $token_state->{generation} != $frame_state->{generation}
 ) {
  _restore_and_invalidate($token_state, terminal => 'generation_rejected');
  _throw_diagnostic(
   code       => 'recognition_mark_generation_invalid',
   rule       => $frame_state->{rule},
   origin     => $frame_state->{origin},
   generation => $token_state->{generation},
  );
 }

 if ($token_state->{state} eq 'invalidated') {
  _throw_diagnostic(
   code      => 'recognition_token_reused',
   rule      => $token_state->{rule},
   origin    => $token_state->{origin},
   operation => $operation,
  );
 }
 return $token_state
}

sub _frame_for_authority {
 my ($self, $frame, %args) = @_;
 my $authority = _authority_state($self);
 _internal_error('invalid invocation frame')
  unless blessed($frame) && $frame->isa('LinkedSpec::RecognitionTransaction::Frame');
 my $frame_state = $FRAME_STATE_BY_ADDRESS{refaddr($frame)};
 _internal_error('expired invocation frame') unless ref($frame_state) eq 'HASH';
 _internal_error('invocation frame belongs to another transaction authority')
  unless $frame_state->{authority_id} == $authority->{authority_id};
 if ($args{require_active} && !$frame_state->{active}) {
  _throw_diagnostic(
   code       => 'recognition_mark_generation_invalid',
   rule       => $frame_state->{rule},
   origin     => $frame_state->{origin},
   generation => $frame_state->{generation},
  );
 }
 return $frame_state
}

sub _authority_state {
 my ($self) = @_;
 _internal_error('invalid transaction authority')
  unless blessed($self) && $self->isa(__PACKAGE__) && reftype($self) eq 'SCALAR';
 my $state = $AUTHORITY_STATE_BY_ADDRESS{refaddr($self)};
 _internal_error('expired transaction authority') unless ref($state) eq 'HASH';
 return $state
}

sub _state_record {
 my ($frame_state) = @_;
 return {
  cursor   => $frame_state->{cursor},
  boundary => $frame_state->{boundary},
  marks    => {%{$frame_state->{marks}}},
 }
}

sub _detached_frame_snapshot {
 my ($frame_state) = @_;
 return {
  source     => $frame_state->{source_identity},
  rule       => $frame_state->{rule},
  invocation => $frame_state->{invocation_id},
  generation => $frame_state->{generation},
  cursor     => $frame_state->{cursor},
  boundary   => $frame_state->{boundary},
  marks      => {%{$frame_state->{marks}}},
 }
}

sub _validated_state_record {
 my ($state, $label) = @_;
 _internal_error("$label must be a hash reference") unless ref($state) eq 'HASH';
 my $cursor = _nonnegative_integer($state->{cursor}, "$label cursor");
 my $boundary = _optional_nonnegative_integer($state->{boundary}, "$label boundary");
 my $marks = $state->{marks};
 _internal_error("$label marks must be a hash reference") unless ref($marks) eq 'HASH';
 my %owned_marks;
 for my $name (keys %$marks) {
  _required_scalar($name, "$label mark name");
  $owned_marks{$name} = _nonnegative_integer($marks->{$name}, "$label mark offset");
 }
 return {
  cursor   => $cursor,
  boundary => $boundary,
  marks    => \%owned_marks,
 }
}

sub _assign_frame_state {
 my ($frame_state, $state) = @_;
 $frame_state->{cursor} = $state->{cursor};
 $frame_state->{boundary} = $state->{boundary};
 $frame_state->{marks} = {%{$state->{marks}}};
 return
}

sub _restore_and_invalidate {
 my ($token_state, %args) = @_;
 my $frame_state = $FRAME_STATE_BY_ADDRESS{$token_state->{frame_address}};
 if (ref($frame_state) eq 'HASH' && $frame_state->{active}) {
  _assign_frame_state($frame_state, $token_state->{snapshot});
 }
 _invalidate($token_state, %args);
 return
}

sub _invalidate {
 my ($token_state, %args) = @_;
 return if $token_state->{state} eq 'invalidated';
 my $authority = $AUTHORITY_STATE_BY_ADDRESS{$token_state->{authority_address}};
 if (ref($authority) eq 'HASH') {
  my $active_address = $authority->{active_token_by_frame}{$token_state->{frame_address}};
  delete $authority->{active_token_by_frame}{$token_state->{frame_address}}
   if defined($active_address) && $active_address == $token_state->{token_address};
 }
 $token_state->{state} = 'invalidated';
 $token_state->{terminal} = defined($args{terminal}) ? "$args{terminal}" : '';
 $token_state->{payload_present} = 0;
 $token_state->{payload} = undef;
 return
}

sub _required_scalar {
 my ($value, $label) = @_;
 _internal_error("$label must be a non-empty scalar")
  unless defined($value) && !ref($value) && length($value);
 return "$value"
}

sub _nonnegative_integer {
 my ($value, $label) = @_;
 _internal_error("$label must be a nonnegative integer")
  unless defined($value) && !ref($value) && $value =~ /\A(?:0|[1-9][0-9]*)\z/;
 return 0 + $value
}

sub _optional_nonnegative_integer {
 my ($value, $label) = @_;
 return undef unless defined $value;
 return _nonnegative_integer($value, $label)
}

sub _throw_diagnostic {
 my (%fields) = @_;
 die LinkedSpec::RecognitionTransaction::Error->new(%fields)
}

sub _internal_error {
 my ($detail) = @_;
 die "(LinkedSpec::RecognitionTransaction) -E- $detail\n"
}

sub DESTROY {
 my ($self) = @_;
 my $address = ref($self) ? refaddr($self) : undef;
 my $authority = defined($address) ? $AUTHORITY_STATE_BY_ADDRESS{$address} : undef;
 if (ref($authority) eq 'HASH') {
  for my $token_address (values %{$authority->{active_token_by_frame}}) {
   my $token_state = $TOKEN_STATE_BY_ADDRESS{$token_address};
   _restore_and_invalidate($token_state, terminal => 'authority_destroyed')
    if ref($token_state) eq 'HASH';
  }
  for my $frame_address (@{$authority->{invocation_stack}}) {
   my $frame_state = $FRAME_STATE_BY_ADDRESS{$frame_address};
   $frame_state->{active} = 0 if ref($frame_state) eq 'HASH';
  }
  delete $AUTHORITY_STATE_BY_ADDRESS{$address};
 }
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::RecognitionTransaction::Frame
# Purpose: Opaque invocation identity and mark-generation handle.
#------------------------------------------------------------------------------
package LinkedSpec::RecognitionTransaction::Frame;

use 5.010;
use strict;
use warnings;

sub DESTROY {
 my ($self) = @_;
 return unless ref($self);
 my $address = Scalar::Util::refaddr($self);
 my $frame_state = $FRAME_STATE_BY_ADDRESS{$address};
 if (ref($frame_state) eq 'HASH' && $frame_state->{active}) {
  my $authority = $AUTHORITY_STATE_BY_ADDRESS{$frame_state->{authority_address}};
  if (ref($authority) eq 'HASH') {
   my $token_address = $authority->{active_token_by_frame}{$address};
   my $token_state = defined($token_address)
    ? $TOKEN_STATE_BY_ADDRESS{$token_address}
    : undef;
   LinkedSpec::RecognitionTransaction::_restore_and_invalidate(
    $token_state,
    terminal => 'frame_destroyed',
   ) if ref($token_state) eq 'HASH';
   @{$authority->{invocation_stack}} = grep {
    $_ != $address
   } @{$authority->{invocation_stack}};
   delete $authority->{active_token_by_frame}{$address};
  }
  $frame_state->{active} = 0;
 }
 delete $FRAME_STATE_BY_ADDRESS{$address};
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::RecognitionTransaction::Token
# Purpose: Opaque linear recognition-transaction handle.
#------------------------------------------------------------------------------
package LinkedSpec::RecognitionTransaction::Token;

use 5.010;
use strict;
use warnings;

sub DESTROY {
 my ($self) = @_;
 my $address = ref($self) ? Scalar::Util::refaddr($self) : undef;
 my $token_state = defined($address) ? $TOKEN_STATE_BY_ADDRESS{$address} : undef;
 if (ref($token_state) eq 'HASH' && $token_state->{state} ne 'invalidated') {
  LinkedSpec::RecognitionTransaction::_restore_and_invalidate(
   $token_state,
   terminal => 'token_destroyed',
  );
 }
 delete $TOKEN_STATE_BY_ADDRESS{$address} if defined $address;
 return
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::RecognitionTransaction::Error
# Purpose: Portable private recognition-transaction diagnostic.
#------------------------------------------------------------------------------
package LinkedSpec::RecognitionTransaction::Error;

use 5.010;
use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %fields) = @_;
 my $self = bless {%fields}, $class;
 Hash::Util::lock_hashref($self);
 return $self
}

sub as_string {
 my ($self) = @_;
 my $code = $self->{code} // 'recognition_transaction_error';
 return "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:$code"
}

1;
