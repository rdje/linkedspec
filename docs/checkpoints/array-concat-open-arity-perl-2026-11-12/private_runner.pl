use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use JSON::PP ();
my ($owner,$test)=@ARGV;
die 'exact owned overlay and normal required' unless @ARGV == 2
 && $owner eq 'docs/checkpoints/array-concat-open-arity-perl-2026-11-12/control-owner/MethodLowering.pm'
 && $test eq 't/array_concat_open_arity_result_guard_composition.t';
require "./$owner";
$INC{'LinkedSpec/ActionIR/MethodLowering.pm'}=$owner;
require LinkedSpec;
die 'private owner replaced before normal' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
do "./$test";
die $@ if $@;
die 'private owner replaced after normal' unless $INC{'LinkedSpec/ActionIR/MethodLowering.pm'} eq $owner;
