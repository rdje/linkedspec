use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $actual = sub { return 'same' };
my $deps = {split_declare_symbol_names => sub { return ['entry'] },
 parse_declare_binding_entry => sub { return {name => 'target', init => 'value'} },
 lower_declare_initializer_expr => $actual};
is(LinkedSpec::ActionIR::MethodLowering::_lower_typed_declare_statement('scalar', 'entry', $deps), 'my $target = same', 'cold declaration required calls preserve native value');
is(refaddr($deps->{lower_declare_initializer_expr}), refaddr($actual), 'cold declaration keeps actual public callback');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold required inference keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold required inference keeps Trace unloaded');
done_testing;
