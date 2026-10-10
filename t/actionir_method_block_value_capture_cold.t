use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my @keys = qw(trim_action_ir_value split_action_ir_statements parse_method_function_expr normalize_method_args_with_optional_scope);
my $normalizations = 0;
my @actual = (sub { return $_[0] }, sub { return ['source'] }, sub { return {method => 'noop'} },
 sub { ++$normalizations; die 'validation-only normalizer invoked' });
my $deps = {__actionir_ast_block_value_bridge => 1};
@{$deps}{@keys} = @actual;
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_block_value_component_expr = sub { return 'VALUE' };
 is(LinkedSpec::ActionIR::MethodLowering::_lower_block_value_expr('{source}', $deps), 'do { VALUE }',
  'cold block value keeps controlled native value');
}
is_deeply([map {refaddr($deps->{$_})} @keys], [map {refaddr($_)} @actual], 'cold block value keeps actual public callbacks');
is($normalizations, 0, 'cold block value validates normalizer without local invocation');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold block value keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold block value keeps Trace unloaded');
done_testing;
