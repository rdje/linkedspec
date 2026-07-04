#------------------------------------------------------------------------------
# Package: LinkedSpec::ActionIR::Trace
# Purpose: Shared lazy trace formatting for ActionIR owner-internal decisions.
#------------------------------------------------------------------------------
package LinkedSpec::ActionIR::Trace;

use 5.010;
BEGIN {
 require File::Basename;
 my $module_dir = (File::Basename::fileparse(__FILE__))[1];
 my $linked_spec_dir = File::Basename::dirname($module_dir);
 my $perl_root = File::Basename::dirname($linked_spec_dir);
 unshift @INC, $perl_root unless grep { defined($_) && $_ eq $perl_root } @INC;
}

use LinkedSpec::OwnerDispatch ();

use constant {
 DUMP_DEBUG => 500,
};

sub _trace_should_dump {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return 0 unless defined &LinkedSpec::Trace::should_dump;
  return LinkedSpec::Trace::should_dump(@args)
 })
}

sub _trace_enter {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return undef unless exists $INC{'LinkedSpec/Trace.pm'};
  return undef unless defined &LinkedSpec::Trace::trace_enter;
  return LinkedSpec::Trace::trace_enter(@args)
 })
}

sub _trace_exit {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return undef unless exists $INC{'LinkedSpec/Trace.pm'};
  return undef unless defined &LinkedSpec::Trace::trace_exit;
  return LinkedSpec::Trace::trace_exit(@args)
 })
}

sub _trace_decision {
 my @args = @_;
 return LinkedSpec::OwnerDispatch::call_preserving_err(sub {
  return 0 unless exists $INC{'LinkedSpec/Trace.pm'};
  return 0 unless defined &LinkedSpec::Trace::trace_decision;
  return LinkedSpec::Trace::trace_decision(@args)
 })
}

sub _trace_actionir_token {
 my ($value, $fallback) = @_;
 $value = $fallback unless defined($value) && length($value);
 $value = '<unknown>' unless defined($value) && length($value);
 $value =~ s/[^A-Za-z0-9_.:-]+/_/go;
 return $value
}

sub _trace_actionir_value {
 my ($value) = @_;
 return '<undef>' unless defined $value;
 return ref($value) if ref($value);
 $value =~ s/\s+/ /go;
 return $value
}

sub decision {
 my (%args) = @_;
 my $taken = $args{taken} ? 1 : 0;
 my $level = exists($args{level}) ? $args{level} : DUMP_DEBUG;
 return $taken unless _trace_should_dump($level);

 my $owner = _trace_actionir_token($args{owner}, 'owner');
 my $phase = _trace_actionir_token($args{phase}, 'phase');
 my $label = _trace_actionir_token($args{label}, '<unknown>');
 my $decision = _trace_actionir_token($args{decision}, 'decision');
 my @reason = (
  'owner=' . $owner,
  'phase=' . $phase,
  'label=' . $label,
  'decision=' . $decision,
 );
 if (ref($args{context}) eq 'HASH') {
  push @reason, map { $_ . '=' . _trace_actionir_value($args{context}{$_}) } sort keys %{$args{context}};
 }

 return _trace_decision(
  "actionir:$owner:$phase:$label:$decision",
  $taken,
  join("\n", @reason),
  $level,
 )
}

sub enter {
 my (%args) = @_;
 my $level = exists($args{level}) ? $args{level} : DUMP_DEBUG;
 return undef unless _trace_should_dump($level);

 my $package = $args{package};
 $package = 'LinkedSpec::ActionIR' unless defined($package) && length($package);
 my $phase = _trace_actionir_token($args{phase}, 'phase');
 my $label = _trace_actionir_token($args{label}, '<unknown>');
 return _trace_enter(
  "${package}::$phase:$label",
  $args{details},
  $level,
 )
}

sub exit_scope {
 my ($scope, $details, $level) = @_;
 $level = DUMP_DEBUG unless defined $level;
 return _trace_exit($scope, $details, $level)
}

1;
