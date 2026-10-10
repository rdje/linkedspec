use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'method owner loads without SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'method owner loads without Trace');
my @roles = qw(trim_action_ir_value split_action_ir_statements parse_method_function_expr
 normalize_method_args_with_optional_scope lower_direct_nested_access_value_expr
 extract_array_symbol_name extract_hash_symbol_name extract_scalar_symbol_name
 lower_scalar_access_key_expr lower_primitive_literal_expr infer_scalar_container_kind
 split_top_level_csv lower_array_pipeline_expr strip_literal_delimiters);
my (@calls, %deps);
for my $role (@roles) {
 $deps{$role} = sub {
  push @calls, $role;
  return $_[0] if $role eq 'trim_action_ir_value';
  return 'VALUE' if $role eq 'lower_primitive_literal_expr';
  die 'unexpected cold required invocation';
 };
}
$deps{__actionir_ast_value_lowering_compat_bridge} = 1;
$deps{lower_declare_initializer_expr} = 'unreachable non-CODE';
my %original = map {$_ => $deps{$_}} @roles;
is(LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr('PLAIN', \%deps), 'VALUE',
 'cold primitive early result survives');
is_deeply(\@calls, [qw(trim_action_ir_value lower_primitive_literal_expr)], 'cold invocation order stays native');
ok(!grep(refaddr($deps{$_}) != refaddr($original{$_}), @roles), 'cold public callback references stay actual');
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold invocation does not autoload SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold invocation does not autoload Trace');
is(LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr(undef, \%deps), undef,
 'cold undefined guard follows validation');
is_deeply(\@calls, [qw(trim_action_ir_value lower_primitive_literal_expr)], 'cold undefined input invokes no callback');
delete $deps{infer_scalar_container_kind};
my $error; eval {LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr(undef, \%deps); 1} or $error = $@;
like($error, qr/missing dependency callback 'infer_scalar_container_kind'/,
 'cold locally unused role remains required before undefined guard');
done_testing;
