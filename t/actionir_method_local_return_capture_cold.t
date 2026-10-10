use strict;
use warnings;
use Test::More;
use Scalar::Util qw(refaddr);
use LinkedSpec::ActionIR::MethodLowering ();
my $args = ['payload'];
my $parser = sub { return {method => 'return', args => $args} };
my $normalizer = sub { return $_[0] };
my $deps = {parse_method_function_expr => $parser, normalize_method_args_with_optional_scope => $normalizer};
{
 no warnings 'redefine';
 local *LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr = sub { return 'VALUE' };
 is(LinkedSpec::ActionIR::MethodLowering::_lower_block_local_return_payload_expr('return(payload)', $deps), 'VALUE',
  'cold local return keeps controlled native value');
}
is_deeply([map {refaddr($deps->{$_})} qw(parse_method_function_expr normalize_method_args_with_optional_scope)],
 [refaddr($parser), refaddr($normalizer)], 'cold local return keeps actual public callbacks');
ok(!$INC{'LinkedSpec/ActionIR/SourceEmissions.pm'}, 'cold local return keeps SourceEmissions unloaded');
ok(!$INC{'LinkedSpec/Trace.pm'}, 'cold local return keeps Trace unloaded');
done_testing;
