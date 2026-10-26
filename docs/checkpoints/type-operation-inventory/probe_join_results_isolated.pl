use strict;
use warnings;
use JSON::PP ();
use Data::Dumper ();
use LinkedSpec ();
my @cases=(
 [direct=>q{parts.join_values(",").uppercase()}],
 [nested=>q{uppercase(join_values(",",parts))}],
 [selected=>q{[["a","b"]].first().join_values("-").uppercase()}],
 [selected_nested=>q{uppercase(join_values("-",first([["a","b"]])))}],
 [hash=>q{meta.sorted_values().join_values(":").uppercase()}],
 [hash_nested=>q{uppercase(join_values(":",sorted_values(meta)))}],
);
for my $case (@cases) {
 my ($label,$expr)=@$case;
 my $source='Top:: I { parts=["a","b"];meta={"b":"y","a":"x"}; return('.$expr.'); }';
 my %ctx; my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';
 my $value=$parser->(\$input);
 print $label," ",JSON::PP->new->canonical->allow_nonref->encode($value),"\n";
 if($ctx{last_error}) { local $Data::Dumper::Maxdepth=3;local $Data::Dumper::Sortkeys=1; print Data::Dumper::Dumper($ctx{last_error}); }
}
