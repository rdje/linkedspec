use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [direct=>q{return(parts.index_of("b").add(1))}],
 [nested=>q{return(num_add(index_of(parts,"b"),1))}],
 [zero=>q{return(parts.index_of("a").add(1))}],
 [absent=>q{return(parts.index_of("z").add(1))}],
 [empty=>q{return([].index_of("a").add(1))}],
 [selected=>q{return([["a","b"]].first().index_of("b").add(1))}],
 [pipeline=>q{return(["b","a"].sorted().index_of("b").add(1))}],
 [from_hash=>q{return(meta.sorted_values().index_of("b").add(1))}],
 [from_string=>q{return("a,b".split(",").index_of("b").add(1))}],
 [string_result=>q{return(parts.index_of("b").cat("!"))}],
 [incompatible=>q{return(parts.index_of("b").sorted())}],
 [producer_snapshot=>q{parts=["a"];value={order=cat(order,"S");parts}.index_of({order=cat(order,"N");parts+="b";"b"});return([value,order,parts])}],
 [bare_snapshot=>q{parts=["a"];value=parts.index_of({order=cat(order,"N");parts+="b";"b"});return([value,order,parts])}],
 [effects=>q{value={order=cat(order,"S");parts}.index_of({order=cat(order,"N");parts+="c";"b"}).add({order=cat(order,"A");parts+="d";1});return([value,order,parts])}],
 [effects_nested=>q{value=num_add(index_of({order=cat(order,"S");parts},{order=cat(order,"N");parts+="c";"b"}),{order=cat(order,"A");parts+="d";1});return([value,order,parts])}],
 [missing=>q{value={order=cat(order,"S");parts}.index_of().add(1);return([value,order])}],
 [extra=>q{value={order=cat(order,"S");parts}.index_of({order=cat(order,"N");"b"},{order=cat(order,"X");"late"}).add(1);return([value,order])}],
);
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I { parts=["a","b"];meta={"a":"a","b":"b"};order="";'.$body.' }';
 my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print "LOWERED $label ",LinkedSpec::call_spec_handler_subst('Top',$body),"\n"
  if $label eq 'direct' || $label eq 'from_hash' || $label eq 'producer_snapshot' || $label eq 'bare_snapshot';
}
