use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $calls = 0;
my $actual = sub { ++$calls; return 'KEY' };
my $deps = {lower_scalar_access_key_expr => $actual};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr = sub { return $_[0]{source} };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_value_binding_source_expr = sub { return 'BOUND' };
 local *LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr = sub { return 'SCALAR' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_push_expr = sub { return 'ARRAY' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_scalar_held_hash_index_assignment_value_node = sub { return undef };
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_mutation_target_is_tracked = sub { return 0 };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_nested_access_assignment_value_node = sub { return 'NESTED' };
 my %expected = (assign_scalar => 'SCALAR', assign_array_append => 'ARRAY',
  assign_hash_index => '$meta{KEY} = VALUE', assign_nested_access => 'NESTED');
 for my $kind (sort keys %expected) {
  is(LinkedSpec::ActionIR::MethodLowering::_lower_ast_assignment_operator_statement(
   {kind => $kind, name => 'meta', key => {kind => 'raw', source => 'key'},
    value => {kind => 'raw', source => 'payload'}}, $deps, $kind),
   $expected{$kind}, "$kind cold controlled native value survives");
 }
}
is($calls, 1, 'cold assignment invokes actual key callback only on hash fallback');
is(refaddr($deps->{lower_scalar_access_key_expr}), refaddr($actual), 'cold assignment keeps actual public callback');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold assignment keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold assignment keeps Trace unloaded');
done_testing;
