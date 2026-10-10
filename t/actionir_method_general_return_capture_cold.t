use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'return owners load without SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'return owners load without Trace');
my @events;
my $trim = sub {push @events, 'trim'; return $_[0]};
my $parse = sub {push @events, 'parse'; return {method => 'return', args => ['Node', 'payload']}};
my $deps = {trim_action_ir_value => $trim, parse_method_function_expr => $parse};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {return {kind => 'call'}};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {return 'VALUE'};
 is(LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr('payload', $deps), 'VALUE', 'cold typed payload keeps native direct result');
}
my $ast_calls = 0;
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {++$ast_calls; return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr = sub {return 'VALUE'};
 is(LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement('return(Node,payload)', $deps),
  "return ['?Node:',  VALUE]", 'cold statement retains labeled return result');
 is_deeply(\@events, [qw(trim parse trim)], 'cold return callbacks keep actual native order');
 ok(refaddr($deps->{trim_action_ir_value}) == refaddr($trim)
  && refaddr($deps->{parse_method_function_expr}) == refaddr($parse), 'cold return public callbacks stay actual');
 delete $deps->{parse_method_function_expr};
 my $error; eval {LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement(undef, $deps); 1} or $error = $@;
 like($error, qr/missing dependency callback 'parse_method_function_expr'/, 'cold parser validation precedes undefined source');
 is($ast_calls, 1, 'cold invalid parser stops before AST helper');
 is_deeply(\@events, [qw(trim parse trim)], 'cold invalid parser invokes no callback');
}
delete $deps->{trim_action_ir_value};
is(LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr(undef, $deps), undef,
 'cold undefined payload bypasses missing trim');
my $error; eval {LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr('payload', $deps); 1} or $error = $@;
like($error, qr/missing dependency callback 'trim_action_ir_value'/, 'cold defined payload validates trim');
$deps->{parse_method_function_expr} = $parse;
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {return 'FAST'};
 is(LinkedSpec::ActionIR::MethodLowering::_lower_return_general_statement('anything', $deps), 'FAST',
  'cold AST fast path does not require lazy label trim');
 is_deeply(\@events, [qw(trim parse trim)], 'cold AST fast path does not invoke parser');
}
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold return calls do not autoload SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold return calls do not autoload Trace');
done_testing;
