use strict;
use warnings;
use JSON::PP ();
use Data::Dumper ();
use LinkedSpec ();
my @cases=(
 [missing_delimiter=>q{[{effects=num_add(effects,1);parts}.join_values(),effects]}],
 [extra_delimiter=>q{[{effects=num_add(effects,1);parts}.join_values({effects=num_add(effects,1);","},{effects=num_add(effects,1);"!"}),effects]}],
);
for my $case (@cases) {
 my ($label,$expr)=@$case;
 my $source='Top:: I { effects=0;parts=["a","b"];meta={"b":"y","a":"x"}; return('.$expr.'); }';
 my %ctx; my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';
 my $value=$parser->(\$input);
 print $label," ",JSON::PP->new->canonical->allow_nonref->encode($value),"\n";
 if($ctx{last_error}) { local $Data::Dumper::Maxdepth=3;local $Data::Dumper::Sortkeys=1; print Data::Dumper::Dumper($ctx{last_error}); }
}
