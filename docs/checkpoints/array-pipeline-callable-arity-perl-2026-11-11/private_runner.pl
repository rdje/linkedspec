use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use JSON::PP ();
my ($owner, $test) = @ARGV;
die 'exact owned image and normal required' unless @ARGV == 2
 && $owner eq '.linkedspec-data/scratch/callable-pipeline-arity-perl/owner.pm'
 && $test eq 't/array_pipeline_callable_arity.t';
require "./$owner";
$INC{'LinkedSpec/ActionIR/MethodLowering.pm'} = $owner;
require LinkedSpec;
die 'private owner replaced' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
open my $fh, '<:raw', $owner or die $!;
my $body = do { local $/; <$fh> }; close $fh or die $!;
print STDERR 'CALLABLE_PIPELINE_ARITY_OWNER ' . JSON::PP->new->canonical->encode({
 path=>$owner, bytes=>length($body), sha256=>sha256_hex($body),
}) . "\n";
do "./$test";
die $@ if $@;
die 'private owner changed' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
