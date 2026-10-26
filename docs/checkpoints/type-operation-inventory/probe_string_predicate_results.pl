use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [producer=>q{return([starts_with("abc","a"),ends_with("abc","c"),contains_substr("abc","b"),matches("abc",/^a/),starts_with("abc","z"),matches("abc",/^z/)])}],
 [starts=>q{return("abc".starts_with("a").cat("!"))}],
 [starts_nested=>q{return(cat(starts_with("abc","a"),"!"))}],
 [ends=>q{return("abc".ends_with("c").cat("!"))}],
 [ends_nested=>q{return(cat(ends_with("abc","c"),"!"))}],
 [contains=>q{return("abc".contains_substr("b").cat("!"))}],
 [contains_nested=>q{return(cat(contains_substr("abc","b"),"!"))}],
 [matches=>q{return("abc".matches(/^a/).cat("!"))}],
 [matches_nested=>q{return(cat(matches("abc",/^a/),"!"))}],
 [boundaries=>q{return([cat(starts_with(undef,""),"!"),cat(starts_with("", ""),"!"),cat(ends_with("abc",undef),"!"),cat(contains_substr("abc",""),"!"),cat(matches(undef,/^$/),"!"),cat(matches("",/^$/),"!")])}],
 [selected=>q{return(["abc"].first().starts_with("a").cat("!"))}],
 [pipeline=>q{return(" abc ".trim().ends_with("c").cat("!"))}],
 [false_default=>q{return("abc".contains_substr("z").coalesce_nonempty("late").cat("!"))}],
 [bridge=>q{return("abc".matches(/^a/).cat(",x").split(",").last().uppercase())}],
 [effects=>q{word="abc";order="";value={order=cat(order,"S");word}.starts_with({order=cat(order,"O");word="zzz";"a"}).cat({order=cat(order,"C");word=cat(word,"tail");"!"});return([value,order,word])}],
 [effects_nested=>q{word="abc";order="";value=cat(starts_with({order=cat(order,"S");word},{order=cat(order,"O");word="zzz";"a"}),{order=cat(order,"C");word=cat(word,"tail");"!"});return([value,order,word])}],
 [missing=>q{order="";value={order=cat(order,"S");"abc"}.starts_with().cat("!");return([value,order])}],
 [extra=>q{order="";value={order=cat(order,"S");"abc"}.starts_with({order=cat(order,"O");"a"},{order=cat(order,"X");"late"}).cat("!");return([value,order])}],
);
my $n=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';my %ctx;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'native',label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n" if $label eq 'starts';
 if($label =~ /^(?:producer|starts|starts_nested|boundaries|effects_nested)$/){
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'string-predicate-result-assessment.spec');my $package='LinkedSpec::StringPredicateResultAssessment'.++$n;
  my $loaded=eval "package $package; $emitted; 1";my $error=$@;my $fresh;
  if($loaded){my $i='x';no strict 'refs';$fresh=eval {&{$package.'::Execute'}(\$i)};$error=$@;}
  print JSON::PP->new->canonical->allow_nonref->encode({route=>'fresh',label=>$label,loaded=>$loaded?1:0,value=>$fresh,error=>$error}),"\n";
 }
}
