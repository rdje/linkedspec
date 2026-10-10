use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'push owner loads without SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'push owner loads without Trace');
my @events;
my $trim = sub {push @events, 'trim'; return $_[0]};
my $deps = {
 parse_method_function_expr => sub {push @events, 'parse'; return {method => 'push', args => ['target', '1']}},
 extract_array_symbol_name => sub {push @events, 'array'; return 'items'},
 trim_action_ir_value => $trim,
 lower_primitive_literal_expr => sub {push @events, 'primitive'; return '1'},
};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {push @events, 'ast'; return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub {push @events, 'value'; return 'VALUE'};
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub {push @events, 'binding'; return undef};
 is(LinkedSpec::ActionIR::MethodLowering::_lower_push_statement('push(target,1)', $deps),
  'push @items, VALUE', 'cold push retains controlled fallback result');
 is_deeply(\@events, [qw(ast parse trim trim primitive trim array trim value binding)], 'cold callbacks retain native order');
 is(refaddr($deps->{trim_action_ir_value}), refaddr($trim), 'cold public trim reference remains actual');
 for my $role (qw(parse_method_function_expr extract_array_symbol_name trim_action_ir_value lower_primitive_literal_expr)) {
  my %invalid = %$deps;
  delete $invalid{$role};
  @events = ();
  my $error;
  eval {LinkedSpec::ActionIR::MethodLowering::_lower_push_statement(undef, \%invalid); 1} or $error = $@;
  like($error, qr/missing dependency callback '\Q$role\E'/, "$role cold required diagnostic");
  is_deeply(\@events, [], "$role cold validation precedes undefined input and AST helper");
 }
}
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold calls do not autoload SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold calls do not autoload Trace');
done_testing;
