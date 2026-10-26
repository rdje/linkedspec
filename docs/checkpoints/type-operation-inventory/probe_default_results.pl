use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [helper_array=>q{coalesce_nonempty("",["a","b"])}],
 [helper_empty_array=>q{coalesce_nonempty("",[],["late"])}],
 [helper_hash=>q{coalesce_nonempty("",{"b":"y","a":"x"})}],
 [receiver_array=>q{"".coalesce_nonempty(["a","b"])}],
 [array=>q{"".coalesce_nonempty(["a","b"]).join_values("-").uppercase()}],
 [joined_array=>q{[].join_values(",").coalesce_nonempty(["a","b"]).join_values("-").uppercase()}],
 [array_nested=>q{uppercase(join_values("-",coalesce_nonempty(join_values(",",[]),["a","b"])))}],
 [hash=>q{[].join_values(",").coalesce_nonempty({"b":"y","a":"x"}).sorted_values().join_values(":").uppercase()}],
 [hash_nested=>q{uppercase(join_values(":",sorted_values(coalesce_nonempty("",{"b":"y","a":"x"}))))}],
 [retained_scalar=>q{["kept"].join_values(",").coalesce_nonempty(["a","b"]).uppercase()}],
 [incompatible_scalar=>q{["kept"].join_values(",").coalesce_nonempty(["a","b"]).sorted()}],
 [selected_null=>q{[].first().coalesce_nonempty(["a","b"]).join_values("-").uppercase()}],
 [null_tail=>q{[].join_values(",").coalesce_nonempty(undef,"").uppercase()}],
 [lazy=>q{["kept"].join_values(",").coalesce_nonempty({order=cat(order,"L");["a"]}).uppercase()}],
 [effects=>q{{order=cat(order,"S");""}.coalesce_nonempty({order=cat(order,"D");["a","b"]},{order=cat(order,"L");["late"]}).join_values({order=cat(order,"J");"-"}).uppercase()}],
);
for my $case (@cases) {
 my ($label,$expr)=@$case;
 my $source='Top:: I { order=""; value='.$expr.'; return([value,order]); }';
 my %ctx; my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx); my $input='x';
 my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 if ($label eq 'joined_array' || $label eq 'hash' || $label eq 'incompatible_scalar') {
  print "LOWERED $label ", LinkedSpec::call_spec_handler_subst('Top','return('.$expr.')'),"\n";
 }
}
