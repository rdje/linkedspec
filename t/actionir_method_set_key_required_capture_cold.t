use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'set-key owner loads without SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'set-key owner loads without Trace');
my @events;
my $trim = sub {push @events, 'trim'; return $_[0]};
my $deps = {
 parse_method_function_expr => sub {push @events, 'parse'; return {method => 'set_key', args => ['target', 'key', 'value']}},
 normalize_method_args_with_optional_scope => sub {push @events, 'normalize'; return $_[0]},
 extract_hash_symbol_name => sub {push @events, 'hash'; return 'meta'},
 lower_scalar_access_key_expr => sub {push @events, 'key'; return 'KEY'},
 trim_action_ir_value => $trim,
};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_call_statement = sub {push @events, 'ast'; return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {push @events, 'mutation'; return 'VALUE'};
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_target_symbol = sub {push @events, 'binding'; return undef};
 is(LinkedSpec::ActionIR::MethodLowering::_lower_set_key_statement('set_key(target,key,value)', $deps),
  'do { my $__ls_set_key_key = KEY; my $__ls_set_key_value = VALUE; $meta{$__ls_set_key_key} = $__ls_set_key_value }', 'cold set-key retains controlled fallback result');
 is_deeply(\@events, [qw(ast parse normalize trim trim trim hash key mutation binding)], 'cold callbacks retain native order');
 is(refaddr($deps->{trim_action_ir_value}), refaddr($trim), 'cold public trim reference remains actual');
 for my $role (qw(parse_method_function_expr normalize_method_args_with_optional_scope extract_hash_symbol_name lower_scalar_access_key_expr trim_action_ir_value)) {
  my %invalid = %$deps;
  delete $invalid{$role};
  @events = ();
  my $error;
  eval {LinkedSpec::ActionIR::MethodLowering::_lower_set_key_statement(undef, \%invalid); 1} or $error = $@;
  like($error, qr/missing dependency callback '\Q$role\E'/, "$role cold required diagnostic");
  is_deeply(\@events, [], "$role cold validation precedes undefined input and AST helper");
 }
}
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold calls do not autoload SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold calls do not autoload Trace');
done_testing;
