use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $calls = 0;
my $actual = sub { ++$calls; return 'target' };
my $deps = {extract_array_symbol_name => $actual};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_value_source_expr = sub { return $_[0]{source} };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub { return 'BINDING' };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_end_expr = sub { return 'INNER' };
 local *LinkedSpec::ActionIR::MethodLowering::_receiver_write_guarded_expr = sub { return 'VALUE' };
 for my $method (qw(push_back push_front pop_back pop_front)) {
  is(LinkedSpec::ActionIR::MethodLowering::_lower_ast_array_end_mutation_method_statement(
   {kind => 'fluent_chain', receiver => {source => 'items', source_span => {start => 0, end => 5}},
    calls => [{method => $method, args => $method =~ /^push_/ ? [{source => 'payload'}] : []}]}, $deps),
   'VALUE', "$method cold controlled native value survives");
 }
}
is($calls, 4, 'cold array-end invokes actual callback once per method');
is(refaddr($deps->{extract_array_symbol_name}), refaddr($actual), 'cold array-end keeps actual public callback');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold array-end keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold array-end keeps Trace unloaded');
done_testing;
