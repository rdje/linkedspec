use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [producer=>q{return([has_key(meta,"a"),has_key(meta,"missing"),has_key(meta,"off"),has_key(meta,"nil")])}],
 [direct=>q{return(meta.has_key("a").cat("!"))}],
 [nested=>q{return(cat(has_key(meta,"a"),"!"))}],
 [key_block=>q{return(meta.has_key({order=cat(order,"K");"a"}))}],
 [variable_key=>q{key="a";return(has_key(meta,key))}],
 [helper_key=>q{return(has_key(meta,cat("a","")))}],
);
my $i=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {meta={"a":"x","off":false,"nil":undef};order="";'.$body.'}';
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'has-key-result-assessment.spec');
 my $package='LinkedSpec::HasKeyResultAssessment'.++$i;
 my $loaded=eval "package $package; $emitted; 1";my $error=$@;my $value;
 if($loaded){my $input='x';no strict 'refs';$value=eval {&{$package.'::Execute'}(\$input)};$error=$@;}
 print JSON::PP->new->canonical->allow_nonref->encode({label=>$label,loaded=>$loaded?1:0,value=>$value,error=>$error}),"\n";
}
