use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [hash_return=>q{return(coalesce_nonempty("",{"b":"y","a":"x"}))}],
 [hash_named=>q{meta={"b":"y","a":"x"};return(coalesce_nonempty("",meta))}],
 [hash_tail=>q{value=coalesce_nonempty("",{"b":"y","a":"x"},"late");return(value)}],
 [hash_assignment=>q{value=coalesce_nonempty("",{"b":"y","a":"x"});return(value)}],
 [hash_chain=>q{meta={"b":"y","a":"x"};return([].join_values(",").coalesce_nonempty(meta).sorted_values().join_values(":").uppercase())}],
 [array_return=>q{return("".coalesce_nonempty(["a","b"]).join_values("-").uppercase())}],
 [lazy_return=>q{order=""; result="kept".coalesce_nonempty({order=cat(order,"L");["a"]}).uppercase();return([result,order])}],
 [nested_effects=>q{order="";fallback=["a","b"];result=uppercase(join_values({order=cat(order,"J");"-"},coalesce_nonempty({order=cat(order,"S");""},{order=cat(order,"D");fallback},{order=cat(order,"L");["late"]})));return([result,order,fallback])}],
 [joined_effects=>q{order="";fallback=["a","b"];result=[].join_values({order=cat(order,"S");","}).coalesce_nonempty({order=cat(order,"D");fallback},{order=cat(order,"L");["late"]}).join_values({order=cat(order,"J");"-"}).uppercase();return([result,order,fallback])}],
);
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';
 my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print "LOWERED $label ",LinkedSpec::call_spec_handler_subst('Top',$body),"\n";
}
