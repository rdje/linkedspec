use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [producer=>q{return([str_eq("a","a"),str_ne("a","b"),str_gt("b","a"),str_ge("a","a"),str_lt("a","b"),str_le("a","a"),str_eq("a","b"),str_ne("a","a"),str_gt("a","b"),str_ge("a","b"),str_lt("b","a"),str_le("b","a")])}],
 [eq=>q{return("a".str_eq("a").cat("!"))}],
 [eq_nested=>q{return(cat(str_eq("a","a"),"!"))}],
 [ne=>q{return("a".str_ne("b").cat("!"))}],
 [gt=>q{return("b".str_gt("a").cat("!"))}],
 [ge=>q{return("a".str_ge("a").cat("!"))}],
 [lt=>q{return("a".str_lt("b").cat("!"))}],
 [le=>q{return("a".str_le("a").cat("!"))}],
 [boundaries=>q{return([cat(str_eq(undef,""),"!"),cat(str_eq("",undef),"!"),cat(str_eq("",""),"!"),cat(str_eq("0","0"),"!"),cat(str_eq("a","b"),"!")])}],
 [false_default=>q{return(str_eq("a","b").coalesce_nonempty("late").cat("!"))}],
 [selected=>q{return(["a"].first().str_eq("a").cat("!"))}],
 [pipeline=>q{return(" A ".trim().lowercase().str_eq("a").cat("!"))}],
 [bridge=>q{return("a".str_eq("a").cat(",x").split(",").last().uppercase())}],
 [effects=>q{word="abc";order="";value={order=cat(order,"S");word}.str_eq({order=cat(order,"O");word="zzz";"abc"}).cat({order=cat(order,"C");word=[].first();"!"});return([value,order,word])}],
 [effects_nested=>q{word="abc";order="";value=cat(str_eq({order=cat(order,"S");word},{order=cat(order,"O");word="zzz";"abc"}),{order=cat(order,"C");word=[].first();"!"});return([value,order,word])}],
 [null_order=>q{order="";value=str_eq({order=cat(order,"S");undef},{order=cat(order,"O");"a"});return([value,order])}],
 [missing=>q{order="";value={order=cat(order,"S");"a"}.str_eq().cat("!");return([value,order])}],
 [extra=>q{order="";value={order=cat(order,"S");"a"}.str_eq({order=cat(order,"O");"a"},{order=cat(order,"X");"b"}).cat("!");return([value,order])}],
);
my $n=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';my %ctx;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'native',label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n" if $label eq 'eq';
 if($label =~ /^(?:producer|eq|eq_nested|boundaries|effects_nested|null_order|false_default)$/){
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'string-comparison-result-assessment.spec');my $package='LinkedSpec::StringComparisonResultAssessment'.++$n;
  my $loaded=eval "package $package; $emitted; 1";my $error=$@;my $fresh;
  if($loaded){my $i='x';no strict 'refs';$fresh=eval {&{$package.'::Execute'}(\$i)};$error=$@;}
  print JSON::PP->new->canonical->allow_nonref->encode({route=>'fresh',label=>$label,loaded=>$loaded?1:0,value=>$fresh,error=>$error}),"\n";
 }
}
