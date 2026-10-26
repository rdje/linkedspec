use strict;
use warnings;
use LinkedSpec ();
use JSON::PP ();
for my $body (
 q{seen=0;bad=and({seen=num_add(seen,1);true}).sorted();return([bad,seen])},
 q{seen=0;bad=sorted(and({seen=num_add(seen,1);true}));return([bad,seen])},
) {
 my $source='Top:: I {'.$body.'}';
 my %context;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%context);
 my $input='x';
 my $value=$parser->(\$input);
 print JSON::PP->new->canonical->encode({value=>$value,error=>$context{last_error}}),"\n";
 print LinkedSpec::call_spec_handler_subst('Top',$body),"\n";
}
