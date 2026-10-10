use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'slot owners load without SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'slot owners load without Trace');
my @calls;
my $trim = sub {push @calls, 'trim'; return $_[0]};
my $primitive = sub {push @calls, 'primitive'; return 'VALUE'};
my $deps = {trim_action_ir_value => $trim, lower_primitive_literal_expr => $primitive};
is(LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr('slot', $deps), '$slot',
 'cold bare source result remains native');
is(LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr('1', $deps), 'VALUE',
 'cold mutation primitive result remains native');
is_deeply(\@calls, [qw(trim trim trim primitive)], 'cold actual nested slot invocation order stays native');
ok(refaddr($deps->{trim_action_ir_value}) == refaddr($trim)
 && refaddr($deps->{lower_primitive_literal_expr}) == refaddr($primitive), 'cold public callbacks remain actual');
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold slot calls do not autoload SourceEmissions');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold slot calls do not autoload Trace');
delete $deps->{lower_primitive_literal_expr};
my $error; eval {LinkedSpec::ActionIR::MethodLowering::_lower_mutation_slot_value_expr(undef, $deps); 1} or $error = $@;
like($error, qr/missing dependency callback 'lower_primitive_literal_expr'/,
 'cold mutation validates primitive before undefined input');
delete $deps->{trim_action_ir_value};
eval {LinkedSpec::ActionIR::MethodLowering::_lower_source_slot_bare_scalar_read_expr(undef, $deps); 1} or $error = $@;
like($error, qr/missing dependency callback 'trim_action_ir_value'/, 'cold bare slot validates trim before undefined input');
is_deeply(\@calls, [qw(trim trim trim primitive)], 'cold invalid eager dependencies invoke no callback');
done_testing;
