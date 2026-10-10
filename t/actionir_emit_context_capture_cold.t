use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::RuleIR::EmitContext ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'require-only consumer keeps SourceEmissions unloaded');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'require-only consumer keeps Trace unloaded');
my $callback = \&LinkedSpec::RuleIR::EmitContext::_lower_method_value_expr;
is(refaddr(LinkedSpec::RuleIR::EmitContext::_register_builtin_contract_emission_callback($callback)),
 refaddr($callback), 'cold selection returns the same actual native callback');
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold selection keeps SourceEmissions unloaded');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold selection keeps Trace unloaded');
done_testing;
