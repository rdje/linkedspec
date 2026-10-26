use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [joined_array=>q{return([].join_values(",").coalesce_nonempty(["a","b"]).join_values("-").uppercase())}],
 [nested_array=>q{return(uppercase(join_values("-",coalesce_nonempty("",["a","b"]))))}],
 [named_hash=>q{meta={"b":"y","a":"x"};return(coalesce_nonempty("",meta))}],
);
my $i=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'default-result-assessment.spec');
 my $package='LinkedSpec::DefaultResultAssessment'.++$i;
 my $loaded=eval "package $package; $emitted; 1";
 die $@ unless $loaded;
 my $input='x';no strict 'refs';my $value=&{$package.'::Execute'}(\$input);
 print $label,' ',JSON::PP->new->canonical->allow_nonref->encode($value),"\n";
}
