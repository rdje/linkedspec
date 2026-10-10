use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my @roles = qw(normalize_method_args_with_optional_scope trim_action_ir_value extract_hash_symbol_name lower_scalar_access_key_expr extract_array_symbol_name lower_primitive_literal_expr);
my %deps = (
 normalize_method_args_with_optional_scope => sub { return $_[0] },
 trim_action_ir_value => sub { return $_[0] },
 extract_hash_symbol_name => sub { return 'meta' },
 lower_scalar_access_key_expr => sub { return 'KEY' },
 extract_array_symbol_name => sub { return 'items' },
 lower_primitive_literal_expr => sub { return 'LITERAL' },
);
my %actual = %deps;
for my $case (['return_undef', [], 'return undef'], ['return', ['LABEL','payload'], "return ['?LABEL:',  VALUE]"],
 ['set_key', ['target','key','value'], '$meta{KEY} = VALUE'], ['push', ['items','payload'], 'push @items, VALUE']) {
 my ($method, $args, $expected) = @$case;
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_actionir_ast_call_arg_sources = sub { return $args };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr = sub { return 'VALUE' };
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub { return undef };
 is(LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement({kind => 'call', name => $method}, undef, \%deps),
  $expected, "cold $method path keeps controlled native value");
}
for my $role (@roles) { is(refaddr($deps{$role}), refaddr($actual{$role}), "cold $role keeps actual public callback") }
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold AST calls keep SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold AST calls keep Trace unloaded');
done_testing;
