use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [producer=>q{return([is_empty([]),is_nonempty([]),is_empty(["a"]),is_nonempty(["a"]),is_empty({}),is_nonempty({"a":1})])}],
 [direct_empty=>q{return([].is_empty().cat("!"))}],
 [nested_empty=>q{return(cat(is_empty([]),"!"))}],
 [direct_nonempty=>q{return(["a"].is_nonempty().cat("!"))}],
 [nested_nonempty=>q{return(cat(is_nonempty(["a"]),"!"))}],
 [hash=>q{meta={"a":1};return(meta.is_nonempty().cat("!"))}],
 [selected=>q{return([["a"]].first().is_nonempty().cat("!"))}],
 [pipeline=>q{return(["a"].copy().is_nonempty().cat("!"))}],
 [text_empty=>q{return(cat(is_empty(""),"!"))}],
 [text_nonempty=>q{return(cat(is_nonempty("x"),"!"))}],
 [zero_text=>q{value="0";return([cat(is_nonempty("0"),"!"),cat(is_nonempty(value),"!")])}],
 [null=>q{return(cat(is_empty(undef),"!"))}],
 [effects=>q{parts=[];order="";value={order=cat(order,"S");parts}.is_empty().cat({order=cat(order,"A");parts+="x";"!"});return([value,order,parts])}],
 [effects_nested=>q{parts=[];order="";value=cat(is_empty({order=cat(order,"S");parts}),{order=cat(order,"A");parts+="x";"!"});return([value,order,parts])}],
 [extra=>q{order="";value={order=cat(order,"S");[]}.is_empty({order=cat(order,"X");1}).cat("!");return([value,order])}],
);
my $n=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';my %ctx;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'native',label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n" if $label eq 'direct_empty' || $label eq 'effects_nested';
 if($label =~ /^(?:producer|direct_empty|nested_empty|zero_text|effects_nested)$/){
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'emptiness-result-assessment.spec');my $package='LinkedSpec::EmptinessResultAssessment'.++$n;
  my $loaded=eval "package $package; $emitted; 1";my $error=$@;my $fresh;
  if($loaded){my $i='x';no strict 'refs';$fresh=eval {&{$package.'::Execute'}(\$i)};$error=$@;}
  print JSON::PP->new->canonical->allow_nonref->encode({route=>'fresh',label=>$label,loaded=>$loaded?1:0,value=>$fresh,error=>$error}),"\n";
 }
}
