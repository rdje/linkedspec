use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'assignment owners load without SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'assignment owners load without Trace');
my @events;
my $trim = sub {push @events, 'trim'; return $_[0]};
my $deps = {
 trim_action_ir_value => $trim,
 extract_scalar_symbol_name => sub {push @events, 'scalar'; return undef},
 extract_array_symbol_name => sub {push @events, 'array'; return 'ITEMS'},
 extract_hash_symbol_name => sub {push @events, 'hash'; return undef},
 lower_assignment_source_expr => sub {push @events, 'source'; return 'VALUE'},
 lower_declare_initializer_expr => sub {push @events, $_[0]; return 'INIT'},
};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_parse_method_value_ast_expr = sub {push @events, 'parse'; return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_ast_assignment_operator_statement = sub {push @events, $_[2]; return undef};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_value_binding_source_expr = sub {push @events, 'binding'; return 'BOUND'};
 local *LinkedSpec::ActionIR::MethodLowering::_tracked_scalar_assignment_expr = sub {return 'TRACKED'};
 local *LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr = sub {push @events, 'mutation'; return 'VALUE'};
 local *LinkedSpec::ActionIR::MethodLowering::_uniform_binding_array_push_expr = sub {return 'PUSH'};
 is(LinkedSpec::ActionIR::MethodLowering::_lower_assign_statement('legacy target', 'payload', $deps),
  '@ITEMS = INIT', 'cold wrapper retains controlled array result');
 is_deeply(\@events, [qw(trim scalar array array)], 'cold wrapper preserves native callback order');
 @events = ();
 is(LinkedSpec::ActionIR::MethodLowering::_lower_scalar_assignment_operator_statement('counter = payload', $deps),
  'TRACKED', 'cold scalar operator retains result');
 is_deeply(\@events, [qw(trim parse assign_scalar trim binding)], 'cold scalar operator trims twice in native order');
 @events = ();
 is(LinkedSpec::ActionIR::MethodLowering::_lower_array_append_operator_statement('items += payload', $deps),
  'PUSH', 'cold append operator retains result');
 is_deeply(\@events, [qw(trim parse assign_array_append trim mutation)], 'cold append trims twice in native order');
 ok(refaddr($deps->{trim_action_ir_value}) == refaddr($trim), 'cold public trim reference stays actual');
 for my $owner (qw(_lower_assign_statement _lower_scalar_assignment_operator_statement _lower_array_append_operator_statement)) {
  @events = ();
  my $error;
  my $callback = LinkedSpec::ActionIR::MethodLowering->can($owner);
  eval {$owner eq '_lower_assign_statement' ? $callback->(undef, undef, {}) : $callback->(undef, {}); 1} or $error = $@;
  like($error, qr/missing dependency callback/, "$owner cold eager validation survives undefined input");
  is_deeply(\@events, [], "$owner cold validation stops before helpers");
 }
}
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold calls do not autoload SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold calls do not autoload Trace');
done_testing;
