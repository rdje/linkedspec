#------------------------------------------------------------------------------
# Package: LinkedSpec::RuntimeDiagnosticOutput
# Purpose: Parse-scoped diagnostic-output delivery and typed runtime control for
#          generated Perl rule handlers.
#------------------------------------------------------------------------------
package LinkedSpec::RuntimeDiagnosticOutput;

use 5.010;
use strict;
use warnings;

use Scalar::Util qw(blessed refaddr);

our $CONTRACT_ID = 'linkedspec-diagnostic-output-v1';

my $SINK_SLOT = '__linkedspec_runtime_diagnostic_sink';
my $CONTROL_ERROR_SLOT = '__linkedspec_runtime_control_error';
sub sink_slot_name { return $SINK_SLOT }
sub control_error_slot_name { return $CONTROL_ERROR_SLOT }

sub validate_invocation_options {
 my ($options) = @_;
 return undef unless defined $options;
 die LinkedSpec::RuntimeDiagnosticOutput::Error->new(
  code => 'invalid_invocation_options',
  expected => 'hash reference',
  actual => ref($options) || 'scalar',
 ) unless ref($options) eq 'HASH';

 my $sink = $options->{diagnostic_sink};
 return undef unless defined $sink;
 die LinkedSpec::RuntimeDiagnosticOutput::Error->new(
  code => 'invalid_diagnostic_sink',
  expected => 'code reference',
  actual => ref($sink) || 'scalar',
 ) unless ref($sink) eq 'CODE';
 return $sink
}

sub _descriptor_slot {
 my ($descr, $slot) = @_;
 return undef unless ref($descr) eq 'HASH';
 return $descr->{$slot}
}

sub _mark_control_error {
 my ($descr, $error) = @_;
 $descr->{$CONTROL_ERROR_SLOT} = $error if ref($descr) eq 'HASH';
 return $error
}

sub is_marked_control_error {
 my ($descr, $error) = @_;
 return 0 unless ref($descr) eq 'HASH' && exists $descr->{$CONTROL_ERROR_SLOT};
 my $marked = $descr->{$CONTROL_ERROR_SLOT};
 return 0 unless defined($marked) && defined($error);
 if (ref($marked) || ref($error)) {
  return 0 unless ref($marked) && ref($error);
  return refaddr($marked) == refaddr($error) ? 1 : 0
 }
 return $marked eq $error ? 1 : 0
}

sub _diagnostic_text {
 my ($value) = @_;
 return '' unless defined $value;
 if (ref($value)) {
  return $value ? '1' : '0'
   if blessed($value) && $value->isa('JSON::PP::Boolean');
  return ''
 }

 my $text = "$value";
 $text = '0' if $text =~ /\A-0(?:\.0+)?\z/;
 return $text
}

sub _arity_error {
 my (%args) = @_;
 my $error = LinkedSpec::RuntimeDiagnosticOutput::Error->new(
  code => 'helper_arity_mismatch',
  helper_name => $args{helper_name},
  rule_label => $args{rule_label},
  actual_arity => 0 + ($args{actual_arity} // 0),
  expected_arity => $args{expected_arity},
  arguments_evaluated => 0,
 );
 _mark_control_error($args{descriptor}, $error);
 die $error
}

sub helper_arity_mismatch {
 my ($descr, $rule_label, $helper_name, $actual_arity, $expected_arity) = @_;
 _arity_error(
  descriptor => $descr,
  rule_label => $rule_label,
  helper_name => $helper_name,
  actual_arity => $actual_arity,
  expected_arity => $expected_arity,
 )
}

sub _validate_helper_values {
 my ($descr, $rule_label, $helper_name, $values) = @_;
 my $actual_arity = ref($values) eq 'ARRAY' ? scalar(@$values) : 0;
 if ($helper_name eq 'print' || $helper_name eq 'say') {
  _arity_error(
   descriptor => $descr,
   rule_label => $rule_label,
   helper_name => $helper_name,
   actual_arity => $actual_arity,
   expected_arity => 'at least 1 positional argument',
  ) if ref($values) ne 'ARRAY' || $actual_arity < 1;
  return
 }
 if ($helper_name eq 'print_each') {
  _arity_error(
   descriptor => $descr,
   rule_label => $rule_label,
   helper_name => $helper_name,
   actual_arity => $actual_arity,
   expected_arity => '2 or 3 positional arguments',
  ) if ref($values) ne 'ARRAY' || ($actual_arity != 2 && $actual_arity != 3);
  return
 }
 die "unsupported diagnostic-output helper '$helper_name'\n"
}

sub _deliver {
 my ($descr, $event) = @_;
 my $sink = _descriptor_slot($descr, $SINK_SLOT);
 return undef unless ref($sink) eq 'CODE';

 my $ok = eval {
  $sink->($event);
  1
 };
 return undef if $ok;

 my $failure = $@;
 _mark_control_error($descr, $failure);
 die $failure
}

sub emit {
 my ($descr, $rule_label, $helper_name, $values) = @_;
 _validate_helper_values($descr, $rule_label, $helper_name, $values);

 if ($helper_name eq 'print_each') {
  my ($target, $prefix, $suffix) = @$values;
  return undef unless ref($target) eq 'ARRAY';
  my $prefix_text = _diagnostic_text($prefix);
  my $suffix_text = @$values == 3 ? _diagnostic_text($suffix) : '';
  foreach my $item (@$target) {
   _deliver(
    $descr,
    LinkedSpec::RuntimeDiagnosticOutputEvent->new(
     helper_name => $helper_name,
     rule_label => $rule_label,
     message => $prefix_text._diagnostic_text($item).$suffix_text,
    ),
   );
  }
  return undef
 }

 my $message = join('', map { _diagnostic_text($_) } @$values);
 $message .= "\n" if $helper_name eq 'say';
 _deliver(
  $descr,
  LinkedSpec::RuntimeDiagnosticOutputEvent->new(
   helper_name => $helper_name,
   rule_label => $rule_label,
   message => $message,
  ),
 );
 return undef
}

sub terminate {
 my ($descr, $rule_label, $status) = @_;
 $status = 1 unless defined($status) && !ref($status) && $status =~ /\A-?\d+\z/;
 my $error = LinkedSpec::RuntimeExitNow->new(
  status => 0 + $status,
  rule_label => $rule_label,
 );
 _mark_control_error($descr, $error);
 die $error
}

package LinkedSpec::RuntimeDiagnosticOutputEvent;

use strict;
use warnings;

sub new {
 my ($class, %fields) = @_;
 return bless {
  helper_name => defined($fields{helper_name}) ? $fields{helper_name} : '',
  rule_label => defined($fields{rule_label}) ? $fields{rule_label} : '',
  message => defined($fields{message}) ? $fields{message} : '',
 }, $class
}

package LinkedSpec::RuntimeDiagnosticOutput::Error;

use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %fields) = @_;
 return bless {
  kind => 'runtime_diagnostic_output_error',
  %fields,
 }, $class
}

sub as_string {
 my ($self) = @_;
 my $code = $self->{code} // 'runtime_diagnostic_output_error';
 return "LINKEDSPEC_RUNTIME_DIAGNOSTIC_OUTPUT_ERROR:$code"
}

package LinkedSpec::RuntimeExitNow;

use strict;
use warnings;
use overload '""' => 'as_string', fallback => 1;

sub new {
 my ($class, %fields) = @_;
 return bless {
  kind => 'runtime_exit_now',
  status => 0 + ($fields{status} // 1),
  rule_label => defined($fields{rule_label}) ? $fields{rule_label} : '',
 }, $class
}

sub status { return $_[0]{status} }

sub as_string {
 my ($self) = @_;
 return 'LINKEDSPEC_RUNTIME_EXIT_NOW:'.$self->{status}
}

1;
