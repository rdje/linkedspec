use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [producer=>q{return([contains(["a","b"],"a"),contains(["a","b"],"z"),contains([],"a"),contains([undef],undef),contains([undef],""),contains([""],undef),contains([""],""),contains([0],"0"),contains([false],0)])}],
 [positive=>q{return(["a","b"].contains("a").cat("!"))}],
 [negative=>q{return(["a","b"].contains("z").coalesce_nonempty("late").cat("!"))}],
 [nested=>q{return(cat(contains(["a","b"],"a"),"!"))}],
 [selected=>q{return([["a"]].first().contains("a").cat("!"))}],
 [bridge=>q{return(["a"].contains("a").cat(",x").split(",").last().uppercase())}],
 [generic=>q{return(["a"].contains("z").is_empty().cat("!"))}],
 [incompatible=>q{return(["a"].contains("a").sorted())}],
 [effects=>q{items=["a"];order="";value={order=cat(order,"S");items}.contains({order=cat(order,"O");items=["z"];"a"}).cat({order=cat(order,"C");items=[].first();"!"});return([value,order,items])}],
 [producer_named_effect=>q{items=["a"];order="";value=contains(items,{order=cat(order,"O");items=["z"];"a"});return([value,order,items])}],
 [effects_nested=>q{items=["a"];order="";value=cat(contains({order=cat(order,"S");items},{order=cat(order,"O");items=["z"];"a"}),{order=cat(order,"C");items=[].first();"!"});return([value,order,items])}],
 [null_order=>q{order="";value=contains({order=cat(order,"S");undef},{order=cat(order,"O");"a"});return([value,order])}],
 [missing=>q{order="";value={order=cat(order,"S");["a"]}.contains();return([value,order])}],
 [extra=>q{order="";value={order=cat(order,"S");["a"]}.contains({order=cat(order,"O");"a"},{order=cat(order,"X");"b"});return([value,order])}],
 [missing_twins=>q{items=["a"];return([items.contains,items.contains()])}],
 [missing_bare=>q{items=["a"];return(items.contains)}],
 [missing_parens=>q{items=["a"];return(items.contains())}],
 [missing_nested_bare=>q{items=["a"];return([items.contains])}],
 [missing_nested_parens=>q{items=["a"];return([items.contains()])}],
);
@cases = grep { !@ARGV || $_->[0] eq $ARGV[0] } @cases;
my $n=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';my %ctx;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'native',label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n" if $label =~ /^(?:positive|missing|missing_bare|missing_nested_bare|missing_nested_parens|producer_named_effect)$/;
 if($label =~ /^(?:producer|positive|nested|effects_nested|null_order|negative|missing|extra|missing_twins|missing_bare|missing_parens|missing_nested_bare|missing_nested_parens|producer_named_effect)$/){
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'contains-result-assessment.spec');my $package='LinkedSpec::ContainsResultAssessment'.++$n;
  my $loaded=eval "package $package; $emitted; 1";my $error=$@;my $fresh;
  if($loaded){my $i='x';no strict 'refs';$fresh=eval {&{$package.'::Execute'}(\$i)};$error=$@;}
  print JSON::PP->new->canonical->allow_nonref->encode({route=>'fresh',label=>$label,loaded=>$loaded?1:0,value=>$fresh,error=>$error}),"\n";
 }
}
