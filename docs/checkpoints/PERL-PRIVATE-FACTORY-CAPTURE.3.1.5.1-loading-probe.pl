use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my $key = 'LinkedSpec/ActionIR/MethodLowering.pm';
sub state {return {loaded => exists($INC{$key}) ? 1 : 0,
 callback => LinkedSpec::ActionIR::MethodLowering->can('_lower_return_payload_expr') ? 1 : 0}}
my $before = state();
my $value = LinkedSpec::call_spec_handler_subst('Top', 'return(1)');
print JSON::PP->new->canonical->encode({before => $before, after => state(), value => $value}), "\n";
