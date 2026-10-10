use strict;
use warnings;
use Test::More;
use JSON::PP ();
use Scalar::Util qw(refaddr);
use LinkedSpec ();
use LinkedSpec::ActionIR::SourceOrigins ();
use LinkedSpec::ActionIR::SourceEmissions ();

my $source = 'items += and(true,false)';
my $ordinary = LinkedSpec::call_spec_handler_subst('Top', $source);
my (@public_calls, $custom);
{
 no warnings 'once';
 local $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr = sub {
  push @public_calls, [@_]; return 'FLOW_OVERRIDE';
 };
 $custom = LinkedSpec::call_spec_handler_subst('Top', $source);
}
sub controlled {
 my ($global, $event) = @_;
 my $state = {global_calls => 0, map_calls => 0, eligible => []};
 my $map_flow = sub {++$state->{map_calls}; return 'MAP_FLOW'};
 my $actual = sub {
  ++$state->{global_calls};
  $state->{args} = [@_];
  $state->{context} = !defined(wantarray) ? 'void' : wantarray ? 'list' : 'scalar';
  push @{$state->{eligible}}, LinkedSpec::ActionIR::SourceEmissions::_eligible_call() ? 1 : 0;
  if ($event) {
   my $builder = LinkedSpec::ActionIR::SourceEmissions::_new_builder($event);
   LinkedSpec::ActionIR::SourceEmissions::_append_generated($builder, 'VALUE');
   LinkedSpec::ActionIR::SourceEmissions::_finish_emission($builder);
  }
  return $event ? 'VALUE' : 'FLOW_OVERRIDE';
 };
 my $deps = {trim_action_ir_value => sub {return $_[0]}, lower_primitive_literal_expr => sub {return undef},
  lower_flow_composite_expr => $map_flow};
 my $call = sub {
  no warnings 'redefine';
  no warnings 'once';
  local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub {return undef};
  local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {return 'METHOD_FALLBACK'};
  local $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr = $global ? $actual : undef;
  return LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr('and(true,false)', $deps);
 };
 return ($call, $actual, $deps, $map_flow, $state);
}
my @controlled;
for my $global (0, 1) {
 my ($call, $actual, $deps, $map_flow, $state) = controlled($global);
 my $value = $call->();
 push @controlled, {global => $global, value => $value, %$state,
  map_identity => refaddr($deps->{lower_flow_composite_expr}) == refaddr($map_flow) ? 1 : 0};
}
my @publication;
for my $known (0, 1) {
 LinkedSpec::ActionIR::SourceOrigins::_with_source_origins('same', sub {
  my $event = {raw => 'same'};
  LinkedSpec::ActionIR::SourceOrigins::_remember_source_origin($event,
   {event => $event, source => 'same', source_span => {start => 0, end => 4}});
  my ($call, $actual, $deps, $map_flow, $state) = controlled(1, $event);
  LinkedSpec::ActionIR::SourceEmissions::_with_emission_producers($known ? [$call, $actual] : [$call], sub {
   my $capture = LinkedSpec::ActionIR::SourceEmissions::_capture_emission($call);
   push @publication, {known => $known, value => $capture->{value}, %$state,
    parent_packet => LinkedSpec::ActionIR::SourceEmissions::_emission_for($capture, $call, $event) ? 1 : 0};
  });
 });
}
my $observed = {ordinary => $ordinary, custom => $custom, public_calls => \@public_calls,
 controlled => \@controlled, publication => \@publication};
if (@ARGV && $ARGV[0] eq 'observe') {print JSON::PP->new->canonical->encode($observed), "\n"; exit 0}

like($ordinary, qr/RuntimeLogical::evaluate\('and'/, 'public Toolbox default mutation retains ordinary logical lowering');
like($custom, qr/push_value\(.*FLOW_OVERRIDE/s, 'public Toolbox mutation reaches package-flow callback');
is_deeply(\@public_calls, [['and(true,false)']], 'public package-flow callback executes once with actual value source');
is($controlled[0]{value}, 'METHOD_FALLBACK', 'map flow callback does not select the legacy package branch');
is($controlled[0]{map_calls}, 0, 'unrelated map callback remains uninvoked');
is($controlled[1]{value}, 'FLOW_OVERRIDE', 'actual package callback controls the legacy branch');
is($controlled[1]{global_calls}, 1, 'controlled package callback executes once');
is($controlled[1]{map_calls}, 0, 'selected package callback does not invoke map callback');
is($controlled[1]{map_identity}, 1, 'legacy branch preserves actual public map callback');
is($controlled[1]{context}, 'scalar', 'legacy package callback receives scalar context');
for my $row (@publication) {
 is($row->{value}, 'VALUE', 'legacy direct callback ordinary value survives');
 is($row->{parent_packet}, 1, 'native direct callback publication currently reaches parent');
 is_deeply($row->{eligible}, [1], 'native direct callback currently borrows enclosing eligibility');
}
done_testing;
