use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [producer=>q{return([has_key(meta,"a"),has_key(meta,"missing"),has_key(meta,"off"),has_key(meta,"nil")])}],
 [variable_key=>q{key="a";return(has_key(meta,key))}],
 [helper_key=>q{return(has_key(meta,cat("a","")))}],
 [direct=>q{return(meta.has_key("a").cat("!"))}],
 [nested=>q{return(cat(has_key(meta,"a"),"!"))}],
 [missing_key=>q{return(meta.has_key("missing").cat("!"))}],
 [false_stored=>q{return(meta.has_key("off").cat("!"))}],
 [null_stored=>q{return(meta.has_key("nil").cat("!"))}],
 [selected=>q{return([meta].first().has_key("a").cat("!"))}],
 [pipeline=>q{return(meta.copy().has_key("a").cat("!"))}],
 [default_false=>q{return(meta.has_key("missing").coalesce_nonempty("late").cat("!"))}],
 [length=>q{return(meta.has_key("a").length().add(1))}],
 [incompatible=>q{return(meta.has_key("a").sorted_values())}],
 [producer_snapshot=>q{value=meta.has_key({order=cat(order,"K");meta["late"]="new";"late"});return([value,order,meta])}],
 [effects=>q{value={order=cat(order,"S");meta}.has_key({order=cat(order,"K");meta["later"]="new";"a"}).cat({order=cat(order,"A");meta["last"]="new";"!"});return([value,order,meta])}],
 [effects_nested=>q{value=cat(has_key({order=cat(order,"S");meta},{order=cat(order,"K");meta["later"]="new";"a"}),{order=cat(order,"A");meta["last"]="new";"!"});return([value,order,meta])}],
 [missing_arg=>q{value={order=cat(order,"S");meta}.has_key().cat("!");return([value,order])}],
 [extra_arg=>q{value={order=cat(order,"S");meta}.has_key({order=cat(order,"K");"a"},{order=cat(order,"X");"late"}).cat("!");return([value,order])}],
);
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {meta={"a":"x","off":false,"nil":undef};order="";'.$body.'}';
 my %ctx;my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print "LOWERED $label ",LinkedSpec::call_spec_handler_subst('Top',$body),"\n"
  if $label eq 'direct' || $label eq 'producer_snapshot';
}
