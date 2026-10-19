package LinkedSpec::PipelineExtraProbe;
use strict;
use warnings;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::RewritePipeline ();

our $TRACE;
sub symbolic {
 push @$TRACE, ['apply', !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $_[0]];
 $_[0] .= ':alias';
 $@ = 'callable successful error';
 return 'LOWERED'
}
{
 package LinkedSpec::PipelineExtraProbe::Overloaded;
 use overload '&{}' => sub {
  push @{$LinkedSpec::PipelineExtraProbe::TRACE}, ['overload'];
  return \&LinkedSpec::PipelineExtraProbe::symbolic
 }, fallback => 1;
}
{
 package LinkedSpec::PipelineExtraProbe::Watch;
 sub DESTROY { push @{$_[0]{trace}}, ['released'] }
}
{
 package LinkedSpec::PipelineExtraProbe::Rule;
 sub TIEHASH { bless {trace => $_[1], kind => $_[2], callback => $_[3]}, $_[0] }
 sub FETCH {
  my ($self, $key) = @_;
  push @{$self->{trace}}, ['fetch', $key];
  return 'probe' if $key eq 'id';
  return undef unless $key eq 'apply';
  if ($self->{kind} eq 'ephemeral') {
   my $watch = bless {trace => $self->{trace}, value => 'LOWERED'},
    'LinkedSpec::PipelineExtraProbe::Watch';
   return sub {
    push @{$watch->{trace}}, ['apply', !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar', $_[0]];
    return $watch->{value}
   }
  }
  return $self->{callback}
 }
}

sub exercise {
 my ($kind) = @_;
 my (@trace, @values, $error, $success_error);
 local $TRACE = \@trace;
 my $callback = $kind eq 'symbolic' ? 'LinkedSpec::PipelineExtraProbe::symbolic'
  : $kind eq 'blessed' ? bless(sub { symbolic(@_) }, 'LinkedSpec::PipelineExtraProbe::Blessed')
  : $kind eq 'overloaded' ? bless({}, 'LinkedSpec::PipelineExtraProbe::Overloaded')
  : $kind eq 'array' ? []
  : $kind eq 'zero' ? 0
  : $kind eq 'missing' ? 'LinkedSpec::PipelineExtraProbe::missing'
  : $kind eq 'undefined' ? undef : sub { symbolic(@_) };
 tie my %rule, 'LinkedSpec::PipelineExtraProbe::Rule', \@trace, $kind, $callback;
 my $rules = [\%rule];
 my $deps = {
  build_action_lowering_contracts => sub { die 'supplied rules must bypass factory' },
  collect_action_helper_ir_nodes => sub {
   push @trace, ['collect', refaddr($_[1]) == refaddr($rules) ? 1 : 0];
   return {helper_action_ir_events => [], helper_action_ir_count => 0}
  },
  build_canonical_action_ir_events => sub {
   push @trace, ['canonical'];
   return {canonical_action_ir_events => [{raw => 'SOURCE', kind => 'PROBE', contract_id => 'probe'}]}
  },
  find_unresolved_action_helpers => sub {
   push @trace, ['find', $_[0], refaddr($_[1]) == refaddr($rules) ? 1 : 0];
   return {unresolved_helper_count => 0}
  },
 };
 my $ok = eval {
  $@ = 'incoming extra error';
  @values = LinkedSpec::ActionIR::RewritePipeline::_rewrite_action_code_with_diagnostics(
   'ExtraLabel', 'SOURCE', $rules, $deps);
  $success_error = $@;
  1
 };
 $error = $@ unless $ok;
 return {kind => $kind, trace => \@trace, values => \@values,
  success => $ok ? 1 : 0, success_error => $success_error, error => $error}
}

sub observations {
 return [map { exercise($_) } qw(code symbolic blessed overloaded array zero missing undefined ephemeral)]
}
unless (caller) {
 print JSON::PP->new->canonical->encode(observations()), "\n";
}
1;
