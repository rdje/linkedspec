use strict;
use warnings;
use Test::More;
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Contracts ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold constructors leave SourceEmissions unloaded');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold constructors leave Trace unloaded');
my $defaults = LinkedSpec::ActionIR::Contracts::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
my $deps = {map { $_ => sub { return undef } } keys %$defaults};
my $contracts = LinkedSpec::ActionIR::Contracts::build_action_lowering_contracts('ColdFactory', $deps);
is(ref($contracts), 'ARRAY', 'cold constructors return the native public array');
ok(@$contracts && !(grep { ref($_) ne 'HASH' || ref($_->{lower}) ne 'CODE' } @$contracts),
 'cold constructors retain actual public contract hashes and callbacks');
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold factory registration keeps SourceEmissions unloaded');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold factory registration keeps Trace unloaded');
done_testing;
