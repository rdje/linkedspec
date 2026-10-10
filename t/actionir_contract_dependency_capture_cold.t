use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::RuleIR::EmitContext ();
use LinkedSpec::ActionIR::Contracts ();

ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold Contracts leaves SourceEmissions unloaded');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold Contracts leaves Trace unloaded');
my $defaults = LinkedSpec::ActionIR::Contracts::default_deps_for_package('LinkedSpec::RuleIR::EmitContext');
is_deeply([map { refaddr($defaults->{$_}) } sort keys %$defaults],
 [map { refaddr(LinkedSpec::RuleIR::EmitContext->can('_'.$_)) } sort keys %$defaults],
 'cold default map retains actual native references');
my $context;
my $actual = sub { $context = defined(wantarray) && !wantarray ? 'scalar' : 'changed'; $_[0] = 'changed'; return 'same' };
my $deps = {map { $_ => $actual } keys %$defaults};
my $bound = LinkedSpec::ActionIR::Contracts::_require_lowering_deps($deps)->{lower_method_value_expr};
my $arg = 'original'; my $value = $bound->($arg);
is_deeply([$value, $arg, $context], ['same', 'changed', 'scalar'], 'cold private binding preserves native aliases and scalar call');
ok(!exists $INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold binding keeps SourceEmissions unloaded');
ok(!exists $INC{'LinkedSpec/Trace.pm'}, 'cold binding keeps Trace unloaded');
done_testing;
