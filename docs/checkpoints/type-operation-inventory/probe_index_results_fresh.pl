use strict;
use warnings;
use JSON::PP ();
use LinkedSpec ();
my @cases=(
 [direct=>q{parts=["a","b"];return(parts.index_of("b").add(1))}],
 [nested=>q{parts=["a","b"];return(num_add(index_of(parts,"b"),1))}],
 [producer_snapshot=>q{parts=["a"];order="";value={order=cat(order,"S");parts}.index_of({order=cat(order,"N");parts+="b";"b"});return([value,order,parts])}],
 [bare_snapshot=>q{parts=["a"];order="";value=parts.index_of({order=cat(order,"N");parts+="b";"b"});return([value,order,parts])}],
);
my $i=0;
for my $case (@cases) {
 my ($label,$body)=@$case;my $source='Top:: I {'.$body.'}';
 my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'index-result-assessment.spec');
 my $package='LinkedSpec::IndexResultAssessment'.++$i;
 my $loaded=eval "package $package; $emitted; 1";die $@ unless $loaded;
 my $input='x';no strict 'refs';my $value=&{$package.'::Execute'}(\$input);
 print $label,' ',JSON::PP->new->canonical->allow_nonref->encode($value),"\n";
}
