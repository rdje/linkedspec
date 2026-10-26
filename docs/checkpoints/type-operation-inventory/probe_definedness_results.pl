use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [producer=>q{return([is_defined(undef),is_undefined(undef),is_defined(""),is_defined(0),is_defined(false),is_defined([]),is_defined({}),is_undefined("")])}],
 [defined=>q{return("abc".is_defined().cat("!"))}],
 [defined_nested=>q{return(cat(is_defined("abc"),"!"))}],
 [undefined=>q{return([].first().is_undefined().cat("!"))}],
 [undefined_nested=>q{return(cat(is_undefined([].first()),"!"))}],
 [false_result=>q{return(cat(is_defined(undef),"!"))}],
 [false_default=>q{return(is_defined(undef).coalesce_nonempty("late").cat("!"))}],
 [boundaries=>q{return([cat(is_defined(""),"!"),cat(is_defined(false),"!"),cat(is_defined(0),"!"),cat(is_defined([]),"!"),cat(is_defined({}),"!"),cat(is_undefined(undef),"!")])}],
 [selected=>q{return(["abc"].first().is_defined().cat("!"))}],
 [pipeline=>q{return(" abc ".trim().is_defined().cat("!"))}],
 [hash=>q{meta={"a":1};return(meta.is_defined().cat("!"))}],
 [array=>q{items=[];return(items.is_defined().cat("!"))}],
 [bridge=>q{return("abc".is_defined().cat(",x").split(",").last().uppercase())}],
 [effects=>q{word="abc";order="";value={order=cat(order,"S");word}.is_defined().cat({order=cat(order,"C");word="changed";"!"});return([value,order,word])}],
 [effects_nested=>q{word="abc";order="";value=cat(is_defined({order=cat(order,"S");word}),{order=cat(order,"C");word="changed";"!"});return([value,order,word])}],
 [extra=>q{order="";value={order=cat(order,"S");"abc"}.is_defined({order=cat(order,"X");"late"}).cat("!");return([value,order])}],
);
my $n=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';my %ctx;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);my $input='x';my $value=eval {$parser->(\$input)};
 print JSON::PP->new->canonical->allow_nonref->encode({route=>'native',label=>$label,value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
 print 'LOWERED ',LinkedSpec::call_spec_handler_subst('Top',$body),"\n" if $label eq 'defined';
 if($label =~ /^(?:producer|defined|defined_nested|undefined|undefined_nested|boundaries|effects_nested|false_result|false_default)$/){
  my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'definedness-result-assessment.spec');my $package='LinkedSpec::DefinednessResultAssessment'.++$n;
  my $loaded=eval "package $package; $emitted; 1";my $error=$@;my $fresh;
  if($loaded){my $i='x';no strict 'refs';$fresh=eval {&{$package.'::Execute'}(\$i)};$error=$@;}
  print JSON::PP->new->canonical->allow_nonref->encode({route=>'fresh',label=>$label,loaded=>$loaded?1:0,value=>$fresh,error=>$error}),"\n";
 }
}
