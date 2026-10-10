use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $actual = sub { return 'VALUE' };
my $deps = {trim_action_ir_value => sub { return $_[0] }, lower_primitive_literal_expr => $actual,
 lower_flow_composite_expr => sub { die 'validation-only flow invoked' }, lower_direct_nested_access_value_expr => sub { return 'VALUE' }};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_expr = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr = sub { return undef };
 is(LinkedSpec::ActionIR::MethodLowering::_lower_block_value_component_expr('source', $deps), 'VALUE',
  'cold component required calls preserve controlled native value');
}
is(refaddr($deps->{lower_primitive_literal_expr}), refaddr($actual), 'cold component keeps actual public callback');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold required component keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold required component keeps Trace unloaded');
done_testing;
