use strict;
use warnings;
use File::Path qw(make_path);
use JSON::PP ();
use LinkedSpec ();
my $path='docs/checkpoints/type-operation-inventory/operand-snapshot-membership.spec';
open my $fh,'<',$path or die "$path: $!";my $source;{local $/;$source=<$fh>}close $fh;
my $json=JSON::PP->new->canonical->allow_nonref;
my (%ctx,$dump);my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx,dump_parser_source=>1,parser_source_ref=>\$dump);
my $input='x';my $value=eval {$parser->(\$input)};
print $json->encode({route=>'native',value=>$value,error=>$ctx{last_error},thrown=>"$@"}),"\n";
make_path('.linkedspec-data/verification');
open my $out,'>', '.linkedspec-data/verification/operand-assessment-perl-source.pl' or die $!;print $out $dump;close $out;
my $emitted=LinkedSpec::emit_generated_source(\$source,source_identity=>'operand-snapshot-membership.spec');
my $loaded=eval "package LinkedSpec::OperandSnapshotAssessment; $emitted; 1";my $error=$@;my $fresh;
if($loaded){my $fresh_input='x';$fresh=eval {LinkedSpec::OperandSnapshotAssessment::Execute(\$fresh_input)};$error=$@;}
print $json->encode({route=>'fresh',loaded=>$loaded?1:0,value=>$fresh,error=>$error}),"\n";
