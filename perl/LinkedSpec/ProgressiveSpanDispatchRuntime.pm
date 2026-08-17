#------------------------------------------------------------------------------
# Package: LinkedSpec::ProgressiveSpanDispatchRuntime
# Purpose: Attach one fresh private progressive authority to a parser invocation
#          and route dedicated ActionIR dispatches through that authority.
#------------------------------------------------------------------------------
package LinkedSpec::ProgressiveSpanDispatchRuntime;

use 5.010;
use strict;
use warnings;

use Scalar::Util qw(blessed);
use LinkedSpec::OwnerDispatch ();
use LinkedSpec::ProgressiveSpanDispatch ();

my $DESCRIPTOR_SLOT = '__linkedspec_progressive_span_dispatch';
my $OPTION_KEY = 'progressive_span_dispatch';
my @CONFIG_FIELDS = qw(
 registry source_id cancellation_token cancelled clock deadline_tick
 remaining_steps max_depth max_calls caller_capabilities required_capabilities
 caller_ceilings required_source_detail dispatch_cost
);

sub descriptor_slot_name { return $DESCRIPTOR_SLOT }
sub option_key { return $OPTION_KEY }

sub begin_invocation {
 my ($input_ref, $options) = @_;
 return undef unless defined $options;
 _internal_error('invocation options must be a hash reference')
  unless ref($options) eq 'HASH';
 return undef unless exists $options->{$OPTION_KEY};

 my $config = $options->{$OPTION_KEY};
 _internal_error("$OPTION_KEY options must be a hash reference")
  unless ref($config) eq 'HASH';
 _internal_error("$OPTION_KEY option fields drifted")
  unless _has_exact_keys($config, \@CONFIG_FIELDS);
 _internal_error('parser input must be a scalar reference')
  unless ref($input_ref) eq 'SCALAR' || ref($input_ref) eq 'REF';

 my $registry = $config->{registry};
 _internal_error('registry must be a progressive registry authority')
  unless blessed($registry)
   && $registry->isa('LinkedSpec::ProgressiveSpanDispatch');
 my $source_id = _required_scalar($config->{source_id}, 'source_id');
 my $invocation = $registry->start_invocation(
  sources => {$source_id => $$input_ref},
  source_id => $source_id,
  cancellation_token => $config->{cancellation_token},
  cancelled => $config->{cancelled},
  clock => $config->{clock},
  deadline_tick => $config->{deadline_tick},
  remaining_steps => $config->{remaining_steps},
  max_depth => $config->{max_depth},
  max_calls => $config->{max_calls},
  active_chain => [],
  total_calls => 0,
 );
 return {
  invocation => $invocation,
  input_ref => $input_ref,
  cancellation_token => $config->{cancellation_token},
  caller_capabilities => _clone_plain($config->{caller_capabilities}),
  required_capabilities => _clone_plain($config->{required_capabilities}),
  caller_ceilings => _clone_plain($config->{caller_ceilings}),
  required_source_detail => _required_scalar(
   $config->{required_source_detail},
   'required_source_detail',
  ),
  dispatch_cost => _nonnegative_integer($config->{dispatch_cost}, 'dispatch_cost'),
 }
}

sub with_invocation {
 my ($descriptor, $input_ref, $options, $callback) = @_;
 _internal_error('descriptor must be a hash reference')
  unless ref($descriptor) eq 'HASH';
 _internal_error('execution callback must be a code reference')
  unless ref($callback) eq 'CODE';
 my $state = begin_invocation($input_ref, $options);
 local $descriptor->{$DESCRIPTOR_SLOT} = $state;
 my $wantarray = wantarray;
 if (!defined $wantarray) {
  $callback->();
  return
 }
 if ($wantarray) {
  my @result = $callback->();
  return @result
 }
 return scalar $callback->()
}

sub dispatch {
 my ($descriptor, $span, $parser_id, $top_rule, $origin) = @_;
 $origin = 'dispatch_span'
  unless defined($origin) && !ref($origin) && length($origin);
 my $state = ref($descriptor) eq 'HASH'
  ? $descriptor->{$DESCRIPTOR_SLOT}
  : undef;
 unless (ref($state) eq 'HASH'
  && blessed($state->{invocation})
  && $state->{invocation}->isa('LinkedSpec::ProgressiveSpanDispatch::Invocation')) {
  LinkedSpec::ProgressiveSpanDispatch::_throw(
   code => 'progressive_registry_missing',
   origin => $origin,
   parser_id => defined($parser_id) && !ref($parser_id) ? $parser_id : '<missing>',
  );
 }

 my $transaction_active_cb = LinkedSpec::OwnerDispatch::require_pkg_cb(
  __PACKAGE__,
  'LinkedSpec::RecognitionTransactionRuntime',
  'transaction_active',
 );
 my $transaction_active = $transaction_active_cb->(
  $descriptor,
  $state->{input_ref},
 );
 return $state->{invocation}->dispatch(
  origin => $origin,
  parser_id => $parser_id,
  top_rule => $top_rule,
  span => $span,
  caller_capabilities => _clone_plain($state->{caller_capabilities}),
  required_capabilities => _clone_plain($state->{required_capabilities}),
  caller_ceilings => _clone_plain($state->{caller_ceilings}),
  required_source_detail => $state->{required_source_detail},
  child_token => $state->{cancellation_token},
  cost => $state->{dispatch_cost},
  transaction_active => $transaction_active,
 )
}

sub is_error {
 return LinkedSpec::ProgressiveSpanDispatch::is_error(@_)
}

sub _has_exact_keys {
 my ($value, $fields) = @_;
 return 0 unless ref($value) eq 'HASH';
 my %expected = map { ($_ => 1) } @$fields;
 return 0 unless keys(%$value) == keys(%expected);
 return !grep { !$expected{$_} } keys %$value
}

sub _clone_plain {
 my ($value) = @_;
 return LinkedSpec::ProgressiveSpanDispatch::Invocation::_clone_plain($value)
}

sub _required_scalar {
 my ($value, $context) = @_;
 _internal_error("$context must be a nonempty scalar")
  unless defined($value) && !ref($value) && length($value);
 return "$value"
}

sub _nonnegative_integer {
 my ($value, $context) = @_;
 _internal_error("$context must be a nonnegative integer")
  unless LinkedSpec::ProgressiveSpanDispatch::_is_nonnegative_integer_scalar($value);
 return 0 + $value
}

sub _internal_error {
 my ($message) = @_;
 die "(LinkedSpec::ProgressiveSpanDispatchRuntime) -E- $message\n"
}

1;
