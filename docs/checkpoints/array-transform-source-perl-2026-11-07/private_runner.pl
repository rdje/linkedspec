use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use JSON::PP ();

my ($owner, $test) = @ARGV;
die 'exact owned source image and test required' unless @ARGV == 2
    && $owner eq 'docs/checkpoints/array-transform-source-perl-2026-11-07/control-owner.pm'
    && $test eq 't/array_transform_source_isolation.t';
require "./$owner";
$INC{'LinkedSpec/ActionIR/MethodLowering.pm'} = $owner;
require LinkedSpec;
die 'private owner was replaced' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
open my $file, '<:raw', $owner or die $!;
my $body = do { local $/; <$file> };
close $file or die $!;
print STDERR 'ARRAY_TRANSFORM_SOURCE_OWNER_IMAGE ' . JSON::PP->new->canonical->encode({
    path => $owner, sha256 => sha256_hex($body), bytes => length($body),
}) . "\n";
do "./$test";
die $@ if $@;
die 'private owner changed during test' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
