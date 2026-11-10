use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use JSON::PP ();
my ($owner, $test) = @ARGV;
die 'exact owned image and normal required' unless @ARGV == 2
 && $owner eq '.linkedspec-data/scratch/array-pipeline-composition-perl/owner.pm'
 && $test eq 't/array_pipeline_result_guard_composition.t';
require "./$owner";
$INC{'LinkedSpec/ActionIR/MethodLowering.pm'} = $owner;
require LinkedSpec;
die 'private owner replaced' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
open my $file, '<:raw', $owner or die $!;
my $body = do { local $/; <$file> }; close $file or die $!;
print STDERR 'ARRAY_PIPELINE_COMPOSITION_OWNER_IMAGE ' . JSON::PP->new->canonical->encode({
 path => $owner, bytes => length($body), sha256 => sha256_hex($body),
}) . "\n";
do "./$test";
die $@ if $@;
die 'private owner changed' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
