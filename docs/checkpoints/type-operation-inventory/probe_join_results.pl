use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @sources=(<<'PAIRS', <<'ORDER');
Top:: I {
 parts=["a","b"];meta={"b":"y","a":"x"};
 return([parts.join_values(",").uppercase(),uppercase(join_values(",",parts)),[["a","b"]].first().join_values("-").uppercase(),uppercase(join_values("-",first([["a","b"]]))),meta.sorted_values().join_values(":").uppercase(),uppercase(join_values(":",sorted_values(meta)))]);
}
PAIRS
Top:: I {
 items=["a","b"];order="";
 joined={order=cat(order,"S");items}.join_values({order=cat(order,"D");items+="c";","});
 bare=["x","y"];named=bare.join_values({order=cat(order,"N");bare+="z";"-"});
 return([joined,order,items,named,bare]);
}
ORDER
for my $source (@sources) {
 my %ctx; my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';
 my $value=$parser->(\$input);
 print JSON::PP->new->canonical->encode($value),"\n";
 print "last_error=",defined($ctx{last_error}) ? $ctx{last_error} : "none","\n";
}
print LinkedSpec::call_spec_handler_subst("Top",q{return(["a","b"].join_values(",").uppercase())}),"\n";
