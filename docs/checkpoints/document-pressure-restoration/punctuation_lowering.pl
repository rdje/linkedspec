use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();

my $json = JSON::PP->new->canonical(1);
for my $source ('return(values.contains)', 'return(values.contains())',
                'return(values.contains("a"))') {
 print $json->encode({source=>$source,
  lowered=>LinkedSpec::call_spec_handler_subst('Top',$source)}),"\n";
}
