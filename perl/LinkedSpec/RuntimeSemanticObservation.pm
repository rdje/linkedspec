#------------------------------------------------------------------------------
# Package: LinkedSpec::RuntimeSemanticObservation
# Purpose: Invocation-local typed semantic observation delivery for Perl rule
#          handlers, independent of textual trace and diagnostic output.
#------------------------------------------------------------------------------
package LinkedSpec::RuntimeSemanticObservation;

use 5.010;
use strict;
use warnings;

use Digest::SHA qw(sha256_hex);
use Encode qw(encode FB_CROAK LEAVE_SRC);
use Scalar::Util qw(refaddr);

our $CONTRACT_ID = 'linkedspec-semantic-execution-observation-v1';

my $SINK_SLOT = '__linkedspec_runtime_semantic_observation_sink';
my $CONTROL_ERROR_SLOT = '__linkedspec_runtime_semantic_observation_error';

sub sink_slot_name { return $SINK_SLOT }
sub control_error_slot_name { return $CONTROL_ERROR_SLOT }

sub validate_invocation_options {
 my ($options) = @_;
 return undef unless defined $options;
 die LinkedSpec::RuntimeSemanticObservation::Error->new(
  code => 'invalid_invocation_options',
  expected => 'hash reference',
  actual => ref($options) || 'scalar',
 ) unless ref($options) eq 'HASH';

 my $sink = $options->{semantic_observation_sink};
 return undef unless defined $sink;
 die LinkedSpec::RuntimeSemanticObservation::Error->new(
  code => 'invalid_semantic_observation_sink',
  expected => 'code reference',
  actual => ref($sink) || 'scalar',
 ) unless ref($sink) eq 'CODE';
 return $sink
}

sub input_identity {
 my ($input_ref) = @_;
 die LinkedSpec::RuntimeSemanticObservation::Error->new(
  code => 'invalid_semantic_observation_input',
  expected => 'scalar reference',
  actual => ref($input_ref) || 'scalar',
 ) unless ref($input_ref) eq 'SCALAR';
 my $value = defined($$input_ref) ? $$input_ref : '';
 my $bytes = utf8::is_utf8($value)
  ? encode('UTF-8', $value, FB_CROAK | LEAVE_SRC)
  : "$value";
 return 'input:sha256:' . sha256_hex($bytes)
}

sub _descriptor_slot {
 my ($descriptor, $slot) = @_;
 return undef unless ref($descriptor) eq 'HASH';
 return $descriptor->{$slot}
}

sub _mark_control_error {
 my ($descriptor, $error) = @_;
 $descriptor->{$CONTROL_ERROR_SLOT} = $error if ref($descriptor) eq 'HASH';
 return $error
}

sub is_marked_control_error {
 my ($descriptor, $error) = @_;
 return 0 unless ref($descriptor) eq 'HASH' && exists $descriptor->{$CONTROL_ERROR_SLOT};
 my $marked = $descriptor->{$CONTROL_ERROR_SLOT};
 return 0 unless defined($marked) && defined($error);
 if (ref($marked) || ref($error)) {
  return 0 unless ref($marked) && ref($error);
  return refaddr($marked) == refaddr($error) ? 1 : 0
 }
 return $marked eq $error ? 1 : 0
}

sub _deliver {
 my ($descriptor, $event) = @_;
 my $sink = _descriptor_slot($descriptor, $SINK_SLOT);
 return undef unless ref($sink) eq 'CODE';
 my $ok = eval {
  $sink->($event);
  1
 };
 return undef if $ok;
 my $failure = $@;
 _mark_control_error($descriptor, $failure);
 die $failure
}

sub emit_slot_selected {
 my ($descriptor, %args) = @_;
 return undef unless ref(_descriptor_slot($descriptor, $SINK_SLOT)) eq 'CODE';
 return _deliver(
  $descriptor,
  LinkedSpec::RuntimeSemanticObservationEvent->new(
   event_kind => 'regex_slot_selected',
   rule_label => $args{rule_label},
   target_rule => $args{target_rule},
   regex_index => $args{regex_index},
   position => $args{position},
  ),
 )
}

sub emit_rule_result {
 my ($descriptor, %args) = @_;
 return undef unless ref(_descriptor_slot($descriptor, $SINK_SLOT)) eq 'CODE';
 return _deliver(
  $descriptor,
  LinkedSpec::RuntimeSemanticObservationEvent->new(
   event_kind => 'rule_result',
   rule_label => $args{rule_label},
   position => $args{position},
   input_identity => $args{input_identity},
   status => 'succeeded',
  ),
 )
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::RuntimeSemanticObservationEvent
# Purpose: Native typed event captured by a caller-owned semantic sink.
#------------------------------------------------------------------------------
package LinkedSpec::RuntimeSemanticObservationEvent;

use 5.010;
use strict;
use warnings;

sub new {
 my ($class, %args) = @_;
 return bless {
  contract_id => $LinkedSpec::RuntimeSemanticObservation::CONTRACT_ID,
  event_kind => defined($args{event_kind}) ? "$args{event_kind}" : undef,
  rule_label => defined($args{rule_label}) ? "$args{rule_label}" : undef,
  target_rule => defined($args{target_rule}) ? "$args{target_rule}" : undef,
  regex_index => defined($args{regex_index}) ? 0 + $args{regex_index} : undef,
  position => defined($args{position}) ? 0 + $args{position} : undef,
  input_identity => defined($args{input_identity}) ? "$args{input_identity}" : undef,
  status => defined($args{status}) ? "$args{status}" : undef,
 }, $class
}

#------------------------------------------------------------------------------
# Package: LinkedSpec::RuntimeSemanticObservation::Error
# Purpose: Stable typed invocation-option validation failures.
#------------------------------------------------------------------------------
package LinkedSpec::RuntimeSemanticObservation::Error;

use 5.010;
use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %args) = @_;
 return bless {
  code => defined($args{code}) ? "$args{code}" : 'semantic_observation_error',
  expected => defined($args{expected}) ? "$args{expected}" : undef,
  actual => defined($args{actual}) ? "$args{actual}" : undef,
 }, $class
}

sub as_string {
 my ($self) = @_;
 return "LinkedSpec semantic observation error [$self->{code}]\n"
}

1;
