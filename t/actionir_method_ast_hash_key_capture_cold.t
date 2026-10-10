use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $actual = sub { return 'KEY' };
my $deps = {lower_scalar_access_key_expr => $actual};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_hash_index_set_expr = sub { return 'VALUE' };
 is(LinkedSpec::ActionIR::MethodLowering::_lower_ast_scalar_held_hash_index_assignment_value_node(
  {kind => 'assign_hash_index', name => 'item', key => {source => 'key'}, value => {source => 'value'}}, $deps), 'VALUE',
  'cold guarded hash key keeps controlled native value');
}
is(refaddr($deps->{lower_scalar_access_key_expr}), refaddr($actual), 'cold guarded hash key keeps actual public callback');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold guarded hash key keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold guarded hash key keeps Trace unloaded');
done_testing;
