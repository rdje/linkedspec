use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $actual = sub { return 'COND' };
my $deps = {normalize_method_args_with_optional_scope => sub { return $_[0] },
 parse_method_function_expr => sub { return {method => 'else', args => ['fallback']} },
 lower_flow_composite_expr => $actual};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_runtime_typed_truthiness_expr = sub { return 'COND' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_inline_value_branch_payload_expr = sub { return 'VALUE' };
 is(LinkedSpec::ActionIR::MethodLowering::_lower_inline_if_value_expr({method => 'if', args => ['COND','THEN','else']}, $deps),
  'do { my $__ls_if_value; if (COND) { $__ls_if_value = VALUE; } else { $__ls_if_value = VALUE; } $__ls_if_value }',
  'cold inline required calls preserve controlled native value');
}
is(refaddr($deps->{lower_flow_composite_expr}), refaddr($actual), 'cold inline keeps actual public callback');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold required inline keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold required inline keeps Trace unloaded');
done_testing;
